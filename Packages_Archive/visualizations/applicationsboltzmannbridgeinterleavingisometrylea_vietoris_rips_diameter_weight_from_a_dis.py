from typing import Callable, FrozenSet, TypeVar

V = TypeVar("V")
Weight = Callable[[FrozenSet], float]


def diam_weight(d: Callable[[V, V], float]) -> Weight:
    """Vietoris-Rips diameter weight from a bare distance matrix d:
        diamWeightOf(sigma) = max(0, max_{x,y in sigma} d(x, y)).
    No metric axioms required; nonnegative, grounded, monotone."""
    def w(sigma: FrozenSet) -> float:
        verts = list(sigma)
        return max([0.0, *(d(x, y) for x in verts for y in verts)])
    return w
