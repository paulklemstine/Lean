"""
Applications of Lorentzian Hessian Certificates

This module demonstrates real-world applications of the Lorentzian
certificate framework for DPP kernels:

1. Diversity sampling diagnostics
2. Kernel quality assessment for ML models
3. Correlation geometry analysis
4. Statistical physics partition function analysis
"""

import numpy as np
from typing import List, Tuple, Dict


# ─── Inline implementations (self-contained) ───────────────────────────

def compute_resolvent_hessian(K: np.ndarray) -> Tuple[np.ndarray, np.ndarray, float]:
    """Compute resolvent Hessian, weight vector, and determinant."""
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag = np.diag(L)
    H = det_A * (np.outer(diag, diag) - L ** 2)
    np.fill_diagonal(H, 0.0)
    return H, diag, det_A


def count_positive_eigenvalues(M: np.ndarray, tol: float = 1e-10) -> int:
    return int(np.sum(np.linalg.eigvalsh(M) > tol))


# ─── Application 1: Diversity Sampling Diagnostics ──────────────────────

def diversity_kernel_diagnostic(K: np.ndarray, item_names: List[str] = None) -> Dict:
    """Analyze a DPP kernel for diversity sampling quality.
    
    Given a kernel K used for diversity sampling (e.g., in recommendation
    systems or document summarization), this diagnostic:
    
    1. Computes the Lorentzian certificate
    2. Checks if the kernel satisfies the Lorentzian property
    3. Identifies pairs with strongest/weakest repulsion
    4. Reports overall diversity quality metrics
    
    Args:
        K: Symmetric PSD contraction kernel
        item_names: Optional names for items
    
    Returns:
        Dictionary with diagnostic information
    """
    n = K.shape[0]
    if item_names is None:
        item_names = [f"item_{i}" for i in range(n)]
    
    H, w, det_A = compute_resolvent_hessian(K)
    num_pos = count_positive_eigenvalues(H)
    
    # Find strongest repulsion pairs (most negative H[i,j])
    pairs = []
    for i in range(n):
        for j in range(i+1, n):
            pairs.append((i, j, H[i, j]))
    pairs.sort(key=lambda x: x[2])
    
    strongest_repulsion = [(item_names[i], item_names[j], val) 
                          for i, j, val in pairs[:5]]
    weakest_repulsion = [(item_names[i], item_names[j], val) 
                        for i, j, val in pairs[-5:]]
    
    # Diversity score: ratio of trace to Frobenius norm
    H_offdiag = H.copy()
    np.fill_diagonal(H_offdiag, 0)
    diversity_score = -np.sum(H_offdiag) / (n * (n-1)) if n > 1 else 0
    
    return {
        "n_items": n,
        "det_I_plus_K": det_A,
        "lorentzian_valid": num_pos <= 1,
        "positive_eigenvalues": num_pos,
        "diversity_score": diversity_score,
        "strongest_repulsion": strongest_repulsion,
        "weakest_repulsion": weakest_repulsion,
        "weight_vector": w,
        "weight_range": (w.min(), w.max()),
    }


# ─── Application 2: Kernel Quality Assessment ────────────────────────────

def kernel_quality_assessment(kernels: List[np.ndarray], 
                               names: List[str] = None) -> List[Dict]:
    """Compare multiple DPP kernels by their Lorentzian certificate quality.
    
    Useful for model selection in ML pipelines that use DPP-based
    diversity sampling (e.g., choosing between different similarity kernels).
    
    Args:
        kernels: List of symmetric PSD contraction kernels
        names: Optional kernel names
    
    Returns:
        List of quality reports, one per kernel
    """
    if names is None:
        names = [f"kernel_{i}" for i in range(len(kernels))]
    
    reports = []
    for K, name in zip(kernels, names):
        H, w, det_A = compute_resolvent_hessian(K)
        eigs = np.linalg.eigvalsh(H)
        num_pos = int(np.sum(eigs > 1e-10))
        
        # Spectral gap: ratio of largest to second-largest eigenvalue
        sorted_eigs = np.sort(eigs)[::-1]
        if len(sorted_eigs) >= 2 and sorted_eigs[1] > 1e-15:
            spectral_gap = sorted_eigs[0] / abs(sorted_eigs[1]) if sorted_eigs[1] != 0 else float('inf')
        else:
            spectral_gap = float('inf')
        
        # Condition number of the resolvent
        L = np.linalg.inv(np.eye(K.shape[0]) + K)
        cond = np.linalg.cond(L)
        
        reports.append({
            "name": name,
            "dimension": K.shape[0],
            "lorentzian": num_pos <= 1,
            "signature_defect": max(0, num_pos - 1),
            "det_I_plus_K": det_A,
            "spectral_gap": spectral_gap,
            "resolvent_condition": cond,
            "max_eigenvalue": sorted_eigs[0],
            "min_eigenvalue": sorted_eigs[-1],
            "weight_uniformity": w.std() / w.mean() if w.mean() > 0 else float('inf'),
        })
    
    return reports


# ─── Application 3: Correlation Geometry Analysis ────────────────────────

def correlation_geometry(K: np.ndarray) -> Dict:
    """Analyze the correlation geometry of a DPP kernel.
    
    The resolvent Hessian encodes the second-order correlation structure
    of the DPP at the all-ones point. This function extracts geometric
    invariants from that structure.
    
    Applications:
    - Statistical physics: susceptibility analysis
    - Probability: negative dependence quantification
    - Geometry: curvature of the log-partition function
    
    Args:
        K: Symmetric PSD contraction kernel
    
    Returns:
        Dictionary with geometric invariants
    """
    n = K.shape[0]
    H, w, det_A = compute_resolvent_hessian(K)
    L = np.linalg.inv(np.eye(n) + K)
    
    # Normalized Hessian (divided by det)
    H_norm = H / det_A if abs(det_A) > 1e-15 else H
    
    # Covariance matrix of DPP indicators
    # Cov(X_i, X_j) = K_ii K_jj - K_ij^2 - K_ii * K_jj = -K_ij^2 for i≠j
    cov_matrix = np.zeros((n, n))
    for i in range(n):
        cov_matrix[i, i] = K[i, i] * (1 - K[i, i])  # Var(X_i)
        for j in range(i+1, n):
            cov_matrix[i, j] = -(K[i, j] ** 2)
            cov_matrix[j, i] = cov_matrix[i, j]
    
    # Susceptibility: ∑_{i,j} Cov(X_i, X_j)
    susceptibility = np.sum(cov_matrix)
    
    # Total repulsion: -∑_{i≠j} K_ij^2
    total_repulsion = np.sum(cov_matrix) - np.trace(cov_matrix)
    
    # Curvature of log-partition at x=1
    # ∂²log Z / ∂x_i ∂x_j = H_ij/Z - (∂_i Z)(∂_j Z)/Z²
    # At x=1: ∂_i Z = Z * L_ii (up to sign convention)
    log_hessian = H_norm - np.outer(w, w)
    
    return {
        "susceptibility": susceptibility,
        "total_repulsion": total_repulsion,
        "covariance_trace": np.trace(cov_matrix),
        "log_partition_curvature": log_hessian,
        "normalized_hessian_spectrum": np.sort(np.linalg.eigvalsh(H_norm))[::-1],
        "resolvent_trace": np.trace(L),
        "resolvent_frobenius": np.linalg.norm(L, 'fro'),
    }


# ─── Application 4: Partition Function Analysis ──────────────────────────

def partition_function_analysis(K: np.ndarray, 
                                 x_points: np.ndarray = None) -> Dict:
    """Analyze the DPP partition function Z_K(x) = det(I + diag(x)K).
    
    Evaluates the partition function along a line from 0 to 1,
    and computes first and second derivatives at x=1.
    
    This connects to statistical physics: Z is the partition function
    of a fermionic system, and its derivatives encode thermodynamic
    quantities (free energy, entropy, susceptibility).
    
    Args:
        K: Symmetric PSD contraction kernel
        x_points: Optional evaluation points for the partition function
    
    Returns:
        Dictionary with partition function data
    """
    n = K.shape[0]
    
    if x_points is None:
        x_points = np.linspace(0, 2, 100)
    
    # Evaluate Z(t,...,t) = det(I + tK) along a line
    z_values = []
    for t in x_points:
        z_values.append(np.linalg.det(np.eye(n) + t * K))
    z_values = np.array(z_values)
    
    # Value at t=1
    z_one = np.linalg.det(np.eye(n) + K)
    
    # First derivatives at x=1: ∂Z/∂x_i = det(A) * L_ii
    L = np.linalg.inv(np.eye(n) + K)
    first_derivs = z_one * np.diag(L)
    
    # Second derivatives (off-diagonal): our Hessian formula
    H, w, _ = compute_resolvent_hessian(K)
    
    # Free energy per site
    free_energy = -np.log(z_one) / n if z_one > 0 else float('inf')
    
    # Entropy contribution
    entropy = np.sum(np.log(1 + np.linalg.eigvalsh(K)))
    
    return {
        "x_points": x_points,
        "z_values": z_values,
        "z_at_one": z_one,
        "first_derivatives": first_derivs,
        "hessian_offdiag": H,
        "free_energy_per_site": free_energy,
        "entropy": entropy,
        "log_z": np.log(z_one) if z_one > 0 else float('-inf'),
    }


# ─── Main Demo ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    rng = np.random.default_rng(42)
    
    print("=" * 70)
    print("APPLICATIONS OF LORENTZIAN HESSIAN CERTIFICATES")
    print("=" * 70)
    
    # Demo 1: Diversity diagnostics
    print("\n--- Application 1: Diversity Sampling Diagnostic ---")
    n = 8
    items = ["article_A", "article_B", "article_C", "article_D",
             "article_E", "article_F", "article_G", "article_H"]
    
    # Create a similarity-based DPP kernel
    # Items are embedded as random unit vectors
    embeddings = rng.standard_normal((n, 5))
    embeddings = embeddings / np.linalg.norm(embeddings, axis=1, keepdims=True)
    similarity = embeddings @ embeddings.T
    # Scale to be a contraction
    max_eig = np.max(np.linalg.eigvalsh(similarity))
    K = similarity * 0.8 / max_eig
    K = (K + K.T) / 2
    
    diag = diversity_kernel_diagnostic(K, items)
    print(f"  Items: {n}")
    print(f"  Lorentzian valid: {diag['lorentzian_valid']}")
    print(f"  Diversity score: {diag['diversity_score']:.4f}")
    print(f"  Strongest repulsion pairs:")
    for name1, name2, val in diag['strongest_repulsion'][:3]:
        print(f"    {name1} ↔ {name2}: {val:.4f}")
    
    # Demo 2: Kernel comparison
    print("\n--- Application 2: Kernel Quality Comparison ---")
    kernels = []
    names = []
    for rank in [2, 5, 8]:
        Q, _ = np.linalg.qr(rng.standard_normal((8, 8)))
        eigs = np.zeros(8)
        eigs[:rank] = rng.uniform(0.1, 0.9, rank)
        K_test = Q @ np.diag(eigs) @ Q.T
        K_test = (K_test + K_test.T) / 2
        kernels.append(K_test)
        names.append(f"rank-{rank}")
    
    reports = kernel_quality_assessment(kernels, names)
    print(f"  {'Kernel':<12} {'Lorentzian':<12} {'Defect':<8} {'Spectral Gap':<14} {'det(I+K)':<12}")
    for r in reports:
        print(f"  {r['name']:<12} {str(r['lorentzian']):<12} {r['signature_defect']:<8} "
              f"{r['spectral_gap']:<14.4f} {r['det_I_plus_K']:<12.4f}")
    
    # Demo 3: Correlation geometry
    print("\n--- Application 3: Correlation Geometry ---")
    K = kernels[1]
    geom = correlation_geometry(K)
    print(f"  Susceptibility: {geom['susceptibility']:.6f}")
    print(f"  Total repulsion: {geom['total_repulsion']:.6f}")
    print(f"  Resolvent trace: {geom['resolvent_trace']:.6f}")
    print(f"  Normalized Hessian spectrum: {geom['normalized_hessian_spectrum'][:5]}")
    
    # Demo 4: Partition function
    print("\n--- Application 4: Partition Function Analysis ---")
    pf = partition_function_analysis(K)
    print(f"  Z(1) = {pf['z_at_one']:.6f}")
    print(f"  Free energy/site = {pf['free_energy_per_site']:.6f}")
    print(f"  Entropy = {pf['entropy']:.6f}")
    print(f"  First derivatives: {pf['first_derivatives'][:4]}")


"""
Demonstration: Lorentzian Hessian Certificate Computation for DPP Kernels

This script:
1. Generates random symmetric PSD contraction kernels
2. Computes the resolvent Hessian certificate
3. Verifies the "at most one positive eigenvalue" property
4. Reports signature defect and runtime
5. Compares certificate cost against eigendecomposition
"""

import numpy as np
import time
from typing import Tuple

def generate_psd_contraction(n: int, rng: np.random.Generator = None) -> np.ndarray:
    """Generate a random n×n symmetric PSD contraction kernel.
    
    A PSD contraction has eigenvalues in [0, 1].
    Strategy: generate random orthogonal matrix Q and diagonal D with entries in [0,1],
    then K = Q D Q^T.
    """
    if rng is None:
        rng = np.random.default_rng()
    # Random orthogonal matrix via QR decomposition
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    # Random eigenvalues in [0, 1]
    eigenvalues = rng.uniform(0, 1, n)
    K = Q @ np.diag(eigenvalues) @ Q.T
    # Symmetrize to remove numerical asymmetry
    K = (K + K.T) / 2
    return K


def compute_resolvent_hessian(K: np.ndarray) -> Tuple[np.ndarray, np.ndarray, float]:
    """Compute the resolvent Hessian certificate for a DPP kernel K.
    
    Returns:
        H: The resolvent Hessian matrix (n×n)
        w: The weight vector (diagonal of (I+K)^{-1})
        det_A: The determinant det(I+K)
    """
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    
    # Assemble Hessian: H[i,j] = det(A) * (L[i,i]*L[j,j] - L[i,j]^2) for i≠j, 0 for i=j
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                H[i, j] = det_A * (L[i, i] * L[j, j] - L[i, j] ** 2)
    
    w = np.diag(L)
    return H, w, det_A


def count_positive_eigenvalues(M: np.ndarray, tol: float = 1e-10) -> int:
    """Count the number of positive eigenvalues of a symmetric matrix."""
    eigenvalues = np.linalg.eigvalsh(M)
    return int(np.sum(eigenvalues > tol))


def verify_conditional_nsd(H: np.ndarray, w: np.ndarray, num_tests: int = 1000) -> bool:
    """Verify conditional negative semidefiniteness by random sampling.
    
    Tests that v^T H v ≤ 0 for random vectors v with ∑ w_i v_i = 0.
    """
    n = H.shape[0]
    rng = np.random.default_rng(42)
    
    for _ in range(num_tests):
        # Generate random vector, then project to zero-sum hyperplane
        v = rng.standard_normal(n)
        # Project: v <- v - (w·v / w·w) * w... wait, we need ∑ w_i v_i = 0
        # which means v - (∑ w_i v_i / ∑ w_i^2) * w ... no
        # Actually ∑ w_i (v_i - c w_i) = ∑ w_i v_i - c ∑ w_i^2 = 0
        # so c = ∑ w_i v_i / ∑ w_i^2
        c = np.dot(w, v) / np.dot(w, w)
        v = v - c * w
        
        qf = v @ H @ v
        if qf > 1e-10:
            return False
    return True


def benchmark_certificate_vs_eigendecomp(sizes: list, num_trials: int = 5):
    """Compare certificate computation time vs full eigendecomposition."""
    print("\n" + "=" * 70)
    print("BENCHMARK: Certificate Computation vs Eigendecomposition")
    print("=" * 70)
    print(f"{'n':>6} | {'Certificate (ms)':>16} | {'Eigendecomp (ms)':>16} | {'Ratio':>8}")
    print("-" * 70)
    
    rng = np.random.default_rng(123)
    
    for n in sizes:
        cert_times = []
        eig_times = []
        
        for _ in range(num_trials):
            K = generate_psd_contraction(n, rng)
            
            # Time certificate computation
            start = time.perf_counter()
            H, w, d = compute_resolvent_hessian(K)
            cert_time = (time.perf_counter() - start) * 1000
            cert_times.append(cert_time)
            
            # Time eigendecomposition of H
            start = time.perf_counter()
            eigenvalues = np.linalg.eigvalsh(H)
            eig_time = (time.perf_counter() - start) * 1000
            eig_times.append(eig_time)
        
        avg_cert = np.mean(cert_times)
        avg_eig = np.mean(eig_times)
        ratio = avg_cert / avg_eig if avg_eig > 0 else float('inf')
        print(f"{n:>6} | {avg_cert:>14.3f}ms | {avg_eig:>14.3f}ms | {ratio:>7.2f}x")


def main():
    print("=" * 70)
    print("LORENTZIAN HESSIAN CERTIFICATE — NUMERICAL DEMONSTRATION")
    print("=" * 70)
    
    rng = np.random.default_rng(42)
    
    # Test 1: Basic certificate computation
    print("\n--- Test 1: Certificate Computation for Random PSD Contractions ---")
    for n in [3, 5, 10, 20, 50]:
        K = generate_psd_contraction(n, rng)
        H, w, det_A = compute_resolvent_hessian(K)
        
        num_pos = count_positive_eigenvalues(H)
        eigs = np.linalg.eigvalsh(H)
        cond_nsd = verify_conditional_nsd(H, w)
        
        print(f"\nn = {n}:")
        print(f"  det(I+K)              = {det_A:.6f}")
        print(f"  Positive eigenvalues  = {num_pos}")
        print(f"  Max eigenvalue        = {eigs[-1]:.6e}")
        print(f"  Min eigenvalue        = {eigs[0]:.6e}")
        print(f"  All weights positive  = {all(w > 0)}")
        print(f"  Conditional NSD       = {cond_nsd}")
        print(f"  H is symmetric        = {np.allclose(H, H.T)}")
        print(f"  Diagonal is zero      = {np.allclose(np.diag(H), 0)}")
    
    # Test 2: Conjecture — Exact Defect Collapse
    print("\n\n--- Test 2: Conjecture — Exact Defect Collapse ---")
    print("Testing: nonzero PSD contraction K => exactly 1 positive eigenvalue")
    
    num_tests = 1000
    failures = 0
    for trial in range(num_tests):
        n = rng.integers(2, 30)
        K = generate_psd_contraction(n, rng)
        H, w, _ = compute_resolvent_hessian(K)
        num_pos = count_positive_eigenvalues(H)
        if num_pos != 1:
            failures += 1
            if failures <= 5:
                print(f"  Trial {trial}: n={n}, positive eigenvalues = {num_pos}")
    
    if failures == 0:
        print(f"  PASSED: All {num_tests} random tests show exactly 1 positive eigenvalue")
    else:
        print(f"  FAILED: {failures}/{num_tests} tests had ≠ 1 positive eigenvalue")
    
    # Test 3: Conjecture — Conditional Negative Type of Normalized Hessian
    print("\n\n--- Test 3: Conditional Negative Type of Normalized Hessian ---")
    print("Testing: H/det(I+K) defines a kernel of negative type on [n]")
    
    failures = 0
    for trial in range(500):
        n = rng.integers(3, 20)
        K = generate_psd_contraction(n, rng)
        H, w, det_A = compute_resolvent_hessian(K)
        H_normalized = H / det_A
        
        # Test: for random zero-sum vectors, v^T H_norm v ≤ 0
        for _ in range(50):
            v = rng.standard_normal(n)
            c = np.dot(w, v) / np.dot(w, w)
            v = v - c * w
            qf = v @ H_normalized @ v
            if qf > 1e-10:
                failures += 1
                break
    
    if failures == 0:
        print(f"  PASSED: All tests confirm conditional negative type")
    else:
        print(f"  VIOLATIONS: {failures} cases found")
    
    # Test 4: Benchmark
    benchmark_certificate_vs_eigendecomp([5, 10, 20, 50, 100, 200, 500])
    
    # Test 5: Edge cases
    print("\n\n--- Test 5: Edge Cases ---")
    
    # Zero kernel
    K_zero = np.zeros((5, 5))
    H_zero, w_zero, d_zero = compute_resolvent_hessian(K_zero)
    print(f"  Zero kernel: H = 0? {np.allclose(H_zero, 0)}, det = {d_zero}")
    
    # Identity kernel
    K_id = np.eye(5)
    H_id, w_id, d_id = compute_resolvent_hessian(K_id)
    num_pos_id = count_positive_eigenvalues(H_id)
    print(f"  Identity kernel: det = {d_id}, positive eigenvalues = {num_pos_id}")
    
    # Rank-1 kernel
    u = rng.standard_normal(5)
    u = u / np.linalg.norm(u)
    K_rank1 = 0.5 * np.outer(u, u)
    H_r1, w_r1, d_r1 = compute_resolvent_hessian(K_rank1)
    num_pos_r1 = count_positive_eigenvalues(H_r1)
    print(f"  Rank-1 kernel: det = {d_r1:.4f}, positive eigenvalues = {num_pos_r1}")


if __name__ == "__main__":
    main()


"""
Visualization 2: Certificate Computation Scaling and Complexity

This script visualizes:
- O(n³) scaling of certificate computation
- Comparison with eigendecomposition cost
- Signature defect as a function of kernel rank
"""

import numpy as np
import matplotlib.pyplot as plt
import time


def generate_psd_contraction(n, rank=None, seed=None):
    rng = np.random.default_rng(seed)
    if rank is None:
        rank = n
    rank = min(rank, n)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = np.zeros(n)
    eigs[:rank] = rng.uniform(0.05, 0.95, rank)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_certificate_timed(K):
    n = K.shape[0]
    start = time.perf_counter()
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag_L = np.diag(L)
    H = det_A * (np.outer(diag_L, diag_L) - L ** 2)
    np.fill_diagonal(H, 0.0)
    cert_time = time.perf_counter() - start

    start = time.perf_counter()
    eigs = np.linalg.eigvalsh(H)
    eig_time = time.perf_counter() - start

    num_pos = int(np.sum(eigs > 1e-10))
    return cert_time, eig_time, num_pos, H, diag_L


fig, axes = plt.subplots(1, 3, figsize=(18, 5))
fig.suptitle('Lorentzian Certificate: Complexity and Scaling', fontsize=16, fontweight='bold')

# Panel 1: Computation time scaling
ax1 = axes[0]
sizes = [5, 10, 20, 30, 50, 75, 100, 150, 200, 300, 400, 500]
cert_times_avg = []
eig_times_avg = []
num_trials = 5

for n in sizes:
    ct_list, et_list = [], []
    for trial in range(num_trials):
        K = generate_psd_contraction(n, seed=trial * 1000 + n)
        ct, et, _, _, _ = compute_certificate_timed(K)
        ct_list.append(ct)
        et_list.append(et)
    cert_times_avg.append(np.mean(ct_list))
    eig_times_avg.append(np.mean(et_list))

ax1.loglog(sizes, cert_times_avg, 'o-', color='#2196F3', linewidth=2,
           markersize=6, label='Certificate (inv + det)')
ax1.loglog(sizes, eig_times_avg, 's-', color='#E91E63', linewidth=2,
           markersize=6, label='Eigendecomposition of H')
# Reference O(n^3) line
ref_sizes = np.array(sizes)
ref = ref_sizes ** 3 * cert_times_avg[0] / sizes[0] ** 3
ax1.loglog(sizes, ref, '--', color='gray', linewidth=1, label='O(n³) reference')

ax1.set_xlabel('Matrix dimension n', fontsize=12)
ax1.set_ylabel('Time (seconds)', fontsize=12)
ax1.set_title('Computation Time Scaling', fontsize=12)
ax1.legend(fontsize=10)
ax1.grid(True, alpha=0.3)

# Panel 2: Certificate cost ratio
ax2 = axes[1]
total_times = [c + e for c, e in zip(cert_times_avg, eig_times_avg)]
ratios = [c / t if t > 0 else 0 for c, t in zip(cert_times_avg, total_times)]
ax2.bar(range(len(sizes)), ratios, color='#4CAF50', alpha=0.7,
        edgecolor='black', linewidth=0.5)
ax2.set_xticks(range(len(sizes)))
ax2.set_xticklabels([str(s) for s in sizes], rotation=45)
ax2.set_xlabel('Matrix dimension n', fontsize=12)
ax2.set_ylabel('Fraction of total time', fontsize=12)
ax2.set_title('Certificate vs Total Cost Ratio', fontsize=12)
ax2.axhline(y=0.5, color='red', linestyle='--', linewidth=1, alpha=0.5)

# Panel 3: Weight vector distribution across dimensions
ax3 = axes[2]
for n, color, marker in [(5, '#2196F3', 'o'), (10, '#4CAF50', 's'),
                          (20, '#FF9800', '^'), (50, '#E91E63', 'D')]:
    K = generate_psd_contraction(n, seed=42)
    _, _, _, _, w = compute_certificate_timed(K)
    w_sorted = np.sort(w)[::-1]
    ax3.plot(range(len(w_sorted)), w_sorted, marker=marker, markersize=4,
             linewidth=1.5, color=color, label=f'n={n}', alpha=0.8)

ax3.set_xlabel('Index (sorted)', fontsize=12)
ax3.set_ylabel('Weight wᵢ = L_{ii}', fontsize=12)
ax3.set_title('Resolvent Weight Distribution', fontsize=12)
ax3.legend(fontsize=10)
ax3.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('certificate_scaling.png', dpi=150, bbox_inches='tight')
print("Saved certificate_scaling.png")


"""
Visualization 3: Conditional Negative Semidefiniteness

This script visualizes the key theorem: on the weighted zero-sum hyperplane,
the Hessian quadratic form is nonpositive. Shows:
- Quadratic form values for random vectors projected to the hyperplane
- The decomposition into rank-1 and Hadamard-square terms
- Comparison of the hyperplane projection effect
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_psd_contraction(n, seed=None):
    rng = np.random.default_rng(seed)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0.05, 0.95, n)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_hessian_data(K):
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag = np.diag(L)
    H = det_A * (np.outer(diag, diag) - L ** 2)
    np.fill_diagonal(H, 0.0)
    return H, diag, det_A, L


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Conditional Negative Semidefiniteness of DPP Hessian',
             fontsize=16, fontweight='bold')

# Use a fixed kernel for all panels
n = 15
K = generate_psd_contraction(n, seed=42)
H, w, det_A, L = compute_hessian_data(K)
rng = np.random.default_rng(123)

# Panel 1: Quadratic form values — on vs off hyperplane
ax1 = axes[0, 0]
on_hyperplane = []
off_hyperplane = []
for _ in range(2000):
    v = rng.standard_normal(n)
    qf_off = v @ H @ v
    off_hyperplane.append(qf_off)
    
    # Project to hyperplane
    c = np.dot(w, v) / np.dot(w, w)
    v_proj = v - c * w
    qf_on = v_proj @ H @ v_proj
    on_hyperplane.append(qf_on)

ax1.hist(off_hyperplane, bins=80, alpha=0.5, color='#FF9800',
         label='General vectors', density=True)
ax1.hist(on_hyperplane, bins=80, alpha=0.5, color='#2196F3',
         label='On hyperplane (∑wᵢvᵢ=0)', density=True)
ax1.axvline(x=0, color='red', linewidth=2, linestyle='--')
ax1.set_xlabel('Quadratic form value v^T H v', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title('Quadratic Form: On vs Off Hyperplane', fontsize=12)
ax1.legend(fontsize=10)

# Panel 2: Decomposition into rank-1 and Hadamard terms
ax2 = axes[0, 1]
rank1_vals = []
hadamard_vals = []
for _ in range(1000):
    v = rng.standard_normal(n)
    c = np.dot(w, v) / np.dot(w, w)
    v = v - c * w
    
    # Rank-1 term: (∑ L_ii v_i)^2
    rank1 = (np.dot(w, v)) ** 2
    # Hadamard-square term: ∑_{i,j} L_ij^2 v_i v_j
    hadamard = v @ (L ** 2) @ v
    
    rank1_vals.append(rank1 * det_A)
    hadamard_vals.append(hadamard * det_A)

ax2.scatter(hadamard_vals, rank1_vals, s=5, alpha=0.3, c='#2196F3', edgecolors='none')
max_val = max(max(hadamard_vals), max(rank1_vals)) * 1.1
ax2.plot([0, max_val], [0, max_val], 'r--', linewidth=1.5, label='y = x (breakeven)')
ax2.set_xlabel('Hadamard term: det(A) · v^T(L∘L)v', fontsize=11)
ax2.set_ylabel('Rank-1 term: det(A) · (∑Lᵢᵢvᵢ)²', fontsize=11)
ax2.set_title('Decomposition (on hyperplane: rank-1 = 0)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_xlim(left=0)
ax2.set_ylim(bottom=-0.01 * max_val)

# Panel 3: Angular distribution of quadratic form
ax3 = axes[1, 0]
# Generate vectors at various angles from the weight vector
angles = np.linspace(0, np.pi, 200)
qf_by_angle = []
for theta in angles:
    # Generate random vector, decompose into w-component and orthogonal
    v_rand = rng.standard_normal(n)
    v_orth = v_rand - (np.dot(w, v_rand) / np.dot(w, w)) * w
    v_orth = v_orth / (np.linalg.norm(v_orth) + 1e-15)
    w_norm = w / np.linalg.norm(w)
    
    v = np.cos(theta) * w_norm + np.sin(theta) * v_orth
    qf = v @ H @ v
    qf_by_angle.append(qf)

ax3.plot(np.degrees(angles), qf_by_angle, color='#2196F3', linewidth=1.5)
ax3.axhline(y=0, color='red', linewidth=1, linestyle='--')
ax3.axvline(x=90, color='green', linewidth=1.5, linestyle=':',
            label='Hyperplane (θ=90°)')
ax3.fill_between(np.degrees(angles), qf_by_angle, 0,
                 where=np.array(qf_by_angle) > 0, alpha=0.3, color='#FF9800',
                 label='Positive region')
ax3.fill_between(np.degrees(angles), qf_by_angle, 0,
                 where=np.array(qf_by_angle) <= 0, alpha=0.3, color='#2196F3',
                 label='Negative region')
ax3.set_xlabel('Angle from weight vector w (degrees)', fontsize=12)
ax3.set_ylabel('Quadratic form v^T H v', fontsize=12)
ax3.set_title('Angular Profile of Quadratic Form', fontsize=12)
ax3.legend(fontsize=9)

# Panel 4: Eigenvalue spectrum with marked positive eigenvalue
ax4 = axes[1, 1]
eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
colors = ['#E91E63' if e > 1e-10 else ('#2196F3' if e < -1e-10 else '#9E9E9E')
          for e in eigs]
ax4.barh(range(len(eigs)), eigs, color=colors, edgecolor='black', linewidth=0.3)
ax4.axvline(x=0, color='black', linewidth=1)
ax4.set_ylabel('Eigenvalue index', fontsize=12)
ax4.set_xlabel('Eigenvalue', fontsize=12)
ax4.set_title(f'Hessian Spectrum (n={n}): Lorentzian Signature', fontsize=12)
ax4.invert_yaxis()

# Add annotation
num_pos = int(np.sum(np.array(eigs) > 1e-10))
num_neg = int(np.sum(np.array(eigs) < -1e-10))
ax4.text(0.95, 0.95, f'Signature: ({num_pos}+, {num_neg}−)',
         transform=ax4.transAxes, fontsize=11, verticalalignment='top',
         horizontalalignment='right',
         bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

plt.tight_layout()
plt.savefig('conditional_nsd.png', dpi=150, bbox_inches='tight')
print("Saved conditional_nsd.png")


"""
Visualization 1: Hessian Eigenvalue Spectrum for DPP Kernels

This script visualizes the eigenvalue distribution of the resolvent Hessian
for random PSD contraction kernels of varying dimension and rank.
The key prediction: exactly one positive eigenvalue for every nonzero kernel.
"""

import numpy as np
import matplotlib.pyplot as plt


def generate_psd_contraction(n, rank=None, seed=None):
    rng = np.random.default_rng(seed)
    if rank is None:
        rank = n
    rank = min(rank, n)
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = np.zeros(n)
    eigs[:rank] = rng.uniform(0.05, 0.95, rank)
    K = Q @ np.diag(eigs) @ Q.T
    return (K + K.T) / 2


def compute_hessian_eigenvalues(K):
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    diag = np.diag(L)
    H = det_A * (np.outer(diag, diag) - L ** 2)
    np.fill_diagonal(H, 0.0)
    return np.sort(np.linalg.eigvalsh(H))[::-1]


# Generate data
fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Resolvent Hessian Eigenvalue Spectra for DPP Kernels', fontsize=16, fontweight='bold')

# Panel 1: Eigenvalue histograms for different dimensions
ax1 = axes[0, 0]
rng = np.random.default_rng(42)
for n, color in [(5, '#2196F3'), (10, '#4CAF50'), (20, '#FF9800'), (50, '#E91E63')]:
    all_eigs = []
    for seed in range(100):
        K = generate_psd_contraction(n, seed=seed * 1000 + n)
        eigs = compute_hessian_eigenvalues(K)
        all_eigs.extend(eigs)
    ax1.hist(all_eigs, bins=80, alpha=0.5, label=f'n={n}', color=color, density=True)

ax1.axvline(x=0, color='black', linewidth=0.5, linestyle='--')
ax1.set_xlabel('Eigenvalue', fontsize=12)
ax1.set_ylabel('Density', fontsize=12)
ax1.set_title('Eigenvalue Distribution (100 random kernels each)', fontsize=12)
ax1.legend(fontsize=10)
ax1.set_xlim(-5, 2)

# Panel 2: Positive eigenvalue count (should always be 1)
ax2 = axes[0, 1]
dims = list(range(3, 31))
pos_counts = {d: [] for d in dims}
for d in dims:
    for trial in range(50):
        K = generate_psd_contraction(d, seed=trial * 100 + d)
        eigs = compute_hessian_eigenvalues(K)
        pos_counts[d].append(int(np.sum(eigs > 1e-10)))

means = [np.mean(pos_counts[d]) for d in dims]
ax2.bar(dims, means, color='#2196F3', alpha=0.7, edgecolor='black', linewidth=0.5)
ax2.axhline(y=1, color='red', linewidth=2, linestyle='--', label='Predicted: exactly 1')
ax2.set_xlabel('Matrix Dimension n', fontsize=12)
ax2.set_ylabel('# Positive Eigenvalues', fontsize=12)
ax2.set_title('Positive Eigenvalue Count (50 trials per dimension)', fontsize=12)
ax2.legend(fontsize=10)
ax2.set_ylim(0, 2)

# Panel 3: Largest vs second-largest eigenvalue
ax3 = axes[1, 0]
largest = []
second = []
for trial in range(500):
    n = np.random.randint(3, 30)
    K = generate_psd_contraction(n, seed=trial)
    eigs = compute_hessian_eigenvalues(K)
    if len(eigs) >= 2:
        largest.append(eigs[0])
        second.append(eigs[1])

ax3.scatter(largest, second, s=8, alpha=0.5, c='#2196F3', edgecolors='none')
ax3.axhline(y=0, color='red', linewidth=1.5, linestyle='--', label='λ₂ = 0 boundary')
ax3.set_xlabel('Largest eigenvalue λ₁', fontsize=12)
ax3.set_ylabel('Second eigenvalue λ₂', fontsize=12)
ax3.set_title('λ₁ vs λ₂: Lorentzian Signature (1, n-1)', fontsize=12)
ax3.legend(fontsize=10)

# Panel 4: Hessian heatmap for a specific kernel
ax4 = axes[1, 1]
K_example = generate_psd_contraction(12, seed=42)
n = K_example.shape[0]
A = np.eye(n) + K_example
L = np.linalg.inv(A)
det_A = np.linalg.det(A)
diag = np.diag(L)
H = det_A * (np.outer(diag, diag) - L ** 2)
np.fill_diagonal(H, 0.0)

im = ax4.imshow(H, cmap='RdBu_r', aspect='equal',
                vmin=-np.max(np.abs(H)), vmax=np.max(np.abs(H)))
plt.colorbar(im, ax=ax4, shrink=0.8)
ax4.set_title(f'Resolvent Hessian (n=12, det={det_A:.2f})', fontsize=12)
ax4.set_xlabel('Column index j', fontsize=12)
ax4.set_ylabel('Row index i', fontsize=12)

plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")
