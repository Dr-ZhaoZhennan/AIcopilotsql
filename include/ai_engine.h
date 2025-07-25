#pragma once
#include <string>
#include <vector>

struct AIModelConfig {
    std::string name;
    std::string url;
    std::string api_key;
    std::string model_id;
};

bool load_ai_config(const std::string& path, std::vector<AIModelConfig>& models);
std::string call_ai(const std::string& prompt, const AIModelConfig& model);
