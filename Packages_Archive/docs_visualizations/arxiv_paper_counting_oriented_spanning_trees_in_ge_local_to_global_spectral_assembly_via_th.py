from __future__ import annotations
import numpy as np
from numpy.typing import NDArray
Array = NDArray[np.float64]

def quotient(weights: Array, sizes: Array) -> Array:
    return np.diag(weights@sizes)-weights@np.diag(sizes)

def assembled_eigenvalues(internal_zero_mass: list[Array], weights: Array,
                          sizes: Array) -> Array:
    degrees=weights@sizes
    shifted=[internal_zero_mass[i]+degrees[i] for i in range(len(sizes))]
    coarse=np.linalg.eigvals(quotient(weights,sizes))
    return np.sort_complex(np.concatenate([*shifted,coarse]))
