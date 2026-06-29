#!/usr/bin/env python3
"""
Algorithms for Tropical Convexity and Helly Theory

Type-hinted implementations of core algorithms from the research.
"""

from typing import Optional
import numpy as np


def tropical_add(a: float, b: float) -> float:
    """Tropical addition: max(a, b)."""
    return max(a, b)


def tropical_mult(a: float, b: float) -> float:
    """Tropical multiplication: a + b."""
    return a + b


def tropical_linear_combination(
    x: np.ndarray, y: np.ndarray, a: float, b: float
) -> np.ndarray:
    """
    Tropical linear combination: coordinatewise max(a + x_i, b + y_i).
    
    Parameters:
        x, y: Points in ℝⁿ
        a, b: Tropical coefficients
    
    Returns:
        z where z_i = max(a + x_i, b + y_i)
    """
    return np.maximum(a + x, b + y)


def is_in_tropical_segment(
    z: np.ndarray, x: np.ndarray, y: np.ndarray, tol: float = 1e-8
) -> tuple[bool, Optional[tuple[float, float]]]:
    """
    Check if z lies in the tropical segment between x and y.
    
    A point z is in tropSegment(x, y) iff there exist a, b such that
    z_i = max(a + x_i, b + y_i) for all i.
    
    Returns:
        (is_member, (a, b) if found else None)
    """
    n = len(z)
    if n == 0:
        return True, (0.0, 0.0)
    
    # For z to equal max(a + x, b + y), we need for each coordinate i:
    # either z_i = a + x_i >= b + y_i, or z_i = b + y_i >= a + x_i
    # This gives a - b >= y_i - x_i (first case) or a - b <= z_i - x_i - (z_i - y_i) = y_i - x_i... 
    # Actually: try all possible assignments of "which term achieves max"
    # For efficiency, try a = z_0 - x_0 and check
    
    for ref_idx in range(n):
        # Try a = z[ref_idx] - x[ref_idx]
        a_try = z[ref_idx] - x[ref_idx]
        # Then for each i where b + y_i = z_i, b = z_i - y_i
        # For each i where a + x_i = z_i, a = z_i - x_i should be consistent
        
        for ref_idx2 in range(n):
            b_try = z[ref_idx2] - y[ref_idx2]
            # Check if this (a, b) works
            z_check = np.maximum(a_try + x, b_try + y)
            if np.allclose(z_check, z, atol=tol):
                return True, (a_try, b_try)
    
    return False, None


def helly_intervals(
    intervals: list[tuple[float, float]]
) -> tuple[bool, Optional[float]]:
    """
    Helly's theorem for intervals.
    
    Given a family of closed intervals [a_i, b_i], determines if they
    have a common point and returns one if so.
    
    The family has non-empty intersection iff for all i, j: a_i <= b_j.
    The common point is max_i(a_i).
    
    Parameters:
        intervals: List of (lower, upper) bounds
    
    Returns:
        (has_intersection, common_point or None)
    """
    if not intervals:
        return True, 0.0
    
    # Check pairwise condition: a_i <= b_j for all i, j
    max_lower = max(a for a, _ in intervals)
    min_upper = min(b for _, b in intervals)
    
    if max_lower <= min_upper + 1e-12:
        return True, max_lower
    else:
        return False, None


def diff_constraint_feasibility(
    n_vars: int,
    constraints: list[tuple[int, int, float]]
) -> tuple[bool, Optional[list[float]]]:
    """
    Bellman-Ford algorithm for difference constraint feasibility.
    
    Given constraints x_i - x_j <= c for each (i, j, c) in constraints,
    determines feasibility and returns a solution if feasible.
    
    The system is feasible iff no negative-weight cycle exists in the
    constraint graph.
    
    Parameters:
        n_vars: Number of variables
        constraints: List of (i, j, c) meaning x_i - x_j <= c
    
    Returns:
        (is_feasible, solution or None)
    """
    # Initialize distances: d[v] = shortest path from source (extra node)
    INF = float('inf')
    dist = [0.0] * n_vars  # Source connects to all with weight 0
    
    # Relax edges n_vars times
    for iteration in range(n_vars):
        updated = False
        for i, j, c in constraints:
            # Edge from j to i with weight c: d[i] <= d[j] + c
            if dist[j] + c < dist[i] - 1e-12:
                dist[i] = dist[j] + c
                updated = True
        if not updated:
            break
    
    # Check for negative cycles (one more iteration)
    for i, j, c in constraints:
        if dist[j] + c < dist[i] - 1e-12:
            return False, None
    
    # Negate to get solution: x_v = -dist[v]
    solution = [-d for d in dist]
    return True, solution


def tropical_halfspace_intersection_nonempty(
    n: int, i: int, j: int, a: float, b: float
) -> tuple[bool, Optional[np.ndarray]]:
    """
    Check if the intersection of tropical halfspaces
    H_ij(a) ∩ H_ji(b) = {z : z_i <= z_j + a} ∩ {z : z_j <= z_i + b}
    is non-empty.
    
    Non-empty iff a + b >= 0.
    
    Parameters:
        n: Ambient dimension
        i, j: Coordinate indices
        a, b: Halfspace bounds
    
    Returns:
        (is_nonempty, witness point or None)
    """
    if a + b < -1e-12:
        return False, None
    
    z = np.zeros(n)
    z[j] = -a  # Then z_i - z_j = 0 - (-a) = a, so z_i = z_j + a
    # z_j <= z_i + b becomes -a <= 0 + b, i.e., a + b >= 0 ✓
    return True, z


def cycle_condition_check(weights: list[float]) -> tuple[bool, Optional[list[float]]]:
    """
    Check the non-negative cycle condition for a cyclic system
    x_{k} - x_{k+1 mod n} <= c_k.
    
    Feasible iff sum(weights) >= 0.
    Solution: x_0 = 0, x_k = -sum(c_0, ..., c_{k-1}).
    
    Parameters:
        weights: Cycle edge weights [c_0, c_1, ..., c_{n-1}]
    
    Returns:
        (is_feasible, solution or None)
    """
    total = sum(weights)
    if total < -1e-12:
        return False, None
    
    n = len(weights)
    solution = [0.0]
    cumsum = 0.0
    for k in range(n - 1):
        cumsum += weights[k]
        solution.append(-cumsum)
    
    return True, solution


def tropical_convex_hull_membership(
    z: np.ndarray,
    generators: list[np.ndarray],
    n_attempts: int = 10000,
    tol: float = 1e-6
) -> bool:
    """
    Approximate membership test for the tropical convex hull.
    
    Tests whether z can be written as max_k(λ_k + p_k) for some
    coefficients λ by random search.
    
    Parameters:
        z: Point to test
        generators: Generator points
        n_attempts: Number of random coefficient trials
    
    Returns:
        True if z appears to be in the tropical convex hull
    """
    m = len(generators)
    dim = len(z)
    
    for _ in range(n_attempts):
        lambdas = np.random.uniform(-5, 5, size=m)
        # Compute tropical combination
        result = np.full(dim, -np.inf)
        for k in range(m):
            result = np.maximum(result, lambdas[k] + generators[k])
        
        if np.allclose(result, z, atol=tol):
            return True
    
    return False


if __name__ == "__main__":
    # Quick self-test
    print("Testing algorithms...")
    
    # Helly intervals
    assert helly_intervals([(1, 5), (2, 6), (3, 7)])[0] == True
    assert helly_intervals([(1, 3), (4, 6)])[0] == False
    
    # Cycle condition
    assert cycle_condition_check([2, 3, -4])[0] == True
    assert cycle_condition_check([1, -3, 1])[0] == False
    
    # Bellman-Ford
    feasible, sol = diff_constraint_feasibility(3, [(0, 1, 2), (1, 2, 3), (2, 0, -4)])
    assert feasible == True
    
    # Halfspace intersection
    assert tropical_halfspace_intersection_nonempty(3, 0, 1, 2.0, -1.0)[0] == True
    assert tropical_halfspace_intersection_nonempty(3, 0, 1, 1.0, -2.0)[0] == False
    
    print("All tests passed! ✓")
