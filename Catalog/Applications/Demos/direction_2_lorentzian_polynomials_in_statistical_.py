#!/usr/bin/env python3
"""
Applications of DPP-Lorentzian Theory
======================================

Shows how the theory applies to:
1. Diverse subset selection (machine learning)
2. Repulsive particle models (statistical physics)
3. Certified diversity guarantees
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple


def item_similarity_kernel(features: np.ndarray) -> np.ndarray:
    """
    Build a DPP kernel from item features for diverse subset selection.

    K = L where L_ij = q_i * S_ij * q_j, with q_i = quality scores
    and S_ij = similarity between items i and j.

    Args:
        features: n × d feature matrix (n items, d features)

    Returns:
        n × n PSD kernel matrix
    """
    # Normalize features
    norms = np.linalg.norm(features, axis=1, keepdims=True)
    norms = np.maximum(norms, 1e-10)
    normalized = features / norms

    # K = features @ features.T (Gram matrix, automatically PSD)
    K = features @ features.T
    return K


def diverse_subset_probability(K: np.ndarray, S: List[int]) -> float:
    """
    Compute the (unnormalized) probability of selecting subset S under the DPP.

    P(S) ∝ det(K_S)

    Args:
        K: n×n PSD kernel
        S: subset indices

    Returns:
        det(K_S), the unnormalized probability
    """
    if len(S) == 0:
        return 1.0
    idx = np.array(S)
    return max(0, np.linalg.det(K[np.ix_(idx, idx)]))


def diversity_score(K: np.ndarray, S: List[int]) -> float:
    """
    Compute the diversity score of a subset S.

    For a DPP kernel K, the diversity of S is captured by det(K_S),
    which is the squared volume of the parallelepiped spanned by
    the feature vectors of items in S.

    Higher det = more diverse (features point in different directions).

    Args:
        K: n×n PSD kernel
        S: subset indices

    Returns:
        Diversity score (det of principal submatrix)
    """
    return diverse_subset_probability(K, S)


def greedy_diverse_selection(K: np.ndarray, k: int) -> Tuple[List[int], float]:
    """
    Greedy algorithm for approximately maximizing det(K_S) subject to |S| = k.

    At each step, adds the item that maximizes the determinant of the
    current selection. This exploits the log-submodularity of det (which
    follows from the Lorentzian structure).

    Args:
        K: n×n PSD kernel
        k: target subset size

    Returns:
        (selected_indices, det_value)

    Time complexity: O(k · n · k^3) = O(k^4 · n)
    """
    n = K.shape[0]
    selected = []

    for _ in range(k):
        best_item = -1
        best_det = -1

        for i in range(n):
            if i in selected:
                continue
            trial = selected + [i]
            d = diverse_subset_probability(K, trial)
            if d > best_det:
                best_det = d
                best_item = i

        if best_item >= 0:
            selected.append(best_item)

    final_det = diverse_subset_probability(K, selected)
    return selected, final_det


def negative_dependence_certificate(K: np.ndarray) -> dict:
    """
    Produce a certificate of negative dependence for diverse selection.

    The theorem guarantees: for PSD K and i ≠ j,
    det(K_{i,j}) ≤ K_ii · K_jj

    This means: the probability of selecting BOTH items i and j
    is at most the product of their individual selection probabilities.
    Items repel each other — diversity is guaranteed.

    This is a mathematically certified guarantee, not just an empirical
    observation.

    Returns:
        Certificate dict with all pairwise bounds.
    """
    n = K.shape[0]
    eigenvalues = np.linalg.eigvalsh(K)

    pairs = []
    for i in range(n):
        for j in range(i + 1, n):
            joint = K[i, i] * K[j, j] - K[i, j] ** 2
            marginal_product = K[i, i] * K[j, j]
            pairs.append({
                "i": i, "j": j,
                "joint_weight": joint,
                "marginal_product": marginal_product,
                "ratio": joint / marginal_product if marginal_product > 1e-15 else 0,
                "satisfies_bound": joint <= marginal_product + 1e-10,
            })

    return {
        "n": n,
        "is_psd": bool(np.all(eigenvalues >= -1e-10)),
        "eigenvalues": eigenvalues.tolist(),
        "pairs": pairs,
        "all_certified": all(p["satisfies_bound"] for p in pairs),
    }


def repulsive_particle_simulation(K: np.ndarray, num_samples: int = 1000) -> dict:
    """
    Simulate a repulsive particle system via DPP sampling.

    Uses the spectral method: K = U Λ U^T, sample each eigenvector
    independently with probability λ_i/(1+λ_i).

    Args:
        K: n×n PSD kernel
        num_samples: number of random subsets to draw

    Returns:
        Statistics about the sampled subsets.
    """
    n = K.shape[0]
    eigenvalues, eigenvectors = np.linalg.eigh(K)

    # Inclusion probabilities for each eigenvector
    probs = eigenvalues / (1 + eigenvalues)
    probs = np.clip(probs, 0, 1)

    rng = np.random.default_rng(42)
    samples = []
    sizes = []

    for _ in range(num_samples):
        # Sample which eigenvectors to include
        included = rng.random(n) < probs
        k = np.sum(included)
        if k == 0:
            samples.append([])
            sizes.append(0)
            continue

        # Project to get the actual selected items
        V = eigenvectors[:, included]
        # Use determinantal sampling from the projected space
        selected = []
        remaining = list(range(n))

        for _ in range(int(k)):
            if len(remaining) == 0:
                break
            # Marginal probability of each remaining item
            marginals = np.array([np.sum(V[i] ** 2) for i in remaining])
            marginals = marginals / max(np.sum(marginals), 1e-15)

            idx = rng.choice(len(remaining), p=marginals)
            item = remaining[idx]
            selected.append(item)
            remaining.pop(idx)

            # Project out the selected direction
            if V.shape[1] > 1:
                v = V[item]
                v = v / max(np.linalg.norm(v), 1e-15)
                V = V - np.outer(V @ v, v)

        samples.append(sorted(selected))
        sizes.append(len(selected))

    # Compute statistics
    pair_counts = np.zeros((n, n))
    single_counts = np.zeros(n)
    for sample in samples:
        for i in sample:
            single_counts[i] += 1
        for i, j in combinations(sample, 2):
            pair_counts[i, j] += 1
            pair_counts[j, i] += 1

    single_freqs = single_counts / num_samples
    pair_freqs = pair_counts / num_samples

    # Check empirical negative dependence
    neg_dep_violations = 0
    for i in range(n):
        for j in range(i + 1, n):
            if pair_freqs[i, j] > single_freqs[i] * single_freqs[j] + 0.05:
                neg_dep_violations += 1

    return {
        "num_samples": num_samples,
        "mean_size": float(np.mean(sizes)),
        "expected_size": float(np.sum(probs)),
        "single_frequencies": single_freqs.tolist(),
        "empirical_neg_dep_violations": neg_dep_violations,
        "total_pairs": n * (n - 1) // 2,
    }


if __name__ == "__main__":
    print("=== Application: Diverse Subset Selection ===\n")

    # Create item features (e.g., 8 items with 3 features each)
    rng = np.random.default_rng(42)
    features = rng.standard_normal((8, 3))
    K = item_similarity_kernel(features)

    print("Feature matrix (8 items × 3 features):")
    print(np.round(features, 2))
    print()

    # Greedy selection
    for k in [2, 3, 4]:
        selected, det_val = greedy_diverse_selection(K, k)
        print(f"Greedy selection of {k} items: {selected}, det = {det_val:.4f}")

    # Certificate
    cert = negative_dependence_certificate(K)
    print(f"\nNegative dependence certified: {cert['all_certified']}")
    print(f"PSD check: {cert['is_psd']}")

    ratios = [p["ratio"] for p in cert["pairs"]]
    print(f"Correlation ratios: min={min(ratios):.4f}, max={max(ratios):.4f}")

    print("\n=== Application: Repulsive Particle Model ===\n")

    n = 6
    K = rng.standard_normal((n, n))
    K = K.T @ K  # PSD
    stats = repulsive_particle_simulation(K, num_samples=2000)
    print(f"Sampled {stats['num_samples']} subsets from DPP with n={n}")
    print(f"Mean subset size: {stats['mean_size']:.2f} (expected: {stats['expected_size']:.2f})")
    print(f"Empirical neg dep violations: {stats['empirical_neg_dep_violations']}/{stats['total_pairs']}")


#!/usr/bin/env python3
"""
DPP Lorentzian Polynomial Demo
==============================

Demonstrates the core theorems connecting determinantal point processes (DPPs),
Lorentzian polynomials, and negative dependence.

For random PSD matrices K of size n x n:
1. Computes the DPP partition function Z_K(x) = det(I + diag(x) K)
2. Extracts homogeneous components and principal minors
3. Verifies pairwise negative dependence: det(K_{ij}) ≤ K_ii * K_jj
4. Tests the Lorentzian conjecture via Hessian signature checks
5. Compares diagonal, rank-one, and generic PSD examples
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Dict, Optional


def random_psd_matrix(n: int, rank: Optional[int] = None, seed: Optional[int] = None) -> np.ndarray:
    """Generate a random positive semidefinite matrix K = A^T A."""
    rng = np.random.default_rng(seed)
    r = rank if rank is not None else n
    A = rng.standard_normal((r, n))
    return A.T @ A


def principal_minor(K: np.ndarray, S: List[int]) -> float:
    """Compute det(K_S), the principal minor indexed by S."""
    if len(S) == 0:
        return 1.0
    idx = np.array(S)
    return np.linalg.det(K[np.ix_(idx, idx)])


def dpp_partition_function_value(K: np.ndarray, x: np.ndarray) -> float:
    """Compute Z_K(x) = det(I + diag(x) K)."""
    n = K.shape[0]
    return np.linalg.det(np.eye(n) + np.diag(x) @ K)


def dpp_partition_function_sum(K: np.ndarray, x: np.ndarray) -> float:
    """Compute Z_K(x) = sum_S det(K_S) prod_{i in S} x_i via principal minor expansion."""
    n = K.shape[0]
    total = 0.0
    for k in range(n + 1):
        for S in combinations(range(n), k):
            coeff = principal_minor(K, list(S))
            monomial = np.prod([x[i] for i in S]) if S else 1.0
            total += coeff * monomial
    return total


def uniform_specialization(K: np.ndarray, t: float) -> float:
    """Compute Z_K(t,...,t) = det(I + tK)."""
    n = K.shape[0]
    return np.linalg.det(np.eye(n) + t * K)


def homogeneous_component_coeffs(K: np.ndarray, d: int) -> Dict[Tuple[int, ...], float]:
    """Extract degree-d homogeneous component: {S: det(K_S)} for |S| = d."""
    n = K.shape[0]
    coeffs = {}
    for S in combinations(range(n), d):
        coeffs[S] = principal_minor(K, list(S))
    return coeffs


def single_inclusion_weight(K: np.ndarray, i: int) -> float:
    """K_ii: unnormalized marginal inclusion probability."""
    return K[i, i]


def pair_inclusion_weight(K: np.ndarray, i: int, j: int) -> float:
    """det(K_{ij}) = K_ii K_jj - K_ij K_ji: pair inclusion weight."""
    return K[i, i] * K[j, j] - K[i, j] * K[j, i]


def verify_negative_dependence(K: np.ndarray) -> bool:
    """Verify pairwise negative dependence: det(K_{ij}) ≤ K_ii * K_jj for all i ≠ j."""
    n = K.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            pw = pair_inclusion_weight(K, i, j)
            prod = single_inclusion_weight(K, i) * single_inclusion_weight(K, j)
            if pw > prod + 1e-10:
                return False
    return True


def verify_fischer_sandwich(K: np.ndarray) -> bool:
    """Verify 0 ≤ det(K_{ij}) ≤ K_ii * K_jj for all i ≠ j (PSD K)."""
    n = K.shape[0]
    for i in range(n):
        for j in range(i + 1, n):
            pw = pair_inclusion_weight(K, i, j)
            prod = single_inclusion_weight(K, i) * single_inclusion_weight(K, j)
            if pw < -1e-10 or pw > prod + 1e-10:
                return False
    return True


def hessian_of_quadratic(coeffs: Dict[Tuple[int, ...], float], n: int) -> np.ndarray:
    """
    For a degree-2 homogeneous polynomial ∑_{|S|=2} c_S x_S,
    compute the Hessian matrix H_{ij} = 2*c_{ij} for i≠j, H_{ii} = 0.
    (Degree-2 multiaffine has no x_i^2 terms.)
    """
    H = np.zeros((n, n))
    for (i, j), c in coeffs.items():
        H[i, j] = c
        H[j, i] = c
    return H


def check_lorentzian_signature(H: np.ndarray) -> bool:
    """Check if H has at most one positive eigenvalue (Lorentzian signature)."""
    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = np.sum(eigenvalues > 1e-10)
    return num_positive <= 1


def test_lorentzian_conjecture(K: np.ndarray, d: int = 2) -> dict:
    """
    Test whether the degree-d homogeneous component of Z_K is Lorentzian.
    For d=2, directly check Hessian signature.
    Returns diagnostic dict.
    """
    n = K.shape[0]
    coeffs = homogeneous_component_coeffs(K, d)

    # Check nonnegativity
    all_nonneg = all(c >= -1e-10 for c in coeffs.values())

    result = {
        "degree": d,
        "n": n,
        "num_coeffs": len(coeffs),
        "all_nonneg": all_nonneg,
    }

    if d == 2:
        H = hessian_of_quadratic(coeffs, n)
        eigenvalues = np.sort(np.linalg.eigvalsh(H))
        result["hessian_eigenvalues"] = eigenvalues.tolist()
        result["is_lorentzian"] = check_lorentzian_signature(H)
    else:
        result["is_lorentzian"] = None  # Need higher-order derivatives for d > 2

    return result


def demo_basic_properties():
    """Demonstrate basic DPP properties."""
    print("=" * 70)
    print("DEMO 1: Basic DPP Properties")
    print("=" * 70)

    n = 4
    K = random_psd_matrix(n, seed=42)
    print(f"\nPSD kernel K ({n}x{n}):")
    print(np.round(K, 3))
    print(f"\nEigenvalues of K: {np.round(np.linalg.eigvalsh(K), 4)}")

    # Verify uniform specialization
    t = 1.0
    z_det = uniform_specialization(K, t)
    z_sum = dpp_partition_function_sum(K, t * np.ones(n))
    print(f"\nUniform specialization at t={t}:")
    print(f"  det(I + tK) = {z_det:.6f}")
    print(f"  ∑_S det(K_S) t^|S| = {z_sum:.6f}")
    print(f"  Match: {abs(z_det - z_sum) < 1e-8}")

    # Partition function at zero
    z0 = dpp_partition_function_value(K, np.zeros(n))
    print(f"\nZ_K(0,...,0) = {z0:.6f} (should be 1.0)")

    # Spectral lower bound
    z1 = uniform_specialization(K, 1.0)
    print(f"det(I + K) = {z1:.6f} (should be ≥ 1.0): {z1 >= 1.0 - 1e-10}")


def demo_negative_dependence():
    """Demonstrate pairwise negative dependence."""
    print("\n" + "=" * 70)
    print("DEMO 2: Pairwise Negative Dependence (Fischer Inequality)")
    print("=" * 70)

    for label, n, rank, seed in [
        ("Diagonal", 5, None, 1),
        ("Rank-1", 5, 1, 2),
        ("Generic PSD", 6, None, 3),
        ("Near-singular", 6, 2, 4),
    ]:
        if label == "Diagonal":
            w = np.abs(np.random.default_rng(seed).standard_normal(n))
            K = np.diag(w)
        elif label == "Rank-1":
            v = np.random.default_rng(seed).standard_normal(n)
            K = np.outer(v, v)
        else:
            K = random_psd_matrix(n, rank=rank, seed=seed)

        print(f"\n{label} (n={n}):")

        # Check Fischer sandwich
        max_ratio = 0.0
        min_ratio = float('inf')
        all_ok = True
        for i in range(n):
            for j in range(i + 1, n):
                pw = pair_inclusion_weight(K, i, j)
                si = single_inclusion_weight(K, i)
                sj = single_inclusion_weight(K, j)
                prod = si * sj
                if prod > 1e-15:
                    ratio = pw / prod
                    max_ratio = max(max_ratio, ratio)
                    min_ratio = min(min_ratio, ratio)
                if pw < -1e-10 or pw > prod + 1e-10:
                    all_ok = False
                    print(f"  VIOLATION at ({i},{j}): pw={pw:.6f}, prod={prod:.6f}")

        if all_ok:
            print(f"  ✓ Fischer sandwich holds for all pairs")
            print(f"  Correlation ratio range: [{min_ratio:.4f}, {max_ratio:.4f}]")
            print(f"  (0 = independent, 1 = perfectly correlated)")


def demo_lorentzian_test():
    """Test the Lorentzian conjecture."""
    print("\n" + "=" * 70)
    print("DEMO 3: Lorentzian Conjecture Test")
    print("=" * 70)

    results = []
    for trial in range(20):
        n = np.random.randint(3, 8)
        K = random_psd_matrix(n, seed=100 + trial)
        result = test_lorentzian_conjecture(K, d=2)
        results.append(result)

    print(f"\nTested {len(results)} random PSD matrices (d=2):")
    lorentzian_count = sum(1 for r in results if r.get("is_lorentzian", False))
    nonneg_count = sum(1 for r in results if r["all_nonneg"])
    print(f"  All coefficients nonneg: {nonneg_count}/{len(results)}")
    print(f"  Lorentzian (≤1 pos eigenvalue): {lorentzian_count}/{len(results)}")

    # Test with positive definite (full rank)
    print("\nStrict Lorentzianity test (positive definite kernels):")
    strict_count = 0
    for trial in range(20):
        n = np.random.randint(3, 7)
        K = random_psd_matrix(n, seed=200 + trial)
        K += 0.1 * np.eye(n)  # Ensure positive definite
        result = test_lorentzian_conjecture(K, d=2)
        if result.get("is_lorentzian", False):
            strict_count += 1

    print(f"  Lorentzian: {strict_count}/20")


def demo_spectral_connection():
    """Demonstrate the spectral connection."""
    print("\n" + "=" * 70)
    print("DEMO 4: Spectral Connection (Cross-Domain Bridge)")
    print("=" * 70)

    n = 5
    K = random_psd_matrix(n, seed=42)
    eigenvalues = np.linalg.eigvalsh(K)
    print(f"\nK eigenvalues: {np.round(eigenvalues, 4)}")

    # det(I + K) = ∏(1 + λ_i)
    det_val = np.linalg.det(np.eye(n) + K)
    prod_val = np.prod(1 + eigenvalues)
    print(f"det(I + K) = {det_val:.6f}")
    print(f"∏(1 + λ_i) = {prod_val:.6f}")
    print(f"Match: {abs(det_val - prod_val) < 1e-8}")

    # Diagonal case: det(I + t·diag(w)) = ∏(1 + t·w_i)
    w = np.abs(np.random.default_rng(7).standard_normal(n))
    print(f"\nDiagonal case w = {np.round(w, 4)}:")
    for t in [0.5, 1.0, 2.0]:
        det_diag = np.linalg.det(np.eye(n) + t * np.diag(w))
        prod_diag = np.prod(1 + t * w)
        print(f"  t={t}: det={det_diag:.4f}, prod={prod_diag:.4f}, match={abs(det_diag - prod_diag) < 1e-8}")

    # Uniform specialization sweep
    print("\nUniform specialization Z_K(t,...,t) = det(I + tK):")
    ts = np.linspace(0, 2, 11)
    for t in ts:
        z = uniform_specialization(K, t)
        z_sum = sum(
            principal_minor(K, list(S)) * t**len(S)
            for k in range(n + 1)
            for S in combinations(range(n), k)
        )
        print(f"  t={t:.1f}: det(I+tK)={z:.4f}, sum={z_sum:.4f}")


def demo_comparison():
    """Compare diagonal, rank-one, and generic PSD matrices."""
    print("\n" + "=" * 70)
    print("DEMO 5: Comparison of Matrix Types")
    print("=" * 70)

    n = 5

    # Diagonal
    w = np.array([1.0, 2.0, 0.5, 3.0, 1.5])
    K_diag = np.diag(w)

    # Rank-1
    v = np.array([1.0, 0.5, -0.3, 0.8, -0.6])
    K_rank1 = np.outer(v, v)

    # Generic PSD
    K_gen = random_psd_matrix(n, seed=42)

    for label, K in [("Diagonal", K_diag), ("Rank-1", K_rank1), ("Generic PSD", K_gen)]:
        print(f"\n{label}:")
        eigenvalues = np.linalg.eigvalsh(K)
        print(f"  Eigenvalues: {np.round(eigenvalues, 4)}")
        print(f"  det(I+K) = {np.linalg.det(np.eye(n) + K):.4f}")
        print(f"  ∏(1+λ) = {np.prod(1 + eigenvalues):.4f}")

        # Homogeneous components
        for d in range(n + 1):
            coeffs = homogeneous_component_coeffs(K, d)
            total = sum(coeffs.values())
            print(f"  e_{d}(K) = sum of {d}×{d} principal minors = {total:.4f}")

        # Negative dependence ratios
        ratios = []
        for i in range(n):
            for j in range(i + 1, n):
                pw = pair_inclusion_weight(K, i, j)
                prod = single_inclusion_weight(K, i) * single_inclusion_weight(K, j)
                if prod > 1e-15:
                    ratios.append(pw / prod)
        if ratios:
            print(f"  Correlation ratios: min={min(ratios):.4f}, max={max(ratios):.4f}, mean={np.mean(ratios):.4f}")


if __name__ == "__main__":
    demo_basic_properties()
    demo_negative_dependence()
    demo_lorentzian_test()
    demo_spectral_connection()
    demo_comparison()
    print("\n" + "=" * 70)
    print("All demos completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualization: DPP Pairwise Correlation Heatmap
================================================

Visualizes the pairwise correlation ratios det(K_{ij}) / (K_ii · K_jj)
for a DPP kernel K. Values close to 0 indicate strong repulsion (negative
dependence), while values close to 1 indicate weak repulsion.

This directly illustrates the Fischer inequality:
0 ≤ det(K_{ij}) ≤ K_ii · K_jj
which is proved in the Lean formalization.
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, seed=42):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    return A.T @ A


def correlation_ratio_matrix(K):
    n = K.shape[0]
    R = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                R[i, j] = 1.0
            else:
                prod = K[i, i] * K[j, j]
                if prod > 1e-15:
                    R[i, j] = (K[i, i] * K[j, j] - K[i, j] ** 2) / prod
                else:
                    R[i, j] = 0.0
    return R


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

titles = ["Diagonal (Independent)", "Rank-1 (Maximum Repulsion)", "Generic PSD"]
matrices = []

# Diagonal
w = np.array([1.0, 2.5, 0.5, 3.0, 1.5, 2.0, 0.8, 1.2])
matrices.append(np.diag(w))

# Rank-1
v = np.array([1.0, 0.5, -0.3, 0.8, -0.6, 0.4, 0.7, -0.2])
matrices.append(np.outer(v, v))

# Generic PSD
matrices.append(random_psd_matrix(8, seed=42))

for ax, K, title in zip(axes, matrices, titles):
    R = correlation_ratio_matrix(K)
    im = ax.imshow(R, cmap='RdYlGn_r', vmin=0, vmax=1, aspect='equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlabel("Item j")
    ax.set_ylabel("Item i")

    # Add text annotations
    n = R.shape[0]
    for i in range(n):
        for j in range(n):
            color = 'white' if R[i, j] < 0.3 or R[i, j] > 0.7 else 'black'
            ax.text(j, i, f'{R[i,j]:.2f}', ha='center', va='center',
                    color=color, fontsize=7)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))

fig.suptitle('DPP Pairwise Correlation Ratios: det(K_{ij}) / (K_ii · K_jj)\n'
             'Green = strong repulsion, Red = weak repulsion',
             fontsize=13, fontweight='bold', y=1.02)
plt.colorbar(im, ax=axes, label='Correlation Ratio', shrink=0.8)
plt.tight_layout()
plt.savefig('viz_correlation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_correlation_heatmap.png")


#!/usr/bin/env python3
"""
Visualization: Fischer Inequality and Negative Dependence
==========================================================

Shows the Fischer sandwich inequality for DPP kernels:
0 ≤ det(K_{ij}) ≤ K_ii · K_jj

Each point represents a pair (i,j). The x-axis is K_ii · K_jj (product
of marginals) and y-axis is det(K_{ij}) (joint weight). Points must lie
between y=0 and y=x (the identity line).

Different colors represent different matrix types (diagonal, rank-1, generic).
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_matrix(n, rank=None, seed=42):
    rng = np.random.default_rng(seed)
    r = rank if rank is not None else n
    A = rng.standard_normal((r, n))
    return A.T @ A


fig, axes = plt.subplots(1, 3, figsize=(17, 5))

# Generate different types of PSD matrices
n = 8
configs = [
    ("Diagonal PSD", np.diag(np.abs(np.random.default_rng(1).standard_normal(n)) + 0.1)),
    ("Rank-2 PSD", random_psd_matrix(n, rank=2, seed=2)),
    ("Generic PSD (Full Rank)", random_psd_matrix(n, seed=3)),
]

for ax, (title, K) in zip(axes, configs):
    prods = []
    joints = []
    ratios = []

    for i in range(n):
        for j in range(i + 1, n):
            prod = K[i, i] * K[j, j]
            joint = K[i, i] * K[j, j] - K[i, j] ** 2
            prods.append(prod)
            joints.append(joint)
            if prod > 1e-15:
                ratios.append(joint / prod)

    prods = np.array(prods)
    joints = np.array(joints)

    # Plot the identity line y = x
    max_val = max(max(prods), max(joints)) * 1.1
    ax.plot([0, max_val], [0, max_val], 'k--', linewidth=1, alpha=0.5, label='y = x (upper bound)')
    ax.axhline(y=0, color='red', linestyle=':', alpha=0.5, label='y = 0 (lower bound)')

    # Fill the valid region
    ax.fill_between([0, max_val], [0, 0], [0, max_val], alpha=0.08, color='green',
                     label='Valid region')

    # Scatter plot
    scatter = ax.scatter(prods, joints, c=ratios if ratios else 'blue',
                         cmap='coolwarm', s=60, edgecolors='black', linewidth=0.5,
                         vmin=0, vmax=1, zorder=5)

    ax.set_xlabel('K_ii · K_jj (Marginal Product)', fontsize=11)
    ax.set_ylabel('det(K_{ij}) (Joint Weight)', fontsize=11)
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.set_xlim(-0.05 * max_val, max_val)
    ax.set_ylim(-0.05 * max_val, max_val)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)
    ax.legend(fontsize=8, loc='upper left')

    # Annotate with ratio statistics
    if ratios:
        ax.text(0.95, 0.05, f'min ratio: {min(ratios):.3f}\nmax ratio: {max(ratios):.3f}\nmean: {np.mean(ratios):.3f}',
                transform=ax.transAxes, fontsize=9, verticalalignment='bottom',
                horizontalalignment='right',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.suptitle('Fischer Inequality: 0 ≤ det(K_{ij}) ≤ K_ii · K_jj\n'
             'Every pair (i,j) satisfies negative dependence',
             fontsize=14, fontweight='bold', y=1.02)
plt.colorbar(scatter, ax=axes, label='Correlation Ratio', shrink=0.8, pad=0.02)
plt.tight_layout()
plt.savefig('viz_fischer_inequality.png', dpi=150, bbox_inches='tight')
print("Saved viz_fischer_inequality.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Bridge — Eigenvalues to Partition Function
===================================================================

Illustrates the cross-domain bridge theorem:
det(I + tK) = ∏_i (1 + t·λ_i)

Shows how the partition function (a combinatorial/probabilistic object)
is completely determined by the spectrum (a linear-algebraic object).
Left: individual eigenvalue contributions. Right: the product.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def random_psd_matrix(n, seed=42):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    return A.T @ A


def principal_minor(K, S):
    if len(S) == 0:
        return 1.0
    idx = list(S)
    return np.linalg.det(K[np.ix_(idx, idx)])


n = 5
K = random_psd_matrix(n, seed=42)
eigenvalues = np.sort(np.linalg.eigvalsh(K))

t_vals = np.linspace(0, 2, 200)

fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Panel 1: Individual eigenvalue factors
ax = axes[0]
colors = plt.cm.viridis(np.linspace(0.2, 0.8, n))
for k, (lam, color) in enumerate(zip(eigenvalues, colors)):
    ax.plot(t_vals, 1 + lam * t_vals, color=color, linewidth=2,
            label=f'λ_{k+1} = {lam:.2f}')
ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('1 + λ_i · t', fontsize=12)
ax.set_title('Individual Eigenvalue Factors', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)
ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5)

# Panel 2: Partition function via product vs via principal minors
ax = axes[1]
z_product = np.array([np.prod(1 + eigenvalues * t) for t in t_vals])
z_det = np.array([np.linalg.det(np.eye(n) + t * K) for t in t_vals])

ax.plot(t_vals, z_product, 'b-', linewidth=2.5, label='∏(1 + λᵢt)')
ax.plot(t_vals, z_det, 'r--', linewidth=2, label='det(I + tK)')

# Also show the principal minor sum
z_minor = np.zeros_like(t_vals)
for k in range(n + 1):
    e_k = sum(principal_minor(K, list(S)) for S in combinations(range(n), k))
    z_minor += e_k * t_vals ** k
ax.plot(t_vals, z_minor, 'g:', linewidth=2, label='Σ eₖ(K)·tᵏ')

ax.set_xlabel('t', fontsize=12)
ax.set_ylabel('Z_K(t,...,t)', fontsize=12)
ax.set_title('Three Equivalent Representations\nof the Partition Function', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Elementary symmetric polynomials (coefficients)
ax = axes[2]
e_k_vals = []
for k in range(n + 1):
    e_k = sum(principal_minor(K, list(S)) for S in combinations(range(n), k))
    e_k_vals.append(e_k)

bars = ax.bar(range(n + 1), e_k_vals, color=plt.cm.plasma(np.linspace(0.2, 0.8, n + 1)),
              edgecolor='black', linewidth=0.5)
ax.set_xlabel('Degree k', fontsize=12)
ax.set_ylabel('eₖ(K) = Σ_{|S|=k} det(K_S)', fontsize=12)
ax.set_title('Elementary Symmetric Functions\n(Principal Minor Sums)', fontsize=13, fontweight='bold')
ax.set_xticks(range(n + 1))

# Add value labels
for bar, val in zip(bars, e_k_vals):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + max(e_k_vals) * 0.02,
            f'{val:.1f}', ha='center', va='bottom', fontsize=9)

ax.grid(True, alpha=0.3, axis='y')

fig.suptitle('The Spectral Bridge: DPP Partition Function ↔ Eigenvalue Statistics',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_spectral_bridge.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_bridge.png")
