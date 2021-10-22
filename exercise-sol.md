### Exercise 4.1 :

文件差异如下所示：

```
diff --git a/boot/start.S b/boot/start.S
index b330fa5..4820afb 100644
--- a/boot/start.S
+++ b/boot/start.S
@@ -3,6 +3,7 @@
 .extern arm64_elX_to_el1
 .extern boot_cpu_stack
 .extern secondary_boot_flag
+.extern secondary_init_c
 .extern clear_bss_flag
 .extern init_c
 
@@ -11,9 +12,36 @@ BEGIN_FUNC(_start)
        and     x8, x8, #0xFF
        cbz     x8, primary
 
-  /* hang all secondary processors before we intorduce multi-processors */
-secondary_hang:
-       bl secondary_hang
+       /* Wait for bss clear */
+wait_for_bss_clear:
+       adr     x0, clear_bss_flag
+       ldr     x1, [x0]
+       cmp     x1, #0
+       bne     wait_for_bss_clear
+
+       /* Turn to el1 from other exception levels. */
+       bl      arm64_elX_to_el1
+
+       /* Prepare stack pointer and jump to C. */
+       mov     x1, #0x1000
+       mul     x1, x8, x1
+       adr     x0, boot_cpu_stack
+       add     x0, x0, x1
+       add     x0, x0, #0x1000
+        mov    sp, x0
+
+wait_until_smp_enabled:
+       /* CPU ID should be stored in x8 from the first line */
+       mov     x1, #8
+       mul     x2, x8, x1
+       ldr     x1, =secondary_boot_flag
+       add     x1, x1, x2
+       ldr     x3, [x1]
+       cbz     x3, wait_until_smp_enabled
+
+       /* Set CPU id */
+       mov     x0, x8
+       bl      secondary_init_c
 
 primary:
```

问题分析见boot/start.S的中文注释部分。

### Exercise 4.2 :

具体实现参见kernel/main.c和kernel/common/smp.c文件。

### Exercise 4.3 :

并行启动副cpu可能导致并发问题，副cpu启动过程中所用的一些寄存器可能会因为并发问题产生错误的值导致初始化失败，且某些函数属于不可重入函数，所以应该依次启动副cpu。

### Exercise 4.4 :

具体实现参见kernel/common/lock.c文件。

### Exercise 4.5 :

具体实现参见kernel/common/lock.c文件。同时根据文档在相应位置上调用接口加锁，解锁统一在exception_return中。同时需要注意的是，来自内核的异常不能加锁，因为这样会重复加锁，不过不用担心内核再次异常造成一次lock,两次unlock,因为在处理中断的时候会禁止中断触发。

### Exercise 4.6 :

调用unlock_kernel后就要从内核态返回用户态，此时内核处理流程结束了，没有必要再保存寄存器的值。而lock_kernel()后还要继续处理，所以要保存之前寄存器的值以便获取锁后恢复现场继续工作流。

### Exercise 4.7 :

具体实现参见kernel/common/policy_rr.c文件。

### Exercise 4.8 :

在协作式调度的前提下，如果不获取内核锁，当用户线程不主动放弃运行，idle会因为最低的优先级而无法调度新线程，从而一直阻塞。

### Exercise 4.11 :

具体实现参见kernel/common/policy_rr.c和kernel/sched/sched.c文件

### Exercise 4.12 :

具体实现参见kernel/common/policy_rr.c文件。

### Exercise 4.13 :

具体实现参见kernel/process/thread.c文件。

对于调度这一节的一些总结：

	idle线程是为了没有线程就绪时让cpu运行，否则cpu某一颗核心会一直阻塞在内核态等待就绪线程，同时无法释放大内核锁，这时其它cpu核心则无法进入内核态。
	时钟中断处理函数调用链：handle_irq -> plat_handle_irq -> handle_timer_irq -> sched_handle_timer_irq -> rr_sched_handle_timer_irq。
