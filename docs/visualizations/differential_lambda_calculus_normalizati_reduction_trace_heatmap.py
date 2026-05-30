#!/usr/bin/env python3
"""
Visualization: Reduction Trace Heatmap

Shows how the stratified measure (type_level, term_size) decreases
during normalization of differential lambda-calculus terms.
The heatmap shows the density of intermediate terms at each
(type_level, size) coordinate during multiple normalization runs.
"""

import matplotlib.pyplot as plt
import numpy as np


def simulate_reduction_traces(n_traces=50, max_level=4, max_size=20):
    """Simulate reduction traces with stratified measure decrease."""
    rng = np.random.RandomState(42)
    all_points = []

    for _ in range(n_traces):
        level = rng.randint(1, max_level + 1)
        size = rng.randint(5, max_size + 1)

        points = [(level, size)]
        while level > 0 or size > 1:
            if rng.random() < 0.3 and level > 0:
                # Beta step: decrease level, potentially increase size
                level -= 1
                size = min(max_size, size + rng.randint(-2, 4))
                size = max(1, size)
            else:
                # Differential/simplification step: decrease size at same level
                if size > 1:
                    size -= rng.randint(1, min(4, size))
                    size = max(1, size)
                elif level > 0:
                    level -= 1
                    size = rng.randint(1, 8)

            points.append((level, size))
        all_points.extend(points)

    return all_points


def plot_reduction_heatmap():
    """Create a heatmap of reduction trace density."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Generate data
    points = simulate_reduction_traces()
    levels = [p[0] for p in points]
    sizes = [p[1] for p in points]

    # Left: Heatmap
    ax = axes[0]
    heatmap, xedges, yedges = np.histogram2d(sizes, levels,
                                              bins=[20, 5],
                                              range=[[0, 20], [0, 5]])
    im = ax.imshow(heatmap.T, origin='lower', aspect='auto',
                   extent=[0, 20, 0, 5], cmap='YlOrRd',
                   interpolation='nearest')
    ax.set_xlabel("Term Size", fontsize=12)
    ax.set_ylabel("Type Level", fontsize=12)
    ax.set_title("Reduction State Density\n(brighter = more visited)", fontsize=13,
                 fontweight='bold')
    plt.colorbar(im, ax=ax, label="Visit count")

    # Add arrow showing the direction of normalization
    ax.annotate("Normalization\ndirection", xy=(2, 0.3), xytext=(12, 3.5),
                arrowprops=dict(arrowstyle="-|>", color='blue', lw=2.5),
                fontsize=11, color='blue', fontweight='bold', ha='center')

    # Right: Individual traces
    ax2 = axes[1]
    rng = np.random.RandomState(42)
    colors = plt.cm.viridis(np.linspace(0, 1, 8))

    for i in range(8):
        level = rng.randint(2, 5)
        size = rng.randint(8, 20)
        trace_l, trace_s = [level], [size]

        while level > 0 or size > 1:
            if rng.random() < 0.3 and level > 0:
                level -= 1
                size = min(20, size + rng.randint(-2, 4))
                size = max(1, size)
            else:
                if size > 1:
                    size -= rng.randint(1, min(4, size))
                    size = max(1, size)
                elif level > 0:
                    level -= 1
                    size = rng.randint(1, 8)
            trace_l.append(level)
            trace_s.append(size)

        ax2.plot(trace_s, trace_l, 'o-', color=colors[i], markersize=3,
                 linewidth=1.5, alpha=0.7, label=f'Term {i+1}')

    ax2.set_xlabel("Term Size", fontsize=12)
    ax2.set_ylabel("Type Level", fontsize=12)
    ax2.set_title("Individual Reduction Traces\n(all converge to normal form)",
                  fontsize=13, fontweight='bold')
    ax2.legend(fontsize=8, ncol=2)
    ax2.set_xlim(0, 22)
    ax2.set_ylim(-0.3, 5)

    # Mark the "normal form region"
    from matplotlib.patches import Rectangle
    rect = Rectangle((0, -0.3), 3, 1, linewidth=2, edgecolor='green',
                     facecolor='green', alpha=0.15)
    ax2.add_patch(rect)
    ax2.text(1.5, 0.2, "Normal\nforms", ha='center', va='center',
             fontsize=10, color='green', fontweight='bold')

    plt.tight_layout()
    plt.savefig("viz_reduction_trace.png", dpi=150, bbox_inches='tight')
    print("Saved: viz_reduction_trace.png")
    plt.close()


if __name__ == "__main__":
    plot_reduction_heatmap()
    print("Reduction trace visualization generated.")
