#!/usr/bin/env python3
"""
Visualization: Product Tower Growth and Stabilization

Shows how the product tower A, A², A³, ... grows for different subsets:
- Subgroups: immediate stabilization (A^k = A for all k)
- Generating sets: monotone growth until filling the group
- Near-subgroups: slow growth before acceleration

This visualizes the key dichotomy underlying the BGT theorem:
growth or algebraic structure, never both.

This script is fully self-contained — no local module imports.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def product_tower_cyclic(n, A, max_k=10):
    """Compute |A^k| for k = 1, ..., max_k in Z/nZ."""
    sizes = []
    current = set(A)
    for k in range(max_k):
        sizes.append(len(current))
        next_set = {(a + b) % n for a in current for b in A}
        if next_set == current:
            # Stabilized — fill the rest
            for _ in range(max_k - k - 1):
                sizes.append(len(current))
            break
        current = next_set
    return sizes


def product_tower_sl2(p, A_set, max_k=8):
    """Compute |A^k| for k = 1,...,max_k in SL(2, F_p)."""
    def mul(X, Y):
        a1, b1, c1, d1 = X
        a2, b2, c2, d2 = Y
        return ((a1*a2+b1*c2)%p, (a1*b2+b1*d2)%p,
                (c1*a2+d1*c2)%p, (c1*b2+d1*d2)%p)

    sizes = []
    current = set(A_set)
    for k in range(max_k):
        sizes.append(len(current))
        next_set = {mul(a, b) for a in current for b in A_set}
        if next_set == current:
            for _ in range(max_k - k - 1):
                sizes.append(len(current))
            break
        current = next_set
    return sizes


fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Product Tower Growth: Subgroups vs Generators',
             fontsize=16, fontweight='bold')

# ── Panel 1: Z/12Z ──
n = 12
cases = [
    ({0, 4, 8}, 'Subgroup {0,4,8}', '#2196F3', 's'),
    ({0, 6}, 'Subgroup {0,6}', '#4CAF50', 'D'),
    ({0, 1, 11}, 'Generator {0,1,11}', '#FF5722', 'o'),
    ({0, 2, 10}, 'Non-gen {0,2,10}', '#9C27B0', '^'),
    ({0, 3, 9}, 'Subgroup {0,3,9}', '#FF9800', 'v'),
]

max_k = 10
for A, label, color, marker in cases:
    sizes = product_tower_cyclic(n, A, max_k)
    ks = list(range(1, len(sizes) + 1))
    ax1.plot(ks, sizes, marker=marker, color=color, label=label,
             linewidth=2, markersize=8)

ax1.axhline(y=n, color='gray', linestyle=':', alpha=0.5, label=f'|G| = {n}')
ax1.set_xlabel('Power k', fontsize=12)
ax1.set_ylabel('|A^k|', fontsize=12)
ax1.set_title('Z/12Z', fontsize=13)
ax1.legend(fontsize=9, loc='center right')
ax1.grid(True, alpha=0.3)
ax1.set_xticks(range(1, max_k + 1))

# ── Panel 2: SL(2, F_3) ──
p = 3
# Count SL(2, F_3) elements
sl2_elems = []
for a in range(p):
    for b in range(p):
        for c in range(p):
            for d in range(p):
                if (a*d - b*c) % p == 1:
                    sl2_elems.append((a, b, c, d))
sl2_size = len(sl2_elems)

ident = (1, 0, 0, 1)
def inv_sl2(X):
    a, b, c, d = X
    return (d%p, (-b)%p, (-c)%p, a%p)

# Different subsets
g1 = (1, 1, 0, 1)
g2 = (1, 0, 1, 1)
g3 = (0, 1, 2, 0)

cases_sl2 = [
    ({ident}, '{I}', '#607D8B', 's'),
    ({ident, g1, inv_sl2(g1)}, '{I, u, u⁻¹}', '#2196F3', 'o'),
    ({ident, g1, inv_sl2(g1), g2, inv_sl2(g2)}, '{I,u,u⁻¹,l,l⁻¹}', '#FF5722', '^'),
    ({ident, g3, inv_sl2(g3)}, '{I, s, s⁻¹}', '#4CAF50', 'D'),
]

max_k_sl = 8
for A, label, color, marker in cases_sl2:
    sizes = product_tower_sl2(p, A, max_k_sl)
    ks = list(range(1, len(sizes) + 1))
    ax2.plot(ks, sizes, marker=marker, color=color, label=label,
             linewidth=2, markersize=8)

ax2.axhline(y=sl2_size, color='gray', linestyle=':', alpha=0.5,
            label=f'|SL(2,F₃)| = {sl2_size}')
ax2.set_xlabel('Power k', fontsize=12)
ax2.set_ylabel('|A^k|', fontsize=12)
ax2.set_title('SL(2, F₃)', fontsize=13)
ax2.legend(fontsize=9, loc='center right')
ax2.grid(True, alpha=0.3)
ax2.set_xticks(range(1, max_k_sl + 1))

plt.tight_layout(rect=[0, 0, 1, 0.95])
plt.savefig('growth_tower.png', dpi=150, bbox_inches='tight')
print("Saved growth_tower.png")
