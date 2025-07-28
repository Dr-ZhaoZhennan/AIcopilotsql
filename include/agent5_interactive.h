#pragma once
#include <string>
#include <vector>
#include "agent2_diagnose.h"

// 增强的诊断报告（包含用户交互信息）
struct EnrichedDiagnosticReport {
    DiagnosticReport base_report;           // 基础诊断报告
    std::string user_knowledge;            // 用户补充的知识
    std::vector<std::string> questions;    // 向用户提出的问题
    std::vector<std::string> answers;      // 用户的回答
    bool needs_more_info;                  // 是否需要更多信息
};

// 判断是否需要用户交互
bool need_user_interaction(const DiagnosticReport& report);

// 根据诊断报告生成问题
std::string generate_question(const DiagnosticReport& report);

// 用用户回答丰富诊断报告
EnrichedDiagnosticReport enrich_report(const DiagnosticReport& report, const std::string& user_answer);
