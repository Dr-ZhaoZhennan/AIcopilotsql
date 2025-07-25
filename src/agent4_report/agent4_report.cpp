#include "agent4_report.h"
#include <iostream>

void output_report(const OptimizationStrategy& strategy) {
    std::cout << "\n===== 优化建议报告 =====" << std::endl;
    std::cout << strategy.suggestion << std::endl;
    std::cout << "\n===== 优化后SQL =====" << std::endl;
    std::cout << strategy.optimized_sql << std::endl;
}
