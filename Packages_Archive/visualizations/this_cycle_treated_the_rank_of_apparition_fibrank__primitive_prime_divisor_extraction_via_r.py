from typing import Dict, List


def factorize(n: int) -> Dict[int, int]:
    factors: Dict[int, int] = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def fib(n: int) -> int:
    a, b = 0, 1
    for _ in range(n):
        a, b = b, a + b
    return a


def fib_rank(m: int) -> int:
    if m <= 1:
        return m
    a, b, k = 0, 1, 0
    while True:
        a, b = b, (a + b) % m
        k += 1
        if a == 0:
            return k


def primitive_prime_divisors(n: int) -> List[int]:
    """Primes q with fibRank(q) == n among the prime divisors of F(n).

    By prime-index Carmichael, when n is prime (n >= 3) this returns ALL prime
    divisors of F(n). Complexity: factor F(n), then one rank per prime factor.
    """
    fn = fib(n)
    if fn <= 1:
        return []
    return [q for q in factorize(fn) if fib_rank(q) == n]
