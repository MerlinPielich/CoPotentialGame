; movement.asm

    global update_triangle_position

    ; WASD input checks
    extern check_w
    extern check_a
    extern check_s
    extern check_d
    extern tri_x
    extern tri_y

section .data
    step dd 0.02          ; movement step

section .text
update_triangle_position:

    ; move up if W pressed
    call check_w         ; returns 1 if pressed, 0 otherwise in eax
    test eax, eax
    jz .skip_up
    movss xmm0, dword [tri_y]
    addss xmm0, dword [step]
    movss dword [tri_y], xmm0
.skip_up:

    ; move down if S pressed
    call check_s
    test eax, eax
    jz .skip_down
    movss xmm0, dword [tri_y]
    subss xmm0, dword [step]
    movss dword [tri_y], xmm0
.skip_down:

    ; move left if A pressed
    call check_a
    test eax, eax
    jz .skip_left
    movss xmm0, dword [tri_x]
    subss xmm0, dword [step]
    movss dword [tri_x], xmm0
.skip_left:

    ; move right if D pressed
    call check_d
    test eax, eax
    jz .skip_right
    movss xmm0, dword [tri_x]
    addss xmm0, dword [step]
    movss dword [tri_x], xmm0
.skip_right:

    ret
