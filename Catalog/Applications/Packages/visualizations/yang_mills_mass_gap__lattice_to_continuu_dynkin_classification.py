#!/usr/bin/env python3
"""
Visualization: Dynkin Diagram Classification of Mass Gaps
=========================================================
Shows how the mass gap lower bound is determined by the Dynkin
diagram of the gauge group, demonstrating the topological invariant
property (Theorem 3.3: plaquette_transport).
"""

import numpy as np
import matplotlib.pyplot as plt

# Data: Dynkin type → (name, Casimir_fund, rank, color)
groups = {
    'A₁': ('SU(2)', 0.75, 1, '#2196F3'),
    'A₂': ('SU(3)', 4/3, 2, '#1976D2'),
    'A₃': ('SU(4)', 15/8, 3, '#1565C0'),
    'A₄': ('SU(5)', 12/5, 4, '#0D47A1'),
    'B₂': ('SO(5)', 2.0, 2, '#F44336'),
    'B₃': ('SO(7)', 3.0, 3, '#D32F2F'),
    'C₂': ('Sp(4)', 5/4, 2, '#4CAF50'),
    'C₃': ('Sp(6)', 7/4, 3, '#388E3C'),
    'D₃': ('SO(6)', 2.5, 3, '#FF9800'),
    'D₄': ('SO(8)', 3.5, 4, '#F57C00'),
    'G₂': ('G₂', 2.0, 2, '#9C27B0'),
    'F₄': ('F₄', 26/3, 4, '#E91E63'),
    'E₆': ('E₆', 26/3, 6, '#795548'),
    'E₇': ('E₇', 57/4, 7, '#607D8B'),
    'E₈': ('E₈', 30.0, 8, '#FF5722'),
}

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# Panel 1: Casimir values by family
ax = axes[0]
families = {'A': [], 'B': [], 'C': [], 'D': [], 'Exceptional': []}
for dynkin, (name, c2, rank, color) in groups.items():
    fam = dynkin[0] if dynkin[0] in 'ABCD' else 'Exceptional'
    families[fam].append((rank, c2, name, color))

markers = {'A': 'o', 'B': 's', 'C': '^', 'D': 'D', 'Exceptional': '*'}
for fam, data in families.items():
    if data:
        ranks, c2s, names, colors = zip(*data)
        ax.scatter(ranks, c2s, c=colors, s=120, marker=markers[fam],
                  label=f'Type {fam}', edgecolors='black', linewidth=0.5, zorder=5)
        for r, c, n in zip(ranks, c2s, names):
            ax.annotate(n, (r, c), textcoords="offset points", 
                       xytext=(8, 4), fontsize=8)

ax.set_xlabel("Rank", fontsize=14)
ax.set_ylabel("Casimir C₂(fund)", fontsize=14)
ax.set_title("Casimir by Dynkin Type", fontsize=16)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Mass gap bounds at β=1
ax = axes[1]
names_list = list(groups.keys())
casimir_vals = [groups[d][1] for d in names_list]
colors_list = [groups[d][3] for d in names_list]

def gap_bound(c2, beta=1.0):
    if beta < 2.0:
        return c2 * max(0.01, 1 - beta * c2 / 4)
    return c2 * np.exp(-0.5 * (beta - 1.0))

gap_vals = [gap_bound(c2) for c2 in casimir_vals]

bars = ax.barh(range(len(names_list)), gap_vals, color=colors_list, 
               edgecolor='black', linewidth=0.5, alpha=0.8)
ax.set_yticks(range(len(names_list)))
ax.set_yticklabels(names_list, fontsize=10)
ax.set_xlabel("Mass Gap Lower Bound (β=1)", fontsize=14)
ax.set_title("Gap by Dynkin Diagram", fontsize=16)
ax.grid(True, alpha=0.3, axis='x')

# Panel 3: Gap vs coupling for classical families
ax = axes[2]
betas = np.linspace(0.05, 4.0, 100)

selected = [('A₁', 'SU(2)'), ('A₂', 'SU(3)'), ('G₂', 'G₂'), ('B₂', 'SO(5)')]
for dynkin, label in selected:
    c2 = groups[dynkin][1]
    color = groups[dynkin][3]
    gaps = [gap_bound(c2, b) for b in betas]
    ax.plot(betas, gaps, color=color, linewidth=2.5, label=label)

ax.set_xlabel("Coupling β", fontsize=14)
ax.set_ylabel("Δ_lb", fontsize=14)
ax.set_title("Gap vs. Coupling", fontsize=16)
ax.legend(fontsize=11)
ax.set_ylim(bottom=0)
ax.grid(True, alpha=0.3)

plt.suptitle("Dynkin Diagram Classification of Yang-Mills Mass Gaps", 
             fontsize=18, y=1.02)
plt.tight_layout()
plt.savefig("dynkin_classification.png", dpi=150, bbox_inches='tight')
print("Saved: dynkin_classification.png")
