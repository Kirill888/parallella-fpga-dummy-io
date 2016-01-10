def _get_line(fname):
    try:
        with open(fname,'r') as f:
            return f.readline().rstrip()
    except IOError:
        return None


def _get_int(fname):
    s = _get_line(fname)
    if s is None: return None

    if s.startswith('0x'): return int(s,16)
    return int(s)


def uio_get_name  (idx): return _get_line('/sys/class/uio/uio%d/name'%(idx))
def uio_get_event (idx): return _get_int ('/sys/class/uio/uio%d/event'%(idx))
def uio_get_addr  (idx): return _get_int ('/sys/class/uio/uio%d/maps/map0/addr'%(idx))
def uio_get_offset(idx): return _get_int ('/sys/class/uio/uio%d/maps/map0/offset'%(idx))
def uio_get_size  (idx): return _get_int ('/sys/class/uio/uio%d/maps/map0/size'%(idx))


def uio_find_by_name(name):
    for i in range(100):
        n = uio_get_name(i)

        if n is None: return None
        if n == name: return i

    return None

def _maybe_numpy():
    try:
        import numpy
        return numpy
    except ImportError:
        return None

_np = _maybe_numpy()


class UIO:

    @staticmethod
    def _ptr_from_buffer(mm):
        ''' Return pointer to memory pointed by the buffer
        '''
        import ctypes
        return ctypes.addressof( ctypes.c_void_p.from_buffer(mm))

    @staticmethod
    def _ptr(x):
        if hasattr(x,'ctypes') and hasattr(x.ctypes,'data'): #probably numpy array:
            return x.ctypes.data

        return None




    def __init__(self, idx):
        import mmap
        import os

        if isinstance(idx, str):
            name = idx
            idx = uio_find_by_name(name)
            if idx is None:
                raise IOError('No such UIO device:'+name)

        sz = uio_get_size(idx)
        if sz is None: raise IOError("Wrong UIO idx: %d"%(idx))

        fd = os.open('/dev/uio%d'%(idx) , os.O_RDWR)
        mm = mmap.mmap(fd, sz)

        self._idx = idx
        self._fd  = fd
        self._mm  = mm
        self._name = uio_get_name(idx)
        self._event_count = uio_get_event(idx)

        self._virt_addr = UIO._ptr_from_buffer(mm)
        self._phy_addr  = uio_get_addr(idx)
        self._sz        = sz


        self._about = "UIO: %s (uio%d) sz:0x%x @0x%08x"%(self._name, self._idx, sz, self._phy_addr)

    def as_ndarray(self, shape=None, dtype='uint8'):
        import numpy as np

        dtype = np.dtype(dtype)
        if shape is None:
            shape = long(len(self._mm)//dtype.itemsize)
        return np.ndarray(shape, dtype, buffer=self._mm)

    def as_recarray(self, shape, dtype):
        import numpy as np
        return np.recarray(shape, dtype, buf=self._mm)

    def virt2phy(self, addr):
        """ Map virtual address to physical
        """
        if addr < self._virt_addr           : return None
        if addr > self._virt_addr + self._sz: return None

        return self._phy_addr + (addr - self._virt_addr)


    def phy(self, arg=None):
        """ Return physical memory value

            no-args          -> base address of the device
            integer argument -> base address plus byte offset

            ndarray          -> physical address of the first element, taking care of any slices
        """
        if arg is None: return self._phy_addr

        if isinstance(arg, (int,long)):
            return self._phy_addr + arg

        pp = UIO._ptr(arg)
        if pp is not None:
            return self.virt2phy(pp)

        raise TypeError('Supported types: None, int,long, and numpy.ndarray')


    def wait_for_interrupt(self):
        """ Blocking, returns number of interrupts that happened since last
            time this function was called, or since creation time in
            case of the first call.

        """
        import os
        import struct

        os.write(self._fd, struct.pack('@I',1))
        e_count = struct.unpack('@I', os.read(self._fd,4) )[0]
        e_diff = e_count - self._event_count
        self._event_count = e_count

        return e_diff



    def __repr__(self):
        return self._about

    def __del__(self):
        import os
        import mmap

        self._mm.close()
        os.close(self._fd)
