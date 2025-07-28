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
    
    // 检查字符串是否为数字
    bool is_numeric(const std::string& str);
    
    // 字符串替换
    std::string replace(const std::string& str, const std::string& from, const std::string& to);
    
    // 字符串连接
    std::string join(const std::vector<std::string>& strings, const std::string& delimiter);
    
    // 获取当前时间戳
    long long get_timestamp();
    
    // 格式化文件大小
    std::string format_file_size(size_t bytes);
}
