"""
demo.py — Numerical demonstrations of the tropical structure of ReLU networks.

This self-contained script illustrates the main results:

  1. The tropical distributive law:  min(u) + min(v) = min over the product set.
  2. Every ReLU network output is a tropical rational function g - h
     (difference of two minima of affine functionals).
  3. Closure under max via the identity  max(p, q) = (p + q) - min(p, q).
  4. Quantitative approximation rates:
        - O(1/N) uniform error for Lipschitz targets,
        - O(1/N^2) uniform error for targets with a Lipschitz derivative,
     using an O(N)-piece (O(N)-monomial) tropical rational interpolant.
  5. The concavity barrier: the tent (unimodal bump) is NOT a tropical
     polynomial (concave), but IS a tropical rational function.

All math uses the MIN-PLUS convention:
    tropical addition  a (+) b = min(a, b)
    tropical product   a (*) b = a + b
"""

from __future__ import annotations

import math
from itertools import product
from typing import Callable, List, Sequence, Tuple

# An affine functional on R^n is a pair (a, b) with a in R^n and b in R,
# evaluated at x as <a, x> + b.
Affine = Tuple[Tuple[float, ...], float]


def aff_eval(ab: Affine, x: Sequence[float]) -> float:
    """Evaluate the affine functional (a, b) at the point x: <a, x> + b."""
    a, b = ab
    return sum(ai * xi for ai, xi in zip(a, x)) + b


def trop_poly_eval(family: Sequence[Affine], x: Sequence[float]) -> float:
    """Evaluate a tropical polynomial: the min over a nonempty affine family."""
    assert family, "a tropical polynomial needs a nonempty affine family"
    return min(aff_eval(ab, x) for ab in family)


def trop_rational_eval(
    g: Sequence[Affine], h: Sequence[Affine], x: Sequence[float]
) -> float:
    """Evaluate a tropical rational function g - h (difference of two minima)."""
    return trop_poly_eval(g, x) - trop_poly_eval(h, x)


# ---------------------------------------------------------------------------
# 1. Tropical distributive law
# ---------------------------------------------------------------------------
def demo_distributive_law() -> None:
    """min(u) + min(v) == min over the product index set of (u_i + v_j)."""
    u = [3.0, -1.0, 7.0, 2.5]
    v = [4.0, 0.0, -2.0]
    lhs = min(u) + min(v)
    rhs = min(ui + vj for ui, vj in product(u, v))
    print("1. Tropical distributive law")
    print(f"   min(u) + min(v)            = {lhs}")
    print(f"   min over product (u_i+v_j) = {rhs}")
    print(f"   equal: {math.isclose(lhs, rhs)}\n")


# ---------------------------------------------------------------------------
# 2 & 3. ReLU as a tropical rational function (closure under max)
# ---------------------------------------------------------------------------
def poly_add(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    """Tropical product (pointwise sum) of two tropical polynomials.

    Realizes  min_S(.) + min_T(.) = min_{S x T}(.)  via the distributive law.
    """
    out: List[Affine] = []
    for (a, b), (c, d) in product(g, h):
        out.append((tuple(ai + ci for ai, ci in zip(a, c)), b + d))
    return out


def poly_min(g: Sequence[Affine], h: Sequence[Affine]) -> List[Affine]:
    """Tropical sum (pointwise min): union of the two affine families."""
    return list(g) + list(h)


def relu_rational(f_g: Sequence[Affine], f_h: Sequence[Affine]):
    """Given f = f_g - f_h, return (G, H) with max(0, f) = G - H.

    Uses  max(p, q) = (p + q) - min(p, q)  with p = 0, q = f.
    Here 0 = (g0 - h0) with g0 = {0} and h0 = {0}; combine via:
        max(f1, f2) = (A + B) - [min(A, B) + (h1 + h2)],
        A = g1 + h2,  B = g2 + h1.
    With f1 = 0 (g1=h1=zero) and f2 = f (g2=f_g, h2=f_h):
        A = zero + f_h,  B = f_g + zero.
    """
    n = len(f_g[0][0])
    zero: List[Affine] = [(tuple(0.0 for _ in range(n)), 0.0)]
    g1, h1, g2, h2 = zero, zero, list(f_g), list(f_h)
    A = poly_add(g1, h2)
    B = poly_add(g2, h1)
    G = poly_add(A, B)
    H = poly_add(poly_min(A, B), poly_add(h1, h2))
    return G, H


def demo_relu_is_tropical_rational() -> None:
    """Numerically check max(0, f(x)) = G(x) - H(x) for a random affine f."""
    f_g: List[Affine] = [((1.5, -0.5), 0.3)]  # f(x) = 1.5 x0 - 0.5 x1 + 0.3
    f_h: List[Affine] = [((0.0, 0.0), 0.0)]   # minus 0
    G, H = relu_rational(f_g, f_h)
    print("2/3. ReLU(f) as a tropical rational function G - H")
    max_err = 0.0
    for x0 in (-2.0, -0.7, 0.0, 1.1, 3.0):
        for x1 in (-1.0, 0.4, 2.0):
            x = (x0, x1)
            direct = max(0.0, aff_eval(f_g[0], x))
            via = trop_rational_eval(G, H, x)
            max_err = max(max_err, abs(direct - via))
    print(f"   |S| of G = {len(G)},  |S| of H = {len(H)}")
    print(f"   max |ReLU(f) - (G - H)| over grid = {max_err:.2e}\n")


# ---------------------------------------------------------------------------
# 4. Approximation rates via piecewise-linear (tropical rational) interpolant
# ---------------------------------------------------------------------------
def pl_interpolant(g: Callable[[float], float], N: int) -> Callable[[float], float]:
    """Piecewise-linear interpolant of g at nodes k/N on [0, 1] (O(N) pieces).

    A continuous piecewise-linear function is a tropical rational function.
    """
    nodes = [k / N for k in range(N + 1)]
    vals = [g(t) for t in nodes]

    def f(x: float) -> float:
        x = min(1.0, max(0.0, x))
        k = min(N - 1, int(x * N))
        t0, t1 = nodes[k], nodes[k + 1]
        w = 0.0 if t1 == t0 else (x - t0) / (t1 - t0)
        return (1 - w) * vals[k] + w * vals[k + 1]

    return f


def sup_error(g: Callable[[float], float], f: Callable[[float], float],
              samples: int = 4001) -> float:
    """Approximate sup-norm error of f against g on [0, 1]."""
    return max(abs(g(x / samples) - f(x / samples)) for x in range(samples + 1))


def demo_approximation_rates() -> None:
    """Empirically confirm O(1/N) for Lipschitz and O(1/N^2) for C^{1,1}."""
    # Lipschitz target: |x - 1/3| (L = 1), kink off the dyadic grid -> rate 1/N.
    g_lip = lambda x: abs(x - 1.0 / 3.0)
    # C^{1,1} target: x^2 (g'' = 2, M = 2) -> rate 1/N^2.
    g_smooth = lambda x: x * x

    print("4. Approximation rates (sup error on [0,1])")
    print("   Lipschitz target g(x) = |x - 1/3|   (expect ~ 1/N)")
    for N in (4, 8, 16, 32, 64):
        e = sup_error(g_lip, pl_interpolant(g_lip, N))
        print(f"     N={N:3d}   error={e:.5e}   error*N={e*N:.4f}")
    print("   Smooth target g(x) = x^2            (expect ~ M/(8 N^2), M=2)")
    for N in (4, 8, 16, 32, 64):
        e = sup_error(g_smooth, pl_interpolant(g_smooth, N))
        print(f"     N={N:3d}   error={e:.5e}   error*N^2={e*N*N:.4f}")
    print()


# ---------------------------------------------------------------------------
# 5. Concavity barrier: the tent bump
# ---------------------------------------------------------------------------
def demo_concavity_barrier() -> None:
    """The tent rises above its endpoint chord, so it is not concave."""
    tent = lambda x: max(0.0, 1.0 - abs(2.0 * x - 1.0))
    # Chord between endpoints (0,0) and (1,0) is the zero function.
    midpoint_value = tent(0.5)
    chord_value = 0.0
    defect = midpoint_value - chord_value
    print("5. Concavity barrier (the tent / unimodal bump)")
    print(f"   tent(1/2) = {midpoint_value}, chord value = {chord_value}")
    print(f"   concavity defect at midpoint = {defect}  (> 0  =>  not concave)")
    print("   => not a tropical polynomial, but IS tropical rational")
    print("      (one subtraction supplies the single curvature change)\n")


def main() -> None:
    print("=" * 64)
    print("Tropical structure of ReLU networks — numerical demonstrations")
    print("=" * 64 + "\n")
    demo_distributive_law()
    demo_relu_is_tropical_rational()
    demo_approximation_rates()
    demo_concavity_barrier()


if __name__ == "__main__":
    main()
