#pragma once
#include <string>
#include <vector>
#include <sstream>

// 字符串工具函数
namespace Utils {
    // 字符串分割
    std::vector<std::string> split(const std::string& str, char delimiter);
    
    // 字符串去首尾空格
    std::string trim(const std::string& str);
    
    // 字符串转小写
    std::string to_lower(const std::string& str);
    
    // 检查字符串是否包含子串
    bool contains(const std::string& str, const std::string& substr);
    
    // 格式化时间
    std::string format_time(double seconds);
    
    // 生成唯一ID
    std::string generate_uuid();
}
