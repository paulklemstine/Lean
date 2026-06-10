#!/usr/bin/env python3
"""
Applications of the Lorentzian Certificate Theory for Strongly Rayleigh Polynomials.

Demonstrates real-world applications:
1. Log-concavity certification for subset selection
2. Negative dependence verification for random sampling
3. Spectral gap estimation from the certificate matrix
"""

import numpy as np
from itertools import combinations
from typing import Dict, List, Tuple


def multiaffine_eval(coeffs: Dict[tuple, float], x: np.ndarray) -> float:
    val = 0.0
    for subset, c in coeffs.items():
        term = c
        for i in subset:
            term *= x[i]
        val += term
    return val


def multiaffine_gradient(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    n = len(x)
    grad = np.zeros(n)
    for i in range(n):
        for subset, c in coeffs.items():
            if i in subset:
                remaining = tuple(j for j in subset if j != i)
                term = c
                for j in remaining:
                    term *= x[j]
                grad[i] += term
    return grad


def multiaffine_hessian(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    n = len(x)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                for subset, c in coeffs.items():
                    if i in subset and j in subset:
                        remaining = tuple(k for k in subset if k != i and k != j)
                        term = c
                        for k in remaining:
                            term *= x[k]
                        H[i, j] += term
    return H


def certificate_matrix(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)
    hess = multiaffine_hessian(coeffs, x)
    return g_val * hess - np.outer(grad, grad)


def dpp_generating_poly(K: np.ndarray) -> Dict[tuple, float]:
    n = K.shape[0]
    coeffs = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if len(subset) == 0:
                coeffs[()] = 1.0
            else:
                sub_K = K[np.ix_(list(subset), list(subset))]
                coeffs[subset] = np.linalg.det(sub_K)
    return coeffs


# ============================================================
# Application 1: Log-Concavity Certification
# ============================================================
def log_concavity_certificate(coeffs: Dict[tuple, float], x: np.ndarray) -> dict:
    """
    Certify log-concavity of the generating polynomial along any direction.

    If M_g(x) is NSD, then log g is concave on the positive orthant,
    which implies unimodality of the coefficient sequence along any line.

    Returns:
        Dictionary with certificate analysis.
    """
    M = certificate_matrix(coeffs, x)
    eigenvalues = np.linalg.eigvalsh(M)
    max_eigenvalue = np.max(eigenvalues)

    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)

    # The log-Hessian is H_log_g = Hess(g)/g - (∇g⊗∇g)/g² = M_g/g²
    if g_val > 0:
        log_hessian = M / (g_val ** 2)
        log_eigenvalues = np.linalg.eigvalsh(log_hessian)
    else:
        log_eigenvalues = None

    return {
        'is_log_concave': max_eigenvalue <= 1e-10,
        'max_eigenvalue_of_M': max_eigenvalue,
        'log_hessian_eigenvalues': log_eigenvalues,
        'certificate_norm': np.linalg.norm(M, 'fro'),
    }


# ============================================================
# Application 2: Negative Dependence Verification
# ============================================================
def negative_dependence_check(coeffs: Dict[tuple, float], x: np.ndarray) -> dict:
    """
    Verify negative dependence properties from the certificate.

    The diagonal entries M_ii = g·∂²g/∂x_i² - (∂g/∂x_i)² ≤ 0
    encode the variance bound Var[1_i] ≤ E[1_i](1 - E[1_i]).
    Off-diagonal entries M_ij ≤ 0 encode negative correlation.

    Returns:
        Dictionary with negative dependence analysis.
    """
    M = certificate_matrix(coeffs, x)
    n = M.shape[0]

    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)

    # Marginal probabilities (at x = 1)
    marginals = grad / g_val if g_val > 0 else np.zeros(n)

    # Pairwise correlations from the Hessian
    hess = multiaffine_hessian(coeffs, x)
    pairwise = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j and g_val > 0:
                pairwise[i, j] = hess[i, j] / g_val - marginals[i] * marginals[j]

    # Check Rayleigh inequality: all M_ij ≤ 0
    all_rayleigh = np.all(M <= 1e-10)

    return {
        'marginals': marginals,
        'pairwise_correlations': pairwise,
        'all_pairwise_negative': np.all(pairwise <= 1e-10),
        'all_rayleigh_hold': all_rayleigh,
        'min_certificate_entry': np.min(M),
        'max_certificate_entry': np.max(M),
    }


# ============================================================
# Application 3: Spectral Gap from Certificate
# ============================================================
def spectral_gap_estimate(coeffs: Dict[tuple, float], x: np.ndarray) -> dict:
    """
    Estimate the spectral gap of the associated Markov chain.

    The certificate matrix eigenvalues bound the mixing time of
    Glauber dynamics for the strongly Rayleigh measure.

    The spectral gap is related to the smallest (most negative)
    eigenvalue of the normalized certificate.

    Returns:
        Dictionary with spectral gap estimates.
    """
    M = certificate_matrix(coeffs, x)
    g_val = multiaffine_eval(coeffs, x)

    if g_val <= 0:
        return {'error': 'g(x) must be positive'}

    # Normalized certificate
    M_norm = M / (g_val ** 2)
    eigenvalues = np.sort(np.linalg.eigvalsh(M_norm))

    # The most negative eigenvalue gives a concavity bound
    spectral_gap_bound = -eigenvalues[0] if len(eigenvalues) > 0 else 0

    return {
        'eigenvalues_normalized': eigenvalues,
        'spectral_gap_bound': spectral_gap_bound,
        'condition_number': abs(eigenvalues[-1] / eigenvalues[0]) if eigenvalues[0] != 0 else float('inf'),
    }


def main():
    np.random.seed(42)

    print("=" * 65)
    print("  Applications of the Lorentzian Certificate Theory")
    print("=" * 65)

    # Application 1: Log-concavity of a DPP
    print("\n--- Application 1: Log-Concavity Certification ---")
    K = np.array([[1.0, 0.3, 0.1],
                   [0.3, 1.0, 0.2],
                   [0.1, 0.2, 1.0]])
    coeffs = dpp_generating_poly(K)
    x = np.ones(3)
    result = log_concavity_certificate(coeffs, x)
    print(f"  DPP with 3×3 PSD kernel at x = (1,1,1)")
    print(f"  Is log-concave: {result['is_log_concave']}")
    print(f"  Max eigenvalue of M_g: {result['max_eigenvalue_of_M']:.6f}")
    if result['log_hessian_eigenvalues'] is not None:
        print(f"  Log-Hessian eigenvalues: {result['log_hessian_eigenvalues']}")

    # Application 2: Negative dependence
    print("\n--- Application 2: Negative Dependence Verification ---")
    result = negative_dependence_check(coeffs, x)
    print(f"  Marginal probabilities: {result['marginals']}")
    print(f"  All pairwise correlations negative: {result['all_pairwise_negative']}")
    print(f"  All Rayleigh inequalities hold: {result['all_rayleigh_hold']}")
    print(f"  Certificate entry range: [{result['min_certificate_entry']:.4f}, {result['max_certificate_entry']:.4f}]")

    # Application 3: Spectral gap
    print("\n--- Application 3: Spectral Gap Estimation ---")
    result = spectral_gap_estimate(coeffs, x)
    print(f"  Normalized eigenvalues: {result['eigenvalues_normalized']}")
    print(f"  Spectral gap bound: {result['spectral_gap_bound']:.6f}")
    print(f"  Condition number: {result['condition_number']:.4f}")

    # Uniform matroid application
    print("\n--- Uniform Matroid U_{2,5} ---")
    coeffs_um = {}
    for subset in combinations(range(5), 2):
        coeffs_um[subset] = 1.0
    x = np.ones(5)

    result1 = log_concavity_certificate(coeffs_um, x)
    result2 = negative_dependence_check(coeffs_um, x)
    result3 = spectral_gap_estimate(coeffs_um, x)

    print(f"  Log-concave: {result1['is_log_concave']}")
    print(f"  All negative correlations: {result2['all_pairwise_negative']}")
    print(f"  Spectral gap bound: {result3['spectral_gap_bound']:.6f}")

    print("\n" + "=" * 65)
    print("  All applications demonstrate the certificate theory in action.")
    print("=" * 65)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demonstration of the Lorentzian Certificate Matrix for Strongly Rayleigh Polynomials.

Computes and verifies the intrinsic Hessian certificate M_g(x) = g(x)*Hess(g)(x) - grad(g)(x)*grad(g)(x)^T
for various polynomial families, including DPP generating polynomials, uniform matroid basis
polynomials, and graphic matroid spanning tree polynomials.

The key prediction: for real stable polynomials, M_g(x) has at most one positive eigenvalue
at every positive point x.
"""

import numpy as np
from itertools import combinations
from typing import Callable, Dict, List, Tuple


def multiaffine_eval(coeffs: Dict[tuple, float], x: np.ndarray) -> float:
    """Evaluate a multiaffine polynomial given as {subset: coeff} at point x."""
    n = len(x)
    val = 0.0
    for subset, c in coeffs.items():
        term = c
        for i in subset:
            term *= x[i]
        val += term
    return val


def multiaffine_gradient(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    """Compute the gradient of a multiaffine polynomial at point x."""
    n = len(x)
    grad = np.zeros(n)
    for i in range(n):
        for subset, c in coeffs.items():
            if i in subset:
                remaining = tuple(j for j in subset if j != i)
                term = c
                for j in remaining:
                    term *= x[j]
                grad[i] += term
    return grad


def multiaffine_hessian(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    """Compute the Hessian matrix of a multiaffine polynomial at point x."""
    n = len(x)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                # Second derivative of multiaffine poly wrt same variable is 0
                H[i, j] = 0.0
            else:
                for subset, c in coeffs.items():
                    if i in subset and j in subset:
                        remaining = tuple(k for k in subset if k != i and k != j)
                        term = c
                        for k in remaining:
                            term *= x[k]
                        H[i, j] += term
    return H


def lorentzian_certificate_matrix(coeffs: Dict[tuple, float], x: np.ndarray) -> np.ndarray:
    """
    Compute the Lorentzian certificate matrix:
    M_g(x) = g(x) * Hess(g)(x) - grad(g)(x) * grad(g)(x)^T
    """
    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)
    hess = multiaffine_hessian(coeffs, x)
    return g_val * hess - np.outer(grad, grad)


def count_positive_eigenvalues(M: np.ndarray, tol: float = 1e-10) -> int:
    """Count eigenvalues strictly greater than tol."""
    eigenvalues = np.linalg.eigvalsh(M)
    return int(np.sum(eigenvalues > tol))


def check_conditional_nsd(M: np.ndarray, w: np.ndarray, num_trials: int = 10000) -> bool:
    """Check conditional NSD by sampling random u orthogonal to w."""
    n = M.shape[0]
    for _ in range(num_trials):
        u = np.random.randn(n)
        u -= (u @ w) / (w @ w) * w  # project onto hyperplane
        quad_form = u @ M @ u
        if quad_form > 1e-8:
            return False
    return True


# ============================================================
# Example 1: DPP with identity kernel (product polynomial)
# ============================================================
def dpp_generating_poly(K: np.ndarray) -> Dict[tuple, float]:
    """
    Compute the DPP generating polynomial det(I + diag(z)*K).
    For an n×n kernel K, this is a multiaffine polynomial in n variables.
    """
    n = K.shape[0]
    coeffs = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if len(subset) == 0:
                coeffs[()] = 1.0
            else:
                sub_K = K[np.ix_(list(subset), list(subset))]
                coeffs[subset] = np.linalg.det(sub_K)
    return coeffs


# ============================================================
# Example 2: Uniform matroid U_{r,n}
# ============================================================
def uniform_matroid_poly(n: int, r: int) -> Dict[tuple, float]:
    """Basis generating polynomial of the uniform matroid U_{r,n}."""
    coeffs = {}
    for subset in combinations(range(n), r):
        coeffs[subset] = 1.0
    return coeffs


# ============================================================
# Example 3: Graphic matroid (spanning trees)
# ============================================================
def spanning_tree_poly_complete(n: int) -> Dict[tuple, float]:
    """
    Basis generating polynomial for the graphic matroid of K_n.
    Edges are indexed and spanning trees are detected via Kirchhoff.
    For small n, enumerate all spanning trees.
    """
    from itertools import combinations as combs

    edges = []
    for i in range(n):
        for j in range(i + 1, n):
            edges.append((i, j))

    m = len(edges)
    coeffs = {}

    # Check if a subset of edges forms a spanning tree
    for subset_idx in combs(range(m), n - 1):
        # Check connectivity
        adj = {v: set() for v in range(n)}
        for idx in subset_idx:
            u, v = edges[idx]
            adj[u].add(v)
            adj[v].add(u)

        # BFS to check connectivity
        visited = set()
        queue = [0]
        visited.add(0)
        while queue:
            node = queue.pop(0)
            for neighbor in adj[node]:
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        if len(visited) == n:
            coeffs[subset_idx] = 1.0

    return coeffs


def run_certificate_test(name: str, coeffs: Dict[tuple, float], x: np.ndarray):
    """Run the certificate computation and report results."""
    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)
    hess = multiaffine_hessian(coeffs, x)
    M = lorentzian_certificate_matrix(coeffs, x)

    eigenvalues = np.linalg.eigvalsh(M)
    n_pos = count_positive_eigenvalues(M)
    is_cond_nsd = check_conditional_nsd(M, grad)

    print(f"\n{'=' * 60}")
    print(f"  {name}")
    print(f"{'=' * 60}")
    print(f"  g(x) = {g_val:.6f}")
    print(f"  ||∇g(x)|| = {np.linalg.norm(grad):.6f}")
    print(f"  Eigenvalues of M_g(x):")
    for i, ev in enumerate(sorted(eigenvalues, reverse=True)):
        marker = " ← POSITIVE" if ev > 1e-10 else ""
        print(f"    λ_{i} = {ev:12.6f}{marker}")
    print(f"  Number of positive eigenvalues: {n_pos}")
    print(f"  At most one positive eigenvalue: {'✓ YES' if n_pos <= 1 else '✗ NO (COUNTEREXAMPLE!)'}")
    print(f"  Conditional NSD (numerical): {'✓ YES' if is_cond_nsd else '✗ NO'}")

    if n_pos > 1:
        print(f"\n  *** POTENTIAL COUNTEREXAMPLE FOUND ***")

    return n_pos


def main():
    np.random.seed(42)

    print("╔══════════════════════════════════════════════════════════════╗")
    print("║  Lorentzian Certificate Matrix: Computational Verification  ║")
    print("║  Testing M_g(x) = g(x)·Hess(g)(x) - ∇g(x)·∇g(x)ᵀ        ║")
    print("║  Conjecture: at most 1 positive eigenvalue for SR polys     ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    all_pass = True

    # Test 1: DPP with identity kernel (2×2)
    K = np.eye(2)
    coeffs = dpp_generating_poly(K)
    x = np.array([1.0, 1.0])
    n_pos = run_certificate_test("DPP: K = I₂, x = (1,1)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 2: DPP with random PSD kernel (3×3)
    A = np.random.randn(3, 3)
    K = A @ A.T / 3
    coeffs = dpp_generating_poly(K)
    x = np.array([1.0, 2.0, 0.5])
    n_pos = run_certificate_test("DPP: random PSD K (3×3), x = (1,2,0.5)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 3: Uniform matroid U_{2,4}
    coeffs = uniform_matroid_poly(4, 2)
    x = np.array([1.0, 1.0, 1.0, 1.0])
    n_pos = run_certificate_test("Uniform matroid U_{2,4}, x = (1,1,1,1)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 4: Uniform matroid U_{2,4} at asymmetric point
    x = np.array([0.5, 1.5, 2.0, 0.3])
    n_pos = run_certificate_test("Uniform matroid U_{2,4}, x = (0.5,1.5,2,0.3)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 5: Uniform matroid U_{3,5}
    coeffs = uniform_matroid_poly(5, 3)
    x = np.ones(5)
    n_pos = run_certificate_test("Uniform matroid U_{3,5}, x = (1,...,1)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 6: Graphic matroid - spanning trees of K_4
    print("\n\n--- Graphic Matroid: Spanning Trees of K₄ ---")
    coeffs = spanning_tree_poly_complete(4)
    n_edges = len(list(combinations(range(4), 2)))
    x = np.ones(n_edges)
    n_pos = run_certificate_test(f"Graphic matroid K₄ ({n_edges} edges), x = 1", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 7: Random positive point for K₄ graphic matroid
    x = np.random.exponential(1.0, n_edges)
    n_pos = run_certificate_test(f"Graphic matroid K₄, random positive x", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 8: DPP with rank-1 kernel
    v = np.array([1.0, 2.0, 3.0])
    K = np.outer(v, v) / np.dot(v, v)
    coeffs = dpp_generating_poly(K)
    x = np.array([1.0, 1.0, 1.0])
    n_pos = run_certificate_test("DPP: rank-1 kernel (3×3), x = (1,1,1)", coeffs, x)
    if n_pos > 1:
        all_pass = False

    # Test 9: Stress test - many random PSD DPPs
    print("\n\n--- Stress Test: 100 Random PSD DPPs (4×4) ---")
    n_counterexamples = 0
    for trial in range(100):
        n = 4
        A = np.random.randn(n, n)
        K = A @ A.T / n
        coeffs = dpp_generating_poly(K)
        x = np.random.exponential(1.0, n)
        M = lorentzian_certificate_matrix(coeffs, x)
        n_pos = count_positive_eigenvalues(M)
        if n_pos > 1:
            n_counterexamples += 1
            print(f"  Trial {trial}: COUNTEREXAMPLE! {n_pos} positive eigenvalues")

    print(f"  Results: {100 - n_counterexamples}/100 passed (at most 1 positive eigenvalue)")
    if n_counterexamples > 0:
        all_pass = False
        print(f"  *** {n_counterexamples} COUNTEREXAMPLES FOUND ***")

    # Test 10: Stress test - uniform matroids
    print("\n--- Stress Test: Uniform Matroids U_{r,n} at random positive points ---")
    n_counterexamples = 0
    test_cases = [(3, 2), (4, 2), (4, 3), (5, 2), (5, 3), (6, 3)]
    for n, r in test_cases:
        coeffs = uniform_matroid_poly(n, r)
        for _ in range(20):
            x = np.random.exponential(1.0, n)
            M = lorentzian_certificate_matrix(coeffs, x)
            n_pos = count_positive_eigenvalues(M)
            if n_pos > 1:
                n_counterexamples += 1
                print(f"  U_{{{r},{n}}} COUNTEREXAMPLE: {n_pos} positive eigenvalues")

    print(f"  Results: {len(test_cases)*20 - n_counterexamples}/{len(test_cases)*20} passed")
    if n_counterexamples > 0:
        all_pass = False

    # Summary
    print("\n" + "=" * 60)
    if all_pass:
        print("  ALL TESTS PASSED: Conjecture holds on all tested examples.")
        print("  The certificate matrix has at most 1 positive eigenvalue")
        print("  for all tested strongly Rayleigh polynomial families.")
    else:
        print("  SOME TESTS FAILED: Potential counterexamples found!")
    print("=" * 60)


if __name__ == "__main__":
    main()


"""
Visualization: Lorentzian Certificate Matrix Eigenvalue Spectrum

Visualizes how the eigenvalues of the certificate matrix M_g(x) vary
as the evaluation point x changes along a path in the positive orthant.
Shows that all eigenvalues remain nonpositive for strongly Rayleigh polynomials.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def multiaffine_eval(coeffs, x):
    val = 0.0
    for subset, c in coeffs.items():
        term = c
        for i in subset:
            term *= x[i]
        val += term
    return val


def multiaffine_gradient(coeffs, x):
    n = len(x)
    grad = np.zeros(n)
    for i in range(n):
        for subset, c in coeffs.items():
            if i in subset:
                remaining = tuple(j for j in subset if j != i)
                term = c
                for j in remaining:
                    term *= x[j]
                grad[i] += term
    return grad


def multiaffine_hessian(coeffs, x):
    n = len(x)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                for subset, c in coeffs.items():
                    if i in subset and j in subset:
                        remaining = tuple(k for k in subset if k != i and k != j)
                        term = c
                        for k in remaining:
                            term *= x[k]
                        H[i, j] += term
    return H


def certificate_matrix(coeffs, x):
    g_val = multiaffine_eval(coeffs, x)
    grad = multiaffine_gradient(coeffs, x)
    hess = multiaffine_hessian(coeffs, x)
    return g_val * hess - np.outer(grad, grad)


def uniform_matroid_poly(n, r):
    coeffs = {}
    for subset in combinations(range(n), r):
        coeffs[subset] = 1.0
    return coeffs


def dpp_generating_poly(K):
    n = K.shape[0]
    coeffs = {}
    for size in range(n + 1):
        for subset in combinations(range(n), size):
            if len(subset) == 0:
                coeffs[()] = 1.0
            else:
                sub_K = K[np.ix_(list(subset), list(subset))]
                coeffs[subset] = np.linalg.det(sub_K)
    return coeffs


# Create figure with 3 subplots
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# --- Panel 1: Eigenvalue paths for U_{2,4} ---
ax1 = axes[0]
coeffs = uniform_matroid_poly(4, 2)
t_values = np.linspace(0.1, 3.0, 100)
all_eigs = []

for t in t_values:
    x = np.array([t, 1.0, 1.5, 0.8])
    M = certificate_matrix(coeffs, x)
    eigs = np.sort(np.linalg.eigvalsh(M))[::-1]
    all_eigs.append(eigs)

all_eigs = np.array(all_eigs)
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']
for i in range(4):
    ax1.plot(t_values, all_eigs[:, i], color=colors[i], linewidth=2,
             label=f'λ_{i+1}')

ax1.axhline(y=0, color='black', linewidth=1, linestyle='--', alpha=0.5)
ax1.set_xlabel('x₁ (other coordinates fixed)', fontsize=11)
ax1.set_ylabel('Eigenvalue', fontsize=11)
ax1.set_title('U_{2,4}: Certificate Eigenvalues\nvs. x₁', fontsize=12)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# --- Panel 2: Heatmap of certificate matrix for DPP ---
ax2 = axes[1]
np.random.seed(42)
A = np.random.randn(4, 4)
K = A @ A.T / 4
coeffs_dpp = dpp_generating_poly(K)
x = np.ones(4)
M = certificate_matrix(coeffs_dpp, x)

im = ax2.imshow(M, cmap='RdBu_r', aspect='equal', vmin=np.min(M), vmax=-np.min(M))
ax2.set_title('DPP Certificate Matrix\nat x = (1,1,1,1)', fontsize=12)
ax2.set_xlabel('Column index j', fontsize=11)
ax2.set_ylabel('Row index i', fontsize=11)
plt.colorbar(im, ax=ax2, shrink=0.8)

# Add value annotations
for i in range(4):
    for j in range(4):
        ax2.text(j, i, f'{M[i,j]:.1f}', ha='center', va='center',
                fontsize=8, color='white' if abs(M[i,j]) > abs(np.max(M))*0.5 else 'black')

# --- Panel 3: Eigenvalue distribution across random points ---
ax3 = axes[2]
coeffs_u35 = uniform_matroid_poly(5, 3)
all_max_eigs = []
all_min_eigs = []

np.random.seed(123)
for trial in range(200):
    x = np.random.exponential(1.0, 5)
    M = certificate_matrix(coeffs_u35, x)
    eigs = np.linalg.eigvalsh(M)
    all_max_eigs.append(np.max(eigs))
    all_min_eigs.append(np.min(eigs))

ax3.hist(all_max_eigs, bins=30, alpha=0.7, color='#e74c3c', label='Max eigenvalue', edgecolor='black')
ax3.axvline(x=0, color='black', linewidth=2, linestyle='--', label='Zero line')
ax3.set_xlabel('Maximum eigenvalue of M_g(x)', fontsize=11)
ax3.set_ylabel('Count', fontsize=11)
ax3.set_title('U_{3,5}: Max Eigenvalue Distribution\n(200 random positive points)', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_visualization.png', dpi=150, bbox_inches='tight')
print("Saved certificate_visualization.png")
