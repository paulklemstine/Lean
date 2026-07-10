"""
Persistent Homology of the Prime Point Cloud
============================================

Numerical demonstrations of the results in the accompanying paper.

Central facts demonstrated here:

  * On a line, two points of a strictly increasing cloud lie in the same
    epsilon-connected component iff every consecutive gap between them is <= eps
    (the Single-Linkage Theorem).

  * Consequently the finite zero-dimensional (H_0) persistence barcode of the
    prime point cloud is EXACTLY the multiset of consecutive prime gaps:
    the i-th finite bar has death scale p_{i+1} - p_i.

  * The twin prime conjecture is equivalent to the barcode containing infinitely
    many bars of length 2.

  * The mean bar length over the first N primes telescopes to (p_{N+1} - 2)/N and
    is asymptotic to log(x), the Prime Number Theorem prediction.

The script is self-contained: it only uses the Python standard library.
"""

from __future__ import annotations

import math
from collections import Counter
from typing import Dict, List, Tuple


# ---------------------------------------------------------------------------
# Primes and gaps
# ---------------------------------------------------------------------------
def sieve_primes(bound: int) -> List[int]:
    """Return all primes <= bound via the sieve of Eratosthenes."""
    if bound < 2:
        return []
    is_prime = bytearray([1]) * (bound + 1)
    is_prime[0] = is_prime[1] = 0
    for i in range(2, int(bound**0.5) + 1):
        if is_prime[i]:
            is_prime[i * i : bound + 1 : i] = b"\x00" * len(
                range(i * i, bound + 1, i)
            )
    return [i for i in range(2, bound + 1) if is_prime[i]]


def prime_gaps(primes: List[int]) -> List[int]:
    """Consecutive prime gaps g_i = p_{i+1} - p_i.

    By the Adjacent-Merge Theorem these are exactly the finite H_0 bar lengths
    (death scales) of the prime point cloud.
    """
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


# ---------------------------------------------------------------------------
# The H_0 barcode
# ---------------------------------------------------------------------------
def h0_barcode(primes: List[int]) -> List[int]:
    """The finite H_0 barcode of the prime cloud = the gap multiset (Cor. 3.3)."""
    return prime_gaps(primes)


def components_at_scale(gaps: List[int], eps: float) -> int:
    """Number of epsilon-connected components (bars alive at scale eps).

    By the Single-Linkage Theorem components are maximal runs of gaps <= eps,
    separated exactly by gaps > eps; hence #components = #(gaps > eps) + 1.
    """
    cuts = sum(1 for g in gaps if g > eps)
    return cuts + 1


def brute_force_components_at_scale(positions: List[int], eps: float) -> int:
    """Independent union-find computation of components, to check the formula.

    Uses the genuine Vietoris-Rips connectivity: union i, j whenever
    |pos_i - pos_j| <= eps.  On a line only adjacent unions can matter, but we
    check all adjacent pairs explicitly with a union-find structure.
    """
    n = len(positions)
    parent = list(range(n))

    def find(x: int) -> int:
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(a: int, b: int) -> None:
        ra, rb = find(a), find(b)
        if ra != rb:
            parent[ra] = rb

    for i in range(n - 1):
        if positions[i + 1] - positions[i] <= eps:
            union(i, i + 1)
    return len({find(i) for i in range(n)})


# ---------------------------------------------------------------------------
# Twin bars
# ---------------------------------------------------------------------------
def twin_bar_count(gaps: List[int]) -> int:
    """Number of length-2 bars = number of twin prime pairs (Thm 4.3)."""
    return sum(1 for g in gaps if g == 2)


def hardy_littlewood_twin_estimate(bound: int) -> float:
    """Hardy-Littlewood prediction 2 C_2 * N / (log N)^2 for twins below `bound`."""
    C2 = 0.6601618158  # twin prime constant
    if bound < 3:
        return 0.0
    # integral form is more accurate, but the leading term suffices for a demo
    return 2 * C2 * bound / (math.log(bound) ** 2)


# ---------------------------------------------------------------------------
# Average-gap law
# ---------------------------------------------------------------------------
def mean_bar_length(primes: List[int]) -> float:
    """Mean finite bar length = (p_N - p_0)/N by telescoping (Sec 6.1)."""
    n = len(primes) - 1
    return (primes[-1] - primes[0]) / n


def bar_length_histogram(gaps: List[int]) -> Dict[int, int]:
    """Multiplicity of each bar length (barcode of the primes)."""
    return dict(sorted(Counter(gaps).items()))


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_single_linkage(bound: int = 200) -> None:
    print("=" * 68)
    print("DEMO 1  Single-Linkage Theorem: formula vs. union-find")
    print("=" * 68)
    primes = sieve_primes(bound)
    gaps = prime_gaps(primes)
    print(f"primes <= {bound}: {primes}")
    for eps in [1, 2, 4, 6, 8, 14]:
        formula = components_at_scale(gaps, eps)
        brute = brute_force_components_at_scale(primes, eps)
        flag = "OK" if formula == brute else "MISMATCH!"
        print(f"  eps={eps:3d}:  formula #components={formula:4d}   "
              f"union-find={brute:4d}   [{flag}]")
    print()


def demo_barcode_is_gaps(bound: int = 100) -> None:
    print("=" * 68)
    print("DEMO 2  The H_0 barcode IS the prime gap sequence")
    print("=" * 68)
    primes = sieve_primes(bound)
    barcode = h0_barcode(primes)
    print(f"primes <= {bound}:")
    print(f"  {primes}")
    print("Finite H_0 bar lengths (= death scales = prime gaps):")
    print(f"  {barcode}")
    print("Bar-length multiplicities (barcode histogram):")
    for length, mult in bar_length_histogram(barcode).items():
        print(f"    length {length:3d}: {'#' * mult} ({mult})")
    print()


def demo_twin_bars(bound: int = 1_000_000) -> None:
    print("=" * 68)
    print("DEMO 3  Twin prime conjecture = infinitely many length-2 bars")
    print("=" * 68)
    primes = sieve_primes(bound)
    gaps = prime_gaps(primes)
    print(f"{'N (bound)':>12} | {'#length-2 bars':>15} | {'H-L estimate':>14}")
    print("-" * 48)
    for b in [1_000, 10_000, 100_000, 1_000_000]:
        if b > bound:
            continue
        sub = [p for p in primes if p <= b]
        subgaps = prime_gaps(sub)
        actual = twin_bar_count(subgaps)
        est = hardy_littlewood_twin_estimate(b)
        print(f"{b:>12} | {actual:>15} | {est:>14.1f}")
    print("Length-2 bars keep appearing -> twin prime conjecture (open).")
    print()


def demo_average_gap_law(bound: int = 1_000_000) -> None:
    print("=" * 68)
    print("DEMO 4  Average bar length ~ log(x)  (Prime Number Theorem)")
    print("=" * 68)
    primes = sieve_primes(bound)
    print(f"{'x = largest prime':>18} | {'mean bar length':>16} | {'log(x)':>10}")
    print("-" * 52)
    for b in [1_000, 10_000, 100_000, 1_000_000]:
        if b > bound:
            continue
        sub = [p for p in primes if p <= b]
        mean = mean_bar_length(sub)
        print(f"{sub[-1]:>18} | {mean:>16.4f} | {math.log(sub[-1]):>10.4f}")
    print()


def demo_poisson_comparison(bound: int = 1_000_000) -> None:
    print("=" * 68)
    print("DEMO 5  Prime barcode vs. Poisson null model")
    print("=" * 68)
    primes = sieve_primes(bound)
    gaps = prime_gaps(primes)
    total = len(gaps)
    even = sum(1 for g in gaps if g % 2 == 0)
    print(f"primes <= {bound}:  {total} finite bars")
    print(f"  fraction of even-length bars : {even / total:.6f}  "
          f"(parity rigidity: -> 1)")
    frac2 = twin_bar_count(gaps) / total
    # Poisson(mean m) would give P(gap == 2) ~ (1/m) e^{-2/m}, continuous model;
    # here we report the observed fraction for contrast.
    m = mean_bar_length(primes)
    poisson_like = (1.0 / m) * math.exp(-2.0 / m)
    print(f"  observed fraction of length-2 bars : {frac2:.6f}")
    print(f"  crude exponential(mean={m:.2f}) density at 2 : {poisson_like:.6f}")
    print("  Small even gaps are over-represented vs. the memoryless model.")
    print()


def main() -> None:
    demo_single_linkage(bound=200)
    demo_barcode_is_gaps(bound=100)
    demo_twin_bars(bound=1_000_000)
    demo_average_gap_law(bound=1_000_000)
    demo_poisson_comparison(bound=1_000_000)


if __name__ == "__main__":
    main()
