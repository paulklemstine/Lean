from typing import Dict

def factorize(n: int) -> Dict[int, int]:
    """Prime factorization of n >= 1 as {prime: exponent}. O(sqrt(n))."""
    if n < 1:
        raise ValueError("n must be >= 1")
    factors: Dict[int, int] = {}
    m, p = n, 2
    while p * p <= m:
        while m % p == 0:
            factors[p] = factors.get(p, 0) + 1
            m //= p
        p += 1
    if m > 1:
        factors[m] = factors.get(m, 0) + 1
    return factors

def totient_multiplicative(n: int) -> int:
    """
    Euler's totient via coprime multiplicativity:
        phi(prod p^k) = prod p^(k-1) * (p - 1).
    Mirrors Nat.totient_mul / Nat.totient_prime / Nat.totient_prime_pow.
    Complexity O(sqrt(n)) dominated by factorization.
    """
    if n == 1:
        return 1
    result = 1
    for p, k in factorize(n).items():
        result *= p ** (k - 1) * (p - 1)
    return result
