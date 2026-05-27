#!/usr/bin/env python3
"""
Visualization: Termination Heatmap

Shows the distPotential measure decrease for each rewrite rule,
demonstrating that every rule strictly reduces the interpretation.

Uses matplotlib to create a heatmap saved as PNG.
"""

import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')
import numpy as np

# Rule name, LHS formula, RHS formula, decrease formula
rules = [
    ("1: A·(v⊕w)", "I(A)·(I(v)+I(w)+1)", "I(A)·I(v)+I(A)·I(w)+1", "I(A)−1"),
    ("2: (A⊞B)·v", "(I(A)+I(B)+1)·I(v)", "I(A)·I(v)+I(B)·I(v)+1", "I(v)−1"),
    ("3: (a⊙A)·v", "(I(a)·I(A)+1)·I(v)", "I(a)·I(A)·I(v)+1", "I(v)−1"),
    ("4: a•(v⊕w)", "I(a)·(I(v)+I(w)+1)+1", "I(a)·I(v)+I(a)·I(w)+3", "I(a)−2"),
    ("5: a⊙(A⊞B)", "I(a)·(I(A)+I(B)+1)+1", "I(a)·I(A)+I(a)·I(B)+3", "I(a)−2"),
    ("6: ⟨v⊕w,u⟩", "(I(v)+I(w)+1)·I(u)", "I(v)·I(u)+I(w)·I(u)+1", "I(u)−1"),
    ("7: ⟨u,v⊕w⟩", "I(u)·(I(v)+I(w)+1)", "I(u)·I(v)+I(u)·I(w)+1", "I(u)−1"),
    ("8: ⟨a•v,w⟩", "(I(a)·I(v)+1)·I(w)", "I(a)·I(v)·I(w)", "I(w)"),
    ("9: a·(b+c)", "I(a)·(I(b)+I(c)+1)", "I(a)·I(b)+I(a)·I(c)+1", "I(a)−1"),
]

# Compute actual decreases for sample values
# Variables have I = 3
def compute_decrease(rule_idx):
    I = 3  # Variable interpretation
    decreases = []
    for v1 in [3, 7, 10]:
        for v2 in [3, 7, 10]:
            for v3 in [3, 7, 10]:
                if rule_idx == 0:  # A·(v⊕w)
                    lhs = v1 * (v2 + v3 + 1)
                    rhs = v1*v2 + v1*v3 + 1
                elif rule_idx == 1:  # (A⊞B)·v
                    lhs = (v1 + v2 + 1) * v3
                    rhs = v1*v3 + v2*v3 + 1
                elif rule_idx == 2:  # (a⊙A)·v
                    lhs = (v1*v2 + 1) * v3
                    rhs = v1*v2*v3 + 1
                elif rule_idx == 3:  # a•(v⊕w)
                    lhs = v1*(v2+v3+1) + 1
                    rhs = v1*v2+1 + v1*v3+1 + 1
                elif rule_idx == 4:  # a⊙(A⊞B)
                    lhs = v1*(v2+v3+1) + 1
                    rhs = v1*v2+1 + v1*v3+1 + 1
                elif rule_idx == 5:  # ⟨v⊕w,u⟩
                    lhs = (v1+v2+1) * v3
                    rhs = v1*v3 + v2*v3 + 1
                elif rule_idx == 6:  # ⟨u,v⊕w⟩
                    lhs = v1*(v2+v3+1)
                    rhs = v1*v2 + v1*v3 + 1
                elif rule_idx == 7:  # ⟨a•v,w⟩
                    lhs = (v1*v2+1) * v3
                    rhs = v1*v2*v3
                elif rule_idx == 8:  # a·(b+c)
                    lhs = v1*(v2+v3+1)
                    rhs = v1*v2 + v1*v3 + 1
                decreases.append(lhs - rhs)
    return min(decreases), max(decreases), np.mean(decreases)

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 7), gridspec_kw={'width_ratios': [2, 1]})
fig.suptitle("Polynomial Interpretation: Every Rule Strictly Decreases distPotential",
             fontsize=13, fontweight='bold')

# Left: decrease formula table
rule_names = [r[0] for r in rules]
decrease_formulas = [r[3] for r in rules]
min_decreases = []
for i in range(9):
    mn, mx, avg = compute_decrease(i)
    min_decreases.append(mn)

# Bar chart of minimum decreases
colors = ['#4CAF50' if d >= 2 else '#FF9800' for d in min_decreases]
bars = ax1.barh(range(9), min_decreases, color=colors, edgecolor='black', height=0.6)
ax1.set_yticks(range(9))
ax1.set_yticklabels([f"{r[0]}" for r in rules], fontsize=9)
ax1.set_xlabel("Minimum Decrease (LHS − RHS)", fontsize=10)
ax1.set_title("Minimum Measure Decrease per Rule", fontsize=11)
ax1.invert_yaxis()

for i, (bar, formula) in enumerate(zip(bars, decrease_formulas)):
    ax1.text(bar.get_width() + 0.2, bar.get_y() + bar.get_height()/2,
             f"Δ = {formula} ≥ {min_decreases[i]}",
             va='center', fontsize=8, color='darkblue')

# Right: heatmap of decrease for different variable values
vals = [3, 5, 7, 10]
heatmap_data = np.zeros((9, len(vals)))
for i in range(9):
    for j, v in enumerate(vals):
        # Use v for all variables
        if i in [0, 6, 8]:  # I(A)-1 type
            heatmap_data[i, j] = v - 1
        elif i in [1, 2, 5]:  # I(v)-1 type
            heatmap_data[i, j] = v - 1
        elif i in [3, 4]:  # I(a)-2 type
            heatmap_data[i, j] = v - 2
        elif i == 7:  # I(w) type
            heatmap_data[i, j] = v

im = ax2.imshow(heatmap_data, cmap='YlGn', aspect='auto', vmin=0)
ax2.set_xticks(range(len(vals)))
ax2.set_xticklabels([f"I={v}" for v in vals])
ax2.set_yticks(range(9))
ax2.set_yticklabels([f"R{i+1}" for i in range(9)])
ax2.set_title("Decrease by Variable Value", fontsize=11)
ax2.set_xlabel("Subterm Interpretation Value")

# Annotate cells
for i in range(9):
    for j in range(len(vals)):
        ax2.text(j, i, f"{int(heatmap_data[i,j])}", ha='center', va='center', fontsize=9,
                color='white' if heatmap_data[i,j] > 4 else 'black')

plt.colorbar(im, ax=ax2, label="Decrease Amount")
plt.tight_layout()
plt.savefig("viz_termination_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved viz_termination_heatmap.png")
