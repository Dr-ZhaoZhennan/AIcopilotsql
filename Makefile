# 指定C++编译器，这里使用g++
CXX = g++

# 编译选项：
# -std=c++11：使用C++11标准
# -Iinclude：添加头文件搜索路径为include目录
CXXFLAGS = -std=c++11 -Iinclude

# 源文件列表，包含主程序和各个功能模块的实现文件
SRC = main.cpp \
    src/agent1_input/agent1_input.cpp \        # 输入接收与验证模块
    src/agent2_diagnose/agent2_diagnose.cpp \  # 语义诊断模块
    src/agent3_strategy/agent3_strategy.cpp \  # 策略生成模块
    src/agent4_report/agent4_report.cpp \      # 报告生成模块
    src/agent5_interactive/agent5_interactive.cpp \ # 交互与知识管理模块
    src/ai_engine/ai_engine.cpp \              # AI接口模块
    src/utils/utils.cpp                        # 工具函数模块

# 对应的目标文件列表（.cpp替换为.o）
OBJ = $(SRC:.cpp=.o)

# 生成主程序main的规则
# 依赖于所有源文件
main: $(SRC)
	$(CXX) $(CXXFLAGS) -o main $(SRC) -lcurl   # 编译并链接，依赖libcurl库用于AI接口HTTP请求

# 清理编译生成的文件
clean:
	rm -f main *.o src/*/*.o                   # 删除主程序、所有.o文件和子目录下的.o文件
