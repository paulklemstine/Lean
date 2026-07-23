from itertools import combinations
from typing import Callable, List, Tuple

Cell = Tuple[int, int]
Square = Callable[[int, int], int]


def adjacent(M: Square, p: Cell, q: Cell) -> bool:
    (i, j), (k, l) = p, q
    return i == k or j == l or M(i, j) == M(k, l)


def count_cliques(M: Square, n: int, k: int) -> int:
    cells: List[Cell] = [(i, j) for i in range(n) for j in range(n)]
    total = 0
    for S in combinations(cells, k):
        if all(adjacent(M, S[a], S[b])
               for a in range(len(S)) for b in range(a + 1, len(S))):
            total += 1
    return total
