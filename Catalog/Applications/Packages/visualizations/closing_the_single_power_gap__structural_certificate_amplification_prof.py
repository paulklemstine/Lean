#!/usr/bin/env python3
"""
Visualization 2: Certificate Amplification Profile

Plots the certificate amplification profile A_F(k) for several exchange families
of increasing dimension. The profile reveals how much complexity is "visible"
at each certificate depth k.

A flat profile at the maximum means depth k captures everything.
A profile that rises steeply means hidden structure exists beyond low depths.

This visualization demonstrates the genuinely new invariant introduced in the paper.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict

# ─── Inline Implementation ───
class ExchangeFamily:
    def __init__(self, dim, states, measure, edges):
        self.dim = dim
        self.states = sorted(states)
        self.measure = measure
        self.adj = defaultdict(list)
        for (u, v) in edges:
            self.adj[u].append(v)

def adversarial_family(d, k=0):
    max_m = min(d ** max(1, d - k), d ** 3)
    states = list(range(max_m + 1))
    measure = {s: s for s in states}
    edges = set()
    for s in states:
        for delta in range(1, min(d + 1, s + 1)):
            edges.add((s, s - delta))
    return ExchangeFamily(d, states, measure, edges)

def amplification_profile(F, k):
    threshold = F.dim ** k
    eligible = [F.measure[s] for s in F.states if F.measure[s] <= threshold]
    return max(eligible) if eligible else 0

# ─── Compute and Plot ───
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

dims = [4, 5, 6, 7, 8]
cmap = plt.cm.viridis

for i, d in enumerate(dims):
    F = adversarial_family(d, k=0)
    worst = max(F.measure[s] for s in F.states)
    ks = list(range(d + 2))
    profiles = [amplification_profile(F, k) for k in ks]
    normalized = [p / worst if worst > 0 else 0 for p in profiles]

    color = cmap(i / (len(dims) - 1))
    ax1.plot(ks, profiles, color=color, marker='o', linewidth=2,
             markersize=6, label=f'd={d}')
    ax2.plot(ks, normalized, color=color, marker='s', linewidth=2,
             markersize=6, label=f'd={d}')

ax1.set_xlabel('Certificate Depth k', fontsize=13)
ax1.set_ylabel('Amplification Profile A(k)', fontsize=13)
ax1.set_title('Raw Amplification Profile', fontsize=14)
ax1.legend(fontsize=11)
ax1.grid(True, alpha=0.3)
ax1.set_yscale('log')

ax2.set_xlabel('Certificate Depth k', fontsize=13)
ax2.set_ylabel('A(k) / worst_case', fontsize=13)
ax2.set_title('Normalized Profile\n(reaches 1 when depth k captures all complexity)', fontsize=14)
ax2.axhline(y=1.0, color='red', linestyle='--', alpha=0.5, label='Full coverage')
ax2.legend(fontsize=11)
ax2.grid(True, alpha=0.3)
ax2.set_ylim(-0.05, 1.15)

fig.suptitle('Certificate Amplification Profile — The New Invariant', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('viz_amplification_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_amplification_profile.png")
