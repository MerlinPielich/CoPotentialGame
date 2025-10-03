; main.asm -- GLFW + OpenGL example (NASM)
; Assemble: nasm -f elf64 main.asm -o main.o
; Link: gcc -no-pie -o main main.o glew_wrapper.o -lglfw -lGL -lGLEW

    extern glfwInit
    extern glClearColor
    extern glGetUniformLocation
    extern glfwGetKey
    extern glfwSetWindowShouldClose
    extern glClear
    extern glUniform2f
    extern glBegin
    extern glVertex3f
    extern glEnd
    extern glfwSwapBuffers
    extern glfwPollEvents
    extern glfwMakeContextCurrent
    extern glfwCreateWindow
    extern glfwWindowHint
    extern glfwWindowShouldClose
    extern glfwTerminate
    extern glUseProgram
    extern glBindBuffer
    extern glEnableVertexAttribArray
    extern glVertexAttribPointer
    extern glBindVertexArray
    extern glGenBuffers
    extern glBufferData
    extern glLinkProgram
    extern glAttachShader
    extern glGenVertexArrays
    extern glShaderSource 
    extern glCreateProgram
    extern glCompileShader
    extern glCreateShader
    extern glViewport
    extern glDrawArrays
    extern glOrtho
    extern glColor3f
    extern initGLEW
    extern glfwGetError 

; --- timing_loop.asm --- ;
    extern run_game_loop    

; --- input.asm --- ;
    extern check_s
    extern check_a
    extern check_w
    extern check_d
    extern check_esc

; --- movement.asm ---;
    extern update_triangle_position

; --- C lib --- ;
    extern printf       

;--- public vars ---;
    global main
    global window
    global offset_loc
    global vao_id
    global program_id

    ; for the testriangle
    global tri_x
    global tri_y

section .rodata
vertex_shader_src: db "#version 330 core",10,\
 "layout (location = 0) in vec3 aPos;",10,\
 "uniform vec2 offset;",10,\
 "void main() {",10,\
 "  vec2 pos = aPos.xy + offset;",10,\
 "  gl_Position = vec4(pos, aPos.z, 1.0);",10,\
 "}",0

fragment_shader_src: db "#version 330 core",10,\
                        "out vec4 FragColor;",10,\
                        "void main() {",10,\
                        "   FragColor = vec4(1.0, 0.0, 0.0, 1.0);",10,\
                        "}",0

section .data
    window_width  dd 1920
    window_height dd 1080
    window_title_str db "GLFW + OpenGL", 0
    ; window dq 0  ; GLFWwindow* window;

; --- User Input ---;
    w_pressed_str db "W pressed!", 10, 0

    ; uniform translation offset
    offset_name db "offset",0
    offset_loc  dd -1

    ; triangle translation
    tri_x dd 0.0
    tri_y dd 0.0

    ; data
    red   dd 0.0
    green dd 0.0
    blue  dd 0.0
    alpha dd 1.0

    ; for the building of the window
    ; but some vars aren't used anymore
    x1 dd 0.0
    y1 dd 0.0
    z1 dd 0.0
    x2 dd 320.0
    y2 dd 480.0
    z2 dd 0.0
    x3 dd 640.0
    y3 dd 0.0
    z3 dd 0.0

    one_f   dd 1.0
    zero_f  dd 0.0

    zero    dq 0.0
    one     dq 1.0
    neg_one dq -1.0

    ; pointer tables for glShaderSource (char * const *)
    vertex_shader_ptr dq vertex_shader_src
    fragment_shader_ptr dq fragment_shader_src

    ; storage for ids
    program_id dd 0
    vertex_shader_id dd 0
    fragment_shader_id dd 0
    vao_id dd 0
    vbo_id dd 0


    ; Some error messages spread out over the code
    error_message db "Error: %s", 10, 0
    ok_msg db "glfwInit succeeded\n",0
    err_create db "glfwCreateWindow failed: %s", 10, 0
    err_fmt db "GLFW error %d: %s", 10, 0
    ;Verts
vertices: dd  0.0,  0.5, 0.0
          dd -0.5, -0.5, 0.0
          dd  0.5, -0.5, 0.0

section .bss
    glfw_err_desc resq 1
    window resq 1
    t1 resq 2   ; tv_seconds, tv_nanoSeconds
    t2 resq 2

section .text
main:
    ; Standard frame
    push rbp
    mov rbp, rsp
    sub rsp, 32 ; Allocate space for local variables and alignment

.glfw_init:
    ; GLFW init
    call glfwInit
    test eax, eax
    jnz .init_ok      ; success

    ; failed → get error
    lea rdi, [rel glfw_err_desc]
    call glfwGetError
    mov rdi, err_fmt
    mov esi, eax
    mov rdx, [glfw_err_desc]
    xor eax, eax
    call printf
    jmp .cleanup
.init_ok:

    ; after call glfwInit
    mov rdi, ok_msg   ; "glfwInit succeeded\n"
    xor eax, eax
    call printf

    ;Check for GLFW errors
    call glfwGetError
    test rax, rax
    jz .set_hints

    ; Handle GLFW error
    mov rdi, error_message
    mov rsi, rax
    call printf
    jmp .cleanup

.set_hints:
    ; Force client API = OpenGL
    mov edi, 0x00022001      ; GLFW_CLIENT_API
    mov esi, 0x00030001      ; GLFW_OPENGL_API
    call glfwWindowHint

    ; Force EGL context creation (important for Wayland + NVIDIA)
    mov edi, 0x0002200E      ; GLFW_CONTEXT_CREATION_API
    mov esi, 0x00032002      ; GLFW_EGL_CONTEXT_API
    call glfwWindowHint

    ; Request OpenGL 4.6 Core
    mov edi, 0x00022002      ; GLFW_CONTEXT_VERSION_MAJOR
    mov esi, 4
    call glfwWindowHint

    mov edi, 0x00022003      ; GLFW_CONTEXT_VERSION_MINOR
    mov esi, 6
    call glfwWindowHint

    mov edi, 0x00022008      ; GLFW_OPENGL_PROFILE
    mov esi, 0x00032001      ; GLFW_OPENGL_CORE_PROFILE
    call glfwWindowHint
; --- This works! Don't touvh it! --- ;
    jmp .create_window   ; go create the window

.create_window:
    ; Create window
    mov esi, dword [window_height]      ; height
    mov edi, dword [window_width]       ; width
    lea rdx, [rel window_title_str]     ; rdx -> title C-string
    xor ecx, ecx                        ; monitor (NULL)
    xor r8d, r8d                        ; share (NULL)
    call glfwCreateWindow
    test rax, rax
    jz .glfw_window_failed         ; failed, jump to handler
    mov [window], rax              ; store pointer in our global var

    ; Success path
    jmp .create_window_ok

.create_window_ok:
    ; Make context current
    mov rdi, [window]
    call glfwMakeContextCurrent

    ; Set viewport using the window size variables
    xor edi, edi                     ; x = 0
    xor esi, esi                     ; y = 0
    mov edx, dword [window_width]    ; width
    mov ecx, dword [window_height]   ; height
    call glViewport

    ; ---------------------------
    ; Compile vertex shader
    ; GLuint glCreateShader(GLenum shaderType);
    mov edi, 0x8B31                  ; GL_VERTEX_SHADER
    call glCreateShader
    mov dword [vertex_shader_id], eax

    ; void glShaderSource(GLuint shader, GLsizei count, const GLchar *const *string, const GLint *lengths);
    mov edi, dword [vertex_shader_id] ; shader
    mov esi, 1                        ; count
    lea rdx, [rel vertex_shader_ptr]  ; const char * const * strings
    xor rcx, rcx                      ; lengths = NULL
    call glShaderSource

    ; glCompileShader
    mov edi, dword [vertex_shader_id]
    call glCompileShader

    ; ---------------------------
    ; Compile fragment shader
    mov edi, 0x8B30                  ; GL_FRAGMENT_SHADER
    call glCreateShader
    mov dword [fragment_shader_id], eax

    mov edi, dword [fragment_shader_id]
    mov esi, 1
    lea rdx, [rel fragment_shader_ptr]
    xor rcx, rcx
    call glShaderSource

    mov edi, dword [fragment_shader_id]
    call glCompileShader

    ; ---------------------------
    ; Link program
    ; GLuint glCreateProgram(void);
    call glCreateProgram
    mov dword [program_id], eax

    ; glAttachShader(program, shader)
    mov edi, dword [program_id]
    mov esi, dword [vertex_shader_id]
    call glAttachShader

    mov edi, dword [program_id]
    mov esi, dword [fragment_shader_id]
    call glAttachShader

    ; glLinkProgram(program)
    mov edi, dword [program_id]
    call glLinkProgram

    ; get location: GLint loc = glGetUniformLocation(program, "offset");
    mov edi, dword [program_id]      ; program
    lea rsi, [rel offset_name]       ; const char *name
    call glGetUniformLocation
    mov dword [offset_loc], eax      ; store location

    ; Use program
    mov edi, dword [program_id]
    call glUseProgram

    ; ---------------------------
    ; Create VAO and VBO (proper arg ordering)
    ; glGenVertexArrays(GLsizei n, GLuint *arrays)
    mov edi, 1               ; n = 1
    sub rsp, 16              ; align and reserve space for return slot
    lea rsi, [rsp]           ; pointer to storage for VAO id
    call glGenVertexArrays
    mov eax, dword [rsp]     ; load generated VAO id
    mov dword [vao_id], eax
    add rsp, 16

    ; glBindVertexArray(GLuint array)
    mov edi, dword [vao_id]
    call glBindVertexArray

    ; glGenBuffers(GLsizei n, GLuint *buffers)
    mov edi, 1
    sub rsp, 16
    lea rsi, [rsp]
    call glGenBuffers
    mov eax, dword [rsp]
    mov dword [vbo_id], eax
    add rsp, 16

    ; glBindBuffer(GLenum target, GLuint buffer)
    mov edi, 0x8892           ; GL_ARRAY_BUFFER
    mov esi, dword [vbo_id]
    call glBindBuffer

    ; glBufferData(GLenum target, GLsizeiptr size, const void *data, GLenum usage)
    mov edi, 0x8892           ; GL_ARRAY_BUFFER
    mov rsi, 9 * 4            ; size in bytes (9 floats * 4)
    lea rdx, [rel vertices]   ; pointer to vertex data
    mov ecx, 0x88E4           ; GL_STATIC_DRAW
    call glBufferData

    ; glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer)
    mov edi, 0                ; index = 0
    mov esi, 3                ; size = 3 (vec3)
    mov edx, 0x1406           ; GL_FLOAT
    xor ecx, ecx              ; normalized = GL_FALSE (0)
    mov r8d, 12               ; stride = 3 * sizeof(float)
    xor r9, r9                ; pointer offset = NULL
    call glVertexAttribPointer

    ; glEnableVertexAttribArray(0)
    mov edi, 0
    call glEnableVertexAttribArray

    ; Unbind VBO and VAO to be tidy (optional)
    mov edi, 0
    call glBindVertexArray      ; bind VAO 0
    mov edi, 0
    call glBindBuffer           ; bind buffer 0 (GL_ARRAY_BUFFER, 0) -> but glBindBuffer needs target in edi, buffer in esi
    ; Correction for glBindBuffer unbind: set target and buffer:
    mov edi, 0x8892
    xor esi, esi
    call glBindBuffer

    ; ---------------------------
    ; Set clear color (optional)
    ; was in the loop I think so watch out
    xor eax, eax
    movss xmm0, dword [zero_f]   ; red = 1.0
    movss xmm1, dword [zero_f]  ; green = 0.0
    movss xmm2, dword [zero_f]  ; blue = 0.0
    movss xmm3, dword [one_f]   ; alpha = 1.0
    call glClearColor

    call run_game_loop 

    jmp .cleanup

.cleanup:
    ; Terminate GLFW
    call glfwTerminate

    ; Restore stack
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret

.glfw_window_failed:
    ; get description of last error
    lea rdi, [glfw_err_desc]
    call glfwGetError    
    test eax, eax
    jz .cleanup              
    mov rdx, [glfw_err_desc]
    mov rdi, err_create
    mov rsi, rdx
    xor eax, eax
    call printf

