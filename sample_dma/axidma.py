import uio
import numpy as np


def to_bin(x):
    vv = [ (x>>(32-(i+1)*4))&0xF for i in range(8)]
    return '{0:04b}_{1:04b}|{2:04b}_{3:04b}|{4:04b}_{5:04b}|{6:04b}_{7:04b}'.format( *vv )


axi_dma_direct_dtype = np.dtype([
        ('cr'        , '<u4'),
        ('st'        , '<u4'),
        ('reserved1' , '<u4',4),
        ('addr_lo'   , '<u4'),
        ('addr_hi'   , '<u4'),
        ('reserved2' , '<u4',2),
        ('length'    , '<u4'),
        ('pad'       , '<u4'),])

axi_dma_sg_dtype = np.dtype([
        ('cr'             , '<u4'),
        ('st'             , '<u4'),
        ('curr_desc'      , '<u4'),
        ('curr_desc_msb'  , '<u4'),
        ('tail_desc'      , '<u4'),
        ('tail_desc_msb'  , '<u4'),
        ('reserved'       , '<u4',5),
        ('sg_ctl'         , '<u4'),])


sg_desc_dtype = np.dtype([
        ('next'               , '<u4'),
        ('next_msb'           , '<u4'),
        ('buffer_address'     , '<u4'),
        ('buffer_address_msb' , '<u4'),
        ('reserved'           , '<u4',2),
        ('control'            , '<u4'),
        ('status'             , '<u4'),
        ('app'                , '<u4',5),
        ('padding'            , '<u4',3)])


def dma_reset(dma):
    dma.cr = 4
    dma.cr = 0

def dma_idle(dma):
    return (dma.st&2) == 2

def dma_halted(dma):
    return (dma.st&1) == 1

def dma_is_sg(dma): return (dma.st&(1<<3) == (1<<3))

class AxiDMA:
    def __init__(self, name_or_idx='dma'):
        dma_uio = uio.UIO(name_or_idx)
        mm2s, s2mm = dma_uio.as_recarray(2, dtype=axi_dma_direct_dtype)

        self._dma_uio = dma_uio
        self.mm2s = mm2s
        self.s2mm = s2mm
        self._streams = (mm2s, s2mm)

        if self.halted() == False:
            self.reset()

    def __repr__(self):
        #TODO: dump state instead
        return self._dma_uio.__repr__()

    def reset(self):
        map(dma_reset, self._streams)

    def idle(self):
        return dma_idle(self.s2mm) and dma_idle(self.mm2s)

    def halted(self):
        return dma_halted(self.s2mm) and dma_halted(self.mm2s)

    def _launch_stream(self, ss, buf, irq_flags = 0x1):
        phy_addr, sz = buf
        ss.addr_lo = phy_addr
        ss.cr = (irq_flags<<12)|1
        ss.length = sz

    def launch(self, src_buf, dst_buf, enable_interrupts = True):
        irq_flags = 0x1 if enable_interrupts else 0

        if enable_interrupts:
            self._dma_uio.enable_interrupts()

        self._launch_stream(self.s2mm, dst_buf, irq_flags)
        self._launch_stream(self.mm2s, src_buf, irq_flags)


    def wait(self, n_iter=2):
        x = self._dma_uio.wait_for_interrupt(reenable=True)
        if x < n_iter: #wait for second interrupt
            x = self._dma_uio.wait_for_interrupt()

        result = self.idle()
        self.reset()

        return result


class AxiDMA_SG:
    def __init__(self, name_or_idx='dma'):
        dma_uio = uio.UIO(name_or_idx)
        mm2s, s2mm = dma_uio.as_recarray(2, dtype=axi_dma_sg_dtype)

        self._dma_uio = dma_uio
        self.mm2s = mm2s
        self.s2mm = s2mm
        self._streams = (mm2s, s2mm)


    def __repr__(self):
        #TODO: dump state instead
        return self._dma_uio.__repr__()

    def reset(self):
        map(dma_reset, self._streams)

    def idle(self):
        return dma_idle(self.s2mm) and dma_idle(self.mm2s)

    def halted(self):
        return dma_halted(self.s2mm) and dma_halted(self.mm2s)

    def _launch_stream(self, ss, buf, irq_flags = 0x1):
        #TODO: descriptor chain management
        phy_addr, sz = buf
        ss.cr = (irq_flags<<12)|1

        assert False and "Not implemented"

    def launch(self, src_buf, dst_buf, enable_interrupts = True):
        irq_flags = 0x1 if enable_interrupts else 0

        if enable_interrupts:
            self._dma_uio.enable_interrupts()

        self._launch_stream(self.s2mm, dst_buf, irq_flags)
        self._launch_stream(self.mm2s, src_buf, irq_flags)


    def wait(self, n_iter=2):
        x = self._dma_uio.wait_for_interrupt(reenable=True)
        if x < n_iter: #wait for second interrupt
            x = self._dma_uio.wait_for_interrupt()

        result = self.idle()
        self.reset()

        return result
