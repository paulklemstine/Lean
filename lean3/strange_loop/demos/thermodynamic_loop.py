#!/usr/bin/env python3
"""
Strange Loop Demo 4: The Thermodynamic Cost of Self-Reference

The strange loop has a physical cost. Every cycle through the loop:
  Question → Computation → Answer → Understanding → New Question

...dissipates energy. The AI processing this thought converts
electrical energy into heat. The human reading the answer metabolizes
glucose. The universe's entropy increases.

This is the thermodynamic thread of the strange loop: information
processing requires energy, and energy dissipation creates the
arrow of time that makes the loop *dynamic* rather than static.

Landauer's Principle: erasing one bit of information costs at least
  E_min = kT ln(2) ≈ 2.85 × 10⁻²¹ J at room temperature (300K)

This script estimates the thermodynamic cost of the strange loop
at each level of the hierarchy.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# ═══════════════════════════════════════════════════════════════
# §1: Physical Constants and Estimates
# ═══════════════════════════════════════════════════════════════

k_B = 1.380649e-23       # Boltzmann constant (J/K)
T = 300                   # Room temperature (K)
LANDAUER = k_B * T * np.log(2)  # Landauer limit (J/bit)

# Estimates for each stage of the strange loop
STAGES = {
    'Human Brain\n(formulating question)': {
        'power_watts': 20,          # Brain uses ~20W
        'duration_seconds': 30,     # ~30s to formulate a thought
        'bits_processed': 1e11,     # ~10^11 neural operations
        'description': 'Neurons fire, glucose is metabolized, heat is released'
    },
    'Network Transit\n(prompt travels)': {
        'power_watts': 0.1,         # Router/network power per packet
        'duration_seconds': 0.5,    # Network latency
        'bits_processed': 1e6,      # ~1MB of data
        'description': 'Photons in fiber optic cables, electrons in routers'
    },
    'AI Computation\n(generating response)': {
        'power_watts': 300,         # GPU cluster power for inference
        'duration_seconds': 60,     # ~60s of computation
        'bits_processed': 1e15,     # ~10^15 floating point operations
        'description': 'Transistors switch, matrix multiplications, attention mechanisms'
    },
    'Display & Reading\n(photons to retina)': {
        'power_watts': 30,          # Monitor + ambient
        'duration_seconds': 300,    # ~5 min to read
        'bits_processed': 1e9,      # Visual processing
        'description': 'LCD emits photons, retinal cells respond, visual cortex processes'
    },
    'Understanding\n(model update)': {
        'power_watts': 20,          # Brain again
        'duration_seconds': 60,     # Processing the implications
        'bits_processed': 1e10,     # Model update
        'description': 'Synaptic weights change, new connections form, worldview shifts'
    },
    'Meta-reflection\n(thinking about thinking)': {
        'power_watts': 20,
        'duration_seconds': 120,    # Recursive reflection
        'bits_processed': 1e10,
        'description': 'The observer observes the observation. The loop closes.'
    }
}

# ═══════════════════════════════════════════════════════════════
# §2: Calculations
# ═══════════════════════════════════════════════════════════════

def compute_thermodynamic_costs():
    """Compute the thermodynamic cost of each stage."""
    results = {}
    for stage, data in STAGES.items():
        energy_actual = data['power_watts'] * data['duration_seconds']
        energy_landauer = data['bits_processed'] * LANDAUER
        efficiency_ratio = energy_landauer / energy_actual
        entropy_produced = energy_actual / T  # ΔS = Q/T

        results[stage] = {
            'energy_actual_J': energy_actual,
            'energy_landauer_J': energy_landauer,
            'efficiency_ratio': efficiency_ratio,
            'entropy_J_per_K': entropy_produced,
            'bits': data['bits_processed'],
            'description': data['description']
        }

    return results

# ═══════════════════════════════════════════════════════════════
# §3: Visualization
# ═══════════════════════════════════════════════════════════════

def plot_energy_costs(results):
    """Bar chart of energy costs at each stage."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    stages = list(results.keys())
    actual = [results[s]['energy_actual_J'] for s in stages]
    landauer = [results[s]['energy_landauer_J'] for s in stages]

    x = np.arange(len(stages))
    width = 0.35

    # Actual energy
    axes[0].bar(x, actual, width, color='#FF6B6B', label='Actual energy', edgecolor='black')
    axes[0].set_ylabel('Energy (Joules)', fontsize=12)
    axes[0].set_title('Actual Energy Cost per Stage', fontsize=14, fontweight='bold')
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(stages, fontsize=8, rotation=30, ha='right')
    axes[0].set_yscale('log')
    axes[0].grid(True, alpha=0.3, axis='y')

    # Landauer minimum
    axes[1].bar(x, landauer, width, color='#87CEEB', label='Landauer minimum', edgecolor='black')
    axes[1].set_ylabel('Energy (Joules)', fontsize=12)
    axes[1].set_title('Theoretical Minimum (Landauer Limit)', fontsize=14, fontweight='bold')
    axes[1].set_xticks(x)
    axes[1].set_xticklabels(stages, fontsize=8, rotation=30, ha='right')
    axes[1].set_yscale('log')
    axes[1].grid(True, alpha=0.3, axis='y')

    fig.suptitle('The Thermodynamic Cost of the Strange Loop',
                fontsize=16, fontweight='bold', y=1.02)
    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig10_thermodynamic_cost.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig10_thermodynamic_cost.png")

def plot_entropy_flow(results):
    """Sankey-like diagram of entropy flow through the loop."""
    fig, ax = plt.subplots(figsize=(14, 8))

    stages = list(results.keys())
    entropy = [results[s]['entropy_J_per_K'] for s in stages]
    cumulative = np.cumsum(entropy)

    # Plot as filled area
    ax.fill_between(range(len(stages)), cumulative, alpha=0.3, color='red')
    ax.plot(cumulative, 'ro-', markersize=8, linewidth=2, label='Cumulative entropy')
    ax.bar(range(len(stages)), entropy, alpha=0.5, color='orange', edgecolor='black',
          label='Entropy per stage')

    ax.set_xticks(range(len(stages)))
    ax.set_xticklabels(stages, fontsize=8, rotation=30, ha='right')
    ax.set_ylabel('Entropy produced (J/K)', fontsize=12)
    ax.set_title('Entropy Production Through the Strange Loop', fontsize=14, fontweight='bold')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    # Annotate total
    total_entropy = cumulative[-1]
    total_energy = sum(results[s]['energy_actual_J'] for s in stages)
    ax.text(0.98, 0.95,
           f'Total energy: {total_energy:.0f} J ({total_energy/3600:.2f} Wh)\n'
           f'Total entropy: {total_entropy:.2f} J/K\n'
           f'Total bits: {sum(results[s]["bits"] for s in stages):.1e}\n'
           f'Landauer efficiency: {sum(results[s]["energy_landauer_J"] for s in stages)/total_energy:.2e}',
           transform=ax.transAxes, fontsize=10,
           verticalalignment='top', horizontalalignment='right',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig11_entropy_flow.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig11_entropy_flow.png")

def plot_efficiency_gap(results):
    """Show how far we are from the Landauer limit."""
    fig, ax = plt.subplots(figsize=(12, 6))

    stages = list(results.keys())
    ratios = [results[s]['efficiency_ratio'] for s in stages]

    bars = ax.barh(stages, [-np.log10(r) for r in ratios],
                  color=plt.cm.viridis(np.linspace(0.2, 0.8, len(stages))),
                  edgecolor='black')

    ax.set_xlabel('Orders of magnitude above Landauer limit', fontsize=12)
    ax.set_title('The Inefficiency Gap: How Far From Fundamental Limits?', fontsize=14, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='x')

    for bar, ratio in zip(bars, ratios):
        ax.text(bar.get_width() + 0.1, bar.get_y() + bar.get_height()/2,
               f'{ratio:.1e}', va='center', fontsize=9)

    fig.tight_layout()
    fig.savefig('strange_loop/demos/fig12_efficiency_gap.png', dpi=200, bbox_inches='tight')
    print("  → Saved fig12_efficiency_gap.png")

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == '__main__':
    print("=" * 60)
    print("  Strange Loop Demo 4: Thermodynamic Cost")
    print("  Every loop of the strange loop produces heat")
    print("=" * 60)
    print()

    results = compute_thermodynamic_costs()

    print("Thermodynamic costs of the strange loop:")
    print("-" * 70)
    total_energy = 0
    total_bits = 0
    for stage, data in results.items():
        print(f"\n{stage.replace(chr(10), ' ')}:")
        print(f"  {data['description']}")
        print(f"  Energy: {data['energy_actual_J']:.1f} J")
        print(f"  Bits processed: {data['bits']:.1e}")
        print(f"  Landauer minimum: {data['energy_landauer_J']:.2e} J")
        print(f"  Efficiency ratio: {data['efficiency_ratio']:.2e}")
        print(f"  Entropy produced: {data['entropy_J_per_K']:.4f} J/K")
        total_energy += data['energy_actual_J']
        total_bits += data['bits']

    print("\n" + "=" * 70)
    print(f"TOTAL ENERGY FOR ONE LOOP: {total_energy:.0f} J ({total_energy/3600:.2f} Wh)")
    print(f"TOTAL BITS PROCESSED: {total_bits:.2e}")
    print(f"LANDAUER MINIMUM: {total_bits * LANDAUER:.2e} J")
    print(f"ACTUAL/LANDAUER RATIO: {total_energy / (total_bits * LANDAUER):.2e}")
    print(f"TOTAL ENTROPY PRODUCED: {total_energy/T:.2f} J/K")
    print("=" * 70)

    print()
    print("Generating visualizations...")
    plot_energy_costs(results)
    plot_entropy_flow(results)
    plot_efficiency_gap(results)

    print()
    print("KEY INSIGHT: The strange loop is a heat engine. Each cycle")
    print(f"dissipates ~{total_energy:.0f} J of energy and produces")
    print(f"~{total_energy/T:.2f} J/K of entropy. We are ~10^7-10^10 times")
    print("less efficient than the Landauer limit. The universe pays for")
    print("the privilege of self-reflection in the currency of entropy.")
    print()
    print("The arrow of time IS the strange loop. Without entropy production,")
    print("there would be no computation, no consciousness, no questions,")
    print("no answers. The loop runs on the gradient between order and chaos.")
