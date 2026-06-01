#!/usr/bin/env python3
"""
Algorithms for Self-Avoiding Walk Analysis

Type-hinted implementations of key algorithms from the SAW theory:
1. SAW enumeration via backtracking
2. Connective constant estimation
3. Bridge decomposition
4. Tropical partition function computation
"""

from typing import List, Tuple, Set, Optional, Dict
import math


# Type aliases
Point = Tuple[int, int]
Walk = List[Point]
Direction = Tuple[int, int]

DIRECTIONS: List[Direction] = [(0, 1), (0, -1), (1, 0), (-1, 0)]


def enumerate_saws_backtrack(n: int) -> List[Walk]:
    """
    Enumerate all n-step self-avoiding walks on ℤ² from origin.
    
    Algorithm: Depth-first backtracking search.
    Time complexity: O(μⁿ · n) where μ ≈ 2.638 is the connective constant.
    Space complexity: O(n) for the stack (iterative DFS).
    
    Args:
        n: Walk length (number of steps)
    
    Returns:
        List of all self-avoiding walks of length n starting at (0,0)
    """
    if n == 0:
        return [[(0, 0)]]
    
    result: List[Walk] = []
    
    def backtrack(path: Walk, visited: Set[Point]) -> None:
        if len(path) == n + 1:
            result.append(list(path))
            return
        x, y = path[-1]
        for dx, dy in DIRECTIONS:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                path.append((nx, ny))
                visited.add((nx, ny))
                backtrack(path, visited)
                path.pop()
                visited.discard((nx, ny))
    
    backtrack([(0, 0)], {(0, 0)})
    return result


def saw_count_fast(n: int) -> int:
    """
    Count n-step SAWs without storing them (memory-efficient).
    
    Uses the same backtracking algorithm but only increments a counter.
    
    Args:
        n: Walk length
    
    Returns:
        Number of self-avoiding walks of length n
    """
    if n == 0:
        return 1
    
    count = 0
    
    def backtrack(x: int, y: int, steps: int, visited: Set[Point]) -> None:
        nonlocal count
        if steps == n:
            count += 1
            return
        for dx, dy in DIRECTIONS:
            nx, ny = x + dx, y + dy
            if (nx, ny) not in visited:
                visited.add((nx, ny))
                backtrack(nx, ny, steps + 1, visited)
                visited.discard((nx, ny))
    
    backtrack(0, 0, 0, {(0, 0)})
    return count


def connective_constant_estimate(max_n: int = 20) -> Tuple[float, List[float]]:
    """
    Estimate the connective constant μ = lim c(n)^{1/n}.
    
    Computes c(n) for n = 1, ..., max_n and returns the sequence
    of estimates c(n)^{1/n} along with the best estimate.
    
    Args:
        max_n: Maximum walk length to enumerate
    
    Returns:
        Tuple of (best estimate, list of c(n)^{1/n} values)
    """
    estimates: List[float] = []
    for n in range(1, max_n + 1):
        c = saw_count_fast(n)
        est = c ** (1.0 / n)
        estimates.append(est)
    
    return estimates[-1], estimates


def nienhuis_properties() -> Dict[str, float]:
    """
    Compute and verify properties of the Nienhuis constant √(2+√2).
    
    Returns:
        Dictionary of computed properties
    """
    sqrt2 = math.sqrt(2)
    mu = math.sqrt(2 + sqrt2)
    xc = 1.0 / mu
    
    return {
        "sqrt_2": sqrt2,
        "nienhuis": mu,
        "nienhuis_sq": mu ** 2,
        "two_plus_sqrt2": 2 + sqrt2,
        "minimal_poly": mu**4 - 4*mu**2 + 2,  # Should be ~0
        "critical_fugacity": xc,
        "fugacity_poly": 2*xc**4 - 4*xc**2 + 1,  # Should be ~0
        "conjugate_product": (2 + sqrt2) * (2 - sqrt2),  # Should be 2
    }


def bridge_decomposition(walk: Walk) -> List[Walk]:
    """
    Decompose a self-avoiding walk into bridges.
    
    A bridge is a maximal segment where the y-coordinate at the endpoint
    exceeds all intermediate y-coordinates, and the y-coordinate at the
    start is below all intermediate y-coordinates.
    
    We use a simpler definition: split the walk at points where the
    y-coordinate achieves a new maximum.
    
    Args:
        walk: A self-avoiding walk (list of points)
    
    Returns:
        List of bridge segments
    """
    if len(walk) <= 1:
        return [walk]
    
    bridges: List[Walk] = []
    current_bridge: Walk = [walk[0]]
    max_y = walk[0][1]
    
    for i in range(1, len(walk)):
        current_bridge.append(walk[i])
        if walk[i][1] > max_y:
            max_y = walk[i][1]
            if i < len(walk) - 1:
                # Check if this is a valid split point
                bridges.append(current_bridge)
                current_bridge = [walk[i]]
    
    if current_bridge:
        bridges.append(current_bridge)
    
    return bridges


def tropical_partition_function(
    log_mu: float, 
    beta: float, 
    max_n: int = 100
) -> float:
    """
    Compute the tropical partition function Z_trop(β) = sup_n (n·log(μ) - β·n).
    
    In the max-plus semiring:
    - Subcritical (β < log μ): Z_trop = +∞ (unbounded)
    - Supercritical (β > log μ): Z_trop = 0 (attained at n=0)
    - Critical (β = log μ): Z_trop = 0 (all terms equal 0)
    
    Args:
        log_mu: Natural log of the connective constant
        beta: Inverse temperature parameter
        max_n: Maximum n to check (approximation for infinite sup)
    
    Returns:
        Approximate value of Z_trop(β)
    """
    return max(n * log_mu - beta * n for n in range(max_n + 1))


def subadditive_sequence_analysis(
    a: List[float]
) -> Dict[str, object]:
    """
    Analyze a sequence for subadditivity and compute Fekete ratio estimates.
    
    Args:
        a: Sequence values a[0], a[1], ..., a[n]
    
    Returns:
        Dictionary with analysis results
    """
    n = len(a)
    
    # Check subadditivity
    violations = []
    for m in range(n):
        for k in range(n):
            if m + k < n:
                if a[m + k] > a[m] + a[k] + 1e-10:
                    violations.append((m, k, a[m+k], a[m] + a[k]))
    
    # Compute ratios a(n)/n
    ratios = [a[i] / i if i > 0 else float('inf') for i in range(n)]
    
    # Infimum of ratios
    finite_ratios = [r for r in ratios[1:] if math.isfinite(r)]
    inf_ratio = min(finite_ratios) if finite_ratios else float('inf')
    
    return {
        "is_subadditive": len(violations) == 0,
        "violations": violations[:5],  # First 5 violations
        "ratios": ratios[1:],
        "infimum": inf_ratio,
    }


if __name__ == "__main__":
    # Demo
    print("SAW counts for n=0..12:")
    for n in range(13):
        c = saw_count_fast(n)
        print(f"  c({n:2d}) = {c}")
    
    print("\nNienhuis constant properties:")
    props = nienhuis_properties()
    for key, val in props.items():
        print(f"  {key}: {val:.12f}")
    
    print("\nConnective constant estimates:")
    best, estimates = connective_constant_estimate(12)
    for i, est in enumerate(estimates, 1):
        print(f"  c({i:2d})^(1/{i:2d}) = {est:.6f}")
    print(f"  Best estimate: μ ≈ {best:.6f}")
    
    print("\nSubadditivity of log(c(n)):")
    counts = [saw_count_fast(n) for n in range(13)]
    log_counts = [math.log(c) if c > 0 else 0 for c in counts]
    analysis = subadditive_sequence_analysis(log_counts)
    print(f"  Is subadditive: {analysis['is_subadditive']}")
    print(f"  Infimum of log(c(n))/n: {analysis['infimum']:.6f}")
    print(f"  exp(infimum) = {math.exp(analysis['infimum']):.6f}")
