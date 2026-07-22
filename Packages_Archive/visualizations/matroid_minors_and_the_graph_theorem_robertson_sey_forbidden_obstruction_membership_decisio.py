from typing import Sequence, Tuple

Vec = Tuple[int, ...]

def leq(a: Vec, b: Vec) -> bool:
    return len(a) == len(b) and all(ai <= bi for ai, bi in zip(a, b))

def in_S(x: Vec, forbidden: Sequence[Vec]) -> bool:
    """True iff no forbidden obstruction lies below x (membership in S)."""
    return not any(leq(b, x) for b in forbidden)
