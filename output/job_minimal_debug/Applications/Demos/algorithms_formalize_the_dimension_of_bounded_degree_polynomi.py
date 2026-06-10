#!/usr/bin/env python3
"""
Algorithms for bounded-degree polynomial spaces.

Implements efficient enumeration, basis construction, and dimension computation
for multivariate polynomial spaces with bounded total degree.
"""

from math import comb
from typing import Iterator, Tuple, List
import numpy as np


def multichoose(n: int, k: int) -> int:
    """Compute the multichoose function: C(n+k-1, k).
    
    The number of multisets of size k from n elements.
    Equivalently, the number of weak compositions of k into n parts.
    
    Time: O(min(n, k))
    Space: O(1)
    
    Args:
        n: Number of element types (variables)
        k: Size of multiset (degree)
    
    Returns:
        Number of multisets / weak compositions
    
    Examples:
        >>> multichoose(3, 2)  # {xx, xy, xz, yy, yz, zz}
        6
        >>> multichoose(2, 3)  # {xxx, xxy, xyy, yyy}
        4
    """
    if n == 0 and k == 0:
        return 1
    if n == 0 or k < 0:
        return 0
    return comb(n + k - 1, k)


def bounded_degree_dimension(n: int, d: int) -> int:
    """Compute dim(K[x_1,...,x_n]_{<d}).
    
    The dimension of the space of multivariate polynomials in n variables
    with total degree strictly less than d.
    
    Formula: C(d + n - 1, n) when d + n > 0
    
    Time: O(min(n, d))
    Space: O(1)
    
    Args:
        n: Number of variables
        d: Degree bound (strict)
    
    Returns:
        Dimension of the bounded-degree polynomial space
    
    Examples:
        >>> bounded_degree_dimension(2, 3)  # 1, x, y, x², xy, y²
        6
        >>> bounded_degree_dimension(3, 2)  # 1, x, y, z
        4
    """
    if d == 0:
        return 0
    if n == 0:
        return 1  # Only the constant
    return comb(d + n - 1, n)


def homogeneous_dimension(n: int, m: int) -> int:
    """Compute dim of degree-m homogeneous component of K[x_1,...,x_n].
    
    Formula: C(m + n - 1, n - 1) for n >= 1
    
    Time: O(min(n, m))
    Space: O(1)
    
    Args:
        n: Number of variables (must be >= 1)
        m: Exact degree
    
    Returns:
        Dimension of the homogeneous component
    """
    if n == 0:
        return 1 if m == 0 else 0
    return comb(m + n - 1, n - 1)


def enumerate_exponent_vectors(n: int, d: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate all exponent vectors (e_1,...,e_n) with sum < d.
    
    Generates in graded lexicographic order.
    
    Time: O(output_size)
    Space: O(n) stack depth
    
    Args:
        n: Number of variables
        d: Degree bound (strict)
    
    Yields:
        Tuples (e_1,...,e_n) with e_1 + ... + e_n < d
    """
    if n == 0:
        if d > 0:
            yield ()
        return
    
    def _generate(remaining: int, budget: int, prefix: list):
        if remaining == 0:
            yield tuple(prefix)
            return
        for e in range(budget + 1):
            prefix.append(e)
            yield from _generate(remaining - 1, budget - e, prefix)
            prefix.pop()
    
    for total_deg in range(d):
        yield from _generate(n, total_deg, [])


def enumerate_homogeneous(n: int, m: int) -> Iterator[Tuple[int, ...]]:
    """Enumerate exponent vectors with sum exactly m."""
    if n == 0:
        if m == 0:
            yield ()
        return
    if n == 1:
        yield (m,)
        return
    for e in range(m + 1):
        for rest in enumerate_homogeneous(n - 1, m - e):
            yield (e,) + rest


def monomial_to_string(exponents: Tuple[int, ...], variables: str = "xyzwvut") -> str:
    """Convert an exponent vector to a monomial string.
    
    Args:
        exponents: Tuple of non-negative integer exponents
        variables: Variable names to use
    
    Returns:
        String representation like "x²yz³"
    """
    if all(e == 0 for e in exponents):
        return "1"
    
    superscripts = str.maketrans("0123456789", "⁰¹²³⁴⁵⁶⁷⁸⁹")
    parts = []
    for i, e in enumerate(exponents):
        if e == 0:
            continue
        var = variables[i] if i < len(variables) else f"x_{i}"
        if e == 1:
            parts.append(var)
        else:
            parts.append(f"{var}{str(e).translate(superscripts)}")
    return "".join(parts)


def construct_vandermonde(points: np.ndarray, d: int) -> np.ndarray:
    """Construct the generalized Vandermonde matrix for bounded-degree polys.
    
    Given N points in R^n, constructs the N × M matrix where M = C(d+n-1, n)
    and each column corresponds to evaluating a monomial of degree < d.
    
    This is the design matrix for polynomial regression / interpolation.
    
    Time: O(N * M)
    Space: O(N * M)
    
    Args:
        points: Array of shape (N, n) with evaluation points
        d: Degree bound (strict)
    
    Returns:
        Vandermonde matrix of shape (N, M)
    """
    N, n = points.shape
    exponents = list(enumerate_exponent_vectors(n, d))
    M = len(exponents)
    
    V = np.ones((N, M))
    for j, exp in enumerate(exponents):
        for k in range(n):
            if exp[k] > 0:
                V[:, j] *= points[:, k] ** exp[k]
    
    return V


def polynomial_interpolation_dimension(n: int, d: int) -> dict:
    """Analyze the interpolation problem for bounded-degree polynomials.
    
    A polynomial of degree < d in n variables is determined by its 
    dim = C(d+n-1, n) coefficients. Interpolation requires at least
    dim evaluation points.
    
    Args:
        n: Number of variables
        d: Degree bound
    
    Returns:
        Dictionary with analysis results
    """
    dim = bounded_degree_dimension(n, d)
    
    # Breakdown by degree
    breakdown = {}
    for m in range(d):
        breakdown[m] = homogeneous_dimension(n, m)
    
    return {
        "n_variables": n,
        "degree_bound": d,
        "total_dimension": dim,
        "min_interpolation_points": dim,
        "degree_breakdown": breakdown,
        "growth_rate": f"O(d^{n})" if n > 0 else "O(1)",
    }


def hilbert_function(n: int, m: int) -> int:
    """The Hilbert function of the polynomial ring K[x_1,...,x_n].
    
    H(m) = dim of degree-m homogeneous component = C(m+n-1, n-1).
    
    Args:
        n: Number of variables
        m: Degree
    
    Returns:
        Hilbert function value
    """
    return homogeneous_dimension(n, m)


def hilbert_series_coefficients(n: int, max_degree: int) -> List[int]:
    """Compute coefficients of the Hilbert series up to given degree.
    
    The Hilbert series of K[x_1,...,x_n] is 1/(1-t)^n = ∑ H(m) t^m.
    
    Args:
        n: Number of variables
        max_degree: Maximum degree to compute
    
    Returns:
        List [H(0), H(1), ..., H(max_degree)]
    """
    return [hilbert_function(n, m) for m in range(max_degree + 1)]


if __name__ == "__main__":
    # Demo
    print("Bounded-degree polynomial dimension analysis")
    print("=" * 50)
    
    for n in [2, 3, 5, 10]:
        for d in [3, 5, 10]:
            info = polynomial_interpolation_dimension(n, d)
            print(f"\nn={n} variables, degree < {d}:")
            print(f"  Dimension: {info['total_dimension']}")
            print(f"  Min interpolation points: {info['min_interpolation_points']}")
            print(f"  Growth rate: {info['growth_rate']}")
    
    # Hilbert series demo
    print("\n\nHilbert series coefficients for K[x,y,z]:")
    coeffs = hilbert_series_coefficients(3, 10)
    print(f"  H(m) = {coeffs}")
    print(f"  These are triangular numbers: 1, 3, 6, 10, 15, ...")
    
    # Vandermonde matrix demo
    print("\n\nVandermonde matrix for 2D quadratic interpolation:")
    points = np.array([[0, 0], [1, 0], [0, 1], [1, 1], [2, 0], [0, 2]], dtype=float)
    V = construct_vandermonde(points, 3)
    print(f"  Points: {points.tolist()}")
    print(f"  Matrix shape: {V.shape}")
    print(f"  Rank: {np.linalg.matrix_rank(V)}")
    print(f"  Expected dimension: {bounded_degree_dimension(2, 3)}")
