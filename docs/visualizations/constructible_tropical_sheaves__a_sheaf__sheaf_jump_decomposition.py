#!/usr/bin/env python3
"""
Visualization 3: Sheaf Jump Decomposition

Visualizes the degree-0 / degree-1 decomposition of sheaf jumps (Theorem 4),
comparing path graphs and cycle graphs side by side.

Shows:
- Stacked bar chart of deg-0 (vertex count) and deg-1 (edge density) jumps
- How the decomposition varies with graph structure
- Total Euler characteristic comparison

This illustrates the cross-domain bridge between sheaf theory and graph topology.
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


def compute_jumps(adj, times):
    crits = sorted(set(times))
    results = []
    for c in crits:
        verts_at_c = [v for v in adj if times[v] == c]
        d0 = len(verts_at_c)
        total = sum(len(adj[v]) + 1 for v in verts_at_c)
        d1 = total - d0
        results.append((c, d0, d1, total))
    return results


n = 8
times = list(range(n))

path_jumps = compute_jumps(make_path_graph(n), times)
cycle_jumps = compute_jumps(make_cycle_graph(n), times)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

for ax, jumps, title, colors in [
    (axes[0], path_jumps, f'Path Graph P₈', ['#42A5F5', '#1565C0']),
    (axes[1], cycle_jumps, f'Cycle Graph C₈', ['#EF5350', '#B71C1C']),
]:
    crits = [j[0] for j in jumps]
    d0 = [j[1] for j in jumps]
    d1 = [j[2] for j in jumps]
    totals = [j[3] for j in jumps]

    x = np.arange(len(crits))
    width = 0.6

    bars1 = ax.bar(x, d0, width, label='Degree-0 (vertex count)', color=colors[0], alpha=0.8)
    bars2 = ax.bar(x, d1, width, bottom=d0, label='Degree-1 (edge density)', color=colors[1], alpha=0.8)

    # Annotate totals
    for i, total in enumerate(totals):
        ax.text(i, total + 0.1, str(total), ha='center', va='bottom',
                fontweight='bold', fontsize=11)

    ax.set_xticks(x)
    ax.set_xticklabels([f'{int(c)}' for c in crits])
    ax.set_xlabel('Critical Value (vertex entrance time)', fontsize=11)
    ax.set_ylabel('Sheaf Jump', fontsize=11)
    ax.set_title(f'{title}\nJump Decomposition', fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(axis='y', alpha=0.3)

    euler = sum(totals)
    ax.text(0.95, 0.95, f'Euler χ = {euler}', transform=ax.transAxes,
            fontsize=12, va='top', ha='right',
            bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

# Add comparison annotation
fig.text(0.5, 0.01,
         'Theorem 4: sheafJump(c) = degree(v) + 1 for vertex v entering at c\n'
         'Path endpoints have jump 2, interior vertices have jump 3; '
         'cycle vertices all have jump 3',
         ha='center', fontsize=10, style='italic', color='#555')

plt.tight_layout(rect=[0, 0.06, 1, 1])
plt.savefig('viz_jump_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_jump_decomposition.png")
