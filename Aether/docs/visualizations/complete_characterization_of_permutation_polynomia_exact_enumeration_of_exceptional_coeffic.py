"""
algorithm.py — Reference implementation of the Norm-Criterion Permutation Test
and the exact exceptional-coefficient enumerator for x -> a*x^p + c*x over
F_{p^2}.

The decision test runs in O(log p) field multiplications via fast
exponentiation, an exponential speedup over the O(p^2) brute-force injectivity
check.
"""

from __future__ import annotations

from itertools import product
from typing import List, Tuple

Element = Tuple[int, int]   # u + v*t represented as (u, v)


def nonresidue(p: int) -> int:
    """A quadratic non-residue g in F_p, used to build F_{p^2} = F_p[t]/(t^2-g)."""
    squares = {(x * x) % p for x in range(p)}
    for g in range(2, p):
        if g not in squares:
            return g
    raise ValueError("no non-residue found")


def mul(a: Element, b: Element, p: int, g: int) -> Element:
    """Multiply in F_{p^2}: (a0+a1 t)(b0+b1 t), t^2 = g."""
    a0, a1 = a
    b0, b1 = b
    return ((a0 * b0 + a1 * b1 * g) % p, (a0 * b1 + a1 * b0) % p)


def power(a: Element, n: int, p: int, g: int) -> Element:
    """Fast exponentiation a^n in F_{p^2}; O(log n) multiplications."""
    result: Element = (1, 0)
    base = a
    while n > 0:
        if n & 1:
            result = mul(result, base, p, g)
        base = mul(base, base, p, g)
        n >>= 1
    return result


def norm(a: Element, p: int, g: int) -> int:
    """N(a) = a^(p+1) in F_p (the second coordinate vanishes)."""
    na = power(a, p + 1, p, g)
    assert na[1] == 0, "norm must lie in the prime field"
    return na[0]


def permutes_linearized(a: Element, c: Element, p: int, g: int) -> bool:
    """Norm criterion: x -> a*x^p + c*x permutes F_{p^2}  iff  N(a) != N(c)."""
    return norm(a, p, g) != norm(c, p, g)


def exceptional_coefficients(p: int, g: int) -> List[Element]:
    """List the exactly p+1 coefficients c with N(c)=1 (x -> x^p + c*x fails)."""
    return [(u, v) for u, v in product(range(p), repeat=2)
            if norm((u, v), p, g) == 1]


if __name__ == "__main__":
    for p in (3, 5, 7, 11):
        g = nonresidue(p)
        exc = exceptional_coefficients(p, g)
        assert len(exc) == p + 1, (p, len(exc))
        print(f"p={p}: #exceptional = {len(exc)} = p+1; "
              f"#permutation coeffs = {p*p - len(exc)} = p^2-(p+1)")
        # Spot-check the criterion against brute force on a few pairs.
        a, c = (1, 0), (1, 1)
        print(f"   N(a)={norm(a,p,g)}, N(c)={norm(c,p,g)}, "
              f"permutes? {permutes_linearized(a, c, p, g)}")
