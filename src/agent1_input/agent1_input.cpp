#include "agent1_input.h"
#include <iostream>

InputData receive_user_input() {
    InputData input;
    std::cout << "请输入SQL语句（单行，回车结束）：" << std::endl;
    std::getline(std::cin, input.sql);
    std::cout << "请输入EXPLAIN(ANALYZE)结果（多行，输入END或#END或连续两次空行结束）：" << std::endl;
    std::string line, explain;
    int empty_count = 0;
    while (true) {
        std::getline(std::cin, line);
        if (line == "END" || line == "#END") break;
        if (line.empty()) {
            empty_count++;
            if (empty_count >= 2) break;
            continue;
        } else {
            empty_count = 0;
        }
        explain += line + "\n";
    }
    input.explain_result = explain;
    return input;
}

bool validate_input(const InputData& input) {
    return !input.sql.empty() && !input.explain_result.empty();
}
