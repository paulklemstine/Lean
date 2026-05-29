#!/usr/bin/env python3
"""
Visualization 1: The Fast-Growing Hierarchy

Visualizes the growth rates of different levels of the fast-growing
hierarchy, showing how each level eventually dominates the previous one.
This is the core visual representation of the "darkness hierarchy" —
each level represents a deeper layer of mathematical unknowability.
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


# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Linear scale (levels 0-2)
n_vals = np.arange(0, 15)
colors = ['#2196F3', '#4CAF50', '#FF9800', '#F44336', '#9C27B0']
labels = [
    r'Level 0: $f_0(n) = n+1$ (successor)',
    r'Level 1: $f_1(n) = n+2$ (addition)',
    r'Level 2: $f_2(n) = 2n+3$ (multiplication)',
]

for k in range(3):
    vals = [fast_grow_closed(k, int(n)) for n in n_vals]
    ax1.plot(n_vals, vals, 'o-', color=colors[k], linewidth=2,
             markersize=6, label=labels[k])

ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('f_k(n)', fontsize=12)
ax1.set_title('Fast-Growing Hierarchy (Linear Scale)', fontsize=14)
ax1.legend(fontsize=9, loc='upper left')
ax1.grid(True, alpha=0.3)
ax1.set_xlim(-0.5, 14.5)

# Panel 2: Log scale (levels 0-3)
n_vals2 = np.arange(0, 12)
labels2 = labels + [r'Level 3: $f_3(n) = 2^{n+3}-3$ (exponential)']

for k in range(4):
    vals = [fast_grow_closed(k, int(n)) for n in n_vals2]
    ax2.semilogy(n_vals2, vals, 'o-', color=colors[k], linewidth=2,
                 markersize=6, label=labels2[k])

# Add reference lines
poly_vals = [int(n)**3 + 1 for n in n_vals2]
ax2.semilogy(n_vals2, poly_vals, '--', color='gray', linewidth=1.5,
             alpha=0.7, label=r'Reference: $n^3+1$')

ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('f_k(n) [log scale]', fontsize=12)
ax2.set_title('Fast-Growing Hierarchy (Log Scale)', fontsize=14)
ax2.legend(fontsize=9, loc='upper left')
ax2.grid(True, alpha=0.3)
ax2.set_xlim(-0.5, 11.5)

# Add annotation about darkness levels
ax2.annotate('Each level is a\n"layer of darkness"',
             xy=(8, fast_grow_closed(3, 8)),
             xytext=(5, 10),
             fontsize=10,
             arrowprops=dict(arrowstyle='->', color='red'),
             bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

plt.suptitle('The Darkness Hierarchy: Layers of Mathematical Unknowability',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_hierarchy.png', dpi=150, bbox_inches='tight')
print("Saved viz_hierarchy.png")
