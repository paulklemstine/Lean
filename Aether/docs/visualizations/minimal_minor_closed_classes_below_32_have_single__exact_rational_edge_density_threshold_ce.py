"""Exact Rational Edge-Density Threshold Certification.

Mirrors the Lean class-level statements `acyclicClass_below_threshold` and
`boundedDegreeTwoClass_below_threshold`: density rho(G) = |E|/|V| < 3/2.
"""
from __future__ import annotations

from fractions import Fraction
from typing import FrozenSet, Sequence, Tuple

Edge = FrozenSet[int]
THRESHOLD = Fraction(3, 2)


def edge_density(vertex_count: int, edges: Sequence[Edge]) -> Fraction:
    """rho(G) = |E| / |V|, with the convention rho = 0 on the empty graph."""
    if vertex_count == 0:
        return Fraction(0)
    return Fraction(len(edges), vertex_count)


def density_below_threshold(
    vertex_count: int, edges: Sequence[Edge]
) -> Tuple[Fraction, bool]:
    """Return (rho, rho < 3/2). Runs in O(|V| + |E|)."""
    rho = edge_density(vertex_count, edges)
    return rho, rho < THRESHOLD


if __name__ == "__main__":
    # C_7: cycle, density exactly 1, below 3/2.
    c7 = [frozenset((i, (i + 1) % 7)) for i in range(7)]
    print(density_below_threshold(7, c7))  # (Fraction(1, 1), True)
