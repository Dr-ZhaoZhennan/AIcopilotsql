#include <ai_engine.h>
#include <fstream>
#include <sstream>
#include <iostream>
#include <nlohmann/json.hpp>
#include <curl/curl.h>

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

// libcurl回调，收集AI回复
static size_t WriteCallback(void* contents, size_t size, size_t nmemb, void* userp) {
    ((std::string*)userp)->append((char*)contents, size * nmemb);
    return size * nmemb;
}

std::string call_ai(const std::string& prompt, const AIModelConfig& model) {
    CURL* curl = curl_easy_init();
    if (!curl) return "[AI调用失败] curl初始化失败";
    std::string readBuffer;
    struct curl_slist* headers = NULL;
    headers = curl_slist_append(headers, ("Authorization: Bearer " + model.api_key).c_str());
    headers = curl_slist_append(headers, "Content-Type: application/json");

    // 构造OpenAI兼容body
    json body;
    body["model"] = model.model_id;
    body["messages"] = {
        { {"role", "system"}, {"content", "你是GaussDB SQL优化专家。请根据用户输入的SQL和EXPLAIN(ANALYZE)结果，输出详细优化建议和优化后SQL。"} },
        { {"role", "user"}, {"content", prompt} }
    };
    body["stream"] = false;
    std::string body_str = body.dump();

    curl_easy_setopt(curl, CURLOPT_URL, model.url.c_str());
    curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, body_str.c_str());
    curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, WriteCallback);
    curl_easy_setopt(curl, CURLOPT_WRITEDATA, &readBuffer);
    CURLcode res = curl_easy_perform(curl);
    curl_slist_free_all(headers);
    curl_easy_cleanup(curl);
    if (res != CURLE_OK) {
        return std::string("[AI调用失败] ") + curl_easy_strerror(res);
    }
    // 解析AI回复
    try {
        auto j = json::parse(readBuffer);
        if (j.contains("choices") && j["choices"].size() > 0 && j["choices"][0]["message"].contains("content")) {
            return j["choices"][0]["message"]["content"].get<std::string>();
        } else {
            return "[AI回复解析失败] " + readBuffer;
        }
    } catch (...) {
        return "[AI回复JSON解析异常] " + readBuffer;
    }
}
