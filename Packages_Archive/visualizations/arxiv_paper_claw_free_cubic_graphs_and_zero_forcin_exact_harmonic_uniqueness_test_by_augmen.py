from fractions import Fraction
from typing import List, Set

def constrained_nullity(matrix: List[List[Fraction]], sampled: Set[int]) -> int:
    a = [row[:] for row in matrix]
    n = len(matrix[0]) if matrix else 0
    for v in sampled:
        row = [Fraction(0)] * n; row[v] = Fraction(1); a.append(row)
    rank = 0
    for col in range(n):
        pivot = next((r for r in range(rank, len(a)) if a[r][col]), None)
        if pivot is None: continue
        a[rank], a[pivot] = a[pivot], a[rank]
        q = a[rank][col]; a[rank] = [x/q for x in a[rank]]
        for r in range(len(a)):
            if r != rank and a[r][col]:
                q = a[r][col]; a[r] = [x-q*y for x,y in zip(a[r],a[rank])]
        rank += 1
    return n-rank
