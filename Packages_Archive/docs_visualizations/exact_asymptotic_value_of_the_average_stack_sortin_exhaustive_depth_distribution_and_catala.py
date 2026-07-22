from itertools import permutations
from math import comb
from typing import Dict, List


def stack_sort(l: List[int]) -> List[int]:
    out: List[int] = []
    s: List[int] = []
    for x in l:
        while s and s[0] < x:
            out.append(s.pop(0))
        s = [x] + s
    out.extend(s)
    return out


def depth(l: List[int]) -> int:
    cur, target, steps = list(l), sorted(l), 0
    while cur != target:
        cur = stack_sort(cur)
        steps += 1
    return steps


def depth_distribution(n: int) -> Dict[int, int]:
    """Map t -> number of permutations of [1..n] with stack-sorting depth t."""
    counts: Dict[int, int] = {}
    for p in permutations(range(1, n + 1)):
        d = depth(list(p))
        counts[d] = counts.get(d, 0) + 1
    return dict(sorted(counts.items()))


def catalan(n: int) -> int:
    return comb(2 * n, n) // (n + 1)


def verify_catalan_law(n: int) -> bool:
    """Check that #{w in S_n : depth(w) <= 1} equals the Catalan number C_n."""
    onepass = sum(1 for p in permutations(range(1, n + 1)) if depth(list(p)) <= 1)
    return onepass == catalan(n)
