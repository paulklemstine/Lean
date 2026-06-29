"""
Numerical demonstration of ReLU depth separation via the tent map.

This script illustrates, with concrete numbers, the theorems formalized in
the accompanying Lean 4 development:

  * tent(x) = 1 - |2x - 1| is a width-2 ReLU block:
        tent(x) = 1 - relu(2x - 1) - relu(1 - 2x)
  * tent^[k] is 2^k-Lipschitz and rises 0 -> 1 over width 2^{-k}
  * dyadic alternation: tent^[k](j / 2^k) = j mod 2
  * forced crossings: any eps-approximant (eps < 1/2) crosses 1/2
        in each of the 2^k dyadic subintervals  ==>  width >= 2^k
  * the two-point gap bound |f(a)-f(b)| <= K|a-b| + 2 eps unifies the
        tent (slope-blowup) and the exponential tower (range-blowup)

Everything is self-contained; only the Python standard library is used.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple


# --------------------------------------------------------------------------
# Core primitives
# --------------------------------------------------------------------------
def relu(x: float) -> float:
    """The rectified linear unit relu(x) = max(x, 0)."""
    return max(x, 0.0)


def tent(x: float) -> float:
    """The tent map tent(x) = 1 - |2x - 1|."""
    return 1.0 - abs(2.0 * x - 1.0)


def tent_via_relu(x: float) -> float:
    """The same tent, written explicitly as a width-2 ReLU layer."""
    return 1.0 - relu(2.0 * x - 1.0) - relu(1.0 - 2.0 * x)


def tent_iterate(k: int, x: float) -> float:
    """Apply the tent map k times: tent^[k](x)."""
    for _ in range(k):
        x = tent(x)
    return x


def iter_exp(k: int, x: float) -> float:
    """Iterated exponential tower: iterExp(0,x)=x, iterExp(n+1,x)=exp(iterExp(n,x))."""
    for _ in range(k):
        x = math.exp(x)
    return x


# --------------------------------------------------------------------------
# Demo 1: the tent really is a ReLU layer
# --------------------------------------------------------------------------
def demo_relu_representation() -> None:
    print("=" * 70)
    print("DEMO 1: tent(x) = 1 - relu(2x-1) - relu(1-2x)")
    print("=" * 70)
    max_err = 0.0
    for i in range(1001):
        x = i / 1000.0
        max_err = max(max_err, abs(tent(x) - tent_via_relu(x)))
    print(f"max |tent - tent_via_relu| over [0,1]: {max_err:.2e}")
    print("-> the tent map IS a width-2 one-hidden-layer ReLU network.\n")


# --------------------------------------------------------------------------
# Demo 2: exponential Lipschitz constant and the steep ramp
# --------------------------------------------------------------------------
def empirical_lipschitz(f: Callable[[float], float], n: int = 200000) -> float:
    """Estimate the Lipschitz constant of f on [0,1] by finite differences."""
    h = 1.0 / n
    best = 0.0
    prev = f(0.0)
    for i in range(1, n + 1):
        cur = f(i * h)
        best = max(best, abs(cur - prev) / h)
        prev = cur
    return best


def demo_slope_blowup() -> None:
    print("=" * 70)
    print("DEMO 2: tent^[k] is 2^k-Lipschitz; rises 0->1 over width 2^{-k}")
    print("=" * 70)
    print(f"{'k':>3} {'2^k':>10} {'empirical L':>14} "
          f"{'tent^k(0)':>11} {'tent^k(2^-k)':>13}")
    for k in range(1, 9):
        L = empirical_lipschitz(lambda x: tent_iterate(k, x), n=2 ** (k + 12))
        left = tent_iterate(k, 0.0)
        peak = tent_iterate(k, (0.5) ** k)
        print(f"{k:>3} {2 ** k:>10} {L:>14.2f} {left:>11.4f} {peak:>13.4f}")
    print("-> empirical Lipschitz constant tracks 2^k; the ramp 0->1 sits on"
          " width 2^{-k}.\n")


# --------------------------------------------------------------------------
# Demo 3: the depth-separation inequality (and its sharpness)
# --------------------------------------------------------------------------
def lipschitz_can_approximate(K: float, k: int, eps: float) -> bool:
    """
    Returns True iff the budget allows approximation, i.e. the separation
    hypothesis K * 2^{-k} + 2 eps < 1 FAILS.  When it holds, Theorem 4.5
    forbids any K-Lipschitz eps-approximant of tent^[k].
    """
    return not (K * (0.5) ** k + 2.0 * eps < 1.0)


def demo_separation_theorem() -> None:
    print("=" * 70)
    print("DEMO 3: depth separation  K*2^{-k} + 2 eps < 1  forbids approx")
    print("=" * 70)
    for k in (3, 5, 8):
        # constant g = 1/2 is 0-Lipschitz; smallest K to even stand a chance:
        threshold_K = 2.0 ** k          # exactly the sharp slope
        forbidden = lipschitz_can_approximate(0.0, k, eps=0.0) is False
        print(f"k={k}: g constant (K=0, eps=0) forbidden? {forbidden}; "
              f"need K >= 2^k = {int(threshold_K)} to approach the threshold")
    # sharpness: 2^k * (1/2)^k = 1 exactly
    for k in (1, 4, 10):
        val = (2.0 ** k) * (0.5 ** k)
        print(f"sharpness check 2^{k} * (1/2)^{k} = {val:.6f}  (=1 exactly)")
    print()


# --------------------------------------------------------------------------
# Demo 4: dyadic alternation tent^[k](j/2^k) = j mod 2
# --------------------------------------------------------------------------
def demo_dyadic_alternation() -> None:
    print("=" * 70)
    print("DEMO 4: dyadic alternation  tent^[k](j/2^k) = j mod 2")
    print("=" * 70)
    for k in (2, 3, 4):
        vals: List[int] = []
        ok = True
        for j in range(2 ** k + 1):
            v = tent_iterate(k, j / 2 ** k)
            vals.append(round(v))
            if abs(v - (j % 2)) > 1e-9:
                ok = False
        print(f"k={k}: {vals}  matches j mod 2? {ok}")
    print("-> the deep tent is a pure 0,1,0,1,... sawtooth on the dyadic grid.\n")


# --------------------------------------------------------------------------
# Demo 5: forced crossings  ==>  width >= 2^k
# --------------------------------------------------------------------------
def count_level_crossings(samples: List[float], level: float = 0.5) -> int:
    """Count sign changes of (sample - level): number of times the level is crossed."""
    crossings = 0
    prev = samples[0] - level
    for s in samples[1:]:
        cur = s - level
        if prev == 0.0:
            prev = cur
            continue
        if cur == 0.0 or (prev < 0.0) != (cur < 0.0):
            crossings += 1
        prev = cur
    return crossings


def demo_forced_crossings() -> None:
    print("=" * 70)
    print("DEMO 5: tent^[k] crosses level 1/2 exactly 2^k times -> width >= 2^k")
    print("=" * 70)
    for k in range(1, 8):
        n = 200 * 2 ** k
        samples = [tent_iterate(k, i / n) for i in range(n + 1)]
        c = count_level_crossings(samples, level=0.5)
        print(f"k={k}: counted crossings of 1/2 = {c:>4}   (2^k = {2 ** k})   "
              f"min width forced >= {2 ** k}")
    print("-> a width-w piecewise-linear net crosses a level <= w times,"
          " so w >= 2^k.\n")


# --------------------------------------------------------------------------
# Demo 6: the unifying two-point gap bound (tent vs exponential tower)
# --------------------------------------------------------------------------
def two_point_budget(K: float, a: float, b: float, eps: float) -> float:
    """Right-hand side K*|a-b| + 2 eps of the unifying inequality."""
    return K * abs(a - b) + 2.0 * eps


def demo_two_point_obstruction() -> None:
    print("=" * 70)
    print("DEMO 6: one inequality |f(a)-f(b)| <= K|a-b| + 2 eps for both")
    print("=" * 70)
    eps = 0.0
    print("TENT (slope blow-up): a=0, b=2^{-k}, gap=1, distance shrinks")
    for k in (3, 6, 9):
        a, b = 0.0, 0.5 ** k
        gap = abs(tent_iterate(k, a) - tent_iterate(k, b))
        K_needed = (gap - 2 * eps) / abs(a - b)
        print(f"  k={k}: gap={gap:.3f}, distance={abs(a-b):.2e}, "
              f"K needed > {K_needed:.1f} (= 2^k = {2 ** k})")
    print("EXP TOWER (range blow-up): a=0, b=1, distance=1, gap explodes")
    for k in (1, 2, 3):
        a, b = 0.0, 1.0
        try:
            gap = iter_exp(k, b) - iter_exp(k, a)
        except OverflowError:
            print(f"  k={k}: gap overflows double precision (tower too tall)")
            continue
        K_needed = (gap - 2 * eps) / abs(a - b)
        print(f"  k={k}: gap={gap:.3e}, distance=1, K needed > {K_needed:.3e}")
    print("-> tent shrinks the denominator; the tower inflates the numerator.\n")


# --------------------------------------------------------------------------
# Demo 7: adversarial reading of the slope blow-up
# --------------------------------------------------------------------------
def demo_adversarial() -> None:
    print("=" * 70)
    print("DEMO 7: adversarial pair  |g(0)-g(2^-k)| < 1 = |true labels gap|")
    print("=" * 70)
    for k in (4, 6, 8):
        K = 2.0 ** k - 1.0          # any Lipschitz constant below 2^k
        max_g_gap = K * (0.5) ** k  # best a K-Lipschitz g can do
        true_gap = abs(tent_iterate(k, 0.0) - tent_iterate(k, (0.5) ** k))
        print(f"k={k}: K={K:.0f} < 2^k -> |g gap| <= {max_g_gap:.4f} "
              f"< true gap = {true_gap:.1f}")
    print("-> a sub-2^k-Lipschitz model cannot separate a 2^{-k}-close"
          " adversarial pair whose true labels are 0 and 1.\n")


def main() -> None:
    demo_relu_representation()
    demo_slope_blowup()
    demo_separation_theorem()
    demo_dyadic_alternation()
    demo_forced_crossings()
    demo_two_point_obstruction()
    demo_adversarial()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
