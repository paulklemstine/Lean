"""
Composition Theory for Set-Local Distortion of Hausdorff Dimension
==================================================================

Numerical demonstrations of the main results:

  * Bi-Lipschitz maps preserve Hausdorff dimension, and this PERSISTS under
    composition  (dimH ((g ∘ f) '' s) = dimH s).
  * Bi-Hölder (quasi-symmetric) maps distort dimension by 1/r, and under
    composition the exponents MULTIPLY:
        dimH((g∘f)''s) ≤ dimH s / (rg·rf),
        dimH s        ≤ dimH((g∘f)''s) / (rf'·rg').
  * Setting all exponents to 1 collapses the two-sided Hölder window to the
    exact bi-Lipschitz invariance.

The arithmetic is exercised on self-similar sets, whose Hausdorff dimension is
the unique root D of  sum_i c_i^D = 1  (Moran/similarity dimension).  A power
("snowflake") map t -> sign(t)*|t|^r acts on a self-similar subset of the line
by replacing every contraction ratio c by c^r, hence multiplies the similarity
dimension by 1/r --- the line-level avatar of the Hölder distortion theorem.

All functions are self-contained; only the standard library is used.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Callable, List, Sequence, Tuple


# --------------------------------------------------------------------------- #
# Core numerics: similarity (Moran) dimension of a self-similar set           #
# --------------------------------------------------------------------------- #
def similarity_dimension(ratios: Sequence[float], tol: float = 1e-14) -> float:
    """Unique D >= 0 solving sum_i ratios[i]**D = 1, by monotone bisection.

    For an IFS of contractions with ratios c_i in (0,1) satisfying the open set
    condition, this D equals the Hausdorff dimension of the attractor.
    """
    assert all(0.0 < c < 1.0 for c in ratios), "ratios must lie in (0,1)"

    def moran(d: float) -> float:
        return sum(c ** d for c in ratios) - 1.0

    lo, hi = 0.0, 1.0
    # Expand the upper bracket until moran(hi) <= 0 (moran is strictly decreasing).
    while moran(hi) > 0.0:
        hi *= 2.0
    for _ in range(200):
        mid = 0.5 * (lo + hi)
        if moran(mid) > 0.0:
            lo = mid
        else:
            hi = mid
        if hi - lo < tol:
            break
    return 0.5 * (lo + hi)


# --------------------------------------------------------------------------- #
# Map descriptors carrying their Hölder exponents (forward and inverse)        #
# --------------------------------------------------------------------------- #
@dataclass(frozen=True)
class HolderMap:
    """A set-local bi-Hölder map descriptor.

    forward_exp  = r   : exponent of the forward map        (HolderOnWith C r f s)
    inverse_exp  = r'  : exponent of the Hölder inverse     (HolderOnWith C' r' f' (f''s))
    ratio_factor       : how the map scales each similarity contraction ratio c,
                         i.e. c -> c**forward_exp  for a power map of exponent r.
    """
    name: str
    forward_exp: float
    inverse_exp: float

    def apply_to_ratios(self, ratios: Sequence[float]) -> List[float]:
        """A snowflake map of exponent r sends ratio c to c**r."""
        return [c ** self.forward_exp for c in ratios]


def compose_exponents(maps: Sequence[HolderMap]) -> Tuple[float, float]:
    """Theorem 7.1: composite forward exponent = product of forward exponents;
    composite inverse exponent = product of inverse exponents."""
    fwd = 1.0
    inv = 1.0
    for m in maps:
        fwd *= m.forward_exp
        inv *= m.inverse_exp
    return fwd, inv


def dimension_window(dim_source: float,
                     fwd_exp: float,
                     inv_exp: float) -> Tuple[float, float]:
    """Two-sided window predicted by Theorem 7.1 for the image dimension:
        lower = dim_source * inv_exp      (from dimH s <= dimH(img)/inv_exp)
        upper = dim_source / fwd_exp      (from dimH(img) <= dimH s/fwd_exp)
    For a true power map both bounds coincide at dim_source / fwd_exp.
    """
    lower = dim_source * inv_exp
    upper = dim_source / fwd_exp
    return lower, upper


# --------------------------------------------------------------------------- #
# Box-counting dimension estimator (numerical confirmation)                    #
# --------------------------------------------------------------------------- #
def cantor_points(ratios_two: Tuple[float, float] = (1 / 3, 1 / 3),
                  depth: int = 12) -> List[float]:
    """Generate the level-`depth` approximation of a two-map self-similar
    subset of [0,1].  Left map x -> r0*x, right map x -> 1 - r1 + r1*x."""
    r0, r1 = ratios_two
    pts = [0.0]
    for _ in range(depth):
        nxt: List[float] = []
        for p in pts:
            nxt.append(r0 * p)
            nxt.append(1.0 - r1 + r1 * p)
        pts = nxt
    return pts


def box_counting_dimension(points: Sequence[float],
                           scales: Sequence[int] = (2, 4, 8, 16, 32, 64, 128, 256)) -> float:
    """Estimate dimension as the log-log slope of N(eps) vs 1/eps."""
    import math

    logs_inv_eps: List[float] = []
    logs_count: List[float] = []
    for n in scales:
        occupied = set()
        for p in points:
            idx = min(int(p * n), n - 1)
            occupied.add(idx)
        logs_inv_eps.append(math.log(n))
        logs_count.append(math.log(len(occupied)))
    # least-squares slope
    k = len(logs_inv_eps)
    mx = sum(logs_inv_eps) / k
    my = sum(logs_count) / k
    num = sum((x - mx) * (y - my) for x, y in zip(logs_inv_eps, logs_count))
    den = sum((x - mx) ** 2 for x in logs_inv_eps)
    return num / den


# --------------------------------------------------------------------------- #
# Demonstrations                                                               #
# --------------------------------------------------------------------------- #
def demo_bilipschitz_invariance_composes() -> None:
    import math
    print("=" * 70)
    print("DEMO 1 — Bi-Lipschitz invariance composes (Theorem 6.1)")
    print("=" * 70)
    # Middle-thirds Cantor set: two maps, ratio 1/3 each.
    ratios = [1 / 3, 1 / 3]
    d0 = similarity_dimension(ratios)
    print(f"Cantor set similarity dimension : {d0:.10f}")
    print(f"Closed form  log2/log3          : {math.log(2)/math.log(3):.10f}")
    # Two bi-Lipschitz maps (exponent 1 both ways): dimension must be unchanged.
    f = HolderMap("affine_rescale", forward_exp=1.0, inverse_exp=1.0)
    g = HolderMap("smooth_warp",   forward_exp=1.0, inverse_exp=1.0)
    fwd, inv = compose_exponents([f, g])
    lo, hi = dimension_window(d0, fwd, inv)
    print(f"After g∘f, predicted window     : [{lo:.10f}, {hi:.10f}]")
    print(f"Window width (should be 0)       : {hi - lo:.2e}")
    assert abs(hi - lo) < 1e-12 and abs(hi - d0) < 1e-12
    print("PASS: composite bi-Lipschitz map preserves dimension exactly.\n")


def demo_holder_exponents_multiply() -> None:
    print("=" * 70)
    print("DEMO 2 — Hölder exponents multiply under composition (Theorem 7.1)")
    print("=" * 70)
    ratios = [1 / 3, 1 / 3]
    d0 = similarity_dimension(ratios)
    print(f"Source dimension dimH s          : {d0:.10f}")
    # Snowflake by 1/2, then snowflake by 2/3.  Power maps are genuine
    # bijections, so forward and inverse exponents coincide for each map.
    f = HolderMap("snowflake_r=1/2", forward_exp=0.5, inverse_exp=0.5)
    g = HolderMap("snowflake_r=2/3", forward_exp=2 / 3, inverse_exp=2 / 3)

    # Direct line-level computation: apply the two power maps to the ratios.
    r1 = f.apply_to_ratios(ratios)
    r2 = g.apply_to_ratios(r1)
    d_direct = similarity_dimension(r2)
    print(f"Direct dimension of g(f(Cantor)) : {d_direct:.10f}")

    # Theorem 7.1 prediction via product exponents.
    fwd, inv = compose_exponents([f, g])
    print(f"Composite forward exponent rg·rf : {fwd:.10f}  (= 0.5 * 2/3)")
    lo, hi = dimension_window(d0, fwd, inv)
    print(f"Predicted window                 : [{lo:.10f}, {hi:.10f}]")
    print(f"Predicted dimension dimH s/(rg·rf): {d0/fwd:.10f}")
    assert abs(d_direct - d0 / fwd) < 1e-9
    assert lo - 1e-12 <= d_direct <= hi + 1e-12
    print("PASS: composite dimension = dimH s / (rg·rf), inside the window.\n")


def demo_exponent_one_collapse() -> None:
    print("=" * 70)
    print("DEMO 3 — Exponent-one collapse (Corollary 7.2)")
    print("=" * 70)
    d0 = similarity_dimension([0.5, 0.25])  # an asymmetric self-similar set
    print(f"Source dimension                 : {d0:.10f}")
    maps = [HolderMap(f"lip_{i}", 1.0, 1.0) for i in range(5)]
    fwd, inv = compose_exponents(maps)
    lo, hi = dimension_window(d0, fwd, inv)
    print(f"5 chained bi-Lipschitz maps      : window [{lo:.10f}, {hi:.10f}]")
    assert abs(hi - lo) < 1e-12
    print("PASS: any finite chain of bi-Lipschitz maps preserves dimension.\n")


def demo_box_counting_check() -> None:
    import math
    print("=" * 70)
    print("DEMO 4 — Numerical box-counting confirmation")
    print("=" * 70)
    pts = cantor_points((1 / 3, 1 / 3), depth=12)
    est = box_counting_dimension(pts)
    exact = math.log(2) / math.log(3)
    print(f"Box-counting estimate            : {est:.6f}")
    print(f"Exact log2/log3                  : {exact:.6f}")
    print(f"Absolute error                   : {abs(est-exact):.4f}")
    print("(Box-counting is a coarse estimator; it tracks the true value.)\n")


def main() -> None:
    demo_bilipschitz_invariance_composes()
    demo_holder_exponents_multiply()
    demo_exponent_one_collapse()
    demo_box_counting_check()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
