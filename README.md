# CoPotentialGame
Merlin the best math tu delft student & Michael the best Data Science tu delft student

## Dependencies
* GLFW (cross-platform window + input handling)
* OpenGL (graphics API)
* GLEW (extension loader for OpenGL)
* NASM (assembler for the .asm files)

### **Linux (Ubuntu/Debian):**
```bash
  sudo apt install cmake build-essential nasm libglfw3-dev libglew-dev libglu1-mesa-dev mesa-common-dev
```
#### Linux (Arch):
``` bash
sudo pacman -S cmake base-devel nasm glfw-x11 glew mesa
```
#### macOS (Homebrew):
```bash
brew install cmake nasm glfw glew
```
#### Windows:
* Install CMake
* and NASM
Use vcpkg:
```bash
vcpkg install glfw3 glew
```

## Build Instructions

From the source directory run:
```bash
cmake -S . -B build
cmake --build build
./build/main
```


