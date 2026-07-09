from __future__ import annotations
import math
from typing import Callable, List, Tuple

def eml_separator(lo: float, t: float) -> float:
    """Canonical strictly-monotone EML primitive g(t)=log(t+1-lo)."""
    return math.log(t + 1.0 - lo)

def _solve_normal(design: List[List[float]], y: List[float]) -> List[float]:
    m, d = len(design), len(design[0])
    G = [[sum(design[r][i]*design[r][j] for r in range(m)) for j in range(d)]
         for i in range(d)]
    b = [sum(design[r][i]*y[r] for r in range(m)) for i in range(d)]
    for i in range(d):
        G[i][i] += 1e-9
    aug = [G[i] + [b[i]] for i in range(d)]
    for col in range(d):
        piv = max(range(col, d), key=lambda r: abs(aug[r][col]))
        aug[col], aug[piv] = aug[piv], aug[col]
        p = aug[col][col]
        for r in range(d):
            if r != col and aug[r][col] != 0:
                f = aug[r][col]/p
                aug[r] = [aug[r][k]-f*aug[col][k] for k in range(d+1)]
    return [aug[i][d]/aug[i][i] for i in range(d)]

def eml_density_fit(target: Callable[[float], float], lo: float, hi: float,
                    degree: int, samples: int = 400) -> Tuple[List[float], float]:
    xs = [lo + (hi-lo)*i/(samples-1) for i in range(samples)]
    gx = [eml_separator(lo, x) for x in xs]
    design = [[g**k for k in range(degree+1)] for g in gx]
    ys = [target(x) for x in xs]
    coeffs = _solve_normal(design, ys)
    approx = [sum(coeffs[k]*(gx[i]**k) for k in range(degree+1))
              for i in range(samples)]
    max_err = max(abs(approx[i]-ys[i]) for i in range(samples))
    return coeffs, max_err
