from itertools import combinations
from typing import List, Sequence, Tuple

Square = List[List[int]]

def are_orthogonal(a: Square, b: Square, n: int) -> bool:
    seen: set[Tuple[int, int]] = set()
    for i in range(n):
        for j in range(n):
            pair = (a[i][j], b[i][j])
            if pair in seen:
                return False
            seen.add(pair)
    return len(seen) == n * n

def is_mutually_orthogonal(family: Sequence[Square], n: int) -> bool:
    return all(
        are_orthogonal(family[s], family[t], n)
        for s, t in combinations(range(len(family)), 2)
    )
