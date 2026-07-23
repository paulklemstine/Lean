from fractions import Fraction

def card_library(b: int, L: int) -> int:
    """Exact volume count |Library(b,L)| = b**L via fast exponentiation."""
    return b ** L

def singleton_probability(b: int, L: int) -> Fraction:
    """Uniform probability of one prescribed volume: b**(-L)."""
    return Fraction(1, b ** L)
