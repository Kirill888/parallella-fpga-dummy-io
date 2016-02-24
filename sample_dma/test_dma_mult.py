#!/usr/bin/env python
from __future__ import print_function


def report_stats(dt, n_in, n_out, item_sz = 4):
    from numpy import r_
    bb = r_[n_in, n_out, n_in + n_out]
    mbb  = bb*1e-6
    bps  = bb/dt
    mbps = mbb/dt
    N    = n_in/item_sz

    print('Memory    : %g Mb(in) + %g Mb(out) = %g Mb(total)'%(mbb[0], mbb[1], mbb[2]) )
    print('Took      : %g ms'%(dt*1e+3))
    print('Per item  : %g us'%((dt*1e+6)/N ))
    print('Items/s   : %.1f' %(N/dt))
    print('Throughput: %g Mb/s(in) + %g Mb/s(out) = %g Mb/s'%(mbps[0], mbps[1], mbps[2]))

def mult_model(src):
    """ Model of the computation performed by PL

        takes memory  |a0_b0|a1_b1|...
        and generates |a0*b0|a1*b1|...
    """

    # view src memory as two interleaved streams of uint16 values
    ab = src.view('uint16')
    a = ab[0::2]
    b = ab[1::2]

    dst = a.astype('uint32')*b
    return dst.view('uint8')

if __name__ == '__main__':
    from axidma import AxiDMA
    import uio
    import numpy as np
    import time
    import sys

    dma = AxiDMA('dma')
    mem_uio = uio.UIO('scratch_mem')

    SZ=(1<<20)

    data = mem_uio.as_ndarray()

    print('Generating Test Data')
    #Generate random test data
    src_data = data[:SZ]
    dst_data = data[SZ:SZ*2]

    src_data[:] = np.random.randint(0,256,SZ)
    dst_data[:] = 0xFF
    expect_data = mult_model(src_data)

    print('SRC   :', src_data[:8],'...')
    print('DST   :', dst_data[:8],'...')
    print('Expect:', expect_data[:8],'...')

    print('='*80)

    print('\nLaunching DMA')
    #Start DMA, time how long it took
    t0 = time.time()

    dma.launch(mem_uio.phy_buf(src_data),
               mem_uio.phy_buf(dst_data),
               enable_interrupts=True)

    rr = dma.wait()
    t_done = time.time()
    dt     = t_done - t0

    if rr:
        print('DMA Transaction Completed')
    else:
        print('DMA FAILED')
        sys.exit(1)


    print('Verifying results...         ', end='')
    if (expect_data == dst_data).all():
        print('SUCCESS: Data received as expected')
    else:
        print('FAILED: results do not match expectations')

    print('='*80)

    print("SRC   :",src_data[:8],'...')
    print("DST   :",dst_data[:8],'...')
    print("Expect:",expect_data[:8],'...')

    print('\nTime Stats')
    print('='*80)
    report_stats(dt, SZ, SZ)
