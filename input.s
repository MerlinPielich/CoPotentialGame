# input.s

    .extern window
    .extern glfwGetKey
    .extern glfwSetWindowShouldClose
    .extern printf

    .globl check_a
    .globl check_s
    .globl check_d
    .globl check_w
    .globl check_esc
    .globl check_input

    .section .data
a_pressed_str:
    .asciz "a pressed!\n"
s_pressed_str:
    .asciz "s pressed!\n"
w_pressed_str:
    .asciz "w pressed!\n"
d_pressed_str:
    .asciz "d pressed!\n"

    .section .text
    .type check_input, @function
check_input:
    pushq %rbp
    movq %rsp, %rbp

    call check_w
    call check_a
    call check_s
    call check_d
    call check_esc

    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_input, .-check_input

    .type check_w, @function
check_w:
    pushq %rbp
    movq %rsp, %rbp

    # window* in %rdi -> supply from global window
    movq window(%rip), %rdi
    movl $87, %esi              # GLFW_KEY_W
    call glfwGetKey
    cmpl $1, %eax               # GLFW_PRESS
    jne .not_pressed_w

    # (optionally print) ; left commented out in original
    # leaq w_pressed_str(%rip), %rdi
    # xorl %eax, %eax
    # call printf

    jmp .done_w

.not_pressed_w:
    xorl %eax, %eax             # return 0

.done_w:
    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_w, .-check_w

    .type check_d, @function
check_d:
    pushq %rbp
    movq %rsp, %rbp

    movq window(%rip), %rdi
    movl $68, %esi              # GLFW_KEY_D
    call glfwGetKey
    cmpl $1, %eax
    jne .not_pressed_d

    # leaq d_pressed_str(%rip), %rdi
    # xorl %eax, %eax
    # call printf

    jmp .done_d

.not_pressed_d:
    xorl %eax, %eax

.done_d:
    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_d, .-check_d

    .type check_a, @function
check_a:
    pushq %rbp
    movq %rsp, %rbp

    movq window(%rip), %rdi
    movl $65, %esi              # GLFW_KEY_A
    call glfwGetKey
    cmpl $1, %eax
    jne .not_pressed_a

    # leaq a_pressed_str(%rip), %rdi
    # xorl %eax, %eax
    # call printf

    jmp .done_a

.not_pressed_a:
    xorl %eax, %eax

.done_a:
    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_a, .-check_a

    .type check_esc, @function
check_esc:
    pushq %rbp
    movq %rsp, %rbp

    movq window(%rip), %rdi
    movl $256, %esi             # GLFW_KEY_ESCAPE
    call glfwGetKey

    cmpl $1, %eax
    jne .done_esc

    movq window(%rip), %rdi
    movl $1, %esi
    call glfwSetWindowShouldClose

.done_esc:
    xorl %eax, %eax
    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_esc, .-check_esc

    .type check_s, @function
check_s:
    pushq %rbp
    movq %rsp, %rbp

    movq window(%rip), %rdi
    movl $83, %esi              # GLFW_KEY_S
    call glfwGetKey
    cmpl $1, %eax
    jne .not_pressed_s

    # leaq s_pressed_str(%rip), %rdi
    # xorl %eax, %eax
    # call printf

    jmp .done_s

.not_pressed_s:
    xorl %eax, %eax

.done_s:
    movq %rbp, %rsp
    popq %rbp
    ret
    .size check_s, .-check_s
