# GaussDB SQL优化Copilot Makefile

# 编译器设置
CXX = g++
CXXFLAGS = -std=c++17 -Wall -Wextra -O2 -g

# 包含目录
INCLUDES = -I./include

# 库文件
LIBS = -lpthread

# 源文件目录
SRC_DIR = src
OBJ_DIR = obj

# 查找所有源文件
SOURCES = $(shell find $(SRC_DIR) -name "*.cpp")
OBJECTS = $(SOURCES:$(SRC_DIR)/%.cpp=$(OBJ_DIR)/%.o)

# 目标文件
TARGET = main

# 默认目标
all: $(TARGET)

# 创建目标目录
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)
	mkdir -p $(OBJ_DIR)/agent1_input
	mkdir -p $(OBJ_DIR)/agent2_diagnose
	mkdir -p $(OBJ_DIR)/agent3_strategy
	mkdir -p $(OBJ_DIR)/agent4_report
	mkdir -p $(OBJ_DIR)/agent5_interactive
	mkdir -p $(OBJ_DIR)/ai_engine
	mkdir -p $(OBJ_DIR)/utils

# 编译目标文件
$(OBJ_DIR)/%.o: $(SRC_DIR)/%.cpp | $(OBJ_DIR)
	@echo "编译 $<"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

# 编译主程序
$(TARGET): main.cpp $(OBJECTS)
	@echo "链接 $(TARGET)"
	@$(CXX) $(CXXFLAGS) $(INCLUDES) $^ -o $@ $(LIBS)

# 检查依赖
check-deps:
	@echo "检查系统依赖..."
	@if ! command -v g++ > /dev/null; then \
		echo "错误: 未找到g++编译器"; \
		exit 1; \
	fi
	@if ! command -v make > /dev/null; then \
		echo "错误: 未找到make工具"; \
		exit 1; \
	fi
	@if [ ! -f "/usr/include/nlohmann/json.hpp" ] && [ ! -f "/usr/local/include/nlohmann/json.hpp" ]; then \
		echo "警告: 未找到nlohmann/json库，请运行: sudo apt-get install nlohmann-json3-dev"; \
	fi
	@if ! command -v ollama > /dev/null; then \
		echo "警告: 未找到Ollama，请先运行setup_ollama.sh"; \
	fi
	@echo "依赖检查完成"

# 安装依赖
install-deps:
	@echo "安装系统依赖..."
	@sudo apt-get update
	@sudo apt-get install -y build-essential nlohmann-json3-dev curl

# 清理
clean:
	@echo "清理编译文件..."
	@rm -rf $(OBJ_DIR)
	@rm -f $(TARGET)
	@rm -f *.log
	@rm -f ollama.pid

# 重新编译
rebuild: clean all

# 运行
run: $(TARGET)
	@echo "启动SQL优化器..."
	@./$(TARGET)

# 测试
test: $(TARGET)
	@echo "运行测试..."
	@echo "这是一个测试SQL查询" | ./$(TARGET)

# 帮助
help:
	@echo "可用目标:"
	@echo "  all        - 编译项目"
	@echo "  clean      - 清理编译文件"
	@echo "  rebuild    - 重新编译"
	@echo "  run        - 编译并运行"
	@echo "  test       - 运行测试"
	@echo "  check-deps - 检查依赖"
	@echo "  install-deps - 安装依赖"
	@echo "  help       - 显示此帮助"

# 伪目标
.PHONY: all clean rebuild run test check-deps install-deps help
