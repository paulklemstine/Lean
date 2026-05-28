#!/usr/bin/env python3
"""
Visualization: SAT-Branch Correspondence Heatmap

Shows how Boolean satisfiability maps onto derivative tree branches.
For a small CNF formula, displays a heatmap where:
- Rows = variable assignments (derivative branch directions)
- Columns = clauses
- Color = satisfied (green) / violated (red)

This visualizes the core bridge: derivative tree leaves encode
the structure of SAT instances.
"""

import math
import itertools
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def evaluate_cnf(num_vars, clauses, assignment):
    """Check which clauses are satisfied by an assignment."""
    results = []
    for clause in clauses:
        sat = any(assignment[v] == p for v, p in clause)
        results.append(sat)
    return results


# Define a sample CNF formula: (x0 ∨ x1) ∧ (¬x1 ∨ x2) ∧ (x0 ∨ ¬x2) ∧ (¬x0 ∨ x1 ∨ x2)
num_vars = 3
clauses = [
    [(0, True), (1, True)],       # x0 ∨ x1
    [(1, False), (2, True)],      # ¬x1 ∨ x2
    [(0, True), (2, False)],      # x0 ∨ ¬x2
    [(0, False), (1, True), (2, True)],  # ¬x0 ∨ x1 ∨ x2
]

clause_labels = ['x₀ ∨ x₁', '¬x₁ ∨ x₂', 'x₀ ∨ ¬x₂', '¬x₀ ∨ x₁ ∨ x₂']

# Enumerate all assignments
assignments = list(itertools.product([False, True], repeat=num_vars))
n_assign = len(assignments)
n_clauses = len(clauses)

# Build satisfaction matrix
sat_matrix = np.zeros((n_assign, n_clauses))
formula_sat = []
for i, asgn in enumerate(assignments):
    results = evaluate_cnf(num_vars, clauses, asgn)
    sat_matrix[i, :] = [1 if r else 0 for r in results]
    formula_sat.append(all(results))

# Create figure
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7), gridspec_kw={'width_ratios': [3, 1]})

# ---- Plot 1: Clause satisfaction heatmap ----
cmap = plt.cm.colors.ListedColormap(['#e74c3c', '#2ecc71'])
bounds = [-0.5, 0.5, 1.5]
norm = plt.cm.colors.BoundaryNorm(bounds, cmap.N)

im = ax1.imshow(sat_matrix, cmap=cmap, norm=norm, aspect='auto',
                interpolation='nearest')

# Labels
assignment_labels = []
for asgn in assignments:
    bits = ''.join('1' if b else '0' for b in asgn)
    multiidx = tuple(1 if b else 0 for b in asgn)
    weight = sum(multiidx)
    sat_str = '✓' if formula_sat[assignments.index(asgn)] else '✗'
    assignment_labels.append(f'{bits} (w={weight}) {sat_str}')

ax1.set_yticks(range(n_assign))
ax1.set_yticklabels(assignment_labels, fontsize=10, fontfamily='monospace')
ax1.set_xticks(range(n_clauses))
ax1.set_xticklabels(clause_labels, fontsize=11, rotation=30, ha='right')

# Add cell text
for i in range(n_assign):
    for j in range(n_clauses):
        text = '✓' if sat_matrix[i, j] else '✗'
        color = 'white' if sat_matrix[i, j] == 0 else 'black'
        ax1.text(j, i, text, ha='center', va='center', fontsize=14,
                fontweight='bold', color=color)

ax1.set_title('Clause Satisfaction Matrix\n(Assignment × Clause)', fontsize=14)
ax1.set_xlabel('Clause', fontsize=12)
ax1.set_ylabel('Assignment (binary multiindex, weight, satisfied?)', fontsize=12)

# Legend
legend_patches = [
    mpatches.Patch(color='#2ecc71', label='Clause satisfied'),
    mpatches.Patch(color='#e74c3c', label='Clause violated'),
]
ax1.legend(handles=legend_patches, loc='upper right', fontsize=10)

# ---- Plot 2: Branch obstruction summary ----
weights = [sum(1 if b else 0 for b in asgn) for asgn in assignments]
unique_weights = sorted(set(weights))

# Count by weight: total, satisfied, obstructed
weight_data = {}
for w in unique_weights:
    total = sum(1 for wt in weights if wt == w)
    sat_count = sum(1 for i, wt in enumerate(weights) if wt == w and formula_sat[i])
    weight_data[w] = (total, sat_count, total - sat_count)

bar_width = 0.35
x_pos = np.arange(len(unique_weights))

sat_counts = [weight_data[w][1] for w in unique_weights]
obs_counts = [weight_data[w][2] for w in unique_weights]

ax2.bar(x_pos, sat_counts, bar_width, label='Satisfying', color='#2ecc71', alpha=0.8)
ax2.bar(x_pos, obs_counts, bar_width, bottom=sat_counts,
        label='Obstructed', color='#e74c3c', alpha=0.8)

ax2.set_xlabel('Weight of multiindex', fontsize=12)
ax2.set_ylabel('Number of branches', fontsize=12)
ax2.set_title('Branch Classification\nby Weight', fontsize=14)
ax2.set_xticks(x_pos)
ax2.set_xticklabels([str(w) for w in unique_weights])
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3, axis='y')

# Add annotation
total_sat = sum(1 for s in formula_sat if s)
total_obs = sum(1 for s in formula_sat if not s)
ax2.text(0.5, 0.95, f'Total: {n_assign} branches\n'
         f'Satisfying: {total_sat}\nObstructed: {total_obs}',
         transform=ax2.transAxes, fontsize=10, verticalalignment='top',
         bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

plt.suptitle('SAT-Branch Correspondence: CNF Formula → Derivative Tree Branches',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('sat_branch_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved sat_branch_heatmap.png")
