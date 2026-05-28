#!/usr/bin/env python3
"""
Visualization: Support Geometry and Rectangularity

Visualizes the support structure of quantum states and their projection
onto bipartitions. For product states, the support projects to a
Cartesian product (rectangle), while for GHZ and W states the support
is non-rectangular — the geometric signature of entanglement.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct


# ─── State definitions ───────────────────────────────────────────────

def ghz_state_3(s):
    return 1.0 if (all(x == 0 for x in s) or all(x == 1 for x in s)) else 0.0

def w_state_3(s):
    return 1.0 if sum(s) == 1 else 0.0

def product_state_3(s):
    return np.prod([1/np.sqrt(2)] * 3)


# ─── Build support projections for n=3, A={0} ───────────────────────

configs = list(iterproduct(range(2), repeat=3))

fig, axes = plt.subplots(2, 3, figsize=(15, 10))

states = [
    ("GHZ State", ghz_state_3),
    ("W State", w_state_3),
    ("Product State", product_state_3),
]

partitions = [
    (frozenset({0}), "A = {0}"),
    (frozenset({0, 1}), "A = {0,1}"),
]

for col, (state_name, psi) in enumerate(states):
    # Top row: support visualization as 3D boolean
    ax = axes[0, col]
    support = [(s[0], s[1], s[2]) for s in configs if abs(psi(s)) > 1e-10]
    non_support = [(s[0], s[1], s[2]) for s in configs if abs(psi(s)) <= 1e-10]
    
    # Plot as a grid
    grid = np.zeros((2, 2, 2))
    for s in support:
        grid[s] = abs(psi(s))
    
    # Flatten to 2D display: x-axis = party 0, y-axis = (party1, party2) as base-2
    display = np.zeros((2, 4))
    labels_y = []
    for b1 in range(2):
        for b2 in range(2):
            idx = b1 * 2 + b2
            labels_y.append(f"({b1},{b2})")
            for b0 in range(2):
                display[b0, idx] = abs(psi((b0, b1, b2)))
    
    im = ax.imshow(display.T, cmap='Blues', aspect='auto', vmin=0, vmax=1.2,
                   interpolation='nearest')
    ax.set_xticks([0, 1])
    ax.set_xticklabels(['0', '1'])
    ax.set_yticks(range(4))
    ax.set_yticklabels(labels_y)
    ax.set_xlabel('Party 0', fontsize=10)
    ax.set_ylabel('(Party 1, Party 2)', fontsize=10)
    ax.set_title(f'{state_name}\nAmplitude Table', fontsize=12, fontweight='bold')
    
    # Annotate
    for i in range(2):
        for j in range(4):
            val = display[i, j]
            color = 'white' if val > 0.6 else 'black'
            text = f"{val:.2f}" if val > 0.01 else "0"
            ax.text(i, j, text, ha='center', va='center', color=color, fontsize=9)
    
    # Bottom row: rectangularity analysis for A = {0}
    ax2 = axes[1, col]
    A = frozenset({0})
    
    # For each a in proj_A and b in proj_Ac, check if (a,b) is in support
    proj_A_vals = sorted(set(s[0] for s in support)) if support else []
    proj_Ac_vals = sorted(set((s[1], s[2]) for s in support)) if support else []
    
    rect_grid = np.zeros((max(len(proj_A_vals), 1), max(len(proj_Ac_vals), 1)))
    missing = []
    
    for i, a in enumerate(proj_A_vals):
        for j, bc in enumerate(proj_Ac_vals):
            s_combined = (a,) + bc
            if abs(psi(s_combined)) > 1e-10:
                rect_grid[i, j] = 1.0
            else:
                rect_grid[i, j] = 0.0
                missing.append((i, j))
    
    im2 = ax2.imshow(rect_grid, cmap='RdYlGn', aspect='auto', vmin=0, vmax=1,
                     interpolation='nearest')
    ax2.set_xticks(range(len(proj_Ac_vals)))
    ax2.set_xticklabels([str(v) for v in proj_Ac_vals], fontsize=8)
    ax2.set_yticks(range(len(proj_A_vals)))
    ax2.set_yticklabels([str(v) for v in proj_A_vals])
    ax2.set_xlabel('Projected support on Aᶜ = {1,2}', fontsize=9)
    ax2.set_ylabel('Projected support on A = {0}', fontsize=9)
    
    is_rect = len(missing) == 0
    rect_status = "RECTANGULAR ✓\n(Product-like)" if is_rect else "NON-RECTANGULAR ✗\n(Entangled!)"
    color = 'green' if is_rect else 'red'
    ax2.set_title(f'Support Rectangularity Check\n{rect_status}',
                  fontsize=11, fontweight='bold', color=color)
    
    # Mark missing entries
    for (i, j) in missing:
        ax2.plot(j, i, 'rx', markersize=15, markeredgewidth=3)
    
    # Annotate
    for i in range(rect_grid.shape[0]):
        for j in range(rect_grid.shape[1]):
            val = rect_grid[i, j]
            text = "✓" if val > 0.5 else "✗"
            c = 'white' if val > 0.5 else 'red'
            ax2.text(j, i, text, ha='center', va='center', color=c, fontsize=14, fontweight='bold')

plt.suptitle('Support Geometry of Quantum States\n'
             'Entanglement = Non-rectangular support projection across bipartitions',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('support_geometry.png', dpi=150, bbox_inches='tight')
print("Saved support_geometry.png")
