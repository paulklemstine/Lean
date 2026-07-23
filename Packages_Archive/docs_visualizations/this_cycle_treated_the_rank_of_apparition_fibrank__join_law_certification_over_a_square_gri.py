from math import gcd
from functools import reduce
from typing import Iterable, List, Tuple


def lcm(a: int, b: int) -> int:
    return 0 if a == 0 or b == 0 else a // gcd(a, b) * b


def fib_rank(m: int) -> int:
    if m == 0:
        return 0
    if m == 1:
        return 1
    a, b = 0, 1
    k = 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def verify_join_law(N: int) -> bool:
    """Check fibRank(lcm(a,b)) == lcm(fibRank(a), fibRank(b)) for all 1<=a,b<=N.

    Complexity: O(N^2) rank computations. Returns True iff the join law holds
    on the whole square (it always does — this certifies the left-adjoint law).
    """
    rank = [0] + [fib_rank(m) for m in range(1, N + 1)]
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            if fib_rank(lcm(a, b)) != lcm(rank[a], rank[b]):
                return False
    return True


def finite_join(family: List[int]) -> Tuple[int, int]:
    """Return (fibRank(lcm family), lcm of fibRanks) — always equal."""
    left = fib_rank(reduce(lcm, family))
    right = reduce(lcm, (fib_rank(a) for a in family))
    return left, right
