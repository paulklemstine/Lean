#!/usr/bin/env python3
"""
Visualization: Product Shadow Inclusion and Entropy Under Multiplication

Visualizes the formally verified product shadow theorem:
  Sh₁(S ⊕ T) ⊆ Sh₁(S) ⊕ T ∪ S ⊕ Sh₁(T)

Shows how shadow entropy behaves under polynomial multiplication,
connecting to the entropy chain rule analogy.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations
from typing import Tuple, FrozenSet

Monomial = Tuple[int, ...]
SupportFamily = FrozenSet[Monomial]

def unit_vector(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def add_monomials(a, b):
    return tuple(x + y for x, y in zip(a, b))

def sub_monomial_at(m, i):
    if m[i] <= 0:
        return None
    return tuple(m[j] - (1 if j == i else 0) for j in range(len(m)))

def one_shadow(S):
    if not S:
        return frozenset()
    n = len(next(iter(S)))
    shadow = set()
    for m in S:
        for i in range(n):
            u = sub_monomial_at(m, i)
            if u is not None:
                shadow.add(u)
    return frozenset(shadow)

def support_mul(A, B):
    return frozenset(add_monomials(a, b) for a in A for b in B)

def shadow_entropy(S):
    if not S:
        return float('-inf')
    sh = one_shadow(S)
    if not sh:
        return float('-inf')
    return math.log(len(sh)) - math.log(len(S))

def entropy_ratio(S):
    if not S:
        return 0.0
    return len(one_shadow(S)) / len(S)


# ═══════════════════════════════════════════════════════════════
# FIGURE: Product shadow inclusion and entropy scaling
# ═══════════════════════════════════════════════════════════════

fig, axes = plt.subplots(2, 2, figsize=(14, 11))
fig.suptitle('Product Shadow Inclusion & Entropy Under Multiplication', 
             fontsize=14, fontweight='bold')

# ─── Panel 1: Venn diagram showing the inclusion ───
ax1 = axes[0, 0]
n = 2

S = frozenset([(1,0), (0,1)])
T = frozenset([(1,0), (0,1)])

prod_ST = support_mul(S, T)
sh_prod = one_shadow(prod_ST)
sh_S = one_shadow(S)
sh_T = one_shadow(T)
left_set = support_mul(sh_S, T)
right_set = support_mul(S, sh_T)

# Bar chart showing set sizes
categories = ['Sh₁(S⊕T)', 'Sh₁(S)⊕T', 'S⊕Sh₁(T)', 'Sh₁(S)⊕T ∪ S⊕Sh₁(T)']
values = [len(sh_prod), len(left_set), len(right_set), len(left_set | right_set)]
colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

bars = ax1.bar(categories, values, color=colors, alpha=0.7, edgecolor='black')
ax1.set_ylabel('Cardinality', fontsize=11)
ax1.set_title(f'Set Sizes for S=T={{e₀,e₁}} in ℕ²\n'
              f'|Sh₁(S⊕T)| = {len(sh_prod)} ≤ {len(left_set | right_set)} = |union|  ✓',
              fontsize=10)
ax1.tick_params(axis='x', rotation=15, labelsize=9)

for bar, val in zip(bars, values):
    ax1.text(bar.get_x() + bar.get_width()/2., bar.get_height() + 0.1,
             str(val), ha='center', va='bottom', fontweight='bold')

# ─── Panel 2: Entropy ratio under iterated multiplication ───
ax2 = axes[0, 1]

for n_val in [2, 3, 4]:
    base = frozenset([unit_vector(n_val, i) for i in range(n_val)])
    current = base
    iters = []
    ratios = []
    
    for k in range(1, 7):
        current = support_mul(current, base)
        r = entropy_ratio(current)
        iters.append(k + 1)
        ratios.append(r)
    
    ax2.plot(iters, ratios, 'o-', linewidth=2, markersize=6,
             label=f'n={n_val}, bound={n_val}')
    ax2.axhline(y=n_val, linestyle='--', alpha=0.3)

ax2.set_xlabel('Product degree (S₀^k)', fontsize=11)
ax2.set_ylabel('Entropy ratio |Sh₁|/|S|', fontsize=11)
ax2.set_title('Entropy Ratio Under Iterated Products', fontsize=12)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

# ─── Panel 3: Shadow entropy scaling with degree ───
ax3 = axes[1, 0]

for n_val in [2, 3, 4]:
    base = frozenset([unit_vector(n_val, i) for i in range(n_val)])
    current = base
    degrees = [1]
    entropies = [shadow_entropy(base)]
    
    for k in range(1, 7):
        current = support_mul(current, base)
        H = shadow_entropy(current)
        degrees.append(k + 1)
        entropies.append(H)
    
    valid = [(d, e) for d, e in zip(degrees, entropies) if e > float('-inf')]
    if valid:
        ds, es = zip(*valid)
        ax3.plot(ds, es, 's-', linewidth=2, markersize=6, label=f'n={n_val}')

ax3.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
ax3.set_xlabel('Degree', fontsize=11)
ax3.set_ylabel('Shadow Entropy H(S)', fontsize=11)
ax3.set_title('Shadow Entropy vs Polynomial Degree', fontsize=12)
ax3.legend(fontsize=9)
ax3.grid(True, alpha=0.3)

# ─── Panel 4: Cardinal bound tightness ───
ax4 = axes[1, 1]

n_val = 3
base_families = [
    frozenset([unit_vector(n_val, i) for i in range(n_val)]),
    frozenset([(1,0,0), (0,1,0)]),
    frozenset([(1,1,0), (0,0,1)]),
]

for fi, base_S in enumerate(base_families):
    base_T = frozenset([unit_vector(n_val, i) for i in range(n_val)])
    
    current_S = base_S
    degrees = []
    tightness = []  # ratio of actual to bound
    
    for k in range(1, 6):
        prod = support_mul(current_S, base_T)
        sh_prod_size = len(one_shadow(prod))
        sh_cs = one_shadow(current_S)
        sh_bt = one_shadow(base_T)
        bound = len(support_mul(sh_cs, base_T)) + len(support_mul(current_S, sh_bt))
        
        if bound > 0:
            degrees.append(k)
            tightness.append(sh_prod_size / bound)
        
        current_S = prod
    
    if degrees:
        ax4.plot(degrees, tightness, 'D-', linewidth=2, markersize=6,
                 label=f'Family {fi+1}')

ax4.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Tight bound')
ax4.set_xlabel('Multiplication step', fontsize=11)
ax4.set_ylabel('|Sh₁(S⊕T)| / bound', fontsize=11)
ax4.set_title('Product Shadow Bound Tightness', fontsize=12)
ax4.legend(fontsize=9)
ax4.grid(True, alpha=0.3)
ax4.set_ylim(0, 1.2)

plt.tight_layout()
plt.savefig('product_shadow_inclusion.png', dpi=150, bbox_inches='tight')
print("Saved: product_shadow_inclusion.png")
