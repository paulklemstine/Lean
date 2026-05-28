"""
Visualization: Shadow Deficit Landscape for Determinant/Permanent Polynomials

Visualizes how shadow deficit, cancellation set size, and shadow bound
scale across different matrix sizes and cancellation scenarios.
Shows the key inequality: deficit ≤ |Sh(Cancel)| always holds.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations


# ── Self-contained functions ─────────────────────────────────────────

def perm_sign(perm):
    n = len(perm)
    visited = [False] * n
    sign = 1
    for i in range(n):
        if visited[i]: continue
        j, cycle_len = i, 0
        while not visited[j]:
            visited[j] = True
            j = perm[j]
            cycle_len += 1
        if cycle_len % 2 == 0:
            sign *= -1
    return sign

def one_shadow(S):
    shadow = set()
    for alpha in S:
        for i in range(len(alpha)):
            if alpha[i] > 0:
                beta = list(alpha)
                beta[i] -= 1
                shadow.add(tuple(beta))
    return shadow

def det_polynomial(n):
    poly = {}
    for perm in permutations(range(n)):
        vec = tuple(1 if j == perm[i] else 0 for i in range(n) for j in range(n))
        poly[vec] = poly.get(vec, 0) + perm_sign(list(perm))
    return {k: v for k, v in poly.items() if v != 0}

def perm_polynomial(n):
    poly = {}
    for perm in permutations(range(n)):
        vec = tuple(1 if j == perm[i] else 0 for i in range(n) for j in range(n))
        poly[vec] = poly.get(vec, 0) + 1
    return {k: v for k, v in poly.items() if v != 0}

def add_poly(p, q):
    r = dict(p)
    for k, v in q.items():
        r[k] = r.get(k, 0) + v
    return {k: v for k, v in r.items() if v != 0}

def negate_poly(p):
    return {k: -v for k, v in p.items()}


# ── Compute data ─────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Cancellation-Aware Shadow Bounds:\nDeterminant vs Permanent Analysis',
             fontsize=14, fontweight='bold')

# Panel 1: Support and shadow sizes across n
ns = [2, 3, 4]
support_sizes = []
shadow_sizes = []
n_factorial = []

for n in ns:
    det = det_polynomial(n)
    supp = set(det.keys())
    sh = one_shadow(supp)
    support_sizes.append(len(supp))
    shadow_sizes.append(len(sh))
    n_factorial.append(len(list(permutations(range(n)))))

ax = axes[0, 0]
x = np.arange(len(ns))
width = 0.3
ax.bar(x - width, support_sizes, width, label='|Support|', color='#2196F3')
ax.bar(x, shadow_sizes, width, label='|Shadow|', color='#FF9800')
ax.bar(x + width, n_factorial, width, label='n!', color='#4CAF50', alpha=0.7)
ax.set_xlabel('Matrix size n')
ax.set_ylabel('Count')
ax.set_title('Support & Shadow Growth')
ax.set_xticks(x)
ax.set_xticklabels([f'{n}×{n}' for n in ns])
ax.legend()
ax.set_yscale('log')

# Panel 2: det+perm and det-perm cancellation
ax = axes[0, 1]
cancel_data = {'det+perm': [], 'det-perm': []}
deficit_data = {'det+perm': [], 'det-perm': []}
sh_cancel_data = {'det+perm': [], 'det-perm': []}

for n in ns:
    det = det_polynomial(n)
    perm = perm_polynomial(n)
    det_supp = set(det.keys())
    perm_supp = set(perm.keys())
    union = det_supp | perm_supp

    for op_name, op in [('det+perm', perm), ('det-perm', negate_poly(perm))]:
        result = add_poly(det, op)
        result_supp = set(result.keys())
        cancel = union - result_supp
        sh_union = one_shadow(union)
        sh_result = one_shadow(result_supp)
        sh_cancel = one_shadow(cancel)
        deficit = max(0, len(sh_union) - len(sh_result))

        cancel_data[op_name].append(len(cancel))
        deficit_data[op_name].append(deficit)
        sh_cancel_data[op_name].append(len(sh_cancel))

x = np.arange(len(ns))
ax.plot(x, deficit_data['det+perm'], 'o-', label='Deficit (det+perm)', color='#E91E63', linewidth=2)
ax.plot(x, sh_cancel_data['det+perm'], 's--', label='|Sh(Cancel)| bound', color='#9C27B0', linewidth=2)
ax.plot(x, deficit_data['det-perm'], '^-', label='Deficit (det−perm)', color='#FF5722', linewidth=2)
ax.plot(x, sh_cancel_data['det-perm'], 'v--', label='|Sh(Cancel)| bound', color='#795548', linewidth=2)
ax.set_xlabel('Matrix size n')
ax.set_ylabel('Shadow count')
ax.set_title('Shadow Deficit ≤ |Sh(Cancel)|')
ax.set_xticks(x)
ax.set_xticklabels([f'{n}×{n}' for n in ns])
ax.legend(fontsize=8)

# Panel 3: Cancellation rate comparison
ax = axes[1, 0]
for n in ns:
    det = det_polynomial(n)
    det_pos = {k: v for k, v in det.items() if v > 0}
    det_neg = {k: -v for k, v in det.items() if v < 0}
    ax.bar(f'{n}×{n}\n+', len(det_pos), color='#2196F3', alpha=0.8)
    ax.bar(f'{n}×{n}\n−', len(det_neg), color='#F44336', alpha=0.8)

ax.set_ylabel('Number of terms')
ax.set_title('Determinant: Positive vs Negative Terms')
ax.axhline(y=0, color='black', linewidth=0.5)

# Panel 4: Shadow deficit as fraction of envelope shadow
ax = axes[1, 1]
fractions_plus = []
fractions_minus = []
for i, n in enumerate(ns):
    det = det_polynomial(n)
    perm = perm_polynomial(n)
    det_supp = set(det.keys())
    perm_supp = set(perm.keys())
    union = det_supp | perm_supp
    sh_union = one_shadow(union)

    for op_name, op, fracs in [('det+perm', perm, fractions_plus),
                                ('det-perm', negate_poly(perm), fractions_minus)]:
        result = add_poly(det, op)
        result_supp = set(result.keys())
        sh_result = one_shadow(result_supp)
        deficit = max(0, len(sh_union) - len(sh_result))
        fracs.append(deficit / max(1, len(sh_union)))

x = np.arange(len(ns))
ax.bar(x - 0.15, fractions_plus, 0.3, label='det+perm', color='#E91E63', alpha=0.8)
ax.bar(x + 0.15, fractions_minus, 0.3, label='det−perm', color='#FF5722', alpha=0.8)
ax.set_xlabel('Matrix size n')
ax.set_ylabel('Deficit / |Sh(envelope)|')
ax.set_title('Relative Shadow Loss')
ax.set_xticks(x)
ax.set_xticklabels([f'{n}×{n}' for n in ns])
ax.legend()
ax.set_ylim(0, 1)

plt.tight_layout()
plt.savefig('shadow_deficit_analysis.png', dpi=150, bbox_inches='tight')
print("Saved: shadow_deficit_analysis.png")
