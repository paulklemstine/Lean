#!/usr/bin/env python3
"""
Neural Hodge Theory: Numerical Demonstrations

Demonstrates the Zaslavsky bound, depth amplification theorem,
and Hodge-type bounds for ReLU neural network decision surfaces.
"""

import math
from typing import List, Tuple


def zaslavsky_bound(m: int, n: int) -> int:
    """Maximum number of regions created by m hyperplanes in R^n."""
    return sum(math.comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim: int, layer_widths: List[int]) -> int:
    """Multiplicative region bound for a ReLU network."""
    bound = 1
    for w in layer_widths:
        bound *= zaslavsky_bound(w, input_dim)
    return bound


def hodge_bound(layer_widths: List[int], p: int, q: int) -> int:
    """Hodge-type bound h^{p,q} for a network with ≥ 2 layers."""
    if len(layer_widths) < 2:
        return 1
    w1, wL = layer_widths[0], layer_widths[-1]
    middle_prod = 1
    for w in layer_widths[1:-1]:
        middle_prod *= w
    return math.comb(w1, p) * math.comb(wL, q) * middle_prod


def demo_zaslavsky_recurrence():
    """Verify: Z(m+1, n) = Z(m, n) + Z(m, n-1) for n ≥ 1."""
    print("=" * 60)
    print("ZASLAVSKY RECURRENCE: Z(m+1,n) = Z(m,n) + Z(m,n-1)")
    print("=" * 60)
    for m in range(6):
        for n in range(1, 6):
            lhs = zaslavsky_bound(m + 1, n)
            rhs = zaslavsky_bound(m, n) + zaslavsky_bound(m, n - 1)
            status = "✓" if lhs == rhs else "✗"
            print(f"  {status} Z({m+1},{n}) = {lhs} = {zaslavsky_bound(m,n)} + {zaslavsky_bound(m,n-1)} = {rhs}")
    print()


def demo_depth_amplification():
    """Compare depth-L width-w vs depth-1 width-(w*L) networks."""
    print("=" * 60)
    print("DEPTH AMPLIFICATION THEOREM")
    print("=" * 60)
    input_dim = 5
    print(f"Input dimension: {input_dim}\n")
    print(f"{'Architecture':<25} {'Neurons':<10} {'Region Bound':<20} {'Upper Bound':<20}")
    print("-" * 75)

    for w, L in [(4, 1), (4, 2), (4, 3), (4, 5), (4, 10),
                  (10, 1), (10, 2), (10, 5),
                  (20, 1), (20, 2), (20, 5)]:
        layers = [w] * L
        neurons = w * L
        bound = network_region_bound(input_dim, layers)
        upper = ((w + 1) ** input_dim) ** L
        arch_str = f"[{w}]×{L}"
        print(f"  {arch_str:<23} {neurons:<10} {bound:<20} {upper:<20}")

    print("\nComparing same neuron budget: depth vs width")
    print("-" * 75)
    total_neurons = 20
    for L in [1, 2, 4, 5, 10, 20]:
        w = total_neurons // L
        if w < 1:
            continue
        layers = [w] * L
        bound = network_region_bound(input_dim, layers)
        arch_str = f"width={w}, depth={L}"
        print(f"  {arch_str:<30} bound = {bound:>15,}")
    print()


def demo_hodge_bounds():
    """Demonstrate Hodge-type bounds for various architectures."""
    print("=" * 60)
    print("HODGE-TYPE BOUNDS: h^{p,q} ≤ C(w₁,p)·C(w_L,q)·∏w_i")
    print("=" * 60)

    architectures = [
        ([4, 4], "2-layer, width 4"),
        ([8, 8], "2-layer, width 8"),
        ([4, 6, 4], "3-layer, [4,6,4]"),
        ([8, 16, 8], "3-layer, [8,16,8]"),
        ([4, 4, 4, 4], "4-layer, width 4"),
    ]

    for layers, desc in architectures:
        total = sum(layers)
        print(f"\n  Architecture: {desc} (layers={layers}, neurons={total})")
        print(f"  2^neurons = {2**total}")
        print(f"  {'(p,q)':<10} {'h^{p,q} bound':<15} {'≤ 2^neurons?'}")
        for p in range(min(4, layers[0] + 1)):
            for q in range(min(4, layers[-1] + 1)):
                hb = hodge_bound(layers, p, q)
                check = "✓" if hb <= 2**total else "✗"
                print(f"  ({p},{q})      {hb:<15} {check}")
    print()


def demo_euler_characteristic():
    """Demonstrate the Euler characteristic bound."""
    print("=" * 60)
    print("EULER CHARACTERISTIC: |χ| ≤ total faces")
    print("=" * 60)

    # Example f-vectors of polyhedral complexes
    examples = [
        ([1, 3, 2], "Triangle (1 vertex, 3 edges, 2 faces)"),
        ([4, 6, 4, 1], "Tetrahedron boundary"),
        ([8, 12, 6], "Cube boundary"),
        ([6, 12, 8], "Octahedron boundary"),
        ([12, 30, 20], "Icosahedron boundary"),
        ([10, 20, 15, 4], "4D simplex boundary"),
    ]

    for fvec, desc in examples:
        total = sum(fvec)
        euler = sum((-1)**k * f for k, f in enumerate(fvec))
        check = "✓" if abs(euler) <= total else "✗"
        print(f"  {desc}")
        print(f"    f-vector: {fvec}")
        print(f"    total faces: {total}, χ = {euler}, |χ| ≤ total: {check}")
    print()


def demo_polynomial_bound():
    """Demonstrate Z(m,n) ≤ (m+1)^n."""
    print("=" * 60)
    print("POLYNOMIAL BOUND: Z(m,n) ≤ (m+1)^n")
    print("=" * 60)
    print(f"  {'m':<5} {'n':<5} {'Z(m,n)':<12} {'(m+1)^n':<12} {'ratio':<10}")
    print("  " + "-" * 44)
    for m in [1, 2, 5, 10, 20, 50]:
        for n in [1, 2, 3, 5]:
            z = zaslavsky_bound(m, n)
            upper = (m + 1) ** n
            ratio = z / upper if upper > 0 else 0
            print(f"  {m:<5} {n:<5} {z:<12} {upper:<12} {ratio:<10.4f}")
    print()


if __name__ == "__main__":
    demo_zaslavsky_recurrence()
    demo_depth_amplification()
    demo_hodge_bounds()
    demo_euler_characteristic()
    demo_polynomial_bound()


#!/usr/bin/env python3
"""
Visualization: Depth Amplification Theorem

Shows how region count grows exponentially with depth for fixed width,
and compares depth vs. width tradeoffs for a fixed neuron budget.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def zaslavsky_bound(m: int, n: int) -> int:
    return sum(math.comb(m, k) for k in range(n + 1))


def network_region_bound(input_dim: int, layer_widths: list) -> int:
    bound = 1
    for w in layer_widths:
        bound *= zaslavsky_bound(w, input_dim)
    return bound


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Region bound vs depth for fixed width
ax = axes[0]
input_dim = 3
for w in [2, 4, 6, 8]:
    depths = list(range(1, 12))
    bounds = [math.log10(network_region_bound(input_dim, [w] * L)) for L in depths]
    ax.plot(depths, bounds, 'o-', label=f'w={w}', linewidth=2, markersize=5)

ax.set_xlabel('Depth (L)', fontsize=12)
ax.set_ylabel('log₁₀(Region Bound)', fontsize=12)
ax.set_title(f'Region Bound vs Depth (n={input_dim})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Depth vs width tradeoff for fixed neuron budget
ax = axes[1]
for budget in [10, 20, 40, 60]:
    widths_list = []
    bounds_list = []
    for L in range(1, budget + 1):
        w = budget // L
        if w < 1:
            break
        bound = network_region_bound(input_dim, [w] * L)
        widths_list.append(L)
        bounds_list.append(math.log10(bound))
    ax.plot(widths_list, bounds_list, 'o-', label=f'{budget} neurons',
            linewidth=2, markersize=4)

ax.set_xlabel('Depth (L)', fontsize=12)
ax.set_ylabel('log₁₀(Region Bound)', fontsize=12)
ax.set_title(f'Depth vs Width Tradeoff (n={input_dim})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 3: Hodge bounds heatmap
ax = axes[2]
layer_widths = [8, 12, 8]
max_pq = 6
hodge_matrix = np.zeros((max_pq + 1, max_pq + 1))
for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        w1, wL = layer_widths[0], layer_widths[-1]
        middle = math.prod(layer_widths[1:-1]) if len(layer_widths) > 2 else 1
        hb = math.comb(w1, p) * math.comb(wL, q) * middle
        hodge_matrix[p, q] = math.log10(max(hb, 1))

im = ax.imshow(hodge_matrix, cmap='YlOrRd', origin='lower')
ax.set_xlabel('q', fontsize=12)
ax.set_ylabel('p', fontsize=12)
ax.set_title(f'log₁₀(Hodge Bound) for {layer_widths}', fontsize=14)
plt.colorbar(im, ax=ax, shrink=0.8)

for p in range(max_pq + 1):
    for q in range(max_pq + 1):
        val = hodge_matrix[p, q]
        ax.text(q, p, f'{val:.1f}', ha='center', va='center', fontsize=7,
                color='white' if val > 2 else 'black')

plt.tight_layout()
plt.savefig('depth_amplification.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved depth_amplification.png")


#!/usr/bin/env python3
"""
Visualization: Zaslavsky Bound Properties

Demonstrates the recurrence, growth rates, and bounds
of the Zaslavsky region-counting function.
"""

import math
import matplotlib.pyplot as plt
import numpy as np


def zaslavsky_bound(m: int, n: int) -> int:
    return sum(math.comb(m, k) for k in range(n + 1))


fig, axes = plt.subplots(1, 3, figsize=(18, 5))

# Plot 1: Z(m, n) vs m for various n
ax = axes[0]
ms = list(range(1, 25))
for n in [1, 2, 3, 4, 5]:
    zs = [zaslavsky_bound(m, n) for m in ms]
    ax.plot(ms, zs, 'o-', label=f'n={n}', markersize=4, linewidth=2)

ax.set_xlabel('m (hyperplanes)', fontsize=12)
ax.set_ylabel('Z(m, n)', fontsize=12)
ax.set_title('Zaslavsky Bound Z(m,n)', fontsize=14)
ax.set_yscale('log')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Plot 2: Ratio Z(m,n) / (m+1)^n → tightness of polynomial bound
ax = axes[1]
ms = list(range(1, 30))
for n in [2, 3, 4, 5]:
    ratios = [zaslavsky_bound(m, n) / ((m + 1) ** n) for m in ms]
    ax.plot(ms, ratios, '-', label=f'n={n}', linewidth=2)

ax.set_xlabel('m (hyperplanes)', fontsize=12)
ax.set_ylabel('Z(m,n) / (m+1)ⁿ', fontsize=12)
ax.set_title('Tightness of Polynomial Bound', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 1.1)

# Plot 3: Recurrence visualization
ax = axes[2]
n = 4
ms = list(range(0, 15))
z_vals = [zaslavsky_bound(m, n) for m in ms]
z_prev = [zaslavsky_bound(m, n - 1) for m in ms]
z_diff = [z_vals[i + 1] - z_vals[i] for i in range(len(ms) - 1)]

ax.bar(ms[:-1], z_diff, alpha=0.6, label='Z(m+1,n) - Z(m,n)', color='steelblue')
ax.plot(ms, z_prev, 'ro-', label=f'Z(m, {n-1})', markersize=5, linewidth=2)
ax.set_xlabel('m', fontsize=12)
ax.set_ylabel('Value', fontsize=12)
ax.set_title(f'Zaslavsky Recurrence (n={n})', fontsize=14)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zaslavsky_bounds.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved zaslavsky_bounds.png")
