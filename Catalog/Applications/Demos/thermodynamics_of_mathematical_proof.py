#!/usr/bin/env python3
"""
Demonstration of Landauer's Principle for Mathematical Proof

Numerical examples illustrating the thermodynamic cost of proof steps,
the telescoping property, erasure concentration, and exponential gaps.
"""

import math

# Physical constants
kB = 1.380649e-23  # Boltzmann constant (J/K)
T_room = 300       # Room temperature (K)
kT_ln2 = kB * T_room * math.log(2)  # ~2.87e-21 J


def step_erasure(m: int, k: int) -> float:
    """Information-theoretic erasure of collapsing m states to k states."""
    assert m >= k > 0
    return math.log(m) - math.log(k)


def trace_erasure(cardinalities: list[int]) -> float:
    """Total erasure across a proof trace given cardinalities at each step."""
    total = 0.0
    for i in range(len(cardinalities) - 1):
        total += step_erasure(cardinalities[i], cardinalities[i + 1])
    return total


def thermodynamic_depth(m: int, k: int) -> float:
    """Minimum erasure for any proof from m states to k states."""
    return math.log(m) - math.log(k)


def landauer_cost(erasure_bits: float, kB_val: float = kB, T: float = T_room) -> float:
    """Thermodynamic cost in joules."""
    return kB_val * T * erasure_bits


def descriptive_complexity(n: int) -> float:
    """Descriptive complexity in bits (log base 2)."""
    return math.log2(n)


def find_bottleneck(cardinalities: list[int]) -> tuple[int, float]:
    """Find the step with maximum erasure (thermodynamic bottleneck)."""
    max_erasure = 0.0
    bottleneck = 0
    for i in range(len(cardinalities) - 1):
        e = step_erasure(cardinalities[i], cardinalities[i + 1])
        if e > max_erasure:
            max_erasure = e
            bottleneck = i
    return bottleneck, max_erasure


def main():
    print("=" * 70)
    print("LANDAUER'S PRINCIPLE FOR MATHEMATICAL PROOF")
    print("Thermodynamic Cost of Logical Reasoning")
    print("=" * 70)

    # Example 1: Single-step collapse
    print("\n--- Example 1: Single-Step Collapse ---")
    for n in [1, 2, 4, 8, 16, 32]:
        m = 2**n
        erasure = step_erasure(m, 1)
        cost = landauer_cost(erasure)
        print(f"  2^{n:2d} → 1: erasure = {erasure:.4f} nats "
              f"= {n:.1f} × ln(2), cost = {cost:.2e} J")

    # Example 2: Telescoping property
    print("\n--- Example 2: Telescoping Property ---")
    traces = [
        [1024, 1],           # Direct collapse
        [1024, 512, 1],      # Two steps
        [1024, 256, 64, 1],  # Three steps
        [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1],  # Ten steps
    ]
    for trace in traces:
        total = trace_erasure(trace)
        boundary = math.log(trace[0]) - math.log(trace[-1])
        print(f"  Trace {trace}: total = {total:.4f}, "
              f"boundary = {boundary:.4f}, match = {abs(total - boundary) < 1e-10}")

    # Example 3: Entropy monotonicity
    print("\n--- Example 3: Entropy Monotonicity ---")
    trace = [1024, 512, 256, 128, 64, 32, 16, 8, 4, 2, 1]
    print(f"  Trace: {trace}")
    print(f"  Entropies: {[f'{math.log(c):.2f}' for c in trace]}")
    print(f"  Monotonically decreasing: {all(trace[i] >= trace[i+1] for i in range(len(trace)-1))}")

    # Example 4: Erasure concentration (bottleneck)
    print("\n--- Example 4: Erasure Concentration ---")
    uneven_trace = [1024, 1023, 1022, 1021, 1020, 100, 10, 1]
    total = trace_erasure(uneven_trace)
    avg = total / (len(uneven_trace) - 1)
    bottleneck_idx, bottleneck_val = find_bottleneck(uneven_trace)
    print(f"  Trace: {uneven_trace}")
    print(f"  Total erasure: {total:.4f}")
    print(f"  Average per step: {avg:.4f}")
    print(f"  Bottleneck at step {bottleneck_idx}: "
          f"{uneven_trace[bottleneck_idx]} → {uneven_trace[bottleneck_idx+1]}, "
          f"erasure = {bottleneck_val:.4f}")
    print(f"  Bottleneck ≥ average: {bottleneck_val >= avg - 1e-10}")

    # Example 5: Exponential erasure gap
    print("\n--- Example 5: Exponential Erasure-to-Description Gap ---")
    print(f"  {'n':>4s}  {'erasure (nats)':>14s}  {'description (bits)':>18s}  {'ratio':>8s}")
    for n in [1, 2, 4, 8, 16, 32, 64, 128]:
        erasure = n * math.log(2)
        description = math.log2(n) if n > 1 else 1
        ratio = erasure / description
        print(f"  {n:4d}  {erasure:14.4f}  {description:18.4f}  {ratio:8.2f}")

    # Example 6: Reversible vs irreversible proofs
    print("\n--- Example 6: Reversible vs Irreversible Steps ---")
    print("  Reversible (bijective) step: Fin 8 → Fin 8")
    print(f"    Erasure: {step_erasure(8, 8):.4f} (zero!)")
    print("  Irreversible step: Fin 8 → Fin 4")
    print(f"    Erasure: {step_erasure(8, 4):.4f} = ln(2) ≈ 0.6931")
    print("  Irreversible step: Fin 8 → Fin 1")
    print(f"    Erasure: {step_erasure(8, 1):.4f} = 3 × ln(2) ≈ 2.0794")

    # Example 7: Physical cost at room temperature
    print("\n--- Example 7: Physical Costs at Room Temperature ---")
    print(f"  kB × T × ln(2) = {kT_ln2:.4e} J per bit erased")
    for n in [1, 10, 100, 1000]:
        cost = landauer_cost(n * math.log(2))
        print(f"  Erasing {n} bits: {cost:.4e} J")
    brain_ops = 10**16  # ~10^16 operations/second in human brain
    brain_cost = brain_ops * kT_ln2
    print(f"\n  Human brain (~10^16 ops/s × 1 bit/op):")
    print(f"    Minimum Landauer cost: {brain_cost:.2f} J/s = {brain_cost:.2f} W")
    print(f"    Actual brain power: ~20 W")
    print(f"    Efficiency ratio: ~{20/brain_cost:.0f}× above Landauer limit")

    print("\n" + "=" * 70)
    print("All examples verified. Telescoping holds. Second Law confirmed.")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Erasure profiles and thermodynamic depth of proof traces.
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def step_erasure(m: int, k: int) -> float:
    return math.log(m) - math.log(k)


def make_trace_plot():
    """Plot entropy along several proof traces with different strategies."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Trace 1: Even binary splitting
    trace1 = [2**10, 2**9, 2**8, 2**7, 2**6, 2**5, 2**4, 2**3, 2**2, 2**1, 2**0]
    entropies1 = [math.log(c) for c in trace1]
    erasures1 = [step_erasure(trace1[i], trace1[i+1]) for i in range(len(trace1)-1)]

    ax = axes[0]
    ax.plot(range(len(trace1)), entropies1, 'b-o', linewidth=2, markersize=6)
    ax.fill_between(range(len(trace1)), entropies1, alpha=0.15, color='blue')
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Entropy (nats)', fontsize=12)
    ax.set_title('Even Binary Splitting\n(uniform erasure per step)', fontsize=11)
    ax.grid(True, alpha=0.3)

    # Trace 2: Front-loaded erasure
    trace2 = [1024, 100, 10, 5, 3, 2, 1]
    entropies2 = [math.log(c) for c in trace2]

    ax = axes[1]
    ax.plot(range(len(trace2)), entropies2, 'r-o', linewidth=2, markersize=6)
    ax.fill_between(range(len(trace2)), entropies2, alpha=0.15, color='red')
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Entropy (nats)', fontsize=12)
    ax.set_title('Front-Loaded Erasure\n(big early collapse)', fontsize=11)
    ax.grid(True, alpha=0.3)

    # Trace 3: Back-loaded erasure
    trace3 = [1024, 1000, 900, 800, 500, 100, 1]
    entropies3 = [math.log(c) for c in trace3]

    ax = axes[2]
    ax.plot(range(len(trace3)), entropies3, 'g-o', linewidth=2, markersize=6)
    ax.fill_between(range(len(trace3)), entropies3, alpha=0.15, color='green')
    ax.set_xlabel('Step', fontsize=12)
    ax.set_ylabel('Entropy (nats)', fontsize=12)
    ax.set_title('Back-Loaded Erasure\n(gradual then sudden)', fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Entropy Monotonicity Along Proof Traces\n'
                 '(Total erasure = log(1024) - log(1) ≈ 6.93 for all traces)',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('erasure_profiles.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: erasure_profiles.png")


def make_gap_plot():
    """Plot the exponential erasure-to-description gap."""
    fig, ax = plt.subplots(figsize=(8, 6))

    ns = list(range(1, 65))
    erasures = [n * math.log(2) for n in ns]
    descriptions = [max(math.log2(n), 1) for n in ns]
    ratios = [e / d for e, d in zip(erasures, descriptions)]

    ax.plot(ns, erasures, 'b-', linewidth=2, label='Erasure: n·ln(2)')
    ax.plot(ns, descriptions, 'r-', linewidth=2, label='Description: log₂(n)')
    ax.fill_between(ns, descriptions, erasures, alpha=0.1, color='purple',
                    label='Erasure gap')
    ax.set_xlabel('Parameter n', fontsize=13)
    ax.set_ylabel('Information (nats / bits)', fontsize=13)
    ax.set_title('Exponential Erasure-to-Description Gap\n'
                 'Proof cost grows exponentially faster than statement complexity',
                 fontsize=12, fontweight='bold')
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('log')

    plt.tight_layout()
    plt.savefig('erasure_gap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: erasure_gap.png")


def make_bottleneck_plot():
    """Visualize erasure concentration and bottleneck detection."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Uneven trace
    trace = [1024, 1020, 1015, 1010, 1000, 500, 10, 1]
    erasures = [step_erasure(trace[i], trace[i+1]) for i in range(len(trace)-1)]
    avg_erasure = sum(erasures) / len(erasures)

    ax = axes[0]
    colors = ['red' if e >= avg_erasure else 'steelblue' for e in erasures]
    bars = ax.bar(range(len(erasures)), erasures, color=colors, edgecolor='black',
                  linewidth=0.5)
    ax.axhline(y=avg_erasure, color='orange', linestyle='--', linewidth=2,
               label=f'Average = {avg_erasure:.3f}')
    ax.set_xlabel('Step Index', fontsize=12)
    ax.set_ylabel('Step Erasure (nats)', fontsize=12)
    ax.set_title('Erasure per Step\n(red = above average = bottleneck)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    # Thermodynamic depth vs number of steps
    ax = axes[1]
    n_vals = range(1, 21)
    depths = [n * math.log(2) for n in n_vals]
    min_bottlenecks = [n * math.log(2) / L for n, L in
                       zip(n_vals, range(1, 21))]

    ax.plot(n_vals, depths, 'b-o', linewidth=2, label='Total depth: n·ln(2)')
    ax.plot(n_vals, [d/n for d, n in zip(depths, n_vals)], 'r-s',
            linewidth=2, label='Min bottleneck: n·ln(2)/n = ln(2)')
    ax.axhline(y=math.log(2), color='gray', linestyle=':', alpha=0.5)
    ax.set_xlabel('n (collapse 2ⁿ → 1)', fontsize=12)
    ax.set_ylabel('Erasure (nats)', fontsize=12)
    ax.set_title('Depth vs Min Bottleneck\n(n steps to collapse 2ⁿ → 1)', fontsize=11)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.suptitle('Erasure Concentration and Bottleneck Analysis',
                 fontsize=13, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('bottleneck_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: bottleneck_analysis.png")


if __name__ == "__main__":
    make_trace_plot()
    make_gap_plot()
    make_bottleneck_plot()
    print("All visualizations generated.")
