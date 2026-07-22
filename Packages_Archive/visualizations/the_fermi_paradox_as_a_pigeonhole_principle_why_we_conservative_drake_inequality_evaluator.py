from fractions import Fraction
from math import prod
from typing import Sequence, Tuple


def drake_bound(
    n_worlds: Fraction,
    hurdles: Sequence[Fraction],
    cap: Fraction = Fraction(1, 10),
    n_max: Fraction = Fraction(10) ** 10,
    min_hurdles: int = 11,
) -> Tuple[Fraction, bool]:
    """
    Evaluate the Drake expectation E = N * prod(hurdles) and certify E < 1.

    The certificate holds (Theorem 4.3) when every hurdle <= cap, the world
    count <= n_max, and there are at least min_hurdles independent hurdles.
    """
    exp = n_worlds * prod(hurdles, start=Fraction(1))
    certified = (
        all(p <= cap for p in hurdles)
        and len(hurdles) >= min_hurdles
        and n_worlds <= n_max
    )
    return exp, certified
