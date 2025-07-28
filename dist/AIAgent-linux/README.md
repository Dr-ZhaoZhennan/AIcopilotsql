# AIAgent - 智能 SQL 优化助手

一个基于 AI 的 GaussDB SQL 优化工具，能够分析 SQL 执行计划并提供专业的优化建议。

## 🚀 功能特性

- 🔍 **智能分析**: 自动分析 SQL 执行计划，识别性能瓶颈
- 🤖 **AI 驱动**: 基于大语言模型生成优化建议
- 📊 **详细报告**: 提供结构化的优化分析报告
- 🔄 **交互式**: 支持多轮问答，补充信息
- 🎯 **专业建议**: 包含索引、参数调优、SQL 重写等建议
- 🌐 **跨平台**: 支持 Linux 和 Windows 系统
- 📦 **模块化**: 清晰的模块架构，易于扩展

## 📁 项目结构详解

```
AIAgent/
├── 📄 main.cpp                    # 主程序入口，协调各个模块
├── 📄 Makefile                    # 跨平台构建配置，支持多种编译模式
├── 📄 CMakeLists.txt             # CMake 构建系统配置
├── 📄 build.sh                   # Linux 构建脚本，包含依赖检查
├── 📄 build.bat                  # Windows 构建脚本
├── 📄 README.md                  # 项目文档
├── 📁 config/                    # 配置文件目录
│   └── 📄 ai_models.json        # AI 模型配置文件
├── 📁 include/                   # 头文件目录
│   ├── 📄 agent1_input.h        # 输入处理模块接口
│   ├── 📄 agent2_diagnose.h     # 诊断分析模块接口
│   ├── 📄 agent3_strategy.h     # 策略生成模块接口
│   ├── 📄 agent4_report.h       # 报告生成模块接口
│   ├── 📄 agent5_interactive.h  # 交互模块接口
│   ├── 📄 ai_engine.h           # AI 引擎接口
│   └── 📄 utils.h               # 工具函数接口
├── 📁 src/                       # 源代码目录
│   ├── 📁 agent1_input/         # 输入处理实现
│   │   └── 📄 agent1_input.cpp  # 多行输入处理、数据验证
│   ├── 📁 agent2_diagnose/      # 诊断分析实现
│   │   └── 📄 agent2_diagnose.cpp # 执行计划分析、问题识别
│   ├── 📁 agent3_strategy/      # 策略生成实现
│   │   └── 📄 agent3_strategy.cpp # 优化策略生成
│   ├── 📁 agent4_report/        # 报告生成实现
│   │   └── 📄 agent4_report.cpp # 报告格式化输出
│   ├── 📁 agent5_interactive/   # 交互实现
│   │   └── 📄 agent5_interactive.cpp # 用户交互处理
│   ├── 📁 ai_engine/            # AI 引擎实现
│   │   └── 📄 ai_engine.cpp     # AI API 调用、响应处理
│   └── 📁 utils/                # 工具函数实现
│       └── 📄 utils.cpp         # 通用工具函数
└── 📁 third_party/              # 第三方库目录
    └── 📄 json.hpp              # nlohmann/json 库（单头文件）
```

## 🏗️ 模块架构详解

### 1. 输入处理模块 (agent1_input)
- **功能**: 接收和验证用户输入的 SQL 和执行计划
- **接口**: `InputData` 结构体、`receive_user_input()`、`validate_input()`
- **特点**: 支持多行输入，自动验证数据格式

### 2. 诊断分析模块 (agent2_diagnose)
- **功能**: 分析执行计划，识别性能问题
- **接口**: `DiagnosticReport` 结构体、`analyze_plan()`
- **特点**: 自动识别瓶颈、生成初步建议

### 3. 策略生成模块 (agent3_strategy)
- **功能**: 根据诊断结果生成优化策略
- **接口**: `OptimizationStrategy` 结构体、`generate_strategy()`
- **特点**: 包含索引建议、参数调优、风险评估

### 4. 报告生成模块 (agent4_report)
- **功能**: 格式化输出优化报告
- **接口**: `output_report()`、`generate_html_report()`、`generate_markdown_report()`
- **特点**: 支持多种输出格式

### 5. 交互模块 (agent5_interactive)
- **功能**: 处理用户交互，补充信息
- **接口**: `EnrichedDiagnosticReport` 结构体、`need_user_interaction()`、`generate_question()`
- **特点**: 智能问答，动态补充信息

### 6. AI 引擎模块 (ai_engine)
- **功能**: 调用 AI API，处理响应
- **接口**: `AIModelConfig` 结构体、`load_ai_config()`、`call_ai()`
- **特点**: 支持多种 AI 模型，错误处理

### 7. 工具模块 (utils)
- **功能**: 提供通用工具函数
- **接口**: `Utils` 命名空间下的各种工具函数
- **特点**: 字符串处理、格式化、ID 生成等

## 🚀 快速开始

### Linux 系统

#### 方法一：使用构建脚本（推荐）

1. **克隆项目**
   ```bash
   git clone <repository-url>
   cd AIAgent
   ```

2. **检查依赖**
   ```bash
   ./build.sh check-deps
   ```

3. **安装依赖（如果需要）**
   ```bash
   ./build.sh install-deps
   ```

4. **编译项目**
   ```bash
   # 编译发布版本
   ./build.sh build release
   
   # 编译调试版本
   ./build.sh build debug
   ```

5. **运行程序**
   ```bash
   ./build.sh run
   ```

#### 方法二：使用 Makefile

```bash
# 检查依赖
make check-deps

# 编译发布版本
make release

# 编译调试版本
make debug

# 编译测试版本
make test

# 静态分析
make analyze

# 运行程序
make run

# 清理构建文件
make clean
```

#### 方法三：使用 CMake

```bash
# 创建构建目录
mkdir build && cd build

# 配置项目
cmake ..

# 编译项目
make

# 运行程序
./bin/AIAgent
```

### Windows 系统

#### 方法一：使用构建脚本

1. **安装 MSYS2**
   - 下载并安装 [MSYS2](https://www.msys2.org/)
   - 在 MSYS2 中运行：
     ```bash
     pacman -S mingw-w64-x86_64-gcc
     pacman -S mingw-w64-x86_64-make
     pacman -S mingw-w64-x86_64-curl
     ```
   - 将 `C:\msys64\mingw64\bin` 添加到 PATH 环境变量

2. **编译项目**
   ```cmd
   build.bat build release
   ```

3. **运行程序**
   ```cmd
   main.exe
   ```

#### 方法二：使用 Visual Studio

1. **安装依赖**
   - 安装 Visual Studio 2019 或更新版本
   - 安装 vcpkg 包管理器

2. **使用 CMake**
   ```cmd
   mkdir build
   cd build
   cmake .. -G "Visual Studio 16 2019"
   cmake --build . --config Release
   ```

## ⚙️ 配置说明

### AI 模型配置

编辑 `config/ai_models.json` 文件来配置 AI 模型：

```json
{
  "models": [
    {
      "name": "deepseek-chat",
      "url": "https://api.deepseek.com/chat/completions",
      "api_key": "your-api-key-here",
      "model_id": "deepseek-chat"
    },
    {
      "name": "deepseek-reasoner",
      "url": "https://api.deepseek.com/chat/completions",
      "api_key": "your-api-key-here",
      "model_id": "deepseek-reasoner"
    }
  ]
}
```

**配置说明**:
- `name`: 模型显示名称
- `url`: API 端点 URL
- `api_key`: 你的 API 密钥
- `model_id`: 模型标识符

### 编译配置

#### Makefile 选项

```bash
# 调试版本（包含调试信息）
make debug

# 发布版本（优化编译）
make release

# 测试版本（包含测试宏）
make test

# 静态分析（内存检查）
make analyze
```

#### CMake 选项

```bash
# 启用测试
cmake .. -DBUILD_TESTS=ON

# 启用文档生成
cmake .. -DBUILD_DOCS=ON

# 启用内存检查
cmake .. -DENABLE_SANITIZERS=ON
```

## 📖 使用教程

### 基本使用流程

1. **启动程序**
   ```bash
   ./main
   ```

2. **输入 SQL 语句**
   ```
   请输入SQL语句（可多行，END/#END/两次空行结束）：
   SELECT u.name, o.order_date, o.total_amount
   FROM users u
   JOIN orders o ON u.id = o.user_id
   WHERE u.status = 'active'
   AND o.order_date >= '2024-01-01'
   ORDER BY o.total_amount DESC;
   END
   ```

3. **输入执行计划**
   ```
   请输入查询计划分析（EXPLAIN(ANALYZE)结果）：
   QUERY PLAN
   ----------------------------------------------------------------
   Sort  (cost=1234.56..1234.57 rows=1 width=64) (actual time=12.345..12.346 rows=100 loops=1)
     Sort Key: o.total_amount DESC
     Sort Method: quicksort  Memory: 25kB
     ->  Hash Join  (cost=123.45..1234.56 rows=1 width=64) (actual time=1.234..12.345 rows=100 loops=1)
           Hash Cond: (u.id = o.user_id)
           ->  Seq Scan on users u  (cost=0.00..123.45 rows=1000 width=32) (actual time=0.123..1.234 rows=1000 loops=1)
                 Filter: (status = 'active'::text)
           ->  Hash  (cost=123.45..123.45 rows=1000 width=32) (actual time=1.234..1.234 rows=1000 loops=1)
                 Buckets: 1024  Batches: 1  Memory Usage: 25kB
                 ->  Seq Scan on orders o  (cost=0.00..123.45 rows=1000 width=32) (actual time=0.123..1.234 rows=1000 loops=1)
                       Filter: (order_date >= '2024-01-01'::date)
   END
   ```

4. **查看 AI 分析结果**
   程序会自动调用 AI 进行分析，输出优化建议。

5. **交互问答**
   如果 AI 需要更多信息，会主动提问，你可以继续补充信息。

6. **退出程序**
   输入 `exit` 或 `quit` 退出程序。

### 高级功能

#### 自定义 AI 提示词

你可以修改 `main.cpp` 中的提示词模板来定制 AI 分析行为：

```cpp
// 在 main.cpp 中修改 prompt 内容
prompt << "你是GaussDB SQL优化专家，精通大规模数据分析、执行计划解读与GUC参数调优。请严格按照如下要求分析和优化：\n";
// ... 更多提示词内容
```

#### 扩展新的 AI 模型

1. **添加新的模型配置**
   在 `config/ai_models.json` 中添加新的模型配置。

2. **修改 AI 调用逻辑**
   在 `src/ai_engine/ai_engine.cpp` 中修改 `call_ai` 函数来支持不同的 API 格式。

#### 添加新的分析模块

1. **创建新的头文件**
   在 `include/` 目录下创建新的模块头文件。

2. **实现模块功能**
   在 `src/` 目录下创建对应的实现文件。

3. **集成到主程序**
   在 `main.cpp` 中调用新的模块功能。

## 🔧 故障排除

### 编译错误

#### 1. 找不到 nlohmann/json
```bash
# 自动下载
./build.sh check-deps
```

#### 2. 找不到 libcurl
```bash
# Linux
sudo apt-get install libcurl4-openssl-dev

# Windows (MSYS2)
pacman -S mingw-w64-x86_64-curl
```

#### 3. 编译器版本过低
- 确保使用支持 C++11 的编译器
- GCC 4.8+ 或 Clang 3.3+
- Visual Studio 2015+

#### 4. 内存不足
```bash
# 使用调试版本编译
make debug

# 或者减少优化级别
make CXXFLAGS="-std=c++11 -Wall -O1"
```

### 运行时错误

#### 1. 配置文件错误
```bash
# 检查配置文件格式
cat config/ai_models.json | python -m json.tool
```

#### 2. 网络连接问题
- 检查网络连接
- 验证 API 端点是否可访问
- 检查防火墙设置

#### 3. API 密钥问题
- 验证 API 密钥是否有效
- 检查 API 配额是否用完
- 确认模型 ID 是否正确

#### 4. 内存泄漏
```bash
# 使用内存检查编译
make analyze

# 运行程序检查内存问题
./main
```

### 性能问题

#### 1. 编译速度慢
```bash
# 使用并行编译
make -j$(nproc)

# 或者使用 CMake
cmake --build . --parallel
```

#### 2. 程序运行慢
- 检查网络延迟
- 优化 AI 提示词长度
- 使用更快的 AI 模型

## 🧪 测试

### 运行测试
```bash
# 编译测试版本
make test

# 运行程序进行测试
./main
```

### 静态分析
```bash
# 编译静态分析版本
make analyze

# 运行程序检查内存问题
./main
```

## 📚 开发指南

### 代码规范

1. **命名规范**
   - 文件名：小写字母，下划线分隔
   - 函数名：小写字母，下划线分隔
   - 类名：大驼峰命名法
   - 常量：全大写，下划线分隔

2. **注释规范**
   - 头文件：详细的功能说明
   - 函数：参数说明、返回值说明
   - 复杂逻辑：行内注释

3. **错误处理**
   - 使用返回值检查错误
   - 提供有意义的错误信息
   - 记录错误日志

### 扩展开发

#### 添加新的分析功能

1. **创建新的模块**
   ```cpp
   // include/new_analyzer.h
   #pragma once
   #include <string>
   
   struct NewAnalysisResult {
       std::string analysis;
       double confidence;
   };
   
   NewAnalysisResult perform_new_analysis(const std::string& sql);
   ```

2. **实现模块功能**
   ```cpp
   // src/new_analyzer/new_analyzer.cpp
   #include "new_analyzer.h"
   
   NewAnalysisResult perform_new_analysis(const std::string& sql) {
       // 实现分析逻辑
       return result;
   }
   ```

3. **集成到主程序**
   ```cpp
   // 在 main.cpp 中添加
   #include "new_analyzer.h"
   
   // 在适当位置调用
   auto new_result = perform_new_analysis(sql);
   ```

#### 添加新的输出格式

1. **扩展报告模块**
   ```cpp
   // 在 agent4_report.h 中添加
   std::string generate_json_report(const OptimizationStrategy& strategy);
   std::string generate_xml_report(const OptimizationStrategy& strategy);
   ```

2. **实现新的格式**
   ```cpp
   // 在 agent4_report.cpp 中实现
   std::string generate_json_report(const OptimizationStrategy& strategy) {
       // 实现 JSON 格式输出
   }
   ```

## 🤝 贡献指南

### 提交 Issue

1. **Bug 报告**
   - 详细描述问题现象
   - 提供复现步骤
   - 包含系统环境信息

2. **功能请求**
   - 描述新功能需求
   - 说明使用场景
   - 提供实现建议

### 提交 Pull Request

1. **代码规范**
   - 遵循项目代码规范
   - 添加必要的注释
   - 包含测试用例

2. **提交信息**
   - 使用清晰的提交信息
   - 说明修改内容
   - 关联相关 Issue

## 📄 许可证

本项目采用 [MIT 许可证](LICENSE)。

## 🙏 致谢

- [nlohmann/json](https://github.com/nlohmann/json) - JSON 解析库
- [libcurl](https://curl.se/) - HTTP 客户端库
- [DeepSeek](https://www.deepseek.com/) - AI 模型服务

## 📞 联系方式

- 项目主页：[https://github.com/Dr-ZhaoZhennan/AIcopilotsql#]
- 问题反馈：[https://github.com/Dr-ZhaoZhennan/AIcopilotsql/issues]
- 邮箱：[1657576024@shu.edu.cn]

---

**注意**: 使用本工具时，请确保遵守相关 API 服务的使用条款和隐私政策。
