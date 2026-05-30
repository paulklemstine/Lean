"""
Conjugation Index Heatmap for S_4

Visualizes the conjugation index [H : H ∩ g⁻¹Hg] as a heatmap over
all pairs (H, g) in the symmetric group S_4. Reveals the algebraic
structure: normal subgroups have uniformly 1 index, while non-normal
subgroups show rich variation reflecting the conjugation geometry.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    inv = [0] * len(p)
    for i, v in enumerate(p):
        inv[v] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def generate_subgroup(gens, n):
    e = identity(n)
    sg = {e}
    q = list(gens)
    while q:
        g = q.pop()
        if g not in sg:
            sg.add(g)
            for h in list(sg):
                for x in [compose(g, h), compose(h, g), inverse(g)]:
                    if x not in sg:
                        q.append(x)
    return frozenset(sg)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0


n = 4
G = list(permutations(range(n)))

# Define subgroups of S_4
subgroup_defs = {
    r"$\langle(01)\rangle$": [(1, 0, 2, 3)],
    r"$\langle(0123)\rangle$": [(1, 2, 3, 0)],
    r"$V_4$ (normal)": [(1, 0, 3, 2), (2, 3, 0, 1)],
    r"$D_4$": [(1, 2, 3, 0), (1, 0, 3, 2)],
    r"$A_4$ (normal)": [(1, 2, 0, 3), (0, 2, 3, 1)],
    r"$S_3$": [(1, 2, 0, 3), (1, 0, 2, 3)],
}

subgroups = {}
for name, gens in subgroup_defs.items():
    subgroups[name] = generate_subgroup(gens, n)

# Compute conjugation index distribution for each subgroup
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle(r"Conjugation Index $[H : H \cap g^{-1}Hg]$ in $S_4$",
             fontsize=16, fontweight='bold')

for idx, (name, H) in enumerate(subgroups.items()):
    ax = axes[idx // 3][idx % 3]

    # Compute index for each g
    indices = [conjugation_index(H, g, n) for g in G]

    # Group by conjugacy class for visualization
    # Sort G elements by cycle type
    def cycle_type(p):
        seen = set()
        cycles = []
        for i in range(len(p)):
            if i not in seen:
                cycle = []
                j = i
                while j not in seen:
                    seen.add(j)
                    cycle.append(j)
                    j = p[j]
                cycles.append(len(cycle))
        return tuple(sorted(cycles, reverse=True))

    # Sort by cycle type
    sorted_pairs = sorted(zip(G, indices), key=lambda x: cycle_type(x[0]))
    sorted_indices = [p[1] for p in sorted_pairs]

    # Create bar chart of index values
    unique_vals = sorted(set(indices))
    counts = {v: indices.count(v) for v in unique_vals}

    colors = ['#2ecc71' if v == 1 else '#e74c3c' if v > 1 else '#3498db'
              for v in unique_vals]
    ax.bar([str(v) for v in unique_vals],
           [counts[v] for v in unique_vals],
           color=colors, edgecolor='black', linewidth=0.5)

    ax.set_title(f"{name}\n|H| = {len(H)}", fontsize=12)
    ax.set_xlabel("Conjugation Index", fontsize=10)
    ax.set_ylabel("# of group elements", fontsize=10)

    max_idx = max(indices)
    ax.annotate(f"max L = {max_idx}",
                xy=(0.95, 0.95), xycoords='axes fraction',
                ha='right', va='top',
                fontsize=11, fontweight='bold',
                color='#e74c3c' if max_idx > 1 else '#2ecc71',
                bbox=dict(boxstyle='round,pad=0.3', facecolor='white',
                         edgecolor='gray', alpha=0.8))

plt.tight_layout()
plt.savefig("conjugation_heatmap.png", dpi=150, bbox_inches='tight')
print("Saved conjugation_heatmap.png")
