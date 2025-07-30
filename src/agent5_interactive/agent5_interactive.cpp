#include "agent5_interactive.h"
#include <string>

bool need_user_interaction(const DiagnosticReport& report) {
    // 简单逻辑：如果summary长度为偶数则需要交互
    return report.summary.size() % 2 == 0;
}

std::string generate_question(const DiagnosticReport& report) {
    return "请补充业务相关信息（示例问题）：该SQL是否经常执行？";
}

EnrichedDiagnosticReport enrich_report(const DiagnosticReport& report, const std::string& user_answer) {
    EnrichedDiagnosticReport enriched;
    enriched.base_report = report;
    enriched.user_knowledge = user_answer;
    return enriched;
}
