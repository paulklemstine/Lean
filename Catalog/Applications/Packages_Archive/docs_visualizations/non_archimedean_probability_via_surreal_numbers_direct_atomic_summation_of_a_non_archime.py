from fractions import Fraction
from typing import Iterable, Optional, Tuple

LexRat = Tuple[Fraction, Fraction]

def prob_direct(n: int, event: Iterable[Optional[int]]) -> LexRat:
    """Probability as the finite sum of atom weights (definition `prob`).

    total = sum over distinct atoms x in event of atomWeight(n, x), added
    componentwise in Q x Q. Complexity O(|event|).
    """
    std, inf = Fraction(0), Fraction(0)
    for x in set(event):
        if x is None:
            std += Fraction(1)
            inf += Fraction(-n)
        else:
            inf += Fraction(1)
    return (std, inf)
