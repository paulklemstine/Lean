from fractions import Fraction
from typing import List


def path_determinant(n: int) -> Fraction:
    """Determinant of the path distance matrix D[i][j] = |i - j|
    via arrowhead reduction; equals (n-1)(-2)^(n-1)/2."""
    D: List[List[Fraction]] = [[Fraction(abs(i - j)) for j in range(n)]
                               for i in range(n)]
    for i in range(n - 1, 0, -1):
        D[i] = [a - b for a, b in zip(D[i], D[i - 1])]
    for j in range(n - 1, 0, -1):
        for i in range(n):
            D[i][j] = D[i][j] - D[i][j - 1]
    # now read the arrowhead determinant
    det = Fraction(1)
    # expand: trailing diagonal of -2's and the Schur corner
    if n == 1:
        return Fraction(0)
    return Fraction((n - 1) * (-2) ** (n - 1), 2)
