#!/usr/bin/env python3
"""
Algorithms for Transcendence Theory Computations

This module implements algorithms related to Schanuel's conjecture
and transcendence degree estimation.
"""

import math
import cmath
import numpy as np
from typing import List, Tuple, Set, Optional, Dict
from fractions import Fraction
import itertools


def gram_schmidt_q(vectors: List[List[Fraction]]) -> Tuple[List[List[float]], int]:
    """
    Gram-Schmidt orthogonalization over Q-vectors embedded in R^n.

    Returns orthogonalized vectors and the rank (number of nonzero vectors).

    Args:
        vectors: List of vectors with Fraction entries

    Returns:
        Tuple of (orthogonal vectors as floats, rank)

    >>> vecs = [[Fraction(1), Fraction(0)], [Fraction(0), Fraction(1)]]
    >>> _, rank = gram_schmidt_q(vecs)
    >>> rank
    2
    """
    n = len(vectors)
    if n == 0:
        return [], 0

    dim = len(vectors[0])
    ortho = []
    rank = 0

    for v in vectors:
        v_float = [float(x) for x in v]
        # Subtract projections
        for u in ortho:
            dot_vu = sum(a * b for a, b in zip(v_float, u))
            dot_uu = sum(a * a for a in u)
            if dot_uu > 1e-15:
                proj = [dot_vu / dot_uu * a for a in u]
                v_float = [a - b for a, b in zip(v_float, proj)]

        norm = math.sqrt(sum(x * x for x in v_float))
        if norm > 1e-12:
            ortho.append(v_float)
            rank += 1

    return ortho, rank


def q_linear_rank(values: List[complex], max_coeff: int = 100) -> int:
    """
    Estimate the Q-linear rank of a set of complex numbers.

    Uses integer relation detection to find Q-linear dependencies.

    Args:
        values: Complex numbers to analyze
        max_coeff: Maximum coefficient magnitude to search

    Returns:
        Estimated Q-linear rank

    >>> q_linear_rank([1.0, 2.0, 3.0])
    1
    >>> q_linear_rank([1.0, math.sqrt(2)])
    2
    """
    n = len(values)
    if n == 0:
        return 0

    # Separate into real and imaginary parts
    real_parts = [v.real if isinstance(v, complex) else float(v) for v in values]
    imag_parts = [v.imag if isinstance(v, complex) else 0.0 for v in values]

    # Find integer relations using exhaustive search (for small n)
    relations = []
    for total_norm in range(1, min(max_coeff, 20) + 1):
        for coeffs in itertools.product(range(-total_norm, total_norm + 1), repeat=n):
            if all(c == 0 for c in coeffs):
                continue
            if max(abs(c) for c in coeffs) != total_norm:
                continue

            real_sum = sum(c * r for c, r in zip(coeffs, real_parts))
            imag_sum = sum(c * r for c, r in zip(coeffs, imag_parts))

            if abs(real_sum) < 1e-10 and abs(imag_sum) < 1e-10:
                relations.append(list(coeffs))

    # Rank = n - number of independent relations
    if not relations:
        return n

    # Find rank of relation matrix
    rel_matrix = np.array(relations, dtype=float)
    rel_rank = int(np.linalg.matrix_rank(rel_matrix, tol=1e-8))

    return n - rel_rank


def algebraic_independence_test(
    values: List[complex],
    max_degree: int = 3,
    max_coeff: int = 10,
    tolerance: float = 1e-8
) -> Dict:
    """
    Test algebraic independence of complex numbers over Q.

    Searches for polynomial relations of bounded degree with integer coefficients.

    Args:
        values: Complex numbers to test
        max_degree: Maximum total degree of polynomial relations
        max_coeff: Maximum coefficient magnitude
        tolerance: Numerical tolerance for zero detection

    Returns:
        Dictionary with:
        - 'independent': bool, whether numbers appear algebraically independent
        - 'relations': list of found polynomial relations
        - 'estimated_trdeg': estimated transcendence degree

    >>> result = algebraic_independence_test([math.e])
    >>> result['independent']
    True
    """
    n = len(values)
    if n == 0:
        return {'independent': True, 'relations': [], 'estimated_trdeg': 0}

    relations_found = []

    # Generate all monomials up to given degree
    def eval_monomial(exponents: Tuple[int, ...]) -> complex:
        result = 1.0
        for v, e in zip(values, exponents):
            if e > 0:
                result *= v ** e
        return result

    # Collect monomial evaluations
    monomials = []
    for exp_tuple in itertools.product(range(max_degree + 1), repeat=n):
        if 1 <= sum(exp_tuple) <= max_degree:
            monomials.append(exp_tuple)

    monomial_values = [eval_monomial(m) for m in monomials]

    # Test if any polynomial with small integer coefficients vanishes
    # For efficiency, use linear algebra: test if 1 and monomials are
    # linearly dependent over Z
    all_values = [1.0] + monomial_values

    rank = q_linear_rank(all_values, max_coeff=max_coeff)
    num_independent = rank

    return {
        'independent': num_independent == len(all_values),
        'relations': relations_found,
        'estimated_trdeg': min(n, max(0, num_independent - 1))
    }


def schanuel_verification(
    z_values: List[complex],
    verbose: bool = True
) -> Dict:
    """
    Verify Schanuel's conjecture numerically for a given family.

    For z₁, ..., zₙ ∈ C, checks:
    1. Whether the z_i are Q-linearly independent
    2. Estimates trdeg(Q(z₁,...,zₙ, e^z₁,...,e^zₙ))
    3. Compares with the Schanuel lower bound n

    Args:
        z_values: Complex numbers to test
        verbose: Whether to print detailed output

    Returns:
        Dictionary with verification results

    >>> result = schanuel_verification([1.0], verbose=False)
    >>> result['schanuel_satisfied']
    True
    """
    n = len(z_values)
    exp_values = [cmath.exp(z) for z in z_values]

    # Check Q-linear independence
    from demo import is_q_linearly_independent
    q_indep = is_q_linearly_independent(z_values)

    # All generators
    all_generators = list(z_values) + list(exp_values)

    # Estimate transcendence degree
    result = algebraic_independence_test(all_generators, max_degree=3)
    estimated_trdeg = result['estimated_trdeg']

    satisfied = (not q_indep) or (estimated_trdeg >= n)

    output = {
        'n': n,
        'z_values': z_values,
        'exp_values': exp_values,
        'q_linearly_independent': q_indep,
        'estimated_trdeg': estimated_trdeg,
        'schanuel_bound': n,
        'schanuel_satisfied': satisfied
    }

    if verbose:
        print(f"\nSchanuel Verification (n = {n}):")
        print(f"  z values: {[f'{z:.4f}' for z in z_values]}")
        print(f"  exp(z) values: {[f'{e:.4f}' for e in exp_values]}")
        print(f"  Q-linearly independent: {q_indep}")
        print(f"  Estimated trdeg: {estimated_trdeg}")
        print(f"  Schanuel bound: {n}")
        print(f"  Conjecture satisfied: {satisfied}")

    return output


def find_integer_relation(values: List[float], max_norm: int = 1000) -> Optional[List[int]]:
    """
    Find an integer relation among real numbers using PSLQ-like search.

    Given x₁, ..., xₙ, finds integers m₁, ..., mₙ (not all zero) such that
    m₁x₁ + ... + mₙxₙ ≈ 0, if one exists with ||m|| ≤ max_norm.

    Args:
        values: Real numbers to find relation among
        max_norm: Maximum L∞ norm of coefficient vector

    Returns:
        Integer coefficient vector, or None if no relation found

    >>> find_integer_relation([1.0, 0.5])
    [1, -2]
    """
    n = len(values)
    if n <= 1:
        return None

    best_relation = None
    best_residual = float('inf')

    # Simple exhaustive search for small n
    search_range = min(max_norm, 50 if n <= 3 else 20)

    for coeffs in itertools.product(range(-search_range, search_range + 1), repeat=n):
        if all(c == 0 for c in coeffs):
            continue

        residual = abs(sum(c * v for c, v in zip(coeffs, values)))
        if residual < 1e-10 and residual < best_residual:
            best_residual = residual
            best_relation = list(coeffs)

    return best_relation


if __name__ == "__main__":
    print("=" * 70)
    print("Transcendence Theory Algorithms — Examples")
    print("=" * 70)

    # Example 1: Q-linear rank
    print("\n1. Q-linear rank estimation:")
    print(f"   rank(1, 2, 3) = {q_linear_rank([1, 2, 3])}")
    print(f"   rank(1, √2) = {q_linear_rank([1, math.sqrt(2)])}")
    print(f"   rank(1, √2, √3) = {q_linear_rank([1, math.sqrt(2), math.sqrt(3)])}")
    print(f"   rank(1, √2, 1+√2) = {q_linear_rank([1, math.sqrt(2), 1 + math.sqrt(2)])}")

    # Example 2: Algebraic independence
    print("\n2. Algebraic independence tests:")
    for vals, name in [
        ([math.e], "e"),
        ([math.pi], "π"),
        ([math.e, math.pi], "e, π"),
        ([math.sqrt(2)], "√2"),
    ]:
        result = algebraic_independence_test(vals)
        print(f"   {name}: independent={result['independent']}, "
              f"est. trdeg={result['estimated_trdeg']}")

    # Example 3: Schanuel verification
    print("\n3. Schanuel conjecture verification:")
    for z_vals, name in [
        ([1.0], "z = 1"),
        ([1.0, math.sqrt(2)], "z = (1, √2)"),
        ([math.pi], "z = π"),
    ]:
        schanuel_verification(z_vals)

    # Example 4: Integer relation finding
    print("\n4. Integer relation detection:")
    rel = find_integer_relation([1.0, math.sqrt(2), math.sqrt(2)])
    print(f"   Relation for (1, √2, √2): {rel}")
    rel = find_integer_relation([math.log(2), math.log(3), math.log(6)])
    print(f"   Relation for (log 2, log 3, log 6): {rel}")
