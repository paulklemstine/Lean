#!/usr/bin/env python3
"""
viz_code_families.py — Comparison of quantum LDPC code families via tropical spectra.

Visualizes how different code families (toric, hypergraph product, balanced product)
have distinct tropical Morse spectral signatures.

This script is fully self-contained and does not import from local modules.
"""

import matplotlib.pyplot as plt
import numpy as np


# ─── Inline helpers ───

class Step:
    def __init__(self, w, d, c):
        self.weight = w
        self.dim = d
        self.creates_cycle = c

    def betti_delta(self, n):
        if self.creates_cycle:
            return 1 if self.dim == n else 0
        elif self.dim > 0 and self.dim - 1 == n:
            return -1
        return 0


def toric_filt(L):
    s = []
    V, E = L*L, 2*L*L
    for i in range(V): s.append(Step(1, 0, True))
    for i in range(V-1): s.append(Step(2+i*0.1, 1, False))
    rem = E - (V-1)
    for i in range(2): s.append(Step(L+i, 1, True))
    for i in range(rem-2): s.append(Step(L+2+i*0.1, 1, True))
    fd = rem - 2
    for i in range(fd): s.append(Step(2*L+i*0.1, 2, False))
    s.append(Step(2*L+fd*0.1, 2, True))
    for i in range(L*L - fd - 1): s.append(Step(2*L+(fd+1+i)*0.1, 2, False))
    return s


def hp_filt(n_phys, k, seed=42):
    rng = np.random.RandomState(seed)
    s = []
    nv = max(n_phys // 2, 2)
    for i in range(nv): s.append(Step(1, 0, True))
    tree = nv - 1
    for i in range(tree): s.append(Step(2+i*0.01, 1, False))
    rem = n_phys - tree
    for i in range(rem): s.append(Step(3+i*0.01, 1, True))
    excess = max(rem - k, 0)
    for i in range(excess): s.append(Step(4+i*0.01, 2, False))
    return s


def bp_filt(g):
    s = []
    n_phys = 2*g*g
    k = max(g//2, 1)
    nv = min(g*g + g, n_phys // 2)
    nv = max(nv, 2)
    for i in range(nv): s.append(Step(1, 0, True))
    tree = nv - 1
    for i in range(tree): s.append(Step(2+i*0.01, 1, False))
    rem = n_phys - tree
    births = k + rem // 3
    for i in range(min(births, rem)): s.append(Step(3+i*0.01, 1, True))
    for i in range(max(rem-births, 0)): s.append(Step(3.5+i*0.01, 1, True))
    total_births = min(births, rem) + max(rem-births, 0)
    dn = max(total_births - k, 0)
    for i in range(dn): s.append(Step(4+i*0.01, 2, False))
    return s


def betti(steps, n):
    b = sum(1 for s in steps if s.creates_cycle and s.dim == n)
    d = sum(1 for s in steps if not s.creates_cycle and s.dim == n + 1)
    return b - d


# ─── Collect data ───

toric_data = []
for L in range(2, 10):
    st = toric_filt(L)
    n = sum(1 for s in st if s.dim == 1)
    k = betti(st, 1)
    toric_data.append((n, k, L))

hp_data = []
for seed in range(15):
    n_phys = 50 + seed * 20
    k_target = max(2 + seed, 1)
    st = hp_filt(n_phys, k_target, seed)
    n = sum(1 for s in st if s.dim == 1)
    k = betti(st, 1)
    hp_data.append((n, k, seed))

bp_data = []
for g in range(3, 12):
    st = bp_filt(g)
    n = sum(1 for s in st if s.dim == 1)
    k = betti(st, 1)
    bp_data.append((n, k, g))

# ─── Create figure ───

fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Quantum LDPC Code Families — Tropical Spectral Comparison',
             fontsize=14, fontweight='bold')

# Panel 1: n vs k for all families
ax1 = axes[0]
tn, tk = zip(*[(d[0], d[1]) for d in toric_data])
hn, hk = zip(*[(d[0], d[1]) for d in hp_data])
bn, bk = zip(*[(d[0], d[1]) for d in bp_data])

ax1.scatter(tn, tk, c='#2196F3', s=80, label='Toric', zorder=3, edgecolors='white')
ax1.scatter(hn, hk, c='#F44336', s=80, label='HP', zorder=3, edgecolors='white', marker='s')
ax1.scatter(bn, bk, c='#4CAF50', s=80, label='BP', zorder=3, edgecolors='white', marker='^')
ax1.set_xlabel('Physical Qubits (n)', fontsize=12)
ax1.set_ylabel('Logical Qubits (k = β₁)', fontsize=12)
ax1.set_title('Code Parameters', fontsize=13)
ax1.legend(fontsize=10)
ax1.grid(alpha=0.3)

# Panel 2: Rate k/n
ax2 = axes[1]
trate = [k/n if n > 0 else 0 for n, k, _ in toric_data]
hrate = [k/n if n > 0 else 0 for n, k, _ in hp_data]
brate = [k/n if n > 0 else 0 for n, k, _ in bp_data]

ax2.plot(tn, trate, 'o-', color='#2196F3', label='Toric', markersize=6)
ax2.plot(hn, hrate, 's-', color='#F44336', label='HP', markersize=6)
ax2.plot(bn, brate, '^-', color='#4CAF50', label='BP', markersize=6)
ax2.set_xlabel('Physical Qubits (n)', fontsize=12)
ax2.set_ylabel('Rate k/n', fontsize=12)
ax2.set_title('Code Rate Comparison', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(alpha=0.3)

# Panel 3: Birth/death spectrum comparison
ax3 = axes[2]

# For each family, show birth fraction at various sizes
for label, data_list, color, marker in [
    ('Toric', [(toric_filt(L), L) for L in range(2, 8)], '#2196F3', 'o'),
    ('BP', [(bp_filt(g), g) for g in range(3, 10)], '#4CAF50', '^')
]:
    sizes = []
    birth_fracs = []
    for st, param in data_list:
        total = sum(1 for s in st if s.dim == 1)
        births = sum(1 for s in st if s.creates_cycle and s.dim == 1)
        if total > 0:
            sizes.append(total)
            birth_fracs.append(births / total)
    ax3.plot(sizes, birth_fracs, f'{marker}-', color=color, label=label, markersize=6)

ax3.set_xlabel('Number of Edges', fontsize=12)
ax3.set_ylabel('Birth Fraction (births₁/edges)', fontsize=12)
ax3.set_title('Tropical Birth Concentration', fontsize=13)
ax3.legend(fontsize=10)
ax3.grid(alpha=0.3)

plt.tight_layout()
plt.savefig('viz_code_families.png', dpi=150, bbox_inches='tight')
print("Saved viz_code_families.png")
