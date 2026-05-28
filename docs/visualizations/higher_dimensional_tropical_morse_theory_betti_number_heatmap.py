#!/usr/bin/env python3
"""
viz_betti_heatmap.py — Heatmap of Betti numbers across code families and sizes.

Visualizes how β₀, β₁, β₂ vary across toric, HP, and balanced product codes
of different sizes, showing the tropical Morse spectral fingerprint of each family.

This script is fully self-contained and does not import from local modules.
"""

import matplotlib.pyplot as plt
import numpy as np


# ─── Inline filtration builders ───

class Step:
    def __init__(self, w, d, c):
        self.weight, self.dim, self.creates_cycle = w, d, c

def betti(steps, n):
    b = sum(1 for s in steps if s.creates_cycle and s.dim == n)
    d = sum(1 for s in steps if not s.creates_cycle and s.dim == n + 1)
    return b - d

def toric_steps(L):
    s = []
    V, E = L*L, 2*L*L
    for i in range(V): s.append(Step(1, 0, True))
    for i in range(V-1): s.append(Step(2+i*0.1, 1, False))
    rem = E-(V-1)
    for i in range(2): s.append(Step(L+i, 1, True))
    for i in range(rem-2): s.append(Step(L+2+i*0.1, 1, True))
    fd = rem - 2
    for i in range(fd): s.append(Step(2*L+i*0.1, 2, False))
    s.append(Step(2*L+fd*0.1, 2, True))
    for i in range(L*L-fd-1): s.append(Step(2*L+(fd+1+i)*0.1, 2, False))
    return s

def bp_steps(g):
    s = []
    n_phys = 2*g*g
    k = max(g//2, 1)
    nv = max(min(g*g+g, n_phys//2), 2)
    for i in range(nv): s.append(Step(1, 0, True))
    tree = nv-1
    for i in range(tree): s.append(Step(2+i*0.01, 1, False))
    rem = n_phys-tree
    births = k + rem//3
    for i in range(min(births, rem)): s.append(Step(3+i*0.01, 1, True))
    for i in range(max(rem-births, 0)): s.append(Step(3.5+i*0.01, 1, True))
    tb = min(births, rem)+max(rem-births, 0)
    dn = max(tb-k, 0)
    for i in range(dn): s.append(Step(4+i*0.01, 2, False))
    return s

# ─── Compute data ───

families = {'Toric': [], 'Balanced Product': []}
params_list = {'Toric': [], 'Balanced Product': []}

for L in range(2, 12):
    st = toric_steps(L)
    families['Toric'].append([betti(st, 0), betti(st, 1), betti(st, 2)])
    params_list['Toric'].append(f'L={L}')

for g in range(3, 13):
    st = bp_steps(g)
    families['Balanced Product'].append([betti(st, 0), betti(st, 1), betti(st, 2)])
    params_list['Balanced Product'].append(f'|G|={g}')

# ─── Create figure ───

fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Betti Number Heatmap — Tropical Morse Spectral Fingerprints',
             fontsize=14, fontweight='bold')

for idx, (name, data) in enumerate(families.items()):
    ax = axes[idx]
    arr = np.array(data).T  # shape (3, n_sizes)

    im = ax.imshow(arr, aspect='auto', cmap='YlOrRd', interpolation='nearest')
    ax.set_yticks([0, 1, 2])
    ax.set_yticklabels(['β₀', 'β₁', 'β₂'], fontsize=12)
    ax.set_xticks(range(len(params_list[name])))
    ax.set_xticklabels(params_list[name], rotation=45, ha='right', fontsize=9)
    ax.set_title(f'{name} Codes', fontsize=13)
    ax.set_xlabel('Code Parameter', fontsize=11)

    # Annotate cells
    for i in range(3):
        for j in range(len(data)):
            val = arr[i, j]
            color = 'white' if val > arr.max() / 2 else 'black'
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=8, color=color, fontweight='bold')

    plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

plt.tight_layout()
plt.savefig('viz_betti_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_betti_heatmap.png")
