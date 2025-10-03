; timing_loop.asm -- fixed-timestep + render skeleton (NASM)

    ; Public
    global run_game_loop

    ; from main
    extern window
    extern update_triangle_position
    extern tri_y
    extern tri_x
    extern offset_loc
    extern vao_id
    extern program_id

    ; from glfw 
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
    extern glfwSwapBuffers
    extern glfwPollEvents
    extern glfwWindowShouldClose

    ; from CLib
    extern printf
    extern clock_gettime

section .bss
    ts_now   resq 2   ; struct timespec: tv_sec (qword), tv_nsec (qword)
    ts_last  resq 2
    ; store 64-bit nanosecond values
    now_ns   resq 1
    last_ns  resq 1
    delta_ns resq 1
    acc_ns   resq 1
    ; fixed step in nanoseconds (64-bit)
    fixed_ns resq 1

section .data
    CLOCK_MONOTONIC    equ 1
    ; debug format
    dbg_fmt db "delta_ns=%ld acc_ns=%ld fixed_ns=%ld",10,0

section .text

; run_game_loop() - starts the loop (call from main)
run_game_loop:
    push rbp
    mov rbp, rsp

    and rsp, -16       ; align stack

    ; initialize fixed timestep = 15625000 ns (64 Hz)
    mov rax, 15625000
    mov [fixed_ns], rax

    ; initialize accumulator = 0
    xor rax, rax
    mov [acc_ns], rax

    ; get initial time into ts_last
    mov edi, CLOCK_MONOTONIC
    lea rsi, [ts_last]
    call clock_gettime

    ; compute last_ns = tv_sec * 1e9 + tv_nsec
    mov rax, [ts_last]          ; tv_sec (qword)
    imul rax, 1000000000        ; rax = sec * 1e9
    add rax, [ts_last + 8]     ; add tv_nsec
    mov [last_ns], rax

.game_loop:

    ; check window closes
    mov rdi, [window] ; if you have window pointer global; else omit
    call glfwWindowShouldClose
    test eax, eax
    jnz .exit_loop

    ; get current time
    mov edi, CLOCK_MONOTONIC
    lea rsi, [ts_now]
    call clock_gettime

    ; now_ns = ts_now.tv_sec * 1e9 + ts_now.tv_nsec
    mov rax, [ts_now]
    imul rax, 1000000000
    add rax, [ts_now + 8]
    mov [now_ns], rax

    ; delta_ns = now_ns - last_ns
    mov rax, [now_ns]
    sub rax, [last_ns]
    mov [delta_ns], rax

    ; store last = now
    mov rax, [now_ns]
    mov [last_ns], rax

    ; clamp delta to avoid blowup
    mov rbx, 100000000
    mov rax, [delta_ns]
    cmp rax, rbx
    jle .no_clamp
    mov [delta_ns], rbx
.no_clamp:

    ; accumulator += delta
    mov rax, [acc_ns]
    add rax, [delta_ns]
    mov [acc_ns], rax

    ; fixed = [fixed_ns]
    mov rdx, [fixed_ns]

    ; while (accumulator >= fixed) { update(); accumulator -= fixed; }
.physics_loop:
    mov rax, [acc_ns]
    cmp rax, rdx
    jb .render_loop

    ; call update (your fixed-step physics update)
    ; pass any args if needed; here update_triangle_position uses globals

    call update_triangle_position

    ; accumulator -= fixed
    mov rax, [acc_ns]
    sub rax, rdx
    mov [acc_ns], rax

    jmp .physics_loop

.render_loop:  
    ; call render_frame

    ; if (glfwWindowShouldClose(window)) break;
    mov rdi, [window]
    call glfwWindowShouldClose
    test eax, eax
    jnz .cleanup

    ; glClear(GL_COLOR_BUFFER_BIT)
    mov edi, 0x00004000
    call glClear

    ; glUseProgram(program_id)
    mov edi, dword [program_id]
    call glUseProgram

    ; glUniform2f()
    movss xmm0, dword [tri_x]
    movss xmm1, dword [tri_y]
    mov edi, dword [offset_loc]
    call glUniform2f   ; set offset uniform

    ; glBindVertexArray(vao_id)
    ; glDrawArrays(GL_TRIANGLES, 0, 3)
    mov edi, dword [vao_id]
    call glBindVertexArray

    mov edi, 0x0004      ; GL_TRIANGLES
    xor esi, esi         ; first = 0
    mov edx, 3           ; count = 3
    call glDrawArrays

; --- Pollin for user input ---

    mov rdi, [window]
    call glfwSwapBuffers
    call glfwPollEvents

    ; loop back
    jmp .game_loop

.exit_loop:
    pop rbp
    ret


.cleanup:
    ; Terminate GLFW
    call glfwTerminate

    ; Restore stack
    mov rsp, rbp
    pop rbp
    xor eax, eax
    ret



