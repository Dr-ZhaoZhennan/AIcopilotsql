#pragma once
#include <string>
#include "agent3_strategy.h"

// 输出优化报告
void output_report(const OptimizationStrategy& strategy);

// 生成HTML格式的报告
std::string generate_html_report(const OptimizationStrategy& strategy);

// 生成Markdown格式的报告
std::string generate_markdown_report(const OptimizationStrategy& strategy);
