CXX = g++
CXXFLAGS = -std=c++11 -Iinclude
SRC = main.cpp \
    src/agent1_input/agent1_input.cpp \
    src/agent2_diagnose/agent2_diagnose.cpp \
    src/agent3_strategy/agent3_strategy.cpp \
    src/agent4_report/agent4_report.cpp \
    src/agent5_interactive/agent5_interactive.cpp \
    src/ai_engine/ai_engine.cpp \
    src/utils/utils.cpp
OBJ = $(SRC:.cpp=.o)

main: $(SRC)
	$(CXX) $(CXXFLAGS) -o main $(SRC) -lcurl

clean:
	rm -f main *.o src/*/*.o
