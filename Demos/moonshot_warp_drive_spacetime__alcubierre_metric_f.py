"""
Numerical demonstration of the exact results on the Alcubierre warp-drive geometry.

Geometric units c = G = 1, signature (-,+,+,+).  Everything here is self-contained:
no third-party dependencies, only the standard library.

The script verifies, numerically, each of the following exact statements.

  1.  Pointwise structure.
      The metric g(w) with w = v_s f(r_s) equals S(w)^T eta S(w) for the unimodular
      shear S(w): (t,x,y,z) -> (t, x - w t, y, z).  Hence det g = -1 always.

  2.  Effective FTL without local FTL.
      The ship's four-velocity (1, v_s, 0, 0) has line element exactly -1 for every
      warp speed, while its coordinate velocity is v_s (unbounded) and its velocity
      relative to the local Eulerian observer is exactly 0.  Every timelike vector
      obeys |u^x/u^t - w| < 1.

  3.  Expansion dipole.
      theta = v_s f'(r_s) (x - x_s)/r_s is positive behind the ship, negative ahead,
      zero on the transverse plane, and odd about that plane.

  4.  Exotic energy density.
      rho = -(1/8pi) v_s^2 (y^2+z^2) / (4 r_s^2) * f'(r_s)^2 <= 0 everywhere,
      vanishing exactly on the axis y = z = 0 (toroidal support).

  5.  Exact thin-wall energy.
      E(v,R,D) = -(v^2/12)(R^2/D + D/12), matched against direct numerical
      quadrature of the radial energy functional.

  6.  Quadratic (not linear) scaling.
      E(lam v) = lam^2 E(v); no constant C satisfies E = C v for all v.

  7.  Sharp variational floor.
      min over admissible profiles supported in [a,b] of int_a^b g^2 r^2 dr equals
      ab/(b-a), attained by g*(r) = -(ab/(b-a))/r^2; the piecewise-linear wall
      exceeds the optimal energy by exactly v^2 D / 36.

  8.  Causality dichotomy.
      For every V > 1 and T > 0, the boost beta = 2V/(V^2+1) lies in (0,1), sends the
      arrival event (T, VT) to a NEGATIVE boosted time, and the second warp leg of
      duration s = -T' closes the loop exactly: X' - V s = 0.
"""

from __future__ import annotations

import math
from typing import Callable, List, Sequence, Tuple

TOL = 1e-9


# ----------------------------------------------------------------------------------
# 1.  The metric, the shear, and the line element
# ----------------------------------------------------------------------------------

Matrix4 = List[List[float]]


def metric_matrix(w: float) -> Matrix4:
    """Covariant components g_{mu nu} of the Alcubierre metric at warp factor w."""
    return [
        [w * w - 1.0, -w, 0.0, 0.0],
        [-w, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def minkowski_matrix() -> Matrix4:
    """eta = diag(-1, 1, 1, 1)."""
    return [
        [-1.0, 0.0, 0.0, 0.0],
        [0.0, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def shear_matrix(w: float) -> Matrix4:
    """The unimodular shear S(w): (t,x,y,z) -> (t, x - w t, y, z)."""
    return [
        [1.0, 0.0, 0.0, 0.0],
        [-w, 1.0, 0.0, 0.0],
        [0.0, 0.0, 1.0, 0.0],
        [0.0, 0.0, 0.0, 1.0],
    ]


def mat_mul(a: Matrix4, b: Matrix4) -> Matrix4:
    n = len(a)
    return [[sum(a[i][k] * b[k][j] for k in range(n)) for j in range(n)] for i in range(n)]


def transpose(a: Matrix4) -> Matrix4:
    n = len(a)
    return [[a[j][i] for j in range(n)] for i in range(n)]


def det4(a: Matrix4) -> float:
    """Determinant of a 4x4 matrix by Gaussian elimination with partial pivoting."""
    m = [row[:] for row in a]
    det = 1.0
    for col in range(4):
        pivot = max(range(col, 4), key=lambda r: abs(m[r][col]))
        if abs(m[pivot][col]) < 1e-15:
            return 0.0
        if pivot != col:
            m[col], m[pivot] = m[pivot], m[col]
            det = -det
        det *= m[col][col]
        inv = 1.0 / m[col][col]
        for r in range(col + 1, 4):
            factor = m[r][col] * inv
            for c in range(col, 4):
                m[r][c] -= factor * m[col][c]
    return det


def line_element(w: float, u: Sequence[float]) -> float:
    """ds^2 applied to the tangent vector u = (u^t, u^x, u^y, u^z)."""
    return -u[0] ** 2 + (u[1] - w * u[0]) ** 2 + u[2] ** 2 + u[3] ** 2


def demo_structure() -> None:
    print("=" * 78)
    print("1.  POINTWISE STRUCTURE:  g(w) = S(w)^T eta S(w),  det g = -1")
    print("=" * 78)
    print(f"{'w':>8} {'det g':>14} {'max |S^T eta S - g|':>24}")
    for w in (0.0, 0.5, 1.0, 2.0, 10.0, 1000.0):
        s = shear_matrix(w)
        cong = mat_mul(mat_mul(transpose(s), minkowski_matrix()), s)
        g = metric_matrix(w)
        err = max(abs(cong[i][j] - g[i][j]) for i in range(4) for j in range(4))
        print(f"{w:>8.1f} {det4(g):>14.10f} {err:>24.2e}")
        assert abs(det4(g) + 1.0) < 1e-8 and err < 1e-9
    print("  -> determinant is exactly -1 and the congruence is exact for every w.\n")


# ----------------------------------------------------------------------------------
# 2.  Effective FTL without local FTL
# ----------------------------------------------------------------------------------

def local_speed(w: float, u: Sequence[float]) -> float:
    """Speed of the direction u relative to the local Eulerian observer n = (1,w,0,0)."""
    return abs(u[1] / u[0] - w)


def demo_ftl() -> None:
    print("=" * 78)
    print("2.  EFFECTIVE FTL WITHOUT LOCAL FTL")
    print("=" * 78)
    print(f"{'v_s':>10} {'ds^2 of ship':>16} {'coord. velocity':>18} {'local speed':>14}")
    for v in (0.5, 1.0, 2.0, 10.0, 100.0, 1e4):
        u = (1.0, v, 0.0, 0.0)
        ds2 = line_element(v, u)
        print(f"{v:>10.1f} {ds2:>16.10f} {u[1]/u[0]:>18.1f} {local_speed(v, u):>14.1e}")
        assert abs(ds2 + 1.0) < TOL and local_speed(v, u) < TOL
    print("  -> unit timelike for every warp speed, zero local speed, unbounded coordinate speed.")

    v = 10.0
    print(f"\n  In the ambient flat region (w = 0), the same motion with v = {v} has")
    print(f"  ds^2 = {line_element(0.0, (1.0, v, 0.0, 0.0)):+.1f} > 0: SPACELIKE, i.e. forbidden.")
    assert line_element(0.0, (1.0, v, 0.0, 0.0)) > 0

    print("\n  Strict local speed bound |u^x/u^t - w| < 1 for random timelike vectors:")
    worst = 0.0
    seed = 12345
    for _ in range(2000):
        # crude deterministic pseudo-random generator, keeps the demo dependency-free
        seed = (1103515245 * seed + 12345) % (2 ** 31)
        r1 = seed / 2 ** 31
        seed = (1103515245 * seed + 12345) % (2 ** 31)
        r2 = seed / 2 ** 31
        seed = (1103515245 * seed + 12345) % (2 ** 31)
        r3 = seed / 2 ** 31
        w = 20.0 * (r1 - 0.5)
        ut = 1.0
        ux = w + 0.999 * (2.0 * r2 - 1.0)
        uy = 0.01 * (2.0 * r3 - 1.0)
        u = (ut, ux, uy, 0.0)
        if line_element(w, u) < 0:
            worst = max(worst, local_speed(w, u))
    print(f"    worst observed local speed over 2000 timelike samples: {worst:.6f} < 1\n")
    assert worst < 1.0


# ----------------------------------------------------------------------------------
# 3-4.  Expansion dipole and the toroidal exotic region
# ----------------------------------------------------------------------------------

def bubble_radius(x_s: float, x: float, y: float, z: float) -> float:
    return math.sqrt((x - x_s) ** 2 + y * y + z * z)


def expansion(v: float, df: float, x_s: float, x: float, y: float, z: float) -> float:
    """York expansion scalar theta = v f'(r) (x - x_s)/r."""
    r = bubble_radius(x_s, x, y, z)
    return v * df * (x - x_s) / r


def energy_density(v: float, df: float, x_s: float, x: float, y: float, z: float) -> float:
    """rho = -(1/8pi) v^2 (y^2+z^2)/(4 r^2) f'(r)^2."""
    r = bubble_radius(x_s, x, y, z)
    return -(1.0 / (8.0 * math.pi)) * (v * v * (y * y + z * z) / (4.0 * r * r)) * df * df


def demo_expansion_and_density() -> None:
    print("=" * 78)
    print("3.  EXPANSION:  space expands behind the ship, contracts ahead")
    print("=" * 78)
    v, df, x_s = 2.0, -1.0, 0.0  # decreasing shape function, ship at the origin
    print(f"{'x - x_s':>10} {'theta':>14} {'sign':>10}")
    for dx in (-3.0, -2.0, -1.0, 0.0, 1.0, 2.0, 3.0):
        th = expansion(v, df, x_s, x_s + dx, 1.0, 0.0)
        sign = "expand" if th > TOL else ("contract" if th < -TOL else "zero")
        print(f"{dx:>10.1f} {th:>14.6f} {sign:>10}")
    for s in (0.5, 1.0, 2.5):
        a = expansion(v, df, x_s, x_s + s, 0.7, 0.3)
        b = expansion(v, df, x_s, x_s - s, 0.7, 0.3)
        assert abs(a + b) < TOL
    print("  -> exactly odd about the transverse plane: theta(x_s+s) = -theta(x_s-s).\n")

    print("=" * 78)
    print("4.  ENERGY DENSITY:  never positive, and vanishing exactly on the axis")
    print("=" * 78)
    print(f"{'(y,z)':>14} {'x - x_s':>10} {'rho':>16}")
    for (y, z) in ((0.0, 0.0), (0.0, 1.0), (1.0, 1.0)):
        for dx in (-1.0, 0.5, 1.0):
            rho = energy_density(v, df, x_s, x_s + dx, y, z)
            print(f"{f'({y},{z})':>14} {dx:>10.1f} {rho:>16.8f}")
            assert rho <= TOL
            if y == 0.0 and z == 0.0:
                assert abs(rho) < TOL
    print("  -> zero on the axis y = z = 0, strictly negative off it: a TORUS of exotic matter.\n")


# ----------------------------------------------------------------------------------
# 5-6.  Total energy, exact formula, and quadratic scaling
# ----------------------------------------------------------------------------------

def wall_shape_deriv(R: float, D: float) -> Callable[[float], float]:
    """Derivative of the piecewise-linear thin-wall shape function."""
    def g(r: float) -> float:
        return -1.0 / D if (R - D / 2.0) < r < (R + D / 2.0) else 0.0
    return g


def radial_warp_energy_quadrature(v: float, g: Callable[[float], float],
                                  r_lo: float, r_hi: float, n: int = 400_000) -> float:
    """Numerical value of E = -(v^2/12) int g(r)^2 r^2 dr on [r_lo, r_hi] (midpoint rule).

    The profile vanishes identically outside the wall, so restricting the quadrature to
    an interval containing the wall computes the full integral over (0, infinity).
    """
    h = (r_hi - r_lo) / n
    total = 0.0
    for k in range(n):
        r = r_lo + (k + 0.5) * h
        total += g(r) ** 2 * r * r
    return -(v * v / 12.0) * total * h


def wall_energy_exact(v: float, R: float, D: float) -> float:
    """E(v,R,D) = -(v^2/12)(R^2/D + D/12), valid for 0 < D < 2R."""
    return -(v * v / 12.0) * (R * R / D + D / 12.0)


def demo_energy() -> None:
    print("=" * 78)
    print("5.  EXACT THIN-WALL ENERGY  E = -(v^2/12)(R^2/D + D/12)")
    print("=" * 78)
    print(f"{'v':>6} {'R':>8} {'Delta':>8} {'exact E':>18} {'quadrature':>18} {'rel. err':>12}")
    for (v, R, D) in ((2.0, 100.0, 1.0), (1.0, 10.0, 0.5), (3.0, 50.0, 2.0), (2.0, 100.0, 0.1)):
        exact = wall_energy_exact(v, R, D)
        num = radial_warp_energy_quadrature(v, wall_shape_deriv(R, D),
                                            R - D / 2.0, R + D / 2.0)
        rel = abs(num - exact) / abs(exact)
        print(f"{v:>6.1f} {R:>8.1f} {D:>8.2f} {exact:>18.6f} {num:>18.6f} {rel:>12.2e}")
        assert rel < 1e-4
    print(f"\n  Closed-form instance: E(2, R=100, D=1) = -120001/36 = {-120001/36:.6f}")
    assert abs(wall_energy_exact(2.0, 100.0, 1.0) + 120001 / 36) < 1e-9

    print("\n  Thin-wall blow-up (fixed R = 100, v = 2):")
    print(f"{'Delta':>10} {'E':>20}")
    for D in (1.0, 0.1, 0.01, 0.001, 0.0001):
        print(f"{D:>10.4f} {wall_energy_exact(2.0, 100.0, D):>20.2f}")
    print("  -> |E| grows like 1/Delta without bound.\n")

    print("=" * 78)
    print("6.  QUADRATIC, NOT LINEAR:  E(lam v) = lam^2 E(v);  E ~ M v_s c is FALSE")
    print("=" * 78)
    R, D = 100.0, 1.0
    e1 = wall_energy_exact(1.0, R, D)
    print(f"{'v':>8} {'E(v)':>18} {'E(v)/E(1)':>14} {'v^2':>10}")
    for v in (1.0, 2.0, 3.0, 4.0, 10.0):
        e = wall_energy_exact(v, R, D)
        print(f"{v:>8.1f} {e:>18.4f} {e/e1:>14.4f} {v*v:>10.1f}")
        assert abs(e / e1 - v * v) < 1e-9
    print("\n  Any putative linear law E = C v is refuted: fitting C at v = 1 gives")
    print(f"    predicted E(2) = {2*e1:.4f}  but the true value is {wall_energy_exact(2.0,R,D):.4f}.")
    K = R * R / (12.0 * D) + D / 144.0
    for M in (1.0, 1e3, 1e6):
        v0 = M / K
        v_test = 2.0 * v0
        assert abs(wall_energy_exact(v_test, R, D)) > M * v_test
        print(f"    for M = {M:>8.0e}: |E(v)| > M v for all v > M/K = {v0:.6g}")
    print()


# ----------------------------------------------------------------------------------
# 7.  The sharp variational floor
# ----------------------------------------------------------------------------------

def energy_floor(a: float, b: float) -> float:
    """The geometric floor lambda(a,b) = ab/(b-a) of the cost integral."""
    return a * b / (b - a)


def optimal_profile_deriv(a: float, b: float) -> Callable[[float], float]:
    """The unique minimiser g*(r) = -(ab/(b-a))/r^2."""
    lam = energy_floor(a, b)
    return lambda r: -lam / (r * r)


def cost_integral(g: Callable[[float], float], a: float, b: float, n: int = 200_000) -> float:
    """int_a^b g(r)^2 r^2 dr by the midpoint rule."""
    h = (b - a) / n
    return sum(g(a + (k + 0.5) * h) ** 2 * (a + (k + 0.5) * h) ** 2 for k in range(n)) * h


def normalisation(g: Callable[[float], float], a: float, b: float, n: int = 200_000) -> float:
    """int_a^b g(r) dr, which must equal -1 for an admissible profile."""
    h = (b - a) / n
    return sum(g(a + (k + 0.5) * h) for k in range(n)) * h


def demo_variational_floor() -> None:
    print("=" * 78)
    print("7.  SHARP VARIATIONAL FLOOR:  int_a^b g^2 r^2 dr >= ab/(b-a)")
    print("=" * 78)
    R, D = 100.0, 1.0
    a, b = R - D / 2.0, R + D / 2.0
    lam = energy_floor(a, b)
    print(f"  shell [a,b] = [{a}, {b}],  floor lambda = ab/(b-a) = {lam:.6f}")
    print(f"  closed form for a wall of thickness D at radius R:  R^2/D - D/4 = "
          f"{R*R/D - D/4:.6f}")
    assert abs(lam - (R * R / D - D / 4.0)) < 1e-9

    candidates: List[Tuple[str, Callable[[float], float]]] = [
        ("optimal  g* ~ -1/r^2", optimal_profile_deriv(a, b)),
        ("linear wall  -1/D", wall_shape_deriv(R, D)),
        ("tent profile", lambda r: -(6.0 / D ** 3) * (r - a) * (b - r)),
        ("edge-loaded", lambda r: -(1.0 / (2.0 * math.sqrt(max(r - a, 1e-12) * (b - a))))
         if r > a else 0.0),
    ]
    print(f"\n{'profile':>24} {'int g dr':>12} {'cost':>16} {'cost - floor':>16}")
    for name, g in candidates:
        norm = normalisation(g, a, b)
        cost = cost_integral(g, a, b)
        print(f"{name:>24} {norm:>12.6f} {cost:>16.6f} {cost - lam:>16.6f}")
        if abs(norm + 1.0) < 1e-3:
            assert cost >= lam - 1e-4, "the floor must never be beaten"

    v = 2.0
    optimal_energy = -(v * v / 12.0) * lam
    linear_energy = wall_energy_exact(v, R, D)
    print(f"\n  At v = {v}:  optimal energy = {optimal_energy:.6f},  "
          f"linear wall = {linear_energy:.6f}")
    print(f"  excess of the linear wall = {optimal_energy - linear_energy:.8f}"
          f"   (predicted v^2 D/36 = {v*v*D/36:.8f})")
    assert abs((optimal_energy - linear_energy) - v * v * D / 36.0) < 1e-8
    print("  -> the naive design misses the optimum by only O(Delta); the 1/Delta")
    print("     divergence is universal, not an artefact of a bad profile.\n")


# ----------------------------------------------------------------------------------
# 8.  The causality dichotomy: two corridors close a loop
# ----------------------------------------------------------------------------------

def boost_t(beta: float, t: float, x: float) -> float:
    return (t - beta * x) / math.sqrt(1.0 - beta * beta)


def boost_x(beta: float, t: float, x: float) -> float:
    return (x - beta * t) / math.sqrt(1.0 - beta * beta)


def antitelephone(V: float, T: float) -> Tuple[float, float, float, float]:
    """Return (beta, T', X', s) for the loop-closing two-corridor construction."""
    beta = 2.0 * V / (V * V + 1.0)
    tp = boost_t(beta, T, V * T)
    xp = boost_x(beta, T, V * T)
    return beta, tp, xp, -tp


def demo_causality() -> None:
    print("=" * 78)
    print("8.  CAUSALITY DICHOTOMY")
    print("=" * 78)
    print("  (i) One bubble: coordinate time is a global time function (g^tt = -1),")
    print("      so no closed causal curve exists -- for ANY shape function.")
    print("      Numerically: dt/ds never vanishes along a causal curve.")
    seed = 999
    min_abs_ut = float("inf")
    for _ in range(5000):
        seed = (1103515245 * seed + 12345) % (2 ** 31)
        r1 = seed / 2 ** 31
        seed = (1103515245 * seed + 12345) % (2 ** 31)
        r2 = seed / 2 ** 31
        w = 50.0 * (r1 - 0.5)
        ut = 2.0 * (r2 - 0.5)
        ux = w * ut + 0.5 * ut
        u = (ut, ux, 0.0, 0.0)
        if line_element(w, u) <= 0 and any(abs(c) > 1e-12 for c in u):
            min_abs_ut = min(min_abs_ut, abs(ut))
    print(f"      smallest |u^t| observed over 5000 nonzero causal samples: {min_abs_ut:.3e} > 0\n")

    print("  (ii) Two corridors in relative motion CLOSE A LOOP.")
    print(f"{'V':>7} {'T':>7} {'interval':>12} {'beta':>10} {'T-prime':>12} "
          f"{'s':>10} {'X - V s':>12}")
    for (V, T) in ((1.5, 1.0), (2.0, 1.0), (5.0, 3.0), (10.0, 0.5), (100.0, 1.0)):
        interval = -T * T + (V * T) ** 2   # spacelike separation of the first leg
        beta, tp, xp, s = antitelephone(V, T)
        closure = xp - V * s
        print(f"{V:>7.1f} {T:>7.1f} {interval:>12.4f} {beta:>10.6f} {tp:>12.6f} "
              f"{s:>10.6f} {closure:>12.2e}")
        assert interval > 0            # the warp leg is spacelike in the background frame
        assert 0.0 < beta < 1.0        # the boost is an honest subluminal boost
        assert tp < 0.0                # arrival is already in the past of the boosted frame
        assert s > 0.0                 # the return leg takes positive time
        assert abs(closure) < 1e-9     # the loop closes EXACTLY
    print("  -> for every V > 1 the traveller returns to the very event they departed from.\n")

    V, T = 2.0, 1.0
    beta, tp, xp, s = antitelephone(V, T)
    print(f"  Worked example V = {V}, T = {T}:")
    print(f"    leg 1 in frame S:  (0,0) -> ({T}, {V*T})   [spacelike separation "
          f"{-T*T + (V*T)**2:+.3f}]")
    print(f"    boost velocity beta = 2V/(V^2+1) = {beta:.6f}")
    print(f"    arrival event in S': (t',x') = ({tp:.6f}, {xp:.6f})   -- negative time!")
    print(f"    leg 2 in frame S':  duration s = {s:.6f} > 0, speed V, directed backwards")
    print(f"    final event in S':  ({tp + s:.1e}, {xp - V*s:.1e}) = the origin = departure.\n")


def main() -> None:
    print()
    print("#" * 78)
    print("#  THE ALCUBIERRE WARP DRIVE: EXACT ENERGETICS AND CAUSALITY  (c = G = 1)")
    print("#" * 78)
    print()
    demo_structure()
    demo_ftl()
    demo_expansion_and_density()
    demo_energy()
    demo_variational_floor()
    demo_causality()
    print("All numerical checks passed.")


if __name__ == "__main__":
    main()
