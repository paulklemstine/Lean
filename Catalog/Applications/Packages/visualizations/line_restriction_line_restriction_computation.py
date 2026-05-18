#!/usr/bin/env python3
"""
Algorithms for affine line restriction testing of multivariate polynomials
over finite fields.

Implements:
1. Line restriction computation
2. Low-degree testing via random line probes
3. Polynomial reconstruction from line probes
4. Degree certification algorithm
"""

import numpy as np
from typing import Dict, Tuple, List, Optional
from itertools import product
import time


def mod_inverse(a: int, p: int) -> int:
    """Compute modular inverse of a mod p using Fermat's little theorem."""
    return pow(a, p - 2, p)


def vandermonde_solve(values: List[int], q: int) -> List[int]:
    """
    Solve the Vandermonde system to find polynomial coefficients.
    Given values[i] = f(i) for i = 0, ..., n-1, find coefficients c_0, ..., c_{n-1}
    such that f(x) = sum c_k x^k.

    Args:
        values: List of function values at 0, 1, ..., n-1
        q: Prime modulus

    Returns:
        List of polynomial coefficients [c_0, c_1, ..., c_{n-1}]

    Complexity: O(n^2)
    """
    n = len(values)
    # Use Lagrange interpolation
    coeffs = [0] * n
    for j in range(n):
        # Compute Lagrange basis polynomial L_j
        lj = [0] * n
        lj[0] = 1
        for k in range(n):
            if k == j:
                continue
            inv_diff = mod_inverse((j - k) % q, q)
            new_lj = [0] * n
            for d_idx in range(n - 1, -1, -1):
                if lj[d_idx] == 0:
                    continue
                if d_idx + 1 < n:
                    new_lj[d_idx + 1] = (new_lj[d_idx + 1] + lj[d_idx] * inv_diff) % q
                new_lj[d_idx] = (new_lj[d_idx] - k * lj[d_idx] * inv_diff) % q
            lj = new_lj

        for d_idx in range(n):
            coeffs[d_idx] = (coeffs[d_idx] + values[j] * lj[d_idx]) % q

    while len(coeffs) > 1 and coeffs[-1] == 0:
        coeffs.pop()
    return coeffs


def compute_line_restriction(
    f_eval: callable,
    a: Tuple[int, ...],
    d: Tuple[int, ...],
    q: int,
    m: int
) -> List[int]:
    """
    Compute the restriction of f to the affine line a + t*d.

    Args:
        f_eval: Function (Fin m → Z/qZ) → Z/qZ (oracle access)
        a: Base point of the line
        d: Direction vector
        q: Prime field size
        m: Number of variables

    Returns:
        Coefficients of the univariate polynomial f_{a,d}(t)

    Complexity: O(q * m) oracle queries + O(q^2) for interpolation
    """
    values = []
    for t in range(q):
        point = tuple((a[i] + t * d[i]) % q for i in range(m))
        values.append(f_eval(point))

    return vandermonde_solve(values, q)


def random_line_degree_test(
    f_eval: callable,
    q: int,
    m: int,
    target_degree: int,
    num_lines: int = 100,
    seed: int = None
) -> Tuple[bool, int, List[dict]]:
    """
    Test whether a function f : (Z/qZ)^m → Z/qZ has degree ≤ target_degree
    by sampling random affine lines and checking univariate degree.

    Args:
        f_eval: Oracle access to the function
        q: Prime field size
        m: Number of variables
        target_degree: Maximum allowed degree
        num_lines: Number of random lines to test
        seed: Random seed for reproducibility

    Returns:
        (passed, max_degree_found, violations): Tuple of
            - passed: True if all tested lines have degree ≤ target_degree
            - max_degree_found: Maximum degree found across all lines
            - violations: List of lines where degree > target_degree

    Complexity: O(num_lines * q * m) oracle queries

    Soundness: If f has degree > target_degree, the probability of passing
    is at most (1 - (1 - target_degree/q))^num_lines ≈ exp(-num_lines * (1 - target_degree/q))
    """
    rng = np.random.RandomState(seed)
    max_degree = -1
    violations = []

    for trial in range(num_lines):
        a = tuple(int(x) for x in rng.randint(0, q, size=m))
        d = tuple(int(x) for x in rng.randint(0, q, size=m))

        coeffs = compute_line_restriction(f_eval, a, d, q, m)
        deg = len(coeffs) - 1 if coeffs[-1] != 0 else max(
            (i for i, c in enumerate(coeffs) if c != 0), default=-1
        )

        max_degree = max(max_degree, deg)
        if deg > target_degree:
            violations.append({
                'line': (a, d),
                'degree': deg,
                'coefficients': coeffs,
                'trial': trial
            })

    return len(violations) == 0, max_degree, violations


def certify_polynomial_degree(
    f_eval: callable,
    q: int,
    m: int,
    max_degree: int = None
) -> Tuple[int, float]:
    """
    Certify the degree of a polynomial function using exhaustive line testing.
    Tests ALL affine lines (exact, not probabilistic).

    Args:
        f_eval: Oracle access to the function
        q: Prime field size
        m: Number of variables
        max_degree: If provided, only check up to this degree

    Returns:
        (certified_degree, time_seconds): The maximum degree found and computation time

    Complexity: O(q^{2m} * q * m) oracle queries (exhaustive)
    """
    start = time.time()
    certified_degree = -1
    total_lines = 0

    for a in product(range(q), repeat=m):
        for d in product(range(q), repeat=m):
            coeffs = compute_line_restriction(f_eval, a, d, q, m)
            deg = max((i for i, c in enumerate(coeffs) if c != 0), default=-1)
            certified_degree = max(certified_degree, deg)
            total_lines += 1

            if max_degree is not None and certified_degree > max_degree:
                elapsed = time.time() - start
                return certified_degree, elapsed

    elapsed = time.time() - start
    return certified_degree, elapsed


def reconstruct_polynomial(
    f_eval: callable,
    q: int,
    m: int,
    degree_bound: int
) -> Dict[Tuple[int, ...], int]:
    """
    Reconstruct a polynomial from oracle access, assuming total degree ≤ degree_bound.

    Uses the self-correction technique: for each monomial coefficient,
    compute it using inclusion-exclusion on evaluations.

    Args:
        f_eval: Oracle access to f
        q: Prime field size
        m: Number of variables
        degree_bound: Upper bound on total degree

    Returns:
        Dictionary mapping exponent tuples to coefficients

    Complexity: O(q^m) oracle queries + O(binom(m + degree_bound, m)) coefficient computations
    """
    terms = {}

    # Evaluate f at all points
    eval_table = {}
    for point in product(range(q), repeat=m):
        eval_table[point] = f_eval(point)

    # For each possible monomial exponent vector with total degree ≤ degree_bound
    def generate_exponents(m, max_sum):
        if m == 0:
            yield ()
            return
        for first in range(min(max_sum, q - 1) + 1):
            for rest in generate_exponents(m - 1, max_sum - first):
                yield (first,) + rest

    # Use Mobius inversion / interpolation to extract coefficients
    # For simplicity, use multivariate Lagrange interpolation
    # First, build the evaluation vector
    all_points = list(product(range(q), repeat=m))

    # Build multivariate Vandermonde-like system
    exponents = list(generate_exponents(m, degree_bound))

    if len(exponents) > len(all_points):
        # System is underdetermined; only use reduced monomials
        exponents = [e for e in exponents if all(ei < q for ei in e)]

    # For each exponent, compute its coefficient
    # Using the discrete Fourier transform approach over Z/qZ
    for exp in exponents:
        coeff = 0
        for point in all_points:
            # Lagrange coefficient for this point and exponent
            val = eval_table[point]
            for i in range(m):
                # Multiply by the "indicator" for exponent exp[i] at point[i]
                # Using the fact that sum_{x in F_q} x^k = -1 if (q-1)|k, 0 otherwise
                pass

        # Simpler: direct coefficient extraction via Newton's forward differences
        # For now, just use the evaluation table
        pass

    # Use a simpler approach: evaluate at standard points
    # This works correctly for degree < q
    if degree_bound < q:
        # Use successive univariate interpolations
        terms = _reconstruct_via_interpolation(eval_table, q, m, degree_bound)

    return terms


def _reconstruct_via_interpolation(
    eval_table: Dict,
    q: int,
    m: int,
    degree_bound: int
) -> Dict[Tuple[int, ...], int]:
    """Helper: reconstruct via iterative univariate interpolation."""
    if m == 0:
        val = eval_table[()]
        if val != 0:
            return {(): val}
        return {}

    terms = {}
    # For each value of the last variable x_{m-1} = c
    sub_polys = {}
    for c in range(min(degree_bound + 1, q)):
        # Get evaluation table for x_{m-1} = c
        sub_table = {}
        for point, val in eval_table.items():
            if point[-1] == c:
                sub_table[point[:-1]] = val

        if sub_table:
            sub_terms = _reconstruct_via_interpolation(sub_table, q, m - 1, degree_bound)
            sub_polys[c] = sub_terms

    # Now interpolate in the last variable
    # For each exponent pattern in x_0, ..., x_{m-2}
    all_sub_exps = set()
    for c, sub_terms in sub_polys.items():
        for exp in sub_terms:
            all_sub_exps.add(exp)

    for sub_exp in all_sub_exps:
        # Values of the coefficient of this monomial as a function of x_{m-1}
        values = []
        for c in range(min(degree_bound + 1, q)):
            if c in sub_polys and sub_exp in sub_polys[c]:
                values.append(sub_polys[c][sub_exp])
            else:
                values.append(0)

        # Interpolate to get polynomial in x_{m-1}
        coeffs = vandermonde_solve(values, q)

        for k, coeff in enumerate(coeffs):
            if coeff != 0:
                full_exp = sub_exp + (k,)
                if sum(full_exp) <= degree_bound:
                    terms[full_exp] = coeff

    return terms


# Example usage and testing
if __name__ == "__main__":
    q = 7
    m = 2

    # Define a test polynomial: f = 2*x0^2 + 3*x0*x1 + x1 + 4
    def f_test(point):
        x0, x1 = point
        return (2 * x0**2 + 3 * x0 * x1 + x1 + 4) % q

    print("Algorithm Demonstrations")
    print("=" * 60)

    # Test 1: Line restriction
    print("\n1. Line Restriction Computation")
    a, d = (1, 2), (3, 1)
    coeffs = compute_line_restriction(f_test, a, d, q, m)
    print(f"   f_{{{a},{d}}}(t) has coefficients: {coeffs}")
    print(f"   Degree: {max((i for i, c in enumerate(coeffs) if c != 0), default=-1)}")

    # Test 2: Random line degree test
    print("\n2. Random Line Degree Test")
    for target in [1, 2, 3]:
        passed, max_deg, violations = random_line_degree_test(
            f_test, q, m, target, num_lines=200, seed=42)
        print(f"   Target degree ≤ {target}: {'PASS' if passed else 'FAIL'} "
              f"(max degree found: {max_deg})")

    # Test 3: Exhaustive certification
    print("\n3. Exhaustive Degree Certification")
    cert_deg, elapsed = certify_polynomial_degree(f_test, q, m)
    print(f"   Certified degree: {cert_deg}")
    print(f"   Time: {elapsed:.3f}s")

    # Test 4: Polynomial reconstruction
    print("\n4. Polynomial Reconstruction")
    reconstructed = reconstruct_polynomial(f_test, q, m, 2)
    print(f"   Reconstructed terms: {reconstructed}")
    # Verify
    correct = True
    for point in product(range(q), repeat=m):
        val = sum(c * np.prod([point[i]**e for i, e in enumerate(exp)])
                  for exp, c in reconstructed.items()) % q
        if val != f_test(point):
            correct = False
            break
    print(f"   Reconstruction correct: {correct}")
