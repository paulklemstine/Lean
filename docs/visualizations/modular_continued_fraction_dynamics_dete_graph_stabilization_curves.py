#!/usr/bin/env python3
"""
Visualization: Graph Stabilization Curves
===========================================

Shows how the modular CF graph K_p(x, N) stabilizes as N grows.
For quadratic irrationals, both vertex count and edge count plateau
at a finite value determined by the period. For transcendentals,
the counts grow continuously (up to the p² bound).

This directly illustrates the main theorem: eventually periodic CF
coefficients produce eventually periodic graph invariants.
"""

import matplotlib.pyplot as plt
import numpy as np


def compute_graph_growth(coeffs_func, p, max_n=200):
    """Track vertex and edge count as window size N grows."""
    vertices = set()
    edges = set()
    vertex_counts = []
    edge_counts = []
    new_edge_counts = []

    p_prev, p_curr = 1 % p, coeffs_func(0) % p
    q_prev, q_curr = 0, 1 % p
    prev_pair = (p_curr, q_curr)
    vertices.add(prev_pair)
    vertex_counts.append(len(vertices))
    edge_counts.append(len(edges))
    new_edge_counts.append(0)

    for n in range(1, max_n):
        a = coeffs_func(n) % p
        p_new = (a * p_curr + p_prev) % p
        q_new = (a * q_curr + q_prev) % p
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new

        curr_pair = (p_curr, q_curr)
        vertices.add(curr_pair)
        old_edge_count = len(edges)
        edges.add((prev_pair, curr_pair))
        new_edges = len(edges) - old_edge_count
        prev_pair = curr_pair

        vertex_counts.append(len(vertices))
        edge_counts.append(len(edges))
        new_edge_counts.append(new_edges)

    return vertex_counts, edge_counts, new_edge_counts


# Define number sequences
def golden(n): return 1
def sqrt2(n): return 1 if n == 0 else 2
def sqrt3(n):
    if n == 0: return 1
    return 1 if n % 2 == 1 else 2
def euler_e(n):
    if n == 0: return 2
    if (n + 1) % 3 == 0: return 2 * ((n + 1) // 3)
    return 1

fig, axes = plt.subplots(2, 3, figsize=(18, 10))

primes = [5, 11, 23]
numbers = [
    ("φ (Golden Ratio)", golden, '#2196F3'),
    ("√2", sqrt2, '#4CAF50'),
    ("√3", sqrt3, '#FF9800'),
    ("e (transcendental)", euler_e, '#E91E63'),
]

max_n = 150

for col, p in enumerate(primes):
    ax_vert = axes[0][col]
    ax_edge = axes[1][col]

    for name, func, color in numbers:
        vcounts, ecounts, new_ecounts = compute_graph_growth(func, p, max_n)
        ns = range(len(vcounts))

        ax_vert.plot(ns, vcounts, color=color, linewidth=1.5, label=name, alpha=0.8)
        ax_edge.plot(ns, ecounts, color=color, linewidth=1.5, label=name, alpha=0.8)

    # Add p² bound line
    ax_vert.axhline(y=p**2, color='gray', linestyle=':', alpha=0.5, linewidth=1)
    ax_vert.text(max_n - 2, p**2 + 1, f'p²={p**2}', fontsize=8, color='gray',
                ha='right', va='bottom')

    ax_vert.set_title(f'p = {p}', fontsize=13, fontweight='bold')
    ax_vert.set_ylabel('Vertex Count' if col == 0 else '', fontsize=11)
    ax_vert.set_xlim(0, max_n)
    ax_vert.grid(True, alpha=0.3)
    if col == 0:
        ax_vert.legend(fontsize=8, loc='lower right')

    ax_edge.set_xlabel('Window Size N', fontsize=11)
    ax_edge.set_ylabel('Edge Count' if col == 0 else '', fontsize=11)
    ax_edge.set_xlim(0, max_n)
    ax_edge.grid(True, alpha=0.3)

# Add row labels
axes[0][0].set_ylabel('Vertices in K_p(x, N)', fontsize=12, fontweight='bold')
axes[1][0].set_ylabel('Edges in K_p(x, N)', fontsize=12, fontweight='bold')

fig.suptitle('Modular CF Graph Stabilization: K_p(x, N) as N Grows\n'
             'Quadratic irrationals stabilize; transcendentals keep growing',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 1, 0.93])
plt.savefig('viz_graph_stabilization.png', dpi=150, bbox_inches='tight')
print("Saved viz_graph_stabilization.png")
