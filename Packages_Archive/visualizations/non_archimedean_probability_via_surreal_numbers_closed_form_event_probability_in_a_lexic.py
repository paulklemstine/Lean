from fractions import Fraction
from typing import Iterable, Optional, Tuple

LexRat = Tuple[Fraction, Fraction]  # (std, inf) read as std + inf*eps

def atom_weight(n: int, x: Optional[int]) -> LexRat:
    """Reservoir (None) -> (1, -n); visible atom i -> (0, 1) = eps."""
    if x is None:
        return (Fraction(1), Fraction(-n))
    return (Fraction(0), Fraction(1))

def prob_closed(n: int, event: Iterable[Optional[int]]) -> LexRat:
    """Closed-form probability (prob_eq_closed_form).

    std = [reservoir in event]; inf = (#visible) - [reservoir]*n.
    Complexity O(|event|).
    """
    ev = set(event)
    has_res: bool = None in ev
    visible: int = sum(1 for x in ev if x is not None)
    std = Fraction(1) if has_res else Fraction(0)
    inf = Fraction(visible) - (Fraction(n) if has_res else Fraction(0))
    return (std, inf)

def lex_lt(a: LexRat, b: LexRat) -> bool:
    """Lexicographic strict order: std dominates, inf breaks ties."""
    if a[0] != b[0]:
        return a[0] < b[0]
    return a[1] < b[1]
