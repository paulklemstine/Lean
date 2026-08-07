#!/usr/bin/env python3
"""
Hyperbolic-Pythagorean Geodesics: numerical demonstration
=========================================================

Self-contained numerical companion to the article and paper.

Every primitive Pythagorean triple (a, b, c) with b even is
    (a, b, c) = (m^2 - n^2, 2mn, m^2 + n^2)
for a unique *Euclid seed* (m, n) with 0 < n < m, gcd(m, n) = 1, m + n odd.

Berggren's three tree moves, in seed coordinates:
    s1(m, n) = (2m - n, m)      s2(m, n) = (2m + n, m)      s3(m, n) = (m + 2n, n)

Embedding each seed into the Poincare upper half-plane as z(m, n) = (n + i)/m,
the hyperbolic distance to the base point i satisfies the EXACT identity

    cosh d( i, z(m, n) ) = (m^2 + n^2 + 1) / (2m) = (c + 1) / (2m).

This script verifies, numerically:

  1. the exact distance formula against the general half-plane distance formula;
  2. the logarithmic trajectory law   (1/2) log c <= d <= (1/2) log(2(c+1));
  3. the residual gap sandwich        n^2/(c^2+n^2) <= rho - rho_tilde
                                                    <= ((c+1)/(c-1)) n^2/(c^2+n^2);
  4. exact branch monotonicity: rho increases along s1, decreases along s3, and
     along s2 follows the sign of  m^2 - (2mn + n^2)  with no exception;
  5. the Pell boundary layer (m - n)^2 = 2n^2 + 1, seeds (5,2), (29,12), (169,70), ...;
  6. that no Euclid seed lies exactly on the threshold m^2 = 2mn + n^2;
  7. depth vs. distance: the left spine has depth ~ sqrt(c/2), the Pell spine depth ~ log c;
  8. quadratic ball growth: #nodes within radius R grows like e^{2R};
  9. factoring by collision: two nodes with the same hypotenuse split it.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from decimal import Decimal, getcontext
from math import gcd
from typing import Dict, Iterator, List, Optional, Tuple

Seed = Tuple[int, int]

getcontext().prec = 60

# --------------------------------------------------------------------------- #
# Part 0.  Seeds, triples, tree moves
# --------------------------------------------------------------------------- #


def is_seed(m: int, n: int) -> bool:
    """Is (m, n) a Euclid seed: 0 < n < m, coprime, opposite parity?"""
    return 0 < n < m and gcd(m, n) == 1 and (m + n) % 2 == 1


def triple(m: int, n: int) -> Tuple[int, int, int]:
    """Euclid's parametrisation (m^2 - n^2, 2mn, m^2 + n^2)."""
    return (m * m - n * n, 2 * m * n, m * m + n * n)


def hypot_of(m: int, n: int) -> int:
    """The hypotenuse c = m^2 + n^2."""
    return m * m + n * n


def s1(p: Seed) -> Seed:
    """Berggren move B1 in seed coordinates."""
    m, n = p
    return (2 * m - n, m)


def s2(p: Seed) -> Seed:
    """Berggren move B2 in seed coordinates."""
    m, n = p
    return (2 * m + n, m)


def s3(p: Seed) -> Seed:
    """Berggren move B3 in seed coordinates."""
    m, n = p
    return (m + 2 * n, n)


def parent(p: Seed) -> Optional[Seed]:
    """Inverse Berggren move; None at the root (2, 1).

    The choice of branch is a trichotomy in the slope n/m:
    (0,1/3) -> B3, (1/3,1/2) -> B2, (1/2,1) -> B1.
    """
    m, n = p
    if (m, n) == (2, 1):
        return None
    if 3 * n < m:
        return (m - 2 * n, n)
    if 2 * n < m:
        return (n, m - 2 * n)
    return (n, 2 * n - m)


def depth(p: Seed) -> int:
    """Combinatorial depth of a seed in the Berggren tree (steps to the root)."""
    k = 0
    q: Optional[Seed] = p
    while q is not None and q != (2, 1):
        q = parent(q)
        k += 1
    return k


def all_seeds(m_max: int) -> Iterator[Seed]:
    """All Euclid seeds with first coordinate at most m_max."""
    for m in range(2, m_max + 1):
        for n in range(1, m):
            if is_seed(m, n):
                yield (m, n)


# --------------------------------------------------------------------------- #
# Part 1.  Hyperbolic geometry of the half-plane
# --------------------------------------------------------------------------- #


def hyperbolic_distance(x1: float, y1: float, x2: float, y2: float) -> float:
    """Distance in the Poincare upper half-plane between x1 + i y1 and x2 + i y2."""
    arg = 1.0 + ((x1 - x2) ** 2 + (y1 - y2) ** 2) / (2.0 * y1 * y2)
    return math.acosh(max(arg, 1.0))


def node_dist(m: int, n: int) -> float:
    """d( i, z(m,n) ) via the exact formula cosh d = (m^2 + n^2 + 1)/(2m)."""
    return math.acosh((m * m + n * n + 1.0) / (2.0 * m))


def node_dist_generic(m: int, n: int) -> float:
    """The same distance computed from the general half-plane distance formula."""
    return hyperbolic_distance(0.0, 1.0, n / m, 1.0 / m)


def residual(m: int, n: int) -> float:
    """rho(m,n) = d( i, z(m,n) ) - (1/2) log c."""
    return node_dist(m, n) - 0.5 * math.log(hypot_of(m, n))


def slope_model(m: int, n: int) -> float:
    """rho_tilde(m,n) = (1/2) log(1 + (n/m)^2): the residual as a function of slope alone."""
    return 0.5 * math.log(1.0 + (n / m) ** 2)


def gap_bounds(m: int, n: int) -> Tuple[float, float]:
    """Certified two-sided bounds on rho - rho_tilde, with no transcendental evaluation."""
    c = float(hypot_of(m, n))
    base = (n * n) / (c * c + n * n)
    return base, ((c + 1.0) / (c - 1.0)) * base


def gap_exact(m: int, n: int) -> Decimal:
    """rho - rho_tilde to 60 digits, from the identity exp(gap) = ((c+1)+S)/(2c).

    Needed because at small slope the gap is far below the rounding error of a
    double-precision evaluation of the distance itself.
    """
    c = Decimal(hypot_of(m, n))
    s = ((c + 1) ** 2 - 4 * Decimal(m * m)).sqrt()
    return (((c + 1) + s) / (2 * c)).ln()


# --------------------------------------------------------------------------- #
# Part 2.  Factoring by collision (Euler's two-representation method)
# --------------------------------------------------------------------------- #


def euler_split(m1: int, n1: int, m2: int, n2: int) -> Tuple[int, int, int]:
    """From two representations N = m1^2+n1^2 = m2^2+n2^2 return (N, g, h) with g*h = N."""
    big_n = hypot_of(m1, n1)
    g = gcd(big_n, m1 * m2 + n1 * n2)
    h = gcd(big_n, m1 * n2 + n1 * m2)
    return big_n, g, h


def find_collisions(m_max: int) -> Dict[int, List[Seed]]:
    """Group seeds by hypotenuse and return those hypotenuses carried by >= 2 seeds."""
    table: Dict[int, List[Seed]] = {}
    for m, n in all_seeds(m_max):
        table.setdefault(hypot_of(m, n), []).append((m, n))
    return {c: v for c, v in table.items() if len(v) >= 2}


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #


def demo_exact_distance_formula(m_max: int = 60) -> None:
    print("=" * 78)
    print("1.  EXACT DISTANCE FORMULA:  cosh d(i, z(m,n)) = (m^2 + n^2 + 1) / (2m)")
    print("=" * 78)
    worst = 0.0
    for m, n in all_seeds(m_max):
        worst = max(worst, abs(node_dist(m, n) - node_dist_generic(m, n)))
    print(f"  seeds tested (m <= {m_max}): {sum(1 for _ in all_seeds(m_max))}")
    print(f"  max |formula - general half-plane distance| = {worst:.3e}")
    print()
    print(f"  {'seed':>10} {'triple':>22} {'c':>8} {'cosh d':>12} {'d':>10}")
    for m, n in [(2, 1), (3, 2), (4, 1), (5, 2), (8, 1), (7, 4), (12, 5)]:
        c = hypot_of(m, n)
        print(f"  {str((m, n)):>10} {str(triple(m, n)):>22} {c:>8} "
              f"{(c + 1) / (2 * m):>12.6f} {node_dist(m, n):>10.6f}")
    print()


def demo_logarithmic_trajectory(m_max: int = 200) -> None:
    print("=" * 78)
    print("2.  LOGARITHMIC TRAJECTORY LAW:  (1/2) log c  <=  d  <=  (1/2) log(2(c+1))")
    print("=" * 78)
    lo_ok = hi_ok = True
    rho_min, rho_max = 1.0, 0.0
    for m, n in all_seeds(m_max):
        c = hypot_of(m, n)
        d = node_dist(m, n)
        lo_ok &= d >= 0.5 * math.log(c) - 1e-12
        hi_ok &= d <= 0.5 * math.log(2 * (c + 1)) + 1e-12
        r = residual(m, n)
        rho_min, rho_max = min(rho_min, r), max(rho_max, r)
    print(f"  lower bound d >= (1/2) log c            holds for all seeds: {lo_ok}")
    print(f"  upper bound d <= (1/2) log(2(c+1))      holds for all seeds: {hi_ok}")
    print(f"  observed residual range: [{rho_min:.6f}, {rho_max:.6f}]")
    print(f"  theoretical window width (1/2) log 2  = {0.5 * math.log(2):.6f}")
    print()
    print("  Compression in action: hypotenuse explodes, distance crawls.")
    p: Seed = (2, 1)
    print(f"  {'depth':>6} {'seed':>26} {'hypotenuse c':>22} {'distance d':>12}")
    for k in range(0, 13):
        c = hypot_of(*p)
        print(f"  {k:>6} {str(p):>26} {c:>22} {node_dist(*p):>12.6f}")
        p = s2(p)
    print()


def demo_residual_gap(m_max: int = 200) -> None:
    print("=" * 78)
    print("3.  RESIDUAL GAP SANDWICH:  n^2/(c^2+n^2) <= rho - rho~ <= ((c+1)/(c-1)) * same")
    print("=" * 78)
    ok = True
    for m, n in all_seeds(m_max):
        g = gap_exact(m, n)
        c = Decimal(hypot_of(m, n))
        lo = Decimal(n * n) / (c * c + Decimal(n * n))
        ok &= (lo <= g <= ((c + 1) / (c - 1)) * lo)
    print(f"  sandwich verified for every seed with m <= {m_max}: {ok}")
    print("  (checked in 60-digit arithmetic; in double precision the gap of a small-slope")
    print("   seed is smaller than the rounding error in the distance)")
    print()
    print(f"  {'seed':>10} {'c':>7} {'rho':>11} {'rho~':>11} {'gap':>12} "
          f"{'lower':>12} {'upper':>12}")
    for m, n in [(2, 1), (4, 1), (9, 4), (10, 1), (12, 5), (29, 12), (100, 1)]:
        if not is_seed(m, n):
            continue
        g = residual(m, n) - slope_model(m, n)
        lo, hi = gap_bounds(m, n)
        print(f"  {str((m, n)):>10} {hypot_of(m, n):>7} {residual(m, n):>11.6f} "
              f"{slope_model(m, n):>11.6f} {g:>12.3e} {lo:>12.3e} {hi:>12.3e}")
    print()
    m, n = 4, 1
    g = residual(m, n) - slope_model(m, n)
    print(f"  Seed (4,1), c = 17.  Coarse bound 1/c        = {1 / 17:.6f}")
    print(f"                       Refined bound (n^2+1)/(c(c+1)) = {2 / (17 * 18):.6f}")
    print(f"                       Sharp sandwich          = [{1/290:.6f}, {1/272:.6f}]")
    print(f"                       True gap                = {g:.7f}")
    print()


def demo_branch_monotonicity(m_max: int = 240) -> None:
    print("=" * 78)
    print("4.  EXACT BRANCH MONOTONICITY OF THE RESIDUAL")
    print("=" * 78)
    print("     B1: rho never decreases   |   B3: rho never increases")
    print("     B2: dichotomy in the sign of  m^2 - (2mn + n^2)   (slope vs sqrt(2)-1)")
    print()
    bad_l = bad_r = bad_m = 0
    on_threshold = 0
    total = 0
    for m, n in all_seeds(m_max):
        total += 1
        r0 = residual(m, n)
        if r0 > residual(*s1((m, n))) + 1e-13:
            bad_l += 1
        if residual(*s3((m, n))) > r0 + 1e-13:
            bad_r += 1
        lhs, rhs = m * m, 2 * m * n + n * n
        r2 = residual(*s2((m, n)))
        if lhs < rhs and r2 > r0 + 1e-13:
            bad_m += 1
        if rhs < lhs and r0 > r2 + 1e-13:
            bad_m += 1
        if lhs == rhs:
            on_threshold += 1
    print(f"  seeds tested (m <= {m_max}): {total}")
    print(f"  violations of  B1 monotone up   : {bad_l}")
    print(f"  violations of  B3 monotone down : {bad_r}")
    print(f"  violations of  B2 dichotomy     : {bad_m}")
    print(f"  seeds exactly on m^2 = 2mn + n^2: {on_threshold}   (must be 0: sqrt2 irrational)")
    print()
    print(f"  {'seed':>10} {'slope':>8} {'m^2':>8} {'2mn+n^2':>9} {'side':>7} "
          f"{'rho':>10} {'B2 child':>11} {'rho(child)':>11} {'moves':>7}")
    for m, n in [(3, 2), (5, 2), (4, 1), (10, 1), (29, 12), (169, 70)]:
        lhs, rhs = m * m, 2 * m * n + n * n
        side = "above" if lhs < rhs else "below"
        ch = s2((m, n))
        r0, r1 = residual(m, n), residual(*ch)
        print(f"  {str((m, n)):>10} {n / m:>8.4f} {lhs:>8} {rhs:>9} {side:>7} "
              f"{r0:>10.6f} {str(ch):>11} {r1:>11.6f} "
              f"{('down' if r1 < r0 else 'up'):>7}")
    print(f"\n  threshold slope sqrt(2) - 1 = {math.sqrt(2) - 1:.6f}")
    print()


def demo_pell_boundary_layer() -> None:
    print("=" * 78)
    print("5.  THE PELL BOUNDARY LAYER:  m^2 = 2mn + n^2 + 1  <=>  (m-n)^2 = 2n^2 + 1")
    print("=" * 78)
    print("  On this family the *real* relaxation of the branch inequality fails;")
    print("  integrality (n >= 2, forced by k^2 = 2n^2 + 1) is what closes it.")
    print()
    print(f"  {'seed (m,n)':>16} {'(m-n)^2':>12} {'2n^2+1':>12} {'rho':>11} "
          f"{'rho(B2 child)':>15} {'margin':>12}")
    m, n = 5, 2
    for _ in range(6):
        r0, r1 = residual(m, n), residual(*s2((m, n)))
        print(f"  {str((m, n)):>16} {(m - n) ** 2:>12} {2 * n * n + 1:>12} "
              f"{r0:>11.6f} {r1:>15.6f} {(r1 - r0) / r0:>11.4%}")
        # next Pell seed: (m,n) -> (5m + 2n, 2m + n) sends 5,2 -> 29,12 -> 169,70 -> ...
        m, n = 5 * m + 2 * n, 2 * m + n
    print()


def demo_depth_versus_distance(k_max: int = 14) -> None:
    print("=" * 78)
    print("6.  DEPTH IS NOT CONTROLLED BY DISTANCE")
    print("=" * 78)
    print("  LEFT SPINE (iterate B1): seed at depth k is (k+2, k+1), c = 2k^2 + 6k + 5.")
    print("  Depth is Theta(sqrt(c)); distance is only Theta(log c).")
    print()
    print(f"  {'k':>4} {'seed':>12} {'c':>10} {'distance':>10} {'k / d':>10}")
    for k in range(0, k_max + 1):
        m, n = k + 2, k + 1
        print(f"  {k:>4} {str((m, n)):>12} {hypot_of(m, n):>10} "
              f"{node_dist(m, n):>10.6f} {k / max(node_dist(m, n), 1e-9):>10.4f}")
    print("\n  The ratio k/d grows without bound: no constant C has depth <= C * distance.")
    print()
    print("  PELL SPINE (iterate B2): here k*log2 <= d, so depth and distance agree.")
    print(f"  {'k':>4} {'seed':>18} {'c':>16} {'distance':>10} {'k*log2':>10}")
    p: Seed = (2, 1)
    for k in range(0, 11):
        print(f"  {k:>4} {str(p):>18} {hypot_of(*p):>16} {node_dist(*p):>10.6f} "
              f"{k * math.log(2):>10.6f}")
        p = s2(p)
    print()
    print("  Sanity check: parent-descent recovers the depth of a few seeds.")
    for p in [(2, 1), (3, 2), (5, 2), (9, 4), (12, 5), (16, 9)]:
        if is_seed(*p):
            print(f"    depth{str(p):>10} = {depth(p)}")
    print()


def demo_ball_volume_growth() -> None:
    print("=" * 78)
    print("7.  QUADRATIC BALL GROWTH:  #{nodes within radius R}  ~  e^{2R}")
    print("=" * 78)
    print("  A node of hypotenuse c sits at distance ~ (1/2) log c, so radius R")
    print("  corresponds to hypotenuse ~ e^{2R}: the ball is as big as the number")
    print("  you are trying to factor.  This is the no-free-lunch obstruction.")
    print()
    m_cap = 400
    seeds = list(all_seeds(m_cap))
    dists = sorted(node_dist(m, n) for m, n in seeds)
    print(f"  {'R':>6} {'#nodes with d <= R':>20} {'e^{2R}':>14} {'ratio':>10}")
    for r in [2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]:
        # only trustworthy while the radius stays inside the enumerated box
        if math.exp(2 * r) > 0.5 * m_cap ** 2:
            break
        cnt = sum(1 for d in dists if d <= r)
        print(f"  {r:>6.1f} {cnt:>20} {math.exp(2 * r):>14.1f} "
              f"{cnt / math.exp(2 * r):>10.4f}")
    print("\n  The ratio settles to a constant: the growth exponent is 2R, not R.")
    print("  Heuristic value of the constant:")
    print("    ball  <=>  m^2 + n^2 <= 2m cosh R - 1, a disc of radius ~ cosh R ~ e^R/2")
    print("    area of the part with 0 < n < m  =  (pi/4 + 1/2) cosh^2 R")
    print("    density of coprime pairs of opposite parity  =  (6/pi^2)(2/3) = 4/pi^2")
    print("    =>  #nodes ~ (pi + 2)/(4 pi^2) * e^{2R} = %.5f * e^{2R}"
          % ((math.pi + 2) / (4 * math.pi ** 2)))
    print()


def demo_collision_factoring(m_max: int = 60) -> None:
    print("=" * 78)
    print("8.  FACTORING BY COLLISION:  two nodes, one hypotenuse, a complete split")
    print("=" * 78)
    print("  65 = 8^2 + 1^2 = 7^2 + 4^2:")
    big_n, g, h = euler_split(8, 1, 7, 4)
    print(f"    gcd(65, 8*7 + 1*4) = gcd(65, 60) = {g}")
    print(f"    gcd(65, 8*4 + 1*7) = gcd(65, 39) = {h}")
    print(f"    product {g} * {h} = {g * h} = N = {big_n}")
    print()
    print("  An infinite family: seeds (20j+9, 10j+2) and (20j+7, 10j+6) collide,")
    print("  both with hypotenuse 500j^2 + 400j + 85, and always expose the factor 5.")
    print(f"  {'j':>3} {'seed A':>14} {'seed B':>14} {'N':>12} {'g':>6} {'h':>8} {'g*h=N':>7}")
    for j in range(0, 7):
        a = (20 * j + 9, 10 * j + 2)
        b = (20 * j + 7, 10 * j + 6)
        assert is_seed(*a) and is_seed(*b)
        assert hypot_of(*a) == hypot_of(*b) == 500 * j * j + 400 * j + 85
        big_n, g, h = euler_split(a[0], a[1], b[0], b[1])
        print(f"  {j:>3} {str(a):>14} {str(b):>14} {big_n:>12} {g:>6} {h:>8} "
              f"{str(g * h == big_n):>7}")
    print()
    print(f"  All collisions among seeds with m <= {m_max}, and the factorisations found:")
    cols = find_collisions(m_max)
    shown = 0
    for c in sorted(cols):
        pairs = cols[c]
        (m1, n1), (m2, n2) = pairs[0], pairs[1]
        big_n, g, h = euler_split(m1, n1, m2, n2)
        d1, d2 = node_dist(m1, n1), node_dist(m2, n2)
        print(f"    N = {big_n:>6} = {str((m1, n1)):>10} = {str((m2, n2)):>10}  "
              f"->  {g} * {h}   |d1 - d2| = {abs(d1 - d2):.4f} (<= log 2 = 0.6931)")
        shown += 1
        if shown >= 12:
            print("    ...")
            break
    print()
    print("  BUT: by the volume theorem above, finding such a collision for a general N")
    print("  requires inspecting ~N nodes.  The geometry is beautiful; it is not fast.")
    print()


def main() -> None:
    print()
    print("#" * 78)
    print("#  HYPERBOLIC-PYTHAGOREAN GEODESICS".ljust(77) + "#")
    print("#  The Berggren tree of Pythagorean triples in the Poincare half-plane".ljust(77) + "#")
    print("#" * 78)
    print()
    demo_exact_distance_formula()
    demo_logarithmic_trajectory()
    demo_residual_gap()
    demo_branch_monotonicity()
    demo_pell_boundary_layer()
    demo_depth_versus_distance()
    demo_ball_volume_growth()
    demo_collision_factoring()
    print("=" * 78)
    print("Summary:  distance is (1/2) log c + O(1)  ->  trajectories are logarithmic.")
    print("          depth can be Theta(sqrt c)      ->  paths are not.")
    print("          ball volume is ~ e^{2R} ~ c     ->  no fast factoring algorithm.")
    print("=" * 78)
    print()


if __name__ == "__main__":
    main()
