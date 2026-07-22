from typing import Callable

def brouwer_bisect(f: Callable[[float], float], lo: float = 0.0,
                   hi: float = 1.0, tol: float = 1e-12,
                   max_iter: int = 200) -> float:
    """Bracket-and-bisect locator for the 1D Brouwer fixed point.

    Given continuous f mapping [lo,hi] into itself, g(x)=f(x)-x satisfies
    g(lo) >= 0 >= g(hi).  Corollary `sperner_exists_change` guarantees a sign
    change (discrete IVT); bisection refines it to the fixed point of
    theorem `brouwer_one_dim`."""
    g = lambda x: f(x) - x
    a, b = lo, hi
    ga = g(a)
    for _ in range(max_iter):
        m = 0.5 * (a + b)
        gm = g(m)
        if abs(gm) < tol or (b - a) < tol:
            return m
        if (ga <= 0.0) != (gm <= 0.0):
            b = m
        else:
            a, ga = m, gm
    return 0.5 * (a + b)
