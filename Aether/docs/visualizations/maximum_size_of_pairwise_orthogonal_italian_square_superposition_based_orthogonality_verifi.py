from typing import List, Set, Tuple

def are_orthogonal(L: List[List[int]], M: List[List[int]]) -> bool:
    """Return True iff the superposition of L and M lists all n^2 ordered pairs once."""
    n: int = len(L)
    seen: Set[Tuple[int, int]] = set()
    for i in range(n):
        for j in range(n):
            p = (L[i][j], M[i][j])
            if p in seen:
                return False
            seen.add(p)
    return len(seen) == n * n
