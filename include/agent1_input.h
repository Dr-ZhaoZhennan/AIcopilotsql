#pragma once
#include <string>

// 用户输入数据结构
struct InputData {
    std::string sql;           // SQL语句
    std::string explain_result; // EXPLAIN(ANALYZE)结果
};

// 接收用户输入（多行输入处理）
InputData receive_user_input();

// 验证输入数据的有效性
bool validate_input(const InputData& input);
