#!/usr/bin/env python3
"""
visualize_support_tutte.py — Visualization of Support-Tutte Polynomials

Produces a heatmap showing the coefficients of T(S) for various M-convex
supports, and a comparison chart between binary (matroid) and non-binary
supports. All functions inlined for standalone execution.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

# ============================================================
# Inline polynomial/support functions
# ============================================================

def poly_one():
    return {0: 1}

def poly_var():
    return {1: 1}

def poly_add(p, q):
    result = dict(p)
    for deg, coeff in q.items():
        result[deg] = result.get(deg, 0) + coeff
    return {k: v for k, v in result.items() if v != 0}

def poly_mul(p, q):
    result = {}
    for d1, c1 in p.items():
        for d2, c2 in q.items():
            d = d1 + d2
            result[d] = result.get(d, 0) + c1 * c2
    return {k: v for k, v in result.items() if v != 0}

def poly_eval(p, x):
    return sum(c * x**d for d, c in p.items())

def support_delete(S, i):
    return {v for v in S if v[i] == 0}

def support_contract(S, i):
    result = set()
    for v in S:
        if v[i] > 0:
            w = list(v); w[i] -= 1; result.add(tuple(w))
    return result

def is_loop(S, i):
    return len(S) > 0 and all(v[i] > 0 for v in S)

def is_ordinary(S, i):
    return any(v[i] == 0 for v in S) and any(v[i] > 0 for v in S)

def compute_tutte(S, memo=None):
    if memo is None: memo = {}
    key = frozenset(S)
    if key in memo: return memo[key]
    if not S:
        r = poly_one(); memo[key] = r; return r
    n = len(next(iter(S)))
    zero = tuple([0] * n)
    if S == {zero}:
        r = poly_one(); memo[key] = r; return r
    for i in range(n):
        if is_ordinary(S, i):
            r = poly_add(compute_tutte(support_delete(S, i), memo),
                         compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    for i in range(n):
        if is_loop(S, i):
            r = poly_mul(poly_var(), compute_tutte(support_contract(S, i), memo))
            memo[key] = r; return r
    r = poly_one(); memo[key] = r; return r

def simplex_support(n, d):
    if n == 1: return {(d,)}
    result = set()
    for k in range(d + 1):
        for rest in simplex_support(n - 1, d - k):
            result.add((k,) + rest)
    return result

def check_mconvexity(S):
    if len(S) <= 1: return True
    n = len(next(iter(S)))
    for x in S:
        for y in S:
            for a in range(n):
                if x[a] > y[a]:
                    found = False
                    for b in range(n):
                        if y[b] > x[b]:
                            x_new = list(x); x_new[a] -= 1; x_new[b] += 1
                            y_new = list(y); y_new[a] += 1; y_new[b] -= 1
                            if tuple(x_new) in S and tuple(y_new) in S:
                                found = True; break
                    if not found: return False
    return True

def matroid_basis_support(n, bases):
    result = set()
    for basis in bases:
        v = [0] * n
        for i in basis: v[i] = 1
        result.add(tuple(v))
    return result

# ============================================================
# Visualization
# ============================================================

fig, axes = plt.subplots(1, 3, figsize=(18, 6))

# --- Panel 1: Coefficient heatmap ---
supports_data = []
labels = []

for d in range(1, 6):
    S = simplex_support(3, d)
    T = compute_tutte(S)
    supports_data.append(T)
    labels.append(f"Simplex(3,{d})\n|S|={len(S)}")

for d in range(1, 4):
    S = simplex_support(4, d)
    T = compute_tutte(S)
    supports_data.append(T)
    labels.append(f"Simplex(4,{d})\n|S|={len(S)}")

max_deg = max(max(T.keys()) if T else 0 for T in supports_data)
matrix = np.zeros((len(supports_data), max_deg + 1))
for i, T in enumerate(supports_data):
    for d, c in T.items():
        matrix[i, d] = c

im = axes[0].imshow(matrix, aspect='auto', cmap='YlOrRd', interpolation='nearest')
axes[0].set_yticks(range(len(labels)))
axes[0].set_yticklabels(labels, fontsize=8)
axes[0].set_xlabel('Degree of X', fontsize=11)
axes[0].set_title('Support-Tutte Coefficients', fontsize=13, fontweight='bold')
plt.colorbar(im, ax=axes[0], label='Coefficient value')

# Add text annotations
for i in range(matrix.shape[0]):
    for j in range(matrix.shape[1]):
        if matrix[i, j] > 0:
            axes[0].text(j, i, f'{int(matrix[i,j])}', ha='center', va='center',
                        fontsize=7, color='black' if matrix[i,j] < matrix.max()/2 else 'white')

# --- Panel 2: T(x) evaluation curves ---
x_vals = np.linspace(0, 3, 100)
colors = plt.cm.viridis(np.linspace(0, 1, 5))

for idx, d in enumerate(range(1, 6)):
    S = simplex_support(3, d)
    T = compute_tutte(S)
    y_vals = [sum(c * x**deg for deg, c in T.items()) for x in x_vals]
    axes[1].plot(x_vals, y_vals, color=colors[idx], linewidth=2,
                label=f'd={d}, |S|={len(S)}')

axes[1].set_xlabel('X', fontsize=11)
axes[1].set_ylabel('T(S)(X)', fontsize=11)
axes[1].set_title('Support-Tutte Evaluation Curves\n(3-variable simplices)', fontsize=13, fontweight='bold')
axes[1].legend(fontsize=9)
axes[1].set_yscale('log')
axes[1].grid(True, alpha=0.3)

# --- Panel 3: Binary vs non-binary comparison ---
# Compare matroid supports vs full simplex supports
categories = []
binary_vals = []
full_vals = []
extra_info = []

for d in range(1, 5):
    # Binary: matroid basis indicators for U_{d, d+1}
    n = d + 1
    bases = list(combinations(range(n), d))
    S_bin = matroid_basis_support(n, [list(b) for b in bases])
    T_bin = compute_tutte(S_bin)
    
    # Non-binary: full degree-d simplex in (d+1) vars
    S_full = simplex_support(n, d)
    T_full = compute_tutte(S_full)
    
    categories.append(f"d={d}, n={n}")
    binary_vals.append(poly_eval(T_bin, 2))
    full_vals.append(poly_eval(T_full, 2))
    extra_info.append((len(S_bin), len(S_full)))

x_pos = np.arange(len(categories))
width = 0.35

bars1 = axes[2].bar(x_pos - width/2, binary_vals, width, label='Binary (matroid)',
                     color='steelblue', alpha=0.8)
bars2 = axes[2].bar(x_pos + width/2, full_vals, width, label='Full simplex',
                     color='coral', alpha=0.8)

axes[2].set_xlabel('Support parameters', fontsize=11)
axes[2].set_ylabel('T(S)(2)', fontsize=11)
axes[2].set_title('Binary vs Non-Binary\nSupport-Tutte at X=2', fontsize=13, fontweight='bold')
axes[2].set_xticks(x_pos)
axes[2].set_xticklabels(categories, fontsize=9)
axes[2].legend(fontsize=9)
axes[2].grid(True, alpha=0.3, axis='y')

# Add size annotations
for i, (nb, nf) in enumerate(extra_info):
    axes[2].annotate(f'|S|={nb}', (x_pos[i] - width/2, binary_vals[i]),
                    ha='center', va='bottom', fontsize=7)
    axes[2].annotate(f'|S|={nf}', (x_pos[i] + width/2, full_vals[i]),
                    ha='center', va='bottom', fontsize=7)

plt.tight_layout()
plt.savefig('support_tutte_visualization.png', dpi=150, bbox_inches='tight')
print("Saved: support_tutte_visualization.png")
