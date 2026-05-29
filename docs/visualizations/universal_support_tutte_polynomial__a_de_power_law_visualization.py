#!/usr/bin/env python3
"""
Visualization: Power Law Theorem

The Power Law theorem states that for uniform deletion-contraction
coefficients, T(S; a, b) = (a+b)^|ground| regardless of the support
content. This plot shows the theorem in action: multiple supports with
the same ground size all produce the same curve, while the 4-parameter
evaluation T₄ breaks this degeneracy.
"""

import matplotlib.pyplot as plt
import numpy as np
from itertools import combinations

class GroundSupport:
    def __init__(self, supp, ground):
        self.supp = frozenset(supp)
        self.ground = frozenset(ground)
    def delete(self, e):
        return GroundSupport(frozenset(m for m in self.supp if m[e]==0), self.ground-{e})
    def min_coord(self, e):
        return min((m[e] for m in self.supp), default=0)
    def contract(self, e):
        mc = self.min_coord(e)
        return GroundSupport(frozenset(tuple(v-mc if j==e else v for j,v in enumerate(m))
                            for m in self.supp if m[e]==mc), self.ground-{e})
    def is_loop(self, e):
        return bool(self.supp) and all(m[e]>0 for m in self.supp)
    def is_coloop(self, e):
        return bool(self.supp) and len({m[e] for m in self.supp})==1

def tutte_uniform(S, a=1, b=1):
    if not S.ground: return 1
    e = min(S.ground)
    return a * tutte_uniform(S.delete(e), a, b) + b * tutte_uniform(S.contract(e), a, b)

def tutte_4p(S, x=1, y=1, u=1, v=1):
    if not S.ground: return 1
    e = min(S.ground)
    if S.is_loop(e): return y * tutte_4p(S.delete(e), x, y, u, v)
    elif S.is_coloop(e): return x * tutte_4p(S.contract(e), x, y, u, v)
    else: return u * tutte_4p(S.delete(e), x, y, u, v) + v * tutte_4p(S.contract(e), x, y, u, v)

def simplex(n, d):
    def gen(rv, rs):
        if rv==1: yield (rs,); return
        for val in range(rs+1):
            for rest in gen(rv-1, rs-val): yield (val,)+rest
    return GroundSupport(frozenset(gen(n, d)), frozenset(range(n)))

def uniform_matroid(n, k):
    supp = {tuple(1 if i in B else 0 for i in range(n)) for B in combinations(range(n), k)}
    return GroundSupport(frozenset(supp), frozenset(range(n)))

fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Support-Tutte Power Law vs Case-Dependent Invariant', fontsize=14, fontweight='bold')

# Left panel: Power Law — all supports with same |ground| collapse
a_vals = np.arange(1, 8)
n = 3

supports_n3 = [
    ("Δ(3,1)", simplex(3,1)),
    ("Δ(3,2)", simplex(3,2)),
    ("Δ(3,3)", simplex(3,3)),
    ("U(1,3)", uniform_matroid(3,1)),
    ("U(2,3)", uniform_matroid(3,2)),
    ("{(1,1,1)}", GroundSupport(frozenset({(1,1,1)}), frozenset({0,1,2}))),
]

markers = ['o', 's', '^', 'D', 'v', 'P']
colors = plt.cm.Set2(np.linspace(0, 1, len(supports_n3)))

for idx, (name, S) in enumerate(supports_n3):
    vals = [tutte_uniform(S, a, 1) for a in a_vals]
    ax1.plot(a_vals, vals, markers[idx], color=colors[idx], markersize=8,
             label=name, alpha=0.7)

# Theoretical curve
ax1.plot(a_vals, [(a+1)**n for a in a_vals], 'k--', linewidth=2,
         label=f'(a+1)^{n} (Power Law)', alpha=0.8)

ax1.set_xlabel('Deletion coefficient a (b=1)', fontsize=12)
ax1.set_ylabel('T(S; a, 1)', fontsize=12)
ax1.set_title('Uniform Coefficients: All Collapse to (a+1)³', fontsize=11)
ax1.legend(fontsize=8, loc='upper left')
ax1.set_yscale('log')
ax1.grid(True, alpha=0.3)

# Right panel: 4-parameter evaluation — supports separate
x_vals = np.arange(1, 8)

for idx, (name, S) in enumerate(supports_n3):
    vals = [tutte_4p(S, x=x, y=3, u=1, v=1) for x in x_vals]
    ax2.plot(x_vals, vals, f'{markers[idx]}-', color=colors[idx], markersize=8,
             label=name, alpha=0.7, linewidth=1.5)

ax2.set_xlabel('Coloop weight x (y=3, u=v=1)', fontsize=12)
ax2.set_ylabel('T₄(S; x, 3, 1, 1)', fontsize=12)
ax2.set_title('Case-Dependent: Supports Separate', fontsize=11)
ax2.legend(fontsize=8, loc='upper left')
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('power_law.png', dpi=150, bbox_inches='tight')
print("Saved power_law.png")
