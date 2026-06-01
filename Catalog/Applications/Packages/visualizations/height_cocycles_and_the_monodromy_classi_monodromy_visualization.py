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
