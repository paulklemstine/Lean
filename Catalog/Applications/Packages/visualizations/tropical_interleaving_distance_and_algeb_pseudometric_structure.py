"""
Visualization: Tropical Interleaving Pseudometric Properties

This script visualizes the pseudometric structure of the tropical
interleaving distance through a heatmap of pairwise distances
between step modules and verification of the triangle inequality.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def step_module_val(k, i):
    """Step module at k: 0 for i <= k, 1 for i > k."""
    return 0 if i <= k else 1


def is_delta_interleaved(k1, k2, delta):
    """Check if step(k1) and step(k2) are delta-interleaved."""
    lo = min(k1, k2) - delta - 1
    hi = max(k1, k2) + delta + 1
    for i in range(lo, hi + 1):
        if step_module_val(k1, i) > step_module_val(k2, i + delta):
            return False
        if step_module_val(k2, i) > step_module_val(k1, i + delta):
            return False
    return True


def interleaving_dist(k1, k2, max_d=50):
    """Compute interleaving distance between step(k1) and step(k2)."""
    for d in range(0, max_d + 1):
        if is_delta_interleaved(k1, k2, d):
            return d
    return max_d


def plot_pseudometric():
    fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

    # Panel 1: Distance matrix heatmap
    n = 12
    positions = list(range(n))
    dist_matrix = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            dist_matrix[i, j] = interleaving_dist(i, j)

    ax = axes[0]
    im = ax.imshow(dist_matrix, cmap='YlOrRd', interpolation='nearest')
    ax.set_xlabel('Step module position', fontsize=12)
    ax.set_ylabel('Step module position', fontsize=12)
    ax.set_title('Interleaving Distance Matrix\nd(step(i), step(j))', fontsize=13, fontweight='bold')
    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    plt.colorbar(im, ax=ax, shrink=0.8, label='Distance')

    # Add values to cells
    for i in range(n):
        for j in range(n):
            color = 'white' if dist_matrix[i, j] > n/2 else 'black'
            ax.text(j, i, int(dist_matrix[i, j]), ha='center', va='center',
                    fontsize=7, color=color)

    # Panel 2: Triangle inequality verification
    ax = axes[1]
    violations = 0
    slack_values = []

    for i in range(n):
        for j in range(n):
            for k in range(n):
                d_ik = dist_matrix[i, k]
                d_ij = dist_matrix[i, j]
                d_jk = dist_matrix[j, k]
                slack = (d_ij + d_jk) - d_ik
                slack_values.append(slack)
                if d_ik > d_ij + d_jk:
                    violations += 1

    ax.hist(slack_values, bins=range(0, max(int(max(slack_values))+2, 2)),
            color='#4CAF50', alpha=0.7, edgecolor='#388E3C', align='left')
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2,
               label=f'Equality line')
    ax.set_xlabel('Triangle inequality slack\n(d(i,j)+d(j,k)-d(i,k))', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title(f'Triangle Inequality Verification\n{violations} violations out of {n**3}',
                 fontsize=13, fontweight='bold',
                 color='green' if violations == 0 else 'red')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Panel 3: Distance vs position difference
    ax = axes[2]
    diffs = []
    dists_interleave = []
    dists_pointwise = []

    for i in range(n):
        for j in range(i + 1, n):
            diff = j - i
            d_I = int(dist_matrix[i, j])
            # Pointwise distance for step modules
            d_B = 1 if diff > 0 else 0
            diffs.append(diff)
            dists_interleave.append(d_I)
            dists_pointwise.append(d_B)

    ax.scatter(diffs, dists_interleave, color='#2196F3', s=60, alpha=0.7,
               label='Interleaving d_I', zorder=3)
    ax.scatter(diffs, dists_pointwise, color='#FF5722', s=60, alpha=0.7,
               marker='s', label='Pointwise d_B', zorder=3)
    ax.plot([0, n], [0, n], 'k--', alpha=0.3, label='d_I = gap')
    # Shade the gap region
    ax.axhspan(1, n-1, alpha=0.05, color='purple')

    ax.set_xlabel('Position difference |k₁ - k₂|', fontsize=12)
    ax.set_ylabel('Distance', fontsize=12)
    ax.set_title('Interleaving vs Pointwise Distance\nfor Step Modules', fontsize=13, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Tropical Interleaving Pseudometric: Structure and Verification',
                 fontsize=15, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_pseudometric.png', dpi=150, bbox_inches='tight')
    print("Saved viz_pseudometric.png")


if __name__ == "__main__":
    plot_pseudometric()
