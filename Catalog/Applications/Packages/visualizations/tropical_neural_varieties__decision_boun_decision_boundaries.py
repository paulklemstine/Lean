#!/usr/bin/env python3
"""
Visualization: Decision Boundaries of ReLU Networks as Tropical Varieties

Shows how the decision boundary complexity grows with network depth and width,
and illustrates the piecewise linear (tropical) structure.
"""

import numpy as np

def relu(x):
    return np.maximum(0, x)

class SimpleReLUNet:
    def __init__(self, dims, seed=42):
        np.random.seed(seed)
        self.W = []
        self.b = []
        for i in range(len(dims)-1):
            self.W.append(np.random.randn(dims[i], dims[i+1]) * 0.8)
            self.b.append(np.random.randn(dims[i+1]) * 0.2)

    def forward(self, x):
        for i in range(len(self.W)):
            x = x @ self.W[i] + self.b[i]
            if i < len(self.W) - 1:
                x = relu(x)
        return x

def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        from matplotlib.colors import ListedColormap
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    configs = [
        ([2, 3, 1], "Depth 1, Width 3\nTrop. Degree: 3"),
        ([2, 4, 1], "Depth 1, Width 4\nTrop. Degree: 4"),
        ([2, 3, 3, 1], "Depth 2, Width 3\nTrop. Degree: 9"),
        ([2, 4, 4, 1], "Depth 2, Width 4\nTrop. Degree: 16"),
        ([2, 3, 3, 3, 1], "Depth 3, Width 3\nTrop. Degree: 27"),
        ([2, 4, 4, 4, 1], "Depth 3, Width 4\nTrop. Degree: 64"),
    ]

    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Decision Boundaries as Tropical Hypersurfaces', fontsize=16, fontweight='bold')

    grid_size = 200
    x_range = np.linspace(-3, 3, grid_size)
    y_range = np.linspace(-3, 3, grid_size)
    xx, yy = np.meshgrid(x_range, y_range)
    grid = np.column_stack([xx.ravel(), yy.ravel()])

    cmap = ListedColormap(['#4a90d9', '#d94a4a'])

    for idx, (dims, title) in enumerate(configs):
        ax = axes[idx // 3, idx % 3]
        net = SimpleReLUNet(dims, seed=42 + idx)
        outputs = net.forward(grid).reshape(grid_size, grid_size)

        ax.contourf(xx, yy, outputs, levels=[-100, 0, 100], colors=['#a8c8e8', '#e8a8a8'], alpha=0.6)
        ax.contour(xx, yy, outputs, levels=[0], colors='black', linewidths=2)
        ax.set_title(title, fontsize=10)
        ax.set_xlim(-3, 3)
        ax.set_ylim(-3, 3)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    plt.tight_layout()
    plt.savefig('decision_boundaries.png', dpi=150, bbox_inches='tight')
    print("Saved decision_boundaries.png")

if __name__ == "__main__":
    main()
