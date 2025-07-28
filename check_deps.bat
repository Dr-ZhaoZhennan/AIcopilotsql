@echo off
echo ========================================
echo SQL优化助手 - 依赖关系检查
echo ========================================
echo.

echo 检查头文件依赖关系...
echo.

echo Level 0 (基础层):
echo   - utils.h                    # 工具函数，无依赖
echo   - ai_engine.h               # AI引擎，无依赖
echo.

echo Level 1 (输入层):
echo   - agent1_input.h            # 用户输入处理，无依赖
echo.

echo Level 2 (诊断层):
echo   - agent2_diagnose.h         # 依赖: agent1_input.h
echo.

echo Level 3 (交互层):
echo   - agent5_interactive.h      # 依赖: agent2_diagnose.h
echo.

echo Level 4 (策略层):
echo   - agent3_strategy.h         # 依赖: agent5_interactive.h
echo.

echo Level 5 (报告层):
echo   - agent4_report.h           # 依赖: agent3_strategy.h
echo.

echo Level 6 (主程序):
echo   - main.cpp                  # 依赖: 所有模块
echo.

echo ========================================
echo 依赖关系检查完成！
echo ========================================
echo.

echo 编译顺序:
echo 1. Level 0: utils.cpp, ai_engine.cpp
echo 2. Level 1: agent1_input.cpp
echo 3. Level 2: agent2_diagnose.cpp
echo 4. Level 3: agent5_interactive.cpp
echo 5. Level 4: agent3_strategy.cpp
echo 6. Level 5: agent4_report.cpp
echo 7. Level 6: main.cpp
echo.

echo 注意事项:
echo - 避免循环依赖: 每个模块只能依赖同层或更低层的模块
echo - 头文件保护: 所有头文件都使用 #pragma once
echo - 相对路径: 使用相对路径包含头文件 (#include "header.h")
echo - 模块化设计: 每个模块职责单一，接口清晰
echo.

pause 