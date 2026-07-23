from __future__ import annotations
from typing import Iterator, Optional


def is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False
    d = 3
    while d * d <= n:
        if n % d == 0:
            return False
        d += 2
    return True


def next_prime(p: int) -> int:
    """Smallest prime strictly greater than p (Lemma next_prime_le_of_prime_lt)."""
    c = p + 1
    while not is_prime(c):
        c += 1
    return c


def count_primes(x: int) -> int:
    """pi(x): number of primes <= x; gives the 0-indexed index of a prime p as pi(p)-1."""
    return sum(1 for q in range(2, x + 1) if is_prime(q))


def bounded_pair_to_gap_index(B: int, start: int) -> Optional[tuple[int, int, int]]:
    """
    Realize exists_index_gap_le: given a bound B and a starting threshold,
    find a prime pair (p, q) with p >= start, p < q <= p + B, and return
    (index n with p = p_n, the consecutive gap p_{n+1}-p_n, witness q).
    The returned gap is guaranteed <= B by the reduction theorem.
    """
    p = next_prime(start - 1) if start > 2 else 2
    while True:
        q = next_prime(p)
        if q <= p + B:
            n = count_primes(p) - 1          # 0-indexed: p = nth_prime(n)
            gap = q - p                       # = p_{n+1} - p_n since q is the next prime
            return (n, gap, q)
        p = next_prime(p)


def small_gaps_recur(B: int, indices: list[int], span: int) -> list[tuple[int, int]]:
    """
    Witness liminf primeGap <= B: for each starting index, exhibit some n beyond it
    with consecutive gap <= B, showing the property holds frequently (infinitely often).
    """
    out: list[tuple[int, int]] = []
    for start_index in indices:
        n = start_index
        # advance to the n-th prime
        c, i = 1, -1
        while i < n:
            c += 1
            if is_prime(c):
                i += 1
        p = c
        while True:
            q = next_prime(p)
            if q - p <= B:
                out.append((n, q - p))
                break
            p = q
            n += 1
    return out
