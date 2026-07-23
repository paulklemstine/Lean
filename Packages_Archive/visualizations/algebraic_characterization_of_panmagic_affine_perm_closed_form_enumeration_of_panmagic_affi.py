from typing import List, Tuple

def factorize(n: int) -> List[Tuple[int, int]]:
    """Prime factorization of n as a list of (prime, exponent) pairs."""
    factors: List[Tuple[int, int]] = []
    m, d = n, 2
    while d * d <= m:
        if m % d == 0:
            k = 0
            while m % d == 0:
                m //= d
                k += 1
            factors.append((d, k))
        d += 1
    if m > 1:
        factors.append((m, 1))
    return factors

def count_panmagic(n: int) -> int:
    """Number of panmagic affine permutations of Z_n in closed form.

    N(n) = n * P(n), where P is the multiplicative function with
    P(p^k) = p^(k-1)*(p-3) for primes p >= 5, and P(p^k) = 0 for p in {2,3}.
    Hence N(n) > 0 iff gcd(n, 6) == 1. Complexity: one factorization of n.
    """
    if n == 1:
        return 1  # P(1) = 1
    P = 1
    for p, k in factorize(n):
        if p in (2, 3):
            return 0
        P *= p ** (k - 1) * (p - 3)
    return n * P
