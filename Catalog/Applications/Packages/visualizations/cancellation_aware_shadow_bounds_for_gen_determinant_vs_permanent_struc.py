"""
Visualization: Determinant vs Permanent Support Heatmap

Creates a heatmap showing the coefficient structure of 3×3 and 4×4
determinant and permanent polynomials, highlighting the sign pattern
that drives cancellation in circuits.
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


# ── Compute 3×3 coefficient data ────────────────────────────────────

n = 3
perms_3 = list(permutations(range(n)))

# Create matrix: rows = permutations, columns = variables (i,j)
# Cell value = 1 if variable x_{i,j} appears in that permutation's monomial
perm_matrix = np.zeros((len(perms_3), n * n))
signs_3 = []

for idx, perm in enumerate(perms_3):
    sign = perm_sign(list(perm))
    signs_3.append(sign)
    for i in range(n):
        perm_matrix[idx, i * n + perm[i]] = 1

# ── Create figure ────────────────────────────────────────────────────

fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle('Determinant vs Permanent: Structure of Cancellation',
             fontsize=14, fontweight='bold')

# Panel 1: Permutation-variable incidence (3×3)
ax = axes[0, 0]
im = ax.imshow(perm_matrix, aspect='auto', cmap='Blues', interpolation='nearest')
ax.set_xlabel('Variable index (i·n + j)')
ax.set_ylabel('Permutation index')
ax.set_title('3×3: Monomial Structure\n(each row = one permutation)')
# Add sign indicators on the right
for idx, s in enumerate(signs_3):
    color = '#2E7D32' if s > 0 else '#C62828'
    symbol = '+' if s > 0 else '−'
    ax.text(n*n + 0.3, idx, symbol, fontsize=12, fontweight='bold',
            color=color, va='center')
ax.set_xlim(-0.5, n*n + 0.8)
plt.colorbar(im, ax=ax, fraction=0.02)

# Panel 2: Sign pattern visualization (3×3)
ax = axes[0, 1]
sign_colors = ['#4CAF50' if s > 0 else '#F44336' for s in signs_3]
bars = ax.barh(range(len(signs_3)), [1]*len(signs_3), color=sign_colors, edgecolor='white')
ax.set_xlabel('')
ax.set_ylabel('Permutation index')
ax.set_title('3×3 Determinant Signs\n(green = +1, red = −1)')
ax.set_xlim(0, 1.5)
for idx, (perm, s) in enumerate(zip(perms_3, signs_3)):
    ax.text(1.1, idx, f'σ = {perm}, sign = {"+" if s > 0 else "−"}1',
            va='center', fontsize=8)

# Panel 3: Shadow analysis comparison
ax = axes[1, 0]
data_labels = []
data_sh_sizes = []
data_cancel_sizes = []

for nn in [2, 3, 4]:
    det_poly = {}
    perm_poly = {}
    for perm in permutations(range(nn)):
        vec = tuple(1 if j == perm[i] else 0 for i in range(nn) for j in range(nn))
        sign = perm_sign(list(perm))
        det_poly[vec] = det_poly.get(vec, 0) + sign
        perm_poly[vec] = perm_poly.get(vec, 0) + 1
    det_poly = {k: v for k, v in det_poly.items() if v != 0}
    perm_poly = {k: v for k, v in perm_poly.items() if v != 0}

    supp = set(det_poly.keys())
    sh = one_shadow(supp)

    # det + perm cancellation
    sum_poly = {}
    for k in set(det_poly) | set(perm_poly):
        v = det_poly.get(k, 0) + perm_poly.get(k, 0)
        if v != 0:
            sum_poly[k] = v
    cancel = supp - set(sum_poly.keys())

    data_labels.append(f'{nn}×{nn}')
    data_sh_sizes.append(len(sh))
    data_cancel_sizes.append(len(cancel))

x = np.arange(len(data_labels))
ax.bar(x - 0.15, data_sh_sizes, 0.3, label='|Sh(support)|', color='#2196F3')
ax.bar(x + 0.15, data_cancel_sizes, 0.3, label='|Cancel(det,perm)|', color='#F44336')
ax.set_xlabel('Matrix size')
ax.set_ylabel('Count')
ax.set_title('Shadow Size vs Cancellation\n(det + perm)')
ax.set_xticks(x)
ax.set_xticklabels(data_labels)
ax.legend()

# Panel 4: Key insight text
ax = axes[1, 1]
ax.axis('off')
insight_text = """
KEY INSIGHT

Determinant and permanent share identical 
supports — every monomial ∏ x_{i,σ(i)} 
appears in both. Yet they differ profoundly 
in sign structure:

• Permanent: all coefficients = +1
  → No cancellation possible
  → Shadow is maximized

• Determinant: coefficients = ±1
  → Cancellation at every addition gate
  → Shadow deficit accumulates

The Shadow Deficit Theorem proves:
  
  Δ_sh(f,g) ≤ |Sh(Cancel(f,g))|

This means cancellation leaves detectable 
"geometric scars" in the shadow — opening 
a new route toward distinguishing det 
from perm via combinatorial invariants.
"""
ax.text(0.1, 0.95, insight_text, transform=ax.transAxes,
        fontsize=10, verticalalignment='top', fontfamily='monospace',
        bbox=dict(boxstyle='round,pad=0.5', facecolor='lightyellow',
                  edgecolor='orange', alpha=0.8))

plt.tight_layout()
plt.savefig('det_perm_structure.png', dpi=150, bbox_inches='tight')
print("Saved: det_perm_structure.png")
