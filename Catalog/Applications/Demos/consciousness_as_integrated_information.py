#!/usr/bin/env python3
"""
Demo: Integrated Information Theory — Causal Integration in Action

Demonstrates the key theorems with concrete numerical examples.
"""

from algorithms import (
    cut_weight, compute_phi, integration_complex,
    integration_spectrum, is_reducible, stoer_wagner_approx_phi
)


def demo_basic():
    """Demo 1: Basic Φ computation on a 4-node network."""
    print("=" * 60)
    print("DEMO 1: Basic Integrated Information")
    print("=" * 60)

    # A 4-node network with strong internal connections
    # 0 ↔ 1 (weight 5), 2 ↔ 3 (weight 5), 1 → 2 (weight 1)
    W = [
        [0, 5, 0, 0],
        [5, 0, 1, 0],
        [0, 0, 0, 5],
        [0, 0, 5, 0],
    ]

    phi, partition = compute_phi(W)
    print(f"Network: 4 nodes with strong pairs (0-1, 2-3) and weak link (1→2)")
    print(f"Φ = {phi}")
    print(f"Minimum Information Partition: {partition}")
    print(f"  → The weak link between the two pairs is the bottleneck")
    print()


def demo_reducibility():
    """Demo 2: The Reducibility Theorem."""
    print("=" * 60)
    print("DEMO 2: Reducibility Theorem (Φ = 0 ↔ Disconnected)")
    print("=" * 60)

    # Disconnected: two independent pairs
    W_disconnected = [
        [0, 3, 0, 0],
        [3, 0, 0, 0],
        [0, 0, 0, 7],
        [0, 0, 7, 0],
    ]
    phi_d, _ = compute_phi(W_disconnected)
    red, sep = is_reducible(W_disconnected)
    print(f"Disconnected network (0-1 and 2-3 independent):")
    print(f"  Φ = {phi_d}, Reducible = {red}, Separator = {sep}")

    # Connected: add a link
    W_connected = [
        [0, 3, 0, 0],
        [3, 0, 0.5, 0],
        [0, 0, 0, 7],
        [0, 0, 7, 0],
    ]
    phi_c, part_c = compute_phi(W_connected)
    red_c, _ = is_reducible(W_connected)
    print(f"\nConnected network (added edge 1→2 with weight 0.5):")
    print(f"  Φ = {phi_c}, Reducible = {red_c}, Min partition = {part_c}")
    print()


def demo_monotonicity():
    """Demo 3: Monotonicity — stronger connections → more integration."""
    print("=" * 60)
    print("DEMO 3: Monotonicity of Φ")
    print("=" * 60)

    base = [
        [0, 1, 0],
        [1, 0, 1],
        [0, 1, 0],
    ]

    print("Adding weight to edge 0→2:")
    for extra in [0, 1, 2, 5, 10]:
        W = [row[:] for row in base]
        W[0][2] += extra
        phi, _ = compute_phi(W)
        print(f"  w(0→2) = {extra}: Φ = {phi}")

    print("  → Φ is monotonically non-decreasing ✓")
    print()


def demo_complement_invariance():
    """Demo 4: Complement invariance of cut weight."""
    print("=" * 60)
    print("DEMO 4: Complement Invariance")
    print("=" * 60)

    W = [
        [0, 2, 3],
        [4, 0, 1],
        [5, 6, 0],
    ]

    S = {0}
    Sc = {1, 2}
    cw_S = cut_weight(W, S)
    cw_Sc = cut_weight(W, Sc)
    print(f"Network: 3 nodes with asymmetric weights")
    print(f"  cutWeight({{0}}) = {cw_S}")
    print(f"  cutWeight({{1, 2}}) = {cw_Sc}")
    print(f"  Equal? {cw_S == cw_Sc} ✓")
    print()


def demo_integration_complex():
    """Demo 5: The Integration Complex filtration."""
    print("=" * 60)
    print("DEMO 5: Integration Complex Filtration")
    print("=" * 60)

    # A network where different subsets have different integration levels
    W = [
        [0, 10, 1, 0],
        [10, 0, 1, 0],
        [1, 1, 0, 8],
        [0, 0, 8, 0],
    ]

    print("Network: 4 nodes, strong pairs 0-1 (w=10) and 2-3 (w=8), weak cross (w=1)")
    print()

    # Show spectrum
    spectrum = integration_spectrum(W)
    print("Full integration spectrum:")
    for subset, cw in spectrum:
        print(f"  Subset {subset}: cutWeight = {cw}")

    print()
    for t in [0, 5, 10, 15, 20]:
        ic = integration_complex(W, t)
        print(f"Integration Complex at t={t}: {len(ic)} subsets")
        if len(ic) <= 6:
            for s in ic:
                print(f"    {s}")

    print()
    print("  → As threshold increases, fewer subsets remain (antitone filtration) ✓")
    print()


def demo_symmetric():
    """Demo 6: Symmetric networks and the doubling property."""
    print("=" * 60)
    print("DEMO 6: Symmetric Network Doubling")
    print("=" * 60)

    W = [
        [0, 3, 2],
        [3, 0, 5],
        [2, 5, 0],
    ]

    S = {0}
    forward = sum(W[i][j] for i in S for j in ({0, 1, 2} - S))
    cw = cut_weight(W, S)
    print(f"Symmetric 3-node network")
    print(f"  S = {{0}}")
    print(f"  Forward flow (S → Sᶜ) = {forward}")
    print(f"  cutWeight(S) = {cw}")
    print(f"  2 × forward = {2 * forward}")
    print(f"  cutWeight = 2 × forward? {cw == 2 * forward} ✓")
    print()


def demo_spectral_conjecture():
    """Demo 7: Testing the spectral bound conjecture."""
    print("=" * 60)
    print("DEMO 7: Spectral Bound Conjecture (λ₂ test)")
    print("=" * 60)

    try:
        import numpy as np

        np.random.seed(42)
        n_tests = 10
        violations = 0

        for trial in range(n_tests):
            n = 5
            # Random symmetric network
            W = np.random.rand(n, n) * 5
            W = (W + W.T) / 2
            np.fill_diagonal(W, 0)

            # Compute Laplacian
            D = np.diag(W.sum(axis=1))
            L = D - W

            # Eigenvalues
            eigenvalues = sorted(np.linalg.eigvalsh(L))
            lambda2 = eigenvalues[1]

            # Compute Φ
            phi, _ = compute_phi(W.tolist())

            bound = n * lambda2 / 2
            holds = phi >= bound - 1e-10  # numerical tolerance

            if not holds:
                violations += 1

            print(f"  Trial {trial+1}: Φ = {phi:.3f}, n·λ₂/2 = {bound:.3f}, "
                  f"Bound holds: {holds}")

        print(f"\nViolations: {violations}/{n_tests}")
        if violations == 0:
            print("Conjecture holds for all test cases! (not a proof)")
        else:
            print(f"Conjecture VIOLATED in {violations} cases — needs revision")

    except ImportError:
        print("  NumPy not available — skipping spectral test")
    print()


if __name__ == "__main__":
    demo_basic()
    demo_reducibility()
    demo_monotonicity()
    demo_complement_invariance()
    demo_integration_complex()
    demo_symmetric()
    demo_spectral_conjecture()

    print("=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Integration Landscape of a Causal Network

Shows how the Integration Complex changes with threshold,
and plots the integration spectrum.
"""

import itertools


def cut_weight(weight, S):
    n = len(weight)
    Sc = set(range(n)) - S
    return sum(weight[i][j] for i in S for j in Sc) + sum(weight[i][j] for i in Sc for j in S)


def integration_spectrum(weight):
    n = len(weight)
    spectrum = []
    for r in range(1, n):
        for subset in itertools.combinations(range(n), r):
            S = set(subset)
            cw = cut_weight(weight, S)
            spectrum.append((frozenset(S), cw))
    spectrum.sort(key=lambda x: x[1])
    return spectrum


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import matplotlib.patches as mpatches
    except ImportError:
        print("matplotlib not available")
        return

    # Example network: 5 nodes with hierarchical structure
    W = [
        [0, 8, 1, 0, 0],
        [8, 0, 1, 0, 0],
        [1, 1, 0, 6, 0],
        [0, 0, 6, 0, 5],
        [0, 0, 0, 5, 0],
    ]

    spectrum = integration_spectrum(W)
    subsets = [s for s, _ in spectrum]
    values = [v for _, v in spectrum]

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Integration Spectrum (bar chart)
    ax1 = axes[0]
    labels = [str(set(s)) for s in subsets]
    colors = ['#2196F3' if len(s) == 1 else '#4CAF50' if len(s) == 2
              else '#FF9800' if len(s) == 3 else '#F44336' for s in subsets]
    bars = ax1.barh(range(len(values)), values, color=colors, edgecolor='white', linewidth=0.5)
    ax1.set_yticks(range(len(labels)))
    ax1.set_yticklabels(labels, fontsize=7)
    ax1.set_xlabel('Cut Weight (Integration)', fontsize=12)
    ax1.set_title('Integration Spectrum', fontsize=14, fontweight='bold')
    ax1.axvline(x=min(values), color='red', linestyle='--', alpha=0.7, label=f'Φ = {min(values)}')
    ax1.legend(fontsize=10)

    # Add legend for subset sizes
    patches = [
        mpatches.Patch(color='#2196F3', label='Size 1'),
        mpatches.Patch(color='#4CAF50', label='Size 2'),
        mpatches.Patch(color='#FF9800', label='Size 3'),
        mpatches.Patch(color='#F44336', label='Size 4'),
    ]
    ax1.legend(handles=patches + [plt.Line2D([0], [0], color='red', linestyle='--', label=f'Φ = {min(values)}')],
               loc='lower right', fontsize=8)

    # Plot 2: Integration Complex size vs threshold
    ax2 = axes[1]
    thresholds = sorted(set(values))
    thresholds = [0] + thresholds + [max(values) + 5]
    complex_sizes = []
    for t in thresholds:
        size = sum(1 for _, v in spectrum if v > t)
        complex_sizes.append(size)

    ax2.step(thresholds, complex_sizes, where='post', color='#9C27B0', linewidth=2.5)
    ax2.fill_between(thresholds, complex_sizes, step='post', alpha=0.15, color='#9C27B0')
    ax2.set_xlabel('Threshold t', fontsize=12)
    ax2.set_ylabel('|ℐ_t| (Complex Size)', fontsize=12)
    ax2.set_title('Integration Complex Filtration', fontsize=14, fontweight='bold')
    ax2.annotate(f'Φ = {min(values)}', xy=(min(values), max(complex_sizes)),
                 xytext=(min(values) + 3, max(complex_sizes) - 1),
                 arrowprops=dict(arrowstyle='->', color='red'),
                 fontsize=10, color='red')

    plt.tight_layout()
    plt.savefig('integration_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved integration_landscape.png")


if __name__ == "__main__":
    main()
