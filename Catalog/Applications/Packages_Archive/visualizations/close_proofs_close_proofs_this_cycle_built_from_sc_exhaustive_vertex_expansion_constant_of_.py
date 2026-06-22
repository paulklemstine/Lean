from itertools import combinations
from typing import Callable, List, Sequence, Hashable

def vertex_expansion(elements: Sequence[Hashable],
                     mul: Callable[[Hashable, Hashable], Hashable],
                     gen: Sequence[Hashable]) -> float:
    n = len(elements)
    best = float('inf')
    for k in range(1, n // 2 + 1):
        for combo in combinations(elements, k):
            A = set(combo)
            N = {mul(a, s) for a in A for s in gen}
            boundary = N - A
            best = min(best, len(boundary) / len(A))
    return best
