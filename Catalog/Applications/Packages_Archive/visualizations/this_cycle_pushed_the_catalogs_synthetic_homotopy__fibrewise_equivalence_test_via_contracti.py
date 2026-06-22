from typing import Callable, Hashable, List, TypeVar

A = TypeVar('A', bound=Hashable)
B = TypeVar('B', bound=Hashable)

def hfiber(f: Callable[[A], B], source: List[A], b: B) -> List[A]:
    """HFiber f b = { a // f a = b }."""
    return [a for a in source if f(a) == b]

def is_equiv(f: Callable[[A], B], source: List[A],
             target: List[B]) -> bool:
    """f is an equivalence iff every homotopy fiber is a singleton."""
    return all(len(hfiber(f, source, b)) == 1 for b in target)
