from functools import reduce
from typing import List


def scalar_foldr_min(c: float, d: float, xs: List[float]) -> float:
    """Normalize c (.) (x1 (+) ... (+) xk (+) d) in the min-plus semiring.

    Realizes theorem scalar_foldr_min: distributing the tropical scalar c over a
    whole tropical sum (a right fold of min with base d) equals distributing c
    over every monomial first. Returns the normalized value.
    """
    distributed = [c + x for x in xs]
    return reduce(lambda acc, x: min(x, acc), reversed(distributed), c + d)


def verify_scalar_fold(c: float, d: float, xs: List[float]) -> bool:
    """Check the law against the un-normalized left-hand side."""
    lhs = c + reduce(lambda acc, x: min(x, acc), reversed(xs), d)
    return lhs == scalar_foldr_min(c, d, xs)
