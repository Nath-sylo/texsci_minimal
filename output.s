.data
 print: .asciiz "\n" 
 a: .word 0
 b: .word 0
 c: .word 0
.text
main:
 li $v0, 10
 syscall
