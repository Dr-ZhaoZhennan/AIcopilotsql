# GaussDB SQL 优化 Copilot（C/C++版）

## 项目简介
本项目为 GaussDB 查询优化 Copilot，采用 C/C++ 实现，支持对 EXPLAIN(ANALYZE) 结果进行自动分析、优化建议生成，并具备交互式“会诊”能力。

## 目录结构
```
/src
  /agent1_input         // 输入接收与验证
  /agent2_diagnose      // 语义诊断
  /agent3_strategy      // 策略生成
  /agent4_report        // 报告生成
  /agent5_interactive   // 交互与知识管理
  /ai_engine            // AI接口模块
  /utils                // 工具函数
/include                // 头文件
/config                 // 配置文件（如AI模型）
main.cpp                // 主控程序
Makefile                // 构建脚本
README.md               // 项目说明
```



## 如果要清除原来配置：
```bash
make clean && make
```

## 直接编译
```bash
make
```



## 运行方法
```bash
./main
```

## AI模型配置
请在 `config/ai_models.json` 中配置AI模型信息，支持多模型扩展。注意：此处默认调用第一个AI模型，如需切换模型，请将目标模型移至最前面。

## 功能特性
- 支持GaussDB EXPLAIN(ANALYZE)结果分析
- 自动生成SQL优化建议
- 交互式会诊，主动向用户提问补全知识
- AI接口可配置、可扩展

## 后续开发
请根据模块目录逐步完善各功能模块。
