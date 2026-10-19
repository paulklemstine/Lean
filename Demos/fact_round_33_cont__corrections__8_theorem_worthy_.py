#!/usr/bin/env python3
"""
Numerical companion to "When a Fallen Hypothesis Moves Nothing".

Pure standard-library Python (3.9+). Every function is inlined. Run:

    python3 demo.py

Sections
  1. Harvey's three-term exponent minimax: optimum 1/5, three-way co-dominance.
  2. The slack-constraint lemma: the baby-step ceiling phase diagram.
  3. Filters: pair-only target sigma = 1/6 versus pair+sweep target sigma = 1/18.
  4. The free a <= b pair filter: soundness and exact strength 2|kept| = |all| + isqrt(r).
  5. Euler-gap reveal density (a+b-2)/(ab): the gap g cancels; sup 1 vs sup 1/2.
  6. Divisibility coverings: the disjointness guard and the union (divisor-mass) bound.
  7. A polylogarithmic precondition fails only on a bounded window (k^96 <= 2^k).
  8. The Berggren B-spine: a_k - b_k = (-1)^(k+1), so every gcd probe is trivial.
  9. Effective sample size: primes in [2^19, 2^20) with 13-smooth p - 1.
"""
from __future__ import annotations

from fractions import Fraction as Q
from math import gcd, isqrt
from typing import Iterable, List, Sequence, Tuple


def banner(title: str) -> None:
    print("\n" + "=" * 78)
    print(title)
    print("=" * 78)


# ---------------------------------------------------------------------------
# 1-3. Harvey's exponent model (logarithmic factors dropped)
#   r = N^a pairs, m = N^b baby steps; cost exponent
#   E(a,b) = max( a - s2 , b , 1/2 - a/2 - b - s1 )
#   T2 = a (pair sweep), T3 = b (baby-step table), T1 = 1/2 - a/2 - b (giant sweep)
# ---------------------------------------------------------------------------

def filtered_exp(s1: Q, s2: Q, a: Q, b: Q) -> Q:
    """Exponent of the filtered model (s1 divides the sweep, s2 divides the pairs)."""
    return max(a - s2, b, Q(1, 2) - a / 2 - b - s1)


def filtered_opt(s1: Q, s2: Q) -> Q:
    """Closed-form optimum 1/5 - s2/5 - 2 s1/5 (dual weights 1/5, 2/5, 2/5)."""
    return Q(1, 5) - s2 / 5 - 2 * s1 / 5


def filtered_arg(s1: Q, s2: Q) -> Tuple[Q, Q]:
    v = filtered_opt(s1, s2)
    return (v + s2, v)


def grid_min(s1: Q, s2: Q, cap: Q | None = None, steps: int = 400) -> Tuple[Q, Q, Q]:
    """Brute-force minimum over a rational grid in [0, 1/2]^2 (optionally b <= cap)."""
    best: Tuple[Q, Q, Q] | None = None
    for i in range(steps + 1):
        a = Q(i, 2 * steps)
        for j in range(steps + 1):
            b = Q(j, 2 * steps)
            if cap is not None and b > cap:
                continue
            e = filtered_exp(s1, s2, a, b)
            if best is None or e < best[0]:
                best = (e, a, b)
    assert best is not None
    return best


def capped_opt(c: Q) -> Q:
    """Optimum under the baby-step ceiling b <= c: 1/5 if slack, (1-2c)/3 if active."""
    return Q(1, 5) if c >= Q(1, 5) else (1 - 2 * c) / 3


def section_harvey() -> None:
    banner("1. Harvey's minimax: optimum 1/5 with all three terms tied")
    e, a, b = grid_min(Q(0), Q(0))
    print(f"grid minimum  E = {e}  at (a,b) = ({a}, {b})")
    a0, b0 = filtered_arg(Q(0), Q(0))
    t = (a0, b0, Q(1, 2) - a0 / 2 - b0)
    print(f"closed form   (a,b) = ({a0}, {b0}); terms (pairs, baby, sweep) = {t}")
    print("all three terms equal -> no single term 'dominates' (co-dominance)")

    banner("2. Slack-constraint lemma: phase diagram of the ceiling b <= c")
    print(f"{'c':>8} {'grid opt':>10} {'formula':>10}  regime   (grid denominator 600)")
    for c in [Q(2, 5), Q(3, 10), Q(1, 5), Q(3, 20), Q(1, 10), Q(1, 20), Q(0)]:
        e, _, _ = grid_min(Q(0), Q(0), cap=c, steps=300)
        regime = "slack (exponent frozen)" if c >= Q(1, 5) else "ACTIVE (exponent moves)"
        print(f"{str(c):>8} {str(e):>10} {str(capped_opt(c)):>10}  {regime}")
    print("Harvey's ceiling c = 2/5 exceeds the need 1/5 by N^(1/5): lifting it changes nothing.")

    banner("3. Which term a filter divides decides the target")
    for s in [Q(1, 18), Q(1, 6)]:
        print(f"sigma = {s}:  pair-only optimum = {filtered_opt(Q(0), s)}   "
              f"pair+sweep optimum = {filtered_opt(s, s)}")
    print("pair-only reaches 1/6 at sigma = 1/6; pair+sweep reaches 1/6 at sigma = 1/18.")
    print(f"ratio of targets = {Q(1, 6) / Q(1, 18)}  (three times harder)")
    for s1, s2 in [(Q(1, 30), Q(1, 15)), (Q(1, 50), Q(0)), (Q(0), Q(1, 10))]:
        e, _, _ = grid_min(s1, s2, steps=300)
        f = filtered_opt(s1, s2)
        a, b = filtered_arg(s1, s2)
        print(f"check (s1,s2)=({s1},{s2}): formula {f} attained exactly at ({a},{b}): "
              f"{filtered_exp(s1, s2, a, b) == f};  grid min {e} >= formula: {e >= f}")


# ---------------------------------------------------------------------------
# 4. The free a <= b filter
# ---------------------------------------------------------------------------

def lehman_pairs(r: int) -> List[Tuple[int, int]]:
    return [(a, b) for a in range(1, r + 1) for b in range(1, r // a + 1)]


def section_filter() -> None:
    banner("4. The free a <= b pair filter")
    print(f"{'r':>6} {'#pairs':>8} {'#a<=b':>8} {'isqrt r':>8}  2*kept == all + isqrt(r)?")
    for r in [10, 100, 1000, 5000]:
        P = lehman_pairs(r)
        kept = sum(1 for a, b in P if a <= b)
        print(f"{r:>6} {len(P):>8} {kept:>8} {isqrt(r):>8}  {2 * kept == len(P) + isqrt(r)}")
    # soundness: any Lehman-accurate approximation (a,b) of p/q with p<q has a<b
    viol = 0
    checked = 0
    for p in range(1, 60):
        for q in range(p + 1, 60):
            for b in range(1, 40):
                for a in range(0, 3 * b):
                    if abs(a * q - b * p) < b:
                        checked += 1
                        if not a < b:
                            viol += 1
    print(f"soundness: {checked} Lehman-accurate (p,q,a,b) checked, violations of a<b: {viol}")


# ---------------------------------------------------------------------------
# 5. Euler-gap reveal density
# ---------------------------------------------------------------------------

def reveal_count(a: int, b: int) -> int:
    return sum(1 for k in range(a * b) if (k % a == 0) != (k % b == 0))


def reveal_count_gap(g: int, a: int, b: int) -> int:
    return sum(1 for e in range(g * a * b)
               if e % g == 0 and ((e % (g * a) == 0) != (e % (g * b) == 0)))


def section_density() -> None:
    banner("5. Euler-gap reveal density rho(a,b) = (a+b-2)/(ab): g cancels")
    for a, b in [(2, 3), (3, 5), (4, 9), (1, 7)]:
        counts = [reveal_count_gap(g, a, b) for g in (1, 2, 6, 30)]
        print(f"(a,b)=({a},{b}) count over g in (1,2,6,30): {counts}  "
              f"a+b-2={a + b - 2}  rho={Q(a + b - 2, a * b)}")
    print("along a = 1 (p-1 | q-1):", [str(Q(b - 1, b)) for b in (2, 5, 10, 100, 1000)], "-> 1")
    best = max((Q(a + b - 2, a * b), a, b) for a in range(2, 60) for b in range(2, 60)
               if gcd(a, b) == 1)
    print(f"max over coprime a,b>=2 (<60): rho = {best[0]} at (a,b)=({best[1]},{best[2]})  [= 1/2 iff a or b = 2]")


# ---------------------------------------------------------------------------
# 6. Divisibility coverings
# ---------------------------------------------------------------------------

def covers(S: Sequence[int], T: Sequence[int], n: int) -> bool:
    return all(any((s - t) % k == 0 for s in S for t in T) for k in range(1, n + 1))


def num_divisors(m: int) -> int:
    m = abs(m)
    return sum(1 for d in range(1, m + 1) if m % d == 0)


def section_cover() -> None:
    banner("6. Coverings by divisibility: guard and union bound")
    print("S={0,5}, T={5,7} (share 5) covers [1,1000]:", covers([0, 5], [5, 7], 1000), "<- spurious")
    print("S={0,5}, T={7}   (disjoint) covers [1,3]:   ", covers([0, 5], [7], 3))
    S, T = [0, 1, 2, 6], [30, 60, 61, 90]
    n = 0
    while covers(S, T, n + 1):
        n += 1
    mass = sum(num_divisors(s - t) for s in S for t in T)
    print(f"disjoint S={S}, T={T}: largest covered n = {n}; divisor mass = {mass}; n <= mass: {n <= mass}")


# ---------------------------------------------------------------------------
# 7. Bounded violation window
# ---------------------------------------------------------------------------

def section_window() -> None:
    banner("7. The precondition k^96 <= 2^k fails only on a bounded window")
    fails = [k for k in range(2, 3000) if k ** 96 > 2 ** k]
    print(f"failures for 2 <= k < 3000: from k = {fails[0]} to k = {fails[-1]}, contiguous: "
          f"{fails == list(range(fails[0], fails[-1] + 1))}")
    print("holds at k = 2048 (RSA-2048):", 2048 ** 96 <= 2 ** 2048)


# ---------------------------------------------------------------------------
# 8. Berggren spine
# ---------------------------------------------------------------------------

def section_berggren() -> None:
    banner("8. Berggren B-spine: a_k - b_k = (-1)^(k+1)")
    x = (3, 4, 5)
    for k in range(8):
        a, b, c = x
        assert a * a + b * b == c * c
        print(f"k={k}: ({a}, {b}, {c})  a-b = {a - b:+d}  gcd(a-b, 2^61-1) = {gcd(a - b, 2**61 - 1)}")
        x = (a + 2 * b + 2 * c, 2 * a + b + 2 * c, 2 * a + 2 * b + 3 * c)


# ---------------------------------------------------------------------------
# 9. Effective sample size
# ---------------------------------------------------------------------------

def primes_in(lo: int, hi: int) -> List[int]:
    sieve = bytearray([1]) * hi
    sieve[0:2] = b"\x00\x00"
    for i in range(2, isqrt(hi) + 1):
        if sieve[i]:
            sieve[i * i::i] = bytearray(len(range(i * i, hi, i)))
    return [p for p in range(lo, hi) if sieve[p]]


def is_smooth(n: int, primes: Iterable[int] = (2, 3, 5, 7, 11, 13)) -> bool:
    for q in primes:
        while n % q == 0:
            n //= q
    return n == 1


def section_sample() -> None:
    banner("9. Effective sample size in [2^19, 2^20)")
    P = primes_in(2 ** 19, 2 ** 20)
    smooth = [p for p in P if is_smooth(p - 1)]
    print(f"primes: {len(P)};  with 13-smooth p-1: {len(smooth)}  "
          f"(fraction {len(smooth) / len(P):.4%})")


if __name__ == "__main__":
    section_harvey()
    section_filter()
    section_density()
    section_cover()
    section_window()
    section_berggren()
    section_sample()
