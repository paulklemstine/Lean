from __future__ import annotations
from typing import Callable, List, Tuple

def iterate(f: Callable[[float], float], n: int) -> Callable[[float], float]:
    """f^[n]; f^[0] is the identity (Section 5)."""
    def g(x: float) -> float:
        for _ in range(n):
            x = f(x)
        return x
    return g

def iterate_constants(K: float, K_anti: float, n: int) -> Tuple[float, float]:
    """
    Lipschitz and antilipschitz constants of f^[n] (Lemmas 5.1, 5.2):
    (K^n, K_anti^n).  Both finite => f^[n] stays bi-Lipschitz => dimension fixed.
    """
    return K ** n, K_anti ** n

def holder_corridor(dim_s: float, r: float, n: int) -> float:
    """Theorem 5.6 upper wall: dimH(f^[n](s)) <= dimH(s)/r^n."""
    return dim_s / (r ** n)
