"""
demo.py — Tropical Amoebas and Ronkin Functions
================================================

Numerical demonstrations of the computation-free core of amoeba theory:

  1. The tropical polynomial (amoeba spine)
         trop f(x) = max_i ( log|c_i| + <m_i, x> )
     is convex and piecewise-linear.

  2. The order map: on each dominance region one monomial wins, and the
     spine's slope there is that monomial's integer exponent vector m_k.

  3. The Maslov-deformed Ronkin function
         R_t(x) = t * log( sum_i exp( A_i(x) / t ) ),  A_i(x) = log|c_i| + <m_i,x>
     is convex for every t > 0 (verified numerically).

  4. The dequantization bound
         0 <= R_t(x) - trop f(x) <= t * log N
     holds pointwise and uniformly, so R_t -> trop f as t -> 0+.

All functions are self-contained (standard library only). Run with:

    python3 demo.py
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple

# A Laurent polynomial support is a list of (coefficient_modulus, exponent_vector).
# We only ever need a_i = log|c_i| and the integer exponent m_i, so we store
# the coefficient modulus |c_i| (> 0) and the exponent vector m_i.
Support = List[Tuple[float, Tuple[int, ...]]]


# ----------------------------------------------------------------------
# Core objects
# ----------------------------------------------------------------------
def affine_forms(support: Support, x: Sequence[float]) -> List[float]:
    """Return [A_i(x)] where A_i(x) = log|c_i| + <m_i, x>."""
    out: List[float] = []
    for cmod, m in support:
        a_i = math.log(cmod)
        dot = sum(mk * xk for mk, xk in zip(m, x))
        out.append(a_i + dot)
    return out


def trop_poly(support: Support, x: Sequence[float]) -> float:
    """The tropical polynomial / amoeba spine: max_i A_i(x)."""
    return max(affine_forms(support, x))


def order_map(support: Support, x: Sequence[float]) -> Tuple[int, Tuple[int, ...]]:
    """
    Return (k, m_k): the dominant index and its integer exponent vector at x.
    m_k is the constant slope of the spine on the dominance region containing x.
    """
    A = affine_forms(support, x)
    k = max(range(len(A)), key=lambda i: A[i])
    return k, support[k][1]


def deformed_ronkin(support: Support, x: Sequence[float], t: float) -> float:
    """
    Maslov-deformed Ronkin function R_t(x) = t * log sum_i exp(A_i(x)/t),
    computed with the numerically stable log-sum-exp trick.
    """
    if t <= 0:
        raise ValueError("temperature t must be positive")
    A = affine_forms(support, x)
    M = max(A)
    s = sum(math.exp((a - M) / t) for a in A)
    return M + t * math.log(s)


# ----------------------------------------------------------------------
# Demo 1: convexity & piecewise-linearity of the spine
# ----------------------------------------------------------------------
def demo_spine_convex_piecewise(support: Support) -> None:
    print("=" * 68)
    print("DEMO 1: spine is convex and piecewise-linear")
    print("=" * 68)
    random.seed(0)
    max_violation = 0.0
    for _ in range(20000):
        x = (random.uniform(-3, 3), random.uniform(-3, 3))
        y = (random.uniform(-3, 3), random.uniform(-3, 3))
        lam = random.random()
        mid = (lam * x[0] + (1 - lam) * y[0], lam * x[1] + (1 - lam) * y[1])
        lhs = trop_poly(support, mid)
        rhs = lam * trop_poly(support, x) + (1 - lam) * trop_poly(support, y)
        max_violation = max(max_violation, lhs - rhs)  # convex => <= 0
    print(f"  max convexity violation over 20000 random chords: {max_violation:.2e}")
    print(f"  convex (<= 1e-9): {max_violation <= 1e-9}")

    # piecewise-linearity: on a tiny patch where one index wins, trop f == A_k.
    x0 = (0.7, -1.3)
    k, m_k = order_map(support, x0)
    base = trop_poly(support, x0)
    # move by a small vector and check the change matches the linear slope m_k
    h = (1e-4, -2e-4)
    moved = (x0[0] + h[0], x0[1] + h[1])
    predicted = base + (m_k[0] * h[0] + m_k[1] * h[1])
    actual = trop_poly(support, moved)
    print(f"  at x0={x0}: dominant monomial index {k}, slope m_k={m_k}")
    print(f"  linear-prediction error on small step: {abs(predicted - actual):.2e}")
    print()


# ----------------------------------------------------------------------
# Demo 2: the order map labels dominance regions with Newton lattice points
# ----------------------------------------------------------------------
def demo_order_map(support: Support) -> None:
    print("=" * 68)
    print("DEMO 2: order map -> integer slopes (Newton polytope vertices)")
    print("=" * 68)
    labels = {}
    R = 6.0
    n = 41
    for i in range(n):
        for j in range(n):
            x = (-R + 2 * R * i / (n - 1), -R + 2 * R * j / (n - 1))
            _, m_k = order_map(support, x)
            labels[m_k] = labels.get(m_k, 0) + 1
    print("  exponent vectors (slopes) seen as dominant, with grid frequency:")
    for m_k, count in sorted(labels.items()):
        print(f"    slope {m_k}: {count} grid points")
    print(f"  number of distinct dominance labels (~complement components): {len(labels)}")
    print(f"  these are the lattice points of the Newton polytope conv{{m_i}}.")
    print()


# ----------------------------------------------------------------------
# Demo 3: convexity of the deformed Ronkin function for several t
# ----------------------------------------------------------------------
def demo_ronkin_convex(support: Support) -> None:
    print("=" * 68)
    print("DEMO 3: deformed Ronkin function R_t is convex for every t > 0")
    print("=" * 68)
    random.seed(1)
    for t in (2.0, 1.0, 0.5, 0.1, 0.01):
        worst = 0.0
        for _ in range(5000):
            x = (random.uniform(-3, 3), random.uniform(-3, 3))
            y = (random.uniform(-3, 3), random.uniform(-3, 3))
            lam = random.random()
            mid = (lam * x[0] + (1 - lam) * y[0], lam * x[1] + (1 - lam) * y[1])
            lhs = deformed_ronkin(support, mid, t)
            rhs = lam * deformed_ronkin(support, x, t) + (1 - lam) * deformed_ronkin(support, y, t)
            worst = max(worst, lhs - rhs)
        print(f"  t={t:<5}: max convexity violation {worst:.2e}  (convex: {worst <= 1e-9})")
    print()


# ----------------------------------------------------------------------
# Demo 4: the dequantization bound  0 <= R_t - trop f <= t log N
# ----------------------------------------------------------------------
def demo_dequantization(support: Support) -> None:
    print("=" * 68)
    print("DEMO 4: Maslov dequantization  0 <= R_t - trop f <= t log N")
    print("=" * 68)
    N = len(support)
    print(f"  number of monomials N = {N},  log N = {math.log(N):.6f}")
    random.seed(2)
    for t in (1.0, 0.5, 0.1, 0.01, 0.001):
        bound = t * math.log(N)
        lo, hi = math.inf, -math.inf
        for _ in range(5000):
            x = (random.uniform(-5, 5), random.uniform(-5, 5))
            gap = deformed_ronkin(support, x, t) - trop_poly(support, x)
            lo, hi = min(lo, gap), max(hi, gap)
        ok = (lo >= -1e-12) and (hi <= bound + 1e-9)
        print(f"  t={t:<6}: gap in [{lo:.3e}, {hi:.3e}],  t*logN={bound:.3e},  within bounds: {ok}")
    print("  => R_t converges to trop f uniformly as t -> 0+.")
    print()

    # sharpness of the upper bound: at a balanced point all forms tie.
    print("  Sharpness check (upper bound attained at a balanced point):")
    # For f = 1 + z + w the three forms A_i tie at x where 0 = x0 = x1, i.e. origin.
    x_bal = (0.0, 0.0)
    forms = affine_forms(support, x_bal)
    spread = max(forms) - min(forms)
    if spread < 1e-9:
        for t in (0.5, 0.1, 0.01):
            gap = deformed_ronkin(support, x_bal, t) - trop_poly(support, x_bal)
            print(f"    t={t:<5}: gap {gap:.6f}  vs  t*logN {t*math.log(N):.6f}")
    else:
        print("    (chosen support has no fully balanced point at the origin)")
    print()


# ----------------------------------------------------------------------
# Main
# ----------------------------------------------------------------------
def main() -> None:
    # Running example: f = 1 + z + w  (the tropical line).
    # Monomials: 1*z^(0,0), 1*z^(1,0), 1*z^(0,1).
    line_support: Support = [
        (1.0, (0, 0)),
        (1.0, (1, 0)),
        (1.0, (0, 1)),
    ]

    # A richer example: f = 2 + 3 z + z^2 + w + z w  (5 monomials).
    rich_support: Support = [
        (2.0, (0, 0)),
        (3.0, (1, 0)),
        (1.0, (2, 0)),
        (1.0, (0, 1)),
        (1.0, (1, 1)),
    ]

    print("\n############  EXAMPLE 1: f = 1 + z + w  (tropical line)  ############\n")
    demo_spine_convex_piecewise(line_support)
    demo_order_map(line_support)
    demo_ronkin_convex(line_support)
    demo_dequantization(line_support)

    print("\n############  EXAMPLE 2: f = 2 + 3z + z^2 + w + zw  ############\n")
    demo_spine_convex_piecewise(rich_support)
    demo_order_map(rich_support)
    demo_ronkin_convex(rich_support)
    demo_dequantization(rich_support)


if __name__ == "__main__":
    main()
