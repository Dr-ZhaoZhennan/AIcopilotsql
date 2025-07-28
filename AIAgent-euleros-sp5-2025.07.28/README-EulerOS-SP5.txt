AIAgent - EulerOS SP5 兼容版本

这是专门为 EulerOS release 2.0 (SP5) 优化的兼容性版本。

系统要求:
- EulerOS release 2.0 (SP5) 或更高版本
- x86_64 或 aarch64 架构
- 基本的 C++ 运行时库

兼容性特性:
- 针对 EulerOS SP5 的旧版本 glibc 优化
- 使用静态链接标准库避免版本冲突
- 兼容 EulerOS SP5 的库版本

安装方法:
1. 检查依赖: ./check-euleros-sp5-deps.sh
2. 安装到系统: sudo ./install-euleros-sp5.sh
3. 运行程序: AIAgent

或者直接运行:
./run-euleros-sp5.sh

EulerOS SP5 特定说明:
- 使用 yum 包管理器
- 支持 systemd 服务管理
- 针对 SP5 的库版本兼容性优化
- 使用静态链接避免 glibc 版本冲突

版本信息:
2025-07-28 11:49:08
编译目标: EulerOS release 2.0 (SP5)
兼容性: glibc 2.17+, libstdc++ 4.8+
