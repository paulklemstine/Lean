from fractions import Fraction
from typing import Sequence, Tuple


def first_moment_certify(
    weights: Sequence[Fraction], values: Sequence[int]
) -> Tuple[bool, Fraction, Fraction]:
    """
    Certify cosmic emptiness via the first moment method.

    Returns (guaranteed_empty, expectation, emptiness_lower_bound) where
      expectation            = sum_i w_i * X_i
      emptiness_lower_bound  = max(0, 1 - expectation)   (Theorem 3.2)
      guaranteed_empty       = (expectation < 1)          (Theorem 3.1)
    """
    assert sum(weights) == 1, "weights must sum to 1"
    assert all(w >= 0 for w in weights), "weights non-negative"
    assert all(v >= 0 for v in values), "values non-negative integers"
    exp = sum((w * v for w, v in zip(weights, values)), Fraction(0))
    lower = max(Fraction(0), Fraction(1) - exp)
    return (exp < 1, exp, lower)
