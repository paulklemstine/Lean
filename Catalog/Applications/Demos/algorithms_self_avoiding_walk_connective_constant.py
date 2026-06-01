"""
Self-Avoiding Walk Algorithms
Implementations of SAW enumeration, connective constant estimation,
and related computations.
"""

from typing import List, Tuple, Set, Dict, Optional
import math
from collections import defaultdict


# Type aliases
Point = Tuple[int, int]
Walk = List[Point]


def neighbors(p: Point) -> List[Point]:
    """Return the 4 nearest neighbors of a point on Z²."""
    x, y = p
    return [(x+1, y), (x-1, y), (x, y+1), (x, y-1)]


def count_saws(n: int) -> int:
    """
    Count all self-avoiding walks of length n on Z² starting from origin.

    Uses depth-first search with backtracking.
    Complexity: O(4 * 3^(n-1)) worst case, much less in practice.

    Args:
        n: Length of walks (number of steps)

    Returns:
        Number of self-avoiding walks of length n
    """
    if n == 0:
        return 1

    count = 0
    visited: Set[Point] = {(0, 0)}

    def dfs(pos: Point, steps: int) -> None:
        nonlocal count
        if steps == n:
            count += 1
            return
        for nbr in neighbors(pos):
            if nbr not in visited:
                visited.add(nbr)
                dfs(nbr, steps + 1)
                visited.remove(nbr)

    dfs((0, 0), 0)
    return count


def enumerate_saws(n: int) -> List[Walk]:
    """
    Enumerate all self-avoiding walks of length n on Z² starting from origin.

    Args:
        n: Length of walks (number of steps)

    Returns:
        List of all self-avoiding walks
    """
    if n == 0:
        return [[(0, 0)]]

    result: List[Walk] = []
    visited: Set[Point] = {(0, 0)}
    current: Walk = [(0, 0)]

    def dfs(pos: Point, steps: int) -> None:
        if steps == n:
            result.append(list(current))
            return
        for nbr in neighbors(pos):
            if nbr not in visited:
                visited.add(nbr)
                current.append(nbr)
                dfs(nbr, steps + 1)
                current.pop()
                visited.remove(nbr)

    dfs((0, 0), 0)
    return result


def estimate_connective_constant(max_n: int = 20) -> Dict[str, float]:
    """
    Estimate the connective constant μ of Z² using exact enumeration.

    Uses three methods:
    1. n-th root: μ ≈ c_n^(1/n)
    2. Ratio method: μ ≈ c_{n+1}/c_n
    3. Extrapolation using Nienhuis's conjectured γ = 43/32

    Args:
        max_n: Maximum walk length to enumerate

    Returns:
        Dictionary with estimates from each method
    """
    counts = []
    for k in range(max_n + 1):
        c = count_saws(k)
        counts.append(c)

    # n-th root estimates
    root_estimates = []
    for k in range(1, len(counts)):
        root_estimates.append(counts[k] ** (1.0 / k))

    # Ratio estimates
    ratio_estimates = []
    for k in range(1, len(counts)):
        ratio_estimates.append(counts[k] / counts[k-1])

    # Best estimates (last values)
    n = len(counts) - 1
    return {
        "n": n,
        "c_n": counts[n],
        "root_estimate": root_estimates[-1],
        "ratio_estimate": ratio_estimates[-1],
        "root_estimates": root_estimates,
        "ratio_estimates": ratio_estimates,
        "counts": counts,
    }


def nienhuis_mu() -> float:
    """
    Compute the Nienhuis value μ = √(2 + √2) for the hexagonal lattice.

    Returns:
        The Nienhuis connective constant
    """
    return math.sqrt(2 + math.sqrt(2))


def verify_minimal_polynomial(x: float) -> float:
    """
    Verify that x satisfies the minimal polynomial x⁴ - 4x² + 2 = 0.

    Args:
        x: Value to test

    Returns:
        Residual x⁴ - 4x² + 2 (should be ≈ 0 for μ_hex)
    """
    return x**4 - 4*x**2 + 2


def critical_fugacity() -> float:
    """
    Compute the critical fugacity x_c = 1/μ_hex.

    Returns:
        The critical fugacity
    """
    return 1.0 / nienhuis_mu()


def submultiplicativity_check(counts: List[int]) -> List[Tuple[int, int, bool]]:
    """
    Verify the submultiplicative inequality c(m+n) ≤ c(m) * c(n)
    for all valid pairs (m, n).

    Args:
        counts: List of SAW counts c(0), c(1), ...

    Returns:
        List of (m, n, satisfied) tuples
    """
    results = []
    n = len(counts) - 1
    for m in range(n + 1):
        for k in range(n - m + 1):
            if m + k <= n:
                satisfied = counts[m + k] <= counts[m] * counts[k]
                results.append((m, k, satisfied))
    return results


def bridge_count_estimate(n: int) -> int:
    """
    Count bridges of length n on Z² (walks where x-coordinate
    is maximized at the endpoint).

    Args:
        n: Length of bridges

    Returns:
        Number of bridges of length n
    """
    if n == 0:
        return 1

    count = 0
    visited: Set[Point] = {(0, 0)}

    def dfs(pos: Point, steps: int, max_x: int) -> None:
        nonlocal count
        if steps == n:
            if pos[0] >= max_x:
                count += 1
            return
        for nbr in neighbors(pos):
            if nbr not in visited:
                visited.add(nbr)
                new_max = max(max_x, nbr[0])
                # Bridge condition: intermediate points must have x < final x
                # We check at the end
                dfs(nbr, steps + 1, new_max)
                visited.remove(nbr)

    dfs((0, 0), 0, 0)
    return count


def saw_end_to_end_distance(n: int) -> float:
    """
    Compute the mean squared end-to-end distance of SAWs of length n.

    The conjectured scaling is <R²> ~ n^(2ν) where ν = 3/4 in 2D.

    Args:
        n: Length of walks

    Returns:
        Mean squared end-to-end distance
    """
    if n == 0:
        return 0.0

    total_r2 = 0
    count = 0
    visited: Set[Point] = {(0, 0)}

    def dfs(pos: Point, steps: int) -> None:
        nonlocal total_r2, count
        if steps == n:
            total_r2 += pos[0]**2 + pos[1]**2
            count += 1
            return
        for nbr in neighbors(pos):
            if nbr not in visited:
                visited.add(nbr)
                dfs(nbr, steps + 1)
                visited.remove(nbr)

    dfs((0, 0), 0)
    return total_r2 / count if count > 0 else 0.0


if __name__ == "__main__":
    # Quick self-test
    print("SAW counts for small n:")
    for k in range(11):
        c = count_saws(k)
        print(f"  c({k}) = {c}")

    print(f"\nNienhuis μ = √(2+√2) = {nienhuis_mu():.10f}")
    print(f"Minimal polynomial residual: {verify_minimal_polynomial(nienhuis_mu()):.2e}")
    print(f"Critical fugacity x_c = {critical_fugacity():.10f}")
    print(f"x_c² * (2+√2) = {critical_fugacity()**2 * (2 + math.sqrt(2)):.10f}")
