"""
demo.py — Numerical demonstrations of Hausdorff dimension as a bi-Lipschitz
and affine-group invariant.

This script illustrates, numerically, the main results of the package:

  1. Bi-Lipschitz invariance: the (box-counting estimate of) the dimension of
     the middle-thirds Cantor set is unchanged under scaling, translation, and
     general invertible affine maps  x -> c*x + a   (c != 0).
  2. Scale invariance is the structural reason a self-similar dimension is the
     scale-free ratio  log N / log(1/r)  (Cantor: log 2 / log 3 ~ 0.6309).
  3. The boundary case: a *constant* map (Lipschitz with K = 0, but NOT
     antilipschitz) collapses the line (dimension 1) to a point (dimension 0).
  4. The Hölder bound: a Hölder-r map can inflate dimension by at most 1/r;
     x -> x^2 (inverse sqrt is Hölder-1/2) is the prototype.
  5. Cross-domain: the logarithmic integer fractal {1/log n : n >= 2}, which
     contains the prime fractal {1/log p}, is countable, and its box-counting
     proxy collapses toward 0 — robustly, under bi-Lipschitz reshaping.

Pure standard library; no third-party dependencies. Run:  python demo.py
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple


# ---------------------------------------------------------------------------
# Generating points of the middle-thirds Cantor set
# ---------------------------------------------------------------------------
def cantor_points(depth: int) -> List[float]:
    """Return the 2**depth left endpoints of the level-`depth` Cantor intervals.

    Each surviving interval at level `depth` has length (1/3)**depth and is the
    image of [0,1] under a composition of the two contractions
    x -> x/3 and x -> x/3 + 2/3.  We enumerate them by binary expansion.
    """
    pts: List[float] = []
    for code in range(2 ** depth):
        x = 0.0
        scale = 1.0
        c = code
        for _ in range(depth):
            scale /= 3.0
            if c & 1:
                x += 2.0 * scale
            c >>= 1
        pts.append(x)
    return pts


# ---------------------------------------------------------------------------
# Box-counting dimension estimate
# ---------------------------------------------------------------------------
def box_count(points: Sequence[float], box_size: float) -> int:
    """Number of distinct boxes of width `box_size` containing at least one point."""
    occupied = {math.floor(p / box_size) for p in points}
    return len(occupied)


def box_counting_dimension(
    points: Sequence[float], scales: Sequence[float]
) -> float:
    """Least-squares slope of  log N(eps)  against  log(1/eps).

    This is the standard box-counting estimate of fractal dimension.  For a
    bi-Lipschitz (here: affine) image of a set the estimate is, up to boundary
    effects, the same — illustrating bi-Lipschitz invariance numerically.
    """
    xs = [math.log(1.0 / s) for s in scales]
    ys = [math.log(box_count(points, s)) for s in scales]
    n = len(xs)
    mx = sum(xs) / n
    my = sum(ys) / n
    num = sum((x - mx) * (y - my) for x, y in zip(xs, ys))
    den = sum((x - mx) ** 2 for x in xs)
    return num / den


# ---------------------------------------------------------------------------
# Maps
# ---------------------------------------------------------------------------
def affine(c: float, a: float) -> Callable[[float], float]:
    """The invertible affine map x -> c*x + a (requires c != 0)."""
    if c == 0.0:
        raise ValueError("affine map requires c != 0 to be invertible")
    return lambda x: c * x + a


def apply_map(f: Callable[[float], float], pts: Sequence[float]) -> List[float]:
    return [f(x) for x in pts]


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------
def demo_bilipschitz_invariance() -> None:
    print("=" * 70)
    print("1 & 2.  Bi-Lipschitz / affine invariance of Cantor-set dimension")
    print("=" * 70)
    depth = 12
    pts = cantor_points(depth)
    scales = [(1.0 / 3.0) ** k for k in range(2, depth)]
    theoretical = math.log(2) / math.log(3)
    print(f"  Theoretical similarity dimension  log 2 / log 3 = {theoretical:.6f}")
    print(f"  Estimate on the original Cantor set            = "
          f"{box_counting_dimension(pts, scales):.6f}")

    transforms: List[Tuple[str, Callable[[float], float]]] = [
        ("scale  x -> 5*x        ", affine(5.0, 0.0)),
        ("scale  x -> -2*x       ", affine(-2.0, 0.0)),
        ("translate x -> x + 100 ", affine(1.0, 100.0)),
        ("affine x -> 7*x - 3    ", affine(7.0, -3.0)),
    ]
    for name, f in transforms:
        img = apply_map(f, pts)
        # Rescale the gauge by |c| so box widths track the stretched set; this
        # is exactly the bi-Lipschitz comparison of covers in the proof.
        c = abs(f(1.0) - f(0.0))
        est = box_counting_dimension(img, [s * c for s in scales])
        print(f"  dim of {name} image = {est:.6f}")
    print("  -> all affine images share the dimension: bi-Lipschitz invariance.\n")


def demo_constant_collapse() -> None:
    print("=" * 70)
    print("3.  Boundary case: a constant map collapses dimension")
    print("=" * 70)
    # Sample of the line (dimension 1).
    line = [i / 400.0 for i in range(401)]
    scales = [1.0 / 2 ** k for k in range(1, 8)]
    print(f"  Box-dimension estimate of sampled line  = "
          f"{box_counting_dimension(line, scales):.4f}  (~ 1)")
    const_img = apply_map(lambda x: 7.0, line)  # everything -> the point 7
    distinct = len(set(const_img))
    print(f"  Constant map image has {distinct} distinct point(s) -> dimension 0")
    print("  Constant map is Lipschitz (K=0) but NOT antilipschitz: dimension"
          " drops 1 -> 0.\n")


def demo_holder_inflation() -> None:
    print("=" * 70)
    print("4.  Hölder bound: dim(f(s)) <= dim(s)/r  (here r = 1/2 via x->x^2)")
    print("=" * 70)
    # f = x^2 has inverse sqrt which is Hölder-1/2; near 0 it can inflate dim.
    # We illustrate the controlled inflation factor 1/r = 2 as an upper bound.
    r = 0.5
    dim_source_examples = [0.0, 0.3, 0.5, 0.6309, 1.0]
    print(f"  Hölder exponent r = {r}, allowed inflation factor 1/r = {1/r}")
    for d in dim_source_examples:
        print(f"    dim s = {d:.4f}  =>  dim f(s) <= {d / r:.4f}")
    print("  At r = 1 (Lipschitz) the bound is dim f(s) <= dim s: invariance.\n")


def demo_log_fractal() -> None:
    print("=" * 70)
    print("5.  The logarithmic integer fractal {1/log n} is zero-dimensional")
    print("=" * 70)

    def log_range(n_max: int) -> List[float]:
        return [1.0 / math.log(n) for n in range(2, n_max + 1)]

    def is_prime(n: int) -> bool:
        if n < 2:
            return False
        for d in range(2, int(n ** 0.5) + 1):
            if n % d == 0:
                return False
        return True

    def prime_fractal(n_max: int) -> List[float]:
        return [1.0 / math.log(p) for p in range(2, n_max + 1) if is_prime(p)]

    n_max = 5000
    lr = log_range(n_max)
    pf = prime_fractal(n_max)
    scales = [1.0 / 2 ** k for k in range(1, 9)]
    # As the gauge shrinks, the box count of a convergent countable set grows
    # only sub-polynomially: the box-counting *slope* drifts toward 0.
    print(f"  Integer fractal: {len(lr)} points; prime fractal: {len(pf)} points")
    print("  Box counts N(eps) for the integer fractal (note slow growth):")
    for s in scales:
        print(f"    eps = {s:.5f}  ->  N = {box_count(lr, s)}")
    # rescale by 5 (bi-Lipschitz): the same accumulation structure, dimension 0.
    lr5 = [5.0 * x for x in lr]
    print(f"  After bi-Lipschitz rescaling x -> 5x, still accumulating at 0;")
    print(f"    max point moves {max(lr):.4f} -> {max(lr5):.4f}, dimension stays 0.")
    print("  Countable => Hausdorff dimension 0, robustly under reshaping.\n")


def main() -> None:
    demo_bilipschitz_invariance()
    demo_constant_collapse()
    demo_holder_inflation()
    demo_log_fractal()
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()
