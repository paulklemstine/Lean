#!/usr/bin/env python3
"""
Visualization: Independence Complex of Argumentation Frameworks

Generates a visualization of the attack graph and its independence complex
(Hasse diagram of the face lattice) for the Euler characteristic counterexample.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import combinations


def compute_conflict_free(args, attacks):
    """Compute all conflict-free sets."""
    result = [frozenset()]
    args_sorted = sorted(args)
    for a in args_sorted:
        new_sets = []
        for s in result:
            candidate = s | {a}
            is_cf = True
            for x in candidate:
                for y in candidate:
                    if (x, y) in attacks:
                        is_cf = False
                        break
                if not is_cf:
                    break
            if is_cf:
                new_sets.append(candidate)
        result.extend(new_sets)
    return result


def main():
    # Framework: 0→1, 1→2
    args = {0, 1, 2}
    attacks = {(0, 1), (1, 2)}
    
    cf_sets = compute_conflict_free(args, attacks)
    
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    
    # --- Left: Attack Graph ---
    ax1 = axes[0]
    ax1.set_title("Attack Graph: AF = ({0,1,2}, {0→1, 1→2})", fontsize=12, fontweight='bold')
    
    # Position arguments in a line
    positions = {0: (0.2, 0.5), 1: (0.5, 0.5), 2: (0.8, 0.5)}
    
    # Draw arguments
    for arg, (x, y) in positions.items():
        circle = plt.Circle((x, y), 0.06, color='#4CAF50', ec='black', linewidth=2, zorder=5)
        ax1.add_patch(circle)
        ax1.text(x, y, str(arg), ha='center', va='center', fontsize=14, fontweight='bold', zorder=6)
    
    # Draw attacks
    for (a, b) in attacks:
        x1, y1 = positions[a]
        x2, y2 = positions[b]
        dx = x2 - x1
        dy = y2 - y1
        length = np.sqrt(dx**2 + dy**2)
        # Shorten arrow to not overlap circles
        shrink = 0.07 / length
        ax1.annotate("", xy=(x2 - dx*shrink, y2 - dy*shrink), 
                     xytext=(x1 + dx*shrink, y1 + dy*shrink),
                     arrowprops=dict(arrowstyle='->', color='red', lw=2.5))
    
    ax1.set_xlim(0, 1)
    ax1.set_ylim(0, 1)
    ax1.set_aspect('equal')
    ax1.axis('off')
    
    # Labels
    ax1.text(0.5, 0.15, f"Conflict-free sets: {len(cf_sets)}", 
             ha='center', fontsize=11)
    ax1.text(0.5, 0.08, "∅, {0}, {1}, {2}, {0,2}", 
             ha='center', fontsize=10, style='italic')
    
    # --- Right: Independence Complex (Hasse Diagram) ---
    ax2 = axes[1]
    ax2.set_title("Independence Complex (Face Lattice)", fontsize=12, fontweight='bold')
    
    # Organize by dimension
    by_dim = {}
    for s in cf_sets:
        d = len(s)
        by_dim.setdefault(d, []).append(s)
    
    # Position nodes in Hasse diagram
    node_pos = {}
    colors = {0: '#E3F2FD', 1: '#BBDEFB', 2: '#90CAF9'}
    
    for dim, sets in sorted(by_dim.items()):
        n = len(sets)
        for i, s in enumerate(sorted(sets, key=lambda x: tuple(sorted(x)))):
            x = (i + 0.5) / n
            y = 0.15 + dim * 0.35
            node_pos[s] = (x, y)
    
    # Draw edges (inclusion relations)
    for s1 in cf_sets:
        for s2 in cf_sets:
            if len(s2) == len(s1) + 1 and s1 < s2:
                x1, y1 = node_pos[s1]
                x2, y2 = node_pos[s2]
                ax2.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1.5)
    
    # Draw nodes
    for s, (x, y) in node_pos.items():
        dim = len(s)
        color = colors.get(dim, '#E0E0E0')
        box = mpatches.FancyBboxPatch((x-0.08, y-0.04), 0.16, 0.08,
                                       boxstyle="round,pad=0.02",
                                       facecolor=color, edgecolor='black', linewidth=1.5)
        ax2.add_patch(box)
        label = "∅" if not s else "{" + ",".join(map(str, sorted(s))) + "}"
        ax2.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')
    
    # Dimension labels
    for dim in by_dim:
        ax2.text(-0.05, 0.15 + dim * 0.35, f"dim {dim}", 
                ha='center', va='center', fontsize=9, color='gray')
    
    # Euler characteristic annotation
    f_vec = {d: len(sets) for d, sets in by_dim.items()}
    chi = sum((-1)**d * c for d, c in f_vec.items())
    ax2.text(0.5, 0.95, f"f-vector: ({', '.join(str(f_vec.get(d, 0)) for d in range(max(f_vec)+1))})", 
             ha='center', fontsize=10, transform=ax2.transAxes)
    ax2.text(0.5, 0.88, f"χ = {' + '.join(f'({-1 if d%2 else 1}){f_vec.get(d,0)}' for d in range(max(f_vec)+1))} = {chi}", 
             ha='center', fontsize=10, color='#D32F2F', fontweight='bold', transform=ax2.transAxes)
    
    ax2.set_xlim(-0.15, 1.15)
    ax2.set_ylim(0, 1)
    ax2.axis('off')
    
    plt.tight_layout()
    plt.savefig('independence_complex.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: independence_complex.png")


if __name__ == "__main__":
    main()
