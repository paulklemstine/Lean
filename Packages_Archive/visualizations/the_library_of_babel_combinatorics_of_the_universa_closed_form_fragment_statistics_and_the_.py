from fractions import Fraction

def expected_occurrences(b: int, L: int, k: int) -> Fraction:
    """Expected count of a length-k pattern (Theorem 3); requires b>0, k<=L."""
    assert b > 0 and k <= L
    return Fraction(L - k + 1) * Fraction(1, b ** k)

def containment_upper_bound(b: int, L: int, k: int) -> Fraction:
    """Union-bound upper estimate on containment probability (Theorem 4)."""
    assert k <= L
    return Fraction(L - k + 1) * Fraction(1, b ** k)

def critical_length(b: int, k: int) -> int:
    """Smallest L for which E[occurrences] >= 1, namely L* ~ b**k."""
    return b ** k
