"""
Visualization: Shadow Structure for 2D Lower-Closed Sets

Shows the geometric structure of shadows on example lower-closed sets
in ℕ², highlighting the relationship between set shape, shadow, and
inner boundary. Self-contained — no local imports.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product as cartesian_product


def one_shadow(S, n):
    shadow = set()
    for x in S:
        for i in range(n):
            if x[i] > 0:
                y = list(x)
                y[i] -= 1
                shadow.add(tuple(y))
    return shadow

def inner_boundary(S, n):
    bdy = set()
    for x in S:
        for i in range(n):
            if x[i] > 0:
                y = list(x)
                y[i] -= 1
                if tuple(y) not in S:
                    bdy.add(x)
                    break
    return bdy


fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle("Shadow Geometry of 2D Lower-Closed Sets",
             fontsize=15, fontweight='bold')

# Example sets
examples = [
    ("Staircase (3,2,1)",
     {(i, j) for i in range(3) for j in range(3-i)}),
    ("Rectangle 4×3",
     {(i, j) for i in range(4) for j in range(3)}),
    ("L-shape",
     {(i, j) for i in range(4) for j in range(2)} |
     {(0, 2), (0, 3), (1, 2)}),
    ("Triangle Δ(2,4)",
     {(i, j) for i in range(5) for j in range(5-i)}),
    ("Thick L",
     {(i, j) for i in range(5) for j in range(3)} |
     {(i, j) for i in range(3) for j in range(3, 5)}),
    ("Single column",
     {(0, j) for j in range(8)}),
]

for idx, (name, S) in enumerate(examples):
    ax = axes[idx // 3][idx % 3]
    n = 2

    sh = one_shadow(S, n)
    bdy = inner_boundary(S, n)

    # Classify points
    interior = S - bdy - sh
    shadow_in_S = sh & S
    shadow_out = sh - S
    bdy_pts = bdy

    max_x = max(p[0] for p in S | sh) + 1
    max_y = max(p[1] for p in S | sh) + 1

    # Draw grid
    for i in range(max_x + 1):
        for j in range(max_y + 1):
            ax.plot(i, j, '.', color='lightgray', markersize=3)

    # Draw points by category
    for p in shadow_out:
        ax.plot(p[0], p[1], 'D', color='orange', markersize=7, alpha=0.8)

    for p in shadow_in_S - bdy_pts:
        ax.plot(p[0], p[1], 'o', color='steelblue', markersize=8, alpha=0.7)

    for p in interior:
        ax.plot(p[0], p[1], 'o', color='lightsteelblue', markersize=8, alpha=0.5)

    for p in bdy_pts:
        ax.plot(p[0], p[1], 's', color='crimson', markersize=9, alpha=0.8)

    ax.set_title(f"{name}\n|S|={len(S)}, |Sh₁|={len(sh)}, |∂S|={len(bdy)}",
                 fontsize=10)
    ax.set_xlim(-0.5, max_x + 0.5)
    ax.set_ylim(-0.5, max_y + 0.5)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.15)
    ax.set_xlabel("x₁", fontsize=9)
    ax.set_ylabel("x₂", fontsize=9)

# Legend
handles = [
    mpatches.Patch(color='lightsteelblue', label='Interior (S \\ ∂S \\ Sh₁)', alpha=0.5),
    mpatches.Patch(color='steelblue', label='Shadow ∩ S', alpha=0.7),
    mpatches.Patch(color='crimson', label='Inner boundary ∂S', alpha=0.8),
    mpatches.Patch(color='orange', label='Shadow outside S', alpha=0.8),
]
fig.legend(handles=handles, loc='lower center', ncol=4, fontsize=10,
           bbox_to_anchor=(0.5, -0.02))

plt.tight_layout(rect=[0, 0.03, 1, 0.95])
plt.savefig("shadow_2d_sets.png", dpi=150, bbox_inches='tight')
print("Saved shadow_2d_sets.png")
