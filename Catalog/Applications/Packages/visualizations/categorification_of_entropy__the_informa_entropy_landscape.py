"""
Visualization: Entropy Landscape of Functions Fin n → Fin m

Shows how functorial entropy varies across all functions between small finite
types, revealing the discrete landscape of information loss. Each point
represents a function, colored by its entropy.
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from itertools import product


def functorial_entropy_vec(f_values, n, m):
    """Compute H(f) given f as a list of output values."""
    fiber_counts = Counter(f_values)
    H = 0.0
    for c in fiber_counts.values():
        if c > 0:
            H += (c / n) * math.log(c)
    return H


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Panel 1: All functions Fin 4 → Fin 4, sorted by entropy
    n, m = 4, 4
    all_funcs = list(product(range(m), repeat=n))
    entropies = [functorial_entropy_vec(f, n, m) for f in all_funcs]
    sorted_idx = np.argsort(entropies)
    sorted_H = [entropies[i] for i in sorted_idx]
    
    colors = plt.cm.viridis(np.array(sorted_H) / max(sorted_H) if max(sorted_H) > 0 else np.zeros(len(sorted_H)))
    axes[0].bar(range(len(sorted_H)), sorted_H, color=colors, width=1.0)
    axes[0].set_xlabel('Function index (sorted)', fontsize=11)
    axes[0].set_ylabel('H(f) (nats)', fontsize=11)
    axes[0].set_title(f'Entropy of all {m}^{n}={m**n} functions\nFin {n} → Fin {m}', fontsize=12)
    axes[0].axhline(y=0, color='red', linestyle='--', alpha=0.5, label='H=0 (injective)')
    axes[0].axhline(y=math.log(n), color='orange', linestyle='--', alpha=0.5, label=f'H=log({n}) (constant)')
    axes[0].legend(fontsize=9)
    
    # Panel 2: Histogram of entropy values
    unique_H = sorted(set(round(h, 8) for h in entropies))
    hist_data = [sum(1 for h in entropies if abs(h - uh) < 1e-6) for uh in unique_H]
    
    bar_colors = plt.cm.viridis(np.array(unique_H) / max(unique_H) if max(unique_H) > 0 else np.zeros(len(unique_H)))
    axes[1].bar(range(len(unique_H)), hist_data, color=bar_colors, width=0.8)
    axes[1].set_xticks(range(len(unique_H)))
    axes[1].set_xticklabels([f'{h:.3f}' for h in unique_H], rotation=45, fontsize=7)
    axes[1].set_xlabel('Entropy value H(f)', fontsize=11)
    axes[1].set_ylabel('Number of functions', fontsize=11)
    axes[1].set_title('Distribution of entropy values\n(discrete spectrum)', fontsize=12)
    
    # Annotate injective count
    inj_count = sum(1 for h in entropies if abs(h) < 1e-8)
    axes[1].annotate(f'{inj_count} injective\n(H=0)', xy=(0, inj_count),
                     xytext=(2, inj_count + 10), fontsize=9,
                     arrowprops=dict(arrowstyle='->', color='red'),
                     color='red')
    
    # Panel 3: Fiber size vs entropy contribution
    # For different fiber sizes k, show the contribution (k/n)*log(k)
    ks = np.arange(1, 21)
    ns = [5, 10, 20, 50]
    
    for n_val in ns:
        contributions = [(k / n_val) * math.log(k) if k > 0 else 0 for k in ks]
        axes[2].plot(ks, contributions, 'o-', markersize=4, label=f'|α| = {n_val}')
    
    axes[2].set_xlabel('Fiber size k', fontsize=11)
    axes[2].set_ylabel('Contribution (k/|α|)·log(k)', fontsize=11)
    axes[2].set_title('Per-fiber entropy contribution\nvs. fiber size', fontsize=12)
    axes[2].legend(fontsize=9)
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved entropy_landscape.png")


if __name__ == "__main__":
    main()
