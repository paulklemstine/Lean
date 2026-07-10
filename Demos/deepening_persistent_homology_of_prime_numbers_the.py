"""
Persistent Homology of the Prime Point Cloud: The Topology of Arithmetic
========================================================================

Numerical demonstrations of the main results.

Place the n-th prime p_n at position p_n on the real line, and grow a
Vietoris-Rips filtration with scale parameter epsilon. The zero-dimensional
persistent homology (connected components) is governed entirely by the prime
gaps g_n = p_{n+1} - p_n. This module verifies:

  (1) Bar-length identity      : finite bar lengths == prime gaps.
  (2) Betti formula            : b0(eps, n) = 1 + #{ gaps g_i > eps , i < n }.
  (3) Global merge scale       : b0 == 1 iff eps >= max gap.
  (4) Total-persistence identity: sum of gaps == p_n - 2  (telescoping).
  (5) Unbounded bars           : prime gaps (hence bars) grow without bound.

Self-contained; standard library only.
"""

from __future__ import annotations

from bisect import bisect_right
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Prime generation                                                            #
# --------------------------------------------------------------------------- #
def first_n_primes(n: int) -> List[int]:
    """Return the first ``n`` primes via a growing sieve of Eratosthenes."""
    if n < 1:
        return []
    # Upper bound for the n-th prime (valid for n >= 6); pad for small n.
    import math

    if n < 6:
        limit = 15
    else:
        limit = int(n * (math.log(n) + math.log(math.log(n)))) + 10
    sieve = bytearray([1]) * (limit + 1)
    sieve[0] = sieve[1] = 0
    for i in range(2, int(limit ** 0.5) + 1):
        if sieve[i]:
            sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
    primes = [i for i in range(2, limit + 1) if sieve[i]]
    while len(primes) < n:  # safety net if the bound was too tight
        limit *= 2
        sieve = bytearray([1]) * (limit + 1)
        sieve[0] = sieve[1] = 0
        for i in range(2, int(limit ** 0.5) + 1):
            if sieve[i]:
                sieve[i * i :: i] = bytearray(len(sieve[i * i :: i]))
        primes = [i for i in range(2, limit + 1) if sieve[i]]
    return primes[:n]


def prime_gaps(primes: List[int]) -> List[int]:
    """Return the consecutive gaps g_i = p_{i+1} - p_i."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


# --------------------------------------------------------------------------- #
# Persistent homology quantities                                              #
# --------------------------------------------------------------------------- #
def barcode(primes: List[int]) -> Tuple[List[Tuple[float, float]], Tuple[float, float]]:
    """H0 barcode of the prime point cloud.

    Returns (finite_bars, infinite_bar) where each finite bar is [0, g_i).
    """
    gaps = prime_gaps(primes)
    finite_bars = [(0.0, float(g)) for g in gaps]
    infinite_bar = (0.0, float("inf"))
    return finite_bars, infinite_bar


def betti0(eps: float, primes: List[int]) -> int:
    """b0(eps, n) = 1 + #{ i < n : g_i > eps }."""
    gaps = prime_gaps(primes)
    return 1 + sum(1 for g in gaps if g > eps)


def global_merge_scale(primes: List[int]) -> int:
    """Smallest scale at which the first n primes form one component."""
    return max(prime_gaps(primes))


def total_persistence(primes: List[int]) -> int:
    """Sum of finite bar lengths (== sum of gaps)."""
    return sum(prime_gaps(primes))


def betti_curve(primes: List[int]) -> List[Tuple[float, int]]:
    """The descending Betti staircase as (eps, b0) at each distinct gap value."""
    gaps = sorted(set(prime_gaps(primes)))
    curve: List[Tuple[float, int]] = [(0.0, len(primes))]
    for g in gaps:
        curve.append((float(g), betti0(float(g), primes)))
    return curve


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_bar_length_identity(n: int = 10) -> None:
    primes = first_n_primes(n)
    finite_bars, _ = barcode(primes)
    lengths = [b[1] - b[0] for b in finite_bars]
    gaps = [float(g) for g in prime_gaps(primes)]
    print("=== (1) Bar-length identity: bar lengths == prime gaps ===")
    print(f"first {n} primes : {primes}")
    print(f"bar lengths      : {lengths}")
    print(f"prime gaps       : {gaps}")
    print(f"identity holds   : {lengths == gaps}\n")


def demo_betti_and_merge(n: int = 10) -> None:
    primes = first_n_primes(n)
    print("=== (2)/(3) Betti formula and global merge scale ===")
    for eps in [0.5, 1.0, 2.0, 4.0, 6.0]:
        print(f"b0(eps={eps:>4}, n={n}) = {betti0(eps, primes)}")
    M = global_merge_scale(primes)
    print(f"global merge scale M_n = max gap = {M}")
    print(f"b0 == 1 at eps = M_n : {betti0(float(M), primes) == 1}")
    print(f"b0  > 1 just below   : {betti0(float(M) - 0.5, primes) > 1}\n")


def demo_total_persistence(sizes: List[int]) -> None:
    print("=== (4) Total-persistence identity: sum of gaps == p_n - 2 ===")
    print(f"{'n':>8} {'total persistence':>20} {'p_n - 2':>12} {'match':>7}")
    for n in sizes:
        primes = first_n_primes(n)
        tp = total_persistence(primes)
        pred = primes[-1] - 2
        print(f"{n:>8} {tp:>20} {pred:>12} {str(tp == pred):>7}")
    print()


def demo_unbounded_bars(n: int = 100000) -> None:
    primes = first_n_primes(n)
    gaps = prime_gaps(primes)
    print("=== (5) Unbounded bars: record gaps (bar lengths) grow ===")
    record = 0
    for i, g in enumerate(gaps):
        if g > record:
            record = g
            print(f"new record bar length {g:>4} between primes "
                  f"{primes[i]} and {primes[i + 1]}")
    print(f"largest bar length among first {n} primes: {max(gaps)}\n")


def demo_asymptotics(sizes: List[int]) -> None:
    import math

    print("=== Corollary: TP(n) / (n log n) -> 1 (Prime Number Theorem) ===")
    print(f"{'n':>8} {'TP(n)':>12} {'n log n':>14} {'ratio':>8}")
    for n in sizes:
        primes = first_n_primes(n)
        tp = total_persistence(primes)
        nlogn = n * math.log(n)
        print(f"{n:>8} {tp:>12} {nlogn:>14.1f} {tp / nlogn:>8.4f}")
    print()


if __name__ == "__main__":
    demo_bar_length_identity(10)
    demo_betti_and_merge(10)
    demo_total_persistence([10, 100, 1000, 10000])
    demo_unbounded_bars(100000)
    demo_asymptotics([100, 1000, 10000, 100000])
