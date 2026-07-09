from fractions import Fraction

def meaning_density_bound(A: int, L: int, m: int) -> Fraction:
    """Return the exact union bound (L - m + 1) * A^{-m} that upper-bounds the
    fraction of length-L volumes over an A-symbol alphabet containing a fixed
    passage of length m. The polynomial prefactor is the placement count."""
    if not (1 <= m <= L):
        raise ValueError("require 1 <= m <= L")
    return Fraction(L - m + 1, A ** m)
