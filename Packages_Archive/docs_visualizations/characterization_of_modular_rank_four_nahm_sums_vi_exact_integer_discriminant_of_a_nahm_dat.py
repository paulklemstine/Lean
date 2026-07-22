from typing import List

Matrix = List[List[int]]

def det(M: Matrix) -> int:
    """Exact determinant of a square integer matrix by Laplace expansion."""
    n = len(M)
    if n == 1:
        return M[0][0]
    if n == 2:
        return M[0][0] * M[1][1] - M[0][1] * M[1][0]
    total = 0
    for j in range(n):
        minor = [row[:j] + row[j + 1:] for row in M[1:]]
        total += ((-1) ** j) * M[0][j] * det(minor)
    return total

def disc(H: Matrix) -> int:
    """Discriminant of a rank-four Nahm datum: disc(H) = det H."""
    return det(H)
