# SQL优化助手 - 构建说明

## 项目概述

这是一个模块化的SQL优化助手，采用分层架构设计，各个模块职责清晰，依赖关系明确。

## 项目结构

```
AIcopilotsql/
├── include/                    # 头文件目录
│   ├── agent1_input.h         # 用户输入处理
│   ├── agent2_diagnose.h      # 诊断分析
│   ├── agent3_strategy.h      # 优化策略
│   ├── agent4_report.h        # 报告输出
│   ├── agent5_interactive.h   # 用户交互
│   ├── ai_engine.h            # AI引擎
│   └── utils.h                # 工具函数
├── src/                       # 源文件目录
│   ├── agent1_input/
│   ├── agent2_diagnose/
│   ├── agent3_strategy/
│   ├── agent4_report/
│   ├── agent5_interactive/
│   ├── ai_engine/
│   └── utils/
├── config/                    # 配置文件
├── main.cpp                   # 主程序
├── Makefile                   # 构建配置
└── DEPENDENCIES.md           # 依赖关系文档
```

## 依赖关系

项目采用分层架构，依赖关系如下：

```
Level 0: utils.h, ai_engine.h (基础模块)
Level 1: agent1_input.h (输入层)
Level 2: agent2_diagnose.h (诊断层)
Level 3: agent5_interactive.h (交互层)
Level 4: agent3_strategy.h (策略层)
Level 5: agent4_report.h (报告层)
Level 6: main.cpp (主程序)
```

## 构建步骤

### 1. 安装依赖

#### Ubuntu/Debian
```bash
make install-deps-ubuntu
```

#### CentOS/RHEL
```bash
make install-deps-centos
```

#### macOS
```bash
make install-deps-macos
```

### 2. 编译项目

```bash
# 编译项目
make

# 或者编译调试版本
make debug

# 或者编译发布版本
make release
```

### 3. 运行程序

```bash
# 编译并运行
make run

# 或者直接运行
./sql_optimizer
```

## 配置AI模型

1. 复制配置文件模板：
```bash
cp config/ai_models.example.json config/ai_models.json
```

2. 编辑配置文件，添加你的API密钥：
```json
{
  "models": [
    {
      "name": "deepseek-chat",
      "url": "https://api.deepseek.com/chat/completions",
      "api_key": "your-actual-api-key",
      "model_id": "deepseek-chat"
    }
  ]
}
```

## 使用说明

1. 运行程序后，按提示输入SQL语句
2. 输入EXPLAIN(ANALYZE)结果
3. 程序会自动分析并生成优化建议
4. 如果需要补充信息，程序会提示用户输入
5. 最终输出优化后的SQL和建议

## 模块说明

### agent1_input
- 处理用户输入的SQL和执行计划
- 验证输入数据的有效性

### agent2_diagnose
- 分析执行计划，识别性能问题
- 生成诊断报告

### agent5_interactive
- 判断是否需要用户交互
- 生成问题并处理用户回答

### agent3_strategy
- 根据诊断结果生成优化策略
- 提供具体的优化建议

### agent4_report
- 输出格式化的优化报告
- 支持HTML和Markdown格式

### ai_engine
- 配置和调用AI模型
- 处理AI接口通信

### utils
- 提供通用工具函数
- 字符串处理、时间格式化等

## 故障排除

### 编译错误

1. **找不到头文件**
   - 确保使用相对路径包含头文件：`#include "header.h"`
   - 检查include目录是否正确

2. **链接错误**
   - 确保安装了libcurl开发库
   - 检查Makefile中的链接选项

3. **依赖错误**
   - 运行 `make check` 检查依赖关系
   - 确保按照正确的层次编译

### 运行时错误

1. **AI配置错误**
   - 检查 `config/ai_models.json` 文件是否存在
   - 验证API密钥是否正确

2. **网络连接问题**
   - 检查网络连接
   - 验证API端点URL是否正确

## 扩展开发

### 添加新模块

1. 确定模块的依赖层次
2. 在include目录创建头文件
3. 在src目录创建源文件
4. 更新Makefile
5. 更新依赖关系文档

### 修改现有模块

1. 确保不破坏依赖关系
2. 更新相关文档
3. 运行测试验证功能

## 许可证

本项目采用MIT许可证，详见LICENSE文件。

## 贡献

欢迎提交Issue和Pull Request来改进这个项目。 