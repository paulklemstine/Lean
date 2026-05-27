#!/usr/bin/env python3
"""
Visualization 1: Constructible Sheaf Profile

Visualizes the tropical rank sheaf as a step function on the threshold line,
showing:
- The stalk rank at each threshold (step function)
- Critical values as vertical dashed lines
- Sheaf jumps as colored annotations
- Comparison between path graph and cycle graph

This illustrates Theorem 1 (constructibility) and Theorem 2 (event profile recovery).
"""

import matplotlib.pyplot as plt
import numpy as np


def make_path_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def make_cycle_graph(n):
    adj = {i: set() for i in range(n)}
    for i in range(n):
        adj[i].add((i + 1) % n)
        adj[(i + 1) % n].add(i)
    return adj


def tropical_rank(adj, times, t):
    return sum(len(adj[v]) + 1 for v in adj if times[v] <= t)


def sheaf_jump(adj, times, c):
    return sum(len(adj[v]) + 1 for v in adj if times[v] == c)


# Parameters
n = 7
times = list(range(n))
crits = sorted(set(times))

adj_path = make_path_graph(n)
adj_cycle = make_cycle_graph(n)

# Compute profiles
t_fine = np.linspace(-1, n + 0.5, 1000)
rank_path = [tropical_rank(adj_path, times, t) for t in t_fine]
rank_cycle = [tropical_rank(adj_cycle, times, t) for t in t_fine]

# Plot
fig, axes = plt.subplots(2, 1, figsize=(12, 8), sharex=True)

for ax, adj, ranks, name, color in [
    (axes[0], adj_path, rank_path, f'Path Graph P₇', '#2196F3'),
    (axes[1], adj_cycle, rank_cycle, f'Cycle Graph C₇', '#E91E63'),
]:
    ax.step(t_fine, ranks, where='post', color=color, linewidth=2.5, label='Tropical Rank (Stalk)')

    # Mark critical values
    for c in crits:
        j = sheaf_jump(adj, times, c)
        ax.axvline(x=c, color='gray', linestyle='--', alpha=0.4, linewidth=1)
        rank_at_c = tropical_rank(adj, times, c)
        ax.annotate(f'Δ={j}', xy=(c, rank_at_c), xytext=(c + 0.15, rank_at_c + 0.8),
                    fontsize=9, color='darkred', fontweight='bold',
                    arrowprops=dict(arrowstyle='->', color='darkred', lw=1.2))

    # Shade gaps between critical values
    for i in range(len(crits) - 1):
        ax.axvspan(crits[i] + 0.01, crits[i + 1] - 0.01, alpha=0.06, color=color)

    ax.set_ylabel('Tropical Rank', fontsize=12)
    ax.set_title(f'{name} — Constructible Tropical Rank Sheaf', fontsize=14, fontweight='bold')
    ax.legend(fontsize=11, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-1, n + 0.5)

    # Annotate constructibility
    if adj == adj_path:
        ax.text(0.5, 0.95, 'Rank constant between critical values (Theorem 1)',
                transform=ax.transAxes, fontsize=10, va='top', ha='left',
                style='italic', color='#555')

axes[1].set_xlabel('Threshold t', fontsize=12)

plt.tight_layout()
plt.savefig('viz_sheaf_profile.png', dpi=150, bbox_inches='tight')
print("Saved viz_sheaf_profile.png")
