.data
 print: .asciiz "\n" 
 print0: .asciiz main 
.text
main:
		li $v0, 4
		la $a0, print0
		syscall
 li $v0, 10
 syscall
