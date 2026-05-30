"""
Visualization 3: Stone Dual Space and Boolean Algebra Structure

Visualizes the Stone dual space of a hyperplane arrangement, showing
the correspondence between activation patterns (algebra atoms) and
geometric regions. The Hasse diagram shows the Boolean algebra structure,
while the 2D plot shows the geometric realization.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def make_arrangement_and_patterns():
    """Create a 3-line arrangement in R^2 and find all patterns."""
    normals = [np.array([1, 0]), np.array([0, 1]), np.array([1, 1])]
    biases = [0, 0, 0]

    x = np.linspace(-3, 3, 200)
    y = np.linspace(-3, 3, 200)
    xx, yy = np.meshgrid(x, y)
    grid = np.stack([xx, yy], axis=-1)

    patterns_map = {}
    for i in range(200):
        for j in range(200):
            pt = grid[i, j]
            pat = tuple(np.dot(n, pt) + b > 0 for n, b in zip(normals, biases))
            if pat not in patterns_map:
                patterns_map[pat] = []
            patterns_map[pat].append((xx[i, j], yy[i, j]))

    return normals, biases, patterns_map


def plot_stone_dual():
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    normals, biases, patterns_map = make_arrangement_and_patterns()
    patterns = sorted(patterns_map.keys())

    # Color map for patterns
    colors = plt.cm.Set2(np.linspace(0, 1, len(patterns)))

    # Left: Geometric regions
    ax1 = axes[0]
    for idx, pat in enumerate(patterns):
        pts = patterns_map[pat]
        xs, ys = zip(*pts)
        label = ''.join(['+' if p else '-' for p in pat])
        ax1.scatter(xs, ys, c=[colors[idx]], s=0.5, alpha=0.6, label=label)

    # Draw hyperplane lines
    x_line = np.linspace(-3, 3, 100)
    for n, b in zip(normals, biases):
        if abs(n[1]) > 1e-10:
            y_line = -(n[0] * x_line + b) / n[1]
            mask = (y_line > -3) & (y_line < 3)
            ax1.plot(x_line[mask], y_line[mask], 'k-', linewidth=2)
        else:
            ax1.axvline(-b / n[0], color='k', linewidth=2)

    ax1.set_xlim(-3, 3)
    ax1.set_ylim(-3, 3)
    ax1.set_aspect('equal')
    ax1.set_title('Geometric Realization\n(Regions in R²)', fontsize=13, fontweight='bold')
    ax1.set_xlabel('x₁', fontsize=11)
    ax1.set_ylabel('x₂', fontsize=11)
    ax1.legend(title='Pattern (h₁h₂h₃)', fontsize=8, title_fontsize=9,
               loc='upper left', markerscale=5)

    # Right: Stone dual space as a graph
    ax2 = axes[1]

    n_patterns = len(patterns)
    # Arrange points in a circle
    angles = np.linspace(0, 2 * np.pi, n_patterns, endpoint=False)
    radius = 2
    xs = radius * np.cos(angles)
    ys = radius * np.sin(angles)

    for idx, pat in enumerate(patterns):
        label = ''.join(['+' if p else '-' for p in pat])
        ax2.scatter(xs[idx], ys[idx], c=[colors[idx]], s=300, zorder=5,
                    edgecolors='black', linewidth=1.5)
        ax2.annotate(label, (xs[idx], ys[idx]), fontsize=9, ha='center', va='center',
                     fontweight='bold')

    # Draw edges between patterns that differ in exactly one coordinate
    for i in range(n_patterns):
        for j in range(i + 1, n_patterns):
            diff = sum(1 for a, b in zip(patterns[i], patterns[j]) if a != b)
            if diff == 1:
                ax2.plot([xs[i], xs[j]], [ys[i], ys[j]], 'k-', alpha=0.3, linewidth=1)

    ax2.set_xlim(-3.5, 3.5)
    ax2.set_ylim(-3.5, 3.5)
    ax2.set_aspect('equal')
    ax2.set_title(f'Stone Dual Space\n({n_patterns} points = {n_patterns} atoms)',
                  fontsize=13, fontweight='bold')
    ax2.axis('off')

    # Add annotation about the duality
    ax2.text(0, -3.2,
             f'Each point = one ultrafilter = one activation pattern\n'
             f'Edges connect patterns differing by one hyperplane\n'
             f'Boolean algebra has {n_patterns} atoms, 2^{n_patterns}={2**n_patterns} elements',
             ha='center', fontsize=10, style='italic',
             bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    fig.suptitle('Stone Duality: Geometry ↔ Algebra\n'
                 '3 hyperplanes in R² → 7 regions → 7-point Stone dual',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_stone_dual.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_stone_dual.png")


if __name__ == "__main__":
    plot_stone_dual()
