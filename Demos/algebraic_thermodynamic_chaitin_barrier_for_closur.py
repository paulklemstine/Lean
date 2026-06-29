#!/usr/bin/env python3
"""
Thermodynamic Chaitin Barrier — Interactive Demonstration

This script demonstrates the key mathematical ideas behind the
Thermodynamic Chaitin Barrier theorem with concrete numerical examples
and visualizations.

The theorem states: no sound closure self-model can derive that its own
self-sentence has positive thermodynamic randomness deficiency.

The core inequality is:
    D(β, φ) = -(β · E(canonical(φ)) + log Z(β)) ≤ 0

because the canonical code is always a summand in the partition function.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List
import os


class ToyClosureSelfModel:
    """
    A concrete closure self-model with:
    - n admissible codes with specified energies
    - A canonical code for the self-sentence
    """

    def __init__(self, energies: List[float], canonical_index: int):
        self.energies = np.array(energies)
        self.n_codes = len(energies)
        self.canonical_index = canonical_index
        self.canonical_energy = energies[canonical_index]

    def partition_function(self, beta: float) -> float:
        """Z(β) = Σ_w exp(-β · E(w))"""
        return np.sum(np.exp(-beta * self.energies))

    def free_energy(self, beta: float) -> float:
        """F(β) = -log(Z(β)) / β"""
        Z = self.partition_function(beta)
        if Z > 0 and beta > 0:
            return -np.log(Z) / beta
        return 0.0

    def randomness_deficiency(self, beta: float) -> float:
        """D(β) = -(β · E_canonical + log Z(β))"""
        Z = self.partition_function(beta)
        if Z > 0:
            return -(beta * self.canonical_energy + np.log(Z))
        return 0.0

    def gibbs_weights(self, beta: float) -> np.ndarray:
        """Gibbs probabilities p_w = exp(-β E_w) / Z(β)"""
        Z = self.partition_function(beta)
        return np.exp(-beta * self.energies) / Z


def demo_barrier_inequality():
    """Show that D(β, selfSentence) ≤ 0 for various models and temperatures."""
    print("=" * 70)
    print("DEMO 1: Verifying the Thermodynamic Chaitin Barrier")
    print("=" * 70)
    print()

    model1 = ToyClosureSelfModel([1.0, 1.0, 1.0, 1.0], canonical_index=0)
    print("Model 1: 4 codes with uniform energy E=1.0, canonical index=0")

    model2 = ToyClosureSelfModel([0.5, 1.0, 2.0, 3.0, 5.0], canonical_index=0)
    print("Model 2: 5 codes, energies [0.5, 1.0, 2.0, 3.0, 5.0], canonical=low energy")

    model3 = ToyClosureSelfModel([0.5, 1.0, 2.0, 3.0, 5.0], canonical_index=4)
    print("Model 3: 5 codes, energies [0.5, 1.0, 2.0, 3.0, 5.0], canonical=high energy")

    print(f"\n{'β':>6} | {'D₁(β)':>10} | {'D₂(β)':>10} | {'D₃(β)':>10} | {'All ≤ 0?':>10}")
    print("-" * 55)

    for beta in [0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 50.0, 100.0]:
        d1 = model1.randomness_deficiency(beta)
        d2 = model2.randomness_deficiency(beta)
        d3 = model3.randomness_deficiency(beta)
        check = "✓" if d1 <= 1e-15 and d2 <= 1e-15 and d3 <= 1e-15 else "✗"
        print(f"{beta:6.2f} | {d1:10.6f} | {d2:10.6f} | {d3:10.6f} | {check:>10}")

    print("\nRESULT: D(β) ≤ 0 for all models and all β > 0. ✓")
    print()


def demo_chaitin_analogy():
    """Demonstrate the analogy with classical Chaitin incompleteness."""
    print("=" * 70)
    print("DEMO 2: Classical vs Thermodynamic Chaitin Incompleteness")
    print("=" * 70)
    print()
    print("CLASSICAL CHAITIN:")
    print("  K(x) = Kolmogorov complexity of x")
    print("  Theorem: ∃ c_T, ∀ x: T cannot prove K(x) > c_T")
    print()
    print("THERMODYNAMIC VERSION:")
    print("  D(β,φ) = -(β·E(canonical(φ)) + log Z(β))")
    print("  Theorem: ∀ β > 0: M cannot derive D(β, selfSentence) > 0")
    print()
    print("KEY ADVANTAGE: The thermodynamic constant is UNIVERSAL: c_M = 0.")
    print("No system-dependent overhead constant is needed!")
    print()

    model = ToyClosureSelfModel([1.0, 2.0, 3.0, 4.0, 5.0], canonical_index=0)
    for beta in [0.5, 1.0, 2.0]:
        Z = model.partition_function(beta)
        canon = np.exp(-beta * model.canonical_energy)
        D = model.randomness_deficiency(beta)
        print(f"  β={beta}: Z={Z:.4f}, exp(-βE)={canon:.4f}, ratio={canon/Z:.2%}, D={D:.6f} ≤ 0 ✓")
    print()


def plot_deficiency_landscape():
    """Plot randomness deficiency as a function of inverse temperature."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Thermodynamic Chaitin Barrier: Randomness Deficiency Landscape",
                 fontsize=14, fontweight='bold')

    betas = np.linspace(0.01, 10.0, 500)

    ax = axes[0, 0]
    models = [
        (ToyClosureSelfModel([1, 1, 1, 1], 0), "Uniform (4 codes, E=1)"),
        (ToyClosureSelfModel([0.5, 1, 2, 3, 5], 0), "Varied (canonical=low)"),
        (ToyClosureSelfModel([0.5, 1, 2, 3, 5], 4), "Varied (canonical=high)"),
        (ToyClosureSelfModel([1]*10, 0), "Large (10 codes)"),
    ]
    for model, label in models:
        deficiencies = [model.randomness_deficiency(b) for b in betas]
        ax.plot(betas, deficiencies, label=label, linewidth=2)
    ax.axhline(y=0, color='red', linestyle='--', linewidth=1.5, alpha=0.7, label="Barrier (D=0)")
    ax.set_xlabel("Inverse temperature β")
    ax.set_ylabel("Randomness deficiency D(β)")
    ax.set_title("Deficiency vs Temperature")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    ax = axes[0, 1]
    model = ToyClosureSelfModel([0.5, 1.0, 2.0, 3.0, 5.0], 2)
    Z_vals = [model.partition_function(b) for b in betas]
    canon = [np.exp(-b * model.canonical_energy) for b in betas]
    ax.plot(betas, Z_vals, 'b-', linewidth=2, label="Z(β)")
    ax.plot(betas, canon, 'r--', linewidth=2, label=f"exp(-βE), E={model.canonical_energy}")
    ax.fill_between(betas, canon, Z_vals, alpha=0.2, color='blue')
    ax.set_xlabel("Inverse temperature β")
    ax.set_ylabel("Value")
    ax.set_title("Partition Function vs Canonical Contribution")
    ax.legend(fontsize=8)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    ax = axes[1, 0]
    model = ToyClosureSelfModel([0.5, 1.0, 2.0, 3.0, 5.0], 2)
    width = 0.15
    offsets = [-0.3, -0.15, 0, 0.15, 0.3]
    for i, b_val in enumerate([0.1, 0.5, 1.0, 2.0, 5.0]):
        weights = model.gibbs_weights(b_val)
        ax.bar(np.arange(len(weights)) + offsets[i], weights, width=width,
               alpha=0.7, label=f"β={b_val}")
    ax.set_xlabel("Code index")
    ax.set_ylabel("Gibbs weight")
    ax.set_title("Gibbs Distribution at Different Temperatures")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    ax = axes[1, 1]
    for n in [3, 5, 10, 20]:
        m = ToyClosureSelfModel([float(e) for e in range(1, n + 1)], 0)
        fe = [m.free_energy(b) for b in betas]
        ax.plot(betas, fe, linewidth=2, label=f"n={n} codes")
    ax.set_xlabel("Inverse temperature β")
    ax.set_ylabel("Free energy F(β)")
    ax.set_title("Free Energy vs Temperature")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/thermodynamic_barrier_landscape.png", dpi=150, bbox_inches='tight')
    print("Saved: demos/thermodynamic_barrier_landscape.png")
    plt.close()


def plot_summary():
    """Create a summary figure showing the theorem's content."""
    fig, ax = plt.subplots(figsize=(10, 6))

    model = ToyClosureSelfModel([0.5, 1.0, 1.5, 2.0, 3.0, 4.0, 5.0, 7.0], 2)
    betas = np.linspace(0.01, 8.0, 500)
    deficiencies = [model.randomness_deficiency(b) for b in betas]

    ax.fill_between(betas, 0, 3, alpha=0.15, color='red', label="FORBIDDEN: D > 0 (unprovable)")
    ax.fill_between(betas, -5, 0, alpha=0.1, color='green', label="ALLOWED: D ≤ 0")
    ax.plot(betas, deficiencies, 'b-', linewidth=3, label="D(β, selfSentence)")
    ax.axhline(y=0, color='red', linestyle='-', linewidth=2, alpha=0.8)

    ax.annotate("Thermodynamic\nChaitin Barrier",
                xy=(4, 0), xytext=(5, 1.5),
                fontsize=12, fontweight='bold', color='red',
                arrowprops=dict(arrowstyle='->', color='red', lw=2))

    ax.set_xlabel("Inverse temperature β", fontsize=12)
    ax.set_ylabel("Randomness deficiency D(β)", fontsize=12)
    ax.set_title("The Thermodynamic Chaitin Barrier\n"
                 "No sound system can prove D(β, selfSentence) > 0",
                 fontsize=14, fontweight='bold')
    ax.set_ylim(-5, 3)
    ax.legend(fontsize=11, loc='lower right')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/thermodynamic_chaitin_barrier_summary.png", dpi=150, bbox_inches='tight')
    print("Saved: demos/thermodynamic_chaitin_barrier_summary.png")
    plt.close()


def demo_certified_bounds():
    """Show how the theorem extracts certified bounds."""
    print("=" * 70)
    print("DEMO 3: Certified Deficiency Bounds")
    print("=" * 70)
    print()
    print("If a system claims D(β, self) > c for c > 0, it is UNSOUND.")
    print()

    test_cases = [
        ("System A", [1.0, 2.0, 3.0], 0),
        ("System B", [0.1, 0.5, 1.0, 5.0, 10.0], 2),
        ("System C", [2.0, 2.0, 2.0, 2.0], 3),
    ]

    for name, energies, cidx in test_cases:
        model = ToyClosureSelfModel(energies, cidx)
        worst = max(model.randomness_deficiency(b) for b in np.linspace(0.01, 100, 1000))
        status = "✓ SOUND" if worst <= 1e-12 else "✗ ISSUE"
        print(f"  {name}: sup D = {worst:.10f}  →  {status}")
    print()


if __name__ == "__main__":
    os.makedirs("demos", exist_ok=True)

    demo_barrier_inequality()
    demo_chaitin_analogy()
    demo_certified_bounds()

    print("=" * 70)
    print("GENERATING VISUALIZATIONS")
    print("=" * 70)
    plot_deficiency_landscape()
    plot_summary()

    print()
    print("ALL DEMOS COMPLETE ✓")
    print()
    print("Key result: D(β, φ) ≤ 0 always, because the canonical code")
    print("contributes to Z(β), giving exp(-βE) ≤ Z(β), hence D ≤ 0.")
    print("No sound system can derive D > 0: the Thermodynamic Chaitin Barrier.")
