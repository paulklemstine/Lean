from typing import Callable, List, Optional, Tuple, TypeVar
A = TypeVar('A'); B = TypeVar('B')

def locate_collision(f: Callable[[A, B], A], a1: A, a2: A,
                     msg: List[B]) -> Optional[Tuple[A, A, B]]:
    """Return (s1, s2, b) with s1 != s2 and f(s1,b)=f(s2,b) (Theorem 5.1)."""
    s1, s2 = a1, a2
    for b in msg:
        if s1 != s2 and f(s1, b) == f(s2, b):
            return (s1, s2, b)
        s1, s2 = f(s1, b), f(s2, b)
    return None
