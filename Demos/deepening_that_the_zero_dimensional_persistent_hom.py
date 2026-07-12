"""
Numerical demonstrations for:

    The Zero-Dimensional Persistent Homology of the Prime Point Cloud

We treat the primes 2, 3, 5, 7, 11, ... as a point cloud on the real line and
compute, entirely from first principles:

    * prime gaps                g_i = p_{i+1} - p_i
    * the Betti staircase       beta_0(eps, n) = 1 + #{ i < n : g_i > eps }
    * the H_0 barcode           finite bars of length g_i, plus one infinite bar
    * total persistence         TP(n) = p_n - 2
    * Euclid's composite runs   N!+2, ..., N!+N (a "prime desert")

and we verify, numerically, the qualitative theorems:

    * prime gaps are unbounded (large gaps recur arbitrarily far out);
    * for every fixed resolution eps, beta_0(eps, n) grows without bound;
    * there is no global merge scale;
    * total persistence diverges.

The file is self-contained: no third-party dependencies.
"""

from __future__ import annotations

from math import isqrt, factorial
from typing import List, Tuple


# --------------------------------------------------------------------------- #
# Prime generation                                                            #
# --------------------------------------------------------------------------- #
def is_prime(m: int) -> bool:
    """Deterministic trial-division primality test."""
    if m < 2:
        return False
    if m < 4:
        return True
    if m % 2 == 0:
        return False
    for d in range(3, isqrt(m) + 1, 2):
        if m % d == 0:
            return False
    return True


def first_primes(n: int) -> List[int]:
    """Return the first n primes p_0, ..., p_{n-1} with p_0 = 2."""
    primes: List[int] = []
    candidate = 2
    while len(primes) < n:
        if is_prime(candidate):
            primes.append(candidate)
        candidate += 1
    return primes


# --------------------------------------------------------------------------- #
# Core persistent-homology quantities                                         #
# --------------------------------------------------------------------------- #
def prime_gaps(primes: List[int]) -> List[int]:
    """Consecutive gaps g_i = p_{i+1} - p_i."""
    return [primes[i + 1] - primes[i] for i in range(len(primes) - 1)]


def betti_zero(gaps: List[int], eps: float) -> int:
    """Zeroth Betti number of the line point cloud at resolution eps.

    beta_0 = 1 + #{ i : g_i > eps }, the number of eps-connected components.
    """
    return 1 + sum(1 for g in gaps if g > eps)


def barcode(gaps: List[int]) -> Tuple[List[Tuple[float, float]], int]:
    """H_0 barcode of points on a line.

    Returns (finite_bars, infinite_bars) where each finite bar is (birth, death)
    with birth = 0 and death = g_i. There is exactly one infinite bar.
    """
    finite_bars = [(0.0, float(g)) for g in gaps]
    return finite_bars, 1


def total_persistence(primes: List[int]) -> int:
    """Sum of finite bar lengths = p_last - p_0 = p_last - 2 (telescoping)."""
    return primes[-1] - primes[0]


def gap_count_above(gaps: List[int], c: float) -> int:
    """#{ i : g_i > c }: number of bars strictly longer than c."""
    return sum(1 for g in gaps if g > c)


# --------------------------------------------------------------------------- #
# Euclid's composite run (constructive large gaps)                            #
# --------------------------------------------------------------------------- #
def composite_run(N: int) -> List[int]:
    """The prime desert N!+2, ..., N!+N: N-1 consecutive composites."""
    base = factorial(N)
    return [base + j for j in range(2, N + 1)]


def verify_composite_run(N: int) -> bool:
    """Check that every member of the desert is composite (divisible by j)."""
    base = factorial(N)
    return all((base + j) % j == 0 and (base + j) > j for j in range(2, N + 1))


# --------------------------------------------------------------------------- #
# Demonstrations                                                              #
# --------------------------------------------------------------------------- #
def demo_betti_staircase() -> None:
    print("=" * 70)
    print("1. THE BETTI STAIRCASE  beta_0(eps, n) = 1 + #{ i < n : g_i > eps }")
    print("=" * 70)
    primes = first_primes(30)
    gaps = prime_gaps(primes)
    print(f"first primes : {primes[:15]} ...")
    print(f"prime gaps   : {gaps[:14]} ...")
    print()
    print(f"{'eps':>6} | {'beta_0 (components among first 30 primes)':<45}")
    print("-" * 60)
    for eps in [0, 1, 2, 3, 4, 5, 6, 7, 8, 10]:
        b = betti_zero(gaps, eps)
        print(f"{eps:>6} | {b:<3}  {'#' * b}")
    print("As eps grows the staircase descends: coarser vision -> fewer blobs.\n")


def demo_barcode() -> None:
    print("=" * 70)
    print("2. THE H_0 BARCODE  (bar length = prime gap)")
    print("=" * 70)
    primes = first_primes(12)
    gaps = prime_gaps(primes)
    finite_bars, infinite = barcode(gaps)
    print(f"primes: {primes}")
    for i, (birth, death) in enumerate(finite_bars):
        length = death - birth
        bar = "|" + "-" * int(length) + ">"
        print(f"  bar {i:>2}: [0, {death:>4.1f})  len={length:>3.0f}  {bar}")
    print(f"  + {infinite} infinite bar (the component that never dies)")
    print(f"total persistence TP = p_n - 2 = {total_persistence(primes)}\n")


def demo_unbounded_gaps() -> None:
    print("=" * 70)
    print("3. PRIME GAPS ARE UNBOUNDED  (Euclid's factorial desert)")
    print("=" * 70)
    for N in [5, 7, 10]:
        run = composite_run(N)
        ok = verify_composite_run(N)
        print(f"N={N:>2}: desert of {len(run)} consecutive composites, "
              f"first = N!+2 = {run[0]}, all composite? {ok}")
    print("A run of N-1 composites forces a consecutive prime gap of size >= N.\n")

    # Empirically: record-breaking gaps recur as we scan further out.
    primes = first_primes(3000)
    gaps = prime_gaps(primes)
    record = 0
    print("Record prime gaps as we scan the first 3000 primes:")
    for i, g in enumerate(gaps):
        if g > record:
            record = g
            print(f"  new record gap {g:>3} at p_{i} = {primes[i]}")
    print()


def demo_betti_diverges() -> None:
    print("=" * 70)
    print("4. THE BETTI CURVE DIVERGES  (the cloud shatters at every scale)")
    print("=" * 70)
    primes = first_primes(20000)
    gaps = prime_gaps(primes)
    print(f"{'n':>7} | " + " | ".join(f"beta_0(eps={e})" for e in (2, 6, 14, 20)))
    print("-" * 70)
    for n in [10, 100, 1000, 5000, 10000, 20000]:
        sub = gaps[:n]
        row = " | ".join(f"{betti_zero(sub, e):>13}" for e in (2, 6, 14, 20))
        print(f"{n:>7} | {row}")
    print("Every column grows without bound: no fixed eps caps the components.\n")


def demo_no_global_merge() -> None:
    print("=" * 70)
    print("5. NO GLOBAL MERGE SCALE  (some scale is never enough)")
    print("=" * 70)
    primes = first_primes(20000)
    gaps = prime_gaps(primes)
    for eps in [10, 30, 50, 100]:
        # find the first n at which beta_0 exceeds 1 at this resolution
        n_break = None
        for i, g in enumerate(gaps):
            if g > eps:
                n_break = i + 1
                break
        msg = (f"first split after {n_break} primes (gap {gaps[n_break-1]})"
               if n_break else "still connected within sample")
        print(f"  eps={eps:>4}: {msg}")
    print("However coarse the scale, the cloud eventually splits (beta_0 > 1).\n")


def demo_total_persistence() -> None:
    print("=" * 70)
    print("6. TOTAL PERSISTENCE DIVERGES  (TP(n) = p_n - 2)")
    print("=" * 70)
    for n in [10, 100, 1000, 10000]:
        primes = first_primes(n)
        tp_formula = primes[-1] - 2
        tp_sum = sum(prime_gaps(primes))
        print(f"  n={n:>6}: TP = p_n - 2 = {tp_formula:>7}  "
              f"(check sum of gaps = {tp_sum:>7})  match={tp_formula == tp_sum}")
    print("TP grows like p_n -> infinity.\n")


def main() -> None:
    demo_betti_staircase()
    demo_barcode()
    demo_unbounded_gaps()
    demo_betti_diverges()
    demo_no_global_merge()
    demo_total_persistence()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
