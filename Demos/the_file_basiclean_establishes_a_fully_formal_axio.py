"""
Numerical demonstrations for the ReLU depth-separation theorem via the tent map.

This script is fully self-contained: every function is inlined and uses only the
Python standard library. It illustrates, numerically, the theorems proved formally
in `Basic.lean`:

  * tent(x) = 1 - |2x - 1|                                    (the depth-1 ReLU block)
  * tent(x) = 1 - relu(2x - 1) - relu(1 - 2x)                 (tent_relu_repr)
  * tent is 2-Lipschitz; tent^[k] is 2^k-Lipschitz           (tent_iterate_lipschitz)
  * tent^[k](0) = 0                                           (tent_iterate_zero)
  * tent^[k]((1/2)^k) = 1                                     (tent_iterate_peak)
  * K * 2^-k + 2*eps < 1  ==>  no K-Lipschitz eps-approx     (relu_depth_separation)
  * 2^k * 2^-k + 0 = 1                                        (relu_depth_separation_sharp)

Run with:  python3 demo.py
"""

from __future__ import annotations

from typing import Callable, List, Tuple


# ----------------------------------------------------------------------------- #
# Core definitions (mirroring the Lean source of truth)
# ----------------------------------------------------------------------------- #
def relu(x: float) -> float:
    """ReLU activation: relu(x) = max(x, 0)."""
    return max(x, 0.0)


def tent(x: float) -> float:
    """The tent map: tent(x) = 1 - |2x - 1|, a width-2 one-hidden-layer ReLU block."""
    return 1.0 - abs(2.0 * x - 1.0)


def tent_via_relu(x: float) -> float:
    """tent(x) realized as a width-2 ReLU layer: 1 - relu(2x-1) - relu(1-2x)."""
    return 1.0 - relu(2.0 * x - 1.0) - relu(1.0 - 2.0 * x)


def tent_iterate(k: int, x: float) -> float:
    """The depth-k tent network tent^[k](x): apply the tent map k times."""
    t: float = x
    for _ in range(k):
        t = tent(t)
    return t


# ----------------------------------------------------------------------------- #
# Algorithm B: empirical Lipschitz constant on a grid
# ----------------------------------------------------------------------------- #
def empirical_lipschitz(f: Callable[[float], float],
                        a: float, b: float, n: int) -> float:
    """Largest finite-difference slope of f on [a, b] over n+1 uniform samples.

    For tent^[k] on its first ramp this approaches the true Lipschitz constant 2^k.
    """
    xs: List[float] = [a + (b - a) * i / n for i in range(n + 1)]
    best: float = 0.0
    for i in range(n):
        dx = xs[i + 1] - xs[i]
        if dx == 0.0:
            continue
        slope = abs(f(xs[i + 1]) - f(xs[i])) / dx
        best = max(best, slope)
    return best


# ----------------------------------------------------------------------------- #
# Algorithm C: separation certificate (relu_depth_separation)
# ----------------------------------------------------------------------------- #
def separation_budget(k: int, K: float, eps: float) -> float:
    """The separation budget K * 2^-k + 2*eps from relu_depth_separation."""
    return K * (0.5 ** k) + 2.0 * eps


def separation_certificate(k: int, K: float, eps: float) -> bool:
    """True iff Theorem relu_depth_separation CERTIFIES that no K-Lipschitz function
    can eps-approximate tent^[k] on [0,1] (i.e. the budget is strictly below 1)."""
    return separation_budget(k, K, eps) < 1.0


# ----------------------------------------------------------------------------- #
# Oscillation count: tent^[k] is a comb of 2^k spikes
# ----------------------------------------------------------------------------- #
def count_level_crossings(f: Callable[[float], float],
                          level: float, n: int) -> int:
    """Count sign changes of f - level over a uniform grid of n+1 points on [0,1].

    For tent^[k] and level 1/2 this approaches 2^k, the exact oscillation count.
    """
    xs: List[float] = [i / n for i in range(n + 1)]
    vals: List[float] = [f(x) - level for x in xs]
    crossings: int = 0
    for i in range(n):
        if vals[i] == 0.0:
            continue
        if vals[i] * vals[i + 1] < 0.0:
            crossings += 1
    return crossings


# ----------------------------------------------------------------------------- #
# Demonstrations
# ----------------------------------------------------------------------------- #
def demo_relu_representation() -> None:
    print("=" * 70)
    print("1. The tent map IS a width-2 ReLU layer (tent_relu_repr)")
    print("=" * 70)
    print(f"{'x':>8} | {'tent(x)':>10} | {'relu form':>10} | {'match':>6}")
    for i in range(11):
        x = i / 10.0
        a, b = tent(x), tent_via_relu(x)
        print(f"{x:>8.2f} | {a:>10.4f} | {b:>10.4f} | {abs(a - b) < 1e-12!s:>6}")
    print()


def demo_steep_ramp() -> None:
    print("=" * 70)
    print("2. The exponentially steep ramp (tent_iterate_zero / tent_iterate_peak)")
    print("=" * 70)
    print(f"{'k':>3} | {'tent^[k](0)':>14} | {'(1/2)^k':>14} | {'tent^[k]((1/2)^k)':>18}")
    for k in range(0, 11):
        left = tent_iterate(k, 0.0)
        peak_x = 0.5 ** k
        peak_val = tent_iterate(k, peak_x)
        print(f"{k:>3} | {left:>14.6f} | {peak_x:>14.3e} | {peak_val:>18.6f}")
    print("  -> the network rises 0 -> 1 over an interval of width 2^-k.")
    print()


def demo_lipschitz_growth() -> None:
    print("=" * 70)
    print("3. Lipschitz constant grows like 2^k (tent_iterate_lipschitz)")
    print("=" * 70)
    print(f"{'k':>3} | {'2^k (theory)':>14} | {'empirical slope on ramp':>26}")
    for k in range(0, 11):
        f = lambda x, kk=k: tent_iterate(kk, x)
        # Sample the first ramp [0, 2^-k] finely to recover the steep slope.
        emp = empirical_lipschitz(f, 0.0, 0.5 ** k, 2000)
        print(f"{k:>3} | {2 ** k:>14d} | {emp:>26.4f}")
    print()


def demo_oscillation() -> None:
    print("=" * 70)
    print("4. tent^[k] is a comb of 2^k spikes (level-1/2 crossing count)")
    print("=" * 70)
    print(f"{'k':>3} | {'2^k (theory)':>14} | {'crossings of level 1/2':>24}")
    for k in range(0, 9):
        f = lambda x, kk=k: tent_iterate(kk, x)
        # Use a fine grid (>> 2^k) so all spikes are resolved. An ODD grid count
        # avoids landing exactly on the dyadic crossing points (where f == 1/2).
        c = count_level_crossings(f, 0.5, 199_999)
        print(f"{k:>3} | {2 ** k:>14d} | {c:>24d}")
    print()


def demo_separation_certificate() -> None:
    print("=" * 70)
    print("5. Separation certificates (relu_depth_separation)")
    print("=" * 70)
    print("A certificate 'True' means: NO K-Lipschitz g can eps-approximate tent^[k].")
    cases: List[Tuple[int, float, float]] = [
        (3, 0.0, 3.0 / 8.0),   # constant 1/2 (K=0) vs depth-3, eps small
        (3, 1.0, 0.0),         # mild slope, no error
        (10, 100.0, 0.01),     # K=100 < 2^10=1024
        (10, 1024.0, 0.0),     # K = 2^10 EXACTLY: budget hits 1 (no certificate)
        (20, 1000.0, 0.1),     # huge depth, modest shallow budget
    ]
    print(f"{'k':>3} | {'K':>8} | {'eps':>6} | {'budget':>10} | {'certified?':>11}")
    for k, K, eps in cases:
        budget = separation_budget(k, K, eps)
        cert = separation_certificate(k, K, eps)
        print(f"{k:>3} | {K:>8.1f} | {eps:>6.3f} | {budget:>10.5f} | {cert!s:>11}")
    print()


def demo_sharpness() -> None:
    print("=" * 70)
    print("6. The threshold is sharp (relu_depth_separation_sharp)")
    print("=" * 70)
    print("The honest deep solution g = tent^[k] has K = 2^k, eps = 0,")
    print("and saturates the bound to EQUALITY: 2^k * 2^-k + 0 = 1.")
    print(f"{'k':>3} | {'2^k * 2^-k + 2*0':>18}")
    for k in range(0, 11):
        val = (2 ** k) * (0.5 ** k) + 2.0 * 0.0
        print(f"{k:>3} | {val:>18.12f}")
    print("  -> always exactly 1.0; the strict inequality cannot be relaxed to <=.")
    print()


def demo_adversarial() -> None:
    print("=" * 70)
    print("7. Depth-induced fragility (the robustness reading)")
    print("=" * 70)
    print("Inputs 0 and 2^-k differ by 2^-k yet outputs differ by the full range 1.")
    print(f"{'k':>3} | {'input gap 2^-k':>16} | {'output gap':>12}")
    for k in range(1, 21, 2):
        gap_in = 0.5 ** k
        gap_out = abs(tent_iterate(k, 0.5 ** k) - tent_iterate(k, 0.0))
        print(f"{k:>3} | {gap_in:>16.3e} | {gap_out:>12.6f}")
    print("  -> an imperceptible 2^-k perturbation flips the output across [0,1].")
    print()


def main() -> None:
    demo_relu_representation()
    demo_steep_ramp()
    demo_lipschitz_growth()
    demo_oscillation()
    demo_separation_certificate()
    demo_sharpness()
    demo_adversarial()


if __name__ == "__main__":
    main()


"""Visualization: the tent map and its iterates as an exponentially folding comb.

Generates a figure with (a) tent^[k] for k = 1..4 showing the doubling of spikes,
and (b) the exponential growth of the Lipschitz constant vs depth (log scale).
Requires matplotlib + numpy:  pip install matplotlib numpy
"""
from __future__ import annotations
import numpy as np
import matplotlib.pyplot as plt


def tent(x: np.ndarray) -> np.ndarray:
    return 1.0 - np.abs(2.0 * x - 1.0)


def tent_iterate(k: int, x: np.ndarray) -> np.ndarray:
    t = x.copy()
    for _ in range(k):
        t = tent(t)
    return t


def main() -> None:
    fig, axes = plt.subplots(2, 3, figsize=(15, 8))
    xs = np.linspace(0.0, 1.0, 20001)
    for k, ax in zip(range(1, 6), axes.flat):
        ax.plot(xs, tent_iterate(k, xs), lw=0.8, color="#2a6f97")
        ax.axhline(0.5, color="crimson", ls="--", lw=0.7, alpha=0.6)
        ax.set_title(f"tent^[{k}]  ({2**k} spikes, Lipschitz 2^{k}={2**k})")
        ax.set_xlim(0, 1); ax.set_ylim(-0.05, 1.05)
        ax.set_xlabel("x"); ax.set_ylabel("output")

    ax = axes.flat[5]
    ks = np.arange(0, 16)
    ax.semilogy(ks, 2.0 ** ks, "o-", color="#d62828")
    ax.set_title("Lipschitz constant 2^k vs depth k")
    ax.set_xlabel("depth k"); ax.set_ylabel("2^k (log scale)")
    ax.grid(True, which="both", alpha=0.3)

    fig.suptitle("Depth folds the ruler: bounded range, exponential slope",
                 fontsize=14)
    fig.tight_layout()
    fig.savefig("tent_depth_separation.png", dpi=150)
    print("wrote tent_depth_separation.png")


if __name__ == "__main__":
    main()
