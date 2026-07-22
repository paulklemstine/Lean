from itertools import combinations
from typing import List, Sequence, Tuple

Square = List[List[int]]

def oa_of_mols(family: Sequence[Square], n: int) -> List[List[int]]:
    runs: List[List[int]] = []
    for i in range(n):
        for j in range(n):
            runs.append([i, j] + [sq[i][j] for sq in family])
    return runs

def is_orthogonal_array(runs: Sequence[Sequence[int]], n: int) -> bool:
    m = len(runs[0])
    for c, d in combinations(range(m), 2):
        seen: set[Tuple[int, int]] = set()
        for run in runs:
            pair = (run[c], run[d])
            if pair in seen:
                return False
            seen.add(pair)
        if len(seen) != n * n:
            return False
    return True
