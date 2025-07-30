#include "../../include/ai_engine.h"
#include <fstream>
#include <iostream>
#include <sstream>
#include <cstdlib>
#include <cstring>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <netdb.h>
#include <sys/wait.h>
#include <regex>

// 全局AI引擎实例
std::unique_ptr<AIEngine> g_ai_engine = std::make_unique<AIEngine>();

AIEngine::AIEngine() {
    // 构造函数
}

AIEngine::~AIEngine() {
    // 析构函数
}

bool AIEngine::loadConfig(const std::string& config_file) {
    try {
        std::ifstream file(config_file);
        if (!file.is_open()) {
            std::cerr << "无法打开配置文件: " << config_file << std::endl;
            return false;
        }
        
        json config;
        file >> config;
        
        // 解析模型配置
        if (config.contains("models") && config["models"].is_array()) {
            for (const auto& model_config : config["models"]) {
                AIModelConfig model;
                model.name = model_config["name"];
                model.type = model_config["type"];
                model.endpoint = model_config["endpoint"];
                model.description = model_config["description"];
                model.parameters = model_config["parameters"];
                
                // 解析API相关字段
                if (model_config.contains("url")) {
                    model.url = model_config["url"];
                }
                if (model_config.contains("api_key")) {
                    model.api_key = model_config["api_key"];
                }
                if (model_config.contains("model_id")) {
                    model.model_id = model_config["model_id"];
                }
                
                models_.push_back(model);
            }
        }
        
        // 解析默认模型
        if (config.contains("default_model")) {
            default_model_ = config["default_model"];
        }
        
        // 解析Ollama配置
        if (config.contains("ollama_config")) {
            auto& ollama = config["ollama_config"];
            ollama_config_.host = ollama["host"];
            ollama_config_.port = ollama["port"];
            ollama_config_.timeout = ollama["timeout"];
            ollama_config_.retry_count = ollama["retry_count"];
        }
        
        // 解析API配置
        if (config.contains("api_config")) {
            auto& api = config["api_config"];
            api_config_.timeout = api["timeout"];
            api_config_.retry_count = api["retry_count"];
            api_config_.user_agent = api["user_agent"];
        }
        
        std::cout << "已加载 " << models_.size() << " 个AI模型配置" << std::endl;
        return true;
        
    } catch (const std::exception& e) {
        std::cerr << "配置文件解析错误: " << e.what() << std::endl;
        return false;
    }
}

std::string AIEngine::callAI(const std::string& prompt, const std::string& model_name) {
    // 选择模型
    AIModelConfig* selected_model = nullptr;
    
    if (!model_name.empty()) {
        for (auto& model : models_) {
            if (model.name == model_name) {
                selected_model = &model;
                break;
            }
        }
    }
    
    if (!selected_model && !default_model_.empty()) {
        for (auto& model : models_) {
            if (model.name == default_model_) {
                selected_model = &model;
                break;
            }
        }
    }
    
    if (!selected_model && !models_.empty()) {
        selected_model = &models_[0];
    }
    
    if (!selected_model) {
        return "错误: 未找到可用的AI模型";
    }
    
    // 根据模型类型调用不同的方法
    if (selected_model->type == "ollama") {
        // 检查Ollama服务
        if (!checkOllamaService()) {
            std::cout << "Ollama服务未运行，正在启动..." << std::endl;
            if (!startOllamaService()) {
                return "错误: 无法启动Ollama服务";
            }
        }
        return callOllamaModel(prompt, *selected_model);
    } else if (selected_model->type == "api") {
        return callAPIModel(prompt, *selected_model);
    } else {
        return "错误: 不支持的模型类型: " + selected_model->type;
    }
}

std::vector<std::string> AIEngine::getAvailableModels() {
    std::vector<std::string> model_names;
    for (const auto& model : models_) {
        model_names.push_back(model.name);
    }
    return model_names;
}

std::vector<AIModelConfig> AIEngine::getModelConfigs() {
    return models_;
}

AIModelConfig* AIEngine::selectModelByIndex(int index) {
    if (index >= 0 && index < static_cast<int>(models_.size())) {
        return &models_[index];
    }
    return nullptr;
}

bool AIEngine::checkOllamaService() {
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return false;
    }
    
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(ollama_config_.port);
    server_addr.sin_addr.s_addr = inet_addr(ollama_config_.host.c_str());
    
    int result = connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr));
    close(sock);
    
    return result == 0;
}

bool AIEngine::startOllamaService() {
    // 检查是否已经在运行
    if (checkOllamaService()) {
        return true;
    }
    
    // 启动Ollama服务
    pid_t pid = fork();
    if (pid == 0) {
        // 子进程
        execlp("ollama", "ollama", "serve", nullptr);
        exit(1);
    } else if (pid > 0) {
        // 父进程，等待服务启动
        sleep(3);
        return checkOllamaService();
    }
    
    return false;
}

bool AIEngine::stopOllamaService() {
    system("pkill -f 'ollama serve'");
    return true;
}

std::string AIEngine::callOllamaModel(const std::string& prompt, const AIModelConfig& model) {
    std::string request = makeOllamaRequest(prompt, model);
    
    // 创建HTTP请求
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return "错误: 无法创建socket连接";
    }
    
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(ollama_config_.port);
    server_addr.sin_addr.s_addr = inet_addr(ollama_config_.host.c_str());
    
    if (connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        close(sock);
        return "错误: 无法连接到Ollama服务";
    }
    
    // 发送HTTP请求
    if (send(sock, request.c_str(), request.length(), 0) < 0) {
        close(sock);
        return "错误: 发送请求失败";
    }
    
    // 接收响应
    std::string response;
    char buffer[4096];
    int bytes_received;
    
    while ((bytes_received = recv(sock, buffer, sizeof(buffer) - 1, 0)) > 0) {
        buffer[bytes_received] = '\0';
        response += buffer;
    }
    
    close(sock);
    
    // 解析响应
    std::string result;
    if (parseOllamaResponse(response, result)) {
        return result;
    } else {
        return "错误: 解析AI响应失败\n原始响应: " + response;
    }
}

std::string AIEngine::callAPIModel(const std::string& prompt, const AIModelConfig& model) {
    try {
        std::string request = makeAPIRequest(prompt, model);
        
        // 解析URL
        std::regex url_regex(R"((https?)://([^:/]+)(?::(\d+))?(/.*)?)");
        std::smatch url_match;
        
        if (!std::regex_match(model.url, url_match, url_regex)) {
            return "错误: 无效的API URL";
        }
        
        std::string protocol = url_match[1];
        std::string host = url_match[2];
        std::string port_str = url_match[3];
        std::string path = url_match[4];
        
        int port = 443; // 默认HTTPS端口
        if (!port_str.empty()) {
            port = std::stoi(port_str);
        } else if (protocol == "http") {
            port = 80;
        }
        
        // 构建HTTP请求头
        std::ostringstream headers;
        headers << "Host: " << host << "\r\n";
        headers << "Content-Type: application/json\r\n";
        headers << "Authorization: Bearer " << model.api_key << "\r\n";
        headers << "User-Agent: " << api_config_.user_agent << "\r\n";
        headers << "Accept: application/json\r\n";
        headers << "Connection: close\r\n";
        headers << "Content-Length: " << request.length() << "\r\n";
        
        // 发送HTTP请求
        std::string response = makeHTTPRequest(model.url, "POST", headers.str(), request);
        
        // 检查HTTP状态码
        if (response.find("HTTP_STATUS:200") == std::string::npos && 
            response.find("HTTP_STATUS:201") == std::string::npos) {
            // 提取状态码
            size_t status_pos = response.find("HTTP_STATUS:");
            if (status_pos != std::string::npos) {
                size_t status_start = status_pos + 12;
                size_t status_end = response.find("\n", status_start);
                std::string status_code = response.substr(status_start, status_end - status_start);
                return "错误: API请求失败，状态码: " + status_code;
            }
            return "错误: API请求失败，无法解析状态码";
        }
        
        // 解析响应
        std::string result;
        if (parseAPIResponse(response, result)) {
            return result;
        } else {
            return "错误: 解析API响应失败，请检查网络连接和API配置";
        }
    } catch (const std::exception& e) {
        return "错误: API调用异常 - " + std::string(e.what());
    }
}

std::string AIEngine::makeOllamaRequest(const std::string& prompt, const AIModelConfig& model) {
    json request;
    request["model"] = model.name;
    request["prompt"] = prompt;
    request["stream"] = false;
    
    // 添加参数
    if (model.parameters.contains("temperature")) {
        request["options"]["temperature"] = model.parameters["temperature"];
    }
    if (model.parameters.contains("max_tokens")) {
        request["options"]["num_predict"] = model.parameters["max_tokens"];
    }
    if (model.parameters.contains("top_p")) {
        request["options"]["top_p"] = model.parameters["top_p"];
    }
    
    std::string json_str = request.dump();
    
    std::ostringstream http_request;
    http_request << "POST /api/generate HTTP/1.1\r\n";
    http_request << "Host: " << ollama_config_.host << ":" << ollama_config_.port << "\r\n";
    http_request << "Content-Type: application/json\r\n";
    http_request << "Content-Length: " << json_str.length() << "\r\n";
    http_request << "\r\n";
    http_request << json_str;
    
    return http_request.str();
}

std::string AIEngine::makeAPIRequest(const std::string& prompt, const AIModelConfig& model) {
    json request;
    request["model"] = model.model_id;
    request["stream"] = false;
    
    // 构建消息数组
    json messages = json::array();
    
    // 添加系统消息
    json system_message;
    system_message["role"] = "system";
    system_message["content"] = "你是一个专业的SQL优化专家，专门分析GaussDB的SQL查询和执行计划，提供优化建议。";
    messages.push_back(system_message);
    
    // 添加用户消息
    json user_message;
    user_message["role"] = "user";
    user_message["content"] = prompt;
    messages.push_back(user_message);
    
    request["messages"] = messages;
    
    // 添加参数
    if (model.parameters.contains("temperature")) {
        request["temperature"] = model.parameters["temperature"];
    }
    if (model.parameters.contains("max_tokens")) {
        request["max_tokens"] = model.parameters["max_tokens"];
    }
    if (model.parameters.contains("top_p")) {
        request["top_p"] = model.parameters["top_p"];
    }
    
    return request.dump();
}

bool AIEngine::parseOllamaResponse(const std::string& response, std::string& result) {
    try {
        // 分离HTTP头部和JSON体
        size_t json_start = response.find("\r\n\r\n");
        if (json_start == std::string::npos) {
            return false;
        }
        
        std::string json_body = response.substr(json_start + 4);
        json response_json = json::parse(json_body);
        
        if (response_json.contains("response")) {
            result = response_json["response"];
            return true;
        }
        
        return false;
    } catch (const std::exception& e) {
        std::cerr << "JSON解析错误: " << e.what() << std::endl;
        return false;
    }
}

bool AIEngine::parseAPIResponse(const std::string& response, std::string& result) {
    try {
        // 查找JSON响应的开始位置
        size_t json_start = response.find("{");
        if (json_start == std::string::npos) {
            return false;
        }
        
        // 提取JSON部分（从第一个{到最后一个}）
        size_t json_end = response.rfind("}");
        if (json_end == std::string::npos) {
            return false;
        }
        
        std::string json_body = response.substr(json_start, json_end - json_start + 1);
        json response_json = json::parse(json_body);
        
        // 检查是否有错误
        if (response_json.contains("error")) {
            result = "API错误: " + response_json["error"]["message"].get<std::string>();
            return false;
        }
        
        // 解析成功响应
        if (response_json.contains("choices") && response_json["choices"].is_array() && 
            !response_json["choices"].empty()) {
            auto& choice = response_json["choices"][0];
            if (choice.contains("message") && choice["message"].contains("content")) {
                result = choice["message"]["content"];
                return true;
            }
        }
        
        return false;
    } catch (const std::exception& e) {
        std::cerr << "API响应解析错误: " << e.what() << std::endl;
        return false;
    }
}

std::string AIEngine::makeHTTPRequest(const std::string& url, const std::string& method, 
                                     const std::string& headers, const std::string& body) {
    // 对于HTTPS请求，使用curl命令
    std::regex url_regex(R"((https?)://([^:/]+)(?::(\d+))?(/.*)?)");
    std::smatch url_match;
    
    if (!std::regex_match(url, url_match, url_regex)) {
        return "错误: 无效的URL";
    }
    
    std::string protocol = url_match[1];
    
    // 如果是HTTPS，使用curl
    if (protocol == "https") {
        // 创建临时文件存储请求体
        std::string temp_file = "/tmp/api_request_" + std::to_string(getpid()) + ".json";
        std::ofstream temp_out(temp_file);
        temp_out << body;
        temp_out.close();
        
        // 构建curl命令
        std::ostringstream curl_cmd;
        curl_cmd << "curl -s -w '\\nHTTP_STATUS:%{http_code}\\n' ";
        curl_cmd << "-H 'Content-Type: application/json' ";
        
        // 添加自定义头部
        std::istringstream header_stream(headers);
        std::string line;
        while (std::getline(header_stream, line)) {
            if (!line.empty() && line != "\r") {
                // 移除\r\n
                line = line.substr(0, line.find("\r"));
                if (!line.empty()) {
                    curl_cmd << "-H '" << line << "' ";
                }
            }
        }
        
        curl_cmd << "-d @" << temp_file << " " << url;
        
        // 执行curl命令
        FILE* pipe = popen(curl_cmd.str().c_str(), "r");
        if (!pipe) {
            std::remove(temp_file.c_str());
            return "错误: 无法执行curl命令";
        }
        
        std::string response;
        char buffer[4096];
        while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
            response += buffer;
        }
        
        pclose(pipe);
        std::remove(temp_file.c_str());
        return response;
    }
    
    // 对于HTTP请求，使用socket（简化实现）
    std::string host = url_match[2];
    std::string port_str = url_match[3];
    std::string path = url_match[4];
    
    int port = 80;
    if (!port_str.empty()) {
        port = std::stoi(port_str);
    }
    
    // 创建socket连接
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    if (sock < 0) {
        return "错误: 无法创建socket";
    }
    
    struct sockaddr_in server_addr;
    server_addr.sin_family = AF_INET;
    server_addr.sin_port = htons(port);
    
    // 解析主机名
    struct hostent* he = gethostbyname(host.c_str());
    if (he == nullptr) {
        close(sock);
        return "错误: 无法解析主机名";
    }
    server_addr.sin_addr = *((struct in_addr*)he->h_addr);
    
    if (connect(sock, (struct sockaddr*)&server_addr, sizeof(server_addr)) < 0) {
        close(sock);
        return "错误: 无法连接到服务器";
    }
    
    // 构建HTTP请求
    std::ostringstream http_request;
    http_request << method << " " << path << " HTTP/1.1\r\n";
    http_request << "Host: " << host << "\r\n";
    http_request << "Content-Type: application/json\r\n";
    http_request << "Content-Length: " << body.length() << "\r\n";
    if (!headers.empty()) {
        http_request << headers;
    }
    http_request << "\r\n";
    http_request << body;
    
    // 发送请求
    std::string request_str = http_request.str();
    if (send(sock, request_str.c_str(), request_str.length(), 0) < 0) {
        close(sock);
        return "错误: 发送请求失败";
    }
    
    // 接收响应
    std::string response;
    char buffer[4096];
    int bytes_received;
    
    while ((bytes_received = recv(sock, buffer, sizeof(buffer) - 1, 0)) > 0) {
        buffer[bytes_received] = '\0';
        response += buffer;
    }
    
    close(sock);
    return response;
}

std::string AIEngine::escapeJsonString(const std::string& str) {
    std::string escaped;
    for (char c : str) {
        switch (c) {
            case '"': escaped += "\\\""; break;
            case '\\': escaped += "\\\\"; break;
            case '\n': escaped += "\\n"; break;
            case '\r': escaped += "\\r"; break;
            case '\t': escaped += "\\t"; break;
            default: escaped += c; break;
        }
    }
    return escaped;
}

// 便捷函数实现
bool load_ai_config(const std::string& config_file, std::vector<AIModelConfig>& models) {
    try {
        std::ifstream file(config_file);
        if (!file.is_open()) {
            std::cerr << "无法打开配置文件: " << config_file << std::endl;
            return false;
        }
        
        json config;
        file >> config;
        
        // 解析模型配置
        if (config.contains("models") && config["models"].is_array()) {
            for (const auto& model_config : config["models"]) {
                AIModelConfig model;
                model.name = model_config["name"];
                model.type = model_config["type"];
                model.endpoint = model_config["endpoint"];
                model.description = model_config["description"];
                model.parameters = model_config["parameters"];
                
                // 解析API相关字段
                if (model_config.contains("url")) {
                    model.url = model_config["url"];
                }
                if (model_config.contains("api_key")) {
                    model.api_key = model_config["api_key"];
                }
                if (model_config.contains("model_id")) {
                    model.model_id = model_config["model_id"];
                }
                
                models.push_back(model);
            }
        }
        
        // 同时更新全局AI引擎的模型配置
        if (g_ai_engine) {
            g_ai_engine->loadConfig(config_file);
        }
        
        return !models.empty();
        
    } catch (const std::exception& e) {
        std::cerr << "配置文件解析错误: " << e.what() << std::endl;
        return false;
    }
}

std::string call_ai(const std::string& prompt, const AIModelConfig& model) {
    return g_ai_engine->callAI(prompt, model.name);
}
