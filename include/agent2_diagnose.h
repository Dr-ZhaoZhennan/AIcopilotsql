#pragma once
#include <string>
#include "agent1_input.h"

struct DiagnosticReport {
    std::string summary;
    // 可扩展更多诊断字段
};

DiagnosticReport analyze_plan(const InputData& input);
