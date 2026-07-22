from __future__ import annotations
import numpy as np
from numpy.typing import NDArray
Array = NDArray[np.float64]

def apply_join(internal: list[Array], weights: Array, fibers: list[Array]) -> list[Array]:
    sizes=np.array([len(x) for x in fibers],dtype=float)
    masses=np.array([x.sum() for x in fibers],dtype=float)
    degrees=weights@sizes
    coupling=weights@masses
    return [internal[i]@fibers[i]+degrees[i]*fibers[i]-coupling[i]
            for i in range(len(fibers))]
