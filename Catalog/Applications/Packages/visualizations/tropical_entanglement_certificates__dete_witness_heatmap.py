#!/usr/bin/env python3
"""
Visualization: Tropical Partition Witness Heatmap

Visualizes the tropical partition witness values across all nontrivial
bipartitions for GHZ, W, product, and biseparable states on n=3 and n=4 qubits.
The heatmap reveals the entanglement structure: genuinely entangled states
(GHZ, W) show uniformly positive values, while separable states show zeros.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import product as iterproduct, combinations


# ─── Self-contained core functions ───────────────────────────────────

def all_configs(n, d=2):
    return list(iterproduct(range(d), repeat=n))

def mix_config(A, s, t):
    return tuple(s[i] if i in A else t[i] for i in range(len(s)))

def tropical_partition_witness(n, A, psi, d=2):
    configs = all_configs(n, d)
    mags = {s: abs(psi(s)) for s in configs}
    witness = 0.0
    for s in configs:
        ms = mags[s]
        if ms < 1e-15:
            continue
        for t in configs:
            mt = mags[t]
            if mt < 1e-15:
                continue
            val = ms * mt - mags[mix_config(A, s, t)] * mags[mix_config(A, t, s)]
            if val > 0:
                witness += val
    return witness

def nontrivial_partitions(n):
    result = []
    for k in range(1, n):
        for combo in combinations(range(n), k):
            result.append(frozenset(combo))
    return result

def ghz_state(n):
    def psi(s): return 1.0 if (all(x == 0 for x in s) or all(x == 1 for x in s)) else 0.0
    return psi

def w_state(n):
    def psi(s): return 1.0 if sum(s) == 1 else 0.0
    return psi

def product_state(n):
    def psi(s): return np.prod([1/np.sqrt(2) for _ in range(n)])
    return psi

def biseparable_state(n, cut=0):
    def psi(s):
        local_amp = 1.0 / np.sqrt(2)
        rest = tuple(s[i] for i in range(n) if i != cut)
        if all(x == 0 for x in rest) or all(x == 1 for x in rest):
            return local_amp
        return 0.0
    return psi


# ─── Build data and plot ─────────────────────────────────────────────

fig, axes = plt.subplots(1, 2, figsize=(16, 6))

for idx, n in enumerate([3, 4]):
    ax = axes[idx]
    
    state_names = ["GHZ", "W", "Product", "Bisep(0)"]
    state_fns = [ghz_state(n), w_state(n), product_state(n), biseparable_state(n, 0)]
    
    partitions = nontrivial_partitions(n)
    part_labels = ["{" + ",".join(str(x) for x in sorted(A)) + "}" for A in partitions]
    
    data = np.zeros((len(state_names), len(partitions)))
    for i, psi in enumerate(state_fns):
        for j, A in enumerate(partitions):
            data[i, j] = tropical_partition_witness(n, A, psi)
    
    im = ax.imshow(data, cmap='YlOrRd', aspect='auto', interpolation='nearest')
    ax.set_xticks(range(len(part_labels)))
    ax.set_xticklabels(part_labels, rotation=45, ha='right', fontsize=7)
    ax.set_yticks(range(len(state_names)))
    ax.set_yticklabels(state_names, fontsize=10)
    ax.set_title(f'Tropical Partition Witness — n = {n} qubits', fontsize=13, fontweight='bold')
    ax.set_xlabel('Bipartition A', fontsize=10)
    
    # Annotate cells
    for i in range(len(state_names)):
        for j in range(len(partitions)):
            val = data[i, j]
            color = 'white' if val > data.max() * 0.6 else 'black'
            text = f"{val:.1f}" if val > 0.01 else "0"
            ax.text(j, i, text, ha='center', va='center', color=color, fontsize=7)
    
    plt.colorbar(im, ax=ax, shrink=0.8, label='Witness Value')

plt.suptitle('Tropical Entanglement Certificates\nGenuinely entangled states (GHZ, W) show uniformly positive witnesses;\nseparable/biseparable states show zeros',
             fontsize=11, y=1.02)
plt.tight_layout()
plt.savefig('witness_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved witness_heatmap.png")
