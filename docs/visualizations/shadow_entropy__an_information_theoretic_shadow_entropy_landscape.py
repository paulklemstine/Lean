#!/usr/bin/env python3
"""
Visualization: Shadow Entropy Landscape

Visualizes the shadow entropy H(S) = log|Sh₁(S)| - log|S| for various
support families, showing:
1. Entropy vs circuit depth (confirming the (d+1)·log(n) bound)
2. Permanent support entropy scaling (H = log(m))
3. Entropy ratio distribution across random support families

This illustrates the formally verified bound: H(S) ≤ (depth+1)·log(n)
and the computational evidence for the logarithmic circuit entropy law.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from itertools import permutations, combinations
from typing import Tuple, FrozenSet, Optional, Set
import random

# ─── Inline all functions (self-contained) ───

Monomial = Tuple[int, ...]
SupportFamily = FrozenSet[Monomial]

def unit_vector(n, i):
    return tuple(1 if j == i else 0 for j in range(n))

def zero_vector(n):
    return tuple(0 for _ in range(n))

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
    sh = one_shadow(S)
    return len(sh) / len(S) if S else 0

def permanent_support(m):
    monomials = set()
    for perm in permutations(range(m)):
        vec = [0] * (m * m)
        for row, col in enumerate(perm):
            vec[row * m + col] = 1
        monomials.add(tuple(vec))
    return frozenset(monomials)

class SupportCircuit:
    def __init__(self, kind, children=None, var_index=0, n=1):
        self.kind = kind
        self.children = children or []
        self.var_index = var_index
        self.n = n

    @staticmethod
    def var(i, n):
        return SupportCircuit('var', var_index=i, n=n)

    @staticmethod
    def const(n):
        return SupportCircuit('const', n=n)

    @staticmethod
    def add(left, right):
        return SupportCircuit('add', [left, right], n=left.n)

    @staticmethod
    def mul(left, right):
        return SupportCircuit('mul', [left, right], n=left.n)

    @property
    def size(self):
        if self.kind in ('var', 'const'):
            return 1
        return 1 + sum(c.size for c in self.children)

    @property
    def depth(self):
        if self.kind in ('var', 'const'):
            return 0
        if self.kind == 'add':
            return max(c.depth for c in self.children)
        return 1 + max(c.depth for c in self.children)

    def eval(self):
        if self.kind == 'var':
            return frozenset([unit_vector(self.n, self.var_index)])
        if self.kind == 'const':
            return frozenset([zero_vector(self.n)])
        if self.kind == 'add':
            return self.children[0].eval() | self.children[1].eval()
        return support_mul(self.children[0].eval(), self.children[1].eval())


def enumerate_circuits_by_depth(n, max_size):
    """Generate circuits organized by depth."""
    by_size = {}
    atoms = [SupportCircuit.var(i, n) for i in range(n)]
    atoms.append(SupportCircuit.const(n))
    by_size[1] = atoms
    all_circuits = list(atoms)
    for s in range(3, max_size + 1):
        by_size[s] = []
        for s1 in range(1, s - 1):
            s2 = s - 1 - s1
            if s2 not in by_size or s1 not in by_size:
                continue
            for left in by_size[s1]:
                for right in by_size[s2]:
                    for op in ['add', 'mul']:
                        c = SupportCircuit.add(left, right) if op == 'add' else SupportCircuit.mul(left, right)
                        by_size[s].append(c)
                        all_circuits.append(c)
    return all_circuits


# ═══════════════════════════════════════════════════════════════
# FIGURE: Three-panel shadow entropy landscape
# ═══════════════════════════════════════════════════════════════

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))
fig.suptitle('Shadow Entropy Landscape for Polynomial Supports', fontsize=14, fontweight='bold')

# ─── Panel 1: Entropy vs Depth for circuits ───
ax1 = axes[0]
n = 3
circuits = enumerate_circuits_by_depth(n, 7)

depths = []
entropies = []
sizes = []

for C in circuits:
    S = C.eval()
    if not S:
        continue
    H = shadow_entropy(S)
    if H == float('-inf'):
        continue
    depths.append(C.depth)
    entropies.append(H)
    sizes.append(C.size)

scatter = ax1.scatter(depths, entropies, c=sizes, cmap='viridis', alpha=0.5, s=15, edgecolors='none')
plt.colorbar(scatter, ax=ax1, label='Circuit size')

# Plot the bound line
max_depth = max(depths) if depths else 3
d_range = np.linspace(0, max_depth, 100)
bound = (d_range + 1) * math.log(n)
ax1.plot(d_range, bound, 'r-', linewidth=2, label=f'Bound: (d+1)·ln({n})')
ax1.axhline(y=0, color='gray', linestyle='--', alpha=0.3)

ax1.set_xlabel('Multiplicative Depth', fontsize=11)
ax1.set_ylabel('Shadow Entropy H(S)', fontsize=11)
ax1.set_title(f'Circuit Entropy vs Depth (n={n})', fontsize=12)
ax1.legend(fontsize=9)

# ─── Panel 2: Permanent support entropy scaling ───
ax2 = axes[1]
ms = list(range(2, 6))
perm_entropies = []
perm_ratios = []
log_ms = []

for m in ms:
    S = permanent_support(m)
    H = shadow_entropy(S)
    r = entropy_ratio(S)
    perm_entropies.append(H)
    perm_ratios.append(r)
    log_ms.append(math.log(m))

ax2.bar(ms, perm_entropies, color='steelblue', alpha=0.7, label='H(Perm(m))')
ax2.plot(ms, log_ms, 'ro-', linewidth=2, markersize=8, label='ln(m)')
ax2.set_xlabel('Matrix size m', fontsize=11)
ax2.set_ylabel('Shadow Entropy', fontsize=11)
ax2.set_title('Permanent Support Entropy', fontsize=12)
ax2.legend(fontsize=9)

# Add ratio annotation
for i, m in enumerate(ms):
    ax2.annotate(f'ratio={perm_ratios[i]:.1f}', (m, perm_entropies[i]),
                textcoords="offset points", xytext=(0, 10), ha='center', fontsize=8)

# ─── Panel 3: Entropy ratio distribution ───
ax3 = axes[2]

# Generate random support families and compute entropy ratios
random.seed(42)
ratios_by_n = {}
for n_val in [2, 3, 4]:
    ratios = []
    for _ in range(200):
        # Random multilinear support of random size
        k = random.randint(1, min(20, 2**n_val))
        monomials = set()
        while len(monomials) < k:
            m = tuple(random.randint(0, 3) for _ in range(n_val))
            monomials.add(m)
        S = frozenset(monomials)
        r = entropy_ratio(S)
        if r > 0:
            ratios.append(r)
    ratios_by_n[n_val] = ratios

colors = ['#2196F3', '#FF9800', '#4CAF50']
for idx, (n_val, ratios) in enumerate(ratios_by_n.items()):
    ax3.hist(ratios, bins=30, alpha=0.5, color=colors[idx],
             label=f'n={n_val} (bound={n_val})', density=True)
    ax3.axvline(x=n_val, color=colors[idx], linestyle='--', linewidth=1.5)

ax3.set_xlabel('Entropy Ratio |Sh₁(S)|/|S|', fontsize=11)
ax3.set_ylabel('Density', fontsize=11)
ax3.set_title('Entropy Ratio Distribution', fontsize=12)
ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig('shadow_entropy_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: shadow_entropy_landscape.png")
