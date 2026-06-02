#!/usr/bin/env python3
"""
Demo: Neural Network Decision Surface Topology

Demonstrates the key mathematical results:
1. Zaslavsky bounds for hyperplane arrangements
2. Neural complexity computation
3. Activation pattern counting
4. Euler characteristic computation
"""

from math import comb, prod
from typing import List, Tuple


def zaslavsky_bound(n: int, w: int) -> int:
    """Maximum regions from w hyperplanes in R^n."""
    return sum(comb(w, k) for k in range(min(n, w) + 1))


def neural_complexity(input_dim: int, widths: List[int]) -> int:
    """Neural complexity: product of per-layer Zaslavsky bounds."""
    result = 1
    for w in widths:
        result *= zaslavsky_bound(input_dim, w)
    return result


def neural_complexity_upper(widths: List[int]) -> int:
    """Upper bound: 2^{total neurons}."""
    return 2 ** sum(widths)


def hodge_bound(w1: int, wL: int, p: int, q: int) -> int:
    """Hodge number bound: C(w1, p) * C(wL, q)."""
    return comb(w1, p) * comb(wL, q)


def euler_char(f_vector: List[int]) -> int:
    """Euler characteristic from f-vector."""
    return sum((-1)**k * fk for k, fk in enumerate(f_vector))


def main():
    print("=" * 60)
    print("Neural Network Decision Surface Topology")
    print("=" * 60)

    # --- Zaslavsky Bounds ---
    print("\n1. ZASLAVSKY BOUNDS")
    print("-" * 40)
    print(f"{'n':>4} {'w':>4} {'Z(n,w)':>10} {'2^w':>10} {'ratio':>8}")
    for n in [2, 3, 5, 10]:
        for w in [3, 5, 10, 20]:
            z = zaslavsky_bound(n, w)
            p = 2**w
            print(f"{n:4d} {w:4d} {z:10d} {p:10d} {z/p:8.4f}")
        print()

    # --- Neural Complexity ---
    print("\n2. NEURAL COMPLEXITY")
    print("-" * 40)
    architectures = [
        (2, [3]),           # shallow, narrow
        (2, [10]),          # shallow, wide
        (2, [5, 5]),        # 2 layers
        (2, [5, 5, 5]),     # 3 layers
        (10, [20, 20]),     # high-dim
        (2, [100]),         # very wide
        (2, [10, 10, 10]),  # deep
    ]
    print(f"{'arch':>25} {'complexity':>15} {'2^W':>15} {'ratio':>10}")
    for n, widths in architectures:
        arch_str = f"({n}; {widths})"
        nc = neural_complexity(n, widths)
        ub = neural_complexity_upper(widths)
        ratio = nc / ub if ub > 0 else 0
        print(f"{arch_str:>25} {nc:15d} {ub:15d} {ratio:10.6f}")

    # --- Activation Patterns ---
    print("\n3. ACTIVATION PATTERNS")
    print("-" * 40)
    for w in [1, 2, 3, 5, 8, 10]:
        print(f"Width {w}: {2**w} possible patterns")

    # --- Hodge Number Bounds ---
    print("\n4. HODGE NUMBER BOUNDS")
    print("-" * 40)
    print(f"{'w1':>4} {'wL':>4} {'p':>3} {'q':>3} {'h^pq':>10} {'bound':>10}")
    for w1 in [5, 10, 20]:
        for wL in [5, 10, 20]:
            for p, q in [(1, 1), (2, 1), (2, 2)]:
                h = hodge_bound(w1, wL, p, q)
                b = 2**w1 * 2**wL
                print(f"{w1:4d} {wL:4d} {p:3d} {q:3d} {h:10d} {b:10d}")
        print()

    # --- Euler Characteristic ---
    print("\n5. EULER CHARACTERISTIC EXAMPLES")
    print("-" * 40)
    examples = [
        ("triangle", [3, 3]),           # 3 vertices, 3 edges
        ("tetrahedron", [4, 6, 4]),     # 4 verts, 6 edges, 4 faces
        ("cube", [8, 12, 6]),           # 8 verts, 12 edges, 6 faces
        ("2-simplex boundary", [3, 3, 1]),
    ]
    for name, fv in examples:
        chi = euler_char(fv)
        total = sum(fv)
        print(f"{name:>25}: f = {fv}, χ = {chi}, |χ| ≤ {total} ✓" if abs(chi) <= total else f"FAILED")

    # --- Key Theorems Summary ---
    print("\n6. VERIFIED THEOREMS")
    print("-" * 40)
    theorems = [
        "relu_lipschitz: |relu(x) - relu(y)| ≤ |x - y|",
        "relu_idempotent: relu(relu(x)) = relu(x)",
        "zaslavsky_le_pow: Z(n,w) ≤ 2^w",
        "zaslavsky_pos: Z(n,w) ≥ 1",
        "zaslavsky_mono_w: w₁ ≤ w₂ → Z(n,w₁) ≤ Z(n,w₂)",
        "neuralComplexity_le_pow: ν(arch) ≤ 2^W",
        "euler_char_abs_le_totalFaces: |χ| ≤ Σ fₖ",
        "hodge_bound_combinatorial: C(w₁,p)·C(wL,q) ≤ 2^w₁·2^wL",
        "choose_le_pow: C(n,k) ≤ 2^n",
        "chain_module_rank: rank(C_k) = f_k (PL Hodge property)",
        "binomial_sum_eq_pow: Σ C(n,k) = 2^n",
        "card_activation_pattern: |{0,1}^w| = 2^w",
    ]
    for t in theorems:
        print(f"  ✓ {t}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: ReLU Network Decision Surfaces in 2D

Creates a plot showing the decision boundary and linear regions
of a simple ReLU network.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from math import comb


def relu(x):
    return np.maximum(0, x)


def forward(x, weights, biases):
    """Forward pass through a ReLU network."""
    h = x
    for W, b in zip(weights[:-1], biases[:-1]):
        h = relu(h @ W + b)
    h = h @ weights[-1] + biases[-1]
    return h


def zaslavsky_bound(n, w):
    return sum(comb(w, k) for k in range(min(n, w) + 1))


def main():
    np.random.seed(42)

    # Create a small network: R^2 -> R with architecture (2, 4, 3, 1)
    W1 = np.random.randn(2, 4) * 1.5
    b1 = np.random.randn(4) * 0.5
    W2 = np.random.randn(4, 3) * 1.5
    b2 = np.random.randn(3) * 0.5
    W3 = np.random.randn(3, 1) * 1.5
    b3 = np.random.randn(1) * 0.5

    weights = [W1, W2, W3]
    biases = [b1, b2, b3]

    # Create grid
    x_range = np.linspace(-3, 3, 500)
    y_range = np.linspace(-3, 3, 500)
    xx, yy = np.meshgrid(x_range, y_range)
    grid = np.c_[xx.ravel(), yy.ravel()]

    # Forward pass
    output = forward(grid, weights, biases).reshape(xx.shape)

    # Compute activation patterns for coloring linear regions
    h1 = relu(grid @ W1 + b1)
    h2 = relu(h1 @ W2 + b2)
    patterns = (grid @ W1 + b1 > 0).astype(int)
    pattern_ids = np.sum(patterns * (2 ** np.arange(4)), axis=1).reshape(xx.shape)

    # Create figure
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Decision surface (zero contour)
    ax = axes[0]
    im = ax.contourf(xx, yy, output, levels=50, cmap='RdBu_r', alpha=0.8)
    ax.contour(xx, yy, output, levels=[0], colors='black', linewidths=2)
    ax.set_title('Decision Surface V(f) = {x : f(x) = 0}', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')
    plt.colorbar(im, ax=ax, label='f(x)')

    # Plot 2: Linear regions (activation patterns)
    ax = axes[1]
    cmap = plt.cm.get_cmap('tab20', int(pattern_ids.max()) + 1)
    ax.pcolormesh(xx, yy, pattern_ids, cmap=cmap, alpha=0.7)
    ax.contour(xx, yy, output, levels=[0], colors='black', linewidths=2)
    ax.set_title(f'Linear Regions (max Z(2,4)={zaslavsky_bound(2, 4)})', fontsize=12)
    ax.set_xlabel('x₁')
    ax.set_ylabel('x₂')

    # Plot 3: Zaslavsky bounds vs actual regions
    ax = axes[2]
    widths_range = range(1, 21)
    z_bounds = [zaslavsky_bound(2, w) for w in widths_range]
    pow_bounds = [2**w for w in widths_range]
    ax.semilogy(list(widths_range), z_bounds, 'bo-', label='Z(2, w)', markersize=4)
    ax.semilogy(list(widths_range), pow_bounds, 'r--', label='2^w', alpha=0.7)
    ax.set_xlabel('Number of hyperplanes w')
    ax.set_ylabel('Maximum regions')
    ax.set_title('Zaslavsky Bound vs 2^w (n=2)', fontsize=12)
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('decision_surface_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: decision_surface_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hodge Number Bounds for Neural Networks

Creates heatmap visualizations of the Hodge number bounds
h^{p,q} <= C(w1, p) * C(wL, q) for different network architectures.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def hodge_bound(w1, wL, p, q):
    return comb(w1, p) * comb(wL, q)


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    architectures = [
        (3, 3, "w₁=3, w_L=3"),
        (5, 5, "w₁=5, w_L=5"),
        (10, 10, "w₁=10, w_L=10"),
        (5, 10, "w₁=5, w_L=10"),
        (3, 20, "w₁=3, w_L=20"),
        (10, 3, "w₁=10, w_L=3"),
    ]

    for idx, (w1, wL, title) in enumerate(architectures):
        ax = axes[idx // 3][idx % 3]
        max_pq = min(max(w1, wL), 12)
        grid = np.zeros((max_pq + 1, max_pq + 1))
        for p in range(max_pq + 1):
            for q in range(max_pq + 1):
                val = hodge_bound(w1, wL, p, q)
                grid[p, q] = np.log10(val + 1)

        im = ax.imshow(grid, cmap='YlOrRd', origin='lower', aspect='equal')
        ax.set_xlabel('q')
        ax.set_ylabel('p')
        ax.set_title(f'log₁₀(h^{{p,q}} bound)\n{title}', fontsize=10)
        plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle('Hodge Number Bounds: h^{p,q} ≤ C(w₁,p)·C(w_L,q)', fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('hodge_bounds_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: hodge_bounds_visualization.png")


if __name__ == "__main__":
    main()
