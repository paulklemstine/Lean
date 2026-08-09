"""
The silver growth rate of the Berggren tree of Pythagorean triples
==================================================================

Numerical demonstration of the following results.

Setting.  A *Euclid seed* is a pair of integers (m, n) with m > n > 0,
gcd(m, n) = 1 and m + n odd.  It encodes the primitive Pythagorean triple

    a = m^2 - n^2,   b = 2mn,   c = m^2 + n^2.

The three Berggren moves acting on seeds are

    B1(m, n) = (2m - n, m),   B2(m, n) = (2m + n, m),   B3(m, n) = (m + 2n, n),

and every seed is reached from the root (2, 1) -- the triple (3, 4, 5) -- by a
unique finite word in these three moves.  Its length is the *depth*.

Embed a seed in the hyperbolic upper half-plane by z(m, n) = (n + i)/m, and let
d denote hyperbolic distance from the base point i.  Then

    (1)  cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m)                [exact]
    (2)  log m <= d <= log m + log 2                               [Theorem A]
    (3)  Phi(m,n) = m + (sqrt2 - 1) n  satisfies  Phi(B_i v) <= (1+sqrt2) Phi(v)
         for all three moves, with equality for B2                 [Theorem B]
    (4)  d <= (k+1) log(1+sqrt2) + log 2  at depth k               [Theorem C]
    (5)  d_k / k -> log(1+sqrt2) = 0.88137...  on the pure-B2 (Pell) spine,
         while the pure-B1 and pure-B3 spines both have rate 0     [Theorem D]
    (6)  (#B2(w)+1) log 2 <= d <= (|w|+1) log(1+sqrt2) + log 2     [Theorem E]
    (7)  minimal depth of hypotenuse N = log N / (2 log(1+sqrt2)) + O(1)
                                                                   [Theorem F]

Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from math import gcd, log, sqrt, acosh
from typing import Iterator, List, Tuple

Seed = Tuple[int, int]

SQRT2: float = sqrt(2.0)
SILVER: float = 1.0 + SQRT2          # 2.41421356...
LOG_SILVER: float = log(SILVER)      # 0.88137358...
LOG2: float = log(2.0)


# ----------------------------------------------------------------------------
# Basic objects
# ----------------------------------------------------------------------------

def is_seed(m: int, n: int) -> bool:
    """A Euclid seed: m > n > 0, coprime, of opposite parity."""
    return m > n > 0 and gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(seed: Seed) -> Tuple[int, int, int]:
    """The primitive Pythagorean triple of a seed."""
    m, n = seed
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hypot(seed: Seed) -> int:
    """The hypotenuse c = m^2 + n^2."""
    m, n = seed
    return m * m + n * n


def b1(s: Seed) -> Seed:
    m, n = s
    return (2 * m - n, m)


def b2(s: Seed) -> Seed:
    m, n = s
    return (2 * m + n, m)


def b3(s: Seed) -> Seed:
    m, n = s
    return (m + 2 * n, n)


MOVES = {"B1": b1, "B2": b2, "B3": b3}
ROOT: Seed = (2, 1)


def hyperbolic_distance(seed: Seed) -> float:
    """d(i, z(m,n)) via the exact identity cosh d = (m^2+n^2+1)/(2m)."""
    m, n = seed
    return acosh((m * m + n * n + 1) / (2.0 * m))


def potential(seed: Seed) -> float:
    """The silver potential Phi(m,n) = m + (sqrt2 - 1) n."""
    m, n = seed
    return m + (SQRT2 - 1.0) * n


def run_word(word: str) -> Seed:
    """Apply a whitespace-separated word of moves, left to right, from the root."""
    s = ROOT
    for letter in word.split():
        s = MOVES[letter](s)
    return s


def level(k: int) -> Iterator[Seed]:
    """All 3^k seeds at depth k (breadth-first)."""
    frontier: List[Seed] = [ROOT]
    for _ in range(k):
        frontier = [f(s) for s in frontier for f in (b1, b2, b3)]
    return iter(frontier)


# ----------------------------------------------------------------------------
# Demo 1 -- the exact position identity and the logarithmic window
# ----------------------------------------------------------------------------

def demo_logarithmic_window() -> None:
    print("=" * 78)
    print("1.  cosh d = (m^2+n^2+1)/(2m), and  log m <= d <= log m + log 2")
    print("=" * 78)
    print(f"{'seed':>12} {'triple':>20} {'log m':>10} {'d':>10} "
          f"{'log m + log2':>13} {'d - log m':>10}")
    samples: List[Seed] = [(2, 1), (4, 1), (5, 2), (12, 5), (29, 12),
                           (100, 1), (985, 408), (1000, 999)]
    worst = 0.0
    for s in samples:
        m, _ = s
        d = hyperbolic_distance(s)
        lo, hi = log(m), log(m) + LOG2
        assert lo - 1e-12 <= d <= hi + 1e-12, "window violated"
        worst = max(worst, d - lo)
        print(f"{str(s):>12} {str(triple(s)):>20} {lo:10.6f} {d:10.6f} "
              f"{hi:13.6f} {d - lo:10.6f}")
    print(f"\nlargest observed excess d - log m : {worst:.6f}   (bound log 2 = {LOG2:.6f})")
    print("The excess equals log(1 + (n/m)^2) up to O(1/c); it tends to log 2")
    print("along the near-isoceles seeds and to 0 along the seeds (m, 1).\n")


# ----------------------------------------------------------------------------
# Demo 2 -- the silver potential is a common Lyapunov function
# ----------------------------------------------------------------------------

def demo_silver_potential() -> None:
    print("=" * 78)
    print("2.  Phi(B_i v) / Phi(v) <= 1 + sqrt2, with equality for the middle move")
    print("=" * 78)
    print(f"{'seed':>12} {'Phi':>12} {'B1 ratio':>12} {'B2 ratio':>12} {'B3 ratio':>12}")
    seeds: List[Seed] = [(2, 1), (4, 1), (5, 2), (12, 5), (8, 3), (29, 12), (100, 1),
                         (99, 98)]
    worst_ratio = 0.0
    for s in seeds:
        p = potential(s)
        r1 = potential(b1(s)) / p
        r2 = potential(b2(s)) / p
        r3 = potential(b3(s)) / p
        worst_ratio = max(worst_ratio, r1, r2, r3)
        print(f"{str(s):>12} {p:12.6f} {r1:12.8f} {r2:12.8f} {r3:12.8f}")
    print(f"\nmaximum ratio observed : {worst_ratio:.10f}")
    print(f"silver ratio 1 + sqrt2 : {SILVER:.10f}")
    print("B2 attains the bound exactly on every seed; B1 loses 2n and B3 loses")
    print("sqrt2 (m - n), which is why the seed condition n < m is exactly what")
    print("makes the constant 1 + sqrt2 work.\n")


# ----------------------------------------------------------------------------
# Demo 3 -- the sharp envelope, checked exhaustively level by level
# ----------------------------------------------------------------------------

def demo_envelope(max_depth: int = 8) -> None:
    print("=" * 78)
    print("3.  Exhaustive check of  d <= (k+1) log(1+sqrt2) + log 2  at depth k")
    print("=" * 78)
    print(f"{'k':>3} {'#nodes':>8} {'max m':>8} {'silver^(k+1)':>14} {'max d':>10} "
          f"{'envelope':>10} {'old bound':>10} {'argmax':>14}")
    for k in range(max_depth + 1):
        nodes = list(level(k))
        best = max(nodes, key=hyperbolic_distance)
        dmax = hyperbolic_distance(best)
        env = (k + 1) * LOG_SILVER + LOG2
        old = k * log(3.0) + 2.5 * LOG2
        assert dmax <= env + 1e-12, "envelope violated"
        print(f"{k:3d} {len(nodes):8d} {max(m for m, _ in nodes):8d} "
              f"{SILVER ** (k + 1):14.3f} {dmax:10.4f} {env:10.4f} {old:10.4f} "
              f"{str(best):>14}")
    print("\nThe maximiser is the Pell seed B2^k(2,1) at every depth: the pure")
    print("middle branch is extremal, exactly as the equality case predicts.\n")


# ----------------------------------------------------------------------------
# Demo 4 -- the trichotomy of pure branches
# ----------------------------------------------------------------------------

def demo_trichotomy(depths: Tuple[int, ...] = (5, 10, 20, 50, 200, 1000)) -> None:
    print("=" * 78)
    print("4.  Rates d_k / k along the three pure branches")
    print("=" * 78)
    print(f"{'k':>6} {'B1: (k+2,k+1)':>16} {'B2: Pell':>16} {'B3: (2k+2,1)':>16}")
    for k in depths:
        # pure B1 spine
        l_seed: Seed = (k + 2, k + 1)
        # pure B2 spine, computed by the Pell recursion
        m, n = ROOT
        for _ in range(k):
            m, n = 2 * m + n, m
        m_seed: Seed = (m, n)
        # pure B3 spine
        r_seed: Seed = (2 * k + 2, 1)
        # distance on the Pell spine is computed from the certified window,
        # since m has ~0.38 k digits and cosh overflows floats quickly
        d_mid = log(m) + math.log1p((n / m) ** 2)
        print(f"{k:6d} {hyperbolic_distance(l_seed) / k:16.8f} "
              f"{d_mid / k:16.8f} {hyperbolic_distance(r_seed) / k:16.8f}")
    print(f"\nlimits:  B1 -> 0,   B2 -> log(1+sqrt2) = {LOG_SILVER:.8f},   B3 -> 0")
    print(f"log 2 = {LOG2:.8f} < log(1+sqrt2) = {LOG_SILVER:.8f} "
          f"< log 3 = {log(3.0):.8f}")
    print("The pure-B3 branch uses the parabolic move B1 *never* and still has")
    print("rate 0; and no branch at all attains log 3.\n")


# ----------------------------------------------------------------------------
# Demo 5 -- the word sandwich
# ----------------------------------------------------------------------------

def demo_word_sandwich() -> None:
    print("=" * 78)
    print("5.  (#B2 + 1) log 2  <=  d  <=  (|w| + 1) log(1+sqrt2) + log 2")
    print("=" * 78)
    words = [
        "B2 B2 B2 B2 B2 B2",
        "B1 B1 B1 B1 B1 B1",
        "B3 B3 B3 B3 B3 B3",
        "B1 B2 B3 B1 B2 B3",
        "B2 B1 B2 B1 B2 B1",
        "B3 B3 B2 B3 B3 B2",
        "B1 B3 B1 B3 B1 B3",
    ]
    print(f"{'word':>20} {'seed':>16} {'#B2':>4} {'lower':>9} {'d':>9} {'upper':>9}")
    for w in words:
        s = run_word(w)
        letters = w.split()
        cm = letters.count("B2")
        lo = (cm + 1) * LOG2
        hi = (len(letters) + 1) * LOG_SILVER + LOG2
        d = hyperbolic_distance(s)
        assert lo - 1e-12 <= d <= hi + 1e-12, "sandwich violated"
        print(f"{w:>20} {str(s):>16} {cm:4d} {lo:9.5f} {d:9.5f} {hi:9.5f}")
    print("\nThe distance tracks the number of middle moves, not the word length:")
    print("six B1's or six B3's take you almost nowhere; six B2's take you far.\n")


# ----------------------------------------------------------------------------
# Demo 6 -- the optimal depth of a hypotenuse
# ----------------------------------------------------------------------------

def optimal_pell_depth(target: int) -> Tuple[int, Seed]:
    """Least k with hypotenuse of the Pell seed B2^k(2,1) at least `target`."""
    k = 0
    s: Seed = ROOT
    while hypot(s) < target:
        s = b2(s)
        k += 1
    return k, s


def demo_optimal_depth() -> None:
    print("=" * 78)
    print("6.  Minimal depth for hypotenuse >= N  is  log N / (2 log(1+sqrt2)) + O(1)")
    print("=" * 78)
    print(f"{'N':>14} {'lower bd':>10} {'Pell depth':>11} {'upper bd':>10} "
          f"{'log N / (2 log s)':>18}")
    for e in range(2, 15):
        N = 10 ** e
        lower = (log(N) - LOG2) / (2 * LOG_SILVER) - 1
        upper = (log(N) + LOG2) / (2 * LOG_SILVER)
        k, _ = optimal_pell_depth(N)
        pred = log(N) / (2 * LOG_SILVER)
        assert lower - 1e-9 <= k <= upper + 1e-9, "depth law violated"
        print(f"{N:14d} {lower:10.3f} {k:11d} {upper:10.3f} {pred:18.3f}")
    print(f"\nslope constant 1 / (2 log(1+sqrt2)) = {1/(2*LOG_SILVER):.6f}")
    print("Contrast: along the pure-B3 branch, hypotenuse ~ 4k^2 at depth k, so the")
    print("*deepest* node of hypotenuse N sits at depth of order sqrt(N).\n")


# ----------------------------------------------------------------------------
# Demo 7 -- the slope dynamics that explains everything
# ----------------------------------------------------------------------------

def demo_slope_dynamics(steps: int = 12) -> None:
    print("=" * 78)
    print("7.  Slope dynamics: t = n/m under B1: 1/(2-t), B2: 1/(2+t), B3: t/(1+2t)")
    print("=" * 78)
    print("The multiplicative expansion of m in one step is 2-t, 2+t, 1+2t")
    print("respectively; the middle move drives t to sqrt2 - 1 = "
          f"{SQRT2 - 1:.8f}, where its factor equals {SILVER:.8f}.\n")
    print(f"{'step':>5} {'B1 slope':>12} {'B1 factor':>11} {'B2 slope':>12} "
          f"{'B2 factor':>11} {'B3 slope':>12} {'B3 factor':>11}")
    t1 = t2 = t3 = 0.5
    for j in range(steps):
        print(f"{j:5d} {t1:12.8f} {2 - t1:11.8f} {t2:12.8f} {2 + t2:11.8f} "
              f"{t3:12.8f} {1 + 2 * t3:11.8f}")
        t1 = 1.0 / (2.0 - t1)
        t2 = 1.0 / (2.0 + t2)
        t3 = t3 / (1.0 + 2.0 * t3)
    print("\nB1 -> fixed point 1 (factor -> 1), B3 -> fixed point 0 (factor -> 1):")
    print("both parabolic, both metrically inert.  B2 -> sqrt2 - 1 (factor -> 1+sqrt2):")
    print("hyperbolic, and the sole carrier of the tree's metric growth.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  The silver growth rate of the Berggren tree of Pythagorean triples")
    print("#" * 78)
    print()
    demo_logarithmic_window()
    demo_silver_potential()
    demo_envelope()
    demo_trichotomy()
    demo_word_sandwich()
    demo_optimal_depth()
    demo_slope_dynamics()
    print("All assertions passed: every certified inequality held on every example.")


if __name__ == "__main__":
    main()
