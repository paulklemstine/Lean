"""
demo.py — Numerical demonstration of the stage-one firing trace law.

This script is a fully self-contained numerical companion to the theory of the
*firing trace* of the first stage of the elliptic-curve factorization method.

Background in one paragraph
---------------------------
Stage one of the elliptic-curve method walks through the primes
p_1 < p_2 < ... < p_{pi(B1)} up to a bound B1, and after each prime multiplies
an accumulating scalar by p^{floor(log_p B1)}.  Writing

    K(B1, y) = prod_{p <= y} p^{floor(log_p B1)},

the run "fires" for a point of order n at the first schedule position y where
n divides K(B1, y).  The *trace law* says that for any order n dividing the full
multiplier K(B1, B1),

    n | K(B1, y)   <==>   P+(n) <= y,

where P+(n) is the largest prime factor of n.  So the firing threshold equals
P+(n) exactly, and the *normalized firing index* is pi(P+(n)) / pi(B1).

Because a typical integer has a small largest prime factor relative to its own
size (Dickman/Golomb statistics), the firing index piles up near 0 and the late
tail of the schedule is almost empty.  This is the structural reason a
pre-registered hypothesis predicting a *uniform* firing index, or a firing index
concentrated in the final 20% of the schedule, is refuted by data.

What this script demonstrates
-----------------------------
 1. Direct verification of the trace law on all divisors of K(B1, B1).
 2. The empirical firing-index distribution for uniform orders in (0, N],
    for N = 10^3 ... 10^6, reproducing medians 0.083 -> 0.005 and a final-20%
    tail decaying 3.4% -> 1.5%.
 3. The exact late-tail count at B1 = 100 with the schedule cut at y = 67:
    exactly 330 of the 4489 integers in (0, 67^2] fire in the last six of the
    25 schedule steps (7.35%), versus the 20% a uniform law demands.
 4. The competing *divisor* null model: the number of divisors of K(B1) splits
    as tau(K_y) times prod_{y < p <= B1} (floor(log_p B1) + 1); at B1 = 100,
    y = 67 that factor is 64, so the divisor model puts 63/64 ~ 98% of its mass
    in exactly the window the integer model caps at 8%.
 5. The likelihood of the observed empty tail (0 hits out of 55) under the two
    laws, and the resulting likelihood ratio (> 1000 in favour of the
    structural law).
 6. The collision-baseline side: the Bernoulli ceiling 1 - (1 - 1/p)^k <= k/p,
    its scale freedom in the ratio k/p, and the pigeonhole lower bound on the
    number of genuine order-hits in a batch of curves.
 7. The unconditional asymptotic bound: the late-firing density is at most
    2*B1 / (y * floor(log2 y)), hence O(1 / log B1) for a cut proportional
    to B1 -- no constant-fraction late tail can survive.

Run with:  python3 demo.py
No third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1. Elementary sieves
# ----------------------------------------------------------------------------


def primes_up_to(n: int) -> List[int]:
    """All primes p <= n, by a simple sieve of Eratosthenes.  O(n log log n)."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(n**0.5) + 1):
        if sieve[p]:
            sieve[p * p :: p] = bytearray(len(sieve[p * p :: p]))
    return [i for i in range(n + 1) if sieve[i]]


def largest_prime_factor_table(n: int) -> List[int]:
    """largest_prime_factor_table(n)[m] = P+(m), the largest prime factor of m.

    Entries for m = 0 and m = 1 are 0 by convention.  Computed by sweeping each
    prime p over its multiples, so the last prime written for m is the largest.
    Cost O(n log log n) time, O(n) memory.
    """
    lpf = [0] * (n + 1)
    for p in range(2, n + 1):
        if lpf[p] == 0:  # p is prime
            for multiple in range(p, n + 1, p):
                lpf[multiple] = p
    return lpf


def prime_counting(n: int, primes: Sequence[int]) -> int:
    """pi(n), given a sorted list of primes covering [0, n]."""
    lo, hi = 0, len(primes)
    while lo < hi:
        mid = (lo + hi) // 2
        if primes[mid] <= n:
            lo = mid + 1
        else:
            hi = mid
    return lo


# ----------------------------------------------------------------------------
# 2. The stage-one schedule
# ----------------------------------------------------------------------------


def stage_product(b1: int, y: int) -> int:
    """K(B1, y) = prod_{p <= y} p^{floor(log_p B1)}: the accumulated scalar
    after the stage-one schedule has consumed every prime up to y."""
    result = 1
    for p in primes_up_to(min(y, b1)):
        exponent = int(math.log(b1) / math.log(p) + 1e-12)
        result *= p**exponent
    return result


def max_prime_factor(n: int) -> int:
    """P+(n) by trial division; 0 for n in {0, 1}."""
    if n <= 1:
        return 0
    best, m, d = 1, n, 2
    while d * d <= m:
        while m % d == 0:
            best, m = d, m // d
        d += 1
    return max(best, m)


def stage_exponents(b1: int, y: int) -> Dict[int, int]:
    """The exponent vector of K(B1, y): p -> floor(log_p B1) for each p <= y."""
    return {p: int(math.log(b1) / math.log(p) + 1e-12)
            for p in primes_up_to(min(y, b1))}


def divisor_count(exponents: Dict[int, int]) -> int:
    """tau of a number given as a prime-exponent vector: prod (e_p + 1)."""
    total = 1
    for exponent in exponents.values():
        total *= exponent + 1
    return total


def divisors_with_max_prime(exponents: Dict[int, int]) -> Iterable[Tuple[int, int]]:
    """Enumerate every divisor of the number with the given prime-exponent
    vector, together with its largest prime factor (0 for the divisor 1).
    Enumerating from the exponent vector avoids any factorization work."""
    items: List[Tuple[int, int]] = sorted(exponents.items())

    def walk(index: int, value: int, mpf: int) -> Iterable[Tuple[int, int]]:
        if index == len(items):
            yield value, mpf
            return
        p, e = items[index]
        power = 1
        for exponent in range(e + 1):
            yield from walk(index + 1, value * power,
                            p if exponent > 0 else mpf)
            power *= p

    return walk(0, 1, 0)


# ----------------------------------------------------------------------------
# 3. Demonstration blocks
# ----------------------------------------------------------------------------


def verify_trace_law(b1: int = 30) -> Tuple[int, int]:
    """Check `n | K(B1,y) <==> P+(n) <= y` on every divisor n of K(B1,B1) and
    every schedule cut y.  Returns (checks_done, failures)."""
    cuts: List[int] = [0] + primes_up_to(b1)
    partial: Dict[int, int] = {y: stage_product(b1, y) for y in cuts}
    checks = 0
    failures = 0
    for n, mpf in divisors_with_max_prime(stage_exponents(b1, b1)):
        for y in cuts:
            lhs = partial[y] % n == 0
            rhs = mpf <= y
            checks += 1
            if lhs != rhs:
                failures += 1
    return checks, failures


def firing_index_statistics(n_max: int) -> Dict[str, float]:
    """Empirical distribution of the normalized firing index
    pi(P+(n)) / pi(N) for n uniform in (0, N], with the stage-one bound
    B1 = N.  Returns median, mean, final-20% tail mass and first-20% mass."""
    primes = primes_up_to(n_max)
    lpf = largest_prime_factor_table(n_max)
    total_steps = len(primes)
    # rank[p] = pi(p) for prime p; built once
    rank: Dict[int, int] = {p: i + 1 for i, p in enumerate(primes)}
    indices: List[float] = []
    for n in range(2, n_max + 1):
        indices.append(rank[lpf[n]] / total_steps)
    indices.sort()
    count = len(indices)
    median = indices[count // 2]
    mean = sum(indices) / count
    tail = sum(1 for x in indices if x > 0.8) / count
    head = sum(1 for x in indices if x <= 0.2) / count
    return {
        "N": float(n_max),
        "steps": float(total_steps),
        "median": median,
        "mean": mean,
        "final_20pct_mass": tail,
        "first_20pct_mass": head,
    }


def exact_late_tail(m: int, b1: int, y: int) -> int:
    """Exact number of integers n in (0, M] whose firing position exceeds y,
    i.e. that are divisible by some prime in (y, B1].  For M <= y^2 no integer
    can carry two such primes, so this equals sum_{y < p <= B1} floor(M/p)."""
    late_primes = [p for p in primes_up_to(b1) if p > y]
    return sum(m // p for p in late_primes)


def divisor_model_late_factor(b1: int, y: int) -> int:
    """prod_{y < p <= B1} (floor(log_p B1) + 1): the exact factor by which the
    divisor count of the full stage-one multiplier exceeds that of the partial
    product at cut y.  The divisor model therefore fires *late* with
    probability 1 - 1/factor."""
    factor = 1
    for p in primes_up_to(b1):
        if p > y:
            factor *= int(math.log(b1) / math.log(p) + 1e-12) + 1
    return factor


def collision_probability(p: int, k: int) -> float:
    """1 - (1 - 1/p)^k: the chance that k guarded group operations modulo p
    accidentally hit a multiple of p, independently of the point's order.
    Evaluated as -expm1(k * log1p(-1/p)) so it stays accurate for huge p."""
    return -math.expm1(k * math.log1p(-1.0 / p))


def late_density_log_bound(b1: int, y: int) -> float:
    """The unconditional structural cap 2*B1 / (y * floor(log2 y)) on the
    fraction of orders that can fire after schedule position y."""
    return 2.0 * b1 / (y * math.floor(math.log2(y)))


# ----------------------------------------------------------------------------
# 4. Driver
# ----------------------------------------------------------------------------


def banner(text: str) -> None:
    print()
    print("=" * 78)
    print(text)
    print("=" * 78)


def main() -> None:
    banner("1.  THE TRACE LAW:  n | K(B1, y)  <==>  P+(n) <= y")
    for b1 in (12, 20, 30):
        checks, failures = verify_trace_law(b1)
        print(f"  B1 = {b1:>3}:  {checks:>6} (divisor, cut) pairs checked, "
              f"{failures} violations")
    print("  The firing moment of a stage-one reachable order depends on nothing")
    print("  except its largest prime factor.")

    banner("2.  THE FIRING INDEX PILES UP NEAR ZERO")
    print(f"  {'N':>9} {'steps':>7} {'median':>9} {'mean':>9} "
          f"{'final 20%':>10} {'first 20%':>10}")
    for exponent in (3, 4, 5, 6):
        stats = firing_index_statistics(10**exponent)
        print(f"  {int(stats['N']):>9} {int(stats['steps']):>7} "
              f"{stats['median']:>9.3f} {stats['mean']:>9.3f} "
              f"{stats['final_20pct_mass']:>10.3f} "
              f"{stats['first_20pct_mass']:>10.3f}")
    print("  A uniform firing index would print 0.500 / 0.500 / 0.200 / 0.200.")
    print("  Instead the median collapses toward 0 and the late tail decays.")

    banner("3.  THE EXACT LATE TAIL AT B1 = 100, CUT AT y = 67")
    late = exact_late_tail(4489, 100, 67)
    print(f"  Late schedule primes (last six of the 25 steps): "
          f"{[p for p in primes_up_to(100) if p > 67]}")
    print(f"  Integers in (0, 67^2 = 4489] that fire in that window: {late}")
    print(f"  Density = {late}/4489 = {late / 4489:.4f}")
    print(f"  Reciprocal cap  sum_{{67<p<=100}} 1/p = "
          f"{sum(1 / p for p in primes_up_to(100) if p > 67):.4f} < 2/25 = 0.08")
    print("  Uniformity over the final 24% of the schedule would demand ~0.24.")

    banner("4.  THE COMPETING DIVISOR NULL MODEL FIRES *LATE*")
    factor = divisor_model_late_factor(100, 67)
    full_tau = divisor_count(stage_exponents(100, 100))
    part_tau = divisor_count(stage_exponents(100, 67))
    print(f"  tau(K(100,100)) = {full_tau},  tau(K(100,67)) = {part_tau}")
    print(f"  ratio = {full_tau // part_tau}, predicted factor "
          f"prod_(67<p<=100)(floor(log_p 100)+1) = {factor}")
    print(f"  Divisor model late mass  = {1 - 1 / factor:.4f}  (~98%)")
    print(f"  Integer model late cap   = {2 / 25:.4f}  (8%)")
    print("  The two null models differ by more than a factor of twelve on the")
    print("  very quantity the experiment measured.")

    banner("5.  LIKELIHOOD OF THE OBSERVED EMPTY TAIL (0 hits out of 55)")
    uniform_likelihood = (4 / 5) ** 55
    structural_likelihood = (23 / 25) ** 55
    print(f"  Under the pre-registered uniform law (tail = 20%):   "
          f"{uniform_likelihood:.3e}")
    print(f"  Under the structural cap (tail <= 8%):               "
          f"{structural_likelihood:.3e}")
    print(f"  Likelihood ratio: {structural_likelihood / uniform_likelihood:.1f} "
          f"in favour of the structural law")
    print(f"  Under the divisor model (tail = 63/64):              "
          f"{(1 / 64) ** 55:.3e}  (annihilated)")

    banner("6.  THE COLLISION BASELINE IS A CEILING, AND IT IS SCALE FREE")
    print(f"  {'bit length':>11} {'p (approx)':>14} {'k = 2.59*B1':>14} "
          f"{'1-(1-1/p)^k':>13} {'ceiling k/p':>12}")
    for bits in (26, 32, 48, 64):
        p = 2 ** (bits - 1) + 1
        b1 = int(0.125 * p)
        k = int(2.59 * b1)
        print(f"  {bits:>11} {p:>14} {k:>14} "
              f"{collision_probability(p, k):>13.4f} {k / p:>12.4f}")
    print("  The ceiling depends only on the ratio k/p, so it does NOT decay with")
    print("  bit length: a collision-dominated account cannot predict a collapse.")
    print("  Measured success rates: 65.0% (bitlen 26) and 62.5% (bitlen 32),")
    print("  against a ceiling of 0.324 -- an excess of about 0.30.")

    banner("7.  PIGEONHOLE: GENUINE ORDER-HITS MUST EXIST")
    successes, curves = 25, 40
    max_collisions = math.floor(0.324 * curves)
    print(f"  Cell: {curves} curves, {successes} successes.")
    print(f"  At most floor(0.324 * {curves}) = {max_collisions} can be collisions.")
    print(f"  Hence at least {successes - max_collisions} successes are genuine "
          f"order-hits.")

    banner("8.  THE LATE TAIL VANISHES AS B1 GROWS (UNCONDITIONAL BOUND)")
    print(f"  {'B1':>10} {'cut y = B1/2':>13} {'cap 2B1/(y log2 y)':>21} "
          f"{'4/log2 y':>11}")
    for exponent in (10, 14, 20, 26, 32):
        b1 = 2**exponent
        y = 2 ** (exponent - 1)
        print(f"  {b1:>10} {y:>13} {late_density_log_bound(b1, y):>21.4f} "
              f"{4 / math.floor(math.log2(y)):>11.4f}")
    print("  A constant-fraction (20%) late tail is impossible for large B1.")

    banner("9.  MERTENS HEURISTIC FOR THE TAIL")
    print("  Conjecture: the mass firing in the final fraction tau of the")
    print("  schedule is  log(1/(1-tau)) / log(B1) * (1 + o(1)).")
    print(f"  {'B1':>10} {'predicted tail(0.2)':>21} {'measured':>10}")
    measured = {1000: 0.034, 10000: 0.024, 100000: 0.019, 1000000: 0.015}
    for b1, obs in measured.items():
        predicted = math.log(1 / 0.8) / math.log(b1)
        print(f"  {b1:>10} {predicted:>21.4f} {obs:>10.4f}")


if __name__ == "__main__":
    main()
