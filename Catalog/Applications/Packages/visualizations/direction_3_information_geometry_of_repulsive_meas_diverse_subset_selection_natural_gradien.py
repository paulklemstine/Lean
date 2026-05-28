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
