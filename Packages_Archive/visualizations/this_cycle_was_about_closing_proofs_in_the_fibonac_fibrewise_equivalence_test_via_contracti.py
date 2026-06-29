from typing import Callable, Hashable, List, Sequence, TypeVar

A = TypeVar("A", bound=Hashable)
B = TypeVar("B", bound=Hashable)


def homotopy_fiber(f: Callable[[A], B], domain: Sequence[A], b: B) -> List[A]:
    """HFiber f b = { a in domain : f(a) == b }.  O(|domain|)."""
    return [a for a in domain if f(a) == b]


def is_equivalence(
    f: Callable[[A], B], domain: Sequence[A], codomain: Sequence[B]
) -> bool:
    """Decide whether f is a bijection by the fibrewise criterion of Theorem 5.1:
    f is an equivalence iff every homotopy fiber HFiber f b is contractible
    (i.e. a singleton).  Total cost O(|codomain| * |domain|).
    """
    for b in codomain:
        fib = homotopy_fiber(f, domain, b)
        if len(set(fib)) != 1:   # fiber must be contractible (exactly one point)
            return False
    return True
