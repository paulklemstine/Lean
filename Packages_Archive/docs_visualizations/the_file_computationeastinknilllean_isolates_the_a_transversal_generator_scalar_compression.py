from __future__ import annotations
import numpy as np
from typing import Sequence

Matrix = np.ndarray


def transversal_compression(P: Matrix,
                            terms: Sequence[Matrix],
                            scalars: Sequence[complex]) -> Matrix:
    """Compress a transversal generator G = sum terms[i] on code P.

    By the scalar-compression theorem the answer is (sum scalars) * P,
    computed in O(m) scalar additions plus O(n^2) for the scaling, with
    NO matrix multiplication. Returns (sum_i scalars[i]) * P.
    """
    total_scalar: complex = complex(sum(scalars))
    return total_scalar * P
