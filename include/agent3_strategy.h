#pragma once
#include <string>
#include "agent5_interactive.h"

struct OptimizationStrategy {
    std::string suggestion;
    std::string optimized_sql;
};

OptimizationStrategy generate_strategy(const EnrichedDiagnosticReport& enriched);
