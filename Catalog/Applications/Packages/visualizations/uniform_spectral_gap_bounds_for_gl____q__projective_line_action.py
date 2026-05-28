#!/usr/bin/env python3
"""
Visualization: Projective Line Action of Singer-Like Elements

Shows how a Singer-like matrix acts on the projective line ℙ¹(𝔽_q),
demonstrating the key geometric theorem: Singer-like elements have
no fixed points on the projective line. All points are permuted in
a single cycle, visualized as a circular permutation diagram.

This visualization supports Theorem 2 (singer_like_no_fixed_projective_point):
every Singer-like element shuffles all q+1 projective points.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch
import matplotlib.patches as mpatches


def mod_inverse(a, p):
    return pow(int(a), p - 2, p)


def apply_projective(M, pt, p):
    """Apply 2x2 matrix M to projective point pt = (x, y) mod p."""
    a, b, c, d = M[0][0], M[0][1], M[1][0], M[1][1]
    x = (a * pt[0] + b * pt[1]) % p
    y = (c * pt[0] + d * pt[1]) % p
    if x != 0:
        return (1, (y * mod_inverse(x, p)) % p)
    elif y != 0:
        return (0, 1)
    return pt


def get_cycle_structure(M, p):
    """Compute the cycle structure of M acting on ℙ¹(𝔽_p)."""
    points = [(1, b) for b in range(p)] + [(0, 1)]
    point_set = set(points)
    visited = set()
    cycles = []
    
    for pt in points:
        if pt in visited:
            continue
        cycle = [pt]
        visited.add(pt)
        current = apply_projective(M, pt, p)
        while current != pt:
            cycle.append(current)
            visited.add(current)
            current = apply_projective(M, current, p)
        cycles.append(cycle)
    
    return cycles


def is_singer_like(M, p):
    tr = (M[0][0] + M[1][1]) % p
    det = (M[0][0] * M[1][1] - M[0][1] * M[1][0]) % p
    if det == 0:
        return False
    disc = (tr * tr - 4 * det) % p
    if disc == 0:
        return False
    return pow(int(disc), (p - 1) // 2, p) != 1


# ── Create visualization ──

fig, axes = plt.subplots(1, 3, figsize=(18, 6))
fig.suptitle('Projective Line Action: Singer-Like vs Non-Singer Elements', 
             fontsize=14, fontweight='bold')

examples = [
    (5, [[2, 2], [3, 0]], "Singer-like: g = [[2,2],[3,0]]"),
    (5, [[1, 1], [0, 1]], "Non-Singer: h = [[1,1],[0,1]]"),
    (7, [[0, 3], [1, 6]], "Singer-like: g = [[0,3],[1,6]]"),
]

colors_cycle = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12', '#9b59b6', 
                '#1abc9c', '#e67e22', '#34495e']

for idx, (q, M, title) in enumerate(examples):
    ax = axes[idx]
    points = [(1, b) for b in range(q)] + [(0, 1)]
    n = len(points)
    
    # Place points on a circle
    angles = [2 * np.pi * i / n - np.pi/2 for i in range(n)]
    radius = 1.0
    x_pos = [radius * np.cos(a) for a in angles]
    y_pos = [radius * np.sin(a) for a in angles]
    
    # Get cycles
    cycles = get_cycle_structure(M, q)
    singer = is_singer_like(M, q)
    
    # Draw arrows for the permutation
    point_to_idx = {pt: i for i, pt in enumerate(points)}
    
    for c_idx, cycle in enumerate(cycles):
        color = colors_cycle[c_idx % len(colors_cycle)]
        for j in range(len(cycle)):
            src = point_to_idx[cycle[j]]
            dst = point_to_idx[cycle[(j + 1) % len(cycle)]]
            
            dx = x_pos[dst] - x_pos[src]
            dy = y_pos[dst] - y_pos[src]
            
            # Curved arrows
            ax.annotate("", 
                xy=(x_pos[dst], y_pos[dst]),
                xytext=(x_pos[src], y_pos[src]),
                arrowprops=dict(arrowstyle="->", color=color, lw=1.5,
                              connectionstyle="arc3,rad=0.3"))
    
    # Draw points
    for i, pt in enumerate(points):
        label = f"[1:{pt[1]}]" if pt[0] == 1 else "[0:1]"
        ax.plot(x_pos[i], y_pos[i], 'ko', markersize=12, zorder=5)
        ax.plot(x_pos[i], y_pos[i], 'wo', markersize=8, zorder=6)
        
        # Label outside the circle
        label_r = 1.3
        lx = label_r * np.cos(angles[i])
        ly = label_r * np.sin(angles[i])
        ax.text(lx, ly, label, ha='center', va='center', fontsize=8, fontweight='bold')
    
    # Title and annotation
    cycle_desc = " × ".join([f"({len(c)})" for c in sorted(cycles, key=len, reverse=True)])
    ax.set_title(f"{title}\nCycle type: {cycle_desc}", fontsize=10)
    
    if singer:
        ax.text(0, -1.7, "✓ No fixed point\n(Singer-like)", 
                ha='center', color='green', fontsize=9, fontweight='bold')
    else:
        fixed = [c[0] for c in cycles if len(c) == 1]
        if fixed:
            fix_labels = [f"[1:{p[1]}]" if p[0]==1 else "[0:1]" for p in fixed]
            ax.text(0, -1.7, f"✗ Fixed points: {', '.join(fix_labels)}", 
                    ha='center', color='red', fontsize=9, fontweight='bold')
        else:
            ax.text(0, -1.7, "No fixed points\n(but not Singer-like)", 
                    ha='center', color='orange', fontsize=9, fontweight='bold')
    
    ax.set_xlim(-1.8, 1.8)
    ax.set_ylim(-2.0, 1.8)
    ax.set_aspect('equal')
    ax.axis('off')

plt.tight_layout()
plt.savefig('projective_action.png', dpi=150, bbox_inches='tight')
print("Saved: projective_action.png")
