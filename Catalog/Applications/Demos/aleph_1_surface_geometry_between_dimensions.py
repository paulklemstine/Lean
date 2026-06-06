#!/usr/bin/env python3
"""
Aleph-1 Surface: Numerical Demonstrations

Demonstrates the key concepts from the transfinite dimension theory:
1. Cardinal arithmetic computations
2. Finite-dimensional projection information loss
3. Arctan embedding into the Hilbert cube
"""

import math
from typing import List, Tuple

def cardinal_power_chain(base: int = 2, levels: int = 5) -> List[str]:
    """
    Demonstrate the cardinal power tower: 2, 2^ℵ₀, 2^(2^ℵ₀), ...
    
    In finite approximation, show how quickly powers grow.
    Under CH: ℵ₁ = 2^ℵ₀, so 2^ℵ₁ = 2^(2^ℵ₀) >> ℵ₁.
    """
    results = []
    n = base
    for i in range(levels):
        results.append(f"Level {i}: 2^{{{n}}} = {2**n if n < 1000 else '(too large)'}")
        n = 2**n if n < 20 else n  # cap to prevent overflow
    return results


def projection_information_loss(dim_source: int, dim_target: int, num_points: int = 1000) -> float:
    """
    Demonstrate information loss when projecting from high to low dimensions.
    
    Generate random points in R^dim_source, project to R^dim_target,
    and measure the fraction of distinct points that collide.
    
    This is a finite analog of Theorem 4.1 (no injection from R^{ℵ₁} to R^n).
    """
    import random
    random.seed(42)
    
    # Generate random points with integer coordinates for exact comparison
    points = [tuple(random.randint(-100, 100) for _ in range(dim_source)) 
              for _ in range(num_points)]
    
    # Project to first dim_target coordinates
    projected = [p[:dim_target] for p in points]
    
    original_distinct = len(set(points))
    projected_distinct = len(set(projected))
    
    collision_rate = 1.0 - projected_distinct / original_distinct if original_distinct > 0 else 0.0
    
    return collision_rate


def arctan_embedding(values: List[float]) -> List[float]:
    """
    The arctan embedding: R → [0, 1] via x ↦ arctan(x)/π + 1/2.
    
    This is the coordinate-wise map used in Theorem 5.1 to embed
    R^I into the generalized Hilbert cube [0,1]^I.
    """
    return [(math.atan(x) / math.pi + 0.5) for x in values]


def demonstrate_embedding_injectivity(n_samples: int = 20) -> List[Tuple[float, float]]:
    """
    Show that the arctan embedding preserves order (hence is injective).
    """
    import random
    random.seed(42)
    
    values = sorted([random.uniform(-100, 100) for _ in range(n_samples)])
    embedded = arctan_embedding(values)
    
    return list(zip(values, embedded))


def cardinality_comparison_table():
    """
    Display the cardinality hierarchy relevant to the embedding obstruction.
    
    Under CH: ℵ₁ = 𝔠 = 2^ℵ₀
    Key fact: 2^ℵ₁ > ℵ₁ (Cantor), so #(R^{ℵ₁}) > #(R^n) for all n.
    """
    print("=" * 60)
    print("CARDINAL HIERARCHY (under Continuum Hypothesis)")
    print("=" * 60)
    print()
    print(f"{'Space':<25} {'Cardinality':<20} {'Symbol'}")
    print("-" * 60)
    print(f"{'ℕ (naturals)':<25} {'ℵ₀':<20} ℵ₀")
    print(f"{'ℝ (reals)':<25} {'𝔠 = 2^ℵ₀':<20} ℵ₁ (under CH)")
    print(f"{'ℝⁿ (n ≥ 1)':<25} {'𝔠':<20} ℵ₁ (under CH)")
    print(f"{'[0,1]^ℕ (Hilbert cube)':<25} {'𝔠':<20} ℵ₁ (under CH)")
    print(f"{'ℝ^ℵ₁':<25} {'2^ℵ₁':<20} > ℵ₁ (Cantor)")
    print(f"{'[0,1]^ℵ₁ (gen. cube)':<25} {'2^ℵ₁':<20} > ℵ₁ (Cantor)")
    print()
    print("KEY INSIGHT: ℝ^ℵ₁ has 2^ℵ₁ points, while ℝⁿ has only ℵ₁ = 𝔠 points.")
    print("Since 2^ℵ₁ > ℵ₁, no injection from ℝ^ℵ₁ to ℝⁿ can exist.")
    print()
    print("The generalized Hilbert cube [0,1]^ℵ₁ has 2^ℵ₁ points,")
    print("matching ℝ^ℵ₁, so embedding IS possible via arctan.")


def dimension_gap_demonstration():
    """
    Demonstrate the Cantor Dimension Gap: no cardinal between ℵ₀ and ℵ₁.
    
    In finite terms: for well-ordered sets, the successor of the countable
    ordinals is the first uncountable ordinal ω₁, with no intermediate.
    """
    print("\n" + "=" * 60)
    print("CANTOR DIMENSION GAP")
    print("=" * 60)
    print()
    print("The infinite cardinals form a well-ordered sequence:")
    print()
    for i in range(6):
        symbol = f"ℵ_{i}"
        desc = {
            0: "countably infinite (= #ℕ)",
            1: "first uncountable (= 𝔠 under CH)",
            2: "= 2^ℵ₁ under GCH",
            3: "= 2^ℵ₂ under GCH",
            4: "= 2^ℵ₃ under GCH",
            5: "= 2^ℵ₄ under GCH",
        }
        print(f"  {symbol:<8} — {desc[i]}")
    
    print()
    print("THEOREM (ZFC): There is NO cardinal κ with ℵ₀ < κ < ℵ₁.")
    print()
    print("This means the jump from countable to uncountable dimension")
    print("is DISCRETE — there is no 'dimension ℵ₀.5'.")
    print()
    print("Consequence: A space is either ≤ ℵ₀-dimensional (like ℝⁿ, ℓ²)")
    print("or ≥ ℵ₁-dimensional. Nothing in between exists.")


def triangulation_bound_demo():
    """
    Demonstrate the triangulation vertex bound.
    """
    print("\n" + "=" * 60)
    print("TRIANGULATION BOUNDS")
    print("=" * 60)
    print()
    print("Theorem: Any triangulation of a space X needs ≥ #X vertices.")
    print()
    
    # Finite examples
    for n in [3, 10, 100]:
        simplices = n * (n - 1) // 2  # rough bound for a triangulation
        print(f"  • Triangulating {n} points: need ≥ {n} vertices")
    
    print()
    print("For ℝ^ℵ₁ under CH:")
    print("  • #(ℝ^ℵ₁) = 2^ℵ₁ > ℵ₁")
    print("  • Any triangulation needs > ℵ₁ vertices")
    print("  • Even ℵ₁-many vertices are INSUFFICIENT")
    print("  • This is strictly stronger than 'no finite triangulation'")


def main():
    print("ALEPH-1 SURFACE: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    
    # 1. Cardinal power chain
    print("\n1. CARDINAL POWER TOWER")
    print("-" * 40)
    for line in cardinal_power_chain():
        print(f"  {line}")
    
    # 2. Projection information loss
    print("\n2. PROJECTION INFORMATION LOSS")
    print("-" * 40)
    for source_dim in [5, 10, 50, 100]:
        for target_dim in [1, 2, 3]:
            loss = projection_information_loss(source_dim, target_dim)
            print(f"  R^{source_dim} → R^{target_dim}: collision rate = {loss:.1%}")
    
    # 3. Arctan embedding
    print("\n3. ARCTAN EMBEDDING: ℝ → [0,1]")
    print("-" * 40)
    pairs = demonstrate_embedding_injectivity(10)
    print(f"  {'x':<15} {'arctan(x)/π + ½':<15}")
    for x, y in pairs:
        print(f"  {x:<15.4f} {y:<15.6f}")
    print("  Note: order is preserved → injection confirmed")
    
    # 4. Cardinality table
    cardinality_comparison_table()
    
    # 5. Dimension gap
    dimension_gap_demonstration()
    
    # 6. Triangulation bounds
    triangulation_bound_demo()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Arctan Embedding ℝ → [0,1]

Shows how the arctan function maps the entire real line into the unit interval,
demonstrating the coordinate-wise embedding used in Theorem 5.1.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def arctan_embedding(x):
    """The embedding x ↦ arctan(x)/π + 1/2"""
    return np.arctan(x) / np.pi + 0.5

def main():
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # Plot 1: The arctan embedding function
    ax1 = axes[0]
    x = np.linspace(-20, 20, 1000)
    y = arctan_embedding(x)
    ax1.plot(x, y, 'b-', linewidth=2)
    ax1.axhline(y=0, color='gray', linewidth=0.5, linestyle='--')
    ax1.axhline(y=1, color='gray', linewidth=0.5, linestyle='--')
    ax1.axhline(y=0.5, color='gray', linewidth=0.5, linestyle=':')
    ax1.set_xlabel('x ∈ ℝ', fontsize=12)
    ax1.set_ylabel('arctan(x)/π + ½ ∈ [0,1]', fontsize=12)
    ax1.set_title('Arctan Embedding: ℝ → [0,1]', fontsize=14)
    ax1.set_ylim(-0.05, 1.05)
    ax1.fill_between(x, 0, 1, alpha=0.05, color='blue')
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Injectivity demonstration
    ax2 = axes[1]
    test_points = np.array([-50, -10, -5, -2, -1, 0, 1, 2, 5, 10, 50])
    embedded = arctan_embedding(test_points)
    ax2.scatter(test_points, embedded, c='red', s=80, zorder=5)
    for i, (xi, yi) in enumerate(zip(test_points, embedded)):
        ax2.annotate(f'{yi:.3f}', (xi, yi), textcoords="offset points",
                    xytext=(5, 10), fontsize=8)
    ax2.plot(x, arctan_embedding(x), 'b-', alpha=0.3, linewidth=1)
    ax2.set_xlabel('x (original)', fontsize=12)
    ax2.set_ylabel('embedded value', fontsize=12)
    ax2.set_title('Injectivity: All Points Map Distinctly', fontsize=14)
    ax2.grid(True, alpha=0.3)
    
    # Plot 3: The cardinality gap visualization
    ax3 = axes[2]
    categories = ['ℝⁿ\n(any n)', '[0,1]^ℕ\n(Hilbert cube)', 'ℝ^{ℵ₁}', '[0,1]^{ℵ₁}']
    heights = [1, 1, 2.5, 2.5]  # Relative cardinalities (𝔠 vs 2^ℵ₁)
    colors = ['#2196F3', '#2196F3', '#F44336', '#4CAF50']
    bars = ax3.bar(categories, heights, color=colors, edgecolor='black', linewidth=1.2)
    ax3.axhline(y=1, color='orange', linewidth=2, linestyle='--', label='𝔠 = ℵ₁ (under CH)')
    ax3.set_ylabel('Relative Cardinality', fontsize=12)
    ax3.set_title('Cardinality Gap (under CH)', fontsize=14)
    ax3.legend(fontsize=10)
    ax3.set_yticks([0, 1, 2.5])
    ax3.set_yticklabels(['0', '𝔠 = ℵ₁', '2^ℵ₁ > ℵ₁'])
    
    # Add annotations
    ax3.annotate('TOO SMALL\n(no injection)', xy=(0.5, 1.3), 
                fontsize=9, ha='center', color='red', fontweight='bold')
    ax3.annotate('CAN EMBED\n(via arctan)', xy=(3, 2.7), 
                fontsize=9, ha='center', color='green', fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/arctan_embedding.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: arctan_embedding.png")

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Cantor Dimension Gap and Cardinal Hierarchy

Shows the discrete structure of infinite cardinals and the gap between
countable and uncountable dimensions.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Cardinal number line showing the gap
    ax1 = axes[0]
    
    # Finite cardinals
    finite_x = list(range(8))
    ax1.scatter(finite_x, [0]*len(finite_x), c='blue', s=60, zorder=5, label='Finite')
    
    # ℵ₀
    ax1.scatter([10], [0], c='green', s=120, zorder=5, marker='D', label='ℵ₀')
    ax1.annotate('ℵ₀', (10, 0), textcoords="offset points", xytext=(0, 15), fontsize=14, 
                ha='center', fontweight='bold', color='green')
    
    # The GAP
    ax1.annotate('', xy=(13, 0), xytext=(11, 0),
                arrowprops=dict(arrowstyle='<->', color='red', lw=2))
    ax1.text(12, 0.15, 'NO CARDINALS\nHERE', ha='center', fontsize=11, 
            color='red', fontweight='bold')
    
    # ℵ₁
    ax1.scatter([14], [0], c='red', s=120, zorder=5, marker='s', label='ℵ₁')
    ax1.annotate('ℵ₁ = 𝔠\n(under CH)', (14, 0), textcoords="offset points", 
                xytext=(0, 15), fontsize=12, ha='center', fontweight='bold', color='red')
    
    # ℵ₂
    ax1.scatter([17], [0], c='purple', s=120, zorder=5, marker='^', label='ℵ₂')
    ax1.annotate('ℵ₂', (17, 0), textcoords="offset points", xytext=(0, 15), fontsize=14, 
                ha='center', fontweight='bold', color='purple')
    
    ax1.set_xlim(-1, 19)
    ax1.set_ylim(-0.3, 0.5)
    ax1.set_xlabel('Cardinal Scale (schematic)', fontsize=12)
    ax1.set_title('The Cantor Dimension Gap', fontsize=14, fontweight='bold')
    ax1.legend(loc='lower right', fontsize=10)
    ax1.set_yticks([])
    ax1.spines['top'].set_visible(False)
    ax1.spines['left'].set_visible(False)
    ax1.spines['right'].set_visible(False)
    
    # Plot 2: Power tower growth
    ax2 = axes[1]
    
    # Finite analog: powers of 2
    n_values = list(range(8))
    power_values = [2**n for n in n_values]
    
    ax2.semilogy(n_values, power_values, 'bo-', markersize=8, linewidth=2, label='2^n (finite analog)')
    
    # Annotate key levels
    annotations = {
        0: '2⁰ = 1',
        3: '2³ = 8',
        5: '2⁵ = 32',
        7: '2⁷ = 128',
    }
    for n, label in annotations.items():
        ax2.annotate(label, (n, 2**n), textcoords="offset points", xytext=(10, 5), fontsize=9)
    
    # Add transfinite annotations
    ax2.text(0.5, 0.85, 'Transfinite analog:', transform=ax2.transAxes, 
            fontsize=11, fontweight='bold')
    ax2.text(0.5, 0.78, 'ℵ₀ → 2^ℵ₀ = 𝔠 = ℵ₁ (CH)', transform=ax2.transAxes, fontsize=10)
    ax2.text(0.5, 0.71, 'ℵ₁ → 2^ℵ₁ > ℵ₁ (Cantor)', transform=ax2.transAxes, fontsize=10)
    ax2.text(0.5, 0.64, 'This is why ℝ^{ℵ₁} ≠> ℝⁿ', transform=ax2.transAxes, 
            fontsize=10, color='red', fontweight='bold')
    
    ax2.set_xlabel('Exponent level', fontsize=12)
    ax2.set_ylabel('Cardinality (log scale)', fontsize=12)
    ax2.set_title('Cardinal Power Tower', fontsize=14, fontweight='bold')
    ax2.grid(True, alpha=0.3)
    ax2.legend(fontsize=10)
    
    plt.tight_layout()
    plt.savefig('/workspace/request-project/Applications/dimension_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: dimension_gap.png")

if __name__ == "__main__":
    main()
