from __future__ import annotations
from typing import Callable
import numpy as np

Matrix = np.ndarray
Stream = Callable[[int], Matrix]

def trans_endo(f: Stream, i: int, j: int, n: int) -> Matrix:
    """Ordered product f(j-1) @ ... @ f(i); identity when j <= i."""
    acc: Matrix = np.eye(n)
    for t in range(i, max(i, j)):
        acc = f(t) @ acc
    return acc

def windowed_transition_rank(f: Stream, i: int, j: int, n: int,
                             tol: float = 1e-9) -> int:
    """Rank of the transition endomorphism over the window [i, j)."""
    return int(np.linalg.matrix_rank(trans_endo(f, i, j, n), tol=tol))
