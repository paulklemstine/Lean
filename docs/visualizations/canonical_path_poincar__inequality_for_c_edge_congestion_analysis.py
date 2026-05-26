#!/usr/bin/env python3
"""
Visualization: Edge Congestion Heatmap for Canonical Paths on S_n

Visualizes the distribution of edge congestion across different generators
and source vertices in the Cayley graph, showing how bubble-sort canonical
paths distribute load across the network.
"""

import itertools
import math
from collections import defaultdict
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def compose_perm(p, q):
    return tuple(p[q[i]] for i in range(len(p)))

def inverse_perm(p):
    n = len(p)
    inv = [0] * n
    for i in range(n):
        inv[p[i]] = i
    return tuple(inv)

def adj_transposition(n, j):
    p = list(range(n))
    p[j], p[j + 1] = p[j + 1], p[j]
    return tuple(p)

def bubble_sort_path(sigma):
    n = len(sigma)
    arr = list(sigma)
    swaps = []
    for i in range(n):
        for j in range(n - 1 - i):
            if arr[j] > arr[j + 1]:
                arr[j], arr[j + 1] = arr[j + 1], arr[j]
                swaps.append(j)
    swaps.reverse()
    return swaps

def canonical_path(x, y):
    x_inv = inverse_perm(x)
    delta = compose_perm(y, x_inv)
    return bubble_sort_path(delta)


def compute_edge_congestion_matrix(n):
    """Compute congestion matrix: rows = permutations, cols = generators."""
    perms = list(itertools.permutations(range(n)))
    perm_to_idx = {p: i for i, p in enumerate(perms)}
    num_gens = n - 1
    G_card = len(perms)
    
    matrix = np.zeros((G_card, num_gens))
    
    for x in perms:
        for y in perms:
            path = canonical_path(x, y)
            current = x
            for idx in range(len(path) - 1, -1, -1):
                g = path[idx]
                src_idx = perm_to_idx[current]
                matrix[src_idx, g] += 1
                t = adj_transposition(n, g)
                current = compose_perm(t, current)
    
    return matrix, perms


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    fig.suptitle('Edge Congestion in Canonical Path Systems on Sₙ', fontsize=16, fontweight='bold')
    
    for plot_idx, n in enumerate([3, 4, 5]):
        ax = axes[plot_idx]
        matrix, perms = compute_edge_congestion_matrix(n)
        
        # Aggregate by generator (show distribution of congestion per generator)
        congestion_per_gen = matrix.max(axis=0)
        avg_per_gen = matrix.mean(axis=0)
        
        gen_labels = [f'({j},{j+1})' for j in range(n-1)]
        x_pos = np.arange(n-1)
        width = 0.35
        
        bars1 = ax.bar(x_pos - width/2, congestion_per_gen, width, label='Max congestion', color='#e74c3c', alpha=0.8)
        bars2 = ax.bar(x_pos + width/2, avg_per_gen, width, label='Avg congestion', color='#3498db', alpha=0.8)
        
        ax.set_xlabel('Generator (transposition)', fontsize=12)
        ax.set_ylabel('Edge usage count', fontsize=12)
        ax.set_title(f'S_{n} (|G|={math.factorial(n)})', fontsize=14)
        ax.set_xticks(x_pos)
        ax.set_xticklabels(gen_labels)
        ax.legend(fontsize=10)
        
        # Add text annotations
        for bar in bars1:
            height = bar.get_height()
            ax.annotate(f'{int(height)}', xy=(bar.get_x() + bar.get_width()/2, height),
                       xytext=(0, 3), textcoords="offset points", ha='center', fontsize=9)
    
    plt.tight_layout()
    plt.savefig('congestion_heatmap.png', dpi=150, bbox_inches='tight')
    print("Saved congestion_heatmap.png")
    
    # Second figure: congestion growth
    fig2, ax2 = plt.subplots(figsize=(8, 6))
    ns = [3, 4, 5]
    kappas = []
    Ls = []
    
    for n in ns:
        matrix, _ = compute_edge_congestion_matrix(n)
        kappa = int(matrix.max())
        L = n * (n - 1) // 2
        kappas.append(kappa)
        Ls.append(L)
    
    ax2.semilogy(ns, kappas, 'ro-', linewidth=2, markersize=10, label='Congestion κ')
    ax2.semilogy(ns, [n**4 * 0.3 for n in ns], 'b--', linewidth=1, label='0.3·n⁴ (reference)')
    ax2.semilogy(ns, [n**8 * 0.0001 for n in ns], 'g--', linewidth=1, label='10⁻⁴·n⁸ (reference)')
    
    ax2.set_xlabel('n', fontsize=14)
    ax2.set_ylabel('Congestion κ', fontsize=14)
    ax2.set_title('Congestion Growth for Bubble-Sort Paths on Sₙ', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('congestion_growth.png', dpi=150, bbox_inches='tight')
    print("Saved congestion_growth.png")


if __name__ == "__main__":
    main()
