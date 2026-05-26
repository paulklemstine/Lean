#!/usr/bin/env python3
"""
Visualization: Tropical Morse Spectrum of K₅ with distinct weights.

Shows the edge-weight filtration of the complete graph K₅ with weights 1..10.
As edges are added in weight order, we track:
  - Number of connected components (β₀, blue)
  - Cycle rank (β₁, red)
Each edge addition either merges two components (β₀ decreases) or creates
a cycle (β₁ increases) — the exclusive dichotomy theorem.

The vertical dashed line marks the first cycle birth — the tropical
lower bound on code distance.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compute_filtration_k5():
    """Compute Kruskal filtration for K₅ with weights 1..10."""
    # K₅ edges in weight order
    edges = [
        (0,1,1), (0,2,2), (0,3,3), (0,4,4), (1,2,5),
        (1,3,6), (1,4,7), (2,3,8), (2,4,9), (3,4,10)
    ]

    parent = list(range(5))
    rank = [0]*5

    def find(x):
        while parent[x] != x:
            parent[x] = parent[parent[x]]
            x = parent[x]
        return x

    def union(x, y):
        rx, ry = find(x), find(y)
        if rx == ry:
            return False
        if rank[rx] < rank[ry]:
            rx, ry = ry, rx
        parent[ry] = rx
        if rank[rx] == rank[ry]:
            rank[rx] += 1
        return True

    weights = [0]
    beta0 = [5]  # start with 5 isolated vertices
    beta1 = [0]
    events = []
    n_comp = 5

    for u, v, w in edges:
        if union(u, v):
            n_comp -= 1
            events.append(('merge', w))
        else:
            events.append(('cycle', w))
        weights.append(w)
        beta0.append(n_comp)
        beta1.append(len(edges) - (len(weights)-1) + n_comp)  # wrong
        # Actually β₁ = cycle count so far
    # Recompute β₁ correctly
    beta1 = [0]
    cycle_count = 0
    for ev_type, _ in events:
        if ev_type == 'cycle':
            cycle_count += 1
        beta1.append(cycle_count)

    return weights, beta0, beta1, events


def main():
    weights, beta0, beta1, events = compute_filtration_k5()

    fig, (ax1, ax2, ax3) = plt.subplots(3, 1, figsize=(10, 10), sharex=True)
    fig.suptitle('Tropical Morse Spectrum of K₅ (weights 1..10)',
                 fontsize=14, fontweight='bold')

    # Find first cycle birth
    fcb = None
    for ev_type, w in events:
        if ev_type == 'cycle':
            fcb = w
            break

    # Plot β₀
    ax1.step(weights, beta0, where='post', color='#2196F3', linewidth=2)
    ax1.fill_between(weights, beta0, step='post', alpha=0.1, color='#2196F3')
    ax1.set_ylabel('β₀ (components)', fontsize=12)
    ax1.set_ylim(0, 6)
    ax1.grid(True, alpha=0.3)
    ax1.set_title('Connected Components (β₀ decreases at merge events)')

    # Mark merge events
    for ev_type, w in events:
        if ev_type == 'merge':
            ax1.axvline(x=w, color='#2196F3', alpha=0.3, linestyle='--')

    # Plot β₁
    ax2.step(weights, beta1, where='post', color='#F44336', linewidth=2)
    ax2.fill_between(weights, beta1, step='post', alpha=0.1, color='#F44336')
    ax2.set_ylabel('β₁ (cycle rank)', fontsize=12)
    ax2.set_ylim(0, 7)
    ax2.grid(True, alpha=0.3)
    ax2.set_title('Cycle Rank (β₁ increases at cycle events = logical qubits)')

    # Mark cycle events
    for ev_type, w in events:
        if ev_type == 'cycle':
            ax2.axvline(x=w, color='#F44336', alpha=0.3, linestyle='--')

    if fcb is not None:
        ax2.axvline(x=fcb, color='green', linewidth=2, linestyle='-',
                   label=f'First cycle birth = {fcb}')
        ax2.legend(fontsize=11)

    # Combined event diagram
    for i, (ev_type, w) in enumerate(events):
        color = '#2196F3' if ev_type == 'merge' else '#F44336'
        marker = 'v' if ev_type == 'merge' else '^'
        label = ('Merge (β₀--)' if ev_type == 'merge' else 'Cycle (β₁++)') if i < 2 else None
        ax3.scatter(w, 0.5 if ev_type == 'cycle' else -0.5, c=color,
                   marker=marker, s=150, zorder=5, label=label)

    ax3.axhline(y=0, color='gray', linewidth=0.5)
    ax3.set_xlabel('Edge Weight (filtration parameter)', fontsize=12)
    ax3.set_ylabel('Event Type', fontsize=12)
    ax3.set_ylim(-1.5, 1.5)
    ax3.set_yticks([-0.5, 0.5])
    ax3.set_yticklabels(['Merge', 'Cycle'])
    ax3.grid(True, alpha=0.3)
    ax3.set_title('Tropical Morse Spectrum: Event Diagram')
    ax3.legend(fontsize=11)

    if fcb is not None:
        ax3.axvline(x=fcb, color='green', linewidth=2, linestyle='-', alpha=0.5)

    plt.tight_layout()
    plt.savefig('tropical_spectrum_k5.png', dpi=150, bbox_inches='tight')
    print("Saved: tropical_spectrum_k5.png")


if __name__ == "__main__":
    main()
