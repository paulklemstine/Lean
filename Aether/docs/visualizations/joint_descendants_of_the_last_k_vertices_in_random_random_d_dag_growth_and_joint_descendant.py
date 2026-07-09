import random
from typing import List, Sequence


def grow_random_ddag(d: int, N: int, rng: random.Random) -> List[List[int]]:
    """Grow a random d-DAG on vertices 0..N-1: vertex n (>= d) points to d
    distinct uniformly random earlier vertices. Returns parents[n]."""
    parents: List[List[int]] = [[] for _ in range(N)]
    for n in range(d, N):
        parents[n] = rng.sample(range(n), d)
    return parents


def joint_descendant_count(block: Sequence[int],
                           parents: Sequence[Sequence[int]], N: int) -> int:
    """Count vertices reachable-to (descendants of) every vertex in `block`.

    For each seed we propagate a boolean 'is-descendant' flag forward in the
    topological (index) order; the joint set is the intersection. Complexity
    O(k * N * d) for a block of size k."""
    k = len(block)
    flags = [[False] * N for _ in range(k)]
    for idx, v in enumerate(block):
        flags[idx][v] = True
        for w in range(v + 1, N):
            if any(flags[idx][u] for u in parents[w]):
                flags[idx][w] = True
    count = 0
    lo = max(block)
    for w in range(lo + 1, N):
        if all(flags[idx][w] for idx in range(k)):
            count += 1
    return count
