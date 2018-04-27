		 .data
_c:
		.quad 0
_b:
		.quad 0
_a:
		.quad 0
_f:
		.quad 0
_d:
		.quad 0
_e:
		.quad 0
_m:
		.quad 0
_h:
		.quad 0
_l:
		.quad 0
_n:
		.quad 0
_x:
		.quad 0
_z:
		.quad 0
_count0:
		.quad 0
_count1:
		.quad 0
_count2:
		.quad 0
_count3:
		.quad 0
_count4:
		.quad 0
_count5:
		.quad 0
_count6:
		.quad 0
_count7:
		.quad 0
_count8:
		.quad 0
_count9:
		.quad 0
_fib:
		.quad 0
_i:
		.quad 0
_j:
		.quad 0
_k:
		.quad 0
_int:
		.quad 0
_argc:
		.quad 0
for_mat:
		.byte '%', 'l', 'u', 10, 0
		.text
x_0xbbddc0:
		mov %r15, %rsi
		mov %rsi, _c
		mov %r12, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r15
		mov _c, %rsi
		mov %rsi, %r12
		mov %r13, %rsi
		mov %rsi, _c
		mov %r12, %rsi
		push %rsi
		mov %r11, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r14
		mov %r11, %rsi
		push %rsi
		mov %r13, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r13
		mov _c, %rsi
		mov %rsi, %r11
		mov %r10, %rsi
		mov %rsi, _c
		mov %r14, %rsi
		push %rsi
		mov %r9, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r14
		mov %r9, %rsi
		push %rsi
		mov %r10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r10
		mov _c, %rsi
		mov %rsi, %r9
		mov %r8, %rsi
		mov %rsi, _c
		mov %r14, %rsi
		push %rsi
		mov %rcx, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r14
		mov %r8, %rsi
		push %rsi
		mov %rcx, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r8
		mov _c, %rsi
		mov %rsi, %rcx
		mov %rdx, %rsi
		mov %rsi, _c
		mov %r14, %rsi
		push %rsi
		mov _z, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %r14
		mov _z, %rsi
		push %rsi
		mov %rdx, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, %rdx
		mov _c, %rsi
		mov %rsi, _z
		mov %r14, %rsi
		mov %rsi, _count0
		mov $1, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count1
		mov $2, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count2
		mov $3, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count3
		mov $4, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count4
		mov $5, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count5
		mov $6, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count6
		mov $7, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count7
		mov $8, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count8
		mov $9, %rsi
		push %rsi
		mov %r14, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count9
w_0:
		mov _count0, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov _count0, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count1, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count1, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count2, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count2, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count3, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count3, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count4, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count4, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count5, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count5, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count6, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count6, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count7, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count7, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count8, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count8, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count9, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		push %rsi
		mov _count9, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		imul %rax, %rsi
		cmp $0, %rsi
		jz b_0
		mov _count0, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count0
		mov _count1, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count1
		mov _count2, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count2
		mov _count3, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count3
		mov _count4, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count4
		mov _count5, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count5
		mov _count6, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count6
		mov _count7, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count7
		mov _count8, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count8
		mov _count9, %rsi
		push %rsi
		mov $10, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _count9
		jmp w_0
b_0:
		mov %r12, %rsi
		call print_f
if_1:
		mov _count0, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		push %rsi
		mov _count1, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count2, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count3, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count4, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count5, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count6, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count7, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov _count8, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		pop %rax
		add %rax, %rsi
		cmp $0, %rsi
		jz e_1
		mov %r12, %rsi
		call print_f
		jmp c_1
e_1:
if_2:
		mov %r12, %rsi
		push %rsi
		mov $1134903170, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		cmp $0, %rsi
		jz e_2
		mov %r12, %rsi
		call print_f
		jmp c_2
e_2:
		call *_fib
c_2:
c_1:
		ret
print_f:
		mov $for_mat, %rdi
		mov $0, %rax
		mov %r11,_e
		mov %r10,_m
		mov %r9,_h
		mov %r8,_l
		mov %rcx,_n
		mov %rdx,_x
		call printf
		mov _e, %r11
		mov _m, %r10
		mov _h, %r9
		mov _l, %r8
		mov _n, %rcx
		mov _x, %rdx
		ret
		.global main
main:
		mov %rdi, _argc
		mov _argc, %rbx
		mov _b, %r15
		mov _a, %r12
		mov _f, %r13
		mov _d, %r14
		mov _e, %r11
		mov _m, %r10
		mov _h, %r9
		mov _l, %r8
		mov _n, %rcx
		mov _x, %rdx
		.extern printf
		mov $34, %rsi
		mov %rsi, %r12
		mov $55, %rsi
		mov %rsi, %r15
		mov $0, %rsi
		mov %rsi, _c
		mov $13, %rsi
		mov %rsi, %r11
		mov $21, %rsi
		mov %rsi, %r13
		mov $5, %rsi
		mov %rsi, %r9
		mov $8, %rsi
		mov %rsi, %r10
		mov $2, %rsi
		mov %rsi, %rcx
		mov $3, %rsi
		mov %rsi, %r8
		mov $1, %rsi
		mov %rsi, _z
		mov $1, %rsi
		mov %rsi, %rdx
		mov $0, %rsi
		mov %rsi, %r14
		lea x_0xbbddc0, %rsi
		mov %rsi, _fib
		mov $1, %rsi
		mov %rsi, _i
w_3:
		mov _i, %rsi
		push %rsi
		mov $29999999999999, %rsi
		pop %rax
		add %rax, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		cmp $0, %rsi
		jz b_3
		mov $13701723624970323893, %rsi
		call print_f
		mov _i, %rsi
		push %rsi
		mov $1, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _i
		jmp w_3
b_3:
if_4:
		mov _j, %rsi
		push %rsi
		mov $0, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		cmp $0, %rsi
		jz e_4
if_5:
		mov _j, %rsi
		push %rsi
		mov $1, %rsi
		pop %rax
		cmp %rsi, %rax
		mov $0, %rax
		sete %al
		mov %rax, %rsi
		cmp $0, %rsi
		jz e_5
		mov $4, %rsi
		mov %rsi, _k
		jmp c_5
e_5:
		mov $7, %rsi
		mov %rsi, _k
c_5:
		jmp c_4
e_4:
		mov $12341234, %rsi
		call print_f
c_4:
		mov _k, %rsi
		call print_f
w_6:
		mov $18446744073709551609, %rsi
		push %rsi
		mov _i, %rsi
		pop %rax
		add %rax, %rsi
		cmp $0, %rsi
		jz b_6
w_7:
		mov $18446744073709551609, %rsi
		push %rsi
		mov _j, %rsi
		pop %rax
		add %rax, %rsi
		cmp $0, %rsi
		jz b_7
w_8:
		mov $18446744073709551609, %rsi
		push %rsi
		mov _int, %rsi
		pop %rax
		add %rax, %rsi
		cmp $0, %rsi
		jz b_8
		mov _i, %rsi
		call print_f
		mov _j, %rsi
		call print_f
		mov _int, %rsi
		call print_f
		mov _int, %rsi
		push %rsi
		mov $1, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _int
		jmp w_8
b_8:
		mov _j, %rsi
		push %rsi
		mov $1, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _j
		jmp w_7
b_7:
		mov _i, %rsi
		push %rsi
		mov $1, %rsi
		pop %rax
		add %rax, %rsi
		mov %rsi, _i
		jmp w_6
b_6:
		call *_fib
		mov %rbx, %rsi
		push %rsi
		mov %r15, %rsi
		pop %rax
		add %rax, %rsi
		call print_f
		mov $0, %rax
		ret
