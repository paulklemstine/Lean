#!/usr/bin/env python3
"""
Visualization: Certificate Satisfaction Landscape

Visualizes the non-cancellation certificate landscape across random
polynomial families, showing:
- Certificate satisfaction rate vs polynomial density
- Support equality rate for individual vs aggregate operators
- Phase transition behavior

CRITICAL: This script is fully self-contained. No local imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import random


def partial_derivative(poly, var_idx, n_vars):
    result = {}
    for exp, coeff in poly.items():
        e = list(exp)
        if e[var_idx] >= 1:
            new_coeff = coeff * e[var_idx]
            e[var_idx] -= 1
            new_exp = tuple(e)
            result[new_exp] = result.get(new_exp, 0) + new_coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


def mixed_partial(poly, i, j, n_vars):
    return partial_derivative(partial_derivative(poly, j, n_vars), i, n_vars)


def mixed_shadow(supp, i, j, n_vars):
    shadow = set()
    for alpha in supp:
        beta = list(alpha)
        beta[i] -= 1
        beta[j] -= 1
        if all(b >= 0 for b in beta):
            shadow.add(tuple(beta))
    return shadow


def aggregate_mixed_partial(poly, weights, n_vars):
    result = {}
    for i in range(n_vars):
        for j in range(n_vars):
            w = weights[i][j]
            if abs(w) < 1e-12:
                continue
            mp = mixed_partial(poly, i, j, n_vars)
            for exp, coeff in mp.items():
                result[exp] = result.get(exp, 0) + w * coeff
    return {k: v for k, v in result.items() if abs(v) > 1e-12}


random.seed(42)
n_vars = 2
max_degree = 6

fig, axes = plt.subplots(2, 2, figsize=(14, 12))

# Panel 1: Individual faithfulness rate vs number of terms
ax = axes[0][0]
term_counts = range(1, 20)
faithfulness_rates = []

for n_terms in term_counts:
    faithful = 0
    total = 0
    for trial in range(100):
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        for i in range(n_vars):
            for j in range(n_vars):
                mp = mixed_partial(poly, i, j, n_vars)
                shadow = mixed_shadow(set(poly.keys()), i, j, n_vars)
                actual = set(mp.keys())
                total += 1
                if actual == shadow:
                    faithful += 1

    rate = faithful / max(total, 1)
    faithfulness_rates.append(rate)

ax.plot(list(term_counts), faithfulness_rates, 'o-', color='#4CAF50', linewidth=2, markersize=6)
ax.axhline(y=1.0, color='#4CAF50', linestyle='--', alpha=0.5)
ax.set_xlabel('Number of terms in polynomial', fontsize=11)
ax.set_ylabel('Faithfulness rate', fontsize=11)
ax.set_title('Individual ∂ᵢ∂ⱼ: Always Faithful', fontsize=13, fontweight='bold')
ax.set_ylim(0.95, 1.05)
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.3, '100% faithful\n(Theorem 1)', transform=ax.transAxes,
        ha='center', fontsize=14, color='#4CAF50', fontweight='bold')

# Panel 2: Aggregate strict inclusion rate vs number of terms
ax = axes[0][1]
strict_rates = []

for n_terms in term_counts:
    strict = 0
    total = 0
    for trial in range(100):
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        # Random weights
        weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
                   for _ in range(n_vars)]
        agg = aggregate_mixed_partial(poly, weights, n_vars)
        shadow_set = set()
        for i in range(n_vars):
            for j in range(n_vars):
                if abs(weights[i][j]) > 1e-12:
                    shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

        actual = set(agg.keys())
        total += 1
        if actual != shadow_set and shadow_set:
            strict += 1

    rate = strict / max(total, 1)
    strict_rates.append(rate)

ax.plot(list(term_counts), strict_rates, 'o-', color='#F44336', linewidth=2, markersize=6)
ax.set_xlabel('Number of terms in polynomial', fontsize=11)
ax.set_ylabel('Strict inclusion rate', fontsize=11)
ax.set_title('Aggregate: Cancellation Frequency', fontsize=13, fontweight='bold')
ax.grid(True, alpha=0.3)
ax.text(0.5, 0.85, 'Certificate\nfailure rate', transform=ax.transAxes,
        ha='center', fontsize=12, color='#F44336')

# Panel 3: Heatmap of shadow size vs actual support size
ax = axes[1][0]
shadow_sizes = []
actual_sizes = []

for trial in range(500):
    n_terms = random.randint(2, 15)
    poly = {}
    for _ in range(n_terms):
        exp = (random.randint(0, max_degree), random.randint(0, max_degree))
        poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
    if not poly:
        continue

    weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
               for _ in range(n_vars)]
    agg = aggregate_mixed_partial(poly, weights, n_vars)
    shadow_set = set()
    for i in range(n_vars):
        for j in range(n_vars):
            if abs(weights[i][j]) > 1e-12:
                shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

    if shadow_set:
        shadow_sizes.append(len(shadow_set))
        actual_sizes.append(len(set(agg.keys())))

ax.scatter(shadow_sizes, actual_sizes, alpha=0.3, s=20, color='#9C27B0')
max_val = max(max(shadow_sizes, default=1), max(actual_sizes, default=1))
ax.plot([0, max_val], [0, max_val], '--', color='#4CAF50', linewidth=2, label='y = x (faithful)')
ax.set_xlabel('Shadow size (predicted)', fontsize=11)
ax.set_ylabel('Actual support size', fontsize=11)
ax.set_title('Shadow vs Actual Support (Aggregate)', fontsize=13, fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 4: Certificate satisfaction by weight structure
ax = axes[1][1]
categories = ['Identity\n(I)', 'Symmetric\n(wᵢⱼ=wⱼᵢ)', 'Antisymmetric\n(wᵢⱼ=-wⱼᵢ)', 'Random']
cert_rates = []

for cat_idx, category in enumerate(categories):
    holds = 0
    total = 0
    for trial in range(200):
        n_terms = random.randint(3, 10)
        poly = {}
        for _ in range(n_terms):
            exp = (random.randint(0, max_degree), random.randint(0, max_degree))
            poly[exp] = random.choice([-3, -2, -1, 1, 2, 3])
        if not poly:
            continue

        if cat_idx == 0:  # Identity
            weights = [[1 if i == j else 0 for j in range(n_vars)] for i in range(n_vars)]
        elif cat_idx == 1:  # Symmetric
            w01 = random.choice([-2, -1, 1, 2])
            weights = [[random.choice([0, 1, 2]), w01], [w01, random.choice([0, 1, 2])]]
        elif cat_idx == 2:  # Antisymmetric
            w01 = random.choice([-2, -1, 1, 2])
            weights = [[0, w01], [-w01, 0]]
        else:  # Random
            weights = [[random.choice([-2, -1, 0, 1, 2]) for _ in range(n_vars)]
                       for _ in range(n_vars)]

        agg = aggregate_mixed_partial(poly, weights, n_vars)
        shadow_set = set()
        for i in range(n_vars):
            for j in range(n_vars):
                if abs(weights[i][j]) > 1e-12:
                    shadow_set |= mixed_shadow(set(poly.keys()), i, j, n_vars)

        actual = set(agg.keys())
        total += 1
        if actual == shadow_set or not shadow_set:
            holds += 1

    cert_rates.append(holds / max(total, 1))

colors = ['#4CAF50', '#2196F3', '#F44336', '#FF9800']
bars = ax.bar(categories, cert_rates, color=colors, alpha=0.7, edgecolor='black')
ax.set_ylabel('Certificate satisfaction rate', fontsize=11)
ax.set_title('Certificate Rate by Weight Structure', fontsize=13, fontweight='bold')
ax.set_ylim(0, 1.1)
ax.grid(True, alpha=0.3, axis='y')

for bar, rate in zip(bars, cert_rates):
    ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.02,
            f'{rate:.0%}', ha='center', fontsize=11, fontweight='bold')

plt.suptitle('Tropical Faithfulness of Differentiation — Certificate Landscape',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_certificate_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_certificate_landscape.png")
