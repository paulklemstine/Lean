#!/usr/bin/env python3
"""
Zombies and Qualia: Numerical Demonstrations

Demonstrates the mathematical framework for the hard problem of consciousness:
- Zombie multiplicity (exponential growth of indistinguishable variants)
- Qualia complexity spectrum
- Phase transition thresholds
- Explanation gap structure
"""

import math
from typing import List, Tuple, Dict

def zombie_count(n_states: int, n_qualia_values: int) -> int:
    """Number of zombie variants: |Q|^|S| functionally identical systems."""
    return n_qualia_values ** n_states

def qualia_complexity(assignment: List[int]) -> int:
    """Number of distinct qualia values in an assignment."""
    return len(set(assignment))

def phase_transition_point(complexities: List[float], threshold: float) -> int:
    """Find the first index where complexity exceeds the threshold."""
    for i, c in enumerate(complexities):
        if c > threshold:
            return i
    return -1

def explanation_gap_size(functional_props: set, experiential_props: set) -> int:
    """Size of the explanation gap: |experiential \\ functional|."""
    return len(experiential_props - functional_props)


def main():
    print("=" * 60)
    print("ZOMBIES AND QUALIA: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)

    # Demo 1: Zombie Multiplicity
    print("\n--- Demo 1: Zombie Multiplicity ---")
    print("For a system with n states, the number of functionally")
    print("identical 'zombie variants' with k qualia values is k^n.\n")
    for n in range(1, 8):
        bool_zombies = zombie_count(n, 2)
        prop_zombies = zombie_count(n, 3)
        print(f"  n={n}: Bool-zombies = 2^{n} = {bool_zombies:>6}, "
              f"3-zombies = 3^{n} = {prop_zombies:>6}")

    # Demo 2: Qualia Complexity Spectrum
    print("\n--- Demo 2: Qualia Complexity Spectrum ---")
    print("For Fin 5, example qualia assignments and their complexities:\n")
    examples = [
        ([0, 0, 0, 0, 0], "Trivial (zombie)"),
        ([0, 1, 0, 1, 0], "Binary"),
        ([0, 1, 2, 0, 1], "Ternary"),
        ([0, 1, 2, 3, 4], "Maximal (identity)"),
    ]
    for assignment, label in examples:
        c = qualia_complexity(assignment)
        print(f"  {assignment} → complexity={c} ({label})")

    # Demo 3: Phase Transition
    print("\n--- Demo 3: Consciousness Phase Transition ---")
    print("Complexity function: f(n) = n*log(n+1)")
    print("Threshold: 5.0\n")
    complexities = [n * math.log(n + 1) for n in range(15)]
    threshold = 5.0
    n0 = phase_transition_point(complexities, threshold)
    for i, c in enumerate(complexities):
        marker = " ← TRANSITION" if i == n0 else ""
        status = "zombie" if c <= threshold else "conscious"
        print(f"  n={i:2d}: complexity={c:6.2f}  [{status}]{marker}")

    # Demo 4: Explanation Gap
    print("\n--- Demo 4: Explanation Gap Structure ---")
    functional = {"sees_red", "reports_red", "discriminates_wavelength"}
    experiential = functional | {"feels_redness", "has_color_experience",
                                  "subjective_warmth"}
    gap = experiential - functional
    print(f"  Functional properties:   {functional}")
    print(f"  Experiential properties: {experiential}")
    print(f"  Gap (unexplained):       {gap}")
    print(f"  Gap size: {len(gap)}")

    # Demo 5: Cantor Diagonal
    print("\n--- Demo 5: Self-Knowledge Limitation ---")
    print("For Fin n, there are n^n endomorphisms but only n states.")
    print("Surjection is impossible for n ≥ 2:\n")
    for n in range(2, 8):
        n_endo = n ** n
        print(f"  n={n}: states={n}, endomorphisms={n_endo}, "
              f"ratio={n_endo/n:.1f}x")

    # Demo 6: Gap Isomorphism
    print("\n--- Demo 6: Gap Isomorphism ---")
    print("Both gaps have the structure: accessible ⊊ full")
    print()
    print("  Consciousness Gap:")
    print("    accessible = functional descriptions")
    print("    full       = all facts about the system")
    print("    gap        = qualia (unexplained by function)")
    print()
    print("  Incompleteness Gap:")
    print("    accessible = provable sentences")
    print("    full       = true sentences")
    print("    gap        = true but unprovable (Gödel sentences)")
    print()
    print("  Both satisfy: accessible ⊆ full, (full \\ accessible) ≠ ∅")
    print("  → They are instances of the same AbstractGap structure.")

    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Zombie Multiplicity and Qualia Complexity

Standalone matplotlib visualization showing:
1. Exponential growth of zombie variants
2. Phase transition diagram
3. Qualia complexity bounds
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math

def plot_zombie_multiplicity():
    """Plot the exponential growth of zombie variants."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Zombie count vs states
    ax = axes[0]
    ns = np.arange(1, 12)
    for k in [2, 3, 5]:
        counts = [k**n for n in ns]
        ax.semilogy(ns, counts, 'o-', label=f'{k} qualia values', markersize=5)
    ax.set_xlabel('Number of States (n)', fontsize=12)
    ax.set_ylabel('Zombie Variants (k^n)', fontsize=12)
    ax.set_title('Zombie Multiplicity', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 2: Phase transition
    ax = axes[1]
    ns = np.arange(0, 20)
    complexities = [n * math.log(n + 1) for n in ns]
    threshold = 8.0
    colors = ['#e74c3c' if c <= threshold else '#2ecc71' for c in complexities]
    ax.bar(ns, complexities, color=colors, alpha=0.7, edgecolor='black', linewidth=0.5)
    ax.axhline(y=threshold, color='black', linestyle='--', linewidth=2,
               label=f'Threshold = {threshold}')
    n0 = next(i for i, c in enumerate(complexities) if c > threshold)
    ax.annotate(f'Transition at n={n0}', xy=(n0, complexities[n0]),
                xytext=(n0 + 3, complexities[n0] + 5),
                arrowprops=dict(arrowstyle='->', color='black'),
                fontsize=11, fontweight='bold')
    ax.set_xlabel('System Size (n)', fontsize=12)
    ax.set_ylabel('Complexity', fontsize=12)
    ax.set_title('Consciousness Phase Transition', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Qualia complexity bounds
    ax = axes[2]
    ns = np.arange(1, 15)
    max_complexity = ns  # identity qualia
    min_complexity = np.ones_like(ns)  # trivial qualia
    ax.fill_between(ns, min_complexity, max_complexity, alpha=0.3, color='blue',
                    label='Possible complexity range')
    ax.plot(ns, max_complexity, 'b-', linewidth=2, label='Max (identity qualia)')
    ax.plot(ns, min_complexity, 'r--', linewidth=2, label='Min (trivial/zombie)')
    ax.plot(ns, np.sqrt(ns), 'g-.', linewidth=2, label='√n (conjectured threshold)')
    ax.set_xlabel('Number of States (n)', fontsize=12)
    ax.set_ylabel('Qualia Complexity', fontsize=12)
    ax.set_title('Qualia Complexity Bounds', fontsize=14, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('zombie_qualia_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: zombie_qualia_visualization.png")


def plot_gap_structure():
    """Visualize the abstract gap structure."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Consciousness gap
    ax = axes[0]
    theta = np.linspace(0, 2*np.pi, 100)
    # Full circle (experiential)
    ax.fill(3*np.cos(theta), 3*np.sin(theta), alpha=0.2, color='purple',
            label='Experiential (full)')
    ax.plot(3*np.cos(theta), 3*np.sin(theta), 'purple', linewidth=2)
    # Inner circle (functional)
    ax.fill(2*np.cos(theta), 2*np.sin(theta), alpha=0.3, color='blue',
            label='Functional (accessible)')
    ax.plot(2*np.cos(theta), 2*np.sin(theta), 'blue', linewidth=2)
    # Gap annotation
    ax.annotate('GAP\n(qualia)', xy=(2.5, 0), fontsize=14,
                fontweight='bold', color='red', ha='center')
    ax.set_title('Consciousness Gap', fontsize=14, fontweight='bold')
    ax.legend(loc='lower left')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Incompleteness gap
    ax = axes[1]
    ax.fill(3*np.cos(theta), 3*np.sin(theta), alpha=0.2, color='orange',
            label='True sentences (full)')
    ax.plot(3*np.cos(theta), 3*np.sin(theta), 'orange', linewidth=2)
    ax.fill(2*np.cos(theta), 2*np.sin(theta), alpha=0.3, color='green',
            label='Provable sentences (accessible)')
    ax.plot(2*np.cos(theta), 2*np.sin(theta), 'green', linewidth=2)
    ax.annotate('GAP\n(Gödel)', xy=(2.5, 0), fontsize=14,
                fontweight='bold', color='red', ha='center')
    ax.set_title('Incompleteness Gap', fontsize=14, fontweight='bold')
    ax.legend(loc='lower left')
    ax.set_xlim(-4, 4)
    ax.set_ylim(-4, 4)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    fig.suptitle('Gap Isomorphism: Same Structure, Different Domains',
                 fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('gap_isomorphism.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: gap_isomorphism.png")


if __name__ == "__main__":
    plot_zombie_multiplicity()
    plot_gap_structure()
