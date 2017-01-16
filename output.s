.data
 print: .asciiz "\n" 
 a: .word 0
 b: .word 0
 c: .word 0
.text
main:
		li $t0, 30
		sw $t0, a
		li $t0, 10
		sw $t0, b
		lw $t0, b
		li $t1, 2
sub t0, $t0, $t1
		lw $t0, a
		lw $t1, t0
add t1, $t0, $t1
		li $t0, t1
		sw $t0, c
		li $v0, 1
		lw $a0, c
		syscall
		li $v0, 4
		la $a0, print
		syscall
 li $v0, 10
 syscall
