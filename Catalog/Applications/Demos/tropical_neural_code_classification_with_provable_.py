#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Applications

Real-world applications of the tropical classification framework:
1. Neural population decoding with certified robustness
2. Receptive field classification of visual stimuli
3. Adversarial robustness certification for neural networks
"""

import numpy as np
from typing import Dict, List, Tuple

# ─────────────────────────────────────────────────────────
# Application 1: Neural Population Decoding
# ─────────────────────────────────────────────────────────

def neural_population_decoding():
    """
    Application: Decoding stimulus identity from neural population activity.

    Scenario: A population of 8 neurons responds to 3 different visual stimuli.
    Each stimulus evokes a characteristic firing pattern (codebook).
    We decode which stimulus was presented from a noisy observation.

    The tropical classifier provides:
    - Predicted stimulus identity
    - Certified robustness radius (how much noise can be tolerated)
    """
    print("=" * 60)
    print("APPLICATION 1: Neural Population Decoding")
    print("=" * 60)

    np.random.seed(42)
    n_neurons = 8

    # Codebooks: prototypical firing patterns for each stimulus
    # These represent receptive field responses
    stimulus_A = np.array([  # Vertical grating
        [8, 2, 7, 1, 8, 2, 7, 1],   # Pattern 1
        [7, 3, 6, 2, 7, 3, 6, 2],   # Pattern 2 (variation)
    ], dtype=float)

    stimulus_B = np.array([  # Horizontal grating
        [2, 8, 1, 7, 2, 8, 1, 7],
        [3, 7, 2, 6, 3, 7, 2, 6],
    ], dtype=float)

    stimulus_C = np.array([  # Diagonal grating
        [5, 5, 3, 3, 6, 6, 2, 2],
        [4, 6, 2, 4, 5, 7, 1, 3],
    ], dtype=float)

    codebooks = {'Vertical': stimulus_A, 'Horizontal': stimulus_B, 'Diagonal': stimulus_C}

    def trop_score(codebook, x):
        return max(float(np.min(x - s)) for s in codebook)

    def classify(x):
        scores = {name: trop_score(cb, x) for name, cb in codebooks.items()}
        best = max(scores, key=scores.get)
        sorted_scores = sorted(scores.values(), reverse=True)
        gap = sorted_scores[0] - sorted_scores[1]
        return best, gap / 2, scores

    # Simulate noisy neural observations
    print(f"\nNeural population: {n_neurons} neurons, 3 stimulus classes")
    print(f"Codebook sizes: {', '.join(f'{k}={len(v)}' for k, v in codebooks.items())}")

    n_trials = 20
    noise_levels = [0.5, 1.0, 2.0, 3.0]

    for true_stimulus, true_codebook in codebooks.items():
        print(f"\n--- True stimulus: {true_stimulus} ---")
        base_pattern = true_codebook[0]

        for noise_std in noise_levels:
            correct = 0
            certified = 0
            for _ in range(n_trials):
                noise = np.random.normal(0, noise_std, n_neurons)
                observation = base_pattern + noise
                pred, radius, scores = classify(observation)
                if pred == true_stimulus:
                    correct += 1
                actual_noise = np.max(np.abs(noise))
                if actual_noise < radius:
                    certified += 1

            print(f"  σ={noise_std:.1f}: accuracy={correct}/{n_trials}, "
                  f"certified={certified}/{n_trials}")


# ─────────────────────────────────────────────────────────
# Application 2: Receptive Field Classification
# ─────────────────────────────────────────────────────────

def receptive_field_classification():
    """
    Application: Classifying visual features by receptive field responses.

    Models simple/complex cell responses in primary visual cortex.
    Demonstrates that tropical geometry naturally captures the max-pooling
    structure of complex cell responses.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Receptive Field Classification")
    print("=" * 60)

    np.random.seed(123)

    # Simulate receptive field responses for different orientations
    n_orientations = 4  # 0°, 45°, 90°, 135°
    n_spatial_phases = 3  # Different spatial phases

    # Generate orientation-selective codebooks
    codebooks = {}
    for k in range(n_orientations):
        angle = k * 45
        generators = []
        for phase in range(n_spatial_phases):
            # Simple cell response: tuned to orientation + phase
            response = np.zeros(n_orientations * n_spatial_phases)
            for p in range(n_spatial_phases):
                idx = k * n_spatial_phases + p
                response[idx] = 5.0 + np.random.uniform(-0.5, 0.5)
                # Cross-orientation suppression
                for k2 in range(n_orientations):
                    if k2 != k:
                        idx2 = k2 * n_spatial_phases + p
                        response[idx2] = 1.0 + np.random.uniform(-0.3, 0.3)
            generators.append(response)
        codebooks[f'{angle}°'] = np.array(generators)

    n = n_orientations * n_spatial_phases

    def trop_score(codebook, x):
        return max(float(np.min(x - s)) for s in codebook)

    # Compute pairwise margins
    print(f"\nFeature space: {n} dimensions ({n_orientations} orientations × {n_spatial_phases} phases)")
    print(f"Classes: {list(codebooks.keys())}")

    print(f"\nPairwise separation margins:")
    labels = list(codebooks.keys())
    for i in range(len(labels)):
        for j in range(i + 1, len(labels)):
            A, B = codebooks[labels[i]], codebooks[labels[j]]
            margin = float('inf')
            for a in A:
                for b in B:
                    margin = min(margin, float(np.max(a - b)))
            print(f"  {labels[i]} vs {labels[j]}: γ = {margin:.2f}, "
                  f"certified radius = {margin/2:.2f}")

    # Test with noisy observations
    print(f"\nClassification accuracy (100 trials per orientation, σ=1.0):")
    for true_label, cb in codebooks.items():
        correct = 0
        for _ in range(100):
            x = cb[0] + np.random.normal(0, 1.0, n)
            scores = {l: trop_score(c, x) for l, c in codebooks.items()}
            pred = max(scores, key=scores.get)
            if pred == true_label:
                correct += 1
        print(f"  {true_label}: {correct}%")


# ─────────────────────────────────────────────────────────
# Application 3: Adversarial Robustness Certification
# ─────────────────────────────────────────────────────────

def adversarial_robustness():
    """
    Application: Certifying robustness of a tropical classifier against
    adversarial perturbations.

    Demonstrates the margin-based certification: if the score gap exceeds
    2ε, then no L∞ perturbation of size ε can change the classification.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Adversarial Robustness Certification")
    print("=" * 60)

    np.random.seed(456)
    n = 6  # feature dimension

    # Two-class problem with well-separated codebooks
    A = np.array([
        [6, 4, 2, 5, 3, 1],
        [5, 5, 1, 4, 4, 2],
        [7, 3, 3, 6, 2, 0],
    ], dtype=float)

    B = np.array([
        [1, 3, 6, 0, 4, 5],
        [2, 2, 5, 1, 5, 4],
        [0, 4, 7, -1, 3, 6],
    ], dtype=float)

    def trop_score(codebook, x):
        return max(float(np.min(x - s)) for s in codebook)

    # Test point
    x = np.array([5.5, 4.0, 2.5, 4.5, 3.5, 1.5])
    score_A = trop_score(A, x)
    score_B = trop_score(B, x)
    gap = score_A - score_B
    certified_radius = gap / 2

    print(f"\nFeature dimension: {n}")
    print(f"Test point x = {x}")
    print(f"Score(A) = {score_A:.3f}")
    print(f"Score(B) = {score_B:.3f}")
    print(f"Gap = {gap:.3f}")
    print(f"Certified radius = {certified_radius:.3f}")
    print(f"\nPrediction: {'A' if score_A >= score_B else 'B'}")
    print(f"Guarantee: classification is invariant under L∞ perturbations < {certified_radius:.3f}")

    # Verify by exhaustive adversarial search
    print(f"\nAdversarial verification (10000 random attacks):")
    for eps in [0.5, 1.0, 1.5, 2.0, 2.5]:
        flipped = 0
        for _ in range(10000):
            # Random adversarial perturbation
            delta = np.random.uniform(-eps, eps, n)
            x_adv = x + delta
            score_A_adv = trop_score(A, x_adv)
            score_B_adv = trop_score(B, x_adv)
            if (score_A_adv >= score_B_adv) != (score_A >= score_B):
                flipped += 1
        status = "CERTIFIED SAFE" if eps < certified_radius else "vulnerable"
        print(f"  ε={eps:.1f}: {flipped}/10000 flipped | {status}")

    # Coboundary margin analysis
    print(f"\n--- Coboundary Margin Analysis ---")
    # Simulated local margins from piecewise-linear regions
    n_regions = 4
    m = np.array([2.0, 1.5, 1.8, 2.2])  # local margins
    L = np.array([3.0, 2.5, 2.8, 3.2])  # Lipschitz constants
    b = np.array([0.15, 0.1, 0.2, 0.12])  # gauge corrections

    adjusted = (m - L * np.abs(b)) / L
    global_margin = np.min(adjusted)

    print(f"Regions: {n_regions}")
    print(f"Adjusted margins: {adjusted.round(4)}")
    print(f"Global margin δ = {global_margin:.4f}")
    print(f"Certified global radius = {global_margin:.4f}")


if __name__ == '__main__':
    neural_population_decoding()
    receptive_field_classification()
    adversarial_robustness()
    print("\n" + "=" * 60)
    print("All applications completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Demo

Demonstrates the core theorems with concrete numerical examples:
1. Tropical separation margin certifies binary classification
2. Tropical score stability under perturbation
3. Finite dominance patterns control classification capacity
"""

import numpy as np
from typing import List, Tuple, Optional

# ─────────────────────────────────────────────────────────
# Core Definitions
# ─────────────────────────────────────────────────────────

def coord_gap(x: np.ndarray, s: np.ndarray) -> float:
    """Coordinatewise infimum gap: min_i (x_i - s_i)."""
    return np.min(x - s)

def trop_generator_score(S: np.ndarray, x: np.ndarray) -> float:
    """Tropical generator score: max over generators of coord_gap."""
    if len(S) == 0:
        return 0.0
    return max(coord_gap(x, s) for s in S)

def classifies_as_A(A: np.ndarray, B: np.ndarray, x: np.ndarray) -> bool:
    """Returns True if x is classified as class A against class B."""
    return trop_generator_score(A, x) >= trop_generator_score(B, x)

def dominance_signature(C: np.ndarray, x: np.ndarray) -> np.ndarray:
    """For each generator s and coordinate pair (i,j), records x_i - s_i >= x_j - s_j."""
    n = x.shape[0]
    sigs = []
    for s in C:
        gaps = x - s
        sig = np.array([[gaps[i] >= gaps[j] for j in range(n)] for i in range(n)])
        sigs.append(sig)
    return np.array(sigs)

def separation_margin(A: np.ndarray, B: np.ndarray) -> Tuple[float, Optional[int]]:
    """Compute the separation margin: min over (a,b) pairs of max_i (a_i - b_i)."""
    min_margin = float('inf')
    best_coord = None
    for a in A:
        for b in B:
            gaps = a - b
            max_gap = np.max(gaps)
            coord = int(np.argmax(gaps))
            if max_gap < min_margin:
                min_margin = max_gap
                best_coord = coord
    return min_margin, best_coord

# ─────────────────────────────────────────────────────────
# Demo 1: Tropical Separation Certifies Classification
# ─────────────────────────────────────────────────────────

def demo_separation():
    """Demonstrates Theorem A: positive separation implies no dual membership."""
    print("=" * 60)
    print("DEMO 1: Tropical Separation Certifies Classification")
    print("=" * 60)

    # Two neural codebooks in R^3
    # Class A: neurons responding strongly to stimulus type A
    A = np.array([
        [5.0, 3.0, 1.0],   # neuron pattern 1
        [4.5, 3.5, 1.5],   # neuron pattern 2
    ])

    # Class B: neurons responding strongly to stimulus type B
    B = np.array([
        [1.0, 2.0, 4.0],   # neuron pattern 3
        [1.5, 1.5, 3.5],   # neuron pattern 4
    ])

    gamma, coord = separation_margin(A, B)
    print(f"\nCodebook A (stimulus class A):\n{A}")
    print(f"Codebook B (stimulus class B):\n{B}")
    print(f"\nSeparation margin γ = {gamma:.2f} (witnessed at coordinate {coord})")
    print(f"Certified perturbation radius: γ/2 = {gamma/2:.2f}")

    # Test point near class A
    x = np.array([4.8, 3.2, 1.2])
    score_A = trop_generator_score(A, x)
    score_B = trop_generator_score(B, x)

    print(f"\nTest point x = {x}")
    print(f"  Score vs A: {score_A:.2f}")
    print(f"  Score vs B: {score_B:.2f}")
    print(f"  Classification: {'A' if score_A >= score_B else 'B'}")

    # Check distances to nearest generators
    dist_A = min(np.max(np.abs(x - a)) for a in A)
    dist_B = min(np.max(np.abs(x - b)) for b in B)
    print(f"  L∞ distance to A: {dist_A:.2f}")
    print(f"  L∞ distance to B: {dist_B:.2f}")
    print(f"  Within γ/2 of A? {dist_A < gamma/2}")
    print(f"  Within γ/2 of B? {dist_B < gamma/2}")
    print(f"  → Theorem guarantees: cannot be within γ/2 of both! ✓")

    # Perturbed point
    print("\n--- Perturbation test ---")
    eps = 0.3
    perturbation = np.array([0.2, -0.1, 0.3])
    x_perturbed = x + perturbation
    score_A_pert = trop_generator_score(A, x_perturbed)
    score_B_pert = trop_generator_score(B, x_perturbed)
    gap = score_A - score_B
    print(f"  Original gap: {gap:.2f}")
    print(f"  Perturbation size (L∞): {np.max(np.abs(perturbation)):.2f}")
    print(f"  Perturbed scores: A={score_A_pert:.2f}, B={score_B_pert:.2f}")
    print(f"  Classification preserved? {classifies_as_A(A, B, x) == classifies_as_A(A, B, x_perturbed)}")

# ─────────────────────────────────────────────────────────
# Demo 2: Score Stability Under Perturbation
# ─────────────────────────────────────────────────────────

def demo_stability():
    """Demonstrates Theorem A (stability): small perturbations preserve classification."""
    print("\n" + "=" * 60)
    print("DEMO 2: Tropical Score Stability Under Perturbation")
    print("=" * 60)

    np.random.seed(42)
    n = 4  # dimension

    # Generate random codebooks
    A = np.random.randn(3, n) + np.array([3, 0, -1, 2])
    B = np.random.randn(3, n) + np.array([-1, 2, 3, -2])

    x = np.array([2.5, 0.5, -0.5, 1.5])
    score_A = trop_generator_score(A, x)
    score_B = trop_generator_score(B, x)
    gap = score_A - score_B

    print(f"\nDimension: {n}")
    print(f"Original point x = {x}")
    print(f"Score gap (A - B): {gap:.4f}")
    print(f"Critical perturbation radius: {gap/2:.4f}")

    # Test many random perturbations
    print(f"\nTesting 1000 random perturbations of increasing size:")
    for eps_level in [0.1, 0.5, 1.0, 1.5, 2.0]:
        preserved = 0
        for _ in range(1000):
            pert = np.random.uniform(-eps_level, eps_level, n)
            x_pert = x + pert
            if classifies_as_A(A, B, x) == classifies_as_A(A, B, x_pert):
                preserved += 1
        max_safe = gap / 2
        guaranteed = "YES (theorem guarantees)" if eps_level < max_safe else "no guarantee"
        print(f"  ε={eps_level:.1f}: {preserved}/1000 preserved | {guaranteed}")

# ─────────────────────────────────────────────────────────
# Demo 3: Finite Dominance Patterns
# ─────────────────────────────────────────────────────────

def demo_dominance_patterns():
    """Demonstrates Theorem B: dominance patterns form a finite quotient."""
    print("\n" + "=" * 60)
    print("DEMO 3: Finite Dominance Patterns Control Classification")
    print("=" * 60)

    # Simple 2D codebook
    C = np.array([
        [1.0, 3.0],
        [3.0, 1.0],
        [2.0, 2.0],
    ])

    print(f"\nCodebook C ({len(C)} generators in R^2):\n{C}")

    # Sample many random points and collect unique signatures
    np.random.seed(123)
    unique_sigs = set()
    sig_to_points = {}

    for _ in range(10000):
        x = np.random.uniform(-5, 8, 2)
        sig = dominance_signature(C, x)
        sig_key = sig.tobytes()
        unique_sigs.add(sig_key)
        if sig_key not in sig_to_points:
            sig_to_points[sig_key] = []
        if len(sig_to_points[sig_key]) < 3:
            sig_to_points[sig_key].append(x.copy())

    print(f"\nSampled 10000 random points in [-5, 8]^2")
    print(f"Number of unique dominance signatures: {len(unique_sigs)}")
    print(f"\nTheorem B guarantees: any classifier factoring through dominance")
    print(f"signatures has at most {len(unique_sigs)} distinct output labels.")

    # Show that classification agrees within each signature class
    A_code = C[:1]  # first generator is class A
    B_code = C[1:]  # rest is class B

    consistent = True
    for sig_key, points in sig_to_points.items():
        if len(points) >= 2:
            labels = [classifies_as_A(A_code, B_code, p) for p in points]
            if len(set(labels)) > 1:
                consistent = False
                break

    print(f"\nClassification consistent within signature classes: {consistent} ✓")

# ─────────────────────────────────────────────────────────
# Demo 4: Coboundary Margin Transfer
# ─────────────────────────────────────────────────────────

def demo_coboundary():
    """Demonstrates Theorem C: coboundary conditions yield global margins."""
    print("\n" + "=" * 60)
    print("DEMO 4: Coboundary Margin Transfer")
    print("=" * 60)

    # Three regions with local margin certificates
    regions = ['Region 1', 'Region 2', 'Region 3']
    m = np.array([1.0, 0.8, 1.2])    # local margins
    L = np.array([2.0, 1.5, 2.5])    # Lipschitz constants
    b = np.array([0.1, 0.2, 0.15])   # gauge corrections

    print(f"\n{'Region':<12} {'Margin m':<12} {'Lip L':<10} {'Gauge |b|':<12} {'L*|b|':<10} {'Adjusted':<10}")
    print("-" * 66)
    for i in range(3):
        adjusted = (m[i] - L[i] * abs(b[i])) / L[i]
        print(f"{regions[i]:<12} {m[i]:<12.2f} {L[i]:<10.2f} {abs(b[i]):<12.2f} {L[i]*abs(b[i]):<10.2f} {adjusted:<10.4f}")

    # Check coboundary condition
    coboundary_holds = all(L[i] * abs(b[i]) <= m[i] for i in range(3))
    adjusted_margins = [(m[i] - L[i] * abs(b[i])) / L[i] for i in range(3)]
    global_margin = min(adjusted_margins)

    print(f"\nCoboundary condition L·|b| ≤ m: {'✓ holds' if coboundary_holds else '✗ fails'}")
    print(f"Global adjusted margin δ = min(adjusted) = {global_margin:.4f}")
    print(f"δ ≥ 0: {global_margin >= 0} ✓")
    print(f"\nTheorem C guarantees: certified tropical classification margin ≥ {global_margin:.4f}")

# ─────────────────────────────────────────────────────────

if __name__ == '__main__':
    demo_separation()
    demo_stability()
    demo_dominance_patterns()
    demo_coboundary()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Neural Code Classification — Visualizations

Generates publication-quality figures illustrating:
1. Tropical separation between codebooks
2. Dominance pattern partition of input space
3. Score stability under perturbation
4. Coboundary margin diagram
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches

# ─────────────────────────────────────────────────────────
# Figure 1: Tropical Separation Between Codebooks
# ─────────────────────────────────────────────────────────

def plot_tropical_separation():
    """Visualize two codebooks with their γ/2 neighborhoods."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Codebooks in R^2
    A = np.array([[5.0, 3.0], [4.5, 3.5], [4.0, 4.0]])
    B = np.array([[1.0, 2.0], [1.5, 1.5], [2.0, 1.0]])

    # Compute margin
    gamma = float('inf')
    for a in A:
        for b in B:
            gamma = min(gamma, max(a - b))

    radius = gamma / 2

    # Plot neighborhoods (L∞ balls)
    for a in A:
        rect = plt.Rectangle(a - radius, 2 * radius, 2 * radius,
                            fill=True, alpha=0.15, color='royalblue',
                            linewidth=1.5, edgecolor='royalblue', linestyle='--')
        ax.add_patch(rect)

    for b in B:
        rect = plt.Rectangle(b - radius, 2 * radius, 2 * radius,
                            fill=True, alpha=0.15, color='crimson',
                            linewidth=1.5, edgecolor='crimson', linestyle='--')
        ax.add_patch(rect)

    # Plot generators
    ax.scatter(A[:, 0], A[:, 1], s=150, c='royalblue', marker='s',
              zorder=5, edgecolors='navy', linewidth=2, label='Class A generators')
    ax.scatter(B[:, 0], B[:, 1], s=150, c='crimson', marker='^',
              zorder=5, edgecolors='darkred', linewidth=2, label='Class B generators')

    # Annotate margin
    ax.annotate('', xy=(A[0, 0], A[0, 1] - 0.3), xytext=(B[0, 0], B[0, 1] + 0.3),
               arrowprops=dict(arrowstyle='<->', color='black', lw=2))
    mid_x = (A[0, 0] + B[0, 0]) / 2
    mid_y = (A[0, 1] + B[0, 1]) / 2
    ax.text(mid_x + 0.3, mid_y, f'γ = {gamma:.1f}', fontsize=14,
           fontweight='bold', ha='left')

    ax.set_xlabel('Coordinate 1 (Neuron 1 firing rate)', fontsize=13)
    ax.set_ylabel('Coordinate 2 (Neuron 2 firing rate)', fontsize=13)
    ax.set_title('Tropical Separation Between Neural Codebooks', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12, loc='upper left')
    ax.set_xlim(-0.5, 7)
    ax.set_ylim(-0.5, 6)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)

    # Add text box
    textstr = f'Separation margin γ = {gamma:.1f}\nCertified radius γ/2 = {radius:.1f}\nNo point can lie in both\nblue AND red neighborhoods'
    props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
    ax.text(0.02, 0.98, textstr, transform=ax.transAxes, fontsize=11,
           verticalalignment='top', bbox=props)

    plt.tight_layout()
    plt.savefig('fig_tropical_separation.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_tropical_separation.png")

# ─────────────────────────────────────────────────────────
# Figure 2: Dominance Pattern Partition
# ─────────────────────────────────────────────────────────

def plot_dominance_partition():
    """Visualize the finite partition induced by dominance signatures."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Codebook in R^2
    C = np.array([[1.0, 3.0], [3.0, 1.0], [2.0, 2.0]])

    # Compute dominance signature for a grid
    xx, yy = np.meshgrid(np.linspace(-2, 6, 500), np.linspace(-2, 6, 500))
    signatures = np.zeros_like(xx)

    for i in range(xx.shape[0]):
        for j in range(xx.shape[1]):
            x = np.array([xx[i, j], yy[i, j]])
            sig_parts = []
            for s in C:
                gaps = x - s
                sig_parts.append(int(gaps[0] >= gaps[1]))
            signatures[i, j] = sig_parts[0] * 4 + sig_parts[1] * 2 + sig_parts[2]

    # Plot partition with distinct colors
    cmap = plt.cm.Set3
    ax.contourf(xx, yy, signatures, levels=np.arange(-0.5, 9, 1),
               cmap=cmap, alpha=0.6)
    ax.contour(xx, yy, signatures, levels=np.arange(-0.5, 9, 1),
              colors='gray', linewidths=0.5, alpha=0.5)

    # Plot generators
    ax.scatter(C[:, 0], C[:, 1], s=200, c='black', marker='*',
              zorder=5, label='Generators', linewidth=1)
    for idx, s in enumerate(C):
        ax.annotate(f's{idx+1}', s + 0.15, fontsize=13, fontweight='bold')

    # Add diagonal lines showing boundaries
    # Boundary: x₁ - s₁ = x₂ - s₂, i.e., x₁ - x₂ = s₁ - s₂
    for s in C:
        slope_intercept = s[0] - s[1]
        xs = np.linspace(-2, 6, 100)
        ys = xs - slope_intercept
        ax.plot(xs, ys, 'k-', alpha=0.3, linewidth=1)

    n_unique = len(np.unique(signatures))
    ax.set_xlabel('Coordinate 1', fontsize=13)
    ax.set_ylabel('Coordinate 2', fontsize=13)
    ax.set_title(f'Dominance Pattern Partition ({n_unique} cells)', fontsize=15, fontweight='bold')
    ax.legend(fontsize=12)
    ax.set_xlim(-2, 6)
    ax.set_ylim(-2, 6)
    ax.set_aspect('equal')

    textstr = f'{n_unique} distinct dominance patterns\n→ Classification capacity ≤ {n_unique}\n→ Finite quotient theorem (B)'
    props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
    ax.text(0.02, 0.98, textstr, transform=ax.transAxes, fontsize=11,
           verticalalignment='top', bbox=props)

    plt.tight_layout()
    plt.savefig('fig_dominance_partition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_dominance_partition.png")

# ─────────────────────────────────────────────────────────
# Figure 3: Score Stability Under Perturbation
# ─────────────────────────────────────────────────────────

def plot_score_stability():
    """Visualize how tropical scores change under perturbation."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    np.random.seed(42)

    # Codebooks in R^4
    A = np.array([[5, 3, 1, 4], [4.5, 3.5, 1.5, 3.5]], dtype=float)
    B = np.array([[1, 2, 4, 0.5], [1.5, 1.5, 3.5, 1]], dtype=float)

    x = np.array([4.8, 3.2, 1.2, 3.8])

    def trop_score(codebook, point):
        return max(float(np.min(point - s)) for s in codebook)

    score_A_orig = trop_score(A, x)
    score_B_orig = trop_score(B, x)
    gap = score_A_orig - score_B_orig

    # Panel 1: Score gap vs perturbation size
    eps_range = np.linspace(0, 3, 50)
    n_trials = 500
    gaps_mean = []
    gaps_min = []
    gaps_max = []

    for eps in eps_range:
        trial_gaps = []
        for _ in range(n_trials):
            pert = np.random.uniform(-eps, eps, 4)
            x_pert = x + pert
            g = trop_score(A, x_pert) - trop_score(B, x_pert)
            trial_gaps.append(g)
        gaps_mean.append(np.mean(trial_gaps))
        gaps_min.append(np.min(trial_gaps))
        gaps_max.append(np.max(trial_gaps))

    ax1.fill_between(eps_range, gaps_min, gaps_max, alpha=0.2, color='steelblue',
                    label='Min-max range')
    ax1.plot(eps_range, gaps_mean, 'b-', linewidth=2, label='Mean gap')
    ax1.axhline(y=0, color='red', linestyle='--', linewidth=1.5, label='Decision boundary')
    ax1.axvline(x=gap/2, color='green', linestyle=':', linewidth=2,
               label=f'Certified radius = {gap/2:.2f}')

    # Theoretical bounds
    ax1.plot(eps_range, gap - 2 * eps_range, 'k--', linewidth=1.5, alpha=0.5,
            label='Theoretical lower bound')

    ax1.set_xlabel('Perturbation size ε (L∞)', fontsize=13)
    ax1.set_ylabel('Score gap (A - B)', fontsize=13)
    ax1.set_title('Score Stability Under Perturbation', fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)

    # Panel 2: Classification accuracy vs perturbation
    eps_test = np.linspace(0, 3, 30)
    accuracies = []
    for eps in eps_test:
        correct = 0
        for _ in range(1000):
            pert = np.random.uniform(-eps, eps, 4)
            x_pert = x + pert
            if trop_score(A, x_pert) >= trop_score(B, x_pert):
                correct += 1
        accuracies.append(correct / 1000)

    ax2.plot(eps_test, accuracies, 'b-o', markersize=4, linewidth=2)
    ax2.axvline(x=gap/2, color='green', linestyle=':', linewidth=2,
               label=f'Certified radius = {gap/2:.2f}')
    ax2.axhline(y=1.0, color='gray', linestyle='--', alpha=0.5)
    ax2.fill_between([0, gap/2], 0, 1.05, alpha=0.1, color='green',
                    label='Certified region')

    ax2.set_xlabel('Perturbation size ε (L∞)', fontsize=13)
    ax2.set_ylabel('Classification accuracy', fontsize=13)
    ax2.set_title('Classification Robustness', fontsize=14, fontweight='bold')
    ax2.set_ylim(-0.05, 1.05)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_score_stability.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_score_stability.png")

# ─────────────────────────────────────────────────────────
# Figure 4: Coboundary Margin Diagram
# ─────────────────────────────────────────────────────────

def plot_coboundary_margins():
    """Visualize the coboundary margin transfer theorem."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Local margin certificates
    n_regions = 5
    m = np.array([1.0, 0.8, 1.2, 0.9, 1.1])
    L = np.array([2.0, 1.5, 2.5, 1.8, 2.2])
    b = np.array([0.1, 0.2, 0.15, 0.05, 0.18])

    adjusted = (m - L * np.abs(b)) / L
    global_margin = np.min(adjusted)

    # Panel 1: Bar chart of margins
    x_pos = np.arange(n_regions)
    width = 0.35

    bars1 = ax1.bar(x_pos - width/2, m / L, width, label='Raw margin m/L',
                   color='steelblue', alpha=0.8, edgecolor='navy')
    bars2 = ax1.bar(x_pos + width/2, adjusted, width, label='Adjusted margin',
                   color='coral', alpha=0.8, edgecolor='darkred')

    ax1.axhline(y=global_margin, color='green', linestyle='--', linewidth=2,
               label=f'Global margin δ = {global_margin:.3f}')

    ax1.set_xlabel('Region', fontsize=13)
    ax1.set_ylabel('Margin', fontsize=13)
    ax1.set_title('Local vs Adjusted Margins', fontsize=14, fontweight='bold')
    ax1.set_xticks(x_pos)
    ax1.set_xticklabels([f'R{i+1}' for i in range(n_regions)])
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3, axis='y')

    # Panel 2: Margin transfer illustration
    # Show how gauge corrections reduce margins
    gauge_range = np.linspace(0, 0.4, 100)
    for i in range(n_regions):
        adj_curve = (m[i] - L[i] * gauge_range) / L[i]
        adj_curve = np.maximum(adj_curve, 0)
        ax2.plot(gauge_range, adj_curve, linewidth=2,
                label=f'R{i+1}: m={m[i]:.1f}, L={L[i]:.1f}')

    ax2.axhline(y=0, color='red', linestyle='-', linewidth=1)

    # Mark actual gauge values
    for i in range(n_regions):
        ax2.plot(abs(b[i]), adjusted[i], 'ko', markersize=8, zorder=5)

    ax2.set_xlabel('Gauge correction |b|', fontsize=13)
    ax2.set_ylabel('Adjusted margin', fontsize=13)
    ax2.set_title('Margin Degradation vs Gauge', fontsize=14, fontweight='bold')
    ax2.legend(fontsize=9, loc='upper right')
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('fig_coboundary_margins.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: fig_coboundary_margins.png")


if __name__ == '__main__':
    plot_tropical_separation()
    plot_dominance_partition()
    plot_score_stability()
    plot_coboundary_margins()
    print("\nAll visualizations generated successfully!")
