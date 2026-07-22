from typing import List, Set

Matrix = List[List[int]]
TARGETS: Set[int] = {8, 12, 16}

def det(M: Matrix) -> int:
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

def is_candidate_modular(H: Matrix) -> bool:
    """Conjectural rank-four modularity oracle: disc(H) in {8, 12, 16}."""
    return det(H) in TARGETS
