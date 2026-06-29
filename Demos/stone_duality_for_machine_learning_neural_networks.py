#!/usr/bin/env python3
"""
Stone Duality for Neural Networks: Demonstration

Computes activation patterns, linear regions, and the Zaslavsky bound
for small ReLU networks, verifying the theoretical predictions.
"""

import numpy as np
from itertools import product
from math import comb

def activation_pattern(weights, biases, x):
    """Compute the activation pattern of x under the arrangement (weights, biases).
    
    Args:
        weights: (m, n) array of weight vectors
        biases: (m,) array of biases
        x: (n,) input point
    
    Returns:
        Tuple of bools: activation pattern
    """
    activations = weights @ x + biases
    return tuple(a > 0 for a in activations)

def count_regions(weights, biases, n_samples=100000, seed=42):
    """Count distinct activation patterns by random sampling.
    
    Args:
        weights: (m, n) array
        biases: (m,) array
        n_samples: number of random samples
        seed: random seed
    
    Returns:
        Set of distinct activation patterns
    """
    rng = np.random.default_rng(seed)
    n = weights.shape[1]
    patterns = set()
    for _ in range(n_samples):
        x = rng.standard_normal(n) * 10
        pat = activation_pattern(weights, biases, x)
        patterns.add(pat)
    return patterns

def zaslavsky_bound(n, m):
    """Compute the Zaslavsky bound: sum_{i=0}^{min(n,m)} C(m, i)"""
    return sum(comb(m, i) for i in range(min(n, m) + 1))

def neural_bool_alg_size(m):
    """Size of the neural Boolean algebra: 2^(2^m)"""
    return 2 ** (2 ** m)

# ============================================================
# Demo 1: Single layer, 3 hyperplanes in R^2
# ============================================================
print("=" * 60)
print("Demo 1: 3 hyperplanes in R^2")
print("=" * 60)

# Random arrangement in general position
np.random.seed(42)
W = np.random.randn(3, 2)
b = np.random.randn(3)

patterns = count_regions(W, b)
zbound = zaslavsky_bound(2, 3)

print(f"  Weights:\n{W}")
print(f"  Biases: {b}")
print(f"  Found {len(patterns)} distinct regions")
print(f"  Zaslavsky bound Z(2, 3) = {zbound}")
print(f"  Maximum possible = 2^3 = {2**3}")
print(f"  Neural Boolean algebra size = 2^(2^3) = {neural_bool_alg_size(3)}")
print()

# Print all patterns
print("  Activation patterns found:")
for i, pat in enumerate(sorted(patterns)):
    print(f"    Region {i+1}: {tuple(int(p) for p in pat)}")
print()

# ============================================================
# Demo 2: Scaling behavior
# ============================================================
print("=" * 60)
print("Demo 2: Zaslavsky bound vs actual regions")
print("=" * 60)

for n_dim in [2, 3, 5]:
    print(f"\n  Input dimension n = {n_dim}:")
    for m_hyp in [2, 3, 5, 10, 20]:
        W = np.random.randn(m_hyp, n_dim)
        b = np.random.randn(m_hyp)
        patterns = count_regions(W, b, n_samples=200000)
        zb = zaslavsky_bound(n_dim, m_hyp)
        print(f"    m={m_hyp:3d}: found {len(patterns):6d} regions, "
              f"Zaslavsky bound = {zb:6d}, 2^m = {2**m_hyp:10d}")

# ============================================================
# Demo 3: Refinement under composition
# ============================================================
print("\n" + "=" * 60)
print("Demo 3: Refinement under composition")
print("=" * 60)

n = 2
W1 = np.random.randn(3, n)
b1 = np.random.randn(3)
W2 = np.random.randn(3, n)
b2 = np.random.randn(3)

# Combined arrangement
W_combined = np.vstack([W1, W2])
b_combined = np.concatenate([b1, b2])

patterns_1 = count_regions(W1, b1)
patterns_2 = count_regions(W2, b2)
patterns_combined = count_regions(W_combined, b_combined)

print(f"  Arrangement 1: {len(patterns_1)} regions")
print(f"  Arrangement 2: {len(patterns_2)} regions")
print(f"  Combined:      {len(patterns_combined)} regions")
print(f"  Product bound:  {len(patterns_1) * len(patterns_2)}")
print(f"  Zaslavsky Z(2,6) = {zaslavsky_bound(2, 6)}")

# ============================================================
# Demo 4: Sauer-Shelah bound verification
# ============================================================
print("\n" + "=" * 60)
print("Demo 4: Sauer-Shelah bound")
print("=" * 60)

for d in range(1, 8):
    for n_val in [5, 10, 20]:
        bound = sum(comb(n_val, i) for i in range(d + 1))
        total = 2 ** n_val
        print(f"  d={d}, n={n_val}: sum C(n,i) = {bound:8d}, "
              f"2^n = {total:10d}, ratio = {bound/total:.6f}")
    print()

# ============================================================
# Demo 5: Stone duality - Boolean algebra structure
# ============================================================
print("=" * 60)
print("Demo 5: Boolean algebra of regions")
print("=" * 60)

W = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 1.0]])
b = np.array([0.0, 0.0, 0.0])

patterns = count_regions(W, b, n_samples=500000)
print(f"  3 hyperplanes through origin in R^2")
print(f"  Found {len(patterns)} regions (Zaslavsky bound = {zaslavsky_bound(2, 3)})")
print(f"  Boolean algebra has 2^{len(patterns)} = {2**len(patterns)} elements")
print(f"  Each element is a union of regions = a decision region")
print()

# Show Boolean operations
pats = sorted(patterns)
for i, p1 in enumerate(pats):
    for j, p2 in enumerate(pats):
        if i < j:
            # Union = set of two patterns
            union_name = f"R_{{{i+1}}} ∪ R_{{{j+1}}}"
            # Complement of p1 = all other patterns
            comp_name = f"R_{{{i+1}}}ᶜ"
    if i == 0:
        print(f"  Example atom: R_1 = region with pattern {tuple(int(p) for p in pats[0])}")
        print(f"  |R_1| in Boolean algebra = singleton {{{tuple(int(p) for p in pats[0])}}}")
        print(f"  R_1ᶜ in Boolean algebra = all other {len(pats)-1} patterns")

print("\nDone! All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Hyperplane arrangement regions in R^2

Shows the partition of the plane by hyperplanes and colors each
region by its activation pattern.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from math import comb


def activation_pattern(weights, biases, x):
    activations = weights @ x + biases
    return tuple(a > 0 for a in activations)


def zaslavsky_bound(n, m):
    return sum(comb(m, i) for i in range(min(n, m) + 1))


def plot_hyperplane_regions(weights, biases, xlim=(-5, 5), ylim=(-5, 5),
                            resolution=500, title=None):
    """Plot the regions of a 2D hyperplane arrangement."""
    m, n = weights.shape
    assert n == 2, "Only 2D arrangements supported"
    
    # Create grid
    x = np.linspace(xlim[0], xlim[1], resolution)
    y = np.linspace(ylim[0], ylim[1], resolution)
    X, Y = np.meshgrid(x, y)
    
    # Compute patterns for each grid point
    patterns = {}
    Z = np.zeros((resolution, resolution), dtype=int)
    
    for i in range(resolution):
        for j in range(resolution):
            pt = np.array([X[i, j], Y[i, j]])
            pat = activation_pattern(weights, biases, pt)
            if pat not in patterns:
                patterns[pat] = len(patterns)
            Z[i, j] = patterns[pat]
    
    # Plot
    fig, ax = plt.subplots(1, 1, figsize=(10, 8))
    
    # Color regions
    cmap = plt.cm.Set3
    ax.contourf(X, Y, Z, levels=np.arange(-0.5, len(patterns) + 0.5, 1),
                cmap=cmap, alpha=0.7)
    
    # Draw hyperplanes
    for j in range(m):
        w = weights[j]
        b_val = biases[j]
        if abs(w[1]) > 1e-10:
            x_line = np.linspace(xlim[0], xlim[1], 100)
            y_line = -(w[0] * x_line + b_val) / w[1]
            mask = (y_line >= ylim[0]) & (y_line <= ylim[1])
            ax.plot(x_line[mask], y_line[mask], 'k-', linewidth=2,
                    label=f'H_{j+1}: {w[0]:.1f}x + {w[1]:.1f}y + {b_val:.1f} = 0')
        elif abs(w[0]) > 1e-10:
            x_val = -b_val / w[0]
            ax.axvline(x=x_val, color='k', linewidth=2,
                       label=f'H_{j+1}: x = {x_val:.1f}')
    
    ax.set_xlim(xlim)
    ax.set_ylim(ylim)
    ax.set_xlabel('x₁', fontsize=14)
    ax.set_ylabel('x₂', fontsize=14)
    
    if title is None:
        title = (f'{m} hyperplanes in ℝ²: {len(patterns)} regions '
                 f'(Zaslavsky bound = {zaslavsky_bound(2, m)})')
    ax.set_title(title, fontsize=16)
    ax.legend(loc='upper right', fontsize=10)
    
    # Add region labels
    for pat, idx in patterns.items():
        # Find centroid of region
        mask = Z == idx
        if mask.any():
            cy, cx = np.where(mask)
            cx_val = X[0, int(np.mean(cx))]
            cy_val = Y[int(np.mean(cy)), 0]
            label = ''.join(str(int(p)) for p in pat)
            ax.annotate(label, (cx_val, cy_val), fontsize=9,
                       ha='center', va='center',
                       bbox=dict(boxstyle='round,pad=0.3',
                                facecolor='white', alpha=0.8))
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    # Example 1: 3 hyperplanes in general position
    W = np.array([[1.0, 0.5], [-0.3, 1.0], [0.8, -0.6]])
    b = np.array([0.5, -0.3, 0.2])
    fig1 = plot_hyperplane_regions(W, b, title="3 Hyperplanes in General Position")
    fig1.savefig("regions_3hyp.png", dpi=150, bbox_inches='tight')
    
    # Example 2: 5 hyperplanes
    np.random.seed(123)
    W2 = np.random.randn(5, 2)
    b2 = np.random.randn(5) * 0.5
    fig2 = plot_hyperplane_regions(W2, b2, title="5 Hyperplanes in ℝ²")
    fig2.savefig("regions_5hyp.png", dpi=150, bbox_inches='tight')
    
    # Example 3: Axis-aligned (degenerate)
    W3 = np.array([[1.0, 0.0], [0.0, 1.0], [1.0, 0.0]])
    b3 = np.array([0.0, 0.0, -2.0])
    fig3 = plot_hyperplane_regions(
        W3, b3, 
        title="Degenerate: 3 hyperplanes, only 6 regions (< Zaslavsky bound 7)")
    fig3.savefig("regions_degenerate.png", dpi=150, bbox_inches='tight')
    
    plt.show()
    print("Visualizations saved to regions_*.png")


#!/usr/bin/env python3
"""
Visualization: Zaslavsky bound vs actual regions and 2^m

Shows how the Zaslavsky bound grows with m for different dimensions n,
compared to the exponential 2^m.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def zaslavsky_bound(n, m):
    return sum(comb(m, i) for i in range(min(n, m) + 1))


def plot_zaslavsky_comparison():
    """Plot Zaslavsky bound for various dimensions."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    m_values = np.arange(1, 25)
    
    # Left plot: absolute values
    ax = axes[0]
    for n in [1, 2, 3, 5, 10]:
        bounds = [zaslavsky_bound(n, m) for m in m_values]
        ax.semilogy(m_values, bounds, 'o-', label=f'n = {n}', markersize=4)
    
    two_pow = [2**m for m in m_values]
    ax.semilogy(m_values, two_pow, 'k--', linewidth=2, label='2^m (upper bound)')
    
    ax.set_xlabel('m (number of hyperplanes)', fontsize=14)
    ax.set_ylabel('Maximum regions (log scale)', fontsize=14)
    ax.set_title('Zaslavsky Bound Z(n,m) vs Number of Hyperplanes', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Right plot: ratio Z(n,m) / 2^m
    ax = axes[1]
    for n in [1, 2, 3, 5, 10]:
        ratios = [zaslavsky_bound(n, m) / (2**m) for m in m_values]
        ax.plot(m_values, ratios, 'o-', label=f'n = {n}', markersize=4)
    
    ax.axhline(y=1.0, color='k', linestyle='--', linewidth=1)
    ax.set_xlabel('m (number of hyperplanes)', fontsize=14)
    ax.set_ylabel('Z(n,m) / 2^m', fontsize=14)
    ax.set_title('Fraction of Realizable Patterns', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 1.1)
    
    plt.tight_layout()
    return fig


def plot_sauer_shelah():
    """Plot the Sauer-Shelah bound for various VC dimensions."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    n_values = np.arange(1, 30)
    
    for d in [1, 2, 3, 5, 10]:
        bounds = [sum(comb(n, i) for i in range(d + 1)) for n in n_values]
        ax.semilogy(n_values, bounds, 'o-', label=f'd = {d}', markersize=4)
    
    two_pow = [2**n for n in n_values]
    ax.semilogy(n_values, two_pow, 'k--', linewidth=2, label='2^n')
    
    ax.set_xlabel('n (number of points)', fontsize=14)
    ax.set_ylabel('Growth function bound (log scale)', fontsize=14)
    ax.set_title('Sauer-Shelah Bound: Σ C(n,i) for i ≤ d', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    return fig


if __name__ == "__main__":
    fig1 = plot_zaslavsky_comparison()
    fig1.savefig("zaslavsky_bound.png", dpi=150, bbox_inches='tight')
    
    fig2 = plot_sauer_shelah()
    fig2.savefig("sauer_shelah_bound.png", dpi=150, bbox_inches='tight')
    
    plt.show()
    print("Visualizations saved.")
