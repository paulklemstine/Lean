from __future__ import annotations
from fractions import Fraction
from itertools import product

Graph = tuple[int, list[tuple[int, int]]]


def proper_count(graph: Graph, k: int) -> int:
    """Number of proper k-colorings by direct enumeration."""
    n, edges = graph
    if k <= 0:
        return 0 if n > 0 else 1
    return sum(
        1 for c in product(range(k), repeat=n)
        if all(c[a] != c[b] for a, b in edges)
    )


def chromatic_coefficients(graph: Graph) -> list[Fraction]:
    """Monomial coefficients [a_0,...,a_n] of P(G,k) via Lagrange interpolation
    through (j, P(G,j)) for j = 0..n, exact in rationals (degree is exactly n)."""
    n, _ = graph
    xs = list(range(n + 1))
    ys = [Fraction(proper_count(graph, j)) for j in xs]
    coeffs = [Fraction(0)] * (n + 1)
    for i in range(n + 1):
        num: list[Fraction] = [Fraction(1)]
        den = Fraction(1)
        for j in range(n + 1):
            if j == i:
                continue
            new = [Fraction(0)] * (len(num) + 1)
            for d, c in enumerate(num):
                new[d] += -xs[j] * c
                new[d + 1] += c
            num = new
            den *= (xs[i] - xs[j])
        scale = ys[i] / den
        for d, c in enumerate(num):
            coeffs[d] += c * scale
    return coeffs
