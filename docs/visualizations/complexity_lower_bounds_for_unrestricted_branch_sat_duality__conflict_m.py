"""
Visualization: Branch-SAT Duality

Shows the correspondence between Boolean assignments and branch obstructions.
For a small CNF formula, visualizes which assignments conflict which clauses,
illustrating the Branch-SAT Duality Theorem.

Self-contained — does not import any local modules.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product

def find_conflicts(n_vars, clauses):
    """For each assignment, find conflicted clause indices."""
    assignments = list(product([False, True], repeat=n_vars))
    conflict_matrix = np.zeros((len(assignments), len(clauses)), dtype=int)

    for i, assignment in enumerate(assignments):
        for j, clause in enumerate(clauses):
            if all(assignment[v] != p for v, p in clause):
                conflict_matrix[i, j] = 1

    return assignments, conflict_matrix

# Example 1: Unsatisfiable formula
# (x₀∨x₁) ∧ (¬x₀) ∧ (¬x₁)
clauses_unsat = [
    [(0, True), (1, True)],   # x₀ ∨ x₁
    [(0, False)],              # ¬x₀
    [(1, False)],              # ¬x₁
]
clause_labels_unsat = ['x₀∨x₁', '¬x₀', '¬x₁']
assignments_u, conflicts_u = find_conflicts(2, clauses_unsat)
assign_labels_u = [f"({int(a[0])},{int(a[1])})" for a in assignments_u]

# Example 2: Satisfiable formula
# (x₀∨x₁) ∧ (¬x₀∨x₁)
clauses_sat = [
    [(0, True), (1, True)],    # x₀ ∨ x₁
    [(0, False), (1, True)],   # ¬x₀ ∨ x₁
]
clause_labels_sat = ['x₀∨x₁', '¬x₀∨x₁']
assignments_s, conflicts_s = find_conflicts(2, clauses_sat)
assign_labels_s = [f"({int(a[0])},{int(a[1])})" for a in assignments_s]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Unsatisfiable
ax = axes[0]
im = ax.imshow(conflicts_u, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(clause_labels_unsat)))
ax.set_xticklabels(clause_labels_unsat, fontsize=11)
ax.set_yticks(range(len(assign_labels_u)))
ax.set_yticklabels(assign_labels_u, fontsize=11)
ax.set_xlabel('Clauses', fontsize=12)
ax.set_ylabel('Assignment (x₀, x₁)', fontsize=12)
ax.set_title('UNSATISFIABLE\nEvery row has ≥1 conflict (red)', fontsize=12, color='red')

for i in range(conflicts_u.shape[0]):
    for j in range(conflicts_u.shape[1]):
        color = 'white' if conflicts_u[i, j] else 'black'
        text = '✗' if conflicts_u[i, j] else '✓'
        ax.text(j, i, text, ha='center', va='center', fontsize=14, color=color)

# Right: Satisfiable
ax = axes[1]
im = ax.imshow(conflicts_s, cmap='RdYlGn_r', aspect='auto', vmin=0, vmax=1)
ax.set_xticks(range(len(clause_labels_sat)))
ax.set_xticklabels(clause_labels_sat, fontsize=11)
ax.set_yticks(range(len(assign_labels_s)))
ax.set_yticklabels(assign_labels_s, fontsize=11)
ax.set_xlabel('Clauses', fontsize=12)
ax.set_ylabel('Assignment (x₀, x₁)', fontsize=12)
ax.set_title('SATISFIABLE\nSome rows have no conflict', fontsize=12, color='green')

for i in range(conflicts_s.shape[0]):
    for j in range(conflicts_s.shape[1]):
        color = 'white' if conflicts_s[i, j] else 'black'
        text = '✗' if conflicts_s[i, j] else '✓'
        ax.text(j, i, text, ha='center', va='center', fontsize=14, color=color)

    # Highlight conflict-free rows
    if np.sum(conflicts_s[i]) == 0:
        ax.add_patch(plt.Rectangle((-0.5, i - 0.5), len(clause_labels_sat), 1,
                                    fill=False, edgecolor='green', linewidth=3))

plt.suptitle('Branch-SAT Duality: Assignment-Clause Conflict Maps',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_branch_duality.png', dpi=150, bbox_inches='tight')
print("Saved viz_branch_duality.png")
