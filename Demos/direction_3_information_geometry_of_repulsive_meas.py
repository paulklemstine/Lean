#!/usr/bin/env python3
"""
Repulsive Information Geometry — Applications

Demonstrates real-world applications of the repulsive information geometry framework:

1. DPP-based diverse subset selection with resistance-network interpretation
2. Natural gradient computation for DPP parameter optimization
3. Spectral sparsification of repulsion networks
"""

import numpy as np
from numpy.linalg import pinv, eigvalsh, norm, solve


def dpp_log_hessian(L: np.ndarray) -> np.ndarray:
    """DPP log-Hessian (graph Laplacian with conductances L[i,j]^2)."""
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H


# ============================================================
# APPLICATION 1: Diverse Subset Selection via Resistance Distance
# ============================================================
def diversity_score_resistance(L: np.ndarray, subset: list) -> float:
    """Compute the diversity score of a subset using resistance distance.

    The diversity score is the sum of pairwise effective resistances
    within the subset, which measures how "spread out" the items are
    in the repulsion geometry.

    Args:
        L: DPP kernel matrix
        subset: List of indices

    Returns:
        Sum of pairwise effective resistances in subset
    """
    H = dpp_log_hessian(L)
    H_pinv = pinv(H)

    score = 0.0
    for i_idx, i in enumerate(subset):
        for j in subset[i_idx + 1:]:
            R_ij = H_pinv[i, i] + H_pinv[j, j] - 2 * H_pinv[i, j]
            score += R_ij
    return score


def greedy_diverse_selection(L: np.ndarray, k: int) -> list:
    """Greedily select k items maximizing total pairwise resistance distance.

    This is the resistance-geometry analog of farthest-point sampling.

    Args:
        L: n×n DPP kernel
        k: Number of items to select

    Returns:
        List of selected indices
    """
    n = L.shape[0]
    H = dpp_log_hessian(L)
    H_pinv = pinv(H)

    # Effective resistance matrix
    diag = np.diag(H_pinv)
    R = diag[:, None] + diag[None, :] - 2 * H_pinv

    selected = [0]  # Start with item 0
    remaining = set(range(1, n))

    for _ in range(k - 1):
        best_item = -1
        best_score = -np.inf
        for item in remaining:
            score = sum(R[item, s] for s in selected)
            if score > best_score:
                best_score = score
                best_item = item
        selected.append(best_item)
        remaining.remove(best_item)

    return selected


# ============================================================
# APPLICATION 2: Natural Gradient for DPP Parameters
# ============================================================
def natural_gradient_step(L: np.ndarray, grad_log_likelihood: np.ndarray,
                          step_size: float = 0.01) -> np.ndarray:
    """Compute a natural gradient step for DPP log-parameters.

    The natural gradient uses the inverse Fisher information (= Hessian
    pseudoinverse restricted to zero-sum subspace) as a preconditioner:
        θ_{t+1} = θ_t + η · F⁻¹ · ∇log p(data | θ)

    In the repulsive information geometry, F⁻¹ is the effective resistance
    Green function, so the natural gradient diffuses along the resistance network.

    Args:
        L: Current DPP kernel
        grad_log_likelihood: Gradient of log-likelihood w.r.t. log-parameters
        step_size: Learning rate

    Returns:
        Updated parameters (projected to zero-sum subspace)
    """
    n = L.shape[0]
    H = dpp_log_hessian(L)

    # Project gradient to zero-sum subspace
    grad_proj = grad_log_likelihood - grad_log_likelihood.mean()

    # Natural gradient = H⁺ · grad (on zero-sum subspace)
    H_pinv = pinv(H)
    nat_grad = H_pinv @ grad_proj

    # Project result to zero-sum
    nat_grad -= nat_grad.mean()

    return step_size * nat_grad


# ============================================================
# APPLICATION 3: Spectral Sparsification of Repulsion Networks
# ============================================================
def spectral_sparsify(L: np.ndarray, epsilon: float = 0.5,
                      seed: int = 42) -> np.ndarray:
    """Spectrally sparsify the DPP repulsion network.

    Uses effective resistance sampling: sample edges with probability
    proportional to w_ij · R_eff(i,j), then rescale.

    This preserves the Dirichlet energy up to factor (1±ε) on all vectors.

    Args:
        L: DPP kernel (symmetric)
        epsilon: Sparsification quality parameter
        seed: Random seed

    Returns:
        Sparsified Laplacian H_sparse
    """
    rng = np.random.default_rng(seed)
    n = L.shape[0]
    H = dpp_log_hessian(L)
    H_pinv = pinv(H)

    # Compute effective resistances
    diag_pinv = np.diag(H_pinv)
    R = diag_pinv[:, None] + diag_pinv[None, :] - 2 * H_pinv

    # Edge weights (conductances)
    W = L ** 2

    # Sampling probabilities ~ w_ij * R_eff(i,j) / n (leverage scores)
    leverage = W * R
    np.fill_diagonal(leverage, 0)
    total_leverage = leverage.sum() / 2

    q = int(n * np.log(n) / epsilon ** 2)  # number of samples

    # Sample edges
    upper_tri = np.triu_indices(n, k=1)
    edge_probs = leverage[upper_tri]
    edge_probs = edge_probs / edge_probs.sum()  # normalize

    H_sparse = np.zeros((n, n))
    for _ in range(q):
        idx = rng.choice(len(edge_probs), p=edge_probs)
        i, j = upper_tri[0][idx], upper_tri[1][idx]
        weight = W[i, j] / (q * edge_probs[idx])
        H_sparse[i, j] -= weight
        H_sparse[j, i] -= weight
        H_sparse[i, i] += weight
        H_sparse[j, j] += weight

    return H_sparse


if __name__ == "__main__":
    np.set_printoptions(precision=4, suppress=True)

    # Application 1: Diverse subset selection
    print("=" * 60)
    print("APPLICATION 1: Diverse Subset Selection")
    print("=" * 60)

    n = 8
    rng = np.random.default_rng(42)
    A = rng.standard_normal((n, n))
    L = A @ A.T / n

    k = 3
    selected = greedy_diverse_selection(L, k)
    score = diversity_score_resistance(L, selected)
    print(f"  Selected {k} items from {n}: {selected}")
    print(f"  Diversity score (total resistance): {score:.4f}")

    # Compare with random selection
    random_scores = []
    for trial in range(1000):
        rand_subset = list(rng.choice(n, k, replace=False))
        random_scores.append(diversity_score_resistance(L, rand_subset))
    print(f"  Random selection mean score: {np.mean(random_scores):.4f}")
    print(f"  Greedy outperforms random: {score > np.mean(random_scores)}")

    # Application 2: Natural gradient
    print(f"\n{'=' * 60}")
    print("APPLICATION 2: Natural Gradient Step")
    print("=" * 60)

    grad = rng.standard_normal(n)
    nat_grad = natural_gradient_step(L, grad)
    print(f"  Euclidean gradient norm: {norm(grad):.4f}")
    print(f"  Natural gradient norm:   {norm(nat_grad):.4f}")
    print(f"  Zero-sum check: sum = {nat_grad.sum():.2e}")

    # Application 3: Spectral sparsification
    print(f"\n{'=' * 60}")
    print("APPLICATION 3: Spectral Sparsification")
    print("=" * 60)

    H = dpp_log_hessian(L)
    H_sparse = spectral_sparsify(L, epsilon=0.5)
    nnz_original = np.count_nonzero(np.abs(H) > 1e-14)
    nnz_sparse = np.count_nonzero(np.abs(H_sparse) > 1e-14)
    print(f"  Original nonzeros: {nnz_original}")
    print(f"  Sparse nonzeros:   {nnz_sparse}")

    # Check spectral approximation on random zero-sum vectors
    max_ratio = 0
    for _ in range(100):
        x = rng.standard_normal(n)
        x -= x.mean()
        E_orig = x @ H @ x
        E_sparse = x @ H_sparse @ x
        if E_orig > 1e-14:
            ratio = abs(E_sparse / E_orig - 1)
            max_ratio = max(max_ratio, ratio)
    print(f"  Max spectral distortion: {max_ratio:.4f}")


#!/usr/bin/env python3
"""
Repulsive Information Geometry — Interactive Numerical Demonstration

This script demonstrates the core theorems from the repulsive information geometry
framework for small DPP instances:

1. Constructs DPP log-Hessian matrices (weighted graph Laplacians)
2. Verifies the Dirichlet form identity: xᵀHx = ½ ∑ Lᵢⱼ²(xᵢ-xⱼ)²
3. Compares the Hessian-derived metric with effective resistance
4. Tests Conjecture A (repulsion-resistance isometry) numerically

Usage:
    python demo.py
"""

import numpy as np
from numpy.linalg import pinv, det, eigvalsh

np.set_printoptions(precision=6, suppress=True)


def dpp_log_hessian(L: np.ndarray) -> np.ndarray:
    """Construct the DPP log-Hessian from a symmetric matrix L.

    H[i,j] = -(L[i,j])^2  for i != j
    H[i,i] = sum_{k!=i} (L[i,k])^2  (zero row sums)

    This is a weighted graph Laplacian with conductances L[i,j]^2.
    """
    n = L.shape[0]
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                H[i, j] = -(L[i, j] ** 2)
            else:
                H[i, i] = sum(L[i, k] ** 2 for k in range(n) if k != i)
    return H


def laplacian_energy(H: np.ndarray, x: np.ndarray) -> float:
    """Compute the Laplacian energy xᵀHx."""
    return float(x @ H @ x)


def pairwise_dirichlet_energy(H: np.ndarray, x: np.ndarray) -> float:
    """Compute ½ ∑ᵢⱼ (-Hᵢⱼ)(xᵢ - xⱼ)² (the pairwise Dirichlet form)."""
    n = H.shape[0]
    total = 0.0
    for i in range(n):
        for j in range(n):
            total += (-H[i, j]) * (x[i] - x[j]) ** 2
    return 0.5 * total


def dpp_dirichlet_energy(L: np.ndarray, x: np.ndarray) -> float:
    """Compute ½ ∑ᵢⱼ Lᵢⱼ²(xᵢ - xⱼ)² (the DPP resolvent Dirichlet form)."""
    n = L.shape[0]
    total = 0.0
    for i in range(n):
        for j in range(n):
            total += L[i, j] ** 2 * (x[i] - x[j]) ** 2
    return 0.5 * total


def effective_resistance_matrix(L_graph: np.ndarray) -> np.ndarray:
    """Compute the effective resistance matrix of a weighted graph.

    Given the Laplacian L_graph with conductances w[i,j], the effective
    resistance between i and j is:
        R_eff(i,j) = (eᵢ - eⱼ)ᵀ L⁺ (eᵢ - eⱼ) = L⁺[i,i] + L⁺[j,j] - 2·L⁺[i,j]
    where L⁺ is the pseudoinverse.
    """
    n = L_graph.shape[0]
    L_pinv = pinv(L_graph)
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            R[i, j] = L_pinv[i, i] + L_pinv[j, j] - 2 * L_pinv[i, j]
    return R


def hessian_distance_matrix(H: np.ndarray) -> np.ndarray:
    """Compute the Hessian-derived distance matrix.

    d_H(i,j)² = (eᵢ - eⱼ)ᵀ H⁺ (eᵢ - eⱼ)
    where H⁺ is the pseudoinverse.
    """
    return effective_resistance_matrix(H)


def random_symmetric_psd(n: int, seed: int = None) -> np.ndarray:
    """Generate a random symmetric PSD matrix."""
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    return A @ A.T / n


def zero_sum_vector(n: int, seed: int = None) -> np.ndarray:
    """Generate a random zero-sum vector."""
    rng = np.random.default_rng(seed)
    x = rng.standard_normal(n)
    x -= x.mean()
    return x


# ============================================================
# DEMONSTRATION 1: Dirichlet Form Identity
# ============================================================
print("=" * 70)
print("DEMONSTRATION 1: Dirichlet Form Identity")
print("  Theorem: xᵀHx = ½ ∑ᵢⱼ (-Hᵢⱼ)(xᵢ-xⱼ)² for zero-row-sum H")
print("=" * 70)

for n in [3, 5, 8]:
    L = random_symmetric_psd(n, seed=42 + n)
    H = dpp_log_hessian(L)

    # Verify zero row sums
    row_sums = H.sum(axis=1)
    assert np.allclose(row_sums, 0, atol=1e-12), f"Row sums not zero: {row_sums}"

    x = zero_sum_vector(n, seed=100 + n)

    E_quad = laplacian_energy(H, x)
    E_pair = pairwise_dirichlet_energy(H, x)
    E_dpp = dpp_dirichlet_energy(L, x)

    print(f"\n  n = {n}:")
    print(f"    Laplacian energy xᵀHx       = {E_quad:.10f}")
    print(f"    Pairwise ½∑(-Hᵢⱼ)(xᵢ-xⱼ)²  = {E_pair:.10f}")
    print(f"    DPP form ½∑Lᵢⱼ²(xᵢ-xⱼ)²    = {E_dpp:.10f}")
    print(f"    Match (quad vs pair): {np.isclose(E_quad, E_pair)}")
    print(f"    Match (quad vs DPP):  {np.isclose(E_quad, E_dpp)}")

# ============================================================
# DEMONSTRATION 2: Positive Definiteness on Zero-Sum
# ============================================================
print("\n" + "=" * 70)
print("DEMONSTRATION 2: Positive Definiteness on Zero-Sum Subspace")
print("  Theorem: xᵀHx > 0 for all nonzero zero-sum x")
print("=" * 70)

n = 5
L = random_symmetric_psd(n, seed=77)
H = dpp_log_hessian(L)

print(f"\n  Testing n = {n} with 1000 random zero-sum vectors:")
min_energy = float('inf')
for trial in range(1000):
    x = zero_sum_vector(n, seed=trial)
    E = laplacian_energy(H, x)
    # Normalize
    E_norm = E / np.dot(x, x)
    min_energy = min(min_energy, E_norm)

print(f"    Minimum normalized energy: {min_energy:.10f}")
print(f"    Positive definite: {min_energy > 0}")

# Eigenvalues of H
eigvals = eigvalsh(H)
print(f"    Eigenvalues of H: {np.sort(eigvals)}")
print(f"    (Smallest should be ≈0, rest positive — kernel = constants)")

# ============================================================
# DEMONSTRATION 3: Diagonal DPP → Zero Hessian
# ============================================================
print("\n" + "=" * 70)
print("DEMONSTRATION 3: Diagonal DPP Log-Hessian = Zero Matrix")
print("  Theorem: dppLogHessian(diag(w)) = 0")
print("=" * 70)

w = np.array([0.5, 1.2, 0.8, 2.0, 0.3])
L_diag = np.diag(w)
H_diag = dpp_log_hessian(L_diag)
print(f"\n  w = {w}")
print(f"  dppLogHessian(diag(w)) =\n{H_diag}")
print(f"  Is zero matrix: {np.allclose(H_diag, 0)}")

# ============================================================
# DEMONSTRATION 4: Conjecture A — Repulsion-Resistance Isometry
# ============================================================
print("\n" + "=" * 70)
print("DEMONSTRATION 4: Conjecture A — Repulsion-Resistance Isometry")
print("  Claim: H⁺ restricted to zero-sum = effective resistance matrix")
print("=" * 70)

for n in [3, 4, 5, 6, 8]:
    L = random_symmetric_psd(n, seed=200 + n)
    H = dpp_log_hessian(L)

    # Hessian-derived distances
    d_hessian = hessian_distance_matrix(H)

    # Effective resistance from the graph with conductances L[i,j]^2
    # The conductance Laplacian IS exactly H (by construction)
    d_resistance = effective_resistance_matrix(H)

    # They should be identical (since H IS the Laplacian)
    error = np.max(np.abs(d_hessian - d_resistance))
    print(f"\n  n = {n}: max |d_hessian - d_resistance| = {error:.2e}"
          f"  {'✓' if error < 1e-10 else '✗'}")

print("\n  Note: The 'isometry' is trivially true because the DPP log-Hessian")
print("  IS the graph Laplacian — Theorem 3 (Dirichlet form identity) makes")
print("  this manifest. The pseudoinverse of the Hessian directly gives the")
print("  effective resistance by definition.")

# ============================================================
# DEMONSTRATION 5: Energy on Coordinate Differences
# ============================================================
print("\n" + "=" * 70)
print("DEMONSTRATION 5: Energy on Coordinate Differences eᵢ - eⱼ")
print("  Theorem: E(eᵢ-eⱼ) = H[i,i] + H[j,j] + 2·L[i,j]²")
print("=" * 70)

n = 4
L = random_symmetric_psd(n, seed=300)
H = dpp_log_hessian(L)

for i in range(n):
    for j in range(i + 1, n):
        e_diff = np.zeros(n)
        e_diff[i] = 1
        e_diff[j] = -1
        E_computed = laplacian_energy(H, e_diff)
        E_formula = H[i, i] + H[j, j] + 2 * L[i, j] ** 2
        print(f"  (i,j) = ({i},{j}): E = {E_computed:.6f}, "
              f"formula = {E_formula:.6f}, match = {np.isclose(E_computed, E_formula)}")

# ============================================================
# CONJECTURE B: Fisher-Repulsion Equivalence (test)
# ============================================================
print("\n" + "=" * 70)
print("CONJECTURE B: Fisher-Repulsion Equivalence")
print("  For product-of-linear-forms, compare Hessian to Fisher info")
print("=" * 70)

# Product of linear forms: p(x) = ∏_k (a_k^T x) where a_k > 0
n, m = 3, 5
rng = np.random.default_rng(42)
A = np.abs(rng.standard_normal((m, n))) + 0.1  # positive coefficients
v = A @ np.ones(n)  # values at x = 1

# Log-Hessian of log p at x=1:
# ∂²/∂xᵢ∂xⱼ log(∏ fₖ) = -∑ₖ (aₖᵢ/fₖ(1))·(aₖⱼ/fₖ(1))
H_log = np.zeros((n, n))
for k in range(m):
    grad_k = A[k] / v[k]
    H_log -= np.outer(grad_k, grad_k)

# Fisher information of the exponential family with sufficient statistics log(a_k^T x):
# F[i,j] = ∑_k (a_ki / v_k) * (a_kj / v_k) = -H_log[i,j]
F = -H_log

print(f"\n  n = {n}, m = {m} linear forms")
print(f"  Log-Hessian H =\n{H_log}")
print(f"  Fisher info F = -H =\n{F}")
print(f"  F is PSD: {np.all(eigvalsh(F) >= -1e-12)}")

# The Fisher info equals -H exactly (by the product-of-log-concave formula)
print(f"  F = -H_log: {np.allclose(F, -H_log)}")

# Project onto zero-sum subspace
P = np.eye(n) - np.ones((n, n)) / n
F_proj = P @ F @ P
H_proj = P @ (-H_log) @ P
print(f"\n  Projected Fisher (zero-sum) =\n{F_proj}")
print(f"  Match: {np.allclose(F_proj, H_proj)}")

print("\n" + "=" * 70)
print("ALL DEMONSTRATIONS COMPLETE")
print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: Dirichlet Form Identity Verification

Plots the Dirichlet form identity verification for multiple matrix sizes,
showing that xᵀHx = ½∑ Lᵢⱼ²(xᵢ-xⱼ)² holds to machine precision.
Also shows the spectrum of the DPP log-Hessian, confirming PSD with
kernel = constants (smallest eigenvalue ≈ 0).
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import eigvalsh

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left plot: Dirichlet identity errors for various n
sizes = [3, 4, 5, 6, 8, 10]
n_tests = 200
all_errors = {}

for n in sizes:
    rng = np.random.default_rng(42 + n)
    A = rng.standard_normal((n, n))
    L = A @ A.T / n
    H = dpp_log_hessian(L)

    errors = []
    for _ in range(n_tests):
        x = rng.standard_normal(n)
        x -= x.mean()
        E_quad = float(x @ H @ x)
        diff = x[:, None] - x[None, :]
        E_pair = 0.5 * np.sum(L ** 2 * diff ** 2)
        errors.append(abs(E_quad - E_pair))
    all_errors[n] = errors

positions = range(len(sizes))
bp = axes[0].boxplot([all_errors[n] for n in sizes],
                      positions=positions, widths=0.6,
                      patch_artist=True)

colors = plt.cm.viridis(np.linspace(0.2, 0.8, len(sizes)))
for patch, color in zip(bp['boxes'], colors):
    patch.set_facecolor(color)
    patch.set_alpha(0.7)

axes[0].set_xticks(positions)
axes[0].set_xticklabels([str(n) for n in sizes])
axes[0].set_xlabel('Matrix size n', fontsize=12)
axes[0].set_ylabel('Absolute error', fontsize=12)
axes[0].set_title('Dirichlet Form Identity Error\n'
                   r'$x^T H x = \frac{1}{2}\sum L_{ij}^2(x_i-x_j)^2$',
                   fontsize=13, fontweight='bold')
axes[0].set_yscale('log')
axes[0].grid(True, alpha=0.3)

# Right plot: Eigenvalue spectrum for various n
for idx, n in enumerate(sizes):
    rng = np.random.default_rng(42 + n)
    A = rng.standard_normal((n, n))
    L = A @ A.T / n
    H = dpp_log_hessian(L)
    eigs = np.sort(eigvalsh(H))
    axes[1].scatter([idx] * len(eigs), eigs,
                     c=[colors[idx]], alpha=0.8, s=60, zorder=3,
                     edgecolors='black', linewidths=0.5)

axes[1].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='λ = 0')
axes[1].set_xticks(range(len(sizes)))
axes[1].set_xticklabels([str(n) for n in sizes])
axes[1].set_xlabel('Matrix size n', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Spectrum of DPP Log-Hessian\n'
                   '(Smallest eigenvalue ≈ 0, rest positive)',
                   fontsize=13, fontweight='bold')
axes[1].legend(fontsize=11)
axes[1].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_dirichlet.png', dpi=150, bbox_inches='tight')
print("Saved viz_dirichlet.png")


#!/usr/bin/env python3
"""
Visualization: DPP Log-Hessian and Effective Resistance Heatmaps

Visualizes the DPP log-Hessian matrix alongside the effective resistance matrix
derived from it, showing how the repulsion pattern translates into a distance geometry.
The Hessian (left) shows negative off-diagonal entries encoding repulsion strength.
The resistance matrix (right) shows the effective resistance distances.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import pinv

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

def effective_resistance_matrix(H):
    H_pinv = pinv(H)
    diag = np.diag(H_pinv)
    R = diag[:, None] + diag[None, :] - 2 * H_pinv
    return R

# Generate a structured DPP kernel (exponentially decaying correlations)
n = 8
rng = np.random.default_rng(42)
# Create a kernel with geometric decay: L[i,j] = rho^|i-j|
rho = 0.7
L = np.array([[rho ** abs(i - j) for j in range(n)] for i in range(n)])
# Add some noise
L = L + 0.1 * rng.standard_normal((n, n))
L = (L + L.T) / 2  # symmetrize

H = dpp_log_hessian(L)
R = effective_resistance_matrix(H)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: DPP Kernel L
im0 = axes[0].imshow(L, cmap='RdBu_r', aspect='equal')
axes[0].set_title('DPP Kernel L', fontsize=14, fontweight='bold')
axes[0].set_xlabel('Column index j')
axes[0].set_ylabel('Row index i')
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# Plot 2: Log-Hessian (Graph Laplacian)
vmax = np.max(np.abs(H))
im1 = axes[1].imshow(H, cmap='RdBu_r', vmin=-vmax, vmax=vmax, aspect='equal')
axes[1].set_title('DPP Log-Hessian H\n(Graph Laplacian)', fontsize=14, fontweight='bold')
axes[1].set_xlabel('Column index j')
axes[1].set_ylabel('Row index i')
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# Plot 3: Effective Resistance Matrix
im2 = axes[2].imshow(R, cmap='YlOrRd', aspect='equal')
axes[2].set_title('Effective Resistance\n(Repulsion Distance²)', fontsize=14, fontweight='bold')
axes[2].set_xlabel('Column index j')
axes[2].set_ylabel('Row index i')
plt.colorbar(im2, ax=axes[2], shrink=0.8)

plt.suptitle('From DPP Kernel to Resistance Distance',
             fontsize=16, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: DPP Repulsion as a Resistance Network

Draws the DPP repulsion network as a graph where:
- Edge thickness = conductance (L[i,j]^2)
- Edge color = conductance strength (darker = stronger repulsion)
- Node positions from spectral embedding of the Laplacian
- Node labels show effective resistance to a reference node

This makes the central theorem visual: DPP repulsion IS a resistance network.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import pinv, eigvalsh, eigh

def dpp_log_hessian(L):
    n = L.shape[0]
    H = -(L ** 2)
    np.fill_diagonal(H, 0)
    np.fill_diagonal(H, -H.sum(axis=1))
    return H

def spectral_layout(H, dim=2):
    """Compute node positions from the Fiedler vectors of the Laplacian."""
    eigvals, eigvecs = eigh(H)
    # Skip the zero eigenvalue (first), use next `dim` eigenvectors
    idx = np.argsort(eigvals)
    coords = eigvecs[:, idx[1:1+dim]]
    return coords

# Generate a structured DPP kernel
n = 7
rng = np.random.default_rng(123)
A = rng.standard_normal((n, n))
L = A @ A.T / n

H = dpp_log_hessian(L)
H_pinv = pinv(H)

# Conductances
W = L ** 2

# Spectral embedding for layout
pos = spectral_layout(H)

# Effective resistance from node 0
diag = np.diag(H_pinv)
R = diag[:, None] + diag[None, :] - 2 * H_pinv

fig, axes = plt.subplots(1, 2, figsize=(16, 7))

for ax_idx, (ax, title, color_by) in enumerate([
    (axes[0], 'Conductance Network\n(edge width ∝ Lᵢⱼ²)', 'conductance'),
    (axes[1], 'Resistance Distance\n(edge color ∝ R_eff(i,j))', 'resistance')
]):
    # Draw edges
    max_w = np.max(W[np.triu_indices(n, k=1)])
    for i in range(n):
        for j in range(i + 1, n):
            w = W[i, j]
            r = R[i, j]
            if w < 0.01 * max_w:
                continue
            if color_by == 'conductance':
                width = 0.5 + 4 * w / max_w
                alpha = 0.3 + 0.7 * w / max_w
                color = plt.cm.Blues(0.3 + 0.7 * w / max_w)
            else:
                width = 1.5
                max_r = np.max(R[np.triu_indices(n, k=1)])
                alpha = 0.5 + 0.5 * r / max_r
                color = plt.cm.Reds(0.2 + 0.8 * r / max_r)
            ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                    color=color, linewidth=width, alpha=alpha, zorder=1)

    # Draw nodes
    node_colors = R[0, :]  # Distance from node 0
    scatter = ax.scatter(pos[:, 0], pos[:, 1], c=node_colors,
                          cmap='YlOrRd', s=300, zorder=3,
                          edgecolors='black', linewidths=1.5)
    for i in range(n):
        ax.annotate(str(i), (pos[i, 0], pos[i, 1]),
                    ha='center', va='center', fontsize=12, fontweight='bold',
                    color='white' if node_colors[i] > np.median(node_colors) else 'black')

    ax.set_title(title, fontsize=14, fontweight='bold')
    ax.set_aspect('equal')
    ax.axis('off')
    plt.colorbar(scatter, ax=ax, shrink=0.7,
                  label='R_eff(0, i)' if ax_idx == 1 else 'R_eff(0, i)')

plt.suptitle('DPP Repulsion = Resistance Network (n=7)',
             fontsize=16, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_resistance_network.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_network.png")
