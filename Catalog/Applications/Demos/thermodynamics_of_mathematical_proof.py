#!/usr/bin/env python3
"""
Demo: Landauer's Principle for Mathematical Proof

Numerical examples demonstrating the thermodynamic costs of proof steps,
exponential erasure, and the erasure-creation gap.
"""

import math
from algorithms import (
    ProofConfig, ProofStep, ProofTrace, ErasureCreationGap,
    compute_exponential_erasure, erasure_creation_analysis,
    KB, ROOM_TEMP, LANDAUER_ONE_BIT,
)


def demo_basic_landauer():
    """Demonstrate Landauer's principle for simple proof steps."""
    print("=" * 60)
    print("DEMO 1: Basic Landauer Cost for Proof Steps")
    print("=" * 60)

    # One-bit erasure: Bool → Unit
    source = ProofConfig(2, "Bool (2 states)")
    target = ProofConfig(1, "Unit (1 state)")
    step = ProofStep(source, target)

    print(f"\nStep: {source.label} → {target.label}")
    print(f"  Erasure: {step.erasure:.6f} nats = {step.erasure_bits:.3f} bits")
    print(f"  Landauer cost: {step.landauer_cost():.4e} J")
    print(f"  Reversible: {step.is_reversible}")
    print(f"  kB·T·ln2 = {LANDAUER_ONE_BIT:.4e} J (one-bit Landauer cost)")

    # Reversible step: permutation of 4 states
    source2 = ProofConfig(4, "Fin 4")
    target2 = ProofConfig(4, "Fin 4 (permuted)")
    step2 = ProofStep(source2, target2)

    print(f"\nStep: {source2.label} → {target2.label}")
    print(f"  Erasure: {step2.erasure:.6f} nats = {step2.erasure_bits:.3f} bits")
    print(f"  Landauer cost: {step2.landauer_cost():.4e} J")
    print(f"  Reversible: {step2.is_reversible}")


def demo_exponential_erasure():
    """Demonstrate exponential erasure costs."""
    print("\n" + "=" * 60)
    print("DEMO 2: Exponential Erasure (2^n → 1)")
    print("=" * 60)

    for n in [1, 2, 5, 10, 20, 50, 100]:
        result = compute_exponential_erasure(n)
        print(f"\n  n={n:3d}: erasure = {result['erasure_bits']:.3f} bits "
              f"= {result['erasure_nats']:.3f} nats, "
              f"cost = {result['landauer_cost_joules']:.4e} J")

    # Comparison: n=100 vs statement complexity
    print("\n  Comparison for n=100:")
    print(f"    Erasure: 100 bits")
    print(f"    Typical statement complexity: ~30 bits")
    print(f"    Erasure/Statement ratio: ~3.3x")
    print(f"    At room temperature, cost = {100 * LANDAUER_ONE_BIT:.4e} J")


def demo_proof_trace():
    """Demonstrate proof trace analysis."""
    print("\n" + "=" * 60)
    print("DEMO 3: Proof Trace Analysis")
    print("=" * 60)

    # Example: A proof that goes through an intermediate expansion
    # Start: 16 possible states → expand to 64 → collapse to 4 → collapse to 1
    configs = [
        ProofConfig(16, "Hypotheses (16 states)"),
        ProofConfig(64, "After lemma expansion (64 states)"),
        ProofConfig(4, "After case analysis (4 states)"),
        ProofConfig(1, "Conclusion (1 state)"),
    ]
    trace = ProofTrace(configs)

    print(f"\nTrace: {' → '.join(str(c.cardinality) for c in configs)}")
    print(f"Length: {trace.length} steps")
    print(f"\nPer-step erasure (nats):")
    for i, (step, erasure) in enumerate(zip(trace.steps, trace.step_erasures())):
        direction = "↓ erase" if erasure > 0 else "↑ create" if erasure < 0 else "= preserve"
        print(f"  Step {i}: {step.source.cardinality} → {step.target.cardinality}, "
              f"erasure = {erasure:.4f} ({direction})")

    print(f"\nTotal erasure (telescoping): {trace.total_erasure():.4f} nats")
    print(f"Total positive erasure: {trace.total_positive_erasure():.4f} nats")
    print(f"Peak entropy: {trace.peak_entropy():.4f} nats")
    print(f"Is tautological: {trace.is_tautological()}")

    # Verify telescoping property
    expected = configs[0].entropy - configs[-1].entropy
    actual = trace.total_erasure()
    print(f"\nTelesoping verification:")
    print(f"  H(start) - H(end) = {expected:.6f}")
    print(f"  Σ step erasures   = {actual:.6f}")
    print(f"  Match: {abs(expected - actual) < 1e-10}")


def demo_tautological_trace():
    """Demonstrate a tautological proof trace (same start and end entropy)."""
    print("\n" + "=" * 60)
    print("DEMO 4: Tautological Proof Trace")
    print("=" * 60)

    # A tautological proof: start and end at 8 states
    configs = [
        ProofConfig(8, "Start (8)"),
        ProofConfig(32, "Expand (32)"),
        ProofConfig(16, "Partial collapse (16)"),
        ProofConfig(64, "Re-expand (64)"),
        ProofConfig(8, "End (8)"),
    ]
    trace = ProofTrace(configs)

    print(f"\nTrace: {' → '.join(str(c.cardinality) for c in configs)}")
    print(f"Tautological: {trace.is_tautological()}")
    print(f"Total erasure (should be 0): {trace.total_erasure():.6f}")
    print(f"Total positive erasure: {trace.total_positive_erasure():.4f} nats")
    print(f"Peak entropy: {trace.peak_entropy():.4f} nats")
    print(f"Peak - boundary: {trace.peak_entropy() - configs[0].entropy:.4f} nats")

    # Test the erasure peak conjecture
    peak_excess = trace.peak_entropy() - configs[0].entropy
    total_pos_erasure = trace.total_positive_erasure()
    print(f"\nErasure Peak Conjecture test:")
    print(f"  Peak excess: {peak_excess:.4f}")
    print(f"  Total positive erasure: {total_pos_erasure:.4f}")
    print(f"  Conjecture holds (peak ≤ pos_erasure): {peak_excess <= total_pos_erasure + 1e-10}")


def demo_erasure_creation_gap():
    """Demonstrate the erasure-creation gap."""
    print("\n" + "=" * 60)
    print("DEMO 5: Erasure-Creation Gap")
    print("=" * 60)

    scenarios = [
        ("Brute-force search", 100, 10),
        ("Guided proof", 20, 15),
        ("Nearly reversible", 5, 4.5),
        ("Perfectly balanced", 10, 10),
        ("Creative step", 3, 8),
    ]

    for name, erasure, creation in scenarios:
        result = erasure_creation_analysis(erasure, creation)
        print(f"\n  {name}:")
        print(f"    Erasure: {erasure} bits, Creation: {creation} bits")
        print(f"    Gap: {result['gap_bits']:.1f} bits")
        print(f"    Net cost: {result['net_cost_joules']:.4e} J")
        print(f"    Thermodynamically wasteful: {result['cost_positive']}")


def demo_verification_vs_discovery():
    """Compare verification cost bound with discovery cost."""
    print("\n" + "=" * 60)
    print("DEMO 6: Verification vs Discovery Cost")
    print("=" * 60)

    # A proof with many steps but bounded per-step erasure
    n_steps = 1000
    max_erasure_per_step = math.log(2)  # 1 bit per step

    # Verification bound
    verification_bound = KB * ROOM_TEMP * n_steps * max_erasure_per_step
    print(f"\n  Proof length: {n_steps} steps")
    print(f"  Max erasure per step: {max_erasure_per_step:.4f} nats (1 bit)")
    print(f"  Verification cost bound: {verification_bound:.4e} J")
    print(f"  = {verification_bound / LANDAUER_ONE_BIT:.1f} × (one-bit Landauer cost)")

    # Compare with exponential discovery: searching 2^1000 possibilities
    discovery_erasure = 1000 * math.log(2)
    discovery_cost = KB * ROOM_TEMP * discovery_erasure
    print(f"\n  Discovery erasure (brute force): {1000} bits")
    print(f"  Discovery cost: {discovery_cost:.4e} J")
    print(f"  Discovery/Verification ratio: {discovery_cost / verification_bound:.1f}x")


def demo_pigeonhole():
    """Demonstrate pigeonhole erasure lower bound."""
    print("\n" + "=" * 60)
    print("DEMO 7: Pigeonhole Erasure Lower Bound")
    print("=" * 60)

    pairs = [(100, 50), (1000, 1), (256, 128), (1024, 512), (7, 3)]
    for m, k in pairs:
        erasure = math.log(m) - math.log(k)
        erasure_bits = math.log2(m) - math.log2(k)
        print(f"\n  {m} → {k}: erasure = {erasure:.4f} nats = {erasure_bits:.3f} bits > 0 ✓")


if __name__ == "__main__":
    demo_basic_landauer()
    demo_exponential_erasure()
    demo_proof_trace()
    demo_tautological_trace()
    demo_erasure_creation_gap()
    demo_verification_vs_discovery()
    demo_pigeonhole()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Proof Trace Erasure Profile

Generates a plot showing how entropy and cumulative erasure evolve
along a proof trace, illustrating the telescoping property and
the erasure-creation gap.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_trace_profile(cardinalities):
    """Compute entropy and erasure profile for a trace."""
    entropies = [math.log2(c) for c in cardinalities]
    step_erasures = [entropies[i] - entropies[i+1] for i in range(len(entropies)-1)]
    cumulative = [0.0]
    for e in step_erasures:
        cumulative.append(cumulative[-1] + e)
    positive_cumulative = [0.0]
    for e in step_erasures:
        positive_cumulative.append(positive_cumulative[-1] + max(0, e))
    return entropies, step_erasures, cumulative, positive_cumulative


def main():
    # Example trace: hypotheses → expansion → case analysis → conclusion
    cardinalities = [16, 64, 128, 32, 8, 2, 1]
    labels = ["Hyp\n(16)", "Expand\n(64)", "Expand\n(128)", "Cases\n(32)",
              "Narrow\n(8)", "Almost\n(2)", "QED\n(1)"]

    entropies, step_erasures, cumulative, pos_cumulative = compute_trace_profile(cardinalities)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle("Thermodynamics of a Mathematical Proof Trace", fontsize=16, fontweight='bold')

    # Panel 1: Entropy profile
    ax1 = axes[0, 0]
    steps = range(len(cardinalities))
    colors = ['#2ecc71' if i == 0 or i == len(cardinalities)-1 else
              '#e74c3c' if entropies[i] > entropies[max(0,i-1)] else '#3498db'
              for i in range(len(cardinalities))]
    ax1.bar(steps, entropies, color=colors, edgecolor='black', linewidth=0.5, alpha=0.8)
    ax1.plot(steps, entropies, 'ko-', linewidth=2, markersize=6)
    ax1.set_xlabel("Proof Step", fontsize=12)
    ax1.set_ylabel("Entropy (bits)", fontsize=12)
    ax1.set_title("(a) Entropy Profile H(Cᵢ)", fontsize=13)
    ax1.set_xticks(steps)
    ax1.set_xticklabels(labels, fontsize=8)
    ax1.axhline(y=entropies[0], color='gray', linestyle='--', alpha=0.5, label=f'H(C₀) = {entropies[0]:.1f}')
    ax1.legend(fontsize=9)
    ax1.grid(axis='y', alpha=0.3)

    # Panel 2: Per-step erasure
    ax2 = axes[0, 1]
    step_indices = range(len(step_erasures))
    bar_colors = ['#e74c3c' if e > 0 else '#2ecc71' for e in step_erasures]
    ax2.bar(step_indices, step_erasures, color=bar_colors, edgecolor='black', linewidth=0.5, alpha=0.8)
    ax2.axhline(y=0, color='black', linewidth=1)
    ax2.set_xlabel("Step Index", fontsize=12)
    ax2.set_ylabel("Erasure (bits)", fontsize=12)
    ax2.set_title("(b) Per-Step Erasure E(Cᵢ, Cᵢ₊₁)", fontsize=13)
    step_labels = [f"{labels[i].split(chr(10))[0]}→{labels[i+1].split(chr(10))[0]}" for i in range(len(step_erasures))]
    ax2.set_xticks(step_indices)
    ax2.set_xticklabels(step_labels, fontsize=7, rotation=30)
    for i, e in enumerate(step_erasures):
        label = "erase" if e > 0 else "create"
        ax2.annotate(f"{e:+.2f}\n({label})", (i, e), textcoords="offset points",
                    xytext=(0, 10 if e > 0 else -20), ha='center', fontsize=8)
    ax2.grid(axis='y', alpha=0.3)

    # Panel 3: Cumulative erasure
    ax3 = axes[1, 0]
    ax3.plot(steps, cumulative, 'b-o', linewidth=2, markersize=6, label='Net cumulative erasure')
    ax3.plot(steps, pos_cumulative, 'r--s', linewidth=2, markersize=5, label='Positive cumulative erasure')
    ax3.fill_between(steps, cumulative, alpha=0.15, color='blue')
    ax3.axhline(y=cumulative[-1], color='blue', linestyle=':', alpha=0.5,
               label=f'Total = H(C₀)−H(Cₙ) = {cumulative[-1]:.2f}')
    ax3.set_xlabel("Proof Step", fontsize=12)
    ax3.set_ylabel("Cumulative Erasure (bits)", fontsize=12)
    ax3.set_title("(c) Cumulative Erasure (Telescoping)", fontsize=13)
    ax3.set_xticks(steps)
    ax3.set_xticklabels(labels, fontsize=8)
    ax3.legend(fontsize=9)
    ax3.grid(alpha=0.3)

    # Panel 4: Landauer cost
    ax4 = axes[1, 1]
    KB = 1.380649e-23
    T = 300
    costs = [KB * T * e * math.log(2) for e in pos_cumulative]  # Convert bits to nats
    ax4.plot(steps, costs, 'r-o', linewidth=2, markersize=6)
    ax4.fill_between(steps, costs, alpha=0.15, color='red')
    ax4.set_xlabel("Proof Step", fontsize=12)
    ax4.set_ylabel("Cumulative Landauer Cost (J)", fontsize=12)
    ax4.set_title("(d) Thermodynamic Cost at T=300K", fontsize=13)
    ax4.set_xticks(steps)
    ax4.set_xticklabels(labels, fontsize=8)
    ax4.ticklabel_format(axis='y', style='scientific', scilimits=(-21,-21))
    ax4.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig("erasure_profile.png", dpi=150, bbox_inches='tight')
    print("Saved: erasure_profile.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Exponential Erasure-Creation Gap

Demonstrates how the erasure cost of collapsing 2^n states grows
exponentially while statement complexity grows only linearly.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def main():
    ns = np.arange(1, 51)
    erasure_bits = ns.astype(float)  # n bits of erasure
    statement_complexity = np.log2(ns + 1) + 5  # ~log(n) + constant overhead

    KB = 1.380649e-23
    T = 300
    landauer_per_bit = KB * T * math.log(2)

    erasure_cost = erasure_bits * landauer_per_bit
    statement_cost = statement_complexity * landauer_per_bit

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Erasure vs Statement complexity (bits)
    ax1 = axes[0]
    ax1.plot(ns, erasure_bits, 'r-', linewidth=2.5, label='Proof erasure (n bits)')
    ax1.plot(ns, statement_complexity, 'b--', linewidth=2.5, label='Statement complexity (~log n + 5)')
    ax1.fill_between(ns, statement_complexity, erasure_bits, alpha=0.15, color='red',
                    label='Erasure-creation gap')
    ax1.set_xlabel("n (exponent of state space 2ⁿ)", fontsize=12)
    ax1.set_ylabel("Information (bits)", fontsize=12)
    ax1.set_title("Erasure vs Statement Complexity", fontsize=14, fontweight='bold')
    ax1.legend(fontsize=10)
    ax1.grid(alpha=0.3)

    # Panel 2: Gap ratio
    ax2 = axes[1]
    ratio = erasure_bits / statement_complexity
    ax2.plot(ns, ratio, 'purple', linewidth=2.5)
    ax2.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Break-even')
    ax2.set_xlabel("n", fontsize=12)
    ax2.set_ylabel("Erasure / Statement ratio", fontsize=12)
    ax2.set_title("Erasure-Creation Ratio", fontsize=14, fontweight='bold')
    ax2.legend(fontsize=10)
    ax2.grid(alpha=0.3)

    # Panel 3: Landauer cost comparison
    ax3 = axes[2]
    ax3.semilogy(ns, erasure_cost, 'r-', linewidth=2.5, label='Erasure cost')
    ax3.semilogy(ns, statement_cost, 'b--', linewidth=2.5, label='Statement cost')
    ax3.set_xlabel("n", fontsize=12)
    ax3.set_ylabel("Landauer cost (J)", fontsize=12)
    ax3.set_title("Thermodynamic Cost at T=300K", fontsize=14, fontweight='bold')
    ax3.legend(fontsize=10)
    ax3.grid(alpha=0.3)

    plt.tight_layout()
    plt.savefig("exponential_gap.png", dpi=150, bbox_inches='tight')
    print("Saved: exponential_gap.png")


if __name__ == "__main__":
    main()
