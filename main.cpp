#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <algorithm>
#include <agent1_input.h>
#include <agent2_diagnose.h>
#include <agent3_strategy.h>
#include <agent4_report.h>
#include <agent5_interactive.h>
#include <ai_engine.h>

// 辅助函数：多行输入，END/#END/两次空行结束
std::string multiline_input(const std::string& prompt, bool allow_exit = false) {
    std::cout << prompt << std::endl;
    std::string result, line;
    int empty_count = 0;
    while (true) {
        std::getline(std::cin, line);
        std::string lower_line = line;
        std::transform(lower_line.begin(), lower_line.end(), lower_line.begin(), ::tolower);
        if (allow_exit && (lower_line == "exit" || lower_line == "quit")) {
            return "__USER_EXIT__";
        }
        if (line == "END" || line == "#END") break;
        if (line.empty()) {
            empty_count++;
            if (empty_count >= 2) break;
            continue;
        } else {
            empty_count = 0;
        }
        result += line + "\n";
    }
    return result;
}

int main() {
    std::cout << "================ Copilot SQL 优化助手 ================\n";
    std::cout << "本工具可帮助你分析GaussDB SQL及其执行计划，自动生成优化建议和优化后SQL。" << std::endl;
    std::cout << "\n【使用说明】" << std::endl;
    std::cout << "1. 先输入SQL语句（可多行，END/#END/两次空行结束）" << std::endl;
    std::cout << "2. 再输入查询计划分析（EXPLAIN(ANALYZE)结果，可多行，END/#END/两次空行结束）" << std::endl;
    std::cout << "3. 程序将自动调用AI分析并输出建议，如需补充信息会自动提问。" << std::endl;
    std::cout << "4. 在补充信息环节，输入exit或quit并回车可随时结束会诊。" << std::endl;
    std::cout << "====================================================\n";

    // 1. SQL多行输入
    std::cout << "\n【步骤1】请输入SQL语句（可多行，END/#END/两次空行结束）：" << std::endl;
    std::string sql = multiline_input("请粘贴或输入SQL，结束后输入END/#END或连续两次空行：");
    std::cout << "\n已收到SQL语句，内容如下：\n" << sql << std::endl;

    // 2. 执行计划多行输入
    std::cout << "\n【步骤2】请输入查询计划分析（EXPLAIN(ANALYZE)结果，可多行，END/#END/两次空行结束）：" << std::endl;
    std::string explain = multiline_input("请粘贴或输入执行计划，结束后输入END/#END或连续两次空行：");
    std::cout << "\n已收到查询计划分析，内容如下：\n" << explain << std::endl;

    InputData input{sql, explain};
    if (!validate_input(input)) {
        std::cerr << "输入格式错误！请确保SQL和执行计划均已输入。" << std::endl;
        return 1;
    }

    // 3. 加载AI模型配置
    std::cout << "\n【步骤3】正在加载AI模型配置……" << std::endl;
    std::vector<AIModelConfig> models;
    if (!load_ai_config("config/ai_models.json", models) || models.empty()) {
        std::cerr << "AI模型配置加载失败！请检查config/ai_models.json。" << std::endl;
        return 1;
    }
    std::cout << "已加载AI模型：" << models[0].name << "（如需切换请编辑config/ai_models.json）" << std::endl;
    AIModelConfig model = models[0];

    // 4. 构造AI提示词
    std::cout << "\n【步骤4】正在准备AI分析提示词……" << std::endl;
    std::ostringstream prompt;
    prompt << "你是GaussDB SQL优化专家。请根据以下SQL和EXPLAIN(ANALYZE)结果，分析执行瓶颈，指出优化点，并给出优化后SQL和详细建议。\n";
    prompt << "SQL:\n" << sql << "\n";
    prompt << "执行计划:\n" << explain << "\n";
    prompt << "请输出：\n1. 优化建议（分点详细说明）\n2. 优化后SQL（如需加hint、索引、参数等请直接体现在SQL中）\n3. 如需用户补充信息，请明确提出具体问题\n";

    // 5. 无限多轮AI问答主循环
    std::ostringstream full_prompt;
    full_prompt << prompt.str();
    std::string ai_result;
    bool user_exit = false;
    std::string user_info_summary;
    while (true) {
        std::cout << "\n【步骤5】正在调用AI进行智能分析，请稍候……" << std::endl;
        ai_result = call_ai(full_prompt.str(), model);
        std::cout << "\nAI分析完成，正在输出建议……\n" << std::endl;
        std::cout << "\n===== Copilot智能分析与建议 =====\n" << ai_result << std::endl;

        // 检查AI是否需要补充信息
        bool need_more = (ai_result.find("需要补充的信息") != std::string::npos) ||
                         (ai_result.find("请补充") != std::string::npos) ||
                         (ai_result.find("请问") != std::string::npos);
        std::cout << "\n【多轮问答】你可以继续补充信息、主动提问或直接输入exit/quit结束会诊。" << std::endl;
        std::string user_answer = multiline_input("请输入你的补充信息或问题（多行，END/#END/两次空行结束，或输入exit/quit退出）：", true);
        if (user_answer == "__USER_EXIT__") {
            std::cout << "\n【用户已选择退出小助手，感谢使用SQL优化助手！】\n" << std::endl;
            break;
        }
        // 汇总所有用户补充信息，便于AI多轮上下文
        user_info_summary += "\n用户补充信息或提问：" + user_answer;
        full_prompt << "\n用户补充信息或提问：" << user_answer << "\n请结合所有补充信息和问题，重新输出优化建议和优化后SQL。如有新问题请继续提问。";
    }
    return 0;
}
