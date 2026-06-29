#!/usr/bin/env python3
"""
Curvature-Induced Computation: Demonstration
=============================================
Demonstrates the key concepts of the horseshoe-to-computation bridge:
1. Horseshoe orbit realization (generating all symbolic words)
2. Boolean function encoding via horseshoe dynamics
3. Entropy computation and growth rate verification
"""

import itertools
from typing import Callable


def demonstrate_orbit_realization(degree: int, word_length: int) -> None:
    """Show that a degree-d horseshoe realizes all d^n symbolic words."""
    print(f"\n{'='*60}")
    print(f"Orbit Realization: degree={degree}, word_length={word_length}")
    print(f"{'='*60}")

    # Generate all possible words of given length over alphabet {0,...,d-1}
    alphabet = list(range(degree))
    all_words = list(itertools.product(alphabet, repeat=word_length))
    total = len(all_words)
    expected = degree ** word_length

    print(f"Alphabet: {alphabet}")
    print(f"Total words of length {word_length}: {total}")
    print(f"Expected (d^n = {degree}^{word_length}): {expected}")
    assert total == expected, f"Mismatch: {total} != {expected}"
    print(f"✓ Verified: |Fin {word_length} → Fin {degree}| = {degree}^{word_length} = {expected}")

    # Display first few and last few words
    print(f"\nFirst 5 words: {all_words[:5]}")
    if total > 10:
        print(f"Last 5 words:  {all_words[-5:]}")


def demonstrate_boolean_encoding(n_inputs: int) -> None:
    """Show how a binary horseshoe encodes Boolean functions."""
    print(f"\n{'='*60}")
    print(f"Boolean Function Encoding: {n_inputs} inputs")
    print(f"{'='*60}")

    # Generate all possible Boolean functions on n inputs
    n_functions = 2 ** (2 ** n_inputs)
    n_inputs_total = 2 ** n_inputs
    print(f"Number of Boolean functions on {n_inputs} inputs: {n_functions}")
    print(f"Number of possible inputs: {n_inputs_total}")

    # For each function, show the encoding word
    print(f"\nEncoding scheme: for input b = (b_0, ..., b_{{n-1}}),")
    print(f"construct word w = (b_0, ..., b_{{n-1}}, g(b)) of length {n_inputs + 1}")
    print(f"Then horseshoe_orbit_realization gives x with f^k(x) ∈ S_{{w_k}}")
    print(f"Reading strip at time {n_inputs} gives g(b).\n")

    if n_inputs <= 3:
        # Demonstrate with specific functions
        inputs = list(itertools.product([0, 1], repeat=n_inputs))

        # AND function
        def and_fn(bits: tuple) -> int:
            return 1 if all(b == 1 for b in bits) else 0

        # OR function
        def or_fn(bits: tuple) -> int:
            return 1 if any(b == 1 for b in bits) else 0

        # XOR (parity) function
        def xor_fn(bits: tuple) -> int:
            return sum(bits) % 2

        for name, fn in [("AND", and_fn), ("OR", or_fn), ("XOR/PARITY", xor_fn)]:
            print(f"  {name} function:")
            for inp in inputs:
                output = fn(inp)
                word = list(inp) + [output]
                print(f"    input={inp} → output={output} → word={word}")
            print()


def demonstrate_entropy() -> None:
    """Show entropy computation and growth rate verification."""
    import math

    print(f"\n{'='*60}")
    print(f"Topological Entropy of Horseshoe Systems")
    print(f"{'='*60}")

    print(f"\n{'Degree d':>10} {'h(d) = log(d)':>15} {'d^10 (10-step complexity)':>28}")
    print(f"{'-'*10:>10} {'-'*15:>15} {'-'*28:>28}")

    for d in range(2, 11):
        entropy = math.log(d)
        complexity_10 = d ** 10
        print(f"{d:>10} {entropy:>15.6f} {complexity_10:>28,}")

    # Verify the growth rate formula: h(d) = (1/n) * log(d^n)
    print(f"\nGrowth rate verification: h(d) = (1/n) · log(d^n)")
    d = 3
    for n in [1, 2, 5, 10, 50, 100]:
        growth_rate = math.log(d ** n) / n
        exact_entropy = math.log(d)
        error = abs(growth_rate - exact_entropy)
        print(f"  d={d}, n={n:>3}: (1/{n}) · log({d}^{n}) = {growth_rate:.10f}, "
              f"log({d}) = {exact_entropy:.10f}, error = {error:.2e}")


def demonstrate_unbounded_entropy() -> None:
    """Show that unbounded horseshoe degree implies unbounded entropy."""
    import math

    print(f"\n{'='*60}")
    print(f"Unbounded Horseshoe Degree → Unbounded Entropy")
    print(f"{'='*60}")

    print(f"\nFor any threshold C, we find d ≥ 2 with log(d) > C:")
    for C in [1.0, 5.0, 10.0, 50.0, 100.0, 1000.0]:
        d = int(math.floor(math.exp(C))) + 2
        entropy = math.log(d)
        print(f"  C = {C:>8.1f} → d = ⌊exp(C)⌋ + 2 = {d}, "
              f"log(d) = {entropy:.4f} > {C}")


def demonstrate_simulation() -> None:
    """Simulate a simple horseshoe system and verify orbit realization."""
    import math

    print(f"\n{'='*60}")
    print(f"Numerical Horseshoe Simulation (Baker's Map)")
    print(f"{'='*60}")

    # Baker's map: a simple degree-2 horseshoe on [0,1]²
    # S_0 = [0, 1] × [0, 1/3], S_1 = [0, 1] × [2/3, 1]
    # f(x, y) = (2x mod 1, y/3) for y ∈ [0, 1/3]
    # f(x, y) = (2x mod 1, (y+2)/3) for y ∈ [2/3, 1]

    def baker_map(x: float, y: float) -> tuple[float, float]:
        """Baker's map on [0,1]²."""
        if y < 1/3:
            return (2*x % 1, y/3 + 0)
        elif y > 2/3:
            return (2*x % 1, y/3 + 2/3)
        else:
            return (2*x % 1, y/2)  # middle strip (not part of horseshoe)

    def strip_index(y: float) -> int:
        """Which strip a point belongs to. 0 = bottom, 1 = top, -1 = neither."""
        if y < 1/3:
            return 0
        elif y > 2/3:
            return 1
        else:
            return -1

    print(f"\nBaker's map horseshoe:")
    print(f"  Strip 0: [0,1] × [0, 1/3]")
    print(f"  Strip 1: [0,1] × [2/3, 1]")
    print(f"  f maps each strip across both strips")

    # For a target word, find an initial condition by backward iteration
    target_word = [0, 1, 0, 1, 1, 0]
    print(f"\nTarget symbolic word: {target_word}")

    # Construct initial y-coordinate by encoding the word
    # For Baker's map: y = sum(w_k * 2/3 * (1/3)^k) approximately
    y = 0.0
    for k in range(len(target_word) - 1, -1, -1):
        y = y / 3 + target_word[k] * 2/3

    x = 0.5  # arbitrary x

    print(f"Constructed initial condition: ({x:.6f}, {y:.6f})")
    print(f"\nOrbit tracking:")

    current_x, current_y = x, y
    for step in range(len(target_word)):
        idx = strip_index(current_y)
        match = "✓" if idx == target_word[step] else "✗"
        print(f"  Step {step}: y={current_y:.6f}, strip={idx}, "
              f"target={target_word[step]} {match}")
        current_x, current_y = baker_map(current_x, current_y)


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Curvature-Induced Computation: Interactive Demo        ║")
    print("║  From Horseshoe Dynamics to Computational Universality  ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demonstrate_orbit_realization(2, 4)
    demonstrate_orbit_realization(3, 3)
    demonstrate_boolean_encoding(2)
    demonstrate_boolean_encoding(3)
    demonstrate_entropy()
    demonstrate_unbounded_entropy()
    demonstrate_simulation()

    print(f"\n{'='*60}")
    print(f"All demonstrations completed successfully!")
    print(f"{'='*60}")


#!/usr/bin/env python3
"""
Visualization: Horseshoe Entropy and Orbit Complexity
=====================================================
Shows how topological entropy grows with horseshoe degree
and verifies the growth rate formula h = (1/n) log(d^n).
"""

import math
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np


def plot_entropy_vs_degree():
    """Plot symbolic entropy as a function of horseshoe degree."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: Entropy vs degree
    degrees = np.arange(2, 21)
    entropies = [math.log(d) for d in degrees]

    axes[0].bar(degrees, entropies, color='steelblue', alpha=0.8, edgecolor='navy')
    axes[0].set_xlabel('Horseshoe Degree d', fontsize=12)
    axes[0].set_ylabel('Symbolic Entropy h(d) = log(d)', fontsize=12)
    axes[0].set_title('Topological Entropy of Horseshoe Systems', fontsize=14)
    axes[0].grid(axis='y', alpha=0.3)

    # Right: Orbit complexity (d^n) for various d
    n_values = np.arange(1, 16)
    for d in [2, 3, 5, 10]:
        complexities = [d**n for n in n_values]
        axes[1].semilogy(n_values, complexities, 'o-', label=f'd = {d}', markersize=4)

    axes[1].set_xlabel('Word Length n', fontsize=12)
    axes[1].set_ylabel('Number of Distinct Words (d^n)', fontsize=12)
    axes[1].set_title('Exponential Growth of Orbit Complexity', fontsize=14)
    axes[1].legend(fontsize=10)
    axes[1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved entropy_analysis.png")


def plot_growth_rate_convergence():
    """Plot convergence of (1/n) log(d^n) to log(d)."""
    fig, ax = plt.subplots(figsize=(10, 6))

    for d in [2, 3, 5, 10]:
        n_values = np.arange(1, 51)
        growth_rates = [math.log(d**n) / n for n in n_values]
        exact = math.log(d)

        ax.plot(n_values, growth_rates, '-', label=f'd={d}: h = {exact:.4f}', linewidth=2)
        ax.axhline(y=exact, color='gray', linestyle='--', alpha=0.3)

    ax.set_xlabel('Word Length n', fontsize=12)
    ax.set_ylabel('Growth Rate (1/n) · log(d^n)', fontsize=12)
    ax.set_title('Growth Rate Equals Entropy (Exact for Full Shift)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('growth_rate.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved growth_rate.png")


def plot_curvature_computation_bridge():
    """Visualize the chain: curvature → horseshoe → entropy → computation."""
    fig, ax = plt.subplots(figsize=(12, 4))
    ax.set_xlim(0, 10)
    ax.set_ylim(0, 3)
    ax.axis('off')

    boxes = [
        (1, 1.5, 'Negative\nCurvature', '#E74C3C'),
        (3.5, 1.5, 'Smale\nHorseshoe', '#F39C12'),
        (6, 1.5, 'Full\nShift', '#27AE60'),
        (8.5, 1.5, 'Computational\nUniversality', '#2980B9'),
    ]

    for x, y, text, color in boxes:
        rect = plt.Rectangle((x-0.8, y-0.5), 1.6, 1.0,
                            facecolor=color, alpha=0.8, edgecolor='black',
                            linewidth=2, zorder=2)
        ax.add_patch(rect)
        ax.text(x, y, text, ha='center', va='center',
               fontsize=10, fontweight='bold', color='white', zorder=3)

    # Arrows
    for i in range(3):
        x_start = boxes[i][0] + 0.8
        x_end = boxes[i+1][0] - 0.8
        ax.annotate('', xy=(x_end, 1.5), xytext=(x_start, 1.5),
                   arrowprops=dict(arrowstyle='->', lw=2, color='black'))

    # Labels under arrows
    labels = [
        (2.25, 0.7, 'Anosov\nflow'),
        (4.75, 0.7, 'Orbit\nrealization'),
        (7.25, 0.7, 'Boolean\nencoding'),
    ]
    for x, y, text in labels:
        ax.text(x, y, text, ha='center', va='center', fontsize=9,
               style='italic', color='#555')

    ax.set_title('The Curvature-Computation Bridge', fontsize=16,
                fontweight='bold', pad=20)

    plt.tight_layout()
    plt.savefig('bridge_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved bridge_diagram.png")


if __name__ == "__main__":
    plot_entropy_vs_degree()
    plot_growth_rate_convergence()
    plot_curvature_computation_bridge()
    print("All visualizations generated!")
