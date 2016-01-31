#include "my_mult.h"
#include <stdio.h>

bool run_test(uint16_t a, uint16_t b)
{
    uint32_t expect = uint32_t(a)*b;

    uint32_t in = (uint32_t(a)<<16)|b;
    uint32_t out = 0;

    my_mult_axis(&in, &out);

    printf("IN: %u %u => expect: %u actual: %u diff: %d %s\n"
	   , uint32_t(a), uint32_t(b)
	   , expect, out
	   , expect - out
	   , expect == out ? "OK": "FAILED");


    return out == expect;
}

int main(int argc, char *argv[])
{
    (void)argc; (void) argv;

    if ( !run_test(3,6) ) return 1;
    if ( !run_test(0xFFFF,0xFFFF) ) return 1;

    return 0;
}
