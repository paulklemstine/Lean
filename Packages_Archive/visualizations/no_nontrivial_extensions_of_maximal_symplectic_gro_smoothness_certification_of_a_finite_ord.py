from math import gcd
from functools import reduce
from typing import Dict, List, Tuple

def prime_factors(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    m, d = n, 2
    while d * d <= m:
        while m % d == 0:
            factors[d] = factors.get(d, 0) + 1
            m //= d
        d += 1 if d == 2 else 2
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def certify_smooth(orders: List[int]) -> Tuple[int, List[int], int]:
    M = reduce(lambda a, b: a * b // gcd(a, b), orders, 1)
    primes = sorted(prime_factors(M))
    bound = max(primes)
    for N in orders:
        assert M % N == 0, f'{N} does not divide lcm {M}'
    return M, primes, bound

if __name__ == '__main__':
    mukai = [960, 384, 288, 192, 192, 72, 72, 48, 168, 360, 120]
    print(certify_smooth(mukai))  # (40320, [2, 3, 5, 7], 7)
