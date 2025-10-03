; input.asm -- keyboard input functions

    
    global check_a
    global check_s
    global check_d
    global check_w
    global check_esc

    ; from main
    extern window
   
   ; from glfw
    extern glfwGetKey
    extern glfwSetWindowShouldClose

    ;from Clib
    extern printf

section .data
    a_pressed_str db "a pressed!", 10, 0
    s_pressed_str db "s pressed!", 10, 0
    w_pressed_str db "w pressed!", 10, 0
    d_pressed_str db "d pressed!", 10, 0

section .text

; -------------------------------------
; int check_escape(GLFWwindow* window)
; Returns 1 if ESC pressed, else 0
; -------------------------------------

check_input:
    
    push rbp
    mov rbp, rsp

    call check_w
    call check_a
    call check_s
    call check_d
    call check_esc

    mov rsp, rbp
    pop rbp
    ret

check_w:
    push rbp
    mov rbp, rsp

    mov rdi, rdi           ; window*
    mov rdi, [window]
    mov esi, 87            ; GLFW_KEY_W
    call glfwGetKey
    cmp eax, 1             ; GLFW_PRESS
    jne .not_pressed_w

    ; print message
    ; mov rdi, w_pressed_str
    ; xor eax, eax
    ; call printf
    ; mov eax, 1
    jmp .done_w

.not_pressed_w:
    xor eax, eax           ; return 0

.done_w:
    mov rsp, rbp
    pop rbp
    ret

check_d:
    push rbp
    mov rbp, rsp

    mov rdi, rdi           ; window*
    mov rdi, [window]
    mov esi, 68           ; GLFW_KEY_D
    call glfwGetKey
    cmp eax, 1             ; GLFW_PRESS
    jne .not_pressed_d

    ; print message
    ; mov rdi, d_pressed_str
    ; xor eax, eax
    ; call printf
    ; mov eax, 1
    jmp .done_d

.not_pressed_d:
    xor eax, eax           ; return 0

.done_d:
    mov rsp, rbp
    pop rbp
    ret


check_a:
    push rbp
    mov rbp, rsp

    mov rdi, rdi           ; window*
    mov rdi, [window]
    mov esi, 65           ; GLFW_KEY_A
    call glfwGetKey
    cmp eax, 1             ; GLFW_PRESS
    jne .not_pressed_a

    ; print message
    ; mov rdi, a_pressed_str
    ; xor eax, eax
    ; call printf
    ; mov eax, 1
    jmp .done_a

.not_pressed_a:
    xor eax, eax           ; return 0

.done_a:
    mov rsp, rbp
    pop rbp
    ret

; -------------------------------------
; int check_w(GLFWwindow* window)
; Returns 1 if W pressed, else 0
; -------------------------------------
check_esc:
   ; check ESC key
   ; If pressed then close window
   push rbp
   mov rbp, rsp

   mov rdi, [window]
   mov esi, 256                     ; GLFW_KEY_ESCAPE = 256 (!

   call glfwGetKey

   cmp eax, 1                       ; GLFW_PRESS = 2
   jne .done_esc
   mov rdi, [window]
   mov esi, 1
   call glfwSetWindowShouldClose

.not_pressed_esc:
    xor eax, eax

.done_esc:
    mov rsp, rbp
    pop rbp
    ret


check_s:
    push rbp
    mov rbp, rsp

    mov rdi, rdi           ; window*
    mov rdi, [window]
    mov esi, 83            ; GLFW_KEY_W
    call glfwGetKey
    cmp eax, 1
    jne .not_pressed_s

    ; print message
    ; mov rdi, s_pressed_str
    ; xor eax, eax
    ; call printf
    ; mov eax, 1
    jmp .done_s

.not_pressed_s:
    xor eax, eax

.done_s:
    mov rsp, rbp
    pop rbp
    ret

