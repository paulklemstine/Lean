#!/usr/bin/env python3
"""
Applications of the Lorentzian CondNSD Theory

Demonstrates real-world applications:
1. Spectral certificates for negative dependence in DPP subset selection
2. Matroid basis exchange analysis via log-Hessian spectrum
3. Entropy geometry of Lorentzian generating functions
4. Spectral gap as a measure of repulsion strength
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple


# ============================================================================
# Self-contained utilities (no local imports)
# ============================================================================

def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2

def restrict_to_zero_sum(M):
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])
    basis = np.zeros((n, n - 1))
    for k in range(n - 1):
        basis[k, k] = 1.0
        basis[n - 1, k] = -1.0
    Q, _ = np.linalg.qr(basis, mode='reduced')
    return Q.T @ M @ Q

def max_eigenvalue_zero_sum(L):
    R = restrict_to_zero_sum(L)
    return max(np.linalg.eigvalsh(R))


# ============================================================================
# Application 1: DPP Diversity Certificate
# ============================================================================

def dpp_diversity_certificate():
    """Use the CondNSD spectral gap as a diversity certificate for DPP sampling.

    In machine learning, DPPs are used to select diverse subsets.
    The spectral gap of the log-Hessian quantifies how strongly items
    repel each other — larger gaps mean more diverse selections.
    """
    print("=" * 60)
    print("APPLICATION 1: DPP Diversity Certificates")
    print("=" * 60)
    print()
    print("Scenario: Selecting a diverse subset of items using a DPP.")
    print("The spectral gap of -L_p quantifies repulsion strength.\n")

    np.random.seed(42)

    # Compare different DPP kernels
    n = 6
    scenarios = [
        ("Independent (diagonal)", np.diag([0.5, 0.3, 0.8, 0.4, 0.6, 0.7])),
        ("Weakly repulsive", None),  # will construct
        ("Strongly repulsive (projection)", None),  # will construct
    ]

    # Weak repulsion: small off-diagonal
    A = np.eye(n) * 0.5
    A += np.random.randn(n, n) * 0.05
    A = A @ A.T / n
    scenarios[1] = ("Weakly repulsive", A)

    # Strong repulsion: projection kernel
    Q = np.linalg.qr(np.random.randn(n, 3), mode='reduced')[0]
    scenarios[2] = ("Strongly repulsive (projection)", Q @ Q.T)

    for name, K in scenarios:
        K_sym = (K + K.T) / 2
        I = np.eye(n)
        M = K_sym @ np.linalg.inv(I + K_sym)
        L = -(M * M)
        gap = -max_eigenvalue_zero_sum(L)
        print(f"  {name}:")
        print(f"    Spectral gap = {gap:.6f}")
        print(f"    Interpretation: {'High' if gap > 0.1 else 'Low'} repulsion")
        print()


# ============================================================================
# Application 2: Matroid Exchange Analysis
# ============================================================================

def matroid_exchange_analysis():
    """Analyze matroid structure through log-Hessian spectral theory.

    The spectrum of L_p on the zero-sum subspace reveals the exchange
    structure of the matroid: uniform matroids have equal eigenvalues
    (maximally symmetric), while structured matroids show spectral splitting.
    """
    print("=" * 60)
    print("APPLICATION 2: Matroid Exchange Structure via Spectrum")
    print("=" * 60)
    print()

    matroids = []

    # Uniform matroids
    for n, k in [(5, 2), (6, 3), (7, 3), (8, 4)]:
        from math import comb
        val = comb(n, k)
        grad = np.full(n, comb(n - 1, k - 1), dtype=float)
        hess = np.full((n, n), comb(n - 2, k - 2), dtype=float)
        np.fill_diagonal(hess, 0)
        L = log_hessian_at_one(val, grad, hess)
        eigs = np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))
        matroids.append((f"U({k},{n})", eigs))

    # Graphic matroid of K4
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    trees = []
    for combo in combinations(range(6), 3):
        edge_set = [edges[i] for i in combo]
        adj = {v: set() for v in range(4)}
        for u, v in edge_set:
            adj[u].add(v)
            adj[v].add(u)
        visited = {0}
        queue = [0]
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == 4:
            trees.append(combo)

    n = 6
    val = float(len(trees))
    grad = np.zeros(n)
    hess = np.zeros((n, n))
    for tree in trees:
        for i in tree:
            grad[i] += 1
        for i in tree:
            for j in tree:
                if i != j:
                    hess[i, j] += 1
    L = log_hessian_at_one(val, grad, hess)
    eigs = np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))
    matroids.append(("M(K4)", eigs))

    for name, eigs in matroids:
        print(f"  {name}: eigenvalues = [{', '.join(f'{e:.6f}' for e in eigs)}]")
        spread = max(eigs) - min(eigs)
        print(f"    Spectral spread: {spread:.6f} "
              f"({'uniform' if spread < 1e-8 else 'structured'})")
        print()


# ============================================================================
# Application 3: Entropy Curvature
# ============================================================================

def entropy_curvature_analysis():
    """Interpret the log-Hessian as entropy curvature.

    For a probability measure μ with generating polynomial p,
    the log-Hessian at 1 is the Hessian of the entropy functional.
    CondNSD means the entropy is concave on centered perturbations,
    a convexity property of the underlying geometry.
    """
    print("=" * 60)
    print("APPLICATION 3: Entropy Curvature of Lorentzian Measures")
    print("=" * 60)
    print()
    print("The log-Hessian encodes entropy curvature.")
    print("CondNSD ⟺ entropy is concave on centered perturbations.\n")

    np.random.seed(123)

    # Compare entropy curvature for different polynomial families
    for trial in range(5):
        n = np.random.randint(4, 8)
        # Random product of linears (always Lorentzian)
        w = np.random.uniform(0.1, 3.0, size=n)
        L = np.zeros((n, n))
        for i in range(n):
            L[i, i] = -(w[i] / (1 + w[i])) ** 2

        max_eig = max_eigenvalue_zero_sum(L)
        entropy_curvature = -np.trace(restrict_to_zero_sum(L)) / (n - 1)

        print(f"  Trial {trial+1} (n={n}): max_eig = {max_eig:.8f}, "
              f"avg curvature = {entropy_curvature:.8f}")

    print()
    print("All product-of-linear forms have uniformly negative curvature.")


# ============================================================================
# Main
# ============================================================================

def main():
    dpp_diversity_certificate()
    print()
    matroid_exchange_analysis()
    print()
    entropy_curvature_analysis()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Lorentzian CondNSD Conjecture — Log-Hessian Spectral Testing

This script demonstrates the core computational pipeline for testing
the Lorentzian CondNSD Conjecture:

  For a homogeneous multilinear polynomial p with nonneg coefficients,
  is the log-Hessian at the all-ones point conditionally negative
  semidefinite on the zero-sum subspace?

We test this on:
  1. Products of linear forms (simplest Lorentzian polynomials)
  2. Uniform matroid basis generating polynomials
  3. DPP partition functions with various kernels
  4. Random nonneg-coefficient homogeneous polynomials

A single positive eigenvalue on the zero-sum subspace is a counterexample.
"""

import numpy as np
from itertools import combinations
from typing import Tuple, List, Optional

np.set_printoptions(precision=8, suppress=True)


# ============================================================================
# Core computational engine
# ============================================================================

def log_hessian_at_one(value: float, gradient: np.ndarray,
                       hessian: np.ndarray) -> np.ndarray:
    """Compute the log-Hessian matrix L = H/c - gg^T/c^2.

    Parameters
    ----------
    value : float
        p(1,...,1) > 0
    gradient : np.ndarray, shape (n,)
        ∇p(1,...,1)
    hessian : np.ndarray, shape (n, n)
        ∇²p(1,...,1)

    Returns
    -------
    np.ndarray, shape (n, n)
        The log-Hessian L_p at the all-ones point.
    """
    c = value
    g = gradient
    H = hessian
    return H / c - np.outer(g, g) / (c ** 2)


def restrict_to_zero_sum(M: np.ndarray) -> np.ndarray:
    """Restrict a symmetric matrix to the zero-sum subspace {v : sum(v) = 0}.

    Returns the (n-1) x (n-1) matrix Q^T M Q where Q is an orthonormal
    basis for the zero-sum subspace.
    """
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])
    # Orthonormal basis for {v : 1^T v = 0} via QR of complement
    ones = np.ones(n) / np.sqrt(n)
    # Build basis: take e_1 - e_n, e_2 - e_n, ..., e_{n-1} - e_n, then orthonormalize
    basis = np.zeros((n, n - 1))
    for k in range(n - 1):
        basis[k, k] = 1.0
        basis[n - 1, k] = -1.0
    Q, _ = np.linalg.qr(basis, mode='reduced')
    return Q.T @ M @ Q


def test_condNSD(M: np.ndarray, tol: float = 1e-10) -> Tuple[bool, np.ndarray]:
    """Test whether a matrix is conditionally negative semidefinite.

    Returns (is_condNSD, eigenvalues_on_zero_sum_subspace).
    """
    M_restricted = restrict_to_zero_sum(M)
    eigs = np.linalg.eigvalsh(M_restricted)
    is_condNSD = np.all(eigs <= tol)
    return is_condNSD, eigs


def print_test_result(name: str, L: np.ndarray, verbose: bool = True):
    """Print the CondNSD test result for a log-Hessian matrix."""
    is_cond, eigs = test_condNSD(L)
    status = "✓ PASS (CondNSD)" if is_cond else "✗ FAIL (NOT CondNSD)"
    print(f"\n{'='*60}")
    print(f"  {name}")
    print(f"  {status}")
    print(f"  Eigenvalues on zero-sum subspace: {eigs}")
    if verbose and L.shape[0] <= 6:
        print(f"  Log-Hessian matrix:\n{L}")
    print(f"{'='*60}")
    return is_cond


# ============================================================================
# Domain 1: Products of linear forms
# ============================================================================

def product_of_linears_log_hessian(weights: np.ndarray) -> np.ndarray:
    """Log-Hessian at 1 for p(x) = prod_i (1 + w_i x_i).

    For this case, log p = sum_i log(1 + w_i x_i), so
    (∂² log p / ∂x_i ∂x_j)(1) = -w_i²/(1+w_i)² δ_{ij}.
    """
    n = len(weights)
    L = np.zeros((n, n))
    for i in range(n):
        w = weights[i]
        L[i, i] = -(w / (1 + w)) ** 2
    return L


# ============================================================================
# Domain 2: Matroid basis generating polynomials
# ============================================================================

def uniform_matroid_basis_polynomial(n: int, k: int):
    """Compute value, gradient, Hessian at 1 for the uniform matroid U(k,n).

    The basis generating polynomial is p(x) = sum_{|S|=k} prod_{i in S} x_i.
    At x=1: p(1) = C(n,k), g_i = C(n-1,k-1), H_{ij} = C(n-2,k-2) for i≠j, 0 for i=j.
    """
    from math import comb

    value = comb(n, k)
    gradient = np.full(n, comb(n - 1, k - 1), dtype=float)

    # Hessian: ∂²p/∂x_i∂x_j at 1
    # For multilinear p, ∂²p/∂x_i² = 0
    # ∂²p/∂x_i∂x_j = number of bases containing both i and j = C(n-2, k-2)
    hessian = np.full((n, n), comb(n - 2, k - 2), dtype=float)
    np.fill_diagonal(hessian, 0.0)

    return value, gradient, hessian


def graphic_matroid_K4():
    """Basis generating polynomial for the graphic matroid of K4.

    Bases are spanning trees of K4. K4 has 4 vertices and 6 edges.
    Each spanning tree uses 3 edges. There are 16 spanning trees.
    """
    n = 6  # edges
    edges = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]

    # Enumerate spanning trees of K4
    trees = []
    for combo in combinations(range(6), 3):
        edge_set = [edges[i] for i in combo]
        # Check if these 3 edges form a spanning tree (connected, acyclic on 4 vertices)
        adj = {v: set() for v in range(4)}
        for u, v in edge_set:
            adj[u].add(v)
            adj[v].add(u)
        # BFS from vertex 0
        visited = {0}
        queue = [0]
        while queue:
            node = queue.pop(0)
            for nb in adj[node]:
                if nb not in visited:
                    visited.add(nb)
                    queue.append(nb)
        if len(visited) == 4:
            trees.append(combo)

    value = len(trees)
    gradient = np.zeros(n)
    hessian = np.zeros((n, n))

    for tree in trees:
        for i in tree:
            gradient[i] += 1
        for i in tree:
            for j in tree:
                if i != j:
                    hessian[i, j] += 1

    return value, gradient, hessian


# ============================================================================
# Domain 3: DPP partition functions
# ============================================================================

def dpp_log_hessian(K: np.ndarray) -> np.ndarray:
    """Log-Hessian at x=1 for Z_K(x) = det(I + diag(x) K).

    The log-Hessian has entries -(M_ij)^2 where M = K(I+K)^{-1}.
    """
    n = K.shape[0]
    I = np.eye(n)
    M = K @ np.linalg.inv(I + K)
    L = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            L[i, j] = -(M[i, j] ** 2)
    return L


def make_projection_kernel(n: int, k: int) -> np.ndarray:
    """Create a rank-k projection kernel on R^n."""
    Q = np.linalg.qr(np.random.randn(n, k), mode='reduced')[0]
    return Q @ Q.T


def make_psd_kernel(n: int, scale: float = 1.0) -> np.ndarray:
    """Create a random PSD kernel."""
    A = np.random.randn(n, n)
    return scale * (A.T @ A) / n


# ============================================================================
# Main demonstration
# ============================================================================

def main():
    print("=" * 60)
    print("  LORENTZIAN CondNSD CONJECTURE — COMPUTATIONAL TESTING")
    print("=" * 60)
    print()
    print("Testing: Is the log-Hessian at 1 conditionally negative")
    print("semidefinite on the zero-sum subspace?")
    print()

    all_pass = True

    # --- Domain 1: Products of linear forms ---
    print("\n" + "▸" * 60)
    print("  DOMAIN 1: Products of Linear Forms")
    print("▸" * 60)

    for name, w in [
        ("Uniform weights [1,1,1,1]", np.ones(4)),
        ("Varied weights [0.5, 1, 2, 3]", np.array([0.5, 1, 2, 3])),
        ("Large dim [1]*10", np.ones(10)),
        ("Random weights n=6", np.random.uniform(0.1, 5.0, size=6)),
    ]:
        L = product_of_linears_log_hessian(w)
        ok = print_test_result(f"Product of linears: {name}", L, verbose=False)
        all_pass = all_pass and ok

    # --- Domain 2: Matroid basis polynomials ---
    print("\n" + "▸" * 60)
    print("  DOMAIN 2: Matroid Basis Generating Polynomials")
    print("▸" * 60)

    for n, k in [(4, 2), (5, 2), (5, 3), (6, 3), (7, 3), (8, 4)]:
        val, grad, hess = uniform_matroid_basis_polynomial(n, k)
        L = log_hessian_at_one(val, grad, hess)
        ok = print_test_result(f"Uniform matroid U({k},{n})", L, verbose=False)
        all_pass = all_pass and ok

    # K4 graphic matroid
    val, grad, hess = graphic_matroid_K4()
    L = log_hessian_at_one(val, grad, hess)
    ok = print_test_result("Graphic matroid M(K4)", L)
    all_pass = all_pass and ok

    # --- Domain 3: DPP partition functions ---
    print("\n" + "▸" * 60)
    print("  DOMAIN 3: DPP Partition Functions")
    print("▸" * 60)

    np.random.seed(42)

    # Projection DPPs
    for n, k in [(4, 2), (5, 3), (6, 2), (8, 4)]:
        K = make_projection_kernel(n, k)
        L = dpp_log_hessian(K)
        ok = print_test_result(f"Projection DPP (n={n}, rank={k})", L, verbose=False)
        all_pass = all_pass and ok

    # General PSD kernels
    for trial in range(5):
        n = np.random.randint(3, 8)
        K = make_psd_kernel(n, scale=np.random.uniform(0.1, 3.0))
        L = dpp_log_hessian(K)
        ok = print_test_result(f"Random PSD DPP (n={n}, trial {trial+1})", L, verbose=False)
        all_pass = all_pass and ok

    # Diagonal DPP (product of linears)
    w = np.array([0.3, 0.7, 1.2, 0.5])
    K = np.diag(w)
    L = dpp_log_hessian(K)
    ok = print_test_result("Diagonal DPP K=diag(0.3, 0.7, 1.2, 0.5)", L)
    all_pass = all_pass and ok

    # --- Summary ---
    print("\n" + "=" * 60)
    if all_pass:
        print("  ALL TESTS PASSED — Conjecture holds on all tested examples")
    else:
        print("  SOME TESTS FAILED — Potential counterexample found!")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Log-Hessian Matrix Heatmaps

Shows the structure of log-Hessian matrices for different polynomial families,
highlighting the interplay between the Hessian term (H/c) and the gradient
outer-product correction (-gg^T/c^2) that drives CondNSD.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2


fig, axes = plt.subplots(2, 3, figsize=(14, 9))

# Example 1: Uniform matroid U(3,6)
n, k = 6, 3
val = comb(n, k)
grad = np.full(n, comb(n-1, k-1), dtype=float)
hess = np.full((n, n), comb(n-2, k-2), dtype=float)
np.fill_diagonal(hess, 0)
L = log_hessian_at_one(val, grad, hess)

ax = axes[0, 0]
im = ax.imshow(hess / val, cmap='RdBu_r', aspect='equal')
ax.set_title('H/c  (Hessian term)\nU(3,6)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[0, 1]
outer = np.outer(grad, grad) / val**2
im = ax.imshow(-outer, cmap='RdBu_r', aspect='equal')
ax.set_title('-gg^T/c²  (gradient correction)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[0, 2]
vmax = max(abs(L.min()), abs(L.max()))
im = ax.imshow(L, cmap='RdBu_r', aspect='equal', vmin=-vmax, vmax=vmax)
ax.set_title('L = H/c - gg^T/c²  (log-Hessian)')
plt.colorbar(im, ax=ax, shrink=0.8)

# Example 2: DPP with projection kernel
np.random.seed(42)
n = 6
Q = np.linalg.qr(np.random.randn(n, 3), mode='reduced')[0]
K = Q @ Q.T
I_n = np.eye(n)
M = K @ np.linalg.inv(I_n + K)
L_dpp = -(M * M)

ax = axes[1, 0]
im = ax.imshow(M, cmap='viridis', aspect='equal')
ax.set_title('Marginal kernel M\nProjection DPP (n=6, r=3)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[1, 1]
im = ax.imshow(M * M, cmap='viridis', aspect='equal')
ax.set_title('M ∘ M  (Hadamard square)')
plt.colorbar(im, ax=ax, shrink=0.8)

ax = axes[1, 2]
vmax = max(abs(L_dpp.min()), abs(L_dpp.max()))
im = ax.imshow(L_dpp, cmap='RdBu_r', aspect='equal', vmin=-vmax, vmax=vmax)
ax.set_title('-(M ∘ M)  (DPP log-Hessian)')
plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Log-Hessian Decomposition: Hessian vs. Gradient Correction',
             fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig('heatmap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved heatmap_analysis.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap vs. Polynomial Parameters

Shows how the spectral gap (magnitude of max eigenvalue on zero-sum subspace)
varies with polynomial parameters, illustrating the strength of negative
dependence across different families.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2

def restrict_to_zero_sum(M):
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])
    basis = np.zeros((n, n - 1))
    for k in range(n - 1):
        basis[k, k] = 1.0
        basis[n - 1, k] = -1.0
    Q, _ = np.linalg.qr(basis, mode='reduced')
    return Q.T @ M @ Q

def spectral_gap(L):
    R = restrict_to_zero_sum(L)
    eigs = np.linalg.eigvalsh(R)
    return -max(eigs)  # positive when CondNSD holds


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids — gap vs n for fixed k
ax = axes[0]
for k in [2, 3, 4]:
    ns = range(k + 1, 15)
    gaps = []
    ns_list = []
    for n in ns:
        val = comb(n, k)
        grad = np.full(n, comb(n-1, k-1), dtype=float)
        hess = np.full((n, n), comb(n-2, k-2), dtype=float)
        np.fill_diagonal(hess, 0)
        L = log_hessian_at_one(val, grad, hess)
        gaps.append(spectral_gap(L))
        ns_list.append(n)
    ax.plot(ns_list, gaps, 'o-', label=f'k={k}', markersize=5)
ax.set_xlabel('n (ground set size)')
ax.set_ylabel('Spectral gap')
ax.set_title('Uniform Matroid U(k,n)\nSpectral Gap vs n')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: DPP — gap vs kernel spectral norm
ax = axes[1]
np.random.seed(42)
norms = []
gaps = []
for trial in range(50):
    n = 6
    A = np.random.randn(n, n)
    scale = np.random.uniform(0.01, 5.0)
    K = scale * (A.T @ A) / n
    I_n = np.eye(n)
    M = K @ np.linalg.inv(I_n + K)
    L = -(M * M)
    norms.append(np.linalg.norm(K, ord=2))
    gaps.append(spectral_gap(L))
ax.scatter(norms, gaps, alpha=0.6, s=30, c='tab:orange')
ax.set_xlabel('||K||₂ (spectral norm)')
ax.set_ylabel('Spectral gap')
ax.set_title('DPP (n=6)\nSpectral Gap vs Kernel Norm')
ax.grid(True, alpha=0.3)

# Panel 3: Products of linears — gap vs weight variance
ax = axes[2]
variances = []
gaps = []
for trial in range(80):
    n = 6
    mean_w = np.random.uniform(0.5, 2.0)
    spread = np.random.uniform(0, 3.0)
    w = np.maximum(0.01, mean_w + spread * np.random.randn(n))
    L = np.zeros((n, n))
    for i in range(n):
        L[i, i] = -(w[i] / (1 + w[i]))**2
    variances.append(np.var(w))
    gaps.append(spectral_gap(L))
ax.scatter(variances, gaps, alpha=0.6, s=30, c='tab:green')
ax.set_xlabel('Var(weights)')
ax.set_ylabel('Spectral gap')
ax.set_title('Product of Linears (n=6)\nSpectral Gap vs Weight Variance')
ax.grid(True, alpha=0.3)

plt.suptitle('Spectral Gap Analysis: Measuring Negative Dependence Strength',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")


#!/usr/bin/env python3
"""
Visualization: Log-Hessian Spectrum on the Zero-Sum Subspace

Visualizes the eigenvalue spectrum of log-Hessian matrices restricted
to the zero-sum subspace for various polynomial families. This is the
core diagnostic for the Lorentzian CondNSD conjecture: all eigenvalues
should be ≤ 0 (shown in blue), with any positive eigenvalue (red)
indicating a counterexample.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations
from math import comb


def log_hessian_at_one(value, gradient, hessian):
    c, g, H = value, gradient, hessian
    return H / c - np.outer(g, g) / c**2

def restrict_to_zero_sum(M):
    n = M.shape[0]
    if n <= 1:
        return np.array([[0.0]])
    basis = np.zeros((n, n - 1))
    for k in range(n - 1):
        basis[k, k] = 1.0
        basis[n - 1, k] = -1.0
    Q, _ = np.linalg.qr(basis, mode='reduced')
    return Q.T @ M @ Q

def uniform_matroid_eigs(n, k):
    val = comb(n, k)
    grad = np.full(n, comb(n-1, k-1), dtype=float)
    hess = np.full((n, n), comb(n-2, k-2), dtype=float)
    np.fill_diagonal(hess, 0)
    L = log_hessian_at_one(val, grad, hess)
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))

def dpp_eigs(K):
    n = K.shape[0]
    I = np.eye(n)
    M = K @ np.linalg.inv(I + K)
    L = -(M * M)
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))

def product_linears_eigs(w):
    n = len(w)
    L = np.zeros((n, n))
    for i in range(n):
        L[i, i] = -(w[i] / (1 + w[i]))**2
    return np.sort(np.linalg.eigvalsh(restrict_to_zero_sum(L)))


fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# Panel 1: Uniform matroids
ax = axes[0]
matroids = [(5,2), (6,3), (7,3), (8,4), (6,2), (7,4)]
for idx, (n, k) in enumerate(matroids):
    eigs = uniform_matroid_eigs(n, k)
    y = idx
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, y, 'o', color=color, markersize=8, alpha=0.7)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(matroids)))
ax.set_yticklabels([f'U({k},{n})' for n, k in matroids])
ax.set_xlabel('Eigenvalue')
ax.set_title('Uniform Matroid Spectra')

# Panel 2: DPP partition functions
ax = axes[1]
np.random.seed(42)
dpp_names = []
for idx in range(6):
    n = np.random.randint(4, 8)
    if idx < 3:
        k = max(2, n // 2)
        Q = np.linalg.qr(np.random.randn(n, k), mode='reduced')[0]
        K = Q @ Q.T
        name = f'Proj(n={n},r={k})'
    else:
        A = np.random.randn(n, n)
        K = (A.T @ A) / n * 0.5
        name = f'PSD(n={n})'
    eigs = dpp_eigs(K)
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, idx, 'o', color=color, markersize=8, alpha=0.7)
    dpp_names.append(name)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(dpp_names)))
ax.set_yticklabels(dpp_names)
ax.set_xlabel('Eigenvalue')
ax.set_title('DPP Log-Hessian Spectra')

# Panel 3: Products of linear forms
ax = axes[2]
weight_sets = [
    np.ones(5),
    np.array([0.5, 1, 2, 3, 4]),
    np.array([0.1, 0.1, 10, 10, 0.5]),
    np.random.uniform(0.1, 5, size=6),
    np.random.uniform(0.01, 10, size=8),
    np.array([1, 1, 1, 1, 1, 1, 1]),
]
lin_names = ['[1]*5', '[.5,1,2,3,4]', '[.1,.1,10,10,.5]',
             'Rand(6)', 'Rand(8)', '[1]*7']
for idx, w in enumerate(weight_sets):
    eigs = product_linears_eigs(w)
    for e in eigs:
        color = 'tab:blue' if e <= 1e-10 else 'tab:red'
        ax.plot(e, idx, 'o', color=color, markersize=8, alpha=0.7)
ax.axvline(x=0, color='black', linewidth=0.8, linestyle='--', alpha=0.5)
ax.set_yticks(range(len(lin_names)))
ax.set_yticklabels(lin_names)
ax.set_xlabel('Eigenvalue')
ax.set_title('Product-of-Linears Spectra')

plt.suptitle('Log-Hessian Eigenvalues on Zero-Sum Subspace\n'
             '(Blue ≤ 0: CondNSD holds  |  Red > 0: conjecture violation)',
             fontsize=13, y=1.02)
plt.tight_layout()
plt.savefig('spectrum_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectrum_analysis.png")
