from __future__ import annotations
import math
from typing import List, Sequence


def vandermonde_reconstruct(energies: Sequence[float],
                            samples: Sequence[float]) -> List[float]:
    """Solve the Vandermonde system V d = samples with V[k,i] = exp(-E_i)^k.

    Valid for distinct energies (V invertible). Time O(n^2) with partial-pivot
    Gaussian elimination.
    """
    n = len(energies)
    x = [math.exp(-e) for e in energies]
    m: List[List[float]] = [[x[i] ** k for i in range(n)] + [samples[k]]
                            for k in range(n)]
    for c in range(n):
        p = max(range(c, n), key=lambda r: abs(m[r][c]))
        m[c], m[p] = m[p], m[c]
        pv = m[c][c]
        m[c] = [v / pv for v in m[c]]
        for r in range(n):
            if r != c and m[r][c]:
                f = m[r][c]
                m[r] = [a - f * b for a, b in zip(m[r], m[c])]
    return [m[i][n] for i in range(n)]
