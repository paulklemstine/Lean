from __future__ import annotations
import numpy as np
from numpy.typing import NDArray
Array = NDArray[np.float64]

def center_fibers(fibers: list[Array]) -> tuple[list[Array], Array]:
    averages=np.array([float(x.mean()) for x in fibers])
    centered=[x-averages[i] for i,x in enumerate(fibers)]
    return centered, averages

def reconstruct(centered: list[Array], averages: Array) -> list[Array]:
    return [x+averages[i] for i,x in enumerate(centered)]
