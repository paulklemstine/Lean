"""
Double Coset Decomposition Visualization

Shows how the double coset HgH decomposes into left cosets of H
for different group elements g in S_4. The number of cosets equals
the conjugation index, connecting covering theory to Hecke algebras.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
from matplotlib.patches import FancyBboxPatch
import matplotlib.colors as mcolors


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

def left_coset(g, H):
    return frozenset(compose(g, h) for h in H)

def double_coset(H, g):
    result = set()
    for h1 in H:
        for h2 in H:
            result.add(compose(compose(h1, g), h2))
    return frozenset(result)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0

def perm_to_str(p):
    """Convert permutation to cycle notation string."""
    n = len(p)
    seen = set()
    cycles = []
    for i in range(n):
        if i not in seen and p[i] != i:
            cycle = []
            j = i
            while j not in seen:
                seen.add(j)
                cycle.append(j)
                j = p[j]
            if len(cycle) > 1:
                cycles.append(cycle)
    if not cycles:
        return "e"
    return "".join(f"({''.join(str(x) for x in c)})" for c in cycles)


n = 4
G = list(permutations(range(n)))
e = identity(n)

# Choose H = <(01)> (non-normal, order 2)
H = generate_subgroup([(1, 0, 2, 3)], n)

# Get representatives of different conjugation indices
representatives = {}
for g in G:
    ci = conjugation_index(H, g, n)
    if ci not in representatives:
        representatives[ci] = g

# Sort by conjugation index
sorted_reps = sorted(representatives.items())

fig, axes = plt.subplots(1, len(sorted_reps), figsize=(5 * len(sorted_reps), 8))
if len(sorted_reps) == 1:
    axes = [axes]

colors = plt.cm.Set2(np.linspace(0, 1, 8))

for plot_idx, (ci, g) in enumerate(sorted_reps):
    ax = axes[plot_idx]

    dc = double_coset(H, g)

    # Decompose into left cosets
    remaining = set(dc)
    cosets = []
    while remaining:
        rep = min(remaining)  # deterministic choice
        coset = left_coset(rep, H)
        cosets.append((rep, coset))
        remaining -= coset

    ax.set_xlim(-0.5, max(len(cosets), 1) + 0.5)
    ax.set_ylim(-0.5, len(H) + 1.5)
    ax.set_title(f"$Hg H$ for $g = {perm_to_str(g)}$\n"
                 f"Conj. Index = {ci}, |HgH| = {len(dc)}",
                 fontsize=12, fontweight='bold')

    for coset_idx, (rep, coset) in enumerate(cosets):
        x = coset_idx + 0.5
        sorted_elems = sorted(coset)

        # Draw coset box
        rect = FancyBboxPatch((x - 0.4, 0), 0.8, len(sorted_elems) + 0.5,
                              boxstyle="round,pad=0.1",
                              facecolor=colors[coset_idx % len(colors)],
                              edgecolor='black', linewidth=1.5, alpha=0.3)
        ax.add_patch(rect)

        # Label each element
        for elem_idx, elem in enumerate(sorted_elems):
            y = elem_idx + 0.5
            label = perm_to_str(elem)
            ax.text(x, y, label, ha='center', va='center', fontsize=8,
                   fontfamily='monospace')

        # Coset label
        ax.text(x, len(sorted_elems) + 0.3, f"{perm_to_str(rep)}·H",
                ha='center', va='bottom', fontsize=9, fontweight='bold',
                color=colors[coset_idx % len(colors)] * 0.6)

    ax.set_xlabel("Left Cosets", fontsize=11)
    if plot_idx == 0:
        ax.set_ylabel("Elements", fontsize=11)
    ax.set_xticks([])
    ax.set_yticks([])

fig.suptitle(r"Double Coset Decomposition $HgH$ in $S_4$, $H = \langle(01)\rangle$",
             fontsize=16, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("double_coset.png", dpi=150, bbox_inches='tight')
print("Saved double_coset.png")
