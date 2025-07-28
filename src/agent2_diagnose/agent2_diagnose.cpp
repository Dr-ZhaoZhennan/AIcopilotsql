#include "agent2_diagnose.h"

DiagnosticReport analyze_plan(const InputData& input) {
    DiagnosticReport report;
    report.summary = "[诊断报告] SQL长度:" + std::to_string(input.sql.size()) + ", EXPLAIN长度:" + std::to_string(input.explain_result.size());
    return report;
}
