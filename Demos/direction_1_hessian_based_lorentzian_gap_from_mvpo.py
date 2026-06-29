"""
Applications of Hessian-Based Lorentzian Gap Analysis

This module demonstrates real-world applications of the principal minor matrix
and Lorentzian gap theory to:
1. DPP diversity scoring in machine learning
2. Quantum phase transition detection
3. Robustness analysis of correlation structures
"""

import numpy as np
from typing import List, Tuple


def principal_minor_matrix(K: np.ndarray) -> np.ndarray:
    """H_{ij} = K_{ii}·K_{jj} - K_{ij}²"""
    d = np.diag(K)
    return np.outer(d, d) - K * K


def spectral_gap(K: np.ndarray) -> float:
    """Min distance of eigenvalues from {0,1}"""
    eigs = np.linalg.eigvalsh(K)
    return float(np.min(np.minimum(np.clip(eigs, 0, 1), 1 - np.clip(eigs, 0, 1))))


def eigenvalue_gap(H: np.ndarray) -> Tuple[float, float, float]:
    """Returns (λ₁, λ₂, gap)"""
    eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
    return eigs[0], eigs[1] if len(eigs) > 1 else 0.0, eigs[0] - (eigs[1] if len(eigs) > 1 else 0.0)


# ============================================================
# Application 1: DPP Diversity Scoring
# ============================================================

def dpp_diversity_score(K: np.ndarray) -> dict:
    """Compute diversity metrics for a DPP kernel.

    Given a DPP marginal kernel K, computes:
    - Expected sample size: tr(K)
    - Expected diversity (pairwise): (tr K)² - ‖K‖_F²
    - Lorentzian gap: eigenvalue gap of principal minor matrix
    - Diversity efficiency: diversity per pair of expected elements

    Args:
        K: n×n DPP marginal kernel (symmetric PSD, eigenvalues in [0,1])

    Returns:
        Dictionary of diversity metrics
    """
    n = K.shape[0]
    H = principal_minor_matrix(K)
    trace = np.trace(K)
    frob_sq = np.sum(K * K)
    diversity = trace**2 - frob_sq
    lam1, lam2, gap = eigenvalue_gap(H)

    return {
        'n': n,
        'expected_size': float(trace),
        'expected_diversity': float(diversity),
        'lorentzian_gap': float(gap),
        'is_lorentzian': int(np.sum(np.linalg.eigvalsh(H) > 1e-10)) <= 1,
        'diversity_efficiency': float(diversity / max(trace * (trace - 1), 1e-15)),
        'dpp_entropy': float(-np.sum(
            np.clip(np.diag(K), 1e-15, 1-1e-15) * np.log(np.clip(np.diag(K), 1e-15, 1-1e-15)) +
            (1 - np.clip(np.diag(K), 1e-15, 1-1e-15)) * np.log(1 - np.clip(np.diag(K), 1e-15, 1-1e-15))
        ))
    }


def compare_kernels(kernels: List[Tuple[str, np.ndarray]]):
    """Compare diversity properties of multiple DPP kernels."""
    print(f"{'Name':<20} {'E[|S|]':>8} {'Diversity':>10} {'L-Gap':>8} {'Lorentz':>8} {'Entropy':>8}")
    print("-" * 72)
    for name, K in kernels:
        metrics = dpp_diversity_score(K)
        print(f"{name:<20} {metrics['expected_size']:>8.3f} "
              f"{metrics['expected_diversity']:>10.4f} "
              f"{metrics['lorentzian_gap']:>8.4f} "
              f"{'Yes' if metrics['is_lorentzian'] else 'No':>8} "
              f"{metrics['dpp_entropy']:>8.4f}")


# ============================================================
# Application 2: Quantum Phase Transition Detection
# ============================================================

def tfim_correlation_matrix(n: int, J: float, h: float) -> np.ndarray:
    """Correlation matrix for transverse-field Ising model."""
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


def detect_phase_transition(n: int, J: float = 1.0,
                             h_range: Tuple[float, float] = (0.1, 3.0),
                             num_points: int = 100) -> dict:
    """Detect quantum phase transitions via Lorentzian gap analysis.

    Scans the transverse field h and computes the Lorentzian gap at each point.
    Phase transitions are indicated by minima in the gap.

    Args:
        n: number of qubits
        J: coupling strength
        h_range: range of transverse field values
        num_points: number of points to sample

    Returns:
        Dictionary with h values, gaps, and detected transition points
    """
    h_values = np.linspace(h_range[0], h_range[1], num_points)
    gaps = []
    deltas = []
    diversities = []

    for h in h_values:
        K = tfim_correlation_matrix(n, J, h)
        H = principal_minor_matrix(K)
        _, _, gap = eigenvalue_gap(H)
        gaps.append(gap)
        deltas.append(spectral_gap(K))
        diversities.append(np.trace(K)**2 - np.sum(K*K))

    gaps = np.array(gaps)
    deltas = np.array(deltas)

    # Find approximate transition point (minimum gap)
    min_idx = np.argmin(deltas)
    transition_h = h_values[min_idx]

    return {
        'h_values': h_values,
        'lorentzian_gaps': gaps,
        'spectral_gaps': deltas,
        'diversities': np.array(diversities),
        'transition_h': float(transition_h),
        'critical_ratio': float(J)  # theoretical: h_c = J
    }


# ============================================================
# Application 3: Robustness Analysis
# ============================================================

def robustness_analysis(K: np.ndarray, noise_levels: np.ndarray) -> dict:
    """Analyze robustness of Lorentzian structure under noise.

    Adds symmetric Gaussian noise of various levels and tracks
    how the Lorentzian gap degrades.

    Args:
        K: n×n DPP kernel
        noise_levels: array of noise standard deviations

    Returns:
        Dictionary with noise levels and corresponding gap values
    """
    n = K.shape[0]
    H_clean = principal_minor_matrix(K)
    _, _, gap_clean = eigenvalue_gap(H_clean)

    results = {
        'noise_levels': noise_levels,
        'mean_gaps': [],
        'std_gaps': [],
        'clean_gap': float(gap_clean),
        'lorentzian_fraction': []
    }

    for sigma in noise_levels:
        trial_gaps = []
        lor_count = 0
        for _ in range(50):
            E = sigma * np.random.randn(n, n)
            E = (E + E.T) / 2
            K_noisy = K + E
            # Clip to valid range
            eigvals, eigvecs = np.linalg.eigh(K_noisy)
            eigvals = np.clip(eigvals, 0, 1)
            K_noisy = eigvecs @ np.diag(eigvals) @ eigvecs.T

            H_noisy = principal_minor_matrix(K_noisy)
            _, _, gap = eigenvalue_gap(H_noisy)
            trial_gaps.append(gap)
            if int(np.sum(np.linalg.eigvalsh(H_noisy) > 1e-10)) <= 1:
                lor_count += 1

        results['mean_gaps'].append(float(np.mean(trial_gaps)))
        results['std_gaps'].append(float(np.std(trial_gaps)))
        results['lorentzian_fraction'].append(lor_count / 50)

    return results


if __name__ == "__main__":
    print("=" * 70)
    print("  Applications of Hessian-Based Lorentzian Gap Analysis")
    print("=" * 70)

    # App 1: DPP Diversity
    print("\n=== Application 1: DPP Diversity Comparison ===\n")

    np.random.seed(42)
    n = 6

    # Identity-scaled kernel (uniform DPP)
    K_uniform = 0.5 * np.eye(n)

    # Clustered kernel
    K_cluster = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K_cluster[i, j] = 0.5 * np.exp(-0.5 * (i - j)**2)
    eigvals, eigvecs = np.linalg.eigh(K_cluster)
    eigvals = np.clip(eigvals, 0, 1)
    K_cluster = eigvecs @ np.diag(eigvals) @ eigvecs.T

    # Projection kernel
    Q, _ = np.linalg.qr(np.random.randn(n, 3))
    K_proj = Q @ Q.T

    # TFIM kernel
    K_tfim = tfim_correlation_matrix(n, J=1.0, h=0.5)

    compare_kernels([
        ("Uniform (0.5·I)", K_uniform),
        ("Clustered (Gaussian)", K_cluster),
        ("Projection (rank-3)", K_proj),
        ("TFIM (J=1, h=0.5)", K_tfim),
    ])

    # App 2: Phase transition
    print("\n=== Application 2: Phase Transition Detection ===\n")
    for n in [4, 6, 8]:
        result = detect_phase_transition(n)
        print(f"  n={n}: Detected transition at h={result['transition_h']:.3f} "
              f"(theoretical h_c = {result['critical_ratio']:.1f})")

    # App 3: Robustness
    print("\n=== Application 3: Robustness Analysis ===\n")
    K = tfim_correlation_matrix(5, J=1.0, h=0.3)
    noise_levels = np.array([0.0, 0.01, 0.02, 0.05, 0.1, 0.2])
    rob = robustness_analysis(K, noise_levels)

    print(f"  Clean gap: {rob['clean_gap']:.6f}")
    print(f"  {'Noise σ':>10} {'Mean Gap':>10} {'Std Gap':>10} {'Lorentzian %':>12}")
    for i, sigma in enumerate(noise_levels):
        print(f"  {sigma:>10.3f} {rob['mean_gaps'][i]:>10.6f} "
              f"{rob['std_gaps'][i]:>10.6f} {rob['lorentzian_fraction'][i]*100:>11.1f}%")

    print("\n" + "=" * 70)


"""
Interactive Demonstration: Hessian-Based Lorentzian Gap for DPPs

This script demonstrates:
1. Construction of TFIM correlation matrices for n = 3, 4, 5 qubits
2. Computation of the principal minor matrix H and its eigenvalues
3. Visualization of the Lorentzian gap as a function of Δ
4. Comparison with the Ω(Δ²/n) bound
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor_matrix(K):
    """H_{ij} = K_{ii}·K_{jj} - K_{ij}²"""
    d = np.diag(K)
    return np.outer(d, d) - K * K


def eigenvalue_gap(H):
    """Returns (λ₁, λ₂, gap)"""
    eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
    return eigs[0], eigs[1] if len(eigs) > 1 else 0.0, eigs[0] - (eigs[1] if len(eigs) > 1 else 0.0)


def spectral_gap(K):
    """Min distance of eigenvalues from {0,1}"""
    eigs = np.linalg.eigvalsh(K)
    return float(np.min(np.minimum(eigs, 1 - eigs)))


def tfim_correlation_matrix(n, J, h):
    """Correlation matrix for transverse-field Ising model."""
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


def check_lorentzian(H, tol=1e-10):
    """Check at most one positive eigenvalue."""
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1


def main():
    print("=" * 70)
    print("  Hessian-Based Lorentzian Gap for Determinantal Point Processes")
    print("=" * 70)

    # === Part 1: Basic demonstration ===
    print("\n--- Part 1: Principal Minor Matrix Structure ---\n")

    for n in [3, 4, 5]:
        print(f"n = {n} qubits, TFIM with J=1.0, h=0.5:")
        K = tfim_correlation_matrix(n, J=1.0, h=0.5)
        H = principal_minor_matrix(K)
        lam1, lam2, gap = eigenvalue_gap(H)
        delta = spectral_gap(K)
        is_lor = check_lorentzian(H)

        print(f"  tr(K) = {np.trace(K):.4f}")
        print(f"  Spectral gap Δ = {delta:.4f}")
        print(f"  H diagonal (should be 0): {np.diag(H).round(10)}")
        print(f"  Eigenvalues of H: {np.sort(np.linalg.eigvalsh(H))[::-1].round(6)}")
        print(f"  λ₁ = {lam1:.6f}, λ₂ = {lam2:.6f}, gap = {gap:.6f}")
        print(f"  Lorentzian signature: {is_lor}")
        print(f"  Gap parameter (tr²-‖K‖²_F) = {np.trace(K)**2 - np.sum(K*K):.6f}")
        print()

    # === Part 2: Lorentzian gap vs Δ ===
    print("--- Part 2: Lorentzian Gap vs Spectral Gap ---\n")

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    for idx, n in enumerate([3, 4, 5]):
        deltas = []
        gaps = []
        ratios = []

        h_values = np.linspace(0.1, 3.0, 50)
        for h in h_values:
            K = tfim_correlation_matrix(n, J=1.0, h=h)
            delta = spectral_gap(K)
            if delta < 1e-6:
                continue
            H = principal_minor_matrix(K)
            _, _, gap = eigenvalue_gap(H)

            deltas.append(delta)
            gaps.append(gap)
            if delta > 1e-8:
                ratios.append(gap * n**2 / delta**2)

        ax = axes[idx]
        deltas = np.array(deltas)
        gaps = np.array(gaps)

        ax.scatter(deltas**2, gaps, alpha=0.6, s=20, label='Data')
        if len(deltas) > 0:
            # Fit linear bound
            slope = np.min(gaps / (deltas**2 + 1e-15))
            x_fit = np.linspace(0, np.max(deltas**2), 100)
            ax.plot(x_fit, slope * x_fit, 'r--', label=f'Bound: {slope:.2f}·Δ²')

        ax.set_xlabel('Δ²')
        ax.set_ylabel('Eigenvalue gap (λ₁ - λ₂)')
        ax.set_title(f'n = {n} qubits')
        ax.legend()
        ax.grid(True, alpha=0.3)

        if ratios:
            print(f"  n={n}: min ratio (gap·n²/Δ²) = {min(ratios):.4f}")

    plt.suptitle('Lorentzian Gap vs Spectral Gap² for TFIM', fontsize=14)
    plt.tight_layout()
    plt.savefig('lorentzian_gap_vs_delta.png', dpi=150, bbox_inches='tight')
    print("\n  Saved: lorentzian_gap_vs_delta.png")

    # === Part 3: Conjecture test ===
    print("\n--- Part 3: Testing Tight Gap Conjecture ---\n")
    print("  Conjecture: gap · n² / Δ² ≥ 4")
    print()

    conjecture_holds = True
    for n in [3, 4, 5, 6]:
        min_ratio = float('inf')
        for J in [0.5, 1.0, 1.5, 2.0]:
            for h in np.linspace(0.1, 3.0, 30):
                K = tfim_correlation_matrix(n, J=J, h=h)
                delta = spectral_gap(K)
                if delta < 0.01:
                    continue
                H = principal_minor_matrix(K)
                _, _, gap = eigenvalue_gap(H)
                ratio = gap * n**2 / delta**2
                min_ratio = min(min_ratio, ratio)
                if ratio < 4:
                    conjecture_holds = False

        print(f"  n={n}: min ratio = {min_ratio:.4f} {'✓' if min_ratio >= 4 else '✗ COUNTEREXAMPLE'}")

    print(f"\n  Conjecture {'HOLDS' if conjecture_holds else 'FALSIFIED'} for tested parameters")

    # === Part 4: Projection case ===
    print("\n--- Part 4: Projection Case (Zero Temperature) ---\n")

    for n in [4, 6, 8]:
        for k in [1, 2, 3]:
            if k >= n:
                continue
            np.random.seed(42 + n + k)
            Q, _ = np.linalg.qr(np.random.randn(n, k))
            K = Q @ Q.T
            H = principal_minor_matrix(K)
            gap_param = np.trace(K)**2 - np.sum(K*K)
            expected = k**2 - k

            print(f"  n={n}, rank={k}: gap_param = {gap_param:.4f} (expected k²-k = {expected})")

    print("\n" + "=" * 70)
    print("  Demo complete!")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

package = {
    "title": "Hessian-Based Lorentzian Gap from DPP Infrastructure",
    "domain": "Pythagorean / Spectral Theory / Determinantal Point Processes",
    "article": read_file("ARTICLE.md"),
    "research_paper": read_file("RESEARCH_PAPER.md"),
    "future_directions": read_file("FUTURE_DIRECTIONS.md"),
    "demos": [
        {
            "name": "DPP Lorentzian Gap Demo",
            "code": read_file("demo.py")
        }
    ],
    "algorithms": [
        {
            "name": "Principal Minor Matrix Computation",
            "pseudocode": "1. d ← diag(K)  // O(n)\n2. H ← d·dᵀ − K⊙K  // O(n²)\n3. return H",
            "code": read_file("algorithms.py")
        }
    ],
    "visualizations": [
        {
            "name": "Hessian Structure Decomposition",
            "code": read_file("viz_hessian_structure.py"),
            "description": "Shows the decomposition H = d·dᵀ − K⊙K as heatmaps, eigenvalue spectrum, and the Lorentzian gap vs spectral gap relationship for TFIM."
        },
        {
            "name": "Phase Diagram",
            "code": read_file("viz_phase_diagram.py"),
            "description": "Phase diagram of the TFIM showing Lorentzian gap, spectral gap, and DPP diversity across the (J, h) parameter space."
        },
        {
            "name": "Eigenvalue Flow",
            "code": read_file("viz_eigenvalue_flow.py"),
            "description": "Eigenvalue flow of H as a function of transverse field h, showing persistence of Lorentzian signature away from the critical point."
        }
    ],
    "interactive_demos": [
        {
            "name": "2×2 Principal Minor Explorer",
            "html": read_file("interactive_hessian.html"),
            "description": "Interactive exploration of the 2×2 case: adjust K entries and see H₀₁ = ab − c² in real time with PSD region visualization."
        },
        {
            "name": "Eigenvalue Flow Controller",
            "html": read_file("interactive_eigenflow.html"),
            "description": "Drag a slider to control the spectral purity of K and watch the eigenvalues of H respond, showing emergence of Lorentzian signature."
        }
    ],
    "lean_proofs": read_file("Pythagorean/HessianLorentzianGap.lean")
}

with open("PACKAGE.json", "w") as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"Size: {os.path.getsize('PACKAGE.json') / 1024:.1f} KB")


"""
Visualization: Eigenvalue Flow of the Principal Minor Matrix

Shows how the eigenvalues of H = d·dᵀ - K⊙K evolve as the transverse field
h varies, revealing the emergence and persistence of Lorentzian signature.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tfim_correlation_matrix(n, J, h):
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

for plot_idx, n in enumerate([4, 5, 6]):
    h_vals = np.linspace(0.05, 3.0, 100)
    all_eigs = np.zeros((len(h_vals), n))

    for i, h in enumerate(h_vals):
        K = tfim_correlation_matrix(n, J=1.0, h=h)
        d = np.diag(K)
        H = np.outer(d, d) - K * K
        eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
        all_eigs[i] = eigs

    ax = axes[plot_idx]

    # Plot each eigenvalue branch
    colors = plt.cm.RdYlBu(np.linspace(0, 1, n))
    for j in range(n):
        label = f'λ_{j+1}' if j < 3 else None
        lw = 2.5 if j == 0 else 1.5
        ax.plot(h_vals, all_eigs[:, j], color=colors[j], linewidth=lw, label=label)

    ax.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax.axvline(x=1.0, color='gray', linewidth=1.5, linestyle='--', alpha=0.7, label='h = J')

    # Shade the gap region
    ax.fill_between(h_vals, all_eigs[:, 0], all_eigs[:, 1],
                     alpha=0.15, color='red', label='Lorentzian gap')

    ax.set_xlabel('Transverse field h', fontsize=12)
    ax.set_ylabel('Eigenvalues of H', fontsize=12)
    ax.set_title(f'n = {n} qubits (J = 1)', fontsize=13)
    ax.legend(fontsize=9, loc='best')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(h_vals[0], h_vals[-1])

plt.suptitle('Eigenvalue Flow of the Principal Minor Matrix\n'
             'H = d·dᵀ - K⊙K   (one positive eigenvalue = Lorentzian signature)',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('eigenvalue_flow.png', dpi=150, bbox_inches='tight')
print("Saved: eigenvalue_flow.png")


"""
Visualization: Principal Minor Matrix Structure

This script visualizes the decomposition H = d·dᵀ - K⊙K for a DPP kernel,
showing how the rank-1 outer product and Hadamard square combine to produce
the Lorentzian Hessian structure.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def principal_minor_matrix(K):
    d = np.diag(K)
    return np.outer(d, d) - K * K


def tfim_correlation_matrix(n, J, h):
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


# Create figure with 3 panels
fig, axes = plt.subplots(2, 3, figsize=(15, 10))

n = 6
K = tfim_correlation_matrix(n, J=1.0, h=0.5)
d = np.diag(K)
ddT = np.outer(d, d)
KoK = K * K
H = ddT - KoK

# Top row: Matrix decomposition
vmax = max(np.max(np.abs(ddT)), np.max(np.abs(KoK)), np.max(np.abs(H)))

im0 = axes[0, 0].imshow(ddT, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 0].set_title('d·dᵀ (Rank-1 Outer Product)', fontsize=12)
axes[0, 0].set_xlabel('j')
axes[0, 0].set_ylabel('i')
plt.colorbar(im0, ax=axes[0, 0], shrink=0.8)

im1 = axes[0, 1].imshow(KoK, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 1].set_title('K ⊙ K (Hadamard Square)', fontsize=12)
axes[0, 1].set_xlabel('j')
plt.colorbar(im1, ax=axes[0, 1], shrink=0.8)

im2 = axes[0, 2].imshow(H, cmap='RdBu_r', vmin=-vmax, vmax=vmax)
axes[0, 2].set_title('H = d·dᵀ - K⊙K\n(Principal Minor Matrix)', fontsize=12)
axes[0, 2].set_xlabel('j')
plt.colorbar(im2, ax=axes[0, 2], shrink=0.8)

# Bottom left: Eigenvalue spectrum of H
eigs_H = np.sort(np.linalg.eigvalsh(H))[::-1]
colors = ['#e74c3c' if e > 1e-10 else '#3498db' if e < -1e-10 else '#95a5a6' for e in eigs_H]
axes[1, 0].bar(range(n), eigs_H, color=colors, edgecolor='black', linewidth=0.5)
axes[1, 0].axhline(y=0, color='black', linewidth=0.5)
axes[1, 0].set_xlabel('Eigenvalue index')
axes[1, 0].set_ylabel('Eigenvalue')
axes[1, 0].set_title('Eigenvalue Spectrum of H\n(Red=positive, Blue=negative)', fontsize=12)
axes[1, 0].grid(True, alpha=0.3)

# Bottom middle: Comparison across field values
h_vals = np.linspace(0.1, 3.0, 40)
gaps = []
deltas = []
for h in h_vals:
    K_h = tfim_correlation_matrix(n, J=1.0, h=h)
    H_h = principal_minor_matrix(K_h)
    eigs = np.sort(np.linalg.eigvalsh(H_h))[::-1]
    gaps.append(eigs[0] - eigs[1])
    eigs_K = np.linalg.eigvalsh(K_h)
    deltas.append(np.min(np.minimum(eigs_K, 1 - eigs_K)))

axes[1, 1].plot(h_vals, gaps, 'b-', linewidth=2, label='Lorentzian gap')
axes[1, 1].axvline(x=1.0, color='red', linestyle='--', alpha=0.5, label='h = J (critical)')
axes[1, 1].set_xlabel('Transverse field h')
axes[1, 1].set_ylabel('Eigenvalue gap λ₁ - λ₂')
axes[1, 1].set_title('Lorentzian Gap vs Field Strength\n(TFIM, n=6, J=1)', fontsize=12)
axes[1, 1].legend()
axes[1, 1].grid(True, alpha=0.3)

# Bottom right: Gap vs Δ² scatter
axes[1, 2].scatter(np.array(deltas)**2, gaps, c=h_vals, cmap='viridis', s=40, edgecolors='black', linewidth=0.5)
if len(deltas) > 0:
    d2 = np.array(deltas)**2
    g = np.array(gaps)
    mask = d2 > 1e-6
    if np.any(mask):
        slope = np.min(g[mask] / d2[mask])
        x_fit = np.linspace(0, np.max(d2), 100)
        axes[1, 2].plot(x_fit, slope * x_fit, 'r--', linewidth=2, label=f'Bound: {slope:.2f}·Δ²')
cbar = plt.colorbar(axes[1, 2].collections[0], ax=axes[1, 2], shrink=0.8)
cbar.set_label('h value')
axes[1, 2].set_xlabel('Δ²')
axes[1, 2].set_ylabel('Eigenvalue gap')
axes[1, 2].set_title('Gap ∝ Δ² (Quadratic Bound)', fontsize=12)
axes[1, 2].legend()
axes[1, 2].grid(True, alpha=0.3)

plt.suptitle('Hessian Decomposition of DPP Generating Polynomial\n'
             'H = d·dᵀ - K⊙K  reveals Lorentzian signature',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('hessian_structure.png', dpi=150, bbox_inches='tight')
print("Saved: hessian_structure.png")


"""
Visualization: Lorentzian Gap Phase Diagram

This script creates a phase diagram showing how the Lorentzian gap varies
across the (J, h) parameter space of the transverse-field Ising model,
revealing the quantum phase transition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def tfim_correlation_matrix(n, J, h):
    K = np.zeros((n, n))
    for k in range(n):
        theta = 2 * np.pi * k / n
        eps_k = 2 * np.sqrt(max(J**2 + h**2 - 2*J*h*np.cos(theta), 0))
        if eps_k < 1e-14:
            n_k = 0.5
        else:
            cos_angle = (h - J * np.cos(theta)) / (eps_k / 2)
            cos_angle = np.clip(cos_angle, -1, 1)
            n_k = (1 - cos_angle) / 2
        for i in range(n):
            for j in range(n):
                K[i, j] += n_k * np.cos(theta * (i - j)) / n
    K = (K + K.T) / 2
    eigvals, eigvecs = np.linalg.eigh(K)
    eigvals = np.clip(eigvals, 0, 1)
    return eigvecs @ np.diag(eigvals) @ eigvecs.T


def eigenvalue_gap(H):
    eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
    return eigs[0] - (eigs[1] if len(eigs) > 1 else 0.0)


n = 5
J_vals = np.linspace(0.1, 2.5, 40)
h_vals = np.linspace(0.1, 2.5, 40)

gap_map = np.zeros((len(h_vals), len(J_vals)))
delta_map = np.zeros((len(h_vals), len(J_vals)))
diversity_map = np.zeros((len(h_vals), len(J_vals)))

for i, h in enumerate(h_vals):
    for j, J in enumerate(J_vals):
        K = tfim_correlation_matrix(n, J, h)
        d = np.diag(K)
        H = np.outer(d, d) - K * K
        gap_map[i, j] = eigenvalue_gap(H)

        eigs_K = np.linalg.eigvalsh(K)
        delta_map[i, j] = np.min(np.minimum(eigs_K, 1 - eigs_K))
        diversity_map[i, j] = np.trace(K)**2 - np.sum(K*K)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# Panel 1: Lorentzian gap
im0 = axes[0].imshow(gap_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='inferno')
axes[0].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[0].set_xlabel('Coupling J', fontsize=12)
axes[0].set_ylabel('Field h', fontsize=12)
axes[0].set_title('Lorentzian Gap (λ₁ - λ₂)', fontsize=13)
axes[0].legend(fontsize=10, loc='upper left')
plt.colorbar(im0, ax=axes[0], shrink=0.9)

# Panel 2: Spectral gap
im1 = axes[1].imshow(delta_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='viridis')
axes[1].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[1].set_xlabel('Coupling J', fontsize=12)
axes[1].set_ylabel('Field h', fontsize=12)
axes[1].set_title('Spectral Gap Δ', fontsize=13)
axes[1].legend(fontsize=10, loc='upper left')
plt.colorbar(im1, ax=axes[1], shrink=0.9)

# Panel 3: DPP diversity
im2 = axes[2].imshow(diversity_map, origin='lower', aspect='auto',
                       extent=[J_vals[0], J_vals[-1], h_vals[0], h_vals[-1]],
                       cmap='plasma')
axes[2].plot([0.1, 2.5], [0.1, 2.5], 'w--', linewidth=2, label='h = J (critical line)')
axes[2].set_xlabel('Coupling J', fontsize=12)
axes[2].set_ylabel('Field h', fontsize=12)
axes[2].set_title('DPP Diversity (tr²K - ‖K‖²_F)', fontsize=13)
axes[2].legend(fontsize=10, loc='upper left')
plt.colorbar(im2, ax=axes[2], shrink=0.9)

plt.suptitle(f'Phase Diagram: TFIM on {n} qubits\n'
             'Lorentzian gap vanishes at the quantum critical point h = J',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
print("Saved: phase_diagram.png")
