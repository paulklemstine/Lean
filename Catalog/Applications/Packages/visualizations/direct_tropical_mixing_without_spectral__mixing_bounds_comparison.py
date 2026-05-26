"""
Visualization: Tropical Mixing Bounds vs Empirical Mixing Times

Plots the certified tropical mixing bound against empirical mixing time
for Lorentzian-like polynomial state graphs of varying degree and dimension.
Demonstrates that the tropical bound is a valid (conservative) upper bound
that scales polynomially.

Output: viz_mixing_bounds.png
"""

import numpy as np
import matplotlib.pyplot as plt
from collections import defaultdict
from typing import Dict, List, Tuple


# ============================================================
# Self-contained implementations
# ============================================================

def gen_lattice_points(d, n):
    states = []
    def _gen(rem, dim, cur):
        if dim == 0:
            states.append(tuple(cur))
            return
        for i in range(rem + 1):
            _gen(rem - i, dim - 1, cur + [i])
    _gen(d, n, [])
    return states

def build_adj(states, n):
    s2i = {s: i for i, s in enumerate(states)}
    adj = defaultdict(list)
    for i, s in enumerate(states):
        for c in range(n):
            for d in [-1, 1]:
                nb = list(s); nb[c] += d; nbt = tuple(nb)
                if nbt in s2i:
                    j = s2i[nbt]
                    if j not in adj[i]: adj[i].append(j)
    return dict(adj)

def bfs_all(ns, adj):
    paths = {}
    for src in range(ns):
        dist = [-1]*ns; par = [-1]*ns; dist[src] = 0
        q = [src]; h = 0
        while h < len(q):
            u = q[h]; h += 1
            for v in adj.get(u, []):
                if dist[v] == -1:
                    dist[v] = dist[u]+1; par[v] = u; q.append(v)
        for t in range(ns):
            p = []; v = t
            while v != -1: p.append(v); v = par[v]
            p.reverse()
            paths[(src,t)] = p if dist[t] >= 0 else [src]
    return paths

def diam(paths):
    return max((len(p)-1 for p in paths.values()), default=0)

def cong(paths):
    load = defaultdict(int)
    for p in paths.values():
        for v in p: load[v] += 1
    return max(load.values(), default=0)

def cert_bound(c, d, pmin):
    return c * d * np.log(1.0/max(pmin, 1e-15))

def emp_mix(K, pi, th=0.25):
    n = K.shape[0]; worst = 0
    for s in range(min(n, 8)):
        dist = np.zeros(n); dist[s] = 1.0
        for t in range(1, 3001):
            dist = dist @ K
            if 0.5*np.sum(np.abs(dist-pi)) < th:
                worst = max(worst, t); break
        else: worst = max(worst, 3000)
    return worst

def analyze(d, n):
    states = gen_lattice_points(d, n)
    ns = len(states)
    adj = build_adj(states, n)
    paths = bfs_all(ns, adj)
    di = diam(paths); co = cong(paths)
    K = np.zeros((ns,ns))
    for i in range(ns):
        nbs = adj.get(i,[]); deg = len(nbs)
        K[i,i] = 0.5
        for j in nbs: K[i,j] += 0.5/max(deg,1)
    degs = np.array([max(len(adj.get(i,[])),1) for i in range(ns)], dtype=float)
    pi = degs/degs.sum(); pmin = pi.min()
    cb = cert_bound(co, di, pmin)
    em = emp_mix(K, pi)
    return {"d":d,"n":n,"ns":ns,"diam":di,"cong":co,"pmin":pmin,"cert":cb,"emp":em,"dn":d*n}

# ============================================================
# Generate data and plot
# ============================================================

results = []
for d in [2, 3, 4, 5]:
    for n in [2, 3, 4, 5]:
        if d*n > 15:
            continue
        r = analyze(d, n)
        results.append(r)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Plot 1: Certified bound vs empirical mixing time
ax1 = axes[0]
diams = [r['dn'] for r in results]
certs = [r['cert'] for r in results]
emps = [r['emp'] for r in results]

colors = {2:'#2196F3', 3:'#4CAF50', 4:'#FF9800', 5:'#E91E63'}
for r in results:
    ax1.scatter(r['emp'], r['cert'], c=colors.get(r['d'],'gray'),
               s=80, zorder=5, edgecolors='white', linewidth=0.5)

max_val = max(max(certs), max(emps)) * 1.1
ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, label='y = x')
ax1.set_xlabel('Empirical mixing time τ_mix', fontsize=11)
ax1.set_ylabel('Certified tropical bound', fontsize=11)
ax1.set_title('Certified Bound vs. Empirical Mixing', fontsize=12, fontweight='bold')
ax1.legend()
for d_val, color in colors.items():
    ax1.scatter([], [], c=color, s=60, label=f'd = {d_val}')
ax1.legend(fontsize=9)

# Plot 2: τ_mix vs tropical diameter (d*n)
ax2 = axes[1]
dns = [r['dn'] for r in results]
for r in results:
    ax2.scatter(r['dn'], r['emp'], c=colors.get(r['d'],'gray'),
               s=80, zorder=5, edgecolors='white', linewidth=0.5)
ax2.set_xlabel('d × n (tropical diameter bound)', fontsize=11)
ax2.set_ylabel('Empirical mixing time τ_mix', fontsize=11)
ax2.set_title('Mixing Time vs. Tropical Diameter', fontsize=12, fontweight='bold')

# Fit line
if dns:
    z = np.polyfit(dns, emps, 1)
    x_fit = np.linspace(min(dns), max(dns), 100)
    ax2.plot(x_fit, np.polyval(z, x_fit), 'r-', alpha=0.5, label=f'Linear fit')
    ax2.legend(fontsize=9)

# Plot 3: Congestion vs diameter
ax3 = axes[2]
dias = [r['diam'] for r in results]
congs = [r['cong'] for r in results]
for r in results:
    ax3.scatter(r['diam'], r['cong'], c=colors.get(r['d'],'gray'),
               s=80, zorder=5, edgecolors='white', linewidth=0.5)
ax3.set_xlabel('Tropical diameter D', fontsize=11)
ax3.set_ylabel('Vertex congestion C_v', fontsize=11)
ax3.set_title('Congestion vs. Diameter\n(Linear Mixing Conjecture)', fontsize=12, fontweight='bold')

if dias:
    z2 = np.polyfit(dias, congs, 1)
    x_fit2 = np.linspace(min(dias), max(dias), 100)
    ax3.plot(x_fit2, np.polyval(z2, x_fit2), 'r-', alpha=0.5,
             label=f'slope ≈ {z2[0]:.1f}')
    ax3.legend(fontsize=9)

plt.tight_layout()
plt.savefig('viz_mixing_bounds.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_mixing_bounds.png")
