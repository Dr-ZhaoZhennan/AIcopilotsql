#pragma once
#include <string>
#include <vector>
#include "agent1_input.h"

// 诊断报告结构体
struct DiagnosticReport {
    std::string summary;                    // 诊断摘要
    std::vector<std::string> issues;       // 发现的问题列表
    std::vector<std::string> suggestions;  // 初步建议
    double performance_score;               // 性能评分 (0-100)
    std::string bottleneck_analysis;       // 瓶颈分析
};

// 分析执行计划，生成诊断报告
DiagnosticReport analyze_plan(const InputData& input);
