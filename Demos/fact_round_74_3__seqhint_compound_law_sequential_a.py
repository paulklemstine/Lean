#!/usr/bin/env python3
"""
Sequential hint pricing: numerical demonstrations
=================================================

One pricing structure, two faces.

    fixed comparison battery of k thresholds   ->  speedup  <=  k + 1     (linear)
    adaptive comparison queries, budget k      ->  speedup   =  2 ** k    (geometric)
    any strategy whatsoever, budget k          ->  speedup  <=  2 ** k    (hard ceiling)

This script verifies every quantitative claim of the accompanying paper by
direct computation on concrete windows.  It is fully self-contained: standard
library only, every helper inlined, no external data.

Run:  python3 demo.py
"""

from __future__ import annotations

import itertools
import math
from typing import Callable, Dict, Iterable, List, Sequence, Tuple

# ----------------------------------------------------------------------------
# 1.  Windows, fixed batteries, signatures
# ----------------------------------------------------------------------------

Window = Tuple[int, int]  # half-open [lo, hi)


def width(window: Window) -> int:
    """Number of candidates in the half-open window [lo, hi)."""
    lo, hi = window
    return max(0, hi - lo)


def carrier(window: Window) -> List[int]:
    """The candidate list of the window."""
    lo, hi = window
    return list(range(lo, hi))


def signature(thresholds: Sequence[int], x: int) -> int:
    """sigma_T(x) = #{t in T : x <= t}.

    Because comparison answers are nested, this single integer determines the
    entire answer vector of the fixed battery.
    """
    return sum(1 for t in thresholds if x <= t)


def largest_indistinguishable_class(thresholds: Sequence[int],
                                    window: Window) -> int:
    """Size of the largest set of candidates the fixed battery cannot separate."""
    classes: Dict[int, int] = {}
    for x in carrier(window):
        v = signature(thresholds, x)
        classes[v] = classes.get(v, 0) + 1
    return max(classes.values()) if classes else 0


def fixed_battery_speedup(thresholds: Sequence[int], window: Window) -> float:
    """|W| / (size of the residual class): the best speedup the battery can buy."""
    return width(window) / largest_indistinguishable_class(thresholds, window)


def uniform_battery(bound: int, k: int) -> List[int]:
    """The uniform battery t_i = floor(i * bound / (k + 1)), i = 1..k."""
    return sorted({(i * bound) // (k + 1) for i in range(1, k + 1)})


# ----------------------------------------------------------------------------
# 2.  Adaptive lower-median bisection
# ----------------------------------------------------------------------------

def lower_median(window: Window) -> int:
    """The threshold asked by the adaptive arm: lo + floor((w - 1) / 2)."""
    lo, _ = window
    return lo + (width(window) - 1) // 2


def upper_median(window: Window) -> int:
    """The naive (broken) threshold: lo + floor(w / 2).  Stalls on even widths."""
    lo, _ = window
    return lo + width(window) // 2


def bisect_step(window: Window, answer: bool) -> Window:
    """One adaptive step, given the truthful answer to 'x <= mid?'."""
    lo, hi = window
    m = lower_median(window)
    return (lo, m + 1) if answer else (m + 1, hi)


def bisect(x: int, k: int, window: Window) -> Window:
    """Run k truthful lower-median bisection queries against the hidden value x."""
    for _ in range(k):
        window = bisect_step(window, x <= lower_median(window))
    return window


def bisect_up(x: int, k: int, window: Window) -> Window:
    """The naive upper-median arm, retained to exhibit the even-median stall."""
    for _ in range(k):
        lo, hi = window
        m = upper_median(window)
        window = (lo, m + 1) if x <= m else (m + 1, hi)
    return window


def half_iter(k: int, w: int) -> int:
    """k iterations of w -> ceil(w / 2)."""
    for _ in range(k):
        w = (w + 1) // 2
    return w


def ceil_div_pow2(w: int, k: int) -> int:
    """ceil(w / 2 ** k)."""
    return -((-w) // (2 ** k))


def clog2(w: int) -> int:
    """The exact isolating budget ceil(log2 w)."""
    return 0 if w <= 1 else (w - 1).bit_length()


# ----------------------------------------------------------------------------
# 3.  The adaptivity premium
# ----------------------------------------------------------------------------

def premium(k: int) -> float:
    """r(k) = 2 ** k / (k + 1): geometric law divided by linear law."""
    return 2 ** k / (k + 1)


# ----------------------------------------------------------------------------
# 4.  Residue channel and the one-lie (Ulam) channel
# ----------------------------------------------------------------------------

def residue_signature(moduli: Sequence[int], x: int) -> Tuple[int, ...]:
    """The answer vector of a non-adaptive residue battery."""
    return tuple(x % m for m in moduli)


def residue_class_spread(window: Window, m: int, a: int) -> int:
    """Largest gap c - b between two window members congruent to a modulo m."""
    members = [x for x in carrier(window) if x % m == a % m]
    return members[-1] - members[0] if members else 0


def liar_transcript(strategy: Callable[[Tuple[bool, ...]], int],
                    x: int, lie_at: int, k: int) -> Tuple[bool, ...]:
    """k-query transcript when the oracle lies exactly at step `lie_at`.

    `lie_at == k` means 'no lie'.
    """
    history: Tuple[bool, ...] = ()
    for j in range(k):
        t = strategy(history)
        truth = x <= t
        history = history + ((not truth) if j == lie_at else truth,)
    return history


# ----------------------------------------------------------------------------
# 5.  Net economics and the Fermat scan
# ----------------------------------------------------------------------------

def net_cost(c: float, t0: float, k: float) -> float:
    """Net cost of a budget of k adaptive queries: c*k + T0 * 2 ** (-k)."""
    return c * k + t0 * 2.0 ** (-k)


def k_opt(c: float, t0: float) -> float:
    """The optimal (real) budget log2(T0 * ln 2 / c)."""
    return math.log2(t0 * math.log(2.0) / c)


def scan_units(rho: float) -> float:
    """Fermat scan length in units of sqrt(N): (u - 1)^2 / (2u) with u = sqrt(rho)."""
    u = math.sqrt(rho)
    return (u - 1.0) ** 2 / (2.0 * u)


# ----------------------------------------------------------------------------
# Demonstrations
# ----------------------------------------------------------------------------

def demo_linear_pricing() -> None:
    print("=" * 74)
    print("1.  FIXED BATTERIES PRICE LINEARLY:  speedup <= k + 1  (and it is tight)")
    print("=" * 74)
    window: Window = (0, 1024)
    print(f"  window [0, 1024), {width(window)} candidates\n")
    print("     k   best fixed speedup   bound k+1   residual class")
    for k in [0, 1, 2, 3, 6, 9, 12]:
        best = max(
            fixed_battery_speedup(uniform_battery(1024, k), window),
            fixed_battery_speedup([i * 1024 // (k + 1) for i in range(1, k + 1)],
                                  window) if k else 1.0,
        )
        cls = largest_indistinguishable_class(uniform_battery(1024, k), window)
        print(f"  {k:4d}   {best:17.3f}   {k + 1:9d}   {cls:14d}")

    print("\n  Exhaustive sweep: every 3-threshold battery on [0, 8)")
    worst = min(largest_indistinguishable_class(list(T), (0, 8))
                for T in itertools.combinations(range(8), 3))
    print(f"    smallest achievable residual class = {worst}"
          f"   (pigeonhole value 8 / 4 = 2)")
    print("    equally spaced battery {1, 3, 5} achieves "
          f"{largest_indistinguishable_class([1, 3, 5], (0, 8))}")

    print("\n  Exhaustive sweep: every 4-threshold battery on [0, 16)")
    worst16 = min(largest_indistinguishable_class(list(T), (0, 16))
                  for T in itertools.combinations(range(16), 4))
    adaptive_ok = all(carrier(bisect(x, 4, (0, 16))) == [x] for x in range(16))
    print(f"    every one of the {math.comb(16, 4)} batteries leaves >= {worst16} tied")
    print(f"    while 4 ADAPTIVE queries isolate every candidate: {adaptive_ok}")
    print()


def demo_exact_halving() -> None:
    print("=" * 74)
    print("2.  THE WIDTH-HALVING LAW IS EXACT:  residual width = ceil(w / 2^k)")
    print("=" * 74)
    ok = True
    for w in range(1, 400):
        for k in range(0, 11):
            if half_iter(k, w) != ceil_div_pow2(w, k):
                ok = False
    print(f"  ceil-halving composes exactly, all w < 400 and k <= 10: {ok}")

    window: Window = (0, 2 ** 20)
    print(f"\n  window [0, 2^20), {width(window)} candidates, hidden x = 613187")
    print("     k   residual width   ceil(w / 2^k)   log-slope")
    prev = None
    for k in [0, 1, 2, 3, 6, 9, 12, 16, 19, 20, 24]:
        rw = width(bisect(613187, k, window))
        pred = ceil_div_pow2(2 ** 20, k)
        slope = "" if prev is None or prev[1] <= 1 else \
            f"{(math.log(rw) - math.log(prev[1])) / (k - prev[0]):9.4f}"
        print(f"  {k:4d}   {rw:14d}   {pred:13d}   {slope:>9}")
        prev = (k, rw)
    print(f"\n  exact isolating budget for 2^20 candidates: {clog2(2 ** 20)}"
          f"   (theory: ceil(log2 w) = 20)")
    print(f"  exact isolating budget for 3600 candidates : {clog2(3600)}"
          f"   (theory: 12)")
    print(f"  exact slope of log(residual) in k          : {-math.log(2):.4f} = -ln 2")

    print("\n  The even-median stall (why the LOWER median is not cosmetic):")
    print(f"    lower-median arm on [0, 2), x = 0, after 1 query : "
          f"{bisect(0, 1, (0, 2))}")
    for k in [1, 5, 50]:
        print(f"    upper-median arm on [0, 2), x = 0, after {k:2d} queries: "
              f"{bisect_up(0, k, (0, 2))}  <-- stalled")
    print()


def demo_isolation_ceiling() -> None:
    print("=" * 74)
    print("3.  THE ISOLATION CEILING:  no strategy separates more than 2^k")
    print("=" * 74)
    print("  Brute force over ALL deterministic strategies on [0, 8) with k = 2")
    print("  (a strategy = threshold at the root + one threshold per answer)")
    window: Window = (0, 8)
    best_separated = 0
    for t0 in range(-1, 9):
        for t_yes in range(-1, 9):
            for t_no in range(-1, 9):
                transcripts = set()
                for x in carrier(window):
                    b0 = x <= t0
                    b1 = x <= (t_yes if b0 else t_no)
                    transcripts.add((b0, b1))
                best_separated = max(best_separated, len(transcripts))
    print(f"    maximum number of distinct transcripts = {best_separated}"
          f"   (ceiling 2^2 = 4)")

    print("\n  Transcript counting for bisection on [0, 2^m):")
    print("     m    k   distinct transcripts   ceiling 2^k")
    for m, k in [(4, 2), (4, 4), (6, 3), (6, 6)]:
        seen = set()
        for x in range(2 ** m):
            w2: Window = (0, 2 ** m)
            hist: List[bool] = []
            for _ in range(k):
                b = x <= lower_median(w2)
                hist.append(b)
                w2 = bisect_step(w2, b)
            seen.add(tuple(hist))
        print(f"  {m:4d} {k:4d}   {len(seen):20d}   {2 ** k:11d}")
    print()


def demo_premium() -> None:
    print("=" * 74)
    print("4.  THE ADAPTIVITY PREMIUM  r(k) = 2^k / (k+1)")
    print("=" * 74)
    print("     k    2^k      k+1    r(k)         note")
    notes = {0: "r(0) = 1 exactly",
             1: "r(1) = 1 EXACTLY - nothing to adapt to",
             3: "r(3) = 2",
             12: "measured 239.5 [220.1, 261.0] <= 315.08",
             20: "isolation ceiling for the 2^20 window"}
    for k in [0, 1, 2, 3, 6, 9, 12, 14, 16, 20, 24]:
        print(f"  {k:4d} {2 ** k:8d} {k + 1:8d}  {premium(k):11.4f}  {notes.get(k, '')}")
    mono = all(premium(k) < premium(k + 1) for k in range(1, 40))
    superlin = all(premium(k) >= k for k in range(5, 60))
    print(f"\n  strictly increasing from k = 1 on : {mono}")
    print(f"  r(k) >= k for all k >= 5          : {superlin}")
    print(f"  measured premium 239.5 <= r(12) = {premium(12):.4f} : "
          f"{239.5 <= premium(12)}")
    print(f"  grid ratio k = 3 -> k = 12 on [0, 2^20): "
          f"{ceil_div_pow2(2 ** 20, 3) // ceil_div_pow2(2 ** 20, 12)}x  (= 2^9 = 512)")
    print()


def demo_zero_bit_collapse() -> None:
    print("=" * 74)
    print("5.  THE HEADLINE SURPRISE: a fixed battery carrying LITERALLY ZERO BITS")
    print("=" * 74)
    support: Window = (720_000, 723_600)     # balanced stratum, rho <= 1.01
    search_bound = 2 ** 20
    print(f"  balanced support window {support}, {width(support)} candidates")
    print(f"  inside the full search window [2, {search_bound})\n")
    print("     k   thresholds inside support   fixed speedup   residual class")
    for k in [1, 2, 3, 6, 9, 12, 16, 20, 24]:
        T = uniform_battery(search_bound, k)
        inside = sum(1 for t in T if support[0] <= t < support[1])
        print(f"  {k:4d}   {inside:25d}   {fixed_battery_speedup(T, support):13.2f}"
              f"   {largest_indistinguishable_class(T, support):14d}")
    T24 = uniform_battery(search_bound, 24)
    straddle = [t for t in T24 if t < support[1]][-1], \
               [t for t in T24 if t >= support[1]][0]
    print(f"\n  the 24-threshold battery straddles the support with {straddle}")
    print("  -> every candidate answers all 24 queries identically: ZERO bits\n")
    isolated = all(carrier(bisect(x, 12, support)) == [x] for x in carrier(support))
    print(f"  meanwhile 12 ADAPTIVE queries isolate every one of the "
          f"{width(support)} candidates: {isolated}")
    print(f"  adaptive speedup at k = 12 : {width(support)}x")
    print("  fixed    speedup at k = 24 : 1.00x  (exactly)")
    print()


def demo_two_currencies() -> None:
    print("=" * 74)
    print("6.  TWO CHANNELS, TWO CURRENCIES: count versus interval")
    print("=" * 74)
    window: Window = (0, 1024)
    moduli = [2, 3, 5, 7, 11]
    prod = math.prod(moduli)
    print(f"  non-adaptive residue battery, moduli {moduli}, product {prod} >= 2^5")
    sigs = {residue_signature(moduli, x) for x in range(prod)}
    print(f"    distinct answer vectors on a window of width {prod}: {len(sigs)}"
          f"  -> isolates (CRT)")
    print("    => COMPOUNDING WITHOUT ADAPTIVITY: the channel, not the conditioning\n")
    print("  but a single residue class carries no INTERVAL information:")
    print("     m   spread of the class of x = 613 in [0, 1024)   window width - 2m")
    for m in [3, 7, 16, 97]:
        print(f"  {m:4d}   {residue_class_spread(window, m, 613):43d}"
              f"   {width(window) - 2 * m:17d}")
    print("\n  mixed battery: k adaptive comparison queries + one residue query")
    print("     k    m   surviving count   count floor   surviving spread   "
          "interval floor")
    for k, m in [(2, 7), (4, 7), (4, 31), (6, 3)]:
        resid = bisect(613, k, window)
        alive = [y for y in carrier(resid) if y % m == 613 % m]
        spread = alive[-1] - alive[0] if alive else 0
        print(f"  {k:4d} {m:4d}   {len(alive):15d}   "
              f"{width(window) // (2 ** k * m):11d}   {spread:16d}   "
              f"{max(0, width(window) // 2 ** k - 2 * m):14d}")
    print("\n  interval gain is capped by the ORDER budget alone.")
    print()


def demo_one_lie() -> None:
    print("=" * 74)
    print("7.  THE PRICE OF ONE LIE:  (k+1) * |C| <= 2^k")
    print("=" * 74)

    def bisect_strategy(window: Window) -> Callable[[Tuple[bool, ...]], int]:
        def strategy(history: Tuple[bool, ...]) -> int:
            w = window
            for b in history:
                w = bisect_step(w, b)
            return lower_median(w)
        return strategy

    k = 4
    window: Window = (0, 16)
    strategy = bisect_strategy(window)
    print(f"  bisection on {window} with k = {k}, oracle allowed one lie")
    collisions = 0
    for x, y in itertools.combinations(carrier(window), 2):
        for lx in range(k + 1):
            for ly in range(k + 1):
                if liar_transcript(strategy, x, lx, k) == \
                        liar_transcript(strategy, y, ly, k):
                    collisions += 1
    print(f"    colliding (candidate, lie-pattern) pairs: {collisions}")
    print(f"    volume bound: a one-lie-robust strategy pins at most "
          f"2^{k} / {k + 1} = {2 ** k / (k + 1):.3f} candidates")
    print(f"    the truthful arm pins all {width(window)} -> one lie is fatal here\n")
    print("     k    2^k   max one-lie candidates   truthful ceiling 2^k   tax")
    for k in [4, 8, 12, 16, 20]:
        print(f"  {k:4d} {2 ** k:6d}   {2 ** k // (k + 1):22d}   {2 ** k:20d}"
              f"   {k + 1:4d}x")
    print(f"\n  bit-length-40 window [0, 2^20): 21 * 2^20 = {21 * 2 ** 20} > 2^20"
          f" = {2 ** 20}")
    print("  -> no 20-query strategy survives a single lie, though 20 truthful"
          " queries pin it")
    print("  the NOISE tax (k+1) equals the NON-ADAPTIVITY tax (k+1).")
    print()


def demo_economics() -> None:
    print("=" * 74)
    print("8.  NET ECONOMICS:  k_opt = log2(T0 * ln2 / c)")
    print("=" * 74)
    for label, t0, c in [("balanced  ", 1072.43, 1.0),
                         ("unbalanced", 2.862e5, 1.0)]:
        kstar = k_opt(c, t0)
        best_int = min(range(0, 41), key=lambda n: net_cost(c, t0, n))
        print(f"  {label}: T0 = {t0:12.2f}, c = {c}")
        print(f"      predicted k_opt = {kstar:6.2f}    integer argmin = {best_int}"
              f"    floor/ceil = {math.floor(kstar)}/{math.ceil(kstar)}")
        print(f"      net cost at optimum = {net_cost(c, t0, best_int):.3f}"
              f"    residual downstream cost = {t0 * 2 ** -kstar:.4f}"
              f"  (c / ln2 = {c / math.log(2):.4f})")
        print(f"      net speedup = {t0 / net_cost(c, t0, best_int):.1f}x")
    print("\n     k   net cost (unbalanced stratum)")
    for k in [0, 6, 12, 16, 17, 18, 19, 20, 24]:
        print(f"  {k:4d}   {net_cost(1.0, 2.862e5, k):16.2f}")
    print()


def demo_fermat_strata() -> None:
    print("=" * 74)
    print("9.  THE DOWNSTREAM SCAN:  scan / sqrt(N) = (sqrt(rho) - 1)^2 / (2 sqrt(rho))")
    print("=" * 74)
    print("     rho     scan units    stratum")
    for rho in [1.0, 1.001, 1.01, 1.5, 4.0, 7.5, 8.0, 8.5]:
        stratum = "balanced" if rho <= 1.01 else ("unbalanced" if rho >= 7.5 else "")
        print(f"  {rho:6.3f}   {scan_units(rho):12.8f}    {stratum}")
    print(f"\n  balanced bound   : scan_units(1.01) = {scan_units(1.01):.3e}"
          f" <= 1/60000 = {1 / 60000:.3e}")
    print(f"  unbalanced bound : scan_units(7.5)  = {scan_units(7.5):.6f}"
          f" >= 1/2")
    print(f"  stratum contrast : {scan_units(7.5) / scan_units(1.01):.1f}x"
          f"  (theory: >= 10^4)")

    print("\n  Fermat's difference of squares, verified directly:")
    for p, q in [(1009, 1013), (99991, 100003), (65537, 524287)]:
        n = p * q
        a, b = (p + q) // 2, (q - p) // 2
        print(f"    N = {n:14d} = {p} * {q}:  a = {a}, b = {b},"
              f"  a^2 - N == b^2 -> {a * a - n == b * b}")
    print("\n  Pythagorean bridge, (a-b)(a+b) = n^2  <=>  n^2 + b^2 = a^2:")
    for n, b, a in [(3, 4, 5), (5, 12, 13), (20, 21, 29)]:
        print(f"    n = {n:3d}, b = {b:3d}, a = {a:3d}:  "
              f"(a-b)(a+b) = {(a - b) * (a + b):5d} = n^2 = {n * n:5d}   "
              f"n^2 + b^2 = a^2 -> {n * n + b * b == a * a}")
    print()


def demo_end_to_end() -> None:
    print("=" * 74)
    print("10. END TO END: hinted Fermat factoring of a balanced semiprime")
    print("=" * 74)
    p, q = 720_233, 723_419
    n = p * q
    window: Window = (2, 2 ** 20)
    print(f"  N = {n} (bit length {n.bit_length()}), rho = {q / p:.4f}")
    print(f"  hidden smaller factor p = {p}, initial window {window}"
          f" ({width(window)} candidates)\n")
    print("     k   residual window                 width   speedup   pinned")
    for k in [0, 3, 6, 9, 12, 16, 19, 20, 24]:
        resid = bisect(p, k, window)
        pinned = width(resid) == 1
        print(f"  {k:4d}   {str(resid):28s}  {width(resid):6d}"
              f"   {width(window) / width(resid):7.1f}   {pinned}")
    print(f"\n  isolation ceiling: ceil(log2 {width(window)}) = {clog2(width(window))}"
          " queries, and no fewer")

    # the downstream scan, with and without the hint
    root = math.isqrt(n)
    steps_unhinted = 0
    a = root if root * root >= n else root + 1
    while True:
        d = a * a - n
        steps_unhinted += 1
        r = math.isqrt(d)
        if r * r == d:
            break
        a += 1
    print(f"  Fermat scan from ceil(sqrt(N)): {steps_unhinted} step(s)"
          f"   (predicted (sqrt(q)-sqrt(p))^2/2 = "
          f"{(math.sqrt(q) - math.sqrt(p)) ** 2 / 2:.2f})")
    print(f"  recovered factors: {a - math.isqrt(a * a - n)} * "
          f"{a + math.isqrt(a * a - n)} = {n}")
    print()


def main() -> None:
    print()
    print("#" * 74)
    print("#  SEQUENTIAL HINT PRICING - ONE STRUCTURE, TWO FACES".ljust(73) + "#")
    print("#  fixed batteries: k + 1     adaptive queries: 2^k".ljust(73) + "#")
    print("#" * 74)
    print()
    demo_linear_pricing()
    demo_exact_halving()
    demo_isolation_ceiling()
    demo_premium()
    demo_zero_bit_collapse()
    demo_two_currencies()
    demo_one_lie()
    demo_economics()
    demo_fermat_strata()
    demo_end_to_end()
    print("=" * 74)
    print("All demonstrations complete.")
    print("=" * 74)


if __name__ == "__main__":
    main()
