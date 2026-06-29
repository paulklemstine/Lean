from fractions import Fraction
from typing import FrozenSet, Set, Tuple

Edge = FrozenSet[int]
Hypergraph = Set[Edge]
Pool = FrozenSet[int]


def degree(E: Hypergraph, v: int) -> int:
    return sum(1 for e in E if v in e)


def average_degree_bound(E: Hypergraph, S: Pool) -> Tuple[Fraction, Fraction]:
    """Return (delta, (1-delta)*|S|): certified independent-set bound."""
    if not S:
        return Fraction(0), Fraction(0)
    delta = Fraction(sum(degree(E, v) for v in S), len(S))
    return delta, (1 - delta) * len(S)
