from __future__ import annotations
from fractions import Fraction
from typing import Callable, Dict, Tuple

Poly = Dict[Tuple[int, int], Fraction]


def e_polynomial(n: int, h: Callable[[int, int], int]) -> Poly:
    """Build E(X; u, v) = sum_{p,q<=n} (-1)^{p+q} h^{p,q} u^p v^q as {(p,q): coeff}."""
    out: Poly = {}
    for p in range(n + 1):
        for q in range(n + 1):
            c = Fraction((-1) ** (p + q) * h(p, q))
            if c != 0:
                out[(p, q)] = c
    return out


def mirror_functional_equation_rhs(n: int, h: Callable[[int, int], int]) -> Poly:
    """Compute (-1)^n u^n E(X; 1/u, v) as a Laurent polynomial in {(i,j): coeff}."""
    e = e_polynomial(n, h)
    sign = Fraction((-1) ** n)
    rhs: Poly = {}
    for (p, q), c in e.items():
        # u -> 1/u negates p-exponent; then multiply by (-1)^n u^n
        key = (n - p, q)
        rhs[key] = rhs.get(key, Fraction(0)) + sign * c
    return {k: v for k, v in rhs.items() if v != 0}


def verify_mirror_equation(n: int, h: Callable[[int, int], int]) -> bool:
    """Return True iff E(mirror X) equals (-1)^n u^n E(X; 1/u, v) coefficient-wise."""
    lhs = e_polynomial(n, lambda p, q: h(n - p, q))
    lhs = {k: v for k, v in lhs.items() if v != 0}
    return lhs == mirror_functional_equation_rhs(n, h)
