#!/usr/bin/env python3
"""
Visualization: TPE Invariance of Overlap Invariants

Shows that all overlap invariants (class count, degree, complexity,
signature) are preserved under Tropical Projective Equivalence.
Generates random TPE transformations and plots the invariants
before and after, demonstrating perfect agreement.

This illustrates the main theorem: overlap structure is intrinsic
to the tropical projective equivalence class, not an artifact of
a particular representation.
"""

import matplotlib.pyplot as plt
import numpy as np
import random
from collections import defaultdict


def variation_support(f, v0):
    f_v0 = f.get(v0, 0)
    return frozenset(v for v in f if f[v] != f_v0)


def apply_tpe(functions, sigma, constants):
    n = len(functions)
    vertices = set()
    for f in functions:
        vertices |= set(f.keys())
    result = [None] * n
    for i in range(n):
        new_f = {}
        for v in vertices:
            new_f[v] = functions[i].get(v, 0) + constants[i]
        result[sigma[i]] = new_f
    return result


def overlap_classes_count(family):
    n = len(family)
    if n == 0:
        return 0
    parent = list(range(n))
    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x
    def union(x, y):
        px, py = find(x), find(y)
        if px != py:
            parent[px] = py
    for i in range(n):
        for j in range(i + 1, n):
            if family[i] & family[j]:
                union(i, j)
    return len(set(find(i) for i in range(n)))


def overlap_degree(family):
    n = len(family)
    return sum(1 for i in range(n) for j in range(i+1, n) if family[i] & family[j])


def overlap_complexity(family):
    n = len(family)
    return sum(len(family[i] & family[j]) for i in range(n) for j in range(i+1, n))


def overlap_signature(family):
    n = len(family)
    sig = []
    for i in range(n):
        for j in range(i + 1, n):
            s = len(family[i] & family[j])
            if s > 0:
                sig.append(s)
    return tuple(sorted(sig))


# ─────────────────────────────────────────────────────────────────────
# Generate test data
# ─────────────────────────────────────────────────────────────────────

random.seed(42)
np.random.seed(42)

num_trials = 50
num_functions = 5
num_vertices = 8
v0 = 0

# Generate a base function family
base_functions = []
for _ in range(num_functions):
    f = {v: random.randint(-10, 10) for v in range(num_vertices)}
    base_functions.append(f)

# Record invariants for each random TPE
results = {
    'class_count_before': [],
    'class_count_after': [],
    'degree_before': [],
    'degree_after': [],
    'complexity_before': [],
    'complexity_after': [],
    'signature_match': [],
}

for trial in range(num_trials):
    # Random TPE
    sigma = list(range(num_functions))
    random.shuffle(sigma)
    constants = [random.randint(-50, 50) for _ in range(num_functions)]

    f2 = apply_tpe(base_functions, sigma, constants)

    vsf1 = [variation_support(f, v0) for f in base_functions]
    vsf2 = [variation_support(f, v0) for f in f2]

    cc1 = overlap_classes_count(vsf1)
    cc2 = overlap_classes_count(vsf2)
    od1 = overlap_degree(vsf1)
    od2 = overlap_degree(vsf2)
    oc1 = overlap_complexity(vsf1)
    oc2 = overlap_complexity(vsf2)
    sig1 = overlap_signature(vsf1)
    sig2 = overlap_signature(vsf2)

    results['class_count_before'].append(cc1)
    results['class_count_after'].append(cc2)
    results['degree_before'].append(od1)
    results['degree_after'].append(od2)
    results['complexity_before'].append(oc1)
    results['complexity_after'].append(oc2)
    results['signature_match'].append(sig1 == sig2)


# ─────────────────────────────────────────────────────────────────────
# Plot
# ─────────────────────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Plot 1: Class count
ax = axes[0, 0]
ax.scatter(results['class_count_before'], results['class_count_after'],
           c='steelblue', s=80, alpha=0.7, edgecolors='navy', zorder=2)
max_val = max(max(results['class_count_before']), max(results['class_count_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Class Count', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 2: Overlap degree
ax = axes[0, 1]
ax.scatter(results['degree_before'], results['degree_after'],
           c='coral', s=80, alpha=0.7, edgecolors='darkred', zorder=2)
max_val = max(max(results['degree_before']), max(results['degree_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Degree', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 3: Overlap complexity
ax = axes[1, 0]
ax.scatter(results['complexity_before'], results['complexity_after'],
           c='seagreen', s=80, alpha=0.7, edgecolors='darkgreen', zorder=2)
max_val = max(max(results['complexity_before']), max(results['complexity_after'])) + 1
ax.plot([0, max_val], [0, max_val], 'r--', linewidth=2, label='y = x (invariance)', zorder=1)
ax.set_xlabel('Before TPE', fontsize=11)
ax.set_ylabel('After TPE', fontsize=11)
ax.set_title('Overlap Complexity', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.set_aspect('equal')

# Plot 4: Summary bar chart
ax = axes[1, 1]
invariants = ['Class\nCount', 'Overlap\nDegree', 'Overlap\nComplexity', 'Overlap\nSignature']
matches = [
    sum(a == b for a, b in zip(results['class_count_before'], results['class_count_after'])),
    sum(a == b for a, b in zip(results['degree_before'], results['degree_after'])),
    sum(a == b for a, b in zip(results['complexity_before'], results['complexity_after'])),
    sum(results['signature_match']),
]
colors = ['steelblue', 'coral', 'seagreen', 'mediumpurple']
bars = ax.bar(invariants, matches, color=colors, edgecolor='black', linewidth=1.5)
ax.set_ylabel(f'Matches (out of {num_trials})', fontsize=11)
ax.set_title('TPE Invariance Verification', fontsize=13, fontweight='bold')
ax.set_ylim(0, num_trials * 1.15)
for bar, val in zip(bars, matches):
    ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.5,
            f'{val}/{num_trials}', ha='center', va='bottom', fontweight='bold', fontsize=11)

fig.suptitle('Tropical Projective Equivalence Preserves All Overlap Invariants\n'
             f'({num_trials} random TPE transformations on a 5-function family)',
             fontsize=15, fontweight='bold', y=1.02)

plt.tight_layout()
plt.savefig("viz_tpe_invariance.png", dpi=150, bbox_inches='tight')
print("Saved viz_tpe_invariance.png")
