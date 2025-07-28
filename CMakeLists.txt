cmake_minimum_required(VERSION 3.10)
project(AIAgent VERSION 1.0.0 LANGUAGES CXX)

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置编译选项
if(MSVC)
    # Windows MSVC 编译器选项
    add_compile_options(/W4 /utf-8)
    set(CMAKE_CXX_FLAGS_RELEASE "/MT /O2")
    set(CMAKE_CXX_FLAGS_DEBUG "/MTd /Od /Zi")
else()
    # Linux/Unix 编译器选项
    add_compile_options(-Wall -Wextra -fPIC)
    set(CMAKE_CXX_FLAGS_RELEASE "-O3 -DNDEBUG -march=native")
    set(CMAKE_CXX_FLAGS_DEBUG "-g -O0 -DDEBUG")
endif()

# 查找依赖库
find_package(CURL REQUIRED)

# 包含目录
include_directories(include third_party)

# 源文件
set(SOURCES
    main.cpp
    src/agent1_input/agent1_input.cpp
    src/agent2_diagnose/agent2_diagnose.cpp
    src/agent3_strategy/agent3_strategy.cpp
    src/agent4_report/agent4_report.cpp
    src/agent5_interactive/agent5_interactive.cpp
    src/ai_engine/ai_engine.cpp
    src/utils/utils.cpp
)

# 创建可执行文件
add_executable(${PROJECT_NAME} ${SOURCES})

# 链接库
target_link_libraries(${PROJECT_NAME} PRIVATE CURL::libcurl)

# 设置输出目录
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin
)

# 复制配置文件到输出目录
file(COPY config DESTINATION ${CMAKE_BINARY_DIR}/bin)

# 安装规则
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
)

install(DIRECTORY config/
    DESTINATION share/${PROJECT_NAME}/config
    FILES_MATCHING PATTERN "*.json"
)

# 创建包
include(CPack)

# 添加测试（可选）
option(BUILD_TESTS "Build tests" OFF)
option(BUILD_DOCS "Build documentation" OFF)
option(ENABLE_SANITIZERS "Enable sanitizers" OFF)

if(BUILD_TESTS)
    enable_testing()
    # 这里可以添加测试相关的配置
endif()

if(ENABLE_SANITIZERS)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,undefined")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address,undefined")
endif()

# 打印配置信息
message(STATUS "Platform: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}") 