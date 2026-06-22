from math import gcd
from typing import Optional, Tuple


def lcm(a: int, b: int) -> int:
    return a * b // gcd(a, b)


def entry(m: int) -> int:
    if m == 1:
        return 1
    a, b, k = 0, 1, 1
    while b % m != 0:
        a, b = b, (a + b) % m
        k += 1
    return k


def check_join_law(N: int) -> Optional[Tuple[int, int]]:
    """Return None if entry(lcm(a,b)) == lcm(entry(a),entry(b)) for all a,b <= N,
    otherwise the first counterexample pair."""
    for a in range(1, N + 1):
        for b in range(1, N + 1):
            if entry(lcm(a, b)) != lcm(entry(a), entry(b)):
                return (a, b)
    return None
