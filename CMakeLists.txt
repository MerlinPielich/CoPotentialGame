cmake_minimum_required(VERSION 3.15)
project(GLFW-CMake-Starter C ASM)  

enable_language(ASM)
find_program(GCC_EXECUTABLE gcc REQUIRED)

# Find dependencies
find_package(glfw3 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLEW REQUIRED)
find_package(Threads REQUIRED)

# probably just needs -no-pie but the interwebz said
# fPie is cool and it also works so here we are.
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no-pie")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE")

# Collect assembly (.s) sources automatically (expects files like main.s, input.s, movement.s, timing_loop.s)
file(GLOB ASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.s")

# Add assembly sources
# done later I think
set(ASM_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/main.s
    ${CMAKE_CURRENT_SOURCE_DIR}/input.s
    # ${CMAKE_CURRENT_SOURCE_DIR}/render.s
    # ${CMAKE_CURRENT_SOURCE_DIR}/util.s
    # ${CMAKE_CURRENT_SOURCE_DIR}/shader.s
    ${CMAKE_CURRENT_SOURCE_DIR}/movement.s
    ${CMAKE_CURRENT_SOURCE_DIR}/timing_loop.s
)

set(ASM_OBJECTS "")
foreach(ASM_FILE ${ASM_SOURCES})
    get_filename_component(ASM_NAME ${ASM_FILE} NAME_WE)
    set(ASM_OBJ ${CMAKE_CURRENT_BINARY_DIR}/${ASM_NAME}.o)
    add_custom_command(
        OUTPUT ${ASM_OBJ}
        COMMAND ${GCC_EXECUTABLE} -c -o ${ASM_OBJ} ${ASM_FILE}
        DEPENDS ${ASM_FILE}
    )
    list(APPEND ASM_OBJECTS ${ASM_OBJ})
endforeach()

# add add_executable needs to be set now before the references to main
add_executable(main glew_wrapper.c ${ASM_OBJECTS})

# Set compile flags for clangd
set_property(TARGET main PROPERTY CXX_STANDARD 11)
set_property(TARGET main PROPERTY C_STANDARD 11)

target_link_libraries(main
    PRIVATE
      glfw
      OpenGL::GL
      GLEW::GLEW
      Threads::Threads
      dl
      m
)

# Export compile commands for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# Add any C source(s) you have (e.g. glew wrapper)
# set(C_SOURCES
#     ${CMAKE_CURRENT_SOURCE_DIR}/glew_wrapper.c
# )
#
# # Final source list
# set(SOURCES ${ASM_SOURCES} ${C_SOURCES})

# Create executable
# add_executable(main ${SOURCES})

# Set C standard
# set_property(TARGET main PROPERTY C_STANDARD 11)
# set_property(TARGET main PROPERTY C_STANDARD_REQUIRED ON)


# Export compile commands for tools like clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

