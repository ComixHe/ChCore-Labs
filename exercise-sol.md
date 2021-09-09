### exercise 2.1:

编译阶段：scripts/linker-aarch64.lds.in在.init段指定了bootloader的内存布局，.text, .data, .rodata, .bss等段指定了内核的内存布局。

运行阶段：在kernel/mm/mm.c中，mm_init函数初始化内存页相关部分，此时页面元数据和页面的内存布局被确定。

### exercise 2.2:

见kernel/mm/buddy.c文件中的实现。

