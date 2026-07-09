from __future__ import annotations


def is_prime(n: int) -> bool:
    """Deterministic trial-division primality test."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d: int = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def bertrand_prime(n: int) -> int | None:
    """Largest prime p with n/2 < p <= n (Bertrand's postulate, n >= 2)."""
    if n < 2:
        return None
    for p in range(n, n // 2, -1):
        if is_prime(p):
            return p
    return None


def p_adic_valuation_factorial(n: int, p: int) -> int:
    """Legendre's formula: exponent of prime p in n! = sum_{i>=1} floor(n/p^i)."""
    total: int = 0
    power: int = p
    while power <= n:
        total += n // power
        power *= p
    return total


def factorial_is_square(n: int) -> bool:
    """Decide whether n! is a perfect square WITHOUT computing n!.

    Implements the proved theorem factorial_square_iff_le_one. For n >= 2 the
    Bertrand prime p in (n/2, n] satisfies v_p(n!) = 1 (odd), so n! is never a
    square; for n <= 1, n! = 1 is a square.  Runs in O(n log n / log log n) time
    dominated by the primality search, using O(1) big integers.
    """
    if n <= 1:
        return True
    p = bertrand_prime(n)
    assert p is not None, "Bertrand's postulate guarantees a prime for n >= 2"
    return p_adic_valuation_factorial(n, p) % 2 == 0
