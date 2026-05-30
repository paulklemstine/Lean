#!/usr/bin/env python3
"""
Visualization 1: Entropy Landscape for Functions Fin n → Fin m

Shows how functorial entropy varies across the space of all functions
from a small finite set to another. Illustrates the Zero Characterization
Theorem: injective functions sit at H=0, constant functions at H=log(n).
"""

import math
import numpy as np
import matplotlib.pyplot as plt
from collections import Counter
from itertools import product


def functorial_entropy_from_map(f_map: list, n: int) -> float:
    """Compute H(f) given f as a list of output values."""
    if n == 0:
        return 0.0
    counts = Counter(f_map)
    total = 0.0
    for x in range(n):
        fiber_size = counts[f_map[x]]
        total += math.log(fiber_size)
    return total / n


def is_injective_map(f_map: list) -> bool:
    return len(set(f_map)) == len(f_map)


# Generate all functions Fin 4 → Fin 3
n, m = 4, 3
all_funcs = list(product(range(m), repeat=n))
entropies = [functorial_entropy_from_map(list(f), n) for f in all_funcs]
injective_mask = [is_injective_map(list(f)) for f in all_funcs]
surjective_mask = [len(set(f)) == m for f in all_funcs]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: histogram of entropies
ax1 = axes[0]
ax1.hist(entropies, bins=30, color='steelblue', edgecolor='black', alpha=0.7)
ax1.axvline(x=0, color='green', linestyle='--', linewidth=2, label='H=0 (injective)')
ax1.axvline(x=math.log(n), color='red', linestyle='--', linewidth=2,
            label=f'H=log({n})={math.log(n):.2f} (constant)')
ax1.set_xlabel('Functorial Entropy H(f)', fontsize=12)
ax1.set_ylabel('Number of functions', fontsize=12)
ax1.set_title(f'Entropy Distribution: All {m**n} functions Fin {n} → Fin {m}', fontsize=13)
ax1.legend(fontsize=10)

# Right: entropy vs image size
ax2 = axes[1]
image_sizes = [len(set(f)) for f in all_funcs]
colors = ['green' if inj else ('orange' if surj else 'steelblue')
          for inj, surj in zip(injective_mask, surjective_mask)]
ax2.scatter(image_sizes, entropies, c=colors, alpha=0.4, s=20)
ax2.set_xlabel('Image size |f(α)|', fontsize=12)
ax2.set_ylabel('Functorial Entropy H(f)', fontsize=12)
ax2.set_title('Entropy vs Image Size', fontsize=13)

# Add legend
from matplotlib.lines import Line2D
legend_elements = [
    Line2D([0], [0], marker='o', color='w', markerfacecolor='green',
           markersize=8, label='Injective (H=0)'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='orange',
           markersize=8, label='Surjective'),
    Line2D([0], [0], marker='o', color='w', markerfacecolor='steelblue',
           markersize=8, label='Neither'),
]
ax2.legend(handles=legend_elements, fontsize=10)

plt.tight_layout()
plt.savefig('entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved entropy_landscape.png")
