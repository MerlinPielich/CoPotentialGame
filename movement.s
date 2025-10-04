# movement.s -- AT&T/GAS version of update_triangle_position

    .extern check_w
    .extern check_a
    .extern check_s
    .extern check_d
    .extern tri_x
    .extern tri_y

    .globl update_triangle_position

    .section .data
    .align 4
step:
    .float 0.02          # movement step

    .section .text
    .type update_triangle_position, @function
update_triangle_position:
    # move up if W pressed
    call check_w                  # returns 1 if pressed, 0 otherwise in eax
    testl %eax, %eax
    jz .skip_up
    movss tri_y(%rip), %xmm0
    addss step(%rip), %xmm0
    movss %xmm0, tri_y(%rip)
.skip_up:

    # move down if S pressed
    call check_s
    testl %eax, %eax
    jz .skip_down
    movss tri_y(%rip), %xmm0
    subss step(%rip), %xmm0
    movss %xmm0, tri_y(%rip)
.skip_down:

    # move left if A pressed
    call check_a
    testl %eax, %eax
    jz .skip_left
    movss tri_x(%rip), %xmm0
    subss step(%rip), %xmm0
    movss %xmm0, tri_x(%rip)
.skip_left:

    # move right if D pressed
    call check_d
    testl %eax, %eax
    jz .skip_right
    movss tri_x(%rip), %xmm0
    addss step(%rip), %xmm0
    movss %xmm0, tri_x(%rip)
.skip_right:

    ret
    .size update_triangle_position, .-update_triangle_position
