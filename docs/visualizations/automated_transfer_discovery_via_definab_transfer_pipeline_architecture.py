#!/usr/bin/env python3
"""
Visualization: Transfer Pipeline Architecture

Visualizes the three-phase transfer pipeline:
1. Definability Analysis → formula extraction
2. Complexity Bounding → cost estimation
3. Transfer Execution → Łoś theorem application

Shows how formula trees are processed through each phase with
concrete examples from Pythagorean triple theory.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# ---- Panel 1: Transfer pipeline flow ----
ax = axes[0, 0]
ax.set_xlim(0, 10)
ax.set_ylim(0, 10)
ax.set_aspect('equal')
ax.axis('off')
ax.set_title('Transfer Pipeline Architecture', fontsize=13, fontweight='bold')

# Phase boxes
phases = [
    (1.5, 7.5, 'Phase 1:\nDefinability\nAnalysis', '#3498db'),
    (5, 7.5, 'Phase 2:\nComplexity\nBounding', '#e67e22'),
    (8.5, 7.5, 'Phase 3:\nŁoś Transfer\nExecution', '#27ae60'),
]

for x, y, label, color in phases:
    rect = mpatches.FancyBboxPatch((x-1.2, y-1), 2.4, 2,
                                    boxstyle="round,pad=0.15",
                                    facecolor=color, alpha=0.3,
                                    edgecolor=color, linewidth=2)
    ax.add_patch(rect)
    ax.text(x, y, label, ha='center', va='center', fontsize=9, fontweight='bold')

# Arrows between phases
for x1, x2 in [(2.7, 3.8), (6.2, 7.3)]:
    ax.annotate('', xy=(x2, 7.5), xytext=(x1, 7.5),
                arrowprops=dict(arrowstyle='->', lw=2, color='gray'))

# Input/output labels
ax.text(1.5, 5.5, 'Input:\nFinite theorem\n∀ q: F_q, P(q)', ha='center', fontsize=8,
        style='italic', color='#2c3e50',
        bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))
ax.text(8.5, 5.5, 'Output:\nPseudofinite\ntransfer ∀ᵁ P', ha='center', fontsize=8,
        style='italic', color='#2c3e50',
        bbox=dict(boxstyle='round', facecolor='lightgreen', alpha=0.8))

# ---- Panel 2: Complexity growth under composition ----
ax = axes[0, 1]

# Show how complexity grows with number of boolean operations
ops = range(0, 12)
# Starting with 2 atoms, adding operations one at a time
complexities_conj = [2*2 - 1 + 0]  # 2 atoms, 0 negs
complexities_mixed = [2*2 - 1 + 0]

for i in range(1, 12):
    # Pure conjunctions: each adds 1 atom
    complexities_conj.append(2*(i+2) - 1)
    # Mixed ops: alternating conj and neg
    atoms = i // 2 + 2
    negs = (i + 1) // 2
    complexities_mixed.append(2*atoms - 1 + negs)

ax.plot(list(ops), complexities_conj, 'b-o', label='Pure conjunctions', linewidth=2, markersize=5)
ax.plot(list(ops), complexities_mixed, 'r-s', label='Mixed (conj + neg)', linewidth=2, markersize=5)
ax.plot(list(ops), [2*i + 3 for i in ops], 'k--', alpha=0.5, label='Linear bound 2n+3')

ax.set_xlabel('Number of Operations', fontsize=11)
ax.set_ylabel('Formula Complexity', fontsize=11)
ax.set_title('Complexity Growth Under Composition', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# ---- Panel 3: Transfer cost breakdown ----
ax = axes[1, 0]

examples = [
    'x=0', 'x=0 ∧ y=0', 'x=0 → y=0',
    '(x=0 ∧ y=0) → z=0', '¬(x=0 ∨ y=0)'
]
poly_costs = [1, 2, 2, 3, 2]
bool_costs = [0, 1, 2, 3, 3]
total_costs = [p + b for p, b in zip(poly_costs, bool_costs)]

x_pos = np.arange(len(examples))
width = 0.35

bars1 = ax.bar(x_pos - width/2, poly_costs, width, label='Polynomial eval', color='#3498db', alpha=0.8)
bars2 = ax.bar(x_pos + width/2, bool_costs, width, label='Boolean closure', color='#e74c3c', alpha=0.8)

ax.set_xlabel('Formula', fontsize=11)
ax.set_ylabel('Number of Steps', fontsize=11)
ax.set_title('Transfer Cost Breakdown', fontsize=13, fontweight='bold')
ax.set_xticks(x_pos)
ax.set_xticklabels(examples, fontsize=8, rotation=15)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3, axis='y')

# Add total labels
for i, total in enumerate(total_costs):
    ax.text(i, max(poly_costs[i], bool_costs[i]) + 0.2, f'Σ={total}',
            ha='center', fontsize=8, fontweight='bold')

# ---- Panel 4: Depth vs Complexity scatter ----
ax = axes[1, 1]

# Generate random formulas and plot depth vs complexity
np.random.seed(42)

def random_formula_stats(n=200):
    """Generate random formula statistics."""
    depths = []
    complexities = []
    atoms_list = []
    for _ in range(n):
        atoms = np.random.randint(1, 20)
        negs = np.random.randint(0, 10)
        complexity = 2 * atoms - 1 + negs
        # Depth is bounded: depth + 1 ≤ complexity
        max_depth = complexity - 1
        depth = np.random.randint(0, max(1, min(max_depth, int(np.log2(complexity)) + 3)))
        depths.append(depth)
        complexities.append(complexity)
        atoms_list.append(atoms)
    return depths, complexities, atoms_list

depths, complexities, atoms_list = random_formula_stats()

scatter = ax.scatter(depths, complexities, c=atoms_list, cmap='viridis',
                     alpha=0.6, s=30, edgecolors='gray', linewidths=0.3)
cbar = plt.colorbar(scatter, ax=ax)
cbar.set_label('Atom Count', fontsize=10)

# Plot the bound: depth + 1 ≤ complexity
d_range = np.arange(0, max(depths) + 2)
ax.plot(d_range, d_range + 1, 'r--', linewidth=2, label='depth + 1 = complexity', alpha=0.7)

ax.set_xlabel('Depth', fontsize=11)
ax.set_ylabel('Complexity', fontsize=11)
ax.set_title('Depth vs Complexity\n(depth + 1 ≤ complexity always)', fontsize=13, fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_transfer_pipeline.png', dpi=150, bbox_inches='tight')
print("Saved viz_transfer_pipeline.png")
