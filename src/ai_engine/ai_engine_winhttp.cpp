#include <ai_engine.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <string>
#include <windows.h>
#include <winhttp.h>
#include <nlohmann/json.hpp>

#pragma comment(lib, "winhttp.lib")

using json = nlohmann::json;

bool load_ai_config(const std::string& path, std::vector<AIModelConfig>& models) {
    std::ifstream fin(path);
    if (!fin.is_open()) return false;
    json j;
    fin >> j;
    if (!j.contains("models")) return false;
    for (const auto& m : j["models"]) {
        AIModelConfig cfg;
        cfg.name = m.value("name", "");
        cfg.url = m.value("url", "");
        cfg.api_key = m.value("api_key", "");
        cfg.model_id = m.value("model_id", "");
        models.push_back(cfg);
    }
    return !models.empty();
}

// 简单的JSON解析函数（如果nlohmann/json不可用）
std::string extract_content_from_json(const std::string& json_str) {
    // 简单的正则匹配，查找 "content": "..." 模式
    size_t pos = json_str.find("\"content\":");
    if (pos == std::string::npos) return "[AI回复解析失败]";
    
    pos = json_str.find("\"", pos + 10);
    if (pos == std::string::npos) return "[AI回复解析失败]";
    
    size_t start = pos + 1;
    size_t end = json_str.find("\"", start);
    if (end == std::string::npos) return "[AI回复解析失败]";
    
    return json_str.substr(start, end - start);
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
    
    // 构造请求体
    json body;
    body["model"] = model.model_id;
    body["messages"] = {
        { {"role", "system"}, {"content", "你是GaussDB SQL优化专家。请根据用户输入的SQL和EXPLAIN(ANALYZE)结果，输出详细优化建议和优化后SQL。"} },
        { {"role", "user"}, {"content", prompt} }
    };
    body["stream"] = false;
    std::string body_str = body.dump();
    
    // 发送请求
    BOOL bResults = WinHttpSendRequest(hRequest, WINHTTP_NO_ADDITIONAL_HEADERS, 0,
                                      (LPVOID)body_str.c_str(), body_str.length(),
                                      body_str.length(), 0);
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
    try {
        auto j = json::parse(response);
        if (j.contains("choices") && j["choices"].size() > 0 && j["choices"][0]["message"].contains("content")) {
            return j["choices"][0]["message"]["content"].get<std::string>();
        } else {
            return "[AI回复解析失败] " + response;
        }
    } catch (...) {
        return "[AI回复JSON解析异常] " + response;
    }
} 