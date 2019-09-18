#include <linux/module.h>
#include <linux/kernel.h>

int init_module(void)
{
	printk(KERN_INFO "Is there anybody out there?\n");
	return 0;
}

void cleanup_module(void)
{
	printk(KERN_INFO "Goodbye, cruel world.\n");
}
