"""Numerical demonstrations for the lower semi-inducibility profile of S_{2,1}.

This script is fully self-contained (standard library only) and exercises the
main results of the accompanying paper:

  * edge_density(t)      = t * (1 - t/2)              (Def 2.1)
  * min_profile(t)       = t^2 * (1 - t)              (Def 2.2)
  * star_functional(d)   = d^2 * (1 - d)              (Def 2.3)
  * nw_threshold(l)      = l / (2l - 2)               (Def 2.4)

It checks, numerically:
  - the edge-density ceiling 1/2 and its attainment at t = 1 (Thm 3.1, 3.2);
  - strict monotonicity of edge_density and the inverse t(beta) (Thm 3.3, 3.4);
  - ill-posedness above 1/2, refuted at beta = 3/4 (Thm 4.1, 4.2);
  - the bump bound 4/27 with maximizer d = 2/3 (Thm 5.2, 5.3);
  - the mean-relaxation identity: average f = 0 at mean beta (Thm 6.1);
  - the catalog bridge edge_density(1) < nw_threshold(5) (Thm 7.2).
"""

from __future__ import annotations

import math
from typing import Optional


# --------------------------------------------------------------------------
# Core definitions (mirroring the Lean defs)
# --------------------------------------------------------------------------
def edge_density(t: float) -> float:
    """Construction edge density beta(t) = t (1 - t/2)."""
    return t * (1.0 - t / 2.0)


def min_profile(t: float) -> float:
    """Candidate minimum star density p(t) = t^2 (1 - t)."""
    return t * t * (1.0 - t)


def star_functional(d: float) -> float:
    """Per-vertex star functional f(d) = d^2 (1 - d)."""
    return d * d * (1.0 - d)


def nw_threshold(l: int) -> float:
    """Generalized Nash-Williams cycle threshold delta_{C_l} = l/(2l - 2)."""
    return l / (2.0 * l - 2.0)


def invert_edge_density(beta: float) -> Optional[float]:
    """Unique t in [0,1] with edge_density(t) = beta, for beta in [0, 1/2].

    Returns the closed form t = 1 - sqrt(1 - 2 beta), or None if beta > 1/2
    (the ill-posed regime, Thm 4.1)."""
    if beta < 0.0 or beta > 0.5:
        return None
    return 1.0 - math.sqrt(1.0 - 2.0 * beta)


def profile_of_beta(beta: float) -> Optional[float]:
    """The construction profile p_min(beta) = t^2 (1 - t), t = t(beta)."""
    t = invert_edge_density(beta)
    return None if t is None else min_profile(t)


# --------------------------------------------------------------------------
# Demonstrations
# --------------------------------------------------------------------------
def demo_ceiling_and_inverse() -> None:
    print("=" * 68)
    print("Edge-density ceiling, monotonicity, and the inverse t(beta)")
    print("=" * 68)
    print(f"  edge_density(1)   = {edge_density(1.0):.6f}  (Thm 3.2: = 1/2)")
    grid = [i / 20.0 for i in range(21)]
    max_beta = max(edge_density(t) for t in grid)
    print(f"  max edge_density  = {max_beta:.6f}  (Thm 3.1: <= 1/2)")
    mono = all(edge_density(grid[i]) < edge_density(grid[i + 1])
               for i in range(len(grid) - 1))
    print(f"  strictly increasing on grid: {mono}  (Thm 3.3)")
    print("  inverse round-trip beta -> t -> beta (Thm 3.4):")
    for beta in (0.0, 0.1, 0.25, 0.4, 0.5):
        t = invert_edge_density(beta)
        assert t is not None
        print(f"    beta={beta:.2f} -> t={t:.6f} -> beta'={edge_density(t):.6f}")
    print()


def demo_illposed_above_half() -> None:
    print("=" * 68)
    print("Ill-posedness above 1/2 (Thm 4.1) and refutation at 3/4 (Thm 4.2)")
    print("=" * 68)
    for beta in (0.6, 0.75, 0.9):
        t = invert_edge_density(beta)
        print(f"  beta={beta:.2f}: parameter t exists? {t is not None}")
    # brute-force confirmation: no t in [0,1] reaches 3/4
    closest = max(edge_density(i / 100000.0) for i in range(100001))
    print(f"  sup of edge_density over fine grid = {closest:.6f} < 0.75")
    print()


def demo_bump_bound() -> None:
    print("=" * 68)
    print("Bump bound f(d) <= 4/27, maximizer d = 2/3 (Thm 5.2, 5.3)")
    print("=" * 68)
    grid = [i / 100000.0 for i in range(100001)]
    fmax = max(star_functional(d) for d in grid)
    argmax = max(grid, key=star_functional)
    print(f"  numerical max f = {fmax:.8f}")
    print(f"  4/27            = {4.0 / 27.0:.8f}")
    print(f"  argmax (num)    = {argmax:.5f}   (Thm 5.3: 2/3 = {2/3:.5f})")
    print(f"  f(2/3)          = {star_functional(2.0/3.0):.8f}")
    # square certificate (3d - 2)^2 controls the gap
    worst = min(4.0 - 27.0 * star_functional(d) for d in grid)
    print(f"  min of 4 - 27 f(d) over grid = {worst:.8f} (>= 0 certificate)")
    print()


def demo_mean_relaxation() -> None:
    print("=" * 68)
    print("Mean-relaxation identity (Thm 6.1): mean = beta, avg f = 0")
    print("=" * 68)
    for beta in (0.0, 0.2, 0.5, 0.7, 1.0):
        mean = beta * 1.0 + (1.0 - beta) * 0.0
        avg_f = beta * star_functional(1.0) + (1.0 - beta) * star_functional(0.0)
        print(f"  beta={beta:.2f}: two-point law mean={mean:.4f}, avg f={avg_f:.4f}")
    print("  -> averaging constraint alone permits star density 0 everywhere.")
    print("     Positivity of the true minimum is a realizability effect.")
    print(f"     Conjectured corrected boundary value p_min(1/2) = {1/12:.6f}")
    print()


def demo_catalog_bridge() -> None:
    print("=" * 68)
    print("Catalog bridge: 1/2 as a two-sided boundary (Thm 7.1, 7.2)")
    print("=" * 68)
    ceiling = edge_density(1.0)
    for l in range(2, 9):
        thr = nw_threshold(l)
        print(f"  delta_C{l} = {thr:.6f}   ceiling 1/2 < it? {ceiling < thr}")
    print(f"  Thm 7.2: edge_density(1) = {ceiling:.4f} < 5/8 = "
          f"{nw_threshold(5):.4f}")
    print()


def demo_profile_table() -> None:
    print("=" * 68)
    print("The construction profile p_min(beta) on its honest domain [0,1/2]")
    print("=" * 68)
    print("   beta      t(beta)    p_min(beta)")
    for k in range(0, 11):
        beta = 0.5 * k / 10.0
        t = invert_edge_density(beta)
        p = profile_of_beta(beta)
        assert t is not None and p is not None
        print(f"  {beta:5.3f}   {t:8.5f}   {p:10.6f}")
    print(f"  peak of p_min over [0,1/2] occurs at beta = 4/9 = {4/9:.5f},")
    print(f"  value = {profile_of_beta(4/9):.6f} = 4/27 = {4/27:.6f}")
    print()


def main() -> None:
    demo_ceiling_and_inverse()
    demo_illposed_above_half()
    demo_bump_bound()
    demo_mean_relaxation()
    demo_catalog_bridge()
    demo_profile_table()


if __name__ == "__main__":
    main()
