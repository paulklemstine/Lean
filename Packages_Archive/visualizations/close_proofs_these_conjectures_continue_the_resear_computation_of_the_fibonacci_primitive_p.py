from math import gcd
from typing import List, Tuple


def fib(n: int) -> int:
    """n-th Fibonacci number (F(1)=F(2)=1) via fast doubling, O(log n) big-int ops."""
    def _fd(k: int) -> Tuple[int, int]:
        if k == 0:
            return (0, 1)
        a, b = _fd(k >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        return (d, c + d) if k & 1 else (c, d)
    return _fd(n)[0]


def strip_all_aux(r: int, m: int) -> int:
    """Divide r by gcd(r, m) repeatedly until coprime. Terminates: r strictly
    decreases on every productive step (`stripAllAux`)."""
    if m <= 1:
        return r
    while True:
        g = gcd(r, m)
        if g <= 1:
            return r
        r //= g


def proper_divisors(n: int) -> List[int]:
    """All d with 0 < d < n and d | n (`propDivs`)."""
    return [d for d in range(1, n) if n % d == 0]


def prim_part(n: int) -> int:
    """Primitive part of F(n): strip from F(n) all factors shared with F(d) for
    each proper divisor d of n (`primPart`)."""
    r = fib(n)
    for d in proper_divisors(n):
        r = strip_all_aux(r, fib(d))
    return r
