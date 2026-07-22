from functools import lru_cache
from itertools import combinations
from typing import Sequence, Tuple

Perm = Tuple[int, ...]

PATTERN_3412: Perm = (2, 3, 0, 1)
PATTERN_4231: Perm = (3, 1, 2, 0)


def inversion_length(sigma: Perm) -> int:
    n: int = len(sigma)
    return sum(1 for i in range(n) for j in range(i + 1, n)
               if sigma[i] > sigma[j])


def _relative_order(values: Sequence[int]) -> Perm:
    ranks = {v: r for r, v in enumerate(sorted(values))}
    return tuple(ranks[v] for v in values)


def _contains(sigma: Perm, pattern: Perm) -> bool:
    k = len(pattern)
    return any(_relative_order([sigma[p] for p in pos]) == pattern
               for pos in combinations(range(len(sigma)), k))


def is_smooth(sigma: Perm) -> bool:
    return not _contains(sigma, PATTERN_3412) and not _contains(sigma, PATTERN_4231)


def bruhat_covers(sigma: Perm) -> Tuple[Perm, ...]:
    """Lower covers tau < sigma with len(tau) = len(sigma) - 1, via adjacent
    transpositions that remove exactly one inversion."""
    n = len(sigma)
    out = []
    for i in range(n - 1):
        if sigma[i] > sigma[i + 1]:
            t = list(sigma)
            t[i], t[i + 1] = t[i + 1], t[i]
            out.append(tuple(t))
    return tuple(out)


def longest_smooth_chain(sigma: Perm) -> int:
    """Length (number of steps) of the longest length-chain to sigma whose
    every element is smooth; -1 if sigma itself is singular.

    Memoized longest-path in the length-graded DAG restricted to smooth
    vertices; finite by the chain-rank bound (chain_steps_le_len)."""
    @lru_cache(maxsize=None)
    def go(tau: Perm) -> int:
        if not is_smooth(tau):
            return -1
        best = 0
        for c in bruhat_covers(tau):
            sub = go(c)
            if sub >= 0:
                best = max(best, 1 + sub)
        return best
    return go(sigma)
