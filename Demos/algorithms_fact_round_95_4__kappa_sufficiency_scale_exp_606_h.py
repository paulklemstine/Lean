"""
The four algorithms of the paper, in self-contained type-hinted Python.

They are separated here so each can be read, tested and reused on its own:

  A. exact_cell_census          -- exact cell counts and densities over one period
  B. window_cell_count          -- exact windowed cell count + certified error envelope
  C. slope_and_increment        -- OLS slope, identity increment, R^2, Popoviciu certificate
  D. locate_sufficiency_boundary-- unique crossing of a monotone increment through the bar
"""

from __future__ import annotations

from fractions import Fraction
from itertools import combinations
from math import sqrt
from typing import Callable, Dict, FrozenSet, List, NamedTuple, Sequence, Tuple

Cell = FrozenSet[int]


# ======================================================================================
# A.  Exact cell census over a period (totient factorisation method)
# ======================================================================================

class CellRecord(NamedTuple):
    cell: Cell
    kappa: int
    count: int
    density: Fraction


def exact_cell_census(base: Sequence[int]) -> List[CellRecord]:
    """
    For a base B of distinct primes, return for every subset S of B:
      count(S)   = |{ v < prod_{p in B} p : {p in B : p | v} = S }| = prod_{p not in S} (p-1)
      density(S) = prod_{p in S} 1/p * prod_{p not in S} (1 - 1/p)

    Correctness rests on the bijection u -> (prod_{p in S} p) * u between the residues
    below prod_{p not in S} p that are coprime to it, and the fibre over S.

    Complexity: O(2^|B| * |B|) arithmetic operations, independent of the period, which is
    astronomically larger.  No sampling and no enumeration of the period are involved.
    """
    records: List[CellRecord] = []
    for k in range(len(base) + 1):
        for combo in combinations(base, k):
            S = frozenset(combo)
            count = 1
            density = Fraction(1)
            for p in base:
                if p in S:
                    density *= Fraction(1, p)
                else:
                    count *= p - 1
                    density *= 1 - Fraction(1, p)
            records.append(CellRecord(S, len(S), count, density))
    return records


def mean_composition_order(base: Sequence[int]) -> Fraction:
    """Exact mean of kappa over one period: the truncated Mertens sum sum_{p in B} 1/p."""
    return sum((Fraction(1, p) for p in base), Fraction(0))


# ======================================================================================
# B.  Windowed cell count with a certified error envelope (Moebius truncation)
# ======================================================================================

class WindowEstimate(NamedTuple):
    exact_count: int
    predicted: float
    error: float
    certified_bound: int


def window_cell_count(base: Sequence[int], S: Cell, N: int) -> WindowEstimate:
    """
    Exact count of { v < N : cell(v) = S } via the Moebius expansion

        1[cell(v) = S] = sum_{T subset of B\\S} (-1)^{|T|} 1[ (prod_{p in S u T} p) | v ],

    together with the proved error envelope 2^{|B \\ S|} against the periodic prediction
    N * prod_{p in S} 1/p * prod_{p not in S} (1 - 1/p).

    The envelope is UNIFORM IN N: it does not grow with the window length.  This is what
    licenses treating cell frequencies measured on a sampled window as the exact periodic
    densities.

    Complexity: O(2^{|B\\S|}) arithmetic operations -- the window itself is never scanned.
    """
    outside = [p for p in base if p not in S]
    forced = 1
    for p in S:
        forced *= p

    total = 0
    for k in range(len(outside) + 1):
        for extra in combinations(outside, k):
            d = forced
            for p in extra:
                d *= p
            total += (-1) ** k * (-(-N // d))  # ceil(N/d) multiples of d in [0, N)

    density = 1.0
    for p in base:
        density *= (1.0 / p) if p in S else (1.0 - 1.0 / p)
    predicted = N * density
    return WindowEstimate(total, predicted, abs(total - predicted), 2 ** len(outside))


# ======================================================================================
# C.  Slope, identity increment, explained fraction, Popoviciu certificate
# ======================================================================================

class RegressionReport(NamedTuple):
    mean_kappa: float
    var_kappa: float
    var_log_rate: float
    slope: float
    increment: float
    explained_fraction: float
    popoviciu_cap: float
    certified_spread: float
    kappa_sufficient: bool


def slope_and_increment(base: Sequence[int],
                        q: Dict[int, float],
                        w: Dict[int, float],
                        bar: float = 0.02) -> RegressionReport:
    """
    For the product cell measure with marginals q and the additive log-rate
    Lambda(S) = dial - sum_{p in S} w_p, compute:

        v_p       = q_p (1 - q_p)
        E[kappa]  = sum_p q_p
        Var kappa = sum_p v_p
        Var Lambda= sum_p w_p^2 v_p
        slope     = -(sum_p w_p v_p) / (sum_p v_p)          [the v-weighted mean of -w]
        increment = (1/2 sum_{p,r} v_p v_r (w_p - w_r)^2) / sum_p v_p
        R^2       = 1 - increment / Var Lambda
        cap       = (sum_p v_p)(max w - min w)^2 / 4        [sharp Popoviciu envelope]
        spread    >= 2 sqrt(increment / sum_p v_p)          [read backwards from the cap]

    The dial cancels from every quantity, so it is not an argument.
    Complexity: O(|B|^2) for the pairwise energy, or O(|B|) via the moment form.
    """
    v = {p: q[p] * (1.0 - q[p]) for p in base}
    sum_v = sum(v[p] for p in base)
    mean_kappa = sum(q[p] for p in base)
    var_log = sum(w[p] ** 2 * v[p] for p in base)
    slope = -sum(w[p] * v[p] for p in base) / sum_v

    energy = 0.0
    for p in base:
        for r in base:
            energy += v[p] * v[r] * (w[p] - w[r]) ** 2
    increment = 0.5 * energy / sum_v

    lo, hi = min(w[p] for p in base), max(w[p] for p in base)
    cap = sum_v * (hi - lo) ** 2 / 4.0
    cert = 2.0 * sqrt(increment / sum_v) if increment > 0 else 0.0
    explained = 1.0 - increment / var_log if var_log > 0 else 1.0
    return RegressionReport(mean_kappa, sum_v, var_log, slope, increment,
                            explained, cap, cert, increment <= bar)


# ======================================================================================
# D.  Unique sufficiency-boundary localisation by monotone bisection
# ======================================================================================

class BoundaryReport(NamedTuple):
    boundary: float
    bracket: Tuple[float, float]
    smaller_scales_forced: bool


def locate_sufficiency_boundary(g: Callable[[float], float],
                                bar: float,
                                lo: float,
                                hi: float,
                                tol: float = 1e-9) -> BoundaryReport:
    """
    Given a continuous strictly increasing identity increment g and a bar, with
    g(lo) <= bar < g(hi), locate the UNIQUE u* in (lo, hi] with g(u*) = bar.

    Existence is the intermediate value theorem; uniqueness is injectivity of a strictly
    increasing map.  Because the verdict "g(u) <= bar" is then literally "u <= u*", the
    verdict is downward closed and no TRUE / FALSE / TRUE pattern can occur.

    Complexity: O(log((hi - lo)/tol)) evaluations of g.
    """
    if not (g(lo) <= bar < g(hi)):
        raise ValueError("bracket hypothesis g(lo) <= bar < g(hi) fails; no crossing is implied")
    a, b = lo, hi
    while b - a > tol:
        mid = 0.5 * (a + b)
        if g(mid) <= bar:
            a = mid
        else:
            b = mid
    return BoundaryReport(0.5 * (a + b), (lo, hi), True)


def log_linear_increment(u1: float, g1: float, u2: float, g2: float) -> Callable[[float], float]:
    """The unique strictly increasing log-linear increment g(u) = A e^{k u} through two points."""
    import math
    k = (math.log(g2) - math.log(g1)) / (u2 - u1)
    A = g1 * math.exp(-k * u1)
    return lambda u: A * math.exp(k * u)


# ======================================================================================

if __name__ == "__main__":
    B = (2, 3, 5)
    for rec in exact_cell_census(B):
        print(f"cell {sorted(rec.cell)!s:>12}  kappa={rec.kappa}  count={rec.count:>3}  "
              f"density={rec.density}")
    print("mean kappa over a period:", mean_composition_order(B))

    est = window_cell_count(B, frozenset({2}), 1000)
    print("window:", est)

    q = {p: 1.0 / p for p in B}
    print("homogeneous:", slope_and_increment(B, q, {2: .35, 3: .35, 5: .35}))
    print("heterogeneous:", slope_and_increment(B, q, {2: .50, 3: .35, 5: .20}))

    g = log_linear_increment(96, 0.0084, 128, 0.0346)
    print("boundary:", locate_sufficiency_boundary(g, 0.02, 96.0, 128.0))
