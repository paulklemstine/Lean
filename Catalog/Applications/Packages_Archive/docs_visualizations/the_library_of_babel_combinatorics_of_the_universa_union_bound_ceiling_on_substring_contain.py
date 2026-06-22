from fractions import Fraction

def prob_contains_bound(b: int, L: int, k: int) -> Fraction:
    """Union-bound ceiling min(1, (L - k + 1) * b**(-k)) on containment probability."""
    if k > L:
        raise ValueError("pattern longer than volume")
    raw = Fraction(L - k + 1) * Fraction(1, b ** k)
    return min(Fraction(1), raw)