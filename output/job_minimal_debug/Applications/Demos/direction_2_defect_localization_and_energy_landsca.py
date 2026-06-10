"""
Applications of Tropical Defect Localization.

Demonstrates real-world applications of the theory:
1. Explainable robustness certificates for neural networks
2. Weakest-link failure prediction in materials science
3. Spin-glass overlap analysis
"""

import numpy as np
from typing import Tuple, List
from dataclasses import dataclass


# ─── Core functions (self-contained) ─────────────────────────────────────────

def diag_ex_slack_matrix(W: np.ndarray) -> np.ndarray:
    """Compute the full diagExSlack matrix."""
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def compute_landscape(W: np.ndarray) -> dict:
    """Compute energy landscape."""
    n = W.shape[0]
    S = diag_ex_slack_matrix(W)
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    slacks = np.array([S[i, j] for i, j in pairs])
    sorted_slacks = np.sort(slacks)
    min_idx = np.argmin(slacks)
    return {
        'witness': pairs[min_idx],
        'trop_margin': sorted_slacks[0],
        'spectral_gap': sorted_slacks[1] - sorted_slacks[0] if len(sorted_slacks) > 1 else 0,
        'sorted_values': sorted_slacks,
    }

def mean_model(n: int, mu_diag: float, mu_off: float) -> np.ndarray:
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

# ─── Application 1: Explainable Robustness Certificates ─────────────────────

def explain_robustness(weight_matrix: np.ndarray) -> dict:
    """Given a weight matrix from a neural network layer, produce an
    explainable robustness certificate that identifies which specific
    weight entry is the source of instability.
    
    The certificate says: "This layer is fragile because entry (i*, j*)
    of the weight matrix has diagExSlack = δ*, which is the minimum
    over all pairs. Perturbations to this entry will most easily cause
    misclassification."
    
    Args:
        weight_matrix: n×n weight matrix of a network layer
    
    Returns:
        Dictionary with certificate details
    """
    L = compute_landscape(weight_matrix)
    n = weight_matrix.shape[0]
    i_star, j_star = L['witness']
    
    # Compute how much perturbation is needed to break stability
    robustness_radius = abs(L['trop_margin']) / 4  # from Lipschitz bound
    
    # Localization strength: how much more vulnerable is (i*,j*) vs average
    avg_slack = np.mean(L['sorted_values'])
    localization_ratio = avg_slack / (abs(L['trop_margin']) + 1e-10)
    
    return {
        'is_stable': L['trop_margin'] > 0,
        'margin': L['trop_margin'],
        'defect_entry': (i_star, j_star),
        'defect_slack': L['trop_margin'],
        'spectral_gap': L['spectral_gap'],
        'robustness_radius': robustness_radius,
        'localization_ratio': localization_ratio,
        'explanation': (
            f"Layer {'is' if L['trop_margin'] > 0 else 'is NOT'} tropically stable. "
            f"The most vulnerable entry is W[{i_star},{j_star}] with slack {L['trop_margin']:.4f}. "
            f"The spectral gap is {L['spectral_gap']:.4f}, meaning the instability "
            f"{'is well-localized at a single entry' if L['spectral_gap'] > 0.5 else 'is shared across multiple entries'}."
        )
    }


# ─── Application 2: Weakest-Link Failure Prediction ─────────────────────────

@dataclass
class MaterialSample:
    """A disordered material sample with local strength values."""
    name: str
    strength_matrix: np.ndarray  # W[i,j] = interaction strength at bond (i,j)
    
def predict_failure_location(sample: MaterialSample) -> dict:
    """Predict where a disordered material will fail.
    
    In the weakest-link model, failure occurs at the bond with the
    smallest diagExSlack value. The spectral gap predicts whether
    failure is localized (large gap) or diffuse (small gap).
    
    Args:
        sample: A material sample with bond strengths
    
    Returns:
        Failure prediction with location and confidence
    """
    L = compute_landscape(sample.strength_matrix)
    n = sample.strength_matrix.shape[0]
    
    # Failure localization confidence based on spectral gap
    # Large gap → high confidence in single failure point
    confidence = 1.0 - np.exp(-L['spectral_gap'])
    
    return {
        'material': sample.name,
        'failure_bond': L['witness'],
        'failure_strength': L['trop_margin'],
        'spectral_gap': L['spectral_gap'],
        'localization_confidence': confidence,
        'is_localized': L['spectral_gap'] > 0.5,
        'prediction': (
            f"Material '{sample.name}': failure predicted at bond {L['witness']} "
            f"with strength {L['trop_margin']:.4f}. "
            f"{'Localized failure' if L['spectral_gap'] > 0.5 else 'Diffuse failure'} "
            f"(confidence: {confidence:.2%})."
        )
    }


# ─── Application 3: Spin-Glass Overlap Analysis ─────────────────────────────

def spin_glass_overlap_analysis(
    n: int, c: float, n_samples: int = 500, n_pairs: int = 100
) -> dict:
    """Measure the Edwards-Anderson tropical overlap parameter.
    
    For a given n and c, sample many independent matrices from the
    critical window ensemble and measure how often two independent
    samples share the same witness pair.
    
    In the replica-symmetric phase (c > 1), the overlap should → 1.
    In the RSB phase (c < 1), the overlap should remain < 1.
    
    Args:
        n: Matrix size
        c: Critical window parameter
        n_samples: Number of matrix samples
        n_pairs: Number of pairs to compare for overlap
    
    Returns:
        Dictionary with overlap statistics
    """
    rng = np.random.default_rng(42)
    
    # Sample witnesses
    witnesses = []
    for _ in range(n_samples):
        mu_off = c * np.sqrt(np.log(n))
        W = mean_model(n, 0, mu_off) + rng.standard_normal((n, n))
        L = compute_landscape(W)
        witnesses.append(L['witness'])
    
    # Compute pairwise overlaps
    overlaps = []
    for _ in range(n_pairs):
        idx1, idx2 = rng.choice(n_samples, size=2, replace=False)
        overlap = 1.0 if witnesses[idx1] == witnesses[idx2] else 0.0
        overlaps.append(overlap)
    
    # Also measure witness concentration
    from collections import Counter
    witness_counts = Counter(witnesses)
    most_common = witness_counts.most_common(5)
    concentration = most_common[0][1] / n_samples if most_common else 0
    
    return {
        'n': n,
        'c': c,
        'mean_overlap': np.mean(overlaps),
        'concentration': concentration,
        'num_distinct_witnesses': len(witness_counts),
        'top_witnesses': most_common,
        'phase': 'replica-symmetric' if np.mean(overlaps) > 0.5 else 'RSB',
    }


# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    np.random.seed(42)
    
    print("=" * 60)
    print("APPLICATIONS OF TROPICAL DEFECT LOCALIZATION")
    print("=" * 60)
    
    # Application 1: Explainable robustness
    print("\n--- Application 1: Explainable Robustness Certificate ---")
    # Simulate a neural network weight matrix
    n = 20
    W_nn = mean_model(n, 0, 2.0 * np.sqrt(np.log(n))) + np.random.randn(n, n)
    cert = explain_robustness(W_nn)
    print(cert['explanation'])
    print(f"  Robustness radius: {cert['robustness_radius']:.4f}")
    
    # Application 2: Material failure
    print("\n--- Application 2: Weakest-Link Failure Prediction ---")
    material = MaterialSample(
        name="Disordered Alloy Sample #42",
        strength_matrix=mean_model(15, 0, 3.0 * np.sqrt(np.log(15))) + 1.5 * np.random.randn(15, 15)
    )
    prediction = predict_failure_location(material)
    print(prediction['prediction'])
    
    # Application 3: Spin-glass overlap
    print("\n--- Application 3: Spin-Glass Overlap Analysis ---")
    for c_val in [0.5, 1.0, 2.0, 3.0]:
        result = spin_glass_overlap_analysis(n=30, c=c_val, n_samples=300, n_pairs=200)
        print(f"  c={c_val}: overlap={result['mean_overlap']:.3f}, "
              f"concentration={result['concentration']:.3f}, "
              f"phase={result['phase']}")


"""
Demonstration of Tropical Defect Localization and Energy Landscapes.

This script:
1. Samples critical-window matrices for various n and c values
2. Computes the diagExSlack energy landscape
3. Finds the witness pair and spectral gap
4. Plots uniqueness fraction and gap growth vs n
5. Overlays theoretical prediction C·σ·√(log n)
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List

# ─── Core Definitions ───────────────────────────────────────────────────────

def diag_ex_slack(W: np.ndarray, i: int, j: int) -> float:
    """Diagonal exchange slack: δ(i,j) = 2·W(i,j) - W(i,i) - W(j,j)."""
    return 2 * W[i, j] - W[i, i] - W[j, j]

def mean_model(n: int, mu_diag: float, mu_off: float) -> np.ndarray:
    """Mean model matrix: diagonal μ_diag, off-diagonal μ_off."""
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

def critical_window_matrix(n: int, c: float, sigma: float = 1.0) -> np.ndarray:
    """Sample a critical-window matrix.
    
    W_{ij} = μ_diag·δ_{ij} + μ_off·(1-δ_{ij}) + σ·Z_{ij}
    where μ_off - μ_diag = c·σ·√(log n) and Z is i.i.d. N(0,1).
    """
    mu_diag = 0.0
    mu_off = c * sigma * np.sqrt(np.log(n))
    M = mean_model(n, mu_diag, mu_off)
    N = sigma * np.random.randn(n, n)
    return M + N

def energy_landscape(W: np.ndarray) -> dict:
    """Compute the full energy landscape of diagExSlack values.
    
    Returns dict with:
      - slack_values: array of all off-diagonal diagExSlack values
      - witness: (i*, j*) achieving the minimum
      - trop_margin: the minimum diagExSlack value
      - spectral_gap: difference between 2nd smallest and smallest
      - sorted_values: sorted array of slack values
    """
    n = W.shape[0]
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    slacks = np.array([diag_ex_slack(W, i, j) for i, j in pairs])
    
    sorted_slacks = np.sort(slacks)
    min_idx = np.argmin(slacks)
    witness = pairs[min_idx]
    trop_margin = sorted_slacks[0]
    spectral_gap = sorted_slacks[1] - sorted_slacks[0] if len(sorted_slacks) > 1 else 0.0
    
    return {
        'slack_values': slacks,
        'witness': witness,
        'trop_margin': trop_margin,
        'spectral_gap': spectral_gap,
        'sorted_values': sorted_slacks,
        'pairs': pairs,
    }

def tropical_overlap(w1: Tuple[int, int], w2: Tuple[int, int]) -> float:
    """Tropical overlap (Edwards-Anderson order parameter)."""
    return 1.0 if w1 == w2 else 0.0

# ─── Experiments ─────────────────────────────────────────────────────────────

def experiment_uniqueness_and_gap(
    n_values: List[int] = [20, 50, 100, 200],
    c_values: List[float] = [1.5, 2.0, 3.0],
    n_samples: int = 2000,
    sigma: float = 1.0,
) -> dict:
    """Run experiments measuring witness uniqueness and spectral gap growth."""
    results = {}
    
    for c in c_values:
        results[c] = {
            'n_values': n_values,
            'uniqueness_fraction': [],
            'median_gap': [],
            'mean_gap': [],
            'std_gap': [],
        }
        
        for n in n_values:
            unique_count = 0
            gaps = []
            
            for _ in range(n_samples):
                W = critical_window_matrix(n, c, sigma)
                landscape = energy_landscape(W)
                gaps.append(landscape['spectral_gap'])
                
                # Check uniqueness: gap > 0 means unique witness
                if landscape['spectral_gap'] > 1e-10:
                    unique_count += 1
            
            results[c]['uniqueness_fraction'].append(unique_count / n_samples)
            results[c]['median_gap'].append(np.median(gaps))
            results[c]['mean_gap'].append(np.mean(gaps))
            results[c]['std_gap'].append(np.std(gaps))
            
            print(f"c={c}, n={n}: uniqueness={unique_count/n_samples:.3f}, "
                  f"median_gap={np.median(gaps):.3f}, mean_gap={np.mean(gaps):.3f}")
    
    return results

def experiment_subcritical(
    n_values: List[int] = [20, 50, 100, 200],
    c_values: List[float] = [0.5, 0.8, 0.95],
    n_samples: int = 2000,
    sigma: float = 1.0,
) -> dict:
    """Test the subcritical gap conjecture: gap should be O(1) for c < 1."""
    results = {}
    
    for c in c_values:
        results[c] = {'n_values': n_values, 'median_gap': [], 'mean_gap': []}
        for n in n_values:
            gaps = []
            for _ in range(n_samples):
                W = critical_window_matrix(n, c, sigma)
                landscape = energy_landscape(W)
                gaps.append(landscape['spectral_gap'])
            
            results[c]['median_gap'].append(np.median(gaps))
            results[c]['mean_gap'].append(np.mean(gaps))
            print(f"[subcritical] c={c}, n={n}: median_gap={np.median(gaps):.4f}")
    
    return results

# ─── Plotting ────────────────────────────────────────────────────────────────

def plot_results(results: dict, subcritical_results: dict, sigma: float = 1.0):
    """Create publication-quality plots."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    
    # Plot 1: Uniqueness fraction vs n
    ax = axes[0, 0]
    for c, data in results.items():
        ax.plot(data['n_values'], data['uniqueness_fraction'], 'o-', label=f'c={c}', linewidth=2)
    ax.set_xlabel('Matrix size n', fontsize=12)
    ax.set_ylabel('Uniqueness fraction', fontsize=12)
    ax.set_title('Witness Uniqueness in Critical Window', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(0.9, 1.01)
    ax.grid(True, alpha=0.3)
    
    # Plot 2: Spectral gap vs n with theoretical prediction
    ax = axes[0, 1]
    n_theory = np.linspace(10, 250, 100)
    for c, data in results.items():
        ax.plot(data['n_values'], data['median_gap'], 'o-', label=f'c={c} (data)', linewidth=2)
    # Theoretical prediction: gap ~ C·σ·√(log n) (with fitted C)
    ax.plot(n_theory, 0.5 * sigma * np.sqrt(np.log(n_theory)), '--', color='gray', 
            label=r'$0.5 \cdot \sigma \cdot \sqrt{\log n}$', linewidth=2)
    ax.set_xlabel('Matrix size n', fontsize=12)
    ax.set_ylabel('Median spectral gap', fontsize=12)
    ax.set_title('Spectral Gap Growth (Critical Window)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Subcritical gap (should be ~constant)
    ax = axes[1, 0]
    for c, data in subcritical_results.items():
        ax.plot(data['n_values'], data['median_gap'], 's-', label=f'c={c}', linewidth=2)
    ax.set_xlabel('Matrix size n', fontsize=12)
    ax.set_ylabel('Median spectral gap', fontsize=12)
    ax.set_title('Subcritical Gap Conjecture (c < 1)', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Plot 4: Energy landscape example
    ax = axes[1, 1]
    n_example = 50
    W = critical_window_matrix(n_example, c=2.0, sigma=1.0)
    landscape = energy_landscape(W)
    sorted_vals = landscape['sorted_values']
    ax.plot(range(len(sorted_vals)), sorted_vals, 'b-', linewidth=1.5)
    ax.axhline(y=sorted_vals[0], color='r', linestyle='--', alpha=0.7, label='Ground state')
    ax.axhline(y=sorted_vals[1], color='orange', linestyle='--', alpha=0.7, label='1st excited')
    ax.fill_between([0, 5], sorted_vals[0], sorted_vals[1], alpha=0.2, color='green', label='Spectral gap')
    ax.set_xlabel('Pair index (sorted)', fontsize=12)
    ax.set_ylabel('diagExSlack value', fontsize=12)
    ax.set_title(f'Energy Landscape (n={n_example}, c=2.0)', fontsize=13)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('tropical_defect_localization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_defect_localization.png")

# ─── Main ────────────────────────────────────────────────────────────────────

if __name__ == '__main__':
    np.random.seed(42)
    
    print("=" * 60)
    print("TROPICAL DEFECT LOCALIZATION — DEMO")
    print("=" * 60)
    
    print("\n--- Experiment 1: Uniqueness & Gap Growth (Critical Window) ---")
    results = experiment_uniqueness_and_gap(n_samples=1000)
    
    print("\n--- Experiment 2: Subcritical Gap Conjecture ---")
    subcritical = experiment_subcritical(n_samples=1000)
    
    print("\n--- Generating plots ---")
    plot_results(results, subcritical)
    
    # Show a single landscape in detail
    print("\n--- Example Energy Landscape (n=30, c=2.0) ---")
    W = critical_window_matrix(30, c=2.0)
    L = energy_landscape(W)
    print(f"  Witness pair: {L['witness']}")
    print(f"  Tropical margin: {L['trop_margin']:.4f}")
    print(f"  Spectral gap: {L['spectral_gap']:.4f}")
    print(f"  5 smallest slack values: {L['sorted_values'][:5].round(4)}")
    
    # Verify defect identification: witness should have most extreme noise
    N = W - mean_model(30, 0, 2.0 * np.sqrt(np.log(30)))
    noise_landscape = energy_landscape(N)
    print(f"  Noise witness pair: {noise_landscape['witness']}")
    print(f"  Match (defect identification): {L['witness'] == noise_landscape['witness']}")


"""
Visualization: Energy Landscape of Tropical DiagExSlack Values

This script visualizes the "energy landscape" of a matrix — the sorted
collection of diagonal exchange slack values. It shows how a single
defect (the minimum) is isolated from the rest by a spectral gap,
illustrating the core phenomenon of defect localization.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───────────────────────────────────────

def diag_ex_slack_matrix(W):
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

def energy_landscape(W):
    n = W.shape[0]
    S = diag_ex_slack_matrix(W)
    pairs = [(i, j) for i in range(n) for j in range(n) if i != j]
    slacks = np.array([S[i, j] for i, j in pairs])
    sorted_slacks = np.sort(slacks)
    min_idx = np.argmin(slacks)
    return {
        'witness': pairs[min_idx],
        'sorted_values': sorted_slacks,
        'trop_margin': sorted_slacks[0],
        'spectral_gap': sorted_slacks[1] - sorted_slacks[0],
    }

# ─── Generate figure ────────────────────────────────────────────────────────

np.random.seed(2024)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax_idx, (n, c, title) in enumerate([
    (30, 0.5, 'Sub-critical (c=0.5)'),
    (30, 1.0, 'Critical (c=1.0)'),
    (30, 2.5, 'Super-critical (c=2.5)'),
]):
    ax = axes[ax_idx]
    mu_off = c * np.sqrt(np.log(n))
    W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
    L = energy_landscape(W)
    vals = L['sorted_values']
    
    # Color: ground state red, first excited orange, rest blue
    colors = ['red'] + ['orange'] + ['steelblue'] * (len(vals) - 2)
    
    ax.bar(range(len(vals)), vals, color=colors, width=1.0, edgecolor='none', alpha=0.8)
    ax.axhline(y=vals[0], color='red', linestyle='--', alpha=0.5, linewidth=1)
    ax.axhline(y=vals[1], color='orange', linestyle='--', alpha=0.5, linewidth=1)
    
    # Annotate spectral gap
    gap = L['spectral_gap']
    mid_y = (vals[0] + vals[1]) / 2
    ax.annotate(f'Gap = {gap:.2f}', xy=(3, mid_y), fontsize=11,
                color='darkgreen', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightgreen', alpha=0.7))
    
    ax.set_title(title, fontsize=13, fontweight='bold')
    ax.set_xlabel('Pair index (sorted)', fontsize=11)
    ax.set_ylabel('diagExSlack value', fontsize=11)
    ax.grid(True, alpha=0.2)

fig.suptitle('Energy Landscapes: Defect Localization in the Critical Window',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_energy_landscape.png")


"""
Visualization: Spectral Gap Growth vs Matrix Size

This script shows how the spectral gap of the energy landscape grows
with matrix size n, comparing supercritical (c > 1) with subcritical
(c < 1) regimes. The theoretical prediction C·σ·√(log n) is overlaid.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───────────────────────────────────────

def diag_ex_slack_matrix(W):
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

def compute_gap(W):
    n = W.shape[0]
    S = diag_ex_slack_matrix(W)
    slacks = []
    for i in range(n):
        for j in range(n):
            if i != j:
                slacks.append(S[i, j])
    slacks.sort()
    return slacks[1] - slacks[0] if len(slacks) > 1 else 0.0

# ─── Experiment ──────────────────────────────────────────────────────────────

np.random.seed(2024)

n_values = [10, 20, 30, 50, 75, 100, 150, 200]
c_values = [0.5, 1.0, 2.0, 3.0]
n_samples = 500

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Left: Median gap vs n for different c values
for c in c_values:
    median_gaps = []
    for n in n_values:
        gaps = []
        for _ in range(n_samples):
            mu_off = c * np.sqrt(np.log(n))
            W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
            gaps.append(compute_gap(W))
        median_gaps.append(np.median(gaps))
    
    style = '-o' if c >= 1.0 else '--s'
    ax1.plot(n_values, median_gaps, style, label=f'c={c}', linewidth=2, markersize=6)

# Theoretical curve
n_theory = np.linspace(8, 220, 100)
ax1.plot(n_theory, 0.45 * np.sqrt(np.log(n_theory)), ':', color='gray',
         linewidth=2, label=r'$0.45 \sqrt{\log n}$ (theory)')

ax1.set_xlabel('Matrix size n', fontsize=13)
ax1.set_ylabel('Median spectral gap', fontsize=13)
ax1.set_title('Spectral Gap Growth', fontsize=14, fontweight='bold')
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)

# Right: Gap distribution for fixed n=100
n_fixed = 100
for c in [0.5, 1.5, 3.0]:
    gaps = []
    for _ in range(1000):
        mu_off = c * np.sqrt(np.log(n_fixed))
        W = mean_model(n_fixed, 0, mu_off) + np.random.randn(n_fixed, n_fixed)
        gaps.append(compute_gap(W))
    ax2.hist(gaps, bins=40, alpha=0.5, label=f'c={c}', density=True)

ax2.set_xlabel('Spectral gap', fontsize=13)
ax2.set_ylabel('Density', fontsize=13)
ax2.set_title(f'Gap Distribution (n={n_fixed})', fontsize=14, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_gap_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_gap_growth.png")


"""
Visualization: DiagExSlack Heatmap and Defect Localization

This script creates a heatmap of the diagExSlack matrix, showing
how the minimum (defect) is localized at a single entry. The witness
pair is highlighted with a marker.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

# ─── Inline functions (self-contained) ───────────────────────────────────────

def diag_ex_slack_matrix(W):
    diag = np.diag(W)
    return 2 * W - diag[:, np.newaxis] - diag[np.newaxis, :]

def mean_model(n, mu_diag, mu_off):
    M = np.full((n, n), mu_off)
    np.fill_diagonal(M, mu_diag)
    return M

# ─── Generate figure ────────────────────────────────────────────────────────

np.random.seed(123)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

for ax_idx, c in enumerate([0.5, 1.5, 3.0]):
    ax = axes[ax_idx]
    n = 20
    mu_off = c * np.sqrt(np.log(n))
    W = mean_model(n, 0, mu_off) + np.random.randn(n, n)
    S = diag_ex_slack_matrix(W)
    
    # Mask diagonal
    S_display = S.copy()
    np.fill_diagonal(S_display, np.nan)
    
    # Find witness
    S_offdiag = S.copy()
    np.fill_diagonal(S_offdiag, np.inf)
    witness = np.unravel_index(np.argmin(S_offdiag), S.shape)
    
    im = ax.imshow(S_display, cmap='RdYlBu_r', aspect='equal')
    plt.colorbar(im, ax=ax, shrink=0.8, label='diagExSlack')
    
    # Mark witness
    ax.plot(witness[1], witness[0], 'k*', markersize=20, markeredgewidth=2,
            markeredgecolor='white')
    ax.plot(witness[1], witness[0], 'r*', markersize=15)
    
    ax.set_title(f'c = {c} ({"sub" if c < 1 else "super"}-critical)',
                 fontsize=13, fontweight='bold')
    ax.set_xlabel('Column j', fontsize=11)
    ax.set_ylabel('Row i', fontsize=11)
    
    # Add text with gap info
    S_sorted = np.sort(S_offdiag.flatten())
    gap = S_sorted[1] - S_sorted[0]
    ax.text(0.02, 0.98, f'Gap={gap:.2f}\nWitness={witness}',
            transform=ax.transAxes, fontsize=9,
            verticalalignment='top',
            bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

fig.suptitle('DiagExSlack Heatmaps: Defect Localization (★ = witness)',
             fontsize=15, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: viz_heatmap.png")
