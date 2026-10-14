#!/usr/bin/env python3
"""
The divisibility-covering frontier: numerical companion.

A pair of finite sets S, T of non-negative integers is a *divisibility covering*
of [n] = {1, ..., n} if every i in [n] divides some positive difference s - t
with s in S, t in T and t < s.  This script illustrates, on concrete numbers:

  1. the block-product ("trivial", one-sided) covering with T = {0};
  2. the counting wall   4^k <= 2k * M^(|S||T|)   for coverings of [2k];
  3. the divisibility chain  C(2k,k) | lcm(1..2k) | prod (s - t);
  4. the exponent constraint alpha + beta_S + beta_T >= 1 and the sandwich
     at beta = 1/3 (feasible region: alpha >= 1/3 forced, alpha > 2/3 achieved);
  5. the alpha-unit trap: ln ln M / ln n versus ln M / ln n;
  6. the large-prime budget  y^(pi(n) - pi(y)) <= M^(|S||T|);
  7. the disjointness guard (S = T = {a} "covers" everything vacuously);
  8. a small greedy search showing how far unstructured coverings fall short.

Only the Python standard library is used.
"""
from __future__ import annotations

import math
import random
from functools import reduce
from typing import Iterable


# ---------------------------------------------------------------------------
# Basic objects
# ---------------------------------------------------------------------------

def is_div_cover(n: int, S: Iterable[int], T: Iterable[int]) -> bool:
    """True iff every i in [1, n] divides some s - t with s in S, t in T, t < s."""
    diffs = [s - t for s in S for t in T if t < s]
    return all(any(d % i == 0 for d in diffs) for i in range(1, n + 1))


def coverage(n: int, S: Iterable[int], T: Iterable[int]) -> float:
    """Fraction of i in [1, n] dividing at least one positive difference."""
    diffs = [s - t for s in S for t in T if t < s]
    hit = sum(1 for i in range(1, n + 1) if any(d % i == 0 for d in diffs))
    return hit / n


def lcm_up_to(n: int) -> int:
    """lcm(1, 2, ..., n)."""
    return reduce(lambda a, b: a * b // math.gcd(a, b), range(1, n + 1), 1)


def diff_prod(S: Iterable[int], T: Iterable[int]) -> int:
    """Product of all positive differences s - t (t < s)."""
    p = 1
    for s in S:
        for t in T:
            if t < s:
                p *= s - t
    return p


def primes_up_to(n: int) -> list[int]:
    """Sieve of Eratosthenes."""
    if n < 2:
        return []
    sieve = bytearray([1]) * (n + 1)
    sieve[0] = sieve[1] = 0
    for p in range(2, int(n ** 0.5) + 1):
        if sieve[p]:
            sieve[p * p:: p] = bytearray(len(sieve[p * p:: p]))
    return [i for i, b in enumerate(sieve) if b]


# ---------------------------------------------------------------------------
# The block-product (trivial, one-sided) covering
# ---------------------------------------------------------------------------

def block(L: int, j: int) -> int:
    """(jL+1)(jL+2)...(jL+L): a product of L consecutive integers."""
    return math.prod(range(j * L + 1, j * L + L + 1))


def trivial_cover(n: int, L: int) -> tuple[list[int], list[int]]:
    """S = all blocks needed to reach n, T = {0}."""
    B = (n + L - 1) // L
    return [block(L, j) for j in range(B)], [0]


def trivial_cover_for_beta(n: int, beta: float) -> tuple[list[int], list[int], int]:
    """The block length used in the feasibility proof: L = ceil(2 n^(1-beta))."""
    L = math.ceil(2 * n ** (1 - beta))
    S, T = trivial_cover(n, L)
    return S, T, L


# ---------------------------------------------------------------------------
# Units
# ---------------------------------------------------------------------------

def measured_alpha(n: int, M: int) -> float:
    """Correct (double-logarithmic) exponent: ln ln M / ln n."""
    return math.log(math.log(M)) / math.log(n)


def naive_alpha(n: int, M: int) -> float:
    """The *wrong* single-logarithm exponent ln M / ln n."""
    return math.log(M) / math.log(n)


def log_int(M: int) -> float:
    """Natural log of a possibly huge integer."""
    b = M.bit_length()
    if b < 1000:
        return math.log(M)
    shift = b - 900
    return math.log(M >> shift) + shift * math.log(2)


# ---------------------------------------------------------------------------
# Greedy unstructured search (illustrative only)
# ---------------------------------------------------------------------------

def greedy_cover(n: int, sizeS: int, sizeT: int, max_log: float,
                 trials: int = 60, seed: int = 0) -> float:
    """Pick T at random below a bound, then greedily add the s (from random
    candidates of magnitude <= exp(max_log)) that covers the most new i.
    Returns the coverage fraction of [n] reached."""
    rng = random.Random(seed)
    Mbits = max(8, int(max_log / math.log(2)))
    T = sorted(rng.sample(range(0, 10 * n), sizeT))
    uncovered = set(range(1, n + 1))
    S: list[int] = []
    for _ in range(sizeS):
        best, best_gain = None, -1
        for _ in range(trials):
            # candidate: t + (multiple of a product of uncovered i), random t
            t = rng.choice(T)
            m = 1
            for i in sorted(uncovered, reverse=True):
                if (m * i // math.gcd(m, i)).bit_length() > Mbits - 2:
                    continue
                if rng.random() < 0.5:
                    m = m * i // math.gcd(m, i)
            s = t + m
            if s in T:
                continue
            gain = sum(1 for i in uncovered if any((s - u) % i == 0 for u in T if u < s))
            if gain > best_gain:
                best, best_gain = s, gain
        if best is None:
            break
        S.append(best)
        uncovered = {i for i in uncovered if not any((best - u) % i == 0 for u in T if u < best)}
    return 1 - len(uncovered) / n


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_trivial_cover() -> None:
    print("=" * 72)
    print("1. The block-product covering (T = {0})")
    print("=" * 72)
    n, L = 12, 4
    S, T = trivial_cover(n, L)
    print(f"n = {n}, L = {L}:  S = {S},  T = {T}")
    print(f"   is a divisibility covering of [1,{n}]?  {is_div_cover(n, S, T)}")
    for n in (60, 200, 500):
        S, T, L = trivial_cover_for_beta(n, 1 / 3)
        M = max(S)
        lnM = log_int(M)
        bound = 3 * n ** (2 / 3) * math.log(4 * n)
        print(f"n = {n:4d}, beta = 1/3: L = {L:3d}, |S| = {len(S):2d} "
              f"(n^beta = {n ** (1/3):5.2f}), covers: {is_div_cover(n, S, T)}, "
              f"ln M = {lnM:7.1f} <= 3 n^(2/3) ln(4n) = {bound:7.1f}")
    print("   ln M = O(n^(2/3) log n), so ln ln M / ln n -> 2/3 = 1 - beta: every\n"
          "   alpha > 2/3 is eventually achieved (convergence is slow: the log factor).")


def demo_counting_wall() -> None:
    print()
    print("=" * 72)
    print("2-3. The divisibility chain and the counting wall")
    print("=" * 72)
    for k in (3, 6, 10, 25):
        n = 2 * k
        S, T = trivial_cover(n, 4)
        M = max(S)
        C = math.comb(2 * k, k)
        L = lcm_up_to(n)
        P = diff_prod(S, T)
        m = len(S) * len(T)
        print(f"k = {k:2d}: C(2k,k) | lcm(1..2k): {L % C == 0}, "
              f"lcm | prod(s-t): {P % L == 0}, "
              f"4^k = {4 ** k:.3e} <= 2k*M^(|S||T|) = {float(2 * k) * M ** m:.3e}: "
              f"{4 ** k <= 2 * k * M ** m}")
    print("   Prime-power check: every p^v_p(C(2k,k)) is <= 2k (Kummer/Legendre):")
    k = 25
    C = math.comb(2 * k, k)
    worst = 0
    for p in primes_up_to(2 * k):
        v, c = 0, C
        while c % p == 0:
            c //= p
            v += 1
        worst = max(worst, p ** v)
    print(f"   k = {k}: max p^v = {worst} <= 2k = {2 * k}: {worst <= 2 * k}")


def demo_sandwich() -> None:
    print()
    print("=" * 72)
    print("4. The exponent constraint and the sandwich at beta = 1/3")
    print("=" * 72)
    print("Real wall:  (n-1) ln 2 <= ln n + n^(alpha+beta_S+beta_T)")
    for gamma in (0.9, 0.99, 1.0):
        for n in (1e3, 1e9, 1e60):
            lhs = (n - 1) * math.log(2)
            rhs = math.log(n) + n ** gamma
            print(f"   gamma = alpha+beta_S+beta_T = {gamma:4.2f}, n = {n:.0e}: "
                  f"wall {'satisfied' if lhs <= rhs else 'VIOLATED (no covering)'}")
    print("At beta_S = beta_T = 1/3:")
    for alpha in (0.30, 1 / 3, 0.5, 2 / 3, 0.70):
        forced = alpha >= 1 / 3
        known = alpha > 2 / 3
        status = ("impossible" if not forced else
                  "achieved by block products" if known else "OPEN")
        print(f"   alpha = {alpha:.3f}: {status}")
    print("Empirical point (alpha, beta) = (1/2, 2/3): 1/2 > 1 - 2/3 = 1/3, so already\n"
          "   inside the trivially feasible region (even (2/5, 2/3, 0) is feasible).")


def demo_units() -> None:
    print()
    print("=" * 72)
    print("5. The alpha-unit trap")
    print("=" * 72)
    alpha = 1 / 3
    for n in (10 ** 3, 10 ** 6, 10 ** 12, 10 ** 24):
        lnM = n ** alpha            # ln M for M = exp(n^alpha)
        correct = math.log(lnM) / math.log(n)
        naive = lnM / math.log(n)
        print(f"   n = {n:.0e}, M = exp(n^(1/3)): ln ln M/ln n = {correct:.4f}, "
              f"ln M/ln n = {naive:,.1f}")


def demo_large_primes() -> None:
    print()
    print("=" * 72)
    print("6. The large-prime budget  y^(pi(n)-pi(y)) <= M^(|S||T|)")
    print("=" * 72)
    for n in (100, 400, 1000):
        S, T, L = trivial_cover_for_beta(n, 1 / 3)
        lnM = log_int(max(S))
        y = round(n ** (2 / 3))
        cnt = sum(1 for p in primes_up_to(n) if p > y)
        lhs = cnt * math.log(y)
        rhs = len(S) * len(T) * lnM
        print(f"   n = {n:4d}, y = n^(2/3) = {y:3d}: #primes in (y,n] = {cnt:3d}, "
              f"log LHS = {lhs:8.1f} <= log RHS = {rhs:10.1f}: {lhs <= rhs}")


def demo_guard() -> None:
    print()
    print("=" * 72)
    print("7. The disjointness guard")
    print("=" * 72)
    a = 17
    print(f"   Without t < s:  S = T = {{{a}}} gives difference 0, divisible by every i.")
    print(f"   With the guard (t < s): is_div_cover(10, {{{a}}}, {{{a}}}) = "
          f"{is_div_cover(10, [a], [a])}")


def demo_greedy() -> None:
    print()
    print("=" * 72)
    print("8. Unstructured greedy search at the target (illustrative)")
    print("=" * 72)
    for n in (60, 120, 240):
        sz = max(2, round(n ** (1 / 3)))
        target = greedy_cover(n, sz, sz, max_log=n ** (1 / 3))
        szt = round(n ** (2 / 3))
        traded = greedy_cover(n, szt, szt, max_log=n ** 0.5)
        print(f"   n = {n:3d}: (1/3,1/3): |S|=|T|={sz:2d}, ln M <= n^(1/3) -> coverage {target:.2f};  "
              f"(1/2,2/3): |S|=|T|={szt:2d}, ln M <= n^(1/2) -> coverage {traded:.2f}")
    print("   (a toy search; numbers vary with seed. The point: at the target the\n"
          "    budget is so tight that unstructured choices leave much of [n] uncovered.)")


if __name__ == "__main__":
    demo_trivial_cover()
    demo_counting_wall()
    demo_sandwich()
    demo_units()
    demo_large_primes()
    demo_guard()
    demo_greedy()
