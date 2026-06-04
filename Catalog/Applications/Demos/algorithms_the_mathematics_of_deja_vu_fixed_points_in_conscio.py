#!/usr/bin/env python3
"""
Algorithms for Discrete Dynamical Systems Analysis

Type-hinted implementations of the core algorithms used in the
Recurrence Spectrum theory of cognitive dynamics.
"""

from typing import Callable, Dict, List, Optional, Set, Tuple
import math


# ============================================================
# Algorithm 1: Recurrence Spectrum Computation
# ============================================================

def compute_recurrence_spectrum(
    f: Callable[[float], float],
    x0: float,
    max_period: int,
    tolerance: float = 1e-10,
    transient: int = 1000
) -> Dict[int, List[float]]:
    """
    Compute the recurrence spectrum of a dynamical system.
    
    For each period n from 1 to max_period, finds all approximate
    periodic points with minimal period n accessible from x0.
    
    Algorithm:
    1. Skip transient iterations to approach the attractor
    2. For each candidate period n:
       a. Iterate f^n and check if |f^n(x) - x| < tolerance
       b. Verify minimality: no proper divisor d of n has |f^d(x) - x| < tolerance
    3. Group results by minimal period
    
    Returns: Dictionary mapping period n → list of periodic points
    
    Complexity: O(transient + max_period² × orbit_length)
    """
    # Skip transient
    x = x0
    for _ in range(transient):
        x = f(x)
    
    # Collect long orbit
    orbit_len = max_period * 50
    orbit: List[float] = [x]
    for _ in range(orbit_len):
        x = f(x)
        orbit.append(x)
    
    spectrum: Dict[int, List[float]] = {}
    
    for n in range(1, max_period + 1):
        points: List[float] = []
        for i in range(len(orbit) - n):
            if abs(orbit[i + n] - orbit[i]) < tolerance:
                # Check minimality
                is_minimal = True
                for d in range(1, n):
                    if n % d == 0 and abs(orbit[i + d] - orbit[i]) < tolerance:
                        is_minimal = False
                        break
                if is_minimal:
                    # Deduplicate
                    if not any(abs(p - orbit[i]) < tolerance * 100 for p in points):
                        points.append(orbit[i])
        if points:
            spectrum[n] = points
    
    return spectrum


# ============================================================
# Algorithm 2: Recurrence Depth Computation
# ============================================================

def compute_recurrence_depth(
    f: Callable[[float], float],
    x: float,
    epsilon: float,
    max_iterations: int
) -> int:
    """
    Compute the recurrence depth of point x.
    
    The recurrence depth is the minimum k ≥ 0 such that
    |f^[k+1](x) - x| < epsilon. If no such k exists within
    max_iterations, returns max_iterations.
    
    This invariant measures how "close to periodic" a point is:
    - Fixed points: depth = 0
    - Period-n points: depth = n-1
    - Non-recurrent points: depth → ∞
    
    Algorithm: Simple iteration with early termination.
    Complexity: O(max_iterations)
    """
    if epsilon <= 0:
        return max_iterations
    
    current = x
    for k in range(max_iterations):
        current = f(current)
        if abs(current - x) < epsilon:
            return k
    return max_iterations


# ============================================================
# Algorithm 3: Interval Covering Detection
# ============================================================

def detect_covering_relations(
    f: Callable[[float], float],
    intervals: List[Tuple[float, float]],
    n_samples: int = 1000
) -> List[Tuple[int, int]]:
    """
    Detect interval covering relations for a continuous map.
    
    For each pair of intervals (Iᵢ, Iⱼ), checks whether f(Iᵢ) ⊇ Iⱼ
    by sampling the image of Iᵢ and checking containment.
    
    Algorithm:
    1. For each interval Iᵢ = [aᵢ, bᵢ]:
       a. Sample f at n_samples points in Iᵢ
       b. Compute min and max of f(Iᵢ) approximately
    2. Check: f(Iᵢ) ⊇ Iⱼ iff min(f(Iᵢ)) ≤ aⱼ and max(f(Iᵢ)) ≥ bⱼ
    
    Returns: List of (i, j) pairs where Iᵢ f-covers Iⱼ
    Complexity: O(|intervals|² × n_samples)
    """
    n = len(intervals)
    images: List[Tuple[float, float]] = []
    
    for a, b in intervals:
        samples = [f(a + (b - a) * k / n_samples) for k in range(n_samples + 1)]
        images.append((min(samples), max(samples)))
    
    coverings: List[Tuple[int, int]] = []
    for i in range(n):
        for j in range(n):
            a_j, b_j = intervals[j]
            img_min, img_max = images[i]
            if img_min <= a_j + 1e-10 and img_max >= b_j - 1e-10:
                coverings.append((i, j))
    
    return coverings


# ============================================================
# Algorithm 4: Möbius Periodic Point Counting
# ============================================================

def mobius_function(n: int) -> int:
    """Compute the Möbius function μ(n)."""
    if n == 1:
        return 1
    
    # Factor n
    factors: List[int] = []
    d = 2
    temp = n
    while d * d <= temp:
        if temp % d == 0:
            factors.append(d)
            temp //= d
            if temp % d == 0:
                return 0  # p² divides n
        d += 1
    if temp > 1:
        factors.append(temp)
    
    return (-1) ** len(factors)


def count_minimal_period_points(
    phi_values: Dict[int, int],
    n: int
) -> int:
    """
    Apply Möbius inversion to compute the number of minimal-period-n points.
    
    Given Φ(d) = #{x : f^d(x) = x} for all d | n,
    computes φ(n) = Σ_{d|n} μ(n/d) · Φ(d).
    
    This is the key number-theoretic connection in the Recurrence Spectrum theory.
    """
    result = 0
    for d in range(1, n + 1):
        if n % d == 0:
            mu = mobius_function(n // d)
            phi_d = phi_values.get(d, 0)
            result += mu * phi_d
    return result


# ============================================================
# Algorithm 5: Bifurcation Diagram Computation
# ============================================================

def compute_bifurcation_data(
    r_min: float = 2.5,
    r_max: float = 4.0,
    n_r: int = 1000,
    transient: int = 500,
    n_plot: int = 200
) -> List[Tuple[float, List[float]]]:
    """
    Compute bifurcation diagram data for the logistic map.
    
    For each value of parameter r, iterates the logistic map
    past the transient and records the attractor values.
    
    Returns: List of (r, attractor_values) pairs
    """
    data: List[Tuple[float, List[float]]] = []
    
    for i in range(n_r):
        r = r_min + (r_max - r_min) * i / (n_r - 1)
        x = 0.5
        # Skip transient
        for _ in range(transient):
            x = r * x * (1.0 - x)
        # Record attractor
        values: List[float] = []
        for _ in range(n_plot):
            x = r * x * (1.0 - x)
            values.append(x)
        data.append((r, values))
    
    return data


# ============================================================
# Algorithm 6: Lyapunov Exponent Computation
# ============================================================

def lyapunov_exponent(
    f: Callable[[float], float],
    df: Callable[[float], float],
    x0: float,
    n_iter: int = 10000,
    transient: int = 1000
) -> float:
    """
    Compute the Lyapunov exponent of a one-dimensional map.
    
    λ = lim_{n→∞} (1/n) Σ_{k=0}^{n-1} log|f'(f^k(x₀))|
    
    Positive λ indicates chaos (sensitive dependence on initial conditions).
    The Lyapunov exponent equals the topological entropy for unimodal maps.
    """
    x = x0
    # Skip transient
    for _ in range(transient):
        x = f(x)
    
    log_sum = 0.0
    for _ in range(n_iter):
        derivative = abs(df(x))
        if derivative < 1e-15:
            return float('-inf')
        log_sum += math.log(derivative)
        x = f(x)
    
    return log_sum / n_iter


if __name__ == "__main__":
    # Quick test
    r = 3.83
    f = lambda x: r * x * (1.0 - x)
    df = lambda x: r * (1.0 - 2.0 * x)
    
    print("Recurrence Spectrum at r = 3.83:")
    spectrum = compute_recurrence_spectrum(f, 0.5, 10)
    for period, points in sorted(spectrum.items()):
        print(f"  Period {period}: {len(points)} point(s)")
    
    print(f"\nLyapunov exponent: {lyapunov_exponent(f, df, 0.5):.4f}")
    
    print("\nCovering relations for period-3 orbit:")
    # Find orbit
    x = 0.5
    for _ in range(10000):
        x = f(x)
    pts = sorted([x, f(x), f(f(x))])
    intervals = [(pts[0], pts[1]), (pts[1], pts[2])]
    coverings = detect_covering_relations(f, intervals)
    for i, j in coverings:
        print(f"  I_{i} f-covers I_{j}")
