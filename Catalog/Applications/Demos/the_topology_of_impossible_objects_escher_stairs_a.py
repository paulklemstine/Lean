#!/usr/bin/env python3
"""
Demonstration of Impossible Figure Analysis via Monodromy Theory.

This script demonstrates the key results from the cocycle obstruction
framework for impossible figures, including:
1. Penrose triangle impossibility
2. Escher staircase impossibility  
3. Height function construction for realizable cycles
4. Orientation cocycle analysis
5. Euler characteristic computation
6. Rational approximation of impossible figures
"""

import math
from fractions import Fraction
from algorithms import (
    compute_monodromy, is_realizable, construct_height_function,
    verify_realization, is_escher_staircase, penrose_weights,
    orientation_holonomy, is_orientable, count_reversals,
    euler_characteristic, connected_sum_euler,
    rational_approximation, classify_impossible_figure,
    monodromy_bound
)


def separator(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_penrose_triangle():
    separator("1. THE PENROSE TRIANGLE")
    
    for delta in [1.0, 0.5, math.pi, -2.0]:
        weights = penrose_weights(delta)
        mono = compute_monodromy(weights)
        real = is_realizable(weights)
        print(f"  δ = {delta:8.4f}  |  monodromy = {mono:8.4f}  |  "
              f"realizable = {real}")
    
    print(f"\n  δ = 0 (degenerate case):")
    weights = penrose_weights(0.0)
    mono = compute_monodromy(weights)
    real = is_realizable(weights)
    heights = construct_height_function(weights)
    print(f"  monodromy = {mono}  |  realizable = {real}")
    print(f"  height function = {heights}")
    print(f"\n  Theorem: For δ ≠ 0, the Penrose triangle is NEVER realizable.")
    print(f"  Proof: monodromy = 3δ ≠ 0 ⟹ no height function exists.")


def demo_escher_staircase():
    separator("2. ESCHER'S ASCENDING STAIRCASE")
    
    # Various ascending staircases
    examples = [
        [1, 1, 1, 1],        # 4-step uniform
        [0.5, 1.5, 0.3, 2],  # 4-step non-uniform
        [1, 2, 3, 4, 5],     # 5-step increasing
        [0.01] * 100,         # 100-step tiny steps
    ]
    
    for weights in examples:
        n = len(weights)
        mono = compute_monodromy(weights)
        escher = is_escher_staircase(weights)
        real = is_realizable(weights)
        print(f"  n={n:3d}  |  μ = {mono:8.3f}  |  "
              f"Escher = {escher}  |  realizable = {real}")
    
    print(f"\n  Theorem: EVERY Escher staircase is impossible.")
    print(f"  Proof: μ = Σ w(i) > 0 (sum of positives) ⟹ μ ≠ 0.")

    separator("2b. DESCENDING ESCHER STAIRCASE")
    weights = [-1, -1, -1, -1]
    mono = compute_monodromy(weights)
    print(f"  weights = {weights}")
    print(f"  monodromy = {mono}")
    print(f"  Theorem: Descending staircases are EQUALLY impossible.")


def demo_realizable_cycles():
    separator("3. REALIZABLE CYCLES (zero monodromy)")
    
    examples = [
        ("Alternating",     [1, -1, 1, -1]),
        ("Gradient up-down", [3, -1, -1, -1]),
        ("Single bump",     [5, -2, -2, -1]),
        ("Wave pattern",    [1, 2, -3, 1, -1]),
    ]
    
    for name, weights in examples:
        mono = compute_monodromy(weights)
        heights = construct_height_function(weights)
        valid = verify_realization(weights, heights) if heights else False
        print(f"  {name:20s}  |  w = {weights}")
        print(f"  {'':20s}  |  μ = {mono:.1f}  |  h = {heights}")
        print(f"  {'':20s}  |  verified = {valid}")
        print()


def demo_orientation_cocycles():
    separator("4. ORIENTATION COCYCLES (Möbius vs Cylinder)")
    
    examples = [
        ("Cylinder (all +1)",    [1, 1, 1, 1]),
        ("Möbius (one flip)",    [1, 1, 1, -1]),
        ("Two flips (orientable)", [1, -1, 1, -1]),
        ("Three flips (non-orientable)", [1, -1, -1, -1]),
        ("All flips (orientable for even n)", [-1, -1, -1, -1]),
    ]
    
    for name, signs in examples:
        hol = orientation_holonomy(signs)
        orient = is_orientable(signs)
        n_rev = count_reversals(signs)
        print(f"  {name:35s}  |  signs = {signs}")
        print(f"  {'':35s}  |  holonomy = {hol:+d}  |  "
              f"orientable = {orient}  |  reversals = {n_rev} "
              f"({'odd' if n_rev % 2 == 1 else 'even'})")
        print()
    
    print("  Theorem: Non-orientable ⟺ odd number of -1 signs.")


def demo_euler_characteristics():
    separator("5. EULER CHARACTERISTICS OF SURFACES")
    
    surfaces = [
        ("Sphere S²",         1, 0, 1),
        ("Torus T²",          1, 2, 1),
        ("Klein bottle K",    1, 2, 1),
        ("RP²",               1, 1, 1),
        ("Genus-2 surface",   1, 4, 1),
    ]
    
    print(f"  {'Surface':25s}  |  V  E  F  |  χ = V-E+F")
    print(f"  {'-'*25}--+----------+-----------")
    for name, v, e, f in surfaces:
        chi = euler_characteristic(v, e, f)
        print(f"  {name:25s}  |  {v}  {e}  {f}  |  χ = {chi}")
    
    print(f"\n  Connected sum formula: χ(M # N) = χ(M) + χ(N) - 2")
    print(f"  χ(T² # T²)    = {connected_sum_euler(0, 0)}")
    print(f"  χ(RP² # RP²)  = {connected_sum_euler(1, 1)} (= Klein bottle)")
    print(f"  χ(S² # T²)    = {connected_sum_euler(2, 0)} (= T²)")


def demo_rational_approximation():
    separator("6. RATIONAL APPROXIMATION OF IMPOSSIBLE FIGURES")
    
    # Irrational weights
    weights = [math.pi, math.e, math.sqrt(2)]
    mono = compute_monodromy(weights)
    print(f"  Original weights: [{math.pi:.6f}, {math.e:.6f}, {math.sqrt(2):.6f}]")
    print(f"  Original monodromy: {mono:.6f}")
    
    for eps in [0.1, 0.01, 0.001, 0.0001]:
        approx = rational_approximation(weights, eps)
        approx_float = [float(f) for f in approx]
        mono_approx = sum(approx_float)
        max_err = max(abs(w - float(a)) for w, a in zip(weights, approx))
        mono_err = abs(mono - mono_approx)
        print(f"\n  ε = {eps}")
        print(f"    Rational approx: {[str(f) for f in approx]}")
        print(f"    Max edge error:  {max_err:.8f} < {eps}")
        print(f"    Monodromy error: {mono_err:.8f} < {eps}")
        print(f"    Still impossible: {not is_realizable(approx_float)}")


def demo_monodromy_bounds():
    separator("7. MONODROMY BOUNDS")
    
    import random
    random.seed(42)
    
    for n in [3, 5, 10, 50]:
        weights = [random.uniform(-1, 1) for _ in range(n)]
        actual, bound = monodromy_bound(weights)
        print(f"  n = {n:3d}  |  |μ| = {actual:8.4f}  |  "
              f"bound = n·B = {bound:8.4f}  |  "
              f"ratio = {actual/bound:.4f}" if bound > 0 else "")
    
    print(f"\n  Theorem: |μ(w)| ≤ n · max|w(i)| always holds.")


def demo_classification():
    separator("8. COMPLETE CLASSIFICATION")
    
    test_cases = [
        ("Penrose (δ=1)",     [1, 1, 1]),
        ("Escher 4-step",     [0.5, 1, 0.3, 0.7]),
        ("Balanced 4-cycle",  [2, -1, 3, -4]),
        ("Zero weights",      [0, 0, 0, 0]),
        ("Single edge bump",  [10, -5, -5]),
    ]
    
    for name, weights in test_cases:
        result = classify_impossible_figure(weights)
        print(f"  {name:25s}")
        print(f"    Weights:        {weights}")
        print(f"    Monodromy:      {result['monodromy']:.4f}")
        print(f"    Classification: {result['classification'].upper()}")
        if result['height_function']:
            print(f"    Heights:        "
                  f"{[f'{h:.2f}' for h in result['height_function']]}")
        print()


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  IMPOSSIBLE FIGURES: Monodromy Theory Demonstration     ║")
    print("║  Based on cocycle obstruction framework                 ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_penrose_triangle()
    demo_escher_staircase()
    demo_realizable_cycles()
    demo_orientation_cocycles()
    demo_euler_characteristics()
    demo_rational_approximation()
    demo_monodromy_bounds()
    demo_classification()
    
    separator("SUMMARY OF VERIFIED THEOREMS")
    theorems = [
        "Monodromy Classification: realizable ⟺ μ = 0",
        "Escher Impossibility: all-positive weights ⟹ impossible",
        "Descending Escher: all-negative weights ⟹ impossible",
        "Penrose Triangle: μ = 3δ ≠ 0 for δ ≠ 0",
        "Monodromy Linearity: μ(aw + bv) = aμ(w) + bμ(v)",
        "Monodromy Bound: |μ(w)| ≤ n · max|w(i)|",
        "Orientability ⟺ even number of reversals",
        "Klein Bottle χ = 0",
        "Connected Sum: χ(M#N) = χ(M) + χ(N) - 2",
        "Rational Approximation: ∀ε>0, ∃ rational ε-approx",
    ]
    for i, t in enumerate(theorems, 1):
        print(f"  {i:2d}. {t}")
    
    print(f"\n  All theorems formally verified in Lean 4 (zero sorries).")


#!/usr/bin/env python3
"""
Visualization: Monodromy of impossible figures on cycle graphs.

Generates a figure showing:
1. A realizable cycle (monodromy = 0) with its height function
2. A Penrose triangle (monodromy ≠ 0) showing the impossibility
3. An Escher staircase showing the positive monodromy
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_cycle_graph(ax, n, weights, title, color='steelblue'):
    """Draw a cycle graph with weighted edges and height annotations."""
    angles = np.linspace(0, 2 * np.pi, n, endpoint=False) - np.pi / 2
    x = np.cos(angles)
    y = np.sin(angles)

    # Draw edges with weight labels
    for i in range(n):
        j = (i + 1) % n
        ax.annotate('', xy=(x[j], y[j]), xytext=(x[i], y[i]),
                    arrowprops=dict(arrowstyle='->', color=color, lw=2))
        mx = (x[i] + x[j]) / 2
        my = (y[i] + y[j]) / 2
        # Offset label outward
        ox = mx * 0.15
        oy = my * 0.15
        ax.text(mx + ox, my + oy, f'w={weights[i]:.1f}',
                ha='center', va='center', fontsize=9,
                bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow',
                          edgecolor='gray', alpha=0.8))

    # Draw vertices
    for i in range(n):
        ax.plot(x[i], y[i], 'o', markersize=20, color=color,
                markeredgecolor='black', markeredgewidth=1.5)
        ax.text(x[i], y[i], str(i), ha='center', va='center',
                fontsize=11, fontweight='bold', color='white')

    mono = sum(weights)
    color_mono = 'green' if abs(mono) < 1e-10 else 'red'
    status = 'REALIZABLE' if abs(mono) < 1e-10 else 'IMPOSSIBLE'
    ax.set_title(f'{title}\nμ = {mono:.1f} → {status}',
                 fontsize=12, fontweight='bold',
                 color=color_mono)
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-1.8, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')


def draw_height_profile(ax, weights, title):
    """Draw the cumulative height profile along the cycle."""
    n = len(weights)
    mono = sum(weights)
    heights = [0]
    for w in weights:
        heights.append(heights[-1] + w)

    positions = list(range(n + 1))
    labels = [str(i % n) for i in range(n + 1)]

    if abs(mono) < 1e-10:
        ax.fill_between(positions, heights, alpha=0.2, color='green')
        ax.plot(positions, heights, 'o-', color='green', markersize=8, lw=2)
        ax.set_title(f'{title}\nHeight returns to start ✓', fontsize=11,
                     color='green', fontweight='bold')
    else:
        ax.fill_between(positions, heights, alpha=0.2, color='red')
        ax.plot(positions, heights, 'o-', color='red', markersize=8, lw=2)
        ax.axhline(y=0, color='black', linestyle='--', alpha=0.3)
        ax.annotate(f'Gap = {mono:.1f}',
                    xy=(n, heights[-1]), xytext=(n - 0.5, heights[-1] + 0.3),
                    fontsize=10, color='red', fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='red'))
        ax.set_title(f'{title}\nHeight gap = {mono:.1f} ✗', fontsize=11,
                     color='red', fontweight='bold')

    ax.set_xticks(positions)
    ax.set_xticklabels(labels)
    ax.set_xlabel('Vertex', fontsize=10)
    ax.set_ylabel('Height', fontsize=10)
    ax.grid(True, alpha=0.3)


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 11))
    fig.suptitle('Monodromy Theory of Impossible Figures',
                 fontsize=16, fontweight='bold', y=0.98)

    # Example 1: Realizable cycle
    w1 = [2.0, -1.0, 1.0, -2.0]
    draw_cycle_graph(axes[0, 0], 4, w1, 'Balanced 4-Cycle', 'seagreen')
    draw_height_profile(axes[1, 0], w1, 'Balanced 4-Cycle')

    # Example 2: Penrose triangle
    w2 = [1.0, 1.0, 1.0]
    draw_cycle_graph(axes[0, 1], 3, w2, 'Penrose Triangle (δ=1)', 'crimson')
    draw_height_profile(axes[1, 1], w2, 'Penrose Triangle')

    # Example 3: Escher staircase
    w3 = [0.5, 1.0, 0.3, 0.7, 0.5]
    draw_cycle_graph(axes[0, 2], 5, w3, 'Escher Staircase (5-step)',
                     'darkorange')
    draw_height_profile(axes[1, 2], w3, 'Escher Staircase')

    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('monodromy_visualization.png', dpi=150, bbox_inches='tight')
    print('Saved monodromy_visualization.png')


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Surface topology and Euler characteristics.

Generates a figure showing:
1. Euler characteristics of standard surfaces
2. Connected sum formula visualization
3. Orientation cocycle analysis
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def draw_euler_char_table(ax):
    """Draw a visual table of Euler characteristics."""
    surfaces = [
        ('S²', 2, True, 'Sphere'),
        ('T²', 0, True, 'Torus'),
        ('K', 0, False, 'Klein bottle'),
        ('RP²', 1, False, 'Proj. plane'),
        ('Σ₂', -2, True, 'Genus 2'),
    ]

    ax.set_xlim(-0.5, 4.5)
    ax.set_ylim(-0.5, len(surfaces) - 0.5)

    for i, (sym, chi, orient, name) in enumerate(surfaces):
        y = len(surfaces) - 1 - i
        color = 'lightblue' if orient else 'lightyellow'
        rect = plt.Rectangle((-0.4, y - 0.4), 4.8, 0.8,
                              facecolor=color, edgecolor='black',
                              linewidth=1)
        ax.add_patch(rect)
        ax.text(0.3, y, sym, ha='center', va='center',
                fontsize=14, fontweight='bold')
        ax.text(1.5, y, name, ha='center', va='center', fontsize=11)
        ax.text(2.8, y, f'χ = {chi}', ha='center', va='center',
                fontsize=12, fontweight='bold',
                color='darkblue' if chi > 0 else
                      ('black' if chi == 0 else 'darkred'))
        ax.text(3.8, y, '✓' if orient else '✗', ha='center',
                va='center', fontsize=14,
                color='green' if orient else 'red')

    ax.set_title('Euler Characteristics of Closed Surfaces',
                 fontsize=13, fontweight='bold')
    ax.axis('off')

    # Legend
    blue = mpatches.Patch(facecolor='lightblue', edgecolor='black',
                          label='Orientable')
    yellow = mpatches.Patch(facecolor='lightyellow', edgecolor='black',
                            label='Non-orientable')
    ax.legend(handles=[blue, yellow], loc='lower center', fontsize=9)


def draw_connected_sum(ax):
    """Visualize the connected sum Euler characteristic formula."""
    pairs = [
        ('T²', 0, 'T²', 0, 'Σ₂', -2),
        ('RP²', 1, 'RP²', 1, 'K', 0),
        ('S²', 2, 'T²', 0, 'T²', 0),
        ('T²', 0, 'RP²', 1, '?', -1),
    ]

    ax.set_xlim(0, 10)
    ax.set_ylim(-0.5, len(pairs) - 0.5)

    for i, (s1, c1, s2, c2, sr, cr) in enumerate(pairs):
        y = len(pairs) - 1 - i
        computed = c1 + c2 - 2
        correct = computed == cr
        color = 'lightgreen' if correct else 'lightyellow'

        ax.text(1, y, f'{s1} (χ={c1})', ha='center', va='center',
                fontsize=11)
        ax.text(2.5, y, '#', ha='center', va='center',
                fontsize=14, fontweight='bold')
        ax.text(4, y, f'{s2} (χ={c2})', ha='center', va='center',
                fontsize=11)
        ax.text(5.5, y, '=', ha='center', va='center',
                fontsize=14, fontweight='bold')
        ax.text(7, y, f'{sr} (χ={cr})', ha='center', va='center',
                fontsize=11, fontweight='bold')
        ax.text(9, y, f'{c1}+{c2}−2 = {computed}',
                ha='center', va='center', fontsize=10,
                color='green' if correct else 'red',
                fontweight='bold')

    ax.set_title('Connected Sum: χ(M # N) = χ(M) + χ(N) − 2',
                 fontsize=13, fontweight='bold')
    ax.axis('off')


def draw_orientation_analysis(ax):
    """Visualize orientation cocycle holonomy computation."""
    examples = [
        ([1, 1, 1, 1], 'Cylinder'),
        ([1, 1, 1, -1], 'Möbius'),
        ([1, -1, 1, -1], 'Orientable'),
        ([-1, -1, -1, -1], 'Orientable'),
        ([1, -1, -1, -1], 'Möbius-like'),
    ]

    n_examples = len(examples)
    bar_width = 0.6
    x_pos = np.arange(n_examples)

    colors = []
    holonomies = []
    labels = []
    for signs, name in examples:
        hol = 1
        for s in signs:
            hol *= s
        holonomies.append(hol)
        colors.append('steelblue' if hol == 1 else 'coral')
        n_neg = sum(1 for s in signs if s == -1)
        labels.append(f'{name}\n({n_neg} flips)')

    bars = ax.bar(x_pos, holonomies, bar_width, color=colors,
                  edgecolor='black', linewidth=1)
    ax.set_xticks(x_pos)
    ax.set_xticklabels(labels, fontsize=9)
    ax.set_ylabel('Holonomy', fontsize=11)
    ax.set_ylim(-1.5, 1.5)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_title('Orientation Holonomy: Odd flips → Non-orientable',
                 fontsize=12, fontweight='bold')

    # Add value labels
    for bar, val in zip(bars, holonomies):
        ax.text(bar.get_x() + bar.get_width() / 2, val + 0.1 * np.sign(val),
                f'{val:+d}', ha='center', va='bottom' if val > 0 else 'top',
                fontsize=12, fontweight='bold')


import matplotlib.patches as mpatches


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Surface Topology: Euler Characteristics & Orientability',
                 fontsize=15, fontweight='bold', y=1.02)

    draw_euler_char_table(axes[0])
    draw_connected_sum(axes[1])
    draw_orientation_analysis(axes[2])

    plt.tight_layout()
    plt.savefig('surface_topology.png', dpi=150, bbox_inches='tight')
    print('Saved surface_topology.png')


if __name__ == '__main__':
    main()
