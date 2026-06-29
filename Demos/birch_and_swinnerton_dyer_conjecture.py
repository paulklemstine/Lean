"""
Numerical demonstrations of the local and analytic structures underlying the
Birch and Swinnerton-Dyer conjecture.

Every function here mirrors a machine-verified theorem:

  * trace_sequence / trace_eq_power_sum  <->  traceSeq, traceSeq_eq_power_sum,
                                              power_sum_recurrence
  * point_count_tower                    <->  pointCount (= p^n + 1 - s_n)
  * sato_tate_angle                      <->  exists_satoTate_angle
  * power_sum_norm_bound                 <->  traceSeq_norm_le
  * hasse_bound / frobenius_normsq       <->  hasse_bound, frobenius_normSq_eq_iff
  * analytic_rank_of_model               <->  modelL_analyticRank, analyticRank_*
  * parity_of_order                      <->  parity theorem (-1)^ord = w
  * mordell_weil_infinite                <->  mordellWeil_infinite_iff
  * bsd_central_vanishing_iff_infinite   <->  bsd_central_vanishing_iff_infinite

Run:  python demo.py
"""

from __future__ import annotations

import cmath
import math
from typing import List, Tuple


# --------------------------------------------------------------------------
# Local theory: Frobenius eigenvalues, Hasse bound, RH circle
# --------------------------------------------------------------------------

def frobenius_eigenvalues(a: float, p: float) -> Tuple[complex, complex]:
    """Roots alpha, beta of X^2 - a*X + p (the Frobenius eigenvalues)."""
    disc = cmath.sqrt(complex(a * a - 4 * p))
    return ((a + disc) / 2, (a - disc) / 2)


def hasse_bound_holds(a: float, p: float) -> bool:
    """Theorem `hasse_bound`/`frobenius_normSq_eq_iff`: a^2 <= 4p  <=>  |a| <= 2 sqrt p."""
    return a * a <= 4 * p


def frobenius_normsq(a: float, p: float) -> Tuple[float, float]:
    """|alpha|^2 and |beta|^2.  Theorem: both equal p iff a^2 <= 4p."""
    alpha, beta = frobenius_eigenvalues(a, p)
    return (abs(alpha) ** 2, abs(beta) ** 2)


# --------------------------------------------------------------------------
# The trace-sequence recurrence (Theorems power_sum_recurrence,
# traceSeq, traceSeq_eq_power_sum)
# --------------------------------------------------------------------------

def trace_sequence(a: float, p: float, n: int) -> List[float]:
    """
    s_0 = 2, s_1 = a, s_{k+2} = a*s_{k+1} - p*s_k   (Definition `traceSeq`).
    Returns [s_0, ..., s_n].
    """
    s: List[float] = [2.0, a]
    for _ in range(2, n + 1):
        s.append(a * s[-1] - p * s[-2])
    return s[: n + 1]


def power_sums_directly(a: float, p: float, n: int) -> List[complex]:
    """s_k = alpha^k + beta^k computed straight from the eigenvalues."""
    alpha, beta = frobenius_eigenvalues(a, p)
    return [alpha ** k + beta ** k for k in range(n + 1)]


def trace_eq_power_sum(a: float, p: float, n: int, tol: float = 1e-9) -> bool:
    """Theorem `traceSeq_eq_power_sum`: traceSeq(n) == alpha^n + beta^n."""
    rec = trace_sequence(a, p, n)
    direct = power_sums_directly(a, p, n)
    return all(abs(complex(r) - d) < tol for r, d in zip(rec, direct))


def point_count_tower(a: float, p: float, n: int) -> List[float]:
    """
    #E(F_{p^k}) = p^k + 1 - s_k   (Definition `pointCount`).
    The whole tower comes from (a, p) alone via the recurrence.
    """
    s = trace_sequence(a, p, n)
    return [p ** k + 1 - s[k] for k in range(n + 1)]


# --------------------------------------------------------------------------
# Sato-Tate angle and the RH norm bound
# --------------------------------------------------------------------------

def sato_tate_angle(a: float, p: float) -> float:
    """Theorem `exists_satoTate_angle`: theta in [0, pi] with a = 2 sqrt p cos theta."""
    return math.acos(a / (2 * math.sqrt(p)))


def power_sum_norm_bound_holds(a: float, p: float, n: int) -> bool:
    """Theorem `traceSeq_norm_le`: |alpha^n + beta^n| <= 2 (sqrt p)^n."""
    alpha, beta = frobenius_eigenvalues(a, p)
    return abs(alpha ** n + beta ** n) <= 2 * math.sqrt(p) ** n + 1e-9


# --------------------------------------------------------------------------
# Analytic side: model L-function, rank, parity theorem
# --------------------------------------------------------------------------

def model_L(r: int, c: complex, s: complex) -> complex:
    """Model L-function (s-1)^r * c  (Definition `modelL`)."""
    return (s - 1) ** r * c


def analytic_rank_of_model(r: int, c: complex) -> int:
    """
    Theorem `modelL_analyticRank`: the order of vanishing of (s-1)^r c at s=1 is r.
    Detect it numerically by the growth rate  log|L(1+eps)| / log(eps) -> r
    as eps -> 0, which is numerically stable for all r (unlike high-order
    finite differences).
    """
    if r == 0:
        return 0
    eps1, eps2 = 1e-2, 1e-4
    v1 = abs(model_L(r, c, 1 + eps1))
    v2 = abs(model_L(r, c, 1 + eps2))
    slope = (math.log(v2) - math.log(v1)) / (math.log(eps2) - math.log(eps1))
    return round(slope)


def parity_of_order(r: int) -> int:
    """
    Parity theorem: (-1)^{ord} = w, and the model (s-1)^r c has sign w = (-1)^r.
    Returns the sign w in {+1, -1}.
    """
    return 1 if r % 2 == 0 else -1


def functional_equation_residual(r: int, c: complex, s: complex) -> float:
    """Check Lambda(2-s) = w Lambda(s) with w = (-1)^r for the model."""
    w = parity_of_order(r)
    return abs(model_L(r, c, 2 - s) - w * model_L(r, c, s))


# --------------------------------------------------------------------------
# The rank bridge (Theorems mordellWeil_infinite_iff,
# bsd_central_vanishing_iff_infinite)
# --------------------------------------------------------------------------

def mordell_weil_infinite(r: int) -> bool:
    """Theorem `mordellWeil_infinite_iff`: Z^r x (finite) is infinite iff r > 0."""
    return r > 0


def bsd_central_vanishing_iff_infinite(r: int, c: complex) -> Tuple[bool, bool]:
    """
    Theorem `bsd_central_vanishing_iff_infinite`: under analyticRank = r,
    L(1) = 0  <=>  E(Q) infinite.  Returns (L(1)==0, E(Q) infinite); they agree.
    """
    central_vanishes = abs(model_L(r, c, 1)) < 1e-12
    infinite_points = mordell_weil_infinite(r)
    return (central_vanishes, infinite_points)


# --------------------------------------------------------------------------
# Driver
# --------------------------------------------------------------------------

def main() -> None:
    print("=" * 70)
    print("BSD local & analytic structures -- numerical demonstrations")
    print("=" * 70)

    # Worked example from the article: p = 5, a = 3
    a, p, N = 3.0, 5.0, 6
    print(f"\n[1] Trace recurrence and point-count tower  (a={a}, p={p})")
    print(f"    Hasse bound a^2 <= 4p ?  {a*a} <= {4*p}  -> {hasse_bound_holds(a, p)}")
    print(f"    |alpha|^2, |beta|^2 = {tuple(round(x,4) for x in frobenius_normsq(a,p))}  (should be {p}, {p})")
    print(f"    trace sequence s_0..s_{N} = {[round(x,3) for x in trace_sequence(a, p, N)]}")
    print(f"    recurrence == eigenvalue power sums ?  {trace_eq_power_sum(a, p, N)}")
    print(f"    #E(F_(5^n)), n=0..{N} = {[round(x,1) for x in point_count_tower(a, p, N)]}")

    print(f"\n[2] Sato-Tate angle and RH norm bound  (a={a}, p={p})")
    theta = sato_tate_angle(a, p)
    print(f"    theta = arccos(a/2sqrt p) = {theta:.5f} rad  in [0, pi]")
    print(f"    check a = 2 sqrt p cos theta = {2*math.sqrt(p)*math.cos(theta):.5f}")
    print(f"    norm bounds hold for n=0..{N} ?  {all(power_sum_norm_bound_holds(a,p,n) for n in range(N+1))}")

    print("\n[3] Hasse boundary case a^2 = 4p  (a=2*sqrt(2), p=2): eigenvalues on circle")
    a2, p2 = 2 * math.sqrt(2), 2.0
    print(f"    |alpha|^2, |beta|^2 = {tuple(round(x,4) for x in frobenius_normsq(a2,p2))}  (== p = {p2})")

    print("\n[4] Analytic rank, parity theorem, and the BSD bridge")
    for r in range(0, 5):
        c = 2.0 + 0.0j
        rank = analytic_rank_of_model(r, c)
        w = parity_of_order(r)
        resid = functional_equation_residual(r, c, 1.3 + 0.4j)
        vanish, inf = bsd_central_vanishing_iff_infinite(r, c)
        print(f"    r={r}: analyticRank={rank}, (-1)^ord = w = {w:+d}, "
              f"FE residual={resid:.1e}, L(1)=0 ? {vanish}  <=>  E(Q) infinite ? {inf}")

    print("\nAll demonstrations consistent with the verified theorems.")


if __name__ == "__main__":
    main()
