from math import comb

def cover_count(N: int, d: int) -> int:
    """Evaluate Cover's counting function in O(d) using a rolling binomial."""
    if N < 1 or d < 1:
        raise ValueError("require N >= 1 and d >= 1")
    total = 0
    term = 1  # binom(N-1, 0)
    for k in range(d):
        total += term
        term = term * (N - 1 - k) // (k + 1)  # binom(N-1, k+1)
    return 2 * total
