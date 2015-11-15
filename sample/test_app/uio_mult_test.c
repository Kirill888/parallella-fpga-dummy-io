#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <inttypes.h>


int main(int argc, char *argv[])
{
    size_t len = 1<<(10+2); //4K

    int fd = open("/dev/uio0", O_SYNC|O_RDWR);

    if ( fd < 0 )
    {
	perror("Failed to open /dev/uio0\n"
	       "  Does it exists?\n"
	       "  Check permissions\n"
	       "  Check devicetree\n");
	return -1;
    }

    void *mem = mmap(NULL, len
		     , PROT_READ | PROT_WRITE, MAP_SHARED, fd
		     , 0);

    if (mem == MAP_FAILED) {
	perror("Can't map memory");
	close(fd);
	return -2;
    }

    volatile uint32_t * p = (uint32_t*)mem;

    printf("Initial memory state:\n");
    for( size_t i = 0; i < 4; ++i) {printf("%08x ", p[i]);}
    printf("\n");


    for(;;)
    {
	uint32_t a,b;

	printf("Enter two positive interegers in decimal notations:\n>  ");
	fflush(stdout);
	if (scanf("%u %u", &a, &b) != 2)
	    break;

	if ( a > 0xFFFF || b > 0xFFFF)
	{
	    printf("Input values are out of range, must fit in 2 bytes: 0-0xFFFF\n");
	    continue;
	}

	p[0] = (a<<16)|(b);

	uint32_t result = p[1];

	printf("%08x  => %08x (%5u) expect: %5u\n", p[0], result, result, a*b);
    }

    printf("Final memory state:\n");
    for(size_t i = 0; i < 4; ++i) {printf("%08x ", p[i]);}
    printf("\n");

    //cleanup
    munmap(mem, len);
    close(fd);

    return 0;
}
