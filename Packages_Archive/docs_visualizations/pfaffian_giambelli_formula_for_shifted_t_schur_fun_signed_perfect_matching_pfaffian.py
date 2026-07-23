from __future__ import annotations
from typing import List

Matrix = List[List[float]]

def pfaffian_matching(a: Matrix) -> float:
    """Pfaffian of a (2k)x(2k) skew-symmetric matrix via the signed
    perfect-matching sum. Recursion: fix the smallest free index, pair it
    with each remaining index (sign alternates), and recurse on the rest."""
    n = len(a)
    assert n % 2 == 0, "Pfaffian requires an even dimension"

    def rec(rem: List[int]) -> float:
        if not rem:
            return 1.0
        i = rem[0]
        total = 0.0
        for pos in range(1, len(rem)):
            j = rem[pos]
            sign = -1.0 if (pos - 1) % 2 else 1.0
            sub = rem[1:pos] + rem[pos + 1:]
            total += sign * a[i][j] * rec(sub)
        return total

    return rec(list(range(n)))
