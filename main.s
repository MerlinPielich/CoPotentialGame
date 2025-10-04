# main.s

    .extern glfwInit
    .extern glClearColor
    .extern glGetUniformLocation
    .extern glfwGetKey
    .extern glfwSetWindowShouldClose
    .extern glClear
    .extern glUniform2f
    .extern glBegin
    .extern glVertex3f
    .extern glEnd
    .extern glfwSwapBuffers
    .extern glfwPollEvents
    .extern glfwMakeContextCurrent
    .extern glfwCreateWindow
    .extern glfwWindowHint
    .extern glfwWindowShouldClose
    .extern glfwTerminate
    .extern glUseProgram
    .extern glBindBuffer
    .extern glEnableVertexAttribArray
    .extern glVertexAttribPointer
    .extern glBindVertexArray
    .extern glGenBuffers
    .extern glBufferData
    .extern glLinkProgram
    .extern glAttachShader
    .extern glGenVertexArrays
    .extern glShaderSource
    .extern glCreateProgram
    .extern glCompileShader
    .extern glCreateShader
    .extern glViewport
    .extern glDrawArrays
    .extern glOrtho
    .extern glColor3f
    .extern initGLEW
    .extern glfwGetError

    .extern run_game_loop

    .extern check_s
    .extern check_a
    .extern check_w
    .extern check_d
    .extern check_esc

    .extern update_triangle_position

    .extern printf

    .globl main
    .globl window
    .globl offset_loc
    .globl vao_id
    .globl program_id
    .globl tri_x
    .globl tri_y

    .section .rodata
vertex_shader_src:
    .asciz "#version 330 core\nlayout (location = 0) in vec3 aPos;\nuniform vec2 offset;\nvoid main() {\n  vec2 pos = aPos.xy + offset;\n  gl_Position = vec4(pos, aPos.z, 1.0);\n}\n"

fragment_shader_src:
    .asciz "#version 330 core\nout vec4 FragColor;\nvoid main() {\n   FragColor = vec4(1.0, 0.0, 0.0, 1.0);\n}\n"

    .section .data
    .align 8
window_width:
    .long 1920
window_height:
    .long 1080
window_title_str:
    .asciz "GLFW + OpenGL"

w_pressed_str:
    .asciz "W pressed!\n"

offset_name:
    .asciz "offset"
offset_loc:
    .long -1

tri_x:
    .float 0.0
tri_y:
    .float 0.0

red:
    .float 0.0
green:
    .float 0.0
blue:
    .float 0.0
alpha:
    .float 1.0

x1:
    .float 0.0
y1:
    .float 0.0
z1:
    .float 0.0
x2:
    .float 320.0
y2:
    .float 480.0
z2:
    .float 0.0
x3:
    .float 640.0
y3:
    .float 0.0
z3:
    .float 0.0

one_f:
    .float 1.0
zero_f:
    .float 0.0

zero:
    .quad 0
one:
    .quad 1
neg_one:
    .quad -1

vertex_shader_ptr:
    .quad vertex_shader_src
fragment_shader_ptr:
    .quad fragment_shader_src

program_id:
    .long 0
vertex_shader_id:
    .long 0
fragment_shader_id:
    .long 0
vao_id:
    .long 0
vbo_id:
    .long 0

error_message:
    .asciz "Error: %s\n"
ok_msg:
    .asciz "glfwInit succeeded\n"
err_create:
    .asciz "glfwCreateWindow failed: %s\n"
err_fmt:
    .asciz "GLFW error %d: %s\n"

    .align 4
vertices:
    .float 0.0, 0.5, 0.0, -0.5, -0.5, 0.0, 0.5, -0.5, 0.0

    .section .bss
    .align 8
glfw_err_desc:
    .zero 8
window:
    .zero 8
t1:
    .zero 16
t2:
    .zero 16

    .section .text
    .type main, @function
main:
    pushq %rbp
    movq %rsp, %rbp
    subq $32, %rsp      # allocate stack space and keep alignment

# .glfw_init:
    call glfwInit
    testl %eax, %eax
    jnz .init_ok

    # failed -> get error
    leaq glfw_err_desc(%rip), %rdi
    call glfwGetError
    movq $err_fmt, %rdi
    movl %eax, %esi
    movq glfw_err_desc(%rip), %rdx
    xorl %eax, %eax
    call printf
    jmp .cleanup
.init_ok:
    # after call glfwInit
    leaq ok_msg(%rip), %rdi
    xorl %eax, %eax
    call printf

    # Check for GLFW errors
    call glfwGetError
    testq %rax, %rax
    jz .set_hints

    # Handle GLFW error
    leaq error_message(%rip), %rdi
    movq %rax, %rsi
    call printf
    jmp .cleanup

.set_hints:
    # Force client API = OpenGL
    movl $0x00022001, %edi
    movl $0x00030001, %esi
    call glfwWindowHint

    # Force EGL context creation (important for Wayland + NVIDIA)
    movl $0x0002200E, %edi
    movl $0x00032002, %esi
    call glfwWindowHint

    # Request OpenGL 4.6 Core
    movl $0x00022002, %edi
    movl $4, %esi
    call glfwWindowHint

    movl $0x00022003, %edi
    movl $6, %esi
    call glfwWindowHint

    movl $0x00022008, %edi
    movl $0x00032001, %esi
    call glfwWindowHint

    jmp .create_window

.create_window:
    # Create window
    movl window_height(%rip), %esi    # height
    movl window_width(%rip), %edi     # width
    leaq window_title_str(%rip), %rdx # rdx -> title C-string
    xorl %ecx, %ecx                   # monitor (NULL)
    xorl %r8d, %r8d                   # share (NULL) -- use r8d to set low 32 bits
    call glfwCreateWindow
    testq %rax, %rax
    jz .glfw_window_failed
    movq %rax, window(%rip)

    jmp .create_window_ok

.create_window_ok:
    # Make context current
    movq window(%rip), %rdi
    call glfwMakeContextCurrent

    # Set viewport using the window size variables
    xorl %edi, %edi            # x = 0
    xorl %esi, %esi            # y = 0
    movl window_width(%rip), %edx
    movl window_height(%rip), %ecx
    call glViewport

    # ---------------------------
    # Compile vertex shader
    # GLuint glCreateShader(GLenum shaderType);
    movl $0x8B31, %edi        # GL_VERTEX_SHADER
    call glCreateShader
    movl %eax, vertex_shader_id(%rip)

    # void glShaderSource(GLuint shader, GLsizei count, const GLchar *const *string, const GLint *lengths);
    movl vertex_shader_id(%rip), %edi
    movl $1, %esi
    leaq vertex_shader_ptr(%rip), %rdx
    xorl %ecx, %ecx
    call glShaderSource

    # glCompileShader
    movl vertex_shader_id(%rip), %edi
    call glCompileShader

    # ---------------------------
    # Compile fragment shader
    movl $0x8B30, %edi        # GL_FRAGMENT_SHADER
    call glCreateShader
    movl %eax, fragment_shader_id(%rip)

    movl fragment_shader_id(%rip), %edi
    movl $1, %esi
    leaq fragment_shader_ptr(%rip), %rdx
    xorl %ecx, %ecx
    call glShaderSource

    movl fragment_shader_id(%rip), %edi
    call glCompileShader

    # ---------------------------
    # Link program
    call glCreateProgram
    movl %eax, program_id(%rip)

    # glAttachShader(program, shader)
    movl program_id(%rip), %edi
    movl vertex_shader_id(%rip), %esi
    call glAttachShader

    movl program_id(%rip), %edi
    movl fragment_shader_id(%rip), %esi
    call glAttachShader

    # glLinkProgram(program)
    movl program_id(%rip), %edi
    call glLinkProgram

    # get location: GLint loc = glGetUniformLocation(program, "offset");
    movl program_id(%rip), %edi
    leaq offset_name(%rip), %rsi
    call glGetUniformLocation
    movl %eax, offset_loc(%rip)

    # Use program
    movl program_id(%rip), %edi
    call glUseProgram

    # ---------------------------
    # Create VAO and VBO (proper arg ordering)
    # glGenVertexArrays(GLsizei n, GLuint *arrays)
    movl $1, %edi
    subq $16, %rsp
    leaq (%rsp), %rsi
    call glGenVertexArrays
    movl (%rsp), %eax
    movl %eax, vao_id(%rip)
    addq $16, %rsp

    # glBindVertexArray(GLuint array)
    movl vao_id(%rip), %edi
    call glBindVertexArray

    # glGenBuffers(GLsizei n, GLuint *buffers)
    movl $1, %edi
    subq $16, %rsp
    leaq (%rsp), %rsi
    call glGenBuffers
    movl (%rsp), %eax
    movl %eax, vbo_id(%rip)
    addq $16, %rsp

    # glBindBuffer(GLenum target, GLuint buffer)
    movl $0x8892, %edi         # GL_ARRAY_BUFFER
    movl vbo_id(%rip), %esi
    call glBindBuffer

    # glBufferData(GLenum target, GLsizeiptr size, const void *data, GLenum usage)
    movl $0x8892, %edi         # GL_ARRAY_BUFFER
    movq $36, %rsi             # size in bytes (9 floats * 4)
    leaq vertices(%rip), %rdx  # pointer to vertex data
    movl $0x88E4, %ecx         # GL_STATIC_DRAW
    call glBufferData

    # glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer)
    movl $0, %edi              # index = 0
    movl $3, %esi              # size = 3 (vec3)
    movl $0x1406, %edx         # GL_FLOAT
    xorl %ecx, %ecx            # normalized = GL_FALSE (0)
    movl $12, %r8d             # stride = 3 * sizeof(float)
    xorl %r9d, %r9d            # pointer offset = NULL
    call glVertexAttribPointer

    # glEnableVertexAttribArray(0)
    movl $0, %edi
    call glEnableVertexAttribArray

    # Unbind VBO and VAO to be tidy (optional)
    movl $0, %edi
    call glBindVertexArray      # bind VAO 0

    # bind buffer 0 (GL_ARRAY_BUFFER, 0)
    movl $0x8892, %edi
    xorl %esi, %esi
    call glBindBuffer

    # ---------------------------
    # Set clear color (optional)
    xorl %eax, %eax
    movss zero_f(%rip), %xmm0   # red = 0.0
    movss zero_f(%rip), %xmm1   # green = 0.0
    movss zero_f(%rip), %xmm2   # blue = 0.0
    movss one_f(%rip), %xmm3    # alpha = 1.0
    call glClearColor

    call run_game_loop

    jmp .cleanup

.cleanup:
    call glfwTerminate

    movq %rbp, %rsp
    popq %rbp
    xorl %eax, %eax
    ret

.glfw_window_failed:
    leaq glfw_err_desc(%rip), %rdi
    call glfwGetError
    testl %eax, %eax
    jz .cleanup
    movq glfw_err_desc(%rip), %rdx
    leaq err_create(%rip), %rdi
    movq %rdx, %rsi
    xorl %eax, %eax
    call printf

    .size main, .-main
