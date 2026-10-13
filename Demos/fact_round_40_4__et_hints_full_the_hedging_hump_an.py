#!/usr/bin/env python3
"""
The Hedging Hump and Placement-Structured Ceilings -- numerical companion.

Setting.  Two numbers p, q are drawn independently and uniformly from {1, ..., M}.
A searcher wants J = min(p, q) and probes the cells 1, 2, ... in some order; the cost
is the number of probes until J is found.  The prior of J is the "min-law"

    P(J = i + 1) = (2 (M - 1 - i) + 1) / M^2,   i = 0, ..., M - 1,

which is strictly decreasing, so the optimal blind order is ascending, with expected
cost B(M) = (M + 1)(2M + 1) / (6M)   (B(512) = 171.17).

An oracle names a window S of cells.  Trusting it at level alpha means putting mass
alpha on S and 1 - alpha off S, each spread proportionally to the prior.  The
Bayes-optimal searcher probes cells in decreasing posterior order; its expected cost
is E(alpha).

This script reproduces every headline number of the paper with exact rational
arithmetic (fractions.Fraction) wherever that is cheap, and floats elsewhere.
Only the Python standard library is used.
"""
from __future__ import annotations

import itertools
import math
import random
from fractions import Fraction
from typing import Callable, List, Sequence, Tuple

Num = Fraction


# ---------------------------------------------------------------------------
# Core objects
# ---------------------------------------------------------------------------

def min_law(M: int) -> List[Fraction]:
    """Prior of J = min(p, q) on cells 0..M-1 (cell i means J = i + 1)."""
    return [Fraction(2 * (M - 1 - i) + 1, M * M) for i in range(M)]


def probe_cost(q: Sequence[Fraction], order: Sequence[int]) -> Fraction:
    """Expected number of probes when the cells are visited in `order`."""
    return sum((Fraction(k + 1) * q[c] for k, c in enumerate(order)), Fraction(0))


def opt_cost(q: Sequence[Fraction]) -> Fraction:
    """Bayes-optimal cost: visit cells in decreasing weight (the rearrangement inequality)."""
    w = sorted(q, reverse=True)
    return sum((Fraction(k + 1) * x for k, x in enumerate(w)), Fraction(0))


def window_mass(p: Sequence[Fraction], S: set[int]) -> Fraction:
    return sum((p[j] for j in S), Fraction(0))


def trust_posterior(p: Sequence[Fraction], S: set[int], alpha: Fraction) -> List[Fraction]:
    """Prior-proportional posterior after trusting 'J in S' at level alpha."""
    P = window_mass(p, S)
    return [(alpha / P if j in S else (1 - alpha) / (1 - P)) * p[j] for j in range(len(p))]


def trust_cost(p: Sequence[Fraction], S: set[int], alpha: Fraction) -> Fraction:
    return opt_cost(trust_posterior(p, S, alpha))


def blind_cost(M: int) -> Fraction:
    return Fraction((M + 1) * (2 * M + 1), 6 * M)


def right_window(M: int, W: int) -> set[int]:
    return set(range(M - W, M))


def left_window(M: int, W: int) -> set[int]:
    return set(range(W))


def centered_window(M: int, W: int) -> set[int]:
    s = (M - W) // 2
    return set(range(s, s + W))


# ---------------------------------------------------------------------------
# 1. Exhaustive check that sorting is optimal (small M)
# ---------------------------------------------------------------------------

def demo_exhaustive_sorting() -> None:
    print("=" * 72)
    print("1. Sorting is Bayes-optimal: exhaustive check over all M! orders")
    print("=" * 72)
    rng = random.Random(20260824)
    worst_gap = 0.0
    for M in range(5, 9):
        p = min_law(M)
        for W in range(1, M):
            for S in (right_window(M, W), left_window(M, W)):
                alpha = Fraction(rng.randint(1, 99), 100)
                q = trust_posterior(p, S, alpha)
                brute = min(probe_cost(q, perm) for perm in itertools.permutations(range(M)))
                worst_gap = max(worst_gap, abs(float(brute - opt_cost(q))))
        print(f"  M = {M}: all windows checked")
    print(f"  largest gap between brute force and sorting: {worst_gap:.1e}\n")


# ---------------------------------------------------------------------------
# 2. The hedging hump (Theorem A)
# ---------------------------------------------------------------------------

def hump_curve(M: int, S: set[int], steps: int = 200) -> List[Tuple[float, float]]:
    p = min_law(M)
    return [(k / steps, float(trust_cost(p, S, Fraction(k, steps)))) for k in range(steps + 1)]


def demo_hedging_hump() -> None:
    print("=" * 72)
    print("2. The hedging hump: E(alpha) is concave and exceeds the blind cost")
    print("=" * 72)
    M = 512
    B = float(blind_cost(M))
    print(f"  M = {M}, blind optimal cost B = (M+1)(2M+1)/(6M) = {B:.2f}")
    print(f"  absolute ceiling (M+1)/2 = {(M + 1) / 2:.1f}")
    for name, S in (("right x=1/4", right_window(M, 128)),
                    ("right x=1/2", right_window(M, 256)),
                    ("left  x=1/4", left_window(M, 128)),
                    ("center x=1/4", centered_window(M, 128)),
                    ("right x=1/64", right_window(M, 8))):
        curve = hump_curve(M, S)
        a_star, peak = max(curve, key=lambda t: t[1])
        P = float(window_mass(min_law(M), S))
        print(f"  {name:13s}: P(S) = {P:.4f}  E(0) = {curve[0][1]:7.2f}  "
              f"E(1) = {curve[-1][1]:7.2f}  peak {peak:7.2f} at alpha = {a_star:.3f}")
    print("  -> every placement shows a hump above B; partial trust is the costliest regime.\n")


# ---------------------------------------------------------------------------
# 3. The placement law (Theorem B)
# ---------------------------------------------------------------------------

def placement_cost_direct(M: int, s: int, W: int) -> Fraction:
    p = min_law(M)
    Z = sum(p[s:s + W], Fraction(0))
    return sum((Fraction(r + 1) * p[s + r] for r in range(W)), Fraction(0)) / Z


def placement_cost_formula(M: int, s: int, W: int) -> Fraction:
    d = M - s
    return Fraction((W + 1) * (6 * d - 4 * W + 1), 6 * (2 * d - W))


def demo_placement_law() -> None:
    print("=" * 72)
    print("3. Placement law  E = (W+1)(6d-4W+1) / (6(2d-W)),  d = M - s")
    print("=" * 72)
    ok = all(placement_cost_direct(M, s, W) == placement_cost_formula(M, s, W)
             for M in range(1, 40) for W in range(1, M + 1) for s in range(0, M - W + 1))
    print(f"  exact agreement for all 1 <= W <= M < 40 and all placements: {ok}")
    M = 256
    B = blind_cost(M)
    print(f"  M = {M}, perfect coverage (alpha = 1), speedup = B / E:")
    print(f"  {'x':>6s} {'left':>8s} {'center':>8s} {'right':>8s} {'1/x':>6s} "
          f"{'2/(3x)':>8s}")
    for W in (4, 8, 16, 32, 64):
        x = W / M
        sp = [float(B / placement_cost_formula(M, s, W)) for s in (0, (M - W) // 2, M - W)]
        print(f"  1/{M // W:<4d} {sp[0]:8.2f} {sp[1]:8.2f} {sp[2]:8.2f} {1 / x:6.0f} "
              f"{2 / (3 * x):8.2f}")
    best = B / placement_cost_formula(256, 240, 16)
    print(f"  best cell (right, x = 1/16): {best} = {float(best):.4f}  (ceiling 16)")
    print("  asymptotic law k(2m-1)/(3m-2): right/left ratio (3k-2)/(2k-1) -> 3/2:")
    for k in (4, 16, 64, 1024):
        print(f"    k = {k:5d}: ratio = {(3 * k - 2) / (2 * k - 1):.4f}")
    print()


# ---------------------------------------------------------------------------
# 4. The 5.19x crossing for left windows
# ---------------------------------------------------------------------------

def left_committed_speedup(M: int, W: int, alpha: float) -> float:
    p = [float(v) for v in min_law(M)]
    P = sum(p[:W])
    cost = sum((j + 1) * (alpha / P if j < W else (1 - alpha) / (1 - P)) * p[j]
               for j in range(M))
    return float(blind_cost(M)) / cost


def bisect(f: Callable[[float], float], lo: float, hi: float, it: int = 60) -> float:
    for _ in range(it):
        mid = (lo + hi) / 2
        if f(mid) < 0:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


def demo_crossing() -> None:
    print("=" * 72)
    print("4. Trust needed for a 5.19x speedup (left window, ascending committed scan)")
    print("=" * 72)
    for M in (256, 512, 1024):
        row = []
        for frac in (64, 8):
            W = M // frac
            a = bisect(lambda t: left_committed_speedup(M, W, t) - 5.19, 0.0, 1.0)
            row.append(f"x=1/{frac}: alpha* = {a:.4f}")
        print(f"  M = {M:5d}:  " + "   ".join(row))
    print("  -> the useful regime is narrow AND near-certain.\n")


# ---------------------------------------------------------------------------
# 5. The calibration gate (Theorem C)
# ---------------------------------------------------------------------------

def demo_calibration_gate() -> None:
    print("=" * 72)
    print("5. Calibration gate for uniform-given-hit hints")
    print("=" * 72)
    M = 512
    p = min_law(M)
    for name, S in (("right x=1/16", right_window(M, 32)), ("left  x=1/16", left_window(M, 32))):
        W = len(S)
        lightest = min(p[j] for j in S)
        cap = W * lightest            # r * alpha <= W * min_{j in S} p_j
        print(f"  {name}: lightest window cell {float(lightest):.2e},  "
              f"r*alpha <= {float(cap):.3e}")
    print(f"  right window: alpha * (expected saving) < x = {32 / M:.4f} probe, "
          f"versus blind cost {float(blind_cost(M)):.2f}")
    print(f"  calibrated trust of the right window = x^2 = {(32 / M) ** 2:.5f}")
    # An explicit calibrated uniform-given-hit signal at the cap, built by hand:
    W = 32
    S = sorted(right_window(M, W))
    alpha = Fraction(1)
    r = Fraction(W) * min(p[j] for j in S)        # largest admissible firing rate
    q = [alpha / W if j in S else Fraction(0) for j in range(M)]
    qprime = [(p[j] - r * q[j]) / (1 - r) for j in range(M)]
    assert all(v >= 0 for v in qprime) and sum(qprime) == 1
    saving = opt_cost(p) - (r * opt_cost(q) + (1 - r) * opt_cost(qprime))
    print(f"  extremal signal: r = {float(r):.3e}, saving = {float(saving):.4f} probes "
          f"(bound r(M-1) = {float(r * (M - 1)):.4f})\n")


# ---------------------------------------------------------------------------
# 6. Monte Carlo cross-check
# ---------------------------------------------------------------------------

def demo_monte_carlo(trials: int = 20000) -> None:
    print("=" * 72)
    print("6. Monte Carlo: simulate the searcher on calibrated draws")
    print("=" * 72)
    rng = random.Random(20260824)
    M, W = 64, 16
    p = min_law(M)
    S = right_window(M, W)
    for alpha in (Fraction(0), Fraction(1, 4), Fraction(1)):
        q = trust_posterior(p, S, alpha)
        order = sorted(range(M), key=lambda j: -q[j])
        rank = {c: k + 1 for k, c in enumerate(order)}
        # draw J from the posterior q (the world in which the trust level is correct)
        cells, weights = list(range(M)), [float(v) for v in q]
        samples = [rank[rng.choices(cells, weights)[0]] for _ in range(trials)]
        mean = sum(samples) / trials
        var = sum((s - mean) ** 2 for s in samples) / (trials - 1)
        z = (mean - float(opt_cost(q))) / math.sqrt(var / trials)
        print(f"  alpha = {str(alpha):4s}: exact E = {float(opt_cost(q)):6.3f}, "
              f"simulated {mean:6.3f}, z = {z:+.2f}")
    print()


if __name__ == "__main__":
    demo_exhaustive_sorting()
    demo_hedging_hump()
    demo_placement_law()
    demo_crossing()
    demo_calibration_gate()
    demo_monte_carlo()
