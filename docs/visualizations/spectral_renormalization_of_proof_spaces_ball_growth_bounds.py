#!/usr/bin/env python3
"""Visualization: Ball growth bounds comparison."""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from collections import defaultdict

def make_digraph(n, edges):
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
    return n, adj

def ball(n, adj, sources, k):
    current = set(sources)
    for _ in range(k):
        exp = set()
        for v in current:
            exp |= adj[v]
        current = current | exp
    return current

def main():
    # Binary tree
    n = 63
    edges = []
    for i in range(31):
        if 2*i+1 < n: edges.append((i, 2*i+1))
        if 2*i+2 < n: edges.append((i, 2*i+2))
    _, adj_tree = make_digraph(n, edges)

    # Random graph
    rng = np.random.default_rng(42)
    n2 = 200
    edges2 = []
    for v in range(n2):
        for w in rng.choice(n2, size=4, replace=False):
            if w != v:
                edges2.append((v, int(w)))
    _, adj_rand = make_digraph(n2, edges2)

    max_k = 8
    ks = list(range(max_k + 1))

    tree_sizes = [len(ball(n, adj_tree, {0}, k)) for k in ks]
    rand_sizes = [len(ball(n2, adj_rand, {0}, k)) for k in ks]
    upper_tree = [1 * 3**k for k in ks]
    upper_rand = [1 * 5**k for k in ks]

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.semilogy(ks, tree_sizes, 'o-', label='Actual |ball({0}, k)|', linewidth=2)
    ax1.semilogy(ks, upper_tree, 's--', label='Upper bound (d+1)^k', linewidth=2, alpha=0.7)
    ax1.set_xlabel('Steps k', fontsize=12)
    ax1.set_ylabel('Ball size (log scale)', fontsize=12)
    ax1.set_title('Binary Tree (d=2)', fontsize=14)
    ax1.legend(fontsize=11)
    ax1.grid(True, alpha=0.3)

    ax2.semilogy(ks, rand_sizes, 'o-', label='Actual |ball({0}, k)|', linewidth=2)
    ax2.semilogy(ks, upper_rand, 's--', label='Upper bound (d+1)^k', linewidth=2, alpha=0.7)
    ax2.set_xlabel('Steps k', fontsize=12)
    ax2.set_ylabel('Ball size (log scale)', fontsize=12)
    ax2.set_title('Random Graph (d≈4)', fontsize=14)
    ax2.legend(fontsize=11)
    ax2.grid(True, alpha=0.3)

    fig.suptitle('Ball Growth Bound: |ball(S, k)| ≤ |S| · (d+1)^k', fontsize=15, y=1.02)
    plt.tight_layout()
    plt.savefig('ball_growth.png', dpi=150, bbox_inches='tight')
    print("Saved ball_growth.png")

if __name__ == '__main__':
    main()
