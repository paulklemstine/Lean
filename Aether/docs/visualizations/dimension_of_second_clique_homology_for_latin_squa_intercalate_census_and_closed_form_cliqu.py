from math import comb
from typing import Callable, Tuple

Square = Callable[[int, int], int]


def intercalate_count(M: Square, n: int) -> int:
    total = 0
    for i in range(n):
        for ip in range(i + 1, n):
            for j in range(n):
                for jp in range(j + 1, n):
                    if M(i, j) == M(ip, jp) and M(i, jp) == M(ip, j):
                        total += 1
    return total


def clique_counts(M: Square, n: int) -> Tuple[int, int, int]:
    I = intercalate_count(M, n)
    triangles = 3 * n * comb(n, 3) + n * n * (n - 1)
    tetrahedra = 3 * n * comb(n, 4) + I
    return triangles, tetrahedra, I
