#pragma once
#include <string>

struct InputData {
    std::string sql;
    std::string explain_result;
};

InputData receive_user_input();
bool validate_input(const InputData& input);
