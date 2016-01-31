#include "my_mult.h"

void my_mult_axis(uint32_t const * S_AXIS, uint32_t * D_AXIS)
{
    uint32_t v = *S_AXIS;

    uint16_t a = v>>16;
    uint16_t b = v&0xFFFF;

    uint32_t r = a*b;

    *D_AXIS = r;
}
