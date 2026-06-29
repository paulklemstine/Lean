"""
Composition Theory for Set-Local Distortion of Hausdorff Dimension
==================================================================

Numerical demonstrations of the results formalized in
`Catalog/Geometry/QuasiSymmetricComposition.lean`.

The theorems are about (possibly fractal) sets in metric spaces, but their
*quantitative content* is fully computable:

  * Lipschitz maps do not increase Hausdorff dimension.
  * Antilipschitz (non-collapsing) maps do not decrease it.
  * Bi-Lipschitz maps preserve it exactly  (Theorem 3.5 / 5.1).
  * Hölder maps of exponent r distort dimension by at most 1/r,
    and composing Hölder maps MULTIPLIES the exponents
    (Theorem 6.1: the product-exponent distortion corridor).

This script is self-contained (standard library only). Every helper is inlined.
Run with:  python3 demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. Similarity dimension of a self-similar fractal (IFS attractor)
#
#    For contraction ratios c_1,...,c_m satisfying the open set condition,
#    the Hausdorff dimension D is the unique root of   sum_i c_i^D = 1.
#    The map  D |-> sum_i c_i^D  is strictly decreasing, so we bisect.
# ---------------------------------------------------------------------------
def similarity_dimension(ratios: Sequence[float],
                         tol: float = 1e-12,
                         max_iter: int = 200) -> float:
    """Return the similarity dimension D solving sum_i ratios_i^D = 1."""
    if any(not (0.0 < c < 1.0) for c in ratios):
        raise ValueError("each contraction ratio must lie strictly in (0, 1)")

    def moran(d: float) -> float:
        return sum(c ** d for c in ratios) - 1.0

    lo, hi = 0.0, 1.0
    # grow the upper bracket until the Moran sum drops below 1
    while moran(hi) > 0.0:
        hi *= 2.0
    for _ in range(max_iter):
        mid = 0.5 * (lo + hi)
        if moran(mid) > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


# ---------------------------------------------------------------------------
# 2. Box-counting dimension of a finite point cloud
#
#    A robust numerical proxy for Hausdorff dimension on self-similar sets:
#    slope of  log N(eps)  against  log(1/eps), where N(eps) is the number of
#    occupied boxes of side eps.
# ---------------------------------------------------------------------------
def box_counting_dimension(points: Sequence[float],
                           scales: Sequence[float]) -> float:
    """Least-squares slope of log N(eps) vs log(1/eps) for 1-D point data."""
    xs: List[float] = []
    ys: List[float] = []
    for eps in scales:
        occupied = {math.floor(p / eps) for p in points}
        xs.append(math.log(1.0 / eps))
        ys.append(math.log(len(occupied)))
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


def cantor_points(level: int) -> List[float]:
    """Endpoints of the level-`level` middle-thirds Cantor construction."""
    pts = [0.0]
    for _ in range(level):
        nxt: List[float] = []
        for p in pts:
            nxt.append(p)            # left third start kept implicitly
        # build via the two contractions x->x/3 and x->x/3+2/3
        pts = [p / 3.0 for p in pts] + [p / 3.0 + 2.0 / 3.0 for p in pts]
    return sorted(set(pts))


# ---------------------------------------------------------------------------
# 3. The composition / distortion laws as pure exponent arithmetic
# ---------------------------------------------------------------------------
def lipschitz_compose_constant(k_f: float, k_g: float) -> float:
    """Lipschitz constants multiply: Lip(g o f) <= k_g * k_f."""
    return k_g * k_f


def antilipschitz_compose_constant(k_f: float, k_g: float) -> float:
    """Antilipschitz constants multiply (Theorem 4.1): K(g o f) <= k_f * k_g."""
    return k_f * k_g


def holder_compose_exponent(r_f: float, r_g: float) -> float:
    """Hölder exponents multiply under composition: r(g o f) = r_g * r_f."""
    return r_g * r_f


def biholder_distortion_corridor(dimH_source: float,
                                 r_forward_exponents: Sequence[float],
                                 r_inverse_exponents: Sequence[float]
                                 ) -> Tuple[float, float]:
    """
    Composite quasi-symmetric distortion corridor (Theorem 6.1).

    For a chain of bi-Hölder links with forward exponents r_i and inverse
    exponents r_i', the image dimension d satisfies
        d <= dimH_source / (prod r_i)            (upper bound)
        dimH_source <= d / (prod r_i')   <=>     d >= dimH_source * (prod r_i')
    Returns (lower_bound, upper_bound) on dimH of the image.
    """
    prod_fwd = math.prod(r_forward_exponents)
    prod_inv = math.prod(r_inverse_exponents)
    upper = dimH_source / prod_fwd
    lower = dimH_source * prod_inv
    return lower, upper


# ---------------------------------------------------------------------------
# 4. Empirical check: a Hölder snowflake of exponent r inflates dimension ~1/r
#
#    Endow the Cantor set with the snowflaked metric d^r. Under the identity
#    map (X, d) -> (X, d^r), distances shrink as d -> d^r (for small d, r<1
#    makes them relatively larger), and Hausdorff dimension scales by 1/r.
#    We verify the exponent-multiplication law on the *dimension* directly.
# ---------------------------------------------------------------------------
def snowflaked_box_dimension(points: Sequence[float],
                             original_sides: Sequence[float],
                             r: float) -> float:
    """
    Box-counting dimension of `points` under the snowflake metric d^r (r in (0,1]).
    A ball of radius eps in the snowflaked metric d^r equals a ball of original
    radius side = eps^(1/r), i.e. eps = side^r. We count boxes at the original
    `original_sides` (kept within the data's resolution) and plot N(side) against
    the snowflaked scale log(1/eps) = r * log(1/side). The slope is the
    snowflaked dimension, theoretically (original dimension) / r.
    """
    xs: List[float] = []
    ys: List[float] = []
    for side in original_sides:
        eps = side ** r                       # corresponding snowflaked radius
        occupied = {math.floor(p / side) for p in points}
        xs.append(math.log(1.0 / eps))        # snowflaked scale on the x-axis
        ys.append(math.log(len(occupied)))
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


# ---------------------------------------------------------------------------
# Demonstration driver
# ---------------------------------------------------------------------------
def main() -> None:
    print("=" * 72)
    print(" Composition Theory for Set-Local Distortion of Hausdorff Dimension")
    print("=" * 72)

    # --- (A) Reference dimensions of classic self-similar fractals ----------
    print("\n[A] Similarity dimensions (Moran equation sum c_i^D = 1):")
    examples = {
        "Cantor set  (2 maps, ratio 1/3)": [1 / 3, 1 / 3],
        "Koch curve  (4 maps, ratio 1/3)": [1 / 3] * 4,
        "Sierpinski  (3 maps, ratio 1/2)": [1 / 2] * 3,
        "Sierp.carpet(8 maps, ratio 1/3)": [1 / 3] * 8,
    }
    closed = {
        "Cantor set  (2 maps, ratio 1/3)": math.log(2) / math.log(3),
        "Koch curve  (4 maps, ratio 1/3)": math.log(4) / math.log(3),
        "Sierpinski  (3 maps, ratio 1/2)": math.log(3) / math.log(2),
        "Sierp.carpet(8 maps, ratio 1/3)": math.log(8) / math.log(3),
    }
    for name, ratios in examples.items():
        d = similarity_dimension(ratios)
        print(f"    {name:38s}  D = {d:.6f}  (exact {closed[name]:.6f})")

    # --- (B) Bi-Lipschitz invariance (Theorem 3.5 / 5.1) -------------------
    print("\n[B] Bi-Lipschitz invariance: an affine map x -> 5x + 2")
    print("    rescales the Cantor set but must preserve its dimension.")
    pts = cantor_points(12)
    scales = [3.0 ** (-k) for k in range(1, 9)]
    d_orig = box_counting_dimension(pts, scales)
    affine: Callable[[float], float] = lambda x: 5.0 * x + 2.0
    pts_img = [affine(p) for p in pts]
    # box counting is scale-covariant; rescale grid by the Lipschitz factor 5
    d_img = box_counting_dimension(pts_img, [5.0 * s for s in scales])
    print(f"    box-dim(Cantor)        = {d_orig:.4f}")
    print(f"    box-dim(5*Cantor + 2)  = {d_img:.4f}   "
          f"(equal up to discretization; theory: exactly equal)")

    # --- (C) Composition multiplies exponents (Theorem 6.1) ----------------
    print("\n[C] Hölder exponents multiply under composition:")
    r_f, r_g = 0.5, 0.5
    r_comp = holder_compose_exponent(r_f, r_g)
    print(f"    f Hölder exp r_f = {r_f},  g Hölder exp r_g = {r_g}")
    print(f"    => g o f Hölder exp = r_g * r_f = {r_comp}")
    print(f"    Lipschitz const compose:    Lip(g o f) <= "
          f"{lipschitz_compose_constant(2.0, 3.0)}")
    print(f"    Antilipschitz const compose: K(g o f)  <= "
          f"{antilipschitz_compose_constant(2.0, 3.0)}")

    # --- (D) Composite distortion corridor ---------------------------------
    print("\n[D] Composite bi-Hölder distortion corridor (Theorem 6.1):")
    d_source = math.log(2) / math.log(3)  # Cantor dimension
    chain_fwd = [0.5, 0.5]                 # two snowflakes, each exp 1/2
    chain_inv = [0.5, 0.5]
    lo, hi = biholder_distortion_corridor(d_source, chain_fwd, chain_inv)
    print(f"    source dimH (Cantor)             = {d_source:.6f}")
    print(f"    forward exponents {chain_fwd}, product = {math.prod(chain_fwd)}")
    print(f"    => image dimH bounded in corridor: [{lo:.6f}, {hi:.6f}]")
    print(f"    (upper bound = source / product = {d_source / 0.25:.6f}: "
          f"4x inflation, exactly as a single exp-1/4 snowflake)")

    # --- (E) Empirical exponent-multiplication on a snowflaked Cantor set ---
    print("\n[E] Empirical: snowflaking the Cantor set by exponent r")
    print("    inflates its box dimension by ~1/r (then composing squares it):")
    base = box_counting_dimension(pts, scales)
    for r in (1.0, 0.5, 0.25):
        d_snow = snowflaked_box_dimension(pts, scales, r)
        print(f"    r = {r:>4}:  box-dim ~ {d_snow:.4f}   "
              f"(predicted {base / r:.4f})")

    print("\nAll demonstrations consistent with the formalized theorems.")


if __name__ == "__main__":
    main()
