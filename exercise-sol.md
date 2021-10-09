### Exercise 3.1 :

具体实现参见kernel/process/thread.c ,kernel/sched/context.c ,kernel/sched/sched.c。

### Exercise 3.2 :

具体过程解释参见kernel/process/process.c中process_create_root函数的注释。

### Exercise 3.3 :

具体实现参见kernel/exception/exception_table.s, kernel/exception/exception.S, kernel/exception/exception.c。

### Exercise 3.4 ：

用户态触发同步异常后进入sync_el0_64进行判断，如果同步异常是svc指令触发，则进入el0_syscall后根据syscall_table和syscall_number找到对应的系统调用入口，然后再调用相应的系统调用处理程序。

### Exercise 3.5 :

具体实现参见user/lib/syscall.c。

### Exercise 3.6 :

具体实现参见kernel/syscall/syscall.c, kernal/mm/vm_syscall.c。

### Exercise 3.8 :

具体实现参见user/lib/libmain.c。

### Exercise 3.9 :

具体实现参见kernel/exception/pgfault.c, kernel/exception/exception.c。

