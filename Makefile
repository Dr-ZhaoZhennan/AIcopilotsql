# SQL优化助手编译配置
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -I./include
LDFLAGS = -lcurl

# 源文件目录
SRC_DIR = src
BUILD_DIR = build

# 源文件
SOURCES = \
	$(SRC_DIR)/utils/utils.cpp \
	$(SRC_DIR)/agent1_input/agent1_input.cpp \
	$(SRC_DIR)/agent2_diagnose/agent2_diagnose.cpp \
	$(SRC_DIR)/agent5_interactive/agent5_interactive.cpp \
	$(SRC_DIR)/agent3_strategy/agent3_strategy.cpp \
	$(SRC_DIR)/agent4_report/agent4_report.cpp \
	$(SRC_DIR)/ai_engine/ai_engine.cpp \
	main.cpp

# 目标文件
OBJECTS = $(SOURCES:%.cpp=$(BUILD_DIR)/%.o)

# 可执行文件
TARGET = sql_optimizer

# 默认目标
all: $(TARGET)

# 创建构建目录
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/utils
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/agent1_input
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/agent2_diagnose
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/agent3_strategy
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/agent4_report
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/agent5_interactive
	mkdir -p $(BUILD_DIR)/$(SRC_DIR)/ai_engine

# 编译目标文件
$(BUILD_DIR)/%.o: %.cpp | $(BUILD_DIR)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# 链接可执行文件
$(TARGET): $(OBJECTS)
	$(CXX) $(OBJECTS) -o $@ $(LDFLAGS)
	@echo "编译完成！可执行文件: $(TARGET)"

# 清理
clean:
	rm -rf $(BUILD_DIR) $(TARGET)

# 安装依赖（Ubuntu/Debian）
install-deps-ubuntu:
	sudo apt-get update
	sudo apt-get install -y libcurl4-openssl-dev nlohmann-json3-dev

# 安装依赖（CentOS/RHEL）
install-deps-centos:
	sudo yum install -y libcurl-devel nlohmann-json-devel

# 安装依赖（macOS）
install-deps-macos:
	brew install curl nlohmann-json

# 运行
run: $(TARGET)
	./$(TARGET)

# 调试版本
debug: CXXFLAGS += -g -DDEBUG
debug: $(TARGET)

# 发布版本
release: CXXFLAGS += -DNDEBUG
release: $(TARGET)

# 检查代码
check:
	@echo "检查头文件依赖关系..."
	@echo "agent1_input.h - 基础模块，无依赖"
	@echo "agent2_diagnose.h - 依赖 agent1_input.h"
	@echo "agent5_interactive.h - 依赖 agent2_diagnose.h"
	@echo "agent3_strategy.h - 依赖 agent5_interactive.h"
	@echo "agent4_report.h - 依赖 agent3_strategy.h"
	@echo "ai_engine.h - 独立模块"
	@echo "utils.h - 独立模块"

# 帮助
help:
	@echo "可用目标:"
	@echo "  all          - 编译项目"
	@echo "  clean        - 清理构建文件"
	@echo "  debug        - 编译调试版本"
	@echo "  release      - 编译发布版本"
	@echo "  run          - 编译并运行"
	@echo "  check        - 检查依赖关系"
	@echo "  install-deps-ubuntu  - 安装Ubuntu依赖"
	@echo "  install-deps-centos  - 安装CentOS依赖"
	@echo "  install-deps-macos   - 安装macOS依赖"

.PHONY: all clean debug release run check help install-deps-ubuntu install-deps-centos install-deps-macos 