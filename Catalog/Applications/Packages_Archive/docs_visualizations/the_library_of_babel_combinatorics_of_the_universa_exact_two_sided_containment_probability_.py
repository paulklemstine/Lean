from __future__ import annotations
from fractions import Fraction
from typing import Tuple

def containment_sandwich(b: int, L: int, k: int) -> Tuple[Fraction, Fraction]:
    """Return (lower, upper) bounds on the probability that a uniformly random
    volume of length L over a b-symbol alphabet contains a fixed length-k pattern.

        lower = 1 - (1 - b^-k)^(L // k)      (disjoint-block independence)
        upper = (L - k + 1) * b^-k           (union bound)

    Both are exact rationals; cost is O(1) arithmetic ops with big-integer powers.
    """
    if not (k >= 1 and b >= 1 and k <= L):
        raise ValueError("require 1 <= k <= L and b >= 1")
    m = L // k
    lower = Fraction(1) - Fraction(b ** k - 1, b ** k) ** m
    upper = Fraction(L - k + 1, b ** k)
    return lower, upper

if __name__ == "__main__":
    lo, up = containment_sandwich(25, 1_312_000, 3)
    print(f"Borges (b=25, L=1,312,000, k=3): lower={float(lo):.12f} upper={float(up):.3e}")
    lo2, up2 = containment_sandwich(4, 10, 3)
    print(f"mini  (b=4,  L=10,        k=3): lower={float(lo2):.6f} upper={float(up2):.6f}")
