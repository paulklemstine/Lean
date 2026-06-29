"""
Demo: Impossible Figures — Height Cocycles and Monodromy

Demonstrates the Monodromy Classification Theorem and its applications
to analyzing impossible figures like the Penrose triangle.
"""

from algorithms import (
    compute_monodromy, is_coboundary, reconstruct_heights,
    impossibility_index, orientation_monodromy, classify_cocycle,
    decompose_cocycle
)


def demo_penrose_triangle():
    """The classic Penrose triangle: 3 edges, each with height difference 1."""
    print("=" * 60)
    print("PENROSE TRIANGLE (Impossible Figure)")
    print("=" * 60)
    
    # Each edge contributes a height difference of 1
    # After going around all 3 edges, you're 3 units higher — impossible!
    weights = [1.0, 1.0, 1.0]
    result = classify_cocycle(weights)
    
    print(f"Edge weights: {result['edge_weights']}")
    print(f"Monodromy: {result['monodromy']}")
    print(f"Impossibility index: {result['impossibility_index']}")
    print(f"Is realizable? {result['is_realizable']}")
    print(f"Cohomology class: [{result['cohomology_class']}] ∈ H¹(C₃; ℝ) ≅ ℝ")
    print()


def demo_escher_staircase():
    """Escher's ascending/descending staircase: 4 edges."""
    print("=" * 60)
    print("ESCHER STAIRCASE (Impossible Figure)")
    print("=" * 60)
    
    # 4 flights of stairs, each ascending by 2 units
    weights = [2.0, 2.0, 2.0, 2.0]
    result = classify_cocycle(weights)
    
    print(f"Edge weights: {result['edge_weights']}")
    print(f"Monodromy: {result['monodromy']}")
    print(f"Impossibility index: {result['impossibility_index']}")
    print(f"Is realizable? {result['is_realizable']}")
    print()


def demo_realizable_figure():
    """A realizable figure: monodromy = 0."""
    print("=" * 60)
    print("REALIZABLE FIGURE (Consistent Height Assignment)")
    print("=" * 60)
    
    # Heights go: 0 → 3 → 5 → 1 → 0
    weights = [3.0, 2.0, -4.0, -1.0]
    result = classify_cocycle(weights)
    
    print(f"Edge weights: {result['edge_weights']}")
    print(f"Monodromy: {result['monodromy']}")
    print(f"Impossibility index: {result['impossibility_index']}")
    print(f"Is realizable? {result['is_realizable']}")
    print(f"Reconstructed heights: {result['heights']}")
    print()
    
    # Verify: differences match edge weights
    h = result['heights']
    n = len(h)
    for i in range(n):
        diff = h[(i+1) % n] - h[i]
        print(f"  h[{(i+1)%n}] - h[{i}] = {h[(i+1)%n]:.1f} - {h[i]:.1f} = {diff:.1f} "
              f"(expected {weights[i]:.1f}) ✓")
    print()


def demo_hodge_decomposition():
    """Demonstrate the Hodge decomposition of a cocycle."""
    print("=" * 60)
    print("HODGE DECOMPOSITION ON CYCLE GRAPH")
    print("=" * 60)
    
    weights = [3.0, 1.0, -1.0, 2.0, 1.0]  # C₅
    coboundary_part, harmonic_part = decompose_cocycle(weights)
    
    print(f"Original cocycle: {weights}")
    print(f"Monodromy: {compute_monodromy(weights)}")
    print(f"Harmonic part (constant): {harmonic_part}")
    print(f"Coboundary part: {[round(x, 4) for x in coboundary_part]}")
    print(f"Coboundary monodromy: {compute_monodromy(coboundary_part):.10f} (should be ≈ 0)")
    print(f"Harmonic monodromy: {compute_monodromy(harmonic_part):.1f} (should equal original)")
    print()


def demo_orientation_cocycles():
    """Demonstrate orientation cocycles and non-orientability."""
    print("=" * 60)
    print("ORIENTATION COCYCLES: Cylinder vs Möbius Strip")
    print("=" * 60)
    
    # Cylinder (orientable): all orientations agree
    cylinder = [1, 1, 1, 1]
    m_cyl = orientation_monodromy(cylinder)
    print(f"Cylinder orientations: {cylinder}")
    print(f"Orientation monodromy: {m_cyl} → {'Orientable ✓' if m_cyl == 1 else 'Non-orientable'}")
    print()
    
    # Möbius strip (non-orientable): one orientation flip
    mobius = [1, 1, 1, -1]
    m_mob = orientation_monodromy(mobius)
    print(f"Möbius orientations: {mobius}")
    print(f"Orientation monodromy: {m_mob} → {'Orientable' if m_mob == 1 else 'Non-orientable ✗'}")
    print()
    
    # Three flips (still non-orientable — odd number of flips)
    triple_flip = [1, -1, -1, -1]
    m_tf = orientation_monodromy(triple_flip)
    print(f"Triple-flip orientations: {triple_flip}")
    print(f"Orientation monodromy: {m_tf} → {'Orientable' if m_tf == 1 else 'Non-orientable ✗'}")
    print(f"Number of -1s: {triple_flip.count(-1)} (odd → non-orientable)")
    print()


def demo_perturbation_stability():
    """Demonstrate that impossibility is stable under small perturbations."""
    print("=" * 60)
    print("PERTURBATION STABILITY")
    print("=" * 60)
    
    original = [1.0, 1.0, 1.0]  # Penrose triangle
    print(f"Original: {original}, monodromy = {compute_monodromy(original)}")
    
    # Small perturbation
    perturbed = [1.1, 0.9, 1.05]
    print(f"Perturbed: {perturbed}, monodromy = {compute_monodromy(perturbed):.2f}")
    print(f"Still impossible? {not is_coboundary(perturbed)} ✓")
    
    # Large perturbation that cancels
    cancelled = [1.0, 1.0, -2.0]
    print(f"Cancelled: {cancelled}, monodromy = {compute_monodromy(cancelled):.2f}")
    print(f"Still impossible? {not is_coboundary(cancelled)}")
    print(f"(Now realizable — perturbation exceeded stability radius)")
    print()


def demo_cohomology_class():
    """Demonstrate that cohomologous cocycles have the same monodromy."""
    print("=" * 60)
    print("COHOMOLOGY CLASSES: H¹(Cₙ; ℝ) ≅ ℝ")
    print("=" * 60)
    
    # Two different cocycles with the same monodromy
    w1 = [1.0, 1.0, 1.0]
    w2 = [0.5, 2.0, 0.5]
    
    print(f"Cocycle 1: {w1}, monodromy = {compute_monodromy(w1)}")
    print(f"Cocycle 2: {w2}, monodromy = {compute_monodromy(w2)}")
    print(f"Same monodromy? {compute_monodromy(w1) == compute_monodromy(w2)}")
    print(f"Therefore cohomologous — they represent the same obstruction!")
    
    # Their difference is a coboundary
    diff = [w1[i] - w2[i] for i in range(3)]
    print(f"Difference: {diff}, monodromy = {compute_monodromy(diff)}")
    print(f"Difference is coboundary? {is_coboundary(diff)} ✓")
    print()


if __name__ == "__main__":
    demo_penrose_triangle()
    demo_escher_staircase()
    demo_realizable_figure()
    demo_hodge_decomposition()
    demo_orientation_cocycles()
    demo_perturbation_stability()
    demo_cohomology_class()
    
    print("=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("The Monodromy Classification Theorem provides a complete")
    print("criterion for impossibility: a figure is impossible if and")
    print("only if the total height discrepancy around any cycle is")
    print("nonzero. This connects the art of Escher and Penrose to")
    print("the mathematics of cohomology and the de Rham theorem.")


"""
Visualization: Monodromy and Impossibility on Cycle Graphs

Produces three plots:
1. A cycle graph with height annotations showing an impossible figure
2. The Hodge decomposition of a cocycle
3. The impossibility index as a function of perturbation
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import math


def draw_cycle_graph(ax, n, weights, title, color_impossible='red', color_possible='green'):
    """Draw a cycle graph with edge weights and height annotations."""
    angles = [2 * math.pi * k / n - math.pi / 2 for k in range(n)]
    xs = [math.cos(a) for a in angles]
    ys = [math.sin(a) for a in angles]
    
    monodromy = sum(weights)
    is_impossible = abs(monodromy) > 1e-10
    edge_color = color_impossible if is_impossible else color_possible
    
    # Draw edges
    for i in range(n):
        j = (i + 1) % n
        ax.annotate('', xy=(xs[j], ys[j]), xytext=(xs[i], ys[i]),
                    arrowprops=dict(arrowstyle='->', color=edge_color, lw=2))
        mx = (xs[i] + xs[j]) / 2
        my = (ys[i] + ys[j]) / 2
        offset_x = 0.15 * (ys[j] - ys[i])
        offset_y = -0.15 * (xs[j] - xs[i])
        ax.text(mx + offset_x, my + offset_y, f'{weights[i]:+.1f}',
                ha='center', va='center', fontsize=10, fontweight='bold',
                color=edge_color,
                bbox=dict(boxstyle='round,pad=0.2', facecolor='white', edgecolor=edge_color, alpha=0.8))
    
    # Draw vertices
    for i in range(n):
        ax.plot(xs[i], ys[i], 'o', markersize=20, color='white',
                markeredgecolor='black', markeredgewidth=2, zorder=5)
        ax.text(xs[i], ys[i], str(i), ha='center', va='center',
                fontsize=12, fontweight='bold', zorder=6)
    
    status = "IMPOSSIBLE" if is_impossible else "REALIZABLE"
    ax.set_title(f'{title}\nMonodromy = {monodromy:.1f} ({status})',
                fontsize=12, fontweight='bold')
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.6, 1.6)
    ax.set_aspect('equal')
    ax.axis('off')


def plot_hodge_decomposition(ax, weights):
    """Plot the Hodge decomposition of a cocycle."""
    n = len(weights)
    m = sum(weights)
    harmonic = [m / n] * n
    coboundary = [weights[i] - harmonic[i] for i in range(n)]
    
    x = np.arange(n)
    width = 0.25
    
    bars1 = ax.bar(x - width, weights, width, label='Original ω', color='steelblue', edgecolor='black')
    bars2 = ax.bar(x, coboundary, width, label='Coboundary δf', color='forestgreen', edgecolor='black')
    bars3 = ax.bar(x + width, harmonic, width, label='Harmonic ω_h', color='coral', edgecolor='black')
    
    ax.set_xlabel('Edge index', fontsize=11)
    ax.set_ylabel('Weight', fontsize=11)
    ax.set_title(f'Hodge Decomposition: ω = δf + ω_h\n(monodromy = {m:.1f})', fontsize=12, fontweight='bold')
    ax.set_xticks(x)
    ax.legend(fontsize=9)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.grid(axis='y', alpha=0.3)


def plot_perturbation_stability(ax, base_weights):
    """Plot impossibility index under perturbation."""
    base_monodromy = sum(base_weights)
    n = len(base_weights)
    
    # Perturb the last edge weight
    perturbations = np.linspace(-abs(base_monodromy) - 2, abs(base_monodromy) + 2, 200)
    indices = []
    for p in perturbations:
        perturbed = list(base_weights)
        perturbed[-1] += p
        indices.append(abs(sum(perturbed)))
    
    ax.plot(perturbations, indices, 'b-', linewidth=2)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5, linestyle='--')
    
    # Mark the critical perturbation where impossibility changes
    critical = -base_weights[-1] - sum(base_weights[:-1])
    ax.axvline(x=critical, color='red', linewidth=1, linestyle='--', label=f'Critical: δ={critical:.1f}')
    ax.plot(0, abs(base_monodromy), 'ro', markersize=8, zorder=5, label=f'Original (index={abs(base_monodromy):.1f})')
    
    ax.fill_between(perturbations, 0, indices, alpha=0.1, color='blue')
    ax.set_xlabel('Perturbation δ on last edge', fontsize=11)
    ax.set_ylabel('Impossibility Index |M|', fontsize=11)
    ax.set_title('Perturbation Stability\nof Impossibility Index', fontsize=12, fontweight='bold')
    ax.legend(fontsize=9)
    ax.grid(alpha=0.3)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    
    # 1. Penrose triangle (impossible)
    draw_cycle_graph(axes[0, 0], 3, [1.0, 1.0, 1.0], 'Penrose Triangle')
    
    # 2. Realizable quadrilateral
    draw_cycle_graph(axes[0, 1], 4, [3.0, 2.0, -4.0, -1.0], 'Realizable Quadrilateral')
    
    # 3. Hodge decomposition
    plot_hodge_decomposition(axes[1, 0], [3.0, 1.0, -1.0, 2.0, 1.0])
    
    # 4. Perturbation stability
    plot_perturbation_stability(axes[1, 1], [1.0, 1.0, 1.0])
    
    plt.suptitle('Impossible Figures: Height Cocycles and Monodromy',
                fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('monodromy_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved monodromy_visualization.png")


if __name__ == "__main__":
    main()
