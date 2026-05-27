#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Landscape

Visualizes how the support-Tutte polynomial varies across different M-convex
supports in the degree-≤4 simplex with 2 variables. Shows the polynomial
degree and coefficient structure as a heatmap.

This reveals the "arithmetic landscape" of support invariants — structure
that classical matroid Tutte theory cannot see.
"""

import matplotlib.pyplot as plt
import numpy as np
from collections import defaultdict
import itertools

# ===== Inline all needed functions =====

def poly_add(p, q):
    result = dict(p)
    for k, v in q.items():
        result[k] = result.get(k, 0) + v
    return {k: v for k, v in result.items() if v != 0}

def poly_mul_x(p):
    return {k + 1: v for k, v in p.items()}

def poly_eval(p, x):
    return sum(coeff * x**deg for deg, coeff in p.items())

def poly_str(p):
    if not p:
        return "0"
    terms = []
    for deg in sorted(p.keys(), reverse=True):
        coeff = p[deg]
        if coeff == 0:
            continue
        if deg == 0:
            terms.append(str(coeff))
        elif deg == 1:
            terms.append(f"{coeff}X" if coeff != 1 else "X")
        else:
            terms.append(f"{coeff}X^{deg}" if coeff != 1 else f"X^{deg}")
    return " + ".join(terms) if terms else "0"

def support_tutte(S, n, memo=None):
    if memo is None:
        memo = {}
    if S in memo:
        return memo[S]
    if len(S) == 0:
        result = {0: 1}
    elif S == frozenset({tuple(0 for _ in range(n))}):
        result = {0: 1}
    else:
        result = None
        for i in range(n):
            has_zero = any(m[i] == 0 for m in S)
            has_pos = any(m[i] > 0 for m in S)
            if has_zero and has_pos:
                d = support_tutte(frozenset(m for m in S if m[i] == 0), n, memo)
                contracted = set()
                for m in S:
                    if m[i] > 0:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                c = support_tutte(frozenset(contracted), n, memo)
                result = poly_add(d, c)
                break
        if result is None:
            for i in range(n):
                if all(m[i] > 0 for m in S):
                    contracted = set()
                    for m in S:
                        new_m = list(m)
                        new_m[i] -= 1
                        contracted.add(tuple(new_m))
                    c = support_tutte(frozenset(contracted), n, memo)
                    result = poly_mul_x(c)
                    break
        if result is None:
            result = {0: 1}
    memo[S] = result
    return result

def check_exchange(S, n):
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            nx = list(x); nx[a] -= 1; nx[b] += 1
                            ny = list(y); ny[a] += 1; ny[b] -= 1
                            if tuple(nx) in S and tuple(ny) in S:
                                found = True; break
                    if not found:
                        return False
    return True

# ===== Generate data =====

max_deg = 4
n_vars = 2

# Generate all simplex points
points = []
for combo in itertools.product(range(max_deg + 1), repeat=n_vars):
    if sum(combo) <= max_deg:
        points.append(combo)

# Find M-convex subsets and compute polynomials
data = []
for size in range(1, min(len(points) + 1, 7)):
    for subset in itertools.combinations(points, size):
        S = frozenset(subset)
        if check_exchange(S, n_vars):
            T = support_tutte(S, n_vars)
            max_power = max(T.keys()) if T else 0
            leading_coeff = T.get(max_power, 0)
            eval_2 = poly_eval(T, 2)
            data.append({
                'S': S, 'T': T, 'size': len(S),
                'max_deg': max_power, 'leading': leading_coeff,
                'eval_2': eval_2, 'poly_str': poly_str(T)
            })

# ===== Create figure =====

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Universal Support-Tutte Polynomial Landscape\n'
             f'M-convex supports in degree-≤{max_deg} simplex ({n_vars} variables)',
             fontsize=14, fontweight='bold')

# Plot 1: Size vs Max Degree scatter
ax1 = axes[0, 0]
sizes = [d['size'] for d in data]
degs = [d['max_deg'] for d in data]
colors = [d['eval_2'] for d in data]
scatter = ax1.scatter(sizes, degs, c=colors, cmap='viridis', 
                      alpha=0.7, edgecolors='black', linewidths=0.5, s=60)
ax1.set_xlabel('Support size |S|')
ax1.set_ylabel('Max polynomial degree')
ax1.set_title('Polynomial Degree vs Support Size')
plt.colorbar(scatter, ax=ax1, label='T(2)')

# Plot 2: Distribution of polynomial degrees
ax2 = axes[0, 1]
deg_counts = defaultdict(int)
for d in data:
    deg_counts[d['max_deg']] += 1
deg_keys = sorted(deg_counts.keys())
ax2.bar(deg_keys, [deg_counts[k] for k in deg_keys], 
        color='steelblue', edgecolor='black')
ax2.set_xlabel('Max polynomial degree')
ax2.set_ylabel('Number of M-convex supports')
ax2.set_title('Distribution of Polynomial Degrees')

# Plot 3: Evaluation curve for select supports
ax3 = axes[1, 0]
x_vals = np.linspace(0, 3, 100)
interesting = sorted(data, key=lambda d: d['max_deg'], reverse=True)[:6]
for d in interesting:
    y_vals = [poly_eval(d['T'], x) for x in x_vals]
    ax3.plot(x_vals, y_vals, label=f"|S|={d['size']}, T={d['poly_str']}", 
             linewidth=1.5)
ax3.set_xlabel('X')
ax3.set_ylabel('T(X)')
ax3.set_title('Support-Tutte Polynomial Evaluation Curves')
ax3.legend(fontsize=7, loc='upper left')
ax3.set_ylim(0, max(50, max(poly_eval(d['T'], 3) for d in interesting)))

# Plot 4: Binary vs non-binary comparison
ax4 = axes[1, 1]
binary = [d for d in data if all(all(v <= 1 for v in m) for m in d['S'])]
nonbinary = [d for d in data if any(any(v > 1 for v in m) for m in d['S'])]
bins_deg_b = defaultdict(int)
bins_deg_nb = defaultdict(int)
for d in binary:
    bins_deg_b[d['max_deg']] += 1
for d in nonbinary:
    bins_deg_nb[d['max_deg']] += 1
all_degs = sorted(set(list(bins_deg_b.keys()) + list(bins_deg_nb.keys())))
width = 0.35
x_pos = np.arange(len(all_degs))
ax4.bar(x_pos - width/2, [bins_deg_b.get(k, 0) for k in all_degs],
        width, label='Binary (matroidal)', color='cornflowerblue', edgecolor='black')
ax4.bar(x_pos + width/2, [bins_deg_nb.get(k, 0) for k in all_degs],
        width, label='Non-binary', color='salmon', edgecolor='black')
ax4.set_xticks(x_pos)
ax4.set_xticklabels(all_degs)
ax4.set_xlabel('Max polynomial degree')
ax4.set_ylabel('Count')
ax4.set_title('Binary vs Non-binary Supports')
ax4.legend()

plt.tight_layout()
plt.savefig('tutte_landscape.png', dpi=150, bbox_inches='tight')
print(f"Saved visualization with {len(data)} M-convex supports")
