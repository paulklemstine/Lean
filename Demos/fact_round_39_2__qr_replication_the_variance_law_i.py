#!/usr/bin/env python3
"""
Seed-robustness of the quadratic-residue variance law -- numerical companion.

Every identity below is checked by exhaustive enumeration over small moduli,
followed by a Monte-Carlo illustration of seed drift.

Notation
--------
* M = p_1 ... p_k, a product of distinct odd primes; G = (Z/M)^x, phi = |G|.
* r_M(N) = #{x mod M : x^2 = N}  (local square-root count / local divisibility rate).
* t = #{y in G : y^2 = 1} = 2^k (the 2-torsion of G).
* f = r - 1 is the centred QR score; a "seed" is a tuple of n uniform draws from G
  and S(x) = sum_i f(x_i) is its sample sum.

Pure standard library; runs in a few seconds.
"""
from __future__ import annotations

import itertools
import math
import random
from typing import Callable, Dict, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Basic arithmetic
# ---------------------------------------------------------------------------

def units(m: int) -> List[int]:
    """Residues mod m that are coprime to m."""
    return [a for a in range(1, m) if math.gcd(a, m) == 1] if m > 1 else [0]


def root_count_table(m: int) -> Dict[int, int]:
    """r_m(N) = #{x mod m : x^2 = N mod m}, tabulated for every unit N."""
    counts: Dict[int, int] = {n: 0 for n in units(m)}
    for x in range(m):
        s = (x * x) % m
        if s in counts:
            counts[s] += 1
    return counts


def legendre(a: int, p: int) -> int:
    """Legendre symbol via Euler's criterion a^((p-1)/2) mod p."""
    v = pow(a % p, (p - 1) // 2, p)
    return -1 if v == p - 1 else v


def two_torsion(m: int) -> int:
    """t = #{y in (Z/m)^x : y^2 = 1}."""
    return sum(1 for y in units(m) if (y * y) % m == 1)


# ---------------------------------------------------------------------------
# 1. The population law: mean 1, variance t - 1 = 2^k - 1
# ---------------------------------------------------------------------------

def population_law(m: int) -> Tuple[int, int, int, int]:
    """Return (phi, sum of (r-1), sum of (r-1)^2, t) over the units mod m."""
    r = root_count_table(m)
    phi = len(r)
    s1 = sum(v - 1 for v in r.values())
    s2 = sum((v - 1) ** 2 for v in r.values())
    return phi, s1, s2, two_torsion(m)


def demo_population_law() -> None:
    print("=" * 76)
    print("1. Population law over the units mod M:  mean r = 1,  Var r = 2^k - 1")
    print("=" * 76)
    print(f"{'M':>6} {'k':>2} {'phi':>5} {'sum(r-1)':>9} {'sum(r-1)^2':>11} "
          f"{'phi(2^k-1)':>11} {'t':>3}")
    for m, k in [(7, 1), (15, 2), (105, 3), (1155, 4), (15015, 5)]:
        phi, s1, s2, t = population_law(m)
        assert s1 == 0 and s2 == phi * (2 ** k - 1) and t == 2 ** k
        print(f"{m:>6} {k:>2} {phi:>5} {s1:>9} {s2:>11} {phi * (2 ** k - 1):>11} {t:>3}")
    print("   -> the QR restriction never moves the mean; it only creates variance.\n")


# ---------------------------------------------------------------------------
# 2. The replication layer: exact seed identities by full enumeration
# ---------------------------------------------------------------------------

def seed_moments(m: int, n: int) -> Tuple[int, int, int, int, int]:
    """
    Enumerate all phi^n seeds of length n from (Z/m)^x.
    Returns (phi, sum S, sum S^2, sum over seed pairs (S_x - S_y)^2,
             sum of the plug-in variance statistic n*sum f^2 - S^2).
    """
    r = root_count_table(m)
    f_vals = [v - 1 for v in r.values()]
    phi = len(f_vals)
    sums: List[int] = []
    plug: List[int] = []
    for seed in itertools.product(f_vals, repeat=n):
        s = sum(seed)
        sums.append(s)
        plug.append(n * sum(v * v for v in seed) - s * s)
    total = sum(sums)
    total_sq = sum(s * s for s in sums)
    # pair drift computed directly (O(phi^(2n)), fine for tiny cases)
    if phi ** (2 * n) <= 2_000_000:
        drift = sum((a - b) ** 2 for a in sums for b in sums)
    else:  # use the expansion, which is an identity of finite sums
        drift = 2 * len(sums) * total_sq - 2 * total * total
    return phi, total, total_sq, drift, sum(plug)


def demo_replication_law() -> None:
    print("=" * 76)
    print("2. Replication law (exhaustive over all seeds of length n)")
    print("   sum S = 0,  sum S^2 = n phi^n (t-1),  sum (Sx-Sy)^2 = 2 n phi^(2n) (t-1)")
    print("   Bessel:  sum (n sum f^2 - S^2) = n (n-1) phi^n (t-1)")
    print("=" * 76)
    for m, n in [(7, 2), (7, 3), (15, 2), (15, 3), (105, 2), (21, 3)]:
        phi, s1, s2, d, pv = seed_moments(m, n)
        t = two_torsion(m)
        pred2 = n * phi ** n * (t - 1)
        predd = 2 * n * phi ** (2 * n) * (t - 1)
        predv = n * (n - 1) * phi ** n * (t - 1)
        assert s1 == 0 and s2 == pred2 and d == predd and pv == predv
        print(f"   M={m:>3} n={n}: sum S={s1}, sum S^2={s2} (= {pred2}), "
              f"drift={d} (= {predd}), plug-in={pv} (= {predv})")
    print("   -> mean squared drift of two sample MEANS = 2 (t - 1) / n exactly.\n")


# ---------------------------------------------------------------------------
# 3. The k-prime Euler-criterion score via the CRT
# ---------------------------------------------------------------------------

def euler_score_moments(primes: Sequence[int], weights: Sequence[int]) -> Tuple[int, int, int]:
    """
    Over all units N mod M = prod p_i, compute
    (phi(M), sum_N S(N), sum_N (S(N) - sum w)^2) for
    S(N) = sum_i w_i r_{p_i}(N mod p_i), with r_p(N) = 1 + (N/p).
    """
    m = math.prod(primes)
    sw = sum(weights)
    tot = 0
    tot_sq = 0
    us = units(m)
    for nres in us:
        s = sum(w * (1 + legendre(nres, p)) for p, w in zip(primes, weights))
        tot += s
        tot_sq += (s - sw) ** 2
    return len(us), tot, tot_sq


def demo_multi_prime_score() -> None:
    print("=" * 76)
    print("3. k-prime Euler score  S(N) = sum_i w_i r_{p_i}(N):  mean sum w,  var sum w^2")
    print("=" * 76)
    cases = [((3, 5), (1, 1)), ((3, 5), (2, -1)), ((3, 5, 7), (1, 1, 1)),
             ((3, 5, 7, 11), (3, 1, -2, 5)), ((5, 7, 11, 13), (1, 1, 1, 1)),
             ((3, 7, 11, 13, 17), (1, 2, 3, 4, 5))]
    for primes, w in cases:
        phi, tot, tot_sq = euler_score_moments(primes, w)
        assert tot == phi * sum(w) and tot_sq == phi * sum(x * x for x in w)
        print(f"   p={str(primes):<20} w={str(w):<18} mean={tot / phi:>5.1f} "
              f"(sum w={sum(w)})  var={tot_sq / phi:>5.1f} (sum w^2={sum(x*x for x in w)})")
    print("   -> unweighted count: mean k, variance k (no cross terms between primes).\n")


# ---------------------------------------------------------------------------
# 4. Chebyshev tail for seed drift
# ---------------------------------------------------------------------------

def demo_chebyshev(m: int = 15, n: int = 3) -> None:
    print("=" * 76)
    print(f"4. Drift tail bound (M={m}, n={n}):  #{{|Sx-Sy| >= c}} c^2 <= 2 n phi^(2n)(t-1)")
    print("=" * 76)
    r = root_count_table(m)
    f_vals = [v - 1 for v in r.values()]
    phi, t = len(f_vals), two_torsion(m)
    sums = [sum(s) for s in itertools.product(f_vals, repeat=n)]
    hist: Dict[int, int] = {}
    for s in sums:
        hist[s] = hist.get(s, 0) + 1
    pairs = phi ** (2 * n)
    for c in [2, 4, 6, 8, 10, 12]:
        cnt = sum(ha * hb for a, ha in hist.items() for b, hb in hist.items()
                  if (a - b) ** 2 >= c * c)
        bound = min(1.0, 2 * n * (t - 1) / c ** 2)
        assert cnt * c * c <= 2 * n * pairs * (t - 1)
        print(f"   c={c:>2}: exact fraction {cnt / pairs:.4f}   Chebyshev bound {bound:.4f}")
    print()


# ---------------------------------------------------------------------------
# 5. Monte-Carlo: two seeds, same law
# ---------------------------------------------------------------------------

def monte_carlo_mean(m: int, n: int, seed: int) -> float:
    rng = random.Random(seed)
    r = root_count_table(m)
    keys = list(r.keys())
    return sum(r[rng.choice(keys)] for _ in range(n)) / n


def demo_two_seeds() -> None:
    print("=" * 76)
    print("5. Two seeds (20260821 vs 20260826): sample mean of r_M and predicted drift")
    print("=" * 76)
    for m in [105, 1155, 15015]:
        t = two_torsion(m)
        for n in [1_000, 100_000]:
            a = monte_carlo_mean(m, n, 20260821)
            b = monte_carlo_mean(m, n, 20260826)
            rms = math.sqrt(2 * (t - 1) / n)
            print(f"   M={m:>5} t={t:>2} n={n:>6}: mean_A={a:.4f} mean_B={b:.4f} "
                  f"|drift|={abs(a - b):.4f}  predicted RMS drift={rms:.4f}")
    print("   -> both seeds center on 1; drift is of the size the variance law predicts.\n")


# ---------------------------------------------------------------------------
# 6. Square-relabelling symmetry and the (conjectural) fourth moment
# ---------------------------------------------------------------------------

def demo_symmetry_and_fourth_moment() -> None:
    print("=" * 76)
    print("6. r(y^2 g) = r(g); and a numerical look at the fourth-moment conjecture")
    print("=" * 76)
    for m in [15, 105]:
        r = root_count_table(m)
        assert all(r[(y * y * g) % m] == r[g] for y in r for g in r)
        print(f"   M={m}: root count invariant under multiplication by every square. OK")
    for m, n in [(7, 2), (15, 2), (15, 3), (21, 3), (105, 2)]:
        f_vals = [v - 1 for v in root_count_table(m).values()]
        phi, t = len(f_vals), two_torsion(m)
        s4 = sum(sum(s) ** 4 for s in itertools.product(f_vals, repeat=n))
        pred = n * phi ** n * (t - 1) * (t * t - 3 * t + 3) + 3 * n * (n - 1) * phi ** n * (t - 1) ** 2
        print(f"   M={m:>3} n={n}: sum S^4 = {s4}, conjectured formula = {pred}, match={s4 == pred}")
    print("   (fourth moment is an open direction; these are numerical checks only)\n")


if __name__ == "__main__":
    demo_population_law()
    demo_replication_law()
    demo_multi_prime_score()
    demo_chebyshev()
    demo_two_seeds()
    demo_symmetry_and_fourth_moment()
    print("All exact identities verified by enumeration.")
