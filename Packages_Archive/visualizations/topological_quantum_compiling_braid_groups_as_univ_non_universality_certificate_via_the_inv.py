from __future__ import annotations
from typing import List
import numpy as np


def burau(i: int, t: complex) -> np.ndarray:
    mats = {
        1: [[-t, 0, 0], [1, 1, 0], [0, 0, 1]],
        2: [[1, t, 0], [0, -t, 0], [0, 1, 1]],
        3: [[1, 0, 0], [0, 1, t], [0, 0, -t]],
    }
    return np.array(mats[i], dtype=complex)


def non_universality_certificate(t: complex, tol: float = 1e-9) -> bool:
    """Return True if the parameter t is *certified non-universal*.

    A sufficient obstruction: every generator is an involution (rho(sigma_i)^2 = I),
    forcing the image through the finite symmetric group S_4. Returns True exactly
    when this obstruction is detected.
    """
    I = np.eye(3, dtype=complex)
    return all(np.allclose(burau(i, t) @ burau(i, t), I, atol=tol) for i in (1, 2, 3))
