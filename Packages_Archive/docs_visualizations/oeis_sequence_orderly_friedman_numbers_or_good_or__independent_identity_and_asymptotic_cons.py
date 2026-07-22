from __future__ import annotations
from fractions import Fraction

def audit(n: int) -> dict[str, bool]:
    """Check the closed form, suffix, bounds, and normalized error."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    f = int("127" * (n + 1))
    p = 1000 ** (n + 1)
    return {
        "closed_form": 999 * f == 127 * (p - 1),
        "suffix": f % 1000 == 127,
        "lower_bound": 126 * p < 999 * f,
        "upper_bound": 999 * f < 127 * p,
        "exact_error": Fraction(127, 999) - Fraction(f, p) == Fraction(127, 999 * p),
    }

if __name__ == "__main__":
    for i in range(6):
        print(i, audit(i))
