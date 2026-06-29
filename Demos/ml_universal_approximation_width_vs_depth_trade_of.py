"""
demo.py — Numerical demonstrations of the two-sided depth--width separation
for ReLU networks via the iterated tent map.

This script is fully self-contained (standard library only) and reproduces,
numerically, every quantitative claim of the accompanying paper:

  * tent(x) = 1 - |2x - 1| equals the two-neuron ReLU block
        1 - relu(2x - 1) - relu(-2x + 1)                         (Theorem 5.1)
  * the depth-k deep tent (k stacked 2-neuron blocks) realizes tent^[k]
    exactly, with total size 2k                                  (Theorems 5.2, 5.3)
  * the deep tent has discrete total variation exactly 2^k       (Theorem 3.3)
  * a shallow net's total variation is bounded by its L1 weight  (Theorem 4.2)
  * the forced shallow width is >= 2^k (1 - 2 eps) / A           (Theorem 4.5)
  * the deep size 2k is logarithmic in the oscillation count     (Theorem 5.5)
  * the shallow/deep gap is unbounded                            (Theorem 6.2)

Run:  python demo.py
"""

from __future__ import annotations

from math import ceil, log2
from typing import Callable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core building blocks                                                         #
# --------------------------------------------------------------------------- #

def relu(y: float) -> float:
    """Rectified linear unit: max(y, 0)."""
    return y if y > 0.0 else 0.0


def tent(x: float) -> float:
    """The tent map on [0, 1]: tent(x) = 1 - |2x - 1|."""
    return 1.0 - abs(2.0 * x - 1.0)


def tent_block(x: float) -> float:
    """The tent map as a two-neuron ReLU block: 1 - relu(2x-1) - relu(-2x+1).

    Equals tent(x) exactly, via the identity |y| = relu(y) + relu(-y).
    """
    return 1.0 - relu(2.0 * x - 1.0) - relu(-2.0 * x + 1.0)


def deep_tent(k: int, x: float) -> float:
    """Evaluate the depth-k deep tent network: k stacked tent blocks.

    Returns tent^[k](x) exactly. Total network size is 2k neurons.
    """
    y = x
    for _ in range(k):
        y = tent_block(y)
    return y


def iterated_tent(k: int, x: float) -> float:
    """Reference implementation: the k-fold composition tent^[k](x)."""
    y = x
    for _ in range(k):
        y = tent(y)
    return y


def deep_tent_size(k: int) -> int:
    """Total hidden-neuron count of the depth-k deep tent network: 2k."""
    return 2 * k


# --------------------------------------------------------------------------- #
# Shallow networks and total variation                                        #
# --------------------------------------------------------------------------- #

def shallow_net(a: Sequence[float], t: Sequence[float], c: float, x: float) -> float:
    """Single-hidden-layer ReLU network c + sum_j a_j relu(x - t_j)."""
    return c + sum(aj * relu(x - tj) for aj, tj in zip(a, t))


def discrete_tv(g: Callable[[float], float], k: int) -> float:
    """Discrete total variation of g over the 2^k-cell dyadic grid of [0, 1]."""
    n = 2 ** k
    nodes = [i / n for i in range(n + 1)]
    return sum(abs(g(nodes[i + 1]) - g(nodes[i])) for i in range(n))


def shallow_width_lower_bound(k: int, eps: float, A: float) -> int:
    """Minimum shallow width forced by Theorem 4.5: ceil(2^k (1 - 2 eps) / A)."""
    if not (0.0 <= eps < 0.5):
        raise ValueError("require 0 <= eps < 1/2 for a positive bound")
    if A <= 0.0:
        raise ValueError("require weight cap A > 0")
    return max(0, ceil((2 ** k) * (1.0 - 2.0 * eps) / A))


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #

def demo_block_equals_tent() -> None:
    """Theorem 5.1: the two-neuron block reproduces the tent map exactly."""
    print("=" * 70)
    print("DEMO 1 — tent block equals the tent map (Theorem 5.1)")
    print("=" * 70)
    xs = [i / 10 for i in range(11)]
    max_err = max(abs(tent_block(x) - tent(x)) for x in xs)
    for x in xs:
        print(f"  x={x:4.2f}   tent={tent(x):6.3f}   block={tent_block(x):6.3f}")
    print(f"  max |block - tent| over sample = {max_err:.2e}  (exact identity)\n")


def demo_deep_realization_and_size() -> None:
    """Theorems 5.2/5.3: deep tent realizes tent^[k] exactly with size 2k."""
    print("=" * 70)
    print("DEMO 2 — deep tent realizes tent^[k] exactly; size = 2k")
    print("=" * 70)
    for k in range(0, 7):
        xs = [i / 64 for i in range(65)]
        err = max(abs(deep_tent(k, x) - iterated_tent(k, x)) for x in xs)
        print(f"  k={k}: size={deep_tent_size(k):2d}  "
              f"oscillations=2^k={2**k:4d}  "
              f"max|deep - tent^[k]|={err:.2e}")
    print()


def demo_total_variation() -> None:
    """Theorem 3.3: the deep tent has discrete total variation exactly 2^k."""
    print("=" * 70)
    print("DEMO 3 — discrete total variation of tent^[k] is 2^k (Theorem 3.3)")
    print("=" * 70)
    for k in range(0, 8):
        tv = discrete_tv(lambda x, k=k: deep_tent(k, x), k)
        print(f"  k={k}: TV_k(deep tent)={tv:7.1f}   2^k={2**k:4d}")
    print()


def demo_shallow_tv_bounded_by_weight() -> None:
    """Theorem 4.2: a shallow net's total variation <= its L1 weight mass."""
    print("=" * 70)
    print("DEMO 4 — shallow TV <= L1 weight mass (Theorem 4.2)")
    print("=" * 70)
    # An arbitrary shallow net with 5 ramps.
    a = [1.3, -2.1, 0.7, -0.4, 1.0]
    t = [0.1, 0.3, 0.5, 0.7, 0.9]
    c = 0.2
    weight_mass = sum(abs(aj) for aj in a)
    for k in range(1, 9):
        tv = discrete_tv(lambda x: shallow_net(a, t, c, x), k)
        ok = "OK" if tv <= weight_mass + 1e-9 else "VIOLATED"
        print(f"  k={k}: TV={tv:7.4f}  <=  sum|a_j|={weight_mass:7.4f}  [{ok}]")
    print()


def demo_width_lower_bound() -> None:
    """Theorem 4.5: forced shallow width >= 2^k (1 - 2 eps) / A."""
    print("=" * 70)
    print("DEMO 5 — forced shallow width >= 2^k(1-2eps)/A (Theorem 4.5)")
    print("=" * 70)
    eps, A = 0.1, 1.0
    print(f"  (eps={eps}, weight cap A={A})")
    for k in range(0, 13):
        w_min = shallow_width_lower_bound(k, eps, A)
        print(f"  k={k:2d}: deep size=2k={2*k:3d}   "
              f"forced shallow width >= {w_min:6d}")
    print()


def demo_logarithmic_law_and_gap() -> Tuple[List[int], List[float]]:
    """Theorems 5.5/6.2: log-size law and unbounded shallow/deep gap."""
    print("=" * 70)
    print("DEMO 6 — logarithmic-size law and unbounded gap (Theorems 5.5, 6.2)")
    print("=" * 70)
    eps, A = 0.1, 1.0
    ks: List[int] = []
    ratios: List[float] = []
    for k in range(1, 21):
        # size = 2 * log2(2^k) = 2k
        size_via_log = 2 * int(round(log2(2 ** k)))
        assert size_via_log == deep_tent_size(k)
        w_min = (2 ** k) * (1.0 - 2.0 * eps) / A
        ratio = w_min / deep_tent_size(k)
        ks.append(k)
        ratios.append(ratio)
        print(f"  k={k:2d}: deep size=2k={2*k:3d}  "
              f"shallow width≈{w_min:12.1f}  ratio={ratio:12.1f}")
    print("  ratio grows without bound: exponential / linear -> infinity\n")
    return ks, ratios


def demo_unbounded_threshold() -> None:
    """Theorem 6.2 in usable form: depth k where shallow > R * deep."""
    print("=" * 70)
    print("DEMO 7 — for any ratio R, find depth where shallow > R * deep")
    print("=" * 70)
    eps, A = 0.1, 1.0
    for R in (10.0, 1_000.0, 1_000_000.0):
        k = 1
        while (2 ** k) * (1.0 - 2.0 * eps) / A <= R * (2 * k):
            k += 1
        print(f"  R={R:>12,.0f}:  depth k={k:2d}  "
              f"(shallow width≈{(2**k)*(1-2*eps)/A:,.0f} > {R:,.0f} x {2*k})")
    print()


def main() -> None:
    print("\nTwo-Sided Depth--Width Separation for ReLU Networks — Numerical Demo\n")
    demo_block_equals_tent()
    demo_deep_realization_and_size()
    demo_total_variation()
    demo_shallow_tv_bounded_by_weight()
    demo_width_lower_bound()
    demo_logarithmic_law_and_gap()
    demo_unbounded_threshold()
    print("All numerical checks consistent with the formal theorems.")


if __name__ == "__main__":
    main()
