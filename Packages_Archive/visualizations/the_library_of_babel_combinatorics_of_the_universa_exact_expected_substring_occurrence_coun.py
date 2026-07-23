from fractions import Fraction

def expected_substring_count(b: int, L: int, k: int) -> Fraction:
    """Exact E[occurrences] = (L - k + 1) * b**(-k); requires k <= L and b >= 1."""
    if k > L:
        raise ValueError("pattern longer than volume")
    if b < 1:
        raise ValueError("expectation undefined for empty alphabet")
    return Fraction(L - k + 1) * Fraction(1, b ** k)