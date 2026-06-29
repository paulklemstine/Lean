"""
Numerical demonstrations of the quantitative universal approximation theorems
for one-dimensional single-hidden-layer ReLU networks.

The network under study is the ramp-difference interpolation network

    reluInterpNet(f, n, x)
        = f(0) + sum_{k<n} cellSlope(f,n,k) * (relu(x - k/n) - relu(x - (k+1)/n))

with cellSlope(f,n,k) = n * (f((k+1)/n) - f(k/n)).  It uses 2n ReLU neurons.

This script verifies, numerically:
  (1) the exact cellwise identity reluInterpNet_eq_on_cell;
  (2) the linear rate quantitative_uat_core: error <= L/n for L-Lipschitz f;
  (3) the width tradeoff quantitative_uat_width: 2n = O(1/eps);
  (4) the quadratic rate sobolev_quadratic_rate: error <= M/n^2 for W^{2,inf} f;
  (5) the improved width tradeoff sobolev_width_tradeoff: 2n = O(1/sqrt(eps));
  (6) the empirical O(1/n) vs O(1/n^2) decay as the architecture is held fixed.

Pure standard library; no third-party dependencies.
"""

from __future__ import annotations

import math
from typing import Callable, List, Tuple

Func = Callable[[float], float]


# --------------------------------------------------------------------------- #
# Core construction (inlined, mirroring the formal definitions)
# --------------------------------------------------------------------------- #

def relu(x: float) -> float:
    """ReLU activation: relu(x) = max(x, 0)."""
    return x if x > 0.0 else 0.0


def grid(n: int, k: int) -> float:
    """Uniform grid node grid(n, k) = k / n on [0, 1]."""
    return k / n


def cell_slope(f: Func, n: int, k: int) -> float:
    """Scaled cell slope: n * (f((k+1)/n) - f(k/n))."""
    return n * (f(grid(n, k + 1)) - f(grid(n, k)))


def relu_interp_net(f: Func, n: int, x: float) -> float:
    """The 2n-neuron ramp-difference ReLU network evaluating at x."""
    total = f(0.0)
    for k in range(n):
        total += cell_slope(f, n, k) * (
            relu(x - grid(n, k)) - relu(x - grid(n, k + 1))
        )
    return total


def affine_interpolant_on_cell(f: Func, n: int, k: int, x: float) -> float:
    """The affine interpolant f(k/n) + cellSlope*(x - k/n) on cell k."""
    return f(grid(n, k)) + cell_slope(f, n, k) * (x - grid(n, k))


# --------------------------------------------------------------------------- #
# Measurement helpers
# --------------------------------------------------------------------------- #

def sup_error(f: Func, n: int, samples: int = 4001) -> float:
    """Empirical sup-norm error of the network against f on [0, 1]."""
    worst = 0.0
    for i in range(samples):
        x = i / (samples - 1)
        worst = max(worst, abs(relu_interp_net(f, n, x) - f(x)))
    return worst


def empirical_lipschitz(f: Func, samples: int = 2001) -> float:
    """Estimate the Lipschitz constant L of f on [0, 1] by finite differences."""
    xs = [i / (samples - 1) for i in range(samples)]
    L = 0.0
    for i in range(1, samples):
        L = max(L, abs(f(xs[i]) - f(xs[i - 1])) / (xs[i] - xs[i - 1]))
    return L


def empirical_second_lipschitz(fp: Func, samples: int = 2001) -> float:
    """Estimate M = Lipschitz constant of the derivative f' on [0, 1]."""
    return empirical_lipschitz(fp, samples)


# --------------------------------------------------------------------------- #
# Demo 1: exact cellwise identity (Theorem reluInterpNet_eq_on_cell)
# --------------------------------------------------------------------------- #

def demo_exact_cellwise_identity() -> None:
    print("=" * 70)
    print("DEMO 1  Exact cellwise identity  (reluInterpNet_eq_on_cell)")
    print("=" * 70)
    f: Func = lambda x: math.sin(3.0 * x) + 0.5 * x * x
    n = 8
    max_gap = 0.0
    for k in range(n):
        for t in (0.0, 0.25, 0.5, 0.75, 1.0):
            x = grid(n, k) + t * (grid(n, k + 1) - grid(n, k))
            net = relu_interp_net(f, n, x)
            aff = affine_interpolant_on_cell(f, n, k, x)
            max_gap = max(max_gap, abs(net - aff))
    print(f"  target f(x) = sin(3x) + x^2/2,  n = {n}")
    print(f"  max |network - affine interpolant| over all cells = {max_gap:.3e}")
    print("  -> network equals the piecewise-linear interpolant exactly.\n")


# --------------------------------------------------------------------------- #
# Demo 2: linear rate L/n for Lipschitz targets (quantitative_uat_core)
# --------------------------------------------------------------------------- #

def demo_linear_rate() -> None:
    print("=" * 70)
    print("DEMO 2  Linear rate L/n for Lipschitz targets  (quantitative_uat_core)")
    print("=" * 70)
    # A genuinely non-smooth (only Lipschitz) target: a triangle/sawtooth.
    f: Func = lambda x: abs(x - 1.0/3.0)        # 1-Lipschitz, breakpoint off the grid
    L = empirical_lipschitz(f)
    print(f"  target f(x) = |x - 1/3|,  estimated L = {L:.4f}")
    print(f"  {'n':>5} {'sup error':>14} {'bound L/n':>14} {'holds?':>8}")
    for n in (4, 8, 16, 32, 64, 128):
        err = sup_error(f, n)
        bound = L / n
        ok = err <= bound + 1e-9
        print(f"  {n:>5} {err:>14.6e} {bound:>14.6e} {str(ok):>8}")
    print("  -> error stays under L/n and decays like 1/n.\n")


# --------------------------------------------------------------------------- #
# Demo 3: width/error tradeoff 2n = O(1/eps) (quantitative_uat_width)
# --------------------------------------------------------------------------- #

def demo_width_tradeoff_linear() -> None:
    print("=" * 70)
    print("DEMO 3  Width budget 2n = O(1/eps), Lipschitz  (quantitative_uat_width)")
    print("=" * 70)
    f: Func = lambda x: abs(x - 1.0/3.0)
    L = empirical_lipschitz(f)
    print(f"  target f(x) = |x - 1/3|,  L = {L:.4f}")
    print(f"  {'eps':>10} {'n>=L/eps':>10} {'width 2n':>10} {'sup error':>14} {'<=eps?':>8}")
    for eps in (1e-1, 5e-2, 1e-2, 5e-3, 1e-3):
        n = math.ceil(L / eps)
        err = sup_error(f, n)
        ok = err <= eps + 1e-9
        print(f"  {eps:>10.0e} {n:>10d} {2*n:>10d} {err:>14.6e} {str(ok):>8}")
    print("  -> required width grows linearly in 1/eps.\n")


# --------------------------------------------------------------------------- #
# Demo 4: quadratic rate M/n^2 for W^{2,inf} targets (sobolev_quadratic_rate)
# --------------------------------------------------------------------------- #

def demo_quadratic_rate() -> None:
    print("=" * 70)
    print("DEMO 4  Quadratic rate M/n^2 for W^{2,inf}  (sobolev_quadratic_rate)")
    print("=" * 70)
    # Smooth target with Lipschitz derivative; f'(x)=2x is 2-Lipschitz so M=2.
    f: Func = lambda x: x * x
    fp: Func = lambda x: 2.0 * x
    M = empirical_second_lipschitz(fp)
    print(f"  target f(x) = x^2,  f'(x) = 2x,  estimated M = {M:.4f}")
    print(f"  {'n':>5} {'sup error':>14} {'bound M/n^2':>14} {'sharp M/8n^2':>14} {'holds?':>8}")
    for n in (4, 8, 16, 32, 64, 128):
        err = sup_error(f, n)
        bound = M / (n * n)
        sharp = M / (8.0 * n * n)
        ok = err <= bound + 1e-9
        print(f"  {n:>5} {err:>14.6e} {bound:>14.6e} {sharp:>14.6e} {str(ok):>8}")
    print("  -> error stays under M/n^2 and tracks the sharp M/(8n^2) (future C1).\n")


# --------------------------------------------------------------------------- #
# Demo 5: improved width tradeoff 2n = O(1/sqrt(eps)) (sobolev_width_tradeoff)
# --------------------------------------------------------------------------- #

def demo_width_tradeoff_quadratic() -> None:
    print("=" * 70)
    print("DEMO 5  Width budget 2n = O(1/sqrt(eps)), W^{2,inf}  (sobolev_width_tradeoff)")
    print("=" * 70)
    f: Func = lambda x: x * x
    fp: Func = lambda x: 2.0 * x
    M = empirical_second_lipschitz(fp)
    print(f"  target f(x) = x^2,  M = {M:.4f}")
    print(f"  {'eps':>10} {'n>=sqrt(M/eps)':>16} {'width 2n':>10} {'sup error':>14} {'<=eps?':>8}")
    for eps in (1e-1, 5e-2, 1e-2, 5e-3, 1e-3):
        n = math.ceil(math.sqrt(M / eps))
        err = sup_error(f, n)
        ok = err <= eps + 1e-9
        print(f"  {eps:>10.0e} {n:>16d} {2*n:>10d} {err:>14.6e} {str(ok):>8}")
    print("  -> required width grows like 1/sqrt(eps): quadratically fewer neurons.\n")


# --------------------------------------------------------------------------- #
# Demo 6: regularity, not architecture, sets the exponent
# --------------------------------------------------------------------------- #

def _log2_decay_exponent(ns: List[int], errs: List[float]) -> float:
    """Slope of log2(error) vs log2(n): the empirical decay exponent."""
    pts: List[Tuple[float, float]] = [
        (math.log2(n), math.log2(e)) for n, e in zip(ns, errs) if e > 0.0
    ]
    m = len(pts)
    sx = sum(p[0] for p in pts)
    sy = sum(p[1] for p in pts)
    sxx = sum(p[0] * p[0] for p in pts)
    sxy = sum(p[0] * p[1] for p in pts)
    return (m * sxy - sx * sy) / (m * sxx - sx * sx)


def demo_exponent_is_regularity() -> None:
    print("=" * 70)
    print("DEMO 6  Same network: exponent set by regularity of the target")
    print("=" * 70)
    rough: Func = lambda x: abs(x - 1.0/3.0)    # Lipschitz only  -> expect ~ -1
    smooth: Func = lambda x: x * x              # W^{2,inf}        -> expect ~ -2
    ns = [8, 16, 32, 64, 128, 256]
    rough_errs = [sup_error(rough, n) for n in ns]
    smooth_errs = [sup_error(smooth, n) for n in ns]
    er = _log2_decay_exponent(ns, rough_errs)
    es = _log2_decay_exponent(ns, smooth_errs)
    print(f"  Lipschitz target |x-1/3|:   empirical decay exponent = {er:+.3f}  (theory -1)")
    print(f"  Smooth   target x^2:        empirical decay exponent = {es:+.3f}  (theory -2)")
    print("  -> architecture is identical; the smoothness class drives the rate.\n")


def main() -> None:
    demo_exact_cellwise_identity()
    demo_linear_rate()
    demo_width_tradeoff_linear()
    demo_quadratic_rate()
    demo_width_tradeoff_quadratic()
    demo_exponent_is_regularity()


if __name__ == "__main__":
    main()
