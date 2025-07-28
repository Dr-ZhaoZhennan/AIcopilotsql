#include <ai_engine.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <windows.h>
#include <winhttp.h>

#pragma comment(lib, "winhttp.lib")

// 简单的JSON解析函数
std::string extract_json_value(const std::string& json_str, const std::string& key) {
    std::string search_key = "\"" + key + "\":";
    size_t pos = json_str.find(search_key);
    if (pos == std::string::npos) return "";
    
    pos = json_str.find("\"", pos + search_key.length());
    if (pos == std::string::npos) return "";
    
    size_t start = pos + 1;
    size_t end = json_str.find("\"", start);
    if (end == std::string::npos) return "";
    
    return json_str.substr(start, end - start);
}

bool load_ai_config(const std::string& path, std::vector<AIModelConfig>& models) {
    std::ifstream fin(path);
    if (!fin.is_open()) return false;
    
    std::string content((std::istreambuf_iterator<char>(fin)),
                        std::istreambuf_iterator<char>());
    
    // 简单的JSON解析
    size_t pos = content.find("\"models\"");
    if (pos == std::string::npos) return false;
    
    pos = content.find("[", pos);
    if (pos == std::string::npos) return false;
    
    size_t end_pos = content.find("]", pos);
    if (end_pos == std::string::npos) return false;
    
    std::string models_str = content.substr(pos + 1, end_pos - pos - 1);
    
    // 解析每个模型配置
    size_t model_start = 0;
    while ((model_start = models_str.find("{", model_start)) != std::string::npos) {
        size_t model_end = models_str.find("}", model_start);
        if (model_end == std::string::npos) break;
        
        std::string model_str = models_str.substr(model_start, model_end - model_start + 1);
        
        AIModelConfig cfg;
        cfg.name = extract_json_value(model_str, "name");
        cfg.url = extract_json_value(model_str, "url");
        cfg.api_key = extract_json_value(model_str, "api_key");
        cfg.model_id = extract_json_value(model_str, "model_id");
        
        if (!cfg.name.empty() && !cfg.url.empty() && !cfg.api_key.empty() && !cfg.model_id.empty()) {
            models.push_back(cfg);
        }
        
        model_start = model_end + 1;
    }
    
    return !models.empty();
}

std::string call_ai(const std::string& prompt, const AIModelConfig& model) {
    // 解析URL
    std::string url = model.url;
    std::string host, path;
    
    // 简单的URL解析
    if (url.find("https://") == 0) {
        url = url.substr(8);
    } else if (url.find("http://") == 0) {
        url = url.substr(7);
    }
    
    size_t slash_pos = url.find('/');
    if (slash_pos != std::string::npos) {
        host = url.substr(0, slash_pos);
        path = url.substr(slash_pos);
    } else {
        host = url;
        path = "/";
    }
    
    // 初始化WinHTTP
    HINTERNET hSession = WinHttpOpen(L"SQL AI Copilot/1.0", 
                                    WINHTTP_ACCESS_TYPE_DEFAULT_PROXY,
                                    WINHTTP_NO_PROXY_NAME, 
                                    WINHTTP_NO_PROXY_BYPASS, 0);
    if (!hSession) return "[AI调用失败] WinHTTP初始化失败";
    
    // 连接到服务器
    HINTERNET hConnect = WinHttpConnect(hSession, 
                                       std::wstring(host.begin(), host.end()).c_str(),
                                       INTERNET_DEFAULT_HTTPS_PORT, 0);
    if (!hConnect) {
        WinHttpCloseHandle(hSession);
        return "[AI调用失败] 无法连接到服务器";
    }
    
    // 创建请求
    HINTERNET hRequest = WinHttpOpenRequest(hConnect, L"POST",
                                           std::wstring(path.begin(), path.end()).c_str(),
                                           NULL, WINHTTP_NO_REFERER,
                                           WINHTTP_DEFAULT_ACCEPT_TYPES,
                                           WINHTTP_FLAG_SECURE);
    if (!hRequest) {
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "[AI调用失败] 无法创建HTTP请求";
    }
    
    // 设置请求头
    std::wstring auth_header = L"Authorization: Bearer " + std::wstring(model.api_key.begin(), model.api_key.end());
    std::wstring content_header = L"Content-Type: application/json";
    
    WinHttpAddRequestHeaders(hRequest, auth_header.c_str(), -1, WINHTTP_ADDREQ_FLAG_ADD);
    WinHttpAddRequestHeaders(hRequest, content_header.c_str(), -1, WINHTTP_ADDREQ_FLAG_ADD);
    
    // 构造请求体（简化JSON）
    std::string body = "{"
        "\"model\":\"" + model.model_id + "\","
        "\"messages\":["
            "{\"role\":\"system\",\"content\":\"你是GaussDB SQL优化专家。请根据用户输入的SQL和EXPLAIN(ANALYZE)结果，输出详细优化建议和优化后SQL。\"},"
            "{\"role\":\"user\",\"content\":\"" + prompt + "\"}"
        "],"
        "\"stream\":false"
    "}";
    
    // 发送请求
    BOOL bResults = WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                                      (LPVOID)body.c_str(), body.length(),
                                      body.length(), 0);
    if (!bResults) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "[AI调用失败] 发送请求失败";
    }
    
    // 接收响应
    bResults = WinHttpReceiveResponse(hRequest, NULL);
    if (!bResults) {
        WinHttpCloseHandle(hRequest);
        WinHttpCloseHandle(hConnect);
        WinHttpCloseHandle(hSession);
        return "[AI调用失败] 接收响应失败";
    }
    
    // 读取响应数据
    std::string response;
    DWORD dwSize = 0;
    DWORD dwDownloaded = 0;
    LPSTR pszOutBuffer;
    
    do {
        dwSize = 0;
        if (!WinHttpQueryDataAvailable(hRequest, &dwSize)) break;
        
        pszOutBuffer = new char[dwSize + 1];
        if (!pszOutBuffer) break;
        
        ZeroMemory(pszOutBuffer, dwSize + 1);
        
        if (!WinHttpReadData(hRequest, (LPVOID)pszOutBuffer, dwSize, &dwDownloaded)) {
            delete[] pszOutBuffer;
            break;
        }
        
        response.append(pszOutBuffer, dwDownloaded);
        delete[] pszOutBuffer;
        
    } while (dwSize > 0);
    
    // 清理资源
    WinHttpCloseHandle(hRequest);
    WinHttpCloseHandle(hConnect);
    WinHttpCloseHandle(hSession);
    
    // 解析响应
    std::string content = extract_json_value(response, "content");
    if (!content.empty()) {
        return content;
    } else {
        return "[AI回复解析失败] " + response;
    }
} 