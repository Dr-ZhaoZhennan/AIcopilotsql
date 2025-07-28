# SQL优化助手 - 模块依赖关系

## 依赖层次结构

```
Level 0 (基础层):
├── utils.h                    # 工具函数，无依赖
└── ai_engine.h               # AI引擎，无依赖

Level 1 (输入层):
└── agent1_input.h            # 用户输入处理，无依赖

Level 2 (诊断层):
└── agent2_diagnose.h         # 依赖: agent1_input.h

Level 3 (交互层):
└── agent5_interactive.h      # 依赖: agent2_diagnose.h

Level 4 (策略层):
└── agent3_strategy.h         # 依赖: agent5_interactive.h

Level 5 (报告层):
└── agent4_report.h           # 依赖: agent3_strategy.h

Level 6 (主程序):
└── main.cpp                  # 依赖: 所有模块
```

## 详细依赖说明

### 1. 基础模块 (Level 0)

#### utils.h
- **功能**: 提供通用工具函数
- **依赖**: 无
- **包含**: 字符串处理、时间格式化、UUID生成等

#### ai_engine.h
- **功能**: AI模型配置和调用
- **依赖**: 无
- **包含**: AI模型配置结构、配置文件加载、AI接口调用

### 2. 输入模块 (Level 1)

#### agent1_input.h
- **功能**: 用户输入数据结构和验证
- **依赖**: 无
- **包含**: InputData结构体、输入验证函数

### 3. 诊断模块 (Level 2)

#### agent2_diagnose.h
- **功能**: 执行计划分析和诊断
- **依赖**: agent1_input.h
- **包含**: DiagnosticReport结构体、分析函数

### 4. 交互模块 (Level 3)

#### agent5_interactive.h
- **功能**: 用户交互和问题生成
- **依赖**: agent2_diagnose.h
- **包含**: EnrichedDiagnosticReport结构体、交互判断函数

### 5. 策略模块 (Level 4)

#### agent3_strategy.h
- **功能**: 优化策略生成
- **依赖**: agent5_interactive.h
- **包含**: OptimizationStrategy结构体、策略生成函数

### 6. 报告模块 (Level 5)

#### agent4_report.h
- **功能**: 报告输出和格式化
- **依赖**: agent3_strategy.h
- **包含**: 报告输出函数、HTML/Markdown生成

## 编译顺序

正确的编译顺序应该按照依赖层次进行：

1. **Level 0**: utils.cpp, ai_engine.cpp
2. **Level 1**: agent1_input.cpp
3. **Level 2**: agent2_diagnose.cpp
4. **Level 3**: agent5_interactive.cpp
5. **Level 4**: agent3_strategy.cpp
6. **Level 5**: agent4_report.cpp
7. **Level 6**: main.cpp

## 依赖检查

使用以下命令检查依赖关系：

```bash
make check
```

## 编译项目

```bash
# 安装依赖 (Ubuntu/Debian)
make install-deps-ubuntu

# 编译项目
make

# 运行程序
make run
```

## 注意事项

1. **避免循环依赖**: 每个模块只能依赖同层或更低层的模块
2. **头文件保护**: 所有头文件都使用 `#pragma once`
3. **相对路径**: 使用相对路径包含头文件 (`#include "header.h"`)
4. **模块化设计**: 每个模块职责单一，接口清晰

## 扩展指南

添加新模块时：

1. 确定模块的依赖层次
2. 在相应目录创建头文件和源文件
3. 更新Makefile中的源文件列表
4. 更新依赖关系文档
5. 确保不引入循环依赖 