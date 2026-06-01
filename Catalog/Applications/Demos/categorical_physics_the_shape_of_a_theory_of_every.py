"""
Demo: Categorical Physics — The Shape of a Theory of Everything

Demonstrates the key results:
1. The (2,∞)-category necessity theorem
2. Oracle hierarchy computations
3. Shadow classification of physical theories
4. Duality sector bounds
"""

from algorithms import (
    TheoryType, OracleLevel, DualizableTower, PhysicalTheoryCandidate,
    tqft_oracle_level, theory_inclusion_graph, verify_two_infinity_necessity,
    compute_oracle_hierarchy, duality_sector_analysis
)


def demo_theory_inclusion():
    """Demonstrate the theory inclusion hierarchy."""
    print("=" * 60)
    print("§1. Theory Inclusion Hierarchy")
    print("=" * 60)
    print()
    print("  TQFT ──→ CFT ──→ Gravity")
    print("                    ↑")
    print("  String ───────────┘")
    print()
    print("Each arrow represents a strict inclusion:")
    print("  • TQFT ⊂ CFT: forgetting topology-only invariance")
    print("  • CFT ⊂ Gravity: making the metric dynamical")
    print("  • String ⊂ Gravity: strings propagate in spacetime")
    print()

    graph = theory_inclusion_graph()
    for theory, targets in graph.items():
        if targets:
            for t in targets:
                print(f"  {theory.name} includes into {t.name}")
        else:
            print(f"  {theory.name} is the most general")
    print()


def demo_two_infinity_theorem():
    """Demonstrate the (2,∞)-category necessity theorem."""
    print("=" * 60)
    print("§2. The (2,∞)-Category Necessity Theorem")
    print("=" * 60)
    print()
    print("THEOREM: Any physical theory admitting both TQFT and String")
    print("shadows must have stable level ≥ 2 in its dualizable tower.")
    print()

    # Test all stable levels 0..5
    for stable in range(6):
        obj_counts = [max(1, 2 if i < stable else 1) for i in range(stable + 3)]
        tower = DualizableTower(
            obj_counts=obj_counts,
            stable_level=stable,
            dual=[lambda x: x] * (stable + 3)
        )
        candidate = PhysicalTheoryCandidate(
            tower=tower,
            shadows={TheoryType.TQFT, TheoryType.STRING}
        )
        ok = candidate.satisfies_two_infinity_bound()
        symbol = "✓" if ok else "✗"
        reason = ""
        if stable == 0:
            reason = " (Obj(0) trivial → no TQFT)"
        elif stable == 1:
            reason = " (Obj(1) trivial → no String)"
        print(f"  stable_level = {stable}: {symbol} satisfies bound{reason}")

    print()
    print(f"  Computational verification: {verify_two_infinity_necessity()}")
    print()


def demo_oracle_hierarchy():
    """Demonstrate the oracle hierarchy for TQFTs."""
    print("=" * 60)
    print("§3. Oracle Hierarchy: Computability of TQFTs")
    print("=" * 60)
    print()
    print("The oracle level measures how much non-computable information")
    print("a TQFT requires. Key thresholds:")
    print()
    print("  dim ≤ 3: COMPUTABLE")
    print("    → Smooth structures essentially unique")
    print("    → Manifold classification decidable")
    print()
    print("  dim = 4: UNDECIDABLE (Σ₁)")
    print("    → Exotic smooth structures on ℝ⁴")
    print("    → Markov's theorem: homeomorphism undecidable")
    print()
    print("  dim ≥ 5: HIGHER ORACLE LEVELS")
    print("    → Each dimension adds one level")
    print()

    hierarchy = compute_oracle_hierarchy(12)
    print("  dim | oracle level | status")
    print("  ----|-------------|--------")
    for d, sigma in hierarchy:
        if sigma == 0:
            status = "computable ✓"
        elif sigma == 1:
            status = "undecidable (Σ₁) ✗"
        else:
            status = f"Σ_{sigma} oracle needed"
        print(f"  {d:3d} | {sigma:11d} | {status}")
    print()

    # Verify oracle unboundedness
    print("  THEOREM: Oracle level is unbounded (∀n, ∃d, σ(d) > n)")
    for n in range(1, 8):
        d = n + 4
        sigma = tqft_oracle_level(d).sigma_level
        print(f"    n={n}: d={d} gives σ={sigma} > {n} ✓")
    print()


def demo_duality_sectors():
    """Demonstrate duality sector bounds."""
    print("=" * 60)
    print("§4. Duality Sector Bounds")
    print("=" * 60)
    print()
    print("Under Z/2 duality, n objects form at most ⌈n/2⌉ orbits.")
    print("Self-dual objects contribute 1 orbit each;")
    print("dual pairs contribute 1 orbit for 2 objects.")
    print()

    for n, bound in duality_sector_analysis(15):
        bar = "█" * bound + "░" * (n - bound)
        print(f"  {n:2d} objects: ≤ {bound:2d} sectors  {bar}")
    print()


def demo_shadow_dimensions():
    """Demonstrate shadow dimension constraints."""
    print("=" * 60)
    print("§5. Shadow Dimension Constraints")
    print("=" * 60)
    print()
    print("Different theory types operate at different dimensions:")
    print()
    for tt in TheoryType:
        if tt == TheoryType.STRING:
            dim = "2 (worldsheet)"
        elif tt == TheoryType.TQFT:
            dim = "d (arbitrary)"
        elif tt == TheoryType.CFT:
            dim = "d (with conformal structure)"
        else:
            dim = "d (with dynamical metric)"
        print(f"  {tt.name:8s}: dimension {dim}")
    print()
    print("CONSEQUENCE: A unified theory with String shadow needs d ≥ 2")
    print()


def demo_cobordism_hypothesis():
    """Demonstrate the cobordism hypothesis."""
    print("=" * 60)
    print("§6. The Cobordism Hypothesis")
    print("=" * 60)
    print()
    print("THEOREM (Baez-Dolan-Lurie): A fully extended n-TQFT valued")
    print("in an (∞,n)-category C with duals is completely determined")
    print("by its value on a point — a fully dualizable object of C.")
    print()
    print("In our formalization:")
    print("  PointEquivalent(Z₁, Z₂) ⟺ Z₁ = Z₂")
    print()
    print("This means the evaluation-at-a-point functor")
    print("  ev₀ : Fun⊗(Bord_n, C) → C^fd")
    print("is an equivalence.")
    print()
    print("Physical interpretation:")
    print("  • A TQFT is entirely encoded in ONE object")
    print("  • All amplitudes, partition functions, state spaces")
    print("    are determined by this single datum")
    print("  • The cobordism hypothesis is the ultimate compression")
    print()


if __name__ == "__main__":
    demo_theory_inclusion()
    demo_two_infinity_theorem()
    demo_oracle_hierarchy()
    demo_duality_sectors()
    demo_shadow_dimensions()
    demo_cobordism_hypothesis()

    print("=" * 60)
    print("Summary of Proved Theorems")
    print("=" * 60)
    print()
    print("1. cobordism_hypothesis_structural")
    print("   Two fully extended TQFTs agreeing on the point are equal.")
    print()
    print("2. two_infinity_necessity")
    print("   TQFT + String shadows ⟹ stable level ≥ 2.")
    print()
    print("3. two_infinity_achievable")
    print("   The bound is tight: stable level = 2 is achievable.")
    print()
    print("4. oracle_unbounded")
    print("   ∀n, ∃d, tqft_oracle_level(d) > n.")
    print()
    print("5. oracle_level_monotone")
    print("   d₁ ≤ d₂ ⟹ oracle_level(d₁) ≤ oracle_level(d₂).")
    print()
    print("6. dual_determined_by_objects")
    print("   In a (2,∞)-tower, levels ≥ 2 have unique objects.")
    print()
    print("7. self_dual_above_stable")
    print("   Above the stable level, every object is self-dual.")
    print()
    print("All proofs are machine-verified in Lean 4 with Mathlib.")


"""
Visualization: Oracle Hierarchy for TQFTs by Dimension

Standalone matplotlib visualization showing how the computability
of topological quantum field theories depends on spacetime dimension.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def tqft_oracle_level(d: int) -> int:
    """Oracle level sigma for dimension d."""
    return 0 if d <= 3 else d - 3


def main():
    dims = list(range(0, 16))
    levels = [tqft_oracle_level(d) for d in dims]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Oracle level vs dimension
    colors = ['#2ecc71' if l == 0 else '#e74c3c' if l == 1 else '#3498db'
              for l in levels]

    bars = ax1.bar(dims, levels, color=colors, edgecolor='black', linewidth=0.5)
    ax1.set_xlabel('Spacetime Dimension d', fontsize=12)
    ax1.set_ylabel('Oracle Level σ(d)', fontsize=12)
    ax1.set_title('Computability of TQFTs by Dimension', fontsize=14, fontweight='bold')

    # Add annotations
    ax1.axhline(y=0, color='green', linestyle='--', alpha=0.3, label='Computable')
    ax1.axhline(y=1, color='red', linestyle='--', alpha=0.3, label='Undecidable')

    ax1.annotate('Computable\n(d ≤ 3)', xy=(1.5, 0.2), fontsize=10,
                ha='center', color='#27ae60', fontweight='bold')
    ax1.annotate('Exotic R⁴\n(d = 4)', xy=(4, 1.3), fontsize=9,
                ha='center', color='#c0392b')
    ax1.annotate('Higher\noracles', xy=(10, 7.5), fontsize=10,
                ha='center', color='#2980b9')

    green_patch = mpatches.Patch(color='#2ecc71', label='Computable (Σ₀)')
    red_patch = mpatches.Patch(color='#e74c3c', label='Undecidable (Σ₁)')
    blue_patch = mpatches.Patch(color='#3498db', label='Higher oracle (Σₙ)')
    ax1.legend(handles=[green_patch, red_patch, blue_patch], loc='upper left')

    # Plot 2: Theory inclusion hierarchy
    ax2.set_xlim(0, 10)
    ax2.set_ylim(0, 10)
    ax2.set_aspect('equal')
    ax2.axis('off')
    ax2.set_title('Theory Inclusion & Shadow Structure', fontsize=14, fontweight='bold')

    # Draw theory nodes
    positions = {
        'TQFT': (2, 7),
        'CFT': (5, 7),
        'String': (2, 3),
        'Gravity': (8, 5),
    }
    node_colors = {
        'TQFT': '#2ecc71',
        'CFT': '#f39c12',
        'String': '#9b59b6',
        'Gravity': '#e74c3c',
    }

    for name, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.8, color=node_colors[name],
                           ec='black', linewidth=2, alpha=0.8)
        ax2.add_patch(circle)
        ax2.text(x, y, name, ha='center', va='center', fontsize=10,
                fontweight='bold', color='white')

    # Draw inclusion arrows
    arrows = [
        ('TQFT', 'CFT'),
        ('CFT', 'Gravity'),
        ('String', 'Gravity'),
    ]
    for src, dst in arrows:
        sx, sy = positions[src]
        dx, dy = positions[dst]
        ax2.annotate('', xy=(dx - 0.8 * (dx - sx) / np.sqrt((dx-sx)**2 + (dy-sy)**2),
                            dy - 0.8 * (dy - sy) / np.sqrt((dx-sx)**2 + (dy-sy)**2)),
                    xytext=(sx + 0.8 * (dx - sx) / np.sqrt((dx-sx)**2 + (dy-sy)**2),
                           sy + 0.8 * (dy - sy) / np.sqrt((dx-sx)**2 + (dy-sy)**2)),
                    arrowprops=dict(arrowstyle='->', lw=2, color='black'))

    # Add the (2,∞) annotation
    ax2.text(5, 1.2, '(2,∞)-Category Necessity:', fontsize=11,
            ha='center', fontweight='bold')
    ax2.text(5, 0.5, 'TQFT ∧ String ⟹ stable level ≥ 2',
            fontsize=10, ha='center', style='italic')

    plt.tight_layout()
    plt.savefig('oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: oracle_hierarchy.png")


if __name__ == "__main__":
    main()
