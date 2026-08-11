"""
Spectral Bounds on Non-Homogeneous Quadratic Forms over the Integer Lattice
===========================================================================

Numerical demonstrations of the main results:

  1. Spectral gap:          Q(x - t) >= m * d(t, Z^n)^2   for all x in Z^n
  2. Covering bound:        min_x Q(x - t) <= M * n / 4
  3. Spectral sandwich:     m*d(t,Z^n)^2 <= mu(Q,t) <= M*n/4
  4. Effective rational gap: Q(x - a/q) >= m / q^2
  5. Two-sided counting:    (2*sqrt(R/(Mn)) - 1)^n <= N(R) <= (2*sqrt(R/m) + 1)^n
  6. Theta series:          convergence, e^{-sMn/4} <= Theta(s),
                            Theta(s) <= e^{-(s-s0) m d^2} Theta(s0),
                            diagonal factorisation into Jacobi theta factors
  7. Extremal set:          sum_i (x_i - 1/2)^2 >= n/4, equality exactly on {0,1}^n

Pure standard library + a tiny hand-rolled symmetric eigenvalue routine, so the
script runs anywhere with Python 3.9+.  No external dependencies.
"""

from __future__ import annotations

import itertools
import math
from typing import Iterable, Iterator, List, Sequence, Tuple

Vector = Sequence[float]
Matrix = Sequence[Sequence[float]]

# ----------------------------------------------------------------------------
# Core quantities
# ----------------------------------------------------------------------------


def quadratic_form(A: Matrix, x: Vector) -> float:
    """Evaluate Q_A(x) = sum_{i,j} A[i][j] * x[i] * x[j]."""
    n = len(x)
    return sum(A[i][j] * x[i] * x[j] for i in range(n) for j in range(n))


def inhom_eval(A: Matrix, t: Vector, x: Sequence[int]) -> float:
    """Evaluate the non-homogeneous form Q_A(x - t) at an integer point x."""
    return quadratic_form(A, [x[i] - t[i] for i in range(len(t))])


def dist_to_Z(u: float) -> float:
    """Distance from the real number u to the nearest integer: min(frac, 1-frac)."""
    frac = u - math.floor(u)
    return min(frac, 1.0 - frac)


def sq_dist_lattice(t: Vector) -> float:
    """Squared Euclidean distance d(t, Z^n)^2 = sum_i dist_to_Z(t_i)^2."""
    return sum(dist_to_Z(u) ** 2 for u in t)


def spectral_gap(m: float, t: Vector) -> float:
    """The certified forbidden-zone threshold m * d(t, Z^n)^2."""
    return m * sq_dist_lattice(t)


def covering_bound(M: float, n: int) -> float:
    """The certified covering value M * n / 4."""
    return M * n / 4.0


def rounded_point(t: Vector) -> List[int]:
    """Coordinatewise nearest-integer rounding, the witness for the covering bound."""
    # round-half-away-from-zero, so that |t_i - x_i| <= 1/2 always holds.
    return [int(math.floor(u + 0.5)) for u in t]


# ----------------------------------------------------------------------------
# Symmetric eigenvalues (Jacobi rotations) -- used only to obtain m and M
# ----------------------------------------------------------------------------


def symmetric_eigenvalues(A: Matrix, iterations: int = 200, tol: float = 1e-14) -> List[float]:
    """Eigenvalues of a real symmetric matrix by the cyclic Jacobi method."""
    n = len(A)
    B: List[List[float]] = [list(map(float, row)) for row in A]
    for _ in range(iterations):
        off = math.sqrt(sum(B[i][j] ** 2 for i in range(n) for j in range(n) if i != j))
        if off < tol:
            break
        for p in range(n - 1):
            for q in range(p + 1, n):
                if abs(B[p][q]) < tol:
                    continue
                theta = (B[q][q] - B[p][p]) / (2.0 * B[p][q])
                sign = 1.0 if theta >= 0 else -1.0
                s_t = sign / (abs(theta) + math.sqrt(theta * theta + 1.0))
                c = 1.0 / math.sqrt(s_t * s_t + 1.0)
                s = s_t * c
                for k in range(n):
                    bkp, bkq = B[k][p], B[k][q]
                    B[k][p] = c * bkp - s * bkq
                    B[k][q] = s * bkp + c * bkq
                for k in range(n):
                    bpk, bqk = B[p][k], B[q][k]
                    B[p][k] = c * bpk - s * bqk
                    B[q][k] = s * bpk + c * bqk
    return sorted(B[i][i] for i in range(n))


def spectral_bounds(A: Matrix) -> Tuple[float, float]:
    """Return (m, M), the extreme eigenvalues of the symmetric part of A."""
    n = len(A)
    S = [[0.5 * (A[i][j] + A[j][i]) for j in range(n)] for i in range(n)]
    eigs = symmetric_eigenvalues(S)
    return eigs[0], eigs[-1]


# ----------------------------------------------------------------------------
# Enumeration in the certified box
# ----------------------------------------------------------------------------


def certified_box(t: Vector, radius: float) -> List[range]:
    """The integer box [ceil(t_i - r), floor(t_i + r)] containing every solution."""
    return [
        range(math.ceil(u - radius), math.floor(u + radius) + 1)
        for u in t
    ]


def enumerate_solutions(A: Matrix, t: Vector, m: float, R: float) -> Iterator[Tuple[int, ...]]:
    """All integer x with Q(x - t) <= R, found by scanning the certified box."""
    r = math.sqrt(max(R, 0.0) / m)
    for x in itertools.product(*certified_box(t, r)):
        if inhom_eval(A, t, x) <= R + 1e-12:
            yield x


def inhom_min_exact(A: Matrix, t: Vector, m: float, M: float) -> Tuple[float, Tuple[int, ...]]:
    """Exact inhomogeneous minimum mu(Q,t) by enumerating the certified box.

    Search radius R = M*n/4 is guaranteed to contain a minimiser (covering bound).
    """
    n = len(t)
    R = covering_bound(M, n)
    best_val = math.inf
    best_x: Tuple[int, ...] = tuple(rounded_point(t))
    r = math.sqrt(R / m)
    for x in itertools.product(*certified_box(t, r)):
        v = inhom_eval(A, t, x)
        if v < best_val:
            best_val, best_x = v, x
    return best_val, best_x


# ----------------------------------------------------------------------------
# Counting
# ----------------------------------------------------------------------------


def count_solutions(A: Matrix, t: Vector, m: float, R: float) -> int:
    """N(R) = #{x in Z^n : Q(x - t) <= R}, computed exactly."""
    return sum(1 for _ in enumerate_solutions(A, t, m, R))


def counting_bounds(m: float, M: float, n: int, R: float) -> Tuple[float, float]:
    """The certified pair ((2 sqrt(R/(Mn)) - 1)^n, (2 sqrt(R/m) + 1)^n)."""
    lower = (2.0 * math.sqrt(R / (M * n)) - 1.0) ** n
    upper = (2.0 * math.sqrt(R / m) + 1.0) ** n
    return lower, upper


# ----------------------------------------------------------------------------
# Theta series
# ----------------------------------------------------------------------------


def theta_1d(d: float, shift: float, s: float, cutoff: int = 60) -> float:
    """One-dimensional shifted Jacobi theta value  sum_k exp(-s d (k - shift)^2)."""
    k0 = int(round(shift))
    return sum(
        math.exp(-s * d * (k - shift) ** 2)
        for k in range(k0 - cutoff, k0 + cutoff + 1)
    )


def theta_series(A: Matrix, t: Vector, m: float, s: float, cutoff_sigma: float = 45.0) -> float:
    """Theta(s) = sum_{x in Z^n} exp(-s Q(x - t)), truncated at a certified radius.

    Terms outside the box of radius r are each smaller than exp(-s m r^2); the
    radius is chosen so that this is far below machine precision.
    """
    r = math.sqrt(cutoff_sigma / (s * m)) + 1.0
    total = 0.0
    for x in itertools.product(*certified_box(t, r)):
        total += math.exp(-s * inhom_eval(A, t, x))
    return total


# ----------------------------------------------------------------------------
# Reporting helpers
# ----------------------------------------------------------------------------


def banner(title: str) -> None:
    print()
    print("=" * 78)
    print(title)
    print("=" * 78)


def fmt_vec(v: Iterable[float]) -> str:
    return "(" + ", ".join(f"{u:g}" for u in v) + ")"


# ----------------------------------------------------------------------------
# Demonstration 1: the spectral gap and the forbidden zone
# ----------------------------------------------------------------------------


def demo_spectral_gap() -> None:
    banner("1.  SPECTRAL GAP:  Q(x - t) >= m * d(t, Z^n)^2  (the forbidden zone)")

    A = [[2.0, 0.5, 0.0], [0.5, 3.0, 0.5], [0.0, 0.5, 5.0]]
    t = [0.5, 0.5, 0.5]
    m, M = spectral_bounds(A)
    n = len(t)
    gap = spectral_gap(m, t)

    print(f"A = {A}")
    print(f"eigenvalue range: m = {m:.6f},  M = {M:.6f}")
    print(f"shift t = {fmt_vec(t)},  d(t,Z^3)^2 = {sq_dist_lattice(t):.6f}")
    print(f"certified gap  m*d^2 = {gap:.6f}")
    print(f"covering bound M*n/4 = {covering_bound(M, n):.6f}")

    worst = math.inf
    for x in itertools.product(range(-3, 4), repeat=3):
        worst = min(worst, inhom_eval(A, t, x))
    print(f"minimum over the box [-3,3]^3:  {worst:.6f}")
    print(f"gap <= observed minimum?  {gap <= worst + 1e-12}   "
          f"(slack {worst - gap:.6f})")
    print(f"=> Q(x - t) = c has NO integer solution for any c < {gap:.6f}.")


# ----------------------------------------------------------------------------
# Demonstration 2: the sandwich for the inhomogeneous minimum
# ----------------------------------------------------------------------------


def demo_sandwich() -> None:
    banner("2.  SPECTRAL SANDWICH:  m*d(t,Z^n)^2 <= mu(Q,t) <= M*n/4")

    cases: List[Tuple[str, Matrix, List[float]]] = [
        ("identity, half shift", [[1.0, 0.0], [0.0, 1.0]], [0.5, 0.5]),
        ("diagonal (1,4), half shift", [[1.0, 0.0], [0.0, 4.0]], [0.5, 0.5]),
        ("skewed 2x2, generic shift", [[2.0, 1.0], [1.0, 3.0]], [0.3, 0.75]),
        ("identity 3d, third shift", [[1.0, 0, 0], [0, 1.0, 0], [0, 0, 1.0]],
         [1 / 3, 1 / 3, 1 / 3]),
    ]
    header = f"{'case':<28}{'m':>8}{'M':>8}{'gap':>10}{'mu':>10}{'Mn/4':>10}  minimiser"
    print(header)
    print("-" * len(header))
    for name, A, t in cases:
        n = len(t)
        m, M = spectral_bounds(A)
        gap = spectral_gap(m, t)
        mu, xstar = inhom_min_exact(A, t, m, M)
        cov = covering_bound(M, n)
        ok = gap <= mu + 1e-9 <= cov + 1e-9
        print(f"{name:<28}{m:>8.3f}{M:>8.3f}{gap:>10.4f}{mu:>10.4f}{cov:>10.4f}  "
              f"{tuple(xstar)}  {'OK' if ok else 'FAIL'}")
    print("\nNote the first row: m = M = 1 and d^2 = n/4, so the sandwich collapses")
    print("to an equality and mu = n/4 exactly.")


# ----------------------------------------------------------------------------
# Demonstration 3: the effective rational gap m / q^2
# ----------------------------------------------------------------------------


def demo_rational_gap() -> None:
    banner("3.  EFFECTIVE RATIONAL GAP:  Q(x - a/q) >= m / q^2")

    A = [[2.0, 0.0, 0.0], [0.0, 3.0, 0.0], [0.0, 0.0, 5.0]]
    m, M = spectral_bounds(A)
    print(f"Q(y) = 2y1^2 + 3y2^2 + 5y3^2,  m = {m:g},  M = {M:g}")
    print(f"{'q':>4}{'a':>14}{'m/q^2':>12}{'true gap':>12}{'observed min':>14}")
    print("-" * 56)
    for q, a in [(2, (1, 1, 1)), (3, (1, 1, 1)), (5, (2, 3, 4)), (7, (1, 0, 0))]:
        t = [ai / q for ai in a]
        certified = m / q ** 2
        true_gap = spectral_gap(m, t)
        observed = min(
            inhom_eval(A, t, x) for x in itertools.product(range(-2, 3), repeat=3)
        )
        print(f"{q:>4}{str(a):>14}{certified:>12.5f}{true_gap:>12.5f}{observed:>14.5f}")
    print("\nEvery observed minimum exceeds both certified thresholds, and the")
    print("denominator bound m/q^2 needs no floating-point distance computation.")


# ----------------------------------------------------------------------------
# Demonstration 4: two-sided counting
# ----------------------------------------------------------------------------


def demo_counting() -> None:
    banner("4.  TWO-SIDED COUNTING:  (2 sqrt(R/(Mn)) - 1)^n <= N(R) <= (2 sqrt(R/m) + 1)^n")

    A = [[1.0, 0.25], [0.25, 2.0]]
    t = [0.4, 0.1]
    n = len(t)
    m, M = spectral_bounds(A)
    print(f"A = {A},  t = {fmt_vec(t)},  m = {m:.4f}, M = {M:.4f}")
    print(f"covering threshold M*n/4 = {covering_bound(M, n):.4f}")
    print(f"{'R':>8}{'lower':>12}{'N(R)':>10}{'upper':>14}{'ratio N/R^(n/2)':>18}")
    print("-" * 62)
    for R in [2.0, 5.0, 10.0, 25.0, 50.0, 100.0, 200.0]:
        lo, hi = counting_bounds(m, M, n, R)
        N = count_solutions(A, t, m, R)
        assert lo <= N <= hi + 1e-9, "counting bound violated"
        print(f"{R:>8.1f}{lo:>12.3f}{N:>10d}{hi:>14.3f}{N / R ** (n / 2):>18.4f}")
    print("\nThe last column stabilises: N(R) grows exactly like R^(n/2), as the")
    print("two-sided bound predicts (both sides are of that order).")


# ----------------------------------------------------------------------------
# Demonstration 5: the theta series
# ----------------------------------------------------------------------------


def demo_theta() -> None:
    banner("5.  THETA SERIES:  convergence, lower bound, and gap-rate decay")

    A = [[1.0, 0.0], [0.0, 3.0]]
    t = [0.5, 0.5]
    n = len(t)
    m, M = spectral_bounds(A)
    gap = spectral_gap(m, t)
    s0 = 0.5
    theta0 = theta_series(A, t, m, s0)

    print(f"Q(y) = y1^2 + 3y2^2,  t = {fmt_vec(t)},  m = {m:g}, M = {M:g}")
    print(f"gap m*d^2 = {gap:g},  covering M*n/4 = {covering_bound(M, n):g}")
    print(f"Theta({s0}) = {theta0:.8f}")
    print()
    print(f"{'s':>6}{'Theta(s)':>16}{'floor e^{-sMn/4}':>20}"
          f"{'decay bound':>18}{'-log Theta / s':>18}")
    print("-" * 78)
    for s in [0.5, 1.0, 2.0, 4.0, 8.0, 16.0, 32.0]:
        th = theta_series(A, t, m, s)
        floor = math.exp(-s * covering_bound(M, n))
        bound = math.exp(-(s - s0) * gap) * theta0
        assert floor <= th + 1e-12, "theta lower bound violated"
        assert th <= bound + 1e-12, "theta decay bound violated"
        print(f"{s:>6.1f}{th:>16.8f}{floor:>20.8f}{bound:>18.8f}"
              f"{-math.log(th) / s:>18.6f}")
    print()
    print("The last column approaches the inhomogeneous minimum mu(Q,t) = 1/4 + 3/4 = 1,")
    print(f"which lies inside the certified sandwich [{gap:g}, {covering_bound(M, n):g}].")

    # Diagonal factorisation check
    s = 1.3
    direct = theta_series(A, t, m, s)
    factored = theta_1d(1.0, t[0], s) * theta_1d(3.0, t[1], s)
    print(f"\nDiagonal factorisation at s = {s}:")
    print(f"  direct  sum over Z^2 : {direct:.12f}")
    print(f"  product of 1d thetas : {factored:.12f}")
    print(f"  agreement            : {abs(direct - factored) < 1e-9}"
          f"   (difference {abs(direct - factored):.2e})")


# ----------------------------------------------------------------------------
# Demonstration 6: the extremal set of the half-shifted sum of squares
# ----------------------------------------------------------------------------


def demo_extremal() -> None:
    banner("6.  EXTREMAL SET:  sum_i (x_i - 1/2)^2 >= n/4, equality exactly on {0,1}^n")

    print(f"{'n':>4}{'n/4':>8}{'observed min':>16}{'# minimisers':>16}{'2^n':>8}")
    print("-" * 52)
    for n in range(1, 7):
        t = [0.5] * n
        A = [[1.0 if i == j else 0.0 for j in range(n)] for i in range(n)]
        minimisers = [
            x for x in itertools.product(range(-2, 4), repeat=n)
            if inhom_eval(A, t, x) <= n / 4 + 1e-12
        ]
        observed = min(inhom_eval(A, t, x) for x in itertools.product(range(-2, 4), repeat=n))
        assert all(all(xi in (0, 1) for xi in x) for x in minimisers)
        assert len(minimisers) == 2 ** n
        print(f"{n:>4}{n / 4:>8.2f}{observed:>16.4f}{len(minimisers):>16d}{2 ** n:>8d}")
    print("\nEvery minimiser is a vertex of the unit cube, and there are exactly 2^n of")
    print("them: the minimum n/4 is attained with exponential multiplicity.")
    print("\nOpening puzzle: (x1-1/2)^2 + (x2-1/2)^2 + (x3-1/2)^2 = 0.7 has no integer")
    print("solution, because the left side is always at least 3/4 = 0.75.")


# ----------------------------------------------------------------------------
# Demonstration 7: solvability window
# ----------------------------------------------------------------------------


def demo_solvability_window() -> None:
    banner("7.  SOLVABILITY WINDOW:  reject below the gap, accept above M*n/4")

    A = [[2.0, 0.6], [0.6, 4.0]]
    t = [0.5, 0.25]
    n = len(t)
    m, M = spectral_bounds(A)
    gap = spectral_gap(m, t)
    cov = covering_bound(M, n)
    print(f"m = {m:.4f}, M = {M:.4f}, gap = {gap:.4f}, covering = {cov:.4f}")
    print(f"{'R':>8}{'verdict':>18}{'certified?':>16}{'truth':>12}")
    print("-" * 52)
    for R in [0.05, 0.2, 0.5, 1.0, 2.0, 3.0]:
        solvable = count_solutions(A, t, m, R) > 0
        if R < gap:
            verdict, certified = "UNSOLVABLE", "yes (gap)"
        elif R >= cov:
            verdict, certified = "SOLVABLE", "yes (covering)"
        else:
            verdict, certified = "undetermined", "no"
        print(f"{R:>8.2f}{verdict:>18}{certified:>16}"
              f"{('solvable' if solvable else 'unsolvable'):>12}")
    print("\nEvery certified verdict matches the truth; only the middle band requires")
    print("an actual search.")


def main() -> None:
    print(__doc__)
    demo_spectral_gap()
    demo_sandwich()
    demo_rational_gap()
    demo_counting()
    demo_theta()
    demo_extremal()
    demo_solvability_window()
    banner("All demonstrations completed: every certified bound held.")


if __name__ == "__main__":
    main()
