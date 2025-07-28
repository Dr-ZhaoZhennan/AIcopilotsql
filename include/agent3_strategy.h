#pragma once
#include <string>
#include <vector>
#include "agent5_interactive.h"

// 优化策略结构体
struct OptimizationStrategy {
    std::string suggestion;                 // 优化建议
    std::string optimized_sql;             // 优化后的SQL
    std::vector<std::string> index_hints;  // 索引建议
    std::vector<std::string> param_hints;  // 参数调优建议
    double expected_improvement;           // 预期性能提升百分比
    std::string risk_assessment;           // 风险评估
};

// 根据增强的诊断报告生成优化策略
OptimizationStrategy generate_strategy(const EnrichedDiagnosticReport& enriched);
