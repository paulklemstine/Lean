#!/usr/bin/env python3
"""
Neural Decision Surface Topology — Demonstration Script

Demonstrates the key mathematical results connecting ReLU network
architecture to decision surface geometry through Zaslavsky's theorem.
"""

from math import comb, factorial, prod
from typing import List, Tuple
import itertools


def zaslavsky(m: int, n: int) -> int:
    """Zaslavsky function: max regions from m hyperplanes in R^n."""
    return sum(comb(m, k) for k in range(n + 1))


def deep_network_bound(widths: List[int], input_dim: int) -> int:
    """Upper bound on linear regions for a deep ReLU network."""
    return prod(zaslavsky(w, input_dim) for w in widths)


def tropical_monomial_count(widths: List[int]) -> int:
    """Number of tropical monomials: product of 2^w_i = 2^N."""
    return prod(2**w for w in widths)


def arrangement_euler_char(m: int, n: int) -> int:
    """Euler characteristic of arrangement complement."""
    return sum((-1)**k * comb(m, k) for k in range(n + 1))


def shallow_bound(N: int, n: int) -> int:
    """Upper bound on regions for a shallow network: (N+1)^n."""
    return (N + 1) ** n


# =============================================================================
# Demo 1: Zaslavsky Recurrence Verification
# =============================================================================
print("=" * 60)
print("Demo 1: Zaslavsky Recurrence Z(m+1,n+1) = Z(m,n+1) + Z(m,n)")
print("=" * 60)
for m in range(6):
    for n in range(6):
        lhs = zaslavsky(m + 1, n + 1)
        rhs = zaslavsky(m, n + 1) + zaslavsky(m, n)
        assert lhs == rhs, f"Recurrence failed at m={m}, n={n}"
print("✓ Verified for all 0 ≤ m, n ≤ 5")
print()

# =============================================================================
# Demo 2: Zaslavsky Table
# =============================================================================
print("=" * 60)
print("Demo 2: Zaslavsky Function Z(m, n)")
print("=" * 60)
header = 'm\\n'
print(f"{header:>4}", end="")
for n in range(8):
    print(f"{n:>6}", end="")
print()
print("-" * 52)
for m in range(8):
    print(f"{m:>4}", end="")
    for n in range(8):
        print(f"{zaslavsky(m, n):>6}", end="")
    print()
print()

# =============================================================================
# Demo 3: Exponential Bound Verification
# =============================================================================
print("=" * 60)
print("Demo 3: Z(m, n) ≤ 2^m (Exponential Bound)")
print("=" * 60)
for m in range(10):
    for n in range(10):
        assert zaslavsky(m, n) <= 2**m
print("✓ Verified for all 0 ≤ m, n ≤ 9")
print()

# =============================================================================
# Demo 4: Full-Dimension Equality
# =============================================================================
print("=" * 60)
print("Demo 4: Z(m, n) = 2^m when m ≤ n")
print("=" * 60)
for m in range(8):
    for n in range(m, 10):
        assert zaslavsky(m, n) == 2**m, f"Failed at m={m}, n={n}"
print("✓ Verified for all m ≤ n ≤ 9")
print()

# =============================================================================
# Demo 5: Depth vs Width Advantage
# =============================================================================
print("=" * 60)
print("Demo 5: Depth vs Width — Exponential Advantage")
print("=" * 60)
input_dim = 3
for total_neurons in [6, 9, 12, 15, 18]:
    # Shallow: one layer of total_neurons neurons
    shallow = zaslavsky(total_neurons, input_dim)
    # Deep: layers of width 3 (equal to input dim)
    num_layers = total_neurons // 3
    deep = deep_network_bound([3] * num_layers, input_dim)
    ratio = deep / shallow if shallow > 0 else float('inf')
    print(f"  N={total_neurons:>2}: Shallow Z({total_neurons},{input_dim}) = {shallow:>8}, "
          f"Deep Z(3,{input_dim})^{num_layers} = {deep:>12}, "
          f"Ratio = {ratio:>8.1f}x")
print()

# =============================================================================
# Demo 6: Concrete Architecture Prediction (2→3→3→1)
# =============================================================================
print("=" * 60)
print("Demo 6: Architecture 2→3→3→1 Prediction")
print("=" * 60)
widths = [3, 3]
input_dim = 2
per_layer = [zaslavsky(w, input_dim) for w in widths]
total = deep_network_bound(widths, input_dim)
print(f"  Input dimension: {input_dim}")
print(f"  Layer widths: {widths}")
print(f"  Per-layer regions: {per_layer}")
print(f"  Total regions (product): {total}")
print(f"  Tropical monomials: {tropical_monomial_count(widths)}")
print(f"  Euler characteristic χ(3,2) = {arrangement_euler_char(3, 2)}")
print()

# =============================================================================
# Demo 7: Shallow Polynomial Bound
# =============================================================================
print("=" * 60)
print("Demo 7: Shallow Bound Z(N, n) ≤ (N+1)^n")
print("=" * 60)
for N in range(1, 20):
    for n in range(1, 8):
        z = zaslavsky(N, n)
        bound = shallow_bound(N, n)
        assert z <= bound, f"Failed at N={N}, n={n}: {z} > {bound}"
print("✓ Verified for all 1 ≤ N ≤ 19, 1 ≤ n ≤ 7")
print()

# =============================================================================
# Demo 8: Activation Pattern Efficiency
# =============================================================================
print("=" * 60)
print("Demo 8: Activation Pattern Efficiency")
print("=" * 60)
print(f"{'N':>4} {'n':>4} {'Z(N,n)':>10} {'2^N':>12} {'Efficiency':>12}")
print("-" * 44)
for N, n in [(10, 2), (20, 3), (50, 5), (100, 10), (200, 20)]:
    z = zaslavsky(N, n)
    total = 2**N
    eff = z / total
    print(f"{N:>4} {n:>4} {z:>10} {total:>12} {eff:>12.2e}")
print()
print("As N >> n, only a vanishing fraction of activation patterns are realizable.")
print()

# =============================================================================
# Demo 9: Tropical Monomial Bound
# =============================================================================
print("=" * 60)
print("Demo 9: Tropical Monomial Bound ∏ 2^(w_i) = 2^N")
print("=" * 60)
architectures = [
    [3, 3],          # 2→3→3→1
    [4, 4, 4],       # 3→4→4→4→1
    [10, 10],        # 5→10→10→1
    [5, 5, 5, 5],    # 3→5→5→5→5→1
]
for widths in architectures:
    N = sum(widths)
    trop = tropical_monomial_count(widths)
    assert trop == 2**N
    print(f"  Widths {str(widths):>20}: N={N:>3}, 2^N = {trop}")
print("✓ All match 2^N")
print()

print("=" * 60)
print("All demonstrations completed successfully.")
print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Zaslavsky Function and Depth-Width Tradeoff

Generates plots showing the Zaslavsky function, the depth-width
expressivity gap, and activation pattern efficiency.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from math import comb, prod

def zaslavsky(m: int, n: int) -> int:
    return sum(comb(m, k) for k in range(n + 1))

# =========================================================================
# Plot 1: Zaslavsky Function Heatmap
# =========================================================================
fig, axes = plt.subplots(1, 3, figsize=(18, 5))

max_val = 12
Z = np.zeros((max_val, max_val))
for m in range(max_val):
    for n in range(max_val):
        Z[m, n] = zaslavsky(m, n)

im = axes[0].imshow(np.log2(Z + 1), origin='lower', cmap='viridis', aspect='equal')
axes[0].set_xlabel('Dimension n')
axes[0].set_ylabel('Hyperplanes m')
axes[0].set_title('log₂(Z(m, n) + 1)')
plt.colorbar(im, ax=axes[0], label='log₂(regions + 1)')

# =========================================================================
# Plot 2: Depth vs Width Advantage
# =========================================================================
input_dim = 3
total_neurons_range = range(3, 31)
shallow_vals = []
deep_vals = []

for N in total_neurons_range:
    shallow_vals.append(zaslavsky(N, input_dim))
    L = N // input_dim
    if L > 0:
        deep_vals.append(zaslavsky(input_dim, input_dim) ** L)
    else:
        deep_vals.append(1)

axes[1].semilogy(list(total_neurons_range), shallow_vals, 'b-o',
                 label=f'Shallow: Z(N, {input_dim})', markersize=3)
axes[1].semilogy(list(total_neurons_range), deep_vals, 'r-s',
                 label=f'Deep: Z({input_dim},{input_dim})^(N/{input_dim})', markersize=3)
axes[1].set_xlabel('Total neurons N')
axes[1].set_ylabel('Max linear regions')
axes[1].set_title('Depth vs Width Advantage (n=3)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# =========================================================================
# Plot 3: Activation Pattern Efficiency
# =========================================================================
dims = [2, 3, 5, 10]
N_range = range(5, 51)

for n in dims:
    effs = [zaslavsky(N, n) / 2**N for N in N_range]
    axes[2].semilogy(list(N_range), effs, '-', label=f'n={n}', linewidth=2)

axes[2].set_xlabel('Total neurons N')
axes[2].set_ylabel('Efficiency Z(N,n) / 2^N')
axes[2].set_title('Activation Pattern Efficiency')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('zaslavsky_analysis.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved zaslavsky_analysis.png")
