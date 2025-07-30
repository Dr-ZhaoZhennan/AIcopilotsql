#ifndef AI_ENGINE_H
#define AI_ENGINE_H

#include <string>
#include <vector>
#include <memory>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// AI模型配置结构
struct AIModelConfig {
    std::string name;
    std::string type;  // "ollama" 或 "api"
    std::string endpoint;
    std::string description;
    json parameters;
    
    // API相关字段
    std::string url;
    std::string api_key;
    std::string model_id;
};

// Ollama配置结构
struct OllamaConfig {
    std::string host;
    int port;
    int timeout;
    int retry_count;
};

// API配置结构
struct APIConfig {
    int timeout;
    int retry_count;
    std::string user_agent;
};

// AI引擎类
class AIEngine {
public:
    AIEngine();
    ~AIEngine();
    
    // 加载AI配置
    bool loadConfig(const std::string& config_file);
    
    // 调用AI模型
    std::string callAI(const std::string& prompt, const std::string& model_name = "");
    
    // 获取可用模型列表
    std::vector<std::string> getAvailableModels();
    
    // 获取模型详细信息
    std::vector<AIModelConfig> getModelConfigs();
    
    // 根据索引选择模型
    AIModelConfig* selectModelByIndex(int index);
    
    // 检查Ollama服务状态
    bool checkOllamaService();
    
    // 启动Ollama服务
    bool startOllamaService();
    
    // 停止Ollama服务
    bool stopOllamaService();

private:
    std::vector<AIModelConfig> models_;
    OllamaConfig ollama_config_;
    APIConfig api_config_;
    std::string default_model_;
    
    // 内部方法
    std::string callOllamaModel(const std::string& prompt, const AIModelConfig& model);
    std::string callAPIModel(const std::string& prompt, const AIModelConfig& model);
    std::string makeOllamaRequest(const std::string& prompt, const AIModelConfig& model);
    std::string makeAPIRequest(const std::string& prompt, const AIModelConfig& model);
    bool parseOllamaResponse(const std::string& response, std::string& result);
    bool parseAPIResponse(const std::string& response, std::string& result);
    std::string escapeJsonString(const std::string& str);
    std::string makeHTTPRequest(const std::string& url, const std::string& method, 
                               const std::string& headers, const std::string& body);
};

// 全局AI引擎实例
extern std::unique_ptr<AIEngine> g_ai_engine;

// 便捷函数
bool load_ai_config(const std::string& config_file, std::vector<AIModelConfig>& models);
std::string call_ai(const std::string& prompt, const AIModelConfig& model);

#endif // AI_ENGINE_H
