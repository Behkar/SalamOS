.section .multiboot, "a"
.align 4
.long 0x1BADB002
.long 0x00000003
.long -(0x1BADB002 + 0x00000003)
.section .text
.global _start
_start: call main; cli; 1: hlt; jmp 1b
