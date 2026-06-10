#!/usr/bin/env python3
"""
Algorithms for the Anisotropic Footprint Bound

Implements the core algorithms from the research paper:
1. Footprint bound computation
2. Grid evaluation counting
3. Polynomial reduction modulo coordinate vanishing ideals
4. Affine Cartesian code construction
"""

from typing import Dict, List, Tuple, Set, Optional
from itertools import product
from functools import reduce
import numpy as np


def footprint_bound(grid_sets: List[Set[int]], degree_bounds: List[int]) -> int:
    """
    Compute the anisotropic footprint lower bound.

    Given finite sets S_1, ..., S_n and degree bounds e_1, ..., e_n with e_i < |S_i|,
    returns prod_{i=1}^{n} (|S_i| - e_i).

    Args:
        grid_sets: List of finite sets S_i (one per variable).
        degree_bounds: List of degree bounds e_i (one per variable).

    Returns:
        The footprint lower bound prod(|S_i| - e_i).

    Raises:
        ValueError: If any e_i >= |S_i|.

    >>> footprint_bound([{0,1,2,3}, {0,1,2}], [2, 1])
    4
    """
    n = len(grid_sets)
    if len(degree_bounds) != n:
        raise ValueError("Number of grid sets must match number of degree bounds")

    bound = 1
    for i in range(n):
        si = len(grid_sets[i])
        ei = degree_bounds[i]
        if ei >= si:
            raise ValueError(f"Degree bound e_{i}={ei} must be < |S_{i}|={si}")
        bound *= (si - ei)

    return bound


class MultivariatePolynomial:
    """
    Sparse multivariate polynomial over a finite field GF(p).

    Represented as a dictionary: exponent tuple -> coefficient.

    Attributes:
        coeffs: Dict mapping exponent tuples to nonzero coefficients.
        n_vars: Number of variables.
        prime: Characteristic of the base field (0 for integers).
    """

    def __init__(self, coeffs: Dict[Tuple[int, ...], int], n_vars: int,
                 prime: int = 0):
        """
        Initialize a multivariate polynomial.

        Args:
            coeffs: Dict of {exponent_tuple: coefficient}.
            n_vars: Number of variables.
            prime: Field characteristic (0 for integers/rationals).
        """
        self.n_vars = n_vars
        self.prime = prime
        self.coeffs: Dict[Tuple[int, ...], int] = {}
        for exp, c in coeffs.items():
            if len(exp) != n_vars:
                raise ValueError(f"Exponent tuple {exp} has wrong length")
            c_mod = c % prime if prime > 0 else c
            if c_mod != 0:
                self.coeffs[exp] = c_mod

    def evaluate(self, point: Tuple[int, ...]) -> int:
        """
        Evaluate the polynomial at a point.

        Args:
            point: Tuple of field element values.

        Returns:
            The evaluation f(point), reduced modulo prime if applicable.

        >>> p = MultivariatePolynomial({(1,0): 1, (0,1): 1}, 2, 5)
        >>> p.evaluate((2, 3))
        0
        """
        val = 0
        for exp, c in self.coeffs.items():
            term = c
            for i in range(self.n_vars):
                term *= point[i] ** exp[i]
            val += term
        return val % self.prime if self.prime > 0 else val

    def degree_of(self, var_index: int) -> int:
        """
        Get the degree in a specific variable.

        Args:
            var_index: Index of the variable (0-indexed).

        Returns:
            Maximum exponent of var_index across all monomials.

        >>> p = MultivariatePolynomial({(2,1): 1, (0,3): 1}, 2)
        >>> p.degree_of(0)
        2
        """
        if not self.coeffs:
            return 0
        return max(exp[var_index] for exp in self.coeffs)

    def degree_bounds(self) -> List[int]:
        """Get degree bounds for each variable."""
        return [self.degree_of(i) for i in range(self.n_vars)]

    def is_reduced_on_grid(self, grid_sets: List[Set[int]]) -> bool:
        """
        Check if the polynomial is reduced on the given grid.

        A polynomial is reduced on grid S if every monomial's exponent
        in variable i is strictly less than |S_i|.

        Args:
            grid_sets: List of finite sets S_i.

        Returns:
            True if the polynomial is reduced.

        >>> p = MultivariatePolynomial({(1,2): 1}, 2)
        >>> p.is_reduced_on_grid([{0,1,2}, {0,1,2,3}])
        True
        """
        for exp in self.coeffs:
            for i, e in enumerate(exp):
                if e >= len(grid_sets[i]):
                    return False
        return True

    def is_zero(self) -> bool:
        """Check if the polynomial is zero."""
        return len(self.coeffs) == 0


def count_nonzeros(poly: MultivariatePolynomial,
                   grid_sets: List[Set[int]]) -> Tuple[int, int]:
    """
    Count nonzero evaluations on a finite Cartesian grid.

    Args:
        poly: A multivariate polynomial.
        grid_sets: List of finite sets forming the grid.

    Returns:
        (nonzero_count, total_grid_size)

    Time complexity: O(|grid| * |support(f)|)
    Space complexity: O(|grid|) for storing evaluations.

    >>> p = MultivariatePolynomial({(1,): 1}, 1, 5)
    >>> count_nonzeros(p, [{0,1,2,3,4}])
    (4, 5)
    """
    grid_points = list(product(*[sorted(s) for s in grid_sets]))
    total = len(grid_points)
    nonzero = sum(1 for pt in grid_points if poly.evaluate(pt) != 0)
    return nonzero, total


def verify_footprint_bound(poly: MultivariatePolynomial,
                           grid_sets: List[Set[int]],
                           degree_bounds: Optional[List[int]] = None) -> dict:
    """
    Verify the footprint bound for a given polynomial and grid.

    Args:
        poly: A nonzero multivariate polynomial.
        grid_sets: List of finite sets S_i.
        degree_bounds: Optional explicit degree bounds (defaults to actual degrees).

    Returns:
        Dictionary with verification results.
    """
    if poly.is_zero():
        return {"error": "Polynomial is zero; bound does not apply"}

    if degree_bounds is None:
        degree_bounds = poly.degree_bounds()

    if not poly.is_reduced_on_grid(grid_sets):
        return {"error": "Polynomial is not reduced on grid"}

    for i, (ei, si) in enumerate(zip(degree_bounds, grid_sets)):
        if ei >= len(si):
            return {"error": f"Degree bound e_{i}={ei} >= |S_{i}|={len(si)}"}

    nonzero, total = count_nonzeros(poly, grid_sets)
    bound = footprint_bound(grid_sets, degree_bounds)

    return {
        "polynomial_support_size": len(poly.coeffs),
        "n_variables": poly.n_vars,
        "grid_sizes": [len(s) for s in grid_sets],
        "degree_bounds": degree_bounds,
        "grid_total": total,
        "nonzero_count": nonzero,
        "zero_count": total - nonzero,
        "footprint_bound": bound,
        "bound_satisfied": nonzero >= bound,
        "slack": nonzero - bound,
    }


def reduce_polynomial(poly: MultivariatePolynomial,
                      grid_sets: List[Set[int]]) -> MultivariatePolynomial:
    """
    Reduce a polynomial modulo the coordinate vanishing ideal.

    For each variable x_i with grid S_i, replace x_i^k for k >= |S_i|
    using the relation x_i^{|S_i|} = sum of lower-degree terms
    (derived from the vanishing polynomial prod_{a in S_i}(x_i - a) = 0
    on the grid).

    This is a simplified version that works by repeated evaluation and
    interpolation on the grid.

    Args:
        poly: The polynomial to reduce.
        grid_sets: The grid sets S_i defining the vanishing ideal.

    Returns:
        The reduced polynomial (equivalent on the grid).

    Time complexity: O(|grid| * n * max|S_i|)
    """
    # Reduce by evaluating on the grid and interpolating back
    # This uses the fact that the evaluation map is a bijection
    # between reduced polynomials and functions on the grid.

    grid_points = list(product(*[sorted(s) for s in grid_sets]))
    values = [poly.evaluate(pt) for pt in grid_points]

    # For small grids, build the reduced polynomial by iterating over
    # all reduced monomials and solving the linear system
    max_degs = [len(s) - 1 for s in grid_sets]
    reduced_monomials = list(product(*[range(d + 1) for d in max_degs]))

    n = len(grid_points)
    m = len(reduced_monomials)

    if n != m:
        raise ValueError("Grid size must match number of reduced monomials")

    # Build Vandermonde-like matrix
    A = np.zeros((n, m), dtype=float)
    for i, pt in enumerate(grid_points):
        for j, mon in enumerate(reduced_monomials):
            val = 1
            for k in range(poly.n_vars):
                val *= pt[k] ** mon[k]
            A[i, j] = val

    # Solve for coefficients (over reals, then round)
    coeffs_vec = np.linalg.solve(A, np.array(values, dtype=float))

    result_coeffs = {}
    for j, mon in enumerate(reduced_monomials):
        c = int(round(coeffs_vec[j]))
        if poly.prime > 0:
            c = c % poly.prime
        if c != 0:
            result_coeffs[mon] = c

    return MultivariatePolynomial(result_coeffs, poly.n_vars, poly.prime)


def affine_cartesian_code(grid_sets: List[Set[int]],
                          degree_bounds: List[int],
                          prime: int) -> dict:
    """
    Construct an affine Cartesian evaluation code and compute its parameters.

    The code C(S, e) consists of all evaluation vectors (f(x))_{x in prod S_i}
    where f ranges over polynomials with deg_{x_i}(f) <= e_i.

    Args:
        grid_sets: List of evaluation sets S_i.
        degree_bounds: Maximum degree in each variable.
        prime: Field characteristic.

    Returns:
        Dictionary with code parameters:
        - length: n = |prod S_i|
        - dimension: k = prod(e_i + 1)
        - distance_bound: d >= prod(|S_i| - e_i)
    """
    # Code length
    length = reduce(lambda a, b: a * b, [len(s) for s in grid_sets])

    # Code dimension (number of reduced monomials)
    dimension = reduce(lambda a, b: a * b, [e + 1 for e in degree_bounds])

    # Distance lower bound from footprint theorem
    distance_bound = footprint_bound(grid_sets, degree_bounds)

    # Singleton bound check
    singleton = length - dimension + 1

    return {
        "length": length,
        "dimension": dimension,
        "distance_lower_bound": distance_bound,
        "singleton_bound": singleton,
        "rate": dimension / length,
        "relative_distance_bound": distance_bound / length,
        "grid_sizes": [len(s) for s in grid_sets],
        "degree_bounds": degree_bounds,
        "prime": prime,
    }


if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Basic footprint bound
    S = [{0, 1, 2, 3, 4}, {0, 1, 2}]
    e = [2, 1]
    print(f"Footprint bound for |S|={[len(s) for s in S]}, e={e}: {footprint_bound(S, e)}")

    # 2. Polynomial verification
    p = MultivariatePolynomial({(2, 0): 1, (1, 1): 1, (0, 0): 3}, 2, prime=7)
    result = verify_footprint_bound(p, S, e)
    print(f"\nVerification: {result}")

    # 3. Code parameters
    code = affine_cartesian_code(
        [{0, 1, 2, 3}, {0, 1, 2, 3, 4}],
        [2, 3],
        prime=7
    )
    print(f"\nAffine Cartesian Code: {code}")
