from typing import Iterator, Tuple

def continued_fraction(num: int, den: int) -> Iterator[int]:
    """Yield the continued-fraction quotients of num/den (exact integer arithmetic)."""
    while den:
        a = num // den
        yield a
        num, den = den, num - a * den

def convergents(num: int, den: int) -> Iterator[Tuple[int, int]]:
    """Yield the convergents (h_i, k_i) of num/den as (numerator, denominator).

    Uses the standard recurrences h_i = a_i h_{i-1} + h_{i-2},
    k_i = a_i k_{i-1} + k_{i-2}. Each convergent is the best rational
    approximation of num/den with denominator at most k_i.
    """
    h_prev, h_cur = 0, 1
    k_prev, k_cur = 1, 0
    for a in continued_fraction(num, den):
        h_prev, h_cur = h_cur, a * h_cur + h_prev
        k_prev, k_cur = k_cur, a * k_cur + k_prev
        yield h_cur, k_cur
