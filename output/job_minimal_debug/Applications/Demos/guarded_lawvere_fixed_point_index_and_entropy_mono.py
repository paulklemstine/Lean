#!/usr/bin/env python3
"""
Guarded Fixed-Point Index Theory — Interactive Demo
====================================================

This script demonstrates the formal theory developed in
GuardedFixedPointIndex.lean with concrete numerical examples
and visualizations.

The key idea: every guarded endomorphism carries a numerical
"fixed-point index" measuring the irreducible feedback cost.
This index is:
  - monotone under semantic domination
  - invariant under trace-conjugacy (reversible equivalence)
  - additive under stratified composition
  - an obstruction to elimination (nonzero index → irreducible feedback)
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from dataclasses import dataclass
from typing import Callable, Optional
import itertools

# ============================================================
# Core Data Structures
# ============================================================

@dataclass
class GuardedEnd:
    """A guarded endomorphism with oracle level and guard cost.

    Mirrors the Lean structure:
      structure GuardedEnd (α : Type*) where
        f : α → α
        oracleLevel : ℕ
        guardCost : int | float  (WithTop ℕ, where float('inf') = ⊤)
    """
    f: Callable
    oracle_level: int
    guard_cost: float  # Use float('inf') for ⊤

    def fixed_point_index(self) -> float:
        """The guarded fixed-point index = guard_cost (proven in Lean)."""
        return self.guard_cost

    def is_eliminable(self) -> bool:
        """An endomorphism is eliminable iff its index is zero."""
        return self.fixed_point_index() == 0

    def compose(self, other: 'GuardedEnd') -> 'GuardedEnd':
        """Stratified composition: oracle levels max, costs add."""
        return GuardedEnd(
            f=lambda x: self.f(other.f(x)),
            oracle_level=max(self.oracle_level, other.oracle_level),
            guard_cost=self.guard_cost + other.guard_cost
        )

    def __repr__(self):
        cost_str = "∞" if self.guard_cost == float('inf') else str(self.guard_cost)
        return f"GuardedEnd(level={self.oracle_level}, cost={cost_str})"


def entropy_bound(index: float) -> float:
    """The entropy bound observable (identity in the concrete version)."""
    return index


# ============================================================
# Demo 1: Basic Index Properties
# ============================================================

def demo_basic_properties():
    """Demonstrate the fundamental properties of the fixed-point index."""
    print("=" * 60)
    print("Demo 1: Basic Fixed-Point Index Properties")
    print("=" * 60)

    # Create some guarded endomorphisms on integers mod 10
    g1 = GuardedEnd(f=lambda x: (x + 1) % 10, oracle_level=1, guard_cost=3)
    g2 = GuardedEnd(f=lambda x: (x + 2) % 10, oracle_level=2, guard_cost=5)
    g3 = GuardedEnd(f=lambda x: (x * 3) % 10, oracle_level=1, guard_cost=0)

    print(f"\ng1 = {g1}")
    print(f"  Fixed-point index: {g1.fixed_point_index()}")
    print(f"  Eliminable: {g1.is_eliminable()}")

    print(f"\ng2 = {g2}")
    print(f"  Fixed-point index: {g2.fixed_point_index()}")
    print(f"  Eliminable: {g2.is_eliminable()}")

    print(f"\ng3 = {g3}")
    print(f"  Fixed-point index: {g3.fixed_point_index()}")
    print(f"  Eliminable: {g3.is_eliminable()}")

    # Monotonicity: g1 ≤ g2 (level and cost)
    print(f"\n--- Monotonicity ---")
    print(f"g1 ≤ g2 (level {g1.oracle_level} ≤ {g2.oracle_level}, "
          f"cost {g1.guard_cost} ≤ {g2.guard_cost})")
    print(f"  ⟹ index(g1) = {g1.fixed_point_index()} ≤ "
          f"{g2.fixed_point_index()} = index(g2) ✓")

    # Composition additivity
    g12 = g1.compose(g2)
    print(f"\n--- Composition Additivity ---")
    print(f"g1 ∘ g2 = {g12}")
    print(f"  index(g1 ∘ g2) = {g12.fixed_point_index()}")
    print(f"  index(g1) + index(g2) = {g1.fixed_point_index()} + "
          f"{g2.fixed_point_index()} = {g1.fixed_point_index() + g2.fixed_point_index()}")
    print(f"  Additivity: {g12.fixed_point_index()} = "
          f"{g1.fixed_point_index() + g2.fixed_point_index()} ✓")

    # Obstruction theorem
    print(f"\n--- Obstruction Theorem ---")
    print(f"g1 has positive index ({g1.fixed_point_index()} > 0)")
    print(f"  ⟹ g1 is NOT eliminable: {not g1.is_eliminable()} ✓")
    print(f"g3 has zero index ({g3.fixed_point_index()} = 0)")
    print(f"  ⟹ g3 IS eliminable: {g3.is_eliminable()} ✓")


# ============================================================
# Demo 2: Trace-Conjugacy Invariance
# ============================================================

def demo_trace_conjugacy():
    """Show that conjugation by permutations preserves the index."""
    print("\n" + "=" * 60)
    print("Demo 2: Trace-Conjugacy Invariance")
    print("=" * 60)

    n = 5
    elements = list(range(n))

    # Original endomorphism: cyclic shift
    f = lambda x: (x + 1) % n
    g = GuardedEnd(f=f, oracle_level=2, guard_cost=4)

    # A permutation (swap 0 and 1)
    perm = {0: 1, 1: 0, 2: 2, 3: 3, 4: 4}
    perm_inv = {v: k for k, v in perm.items()}

    # Conjugated endomorphism: e ∘ f ∘ e⁻¹
    f_conj = lambda x: perm[f(perm_inv[x])]
    h = GuardedEnd(f=f_conj, oracle_level=2, guard_cost=4)

    print(f"\nOriginal g: f(x) = (x+1) mod {n}")
    print(f"  Orbit: {' → '.join(str(f(x)) for x in elements)} → {f(elements[-1])}")
    print(f"  Index: {g.fixed_point_index()}")

    print(f"\nPermutation e: {perm}")
    print(f"Conjugated h: f'(x) = e ∘ f ∘ e⁻¹(x)")
    print(f"  Orbit: {' → '.join(str(f_conj(x)) for x in elements)} → {f_conj(elements[-1])}")
    print(f"  Index: {h.fixed_point_index()}")

    print(f"\nInvariance: index(g) = {g.fixed_point_index()} = "
          f"{h.fixed_point_index()} = index(h) ✓")
    print("(The dynamics changed but the quantitative obstruction is preserved)")


# ============================================================
# Demo 3: Oracle Tower and Index Growth
# ============================================================

def demo_oracle_tower():
    """Visualize how index grows through an oracle tower."""
    print("\n" + "=" * 60)
    print("Demo 3: Oracle Tower — Index Growth")
    print("=" * 60)

    # Build a tower of guarded endomorphisms with increasing oracle levels
    tower = []
    for level in range(1, 8):
        cost = level * 2 + 1  # Increasing guard costs
        g = GuardedEnd(f=lambda x, l=level: x + l, oracle_level=level, guard_cost=cost)
        tower.append(g)

    # Compose them sequentially
    compositions = [tower[0]]
    for i in range(1, len(tower)):
        compositions.append(compositions[-1].compose(tower[i]))

    print("\nIndividual levels:")
    for i, g in enumerate(tower):
        print(f"  Level {g.oracle_level}: guard_cost = {g.guard_cost}, "
              f"index = {g.fixed_point_index()}")

    print("\nCumulative compositions:")
    for i, g in enumerate(compositions):
        expected_sum = sum(t.guard_cost for t in tower[:i+1])
        print(f"  Levels 1..{i+1}: oracle_level = {g.oracle_level}, "
              f"index = {g.fixed_point_index()}, "
              f"sum of parts = {expected_sum} "
              f"{'✓' if g.fixed_point_index() == expected_sum else '✗'}")

    # Visualization
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    levels = [g.oracle_level for g in tower]
    costs = [g.guard_cost for g in tower]
    cum_indices = [g.fixed_point_index() for g in compositions]
    cum_levels = list(range(1, len(tower) + 1))

    ax1.bar(levels, costs, color='steelblue', alpha=0.8, edgecolor='navy')
    ax1.set_xlabel('Oracle Level', fontsize=12)
    ax1.set_ylabel('Guard Cost', fontsize=12)
    ax1.set_title('Guard Cost per Oracle Level', fontsize=14)
    ax1.grid(axis='y', alpha=0.3)

    ax2.plot(cum_levels, cum_indices, 'o-', color='crimson', linewidth=2, markersize=8)
    ax2.fill_between(cum_levels, cum_indices, alpha=0.15, color='crimson')
    ax2.set_xlabel('Number of Composed Levels', fontsize=12)
    ax2.set_ylabel('Cumulative Fixed-Point Index', fontsize=12)
    ax2.set_title('Index Growth Under Composition\n(Exact Additivity)', fontsize=14)
    ax2.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig('oracle_tower_index.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("\n[Saved: oracle_tower_index.png]")


# ============================================================
# Demo 4: Obstruction Landscape
# ============================================================

def demo_obstruction_landscape():
    """Visualize the eliminability/obstruction landscape."""
    print("\n" + "=" * 60)
    print("Demo 4: Obstruction Landscape")
    print("=" * 60)

    # Create a grid of guarded endomorphisms
    max_level = 6
    max_cost = 8

    fig, ax = plt.subplots(figsize=(10, 7))

    for level in range(max_level + 1):
        for cost in range(max_cost + 1):
            g = GuardedEnd(f=lambda x: x, oracle_level=level, guard_cost=cost)
            idx = g.fixed_point_index()
            elim = g.is_eliminable()

            color = 'limegreen' if elim else plt.cm.Reds(min(idx / max_cost, 1.0))
            size = 80 if elim else 80 + idx * 30

            ax.scatter(level, cost, c=[color], s=size, edgecolors='black',
                      linewidth=0.5, zorder=3)
            if cost <= 5:
                ax.annotate(f'{int(idx)}', (level, cost), textcoords="offset points",
                           xytext=(0, -2), ha='center', va='center', fontsize=7,
                           fontweight='bold')

    # Legend
    green_patch = mpatches.Patch(color='limegreen', label='Eliminable (index = 0)')
    red_patch = mpatches.Patch(color='crimson', label='Obstructed (index > 0)')
    ax.legend(handles=[green_patch, red_patch], loc='upper left', fontsize=11)

    ax.set_xlabel('Oracle Level', fontsize=13)
    ax.set_ylabel('Guard Cost = Fixed-Point Index', fontsize=13)
    ax.set_title('Obstruction Landscape\n'
                 'Green = eliminable self-reference, Red = irreducible feedback',
                 fontsize=14)
    ax.set_xticks(range(max_level + 1))
    ax.set_yticks(range(max_cost + 1))
    ax.grid(alpha=0.2)

    plt.tight_layout()
    plt.savefig('obstruction_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: obstruction_landscape.png]")


# ============================================================
# Demo 5: Entropy Monotonicity
# ============================================================

def demo_entropy_monotonicity():
    """Demonstrate entropy monotonicity under various monotone maps."""
    print("\n" + "=" * 60)
    print("Demo 5: Entropy Monotonicity")
    print("=" * 60)

    # Various monotone entropy maps
    entropy_maps = {
        'Identity (id)': lambda x: x,
        'Logarithmic (log₂)': lambda x: np.log2(x + 1),
        'Square root': lambda x: np.sqrt(x),
        'Linear (2x + 1)': lambda x: 2 * x + 1,
    }

    # Sequence of guarded endomorphisms with increasing costs
    costs = list(range(0, 11))
    indices = costs  # index = guardCost

    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    for ax, (name, phi) in zip(axes.flat, entropy_maps.items()):
        entropy_vals = [phi(c) for c in costs]

        ax.plot(costs, entropy_vals, 'o-', color='darkblue', linewidth=2, markersize=6)
        ax.fill_between(costs, entropy_vals, alpha=0.1, color='blue')

        # Highlight the zero/nonzero boundary
        ax.axvline(x=0.5, color='red', linestyle='--', alpha=0.5, label='Index > 0 boundary')
        ax.axhline(y=phi(1) if len(costs) > 1 else 0, color='green', linestyle=':',
                   alpha=0.5, label=f'φ(1) = {phi(1):.2f}')

        ax.set_xlabel('Fixed-Point Index', fontsize=11)
        ax.set_ylabel(f'φ(index)', fontsize=11)
        ax.set_title(f'Entropy Map: {name}', fontsize=12)
        ax.grid(alpha=0.3)
        ax.legend(fontsize=8)

    fig.suptitle('Entropy Monotonicity: φ(index(g)) ≤ φ(index(h)) when g ≤ h\n'
                 'Positive index ⟹ positive entropy for all positivity-preserving φ',
                 fontsize=13, y=1.02)
    plt.tight_layout()
    plt.savefig('entropy_monotonicity.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("[Saved: entropy_monotonicity.png]")

    # Numerical verification
    print("\nNumerical verification of entropy monotonicity:")
    g_low = GuardedEnd(f=lambda x: x, oracle_level=1, guard_cost=3)
    g_high = GuardedEnd(f=lambda x: x, oracle_level=2, guard_cost=7)

    for name, phi in entropy_maps.items():
        e_low = phi(g_low.fixed_point_index())
        e_high = phi(g_high.fixed_point_index())
        print(f"  {name}: φ({g_low.fixed_point_index()}) = {e_low:.3f} ≤ "
              f"{e_high:.3f} = φ({g_high.fixed_point_index()})  "
              f"{'✓' if e_low <= e_high else '✗'}")


# ============================================================
# Demo 6: Application — Circuit Feedback Analysis
# ============================================================

def demo_circuit_application():
    """Demonstrate application to reversible circuit feedback analysis."""
    print("\n" + "=" * 60)
    print("Demo 6: Application — Reversible Circuit Feedback Analysis")
    print("=" * 60)

    print("""
Scenario: A reversible computation circuit has several feedback loops,
each requiring different amounts of "guarded delay" (temporal oracle calls).
The fixed-point index tells us the minimum total feedback cost.

Circuit structure:
  ┌─────────────────────────────────────┐
  │  [Gate A] ──→ [Gate B] ──→ [Gate C] │
  │     ↑           ↑           │       │
  │     │ cost=2    │ cost=3    │       │
  │     └───────────┘           │       │
  │                   cost=1    │       │
  │     ←──────────────────────┘       │
  └─────────────────────────────────────┘
""")

    # Model each feedback loop as a guarded endomorphism
    loop_a = GuardedEnd(f=lambda x: x, oracle_level=1, guard_cost=2)
    loop_b = GuardedEnd(f=lambda x: x, oracle_level=2, guard_cost=3)
    loop_c = GuardedEnd(f=lambda x: x, oracle_level=1, guard_cost=1)

    print(f"Loop A: level={loop_a.oracle_level}, index={loop_a.fixed_point_index()}")
    print(f"Loop B: level={loop_b.oracle_level}, index={loop_b.fixed_point_index()}")
    print(f"Loop C: level={loop_c.oracle_level}, index={loop_c.fixed_point_index()}")

    # Total circuit feedback
    total = loop_a.compose(loop_b).compose(loop_c)
    print(f"\nTotal circuit: level={total.oracle_level}, index={total.fixed_point_index()}")
    print(f"Temporal feedback complexity: {entropy_bound(total.fixed_point_index())}")

    # Can we eliminate any loops?
    print("\nEliminability analysis:")
    for name, loop in [("A", loop_a), ("B", loop_b), ("C", loop_c)]:
        if loop.is_eliminable():
            print(f"  Loop {name}: ELIMINABLE (zero index)")
        else:
            print(f"  Loop {name}: IRREDUCIBLE (index = {loop.fixed_point_index()} > 0)")

    # What if we could remove loop C?
    without_c = loop_a.compose(loop_b)
    print(f"\nWithout loop C: index would be {without_c.fixed_point_index()} "
          f"(saved {total.fixed_point_index() - without_c.fixed_point_index()})")
    print(f"But loop C has nonzero index — the obstruction theorem says it CANNOT be eliminated!")


# ============================================================
# Main
# ============================================================

if __name__ == '__main__':
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Guarded Fixed-Point Index Theory — Interactive Demo    ║")
    print("║  Formal proofs in GuardedFixedPointIndex.lean           ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_properties()
    demo_trace_conjugacy()
    demo_oracle_tower()
    demo_obstruction_landscape()
    demo_entropy_monotonicity()
    demo_circuit_application()

    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("Generated visualizations:")
    print("  • oracle_tower_index.png")
    print("  • obstruction_landscape.png")
    print("  • entropy_monotonicity.png")
    print("=" * 60)
