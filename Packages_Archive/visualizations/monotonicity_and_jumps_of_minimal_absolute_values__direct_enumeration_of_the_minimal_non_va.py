from __future__ import annotations
import cmath, math, itertools

def sigma5(n: int, tol: float = 1e-9) -> float:
    roots: list[complex] = [cmath.exp(2j * math.pi * k / 5.0) for k in range(5)]
    best: float = math.inf
    for combo in itertools.combinations_with_replacement(range(5), n):
        s: complex = 0j
        for k in combo:
            s += roots[k]
        m: float = abs(s)
        if m > tol:
            best = min(best, m)
    return best
