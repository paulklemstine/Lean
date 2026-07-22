from __future__ import annotations
from fractions import Fraction
from typing import List, Union

Number = Union[int, Fraction]

def extended_eulerian_triangle(N: int, s: Number) -> List[List[Number]]:
    """Tabulate A(n,k,s) for 0 <= k <= n <= N in O(N^2) exact rational ops.

    Uses the recurrence A(m,j,s) = (j+1-s)*A(m-1,j,s) + (m-j+s)*A(m-1,j-1,s)
    with A(0,0,s)=1 and out-of-range entries equal to 0.
    """
    s = Fraction(s)
    triangle: List[List[Number]] = [[Fraction(1)]]
    for m in range(1, N + 1):
        prev = triangle[-1]
        row: List[Number] = [Fraction(0)] * (m + 1)
        for j in range(m + 1):
            left = prev[j] if 0 <= j <= m - 1 else Fraction(0)
            down = prev[j - 1] if 0 <= j - 1 <= m - 1 else Fraction(0)
            row[j] = (Fraction(j + 1) - s) * left + (Fraction(m - j) + s) * down
        triangle.append(row)
    return triangle
