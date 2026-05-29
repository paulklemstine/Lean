#!/usr/bin/env python3
"""
Visualization: The Unbounded Completion Pipeline

Shows the logical flow of the main theorem as a pipeline diagram:
Stabilization → Global Joinability → Local Confluence → Confluence → Unique NFs → Decidable Word Problem
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np

fig, ax = plt.subplots(figsize=(16, 9))
ax.set_xlim(-0.5, 10.5)
ax.set_ylim(-1, 7)
ax.axis('off')

# Title
ax.text(5.25, 6.5, "The Unbounded Completion Pipeline",
        fontsize=20, fontweight='bold', ha='center', va='center',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='#E3F2FD', edgecolor='#1565C0', linewidth=2))

# Pipeline stages
stages = [
    (0.5, 4.5, "INPUTS", "#FFF3E0", "#E65100", [
        "Terminating system E",
        "Stabilization at N₀",
        "All CPs joinable at N₀"
    ]),
    (3.0, 4.5, "STEP 1", "#E8F5E9", "#2E7D32", [
        "Global Joinability",
        "∀N: AllCPsJoinable(E,N)",
        "[stabilization_implies_",
        " global_joinability]"
    ]),
    (5.5, 4.5, "STEP 2", "#E3F2FD", "#1565C0", [
        "Local Confluence",
        "∀t,u,v: t→u ∧ t→v",
        "  ⟹ ∃w: u→*w ∧ v→*w",
        "[globalLocalConfluence_",
        " of_allJoinable]"
    ]),
    (8.0, 4.5, "STEP 3", "#F3E5F5", "#7B1FA2", [
        "Global Confluence",
        "∀t,u,v: t→*u ∧ t→*v",
        "  ⟹ ∃w: u→*w ∧ v→*w",
        "[newman_lemma]"
    ]),
]

outputs = [
    (3.0, 1.2, "OUTPUT 1", "#FFEBEE", "#C62828", [
        "Unique Normal Forms",
        "∀t: ∃!n: nf(n) ∧ t→*n",
        "[master_pipeline]"
    ]),
    (6.5, 1.2, "OUTPUT 2", "#FFF8E1", "#F57F17", [
        "Decidable Word Problem",
        "nf(s)=nf(t) ⟺ s≡t",
        "[ho_word_problem_",
        " decidable]"
    ]),
]

def draw_box(ax, x, y, title, bg_color, border_color, lines, width=2.2, height=2.0):
    rect = mpatches.FancyBboxPatch(
        (x - width/2, y - height/2), width, height,
        boxstyle="round,pad=0.1",
        facecolor=bg_color, edgecolor=border_color, linewidth=2
    )
    ax.add_patch(rect)
    ax.text(x, y + height/2 - 0.25, title,
            fontsize=10, fontweight='bold', ha='center', va='center',
            color=border_color)
    for i, line in enumerate(lines):
        ax.text(x, y + height/2 - 0.55 - i * 0.3, line,
                fontsize=8, ha='center', va='center',
                fontfamily='monospace')

# Draw stages
for x, y, title, bg, border, lines in stages:
    draw_box(ax, x, y, title, bg, border, lines)

# Draw outputs  
for x, y, title, bg, border, lines in outputs:
    draw_box(ax, x, y, title, bg, border, lines)

# Draw arrows between stages
arrow_style = dict(arrowstyle='->', color='#424242', lw=2.5,
                   connectionstyle='arc3,rad=0')

for i in range(len(stages) - 1):
    x1 = stages[i][0] + 1.1
    x2 = stages[i+1][0] - 1.1
    y = stages[i][1]
    ax.annotate('', xy=(x2, y), xytext=(x1, y), arrowprops=arrow_style)

# Arrows from Step 3 to outputs
ax.annotate('', xy=(3.0, 2.2), xytext=(8.0, 3.5),
            arrowprops=dict(arrowstyle='->', color='#C62828', lw=2,
                           connectionstyle='arc3,rad=0.3'))

ax.annotate('', xy=(6.5, 2.2), xytext=(8.0, 3.5),
            arrowprops=dict(arrowstyle='->', color='#F57F17', lw=2,
                           connectionstyle='arc3,rad=-0.2'))

# Add "+" between termination and confluence for Newman's lemma
ax.text(8.0, 3.3, "+ Termination", fontsize=8, ha='center',
        style='italic', color='#7B1FA2')

# Key insight box
ax.text(5.25, -0.3,
        "KEY INSIGHT: Stabilization at a finite level N₀ reduces the infinite\n"
        "critical pair enumeration to a finite check, making the procedure effective.",
        fontsize=11, ha='center', va='center', style='italic',
        bbox=dict(boxstyle='round,pad=0.4', facecolor='lightyellow', 
                  edgecolor='#FF6F00', linewidth=1.5))

plt.tight_layout()
plt.savefig('pipeline_diagram.png', dpi=150, bbox_inches='tight')
print("Saved pipeline_diagram.png")
