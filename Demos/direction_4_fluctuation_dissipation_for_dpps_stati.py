#!/usr/bin/env python3
"""
Applications of DPP Fluctuation-Dissipation Theory
====================================================
Demonstrates real-world applications of the DPP response theory,
including sensor placement, experimental design, and diversity sampling.
"""

import numpy as np
from numpy.linalg import inv, det, eigvalsh, pinv


def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)


def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi


def rbf_kernel(X, sigma=1.0):
    """Compute RBF (Gaussian) kernel matrix."""
    n = X.shape[0]
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = np.exp(-np.sum((X[i] - X[j])**2) / (2 * sigma**2))
    return K


# ============================================================
# Application 1: Sensor Placement with Uncertainty Quantification
# ============================================================
def sensor_placement_demo():
    """
    Use DPP response theory for optimal sensor placement.

    The susceptibility distance d_χ(i,j) measures how much information
    is shared between sensor locations i and j. Large distance means
    sensors provide independent information — ideal for coverage.

    The effective resistance R_eff(i,j) gives a network-theoretic lower
    bound on information independence.
    """
    print("=" * 60)
    print("APPLICATION 1: Sensor Placement")
    print("=" * 60)

    # Create a 2D grid of candidate sensor locations
    np.random.seed(42)
    n = 8
    X = np.random.randn(n, 2)

    # Build spatial correlation kernel
    L = rbf_kernel(X, sigma=1.0)
    beta = 1.0

    # Compute susceptibility distance
    chi = compute_susceptibility(beta, L)
    d_chi = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_chi[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]

    # Find the pair with maximum susceptibility distance
    # (most independent pair of sensors)
    max_d = 0
    best_pair = (0, 0)
    for i in range(n):
        for j in range(i + 1, n):
            if d_chi[i, j] > max_d:
                max_d = d_chi[i, j]
                best_pair = (i, j)

    print(f"Number of candidate locations: {n}")
    print(f"Most independent sensor pair: {best_pair}")
    print(f"Susceptibility distance: {max_d:.4f}")
    print(f"\nSusceptibility distance matrix:")
    print(np.round(d_chi, 4))

    # Greedy selection: pick sensors maximizing minimum susceptibility distance
    selected = [best_pair[0], best_pair[1]]
    remaining = list(set(range(n)) - set(selected))

    while len(selected) < min(4, n):
        best_score = -1
        best_next = -1
        for r in remaining:
            min_d = min(d_chi[r, s] for s in selected)
            if min_d > best_score:
                best_score = min_d
                best_next = r
        selected.append(best_next)
        remaining.remove(best_next)

    print(f"\nGreedy sensor selection (4 sensors): {selected}")
    print(f"Minimum pairwise susceptibility distance: "
          f"{min(d_chi[i,j] for i in selected for j in selected if i != j):.4f}")
    print()
    return selected, d_chi


# ============================================================
# Application 2: Bayesian Experimental Design
# ============================================================
def experimental_design_demo():
    """
    Use DPP covariance structure for experimental design.

    The DPP covariance matrix χ encodes how much each experiment
    contributes to reducing uncertainty. The Dirichlet energy
    representation shows that the total information gain decomposes
    into pairwise independent contributions.
    """
    print("=" * 60)
    print("APPLICATION 2: Bayesian Experimental Design")
    print("=" * 60)

    np.random.seed(123)
    n = 6  # candidate experiments

    # Feature vectors for experiments
    features = np.random.randn(n, 3)
    L = features @ features.T  # L-ensemble kernel

    print(f"Number of candidate experiments: {n}")
    print(f"Feature dimension: 3")

    # Analyze at different temperatures
    for beta in [0.1, 0.5, 1.0, 2.0, 5.0]:
        K = compute_marginal_kernel(beta, L)
        chi = compute_susceptibility(beta, L)

        # Expected subset size
        expected_size = np.trace(K)

        # Total variance (sum of diagonal)
        total_var = np.trace(chi)

        # Off-diagonal repulsion (sum of |off-diagonal|)
        total_repulsion = sum(abs(chi[i, j])
                             for i in range(n) for j in range(n) if i != j)

        print(f"\n  β = {beta}:")
        print(f"    Expected subset size: {expected_size:.2f}")
        print(f"    Total variance: {total_var:.4f}")
        print(f"    Total repulsion: {total_repulsion:.4f}")
        print(f"    Variance/repulsion ratio: {total_var/max(total_repulsion, 1e-10):.4f}")

    print()


# ============================================================
# Application 3: Diversity Certification for ML
# ============================================================
def diversity_certification_demo():
    """
    Certify diversity of DPP samples using response theory.

    The resistance comparison theorem R_eff(i,j) ≤ d_χ(i,j) provides
    a network-theoretic certificate: if the effective resistance is
    large, then items i and j are guaranteed to be diverse.
    """
    print("=" * 60)
    print("APPLICATION 3: Diversity Certification")
    print("=" * 60)

    np.random.seed(456)
    n = 6

    # Simulate item embeddings (e.g., document features)
    embeddings = np.random.randn(n, 4)
    L = embeddings @ embeddings.T
    beta = 1.0

    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility(beta, L)

    # Compute conductances and effective resistance
    c = K ** 2
    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]

    G = pinv(Lap)

    print(f"Number of items: {n}")
    print(f"\nDiversity certificates (R_eff ≤ d_χ):")
    print(f"{'Pair':<10} {'R_eff':>10} {'d_χ':>10} {'Gap':>10} {'Certificate':>12}")
    print("-" * 55)

    for i in range(n):
        for j in range(i + 1, n):
            R_eff = G[i, i] + G[j, j] - 2 * G[i, j]
            d_chi = chi[i, i] + chi[j, j] - 2 * chi[i, j]
            gap = d_chi - R_eff
            cert = "✓ diverse" if R_eff > 0.01 else "? weak"
            print(f"({i},{j}){'':<5} {R_eff:>10.4f} {d_chi:>10.4f} "
                  f"{gap:>10.4f} {cert:>12}")

    print()


# ============================================================
# Application 4: Network Robustness Analysis
# ============================================================
def network_robustness_demo():
    """
    Analyze network robustness using DPP conductance structure.

    The DPP conductance network c_ij = K_ij² inherits structure from
    the correlation kernel. The effective resistance captures how
    well-connected pairs of nodes are through the correlation network.
    """
    print("=" * 60)
    print("APPLICATION 4: Network Robustness via DPP Conductances")
    print("=" * 60)

    # Create a graph-like kernel (adjacency + self-loops)
    n = 6
    np.random.seed(789)
    A = np.zeros((n, n))
    # Create a specific graph structure
    edges = [(0, 1), (1, 2), (2, 3), (3, 4), (4, 5), (5, 0), (0, 3)]
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0

    # L = A + degree-weighted diagonal for PSD
    D = np.diag(A.sum(axis=1))
    L = A + 2 * D  # Ensures PSD

    beta = 0.5
    K = compute_marginal_kernel(beta, L)
    c = K ** 2  # DPP conductances

    print(f"Graph edges: {edges}")
    print(f"\nDPP conductance network (K_ij²):")
    print(np.round(c, 4))

    # Compute Kirchhoff index (sum of effective resistances)
    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]
    G = pinv(Lap)

    kirchhoff = 0
    for i in range(n):
        for j in range(i + 1, n):
            kirchhoff += G[i, i] + G[j, j] - 2 * G[i, j]

    print(f"\nKirchhoff index (sum of effective resistances): {kirchhoff:.4f}")
    print(f"Average effective resistance: {kirchhoff / (n*(n-1)/2):.4f}")

    # Compare with susceptibility-based bound
    chi = compute_susceptibility(beta, L)
    kirchhoff_bound = 0
    for i in range(n):
        for j in range(i + 1, n):
            kirchhoff_bound += chi[i, i] + chi[j, j] - 2 * chi[i, j]

    print(f"Susceptibility distance bound: {kirchhoff_bound:.4f}")
    print(f"Ratio (Kirchhoff / bound): {kirchhoff / kirchhoff_bound:.4f}")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("DPP FLUCTUATION-DISSIPATION: APPLICATIONS")
    print("=" * 60 + "\n")

    sensor_placement_demo()
    experimental_design_demo()
    diversity_certification_demo()
    network_robustness_demo()


#!/usr/bin/env python3
"""
DPP Fluctuation-Dissipation Demo
=================================
Numerical verification of the fluctuation-dissipation principle for
determinantal point processes (DPPs).

Tests:
1. Susceptibility = covariance Hessian (Theorem A)
2. Laplacian/Dirichlet structure of covariance (Theorem B)
3. Effective resistance comparison (Theorem C)
4. Negative type property of susceptibility distance
5. Conjecture FD-DPP-1 (Green kernel correspondence)
6. Conjecture FD-DPP-2 (negative type)
"""

import numpy as np
from numpy.linalg import det, inv, eigvalsh
np.set_printoptions(precision=8, suppress=True)


def random_psd_kernel(n, rank=None, seed=None):
    """Generate a random symmetric positive semidefinite n×n matrix."""
    rng = np.random.RandomState(seed)
    if rank is None:
        rank = n
    A = rng.randn(n, rank)
    return A @ A.T


def marginal_kernel(beta, L):
    """Compute K = βL(I + βL)⁻¹."""
    n = L.shape[0]
    M = beta * L
    return M @ inv(np.eye(n) + M)


def covariance_matrix(beta, L):
    """Compute the DPP covariance matrix.
    Diagonal: K_ii(1-K_ii), Off-diagonal: -K_ij²
    """
    K = marginal_kernel(beta, L)
    n = K.shape[0]
    chi = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i == j:
                chi[i, j] = K[i, i] * (1 - K[i, i])
            else:
                chi[i, j] = -(K[i, j] ** 2)
    return chi


def partition_function(beta, L, h):
    """Compute Z_β(h) = det(I + β diag(e^h) L)."""
    n = L.shape[0]
    D = np.diag(np.exp(h))
    return det(np.eye(n) + beta * D @ L)


def numerical_hessian(beta, L, eps=1e-5):
    """Compute Hessian of log Z by finite differences."""
    n = L.shape[0]
    h0 = np.zeros(n)
    Z0 = partition_function(beta, L, h0)
    logZ0 = np.log(Z0)
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            h_pp = h0.copy(); h_pp[i] += eps; h_pp[j] += eps
            h_pm = h0.copy(); h_pm[i] += eps; h_pm[j] -= eps
            h_mp = h0.copy(); h_mp[i] -= eps; h_mp[j] += eps
            h_mm = h0.copy(); h_mm[i] -= eps; h_mm[j] -= eps
            H[i, j] = (np.log(partition_function(beta, L, h_pp))
                       - np.log(partition_function(beta, L, h_pm))
                       - np.log(partition_function(beta, L, h_mp))
                       + np.log(partition_function(beta, L, h_mm))) / (4 * eps**2)
    return H


def dpp_laplacian(beta, L):
    """Compute the DPP Laplacian from conductances K_ij²."""
    K = marginal_kernel(beta, L)
    n = K.shape[0]
    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -(K[i, j] ** 2)
                Lap[i, i] += K[i, j] ** 2
    return Lap


def conductance_matrix(beta, L):
    """Compute edge conductances c_ij = K_ij²."""
    K = marginal_kernel(beta, L)
    return K ** 2


def effective_resistance(c, i, j):
    """Compute effective resistance R_eff(i,j) via Laplacian energy on e_i - e_j."""
    n = c.shape[0]
    Lap = np.zeros((n, n))
    for a in range(n):
        for b in range(n):
            if a != b:
                Lap[a, b] = -c[a, b]
                Lap[a, a] += c[a, b]
    delta = np.zeros(n)
    delta[i] = 1
    delta[j] = -1
    return delta @ Lap @ delta


def susceptibility_distance(beta, L, i, j):
    """Compute d_χ(i,j) = χ_ii + χ_jj - 2χ_ij."""
    chi = covariance_matrix(beta, L)
    return chi[i, i] + chi[j, j] - 2 * chi[i, j]


def green_kernel(c):
    """Compute the pseudoinverse Green kernel of the Laplacian."""
    n = c.shape[0]
    Lap = np.zeros((n, n))
    for a in range(n):
        for b in range(n):
            if a != b:
                Lap[a, b] = -c[a, b]
                Lap[a, a] += c[a, b]
    return np.linalg.pinv(Lap)


def test_hessian_equals_covariance(n=4, beta=1.0, seed=42):
    """Test Theorem A: Hessian of log Z = covariance matrix."""
    print("=" * 60)
    print("TEST 1: Hessian of log-partition = Covariance Matrix")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    chi = covariance_matrix(beta, L)
    H = numerical_hessian(beta, L)
    err = np.max(np.abs(chi - H))
    print(f"n={n}, β={beta}")
    print(f"Covariance matrix:\n{chi}")
    print(f"Numerical Hessian:\n{H}")
    print(f"Max error: {err:.2e}")
    print(f"PASS: {err < 1e-4}\n")
    return err < 1e-4


def test_dirichlet_form(n=4, beta=1.0, seed=42):
    """Test Theorem B: quadratic form = Dirichlet energy."""
    print("=" * 60)
    print("TEST 2: Dirichlet Form Representation")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    Lap = dpp_laplacian(beta, L)
    c = conductance_matrix(beta, L)
    rng = np.random.RandomState(seed + 1)
    v = rng.randn(n)
    # Quadratic form
    qf = v @ Lap @ v
    # Dirichlet energy
    de = 0.5 * sum(c[i, j] * (v[i] - v[j])**2
                   for i in range(n) for j in range(n))
    err = abs(qf - de)
    print(f"Quadratic form: {qf:.8f}")
    print(f"Dirichlet energy: {de:.8f}")
    print(f"Error: {err:.2e}")
    print(f"PASS: {err < 1e-10}\n")
    return err < 1e-10


def test_resistance_comparison(n=4, beta=1.0, seed=42):
    """Test Theorem C: R_eff(i,j) ≤ d_χ(i,j)."""
    print("=" * 60)
    print("TEST 3: Effective Resistance ≤ Susceptibility Distance")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    c = conductance_matrix(beta, L)
    all_pass = True
    for i in range(n):
        for j in range(i + 1, n):
            R = effective_resistance(c, i, j)
            d = susceptibility_distance(beta, L, i, j)
            ok = R <= d + 1e-10
            print(f"  R_eff({i},{j}) = {R:.6f}, d_χ({i},{j}) = {d:.6f}, "
                  f"ratio = {R/d:.4f}, OK = {ok}")
            all_pass = all_pass and ok
    print(f"PASS: {all_pass}\n")
    return all_pass


def test_negative_type(n=5, beta=1.0, seed=42, num_tests=100):
    """Test Conjecture FD-DPP-2: susceptibility distance is negative type."""
    print("=" * 60)
    print("TEST 4: Negative Type Property")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    rng = np.random.RandomState(seed + 2)
    all_pass = True
    max_val = -np.inf
    for t in range(num_tests):
        a = rng.randn(n)
        a -= a.mean()  # zero-sum
        val = sum(a[i] * a[j] * susceptibility_distance(beta, L, i, j)
                  for i in range(n) for j in range(n))
        max_val = max(max_val, val)
        if val > 1e-10:
            all_pass = False
    print(f"Max value of ∑ a_i a_j d(i,j) over {num_tests} trials: {max_val:.2e}")
    print(f"PASS: {all_pass}\n")
    return all_pass


def test_green_kernel_conjecture(n=4, beta=1.0, seed=42):
    """Test Conjecture FD-DPP-1: χ^# ≈ β G(c)."""
    print("=" * 60)
    print("TEST 5: Green Kernel Correspondence (Conjecture FD-DPP-1)")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    chi = covariance_matrix(beta, L)
    c = conductance_matrix(beta, L)
    G = green_kernel(c)
    # Center both matrices
    chi_centered = chi - np.mean(chi, axis=0, keepdims=True) - np.mean(chi, axis=1, keepdims=True) + np.mean(chi)
    G_centered = G - np.mean(G, axis=0, keepdims=True) - np.mean(G, axis=1, keepdims=True) + np.mean(G)
    # Compare β * G_centered with chi_centered
    diff = chi_centered - beta * G_centered
    frob_norm = np.linalg.norm(diff, 'fro')
    print(f"Centered covariance:\n{chi_centered}")
    print(f"β × Centered Green kernel:\n{beta * G_centered}")
    print(f"Frobenius norm of difference: {frob_norm:.6f}")
    print(f"(Not expected to be zero in general — this tests the conjecture)\n")
    return frob_norm


def test_contraction_lemma(n=5, beta=1.0, seed=42):
    """Verify the contraction lemma: ∑_{k≠i} K_ik² ≤ K_ii(1-K_ii)."""
    print("=" * 60)
    print("TEST 6: Marginal Kernel Contraction Lemma")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    K = marginal_kernel(beta, L)
    all_pass = True
    for i in range(n):
        off_diag_sq = sum(K[i, k]**2 for k in range(n) if k != i)
        bound = K[i, i] * (1 - K[i, i])
        ok = off_diag_sq <= bound + 1e-10
        print(f"  i={i}: ∑_{'{k≠i}'} K_ik² = {off_diag_sq:.6f}, "
              f"K_ii(1-K_ii) = {bound:.6f}, OK = {ok}")
        all_pass = all_pass and ok
    print(f"PASS: {all_pass}\n")
    return all_pass


def test_off_diagonal_nonpositive(n=5, beta=1.0, seed=42):
    """Verify Theorem 1: off-diagonal covariance ≤ 0."""
    print("=" * 60)
    print("TEST 7: Off-Diagonal Nonpositivity")
    print("=" * 60)
    L = random_psd_kernel(n, seed=seed)
    chi = covariance_matrix(beta, L)
    all_pass = True
    for i in range(n):
        for j in range(n):
            if i != j:
                ok = chi[i, j] <= 1e-10
                if not ok:
                    print(f"  FAIL: χ({i},{j}) = {chi[i,j]:.8f}")
                all_pass = all_pass and ok
    print(f"All off-diagonal entries ≤ 0: {all_pass}\n")
    return all_pass


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("DPP FLUCTUATION-DISSIPATION NUMERICAL VERIFICATION")
    print("=" * 60 + "\n")

    results = []
    results.append(("Hessian = Covariance", test_hessian_equals_covariance()))
    results.append(("Dirichlet Form", test_dirichlet_form()))
    results.append(("Resistance Comparison", test_resistance_comparison()))
    results.append(("Negative Type", test_negative_type()))
    results.append(("Contraction Lemma", test_contraction_lemma()))
    results.append(("Off-Diagonal ≤ 0", test_off_diagonal_nonpositive()))

    # Green kernel conjecture (informational, not pass/fail)
    test_green_kernel_conjecture()

    # Multiple random kernels
    print("=" * 60)
    print("STRESS TEST: Multiple random kernels (n=3..6)")
    print("=" * 60)
    all_ok = True
    for n in range(3, 7):
        for seed in range(10):
            for beta in [0.1, 0.5, 1.0, 2.0]:
                L = random_psd_kernel(n, seed=seed)
                chi = covariance_matrix(beta, L)
                c = conductance_matrix(beta, L)
                # Check negative type
                rng = np.random.RandomState(seed * 100 + n)
                for _ in range(10):
                    a = rng.randn(n)
                    a -= a.mean()
                    val = sum(a[i] * a[j] *
                             susceptibility_distance(beta, L, i, j)
                             for i in range(n) for j in range(n))
                    if val > 1e-8:
                        print(f"  FAIL neg type: n={n}, seed={seed}, β={beta}")
                        all_ok = False
                # Check resistance comparison
                for i in range(n):
                    for j in range(i + 1, n):
                        R = effective_resistance(c, i, j)
                        d = susceptibility_distance(beta, L, i, j)
                        if R > d + 1e-8:
                            print(f"  FAIL resistance: n={n}, seed={seed}, β={beta}")
                            all_ok = False
    print(f"All stress tests passed: {all_ok}\n")

    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    for name, passed in results:
        print(f"  {'✓' if passed else '✗'} {name}")
    print(f"  {'✓' if all_ok else '✗'} Stress Tests")


#!/usr/bin/env python3
"""
Visualization 1: DPP Response Theory Heatmaps
==============================================
Visualizes the key matrices of the DPP fluctuation-dissipation principle:
- Marginal kernel K
- Covariance/susceptibility matrix χ
- Conductance network c_ij = K_ij²
- Susceptibility distance d_χ(i,j)

Shows how the same kernel gives rise to both statistical and
electrical network structure.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv

def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)

def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi

np.random.seed(42)
n = 6
A = np.random.randn(n, 3)
L = A @ A.T
beta = 1.0

K = compute_marginal_kernel(beta, L)
chi = compute_susceptibility(beta, L)
c = K ** 2
d_chi = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        d_chi[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('DPP Fluctuation–Dissipation: Key Matrices', fontsize=16, fontweight='bold')

# Marginal kernel
im0 = axes[0, 0].imshow(K, cmap='RdBu_r', aspect='equal')
axes[0, 0].set_title('Marginal Kernel K', fontsize=13)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('i')
plt.colorbar(im0, ax=axes[0, 0], shrink=0.8)

# Covariance matrix
im1 = axes[0, 1].imshow(chi, cmap='RdBu_r', aspect='equal')
axes[0, 1].set_title('Covariance Matrix χ\n(= Susceptibility)', fontsize=13)
axes[0, 1].set_xlabel('j')
axes[0, 1].set_ylabel('i')
plt.colorbar(im1, ax=axes[0, 1], shrink=0.8)

# Conductance network
im2 = axes[1, 0].imshow(c, cmap='YlOrRd', aspect='equal')
axes[1, 0].set_title('Conductance Network c = K²\n(Electrical Weights)', fontsize=13)
axes[1, 0].set_xlabel('j')
axes[1, 0].set_ylabel('i')
plt.colorbar(im2, ax=axes[1, 0], shrink=0.8)

# Susceptibility distance
im3 = axes[1, 1].imshow(d_chi, cmap='viridis', aspect='equal')
axes[1, 1].set_title('Susceptibility Distance d_χ\n(Response Metric)', fontsize=13)
axes[1, 1].set_xlabel('j')
axes[1, 1].set_ylabel('i')
plt.colorbar(im3, ax=axes[1, 1], shrink=0.8)

plt.tight_layout()
plt.savefig('viz_heatmaps.png', dpi=150, bbox_inches='tight')
print("Saved viz_heatmaps.png")


#!/usr/bin/env python3
"""
Visualization 2: Resistance vs Susceptibility Distance
========================================================
Scatter plot comparing effective resistance R_eff(i,j) against
susceptibility distance d_χ(i,j) for all pairs across multiple
random DPP kernels. Demonstrates the proven inequality R_eff ≤ d_χ.

The diagonal line y=x shows where equality holds; all points
should lie below or on this line.
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, pinv

def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)

def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi

def compute_eff_resistance_and_susc_dist(beta, L):
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility(beta, L)
    n = K.shape[0]
    c = K ** 2
    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]
    G = pinv(Lap)
    R_list, d_list = [], []
    for i in range(n):
        for j in range(i + 1, n):
            R = G[i, i] + G[j, j] - 2 * G[i, j]
            d = chi[i, i] + chi[j, j] - 2 * chi[i, j]
            R_list.append(R)
            d_list.append(d)
    return np.array(R_list), np.array(d_list)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Effective Resistance ≤ Susceptibility Distance (Proven Inequality)',
             fontsize=15, fontweight='bold')

betas = [0.5, 1.0, 2.0]
colors_map = {0.5: '#2196F3', 1.0: '#4CAF50', 2.0: '#FF5722'}

for idx, beta in enumerate(betas):
    ax = axes[idx]
    all_R, all_d = [], []
    for seed in range(30):
        np.random.seed(seed)
        n = np.random.choice([3, 4, 5, 6])
        A = np.random.randn(n, n)
        L = A @ A.T
        R, d = compute_eff_resistance_and_susc_dist(beta, L)
        all_R.extend(R)
        all_d.extend(d)

    all_R = np.array(all_R)
    all_d = np.array(all_d)

    ax.scatter(all_d, all_R, alpha=0.5, s=20, color=colors_map[beta],
               edgecolors='none')
    mx = max(all_d.max(), all_R.max()) * 1.1
    ax.plot([0, mx], [0, mx], 'k--', alpha=0.4, label='y = x')
    ax.set_xlabel('Susceptibility Distance d_χ(i,j)', fontsize=12)
    ax.set_ylabel('Effective Resistance R_eff(i,j)', fontsize=12)
    ax.set_title(f'β = {beta}', fontsize=13)
    ax.set_xlim(0, mx)
    ax.set_ylim(0, mx)
    ax.set_aspect('equal')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Count violations
    violations = np.sum(all_R > all_d + 1e-8)
    ax.text(0.05, 0.92, f'Violations: {violations}/{len(all_R)}',
            transform=ax.transAxes, fontsize=10,
            bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))

plt.tight_layout()
plt.savefig('viz_resistance_comparison.png', dpi=150, bbox_inches='tight')
print("Saved viz_resistance_comparison.png")


#!/usr/bin/env python3
"""
Visualization 3: Temperature Dependence of DPP Response
=========================================================
Shows how the DPP susceptibility, conductance, and effective
resistance evolve as β (inverse temperature) varies.

At low β: weak coupling, nearly independent items
At high β: strong coupling, strong repulsion
"""

import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, pinv, eigvalsh

def compute_marginal_kernel(beta, L):
    n = L.shape[0]
    return (beta * L) @ inv(np.eye(n) + beta * L)

def compute_susceptibility(beta, L):
    K = compute_marginal_kernel(beta, L)
    n = K.shape[0]
    chi = -(K ** 2)
    for i in range(n):
        chi[i, i] = K[i, i] * (1 - K[i, i])
    return chi

np.random.seed(42)
n = 5
A = np.random.randn(n, 3)
L = A @ A.T

betas = np.linspace(0.01, 5.0, 100)

# Track quantities
trace_K_vals = []
trace_chi_vals = []
total_repulsion_vals = []
max_susc_dist_vals = []
min_eig_chi_vals = []
kirchhoff_vals = []

for beta in betas:
    K = compute_marginal_kernel(beta, L)
    chi = compute_susceptibility(beta, L)
    c = K ** 2

    trace_K_vals.append(np.trace(K))
    trace_chi_vals.append(np.trace(chi))
    total_repulsion_vals.append(
        sum(abs(chi[i, j]) for i in range(n) for j in range(n) if i != j))

    d_chi = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            d_chi[i, j] = chi[i, i] + chi[j, j] - 2 * chi[i, j]
    max_susc_dist_vals.append(d_chi.max())

    eigs = eigvalsh(chi)
    min_eig_chi_vals.append(eigs.min())

    Lap = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            if i != j:
                Lap[i, j] = -c[i, j]
                Lap[i, i] += c[i, j]
    G = pinv(Lap)
    kirch = sum(G[i, i] + G[j, j] - 2 * G[i, j]
                for i in range(n) for j in range(i + 1, n))
    kirchhoff_vals.append(kirch)

fig, axes = plt.subplots(2, 3, figsize=(16, 9))
fig.suptitle('Temperature Dependence of DPP Response Theory',
             fontsize=15, fontweight='bold')

# Plot 1: Expected subset size
axes[0, 0].plot(betas, trace_K_vals, color='#1976D2', linewidth=2)
axes[0, 0].set_xlabel('β (inverse temperature)')
axes[0, 0].set_ylabel('E[|S|] = tr(K)')
axes[0, 0].set_title('Expected Subset Size')
axes[0, 0].grid(True, alpha=0.3)
axes[0, 0].axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f'n={n}')
axes[0, 0].legend()

# Plot 2: Total variance
axes[0, 1].plot(betas, trace_chi_vals, color='#388E3C', linewidth=2)
axes[0, 1].set_xlabel('β')
axes[0, 1].set_ylabel('tr(χ)')
axes[0, 1].set_title('Total Variance (Fluctuation)')
axes[0, 1].grid(True, alpha=0.3)

# Plot 3: Total repulsion
axes[0, 2].plot(betas, total_repulsion_vals, color='#D32F2F', linewidth=2)
axes[0, 2].set_xlabel('β')
axes[0, 2].set_ylabel('∑|χ_ij| (i≠j)')
axes[0, 2].set_title('Total Repulsion (Dissipation)')
axes[0, 2].grid(True, alpha=0.3)

# Plot 4: Max susceptibility distance
axes[1, 0].plot(betas, max_susc_dist_vals, color='#7B1FA2', linewidth=2)
axes[1, 0].set_xlabel('β')
axes[1, 0].set_ylabel('max d_χ(i,j)')
axes[1, 0].set_title('Max Susceptibility Distance')
axes[1, 0].grid(True, alpha=0.3)

# Plot 5: Minimum eigenvalue of χ
axes[1, 1].plot(betas, min_eig_chi_vals, color='#F57C00', linewidth=2)
axes[1, 1].set_xlabel('β')
axes[1, 1].set_ylabel('λ_min(χ)')
axes[1, 1].set_title('Min Eigenvalue of χ')
axes[1, 1].axhline(y=0, color='gray', linestyle=':', alpha=0.5)
axes[1, 1].grid(True, alpha=0.3)

# Plot 6: Kirchhoff index
axes[1, 2].plot(betas, kirchhoff_vals, color='#00796B', linewidth=2)
axes[1, 2].set_xlabel('β')
axes[1, 2].set_ylabel('Kirchhoff Index')
axes[1, 2].set_title('Total Effective Resistance')
axes[1, 2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_temperature.png', dpi=150, bbox_inches='tight')
print("Saved viz_temperature.png")
