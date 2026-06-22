from typing import Callable, FrozenSet, TypeVar

A = TypeVar("A")
B = TypeVar("B")
Weight = Callable[[FrozenSet], float]


def pullback(f: Callable[[A], B], wg: Weight) -> Weight:
    """Pullback of a filtration along a vertex map f : A -> B.
        (pullback f F).weight(sigma) = w_F(f(sigma)),  f(sigma) = image set.
    Monotone because images respect inclusion; 1-Lipschitz for the interleaving
    distance, and an isometry exactly when f is surjective."""
    return lambda sigma: wg(frozenset(f(v) for v in sigma))
