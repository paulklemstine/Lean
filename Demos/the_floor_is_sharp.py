"""
Numerical demonstrations for
"Sharp Constants for Quantised Fair Scheduling: The Slack Spectrum of a
Photon-Transport Exchange".

The script is self-contained (standard library only) and verifies, numerically,
every headline claim of the paper:

  1.  no starvation and the factor-two ceiling:  ideal <= service < 2 * ideal;
  2.  the slack spectrum is exactly [1, 2):  every target t in [1,2) is realised
      by the witness exchange with demand 2/t, and nothing outside [1,2) occurs;
  3.  the optimal constants for a general grid ratio rho are 1 and rho;
  4.  aggregation:  sum(ideal) <= sum(service) < 2 * sum(ideal);
  5.  jitter:  the floor and ceiling hold at every phase, the geometric-mean
      slack is sqrt(rho) and the arithmetic-mean slack is (rho-1)/log(rho),
      with the strict hierarchy sqrt(rho) < (rho-1)/log rho < rho;
  6.  the grid cost rho/log(rho) is uniquely minimised at rho = e, C(4) = C(2),
      and C(2) < 1.07 e;
  7.  the Diophantine dichotomy:  the slack orbit of a geometric demand ladder
      alpha^n is dense in [1,2) iff log2(alpha) is irrational.

Run:  python3 demo.py
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from fractions import Fraction
from typing import Callable, Dict, List, Sequence, Tuple

# --------------------------------------------------------------------------- #
# 0.  Numerically careful grid quantiser
# --------------------------------------------------------------------------- #

EPS: float = 1e-12


def grid_ceil(rho: float, x: float) -> float:
    """Smallest integer power of `rho` that is >= `x`.

    The naive `rho ** ceil(log(x, rho))` misfires when `x` is exactly a power of
    `rho`: floating point may return `log` a hair above the integer, and the
    quantiser then jumps a whole level, reporting a slack of `rho` instead of 1.
    We snap the logarithm to an integer when it is within EPS of one.
    """
    if rho <= 1.0:
        raise ValueError("grid ratio must exceed 1")
    if x <= 0.0:
        raise ValueError("request size must be positive")
    t: float = math.log(x) / math.log(rho)
    nearest: int = round(t)
    k: int = nearest if abs(t - nearest) < EPS else math.ceil(t)
    return float(rho) ** k


def slack(rho: float, x: float) -> float:
    """Multiplicative overshoot gridCeil_rho(x) / x, always in [1, rho)."""
    return grid_ceil(rho, x) / x


def log_slack(rho: float, x: float) -> float:
    """Overshoot measured in backoff levels; equals frac(-log_rho x)."""
    return math.log(slack(rho, x)) / math.log(rho)


def frac(t: float) -> float:
    """Fractional part t - floor(t)."""
    return t - math.floor(t)


# --------------------------------------------------------------------------- #
# 1.  The photon-transport exchange
# --------------------------------------------------------------------------- #

@dataclass(frozen=True)
class TransportClass:
    """One traffic class: occupancy p in (0,1], demand d > 0, credit r."""
    name: str
    p: float
    d: float
    r: float


@dataclass(frozen=True)
class Exchange:
    """A photon-transport exchange: constants beta, gamma, M and its classes."""
    beta: float
    gamma: float
    M: float
    classes: Tuple[TransportClass, ...]

    def gap(self, c: TransportClass) -> float:
        """Boltzmann cost of one successful transfer, corrected by credit."""
        g: float = self.beta * math.log(1.0 / c.p) + self.M + self.gamma - c.r
        if g <= 0.0:
            raise ValueError(f"class {c.name}: transport gap must be positive")
        return g

    def ideal(self, c: TransportClass) -> float:
        """The perfectly divisible fair share gamma * d / gap."""
        return self.gamma * c.d / self.gap(c)

    def service(self, c: TransportClass, rho: float = 2.0) -> float:
        """The window actually delivered by the grid-rho backoff arbiter."""
        return grid_ceil(rho, self.ideal(c))


def witness(x: float) -> Exchange:
    """Single-class exchange whose ideal share is exactly `x`.

    beta = gamma = M = 1, p = 1 (so log(1/p) = 0), r = 1, hence
    gap = 0 + 1 + 1 - 1 = 1 and ideal = gamma * x / 1 = x.
    """
    return Exchange(1.0, 1.0, 1.0, (TransportClass("w", 1.0, x, 1.0),))


# --------------------------------------------------------------------------- #
# 2.  Demonstrations
# --------------------------------------------------------------------------- #

def rule(title: str) -> None:
    print("\n" + "=" * 74)
    print(title)
    print("=" * 74)


def demo_floor_and_ceiling() -> None:
    rule("1. No starvation and the factor-two ceiling")
    ex = Exchange(
        beta=1.0,
        gamma=1.0,
        M=2.0,
        classes=(
            TransportClass("bulk",     p=0.90, d=3.0,  r=0.5),
            TransportClass("control",  p=0.60, d=1.0,  r=1.2),
            TransportClass("rare",     p=0.01, d=5.0,  r=0.0),
            TransportClass("priority", p=0.99, d=0.3,  r=2.4),
        ),
    )
    print(f"{'class':>10} {'p':>7} {'gap':>9} {'ideal':>11} {'service':>10} {'slack':>8}")
    for c in ex.classes:
        i, s = ex.ideal(c), ex.service(c)
        print(f"{c.name:>10} {c.p:7.2f} {ex.gap(c):9.4f} {i:11.6f} {s:10.5f} {s / i:8.5f}")
        assert i <= s + 1e-15,  "floor violated"
        assert s < 2.0 * i,     "ceiling violated"

    tot_i = sum(ex.ideal(c) for c in ex.classes)
    tot_s = sum(ex.service(c) for c in ex.classes)
    print(f"\naggregate:  sum(ideal) = {tot_i:.6f} <= sum(service) = {tot_s:.6f} "
          f"< 2*sum(ideal) = {2 * tot_i:.6f}")
    assert tot_i <= tot_s < 2.0 * tot_i
    print("The 'rare' class (p = 0.01) has a large Boltzmann cost and is squeezed")
    print("towards zero service: the floor is a saturating constraint, not a tautology.")


def demo_spectrum() -> None:
    rule("2. The slack spectrum is exactly [1, 2)")
    print("Target slack t is realised by the witness exchange with demand 2/t.\n")
    print(f"{'target t':>10} {'demand 2/t':>12} {'service':>9} {'realised':>10} {'error':>11}")
    targets: List[float] = [1.0, 1.05, 1.25, 1.4142135623730951, 1.5, 1.75, 1.9, 1.999]
    for t in targets:
        x = 2.0 / t
        ex = witness(x)
        c = ex.classes[0]
        realised = ex.service(c) / ex.ideal(c)
        print(f"{t:10.6f} {x:12.6f} {ex.service(c):9.4f} {realised:10.6f} "
              f"{abs(realised - t):11.2e}")
        assert abs(realised - t) < 1e-12

    print("\nA random sweep of ideal shares over 6 decades never leaves [1, 2):")
    lo, hi = 2.0, 1.0
    n = 20000
    for k in range(n):
        x = 10.0 ** (-3.0 + 6.0 * k / (n - 1))
        s = slack(2.0, x)
        lo, hi = min(lo, s), max(hi, s)
    print(f"  observed slack range over {n} samples: [{lo:.6f}, {hi:.6f}]")
    assert 1.0 <= lo and hi < 2.0


def demo_general_grid() -> None:
    rule("3. For grid ratio rho the optimal constants are 1 and rho")
    for rho in (1.5, 2.0, math.e, 3.0, 4.0, 10.0):
        lo, hi = math.inf, -math.inf
        n = 4000
        for k in range(n):
            x = rho ** (-3.0 + 6.0 * k / (n - 1)) * 1.0000001
            s = slack(rho, x)
            lo, hi = min(lo, s), max(hi, s)
        # the extreme witness: demand just above 1 forces the full jump to rho
        worst = slack(rho, 1.0 + 1e-9)
        print(f"  rho = {rho:6.4f}:  observed slack in [{lo:.6f}, {hi:.6f}], "
              f"near-worst witness slack = {worst:.6f} (sup = rho = {rho:.6f})")
        assert lo >= 1.0 - 1e-12 and hi < rho


def demo_jitter() -> None:
    rule("4. Jitter: worst case unchanged, typical case sqrt(rho), mean (rho-1)/log rho")

    def jitter_ceil(rho: float, theta: float, x: float) -> float:
        t = math.log(x) / math.log(rho) - theta
        nearest = round(t)
        k = nearest if abs(t - nearest) < EPS else math.ceil(t)
        return rho ** (k + theta)

    n_phase = 200000
    for rho in (2.0, math.e, 3.0, 4.0):
        x = 1.3719  # an arbitrary, generic request size
        worst = 0.0
        geo_log_sum = 0.0
        arith_sum = 0.0
        for j in range(n_phase):
            theta = (j + 0.5) / n_phase
            s = jitter_ceil(rho, theta, x) / x
            assert 1.0 <= s < rho + 1e-12, "phase-independent bound violated"
            worst = max(worst, s)
            geo_log_sum += math.log(s)
            arith_sum += s
        geo = math.exp(geo_log_sum / n_phase)
        ari = arith_sum / n_phase
        print(f"  rho = {rho:6.4f}:  sup over phases = {worst:.6f} (theory {rho:.6f});"
              f"  geometric mean = {geo:.6f} (theory {math.sqrt(rho):.6f});")
        print(f"{'':16}arithmetic mean = {ari:.6f} "
              f"(theory {(rho - 1.0) / math.log(rho):.6f})")
        assert abs(geo - math.sqrt(rho)) < 1e-4
        assert abs(ari - (rho - 1.0) / math.log(rho)) < 1e-4
        assert math.sqrt(rho) < (rho - 1.0) / math.log(rho) < rho

    print("\nRandomisation never lowers the supremum: the bound 1 <= slack < rho")
    print("holds at every single phase, so no phase law can beat it.")


def demo_grid_cost() -> None:
    rule("5. The grid cost rho/log(rho) is uniquely minimised at rho = e")

    def grid_cost(rho: float) -> float:
        return rho / math.log(rho)

    print(f"{'rho':>8} {'C(rho)':>12} {'excess over e':>16}")
    for rho in (1.5, 2.0, 2.5, math.e, 3.0, 3.5, 4.0, 8.0, 16.0):
        c = grid_cost(rho)
        print(f"{rho:8.4f} {c:12.6f} {100.0 * (c / math.e - 1.0):15.3f}%")
        assert c >= math.e - 1e-12

    print(f"\n  C(2) = {grid_cost(2.0):.9f}")
    print(f"  C(4) = {grid_cost(4.0):.9f}   (exactly equal to C(2))")
    print(f"  C(3) = {grid_cost(3.0):.9f}   (closest integer ratio to the optimum)")
    print(f"  e    = {math.e:.9f}")
    assert abs(grid_cost(4.0) - grid_cost(2.0)) < 1e-12
    assert grid_cost(2.0) < 1.07 * math.e

    # golden-section search recovers the optimum
    lo, hi = 1.2, 10.0
    inv_phi = (math.sqrt(5.0) - 1.0) / 2.0
    for _ in range(200):
        a = hi - inv_phi * (hi - lo)
        b = lo + inv_phi * (hi - lo)
        if grid_cost(a) < grid_cost(b):
            hi = b
        else:
            lo = a
    print(f"  golden-section minimiser: rho* = {(lo + hi) / 2:.12f}  (e = {math.e:.12f})")
    assert abs((lo + hi) / 2 - math.e) < 1e-6


def star_discrepancy(sample: Sequence[float]) -> float:
    """Exact star discrepancy of a finite sample of [0,1)."""
    xs = sorted(sample)
    n = len(xs)
    d = 0.0
    for i, x in enumerate(xs):
        d = max(d, abs((i + 1) / n - x), abs(i / n - x))
    return d


def demo_dichotomy() -> None:
    rule("6. Diophantine dichotomy: dense slack orbit iff log2(alpha) is irrational")
    print("Demand grows by a factor alpha per round; the ideal share climbs alpha^n")
    print("and the log-slack is frac(-n log2 alpha), an orbit of a circle rotation.\n")

    # Rational exponents are handled with exact fractions, so that the finite
    # orbit is reported exactly rather than being smeared by floating-point drift.
    rational_cases: List[Tuple[str, Fraction]] = [
        ("alpha = 4      (log2 alpha = 2)",     Fraction(2, 1)),
        ("alpha = sqrt2  (log2 alpha = 1/2)",   Fraction(1, 2)),
        ("alpha = 2**(3/7)",                    Fraction(3, 7)),
    ]
    irrational_cases: List[Tuple[str, float]] = [
        ("alpha = 3      (log2 3 irrational)",  3.0),
        ("alpha = 10     (log2 10 irrational)", 10.0),
        ("alpha = pi",                          math.pi),
    ]
    N = 4000
    header = (f"{'case':>36} {'#distinct':>10} {'discrepancy':>13} "
              f"{'min slack':>10} {'max slack':>10}")
    print(header)
    for label, theta in rational_cases:
        orbit_q = [(-n * theta) % 1 for n in range(N)]
        distinct = len(set(orbit_q))
        orbit = [float(v) for v in orbit_q]
        slacks = [2.0 ** v for v in orbit]
        print(f"{label:>36} {distinct:10d} {star_discrepancy(orbit):13.6f} "
              f"{min(slacks):10.6f} {max(slacks):10.6f}")
        assert distinct == theta.denominator, "orbit period must be the denominator"
    for label, alpha in irrational_cases:
        orbit = [frac(-n * math.log2(alpha)) for n in range(N)]
        distinct = len({round(v, 9) for v in orbit})
        disc = star_discrepancy(orbit)
        slacks = [2.0 ** v for v in orbit]
        print(f"{label:>36} {distinct:10d} {disc:13.6f} "
              f"{min(slacks):10.6f} {max(slacks):10.6f}")
        assert disc < 0.01, "irrational case must equidistribute"

    print("\nQuantitative saturation for ternary growth (alpha = 3), searching n >= 1:")
    theta3 = math.log2(3.0)
    horizon = 200000
    hi_n = max(range(1, horizon), key=lambda n: frac(-n * theta3))
    lo_n = min(range(1, horizon), key=lambda n: frac(-n * theta3))
    hi_s = 2.0 ** frac(-hi_n * theta3)
    lo_s = 2.0 ** frac(-lo_n * theta3)
    print(f"  best overshoot : n = {hi_n:6d}, slack = {hi_s:.9f}  (ceiling 2)")
    print(f"  best efficiency: m = {lo_n:6d}, slack = {lo_s:.9f}  (floor 1)")
    for eps in (0.5, 0.2, 0.05, 0.01):
        print(f"  eps = {eps:5.2f}:  {hi_s:.9f} > 2^(1-eps) = {2.0 ** (1 - eps):.6f}   and   "
              f"{lo_s:.9f} < 2^eps = {2.0 ** eps:.6f}")
        assert hi_s > 2.0 ** (1 - eps) and lo_s < 2.0 ** eps

    print("\nBy contrast, alpha = 4 has slack identically 1: perfect efficiency forever.")
    assert all(abs(slack(2.0, 4.0 ** n) - 1.0) < 1e-12 for n in range(-20, 21))


def main() -> None:
    print(__doc__.strip().splitlines()[0])
    demos: Dict[str, Callable[[], None]] = {
        "floor/ceiling": demo_floor_and_ceiling,
        "spectrum": demo_spectrum,
        "general grid": demo_general_grid,
        "jitter": demo_jitter,
        "grid cost": demo_grid_cost,
        "dichotomy": demo_dichotomy,
    }
    for fn in demos.values():
        fn()
    print("\n" + "=" * 74)
    print("All numerical checks passed.")
    print("=" * 74)


if __name__ == "__main__":
    main()
