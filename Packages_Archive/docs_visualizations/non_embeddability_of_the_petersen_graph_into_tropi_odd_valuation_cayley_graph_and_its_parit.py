from itertools import combinations, product
from typing import Callable, Dict, List, Tuple

LatticePoint = Tuple[int, ...]
Graph = Dict[LatticePoint, List[LatticePoint]]


def coordinate_sum_valuation(point: LatticePoint) -> int:
    """Tropical valuation v(x_1,...,x_k) = sum of coordinates."""
    return sum(point)


def build_odd_valuation_cayley(
    dim: int,
    radius: int,
    valuation: Callable[[LatticePoint], int] = coordinate_sum_valuation,
) -> Graph:
    """Finite window of the Cayley graph of Z^dim with connection set
    {a : valuation(a) is odd}. Two points are adjacent iff the valuation of
    their difference is odd. Complexity O(N^2) in the number of window points."""
    pts: List[LatticePoint] = list(product(range(-radius, radius + 1), repeat=dim))
    graph: Graph = {p: [] for p in pts}
    for p, q in combinations(pts, 2):
        diff = tuple(pi - qi for pi, qi in zip(p, q))
        if valuation(diff) % 2 == 1:
            graph[p].append(q)
            graph[q].append(p)
    return graph


def parity_certificate(
    graph: Graph,
    valuation: Callable[[LatticePoint], int],
) -> Dict[LatticePoint, int]:
    """The bipartiteness certificate g -> v(g) mod 2 for an odd-valuation
    Cayley graph. Guaranteed proper because adjacency means the difference has
    odd valuation, flipping parity. Complexity O(V)."""
    return {p: valuation(p) % 2 for p in graph}
