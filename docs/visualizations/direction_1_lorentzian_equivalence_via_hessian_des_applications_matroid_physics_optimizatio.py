#!/usr/bin/env python3
"""
applications.py — Real-world applications of Hessian Descent theory.

Demonstrates applications to:
1. Matroid theory — checking basis exchange properties
2. Statistical physics — negative dependence in partition functions
3. Optimization — certifying convexity via coefficient tests
"""

import numpy as np
from math import comb, factorial
from typing import Dict, Tuple, List


def generate_multiindices(n, d):
    """Generate all multi-indices with given total degree."""
    if n == 0:
        return [()]
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in generate_multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


# ============================================================
# APPLICATION 1: Matroid Basis Generating Polynomials
# ============================================================

def uniform_matroid_polynomial(n: int, k: int) -> Dict[Tuple[int, ...], float]:
    """Generate the basis generating polynomial of the uniform matroid U(k,n).

    The bases are all k-element subsets of [n]. The polynomial is:
    f = ∑_{|S|=k} ∏_{i∈S} xᵢ

    This is multi-affine (each variable has degree ≤ 1) and homogeneous
    of degree k.

    Args:
        n: Ground set size
        k: Rank

    Returns:
        Coefficient dictionary (multi-indices have entries 0 or 1)
    """
    coeffs = {}
    for alpha in generate_multiindices(n, k):
        if all(a <= 1 for a in alpha):
            coeffs[alpha] = 1.0
        else:
            coeffs[alpha] = 0.0
    return coeffs


def check_matroid_exchange(coeffs, n):
    """Check the symmetric exchange property for matroid basis support."""
    support = [idx for idx, c in coeffs.items() if c > 0]
    support_set = set(support)
    violations = 0
    total_checks = 0

    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] > beta[i]:
                    total_checks += 1
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            new_a = list(alpha)
                            new_a[i] -= 1
                            new_a[j] += 1
                            if tuple(new_a) in support_set:
                                found = True
                                break
                    if not found:
                        violations += 1

    return violations == 0, total_checks, violations


def demo_matroid_application():
    """Demonstrate Hessian descent on matroid polynomials."""
    print("APPLICATION 1: Matroid Basis Generating Polynomials")
    print("-" * 50)

    for n in range(3, 7):
        for k in range(1, n):
            coeffs = uniform_matroid_polynomial(n, k)
            exch_ok, total, viols = check_matroid_exchange(coeffs, n)

            # Check mixed LC
            mixed_violations = 0
            if k >= 2:
                for alpha in generate_multiindices(n, k - 2):
                    if all(a <= 1 for a in alpha) or True:
                        for i in range(n):
                            for j in range(n):
                                idx_ii = list(alpha)
                                idx_ii[i] += 2
                                idx_jj = list(alpha)
                                idx_jj[j] += 2
                                idx_ij = list(alpha)
                                idx_ij[i] += 1
                                idx_ij[j] += 1
                                c_ii = coeffs.get(tuple(idx_ii), 0)
                                c_jj = coeffs.get(tuple(idx_jj), 0)
                                c_ij = coeffs.get(tuple(idx_ij), 0)
                                if c_ii * c_jj > c_ij ** 2 + 1e-10:
                                    mixed_violations += 1

            print(f"  U({k},{n}): exchange={exch_ok}, "
                  f"mixed_LC_violations={mixed_violations}")

    print()


# ============================================================
# APPLICATION 2: Statistical Physics — Partition Functions
# ============================================================

def ising_partition_coefficients(n: int, J: float, h: float = 0) -> Dict:
    """Compute partition function coefficients for the Ising model on a path.

    Z = ∑_σ exp(-H(σ)) where H = -J ∑ σᵢσᵢ₊₁ - h ∑ σᵢ

    Represented as polynomial in variables tracking magnetization.

    Args:
        n: Number of spins
        J: Coupling constant (J > 0 ferromagnetic)
        h: External field

    Returns:
        Coefficients indexed by magnetization m = number of up spins
    """
    coeffs = {}
    for config in range(2 ** n):
        spins = [(config >> i) & 1 for i in range(n)]
        m = sum(spins)
        energy = 0
        for i in range(n - 1):
            s_i = 2 * spins[i] - 1
            s_j = 2 * spins[i + 1] - 1
            energy -= J * s_i * s_j
        for i in range(n):
            energy -= h * (2 * spins[i] - 1)
        weight = np.exp(-energy)
        coeffs[m] = coeffs.get(m, 0) + weight
    return coeffs


def check_1d_log_concavity(seq):
    """Check log-concavity of a positive sequence: a(k)² ≥ a(k-1)a(k+1)."""
    violations = 0
    for k in range(1, len(seq) - 1):
        if seq[k] ** 2 < seq[k - 1] * seq[k + 1] - 1e-10:
            violations += 1
    return violations == 0, violations


def demo_statistical_physics():
    """Demonstrate negative dependence in partition functions."""
    print("APPLICATION 2: Statistical Physics — Partition Functions")
    print("-" * 50)

    for n in [4, 6, 8, 10]:
        for J in [0.5, 1.0, 2.0]:
            coeffs = ising_partition_coefficients(n, J)
            seq = [coeffs.get(m, 0) for m in range(n + 1)]

            lc_ok, lc_viols = check_1d_log_concavity(seq)
            print(f"  n={n}, J={J}: "
                  f"coeffs={[f'{c:.1f}' for c in seq[:5]]}..., "
                  f"log-concave={lc_ok}")

    print()


# ============================================================
# APPLICATION 3: Convexity Certification
# ============================================================

def check_polynomial_lorentzianity(
    coeffs: Dict[Tuple[int, ...], float],
    n: int
) -> Dict:
    """Full diagnostic for polynomial Lorentzianity.

    Checks coefficient inequalities at all levels.

    Args:
        coeffs: Coefficient dictionary
        n: Number of variables

    Returns:
        Diagnostic dictionary
    """
    # Determine degree
    degrees = set(sum(idx) for idx in coeffs.keys())
    if len(degrees) != 1:
        return {'homogeneous': False}

    d = degrees.pop()
    result = {'homogeneous': True, 'degree': d, 'n_vars': n}

    # Check positivity
    all_pos = all(c > 0 for c in coeffs.values() if True)
    result['all_positive'] = all_pos

    # Check mixed LC at each derivative level
    for level in range(d - 1):
        base_deg = d - 2 - level if d >= 2 + level else -1
        if base_deg < 0:
            continue

        violations = 0
        for alpha in generate_multiindices(n, base_deg):
            for i in range(n):
                for j in range(n):
                    idx_ii = list(alpha)
                    idx_ii[i] += 2
                    idx_jj = list(alpha)
                    idx_jj[j] += 2
                    idx_ij = list(alpha)
                    idx_ij[i] += 1
                    idx_ij[j] += 1
                    c_ii = coeffs.get(tuple(idx_ii), 0)
                    c_jj = coeffs.get(tuple(idx_jj), 0)
                    c_ij = coeffs.get(tuple(idx_ij), 0)
                    if c_ii * c_jj > c_ij ** 2 + 1e-10:
                        violations += 1

        result[f'mixed_lc_level_{level}'] = violations == 0

    return result


def demo_convexity_certification():
    """Demonstrate convexity certification via coefficient tests."""
    print("APPLICATION 3: Convexity Certification")
    print("-" * 50)

    # Test various polynomials
    n = 3
    tests = [
        ("(x+y+z)⁴", np.array([1.0, 1.0, 1.0]), 4),
        ("(x+2y+3z)³", np.array([1.0, 2.0, 3.0]), 3),
        ("(x+y+z)²", np.array([1.0, 1.0, 1.0]), 2),
        ("(2x+y+z)⁵", np.array([2.0, 1.0, 1.0]), 5),
    ]

    for name, weights, degree in tests:
        coeffs = {}
        for alpha in generate_multiindices(n, degree):
            coeff = 1.0
            remaining = degree
            for k in range(n):
                coeff *= comb(remaining, alpha[k])
                remaining -= alpha[k]
                coeff *= weights[k] ** alpha[k]
            coeffs[alpha] = coeff

        result = check_polynomial_lorentzianity(coeffs, n)
        print(f"  {name}: {result}")

    print()


if __name__ == "__main__":
    print("Hessian Descent — Applications")
    print("=" * 60)
    print()

    demo_matroid_application()
    demo_statistical_physics()
    demo_convexity_certification()
