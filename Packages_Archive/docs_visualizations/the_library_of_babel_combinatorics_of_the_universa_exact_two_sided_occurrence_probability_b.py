from fractions import Fraction

def occurrence_probability_bound(b: int, length: int, k: int) -> dict:
    """Exact two-sided band for P(a random volume of length L over b symbols
    contains a fixed length-k pattern).

    Returns the single-position lower bound b**(-k) and the union upper bound
    (L-k+1)*b**(-k), both as exact Fractions (Library-of-Babel theorems
    card_occursAt and prob_contains_substring_bound).
    """
    assert 0 <= k <= length and b > 0
    lower: Fraction = Fraction(1, b ** k)
    upper: Fraction = Fraction(length - k + 1, 1) * Fraction(1, b ** k)
    expectation: Fraction = upper  # equals E[#occurrences] (expected_substring_count)
    return {"lower": lower, "expected_occurrences": expectation, "upper": upper}
