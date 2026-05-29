#!/usr/bin/env python3
"""
Visualization 3: The Diagonal — Absolute Darkness

Visualizes the diagonal function n ↦ f_n(n), which grows faster
than any fixed level in the hierarchy. This represents "absolute
darkness" — the mathematical analogue of a singularity where
witness complexity escapes all finite classification.
"""
import numpy as np
import matplotlib.pyplot as plt


def fast_grow_closed(k, n):
    """Closed-form fast-growing hierarchy."""
    if k == 0:
        return n + 1
    elif k == 1:
        return n + 2
    elif k == 2:
        return 2 * n + 3
    elif k == 3:
        return 2 ** (n + 3) - 3
    return None


def fast_grow_recursive(k, n, depth=0, max_depth=100):
    """Recursive computation with depth limit."""
    if depth > max_depth:
        return float('inf')
    if k == 0:
        return n + 1
    elif n == 0:
        return fast_grow_recursive(k - 1, 1, depth + 1, max_depth)
    else:
        inner = fast_grow_recursive(k, n - 1, depth + 1, max_depth)
        if inner == float('inf'):
            return float('inf')
        return fast_grow_recursive(k - 1, inner, depth + 1, max_depth)


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Diagonal vs fixed levels
n_vals = np.arange(0, 5)
colors = ['#90CAF9', '#81C784', '#FFB74D', '#EF5350', '#CE93D8', '#000000']

# Plot fixed levels
for k in range(4):
    vals = []
    for n in n_vals:
        v = fast_grow_closed(k, int(n))
        vals.append(v if v is not None else float('nan'))
    ax1.semilogy(n_vals, vals, 'o--', color=colors[k], linewidth=1.5,
                 markersize=8, alpha=0.6, label=f'Level {k}: $f_{k}(n)$')

# Plot diagonal
diag_vals = []
for n in n_vals:
    v = fast_grow_closed(int(n), int(n))
    if v is None:
        v = fast_grow_recursive(int(n), int(n))
    diag_vals.append(v)

ax1.semilogy(n_vals, diag_vals, 's-', color='black', linewidth=3,
             markersize=10, label=r'Diagonal: $f_n(n)$', zorder=5)

ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value (log scale)', fontsize=12)
ax1.set_title('The Diagonal Escapes Every Level', fontsize=13)
ax1.legend(fontsize=9)
ax1.grid(True, alpha=0.3)

# Add annotation
ax1.annotate('f₃(3) = 61',
             xy=(3, 61), xytext=(3.3, 15),
             fontsize=9,
             arrowprops=dict(arrowstyle='->', color='red'))
ax1.annotate('Diagonal: f₃(3) = 61\n(same point!)',
             xy=(3, 61), xytext=(1.5, 500),
             fontsize=9, color='black',
             arrowprops=dict(arrowstyle='->', color='black'))

# Panel 2: Growth rate comparison (heatmap style)
ax2_data = np.zeros((5, 8))
labels_grid = [['' for _ in range(8)] for _ in range(5)]

for k in range(5):
    for n in range(8):
        v = fast_grow_closed(k, n)
        if v is None:
            try:
                v = fast_grow_recursive(k, n, max_depth=50)
            except RecursionError:
                v = float('inf')
        if v == float('inf') or v > 1e15:
            ax2_data[k][n] = 15
            labels_grid[k][n] = '∞'
        else:
            ax2_data[k][n] = np.log10(max(v, 1))
            if v < 10000:
                labels_grid[k][n] = str(int(v))
            else:
                labels_grid[k][n] = f'{v:.0e}'

im = ax2.imshow(ax2_data, cmap='YlOrRd', aspect='auto',
                interpolation='nearest')

# Add value labels
for k in range(5):
    for n in range(8):
        text_color = 'white' if ax2_data[k][n] > 8 else 'black'
        ax2.text(n, k, labels_grid[k][n], ha='center', va='center',
                 fontsize=7, color=text_color, fontweight='bold')

# Highlight diagonal
for i in range(min(5, 8)):
    ax2.add_patch(plt.Rectangle((i - 0.5, i - 0.5), 1, 1,
                                fill=False, edgecolor='blue',
                                linewidth=3))

ax2.set_xlabel('n (input)', fontsize=12)
ax2.set_ylabel('k (level)', fontsize=12)
ax2.set_title('Fast-Growing Hierarchy Values\n(Blue boxes = diagonal)',
              fontsize=13)
ax2.set_xticks(range(8))
ax2.set_yticks(range(5))
ax2.set_yticklabels([f'Level {k}' for k in range(5)])

cbar = plt.colorbar(im, ax=ax2, label='log₁₀(value)')

plt.suptitle('Absolute Darkness: The Diagonal Function Escapes All Finite Levels',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_diagonal.png', dpi=150, bbox_inches='tight')
print("Saved viz_diagonal.png")
