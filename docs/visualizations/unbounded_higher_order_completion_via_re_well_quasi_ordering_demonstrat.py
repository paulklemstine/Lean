#!/usr/bin/env python3
"""
Visualization: Well-Quasi-Ordering on Terms

Illustrates the WQO property: in any infinite sequence of terms,
there must exist an increasing pair (i < j with size(f(i)) ≤ size(f(j))).

Shows multiple random sequences and highlights the first increasing pair found.
"""

import matplotlib.pyplot as plt
import numpy as np
import random

random.seed(42)
np.random.seed(42)


def random_term_size(max_depth=4):
    """Generate a random term size (simulating random term generation)."""
    if max_depth == 0 or random.random() < 0.4:
        return 1  # Variable
    elif random.random() < 0.5:
        return 1 + random_term_size(max_depth - 1) + random_term_size(max_depth - 1)
    else:
        return 1 + random_term_size(max_depth - 1)


def find_first_increasing_pair(sizes):
    """Find the first (i, j) with i < j and sizes[i] <= sizes[j]."""
    for i in range(len(sizes)):
        for j in range(i + 1, len(sizes)):
            if sizes[i] <= sizes[j]:
                return i, j
    return None, None


fig, axes = plt.subplots(3, 1, figsize=(14, 12))
fig.suptitle("Well-Quasi-Ordering on Terms by Size", 
             fontsize=16, fontweight='bold')

seq_lengths = [15, 25, 40]
max_depths = [3, 4, 5]

for ax_idx, (n, md) in enumerate(zip(seq_lengths, max_depths)):
    ax = axes[ax_idx]
    
    sizes = [random_term_size(md) for _ in range(n)]
    positions = list(range(n))
    
    i, j = find_first_increasing_pair(sizes)
    
    # Plot all points
    ax.bar(positions, sizes, color='#64B5F6', alpha=0.7, edgecolor='#1976D2', linewidth=0.5)
    
    # Highlight the increasing pair
    if i is not None:
        ax.bar([i], [sizes[i]], color='#4CAF50', alpha=0.9, edgecolor='#2E7D32', linewidth=2)
        ax.bar([j], [sizes[j]], color='#FF9800', alpha=0.9, edgecolor='#E65100', linewidth=2)
        
        # Draw arrow between them
        ax.annotate('', xy=(j, sizes[j] + 0.3), xytext=(i, sizes[i] + 0.3),
                    arrowprops=dict(arrowstyle='->', color='red', lw=2))
        
        ax.text((i + j) / 2, max(sizes[i], sizes[j]) + 1.5,
                f'size[{i}]={sizes[i]} ≤ size[{j}]={sizes[j]}',
                ha='center', fontsize=10, color='red', fontweight='bold',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow', alpha=0.8))
    
    ax.set_xlabel('Position in sequence', fontsize=11)
    ax.set_ylabel('Term size', fontsize=11)
    ax.set_title(f'Sequence of {n} random terms (max depth {md}): '
                 f'increasing pair at positions ({i}, {j})',
                 fontsize=12)
    ax.grid(True, alpha=0.2, axis='y')

# Add explanation text
fig.text(0.5, 0.01,
         "The WQO theorem guarantees: every infinite sequence of terms has an increasing pair.\n"
         "Green = first element, Orange = second element of the first increasing pair found.",
         ha='center', fontsize=11, style='italic',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.5))

plt.tight_layout(rect=[0, 0.05, 1, 0.95])
plt.savefig('wqo_visualization.png', dpi=150, bbox_inches='tight')
print("Saved wqo_visualization.png")
