#!/usr/bin/env python3
"""
Visualization: Integration Landscape

Shows how Phi varies as we interpolate between a disconnected and fully connected network.
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations

def cross_weight(W, S):
    n = W.shape[0]
    S_set = set(S)
    Sc = [i for i in range(n) if i not in S_set]
    cw = 0.0
    for i in S:
        for j in Sc:
            cw += W[i, j]
    for i in Sc:
        for j in S:
            cw += W[i, j]
    return cw

def phi(W):
    n = W.shape[0]
    if n < 2:
        return 0.0
    min_cw = float('inf')
    for k in range(1, n):
        for S in combinations(range(n), k):
            cw = cross_weight(W, S)
            min_cw = min(min_cw, cw)
    return min_cw

# Block-diagonal base network
n = 5
W_block = np.zeros((n, n))
# Block 1: nodes 0,1
W_block[0, 1] = 3; W_block[1, 0] = 2
# Block 2: nodes 2,3,4
W_block[2, 3] = 1; W_block[3, 2] = 2
W_block[3, 4] = 1; W_block[4, 3] = 3
W_block[2, 4] = 0.5; W_block[4, 2] = 1

# Cross-edges to add
W_cross = np.zeros((n, n))
W_cross[1, 2] = 1; W_cross[2, 0] = 1
W_cross[0, 3] = 0.5; W_cross[4, 1] = 0.5

# Interpolate
alphas = np.linspace(0, 3, 100)
phis = [phi(W_block + a * W_cross) for a in alphas]

fig, axes = plt.subplots(1, 2, figsize=(14, 5))

# Left: Phi vs alpha
ax = axes[0]
ax.plot(alphas, phis, 'b-', linewidth=2)
ax.axhline(y=0, color='r', linestyle='--', alpha=0.5, label='Disconnected (Φ=0)')
ax.set_xlabel('Cross-link strength α', fontsize=13)
ax.set_ylabel('Φ (Integrated Information)', fontsize=13)
ax.set_title('Phase Transition: Disconnected → Integrated', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Right: Integration profile for a specific network
ax = axes[1]
W_example = W_block + 1.5 * W_cross
profile = {}
for k in range(1, n):
    for S in combinations(range(n), k):
        profile[S] = cross_weight(W_example, S)

sorted_profile = sorted(profile.values())
ax.bar(range(len(sorted_profile)), sorted_profile, color='steelblue', alpha=0.7)
ax.axhline(y=phi(W_example), color='r', linestyle='--', linewidth=2, label=f'Φ = {phi(W_example):.2f}')
ax.set_xlabel('Bipartition index (sorted by cross-weight)', fontsize=13)
ax.set_ylabel('Cross-weight', fontsize=13)
ax.set_title('Integration Profile (α=1.5)', fontsize=14)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('integration_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved integration_landscape.png")
