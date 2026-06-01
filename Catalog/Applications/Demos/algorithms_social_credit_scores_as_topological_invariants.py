#!/usr/bin/env python3
"""
Algorithms for Social Credit Score Dynamics

Type-hinted implementations of the core algorithms from the paper.
"""

from typing import Callable
import math


def iterate_contraction(
    update: Callable[[float], float],
    x0: float,
    kappa: float,
    epsilon: float = 1e-10,
    max_iter: int = 10000,
) -> tuple[float, int]:
    """
    Iterate a κ-contraction mapping to find its unique fixed point.

    Args:
        update: The contraction mapping T : [0,1] → [0,1].
        x0: Initial score in [0,1].
        kappa: Contraction rate, must satisfy 0 ≤ κ < 1.
        epsilon: Convergence tolerance.
        max_iter: Maximum number of iterations.

    Returns:
        (fixed_point, iterations): The approximate fixed point and
        the number of iterations performed.

    Convergence guarantee: After n iterations,
        |T^n(x₀) - x*| ≤ κ^n / (1-κ) · |T(x₀) - x₀|
    """
    assert 0 <= kappa < 1, f"Contraction rate must be in [0,1), got {kappa}"
    assert 0 <= x0 <= 1, f"Initial score must be in [0,1], got {x0}"

    x = x0
    for i in range(1, max_iter + 1):
        x_new = update(x)
        if abs(x_new - x) < epsilon * (1 - kappa):
            return x_new, i
        x = x_new
    return x, max_iter


def find_fixed_points(
    f: Callable[[float], float],
    n_samples: int = 10000,
    tolerance: float = 1e-8,
) -> list[float]:
    """
    Find all fixed points of f : [0,1] → [0,1] by sampling.

    Uses sign changes of g(x) = f(x) - x to locate fixed points,
    then refines with bisection.

    Args:
        f: The map whose fixed points we seek.
        n_samples: Number of sample points in [0,1].
        tolerance: Precision of fixed point location.

    Returns:
        List of approximate fixed points, sorted.
    """
    fixed_points: list[float] = []
    dx = 1.0 / n_samples

    for i in range(n_samples):
        x_lo = i * dx
        x_hi = (i + 1) * dx
        g_lo = f(x_lo) - x_lo
        g_hi = f(x_hi) - x_hi

        if abs(g_lo) < tolerance:
            if not fixed_points or abs(fixed_points[-1] - x_lo) > tolerance:
                fixed_points.append(x_lo)
        elif g_lo * g_hi < 0:
            # Bisection
            lo, hi = x_lo, x_hi
            for _ in range(100):
                mid = (lo + hi) / 2
                g_mid = f(mid) - mid
                if abs(g_mid) < tolerance:
                    break
                if g_lo * g_mid < 0:
                    hi = mid
                else:
                    lo = mid
                    g_lo = g_mid
            fixed_points.append((lo + hi) / 2)

    return sorted(set(round(fp, 8) for fp in fixed_points))


def detect_bifurcations(
    family: Callable[[float, float], float],
    a_min: float,
    a_max: float,
    n_params: int = 1000,
) -> list[tuple[float, int, int]]:
    """
    Detect bifurcation points in a parameterized family of maps.

    Args:
        family: A function (a, x) → f_a(x) parameterized by a.
        a_min, a_max: Parameter range to scan.
        n_params: Number of parameter values to test.

    Returns:
        List of (a_value, fp_count_before, fp_count_after) at
        bifurcation points.
    """
    da = (a_max - a_min) / n_params
    bifurcations: list[tuple[float, int, int]] = []

    prev_count = len(find_fixed_points(lambda x: family(a_min, x)))

    for i in range(1, n_params + 1):
        a = a_min + i * da
        curr_count = len(find_fixed_points(lambda x, a=a: family(a, x)))
        if curr_count != prev_count:
            bifurcations.append((a, prev_count, curr_count))
        prev_count = curr_count

    return bifurcations


def cantor_set_intervals(n_stages: int) -> list[tuple[float, float]]:
    """
    Compute the intervals at stage n of the Cantor set construction.

    At each stage, the middle third of every interval is removed.

    Args:
        n_stages: Number of removal stages.

    Returns:
        List of (left, right) endpoints of surviving intervals.
    """
    intervals = [(0.0, 1.0)]
    for _ in range(n_stages):
        new_intervals: list[tuple[float, float]] = []
        for a, b in intervals:
            w = (b - a) / 3
            new_intervals.append((a, a + w))
            new_intervals.append((b - w, b))
        intervals = new_intervals
    return intervals


def cantor_set_measure(n_stages: int) -> float:
    """
    Compute the total Lebesgue measure at stage n.

    Returns (2/3)^n, demonstrating measure-zero convergence.
    """
    return (2.0 / 3.0) ** n_stages


def logistic_bifurcation_diagram(
    a_min: float = 0.0,
    a_max: float = 4.0,
    n_params: int = 2000,
    n_warmup: int = 500,
    n_plot: int = 200,
) -> list[tuple[float, float]]:
    """
    Compute the bifurcation diagram of the logistic map.

    For each parameter value a, iterates f_a(x) = ax(1-x) from x=0.5,
    discards transients, and records the attractor.

    Args:
        a_min, a_max: Parameter range.
        n_params: Number of parameter values.
        n_warmup: Iterations to discard (transient).
        n_plot: Iterations to record (attractor).

    Returns:
        List of (a, x) points on the bifurcation diagram.
    """
    points: list[tuple[float, float]] = []
    da = (a_max - a_min) / n_params

    for i in range(n_params + 1):
        a = a_min + i * da
        x = 0.5
        for _ in range(n_warmup):
            x = a * x * (1 - x)
        for _ in range(n_plot):
            x = a * x * (1 - x)
            points.append((a, x))

    return points


def score_entropy(
    f: Callable[[float], float],
    n_grid: int = 1000,
    period_max: int = 20,
) -> float:
    """
    Estimate the topological entropy of a map f : [0,1] → [0,1].

    Uses the growth rate of period-n points: h = lim (1/n) log(#periodic points of period n).

    Args:
        f: The map.
        n_grid: Grid resolution for finding periodic points.
        period_max: Maximum period to check.

    Returns:
        Estimated topological entropy.
    """
    def compose_n(f: Callable[[float], float], n: int) -> Callable[[float], float]:
        def fn(x: float) -> float:
            for _ in range(n):
                x = f(x)
            return x
        return fn

    entropies: list[float] = []
    for n in range(1, period_max + 1):
        fn = compose_n(f, n)
        periodic = find_fixed_points(fn, n_samples=n_grid * n)
        count = max(len(periodic), 1)
        entropies.append(math.log(count) / n)

    return max(entropies) if entropies else 0.0


if __name__ == "__main__":
    # Demo: contraction convergence
    kappa = 0.5
    fp, iters = iterate_contraction(lambda x: 0.5 * x + 0.25, 0.0, kappa)
    print(f"Contraction fixed point: {fp:.10f} (iterations: {iters})")

    # Demo: logistic fixed points
    for a in [0.5, 1.0, 1.5, 2.0, 3.0]:
        fps = find_fixed_points(lambda x, a=a: a * x * (1 - x))
        print(f"Logistic a={a:.1f}: fixed points = {fps}")

    # Demo: bifurcation detection
    bifs = detect_bifurcations(
        lambda a, x: a * x * (1 - x), 0.0, 3.5, n_params=500
    )
    for a, before, after in bifs:
        print(f"Bifurcation at a ≈ {a:.3f}: {before} → {after} fixed points")

    # Demo: Cantor set
    for n in range(6):
        intervals = cantor_set_intervals(n)
        print(f"Cantor stage {n}: {len(intervals)} intervals, "
              f"measure = {cantor_set_measure(n):.6f}")
