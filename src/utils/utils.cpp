#include "utils.h"
#include <algorithm>
#include <sstream>
#include <iomanip>
#include <random>
#include <chrono>

namespace Utils {

// 字符串分割
std::vector<std::string> split(const std::string& str, char delimiter) {
    std::vector<std::string> tokens;
    std::stringstream ss(str);
    std::string token;
    
    while (std::getline(ss, token, delimiter)) {
        if (!token.empty()) {
            tokens.push_back(token);
        }
    }
    
    return tokens;
}

// 字符串去首尾空格
std::string trim(const std::string& str) {
    size_t start = str.find_first_not_of(" \t\n\r");
    if (start == std::string::npos) {
        return "";
    }
    
    size_t end = str.find_last_not_of(" \t\n\r");
    return str.substr(start, end - start + 1);
}

// 字符串转小写
std::string to_lower(const std::string& str) {
    std::string result = str;
    std::transform(result.begin(), result.end(), result.begin(), ::tolower);
    return result;
}

// 检查字符串是否包含子串
bool contains(const std::string& str, const std::string& substr) {
    return str.find(substr) != std::string::npos;
}

// 格式化时间
std::string format_time(double seconds) {
    if (seconds < 1.0) {
        return std::to_string(static_cast<int>(seconds * 1000)) + "ms";
    } else if (seconds < 60.0) {
        return std::to_string(static_cast<int>(seconds)) + "s";
    } else {
        int minutes = static_cast<int>(seconds / 60);
        int remaining_seconds = static_cast<int>(seconds) % 60;
        return std::to_string(minutes) + "m " + std::to_string(remaining_seconds) + "s";
    }
}

// 生成唯一ID
std::string generate_uuid() {
    static std::random_device rd;
    static std::mt19937 gen(rd());
    static std::uniform_int_distribution<> dis(0, 15);
    static const char* hex_chars = "0123456789abcdef";
    
    std::string uuid;
    uuid.reserve(36);
    
    for (int i = 0; i < 36; ++i) {
        if (i == 8 || i == 13 || i == 18 || i == 23) {
            uuid += '-';
        } else {
            uuid += hex_chars[dis(gen)];
        }
    }
    
    return uuid;
}

// 检查字符串是否为数字
bool is_numeric(const std::string& str) {
    if (str.empty()) return false;
    
    size_t start = 0;
    if (str[0] == '-' || str[0] == '+') {
        start = 1;
        if (str.length() == 1) return false;
    }
    
    bool has_digit = false;
    bool has_dot = false;
    
    for (size_t i = start; i < str.length(); ++i) {
        if (str[i] == '.') {
            if (has_dot) return false;
            has_dot = true;
        } else if (std::isdigit(str[i])) {
            has_digit = true;
        } else {
            return false;
        }
    }
    
    return has_digit;
}

// 字符串替换
std::string replace(const std::string& str, const std::string& from, const std::string& to) {
    std::string result = str;
    size_t pos = 0;
    while ((pos = result.find(from, pos)) != std::string::npos) {
        result.replace(pos, from.length(), to);
        pos += to.length();
    }
    return result;
}

// 字符串连接
std::string join(const std::vector<std::string>& strings, const std::string& delimiter) {
    if (strings.empty()) return "";
    
    std::string result = strings[0];
    for (size_t i = 1; i < strings.size(); ++i) {
        result += delimiter + strings[i];
    }
    return result;
}

// 获取当前时间戳
long long get_timestamp() {
    auto now = std::chrono::system_clock::now();
    auto duration = now.time_since_epoch();
    return std::chrono::duration_cast<std::chrono::milliseconds>(duration).count();
}

// 格式化文件大小
std::string format_file_size(size_t bytes) {
    const char* units[] = {"B", "KB", "MB", "GB", "TB"};
    int unit_index = 0;
    double size = static_cast<double>(bytes);
    
    while (size >= 1024.0 && unit_index < 4) {
        size /= 1024.0;
        unit_index++;
    }
    
    std::ostringstream oss;
    oss << std::fixed << std::setprecision(2) << size << " " << units[unit_index];
    return oss.str();
}

} // namespace Utils
