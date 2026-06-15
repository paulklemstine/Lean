from typing import Callable, Hashable, List, Optional, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def is_proposition(elements: Sequence[B]) -> bool:
    """An h-proposition has at most one element (any two points are connected)."""
    return len(set(elements)) <= 1


def ptrunc_rec(
    elements: Sequence[A],
    f: Callable[[A], B],
    target_prop: Sequence[B],
) -> Optional[B]:
    """Recursion principle for propositional truncation ||A||.

    A map f : A -> P into a proposition P factors uniquely through ||A||.
    Returns the unique value (None for the empty truncation). The uniqueness
    half (PTrunc.rec_unique) is reflected by the assertion that the image
    collapses to a single point.
    """
    assert is_proposition(target_prop), "target must be a proposition"
    if not elements:
        return None
    values = {f(a) for a in elements}
    assert len(values) == 1, "image must collapse to one point (rec_unique)"
    return next(iter(values))
