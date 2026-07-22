from typing import Literal

def quadratic_class(b: int, c: int, p: int) -> Literal["repeated", "reducible", "irreducible"]:
    """Classify x^2 + bx + c over F_p (p odd prime) via its discriminant.
    Uses the Euler criterion: a nonzero d is a square iff d^((p-1)/2) == 1."""
    disc = (b * b - 4 * c) % p
    if disc == 0:
        return "repeated"
    if pow(disc, (p - 1) // 2, p) == 1:
        return "reducible"      # discriminant is a nonzero square: two roots
    return "irreducible"        # discriminant is a non-square: no root
