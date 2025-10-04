cmake_minimum_required(VERSION 3.15)
<<<<<<< HEAD
project(GLFW-CMake-Starter C ASM)  

# make sure NASM exists 
find_program(NASM_EXECUTABLE nasm REQUIRED)
if(NOT NASM_EXECUTABLE)
    message(FATAL_ERROR "NASM not found on this system")
endif()

# probably just needs -no-pie but the interwebz said
# fPie is cool and it also works so here we are.
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no-pie")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fPIE")

# Add assembly sources
set(ASM_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/main.asm
    ${CMAKE_CURRENT_SOURCE_DIR}/input.asm
    # ${CMAKE_CURRENT_SOURCE_DIR}/render.asm
    # ${CMAKE_CURRENT_SOURCE_DIR}/util.asm
    # ${CMAKE_CURRENT_SOURCE_DIR}/shader.asm
    ${CMAKE_CURRENT_SOURCE_DIR}/movement.asm
    ${CMAKE_CURRENT_SOURCE_DIR}/timing_loop.asm
)

set(ASM_OBJECTS "")
foreach(ASM_FILE ${ASM_SOURCES})
    get_filename_component(ASM_NAME ${ASM_FILE} NAME_WE)
    set(ASM_OBJ ${CMAKE_CURRENT_BINARY_DIR}/${ASM_NAME}.o)
    add_custom_command(
        OUTPUT ${ASM_OBJ}
        COMMAND ${NASM} -f elf64 -o ${ASM_OBJ} ${ASM_FILE}
        DEPENDS ${ASM_FILE}
    )
    list(APPEND ASM_OBJECTS ${ASM_OBJ})
endforeach()


# dependencies
find_package(glfw3 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLEW REQUIRED)

# add add_executable needs to be set now before the references to main
add_executable(main glew_wrapper.c ${ASM_OBJECTS})

# Set compile flags for clangd
set_property(TARGET main PROPERTY CXX_STANDARD 11)
set_property(TARGET main PROPERTY C_STANDARD 11)

# Link libraries
target_link_libraries(main
    glfw
    OpenGL::GL
    GLEW::GLEW
)

# Export compile commands for clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
=======
project(rts C ASM)

# Enable assembling .s (GAS/AT&T) sources
enable_language(ASM)

# Prefer explicit no-PIE linking to match non-PIE assembly if needed
# If you want PIE, remove this line.
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -no-pie")

# Find dependencies
find_package(glfw3 REQUIRED)
find_package(OpenGL REQUIRED)
find_package(GLEW REQUIRED)
find_package(Threads REQUIRED)

# Collect assembly (.s) sources automatically (expects files like main.s, input.s, movement.s, timing_loop.s)
file(GLOB ASM_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.s")

# Add any C source(s) you have (e.g. glew wrapper)
set(C_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/glew_wrapper.c
)

# Final source list
set(SOURCES ${ASM_SOURCES} ${C_SOURCES})

# Create executable
add_executable(main ${SOURCES})

# Set C standard
set_property(TARGET main PROPERTY C_STANDARD 11)
set_property(TARGET main PROPERTY C_STANDARD_REQUIRED ON)

# Link libraries
target_link_libraries(main
    PRIVATE
      glfw
      OpenGL::GL
      GLEW::GLEW
      Threads::Threads
      dl
      m
)

# Export compile commands for tools like clangd
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Helpful messages
message(STATUS "ASM sources: ${ASM_SOURCES}")
message(STATUS "Building executable: main")
>>>>>>> 9f59466 ( new syntax, new me)
