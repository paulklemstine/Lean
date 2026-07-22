from typing import Dict

VSpace = Dict[int, int]  # dimension -> virtual cell count (finite support)


def euler_characteristic(space: VSpace) -> int:
    """Evaluate chi(sum b_d t^d) = sum (-1)^d b_d by substituting t = -1.

    Uses the parity of each integer dimension d (including negative d),
    since (-1)^d = (-1)^(d mod 2) and (-1)^{-n} = (-1)^n.
    Runs in O(m) integer operations for m nonzero strata.
    """
    total: int = 0
    for d, b_d in space.items():
        sign: int = 1 if d % 2 == 0 else -1
        total += sign * b_d
    return total
