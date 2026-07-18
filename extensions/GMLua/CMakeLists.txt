cmake_minimum_required(VERSION 4.3)

project(GMLua VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB SRC_FILES "src/*.cpp" "src/*.c")

add_library(GMLua SHARED ${SRC_FILES})

target_compile_definitions(GMLua PRIVATE GMLUA_BUILD)

target_include_directories(GMLua
    PUBLIC include
    PRIVATE LuaJIT/include
	PRIVATE GameMaker/include
)

target_link_directories(GMLua
    PRIVATE LuaJIT/lib
)

target_link_libraries(GMLua
    PRIVATE lua51
)