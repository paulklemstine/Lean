#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of Digital Immortality bounds.

Illustrates the key information-theoretic results:
1. Connectome space grows doubly exponentially
2. Compression impossibility via pigeonhole
3. Bekenstein capacity vs. connectome requirements
4. Data processing inequality for mind uploading
5. Incompressible connectome fraction
"""

import math
from algorithms import (
    connectome_space_size, mind_encoding_bound, bekenstein_capacity,
    max_neurons_for_capacity, compression_ratio, simulation_fidelity,
    composition_fidelity, incompressible_fraction, neuron_scaling_cost,
    digital_immortality_gap, HUMAN_NEURONS, BRAIN_RADIUS, BRAIN_REST_MASS_ENERGY
)


def demo_connectome_counting():
    """Demonstrate doubly exponential growth of connectome space."""
    print("=" * 60)
    print("DEMO 1: Connectome Space Size (Doubly Exponential Growth)")
    print("=" * 60)
    print(f"{'Neurons':>8} {'Edges':>10} {'Connectomes':>30} {'Bits':>8}")
    print("-" * 60)
    for n in [2, 3, 4, 5, 6, 7, 8, 10, 15, 20]:
        edges = n * n
        size = connectome_space_size(n)
        bits = mind_encoding_bound(n)
        size_str = f"{size:,}" if size < 10**15 else f"~10^{math.log10(size):.1f}"
        print(f"{n:>8} {edges:>10} {size_str:>30} {bits:>8}")
    print()


def demo_compression_impossibility():
    """Show that sub-quadratic compression is impossible."""
    print("=" * 60)
    print("DEMO 2: Compression Impossibility (Pigeonhole Principle)")
    print("=" * 60)
    for n in [3, 5, 10, 20]:
        required = mind_encoding_bound(n)
        for ratio_pct in [50, 75, 90, 100]:
            target = int(required * ratio_pct / 100)
            cr = compression_ratio(n, target)
            possible = "✓ POSSIBLE" if target >= required else "✗ IMPOSSIBLE"
            print(f"  n={n:>3}, target={target:>4} bits "
                  f"(ratio={cr:.2f}): {possible}")
        print()


def demo_bekenstein_brain():
    """Compare Bekenstein capacity to connectome requirements."""
    print("=" * 60)
    print("DEMO 3: Bekenstein Bound vs. Connectome Requirements")
    print("=" * 60)
    
    bek = bekenstein_capacity(BRAIN_RADIUS, BRAIN_REST_MASS_ENERGY)
    print(f"Human brain Bekenstein capacity: ~{bek:.2e} bits")
    print(f"  (radius = {BRAIN_RADIUS} m, rest-mass energy = {BRAIN_REST_MASS_ENERGY:.2e} J)")
    
    max_n = max_neurons_for_capacity(bek)
    print(f"Max neurons for full connectome: ~{max_n:.2e}")
    
    n = HUMAN_NEURONS
    required = mind_encoding_bound(n)
    gap = digital_immortality_gap(n, int(bek))
    print(f"\nHuman brain ({n:,} neurons):")
    print(f"  Required bits: ~10^{math.log10(required):.1f}")
    print(f"  Bekenstein cap: ~10^{math.log10(bek):.1f}")
    if gap > 0:
        print(f"  Gap: ~10^{math.log10(gap):.1f} bits (FAITHFUL ENCODING IMPOSSIBLE)")
    else:
        print(f"  Gap: 0 (encoding is physically possible)")
    print()


def demo_data_processing():
    """Demonstrate the data processing inequality for mind uploading."""
    print("=" * 60)
    print("DEMO 4: Data Processing Inequality (Fidelity Decay)")
    print("=" * 60)
    
    # Simulate a 3-stage mind uploading pipeline
    # Stage 1: Brain scanning (10 mind states → 8 digital states)
    scan = {i: i % 8 for i in range(10)}
    # Stage 2: Compression (8 states → 5 states)
    compress = {i: i % 5 for i in range(8)}
    # Stage 3: Simulation (5 states → 4 states)  
    simulate = {i: i % 4 for i in range(5)}
    
    fid_scan = simulation_fidelity(scan)
    fid_compress = simulation_fidelity(compress)
    fid_simulate = simulation_fidelity(simulate)
    
    # Composition fidelities
    fid_sc, fid_sc_comp = composition_fidelity(scan, compress)
    
    # Full pipeline
    full = {k: simulate.get(compress.get(v)) for k, v in scan.items() 
            if v in compress and compress[v] in simulate}
    fid_full = len(set(full.values()))
    
    print(f"  Mind states:       10")
    print(f"  After scanning:    {fid_scan} distinguishable states")
    print(f"  After compression: {fid_sc_comp} distinguishable states")
    print(f"  After simulation:  {fid_full} distinguishable states")
    print(f"\n  ⟹ Each stage can only lose information, never gain it.")
    print(f"  ⟹ 10 ≥ {fid_scan} ≥ {fid_sc_comp} ≥ {fid_full} (monotone decrease)")
    print()


def demo_incompressibility():
    """Show that most connectomes are incompressible."""
    print("=" * 60)
    print("DEMO 5: Incompressible Connectomes (Counting Argument)")
    print("=" * 60)
    
    for n in [3, 5, 8, 10]:
        total = connectome_space_size(n)
        bits = mind_encoding_bound(n)
        for k in [1, 5, 10]:
            if k <= bits:
                frac = incompressible_fraction(n, k)
                print(f"  n={n:>3}: {frac*100:.4f}% of connectomes need "
                      f"≥ {bits - k} bits (k={k})")
        print()


def demo_scaling_law():
    """Show the quadratic scaling law for neuron addition."""
    print("=" * 60)
    print("DEMO 6: Neuron Scaling Law (Marginal Cost)")
    print("=" * 60)
    print(f"{'n':>5} {'Bits needed':>12} {'Marginal cost':>14} {'Cost/n':>8}")
    print("-" * 45)
    for n in range(1, 21):
        bits = mind_encoding_bound(n)
        cost = neuron_scaling_cost(n - 1) if n > 0 else 0
        ratio = cost / n if n > 0 else 0
        print(f"{n:>5} {bits:>12} {cost:>14} {ratio:>8.1f}")
    print()
    print("Note: Marginal cost grows linearly in n → total cost is quadratic.")
    print()


if __name__ == "__main__":
    print("\n" + "=" * 60)
    print("  DIGITAL IMMORTALITY: CAN A MIND BE ENCODED?")
    print("  Information-Theoretic Bounds on Mind Uploading")
    print("=" * 60 + "\n")
    
    demo_connectome_counting()
    demo_compression_impossibility()
    demo_bekenstein_brain()
    demo_data_processing()
    demo_incompressibility()
    demo_scaling_law()
    
    print("=" * 60)
    print("CONCLUSION: The quadratic barrier n² is fundamental.")
    print("No compression scheme, no matter how clever, can reduce")
    print("the description of a generic connectome below n² bits.")
    print("For the human brain (~86 billion neurons), this means")
    print(f"~{HUMAN_NEURONS**2:.1e} bits ≈ 10^{2*math.log10(HUMAN_NEURONS):.0f} bits")
    print("are required for faithful encoding — far beyond any")
    print("foreseeable storage technology.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Connectome space size and encoding bounds.
Standalone script using matplotlib.
"""

import math

def connectome_space_size(n):
    return 2 ** (n * n)

def mind_encoding_bound(n):
    return n * n

def plot_connectome_bounds():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
        matplotlib.use('Agg')
    except ImportError:
        print("matplotlib not available, skipping plot")
        return

    neurons = list(range(1, 16))
    bits_needed = [mind_encoding_bound(n) for n in neurons]
    log_space = [n * n * math.log10(2) for n in neurons]
    linear = [n for n in neurons]
    
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
    
    # Plot 1: Encoding bits vs neurons
    ax1.plot(neurons, bits_needed, 'bo-', label='Encoding bound (n²)', linewidth=2)
    ax1.plot(neurons, linear, 'r--', label='Linear (n)', linewidth=1.5)
    ax1.fill_between(neurons, linear, bits_needed, alpha=0.2, color='blue',
                      label='Quadratic gap')
    ax1.set_xlabel('Number of Neurons (n)', fontsize=12)
    ax1.set_ylabel('Bits Required', fontsize=12)
    ax1.set_title('Mind Encoding Bound: Quadratic Growth', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    
    # Plot 2: Log of connectome space size
    ax2.plot(neurons, log_space, 'go-', label='log₁₀(|ConnectomeSpace|)', linewidth=2)
    ax2.set_xlabel('Number of Neurons (n)', fontsize=12)
    ax2.set_ylabel('log₁₀(Number of Connectomes)', fontsize=12)
    ax2.set_title('Connectome Space: Doubly Exponential', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('connectome_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved: connectome_bounds.png")

def plot_scaling_law():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
        matplotlib.use('Agg')
    except ImportError:
        return

    neurons = list(range(1, 25))
    marginal = [2 * n + 1 for n in neurons]
    cumulative = [mind_encoding_bound(n + 1) for n in neurons]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.bar(neurons, marginal, alpha=0.7, color='steelblue', label='Marginal cost (2n+1)')
    ax2 = ax.twinx()
    ax2.plot(neurons, cumulative, 'r-o', label='Total bits ((n+1)²)', linewidth=2)
    
    ax.set_xlabel('Current Neuron Count (n)', fontsize=12)
    ax.set_ylabel('Marginal Bits for Next Neuron', fontsize=12, color='steelblue')
    ax2.set_ylabel('Total Bits Needed', fontsize=12, color='red')
    ax.set_title('Neuron Scaling Law: Each New Neuron Costs More', fontsize=14)
    ax.legend(loc='upper left')
    ax2.legend(loc='lower right')
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('scaling_law.png', dpi=150, bbox_inches='tight')
    print("Saved: scaling_law.png")


def plot_incompressibility():
    try:
        import matplotlib.pyplot as plt
        import matplotlib
        matplotlib.use('Agg')
    except ImportError:
        return
    
    ks = list(range(1, 21))
    fracs = [1.0 - 2**(-k) for k in ks]
    
    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(ks, [f * 100 for f in fracs], 'mo-', linewidth=2)
    ax.axhline(y=100, color='gray', linestyle='--', alpha=0.5)
    ax.set_xlabel('Incompressibility Parameter k', fontsize=12)
    ax.set_ylabel('% of Connectomes that are k-Incompressible', fontsize=12)
    ax.set_title('Most Connectomes Cannot Be Compressed', fontsize=14)
    ax.set_ylim(0, 105)
    ax.grid(True, alpha=0.3)
    
    for k in [1, 5, 10, 15, 20]:
        if k <= 20:
            ax.annotate(f'{(1-2**(-k))*100:.2f}%', 
                       xy=(k, (1-2**(-k))*100),
                       textcoords="offset points", xytext=(10, -15),
                       fontsize=9)
    
    plt.tight_layout()
    plt.savefig('incompressibility.png', dpi=150, bbox_inches='tight')
    print("Saved: incompressibility.png")


if __name__ == "__main__":
    plot_connectome_bounds()
    plot_scaling_law()
    plot_incompressibility()
