from fractions import Fraction
from typing import Dict, Sequence, Tuple

Pair = Tuple[int, int]


def catch_probability(edges: Sequence[Pair],
                      colouring: Dict[int, int]) -> Fraction:
    """Exact probability a random edge catches the prover."""
    m = len(edges)
    assert m > 0
    caught = sum(1 for (u, v) in edges if colouring[u] == colouring[v])
    return Fraction(caught, m)
