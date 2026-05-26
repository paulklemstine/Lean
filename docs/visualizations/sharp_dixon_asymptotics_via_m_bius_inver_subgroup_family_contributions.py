"""
Visualization: Subgroup Family Contributions to Generation Probability

This script creates a stacked bar chart showing how different families of subgroups
(point stabilizers, alternating group, other) contribute to the non-generation
probability through the Möbius inversion formula. It demonstrates that point
stabilizers dominate, contributing the 1/n term in the asymptotic expansion.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from math import factorial
from fractions import Fraction
from collections import defaultdict


def compose(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def identity(n):
    return tuple(range(n))

def closure(generators, n):
    elements = {identity(n)}
    for g in generators:
        elements.add(g)
        elements.add(inverse(g))
    changed = True
    while changed:
        changed = False
        new = set()
        for a in elements:
            for b in elements:
                c = compose(a, b)
                if c not in elements and c not in new:
                    new.add(c)
                    changed = True
        elements |= new
    return frozenset(elements)

def enumerate_subgroups(n):
    all_perms = list(permutations(range(n)))
    subgroups = set()
    subgroups.add(frozenset([identity(n)]))
    for g in all_perms:
        subgroups.add(closure([g], n))
    for i, g in enumerate(all_perms):
        for h in all_perms[i:]:
            subgroups.add(closure([g, h], n))
    return subgroups

def compute_moebius(subgroups, n):
    sn = frozenset(permutations(range(n)))
    sorted_subs = sorted(subgroups, key=lambda s: -len(s))
    mu = {}
    for H in sorted_subs:
        if H == sn:
            mu[H] = 1
        else:
            mu[H] = -sum(mu[K] for K in sorted_subs if H < K and H.issubset(K))
    return mu


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

ns = [2, 3, 4, 5]
family_data = {n: {} for n in ns}

for n in ns:
    subgroups = enumerate_subgroups(n)
    mu = compute_moebius(subgroups, n)
    sn = frozenset(permutations(range(n)))
    total = factorial(n) ** 2

    contributions = defaultdict(lambda: Fraction(0))

    for H in subgroups:
        if H == sn:
            continue  # Skip S_n itself

        order = len(H)
        contrib = Fraction(mu[H] * order**2, total)

        # Classify
        if order == factorial(n - 1) and n > 1:
            is_stab = any(all(p[i] == i for p in H) for i in range(n))
            if is_stab:
                contributions["Point Stabilizers"] += contrib
            else:
                contributions["Other"] += contrib
        elif order == factorial(n) // 2 and n >= 2:
            contributions["Alternating Group"] += contrib
        else:
            contributions["Other"] += contrib

    family_data[n] = dict(contributions)

# Plot 1: Stacked bar chart of contributions to 1 - P_n
categories = ["Point Stabilizers", "Alternating Group", "Other"]
colors = ['#e74c3c', '#3498db', '#95a5a6']

x = np.arange(len(ns))
width = 0.6

bottoms = np.zeros(len(ns))
for cat, color in zip(categories, colors):
    vals = [-float(family_data[n].get(cat, Fraction(0))) for n in ns]
    bars = ax1.bar(x, vals, width, bottom=bottoms, label=cat, color=color, alpha=0.8)
    bottoms += np.array(vals)

# Add reference line for 1/n
ref_vals = [1/n for n in ns]
ax1.plot(x, ref_vals, 'k--', linewidth=2, label='$1/n$', zorder=5)

ax1.set_xticks(x)
ax1.set_xticklabels([f'$S_{n}$' for n in ns], fontsize=13)
ax1.set_ylabel('Contribution to $1 - P_n$', fontsize=13)
ax1.set_title('Obstruction Decomposition by Subgroup Family', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.2, axis='y')

# Plot 2: Ratio of point stabilizer contribution to 1/n
stab_ratios = []
for n in ns:
    stab_contrib = -float(family_data[n].get("Point Stabilizers", Fraction(0)))
    stab_ratios.append(stab_contrib / (1/n) if n > 0 else 0)

ax2.bar(x, stab_ratios, width, color='#e74c3c', alpha=0.8)
ax2.axhline(y=1.0, color='black', linestyle='--', linewidth=1.5, label='Ratio = 1')
ax2.set_xticks(x)
ax2.set_xticklabels([f'$S_{n}$' for n in ns], fontsize=13)
ax2.set_ylabel('Stabilizer contribution / $(1/n)$', fontsize=13)
ax2.set_title('Point Stabilizer Dominance', fontsize=14)
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.2, axis='y')

for i, ratio in enumerate(stab_ratios):
    ax2.text(i, ratio + 0.02, f'{ratio:.3f}', ha='center', va='bottom', fontsize=11, fontweight='bold')

plt.tight_layout()
plt.savefig('subgroup_contributions.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved: subgroup_contributions.png")
