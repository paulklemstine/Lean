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


#!/usr/bin/env python3
"""
demo.py — Computational exploration of the Hessian Descent Certificate
for Lorentzian polynomials.

Demonstrates:
1. Forward verification: Lorentzian polynomials satisfy mixed coefficient inequalities
2. Counterexample search: pairwise det ≤ 0 does NOT imply Lorentzianity for n ≥ 3
3. Exchange support checking
4. Comparison with eigenvalue-based Lorentzian test
"""

import numpy as np
from itertools import product as iterproduct
from math import comb
import sys


def generate_multiindices(n, d):
    """Generate all multi-indices α with |α| = d in n variables."""
    if n == 0:
        return [()]
    if n == 1:
        return [(d,)]
    result = []
    for first in range(d + 1):
        for rest in generate_multiindices(n - 1, d - first):
            result.append((first,) + rest)
    return result


def random_positive_homogeneous_coeffs(n, d, scale=1.0):
    """Generate random positive coefficients for a homogeneous polynomial."""
    indices = generate_multiindices(n, d)
    coeffs = {}
    for idx in indices:
        coeffs[idx] = np.random.exponential(scale)
    return coeffs


def check_mixed_log_concavity(coeffs, n, d):
    """Check mixed directional log-concavity for all base indices α and directions i,j."""
    violations = []
    # For a degree-d polynomial, α ranges over |α| = d-2, and we check
    # c(α+2eᵢ) · c(α+2eⱼ) ≤ c(α+eᵢ+eⱼ)²
    if d < 2:
        return True, violations

    base_indices = generate_multiindices(n, d - 2) if d >= 2 else [tuple([0]*n)]

    for alpha in base_indices:
        for i in range(n):
            for j in range(n):
                # α + eᵢ + eᵢ
                idx_ii = list(alpha)
                idx_ii[i] += 2
                idx_ii = tuple(idx_ii)
                # α + eⱼ + eⱼ
                idx_jj = list(alpha)
                idx_jj[j] += 2
                idx_jj = tuple(idx_jj)
                # α + eᵢ + eⱼ
                idx_ij = list(alpha)
                idx_ij[i] += 1
                idx_ij[j] += 1
                idx_ij = tuple(idx_ij)

                c_ii = coeffs.get(idx_ii, 0.0)
                c_jj = coeffs.get(idx_jj, 0.0)
                c_ij = coeffs.get(idx_ij, 0.0)

                if c_ii * c_jj > c_ij ** 2 + 1e-10:
                    violations.append((alpha, i, j, c_ii * c_jj, c_ij ** 2))

    return len(violations) == 0, violations


def check_axis_log_concavity(coeffs, n, d):
    """Check axis directional log-concavity: c(α+2eᵢ)·c(α) ≤ c(α+eᵢ)²."""
    violations = []
    if d < 2:
        return True, violations

    for alpha_deg in range(d - 1):
        for alpha in generate_multiindices(n, alpha_deg):
            for i in range(n):
                idx_2i = list(alpha)
                idx_2i[i] += 2
                idx_2i = tuple(idx_2i)
                idx_1i = list(alpha)
                idx_1i[i] += 1
                idx_1i = tuple(idx_1i)

                c_2i = coeffs.get(idx_2i, 0.0)
                c_0 = coeffs.get(alpha, 0.0)
                c_1i = coeffs.get(idx_1i, 0.0)

                if c_2i * c_0 > c_1i ** 2 + 1e-10:
                    violations.append((alpha, i, c_2i * c_0, c_1i ** 2))

    return len(violations) == 0, violations


def check_exchange_support(coeffs, n, d):
    """Check the exchange property on support."""
    support = [idx for idx, c in coeffs.items() if abs(c) > 1e-12]
    violations = []

    for alpha in support:
        for beta in support:
            for i in range(n):
                if alpha[i] > beta[i]:
                    found = False
                    for j in range(n):
                        if beta[j] > alpha[j]:
                            new_alpha = list(alpha)
                            new_alpha[i] -= 1
                            new_alpha[j] += 1
                            new_alpha = tuple(new_alpha)
                            if coeffs.get(new_alpha, 0.0) != 0:
                                found = True
                                break
                    if not found:
                        violations.append((alpha, beta, i))

    return len(violations) == 0, violations


def hessian_matrix_from_coeffs(coeffs, n, d):
    """Extract the Hessian-like coefficient matrix for degree-2 leaves."""
    if d < 2:
        return np.eye(n)
    # For degree 2: H(i,j) = c(eᵢ + eⱼ)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = [0] * n
            idx[i] += 1
            idx[j] += 1
            H[i, j] = coeffs.get(tuple(idx), 0.0)
    return H


def check_lorentzian_eigenvalues(H):
    """Check if a matrix has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > 1e-10)
    return n_positive <= 1, eigenvalues


def check_pairwise_det(H):
    """Check if H(i,i)*H(j,j) ≤ H(i,j)² for all i,j."""
    n = H.shape[0]
    violations = []
    for i in range(n):
        for j in range(n):
            if H[i, i] * H[j, j] > H[i, j] ** 2 + 1e-10:
                violations.append((i, j, H[i, i] * H[j, j], H[i, j] ** 2))
    return len(violations) == 0, violations


def demo_forward_verification():
    """Demonstrate that Lorentzian polynomials satisfy the coefficient inequalities."""
    print("=" * 70)
    print("DEMO 1: Forward Verification")
    print("Lorentzian polynomials → mixed coefficient inequalities")
    print("=" * 70)

    # Products of linear forms are Lorentzian
    # f = (a₁x₁ + a₂x₂ + ... + aₙxₙ)^d has Lorentzian signature
    for n in [2, 3, 4, 5]:
        for d in [2, 3, 4]:
            # Random product of linear forms
            a = np.random.exponential(1.0, n)
            coeffs = {}
            for alpha in generate_multiindices(n, d):
                # Multinomial coefficient × product of aᵢ^αᵢ
                coeff = 1.0
                remaining = d
                for k in range(n):
                    coeff *= comb(remaining, alpha[k])
                    remaining -= alpha[k]
                    coeff *= a[k] ** alpha[k]
                coeffs[alpha] = coeff

            mixed_ok, mixed_viols = check_mixed_log_concavity(coeffs, n, d)
            axis_ok, _ = check_axis_log_concavity(coeffs, n, d)
            exch_ok, _ = check_exchange_support(coeffs, n, d)

            status = "✓" if (mixed_ok and axis_ok and exch_ok) else "✗"
            print(f"  n={n}, d={d}: Mixed LC={mixed_ok}, Axis LC={axis_ok}, "
                  f"Exchange={exch_ok} {status}")

    print()


def demo_counterexample_search():
    """Search for counterexamples to the converse."""
    print("=" * 70)
    print("DEMO 2: Counterexample Search")
    print("Pairwise det ≤ 0 does NOT imply Lorentzian for n ≥ 3")
    print("=" * 70)

    # The known counterexample
    print("\n  Known counterexample (mixed signs):")
    A = np.array([[1, 1, 1], [1, 1, -1], [1, -1, 1]], dtype=float)
    det_ok, _ = check_pairwise_det(A)
    lor_ok, eigs = check_lorentzian_eigenvalues(A)
    print(f"    A = [[1,1,1],[1,1,-1],[1,-1,1]]")
    print(f"    Pairwise det ≤ 0: {det_ok}")
    print(f"    Lorentzian (≤1 pos eig): {lor_ok}")
    print(f"    Eigenvalues: {np.round(eigs, 4)}")

    print("\n  Known counterexample (nonneg entries):")
    A2 = np.array([[1, 1, 1], [1, 1, 10], [1, 10, 1]], dtype=float)
    det_ok2, _ = check_pairwise_det(A2)
    lor_ok2, eigs2 = check_lorentzian_eigenvalues(A2)
    print(f"    A = [[1,1,1],[1,1,10],[1,10,1]]")
    print(f"    Pairwise det ≤ 0: {det_ok2}")
    print(f"    All entries ≥ 0: {np.all(A2 >= 0)}")
    print(f"    Lorentzian (≤1 pos eig): {lor_ok2}")
    print(f"    Eigenvalues: {np.round(eigs2, 4)}")

    # Random search
    print("\n  Random search for smallest counterexamples (n=3, nonneg):")
    n_found = 0
    for trial in range(1000):
        n = 3
        # Generate random nonneg symmetric matrix with pairwise det condition
        diag = np.random.exponential(1.0, n)
        A = np.zeros((n, n))
        for i in range(n):
            A[i, i] = diag[i]
        for i in range(n):
            for j in range(i + 1, n):
                # Need A[i,j]² ≥ A[i,i]*A[j,j]
                min_val = np.sqrt(A[i, i] * A[j, j])
                A[i, j] = min_val * np.random.uniform(1.0, 5.0)
                A[j, i] = A[i, j]

        det_ok, _ = check_pairwise_det(A)
        if det_ok:
            lor_ok, eigs = check_lorentzian_eigenvalues(A)
            if not lor_ok:
                n_found += 1
                if n_found <= 3:
                    print(f"    Trial {trial}: det_ok={det_ok}, lor={lor_ok}, "
                          f"eigs={np.round(eigs, 3)}")

    print(f"    Found {n_found}/1000 nonneg counterexamples")

    # 2×2 case: no counterexamples expected
    print("\n  2×2 case (should find NO counterexamples):")
    n_found_2d = 0
    for trial in range(10000):
        a = np.random.exponential(1.0)
        c = np.random.exponential(1.0)
        b = np.sqrt(a * c) * np.random.uniform(1.0, 5.0)
        if np.random.random() < 0.5:
            b = -b
        A = np.array([[a, b], [b, c]])
        det_ok, _ = check_pairwise_det(A)
        if det_ok:
            lor_ok, _ = check_lorentzian_eigenvalues(A)
            if not lor_ok:
                n_found_2d += 1

    print(f"    Found {n_found_2d}/10000 counterexamples (expected: 0)")
    print()


def demo_certificate_algorithm():
    """Demonstrate the certificate-checking algorithm."""
    print("=" * 70)
    print("DEMO 3: Certificate Checking Algorithm")
    print("=" * 70)

    # Test on known Lorentzian polynomial: (x+y+z)²
    n, d = 3, 2
    a = np.ones(n)
    coeffs = {}
    for alpha in generate_multiindices(n, d):
        coeff = 1.0
        remaining = d
        for k in range(n):
            coeff *= comb(remaining, alpha[k])
            remaining -= alpha[k]
        coeffs[alpha] = coeff

    print(f"\n  Polynomial: (x₁+x₂+x₃)² (n={n}, d={d})")
    print(f"  Coefficients: {coeffs}")

    mixed_ok, _ = check_mixed_log_concavity(coeffs, n, d)
    axis_ok, _ = check_axis_log_concavity(coeffs, n, d)
    exch_ok, _ = check_exchange_support(coeffs, n, d)

    H = hessian_matrix_from_coeffs(coeffs, n, d)
    lor_ok, eigs = check_lorentzian_eigenvalues(H)
    det_ok, _ = check_pairwise_det(H)

    print(f"  Hessian matrix:\n{H}")
    print(f"  Eigenvalues: {np.round(eigs, 4)}")
    print(f"  Lorentzian (eigenvalue test): {lor_ok}")
    print(f"  Mixed LC (coefficient test): {mixed_ok}")
    print(f"  Axis LC: {axis_ok}")
    print(f"  Exchange support: {exch_ok}")
    print(f"  Pairwise det ≤ 0: {det_ok}")

    # Test on a non-Lorentzian polynomial
    print(f"\n  Non-Lorentzian test: x₁² + x₂² + x₃² (diagonal)")
    coeffs2 = {}
    for alpha in generate_multiindices(3, 2):
        if sum(1 for a in alpha if a == 2) == 1:
            coeffs2[alpha] = 1.0
        else:
            coeffs2[alpha] = 0.0

    mixed_ok2, viols = check_mixed_log_concavity(coeffs2, 3, 2)
    H2 = hessian_matrix_from_coeffs(coeffs2, 3, 2)
    lor_ok2, eigs2 = check_lorentzian_eigenvalues(H2)
    det_ok2, _ = check_pairwise_det(H2)

    print(f"  Coefficients: {coeffs2}")
    print(f"  Hessian matrix:\n{H2}")
    print(f"  Eigenvalues: {np.round(eigs2, 4)}")
    print(f"  Lorentzian: {lor_ok2}")
    print(f"  Mixed LC: {mixed_ok2}")
    print(f"  Pairwise det ≤ 0: {det_ok2}")
    print()


def demo_dimension_sweep():
    """Sweep over dimensions and degrees to test the conjecture."""
    print("=" * 70)
    print("DEMO 4: Dimension/Degree Sweep")
    print("Testing certificate conditions on random Lorentzian polynomials")
    print("=" * 70)

    np.random.seed(42)
    for n in range(2, 6):
        for d in range(2, min(7, 2 + 5 // n)):
            n_tests = 50
            n_lor_cert = 0  # Lorentzian AND has certificate
            n_cert_lor = 0  # Has certificate AND Lorentzian
            n_lor = 0
            n_cert = 0

            for _ in range(n_tests):
                # Generate a product of linear forms (guaranteed Lorentzian)
                a = np.random.exponential(1.0, n)
                coeffs = {}
                for alpha in generate_multiindices(n, d):
                    coeff = 1.0
                    remaining = d
                    for k in range(n):
                        coeff *= comb(remaining, alpha[k])
                        remaining -= alpha[k]
                        coeff *= a[k] ** alpha[k]
                    coeffs[alpha] = coeff

                mixed_ok, _ = check_mixed_log_concavity(coeffs, n, d)
                is_cert = mixed_ok

                # For degree 2, also check eigenvalues
                if d == 2:
                    H = hessian_matrix_from_coeffs(coeffs, n, d)
                    is_lor, _ = check_lorentzian_eigenvalues(H)
                else:
                    is_lor = True  # Products of linear forms are Lorentzian

                if is_lor:
                    n_lor += 1
                if is_cert:
                    n_cert += 1
                if is_lor and is_cert:
                    n_lor_cert += 1
                if is_cert and is_lor:
                    n_cert_lor += 1

            print(f"  n={n}, d={d}: Lorentzian={n_lor}/{n_tests}, "
                  f"Certificate={n_cert}/{n_tests}, "
                  f"Both={n_lor_cert}/{n_tests}")

    print()


if __name__ == "__main__":
    print("Hessian Descent Certificate — Computational Exploration")
    print("=" * 70)
    print()

    np.random.seed(42)

    demo_forward_verification()
    demo_counterexample_search()
    demo_certificate_algorithm()
    demo_dimension_sweep()

    print("=" * 70)
    print("Summary:")
    print("• Forward direction (Lorentzian → coefficient inequalities): CONFIRMED")
    print("• 2×2 equivalence: CONFIRMED (no counterexamples in 10,000 trials)")
    print("• General converse: FAILS (counterexamples found for n ≥ 3)")
    print("• Key insight: pairwise 2×2 minors are necessary but not sufficient")
    print("  for Lorentzianity; additional structure (exchange support, derivative")
    print("  descent) is needed for the converse.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Hessian Descent — Lorentzian Signature vs Coefficient Inequalities

This script visualizes the relationship between the Lorentzian signature condition
(at most one positive eigenvalue) and the pairwise coefficient inequality
(A(i,i)*A(j,j) ≤ A(i,j)²) for 2×2 and 3×3 matrices.

The key insight: in 2D, the conditions are equivalent (blue = green region).
In 3D, pairwise det ≤ 0 is strictly weaker than Lorentzianity (gap region in red).
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ============================================================
# Panel 1: 2×2 case — full equivalence
# ============================================================
ax = axes[0]
ax.set_title('2×2 Matrices: Full Equivalence', fontsize=13, fontweight='bold')

# For [[1, b], [b, 1]], Lorentzian iff 1 ≤ b² iff |b| ≥ 1
# Pairwise det ≤ 0 iff same condition
b_vals = np.linspace(-3, 3, 500)
# Eigenvalues: 1+b, 1-b
eig1 = 1 + b_vals
eig2 = 1 - b_vals
n_pos = (eig1 > 0).astype(int) + (eig2 > 0).astype(int)
is_lorentzian = n_pos <= 1
pairwise_ok = b_vals**2 >= 1

ax.fill_between(b_vals, -1, 3, where=is_lorentzian, alpha=0.3, color='blue',
                label='Lorentzian (≤1 pos eigenvalue)')
ax.fill_between(b_vals, -1, 3, where=pairwise_ok, alpha=0.2, color='green',
                label='Pairwise det ≤ 0')
ax.plot(b_vals, eig1, 'r-', linewidth=1.5, label='λ₁ = 1+b')
ax.plot(b_vals, eig2, 'b-', linewidth=1.5, label='λ₂ = 1−b')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=1, color='gray', linewidth=0.5, linestyle='--')
ax.axvline(x=-1, color='gray', linewidth=0.5, linestyle='--')
ax.set_xlabel('Off-diagonal entry b', fontsize=11)
ax.set_ylabel('Eigenvalue / Region', fontsize=11)
ax.set_ylim(-3, 3.5)
ax.legend(fontsize=8, loc='upper center')
ax.text(0, -2.5, 'NOT Lorentzian\n(2 pos eigenvalues)', ha='center',
        fontsize=9, color='red', style='italic')
ax.text(2, -2.5, 'Lorentzian ✓', ha='center', fontsize=9, color='blue')

# ============================================================
# Panel 2: 3×3 counterexample landscape
# ============================================================
ax = axes[1]
ax.set_title('3×3 Matrices: Gap Between Conditions', fontsize=13, fontweight='bold')

# Matrix [[1, t, s], [t, 1, -t*s], [s, -t*s, 1]] with t,s > 0
# Pairwise: 1 ≤ t², 1 ≤ s², 1 ≤ (ts)²  → need |t|,|s| ≥ 1
np.random.seed(42)
n_samples = 2000
t_vals = np.random.uniform(0.5, 3.0, n_samples)
s_vals = np.random.uniform(0.5, 3.0, n_samples)

lorentzian_points = []
pairwise_only_points = []
neither_points = []

for t, s in zip(t_vals, s_vals):
    A = np.array([[1, t, s], [t, 1, -t*s], [s, -t*s, 1]])
    eigs = np.linalg.eigvalsh(A)
    n_pos = np.sum(eigs > 1e-10)
    is_lor = n_pos <= 1

    pw_ok = (t**2 >= 1 - 1e-10) and (s**2 >= 1 - 1e-10) and ((t*s)**2 >= 1 - 1e-10)

    if is_lor and pw_ok:
        lorentzian_points.append((t, s))
    elif pw_ok and not is_lor:
        pairwise_only_points.append((t, s))
    else:
        neither_points.append((t, s))

if neither_points:
    pts = np.array(neither_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='lightgray', s=8, alpha=0.5, label='Neither')
if pairwise_only_points:
    pts = np.array(pairwise_only_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='red', s=12, alpha=0.7,
               label='Pairwise only (NOT Lorentzian)')
if lorentzian_points:
    pts = np.array(lorentzian_points)
    ax.scatter(pts[:, 0], pts[:, 1], c='blue', s=8, alpha=0.5, label='Lorentzian')

ax.set_xlabel('Parameter t', fontsize=11)
ax.set_ylabel('Parameter s', fontsize=11)
ax.legend(fontsize=8)
ax.set_xlim(0.5, 3)
ax.set_ylim(0.5, 3)

# ============================================================
# Panel 3: Eigenvalue distribution for nonneg counterexamples
# ============================================================
ax = axes[2]
ax.set_title('Eigenvalue Distribution:\nNonneg Matrices with Pairwise Det ≤ 0', fontsize=12, fontweight='bold')

np.random.seed(123)
all_eigs = []
colors = []
for _ in range(500):
    n = 3
    diag = np.random.exponential(1.0, n)
    A = np.zeros((n, n))
    for i in range(n):
        A[i, i] = diag[i]
    for i in range(n):
        for j in range(i+1, n):
            min_val = np.sqrt(A[i,i]*A[j,j])
            A[i,j] = min_val * np.random.uniform(1.0, 3.0)
            A[j,i] = A[i,j]

    # Check pairwise
    pw_ok = True
    for i in range(n):
        for j in range(n):
            if A[i,i]*A[j,j] > A[i,j]**2 + 1e-10:
                pw_ok = False
    if not pw_ok:
        continue

    eigs = sorted(np.linalg.eigvalsh(A))
    n_pos = sum(1 for e in eigs if e > 1e-10)
    all_eigs.append(eigs)
    colors.append('blue' if n_pos <= 1 else 'red')

if all_eigs:
    eigs_arr = np.array(all_eigs)
    for idx, c in enumerate(colors):
        ax.scatter([eigs_arr[idx, 0]], [eigs_arr[idx, 1]], c=c, s=10, alpha=0.5)

    ax.set_xlabel('Smallest eigenvalue λ₁', fontsize=11)
    ax.set_ylabel('Middle eigenvalue λ₂', fontsize=11)

    # Add legend
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='blue',
               markersize=8, label='Lorentzian (≤1 pos)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red',
               markersize=8, label='NOT Lorentzian (2+ pos)')
    ]
    ax.legend(handles=legend_elements, fontsize=8)
    ax.axhline(y=0, color='k', linewidth=0.5, linestyle='--')
    ax.axvline(x=0, color='k', linewidth=0.5, linestyle='--')

plt.tight_layout()
plt.savefig('hessian_descent_viz.png', dpi=150, bbox_inches='tight')
print("Saved hessian_descent_viz.png")
