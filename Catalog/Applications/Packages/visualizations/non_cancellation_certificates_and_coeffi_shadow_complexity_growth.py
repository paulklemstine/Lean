#!/usr/bin/env python3
"""
Visualization 3: Shadow Complexity Growth

Plots shadow complexity vs support size for elementary symmetric
polynomials e_k(x₁,...,xₙ), demonstrating how the shadow lower
bound grows with polynomial parameters.

Also shows the shadow-closure rate for random support sets,
illustrating the genericity of the non-cancellation certificate.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations
import random


def compute_quadratic_shadow(support, n_vars):
    shadow = set()
    for alpha in support:
        for i in range(n_vars):
            if alpha[i] < 1:
                continue
            a = list(alpha)
            a[i] -= 1
            for j in range(n_vars):
                if a[j] < 1:
                    continue
                b = list(a)
                b[j] -= 1
                shadow.add(tuple(b))
    return shadow


def elementary_symmetric_support(n, k):
    support = set()
    for subset in combinations(range(n), k):
        exp = [0] * n
        for idx in subset:
            exp[idx] = 1
        support.add(tuple(exp))
    return support


def is_shadow_closed(support, n_vars):
    return compute_quadratic_shadow(support, n_vars).issubset(support)


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ─── Panel 1: Shadow complexity of e_k ───
ax = axes[0]
max_n = 12

for k in range(2, 6):
    ns = list(range(k + 1, max_n + 1))
    support_sizes = []
    shadow_sizes = []
    for n in ns:
        supp = elementary_symmetric_support(n, k)
        shadow = compute_quadratic_shadow(supp, n)
        support_sizes.append(len(supp))
        shadow_sizes.append(len(shadow))

    ax.plot(ns, shadow_sizes, 'o-', label=f'e_{k}', linewidth=2, markersize=6)

ax.set_xlabel("Number of variables n", fontsize=12)
ax.set_ylabel("Shadow complexity |Sh₂(supp)|", fontsize=12)
ax.set_title("Shadow Complexity of e_k(x₁,...,xₙ)", fontsize=13,
            fontweight='bold')
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_yscale('log')

# ─── Panel 2: Support size vs shadow size ratio ───
ax2 = axes[1]

for k in range(2, 6):
    ns = list(range(k + 1, max_n + 1))
    ratios = []
    for n in ns:
        supp = elementary_symmetric_support(n, k)
        shadow = compute_quadratic_shadow(supp, n)
        ratios.append(len(shadow) / len(supp) if len(supp) > 0 else 0)

    ax2.plot(ns, ratios, 's-', label=f'e_{k}', linewidth=2, markersize=6)

ax2.set_xlabel("Number of variables n", fontsize=12)
ax2.set_ylabel("|Shadow| / |Support|", fontsize=12)
ax2.set_title("Shadow Amplification Ratio", fontsize=13, fontweight='bold')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.axhline(y=1, color='black', linestyle='--', alpha=0.5, label='ratio = 1')

# ─── Panel 3: Shadow-closure rate for random supports ───
ax3 = axes[2]
random.seed(42)

n_vars_range = range(2, 7)
n_samples = 300

closure_rates = []
for n_vars in n_vars_range:
    closed_count = 0
    for _ in range(n_samples):
        n_terms = random.randint(3, 15)
        max_deg = random.randint(1, 5)
        support = set()
        for _ in range(n_terms * 3):
            exp = tuple(random.randint(0, max_deg) for _ in range(n_vars))
            support.add(exp)
            if len(support) >= n_terms:
                break
        if is_shadow_closed(support, n_vars):
            closed_count += 1
    closure_rates.append(closed_count / n_samples)

ax3.bar(list(n_vars_range), closure_rates, color='steelblue', alpha=0.8,
       edgecolor='navy')
ax3.set_xlabel("Number of variables", fontsize=12)
ax3.set_ylabel("Fraction shadow-closed", fontsize=12)
ax3.set_title("Shadow-Closure Rate\n(Random Supports)", fontsize=13,
             fontweight='bold')
ax3.set_ylim(0, 1)
ax3.grid(True, alpha=0.3, axis='y')

for i, rate in enumerate(closure_rates):
    ax3.text(list(n_vars_range)[i], rate + 0.02, f"{rate:.0%}",
            ha='center', fontsize=10, fontweight='bold')

plt.suptitle(
    "Shadow Complexity Analysis: From Support to Lower Bounds",
    fontsize=15, fontweight='bold', y=1.02
)
plt.tight_layout()
plt.savefig("visualize_complexity.png", dpi=150, bbox_inches='tight')
print("Saved visualize_complexity.png")
