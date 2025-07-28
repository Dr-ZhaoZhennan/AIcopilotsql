#pragma once
#include <string>
#include <vector>

// AI模型配置结构体
struct AIModelConfig {
    std::string name;      // 模型名称
    std::string url;       // API端点URL
    std::string api_key;   // API密钥
    std::string model_id;  // 模型ID
};

// 加载AI配置文件
bool load_ai_config(const std::string& path, std::vector<AIModelConfig>& models);

// 调用AI接口
std::string call_ai(const std::string& prompt, const AIModelConfig& model);
