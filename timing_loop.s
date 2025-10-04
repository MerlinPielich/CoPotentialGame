# timing_loop.s

    .extern window
    .extern update_triangle_position
    .extern tri_y
    .extern tri_x
    .extern offset_loc
    .extern vao_id
    .extern program_id

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
    .extern glfwSwapBuffers
    .extern glfwPollEvents
    .extern glfwWindowShouldClose

    .extern printf
    .extern clock_gettime

    .globl run_game_loop

    .equ CLOCK_MONOTONIC, 1

    .section .bss
    .align 8
ts_now:
    .zero 16          # struct timespec: tv_sec (8), tv_nsec (8)
ts_last:
    .zero 16
now_ns:
    .zero 8
last_ns:
    .zero 8
delta_ns:
    .zero 8
acc_ns:
    .zero 8
fixed_ns:
    .zero 8

    .section .data
dbg_fmt:
    .asciz "delta_ns=%ld acc_ns=%ld fixed_ns=%ld\n"

    .section .text
    .type run_game_loop, @function
run_game_loop:
    pushq %rbp
    movq %rsp, %rbp
    andq $-16, %rsp          # align stack

    # initialize fixed timestep = 15625000 ns (64 Hz)
    movq $15625000, %rax
    movq %rax, fixed_ns(%rip)

    # initialize accumulator = 0
    xorl %eax, %eax
    movq %rax, acc_ns(%rip)

    # get initial time into ts_last
    movl $CLOCK_MONOTONIC, %edi
    leaq ts_last(%rip), %rsi
    call clock_gettime

    # compute last_ns = tv_sec * 1e9 + tv_nsec
    movq ts_last(%rip), %rax         # tv_sec
    imulq $1000000000, %rax
    addq ts_last+8(%rip), %rax       # add tv_nsec
    movq %rax, last_ns(%rip)

.game_loop:
    # check window closes
    movq window(%rip), %rdi
    call glfwWindowShouldClose
    testl %eax, %eax
    jnz .exit_loop

    # get current time
    movl $CLOCK_MONOTONIC, %edi
    leaq ts_now(%rip), %rsi
    call clock_gettime

    # now_ns = ts_now.tv_sec * 1e9 + ts_now.tv_nsec
    movq ts_now(%rip), %rax
    imulq $1000000000, %rax
    addq ts_now+8(%rip), %rax
    movq %rax, now_ns(%rip)

    # delta_ns = now_ns - last_ns
    movq now_ns(%rip), %rax
    subq last_ns(%rip), %rax
    movq %rax, delta_ns(%rip)

    # store last = now
    movq now_ns(%rip), %rax
    movq %rax, last_ns(%rip)

    # clamp delta to avoid blowup
    movq $100000000, %rbx
    movq delta_ns(%rip), %rax
    cmpq %rbx, %rax
    jle .no_clamp
    movq %rbx, delta_ns(%rip)
.no_clamp:

    # accumulator += delta
    movq acc_ns(%rip), %rax
    addq delta_ns(%rip), %rax
    movq %rax, acc_ns(%rip)

    # fixed = [fixed_ns]
    movq fixed_ns(%rip), %rdx

    # while (accumulator >= fixed) { update(); accumulator -= fixed; }
.physics_loop:
    movq acc_ns(%rip), %rax
    cmpq %rdx, %rax
    jb .render_loop

    call update_triangle_position

    movq acc_ns(%rip), %rax
    subq %rdx, %rax
    movq %rax, acc_ns(%rip)

    jmp .physics_loop

.render_loop:
    # if (glfwWindowShouldClose(window)) break;
    movq window(%rip), %rdi
    call glfwWindowShouldClose
    testl %eax, %eax
    jnz .cleanup

    # glClear(GL_COLOR_BUFFER_BIT)
    movl $0x00004000, %edi
    call glClear

    # glUseProgram(program_id)
    movl program_id(%rip), %edi
    call glUseProgram

    # glUniform2f()
    movss tri_x(%rip), %xmm0
    movss tri_y(%rip), %xmm1
    movl offset_loc(%rip), %edi
    call glUniform2f

    # glBindVertexArray(vao_id)
    movl vao_id(%rip), %edi
    call glBindVertexArray

    # glDrawArrays(GL_TRIANGLES, 0, 3)
    movl $0x0004, %edi
    xorl %esi, %esi
    movl $3, %edx
    call glDrawArrays

    # Polling for user input
    movq window(%rip), %rdi
    call glfwSwapBuffers
    call glfwPollEvents

    jmp .game_loop

.exit_loop:
    popq %rbp
    ret

.cleanup:
    # Terminate GLFW
    call glfwTerminate

    # Restore stack/frame
    movq %rbp, %rsp
    popq %rbp
    xorl %eax, %eax
    ret
    .size run_game_loop, .-run_game_loop
