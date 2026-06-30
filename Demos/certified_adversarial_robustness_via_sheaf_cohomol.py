"""
Certified Adversarial Robustness via Sheaf Cohomology
=====================================================

Numerical demonstrations of the results:

  * Stalk certificate: a linear score s_w(x) = <w, x> against L-infinity
    perturbations is sign-stable on the ball of radius r whenever
        ||w||_1 * r < |s_w(x0)|,
    with tight certified radius  R = |s_w(x0)| / ||w||_1.

  * Tree gluing primitive: on a path nerve, every 1-cochain of overlap
    discrepancies is the coboundary of a global potential (partial sums),
    so the first cohomology vanishes.

  * Cyclic obstruction: on a loop nerve, a 1-cochain glues iff its holonomy
    (sum around the loop) is zero; the unit cochain has holonomy n+1 != 0
    and is therefore an ineliminable obstruction.

  * Global certificate: combining the stalk certificates (uniform margin)
    with vanishing first cohomology on a tree cover yields a single global
    certified radius equal to the worst (minimum) stalk radius.

Self-contained; standard library only.
"""

from __future__ import annotations

import math
import random
from typing import List, Sequence, Tuple


# ---------------------------------------------------------------------------
# 1. The linear stalk certificate
# ---------------------------------------------------------------------------

def score(w: Sequence[float], x: Sequence[float]) -> float:
    """Linear score s_w(x) = sum_i w_i x_i."""
    return sum(wi * xi for wi, xi in zip(w, x))


def weight_l1(w: Sequence[float]) -> float:
    """Weight L1 norm ||w||_1 = sum_i |w_i| (dual norm to L-infinity)."""
    return sum(abs(wi) for wi in w)


def certified_radius(w: Sequence[float], x0: Sequence[float]) -> float:
    """
    Tight L-infinity certified radius R = |s_w(x0)| / ||w||_1.

    Returns +inf if the weights vanish but the score does not (the sign
    can never be flipped), and 0.0 if the point lies on the boundary.
    """
    margin = abs(score(w, x0))
    n1 = weight_l1(w)
    if n1 == 0.0:
        return math.inf if margin > 0.0 else 0.0
    return margin / n1


def margin_condition(w: Sequence[float], x0: Sequence[float], r: float) -> bool:
    """Strict margin test  ||w||_1 * r < |s_w(x0)|  (Theorem: sign stability)."""
    return weight_l1(w) * r < abs(score(w, x0))


def empirically_sign_stable(
    w: Sequence[float],
    x0: Sequence[float],
    r: float,
    trials: int = 20000,
    seed: int = 0,
) -> bool:
    """
    Monte-Carlo check that the sign of s_w is constant on the L-infinity ball
    of radius r about x0 (perturb every coordinate within [-r, r]).
    """
    rng = random.Random(seed)
    base = score(w, x0) > 0.0
    d = len(w)
    for _ in range(trials):
        x = [x0[i] + rng.uniform(-r, r) for i in range(d)]
        if (score(w, x) > 0.0) != base:
            return False
    return True


# ---------------------------------------------------------------------------
# 2. Cohomology of the cover nerve
# ---------------------------------------------------------------------------

def delta0_path(f: Sequence[float]) -> List[float]:
    """Path coboundary (delta^0 f)_i = f_{i+1} - f_i  for i = 0..n-1."""
    return [f[i + 1] - f[i] for i in range(len(f) - 1)]


def tree_glue(g: Sequence[float]) -> List[float]:
    """
    Gluing primitive on a path nerve: given a 1-cochain g (length n),
    return the global potential f (length n+1) with delta^0 f = g.
    Construction: f_0 = 0, f_{k} = f_{k-1} + g_{k-1}  (partial sums).
    """
    f = [0.0]
    for gi in g:
        f.append(f[-1] + gi)
    return f


def delta_cyc(f: Sequence[float]) -> List[float]:
    """Cyclic coboundary (delta^cyc f)_i = f_{(i+1) mod (n+1)} - f_i."""
    m = len(f)
    return [f[(i + 1) % m] - f[i] for i in range(m)]


def holonomy(g: Sequence[float]) -> float:
    """Loop holonomy = sum of the 1-cochain around the cycle."""
    return sum(g)


def loop_cochain_glues(g: Sequence[float]) -> bool:
    """A loop 1-cochain is a coboundary iff its holonomy vanishes."""
    return math.isclose(holonomy(g), 0.0, abs_tol=1e-12)


# ---------------------------------------------------------------------------
# 3. Global certificate on a tree cover
# ---------------------------------------------------------------------------

def global_tree_certificate(
    weights: Sequence[Sequence[float]],
    refs: Sequence[Sequence[float]],
    R: float,
) -> Tuple[bool, float]:
    """
    Check the uniform per-region margin condition on a path (tree) cover.

    Returns (certified, worst_stalk_radius) where `certified` is True iff
    every region clears  ||w_i||_1 * R < |s_{w_i}(x0_i)|, in which case R is a
    valid global certified radius. The worst (minimum) stalk radius is the
    largest such R that the cover supports.
    """
    ok = all(margin_condition(w, x0, R) for w, x0 in zip(weights, refs))
    worst = min(certified_radius(w, x0) for w, x0 in zip(weights, refs))
    return ok, worst


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_stalk() -> None:
    print("=" * 68)
    print("1. STALK CERTIFICATE  (tight L-infinity radius = margin / ||w||_1)")
    print("=" * 68)
    w = [2.0, -1.0, 0.5]
    x0 = [1.0, 1.0, 2.0]
    s = score(w, x0)
    R = certified_radius(w, x0)
    print(f"  weights w      = {w}")
    print(f"  reference x0   = {x0}")
    print(f"  score s_w(x0)  = {s:.4f}   (margin {abs(s):.4f})")
    print(f"  ||w||_1        = {weight_l1(w):.4f}")
    print(f"  certified R    = {R:.6f}")
    # just inside the radius: provably stable; just outside: may flip.
    for r in (0.99 * R, 1.5 * R):
        cond = margin_condition(w, x0, r)
        stable = empirically_sign_stable(w, x0, r)
        tag = "certified" if cond else "NOT certified"
        print(f"  r = {r:.4f}: margin test {tag:>13}; "
              f"empirically stable = {stable}")
    print()


def demo_tree_gluing() -> None:
    print("=" * 68)
    print("2. TREE GLUING  (vanishing first cohomology: every g is a coboundary)")
    print("=" * 68)
    g = [0.7, -1.2, 2.4, 0.1]          # arbitrary overlap discrepancies
    f = tree_glue(g)
    recovered = delta0_path(f)
    print(f"  overlap discrepancies g = {g}")
    print(f"  global potential     f  = {f}")
    print(f"  delta^0 f               = {[round(v, 6) for v in recovered]}")
    print(f"  delta^0 f == g          = "
          f"{all(math.isclose(a, b) for a, b in zip(recovered, g))}")
    print()


def demo_cyclic_obstruction() -> None:
    print("=" * 68)
    print("3. CYCLIC OBSTRUCTION  (loop nerve: unit cochain is NOT a coboundary)")
    print("=" * 68)
    for n in (2, 4, 7):
        unit = [1.0] * (n + 1)
        h = holonomy(unit)
        print(f"  n+1 = {n + 1:>2} regions: unit cochain holonomy = {h:.1f}"
              f"  -> glues? {loop_cochain_glues(unit)}")
    # a zero-holonomy loop cochain DOES glue
    g = [1.0, -2.0, 0.5, 0.5]          # holonomy 0
    print(f"\n  zero-holonomy cochain g = {g}, holonomy = {holonomy(g):.1f}"
          f"  -> glues? {loop_cochain_glues(g)}")
    print()


def demo_global() -> None:
    print("=" * 68)
    print("4. GLOBAL CERTIFICATE  (tree cover, uniform margin = min stalk radius)")
    print("=" * 68)
    weights = [[2.0, -1.0], [1.5, 1.5], [-3.0, 0.5]]
    refs = [[1.0, 0.5], [0.8, 0.9], [1.0, 1.0]]
    radii = [certified_radius(w, x0) for w, x0 in zip(weights, refs)]
    print(f"  per-region stalk radii = {[round(r, 4) for r in radii]}")
    worst = min(radii)
    print(f"  worst (min) stalk radius = {worst:.4f}")
    for R in (0.99 * worst, 1.10 * worst):
        ok, _ = global_tree_certificate(weights, refs, R)
        print(f"  candidate global R = {R:.4f}: certified globally = {ok}")
    print()


def main() -> None:
    demo_stalk()
    demo_tree_gluing()
    demo_cyclic_obstruction()
    demo_global()
    print("All demonstrations completed.")


if __name__ == "__main__":
    main()
