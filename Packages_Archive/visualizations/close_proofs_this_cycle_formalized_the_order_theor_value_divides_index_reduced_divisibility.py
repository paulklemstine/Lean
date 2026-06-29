from __future__ import annotations


def value_divides(a: int, b: int) -> bool:
    """Decide u(a) | u(b) for a growing strong divisibility sequence in O(1).

    Correct by the value biconditional u(a) | u(b) <=> a | b.
    """
    if a <= 0:
        raise ValueError("a must be a positive index")
    return b % a == 0
