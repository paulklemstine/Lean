from typing import Literal

def legendre(a: int, p: int) -> Literal[-1, 0, 1]:
    """Legendre symbol (a | p) via Euler's criterion a^((p-1)/2) mod p.

    Returns 0 if p | a, +1 if a is a nonzero quadratic residue mod p,
    and -1 if a is a quadratic non-residue mod p.  Cost: O(log p).
    """
    a %= p
    if a == 0:
        return 0
    r = pow(a, (p - 1) // 2, p)
    return 1 if r == 1 else -1
