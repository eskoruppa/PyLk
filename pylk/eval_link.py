import numpy as np
import warnings
from .linkingnumber_python import _eval_lk_python

LK_METHOD = 0
try:
    from .linkingnumber_cython import _eval_lk_cython
    LK_METHOD = 1
except ModuleNotFoundError:
    # warnings.warn(
    #     "Cython version of linkingnumber (PyLk) not compiled. Defaulting to numba implementation. Consider compiling the cython version."
    # )
    try:
        from .linkingnumber_numba import _eval_lk_numba
        LK_METHOD = 2
    except ModuleNotFoundError:
        # warnings.warn(
        #     "PyLK: Numba not installed. Defaulting to python implementation. Consider installing numba or compiling cython implementation."
        # )
        pass
         
def linkingnumber(chain1: np.ndarray, chain2: np.ndarray, closed: bool = True) -> np.ndarray:
    # The cython implementations are typed double[:, ::1] and reject
    # non-contiguous or non-float64 input that the other paths accept.
    chain1 = np.ascontiguousarray(chain1, dtype=np.float64)
    chain2 = np.ascontiguousarray(chain2, dtype=np.float64)
    if LK_METHOD == 1:
        return _eval_lk_cython(chain1,chain2,closed=closed)
    elif LK_METHOD == 2:
        return _eval_lk_numba(chain1,chain2,closed=closed)
    return _eval_lk_python(chain1,chain2)

