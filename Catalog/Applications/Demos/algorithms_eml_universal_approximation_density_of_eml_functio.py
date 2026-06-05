#!/usr/bin/env python3
"""
EML Universal Approximation: Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

import numpy as np
from typing import Callable, List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class ApproxResult:
    """Result of an approximation computation."""
    coefficients: np.ndarray
    degree: int
    depth: int
    sup_norm_error: float
    basis_name: str


def iterExp(k: int, x: np.ndarray) -> np.ndarray:
    """
    Iterated exponential: exp composed with itself k times.
    
    iterExp(0, x) = x  (identity)
    iterExp(1, x) = exp(x)
    iterExp(2, x) = exp(exp(x))
    ...
    """
    result = x.copy().astype(float)
    for _ in range(k):
        result = np.exp(np.clip(result, -500, 500))  # Clip to prevent overflow
    return result


def build_basis_matrix(x: np.ndarray, depth: int, degree: int) -> np.ndarray:
    """
    Build the Vandermonde matrix for depth-d polynomial approximation.
    
    Depth 0: [1, x, x², ..., x^degree]
    Depth 1: [1, exp(x), exp(x)², ..., exp(x)^degree]
    Depth d: [1, iterExp(d,x), iterExp(d,x)², ...]
    """
    base = iterExp(depth, x)
    return np.vander(base, degree + 1, increasing=True)


def eml_approximate(
    f: Callable[[np.ndarray], np.ndarray],
    depth: int,
    degree: int,
    n_points: int = 500,
    domain: Tuple[float, float] = (0.0, 1.0)
) -> ApproxResult:
    """
    Approximate f on [a,b] using degree-N polynomial in iterExp(depth, x).
    
    Args:
        f: Target function
        depth: Tower depth (0=polynomials, 1=poly in exp, etc.)
        degree: Polynomial degree
        n_points: Number of sample points
        domain: Approximation domain [a, b]
    
    Returns:
        ApproxResult with coefficients and error bound
    """
    a, b = domain
    x = np.linspace(a, b, n_points)
    y = f(x)
    
    V = build_basis_matrix(x, depth, degree)
    coeffs, _, _, _ = np.linalg.lstsq(V, y, rcond=None)
    approx = V @ coeffs
    error = float(np.max(np.abs(approx - y)))
    
    depth_names = {0: "polynomial", 1: "poly-in-exp", 2: "poly-in-exp²"}
    basis_name = depth_names.get(depth, f"poly-in-exp^{depth}")
    
    return ApproxResult(
        coefficients=coeffs,
        degree=degree,
        depth=depth,
        sup_norm_error=error,
        basis_name=basis_name
    )


def tower_search(
    f: Callable[[np.ndarray], np.ndarray],
    epsilon: float,
    max_depth: int = 5,
    max_degree: int = 50,
    domain: Tuple[float, float] = (0.0, 1.0)
) -> Optional[ApproxResult]:
    """
    Search the approximation tower for the shallowest depth and lowest degree
    that achieves error < epsilon.
    
    This implements the abstract tower search guaranteed to terminate
    by the density theorem (eml_universalDensity_01).
    """
    for depth in range(max_depth + 1):
        for degree in range(1, max_degree + 1):
            result = eml_approximate(f, depth, degree, domain=domain)
            if result.sup_norm_error < epsilon:
                return result
    return None


def compare_depths(
    f: Callable[[np.ndarray], np.ndarray],
    degrees: List[int],
    max_depth: int = 3,
    domain: Tuple[float, float] = (0.0, 1.0)
) -> dict:
    """
    Compare approximation errors across tower depths.
    
    Returns a dict mapping (depth, degree) -> error.
    """
    results = {}
    for depth in range(max_depth + 1):
        for degree in degrees:
            result = eml_approximate(f, depth, degree, domain=domain)
            results[(depth, degree)] = result.sup_norm_error
    return results


def stone_weierstrass_witness(
    x1: float,
    x2: float,
    depth: int = 1
) -> float:
    """
    Demonstrate point separation: given x1 ≠ x2 in [0,1],
    return |iterExp(depth, x1) - iterExp(depth, x2)|.
    
    This is always positive when x1 ≠ x2, witnessing the
    separation property used in Stone-Weierstrass.
    """
    val1 = iterExp(depth, np.array([x1]))[0]
    val2 = iterExp(depth, np.array([x2]))[0]
    return abs(val1 - val2)


if __name__ == "__main__":
    # Example: approximate sin(πx) on [0,1]
    target = lambda x: np.sin(np.pi * x)
    
    print("Tower search for sin(πx), ε = 0.01:")
    result = tower_search(target, 0.01)
    if result:
        print(f"  Found at depth {result.depth}, degree {result.degree}")
        print(f"  Basis: {result.basis_name}")
        print(f"  Error: {result.sup_norm_error:.6f}")
    
    print("\nDepth comparison for sin(πx):")
    errors = compare_depths(target, [3, 5, 10, 15])
    for (d, n), e in sorted(errors.items()):
        print(f"  Depth {d}, Degree {n}: error = {e:.2e}")
    
    print("\nPoint separation witness:")
    for x1, x2 in [(0.3, 0.7), (0.49, 0.51), (0.0, 1.0)]:
        gap = stone_weierstrass_witness(x1, x2)
        print(f"  |exp({x1}) - exp({x2})| = {gap:.6f}")
