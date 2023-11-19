cmake_minimum_required(VERSION 3.26)
project(DeadRussians)

set(CMAKE_CXX_STANDARD 20)

add_subdirectory(External)

add_executable(${PROJECT_NAME} main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE cpr::cpr)


