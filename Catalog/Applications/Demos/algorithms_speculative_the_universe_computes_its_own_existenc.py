#!/usr/bin/env python3
"""
Reflexive Simulation Systems: Core Algorithms

Type-hinted implementations of the key algorithms from the RSS framework.
"""

from typing import TypeVar, Callable, List, Tuple, Optional, Generic
from dataclasses import dataclass
import math

T = TypeVar('T')


@dataclass
class FixedPointResult(Generic[T]):
    """Result of a fixed point computation."""
    value: T
    iterations: int
    trajectory: List[T]
    converged: bool


def kleene_iterate(
    f: Callable[[float], float],
    bot: float = 0.0,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> FixedPointResult[float]:
    """
    Kleene Fixed Point Iteration.

    Computes the least fixed point of a monotone ω-continuous function f
    by iterating: ⊥, f(⊥), f²(⊥), ...

    Theorem (Kleene): If f is ω-continuous on a complete lattice,
    lfp(f) = ⨆_n f^n(⊥).

    Args:
        f: Monotone function
        bot: Bottom element of the lattice
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        FixedPointResult with the computed fixed point
    """
    trajectory = [bot]
    x = bot
    for i in range(max_iter):
        x_new = f(x)
        trajectory.append(x_new)
        if abs(x_new - x) < tol:
            return FixedPointResult(x_new, i + 1, trajectory, True)
        x = x_new
    return FixedPointResult(x, max_iter, trajectory, False)


def diagonal_fixed_point(
    phi: Callable[[float, float], float],
    bot: float = 0.0,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> FixedPointResult[float]:
    """
    Diagonal Fixed Point Algorithm.

    Given Φ : α × α → α (representing Φ(a)(b)), computes the least x₀
    such that Φ(x₀)(x₀) = x₀.

    This is the self-simulation fixed point: law x₀ simulates itself.

    Theorem (Diagonal FP): The diagonal map D(x) = Φ(x)(x) is monotone
    if Φ is monotone in both arguments, and lfp(D) exists.

    Args:
        phi: The simulation family Φ(a, b) = Φ(a)(b)
        bot: Bottom element
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        FixedPointResult with the self-simulation fixed point
    """
    def diagonal(x: float) -> float:
        return phi(x, x)
    return kleene_iterate(diagonal, bot, tol, max_iter)


def product_simulation(
    sims: List[Callable[[float], float]],
    bot: Optional[List[float]] = None,
    tol: float = 1e-12,
    max_iter: int = 10000
) -> Tuple[List[float], List[int]]:
    """
    Product Simulation: compute component-wise fixed points.

    Theorem: A product simulation fixes a vector iff each component
    simulation fixes its corresponding entry.

    Args:
        sims: List of component simulation functions
        bot: Bottom vector (default: all zeros)
        tol: Convergence tolerance
        max_iter: Maximum iterations

    Returns:
        Tuple of (fixed point vector, iteration counts per component)
    """
    n = len(sims)
    if bot is None:
        bot = [0.0] * n

    results = [kleene_iterate(sims[i], bot[i], tol, max_iter) for i in range(n)]
    return [r.value for r in results], [r.iterations for r in results]


def idempotent_collapse(
    f: Callable[[float], float],
    sample_points: List[float]
) -> Tuple[List[float], List[float]]:
    """
    Idempotent Collapse: compute the range and fixed points of an
    idempotent function.

    Theorem: For idempotent f (f∘f = f), range(f) = fixedPoints(f).
    Also: lfp(f) = f(⊥), gfp(f) = f(⊤).

    Args:
        f: Idempotent function
        sample_points: Points to evaluate

    Returns:
        Tuple of (range values, fixed points found)
    """
    range_values = sorted(set(round(f(x), 10) for x in sample_points))
    fixed_points = [x for x in sample_points if abs(f(x) - x) < 1e-10]
    return range_values, fixed_points


def simulation_depth(
    f: Callable[[float], float],
    x: float,
    bot: float = 0.0,
    max_depth: int = 1000
) -> Optional[int]:
    """
    Compute the simulation depth of x with respect to f.

    depth_f(x) = min{n ∈ ℕ : x ≤ f^n(⊥)}

    Measures how many iterations of self-simulation are needed to
    "reach" the state x.

    Theorem: depth(⊥) = 0.
    Theorem: If lfp(f) has finite depth and f is ω-continuous,
    then lfp(f) is reachable.

    Args:
        f: Monotone function
        x: Target element
        bot: Bottom element
        max_depth: Maximum search depth

    Returns:
        Depth (int) or None if not reachable within max_depth
    """
    val = bot
    for n in range(max_depth + 1):
        if val >= x - 1e-10:
            return n
        val = f(val)
    return None


def fixed_point_spectrum(
    f: Callable[[float], float],
    search_range: Tuple[float, float] = (0.0, 1.0),
    num_samples: int = 10000,
    tol: float = 1e-8
) -> List[float]:
    """
    Search for all fixed points of f in a given range.

    Finds x such that |f(x) - x| < tol by dense sampling and refinement.

    Theorem: All fixed points lie in [lfp(f), gfp(f)].

    Args:
        f: Monotone function
        search_range: Range to search
        num_samples: Number of sample points
        tol: Fixed point tolerance

    Returns:
        List of approximate fixed points
    """
    lo, hi = search_range
    candidates = []

    xs = [lo + (hi - lo) * i / num_samples for i in range(num_samples + 1)]
    for x in xs:
        if abs(f(x) - x) < tol:
            candidates.append(x)

    # Merge nearby candidates
    if not candidates:
        return []

    merged = [candidates[0]]
    for c in candidates[1:]:
        if c - merged[-1] > tol * 10:
            merged.append(c)

    return merged


def uniqueness_test(
    f: Callable[[float], float],
    search_range: Tuple[float, float] = (0.0, 1.0),
    tol: float = 1e-8
) -> Tuple[bool, List[float]]:
    """
    Test whether f has a unique fixed point.

    Theorem: lfp(f) = gfp(f) ↔ the fixed point is unique.

    Args:
        f: Monotone function
        search_range: Range to search
        tol: Tolerance

    Returns:
        Tuple of (is_unique, list of fixed points found)
    """
    fps = fixed_point_spectrum(f, search_range, tol=tol)
    return len(fps) <= 1, fps


# ============================================================================
# Example usage
# ============================================================================

if __name__ == "__main__":
    print("=== Reflexive Simulation System Algorithms ===\n")

    # 1. Diagonal fixed point
    phi = lambda a, b: (a + 2*b + 1) / 4
    result = diagonal_fixed_point(phi)
    print(f"Diagonal FP of Φ(a,b) = (a+2b+1)/4:")
    print(f"  x₀ = {result.value:.10f} (expected: 1.0)")
    print(f"  Converged in {result.iterations} iterations")
    print(f"  Self-consistent: Φ(x₀,x₀) = {phi(result.value, result.value):.10f}\n")

    # 2. Product simulation
    sims = [
        lambda x: (x + 0.5) / 2,   # fp = 0.5
        lambda x: (x + 3.0) / 2,   # fp = 3.0
        lambda x: (x + 0.1) / 2,   # fp = 0.1
    ]
    fps, iters = product_simulation(sims)
    print(f"Product simulation (3 components):")
    print(f"  Fixed points: {[f'{x:.6f}' for x in fps]}")
    print(f"  Iterations:   {iters}\n")

    # 3. Uniqueness test
    is_unique, fps_found = uniqueness_test(lambda x: x**3, (0.0, 1.0))
    print(f"Uniqueness test for f(x) = x³ on [0,1]:")
    print(f"  Unique? {is_unique}")
    print(f"  Fixed points: {fps_found}\n")

    # 4. Simulation depth
    f = lambda x: min(x + 0.1, 1.0)
    for target in [0.0, 0.3, 0.5, 1.0]:
        d = simulation_depth(f, target)
        print(f"  depth_{'{f}'}({target}) = {d}")
