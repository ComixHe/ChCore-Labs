#include <common/asm.h>

.extern arm64_elX_to_el1
.extern boot_cpu_stack
.extern secondary_boot_flag
.extern secondary_init_c
.extern clear_bss_flag
.extern init_c

BEGIN_FUNC(_start)
	mrs	x8, mpidr_el1 /*把当前的cpuid存到x8寄存器中*/
	and	x8, x8,	#0xFF /*把x8和0xFF相与*/
	cbz	x8, primary  /*结果为0则为主CPU，不为零则为副CPU，主cpu进入primary开始初始化，副cpu清除bss、设置好栈后循环等待主cpu启动副cpu*/

	/* Wait for bss clear */
wait_for_bss_clear:
	adr	x0, clear_bss_flag
	ldr	x1, [x0]
	cmp     x1, #0
	bne	wait_for_bss_clear

	/* Turn to el1 from other exception levels. */
	bl 	arm64_elX_to_el1

	/* Prepare stack pointer and jump to C. */
	mov	x1, #0x1000
	mul	x1, x8, x1
	adr 	x0, boot_cpu_stack
	add	x0, x0, x1
	add	x0, x0, #0x1000
        mov	sp, x0 /* 设置当前cpu栈为boot_cpu_stack[cpuid] */

wait_until_smp_enabled:
	/* CPU ID should be stored in x8 from the first line */
	mov	x1, #8
	mul	x2, x8, x1
	ldr	x1, =secondary_boot_flag
	add	x1, x1, x2
	ldr	x3, [x1]
	cbz	x3, wait_until_smp_enabled /*x3的结果即为secondary_boot_flag[cpuid],结果不为零则进入secondary_init_c初始化当前cpu*/
	/*即这里主cpu通过设置secondary_boot_flag[cpuid] = 1选中启动的cpu*/
	/* Set CPU id */
	mov	x0, x8
	bl 	secondary_init_c

primary:

	/* Turn to el1 from other exception levels. */
	bl 	arm64_elX_to_el1

	/* Prepare stack pointer and jump to C. */
	adr 	x0, boot_cpu_stack
	add 	x0, x0, #0x1000
	mov 	sp, x0

	bl 	init_c

	/* Should never be here */
	b	.
END_FUNC(_start)
