// texture renderer

.section .text
.globl   draw_texture
.type    draw_texture, @function

draw_texture:
        push %rbp
        mov  %rsp, %rbp
        sub  $32, %rsp

        // Save texture id into esi immediately (preserve it while we call functions that set edi)
        movl %edi, %esi ## %esi = texture id

        // compute half sizes
        movss .LC_HALF(%rip), %xmm4
        movss %xmm2, %xmm5
        mulss %xmm4, %xmm5
        movss %xmm3, %xmm6
        mulss %xmm4, %xmm6

        movss %xmm0, %xmm7
        subss %xmm5, %xmm7
        movss %xmm1, %xmm8
        subss %xmm6, %xmm8

        movss %xmm0, %xmm9
        addss %xmm5, %xmm9
        movss %xmm1, %xmm10
        addss %xmm6, %xmm10

        // Enable texture
        movl $0x0DE1, %edi
        call glEnable

        // Bind texture: (target, texture)
        movl $0x0DE1, %edi // target = GL_TEXTURE_2D

        // texture id is in esi already
        call glBindTexture

        // Begin quad
        movl $0x0007, %edi ## GL_QUADS
        call glBegin

        // Bottom-left: texcoord (0,0) vertex (bl_x, bl_y)
        movss .LC_0(%rip), %xmm0 ## s = 0.0
        movss .LC_0(%rip), %xmm1 ## t = 0.0
        call  glTexCoord2f
        movss %xmm7, %xmm0       ## x = bl_x
        movss %xmm8, %xmm1       ## y = bl_y
        call  glVertex2f

        // Bottom-right: texcoord##1,0) vertex (br_x, bl_y)
        movss .LC_1(%rip), %xmm0 ## s = 1.0
        movss .LC_0(%rip), %xmm1 ## t = 0.0
        call  glTexCoord2f
        movss %xmm9, %xmm0       ## x = br_x
        movss %xmm8, %xmm1       ## y = bl_y
        call  glVertex2f

        // Top-right: texcoord (1##) vertex (tr_x, tr_y)
        movss .LC_1(%rip), %xmm0
        movss .LC_1(%rip), %xmm1
        call  glTexCoord2f
        movss %xmm9, %xmm0       ## x = tr_x
        movss %xmm10, %xmm1      ## y = tr_y
        call  glVertex2f

        // Top-left: texcoord (0,## vertex (tl_x, tr_y)
        movss .LC_0(%rip), %xmm0
        movss .LC_1(%rip), %xmm1
        call  glTexCoord2f
        movss %xmm7, %xmm0       ## x = tl_x
        movss %xmm10, %xmm1      ## y = tr_y
        call  glVertex2f

        call glEnd

        add $32, %rsp
        pop %rbp
        ret

.size draw_texture, .-draw_texture

.section .rodata

.LC_HALF:
        .float 0.5

.LC_0:
        .float 0.0

.LC_1:
        .float 1.0
