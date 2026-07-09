from fractions import Fraction
from typing import Dict, List, Sequence, Tuple

Edge = Tuple[int, int]
Coloring = Dict[int, int]


def is_proper_coloring(edges: Sequence[Edge], coloring: Coloring) -> bool:
    """True iff every edge has endpoints of distinct colours (proper colouring)."""
    return all(coloring[u] != coloring[v] for (u, v) in edges)


def failing_edges(edges: Sequence[Edge], coloring: Coloring) -> List[Edge]:
    """Edges whose endpoints share a colour: the witnesses of improperness."""
    return [(u, v) for (u, v) in edges if coloring[u] == coloring[v]]


def gmw_kround_soundness_bound(num_edges: int, k: int) -> Fraction:
    """Three-Colouring Amplified Soundness bound ((|E|-1)/|E|)^k.

    A cheating prover committing to an improper colouring each round survives all
    k random-edge challenges with probability at most this value.
    """
    if num_edges <= 0:
        raise ValueError("edge set must be nonempty")
    return Fraction(num_edges - 1, num_edges) ** k
