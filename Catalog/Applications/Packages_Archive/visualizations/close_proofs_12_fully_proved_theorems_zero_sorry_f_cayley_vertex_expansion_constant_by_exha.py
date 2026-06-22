from itertools import combinations
from typing import List, Sequence, Set, Tuple
Perm = Tuple[int, ...]

def compose(a: Perm, b: Perm) -> Perm:
    return tuple(a[b[i]] for i in range(len(a)))

def cayley_boundary(S: Sequence[Perm], A: Set[Perm]) -> Set[Perm]:
    neigh = {compose(a, s) for a in A for s in S}
    return neigh - A

def vertex_expansion_constant(group: List[Perm], S: Sequence[Perm]) -> float:
    G = list(group); N = len(G); best = float('inf')
    for size in range(1, N // 2 + 1):
        for combo in combinations(G, size):
            A = set(combo)
            best = min(best, len(cayley_boundary(S, A)) / size)
    return best
