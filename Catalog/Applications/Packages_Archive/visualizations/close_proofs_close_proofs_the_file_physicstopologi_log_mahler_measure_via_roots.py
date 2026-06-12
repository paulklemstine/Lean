from __future__ import annotations
import math, cmath
from typing import List

def poly_eval(coeffs: List[float], x: complex) -> complex:
    """Horner evaluation; coeffs ascending (coeffs[k] = coeff of x^k)."""
    r: complex = 0
    for c in reversed(coeffs):
        r = r * x + c
    return r

def durand_kerner_roots(coeffs: List[float], iters: int = 1000,
                        tol: float = 1e-14) -> List[complex]:
    """All complex roots of a polynomial via the Durand-Kerner iteration."""
    d = max((k for k, c in enumerate(coeffs) if c != 0), default=-1)
    if d < 1:
        return []
    monic = [c / coeffs[d] for c in coeffs[:d + 1]]
    seed = complex(0.4, 0.9)
    roots: List[complex] = [seed ** k for k in range(d)]
    for _ in range(iters):
        delta_max = 0.0
        nxt = roots[:]
        for i in range(d):
            den: complex = 1.0
            for j in range(d):
                if j != i:
                    den *= roots[i] - roots[j]
            if den == 0:
                continue
            step = poly_eval(monic, roots[i]) / den
            nxt[i] = roots[i] - step
            delta_max = max(delta_max, abs(step))
        roots = nxt
        if delta_max < tol:
            break
    return roots

def log_mahler_measure(coeffs: List[float]) -> float:
    """m(P) = sum over roots alpha of max(0, log|alpha|)  (root-factorization)."""
    return sum(max(0.0, math.log(abs(r)))
               for r in durand_kerner_roots(coeffs) if abs(r) > 0)

def mahler_measure(coeffs: List[float]) -> float:
    """M(P) = exp(m(P))."""
    return math.exp(log_mahler_measure(coeffs))
