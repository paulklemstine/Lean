"""Reference algorithms for computing HH_0(R[G]) = R[Conj(G)]."""

from __future__ import annotations

from fractions import Fraction
from typing import Sequence


def conjugacy_classes(
    order: int, mul: Sequence[Sequence[int]], inv: Sequence[int]
) -> list[frozenset[int]]:
    """Partition a finite group into conjugacy classes by orbit enumeration.

    Args:
        order: |G|, elements are 0..order-1.
        mul:   Cayley table, mul[a][b] = a*b.
        inv:   inv[a] = a^{-1}.

    Returns:
        The list of conjugacy classes; its length is dim_R HH_0(R[G]).
    """
    seen: set[int] = set()
    classes: list[frozenset[int]] = []
    for u in range(order):
        if u in seen:
            continue
        orbit = frozenset(mul[mul[c][u]][inv[c]] for c in range(order))
        classes.append(orbit)
        seen |= orbit
    return classes


def to_conj_coordinates(
    coeffs: dict[int, Fraction], classes: list[frozenset[int]]
) -> list[Fraction]:
    """Image of an element of R[G] in HH_0(R[G]) = R[Conj(G)].

    The coordinate of each conjugacy class is the sum of the coefficients of its
    members; this realizes the universal trace toConj.
    """
    return [
        sum((coeffs.get(g, Fraction(0)) for g in cls), Fraction(0))
        for cls in classes
    ]
