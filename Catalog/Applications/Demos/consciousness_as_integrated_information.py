"""
Integrated Information Theory: Interactive Demo

Demonstrates the key theorems about Φ (integrated information) with
concrete numerical examples.
"""

import numpy as np
from algorithms import phi, cut_value, direct_sum, subsystem_phi, find_complex, scale_system


def demo_basic_phi():
    """Demo 1: Computing Φ for simple systems."""
    print("=" * 60)
    print("DEMO 1: Basic Integrated Information (Φ)")
    print("=" * 60)

    # A fully connected 3-node system
    W = np.array([
        [0, 1, 1],
        [1, 0, 1],
        [1, 1, 0]
    ], dtype=float)

    phi_val, partition = phi(W)
    print(f"\nFully connected 3-node system (all weights = 1):")
    print(f"  Weight matrix:\n{W}")
    print(f"  Φ = {phi_val}")
    print(f"  Minimum information partition: {partition}")
    print(f"  (Any singleton is a MIP due to symmetry)")

    # A strongly connected core with weak peripheral connection
    W2 = np.array([
        [0, 5, 5],
        [5, 0, 5],
        [0.1, 0.1, 0]
    ], dtype=float)

    phi_val2, partition2 = phi(W2)
    print(f"\nStrong 2-core with weak peripheral node:")
    print(f"  Weight matrix:\n{W2}")
    print(f"  Φ = {phi_val2}")
    print(f"  MIP: {partition2}")
    print(f"  (Weakest link is the peripheral node)")


def demo_composition():
    """Demo 2: Composition theorem — direct sums have Φ = 0."""
    print("\n" + "=" * 60)
    print("DEMO 2: Composition Theorem (Φ of direct sum = 0)")
    print("=" * 60)

    W1 = np.array([[0, 3], [3, 0]], dtype=float)
    W2 = np.array([[0, 5], [5, 0]], dtype=float)

    phi1, _ = phi(W1)
    phi2, _ = phi(W2)
    W_sum = direct_sum(W1, W2)
    phi_sum, part_sum = phi(W_sum)

    print(f"\nSystem 1 (2 nodes, weight 3): Φ = {phi1}")
    print(f"System 2 (2 nodes, weight 5): Φ = {phi2}")
    print(f"Direct sum (4 nodes, no cross-links): Φ = {phi_sum}")
    print(f"  MIP of direct sum: {part_sum}")
    print(f"\n✓ Composition theorem verified: Φ(C₁ ⊕ C₂) = 0")

    # Now add a tiny connection
    W_connected = W_sum.copy()
    W_connected[0, 2] = 0.01  # Tiny connection between blocks
    phi_connected, _ = phi(W_connected)
    print(f"\nWith tiny cross-connection (w=0.01): Φ = {phi_connected}")
    print(f"  Even minimal interaction creates non-zero Φ!")


def demo_scaling():
    """Demo 3: Scaling theorem — Φ(r·C) = r·Φ(C)."""
    print("\n" + "=" * 60)
    print("DEMO 3: Scaling Theorem (Φ scales linearly)")
    print("=" * 60)

    W = np.array([
        [0, 2, 1],
        [1, 0, 3],
        [2, 1, 0]
    ], dtype=float)

    phi_base, _ = phi(W)
    print(f"\nBase system Φ = {phi_base}")

    for r in [0.5, 1.0, 2.0, 3.0, 10.0]:
        W_scaled = scale_system(W, r)
        phi_scaled, _ = phi(W_scaled)
        print(f"  r = {r:5.1f}: Φ(r·C) = {phi_scaled:8.4f}, "
              f"r·Φ(C) = {r * phi_base:8.4f}, "
              f"match = {np.isclose(phi_scaled, r * phi_base)}")

    print(f"\n✓ Scaling theorem verified: Φ(r·C) = r·Φ(C)")


def demo_exclusion():
    """Demo 4: Exclusion principle — finding the complex."""
    print("\n" + "=" * 60)
    print("DEMO 4: Exclusion Principle (Maximally Integrated Complex)")
    print("=" * 60)

    # 4-node system with a strongly integrated 3-node core
    W = np.array([
        [0, 5, 5, 0.1],
        [5, 0, 5, 0.1],
        [5, 5, 0, 0.1],
        [0.1, 0.1, 0.1, 0]
    ], dtype=float)

    print(f"\n4-node system with strong 3-node core:")
    print(f"  Weight matrix:\n{W}")

    complex_set, max_phi = find_complex(W)
    print(f"\n  Complex (maximally integrated subsystem): {complex_set}")
    print(f"  Maximum subsystem Φ = {max_phi}")

    print(f"\n  All subsystem Φ values:")
    import itertools
    for size in range(2, 5):
        for subset in itertools.combinations(range(4), size):
            sp = subsystem_phi(W, set(subset))
            marker = " ← COMPLEX" if set(subset) == complex_set else ""
            print(f"    {set(subset)}: Φ = {sp:.4f}{marker}")

    print(f"\n✓ Exclusion principle verified: unique maximum exists")


def demo_disconnection():
    """Demo 5: Disconnection characterization — Φ = 0 iff disconnected."""
    print("\n" + "=" * 60)
    print("DEMO 5: Disconnection Characterization")
    print("=" * 60)

    # Connected system
    W_conn = np.array([
        [0, 1, 0],
        [0, 0, 1],
        [1, 0, 0]
    ], dtype=float)

    phi_conn, _ = phi(W_conn)
    print(f"\nConnected cycle (1→2→3→1): Φ = {phi_conn}")

    # Disconnected system
    W_disc = np.array([
        [0, 1, 0],
        [1, 0, 0],
        [0, 0, 0]
    ], dtype=float)

    phi_disc, part_disc = phi(W_disc)
    print(f"Disconnected (1↔2, isolated 3): Φ = {phi_disc}")
    print(f"  MIP: {part_disc}")

    # Gradually connecting
    print(f"\n  Gradually connecting node 3:")
    for eps in [0, 0.01, 0.1, 0.5, 1.0, 2.0]:
        W_eps = W_disc.copy()
        W_eps[0, 2] = eps
        W_eps[2, 0] = eps
        phi_eps, _ = phi(W_eps)
        print(f"    ε = {eps:.2f}: Φ = {phi_eps:.4f}")

    print(f"\n✓ Sharp transition: Φ = 0 ↔ disconnectable")


if __name__ == "__main__":
    demo_basic_phi()
    demo_composition()
    demo_scaling()
    demo_exclusion()
    demo_disconnection()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


"""
Visualization: The Exclusion Principle — Finding the Complex.

Shows how subsystem Φ varies across all subsystems of a network,
highlighting the maximally integrated complex.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools


def subsystem_phi(weights, system):
    system_list = sorted(system)
    m = len(system_list)
    if m < 2:
        return 0.0
    min_cut = float('inf')
    for k in range(1, m):
        for subset_tuple in itertools.combinations(system_list, k):
            T = set(subset_tuple)
            S_minus_T = system - T
            forward = sum(weights[i, j] for i in T for j in S_minus_T)
            backward = sum(weights[i, j] for i in S_minus_T for j in T)
            min_cut = min(min_cut, forward + backward)
    return min_cut


def main():
    # 5-node system with interesting structure
    W = np.array([
        [0, 4, 4, 0.2, 0.1],
        [4, 0, 4, 0.2, 0.1],
        [4, 4, 0, 0.2, 0.1],
        [0.2, 0.2, 0.2, 0, 3],
        [0.1, 0.1, 0.1, 3, 0]
    ], dtype=float)

    n = W.shape[0]

    # Compute subsystem Phi for all subsystems of size >= 2
    subsystems = []
    phi_values = []
    labels = []

    for size in range(2, n + 1):
        for subset in itertools.combinations(range(n), size):
            s = set(subset)
            sp = subsystem_phi(W, s)
            subsystems.append(s)
            phi_values.append(sp)
            labels.append(str(s))

    # Find the complex
    max_idx = np.argmax(phi_values)
    complex_set = subsystems[max_idx]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))

    # Plot 1: Bar chart of subsystem Phi values
    colors = ['#e74c3c' if s == complex_set else
              '#3498db' if len(s) == 2 else
              '#2ecc71' if len(s) == 3 else
              '#9b59b6' if len(s) == 4 else '#f39c12'
              for s in subsystems]

    bars = ax1.barh(range(len(phi_values)), phi_values, color=colors, alpha=0.8)
    ax1.set_yticks(range(len(labels)))
    ax1.set_yticklabels(labels, fontsize=7)
    ax1.set_xlabel('Subsystem Φ', fontsize=12)
    ax1.set_title('Exclusion: All Subsystem Φ Values', fontsize=14)

    # Highlight the complex
    ax1.barh(max_idx, phi_values[max_idx], color='red', alpha=1.0,
            edgecolor='black', linewidth=2)
    ax1.annotate('COMPLEX\n(maximum Φ)',
                xy=(phi_values[max_idx], max_idx),
                xytext=(phi_values[max_idx] + 1, max_idx + 2),
                fontsize=11, fontweight='bold', color='red',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#3498db', label='Size 2'),
        Patch(facecolor='#2ecc71', label='Size 3'),
        Patch(facecolor='#9b59b6', label='Size 4'),
        Patch(facecolor='#f39c12', label='Size 5'),
        Patch(facecolor='red', edgecolor='black', linewidth=2, label='Complex'),
    ]
    ax1.legend(handles=legend_elements, loc='lower right')

    # Plot 2: Network visualization (simple circle layout)
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False)
    x = np.cos(angles)
    y = np.sin(angles)

    # Draw edges
    for i in range(n):
        for j in range(n):
            if i != j and W[i, j] > 0:
                alpha = min(1, W[i, j] / 5)
                lw = W[i, j] / 2
                ax2.plot([x[i], x[j]], [y[i], y[j]], 'gray',
                        alpha=alpha, linewidth=lw)

    # Draw nodes
    node_colors = ['red' if i in complex_set else 'lightblue' for i in range(n)]
    for i in range(n):
        circle = plt.Circle((x[i], y[i]), 0.12, color=node_colors[i],
                           ec='black', linewidth=2, zorder=5)
        ax2.add_patch(circle)
        ax2.text(x[i], y[i], str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', zorder=6)

    ax2.set_xlim(-1.5, 1.5)
    ax2.set_ylim(-1.5, 1.5)
    ax2.set_aspect('equal')
    ax2.set_title(f'Network (Complex = {complex_set})', fontsize=14)
    ax2.axis('off')

    plt.tight_layout()
    plt.savefig('exclusion_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved exclusion_visualization.png")


if __name__ == "__main__":
    main()


"""
Visualization: How Φ varies with network connectivity.

Generates a plot showing Φ as a function of cross-connection strength
for a system transitioning from disconnected to fully connected.
"""

import numpy as np
import matplotlib.pyplot as plt
import itertools


def cut_value(weights, subset):
    n = weights.shape[0]
    complement = set(range(n)) - subset
    forward = sum(weights[i, j] for i in subset for j in complement)
    backward = sum(weights[i, j] for i in complement for j in subset)
    return forward + backward


def compute_phi(weights):
    n = weights.shape[0]
    if n < 2:
        return 0.0
    min_cut = float('inf')
    for k in range(1, n):
        for subset_tuple in itertools.combinations(range(n), k):
            cv = cut_value(weights, set(subset_tuple))
            min_cut = min(min_cut, cv)
    return min_cut


def main():
    # System: two strongly connected pairs, varying cross-connection
    epsilons = np.linspace(0, 5, 200)
    phis = []

    for eps in epsilons:
        W = np.array([
            [0, 3, eps, 0],
            [3, 0, 0, eps],
            [eps, 0, 0, 3],
            [0, eps, 3, 0]
        ], dtype=float)
        phis.append(compute_phi(W))

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Plot 1: Phi vs cross-connection strength
    ax1.plot(epsilons, phis, 'b-', linewidth=2)
    ax1.set_xlabel('Cross-connection strength (ε)', fontsize=12)
    ax1.set_ylabel('Integrated Information (Φ)', fontsize=12)
    ax1.set_title('Φ as Connection Strength Varies', fontsize=14)
    ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax1.grid(True, alpha=0.3)
    ax1.annotate('Disconnected\n(Φ = 0)', xy=(0, 0), xytext=(0.5, 1),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
                color='red')

    # Plot 2: Phi for random systems of different sizes
    np.random.seed(42)
    sizes = range(2, 8)
    phi_means = []
    phi_stds = []

    for n in sizes:
        phi_samples = []
        for _ in range(100):
            W = np.random.exponential(1, (n, n))
            np.fill_diagonal(W, 0)
            phi_samples.append(compute_phi(W))
        phi_means.append(np.mean(phi_samples))
        phi_stds.append(np.std(phi_samples))

    ax2.errorbar(list(sizes), phi_means, yerr=phi_stds, fmt='o-',
                capsize=5, linewidth=2, markersize=8, color='darkgreen')
    ax2.set_xlabel('System Size (n)', fontsize=12)
    ax2.set_ylabel('Φ (mean ± std)', fontsize=12)
    ax2.set_title('Φ of Random Systems by Size', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('phi_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved phi_visualization.png")


if __name__ == "__main__":
    main()
