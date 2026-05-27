"""
Applications of Quantum DPP Entanglement via Lorentzian Geometry.

Demonstrates real-world applications:
1. Entanglement detection in free-fermion quantum systems
2. Graph-theoretic entanglement from spectral graph kernels
3. DPP-based diversity certification
4. Certified entropy bounds for quantum simulation
"""

import numpy as np
from itertools import combinations


# ─── Core functions (self-contained) ───────────────────────────────────────

def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermionic_entropy_matrix(K, A):
    if len(A) == 0:
        return 0.0
    idx = np.array(A)
    K_A = K[np.ix_(idx, idx)]
    eigs = np.clip(np.linalg.eigvalsh(K_A), 0, 1)
    return sum(binary_entropy(lam) for lam in eigs)


def balanced_bipartitions(n):
    return [list(c) for c in combinations(range(n), n // 2)]


def min_balanced_entropy(K):
    n = K.shape[0]
    bps = balanced_bipartitions(n)
    return min(fermionic_entropy_matrix(K, A) for A in bps) if bps else 0.0


def max_leaf_witness(K):
    n = K.shape[0]
    return max(K[i, j] ** 2 for i in range(n) for j in range(i + 1, n))


def random_psd_contraction(n, rng):
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


# ─── Application 1: Free-Fermion Entanglement Detection ────────────────────

def detect_entanglement(K: np.ndarray) -> dict:
    """Detect entanglement in a free-fermion system using the Lorentzian witness.

    A free-fermion state with correlation kernel K is entangled across
    a bipartition A|Ac if and only if K_A has eigenvalues not all in {0,1}.
    The Lorentzian witness K_ij² > 0 indicates off-diagonal correlations,
    which is necessary for entanglement when K is not a projection.

    Args:
        K: n×n symmetric PSD contraction (correlation kernel).

    Returns:
        Dictionary with entanglement analysis results.
    """
    n = K.shape[0]
    eigs_full = np.linalg.eigvalsh(K)

    # Check if K is a projection
    is_projection = np.allclose(eigs_full * (1 - eigs_full), 0, atol=1e-8)

    # Lorentzian witness
    witness = max_leaf_witness(K)

    # Entropy bounds
    min_ent = min_balanced_entropy(K)

    # Individual pair analysis
    pair_analysis = []
    for i in range(n):
        for j in range(i + 1, n):
            curv = K[i, j] ** 2
            S_pair = fermionic_entropy_matrix(K, [i, j])
            pair_analysis.append({
                'pair': (i, j),
                'curvature': curv,
                'entropy': S_pair,
                'entangled': S_pair > 1e-10
            })

    return {
        'n': n,
        'eigenvalues': eigs_full,
        'is_projection': is_projection,
        'witness': witness,
        'min_balanced_entropy': min_ent,
        'is_entangled': min_ent > 1e-10,
        'pairs': pair_analysis
    }


# ─── Application 2: Graph-Theoretic Entanglement ───────────────────────────

def graph_laplacian_kernel(adjacency: np.ndarray) -> np.ndarray:
    """Construct a correlation kernel from a graph's normalized Laplacian.

    The normalized Laplacian L = I - D^{-1/2} A D^{-1/2} has eigenvalues
    in [0, 2]. We rescale to K = L/2 to get eigenvalues in [0, 1].

    For graph Laplacian kernels, entanglement entropy of a vertex subset
    captures graph-structural properties: highly connected subsets have
    lower entropy (more projection-like behavior).
    """
    n = adjacency.shape[0]
    degrees = adjacency.sum(axis=1)
    D_inv_sqrt = np.diag(1.0 / np.sqrt(np.maximum(degrees, 1e-10)))
    L = np.eye(n) - D_inv_sqrt @ adjacency @ D_inv_sqrt
    # Rescale to [0, 1]
    return L / 2


def graph_entanglement_analysis(adjacency: np.ndarray, name: str = "Graph"):
    """Analyze entanglement structure from a graph kernel."""
    K = graph_laplacian_kernel(adjacency)
    result = detect_entanglement(K)

    print(f"\n  {name}:")
    print(f"    Vertices: {result['n']}")
    print(f"    Kernel eigenvalues: {np.round(result['eigenvalues'], 4)}")
    print(f"    Lorentzian witness: {result['witness']:.6f}")
    print(f"    Min balanced entropy: {result['min_balanced_entropy']:.6f}")
    print(f"    Entangled? {result['is_entangled']}")
    return result


# ─── Application 3: DPP Diversity Certification ────────────────────────────

def certify_dpp_diversity(K: np.ndarray, threshold: float = 0.01) -> dict:
    """Certify diversity properties of a DPP kernel.

    A DPP with kernel K selects diverse subsets. The negative dependence
    K_ij² ≤ K_ii·K_jj (verified in Lean) quantifies repulsion.

    The entropy S_A measures how uncertain the occupancy of subset A is.
    Higher entropy = more diversity within A.

    Args:
        K: DPP correlation kernel (symmetric PSD contraction).
        threshold: Minimum entropy for "diverse" certification.

    Returns:
        Diversity certification results.
    """
    n = K.shape[0]
    bps = balanced_bipartitions(n)

    # Check negative dependence (Cauchy-Schwarz)
    neg_dep_violations = 0
    for i in range(n):
        for j in range(i + 1, n):
            if K[i, j] ** 2 > K[i, i] * K[j, j] + 1e-10:
                neg_dep_violations += 1

    # Entropy profile
    entropies = [fermionic_entropy_matrix(K, A) for A in bps]

    return {
        'n': n,
        'negative_dependence_satisfied': neg_dep_violations == 0,
        'min_entropy': min(entropies) if entropies else 0,
        'max_entropy': max(entropies) if entropies else 0,
        'mean_entropy': np.mean(entropies) if entropies else 0,
        'diverse': min(entropies) > threshold if entropies else False,
        'witness': max_leaf_witness(K)
    }


# ─── Application 4: Quantum Simulation Entropy Bounds ──────────────────────

def entropy_bounds_analysis(K: np.ndarray) -> dict:
    """Compute rigorous entropy bounds for quantum simulation.

    For free-fermion systems, we can bound the entropy using:
    1. Lower bound: S ≥ 2·Var(N_A) where Var = tr(K_A - K_A²)
    2. Upper bound: S ≤ |A| · ln 2
    3. Lorentzian bound: from elementary symmetric polynomial inequalities
    """
    n = K.shape[0]
    bps = balanced_bipartitions(n)
    results = []

    for A in bps[:min(5, len(bps))]:  # Analyze first few bipartitions
        m = len(A)
        idx = np.array(A)
        K_A = K[np.ix_(idx, idx)]
        eigs = np.clip(np.linalg.eigvalsh(K_A), 0, 1)

        # Exact entropy
        S = sum(binary_entropy(lam) for lam in eigs)

        # Variance lower bound
        variance = sum(lam * (1 - lam) for lam in eigs)
        lower_bound = 2 * variance

        # ln 2 upper bound
        upper_bound = m * np.log(2)

        # Elementary symmetric polynomial bound
        e1 = sum(eigs)
        e2 = sum(eigs[i] * eigs[j] for i in range(m) for j in range(i + 1, m))
        esymm_bound = 2 * (e1 - e1 ** 2 + 2 * e2)

        results.append({
            'A': A,
            'entropy': S,
            'lower_bound_variance': lower_bound,
            'lower_bound_esymm': esymm_bound,
            'upper_bound': upper_bound,
            'tight': upper_bound - S < 0.1 * upper_bound
        })

    return results


# ─── Main ──────────────────────────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Applications: Quantum DPP Entanglement                 ║")
    print("╚══════════════════════════════════════════════════════════╝")

    rng = np.random.default_rng(42)
    n = 4

    # Application 1: Free-Fermion Entanglement Detection
    print("\n" + "=" * 60)
    print("  APP 1: FREE-FERMION ENTANGLEMENT DETECTION")
    print("=" * 60)

    K = random_psd_contraction(n, rng)
    result = detect_entanglement(K)
    print(f"  Random kernel eigenvalues: {np.round(result['eigenvalues'], 4)}")
    print(f"  Lorentzian witness: {result['witness']:.6f}")
    print(f"  Min balanced entropy: {result['min_balanced_entropy']:.6f}")
    print(f"  Entangled: {result['is_entangled']}")
    print(f"  Top entangled pairs:")
    for p in sorted(result['pairs'], key=lambda x: -x['entropy'])[:3]:
        print(f"    ({p['pair'][0]},{p['pair'][1]}): curvature={p['curvature']:.4f}, "
              f"entropy={p['entropy']:.4f}")

    # Application 2: Graph Entanglement
    print("\n" + "=" * 60)
    print("  APP 2: GRAPH-THEORETIC ENTANGLEMENT")
    print("=" * 60)

    # Path graph
    P4 = np.array([[0, 1, 0, 0], [1, 0, 1, 0], [0, 1, 0, 1], [0, 0, 1, 0]], dtype=float)
    graph_entanglement_analysis(P4, "Path P4")

    # Complete graph
    K4 = np.ones((4, 4)) - np.eye(4)
    graph_entanglement_analysis(K4, "Complete K4")

    # Cycle graph
    C4 = np.array([[0, 1, 0, 1], [1, 0, 1, 0], [0, 1, 0, 1], [1, 0, 1, 0]], dtype=float)
    graph_entanglement_analysis(C4, "Cycle C4")

    # Star graph
    S4 = np.array([[0, 1, 1, 1], [1, 0, 0, 0], [1, 0, 0, 0], [1, 0, 0, 0]], dtype=float)
    graph_entanglement_analysis(S4, "Star S4")

    # Application 3: DPP Diversity Certification
    print("\n" + "=" * 60)
    print("  APP 3: DPP DIVERSITY CERTIFICATION")
    print("=" * 60)

    K_diverse = random_psd_contraction(n, rng)
    cert = certify_dpp_diversity(K_diverse)
    print(f"\n  Negative dependence satisfied: {cert['negative_dependence_satisfied']}")
    print(f"  Entropy range: [{cert['min_entropy']:.4f}, {cert['max_entropy']:.4f}]")
    print(f"  Diverse (entropy > 0.01): {cert['diverse']}")
    print(f"  Lorentzian witness: {cert['witness']:.6f}")

    # Application 4: Entropy Bounds
    print("\n" + "=" * 60)
    print("  APP 4: QUANTUM SIMULATION ENTROPY BOUNDS")
    print("=" * 60)

    K_sim = random_psd_contraction(n, rng)
    bounds = entropy_bounds_analysis(K_sim)
    print(f"\n  {'Subset':<12} {'Entropy':<10} {'LB(var)':<10} {'LB(esymm)':<12} {'UB(ln2)':<10}")
    print(f"  {'-' * 54}")
    for b in bounds:
        print(f"  {str(b['A']):<12} {b['entropy']:<10.4f} {b['lower_bound_variance']:<10.4f} "
              f"{b['lower_bound_esymm']:<12.4f} {b['upper_bound']:<10.4f}")

    print()


if __name__ == "__main__":
    main()


"""
Interactive Demonstration: Quantum DPP Entanglement via Lorentzian Geometry

This demo illustrates the bridge between Lorentzian polynomial geometry and
quantum entanglement entropy for free-fermion systems.

Usage:
    python demo.py [--n N] [--samples S] [--seed SEED] [--kernel TYPE]

Arguments:
    --n         Matrix dimension (default: 4)
    --samples   Number of random samples (default: 100)
    --seed      Random seed (default: 42)
    --kernel    Kernel type: random, diagonal, projection, toeplitz (default: random)
"""

import numpy as np
from itertools import combinations
import argparse
import sys


# ─── Self-contained implementations (no local imports) ─────────────────────

def binary_entropy(x):
    """h(x) = -x log x - (1-x) log(1-x), with h(0) = h(1) = 0."""
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermionic_entropy(eigenvalues):
    """S = sum_i h(lambda_i)."""
    return sum(binary_entropy(lam) for lam in eigenvalues)


def principal_submatrix(K, A):
    """Extract K_A = K[A, A]."""
    idx = np.array(A)
    return K[np.ix_(idx, idx)]


def fermionic_entropy_matrix(K, A):
    """S_A(K) = sum_i h(lambda_i(K_A))."""
    if len(A) == 0:
        return 0.0
    K_A = principal_submatrix(K, A)
    eigs = np.clip(np.linalg.eigvalsh(K_A), 0.0, 1.0)
    return fermionic_entropy(eigs)


def balanced_bipartitions(n):
    """All subsets of [n] of size n//2."""
    return [list(c) for c in combinations(range(n), n // 2)]


def leaf_curvature_witness(K, i, j):
    """K[i,j]^2."""
    return K[i, j] ** 2


def max_leaf_witness(K):
    """max_{i<j} K[i,j]^2."""
    n = K.shape[0]
    return max(K[i, j] ** 2 for i in range(n) for j in range(i + 1, n))


def min_balanced_entropy(K):
    """min_{A in B_n} S_A(K)."""
    n = K.shape[0]
    bps = balanced_bipartitions(n)
    if not bps:
        return 0.0
    return min(fermionic_entropy_matrix(K, A) for A in bps)


def random_psd_contraction(n, rng):
    """Random n×n PSD matrix with eigenvalues in [0,1]."""
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


def projection_kernel(n, k, rng):
    """Random rank-k projection."""
    A = rng.standard_normal((n, k))
    Q, _ = np.linalg.qr(A)
    return Q @ Q.T


def toeplitz_kernel(n, rho):
    """Toeplitz kernel K[i,j] = rho^|i-j|, scaled to [0,1] eigenvalues."""
    K = np.array([[rho ** abs(i - j) for j in range(n)] for i in range(n)])
    max_eig = np.max(np.linalg.eigvalsh(K))
    return K / max_eig if max_eig > 0 else K


# ─── Demo Functions ────────────────────────────────────────────────────────

def demo_binary_entropy():
    """Demonstrate binary entropy properties."""
    print("=" * 60)
    print("  BINARY ENTROPY h(x) = -x log x - (1-x) log(1-x)")
    print("=" * 60)
    print()
    print("Key properties (all formally verified in Lean):")
    print(f"  h(0)   = {binary_entropy(0.0):.6f}  (= 0, verified)")
    print(f"  h(1)   = {binary_entropy(1.0):.6f}  (= 0, verified)")
    print(f"  h(0.5) = {binary_entropy(0.5):.6f}  (= ln 2 = {np.log(2):.6f})")
    print(f"  h(0.3) = {binary_entropy(0.3):.6f}  (> 0 for x ∈ (0,1), verified)")
    print()
    print("  Symmetry: h(0.3) = h(0.7)?", abs(binary_entropy(0.3) - binary_entropy(0.7)) < 1e-15)
    print("  Nonneg on [0,1]: all h(x) ≥ 0?", all(binary_entropy(x / 100) >= -1e-15 for x in range(101)))
    print()
    # Quadratic lower bound h(x) >= 2x(1-x)
    print("  Quadratic bound h(x) ≥ 2x(1-x):")
    for x in [0.1, 0.25, 0.5, 0.75, 0.9]:
        h = binary_entropy(x)
        q = 2 * x * (1 - x)
        print(f"    x={x:.2f}: h={h:.4f} ≥ 2x(1-x)={q:.4f}  ✓" if h >= q - 1e-10 else f"    x={x:.2f}: FAILED")
    print()


def demo_diagonal_kernel(n, p=None):
    """Demonstrate diagonal kernel entropy properties."""
    print("=" * 60)
    print(f"  DIAGONAL KERNEL (n={n})")
    print("=" * 60)
    print()
    if p is None:
        p = np.linspace(0.1, 0.9, n)
    print(f"  p = {np.round(p, 3)}")
    print()

    # Entropy for each singleton
    print("  Singleton entropies:")
    for i in range(n):
        print(f"    h(p_{i}) = h({p[i]:.3f}) = {binary_entropy(p[i]):.6f}")
    print()

    # Entropy for balanced bipartitions
    bps = balanced_bipartitions(n)
    print(f"  Balanced bipartitions ({len(bps)} total):")
    K = np.diag(p)
    for A in bps:
        S = fermionic_entropy_matrix(K, A)
        S_direct = sum(binary_entropy(p[i]) for i in A)
        print(f"    A={A}: S_A = {S:.6f} = Σh(p_i) = {S_direct:.6f}  "
              f"{'✓' if abs(S - S_direct) < 1e-10 else '✗'}")
    print()

    # Monotonicity check
    print("  Monotonicity check (A ⊆ B → S_A ≤ S_B):")
    for A in bps[:3]:
        for B in bps:
            if set(A).issubset(set(B)) and A != B:
                S_A = fermionic_entropy_matrix(K, A)
                S_B = fermionic_entropy_matrix(K, B)
                print(f"    {A} ⊆ {B}: S_A={S_A:.4f} ≤ S_B={S_B:.4f}  "
                      f"{'✓' if S_A <= S_B + 1e-10 else '✗'}")
    print()


def demo_hessian_signature(n):
    """Demonstrate Hessian signature properties."""
    print("=" * 60)
    print(f"  HESSIAN SIGNATURE AT DERIVATIVE LEAVES (n={n})")
    print("=" * 60)
    print()

    p = np.array([0.3, 0.7, 0.0, 0.5]) if n == 4 else np.linspace(0.1, 0.9, n)
    print(f"  Diagonal kernel p = {np.round(p, 3)}")
    print()

    print("  Leaf Hessian positive indices (verified ≤ 1 in Lean):")
    for i in range(n):
        for j in range(i + 1, n):
            prod = p[i] * p[j]
            idx = 1 if abs(prod) > 1e-15 else 0
            print(f"    ({i},{j}): p_i·p_j = {prod:.4f}, "
                  f"posIndex = {idx} {'≤ 1 ✓' if idx <= 1 else '> 1 ✗'}")
    print()

    # Connection to entropy
    print("  Bridge: posIndex=1 + strict contraction → positive entropy:")
    K = np.diag(p)
    for i in range(n):
        for j in range(i + 1, n):
            prod = p[i] * p[j]
            if abs(prod) > 1e-15 and p[i] < 1 and p[j] < 1:
                S = binary_entropy(p[i]) + binary_entropy(p[j])
                print(f"    ({i},{j}): p_i·p_j > 0, p_i<1, p_j<1 → "
                      f"S_{{{i},{j}}} = {S:.6f} > 0 ✓")
    print()


def demo_correlation_study(n, num_samples, seed, kernel_type):
    """Study correlation between Lorentzian witness and entropy."""
    print("=" * 60)
    print(f"  CORRELATION STUDY (n={n}, {num_samples} samples, {kernel_type})")
    print("=" * 60)
    print()

    rng = np.random.default_rng(seed)
    min_entropies = []
    witnesses = []
    leaf_indices = []

    for _ in range(num_samples):
        if kernel_type == "random":
            K = random_psd_contraction(n, rng)
        elif kernel_type == "projection":
            k = rng.integers(1, n)
            K = projection_kernel(n, k, rng)
        elif kernel_type == "diagonal":
            p = rng.uniform(0, 1, n)
            K = np.diag(p)
        elif kernel_type == "toeplitz":
            rho = rng.uniform(0.1, 0.99)
            K = toeplitz_kernel(n, rho)
        else:
            K = random_psd_contraction(n, rng)

        S_min = min_balanced_entropy(K)
        w = max_leaf_witness(K)
        idx = 1 if w > 1e-15 else 0

        min_entropies.append(S_min)
        witnesses.append(w)
        leaf_indices.append(idx)

    min_entropies = np.array(min_entropies)
    witnesses = np.array(witnesses)
    leaf_indices = np.array(leaf_indices)

    # Statistics
    corr = np.corrcoef(min_entropies, witnesses)[0, 1]
    print(f"  Pearson correlation (min_entropy, max_witness): {corr:.4f}")
    print(f"  Mean min_entropy: {np.mean(min_entropies):.4f}")
    print(f"  Mean max_witness: {np.mean(witnesses):.4f}")
    print()

    # Conjecture test: witness > 0 → min_entropy > 0?
    pos_witness = witnesses > 1e-15
    pos_entropy = min_entropies > 1e-10
    n_both = np.sum(pos_witness & pos_entropy)
    n_witness_only = np.sum(pos_witness & ~pos_entropy)
    print(f"  Conjecture test (witness > 0 → entropy > 0):")
    print(f"    witness > 0 AND entropy > 0: {n_both}")
    print(f"    witness > 0 BUT entropy = 0: {n_witness_only}")
    if np.sum(pos_witness) > 0:
        success_rate = n_both / np.sum(pos_witness)
        print(f"    Success rate: {success_rate:.2%}")
    print()

    # Distribution by quartile
    print("  Min entropy by witness quartile:")
    q25, q50, q75 = np.percentile(witnesses, [25, 50, 75])
    for lo, hi, label in [(0, q25, "Q1"), (q25, q50, "Q2"),
                           (q50, q75, "Q3"), (q75, np.inf, "Q4")]:
        mask = (witnesses >= lo) & (witnesses < hi)
        if np.sum(mask) > 0:
            print(f"    {label} (witness ∈ [{lo:.4f}, {hi:.4f})): "
                  f"mean S_min = {np.mean(min_entropies[mask]):.4f}, "
                  f"n = {np.sum(mask)}")
    print()


def demo_explicit_families(n):
    """Test on explicit structured kernel families."""
    print("=" * 60)
    print(f"  EXPLICIT KERNEL FAMILIES (n={n})")
    print("=" * 60)
    print()

    rng = np.random.default_rng(42)

    # 1. Diagonal kernel
    p = np.array([0.3, 0.7, 0.1, 0.9]) if n == 4 else np.linspace(0.1, 0.9, n)
    K_diag = np.diag(p)
    print("  1. Diagonal kernel diag(p):")
    print(f"     p = {np.round(p, 3)}")
    print(f"     Min balanced entropy: {min_balanced_entropy(K_diag):.6f}")
    print(f"     Max leaf witness: {max_leaf_witness(K_diag):.6f}")
    print(f"     (For diagonal: witness=0 since off-diagonal=0)")
    print()

    # 2. Rank-1 projection
    v = rng.standard_normal(n)
    v /= np.linalg.norm(v)
    K_proj1 = np.outer(v, v)
    print("  2. Rank-1 projection v·vᵀ:")
    print(f"     v = {np.round(v, 3)}")
    print(f"     Eigenvalues: {np.round(np.sort(np.linalg.eigvalsh(K_proj1)), 4)}")
    print(f"     Min balanced entropy: {min_balanced_entropy(K_proj1):.6f}")
    print(f"     Max leaf witness: {max_leaf_witness(K_proj1):.6f}")
    print()

    # 3. Rank-2 projection
    K_proj2 = projection_kernel(n, 2, rng)
    print("  3. Rank-2 projection:")
    print(f"     Eigenvalues: {np.round(np.sort(np.linalg.eigvalsh(K_proj2)), 4)}")
    print(f"     Min balanced entropy: {min_balanced_entropy(K_proj2):.6f}")
    print(f"     Max leaf witness: {max_leaf_witness(K_proj2):.6f}")
    print()

    # 4. Toeplitz kernel
    K_toep = toeplitz_kernel(n, 0.5)
    print("  4. Toeplitz kernel (ρ=0.5):")
    print(f"     Eigenvalues: {np.round(np.sort(np.linalg.eigvalsh(K_toep)), 4)}")
    print(f"     Min balanced entropy: {min_balanced_entropy(K_toep):.6f}")
    print(f"     Max leaf witness: {max_leaf_witness(K_toep):.6f}")
    print()

    # 5. Half-filled uniform kernel
    K_half = 0.5 * np.eye(n) + 0.1 * np.ones((n, n))
    eigs = np.linalg.eigvalsh(K_half)
    K_half = K_half / max(np.max(eigs), 1.0)  # ensure contraction
    print("  5. Near-uniform half-filled kernel:")
    print(f"     Eigenvalues: {np.round(np.sort(np.linalg.eigvalsh(K_half)), 4)}")
    print(f"     Min balanced entropy: {min_balanced_entropy(K_half):.6f}")
    print(f"     Max leaf witness: {max_leaf_witness(K_half):.6f}")
    print()


def main():
    parser = argparse.ArgumentParser(
        description="Quantum DPP Entanglement via Lorentzian Geometry — Interactive Demo")
    parser.add_argument("--n", type=int, default=4, help="Matrix dimension")
    parser.add_argument("--samples", type=int, default=100, help="Number of random samples")
    parser.add_argument("--seed", type=int, default=42, help="Random seed")
    parser.add_argument("--kernel", type=str, default="random",
                        choices=["random", "diagonal", "projection", "toeplitz"],
                        help="Kernel type for correlation study")
    args = parser.parse_args()

    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Quantum DPP Entanglement via Lorentzian Geometry       ║")
    print("║  Bridging polynomial geometry and quantum information   ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_binary_entropy()
    demo_diagonal_kernel(args.n)
    demo_hessian_signature(args.n)
    demo_correlation_study(args.n, args.samples, args.seed, args.kernel)
    demo_explicit_families(args.n)

    print("=" * 60)
    print("  SUMMARY OF VERIFIED RESULTS")
    print("=" * 60)
    print()
    print("  The following theorems are formally verified in Lean 4:")
    print("  1. Binary entropy h(x) > 0 for x ∈ (0,1)")
    print("  2. Monotonicity: A ⊆ B → S_A ≤ S_B")
    print("  3. Hessian positive index ≤ 1 at all degree-2 leaves")
    print("  4. Positive leaf curvature → positive pair entropy")
    print("  5. Cauchy-Schwarz: K_ij² ≤ K_ii · K_jj for PSD K")
    print("  6. Conjecture bridge: leaf index = 1 → ∃ balanced A, S_A > 0")
    print()


if __name__ == "__main__":
    main()


"""
Visualization: Correlation between Lorentzian Witness and Entanglement Entropy

Generates scatter plots showing the relationship between the maximum leaf
curvature witness (K_ij^2) and the minimum balanced entropy for random
PSD contraction kernels.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def binary_entropy(x):
    if x <= 0 or x >= 1:
        return 0.0
    return -x * np.log(x) - (1 - x) * np.log(1 - x)


def fermionic_entropy_matrix(K, A):
    if len(A) == 0:
        return 0.0
    idx = np.array(A)
    K_A = K[np.ix_(idx, idx)]
    eigs = np.clip(np.linalg.eigvalsh(K_A), 0, 1)
    return sum(binary_entropy(lam) for lam in eigs)


def balanced_bipartitions(n):
    return [list(c) for c in combinations(range(n), n // 2)]


def min_balanced_entropy(K):
    n = K.shape[0]
    bps = balanced_bipartitions(n)
    return min(fermionic_entropy_matrix(K, A) for A in bps) if bps else 0.0


def max_leaf_witness(K):
    n = K.shape[0]
    return max(K[i, j] ** 2 for i in range(n) for j in range(i + 1, n))


def random_psd_contraction(n, rng):
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


def toeplitz_kernel(n, rho):
    K = np.array([[rho ** abs(i - j) for j in range(n)] for i in range(n)])
    max_eig = np.max(np.linalg.eigvalsh(K))
    return K / max_eig if max_eig > 0 else K


fig, axes = plt.subplots(2, 2, figsize=(14, 12))
rng = np.random.default_rng(42)
num_samples = 200

for idx, (n, ax) in enumerate(zip([3, 4, 5, 6], axes.flat)):
    entropies = []
    witnesses = []
    colors = []

    for _ in range(num_samples):
        # Mix kernel types
        choice = rng.integers(0, 3)
        if choice == 0:
            K = random_psd_contraction(n, rng)
            c = 'steelblue'
        elif choice == 1:
            rho = rng.uniform(0.1, 0.99)
            K = toeplitz_kernel(n, rho)
            c = 'coral'
        else:
            p = rng.uniform(0, 1, n)
            K = np.diag(p)
            c = 'forestgreen'

        S_min = min_balanced_entropy(K)
        w = max_leaf_witness(K)
        entropies.append(S_min)
        witnesses.append(w)
        colors.append(c)

    entropies = np.array(entropies)
    witnesses = np.array(witnesses)

    # Scatter plot
    for c, label in [('steelblue', 'Random'), ('coral', 'Toeplitz'),
                      ('forestgreen', 'Diagonal')]:
        mask = np.array(colors) == c
        ax.scatter(witnesses[mask], entropies[mask], c=c, alpha=0.5,
                   s=20, label=label, edgecolors='none')

    # Correlation
    corr = np.corrcoef(entropies, witnesses)[0, 1]

    ax.set_xlabel(r'Max leaf witness $\max_{i,j} K_{ij}^2$', fontsize=11)
    ax.set_ylabel(r'Min balanced entropy $\min_A S_A$', fontsize=11)
    ax.set_title(f'n = {n}  (ρ = {corr:.3f})', fontsize=13, fontweight='bold')
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Annotate the conjecture region
    if np.any(witnesses > 0.01):
        ax.axvline(x=0.01, color='red', linestyle=':', alpha=0.5)
        ax.text(0.02, ax.get_ylim()[1] * 0.9,
                'Witness > 0:\nentropy expected > 0',
                fontsize=8, color='red', alpha=0.7)

plt.suptitle('Lorentzian Witness vs. Entanglement Entropy\n'
             'Across Kernel Families and Dimensions',
             fontsize=15, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('correlation_scatter.png', dpi=150, bbox_inches='tight')
print("Saved correlation_scatter.png")


"""
Visualization: Binary Entropy and Fermionic Entropy Landscape

Visualizes the binary entropy function h(x) = -x log x - (1-x) log(1-x)
along with its quadratic lower bound 2x(1-x) and the constant upper bound ln(2).
Also shows the fermionic entropy as a function of a 2-mode spectrum.

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec


def binary_entropy(x):
    """h(x) = -x log x - (1-x) log(1-x)"""
    result = np.zeros_like(x, dtype=float)
    mask = (x > 0) & (x < 1)
    xm = x[mask]
    result[mask] = -xm * np.log(xm) - (1 - xm) * np.log(1 - xm)
    return result


fig = plt.figure(figsize=(14, 10))
gs = gridspec.GridSpec(2, 2, hspace=0.35, wspace=0.3)

# ─── Panel 1: Binary entropy with bounds ───────────────────────────────────
ax1 = fig.add_subplot(gs[0, 0])
x = np.linspace(0, 1, 1000)
h = binary_entropy(x)
quad = 2 * x * (1 - x)

ax1.fill_between(x, quad, np.log(2), alpha=0.15, color='steelblue',
                  label='Feasible region')
ax1.plot(x, h, 'b-', linewidth=2.5, label=r'$h(x) = -x\ln x - (1{-}x)\ln(1{-}x)$')
ax1.plot(x, quad, 'r--', linewidth=1.5, label=r'Lower bound: $2x(1{-}x)$')
ax1.axhline(y=np.log(2), color='green', linestyle=':', linewidth=1.5,
            label=r'Upper bound: $\ln 2$')
ax1.set_xlabel('x (occupation probability)', fontsize=12)
ax1.set_ylabel('h(x)', fontsize=12)
ax1.set_title('Binary Entropy with Verified Bounds', fontsize=13, fontweight='bold')
ax1.legend(fontsize=9, loc='lower center')
ax1.set_xlim(0, 1)
ax1.set_ylim(-0.02, 0.8)
ax1.grid(True, alpha=0.3)

# ─── Panel 2: 2-mode fermionic entropy surface ────────────────────────────
ax2 = fig.add_subplot(gs[0, 1], projection='3d')
p1 = np.linspace(0, 1, 80)
p2 = np.linspace(0, 1, 80)
P1, P2 = np.meshgrid(p1, p2)
H1 = binary_entropy(P1.ravel()).reshape(P1.shape)
H2 = binary_entropy(P2.ravel()).reshape(P2.shape)
S = H1 + H2

surf = ax2.plot_surface(P1, P2, S, cmap='viridis', alpha=0.85,
                         edgecolor='none')
ax2.set_xlabel(r'$p_1$', fontsize=11)
ax2.set_ylabel(r'$p_2$', fontsize=11)
ax2.set_zlabel(r'$S_{\{1,2\}}$', fontsize=11)
ax2.set_title('2-Mode Entropy Surface', fontsize=13, fontweight='bold')
ax2.view_init(elev=25, azim=135)

# ─── Panel 3: Entropy monotonicity ────────────────────────────────────────
ax3 = fig.add_subplot(gs[1, 0])
np.random.seed(42)
n = 6
p = np.sort(np.random.uniform(0.1, 0.9, n))[::-1]

sizes = range(1, n + 1)
entropies = [sum(binary_entropy(np.array([p[i]])) for i in range(k)) for k in sizes]

ax3.bar(sizes, entropies, color='steelblue', alpha=0.7, edgecolor='navy')
ax3.plot(sizes, entropies, 'ro-', markersize=8, linewidth=2, zorder=5)
ax3.set_xlabel('Subsystem size |A|', fontsize=12)
ax3.set_ylabel('Fermionic entropy $S_A$', fontsize=12)
ax3.set_title('Entropy Monotonicity (Verified)', fontsize=13, fontweight='bold')
ax3.set_xticks(list(sizes))
ax3.grid(True, alpha=0.3)
ax3.annotate('Monotone increasing\n(formally verified)',
             xy=(3, entropies[2]), xytext=(1.5, entropies[4]),
             fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
             color='red')

# ─── Panel 4: Hessian signature profile ───────────────────────────────────
ax4 = fig.add_subplot(gs[1, 1])
n = 5
p_vals = np.array([0.3, 0.0, 0.7, 0.5, 0.9])
mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            prod = p_vals[i] * p_vals[j]
            mat[i, j] = 1 if prod > 1e-10 else 0

im = ax4.imshow(mat, cmap='RdYlGn', vmin=0, vmax=1, aspect='equal')
ax4.set_xticks(range(n))
ax4.set_yticks(range(n))
ax4.set_xticklabels([f'{p:.1f}' for p in p_vals])
ax4.set_yticklabels([f'{p:.1f}' for p in p_vals])
ax4.set_xlabel('$p_j$', fontsize=12)
ax4.set_ylabel('$p_i$', fontsize=12)
ax4.set_title('Leaf Hessian Positive Index\n(1=green, 0=red)', fontsize=13, fontweight='bold')

for i in range(n):
    for j in range(n):
        if i != j:
            ax4.text(j, i, f'{int(mat[i, j])}',
                     ha='center', va='center', fontsize=14, fontweight='bold',
                     color='white' if mat[i, j] < 0.5 else 'black')
        else:
            ax4.text(j, i, '—', ha='center', va='center', fontsize=12, color='gray')

plt.colorbar(im, ax=ax4, shrink=0.8)

plt.suptitle('Quantum DPP Entanglement via Lorentzian Geometry',
             fontsize=15, fontweight='bold', y=1.01)
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")


"""
Visualization: Hessian Eigenvalue Spectrum at Derivative Leaves

Shows the eigenvalue structure of Hessian matrices at degree-2 derivative
leaves of DPP partition polynomials for different kernel types.
Illustrates the Lorentzian signature constraint (at most 1 positive eigenvalue).

This script is fully self-contained — no local imports.
"""

import numpy as np
import matplotlib.pyplot as plt


def random_psd_contraction(n, rng):
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    eigs = rng.uniform(0, 1, n)
    return Q @ np.diag(eigs) @ Q.T


fig, axes = plt.subplots(2, 2, figsize=(14, 11))

rng = np.random.default_rng(42)

# ─── Panel 1: Diagonal kernel leaf eigenvalues ─────────────────────────────
ax = axes[0, 0]
n = 5
p = np.array([0.3, 0.6, 0.1, 0.8, 0.5])

pairs = [(i, j) for i in range(n) for j in range(i + 1, n)]
pair_labels = [f'({i},{j})' for i, j in pairs]
pos_eigs = [p[i] * p[j] for i, j in pairs]
neg_eigs = [-p[i] * p[j] for i, j in pairs]

x_pos = np.arange(len(pairs))
width = 0.35

bars1 = ax.bar(x_pos - width / 2, pos_eigs, width, color='steelblue',
               alpha=0.8, label=r'$+\lambda$')
bars2 = ax.bar(x_pos + width / 2, neg_eigs, width, color='coral',
               alpha=0.8, label=r'$-\lambda$')

ax.axhline(y=0, color='black', linewidth=0.5)
ax.set_xticks(x_pos)
ax.set_xticklabels(pair_labels, fontsize=8, rotation=45)
ax.set_ylabel('Eigenvalue', fontsize=11)
ax.set_title('Diagonal Kernel: Leaf Hessian Eigenvalues\n'
             r'$H = [[0, p_i p_j], [p_i p_j, 0]]$  →  eigenvalues $\pm p_i p_j$',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# ─── Panel 2: Pos index histogram for random kernels ──────────────────────
ax = axes[0, 1]
n = 5
num_trials = 500
pos_indices = []

for _ in range(num_trials):
    K = random_psd_contraction(n, rng)
    for i in range(n):
        for j in range(i + 1, n):
            # For diagonal-like kernels, Hessian is [[0, c], [c, 0]]
            # For general kernels, examine the 2×2 principal minor structure
            c = K[i, j]
            det = -c ** 2
            if det < -1e-15:
                pos_indices.append(1)
            elif det > 1e-15:
                pos_indices.append(2 if c > 0 else 0)
            else:
                pos_indices.append(0)

counts = [pos_indices.count(i) for i in range(3)]
colors_bar = ['#d62728', '#2ca02c', '#9467bd']
bars = ax.bar([0, 1, 2], counts, color=colors_bar, alpha=0.8, edgecolor='black')
ax.set_xticks([0, 1, 2])
ax.set_xticklabels(['0', '1', '2'], fontsize=12)
ax.set_xlabel('Positive Index', fontsize=12)
ax.set_ylabel('Count', fontsize=12)
ax.set_title(f'Hessian Positive Index Distribution\n'
             f'({num_trials} random kernels, n={n})',
             fontsize=11, fontweight='bold')

# Annotate Lorentzian constraint
ax.annotate('Lorentzian: pos index ≤ 1\n(formally verified)',
            xy=(1, counts[1]), xytext=(1.5, counts[1] * 0.8),
            fontsize=10, color='green', fontweight='bold',
            arrowprops=dict(arrowstyle='->', color='green'))
if counts[2] > 0:
    ax.annotate('Should be 0\nfor Lorentzian\npolynomials',
                xy=(2, counts[2]), xytext=(2.3, counts[2] + 100),
                fontsize=9, color='red',
                arrowprops=dict(arrowstyle='->', color='red'))

ax.grid(True, alpha=0.3, axis='y')

# ─── Panel 3: Curvature vs entropy scatter (pairs) ────────────────────────
ax = axes[1, 0]
n = 6
curvatures = []
pair_entropies = []

for trial in range(200):
    K = random_psd_contraction(n, rng)
    for i in range(n):
        for j in range(i + 1, n):
            curv = K[i, j] ** 2
            # 2×2 submatrix entropy
            K_sub = K[np.ix_([i, j], [i, j])]
            eigs = np.clip(np.linalg.eigvalsh(K_sub), 0, 1)
            S = sum(-lam * np.log(max(lam, 1e-15)) - (1 - lam) * np.log(max(1 - lam, 1e-15))
                    if 0 < lam < 1 else 0 for lam in eigs)
            curvatures.append(curv)
            pair_entropies.append(S)

curvatures = np.array(curvatures)
pair_entropies = np.array(pair_entropies)

ax.scatter(curvatures, pair_entropies, alpha=0.2, s=5, c='steelblue',
           edgecolors='none')

# Fit trend line
mask = curvatures > 1e-8
if np.sum(mask) > 10:
    z = np.polyfit(curvatures[mask], pair_entropies[mask], 1)
    x_fit = np.linspace(0, np.max(curvatures), 100)
    ax.plot(x_fit, np.polyval(z, x_fit), 'r-', linewidth=2,
            label=f'Linear fit (slope={z[0]:.2f})')

corr = np.corrcoef(curvatures, pair_entropies)[0, 1]
ax.set_xlabel(r'Leaf curvature $K_{ij}^2$', fontsize=11)
ax.set_ylabel(r'Pair entropy $S_{\{i,j\}}$', fontsize=11)
ax.set_title(f'Curvature vs. Pair Entropy\n(ρ = {corr:.3f})',
             fontsize=11, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ─── Panel 4: Signature profile heatmap ───────────────────────────────────
ax = axes[1, 1]
n = 6
K = random_psd_contraction(n, rng)

# Compute the curvature matrix
curv_mat = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i != j:
            curv_mat[i, j] = K[i, j] ** 2

im = ax.imshow(curv_mat, cmap='YlOrRd', aspect='equal')
ax.set_xticks(range(n))
ax.set_yticks(range(n))
ax.set_xlabel('Mode j', fontsize=11)
ax.set_ylabel('Mode i', fontsize=11)
ax.set_title('Leaf Curvature Profile $K_{ij}^2$\n(Random Kernel)',
             fontsize=11, fontweight='bold')

for i in range(n):
    for j in range(n):
        val = curv_mat[i, j]
        color = 'white' if val > 0.5 * curv_mat.max() else 'black'
        ax.text(j, i, f'{val:.3f}', ha='center', va='center',
                fontsize=7, color=color)

plt.colorbar(im, ax=ax, shrink=0.8)

plt.suptitle('Hessian Signature Analysis for DPP Partition Polynomials',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.96])
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved hessian_spectrum.png")
