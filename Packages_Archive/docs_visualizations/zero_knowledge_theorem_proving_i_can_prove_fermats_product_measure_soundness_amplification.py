from fractions import Fraction


def survival(n: int, e: int, k: int) -> Fraction:
    """Exact k-round survival probability (e/n)^k."""
    return Fraction(e, n) ** k


def rounds_for_error(n: int, e: int, target: Fraction) -> int:
    """Smallest k with (e/n)^k <= target (requires e < n)."""
    assert e < n, "per-round acceptance must be < 1 to amplify"
    prob = Fraction(1)
    k = 0
    while prob > target:
        prob *= Fraction(e, n)
        k += 1
    return k
