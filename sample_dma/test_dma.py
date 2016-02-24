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


if __name__ == '__main__':
    from axidma import AxiDMA
    import uio
    import numpy as np
    import time

    dma = AxiDMA('dma')
    mem_uio = uio.UIO('scratch_mem')

    SZ=(1<<20)

    data = mem_uio.as_ndarray()

    src_data = data[:SZ]
    dst_data = data[SZ:SZ*2]

    src_data[:] = np.random.randint(0,256,SZ)
    dst_data[:] = 0xFF

    print("SRC:", src_data[:4],'...')
    print("DST:", dst_data[:4],'...')

    #Start DMA, time how long it took
    t0 = time.time()
    dma.launch(mem_uio.phy_buf(src_data)
               , mem_uio.phy_buf(dst_data)
               , enable_interrupts=True)

    rr = dma.wait()
    t_done = time.time()
    dt     = t_done - t0

    if rr:
        print('DMA Transaction Completed')
    else:
        print('DMA FAILED')
        sys.exit(1)

    if (src_data == dst_data).all():
        print('SUCCESS: Data copied as expected')
    else:
        print('FAILED: dst and src do not match up')

    print("SRC:",src_data[:4],'...')
    print("DST:",dst_data[:4],'...')

    print('\nTime Stats')
    print('='*80)
    report_stats(dt, SZ, SZ)
