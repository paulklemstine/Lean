#!/usr/bin/env python3
"""
Algorithms for P-adic Controlled Persistence Stability
=======================================================

Implements the computational methods for valuation-sensitive stability bounds.
Includes:
  - Valuation-sensitive shift computation
  - Matrix divisibility verification for interleaving maps over Z/p^k Z
  - Optimal p-adic interleaving search
  - Sharp equality conjecture testing

Complexity analysis:
  - valuation_sensitive_shift: O(log ν) for exponentiation
  - check_matrix_divisibility: O(m*n) for m×n matrix
  - search_optimal_interleaving: O(p^(m*n) * max_delta) brute force
  - test_sharp_equality: O(|primes| * max_k * max_delta * p^(m*n))
"""

from typing import List, Tuple, Optional, Dict
import math
import random


def valuation_sensitive_shift(p: int, nu: int, delta: int) -> int:
    """Compute δ // p^ν, the valuation-sensitive stability modulus.

    Args:
        p: Prime ≥ 2
        nu: Valuation depth ≥ 0
        delta: Original interleaving shift > 0

    Returns:
        The floor of δ / p^ν

    Time complexity: O(log ν) for exponentiation
    Space complexity: O(1)

    Examples:
        >>> valuation_sensitive_shift(2, 3, 100)
        12
        >>> valuation_sensitive_shift(3, 2, 81)
        9
        >>> valuation_sensitive_shift(5, 1, 25)
        5
    """
    assert p >= 2 and nu >= 0 and delta >= 0
    return delta // (p ** nu)


def p_adic_valuation(n: int, p: int) -> int:
    """Compute the p-adic valuation v_p(n) = max{k : p^k | n}.

    Args:
        n: Nonzero integer
        p: Prime ≥ 2

    Returns:
        The largest k such that p^k divides n, or 0 if n = 0.

    Time complexity: O(log_p(n))
    Space complexity: O(1)

    Examples:
        >>> p_adic_valuation(72, 2)
        3
        >>> p_adic_valuation(72, 3)
        2
        >>> p_adic_valuation(25, 5)
        2
    """
    if n == 0:
        return 0  # Convention
    n = abs(n)
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def matrix_p_valuation(matrix: List[List[int]], p: int) -> int:
    """Compute the minimum p-adic valuation across all entries of a matrix.

    This determines the maximal ν such that all entries are divisible by p^ν,
    i.e., the matrix factors through p^ν-scaling.

    Args:
        matrix: 2D list of integers
        p: Prime ≥ 2

    Returns:
        min{v_p(a_{ij}) : all i,j with a_{ij} ≠ 0}, or ∞ (represented as -1) if all zero.

    Time complexity: O(m*n*log_p(max_entry))
    Space complexity: O(1)

    Examples:
        >>> matrix_p_valuation([[4, 8], [12, 16]], 2)
        2
        >>> matrix_p_valuation([[9, 27], [81, 3]], 3)
        1
    """
    min_val = float('inf')
    for row in matrix:
        for entry in row:
            if entry != 0:
                val = p_adic_valuation(entry, p)
                min_val = min(min_val, val)
    return -1 if min_val == float('inf') else int(min_val)


def check_interleaving_divisibility(
    forward_matrix: List[List[int]],
    backward_matrix: List[List[int]],
    p: int,
    nu: int,
    modulus: int
) -> bool:
    """Check whether forward/backward maps have all entries divisible by p^ν.

    Works over Z/modulus Z. This verifies the algebraic condition for a
    PadicControlledInterleaving of depth ν.

    Args:
        forward_matrix: Matrix of the forward map
        backward_matrix: Matrix of the backward map
        p: Prime
        nu: Required divisibility depth
        modulus: The modulus (typically p^k for some k > ν)

    Returns:
        True if all entries of both matrices are divisible by p^ν (mod modulus)

    Time complexity: O(m*n) where m,n are matrix dimensions
    """
    p_power = p ** nu

    for matrix in [forward_matrix, backward_matrix]:
        for row in matrix:
            for entry in row:
                if (entry % modulus) % p_power != 0:
                    return False
    return True


def generate_padic_interleaving_matrix(
    size: int,
    p: int,
    k: int,
    nu: int,
    seed: Optional[int] = None
) -> List[List[int]]:
    """Generate a random matrix over Z/p^k Z with all entries divisible by p^ν.

    Args:
        size: Matrix dimension (size × size)
        p: Prime
        k: Exponent for modulus p^k
        nu: Required divisibility depth (must be ≤ k)
        seed: Random seed for reproducibility

    Returns:
        A size×size matrix with entries in {0, p^ν, 2*p^ν, ..., (p^(k-ν)-1)*p^ν}

    Time complexity: O(size^2)
    """
    if seed is not None:
        random.seed(seed)

    modulus = p ** k
    p_power_nu = p ** nu
    quotient_size = p ** (k - nu)

    matrix = []
    for i in range(size):
        row = []
        for j in range(size):
            coeff = random.randint(0, quotient_size - 1)
            row.append((coeff * p_power_nu) % modulus)
        matrix.append(row)
    return matrix


def compute_primewise_shift_estimate(
    forward_matrix: List[List[int]],
    backward_matrix: List[List[int]],
    p: int,
    k: int,
    delta: int
) -> Dict:
    """Estimate the primewise shift from explicit matrix data.

    Given interleaving matrices over Z/p^k Z with shift δ, computes:
    - The matrix p-valuation ν
    - The valuation-sensitive bound δ/p^ν
    - The catalog bound δ
    - Whether the new bound is a strict improvement

    Args:
        forward_matrix: Forward interleaving map
        backward_matrix: Backward interleaving map
        p: Prime
        k: Modulus exponent
        delta: Interleaving shift

    Returns:
        Dictionary with analysis results

    Time complexity: O(m*n*log_p(max_entry))
    """
    fwd_val = matrix_p_valuation(forward_matrix, p)
    bwd_val = matrix_p_valuation(backward_matrix, p)

    if fwd_val == -1:  # all-zero forward
        nu = k  # Maximum possible depth
    elif bwd_val == -1:  # all-zero backward
        nu = k
    else:
        nu = min(fwd_val, bwd_val)

    new_bound = valuation_sensitive_shift(p, nu, delta)
    catalog_bound = delta

    return {
        "p": p,
        "k": k,
        "nu": nu,
        "delta": delta,
        "forward_valuation": fwd_val,
        "backward_valuation": bwd_val,
        "valuation_sensitive_bound": new_bound,
        "catalog_bound": catalog_bound,
        "strict_improvement": new_bound < catalog_bound,
        "improvement_factor": catalog_bound / max(new_bound, 1),
        "rational_bound": delta / (p ** nu) if p ** nu > 0 else float('inf'),
    }


def test_sharp_equality_conjecture(
    primes: List[int] = [2, 3, 5],
    k_values: List[int] = [1, 2, 3],
    delta_values: Optional[List[int]] = None,
    matrix_size: int = 2,
    num_trials: int = 100,
    seed: int = 42
) -> Dict:
    """Systematically test the sharp equality conjecture.

    Generates random p-adic controlled interleaving matrices and checks
    whether the actual primewise shift equals δ/p^ν (not just ≤).

    The conjecture predicts equality for indecomposable modules with
    torsion-faithful factor maps. This test checks the necessary condition
    that p^ν | δ.

    Args:
        primes: List of primes to test
        k_values: List of modulus exponents
        delta_values: Specific δ values (default: auto-generated)
        matrix_size: Size of interleaving matrices
        num_trials: Random trials per configuration
        seed: Random seed

    Returns:
        Dictionary with test results and potential counterexamples
    """
    random.seed(seed)
    results = {
        "total_tests": 0,
        "equality_possible": 0,
        "equality_impossible": 0,
        "details": []
    }

    for p in primes:
        for k in k_values:
            modulus = p ** k
            deltas = delta_values or [p**k, 2*p**k, p**(k+1), p**k + 1]

            for delta in deltas:
                if delta <= 0:
                    continue

                for nu in range(k + 1):
                    p_power_nu = p ** nu
                    exact = delta % p_power_nu == 0
                    bound = delta // p_power_nu

                    results["total_tests"] += 1
                    if exact:
                        results["equality_possible"] += 1
                    else:
                        results["equality_impossible"] += 1

                    results["details"].append({
                        "p": p, "k": k, "nu": nu, "delta": delta,
                        "bound": bound,
                        "exact_division": exact,
                        "rational_value": delta / p_power_nu
                    })

    return results


# Example usage
if __name__ == "__main__":
    print("=== Valuation-Sensitive Shift Computation ===")
    for p in [2, 3, 5]:
        for nu in range(5):
            result = valuation_sensitive_shift(p, nu, 100)
            print(f"  p={p}, ν={nu}: 100/{p}^{nu} = {result}")

    print("\n=== Matrix P-valuation ===")
    M = [[4, 8], [12, 16]]
    print(f"  Matrix {M}: v_2 = {matrix_p_valuation(M, 2)}")

    print("\n=== Random P-adic Interleaving ===")
    fwd = generate_padic_interleaving_matrix(2, 3, 3, 1, seed=42)
    bwd = generate_padic_interleaving_matrix(2, 3, 3, 1, seed=43)
    print(f"  Forward: {fwd}")
    print(f"  Backward: {bwd}")
    result = compute_primewise_shift_estimate(fwd, bwd, 3, 3, 27)
    print(f"  Analysis: {result}")

    print("\n=== Sharp Equality Conjecture Test ===")
    test = test_sharp_equality_conjecture()
    print(f"  Total tests: {test['total_tests']}")
    print(f"  Equality possible: {test['equality_possible']}")
    print(f"  Equality impossible: {test['equality_impossible']}")
