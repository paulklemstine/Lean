"""
Numerical demonstrations for the logarithmic prime embedding
============================================================

The prime fractal is the image of the primes under the logarithmic lens

    iota(p) = 1 / log p,        d(p, q) = |1/log p - 1/log q|,

a bounded subset of (0, 1/log 2] whose geometry is completely described by:

  * Hausdorff dimension              = 0          (the set is countable)
  * box-counting dimension           = 1          (exactly, upper and lower)
  * one-dimensional Minkowski content= 0          (N(m) = Theta(m / log m))
  * total d-length of the primes     = 1/log 2    (telescoping, finite)
  * twin-pair scale                  d(p,p+2) <= 2 / (p (log p)^2)
  * identical dimensions for all integers >= 2    (dimension blindness)

This script demonstrates each of those statements numerically.  It is
self-contained: only the Python standard library is used.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Dict, Iterator, List, Set, Tuple

# ----------------------------------------------------------------------------
# 0.  Basic tools
# ----------------------------------------------------------------------------


def sieve_primes(limit: int) -> List[int]:
    """All primes <= limit, by the sieve of Eratosthenes.  O(limit log log limit)."""
    if limit < 2:
        return []
    flags = bytearray([1]) * (limit + 1)
    flags[0] = flags[1] = 0
    for p in range(2, int(limit**0.5) + 1):
        if flags[p]:
            flags[p * p :: p] = bytearray(len(flags[p * p :: p]))
    return [i for i in range(limit + 1) if flags[i]]


def iota(n: int) -> float:
    """The logarithmic lens 1 / log n, defined for n >= 2."""
    return 1.0 / math.log(n)


def d_metric(p: int, q: int) -> float:
    """The mission metric d(p, q) = |1/log p - 1/log q|."""
    return abs(iota(p) - iota(q))


def box_index(m: int, n: int) -> int:
    """Index of the box of width 1/m containing iota(n): floor(m / log n)."""
    return int(math.floor(m / math.log(n)))


# ----------------------------------------------------------------------------
# 1.  The total d-length of the primes is exactly 1 / log 2
# ----------------------------------------------------------------------------


def cumulative_length(primes: List[int]) -> float:
    """Sum of d(p_i, p_{i+1}) along consecutive primes; telescopes."""
    return sum(d_metric(primes[i], primes[i + 1]) for i in range(len(primes) - 1))


def demo_total_length(primes: List[int]) -> None:
    limit_value = 1.0 / math.log(2.0)
    print("=" * 74)
    print("1. TOTAL LENGTH THEOREM:  sum of d(p_i, p_{i+1})  ->  1 / log 2")
    print("=" * 74)
    print(f"   target 1/log 2 = {limit_value:.12f}\n")
    print(f"   {'primes used':>12} {'largest prime':>14} {'walk length':>16} "
          f"{'predicted deficit':>18}")
    counts = [c for c in (10, 100, 1000, 10_000, len(primes))]
    for count in counts:
        chunk = primes[:count]
        walked = cumulative_length(chunk)
        # the telescoping identity predicts exactly 1/log 2 - 1/log(last prime)
        predicted = limit_value - iota(chunk[-1])
        print(f"   {count:>12} {chunk[-1]:>14} {walked:>16.10f} "
              f"{predicted:>18.10f}")
    print("\n   The two right-hand columns agree to machine precision: the walk")
    print("   telescopes, so the total length is finite and equals 1/log 2.")
    print("   (The heuristic sum  sum_p 1/(p log p)  also converges:")
    partial = sum(1.0 / (p * math.log(p)) for p in primes)
    print(f"    over primes up to {primes[-1]}, it is {partial:.6f} -- bounded, not log log x.)\n")


# ----------------------------------------------------------------------------
# 2.  The twin-pair scale:  d(p, p+2) <= 2 / (p (log p)^2)
# ----------------------------------------------------------------------------


def twin_pairs(primes: List[int]) -> List[Tuple[int, int]]:
    prime_set = set(primes)
    return [(p, p + 2) for p in primes if (p + 2) in prime_set]


def demo_twin_scale(primes: List[int]) -> None:
    print("=" * 74)
    print("2. TWIN SCALE THEOREM:  d(p, p+2) <= 2 / (p (log p)^2)")
    print("=" * 74)
    twins = twin_pairs(primes)
    print(f"   {len(twins)} twin pairs found below {primes[-1]}\n")
    print(f"   {'p':>10} {'d(p,p+2)':>14} {'2/(p log^2 p)':>16} "
          f"{'1/(p log p) [heuristic]':>24} {'ratio':>8}")
    samples = [twins[0], twins[1], twins[len(twins) // 8], twins[len(twins) // 3],
               twins[len(twins) // 2], twins[-1]]
    worst = 0.0
    for p, _ in samples:
        actual = d_metric(p, p + 2)
        proved = 2.0 / (p * math.log(p) ** 2)
        heuristic = 1.0 / (p * math.log(p))
        print(f"   {p:>10} {actual:>14.3e} {proved:>16.3e} {heuristic:>24.3e} "
              f"{heuristic / actual:>8.2f}")
    for p, _ in twins:
        actual = d_metric(p, p + 2)
        proved = 2.0 / (p * math.log(p) ** 2)
        worst = max(worst, actual / proved)
    print(f"\n   max over all {len(twins)} pairs of d(p,p+2) / [2/(p log^2 p)] = {worst:.6f} <= 1")
    print("   The proved bound holds everywhere; the heuristic 1/(p log p) is")
    print("   larger by a growing factor ~ log p / 2, i.e. it overestimates the")
    print("   twin scale.  Twins are closer than the conjecture assumed.\n")


# ----------------------------------------------------------------------------
# 3.  Hausdorff dimension 0:  a cover whose s-cost is arbitrarily small
# ----------------------------------------------------------------------------


def hausdorff_cover_cost(points: List[float], s: float, delta: float) -> float:
    """Sum of (diam U_n)^s for the cover U_n = interval of width delta*2^{-n}."""
    return sum((delta * 2.0 ** (-n)) ** s for n in range(len(points)))


def demo_hausdorff_zero(primes: List[int]) -> None:
    print("=" * 74)
    print("3. HAUSDORFF DIMENSION THEOREM:  dim_H = 0  (countability)")
    print("=" * 74)
    points = [iota(p) for p in primes[:4000]]
    print("   Enumerate the points and cover the n-th one by an interval of")
    print("   width delta * 2^-n.  The total s-cost is then at most")
    print("   delta^s * sum_n 2^{-ns} = delta^s / (2^s - 1), which tends to 0 as")
    print("   delta -> 0 for EVERY exponent s > 0 -- only the speed depends on s.\n")
    print(f"   {'s':>8} {'cost at delta=1e-3':>20} {'delta needed for cost<1e-3':>28} "
          f"{'cost there':>12}")
    for s in (1.0, 0.5, 0.2, 0.1):
        cost_ref = hausdorff_cover_cost(points, s, 1e-3)
        # delta^s/(2^s - 1) < 1e-3  <=>  delta < (1e-3 (2^s - 1))^(1/s)
        delta_needed = (1e-3 * (2.0**s - 1.0)) ** (1.0 / s)
        cost_there = hausdorff_cover_cost(points, s, delta_needed)
        print(f"   {s:>8.2f} {cost_ref:>20.3e} {delta_needed:>28.3e} "
              f"{cost_there:>12.3e}")
    print("\n   For every s > 0 a small enough delta makes the s-cost as small as we")
    print("   like, so H^s = 0 for all s > 0 and the Hausdorff dimension is 0.")
    print("   Nothing arithmetic was used: the same argument applies to the twin")
    print("   primes, or to any subfamily of primes whatsoever.\n")


# ----------------------------------------------------------------------------
# 4.  Isolation: every point of the prime fractal is isolated
# ----------------------------------------------------------------------------


def demo_isolation(primes: List[int]) -> None:
    print("=" * 74)
    print("4. ISOLATION THEOREM:  no dust -- every point is isolated")
    print("=" * 74)
    print("   Nearest-neighbour gap around iota(p), and the count of primes")
    print("   lying above height t (all of them have p <= exp(1/t)).\n")
    print(f"   {'p':>10} {'iota(p)':>12} {'gap to neighbour':>18} "
          f"{'#primes above iota(p)':>22}")
    for p in (2, 3, 101, 1009, 100003):
        idx = primes.index(p)
        gap = min(d_metric(p, primes[idx - 1]) if idx > 0 else float("inf"),
                  d_metric(p, primes[idx + 1]))
        above = sum(1 for q in primes if iota(q) >= iota(p))
        print(f"   {p:>10} {iota(p):>12.8f} {gap:>18.3e} {above:>22}")
    print("\n   Gaps are strictly positive at every point, and only finitely many")
    print("   points lie above any positive height.  The single accumulation")
    print("   point is 0, and infinitely many twin primes is exactly the")
    print("   statement that 0 lies in the closure of the twin subfractal.\n")


# ----------------------------------------------------------------------------
# 5.  Box counting:  N(m) with the head/tail split, and the dimension 1
# ----------------------------------------------------------------------------


def head_indices(m: int, primes: List[int]) -> Set[int]:
    """Exact set of occupied box indices coming from the sieved primes p <= X."""
    return {box_index(m, p) for p in primes}


def tail_index_count(m: int, sieve_limit: int) -> int:
    """
    Number of occupied indices k for which the defining interval
        I_k = (exp(m/(k+1)), exp(m/k)]
    reaches beyond the sieve limit X.  Index k = 0 (primes p > e^m) is always
    occupied.  For 1 <= k < m/log X the interval has ratio exp(m/(k(k+1))),
    astronomically wide, and the Prime Number Theorem estimate for the number
    of primes it contains is enormous, so it is occupied.
    """
    if sieve_limit < 3:
        return 0
    k_max = int(math.floor(m / math.log(sieve_limit)))
    return k_max + 1  # indices 0, 1, ..., k_max


def box_count(m: int, primes: List[int]) -> int:
    """
    N(m): number of boxes of width 1/m meeting the prime fractal.

    Head (exact, from sieved primes) union tail (predicted occupied).
    """
    sieve_limit = primes[-1]
    occupied = head_indices(m, primes)
    k_max = int(math.floor(m / math.log(sieve_limit)))
    occupied.update(range(0, k_max + 1))
    return len(occupied)


def int_box_count(m: int, limit: int) -> int:
    """Box count of the integer fractal {1/log n : n >= 2} with the same split."""
    occupied = {box_index(m, n) for n in range(2, limit + 1)}
    k_max = int(math.floor(m / math.log(limit)))
    occupied.update(range(0, k_max + 1))
    return len(occupied)


def demo_box_dimension(primes: List[int]) -> None:
    print("=" * 74)
    print("5. BOX DIMENSION THEOREM:  log N(m) / log m  ->  1")
    print("=" * 74)
    print("   N(m) = #{ floor(m / log p) : p prime }, boxes of width 1/m.")
    print("   Proved bracket:   m / (16 (log m)^4)  <=  N(m)  <=  5 m / log m.\n")
    print(f"   {'m':>10} {'N(m)':>10} {'log N/log m':>13} {'N log m / m':>13} "
          f"{'lower bd':>11} {'upper bd':>11} {'1-loglog/log':>13}")
    for m in (10, 100, 1000, 10_000, 100_000, 1_000_000):
        n_m = box_count(m, primes)
        logm = math.log(m)
        ratio = math.log(n_m) / logm
        normalised = n_m * logm / m
        lower = m / (16 * logm**4)
        upper = 5 * m / logm
        predicted = 1 - math.log(logm) / logm
        print(f"   {m:>10} {n_m:>10} {ratio:>13.5f} {normalised:>13.5f} "
              f"{lower:>11.1f} {upper:>11.1f} {predicted:>13.5f}")
    print("\n   * log N(m)/log m creeps toward 1 at the theoretical rate")
    print("     1 - log log m / log m  (rightmost column) -- a measurement of")
    print("     0.86 is NOT a dimension of 0.86, it is 1 minus a log log defect.")
    print("   * N(m) log m / m stays in a narrow band and drifts down toward the")
    print("     conjectured limit 1: zero one-dimensional Minkowski content,")
    print("     since N(m)/m -> 0.\n")


# ----------------------------------------------------------------------------
# 6.  Separation and the Chebyshev input behind the lower bound
# ----------------------------------------------------------------------------


def separation_is_injective(m: int, y: int, primes: List[int]) -> Tuple[bool, int]:
    """Check that p -> floor(m/log p) is injective on primes p <= y."""
    indices = [box_index(m, p) for p in primes if p <= y]
    return len(indices) == len(set(indices)), len(indices)


def demo_separation_and_chebyshev(primes: List[int]) -> None:
    print("=" * 74)
    print("6. SEPARATION + CHEBYSHEV:  the arithmetic behind the lower bound")
    print("=" * 74)
    print("   Box Separation Theorem: if 2 Y (log Y)^2 <= m then distinct primes")
    print("   p <= Y occupy distinct boxes of width 1/m, so N(m) >= pi(Y).\n")
    print(f"   {'Y':>8} {'required m':>14} {'injective?':>12} {'pi(Y)':>8} "
          f"{'Y/(8 log Y)':>13}")
    for y in (10, 100, 1000, 10_000, 100_000):
        need_m = int(math.ceil(2 * y * math.log(y) ** 2))
        ok, count = separation_is_injective(need_m, y, primes)
        chebyshev = y / (8 * math.log(y))
        print(f"   {y:>8} {need_m:>14} {str(ok):>12} {count:>8} {chebyshev:>13.2f}")
    print("\n   Chebyshev-type lower bound  pi(n) >= n / (8 log n)  for n >= 8:")
    print(f"   {'n':>10} {'pi(n)':>10} {'n/(8 log n)':>14} {'slack factor':>14}")
    for n in (10, 100, 1000, 10_000, 100_000, 1_000_000):
        pi_n = sum(1 for p in primes if p <= n)
        bound = n / (8 * math.log(n))
        print(f"   {n:>10} {pi_n:>10} {bound:>14.2f} {pi_n / bound:>14.2f}")
    print("\n   Choosing Y = m / (log m)^3 -- the largest the separation allows --")
    print("   gives N(m) >= pi(Y) >= m / (16 (log m)^4), which is enough for the")
    print("   dimension, the constants being invisible on a logarithmic scale.\n")


# ----------------------------------------------------------------------------
# 7.  Dimension blindness: primes versus all integers
# ----------------------------------------------------------------------------


def demo_dimension_blindness(primes: List[int]) -> None:
    print("=" * 74)
    print("7. DIMENSION BLINDNESS:  primes and integers give the same dimensions")
    print("=" * 74)
    limit = 200_000
    print(f"   Integer fractal built from n = 2..{limit}, prime fractal from")
    print(f"   primes up to {primes[-1]}.\n")
    print(f"   {'m':>10} {'N_primes(m)':>13} {'N_integers(m)':>15} "
          f"{'log ratio primes':>18} {'log ratio integers':>20}")
    small_primes = [p for p in primes if p <= limit]
    for m in (100, 1000, 10_000, 100_000):
        n_p = box_count(m, small_primes)
        n_i = int_box_count(m, limit)
        logm = math.log(m)
        print(f"   {m:>10} {n_p:>13} {n_i:>15} {math.log(n_p)/logm:>18.5f} "
              f"{math.log(n_i)/logm:>20.5f}")
    print("\n   Both columns of ratios converge to 1, and both sets are countable")
    print("   so both have Hausdorff dimension 0.  No dimension of the")
    print("   logarithmic lens distinguishes the primes from all the integers;")
    print("   a fortiori none can encode the twin prime conjecture.  The")
    print("   difference is only second order: N(m) ~ m/log m for the primes")
    print("   against ~ m for the integers.\n")


# ----------------------------------------------------------------------------
# main
# ----------------------------------------------------------------------------


def main() -> None:
    sieve_limit = 1_000_000
    print("\nBuilding a sieve of primes up to", f"{sieve_limit:,}", "...\n")
    primes = sieve_primes(sieve_limit)
    print(f"pi({sieve_limit:,}) = {len(primes):,}\n")

    demo_total_length(primes)
    demo_twin_scale(primes)
    demo_hausdorff_zero(primes)
    demo_isolation(primes)
    demo_box_dimension(primes)
    demo_separation_and_chebyshev(primes)
    demo_dimension_blindness(primes)

    print("=" * 74)
    print("SUMMARY")
    print("=" * 74)
    print("   Hausdorff dimension of the prime fractal ............ 0")
    print("   box-counting dimension .............................. 1 (exactly)")
    print("   one-dimensional Minkowski content ................... 0")
    print(f"   total d-length of the primes ........................ 1/log 2 = "
          f"{1/math.log(2):.9f}")
    print("   twin scale .......................................... <= 2/(p log^2 p)")
    print("   same two dimensions for all integers >= 2 ........... yes")
    print("   => the conjecture 'dimension = 1 + eps(twin primes)' is impossible.")
    print()


if __name__ == "__main__":
    main()
