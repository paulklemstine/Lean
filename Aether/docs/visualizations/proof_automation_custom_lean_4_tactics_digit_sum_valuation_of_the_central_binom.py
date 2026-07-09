from math import comb
from typing import List


def digit_sum_base(m: int, base: int) -> int:
    """Sum of the base-`base` digits of m."""
    s = 0
    while m > 0:
        s += m % base
        m //= base
    return s


def central_binom_valuation(n: int, p: int) -> int:
    """v_p(C(2n,n)) computed via the digit-sum formula
    v_p(C(2n,n)) = (2*s_p(n) - s_p(2n)) / (p-1),
    in O(log_p n) operations, without factoring C(2n,n)."""
    if p < 2:
        raise ValueError("p must be a prime >= 2")
    numerator = 2 * digit_sum_base(n, p) - digit_sum_base(2 * n, p)
    return numerator // (p - 1)


def central_binom_factorization(n: int, primes: List[int]) -> dict[int, int]:
    """Prime factorization of C(2n,n) over the supplied primes (each <= 2n),
    using only digit-sum valuations."""
    return {p: central_binom_valuation(n, p)
            for p in primes if central_binom_valuation(n, p) > 0}
