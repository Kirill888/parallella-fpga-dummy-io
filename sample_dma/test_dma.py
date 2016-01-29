#!/usr/bin/env python
from __future__ import print_function

if __name__ == '__main__':
    from axidma import AxiDMA
    import uio
    import numpy as np

    dma = AxiDMA('dma')
    mem_uio = uio.UIO('scratch_mem')

    SZ=(1<<12)

    data = mem_uio.as_ndarray()

    src_data = data[:SZ]
    dst_data = data[SZ:SZ*2]

    src_data[:] = np.random.randint(0,256,SZ)
    dst_data[:] = 0xFF

    print("SRC:", src_data[:4],'...')
    print("DST:", dst_data[:4],'...')

    dma.launch(mem_uio.phy_buf(src_data)
               , mem_uio.phy_buf(dst_data)
               , enable_interrupts=True)

    if dma.wait():
        print('DMA Transfer Completed')
    else:
        print('DMA Transfer FAILED')

    if (src_data == dst_data).all():
        print('SUCCESS: Data copied as expected')
    else:
        print('FAILED: dst and src do not match up')

    print("SRC:",src_data[:4],'...')
    print("DST:",dst_data[:4],'...')
