"""
Product Covering Bound Verification

Scatter plot comparing actual covering numbers C(A·A) vs the
theoretical bound C(A)² · L for random subsets of S_4 with
various subgroup choices. Points below the diagonal confirm
the conjecture; the gap reveals tightness.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import permutations
import random

random.seed(42)


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
    n = len(g)
    return frozenset(compose(g, h) for h in H)

def conjugation_index(H, g, n):
    g_inv = inverse(g)
    conj_H = frozenset(compose(compose(g_inv, h), g) for h in H)
    inter = H & conj_H
    return len(H) // len(inter) if inter else 0

def greedy_covering(A, H, G, n):
    if not A:
        return 0, []
    coset_map = {}
    seen = set()
    for g in G:
        c = left_coset(g, H)
        if c not in seen:
            coset_map[g] = c
            seen.add(c)
    uncov = set(A)
    cover = []
    while uncov:
        best_g, best_n = None, 0
        for g, c in coset_map.items():
            ct = len(uncov & c)
            if ct > best_n:
                best_n = ct
                best_g = g
        if best_g is None or best_n == 0:
            break
        cover.append(best_g)
        uncov -= coset_map[best_g]
    return len(cover), cover


n = 4
G = list(permutations(range(n)))

subgroup_configs = [
    (r"$\langle(01)\rangle$ (non-normal)", [(1, 0, 2, 3)], '#e74c3c'),
    (r"$\langle(0123)\rangle$", [(1, 2, 3, 0)], '#3498db'),
    (r"$V_4$ (normal)", [(1, 0, 3, 2), (2, 3, 0, 1)], '#2ecc71'),
]

fig, ax = plt.subplots(1, 1, figsize=(10, 8))

max_bound = 0

for name, gens, color in subgroup_configs:
    H = generate_subgroup(gens, n)

    actuals = []
    bounds = []

    for trial in range(100):
        k = random.randint(2, len(G) // 2)
        A = frozenset(random.sample(G, k))

        C_A, T_A = greedy_covering(A, H, G, n)
        if C_A == 0:
            continue

        L = max(conjugation_index(H, t, n) for t in T_A)
        AA = frozenset(compose(a, b) for a in A for b in A)
        C_AA, _ = greedy_covering(AA, H, G, n)

        bound = C_A ** 2 * L
        actuals.append(C_AA)
        bounds.append(bound)
        max_bound = max(max_bound, bound, C_AA)

    ax.scatter(bounds, actuals, alpha=0.5, s=40, color=color,
              edgecolors='black', linewidth=0.3, label=name, zorder=3)

# Diagonal line
diag_max = max_bound + 2
ax.plot([0, diag_max], [0, diag_max], 'k--', alpha=0.4, linewidth=1.5,
        label=r'$C(A\cdot A) = C^2 \cdot L$')

# Fill the "conjecture holds" region
ax.fill_between([0, diag_max], [0, diag_max], [0, 0], alpha=0.05,
                color='green', zorder=1)
ax.fill_between([0, diag_max], [diag_max, diag_max], [0, diag_max],
                alpha=0.05, color='red', zorder=1)

ax.set_xlabel(r"Bound $C(A)^2 \cdot L$", fontsize=14)
ax.set_ylabel(r"Actual $C(A \cdot A)$", fontsize=14)
ax.set_title(r"Product Covering: $C(A \cdot A)$ vs $C(A)^2 \cdot L$ in $S_4$",
             fontsize=16, fontweight='bold')
ax.legend(fontsize=11, loc='upper left')
ax.set_aspect('equal')
ax.grid(True, alpha=0.3)

# Annotation
ax.annotate("Conjecture holds\n(below diagonal)",
            xy=(diag_max * 0.7, diag_max * 0.3),
            fontsize=12, color='#27ae60', ha='center',
            fontweight='bold')

plt.tight_layout()
plt.savefig("covering_bound.png", dpi=150, bbox_inches='tight')
print("Saved covering_bound.png")
