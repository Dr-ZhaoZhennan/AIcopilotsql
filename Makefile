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

# 默认库
LIBS = $(CURL_LIB)

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
	$(CXX) $(CXXFLAGS) $(INCLUDES) -o $(TARGET) $(SRC) $(LIBS)
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

# 静态链接版本（完全独立）- 修复版本
static: CXXFLAGS += -static
static: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err -lpsl -lidn2 -lssh2 -lzstd -lbrotlidec -lbrotlicommon -lnghttp2 -lrtmp -lopenldap -lber -lsasl2 -lgssapi -lkrb5 -lk5crypto -lcom_err -lresolv -lnsl -lrt
static: $(TARGET)

# 发布版本（优化 + 静态链接）- 修复版本
release-static: CXXFLAGS = $(RELEASE_FLAGS) -static
release-static: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread -lgssapi_krb5 -lkrb5 -lk5crypto -lcom_err -lpsl -lidn2 -lssh2 -lzstd -lbrotlidec -lbrotlicommon -lnghttp2 -lrtmp -lopenldap -lber -lsasl2 -lgssapi -lkrb5 -lk5crypto -lcom_err -lresolv -lnsl -lrt
release-static: $(TARGET)

# 简化静态链接版本（仅基本依赖）
static-simple: CXXFLAGS += -static
static-simple: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread -lresolv -lrt
static-simple: $(TARGET)

# 简化发布静态版本
release-static-simple: CXXFLAGS = $(RELEASE_FLAGS) -static
release-static-simple: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread -lresolv -lrt
release-static-simple: $(TARGET)

# 最小化静态链接版本（仅核心依赖）
static-minimal: CXXFLAGS += -static
static-minimal: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread
static-minimal: $(TARGET)

# 最小化发布静态版本
release-static-minimal: CXXFLAGS = $(RELEASE_FLAGS) -static
release-static-minimal: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread
release-static-minimal: $(TARGET)

# 动态链接版本（推荐用于开发）
dynamic: CXXFLAGS = $(RELEASE_FLAGS)
dynamic: LIBS = -lcurl -lssl -lcrypto -lz -ldl -lpthread
dynamic: $(TARGET)

# 创建发布包
package: release-static-simple
	@echo "创建发布包..."
	@mkdir -p dist/AIAgent
	@cp main dist/AIAgent/AIAgent
	@cp -r config dist/AIAgent/
	@cp README.md dist/AIAgent/
	@cp LICENSE dist/AIAgent/ 2>/dev/null || echo "LICENSE 文件不存在，跳过"
	@echo "发布包创建完成：dist/AIAgent/"

# 创建Windows发布包
package-windows: dynamic
	@echo "创建Windows发布包..."
	@mkdir -p dist/AIAgent-windows
	@cp main.exe dist/AIAgent-windows/AIAgent.exe
	@cp -r config dist/AIAgent-windows/
	@cp README.md dist/AIAgent-windows/
	@cp LICENSE dist/AIAgent-windows/ 2>/dev/null || echo "LICENSE 文件不存在，跳过"
	@echo "Windows发布包创建完成：dist/AIAgent-windows/"

# 创建Linux发布包
package-linux: release-static-simple
	@echo "创建Linux发布包..."
	@mkdir -p dist/AIAgent-linux
	@cp main dist/AIAgent-linux/AIAgent
	@cp -r config dist/AIAgent-linux/
	@cp README.md dist/AIAgent-linux/
	@cp LICENSE dist/AIAgent-linux/ 2>/dev/null || echo "LICENSE 文件不存在，跳过"
	@echo "Linux发布包创建完成：dist/AIAgent-linux/"

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
	@echo "  static       - 静态链接版本（完整依赖）"
	@echo "  static-simple - 静态链接版本（简化依赖）"
	@echo "  static-minimal - 静态链接版本（最小依赖）"
	@echo "  release-static - 优化静态链接版本（完整依赖）"
	@echo "  release-static-simple - 优化静态链接版本（简化依赖）"
	@echo "  release-static-minimal - 优化静态链接版本（最小依赖）"
	@echo "  dynamic      - 动态链接版本（推荐开发使用）"
	@echo "  package      - 创建发布包"
	@echo "  package-windows - 创建Windows发布包"
	@echo "  package-linux   - 创建Linux发布包"
	@echo "  install-deps-linux   - 安装 Linux 依赖"
	@echo "  install-deps-windows - 显示 Windows 依赖安装说明"
	@echo ""
	@echo "平台检测: $(PLATFORM)"
	@echo "编译器: $(CXX)"
	@echo "目标文件: $(TARGET)"
	@echo ""
	@echo "推荐编译命令:"
	@echo "  Linux开发:   make dynamic"
	@echo "  Linux发布:   make release-static-minimal 或 make dynamic"
	@echo "  Windows:     make dynamic"

.PHONY: all clean install-deps-linux install-deps-windows check-deps run debug release test analyze static static-simple static-minimal release-static release-static-simple release-static-minimal dynamic package package-windows package-linux help
