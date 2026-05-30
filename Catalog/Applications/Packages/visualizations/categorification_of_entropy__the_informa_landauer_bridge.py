"""
Visualization: Landauer Bridge — Information Loss as Thermodynamic Cost

Shows the connection between functorial entropy and Landauer's principle:
the minimum energy dissipation of a computation equals kT * H(f), where
H(f) is the functorial entropy measuring information destruction.
"""

import math
import numpy as np
import matplotlib.pyplot as plt


def functorial_entropy_erasure(n_states, n_output):
    """
    H(f) for a function that maps n_states uniformly to n_output states.
    Each fiber has size n_states/n_output.
    H = log(n_states/n_output)
    """
    if n_output >= n_states or n_output == 0:
        return 0.0
    k = n_states / n_output
    return math.log(k)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    k_B = 1.380649e-23  # Boltzmann constant
    T = 300  # Room temperature
    kT = k_B * T
    
    # Panel 1: Landauer cost vs number of bits erased
    n_bits = np.arange(0, 11)
    n_states = 2 ** n_bits
    H_values = [math.log(2**b) if b > 0 else 0 for b in n_bits]
    costs_J = [kT * H for H in H_values]
    costs_eV = [c / 1.602e-19 for c in costs_J]
    
    ax1 = axes[0]
    color1 = '#2196F3'
    color2 = '#FF5722'
    
    ax1.bar(n_bits - 0.15, H_values, width=0.3, color=color1, alpha=0.8, label='H(f) (nats)')
    ax1_twin = ax1.twinx()
    ax1_twin.bar(n_bits + 0.15, [c * 1e21 for c in costs_J], width=0.3, 
                 color=color2, alpha=0.8, label='Cost (×10⁻²¹ J)')
    
    ax1.set_xlabel('Bits erased', fontsize=11)
    ax1.set_ylabel('Functorial entropy H(f)', fontsize=11, color=color1)
    ax1_twin.set_ylabel('Landauer cost (×10⁻²¹ J)', fontsize=11, color=color2)
    ax1.set_title('Landauer Cost of Bit Erasure\nat T = 300K', fontsize=12)
    ax1.set_xticks(n_bits)
    
    lines1, labels1 = ax1.get_legend_handles_labels()
    lines2, labels2 = ax1_twin.get_legend_handles_labels()
    ax1.legend(lines1 + lines2, labels1 + labels2, fontsize=9)
    
    # Panel 2: Phase diagram — reversible vs irreversible
    ax2 = axes[1]
    
    # Generate random functions Fin 8 → Fin 8 and classify
    np.random.seed(42)
    n = 8
    n_samples = 500
    
    entropies = []
    range_sizes = []
    
    for _ in range(n_samples):
        f = np.random.randint(0, n, size=n)
        from collections import Counter
        fibers = Counter(f)
        H = sum((c / n) * math.log(c) for c in fibers.values() if c > 0)
        rs = len(set(f))
        entropies.append(H)
        range_sizes.append(rs)
    
    # Add all permutations (bijective = reversible)
    for _ in range(50):
        f = np.random.permutation(n)
        entropies.append(0.0)
        range_sizes.append(n)
    
    colors = ['green' if h < 0.01 else ('gold' if h < 1.0 else 'red') 
              for h in entropies]
    
    ax2.scatter(range_sizes, entropies, c=colors, alpha=0.5, s=20, edgecolors='none')
    ax2.set_xlabel('|Image(f)| (range size)', fontsize=11)
    ax2.set_ylabel('H(f) (nats)', fontsize=11)
    ax2.set_title('Phase Diagram: Reversible vs Irreversible\n(Fin 8 → Fin 8)', fontsize=12)
    
    # Add legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='green', alpha=0.7, label='Reversible (H=0)'),
        Patch(facecolor='gold', alpha=0.7, label='Low loss (H<1)'),
        Patch(facecolor='red', alpha=0.7, label='High loss (H≥1)')
    ]
    ax2.legend(handles=legend_elements, fontsize=9)
    ax2.grid(True, alpha=0.3)
    
    # Panel 3: Entropy vs collapse ratio
    ax3 = axes[2]
    
    # For uniform fibers: H = log(k) where k = |domain|/|range|
    collapse_ratios = np.linspace(1, 20, 200)
    H_uniform = np.log(collapse_ratios)
    
    ax3.plot(collapse_ratios, H_uniform, 'b-', linewidth=2, label='Uniform: H = log(k)')
    ax3.fill_between(collapse_ratios, 0, H_uniform, alpha=0.15, color='blue')
    
    # Mark special points
    special = [(1, 'Injective\n(reversible)'), (2, 'Binary\ncollapse'),
               (math.e, 'k = e'), (10, '10:1\ncompression')]
    for k, label in special:
        if k <= 20:
            ax3.plot(k, math.log(k), 'ro', markersize=8, zorder=5)
            ax3.annotate(label, xy=(k, math.log(k)),
                        xytext=(k + 0.5, math.log(k) + 0.15),
                        fontsize=8, ha='left')
    
    ax3.set_xlabel('Collapse ratio k = |fiber|', fontsize=11)
    ax3.set_ylabel('Functorial entropy H(f)', fontsize=11)
    ax3.set_title('Entropy vs. Collapse Ratio\n(Uniform Fiber Theorem)', fontsize=12)
    ax3.grid(True, alpha=0.3)
    ax3.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('landauer_bridge.png', dpi=150, bbox_inches='tight')
    print("Saved landauer_bridge.png")


if __name__ == "__main__":
    main()
