from typing import List, Tuple

def divisors(n: int) -> List[int]:
    """Sorted positive divisors of n (n >= 1)."""
    small: List[int] = []
    large: List[int] = []
    d = 1
    while d * d <= n:
        if n % d == 0:
            small.append(d)
            if d != n // d:
                large.append(n // d)
        d += 1
    return small + large[::-1]

def fib_pair_mod(n: int, m: int) -> Tuple[int, int]:
    """(F_n mod m, F_{n+1} mod m) by fast doubling, O(log n) multiplications."""
    if m == 1:
        return (0, 0)
    if n == 0:
        return (0, 1 % m)
    a, b = fib_pair_mod(n >> 1, m)
    c = (a * ((2 * b - a) % m)) % m
    d = (a * a + b * b) % m
    return (d, (c + d) % m) if n & 1 else (c, d)

def fib_mod(n: int, m: int) -> int:
    return fib_pair_mod(n, m)[0]

def rank_of_apparition(p: int) -> int:
    """
    Least k > 0 with p | F_k, for a prime p >= 7, via the Law of Apparition.
    Only the divisors of p-1 and p+1 are tested (the theorem guarantees one works,
    and the spine guarantees the least hit is the true rank).
    """
    candidates = sorted(set(divisors(p - 1)) | set(divisors(p + 1)))
    for d in candidates:
        if fib_mod(d, p) == 0:
            return d
    raise RuntimeError("Law of Apparition violated (input not a valid prime >= 7?)")
