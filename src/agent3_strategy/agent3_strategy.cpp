#include <agent3_strategy.h>
#include <sstream>

OptimizationStrategy generate_strategy(const EnrichedDiagnosticReport& enriched) {
    OptimizationStrategy strategy;
    std::ostringstream oss;
    oss << "[建议] ";
    if (enriched.base_report.summary.find("全表扫描") != std::string::npos) {
        oss << "建议为相关表添加合适索引，或优化WHERE条件。";
    } else if (enriched.base_report.summary.find("嵌套循环") != std::string::npos) {
        oss << "建议优化JOIN顺序，或考虑并行查询。";
    } else {
        oss << "可考虑增加索引或调整SQL结构。";
    }
    if (!enriched.user_knowledge.empty()) {
        oss << " 用户补充：" << enriched.user_knowledge;
    }
    strategy.suggestion = oss.str();
    strategy.optimized_sql = "-- 优化建议SQL示例：\n-- 可在WHERE条件涉及的列上创建索引，如：\n-- CREATE INDEX idx_col ON table(col);";
    return strategy;
}
