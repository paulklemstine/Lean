from __future__ import annotations
import math
from itertools import combinations
from typing import FrozenSet, List

Set = FrozenSet[int]


def coordinate_factor(a: int, b: int, c: int) -> int:
    """(1 - (ab + bc + ca)) mod 3 for one coordinate."""
    return (1 - (a * b + b * c + c * a)) % 3


def tensor_T0(a: Set, b: Set, c: Set, n: int) -> int:
    """Naslund-Sawin core tensor over F_3: product of per-coordinate factors."""
    value = 1
    for i in range(n):
        value = (value * coordinate_factor(int(i in a), int(i in b), int(i in c))) % 3
    return value


def monomial_count(n: int) -> int:
    """M(n) = sum_{k<=n/3} C(n,k): squarefree monomials of degree at most n/3."""
    return sum(math.comb(n, k) for k in range(0, n // 3 + 1))


def sunflower_free_upper_bound(n: int, uniform: bool = False) -> int:
    """
    Upper bound on a 3-sunflower-free family over [n].
    Uniform families: 3*M(n).  General families: (n+1)*3*M(n).
    """
    base = 3 * monomial_count(n)
    return base if uniform else (n + 1) * base


def slice_rank_of_diagonal(support_size: int) -> int:
    """Slice Rank Lemma: a diagonal tensor has slice rank equal to its support."""
    return support_size


def certify_uniform_family(family: List[Set], n: int) -> bool:
    """
    Certify that a uniform family diagonalizes T (1 on diagonal, 0 off) and that
    its size respects the slice-rank upper bound 3*M(n).
    """
    for a in family:
        for b in family:
            for c in family:
                v = tensor_T0(a, b, c, n)
                if a == b == c:
                    if v != 1:
                        return False
                elif v != 0:
                    return False
    return len(family) <= sunflower_free_upper_bound(n, uniform=True)
