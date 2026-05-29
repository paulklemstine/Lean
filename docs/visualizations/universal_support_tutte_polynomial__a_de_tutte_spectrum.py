#!/usr/bin/env python3
"""
Visualization: Support-Tutte Polynomial Spectrum

Shows how the 4-parameter Tutte evaluation varies across different
support types for uniform matroid supports U(k,n). The heatmap reveals
how loop/coloop/ordinary activity structure creates distinct invariant
values, with the Power Law (a+b)^n as the diagonal baseline.
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

def tutte_4p(S, x=1, y=1, u=1, v=1):
    if not S.ground: return 1
    e = min(S.ground)
    if S.is_loop(e): return y * tutte_4p(S.delete(e), x, y, u, v)
    elif S.is_coloop(e): return x * tutte_4p(S.contract(e), x, y, u, v)
    else: return u * tutte_4p(S.delete(e), x, y, u, v) + v * tutte_4p(S.contract(e), x, y, u, v)

def uniform_matroid(n, k):
    supp = {tuple(1 if i in B else 0 for i in range(n)) for B in combinations(range(n), k)}
    return GroundSupport(frozenset(supp), frozenset(range(n)))

def simplex(n, d):
    def gen(rv, rs):
        if rv==1: yield (rs,); return
        for val in range(rs+1):
            for rest in gen(rv-1, rs-val): yield (val,)+rest
    return GroundSupport(frozenset(gen(n, d)), frozenset(range(n)))

# Compute T₄ for various (x,y) values with u=1, v=1
fig, axes = plt.subplots(2, 3, figsize=(15, 10))
fig.suptitle('Support-Tutte Spectrum T₄(x,y,1,1) for Different Supports', fontsize=14)

supports = [
    ("U(1,4)", uniform_matroid(4, 1)),
    ("U(2,4)", uniform_matroid(4, 2)),
    ("U(3,4)", uniform_matroid(4, 3)),
    ("Δ(4,1)", simplex(4, 1)),
    ("Δ(4,2)", simplex(4, 2)),
    ("Δ(4,3)", simplex(4, 3)),
]

x_vals = np.linspace(0.5, 4, 20)
y_vals = np.linspace(0.5, 4, 20)

for idx, (name, S) in enumerate(supports):
    ax = axes[idx // 3][idx % 3]
    Z = np.zeros((len(y_vals), len(x_vals)))
    for i, yv in enumerate(y_vals):
        for j, xv in enumerate(x_vals):
            Z[i, j] = tutte_4p(S, x=int(xv*100), y=int(yv*100), u=100, v=100) / (100**len(S.ground))

    im = ax.imshow(Z, extent=[0.5, 4, 0.5, 4], origin='lower', aspect='auto', cmap='viridis')
    ax.set_title(f'{name}  |supp|={len(S.supp)}', fontsize=11)
    ax.set_xlabel('x (coloop weight)')
    ax.set_ylabel('y (loop weight)')
    plt.colorbar(im, ax=ax, shrink=0.8)

plt.tight_layout()
plt.savefig('tutte_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved tutte_spectrum.png")
