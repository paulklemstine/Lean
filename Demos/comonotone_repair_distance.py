"""
Comonotone Repair Distance vs. Discordance Mass
===============================================

Numerical companion to "The Comonotone Repair Distance and the Discordance Mass".

Everything here is self-contained: no third-party dependencies, only the standard
library.  We compute, for finite populations (x, y) of paired observations,

    *  the discordance mass      Delta(x, y) = sum_{i,j} max(-(x_i-x_j)(y_i-y_j), 0)
    *  the concordance mass      C(x, y)     = sum_{i,j} max( (x_i-x_j)(y_i-y_j), 0)
    *  the weighted covariance   wcov(p;x,y) = (1/2) sum_{i,j} p_i p_j (x_i-x_j)(y_i-y_j)
    *  the repair distance       delta(x, y) = min { ||d||_1 : (x, y+d) comonotone }

and we verify numerically:

    1.  the uniform pair identity        2 n^2 wcov = C - Delta
    2.  the sharp two-sided comparison   2 g delta <= Delta <= 2 n R delta
    3.  attainment of the constant 2     (x = (0,1), y = (3,0))
    4.  failure of  delta^2 <= Delta     (a degree obstruction)
    5.  failure of  Delta <= 2 delta R   (a dimension obstruction)
    6.  irreducibility: Delta is not a function of delta
    7.  the regime-uniform triage rule and its measurement-robust version
    8.  the dial cap  2 n^2 wcov <= C - g delta

Run with:  python3 demo.py
"""

from __future__ import annotations

import random
from itertools import product
from typing import Dict, List, Sequence, Tuple

Vector = Sequence[float]

TOL: float = 1e-9


# ---------------------------------------------------------------------------
# Pairwise functionals
# ---------------------------------------------------------------------------

def discordance_mass(x: Vector, y: Vector) -> float:
    """Sum over ORDERED pairs of the size of each violation of comonotonicity."""
    return sum(
        max(-(x[i] - x[j]) * (y[i] - y[j]), 0.0)
        for i, j in product(range(len(x)), repeat=2)
    )


def concordance_mass(x: Vector, y: Vector) -> float:
    """Sum over ORDERED pairs of the size of each agreement."""
    return sum(
        max((x[i] - x[j]) * (y[i] - y[j]), 0.0)
        for i, j in product(range(len(x)), repeat=2)
    )


def wcov(p: Vector, x: Vector, y: Vector) -> float:
    """Weighted covariance in its pair (Hoeffding) form."""
    return 0.5 * sum(
        p[i] * p[j] * (x[i] - x[j]) * (y[i] - y[j])
        for i, j in product(range(len(x)), repeat=2)
    )


def is_comonotone(x: Vector, y: Vector) -> bool:
    """True when no ordered pair is discordant."""
    return all(
        (x[i] - x[j]) * (y[i] - y[j]) >= -TOL
        for i, j in product(range(len(x)), repeat=2)
    )


def footprint_range(x: Vector) -> float:
    """R = max_{i,j} |x_i - x_j|."""
    return max(x) - min(x) if x else 0.0


def footprint_separation(x: Vector) -> float:
    """g = min { x_j - x_i : x_i < x_j }, or +inf when x is constant."""
    values = sorted(set(x))
    if len(values) < 2:
        return float("inf")
    return min(b - a for a, b in zip(values, values[1:]))


# ---------------------------------------------------------------------------
# The repair distance: bounds and exact value
# ---------------------------------------------------------------------------

def isotonic_upper_envelope(x: Vector, y: Vector) -> List[float]:
    """Largest rate observed at or strictly below each key's footprint.

    This is the canonical isotonic majorant of y along x; it is comonotone with
    x, so the nonnegative nudge (envelope - y) is always an admissible repair.
    """
    n = len(x)
    return [
        max(y[j] for j in range(n) if j == i or x[j] < x[i])
        for i in range(n)
    ]


def envelope_repair_cost(x: Vector, y: Vector) -> float:
    """Constructive UPPER bound on delta given by the isotonic upper envelope."""
    env = isotonic_upper_envelope(x, y)
    return sum(e - v for e, v in zip(env, y))


def pair_certificate_bound(x: Vector, y: Vector) -> float:
    """LOWER bound on delta: the largest single inversion of the rates.

    If x_i < x_j then any repair must close the gap y_i - y_j, so this maximum
    is a valid lower bound for the repair distance.
    """
    n = len(x)
    best = 0.0
    for i, j in product(range(n), repeat=2):
        if x[i] < x[j]:
            best = max(best, y[i] - y[j])
    return best


def repair_distance(x: Vector, y: Vector) -> float:
    """Exact comonotone repair distance delta(x, y).

    delta(x, y) = min { ||y - z||_1 : (x, z) comonotone }.  Keys sharing a
    footprint value impose no constraint on each other, so the feasible z are
    exactly those admitting cuts t_0 <= t_1 <= ... with every rate at level l
    lying in [t_{l-1}, t_l].  The objective is piecewise linear, so an optimal
    set of cuts may be taken from the multiset of observed rates; a dynamic
    program over (level, cut) then gives the exact optimum.
    """
    n = len(x)
    if n == 0:
        return 0.0

    levels: Dict[float, List[float]] = {}
    for xi, yi in zip(x, y):
        levels.setdefault(xi, []).append(yi)
    blocks: List[List[float]] = [levels[v] for v in sorted(levels)]

    cuts: List[float] = sorted(set(y))
    k = len(cuts)

    def block_cost(block: Sequence[float], low: float, high: float) -> float:
        """Cost of clamping every rate of a level into the interval [low, high]."""
        return sum(max(low - v, 0.0) + max(v - high, 0.0) for v in block)

    low0 = cuts[0]  # optimal rates never leave [min y, max y]
    table: List[float] = [block_cost(blocks[0], low0, cuts[c]) for c in range(k)]

    for block in blocks[1:]:
        new_table = [float("inf")] * k
        for c in range(k):                      # ceiling of this level
            best = float("inf")
            for c_prev in range(c + 1):         # floor inherited from below
                candidate = table[c_prev] + block_cost(block, cuts[c_prev], cuts[c])
                best = min(best, candidate)
            new_table[c] = best
        table = new_table

    return min(table)


def optimal_repair(x: Vector, y: Vector) -> List[float]:
    """An optimal perturbation d with ||d||_1 = delta(x, y), found by search
    over cut vectors drawn from the observed rates (attainment made explicit)."""
    n = len(x)
    levels: Dict[float, List[int]] = {}
    for i, xi in enumerate(x):
        levels.setdefault(xi, []).append(i)
    blocks: List[List[int]] = [levels[v] for v in sorted(levels)]
    cuts: List[float] = sorted(set(y))

    best_cost = float("inf")
    best_z: List[float] = list(y)
    for choice in product(range(len(cuts)), repeat=len(blocks)):
        if any(a > b for a, b in zip(choice, choice[1:])):
            continue
        z = list(y)
        low = cuts[0]
        cost = 0.0
        for block, c in zip(blocks, choice):
            high = cuts[c]
            for i in block:
                zi = min(max(y[i], low), high)
                z[i] = zi
                cost += abs(zi - y[i])
            low = high
        if cost < best_cost - TOL:
            best_cost, best_z = cost, z
    return [zi - yi for zi, yi in zip(best_z, y)]


# ---------------------------------------------------------------------------
# Triage
# ---------------------------------------------------------------------------

def triage_certified(
    x: Vector, y: Vector, eps: float, big_m: float, eta: float = 0.0
) -> bool:
    """Regime-uniform triage from the single population parameter delta.

    Returns True when  (M/eps)^2 * 2 n R (delta + eta) < C(x, y), which
    certifies wcov(p; x, y) > 0 for EVERY draw regime with eps <= p_i <= M,
    tolerating total measurement error eta in the rates.
    """
    n = len(x)
    kappa = big_m / eps
    budget = kappa ** 2 * 2 * n * footprint_range(x) * (repair_distance(x, y) + eta)
    return budget < concordance_mass(x, y)


def worst_case_wcov(x: Vector, y: Vector, eps: float, big_m: float,
                    trials: int = 20000, seed: int = 0) -> float:
    """Smallest weighted covariance found by random search over admissible
    regimes eps <= p_i <= M, sum p_i = 1.  Used to sanity-check triage."""
    rng = random.Random(seed)
    n = len(x)
    worst = float("inf")
    for _ in range(trials):
        raw = [rng.random() for _ in range(n)]
        total = sum(raw)
        p = [r / total for r in raw]
        if all(eps - TOL <= pi <= big_m + TOL for pi in p):
            worst = min(worst, wcov(p, x, y))
    return worst


# ---------------------------------------------------------------------------
# Reporting helpers
# ---------------------------------------------------------------------------

def banner(title: str) -> None:
    print()
    print("=" * 74)
    print(title)
    print("=" * 74)


def report_population(name: str, x: Vector, y: Vector) -> Tuple[float, float]:
    delta = repair_distance(x, y)
    delta_mass = discordance_mass(x, y)
    conc = concordance_mass(x, y)
    n = len(x)
    R = footprint_range(x)
    g = footprint_separation(x)
    env = envelope_repair_cost(x, y)
    cert = pair_certificate_bound(x, y)
    print(f"\n{name}")
    print(f"  x = {list(x)}")
    print(f"  y = {list(y)}")
    print(f"  n = {n}   range R = {R:g}   separation g = {g:g}")
    print(f"  discordance mass  Delta = {delta_mass:g}")
    print(f"  concordance mass  C     = {conc:g}")
    print(f"  repair distance   delta = {delta:g}"
          f"   (certificate {cert:g} <= delta <= envelope {env:g})")
    if g < float("inf"):
        lhs, rhs = 2 * g * delta, 2 * n * R * delta
        ok = lhs <= delta_mass + TOL <= rhs + TOL
        print(f"  two-sided:  2g*delta = {lhs:g}  <=  Delta = {delta_mass:g}"
              f"  <=  2nR*delta = {rhs:g}   [{'OK' if ok else 'FAIL'}]")
    return delta, delta_mass


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_witnesses() -> None:
    banner("1.  The witness populations")

    report_population("Two keys, one large inversion", [0.0, 1.0], [3.0, 0.0])
    report_population("Three keys, outlier at the bottom", [0.0, 1.0, 2.0], [1.0, 0.0, 0.0])
    report_population("Three keys, inversion at the top", [0.0, 1.0, 2.0], [0.0, 1.0, 0.0])
    report_population("Comonotone population", [0.0, 1.0, 2.0], [0.0, 1.0, 5.0])

    d = optimal_repair([0.0, 1.0, 2.0], [1.0, 0.0, 0.0])
    print(f"\n  An optimal repair of the outlier population: d = {d} "
          f"(cost {sum(abs(v) for v in d):g})")


def demo_optimal_constant() -> None:
    banner("2.  The constant 2 in  2 g delta <= Delta  is exactly attained")
    x, y = [0.0, 1.0], [3.0, 0.0]
    g = footprint_separation(x)
    delta = repair_distance(x, y)
    mass = discordance_mass(x, y)
    print(f"\n  x = {x},  y = {y}")
    print(f"  g = {g:g},  delta = {delta:g},  Delta = {mass:g}")
    print(f"  2 g delta = {2 * g * delta:g}  ==  Delta = {mass:g}   -> equality")
    for C in (2.5, 3.0, 10.0):
        holds = C * g * delta <= mass + TOL
        print(f"  constant C = {C:>4}:  C g delta = {C * g * delta:>6g} <= Delta ?  {holds}")


def demo_degree_obstruction() -> None:
    banner("3.  delta^2 <= Delta is false, and fails by an unbounded margin")
    x = [0.0, 1.0]
    print("\n  Both delta and Delta are homogeneous of degree one in the rates,")
    print("  while delta^2 is homogeneous of degree two:")
    print(f"\n  {'t':>8} {'delta':>10} {'Delta':>10} {'delta^2/Delta':>16}")
    for t in (0.5, 1.0, 2.0, 5.0, 20.0, 100.0):
        y = [3.0 * t, 0.0]
        d = repair_distance(x, y)
        m = discordance_mass(x, y)
        print(f"  {t:>8g} {d:>10g} {m:>10g} {d * d / m:>16g}")
    print("\n  The ratio grows linearly in t, so no constant C satisfies")
    print("  C * Delta >= delta^2 for all populations.")


def demo_dimension_obstruction() -> None:
    banner("4.  Delta <= 2 delta R is false: the population-size factor is needed")
    print("\n  Outlier family: x = (0,1,...,n-1), y = (1,0,...,0).")
    print(f"\n  {'n':>4} {'delta':>8} {'R':>6} {'Delta':>10} "
          f"{'2 delta R':>12} {'Delta/(R delta)':>17} {'2 n R delta':>13}")
    for n in range(2, 10):
        x = [float(i) for i in range(n)]
        y = [1.0] + [0.0] * (n - 1)
        d = repair_distance(x, y)
        m = discordance_mass(x, y)
        R = footprint_range(x)
        print(f"  {n:>4} {d:>8g} {R:>6g} {m:>10g} {2 * d * R:>12g} "
              f"{m / (R * d):>17g} {2 * n * R * d:>13g}")
    print("\n  Delta = n(n-1) exactly, so Delta/(R delta) = n is unbounded:")
    print("  no bound of the form Delta <= C R delta can hold.")
    print("  The true value is exactly half of the general bound 2 n R delta.")


def demo_irreducibility() -> None:
    banner("5.  Irreducibility: Delta is not a function of delta")
    x = [0.0, 1.0, 2.0]
    for label, y in (("outlier at the bottom", [1.0, 0.0, 0.0]),
                     ("inversion at the top", [0.0, 1.0, 0.0])):
        print(f"\n  y = {y}  ({label})")
        print(f"    delta = {repair_distance(x, y):g}")
        print(f"    Delta = {discordance_mass(x, y):g}")
    print("\n  Same footprint, same repair distance, discordance masses 6 and 2.")
    print("  An l^1 repair sees how far rates must move, not how many pairs each")
    print("  misplaced rate offends -- so the pairwise data is irreducible.")


def demo_pair_identity_and_cap() -> None:
    banner("6.  The uniform pair identity and the dial cap")
    populations = [
        ([0.0, 1.0, 2.0, 3.0], [0.0, 2.0, 1.0, 4.0]),
        ([0.0, 1.0, 2.0], [1.0, 0.0, 0.0]),
        ([0.0, 2.0, 4.0, 6.0, 8.0], [1.0, 3.0, 2.0, 5.0, 4.0]),
    ]
    for x, y in populations:
        n = len(x)
        p = [1.0 / n] * n
        lhs = 2 * n ** 2 * wcov(p, x, y)
        rhs = concordance_mass(x, y) - discordance_mass(x, y)
        g = footprint_separation(x)
        delta = repair_distance(x, y)
        cap = concordance_mass(x, y) - g * delta
        print(f"\n  x = {x}\n  y = {y}")
        print(f"    2 n^2 wcov = {lhs:g}      C - Delta = {rhs:g}"
              f"   [{'OK' if abs(lhs - rhs) < 1e-7 else 'FAIL'}]")
        print(f"    dial cap:  2 n^2 wcov = {lhs:g} <= C - g delta = {cap:g}"
              f"   [{'OK' if lhs <= cap + TOL else 'FAIL'}]")


def demo_triage() -> None:
    banner("7.  Regime-uniform triage from a single population parameter")
    x = [0.0, 1.0, 2.0, 3.0, 4.0]
    y = [0.0, 1.0, 0.9, 3.0, 4.0]          # one small inversion, strong trend
    n = len(x)
    eps, big_m = 0.12, 0.30
    delta = repair_distance(x, y)
    C = concordance_mass(x, y)
    kappa = big_m / eps
    budget = kappa ** 2 * 2 * n * footprint_range(x) * delta
    print(f"\n  x = {x}\n  y = {y}")
    print(f"  delta = {delta:g},  C = {C:g},  R = {footprint_range(x):g},"
          f"  kappa = M/eps = {kappa:g}")
    print(f"  triage budget kappa^2 * 2 n R delta = {budget:g}  vs  C = {C:g}")
    print(f"  certified positive in every regime?  {triage_certified(x, y, eps, big_m)}")
    worst = worst_case_wcov(x, y, eps, big_m)
    print(f"  smallest wcov found over 20000 random admissible regimes: {worst:g}")

    print("\n  Robustness: delta is 1-Lipschitz in the rates, so a total")
    print("  measurement error eta is absorbed by replacing delta with delta + eta.")
    for eta in (0.0, 0.05, 0.2, 1.0):
        print(f"    eta = {eta:>4}:  certified?  {triage_certified(x, y, eps, big_m, eta)}")

    print("\n  By contrast the discordance mass admits no Lipschitz estimate:")
    print("  fix the rate move at 1 and stretch the footprint by lam.")
    for lam in (1.0, 2.0, 10.0, 100.0):
        xs = [0.0, lam]
        y1 = [3.0, 0.0]
        y2 = [2.0, 0.0]
        move = sum(abs(a - b) for a, b in zip(y1, y2))
        dmass = abs(discordance_mass(xs, y1) - discordance_mass(xs, y2))
        ddelta = abs(repair_distance(xs, y1) - repair_distance(xs, y2))
        print(f"    lam = {lam:>5g}, rate move {move:g}:  |change in Delta| = {dmass:>7g},"
              f"  |change in delta| = {ddelta:g}")


def demo_random_stress() -> None:
    banner("8.  Randomised stress test of the two-sided comparison")
    rng = random.Random(20260910)
    worst_lower = float("inf")
    worst_upper = float("inf")
    checked = 0
    for _ in range(4000):
        n = rng.randint(2, 7)
        x = [float(rng.randint(0, 5)) for _ in range(n)]
        y = [float(rng.randint(-4, 4)) for _ in range(n)]
        g = footprint_separation(x)
        if g == float("inf"):
            continue
        R = footprint_range(x)
        delta = repair_distance(x, y)
        mass = discordance_mass(x, y)
        assert 2 * g * delta <= mass + 1e-7, (x, y)
        assert mass <= 2 * n * R * delta + 1e-7, (x, y)
        # also check the envelope / certificate sandwich and Lipschitz stability
        assert pair_certificate_bound(x, y) <= delta + 1e-9
        assert delta <= envelope_repair_cost(x, y) + 1e-9
        y2 = [v + rng.uniform(-1, 1) for v in y]
        move = sum(abs(a - b) for a, b in zip(y, y2))
        assert abs(delta - repair_distance(x, y2)) <= move + 1e-7
        if delta > 0:
            worst_lower = min(worst_lower, mass / (2 * g * delta))
            worst_upper = min(worst_upper, 2 * n * R * delta / mass) if mass > 0 else worst_upper
        checked += 1
    print(f"\n  {checked} random populations checked; every instance satisfies")
    print("    2 g delta <= Delta <= 2 n R delta,")
    print("    max single inversion <= delta <= envelope cost,")
    print("    |delta(x,y) - delta(x,y')| <= ||y - y'||_1.")
    print(f"  tightest observed slack in the lower bound: Delta/(2 g delta) = {worst_lower:g}")
    print(f"  tightest observed slack in the upper bound: 2 n R delta/Delta = {worst_upper:g}")


def main() -> None:
    print(__doc__)
    demo_witnesses()
    demo_optimal_constant()
    demo_degree_obstruction()
    demo_dimension_obstruction()
    demo_irreducibility()
    demo_pair_identity_and_cap()
    demo_triage()
    demo_random_stress()
    banner("Done")


if __name__ == "__main__":
    main()
