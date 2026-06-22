from fractions import Fraction
from typing import List, Sequence, Tuple


def padic_valuation(x: Fraction, p: int) -> float:
    if x == 0:
        return float("inf")
    num, den, v = abs(x.numerator), x.denominator, 0
    while num % p == 0:
        num //= p; v += 1
    while den % p == 0:
        den //= p; v -= 1
    return v


def padic_dist(x: Fraction, y: Fraction, p: int) -> float:
    d = x - y
    if d == 0:
        return 0.0
    return float(p) ** (-padic_valuation(d, p))


def ultrametric_dendrogram(points: Sequence[Fraction],
                           p: int) -> List[Tuple[int, int, float]]:
    """Exact single-linkage dendrogram of an ultrametric point set.

    Returns a list of merges (i, j, height): cluster i and cluster j merge at
    ultrametric height `height`. Because balls are nested-or-disjoint, the
    merge order is canonical (independent of tie-breaking).
    """
    n = len(points)
    parent = list(range(n))

    def find(a: int) -> int:
        while parent[a] != a:
            parent[a] = parent[parent[a]]
            a = parent[a]
        return a

    edges: List[Tuple[float, int, int]] = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((padic_dist(points[i], points[j], p), i, j))
    edges.sort()

    merges: List[Tuple[int, int, float]] = []
    for h, i, j in edges:
        ri, rj = find(i), find(j)
        if ri != rj:
            parent[ri] = rj
            merges.append((ri, rj, h))
    return merges
