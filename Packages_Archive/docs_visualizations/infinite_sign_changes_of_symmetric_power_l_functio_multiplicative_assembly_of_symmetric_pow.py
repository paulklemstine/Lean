from __future__ import annotations
import math
from typing import List


def local_sympow_coeffs(theta: float, j: int, e_max: int) -> List[float]:
    """lambda_{sym^j f}(p^e), e = 0..e_max, from the j+1 Satake roots."""
    roots = [complex(math.cos((j - 2 * i) * theta), math.sin((j - 2 * i) * theta))
             for i in range(j + 1)]
    series = [0j] * (e_max + 1)
    series[0] = 1 + 0j
    for z in roots:
        new = [0j] * (e_max + 1)
        for e in range(e_max + 1):
            acc = 0j
            zk = 1 + 0j
            for k in range(e + 1):
                acc += series[e - k] * zk
                zk *= z
            new[e] = acc
        series = new
    return [c.real for c in series]


def assemble_multiplicative(local: dict, N: int) -> List[float]:
    """Assemble a multiplicative function on 1..N from prime-power values.

    `local[p]` is a list with local[p][e] = value at p^e (local[p][0] == 1).
    """
    lam = [0.0] * (N + 1)
    lam[1] = 1.0
    for p, loc in local.items():
        e_max = len(loc) - 1
        new = lam[:]
        for e in range(1, e_max + 1):
            pe = p ** e
            base = 1
            while base * pe <= N:
                if base % p != 0:
                    new[base * pe] = lam[base] * loc[e]
                base += 1
        lam = new
    return lam
