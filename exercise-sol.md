### exercise 1.2:

入口（bootloader）地址：0x0000000000080000 in _start ().

### exercise 1.3 :

```
There are 9 section headers, starting at offset 0x20cd8: 

节头： 
  [号] 名称        类型       地址        偏移量 
    大小        全体大小      旗标  链接  信息  对齐 
  [ 0]          NULL       0000000000000000  00000000 
    0000000000000000  0000000000000000      0   0   0 
  [ 1] init        PROGBITS     0000000000080000  00010000 
    000000000000b5b0  0000000000000008 WAX    0   0   4096 
  [ 2] .text       PROGBITS     ffffff000008c000  0001c000 
    00000000000011dc  0000000000000000  AX    0   0   8 
  [ 3] .rodata      PROGBITS     ffffff0000090000  00020000 
    00000000000000f8  0000000000000001 AMS    0   0   8 
  [ 4] .bss        NOBITS      ffffff0000090100  000200f8 
    0000000000008000  0000000000000000  WA    0   0   16 
  [ 5] .comment      PROGBITS     0000000000000000  000200f8 
    0000000000000032  0000000000000001  MS    0   0   1 
  [ 6] .symtab      SYMTAB      0000000000000000  00020130 
    0000000000000858  0000000000000018      7   46   8 
  [ 7] .strtab      STRTAB      0000000000000000  00020988 
    000000000000030f  0000000000000000      0   0   1 
  [ 8] .shstrtab     STRTAB      0000000000000000  00020c97 
    000000000000003c  0000000000000000      0   0   1 
Key to Flags: 
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info), 
  L (link order), O (extra OS processing required), G (group), T (TLS), 
  C (compressed), x (unknown), o (OS specific), E (exclude), 
  p (processor specific)
```

入口在init段内，地址值0x80000定义于boot/image.h，后经链接器脚本将init设置为0x80000,编译时使用链接器脚本最终得到此结果。

启动流程：将mpidr_el1中的core id载入x8，然后x8寄存器和自身相与，如果结果为0则正常启动，如果结果不为零则被挂起。

### exercise 1.4:

```
build/kernel.img：     文件格式 elf64-little

节：
Idx Name          Size      VMA               LMA               File off  Algn
  0 init          0000b5b0  0000000000080000  0000000000080000  00010000  2**12
                  CONTENTS, ALLOC, LOAD, CODE
  1 .text         000011dc  ffffff000008c000  000000000008c000  0001c000  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
  2 .rodata       000000f8  ffffff0000090000  0000000000090000  00020000  2**3
                  CONTENTS, ALLOC, LOAD, READONLY, DATA
  3 .bss          00008000  ffffff0000090100  0000000000090100  000200f8  2**4
                  ALLOC
  4 .comment      00000032  0000000000000000  0000000000000000  000200f8  2**0
                  CONTENTS, READONLY
```

如输出所示，init和comment段的VMA和LMA地址相同。text,rodata,bss段则不相同。init段存储的是bootloader代码，此时没有虚拟地址概念。同时comment段存储的注释信息与程序运行无关，所以lma和vma相同。而text段，rodata段，bss段在程序运行事会先被装载进内存在由cpu取指令执行。此时若开启mmu则有实地址和虚拟地址之分，故lma和vma不一样。内核通过虚拟内存映射达到地址转换的效果。

### exercise 1.5:

具体实现见kernel/common/printk.c

### exercise 1.6:

内核栈初始化代码位于kernel/head.S中，内核栈位于内存中的0xffffff0000090110处，在主函数中加入一条语句输出地址即可获得对应的值。这里是把kernel_stack这个二维数组当作内核栈。

### exercise 1.7: 

stack_test函数反汇编可得：

```
(gdb) disass stack_test
Dump of assembler code for function stack_test:
=> 0xffffff000008c020 <+0>:     stp     x29, x30, [sp, #-32]!
   0xffffff000008c024 <+4>:     mov     x29, sp
   0xffffff000008c028 <+8>:     str     x19, [sp, #16]
   0xffffff000008c02c <+12>:    mov     x19, x0
   0xffffff000008c030 <+16>:    mov     x1, x0
   0xffffff000008c034 <+20>:    adrp    x0, 0xffffff0000090000
   0xffffff000008c038 <+24>:    add     x0, x0, #0x0
   0xffffff000008c03c <+28>:    bl      0xffffff000008c620 <printk>
   0xffffff000008c040 <+32>:    cmp     x19, #0x0
   0xffffff000008c044 <+36>:    b.gt    0xffffff000008c068 <stack_test+72>
   0xffffff000008c048 <+40>:    bl      0xffffff000008c0dc <stack_backtrace>
   0xffffff000008c04c <+44>:    mov     x1, x19
   0xffffff000008c050 <+48>:    adrp    x0, 0xffffff0000090000
   0xffffff000008c054 <+52>:    add     x0, x0, #0x20
   0xffffff000008c058 <+56>:    bl      0xffffff000008c620 <printk>
   0xffffff000008c05c <+60>:    ldr     x19, [sp, #16]
   0xffffff000008c060 <+64>:    ldp     x29, x30, [sp], #32
   0xffffff000008c064 <+68>:    ret
   0xffffff000008c068 <+72>:    sub     x0, x19, #0x1
   0xffffff000008c06c <+76>:    bl      0xffffff000008c020 <stack_test>
   0xffffff000008c070 <+80>:    mov     x1, x19
   0xffffff000008c074 <+84>:    adrp    x0, 0xffffff0000090000
   0xffffff000008c078 <+88>:    add     x0, x0, #0x20
   0xffffff000008c07c <+92>:    bl      0xffffff000008c620 <printk>
   0xffffff000008c080 <+96>:    ldr     x19, [sp, #16]
   0xffffff000008c084 <+100>:   ldp     x29, x30, [sp], #32
   0xffffff000008c088 <+104>:   ret
End of assembler dump.
```

结合每次嵌套调用时函数栈入栈数据分析可知，每次递归会将三个值入栈，分别是sp(x29),lr(x30),参数x(x19)。

### exercise 1.8: 

最终调用栈如下所示：

```
(gdb) x/30xg $sp
0xffffff0000092030 <kernel_stack+7984>: 0xffffff0000092050      0xffffff000008c070
0xffffff0000092040 <kernel_stack+8000>: 0x0000000000000001      0x00000000ffffffc0
0xffffff0000092050 <kernel_stack+8016>: 0xffffff0000092070      0xffffff000008c070
0xffffff0000092060 <kernel_stack+8032>: 0x0000000000000002      0x00000000ffffffc0
0xffffff0000092070 <kernel_stack+8048>: 0xffffff0000092090      0xffffff000008c070
0xffffff0000092080 <kernel_stack+8064>: 0x0000000000000003      0x00000000ffffffc0
0xffffff0000092090 <kernel_stack+8080>: 0xffffff00000920b0      0xffffff000008c070
0xffffff00000920a0 <kernel_stack+8096>: 0x0000000000000004      0x00000000ffffffc0
0xffffff00000920b0 <kernel_stack+8112>: 0xffffff00000920d0      0xffffff000008c070
0xffffff00000920c0 <kernel_stack+8128>: 0x0000000000000005      0x00000000ffffffc0
0xffffff00000920d0 <kernel_stack+8144>: 0xffffff00000920f0      0xffffff000008c0d4
0xffffff00000920e0 <kernel_stack+8160>: 0x0000000000000000      0x00000000ffffffc0
0xffffff00000920f0 <kernel_stack+8176>: 0x0000000000000000      0xffffff000008c018
0xffffff0000092100 <kernel_stack+8192>: 0x0000000000000000      0x0000000000000000
0xffffff0000092110 <kernel_stack+8208>: 0x0000000000000000      0x0000000000000000
```

通过观察栈内数据和相应数据存储地址，我们不难发现父函数的寄存器中的值被保存在子函数栈中。

这里要注意，参数在函数调用前

### exercise 1.9:

具体实现见kernel/monitor.c。
