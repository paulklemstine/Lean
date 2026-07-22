from typing import Callable, List, Optional, TypeVar

T = TypeVar("T")

def lawvere_fixed_point(
    encoding: List[List[T]], g: Callable[[T], T]
) -> Optional[T]:
    """Given a square 'encoding' whose row a is the predicate f(a) : A -> B, and
    an endomap g : B -> B, search for a code c with row c equal to the diagonal
    map d(a) = g(f(a)(a)). If found, f(c)(c) is a fixed point of g (Lawvere).
    Returns the fixed point, or None if the encoding is not point-surjective for
    this diagonal (as must happen when g has no fixed point, e.g. negation)."""
    n = len(encoding)
    diagonal = [g(encoding[a][a]) for a in range(n)]
    for c in range(n):
        if encoding[c] == diagonal:
            return encoding[c][c]  # equals g(encoding[c][c]): a fixed point
    return None
