# 跨平台 Makefile for AIAgent
# 支持 Linux 和 Windows 编译

# 检测操作系统
ifeq ($(OS),Windows_NT)
    # Windows 设置
    PLATFORM = windows
    CXX = g++
    RM = del /Q
    EXE_EXT = .exe
    CURL_LIB = -lcurl
else
    # Linux/Unix 设置
    PLATFORM = linux
    CXX = g++
    RM = rm -f
    EXE_EXT = 
    CURL_LIB = -lcurl
endif

# 编译选项
CXXFLAGS = -std=c++11 -Wall -Wextra -O2 -fPIC
INCLUDES = -Iinclude -Ithird_party

# 调试选项
DEBUG_FLAGS = -g -DDEBUG -O0
RELEASE_FLAGS = -DNDEBUG -O3 -march=native

# 测试选项
TEST_FLAGS = -DTESTING -g

# 源文件列表
SRC = main.cpp \
    src/agent1_input/agent1_input.cpp \
    src/agent2_diagnose/agent2_diagnose.cpp \
    src/agent3_strategy/agent3_strategy.cpp \
    src/agent4_report/agent4_report.cpp \
    src/agent5_interactive/agent5_interactive.cpp \
    src/ai_engine/ai_engine.cpp \
    src/utils/utils.cpp

# 目标文件名
TARGET = main$(EXE_EXT)

# 默认目标
all: $(TARGET)

# 生成主程序
$(TARGET): $(SRC)
	@echo "正在编译 $(PLATFORM) 版本..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SRC) $(CURL_LIB)
	@echo "编译完成！可执行文件: $(TARGET)"

# 清理编译生成的文件
clean:
	@echo "清理编译文件..."
ifeq ($(PLATFORM),windows)
	$(RM) $(TARGET) *.o src\*\*.o
else
	$(RM) $(TARGET) *.o src/*/*.o
endif
	@echo "清理完成！"

# 安装依赖（仅 Linux）
install-deps-linux:
	@echo "安装 Linux 依赖..."
	sudo apt-get update
	sudo apt-get install -y g++ make libcurl4-openssl-dev
	@echo "依赖安装完成！"

# 安装依赖（Windows，需要先安装 MSYS2）
install-deps-windows:
	@echo "Windows 依赖安装说明："
	@echo "1. 安装 MSYS2: https://www.msys2.org/"
	@echo "2. 在 MSYS2 中运行: pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-make mingw-w64-x86_64-curl"
	@echo "3. 将 MSYS2 的 bin 目录添加到 PATH 环境变量"

# 检查依赖
check-deps:
	@echo "检查编译依赖..."
	@which $(CXX) > /dev/null || (echo "错误: 找不到编译器 $(CXX)" && exit 1)
	@echo "编译器: $(CXX) ✓"
	@test -f third_party/json.hpp || (echo "错误: 找不到 nlohmann/json 库" && exit 1)
	@echo "nlohmann/json 库: ✓"
	@echo "所有依赖检查通过！"

# 运行程序
run: $(TARGET)
	@echo "运行程序..."
	./$(TARGET)

# 调试版本
debug: CXXFLAGS = $(DEBUG_FLAGS)
debug: $(TARGET)

# 发布版本
release: CXXFLAGS = $(RELEASE_FLAGS)
release: $(TARGET)

# 测试版本
test: CXXFLAGS = $(TEST_FLAGS)
test: $(TARGET)

# 静态分析
analyze: CXXFLAGS += -Wextra -Wpedantic -fsanitize=address,undefined
analyze: $(TARGET)

# 帮助信息
help:
	@echo "AIAgent 跨平台编译系统"
	@echo ""
	@echo "可用目标:"
	@echo "  all          - 编译程序 (默认)"
	@echo "  clean        - 清理编译文件"
	@echo "  check-deps   - 检查依赖"
	@echo "  run          - 编译并运行程序"
	@echo "  debug        - 编译调试版本"
	@echo "  release      - 编译发布版本"
	@echo "  test         - 编译测试版本"
	@echo "  analyze      - 静态分析编译"
	@echo "  install-deps-linux   - 安装 Linux 依赖"
	@echo "  install-deps-windows - 显示 Windows 依赖安装说明"
	@echo ""
	@echo "平台检测: $(PLATFORM)"
	@echo "编译器: $(CXX)"
	@echo "目标文件: $(TARGET)"

.PHONY: all clean install-deps-linux install-deps-windows check-deps run debug release test analyze help
