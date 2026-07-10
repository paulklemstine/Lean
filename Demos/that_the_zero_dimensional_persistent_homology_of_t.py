"""
Numerical demonstration of the quantitative invariants of the zero-dimensional
persistent homology of the prime point cloud.

The prime point cloud places the n-th prime p_n on the real line:

    P(0) = 2, P(1) = 3, P(2) = 5, P(3) = 7, P(4) = 11, ...

Its zero-dimensional persistent homology (Vietoris-Rips filtration) is entirely
governed by the prime gaps g_i = p_{i+1} - p_i.  This script verifies the two
headline identities established for this cloud:

  * Total persistence of the first n finite bars  =  p_n - 2  =  sum of the
    first n prime gaps  (telescoping identity).

  * Betti staircase:  b_0(epsilon, n) = 1 + #{ i < n : g_i > epsilon }, and the
    global merge scale (smallest epsilon making the cloud connected) equals the
    maximal gap.

All functions are self-contained and type-hinted; run with `python3 demo.py`.
"""

from __future__ import annotations

from typing import List, Tuple


# ---------------------------------------------------------------------------
# Prime generation
# ---------------------------------------------------------------------------
def first_primes(count: int) -> List[int]:
    """Return the first `count` primes p_0, ..., p_{count-1} (p_0 = 2)."""
    if count <= 0:
        return []
    primes: List[int] = []
    candidate: int = 2
    while len(primes) < count:
        is_prime: bool = True
        for q in primes:
            if q * q > candidate:
                break
            if candidate % q == 0:
                is_prime = False
                break
        if is_prime:
            primes.append(candidate)
        candidate += 1
    return primes


def prime_gaps(primes: List[int]) -> List[int]:
    """Prime gaps g_i = p_{i+1} - p_i for i = 0, ..., len(primes)-2."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


# ---------------------------------------------------------------------------
# Barcode and total persistence
# ---------------------------------------------------------------------------
def finite_bars(primes: List[int], n: int) -> List[Tuple[float, float]]:
    """The n finite H_0 bars [0, g_i) of the prime cloud on {p_0, ..., p_n}."""
    gaps = prime_gaps(primes[: n + 1])
    return [(0.0, float(g)) for g in gaps]


def total_persistence(primes: List[int], n: int) -> int:
    """Total persistence of the first n finite bars = sum of the first n gaps."""
    return sum(prime_gaps(primes[: n + 1]))


def total_persistence_closed_form(primes: List[int], n: int) -> int:
    """Closed form of the same quantity: p_n - 2."""
    return primes[n] - 2


# ---------------------------------------------------------------------------
# Betti staircase
# ---------------------------------------------------------------------------
def betti_zero(primes: List[int], epsilon: float, n: int) -> int:
    """b_0(epsilon, n) = 1 + #{ i < n : g_i > epsilon }."""
    gaps = prime_gaps(primes[: n + 1])
    return 1 + sum(1 for g in gaps if g > epsilon)


def global_merge_scale(primes: List[int], n: int) -> int:
    """Smallest epsilon making the first n+1 points a single component = max gap."""
    gaps = prime_gaps(primes[: n + 1])
    return max(gaps) if gaps else 0


def betti_staircase(primes: List[int], n: int) -> List[Tuple[float, int]]:
    """
    The full Betti curve as a list of (epsilon-threshold, b0-just-above) pairs.
    b0 starts at n+1 for epsilon in [0, min gap) and descends to 1.
    Returns the distinct gap thresholds with the Betti value strictly above them.
    """
    gaps = sorted(set(prime_gaps(primes[: n + 1])))
    curve: List[Tuple[float, int]] = []
    for g in gaps:
        curve.append((float(g), betti_zero(primes, float(g), n)))
    return curve


# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------
def main() -> None:
    N: int = 30
    primes = first_primes(N + 1)  # p_0 ... p_N
    gaps = prime_gaps(primes)

    print("=" * 70)
    print("Prime point cloud  P(k) = p_k")
    print("=" * 70)
    print("primes p_0..p_N :", primes)
    print("gaps   g_0..g_{N-1}:", gaps)
    print()

    print("-" * 70)
    print("Total persistence identity:  TP(n) = sum of gaps = p_n - 2")
    print("-" * 70)
    print(f"{'n':>3} | {'sum of gaps':>12} | {'p_n - 2':>9} | match")
    for n in [1, 2, 5, 10, 20, 30]:
        tp = total_persistence(primes, n)
        cf = total_persistence_closed_form(primes, n)
        print(f"{n:>3} | {tp:>12} | {cf:>9} | {tp == cf}")
    print()

    print("-" * 70)
    print("Barcode of the first 8 points (finite bars [0, g_i)):")
    print("-" * 70)
    for i, bar in enumerate(finite_bars(primes, 7)):
        print(f"  bar {i}: [{bar[0]:.0f}, {bar[1]:.0f})   length (= gap g_{i}) = {bar[1]-bar[0]:.0f}")
    print("  plus one essential bar [0, infinity)")
    print()

    print("-" * 70)
    print("Betti staircase:  b_0(epsilon, n) = 1 + #{ i < n : g_i > epsilon }")
    print(f"(n = {N}; there are {N} finite bars, so b_0(0) = {N + 1})")
    print("-" * 70)
    print(f"{'epsilon':>8} | {'b_0':>4}")
    for eps in [0.0, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 6.0, 8.0, 100.0]:
        print(f"{eps:>8.1f} | {betti_zero(primes, eps, N):>4}")
    print()

    print("-" * 70)
    print("Global merge scale = maximal gap")
    print("-" * 70)
    gms = global_merge_scale(primes, N)
    print(f"  max gap among first {N} gaps = {gms}")
    print(f"  b_0(max_gap,     n) = {betti_zero(primes, float(gms), N)}  (single component)")
    print(f"  b_0(max_gap - 1, n) = {betti_zero(primes, float(gms) - 1, N)}  (not yet merged)")
    print()

    print("-" * 70)
    print("Distinct steps of the Betti curve (threshold, b_0 at that gap value):")
    print("-" * 70)
    for thr, b0 in betti_staircase(primes, N):
        print(f"  epsilon = {thr:>4.0f}  ->  b_0 = {b0}")


if __name__ == "__main__":
    main()
