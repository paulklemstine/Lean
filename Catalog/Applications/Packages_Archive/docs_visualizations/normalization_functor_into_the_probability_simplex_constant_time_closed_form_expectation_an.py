from fractions import Fraction

def expected_occurrences_closed_form(b: int, L: int, k: int) -> Fraction:
    """Closed-form expected occurrence count (theorem expected_substring_count).

    Returns (L - k + 1) * b**(-k) exactly as a rational. Requires k <= L, b > 0.
    Complexity: O(1) arithmetic operations (plus big-integer exponentiation).
    """
    if not (0 < b and k <= L):
        raise ValueError("require 0 < b and k <= L")
    return Fraction(L - k + 1) * Fraction(1, b ** k)

def containment_union_bound(b: int, L: int, k: int) -> Fraction:
    """Union-bound upper bound on P[volume contains pattern]
    (theorem prob_contains_substring_bound): (L - k + 1) * b**(-k)."""
    return expected_occurrences_closed_form(b, L, k)
