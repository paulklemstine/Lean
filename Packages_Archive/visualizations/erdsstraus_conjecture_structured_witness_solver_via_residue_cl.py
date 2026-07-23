from fractions import Fraction
from typing import Optional, Tuple

Triple = Tuple[int, int, int]

def min_fac(n: int) -> int:
    if n % 2 == 0:
        return 2
    d = 3
    while d * d <= n:
        if n % d == 0:
            return d
        d += 2
    return n

def search_prime_witness(p: int, bound: int = 200000) -> Optional[Triple]:
    target = Fraction(4, p)
    for x in range(p // 4 + 1, min(bound, 3 * p // 4 + 2) + 1):
        rem = target - Fraction(1, x)
        if rem <= 0:
            continue
        a, c = rem.numerator, rem.denominator
        for y in range(c // a + 1, 2 * c // a + 2):
            second = rem - Fraction(1, y)
            if second > 0 and second.numerator == 1:
                return (x, y, second.denominator)
    return None

def solve(n: int) -> Triple:
    if n < 2:
        raise ValueError('n must be >= 2')
    if n % 2 == 0:
        m = n // 2
        return (m, m + 1, m * (m + 1))
    if n % 3 == 0:
        m = n // 3
        return (m + 1, m * (m + 1), 3 * m)
    if n % 4 == 3:
        k = (n + 1) // 4
        return (k, 2 * k * n, 2 * k * n)
    if n % 8 == 5:
        b = (n + 3) // 8
        return (2 * b, 2 * b * n, b * n)
    p = min_fac(n)
    if p == n:
        t = search_prime_witness(p)
        if t is None:
            raise RuntimeError(f'no witness for prime {p}')
        return t
    x, y, z = solve(p)
    k = n // p
    return (k * x, k * y, k * z)
