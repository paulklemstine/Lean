"""
Numerical demonstrations of Fourier analysis on the finite cyclic group Z/NZ.

This self-contained script illustrates the three structural theorems developed
in the accompanying paper:

  1. Convolution theorem:      DFT(f * g) = DFT(f) . DFT(g)   (pointwise)
  2. Parseval / Plancherel:    sum |DFT(f)(k)|^2 = N * sum |f(j)|^2
  3. Donoho-Stark uncertainty: |supp f| . |supp f_hat| >= N   (f != 0)

It also verifies that subgroup indicators meet the uncertainty bound with
equality.  All routines are elementary O(N^2) reference implementations using
only the Python standard library.
"""

from __future__ import annotations

import cmath
import math
from typing import Callable, List


# ---------------------------------------------------------------------------
# Core transform
# ---------------------------------------------------------------------------

def dft(f: List[complex]) -> List[complex]:
    """Discrete Fourier transform on Z/NZ: f_hat(k) = sum_j f(j) * exp(-2pi i jk/N)."""
    n = len(f)
    return [
        sum(f[j] * cmath.exp(-2j * math.pi * j * k / n) for j in range(n))
        for k in range(n)
    ]


def idft(fhat: List[complex]) -> List[complex]:
    """Inverse DFT: f(j) = (1/N) sum_k f_hat(k) * exp(+2pi i jk/N)."""
    n = len(fhat)
    return [
        sum(fhat[k] * cmath.exp(2j * math.pi * j * k / n) for k in range(n)) / n
        for j in range(n)
    ]


def cyclic_convolution(f: List[complex], g: List[complex]) -> List[complex]:
    """(f * g)(x) = sum_y f(y) g(x - y), indices modulo N."""
    n = len(f)
    return [sum(f[y] * g[(x - y) % n] for y in range(n)) for x in range(n)]


# ---------------------------------------------------------------------------
# Norms and support
# ---------------------------------------------------------------------------

def support_size(f: List[complex], tol: float = 1e-9) -> int:
    """Number of entries whose magnitude exceeds a numerical tolerance."""
    return sum(1 for z in f if abs(z) > tol)


def l1_norm(f: List[complex]) -> float:
    return sum(abs(z) for z in f)


def l2_norm_sq(f: List[complex]) -> float:
    return sum(abs(z) ** 2 for z in f)


def sup_norm(f: List[complex]) -> float:
    return max(abs(z) for z in f)


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_convolution_theorem() -> None:
    """DFT turns cyclic convolution into pointwise multiplication."""
    print("=" * 68)
    print("DEMO 1: Convolution theorem  DFT(f * g) = DFT(f) . DFT(g)")
    print("=" * 68)
    f = [1, 2, 0, -1, 3, 0, 1, 2]           # N = 8
    g = [0, 1, 1, 0, 2, 0, -1, 1]
    lhs = dft(cyclic_convolution(f, g))
    rhs = [a * b for a, b in zip(dft(f), dft(g))]
    err = max(abs(a - b) for a, b in zip(lhs, rhs))
    print(f"  N = {len(f)}")
    print(f"  max | DFT(f*g) - DFT(f).DFT(g) | = {err:.2e}")
    print(f"  identity holds: {err < 1e-9}\n")


def demo_parseval() -> None:
    """Energy is conserved up to the scaling constant N."""
    print("=" * 68)
    print("DEMO 2: Parseval / Plancherel  sum|f_hat|^2 = N * sum|f|^2")
    print("=" * 68)
    for f in ([3, -1, 4, 1, 5, 9, 2, 6], [1, 0, 0, 0, 0]):
        n = len(f)
        lhs = l2_norm_sq(dft([complex(x) for x in f]))
        rhs = n * l2_norm_sq([complex(x) for x in f])
        print(f"  N = {n}:  sum|f_hat|^2 = {lhs:.6f},  "
              f"N*sum|f|^2 = {rhs:.6f},  match: {abs(lhs - rhs) < 1e-6}")
    print()


def demo_uncertainty() -> None:
    """|supp f| . |supp f_hat| >= N for a variety of nonzero signals."""
    print("=" * 68)
    print("DEMO 3: Uncertainty principle  |supp f| . |supp f_hat| >= N")
    print("=" * 68)
    n = 12
    signals = {
        "unit impulse  delta_0": [1] + [0] * (n - 1),
        "two-spike signal":      [1 if j in (0, 5) else 0 for j in range(n)],
        "random-ish signal":     [((7 * j + 3) % 5) - 2 for j in range(n)],
        "constant signal":       [1] * n,
    }
    for name, f in signals.items():
        fc = [complex(x) for x in f]
        s_time = support_size(fc)
        s_freq = support_size(dft(fc))
        product = s_time * s_freq
        print(f"  {name:22s}: |supp f|={s_time:2d}, |supp f_hat|={s_freq:2d}, "
              f"product={product:3d} >= N={n}: {product >= n}")
    print()


def demo_extremal_subgroup() -> None:
    """Subgroup indicators achieve equality |supp f| . |supp f_hat| = N."""
    print("=" * 68)
    print("DEMO 4: Extremal signals  subgroup indicators give equality = N")
    print("=" * 68)
    n = 12
    for d in (1, 2, 3, 4, 6, 12):           # divisors of 12; subgroup H_d
        # H_d = {0, d, 2d, ...} has order N/d.
        f = [complex(1) if (j % d == 0) else complex(0) for j in range(n)]
        s_time = support_size(f)
        s_freq = support_size(dft(f))
        print(f"  subgroup step d={d:2d}: |supp f|={s_time:2d}, "
              f"|supp f_hat|={s_freq:2d}, product={s_time * s_freq:3d} "
              f"(= N={n}: {s_time * s_freq == n})")
    print()


def demo_mixed_bounds() -> None:
    """The two Holder-type mixed bounds that drive the uncertainty proof."""
    print("=" * 68)
    print("DEMO 5: Mixed bounds underlying the uncertainty principle")
    print("=" * 68)
    n = 9
    f = [complex(((3 * j) % 4) - 1) for j in range(n)]
    fhat = dft(f)
    b1_lhs, b1_rhs = sup_norm(fhat), support_size(f) * sup_norm(f)
    b2_lhs, b2_rhs = sup_norm(f), support_size(fhat) * sup_norm(fhat) / n
    print(f"  ||f_hat||_inf = {b1_lhs:.4f} <= |supp f|.||f||_inf = {b1_rhs:.4f}: "
          f"{b1_lhs <= b1_rhs + 1e-9}")
    print(f"  ||f||_inf     = {b2_lhs:.4f} <= (1/N)|supp f_hat|.||f_hat||_inf "
          f"= {b2_rhs:.4f}: {b2_lhs <= b2_rhs + 1e-9}")
    print()


def main() -> None:
    demo_convolution_theorem()
    demo_parseval()
    demo_uncertainty()
    demo_extremal_subgroup()
    demo_mixed_bounds()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
