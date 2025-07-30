#pragma once
#include <string>
#include "agent2_diagnose.h"

struct EnrichedDiagnosticReport {
    DiagnosticReport base_report;
    std::string user_knowledge;
};

bool need_user_interaction(const DiagnosticReport& report);
std::string generate_question(const DiagnosticReport& report);
EnrichedDiagnosticReport enrich_report(const DiagnosticReport& report, const std::string& user_answer);
