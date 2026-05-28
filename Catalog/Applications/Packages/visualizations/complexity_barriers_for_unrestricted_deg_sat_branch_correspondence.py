#!/usr/bin/env python3
"""
Visualization: SAT-to-Branch Correspondence

Illustrates how Boolean satisfiability problems map to derivative-tree
branches in Lorentzian polynomial recognition. Shows the correspondence
between obstructed branches and unsatisfying assignments.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import itertools


def bool_to_multiindex(m, b):
    count_true = sum(1 for x in b if x)
    alpha_0 = m - count_true
    rest = tuple(1 if bi else 0 for bi in b)
    return (alpha_0,) + rest


fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Three CNF formulas to compare
formulas = [
    {
        "name": "Satisfiable: (x₀∨x₁) ∧ (¬x₀∨x₁)",
        "num_vars": 2,
        "clauses": [[(0, True), (1, True)], [(0, False), (1, True)]],
    },
    {
        "name": "Unsatisfiable: (x₀) ∧ (¬x₀)",
        "num_vars": 1,
        "clauses": [[(0, True)], [(0, False)]],
    },
    {
        "name": "3-SAT: (x₀∨x₁∨x₂) ∧ (¬x₀∨¬x₁) ∧ (¬x₁∨¬x₂) ∧ (¬x₀∨¬x₂)",
        "num_vars": 3,
        "clauses": [[(0, True), (1, True), (2, True)],
                    [(0, False), (1, False)],
                    [(1, False), (2, False)],
                    [(0, False), (2, False)]],
    },
]

for ax_idx, formula_info in enumerate(formulas):
    ax = axes[ax_idx]
    m = formula_info["num_vars"]
    clauses = formula_info["clauses"]
    
    assignments = list(itertools.product([False, True], repeat=m))
    
    # Classify each assignment
    free_count = 0
    obstructed_count = 0
    
    bar_labels = []
    bar_colors = []
    bar_alphas = []
    
    for b in assignments:
        satisfied = all(
            any(b[var] == pol for var, pol in clause)
            for clause in clauses
        )
        bits_str = "".join("1" if x else "0" for x in b)
        alpha = bool_to_multiindex(m, b)
        
        bar_labels.append(f"{bits_str}\n{alpha}")
        
        if satisfied:
            bar_colors.append('#2ecc71')  # green for free
            bar_alphas.append(0.8)
            free_count += 1
        else:
            bar_colors.append('#e74c3c')  # red for obstructed
            bar_alphas.append(0.8)
            obstructed_count += 1
    
    # Draw bars
    x_pos = range(len(assignments))
    bars = ax.bar(x_pos, [1] * len(assignments), color=bar_colors, 
                  edgecolor='black', linewidth=0.5)
    
    ax.set_xticks(x_pos)
    ax.set_xticklabels(bar_labels, fontsize=7, fontfamily='monospace')
    ax.set_yticks([])
    ax.set_title(formula_info["name"], fontsize=10, fontweight='bold')
    
    # Summary
    total = len(assignments)
    sat_status = "SAT" if free_count > 0 else "UNSAT"
    ax.text(0.5, 0.5, f"{sat_status}\n{free_count} free / {obstructed_count} obstructed",
            transform=ax.transAxes, ha='center', va='center', fontsize=11,
            fontweight='bold',
            bbox=dict(boxstyle='round,pad=0.5', facecolor='white', alpha=0.8))

# Legend
green_patch = mpatches.Patch(color='#2ecc71', label='Free branch (satisfying)')
red_patch = mpatches.Patch(color='#e74c3c', label='Obstructed branch (falsifying)')
fig.legend(handles=[green_patch, red_patch], loc='lower center', 
           ncol=2, fontsize=11, frameon=True)

plt.suptitle('SAT ↔ Branch Obstruction Correspondence', fontsize=14, 
             fontweight='bold', y=1.02)
plt.tight_layout()
plt.subplots_adjust(bottom=0.12)
plt.savefig('sat_branches.png', dpi=150, bbox_inches='tight')
print("Saved sat_branches.png")
