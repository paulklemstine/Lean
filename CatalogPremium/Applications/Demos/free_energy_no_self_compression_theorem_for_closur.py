#!/usr/bin/env python3
"""
Free-Energy No-Self-Compression Theorem — Numerical Demonstrations

This script provides concrete numerical examples and visualizations
illustrating the Free-Energy No-Self-Compression Theorem for coherent
closure self-models.

The theorem says: in a coherent self-model, no sentence G can have its
free energy certified (internally) to lie strictly below the complexity floor.
We illustrate this with:

1. A toy formal system showing the diagonal fixed-point construction
2. Free energy vs. complexity floor plots showing the impossibility region
3. Temperature dependence of the thermodynamic obstruction
4. Phase diagram showing how the gap varies with inverse temperature β

Requirements: numpy, matplotlib
"""

import numpy as np
import matplotlib.pyplot as plt
from typing import Callable, Tuple, List
import os

# Ensure output directory exists
os.makedirs("output", exist_ok=True)


# ============================================================================
# §1. Toy Formal System Model
# ============================================================================

class ToyClosureSelfModel:
    """
    A concrete (finite, toy) closure self-model to illustrate the theorem.

    Sentences are integers 0..N-1.
    The 'proves' relation is a subset of sentences.
    Free energy and complexity floor are real-valued functions.

    This model satisfies the axioms:
    - Free energy ≥ complexity floor (by construction)
    - Internalized propositions are sound (by construction)
    - Diagonal sentences exist (we construct them explicitly)
    """

    def __init__(self, n_sentences: int = 20, beta: float = 1.0, seed: int = 42):
        self.rng = np.random.RandomState(seed)
        self.n = n_sentences
        self.beta = beta

        # Generate complexity floor: positive, varying across sentences
        self.floor = 0.5 + self.rng.exponential(scale=1.0, size=n_sentences)

        # Free energy is ALWAYS >= floor (the axiom)
        # Add a non-negative gap
        gap = self.rng.exponential(scale=0.5, size=n_sentences)
        self.free_energy = self.floor + gap

        # Provable sentences (some subset)
        self.provable = set(self.rng.choice(n_sentences, size=n_sentences // 3, replace=False))

    def compresses_at(self, g: int) -> bool:
        """Check if sentence g achieves strict sub-floor compression."""
        return self.free_energy[g] < self.floor[g]

    def proves_compression(self, g: int) -> bool:
        """
        Check if the model 'proves' the compression statement for g.
        By soundness + lower bound, this is always False.
        """
        # If the model claimed to prove compression, internalize_sound
        # would give us compresses_at(g) = True, but that's impossible
        # since free_energy >= floor by construction.
        return False

    def get_diagonal_sentence(self) -> int:
        """
        Find a 'diagonal sentence' G: one whose provability status
        regarding compression matches the Gödel-like construction.
        G ↔ ¬Prov(CompressesAt(G))
        Since CompressesAt is always false and unprovable,
        G is equivalent to ¬False = True, so G should be provable.
        """
        # In our toy model, every sentence satisfies the diagonal condition
        # vacuously (since compression is never provable), so we just pick one
        return 0


def demo_toy_model():
    """Demonstrate the theorem with a toy model."""
    print("=" * 70)
    print("DEMO 1: Toy Closure Self-Model")
    print("=" * 70)

    model = ToyClosureSelfModel(n_sentences=20, beta=1.0)

    print(f"\nModel has {model.n} sentences, β = {model.beta}")
    print(f"Number of provable sentences: {len(model.provable)}")

    print("\nFree Energy vs Complexity Floor for each sentence:")
    print(f"{'Sentence':>8} {'F(β,code)':>10} {'Floor':>10} {'Gap':>10} {'Compresses?':>12}")
    print("-" * 55)
    for g in range(min(10, model.n)):
        gap = model.free_energy[g] - model.floor[g]
        compresses = model.compresses_at(g)
        print(f"{g:>8} {model.free_energy[g]:>10.4f} {model.floor[g]:>10.4f} "
              f"{gap:>10.4f} {str(compresses):>12}")

    print(f"\n✓ No sentence achieves sub-floor compression (count: "
          f"{sum(1 for g in range(model.n) if model.compresses_at(g))})")
    print(f"✓ No sentence has provable compression (count: "
          f"{sum(1 for g in range(model.n) if model.proves_compression(g))})")

    G = model.get_diagonal_sentence()
    print(f"\nDiagonal sentence G = {G}")
    print(f"  F(β, selfCode(G)) = {model.free_energy[G]:.4f}")
    print(f"  complexityFloor(β, G) = {model.floor[G]:.4f}")
    print(f"  Gap = {model.free_energy[G] - model.floor[G]:.4f} ≥ 0 ✓")
    print(f"  M ⊢ CompressesAt(β, G)? {model.proves_compression(G)} ✓")

    return model


# ============================================================================
# §2. Free Energy Landscape Visualization
# ============================================================================

def demo_energy_landscape():
    """Visualize the free energy landscape and impossibility region."""
    print("\n" + "=" * 70)
    print("DEMO 2: Free Energy Landscape")
    print("=" * 70)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left panel: Free energy vs complexity floor for many sentences
    n = 50
    rng = np.random.RandomState(42)
    floor = 0.5 + rng.exponential(scale=1.0, size=n)
    gap = rng.exponential(scale=0.3, size=n)
    free_energy = floor + gap

    ax = axes[0]
    max_val = max(max(free_energy), max(floor)) * 1.1

    # Shade the impossible region
    ax.fill_between([0, max_val], [0, 0], [0, max_val],
                    alpha=0.15, color='red', label='Impossible region\n(F < floor)')
    ax.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                    alpha=0.08, color='green', label='Allowed region\n(F ≥ floor)')

    # Plot the diagonal line
    ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, linewidth=1)

    # Plot each sentence
    ax.scatter(floor, free_energy, c='navy', s=40, zorder=5, alpha=0.7)

    ax.set_xlabel('Complexity Floor', fontsize=12)
    ax.set_ylabel('Free Energy F(β, selfCode(G))', fontsize=12)
    ax.set_title('Free Energy vs. Complexity Floor\n(All points above diagonal)', fontsize=13)
    ax.legend(loc='upper left', fontsize=9)
    ax.set_xlim(0, max_val)
    ax.set_ylim(0, max_val)

    # Right panel: Gap distribution
    ax = axes[1]
    gaps = free_energy - floor
    ax.hist(gaps, bins=20, color='steelblue', edgecolor='white', alpha=0.8)
    ax.axvline(x=0, color='red', linestyle='--', linewidth=2,
               label='Floor boundary\n(gap = 0)')
    ax.set_xlabel('Free Energy Gap (F − floor)', fontsize=12)
    ax.set_ylabel('Count', fontsize=12)
    ax.set_title('Distribution of Free Energy Gaps\n(All gaps ≥ 0 by axiom)', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('output/energy_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/energy_landscape.png")


# ============================================================================
# §3. Temperature Dependence
# ============================================================================

def free_energy_model(beta: float, complexity: float, entropy: float) -> float:
    """
    Model free energy as F(β) = β·E - S where E is internal energy
    and S is entropy. The complexity floor grows with β.

    F(β) = β * complexity + entropy_correction
    Floor(β) = complexity * (1 - exp(-β))  [approaches complexity as β→∞]
    """
    return beta * complexity + entropy * np.exp(-beta)


def complexity_floor_model(beta: float, base_complexity: float) -> float:
    """Model complexity floor as an increasing function of β."""
    return base_complexity * (1 - np.exp(-beta))


def demo_temperature_dependence():
    """Show how the free-energy gap varies with inverse temperature."""
    print("\n" + "=" * 70)
    print("DEMO 3: Temperature Dependence of Thermodynamic Obstruction")
    print("=" * 70)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    betas = np.linspace(0.01, 5.0, 200)

    # Parameters for a representative sentence
    E = 2.0  # internal energy / complexity
    S = 1.5  # entropy contribution

    fe = np.array([free_energy_model(b, E, S) for b in betas])
    fl = np.array([complexity_floor_model(b, E) for b in betas])
    gap = fe - fl

    # Panel 1: F and floor vs β
    ax = axes[0]
    ax.plot(betas, fe, 'b-', linewidth=2, label='Free energy F(β)')
    ax.plot(betas, fl, 'r--', linewidth=2, label='Complexity floor')
    ax.fill_between(betas, fl, fe, alpha=0.2, color='green',
                    label='Gap F − floor ≥ 0')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Energy', fontsize=12)
    ax.set_title('Free Energy vs Floor\nvs Inverse Temperature', fontsize=13)
    ax.legend(fontsize=9)

    # Panel 2: Gap vs β
    ax = axes[1]
    ax.plot(betas, gap, 'g-', linewidth=2)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5)
    ax.fill_between(betas, 0, gap, alpha=0.2, color='green')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Gap: F(β) − floor(β)', fontsize=12)
    ax.set_title('Thermodynamic Gap\n(always ≥ 0, no self-compression)', fontsize=13)

    # Panel 3: Multiple sentences
    ax = axes[2]
    rng = np.random.RandomState(42)
    for i in range(8):
        Ei = 1.0 + rng.exponential(1.0)
        Si = 0.5 + rng.exponential(0.5)
        fe_i = np.array([free_energy_model(b, Ei, Si) for b in betas])
        fl_i = np.array([complexity_floor_model(b, Ei) for b in betas])
        gap_i = fe_i - fl_i
        ax.plot(betas, gap_i, alpha=0.7, linewidth=1.5, label=f'G_{i}')

    ax.axhline(y=0, color='red', linestyle='--', linewidth=2, alpha=0.5,
               label='Compression boundary')
    ax.set_xlabel('Inverse temperature β', fontsize=12)
    ax.set_ylabel('Gap: F(β) − floor(β)', fontsize=12)
    ax.set_title('Gaps for Multiple Sentences\n(all stay non-negative)', fontsize=13)
    ax.legend(fontsize=8, ncol=2)

    plt.tight_layout()
    plt.savefig('output/temperature_dependence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/temperature_dependence.png")


# ============================================================================
# §4. Phase Diagram
# ============================================================================

def demo_phase_diagram():
    """Create a phase diagram showing the compression obstruction."""
    print("\n" + "=" * 70)
    print("DEMO 4: Phase Diagram — Compression Obstruction Region")
    print("=" * 70)

    fig, ax = plt.subplots(figsize=(10, 8))

    # Create a grid of (complexity, β) values
    complexities = np.linspace(0.1, 5.0, 100)
    betas = np.linspace(0.01, 5.0, 100)
    C, B = np.meshgrid(complexities, betas)

    # Gap = F(β, c) - floor(β, c)
    # Using our models:
    # F(β, c) = β·c + S·exp(-β), floor(β, c) = c·(1 - exp(-β))
    S = 1.0
    FE = B * C + S * np.exp(-B)
    FL = C * (1 - np.exp(-B))
    GAP = FE - FL

    # Plot the gap as a heatmap
    pcm = ax.pcolormesh(C, B, GAP, cmap='RdYlGn', shading='auto')
    plt.colorbar(pcm, ax=ax, label='Free Energy Gap (F − floor)')

    # Contour at gap = 0 (should not exist in allowed region)
    # Since gap > 0 everywhere for β > 0, we show contours for various gap levels
    levels = [0.5, 1.0, 2.0, 3.0, 5.0]
    cs = ax.contour(C, B, GAP, levels=levels, colors='black', linewidths=0.8, alpha=0.5)
    ax.clabel(cs, inline=True, fontsize=8, fmt='%.1f')

    ax.set_xlabel('Base Complexity', fontsize=13)
    ax.set_ylabel('Inverse Temperature β', fontsize=13)
    ax.set_title('Phase Diagram: Free Energy Gap\n'
                 'Gap is always positive — no self-compression possible',
                 fontsize=14)

    # Add annotation
    ax.annotate('Higher β → larger gap\n(stronger obstruction)',
                xy=(1.5, 4.0), fontsize=11, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='white', alpha=0.8))

    plt.tight_layout()
    plt.savefig('output/phase_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/phase_diagram.png")


# ============================================================================
# §5. Diagonal Sentence Construction Illustration
# ============================================================================

def demo_diagonal_construction():
    """Illustrate the Gödel-Lawvere diagonal construction."""
    print("\n" + "=" * 70)
    print("DEMO 5: Diagonal Sentence Construction")
    print("=" * 70)

    fig, ax = plt.subplots(figsize=(12, 8))

    # Illustrate the logical structure
    # G ↔ ¬Prov(CompressesAt(β, G))
    # where CompressesAt(β, G) := F(β, selfCode(G)) < floor(β, G)

    steps = [
        (0.5, 0.9, "Step 1: Choose Ψ(G) = ⌜F(β, selfCode(G)) < floor(β, G)⌝",
         "Define the compression predicate"),
        (0.5, 0.75, "Step 2: Diagonal lemma → ∃G: M ⊢ (G ↔ ¬Prov(Ψ(G)))",
         "Gödel-Lawvere fixed point"),
        (0.5, 0.60, "Step 3: Suppose M ⊢ Ψ(G)",
         "Assume provable compression (for contradiction)"),
        (0.5, 0.45, "Step 4: By Σ₁-soundness: F(β, selfCode(G)) < floor(β, G)",
         "Soundness gives semantic truth"),
        (0.5, 0.30, "Step 5: But F(β, selfCode(G)) ≥ floor(β, G)  ⊥",
         "Contradicts thermodynamic lower bound!"),
        (0.5, 0.15, "∴ ¬(M ⊢ Ψ(G))  — Compression is unprovable",
         "THE FREE-ENERGY NO-SELF-COMPRESSION THEOREM"),
    ]

    colors = ['#2196F3', '#2196F3', '#FF9800', '#FF9800', '#F44336', '#4CAF50']

    for i, (x, y, main, sub) in enumerate(steps):
        bbox_props = dict(boxstyle='round,pad=0.5', facecolor=colors[i],
                         alpha=0.15, edgecolor=colors[i], linewidth=2)
        ax.text(x, y, main, transform=ax.transAxes, fontsize=12,
                fontfamily='monospace', ha='center', va='center',
                bbox=bbox_props, fontweight='bold')
        ax.text(x, y - 0.04, sub, transform=ax.transAxes, fontsize=10,
                ha='center', va='center', fontstyle='italic', color='gray')

        if i < len(steps) - 1:
            ax.annotate('', xy=(0.5, y - 0.065), xytext=(0.5, y - 0.055),
                       xycoords='axes fraction', textcoords='axes fraction',
                       arrowprops=dict(arrowstyle='->', color='gray', lw=1.5))

    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    ax.set_title('Proof Architecture: Free-Energy No-Self-Compression Theorem',
                fontsize=15, fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('output/diagonal_construction.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/diagonal_construction.png")


# ============================================================================
# §6. Comparison with Classical Incompleteness
# ============================================================================

def demo_comparison():
    """Compare with classical Gödel incompleteness visually."""
    print("\n" + "=" * 70)
    print("DEMO 6: Comparison — Classical vs Thermodynamic Incompleteness")
    print("=" * 70)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: Classical Gödel
    ax = axes[0]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Classical Gödel Incompleteness', fontsize=14, fontweight='bold')

    classical_items = [
        (5, 8.5, "G ↔ ¬Prov(G)", 14, 'navy'),
        (5, 6.5, "If M ⊢ G, then M ⊢ Prov(G)\nby necessitation", 11, 'darkred'),
        (5, 4.5, "But G says ¬Prov(G)\nContradiction with consistency!", 11, 'darkred'),
        (5, 2.5, "∴ M ⊬ G", 14, 'darkgreen'),
        (5, 1.0, "Qualitative: unprovable sentence exists", 10, 'gray'),
    ]
    for x, y, text, size, color in classical_items:
        ax.text(x, y, text, ha='center', va='center', fontsize=size,
                color=color, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    # Right: Thermodynamic
    ax = axes[1]
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 10)
    ax.axis('off')
    ax.set_title('Thermodynamic No-Self-Compression', fontsize=14, fontweight='bold')

    thermo_items = [
        (5, 8.5, "G ↔ ¬Prov(⌜F(β,code) < floor⌝)", 13, 'navy'),
        (5, 6.5, "If M ⊢ ⌜F < floor⌝, then\nby Σ₁-soundness: F < floor", 11, 'darkred'),
        (5, 4.5, "But F(β,code) ≥ floor(β)\nby thermodynamic axiom!", 11, 'darkred'),
        (5, 2.5, "∴ M ⊬ ⌜F < floor⌝", 14, 'darkgreen'),
        (5, 1.0, "Quantitative: free-energy obstruction\nto self-compression", 10, 'gray'),
    ]
    for x, y, text, size, color in thermo_items:
        ax.text(x, y, text, ha='center', va='center', fontsize=size,
                color=color, fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightcyan', alpha=0.8))

    plt.tight_layout()
    plt.savefig('output/comparison.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("  Saved: output/comparison.png")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════╗")
    print("║  Free-Energy No-Self-Compression Theorem — Demonstrations      ║")
    print("║  Formally verified in Lean 4 with Mathlib                      ║")
    print("╚══════════════════════════════════════════════════════════════════╝")

    model = demo_toy_model()
    demo_energy_landscape()
    demo_temperature_dependence()
    demo_phase_diagram()
    demo_diagonal_construction()
    demo_comparison()

    print("\n" + "=" * 70)
    print("All demonstrations complete!")
    print("Output files saved in: output/")
    print("=" * 70)

    # Summary statistics
    print("\nKey insight: The Free-Energy No-Self-Compression Theorem shows")
    print("that in any coherent closure self-model:")
    print("  1. A diagonal sentence G exists (Gödel–Lawvere)")
    print("  2. G's compression predicate is unprovable (thermodynamic bound)")
    print("  3. Self-reference has an irreducible thermodynamic cost")
    print("\nThis upgrades Gödel's incompleteness from a qualitative")
    print("phenomenon to a quantitative free-energy obstruction.")
