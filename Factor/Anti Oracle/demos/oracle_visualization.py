#!/usr/bin/env python3
"""
Oracle Theory Visualizations

Creates publication-quality figures for the oracle theory research paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from matplotlib.patches import FancyBboxPatch


def create_oracle_lattice_diagram():
    """Create a Hasse diagram of the oracle Boolean algebra."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))

    # Node positions for a Boolean algebra on 3 generators
    positions = {
        '⊥ (∅)': (5, 0),
        '{a}': (1, 2), '{b}': (5, 2), '{c}': (9, 2),
        '{a,b}': (1, 4), '{a,c}': (5, 4), '{b,c}': (9, 4),
        '⊤ (U)': (5, 6),
    }

    # Edges (Hasse diagram)
    edges = [
        ('⊥ (∅)', '{a}'), ('⊥ (∅)', '{b}'), ('⊥ (∅)', '{c}'),
        ('{a}', '{a,b}'), ('{a}', '{a,c}'),
        ('{b}', '{a,b}'), ('{b}', '{b,c}'),
        ('{c}', '{a,c}'), ('{c}', '{b,c}'),
        ('{a,b}', '⊤ (U)'), ('{a,c}', '⊤ (U)'), ('{b,c}', '⊤ (U)'),
    ]

    # Draw edges
    for e1, e2 in edges:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=1.5, alpha=0.4)

    # Draw anti-oracle pairings (dashed)
    anti_pairs = [
        ('⊥ (∅)', '⊤ (U)'),
        ('{a}', '{b,c}'),
        ('{b}', '{a,c}'),
        ('{c}', '{a,b}'),
    ]

    for e1, e2 in anti_pairs:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                    arrowprops=dict(arrowstyle='<->', color='red',
                                    linestyle='dashed', linewidth=2, alpha=0.6))

    # Draw nodes
    for label, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.4, color='steelblue', alpha=0.8, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
                fontweight='bold', color='white', zorder=6)

    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.set_title('Oracle Boolean Algebra (Hasse Diagram)\n'
                 'Red dashed arrows = anti-oracle pairings',
                 fontsize=14, fontweight='bold')
    ax.axis('off')

    # Legend
    normal_line = mpatches.Patch(color='gray', alpha=0.4, label='Lattice order (⊆)')
    anti_line = mpatches.Patch(color='red', alpha=0.6, label='Anti-oracle pairing')
    ax.legend(handles=[normal_line, anti_line], loc='lower right', fontsize=11)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/oracle_lattice.png', dpi=150)
    print("Saved: oracle_lattice.png")


def create_anti_oracle_symmetry():
    """Visualize the symmetry between an oracle and its anti-oracle."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    universe = set(range(20))
    carrier = {2, 3, 5, 7, 11, 13, 17, 19}  # Primes < 20
    anti_carrier = universe - carrier

    # Oracle
    ax = axes[0]
    colors = ['steelblue' if x in carrier else 'lightgray' for x in range(20)]
    bars = ax.bar(range(20), [1]*20, color=colors, edgecolor='white', linewidth=0.5)
    ax.set_title('Oracle O\n(PRIMES < 20)', fontsize=13, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_yticks([])
    ax.set_xticks(range(0, 20, 2))

    # Anti-Oracle
    ax = axes[1]
    colors = ['crimson' if x in anti_carrier else 'lightgray' for x in range(20)]
    bars = ax.bar(range(20), [1]*20, color=colors, edgecolor='white', linewidth=0.5)
    ax.set_title('Anti-Oracle anti(O)\n(NON-PRIMES < 20)', fontsize=13, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_yticks([])
    ax.set_xticks(range(0, 20, 2))

    # XOR = Universal
    ax = axes[2]
    colors = ['gold' for x in range(20)]
    bars = ax.bar(range(20), [1]*20, color=colors, edgecolor='white', linewidth=0.5)
    ax.set_title('O ⊕ anti(O) = ⊤\n(UNIVERSAL)', fontsize=13, fontweight='bold')
    ax.set_xlabel('Element')
    ax.set_yticks([])
    ax.set_xticks(range(0, 20, 2))

    plt.suptitle('Anti-Oracle Symmetry: O and anti(O) are perfect complements',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/anti_oracle_symmetry.png', dpi=150,
                bbox_inches='tight')
    print("Saved: anti_oracle_symmetry.png")


def create_inverse_oracle_diagram():
    """Visualize the inverse oracle as preimage computation."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Bijective case
    ax = axes[0]
    np.random.seed(42)

    domain = list(range(8))
    codomain_bij = [(3*x + 1) % 8 for x in domain]

    # Draw domain points
    for i, x in enumerate(domain):
        ax.plot(0.5, 7-i, 'o', color='steelblue', markersize=15, zorder=5)
        ax.text(0.5, 7-i, str(x), ha='center', va='center', color='white',
                fontweight='bold', fontsize=10, zorder=6)

    # Draw codomain points
    for i, y in enumerate(sorted(set(codomain_bij))):
        ax.plot(3.5, 7-i, 'o', color='crimson', markersize=15, zorder=5)
        ax.text(3.5, 7-i, str(y), ha='center', va='center', color='white',
                fontweight='bold', fontsize=10, zorder=6)

    # Draw arrows
    for i, (x, y) in enumerate(zip(domain, codomain_bij)):
        y_pos_domain = 7 - x
        y_pos_codomain = 7 - y
        ax.annotate('', xy=(3.2, y_pos_codomain), xytext=(0.8, y_pos_domain),
                    arrowprops=dict(arrowstyle='->', color='green', linewidth=1.5, alpha=0.6))

    ax.set_title('Bijective f: unique inverse\n'
                 'f(x) = (3x+1) mod 8', fontsize=12, fontweight='bold')
    ax.text(0.5, -0.5, 'Domain', ha='center', fontsize=11)
    ax.text(3.5, -0.5, 'Codomain', ha='center', fontsize=11)
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-1.5, 8)
    ax.axis('off')

    # Non-injective case
    ax = axes[1]
    domain2 = list(range(8))
    codomain_hash = [(x*x) % 7 for x in domain2]

    # Draw domain points
    for i, x in enumerate(domain2):
        ax.plot(0.5, 7-i, 'o', color='steelblue', markersize=15, zorder=5)
        ax.text(0.5, 7-i, str(x), ha='center', va='center', color='white',
                fontweight='bold', fontsize=10, zorder=6)

    # Draw codomain points
    unique_codomain = sorted(set(codomain_hash))
    for i, y in enumerate(unique_codomain):
        y_pos = 7 - i * (7 / max(len(unique_codomain)-1, 1))
        ax.plot(3.5, y_pos, 'o', color='crimson', markersize=15, zorder=5)
        ax.text(3.5, y_pos, str(y), ha='center', va='center', color='white',
                fontweight='bold', fontsize=10, zorder=6)

    # Draw arrows
    for x in domain2:
        y = codomain_hash[x]
        y_pos_domain = 7 - x
        idx = unique_codomain.index(y)
        y_pos_codomain = 7 - idx * (7 / max(len(unique_codomain)-1, 1))
        ax.annotate('', xy=(3.2, y_pos_codomain), xytext=(0.8, y_pos_domain),
                    arrowprops=dict(arrowstyle='->', color='orange', linewidth=1.5, alpha=0.6))

    ax.set_title('Non-injective f: set-valued inverse\n'
                 'f(x) = x² mod 7', fontsize=12, fontweight='bold')
    ax.text(0.5, -0.5, 'Domain', ha='center', fontsize=11)
    ax.text(3.5, -0.5, 'Codomain', ha='center', fontsize=11)
    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-1.5, 8)
    ax.axis('off')

    plt.suptitle('Inverse Oracle: Preimage Computation',
                 fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/inverse_oracle_diagram.png', dpi=150)
    print("Saved: inverse_oracle_diagram.png")


def create_oracle_composition_diagram():
    """Visualize how oracles compose: pullback and pushforward."""
    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Three levels: α, β, γ
    levels = {'α': 1, 'β': 5, 'γ': 9}

    for name, x in levels.items():
        box = FancyBboxPatch((x-0.8, 1), 1.6, 4,
                              boxstyle="round,pad=0.1",
                              facecolor='lightyellow', edgecolor='black',
                              linewidth=2)
        ax.add_patch(box)
        ax.text(x, 5.5, f'Type {name}', ha='center', fontsize=13, fontweight='bold')

    # Points in each type
    for i in range(4):
        ax.plot(1, 1.5 + i, 'o', color='steelblue', markersize=12)
        ax.text(0.5, 1.5 + i, f'a{i}', fontsize=9)

    for i in range(3):
        ax.plot(5, 1.8 + i*1.2, 'o', color='green', markersize=12)
        ax.text(4.5, 1.8 + i*1.2, f'b{i}', fontsize=9)

    for i in range(2):
        ax.plot(9, 2.2 + i*1.6, 'o', color='crimson', markersize=12)
        ax.text(9.5, 2.2 + i*1.6, f'c{i}', fontsize=9)

    # Arrows for functions
    ax.annotate('', xy=(4.7, 3), xytext=(1.3, 3),
                arrowprops=dict(arrowstyle='->', color='blue', linewidth=2.5))
    ax.text(3, 3.5, 'f : α → β', ha='center', fontsize=11, color='blue', fontweight='bold')

    ax.annotate('', xy=(8.7, 3), xytext=(5.3, 3),
                arrowprops=dict(arrowstyle='->', color='darkgreen', linewidth=2.5))
    ax.text(7, 3.5, 'g : β → γ', ha='center', fontsize=11, color='darkgreen', fontweight='bold')

    # Pullback arrow
    ax.annotate('', xy=(1.3, 1), xytext=(8.7, 1),
                arrowprops=dict(arrowstyle='<-', color='red', linewidth=2,
                                linestyle='dashed'))
    ax.text(5, 0.4, 'pullback(O, g∘f) = pullback(pullback(O, g), f)',
            ha='center', fontsize=10, color='red', fontweight='bold',
            style='italic')

    ax.set_xlim(-1, 11)
    ax.set_ylim(-0.5, 6.5)
    ax.axis('off')
    ax.set_title('Oracle Pullback Functoriality\n'
                 'Pullback is contravariant: reverses composition',
                 fontsize=14, fontweight='bold')

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/oracle_composition.png', dpi=150)
    print("Saved: oracle_composition.png")


def create_information_entropy_plot():
    """Plot the information content of oracles vs carrier size."""
    fig, ax = plt.subplots(1, 1, figsize=(10, 6))

    n_universe = 100
    carrier_sizes = np.arange(0, n_universe + 1)
    p = carrier_sizes / n_universe

    # Binary entropy
    entropy = np.zeros_like(p, dtype=float)
    mask = (p > 0) & (p < 1)
    entropy[mask] = -p[mask] * np.log2(p[mask]) - (1-p[mask]) * np.log2(1-p[mask])

    ax.plot(carrier_sizes, entropy, 'b-', linewidth=2.5, label='H(O)')
    ax.fill_between(carrier_sizes, entropy, alpha=0.1, color='blue')

    # Mark special points
    ax.axvline(x=50, color='red', linestyle='--', alpha=0.5)
    ax.annotate('Maximum info\n(50/50 split)', xy=(50, 1.0), xytext=(65, 0.8),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
                color='red', fontweight='bold')

    # Mark anti-oracle symmetry
    for size in [20, 80]:
        p_val = size / n_universe
        h_val = -p_val * np.log2(p_val) - (1-p_val) * np.log2(1-p_val)
        ax.plot(size, h_val, 'ro', markersize=10, zorder=5)

    ax.annotate('O and anti(O)\nhave equal entropy',
                xy=(80, 0.72), xytext=(85, 0.5),
                fontsize=10, arrowprops=dict(arrowstyle='->', color='darkred'),
                color='darkred')

    ax.plot([20, 80], [0.72, 0.72], 'r--', linewidth=1.5, alpha=0.5)

    ax.set_xlabel('|carrier(O)|', fontsize=13)
    ax.set_ylabel('Binary Entropy H(O)', fontsize=13)
    ax.set_title('Oracle Information Content vs Carrier Size\n'
                 'Anti-oracle pairs have identical information',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=12)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/oracle_entropy.png', dpi=150)
    print("Saved: oracle_entropy.png")


def main():
    print("Generating Oracle Theory Visualizations...")
    create_oracle_lattice_diagram()
    create_anti_oracle_symmetry()
    create_inverse_oracle_diagram()
    create_oracle_composition_diagram()
    create_information_entropy_plot()
    print("\nAll visualizations generated!")


if __name__ == "__main__":
    main()
