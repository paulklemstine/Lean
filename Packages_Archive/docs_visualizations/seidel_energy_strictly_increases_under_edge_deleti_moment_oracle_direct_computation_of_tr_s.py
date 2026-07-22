from __future__ import annotations
import numpy as np

def spectral_moments(adjacency: np.ndarray) -> tuple[float, float]:
    """Return the first two Seidel spectral moments (tr S, tr S^2) WITHOUT
    diagonalizing.

    The trace of S is the sum of its zero diagonal, hence 0. The trace of S^2 is
    the sum of squares of all entries of S (S symmetric): each of the n(n-1)
    off-diagonal entries is +-1, so tr S^2 = n(n-1). This routine computes both
    directly in O(n^2), giving a moment oracle that is provably blind to edge
    deletion (both values are structural constants).
    """
    n: int = adjacency.shape[0]
    seidel: np.ndarray = np.ones((n, n)) - np.eye(n) - 2.0 * adjacency.astype(float)
    first: float = float(np.trace(seidel))
    second: float = float(np.sum(seidel * seidel))  # = tr(S^2) since S symmetric
    return first, second
