#!/usr/bin/env python3
"""
Visualization 2: Sheaf-Theoretic Stability

Visualizes the ε-interleaving of sheaf profiles under perturbation (Theorem 3).
Shows:
- Original sheaf profile
- Perturbed sheaf profile
- ε-shifted envelopes demonstrating the interleaving inequality
- The gap between profiles bounded by the stability theorem

This illustrates that stability emerges from sheaf functoriality:
the pullback of the sheaf along the ε-shift map produces the interleaving.
"""

import matplotlib.pyplot as plt
import numpy as np
import random


def make_path_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def tropical_rank(adj, times, t):
    return sum(len(adj[v]) + 1 for v in adj if times[v] <= t)


# Parameters
n = 8
adj = make_path_graph(n)
times_orig = [float(i) for i in range(n)]

epsilon = 0.8
random.seed(42)
times_pert = [t + random.uniform(-epsilon, epsilon) for t in times_orig]

# Fine grid
t_fine = np.linspace(-2, n + 2, 2000)
profile_orig = [tropical_rank(adj, times_orig, t) for t in t_fine]
profile_pert = [tropical_rank(adj, times_pert, t) for t in t_fine]

# Shifted profiles for interleaving
profile_orig_shifted = [tropical_rank(adj, times_orig, t + epsilon) for t in t_fine]
profile_pert_shifted = [tropical_rank(adj, times_pert, t + epsilon) for t in t_fine]

fig, ax = plt.subplots(figsize=(14, 7))

# Plot ε-shifted envelopes
ax.fill_between(t_fine, profile_orig,
                [tropical_rank(adj, times_orig, t + epsilon) for t in t_fine],
                alpha=0.1, color='#2196F3', label='ε-envelope (original)')

# Main profiles
ax.step(t_fine, profile_orig, where='post', color='#2196F3', linewidth=2.5,
        label=f'Original Profile f', linestyle='-')
ax.step(t_fine, profile_pert, where='post', color='#E91E63', linewidth=2.5,
        label=f'Perturbed Profile g (ε={epsilon})', linestyle='-')

# ε-shifted original
ax.step(t_fine, profile_orig_shifted, where='post', color='#2196F3',
        linewidth=1.5, linestyle=':', alpha=0.6, label=f'f(t+ε)')
ax.step(t_fine, profile_pert_shifted, where='post', color='#E91E63',
        linewidth=1.5, linestyle=':', alpha=0.6, label=f'g(t+ε)')

# Mark sup distance
sup_dist = max(abs(times_orig[v] - times_pert[v]) for v in range(n))
ax.axhline(y=0, color='black', linewidth=0.5)

# Annotations
ax.set_xlabel('Threshold t', fontsize=13)
ax.set_ylabel('Sheaf Event Profile', fontsize=13)
ax.set_title(f'Sheaf-Theoretic Stability: ε-Interleaving of Tropical Profiles\n'
             f'Path Graph P₈, ε = {epsilon}, sup-dist = {sup_dist:.3f}',
             fontsize=14, fontweight='bold')

ax.legend(fontsize=10, loc='upper left', framealpha=0.9)
ax.grid(True, alpha=0.3)

# Add theorem statement
textstr = (f'Theorem 3: f(t) ≤ g(t+ε) and g(t) ≤ f(t+ε) for all t\n'
           f'Stability from sheaf functoriality, not ad hoc estimates')
props = dict(boxstyle='round', facecolor='lightyellow', alpha=0.8)
ax.text(0.98, 0.15, textstr, transform=ax.transAxes, fontsize=10,
        verticalalignment='bottom', horizontalalignment='right', bbox=props)

ax.set_xlim(-2, n + 2)
plt.tight_layout()
plt.savefig('viz_stability.png', dpi=150, bbox_inches='tight')
print("Saved viz_stability.png")
