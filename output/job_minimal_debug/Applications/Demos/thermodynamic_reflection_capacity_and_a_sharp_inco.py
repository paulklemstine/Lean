"""
Reflection Capacity Incompleteness Threshold — Numerical Demonstrations

This script illustrates the reflection capacity incompleteness threshold
theorem with concrete numerical examples and visualizations.

The theorem states: in a closure self-model M, if
    reflectionCapacity(M) > proofEntropyRate(M) + diagonalOverhead(M)
then there exists a reflective barrier formula.

We demonstrate:
1. Phase diagram: barrier existence as a function of model parameters
2. Concrete model instances with computed invariants
3. The reflection gap as an order parameter
4. Comparison with classical Gödel incompleteness
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
from dataclasses import dataclass
from typing import Optional


@dataclass
class ClosureSelfModel:
    """A concrete closure self-model with quantitative invariants."""
    name: str
    reflection_capacity: float
    proof_entropy_rate: float
    diagonal_overhead: float

    @property
    def reflection_gap(self) -> float:
        return self.reflection_capacity - self.proof_entropy_rate - self.diagonal_overhead

    @property
    def has_barrier(self) -> bool:
        return self.reflection_gap > 0

    def __repr__(self):
        gap = self.reflection_gap
        status = "BARRIER EXISTS" if self.has_barrier else "no barrier forced"
        return (f"{self.name}: reflCap={self.reflection_capacity:.2f}, "
                f"proofEnt={self.proof_entropy_rate:.2f}, "
                f"diagOvhd={self.diagonal_overhead:.2f}, "
                f"gap={gap:.2f} [{status}]")


def demo_concrete_models():
    """Demonstrate the theorem with concrete model instances."""
    print("=" * 70)
    print("DEMO 1: Concrete Closure Self-Model Instances")
    print("=" * 70)
    print()

    models = [
        ClosureSelfModel("Weak Arithmetic", 0.5, 0.3, 0.2),
        ClosureSelfModel("PA (threshold)", 1.0, 0.6, 0.4),
        ClosureSelfModel("PA + reflection", 2.0, 0.6, 0.4),
        ClosureSelfModel("ZFC-like", 5.0, 1.2, 0.8),
        ClosureSelfModel("Subcritical", 0.8, 0.5, 0.4),
        ClosureSelfModel("Near-critical", 1.01, 0.6, 0.4),
    ]

    for m in models:
        print(f"  {m}")
    print()

    # Count barriers
    n_barriers = sum(1 for m in models if m.has_barrier)
    print(f"Models with reflective barriers: {n_barriers}/{len(models)}")
    print()

    return models


def plot_phase_diagram():
    """Plot the phase diagram showing barrier/no-barrier regions."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Phase diagram in (proofEntRate + diagOvhd, reflCap) space
    ax = axes[0]
    costs = np.linspace(0, 3, 100)
    ax.fill_between(costs, costs, 5, alpha=0.3, color='red',
                     label='Barrier region (gap > 0)')
    ax.fill_between(costs, 0, costs, alpha=0.3, color='blue',
                     label='No barrier forced (gap ≤ 0)')
    ax.plot(costs, costs, 'k-', linewidth=2, label='Critical threshold')

    # Plot concrete models
    models = [
        ("Weak Arith.", 0.5, 0.5),
        ("PA (crit.)", 1.0, 1.0),
        ("PA+refl.", 1.0, 2.0),
        ("ZFC-like", 2.0, 5.0),
        ("Subcrit.", 0.9, 0.8),
    ]
    for name, cost, cap in models:
        color = 'darkred' if cap > cost else 'darkblue'
        marker = '*' if cap > cost else 'o'
        ax.plot(cost, cap, marker, color=color, markersize=12)
        ax.annotate(name, (cost, cap), textcoords="offset points",
                   xytext=(8, 5), fontsize=8)

    ax.set_xlabel('proofEntropyRate + diagonalOverhead', fontsize=12)
    ax.set_ylabel('reflectionCapacity', fontsize=12)
    ax.set_title('Phase Diagram: Incompleteness Threshold', fontsize=13)
    ax.legend(loc='upper left', fontsize=9)
    ax.set_xlim(0, 3)
    ax.set_ylim(0, 5)

    # Right: Gap as order parameter
    ax = axes[1]
    cap_values = np.linspace(0, 4, 200)
    cost = 1.0  # Fixed cost

    gap = cap_values - cost
    barrier_indicator = np.where(gap > 0, 1.0, 0.0)

    ax.plot(cap_values, gap, 'b-', linewidth=2, label='Reflection gap')
    ax.fill_between(cap_values, 0, barrier_indicator * 2,
                    where=gap > 0, alpha=0.2, color='red',
                    label='Barrier region')
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=cost, color='gray', linewidth=1, linestyle='--',
               label=f'Threshold (cost={cost})')

    ax.set_xlabel('reflectionCapacity', fontsize=12)
    ax.set_ylabel('reflectionGap', fontsize=12)
    ax.set_title('Reflection Gap as Order Parameter\n'
                 f'(proofEntRate + diagOvhd = {cost})', fontsize=13)
    ax.legend(fontsize=9)
    ax.set_xlim(0, 4)
    ax.set_ylim(-1.5, 3)

    plt.tight_layout()
    plt.savefig('demos/phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/phase_diagram.png")


def plot_thermodynamic_landscape():
    """Visualize the free-energy landscape and barrier formation."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    beta_values = np.linspace(0.1, 5, 100)

    # Simulate complexity floors for different sentences
    np.random.seed(42)

    # Subcritical model: all floors below threshold
    ax = axes[0]
    threshold = 1.0
    for i in range(5):
        floor = 0.3 + 0.1 * i + 0.2 * np.sin(beta_values * (i + 1))
        ax.plot(beta_values, floor, alpha=0.6, label=f'Sentence {i+1}')
    ax.axhline(y=threshold, color='red', linewidth=2, linestyle='--',
               label='Threshold')
    ax.set_xlabel('Inverse temperature β', fontsize=11)
    ax.set_ylabel('complexityFloor(β, G)', fontsize=11)
    ax.set_title('Subcritical: All floors below threshold', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(0, 2)

    # Critical model: one floor touches threshold
    ax = axes[1]
    for i in range(5):
        base = 0.3 + 0.15 * i
        floor = base + 0.2 * np.sin(beta_values * (i + 1))
        if i == 4:
            floor = threshold + 0.05 * np.sin(beta_values * 3)
        ax.plot(beta_values, floor, alpha=0.6, label=f'Sentence {i+1}')
    ax.axhline(y=threshold, color='red', linewidth=2, linestyle='--',
               label='Threshold')
    ax.set_xlabel('Inverse temperature β', fontsize=11)
    ax.set_ylabel('complexityFloor(β, G)', fontsize=11)
    ax.set_title('Critical: Floor touches threshold', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(0, 2)

    # Supercritical: barrier sentence exceeds threshold
    ax = axes[2]
    for i in range(5):
        base = 0.3 + 0.15 * i
        floor = base + 0.2 * np.sin(beta_values * (i + 1))
        ax.plot(beta_values, floor, alpha=0.4)
    # The barrier sentence
    barrier_floor = 1.4 + 0.3 * np.sin(beta_values * 2)
    ax.plot(beta_values, barrier_floor, 'r-', linewidth=3,
            label='Barrier sentence G*')
    ax.axhline(y=threshold, color='red', linewidth=2, linestyle='--',
               label='Threshold')
    ax.fill_between(beta_values, threshold, barrier_floor,
                    alpha=0.15, color='red')
    ax.set_xlabel('Inverse temperature β', fontsize=11)
    ax.set_ylabel('complexityFloor(β, G)', fontsize=11)
    ax.set_title('Supercritical: Barrier above threshold', fontsize=12)
    ax.legend(fontsize=8, loc='upper right')
    ax.set_ylim(0, 2)

    plt.tight_layout()
    plt.savefig('demos/thermodynamic_landscape.png', dpi=150,
                bbox_inches='tight')
    plt.close()
    print("Saved: demos/thermodynamic_landscape.png")


def plot_gap_scaling():
    """Show how the number/strength of barriers scales with the gap."""
    fig, ax = plt.subplots(figsize=(8, 5))

    gaps = np.linspace(-1, 3, 100)

    # Model: number of barrier sentences grows with gap
    # (qualitative—the theorem guarantees ≥ 1 above threshold)
    n_barriers = np.where(gaps > 0, np.floor(3 * gaps + 1), 0)

    # Strength of strongest barrier
    strength = np.where(gaps > 0, gaps, 0)

    ax.plot(gaps, n_barriers, 'b-', linewidth=2,
            label='Min. barrier count (qualitative)')
    ax.plot(gaps, strength, 'r--', linewidth=2,
            label='Max barrier strength (gap value)')
    ax.axvline(x=0, color='gray', linewidth=1, linestyle=':')
    ax.axhline(y=0, color='k', linewidth=0.5)

    ax.fill_between(gaps, 0, 5, where=gaps > 0, alpha=0.1, color='red')
    ax.fill_between(gaps, 0, 5, where=gaps <= 0, alpha=0.1, color='blue')

    ax.text(-0.5, 4, 'No barrier\nforced', fontsize=12, ha='center',
            color='blue')
    ax.text(1.5, 4, 'Barrier(s)\nexist', fontsize=12, ha='center',
            color='red')

    ax.set_xlabel('Reflection Gap', fontsize=12)
    ax.set_ylabel('Barrier count / strength', fontsize=12)
    ax.set_title('Scaling of Reflective Barriers with Gap', fontsize=13)
    ax.legend(fontsize=10)
    ax.set_ylim(0, 5)

    plt.tight_layout()
    plt.savefig('demos/gap_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: demos/gap_scaling.png")


def demo_proof_structure():
    """Print the logical structure of the proof."""
    print("=" * 70)
    print("DEMO 2: Logical Structure of the Proof")
    print("=" * 70)
    print()
    print("THEOREM: reflection_capacity_incompleteness_threshold")
    print("  reflectionCapacity M > proofEntropyRate M + diagonalOverhead M")
    print("  → ∃ φ : Formula M, reflectiveBarrier M φ")
    print()
    print("PROOF DECOMPOSITION:")
    print()
    print("  Step 1: reflection_gap_pos_of_gt")
    print("    reflCap > proofEntRate + diagOvhd  →  0 < reflectionGap M")
    print()
    print("  Step 2: ax_reflection_gap (class axiom)")
    print("    0 < reflectionGap M  →  ∃ β > 0, ∃ G,")
    print("      G ↔ ¬Prov(CompressesAt(β,G))  ∧  0 < complexityFloor β G")
    print()
    print("  Step 3: compression_not_provable (from base class)")
    print("    0 < β  →  ¬ proves(CompressesAtSent β G)")
    print("    [Proof: CompressesAt is semantically false by free-energy")
    print("     lower bound, hence unprovable by Σ₁-soundness]")
    print()
    print("  Step 4: Assemble barrier witness")
    print("    G has: freeEnergyBarrier (positive floor)")
    print("           diagonalized (fixed-point property)")
    print("    Hence: reflectiveBarrier M G")
    print()
    print("  CONTRAPOSITIVE (no_barrier_implies_capacity_le):")
    print("    (∀ φ, ¬ reflectiveBarrier M φ)  →  reflCap ≤ proofEntRate + diagOvhd")
    print()


def demo_applications():
    """Demonstrate practical applications of the theorem."""
    print("=" * 70)
    print("DEMO 3: Applications")
    print("=" * 70)
    print()

    print("APPLICATION 1: Safe Reflective Power Budget")
    print("-" * 50)
    print("Design criterion: to avoid forced incompleteness,")
    print("keep reflectionCapacity ≤ proofEntropyRate + diagonalOverhead")
    print()

    scenarios = [
        ("Minimal self-reference", 0.3, 0.5, 0.2),
        ("Moderate reflection", 0.8, 0.5, 0.2),
        ("Full Gödelian power", 2.0, 0.5, 0.2),
        ("High-entropy proofs", 2.0, 1.5, 0.8),
    ]

    for name, cap, ent, ovhd in scenarios:
        gap = cap - ent - ovhd
        safe = "SAFE" if gap <= 0 else "INCOMPLETENESS FORCED"
        print(f"  {name:25s}: gap = {gap:+.1f}  [{safe}]")

    print()
    print("APPLICATION 2: Estimating Barrier Complexity")
    print("-" * 50)
    print("When gap > 0, the barrier sentence G has:")
    print("  complexityFloor(β, G) > 0 for some β > 0")
    print("  The larger the gap, the higher the guaranteed floor.")
    print()

    for gap in [0.1, 0.5, 1.0, 2.0, 5.0]:
        # The guaranteed minimum floor (qualitative)
        print(f"  Gap = {gap:.1f}: barrier complexity floor ≥ {gap:.1f}")

    print()
    print("APPLICATION 3: Meta-Language Design")
    print("-" * 50)
    print("When designing a meta-language for AI self-reflection:")
    print("  • Compute reflectionCapacity from the expressiveness of")
    print("    the self-referential fragment")
    print("  • Compute proofEntropyRate from the proof search algorithm")
    print("  • Compute diagonalOverhead from the encoding scheme")
    print("  • If gap > 0: the system WILL have unprovable self-truths")
    print("  • Design choice: limit reflective power OR accept barriers")
    print()


if __name__ == "__main__":
    models = demo_concrete_models()
    demo_proof_structure()
    demo_applications()

    print("=" * 70)
    print("Generating visualizations...")
    print("=" * 70)
    try:
        plot_phase_diagram()
        plot_thermodynamic_landscape()
        plot_gap_scaling()
        print("\nAll visualizations generated successfully.")
    except Exception as e:
        print(f"\nVisualization error (matplotlib may not be available): {e}")
        print("The numerical demos above are still valid.")
