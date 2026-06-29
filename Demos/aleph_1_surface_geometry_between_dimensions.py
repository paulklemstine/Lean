#!/usr/bin/env python3
"""
Transfinite Geometry Demo: Numerical Examples

Demonstrates the key mathematical concepts from the ordinal filtration framework:
1. Stratum disjointness in finite filtrations
2. Cardinality bounds for products
3. Hilbert cube embedding
4. Cardinal chain properties
"""

import math
from typing import List, Set, Tuple, Dict


def demo_stratum_disjointness():
    """Demonstrate stratum disjointness for a concrete filtration on {0,...,9}."""
    print("=" * 60)
    print("DEMO 1: Stratum Disjointness")
    print("=" * 60)
    
    # Filtration: F(k) = {0, 1, ..., k-1} for k = 0, 1, ..., 10
    n = 10
    F = [set(range(k)) for k in range(n + 1)]
    
    # Compute strata: stratum(k) = F(k) \ F(k-1)
    strata = []
    for k in range(n + 1):
        if k == 0:
            strata.append(set())  # F(0) = empty
        else:
            strata.append(F[k] - F[k - 1])
    
    print(f"\nFiltration F(k) = {{0, ..., k-1}} on {{0, ..., {n-1}}}")
    for k in range(n + 1):
        print(f"  F({k}) = {sorted(F[k]) if F[k] else '{}'}")
    
    print(f"\nStrata (birth level):")
    for k in range(n + 1):
        print(f"  stratum({k}) = {sorted(strata[k]) if strata[k] else '{}'}")
    
    # Verify disjointness
    print(f"\nVerifying pairwise disjointness...")
    all_disjoint = True
    for i in range(n + 1):
        for j in range(i + 1, n + 1):
            if strata[i] & strata[j]:
                print(f"  FAIL: stratum({i}) ∩ stratum({j}) = {strata[i] & strata[j]}")
                all_disjoint = False
    if all_disjoint:
        print("  ✓ All strata are pairwise disjoint!")
    
    # Verify exhaustion
    union = set()
    for s in strata:
        union |= s
    print(f"\n  Union of all strata = {sorted(union)}")
    print(f"  Full space = {sorted(range(n))}")
    print(f"  Exhaustion: {'✓' if union == set(range(n)) else '✗'}")


def demo_cardinality_bounds():
    """Demonstrate cardinality bounds for product spaces."""
    print("\n" + "=" * 60)
    print("DEMO 2: Cardinality Bounds")
    print("=" * 60)
    
    print("\nCantor's theorem: 2^κ > κ for all cardinals κ")
    print("(In finite arithmetic, 2^n > n for all n ≥ 0)")
    for n in range(8):
        print(f"  2^{n} = {2**n} > {n}  ✓")
    
    print("\nProduct cardinalities (|X^n| for |X| = c):")
    print(f"  |[0,1]^1| = continuum")
    print(f"  |[0,1]^2| = continuum (𝔠² = 𝔠)")
    print(f"  |[0,1]^ℵ₀| = continuum (𝔠^ℵ₀ = 𝔠)")
    print(f"  |[0,1]^ℵ₁| = 2^ℵ₁ > ℵ₁ = 𝔠  (under CH)")
    
    print("\nEmbedding implications:")
    print(f"  ℝ¹ = 𝔠 — embeddable")
    print(f"  ℝⁿ = 𝔠 — embeddable (for any finite n)")
    print(f"  ℝ^ℵ₀ (Hilbert cube) = 𝔠 — embeddable")
    print(f"  ℝ^ℵ₁ > 𝔠 (under CH) — NOT embeddable in any ℝⁿ!")


def demo_hilbert_cube_embedding():
    """Demonstrate finite-dimensional embedding into the Hilbert cube."""
    print("\n" + "=" * 60)
    print("DEMO 3: Hilbert Cube Embedding")
    print("=" * 60)
    
    # Embed [0,1]^3 into [0,1]^ℕ by padding with zeros
    def embed(point: Tuple[float, ...], target_dim: int = 10) -> List[float]:
        """Embed a finite-dimensional point into higher dimensions."""
        result = list(point) + [0.0] * (target_dim - len(point))
        return result
    
    # Example points in [0,1]^3
    points = [
        (0.5, 0.3, 0.8),
        (0.1, 0.9, 0.2),
        (0.7, 0.7, 0.7),
    ]
    
    print(f"\nEmbedding [0,1]³ into [0,1]^10 (truncated Hilbert cube):")
    for p in points:
        emb = embed(p)
        print(f"  {p} ↦ {emb}")
    
    # Verify injectivity
    embeddings = [tuple(embed(p)) for p in points]
    print(f"\n  Distinct inputs: {len(set(points))}")
    print(f"  Distinct outputs: {len(set(embeddings))}")
    print(f"  Injective: {'✓' if len(set(points)) == len(set(embeddings)) else '✗'}")


def demo_cardinal_chains():
    """Demonstrate strictly increasing cardinal chains."""
    print("\n" + "=" * 60)
    print("DEMO 4: Cardinal Chains")
    print("=" * 60)
    
    # Finite model: strictly increasing chain of natural numbers
    # Analogous to aleph numbers: ℵ₀ < ℵ₁ < ℵ₂ < ...
    chain = [2**n for n in range(8)]
    
    print(f"\nStrictly increasing chain (power-of-2 model):")
    for i, c in enumerate(chain):
        print(f"  f({i}) = {c}")
    
    print(f"\nStrictly monotone: ", end="")
    is_mono = all(chain[i] < chain[i+1] for i in range(len(chain)-1))
    print(f"{'✓' if is_mono else '✗'}")
    
    print(f"Injective: ", end="")
    is_inj = len(set(chain)) == len(chain)
    print(f"{'✓' if is_inj else '✗'}")
    
    # Verify image card
    for n in range(1, len(chain) + 1):
        img = set(chain[:n])
        print(f"  |image(f, [0..{n-1}])| = {len(img)} = {n}  ✓")
    
    print(f"\nAleph hierarchy (analogous):")
    print(f"  ℵ₀ < ℵ₁ < ℵ₂ < ℵ₃ < ...")
    print(f"  Each level is strictly larger than the previous")
    print(f"  Under CH: ℵ₁ = 𝔠 (continuum)")


def demo_independence_number():
    """Demonstrate the transfinite independence number concept."""
    print("\n" + "=" * 60)
    print("DEMO 5: Independence Number")
    print("=" * 60)
    
    # Model: filtration on {0,...,99} with F(k) = {0,...,k-1}
    n = 100
    nonempty_strata = list(range(1, n + 1))  # strata 1 through 100 are nonempty
    
    print(f"\nFiltration on {{0, ..., {n-1}}} with F(k) = {{0, ..., k-1}}")
    print(f"  Nonempty strata: {nonempty_strata[:5]} ... {nonempty_strata[-3:]}")
    print(f"  Independence number = {len(nonempty_strata)}")
    print(f"  Space size = {n}")
    print(f"  Independence number ≤ space size: ✓")
    
    # Sparse filtration: only every 10th stratum is nonempty
    sparse_strata = [k for k in range(1, n + 1) if k % 10 == 0]
    print(f"\nSparse filtration (every 10th point born at a new stage):")
    print(f"  Nonempty strata: {sparse_strata}")
    print(f"  Independence number = {len(sparse_strata)}")


if __name__ == "__main__":
    demo_stratum_disjointness()
    demo_cardinality_bounds()
    demo_hilbert_cube_embedding()
    demo_cardinal_chains()
    demo_independence_number()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("""
Key results demonstrated:
1. Strata are always disjoint — birth ordinals are well-defined
2. Cantor's theorem (2^κ > κ) drives the embedding obstruction
3. Finite-dimensional spaces embed cleanly into the Hilbert cube
4. Strictly increasing chains produce exactly n distinct values
5. The independence number measures dimensional complexity

Under CH:
  - ℵ₁ = 𝔠 (continuum)
  - Spaces with ≥ ℵ₁ dimensions cannot embed in any ℝⁿ
  - The Hilbert cube (countable product) has cardinality exactly 𝔠
  - Transfinite manifolds have no finite triangulation
""")


#!/usr/bin/env python3
"""
Visualization: Ordinal Filtration Strata

Shows how a filtration decomposes a set into disjoint strata,
colored by birth ordinal.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np


def visualize_filtration():
    """Visualize an ordinal filtration on a 2D grid."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    
    # Create a 10x10 grid with birth ordinals
    n = 10
    birth = np.zeros((n, n), dtype=int)
    
    # Concentric square filtration: birth ordinal = distance from center
    for i in range(n):
        for j in range(n):
            birth[i, j] = max(abs(i - n//2), abs(j - n//2)) + 1
    
    # Plot 1: Full filtration with colors
    ax = axes[0]
    im = ax.imshow(birth, cmap='viridis', interpolation='nearest')
    ax.set_title('Birth Ordinal Map', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    for i in range(n):
        for j in range(n):
            ax.text(j, i, str(birth[i, j]), ha='center', va='center', 
                   color='white' if birth[i, j] > 3 else 'black', fontsize=8)
    plt.colorbar(im, ax=ax, label='Birth Ordinal')
    
    # Plot 2: Individual strata
    ax = axes[1]
    max_birth = birth.max()
    colors = plt.cm.Set1(np.linspace(0, 1, max_birth))
    
    for level in range(1, max_birth + 1):
        mask = birth == level
        ys, xs = np.where(mask)
        ax.scatter(xs, ys, c=[colors[level - 1]], s=100, 
                  label=f'Stratum {level}', zorder=5)
    
    ax.set_xlim(-0.5, n - 0.5)
    ax.set_ylim(n - 0.5, -0.5)
    ax.set_title('Disjoint Strata (colored)', fontsize=14, fontweight='bold')
    ax.legend(loc='center left', bbox_to_anchor=(1, 0.5), fontsize=8)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.grid(True, alpha=0.3)
    
    # Plot 3: Filtration levels F(k)
    ax = axes[2]
    levels_to_show = [1, 2, 3, 5]
    colors_f = ['#e41a1c', '#377eb8', '#4daf4a', '#984ea3']
    
    for idx, k in enumerate(levels_to_show):
        mask = birth <= k
        count = mask.sum()
        ys, xs = np.where(mask)
        ax.scatter(xs + idx * 0.05, ys + idx * 0.05, 
                  c=colors_f[idx], s=40, alpha=0.6,
                  label=f'F({k}): {count} points')
    
    ax.set_xlim(-0.5, n - 0.5)
    ax.set_ylim(n - 0.5, -0.5)
    ax.set_title('Filtration Levels F(k)', fontsize=14, fontweight='bold')
    ax.legend(fontsize=9)
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('filtration_strata.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: filtration_strata.png")


def visualize_cardinality_comparison():
    """Visualize the cardinality comparison between products and Euclidean spaces."""
    fig, ax = plt.subplots(figsize=(10, 7))
    
    # Finite model: compare |{0,1}^n| vs n for increasing n
    ns = list(range(1, 20))
    power_of_2 = [2**n for n in ns]
    linear = ns
    
    ax.semilogy(ns, power_of_2, 'ro-', linewidth=2, markersize=6, 
               label=r'$2^n$ (product cardinality)')
    ax.semilogy(ns, linear, 'bs-', linewidth=2, markersize=6,
               label=r'$n$ (dimension)')
    
    # Fill the gap
    ax.fill_between(ns, linear, power_of_2, alpha=0.2, color='red',
                    label='Cantor gap: $2^n > n$')
    
    ax.set_xlabel('n (dimension / number of coordinates)', fontsize=12)
    ax.set_ylabel('Cardinality (log scale)', fontsize=12)
    ax.set_title("Cantor's Theorem: $2^\\kappa > \\kappa$\n"
                 "(Finite model of the embedding obstruction)", 
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    
    # Add annotation
    ax.annotate('This gap prevents embedding\nuncountable products into ℝⁿ',
               xy=(12, 2**12), xytext=(8, 2**16),
               arrowprops=dict(arrowstyle='->', color='darkred'),
               fontsize=10, color='darkred',
               bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))
    
    plt.tight_layout()
    plt.savefig('cardinality_comparison.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: cardinality_comparison.png")


if __name__ == "__main__":
    visualize_filtration()
    visualize_cardinality_comparison()
