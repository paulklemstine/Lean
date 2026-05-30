"""
Visualization 1: Hyperplane Arrangement Regions in R^2

Visualizes the activation regions created by a hyperplane arrangement,
showing how the plane is partitioned into colored regions. Each color
represents a distinct activation pattern — these are the atoms of the
activation algebra and the points of the Stone dual space.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def dot_prod(v, x):
    return np.sum(v * x, axis=-1)


def activation_pattern_grid(normals, biases, xx, yy):
    """Compute activation pattern for each point on a grid."""
    grid = np.stack([xx, yy], axis=-1)
    k = len(normals)
    patterns = np.zeros(xx.shape, dtype=int)
    for j in range(k):
        sign = dot_prod(normals[j], grid) + biases[j] > 0
        patterns += sign.astype(int) * (2**j)
    return patterns


def plot_arrangement_regions():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    # Example 1: Two perpendicular lines
    normals1 = [np.array([1, 0]), np.array([0, 1])]
    biases1 = [0, 0]

    # Example 2: Three lines in general position
    normals2 = [np.array([1, 0]), np.array([0, 1]), np.array([1, 1])]
    biases2 = [0, 0, 0]

    # Example 3: ReLU network (4 neurons)
    np.random.seed(42)
    normals3 = [np.array([1, 1]), np.array([-1, 1]),
                np.array([1, -1]), np.array([0.5, -0.5])]
    biases3 = [0, 0, 0, 0.5]

    examples = [
        (normals1, biases1, "2 Lines: 4 Regions"),
        (normals2, biases2, "3 Lines: 7 Regions (Zaslavsky)"),
        (normals3, biases3, "4 Neurons: ReLU Network"),
    ]

    x = np.linspace(-3, 3, 500)
    y = np.linspace(-3, 3, 500)
    xx, yy = np.meshgrid(x, y)

    cmap = plt.cm.Set3
    for ax, (normals, biases, title) in zip(axes, examples):
        patterns = activation_pattern_grid(normals, biases, xx, yy)
        unique_patterns = np.unique(patterns)
        n_regions = len(unique_patterns)

        # Map patterns to consecutive integers for coloring
        pattern_map = {p: i for i, p in enumerate(unique_patterns)}
        colored = np.vectorize(pattern_map.get)(patterns)

        ax.contourf(xx, yy, colored, levels=np.arange(-0.5, n_regions),
                    cmap=cmap, alpha=0.7)

        # Draw hyperplane lines
        for j, (n, b) in enumerate(zip(normals, biases)):
            if abs(n[1]) > 1e-10:
                yline = -(n[0] * x + b) / n[1]
                mask = (yline > -3) & (yline < 3)
                ax.plot(x[mask], yline[mask], 'k-', linewidth=1.5, alpha=0.8)
            else:
                xval = -b / n[0]
                ax.axvline(x=xval, color='k', linewidth=1.5, alpha=0.8)

        k = len(normals)
        ax.set_title(f"{title}\n(k={k}, 2^k={2**k}, actual={n_regions})",
                     fontsize=12, fontweight='bold')
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.set_xlabel('x₁')
        ax.set_ylabel('x₂')

    fig.suptitle('Activation Regions of Hyperplane Arrangements\n'
                 '(Each color = one activation pattern = one Stone dual point)',
                 fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('viz_regions.png', dpi=150, bbox_inches='tight')
    print("Saved: viz_regions.png")


if __name__ == "__main__":
    plot_arrangement_regions()
