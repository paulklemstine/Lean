#!/usr/bin/env python3
"""
Algorithms for Cognitive Dynamics: Fixed Points and Periodic Orbits

Type-hinted implementations of the core algorithms for computing
periodic orbits, recurrence spectra, Lyapunov exponents, and
bifurcation diagrams for discrete dynamical systems.
"""

from typing import List, Tuple, Set, Callable, Optional
import numpy as np
from dataclasses import dataclass


@dataclass
class PeriodicOrbit:
    """A periodic orbit of a dynamical system."""
    points: List[float]
    period: int
    stability: float  # |λ| = |(f^n)'(x)|; < 1 = stable, > 1 = unstable

    @property
    def is_stable(self) -> bool:
        return self.stability < 1.0


@dataclass
class RecurrenceSpectrum:
    """The recurrence spectrum of a dynamical system.

    The set of positive integers n for which f has a period-n point.
    """
    periods: Set[int]
    orbits: dict  # period -> list of PeriodicOrbit

    def contains(self, n: int) -> bool:
        return n in self.periods

    def is_closed_under_multiples(self, max_check: int = 100) -> bool:
        """Verify closure under multiples (Theorem 5)."""
        for n in self.periods:
            for k in range(2, max_check // n + 1):
                if k * n <= max_check and k * n not in self.periods:
                    return False
        return True


@dataclass
class CognitiveAttractor:
    """Numerical approximation of the ω-limit set."""
    points: np.ndarray
    dimension: float  # Estimated fractal dimension


def logistic_map(x: float, r: float) -> float:
    """The logistic map f_r(x) = r·x·(1-x)."""
    return r * x * (1.0 - x)


def logistic_derivative(x: float, r: float) -> float:
    """Derivative f'_r(x) = r·(1 - 2x)."""
    return r * (1.0 - 2.0 * x)


def iterate(f: Callable[[float, float], float], x: float, n: int,
            r: float) -> float:
    """Compute f^n(x) — the n-fold iterate of f at x."""
    for _ in range(n):
        x = f(x, r)
    return x


def orbit(f: Callable[[float, float], float], x0: float, n: int,
          r: float) -> List[float]:
    """Compute the orbit [x0, f(x0), f²(x0), ..., f^n(x0)]."""
    trajectory: List[float] = [x0]
    x = x0
    for _ in range(n):
        x = f(x, r)
        trajectory.append(x)
    return trajectory


def chain_rule_derivative(f: Callable[[float, float], float],
                          df: Callable[[float, float], float],
                          x: float, n: int, r: float) -> float:
    """Compute (f^n)'(x) via the chain rule.

    (f^n)'(x) = ∏_{k=0}^{n-1} f'(f^k(x))
    """
    deriv = 1.0
    val = x
    for _ in range(n):
        deriv *= df(val, r)
        val = f(val, r)
    return deriv


def newton_periodic_point(f: Callable[[float, float], float],
                           df: Callable[[float, float], float],
                           x0: float, period: int, r: float,
                           tol: float = 1e-12,
                           max_iter: int = 200) -> Optional[float]:
    """Find a period-n point of f near x0 using Newton's method.

    Solves g(x) = f^n(x) - x = 0.
    g'(x) = (f^n)'(x) - 1.

    Returns None if Newton's method fails to converge.
    """
    x = x0
    for _ in range(max_iter):
        fn_x = iterate(f, x, period, r)
        g = fn_x - x
        dg = chain_rule_derivative(f, df, x, period, r) - 1.0

        if abs(dg) < 1e-15:
            return None

        x_new = x - g / dg

        if abs(x_new - x) < tol:
            # Verify
            if abs(iterate(f, x_new, period, r) - x_new) < 1e-8:
                return x_new
            return None
        x = x_new

    return None


def find_all_periodic_points(f: Callable[[float, float], float],
                              df: Callable[[float, float], float],
                              period: int, r: float,
                              n_seeds: int = 2000,
                              tol: float = 1e-10) -> List[PeriodicOrbit]:
    """Find all period-n orbits of f at parameter r.

    Uses Newton's method with multiple seeds, then clusters results
    and identifies distinct orbits.
    """
    raw_points: Set[float] = set()
    seeds = np.linspace(0.01, 0.99, n_seeds)

    for x0 in seeds:
        pt = newton_periodic_point(f, df, float(x0), period, r, tol)
        if pt is not None and 0 < pt < 1:
            raw_points.add(round(pt, 10))

    # Cluster into orbits
    points_list = sorted(raw_points)
    orbits: List[PeriodicOrbit] = []
    used: Set[int] = set()

    for i, p in enumerate(points_list):
        if i in used:
            continue

        # Build the orbit of p
        orb = [p]
        x = p
        for _ in range(period - 1):
            x = f(x, r)
            orb.append(round(x, 10))

        # Check minimal period
        min_period = period
        for d in range(1, period):
            if period % d == 0:
                if abs(iterate(f, p, d, r) - p) < 1e-8:
                    min_period = d
                    break

        if min_period == period:
            stability = abs(chain_rule_derivative(f, df, p, period, r))
            orbits.append(PeriodicOrbit(
                points=sorted(orb),
                period=period,
                stability=stability
            ))

            # Mark all orbit points as used
            for q in orb:
                for j, p2 in enumerate(points_list):
                    if abs(p2 - q) < 1e-8:
                        used.add(j)

    return orbits


def compute_recurrence_spectrum(f: Callable[[float, float], float],
                                 df: Callable[[float, float], float],
                                 r: float,
                                 max_period: int = 20) -> RecurrenceSpectrum:
    """Compute the recurrence spectrum of f at parameter r.

    Returns the set of periods n for which f has a genuine period-n orbit
    (minimal period exactly n).
    """
    periods: Set[int] = set()
    all_orbits: dict = {}

    for n in range(1, max_period + 1):
        orbits = find_all_periodic_points(f, df, n, r)
        if orbits:
            periods.add(n)
            all_orbits[n] = orbits

    return RecurrenceSpectrum(periods=periods, orbits=all_orbits)


def lyapunov_exponent(f: Callable[[float, float], float],
                      df: Callable[[float, float], float],
                      r: float, x0: float = 0.4,
                      n_transient: int = 1000,
                      n_compute: int = 50000) -> float:
    """Compute the Lyapunov exponent of f at parameter r.

    λ = lim_{n→∞} (1/n) Σ_{k=0}^{n-1} log|f'(f^k(x))|
    """
    x = x0
    for _ in range(n_transient):
        x = f(x, r)

    lyap_sum = 0.0
    count = 0
    for _ in range(n_compute):
        d = abs(df(x, r))
        if d > 0:
            lyap_sum += np.log(d)
            count += 1
        x = f(x, r)

    return lyap_sum / count if count > 0 else 0.0


def bifurcation_diagram(f: Callable[[float, float], float],
                         r_min: float = 2.5, r_max: float = 4.0,
                         n_r: int = 2000, n_transient: int = 500,
                         n_plot: int = 300,
                         x0: float = 0.4) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the bifurcation diagram of f.

    Returns (r_values, x_values) arrays for plotting.
    """
    r_values = []
    x_values = []

    for r in np.linspace(r_min, r_max, n_r):
        x = x0
        for _ in range(n_transient):
            x = f(x, r)
        for _ in range(n_plot):
            x = f(x, r)
            r_values.append(r)
            x_values.append(x)

    return np.array(r_values), np.array(x_values)


def compute_cognitive_attractor(f: Callable[[float, float], float],
                                 r: float, x0: float = 0.4,
                                 n_transient: int = 5000,
                                 n_collect: int = 10000) -> CognitiveAttractor:
    """Compute the cognitive attractor (ω-limit set) numerically.

    Estimates the fractal (box-counting) dimension of the attractor.
    """
    x = x0
    for _ in range(n_transient):
        x = f(x, r)

    points = np.zeros(n_collect)
    for i in range(n_collect):
        x = f(x, r)
        points[i] = x

    # Estimate box-counting dimension
    unique_pts = np.unique(np.round(points, 6))
    if len(unique_pts) <= 10:
        dim = 0.0  # Discrete attractor (periodic orbit)
    else:
        # Simple box-counting estimate
        epsilons = [0.01, 0.005, 0.002, 0.001]
        counts = []
        for eps in epsilons:
            boxes = set()
            for p in points:
                boxes.add(int(p / eps))
            counts.append(len(boxes))

        # Linear regression of log(N) vs log(1/ε)
        if len(counts) >= 2:
            log_inv_eps = [np.log(1.0/e) for e in epsilons]
            log_n = [np.log(c) for c in counts]
            coeffs = np.polyfit(log_inv_eps, log_n, 1)
            dim = coeffs[0]
        else:
            dim = 1.0

    return CognitiveAttractor(points=points, dimension=dim)


def ivt_bisection_fixed_point(f: Callable[[float, float], float],
                               r: float, a: float = 0.0, b: float = 1.0,
                               tol: float = 1e-15) -> float:
    """Find a fixed point of f on [a,b] using bisection (IVT proof method).

    Assumes f maps [a,b] to [a,b], so g(x) = f(x) - x satisfies
    g(a) ≥ 0 and g(b) ≤ 0. Uses bisection to find the zero.

    This is the algorithmic analogue of Theorem 1 (Brouwer via IVT).
    """
    def g(x: float) -> float:
        return f(x, r) - x

    ga = g(a)
    gb = g(b)

    if ga * gb > 0:
        raise ValueError(f"g(a)={ga:.4f} and g(b)={gb:.4f} have the same sign")

    if ga < 0:
        a, b = b, a

    while b - a > tol:
        mid = (a + b) / 2.0
        if g(mid) > 0:
            a = mid
        else:
            b = mid

    return (a + b) / 2.0


if __name__ == "__main__":
    print("Computing recurrence spectrum at r=3.83...")
    spec = compute_recurrence_spectrum(logistic_map, logistic_derivative,
                                        3.83, max_period=12)
    print(f"  Periods found: {sorted(spec.periods)}")
    print(f"  Closed under multiples: {spec.is_closed_under_multiples(12)}")

    print("\nComputing Lyapunov exponent...")
    for r in [2.5, 3.2, 3.57, 3.83, 4.0]:
        lam = lyapunov_exponent(logistic_map, logistic_derivative, r)
        print(f"  r={r:.2f}: λ = {lam:.4f}")

    print("\nComputing cognitive attractor at r=3.83...")
    attractor = compute_cognitive_attractor(logistic_map, 3.83)
    print(f"  Attractor dimension ≈ {attractor.dimension:.3f}")
    print(f"  Number of distinct points (rounded): "
          f"{len(np.unique(np.round(attractor.points, 4)))}")
