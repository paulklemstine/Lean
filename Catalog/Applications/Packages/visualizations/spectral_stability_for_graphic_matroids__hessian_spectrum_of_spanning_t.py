#!/usr/bin/env python3
"""
Visualization 2: Hessian Spectrum of Spanning Tree Polynomials

Visualizes the eigenvalue structure of quadratic leaf Hessians for different
graph families. Shows the "one positive eigenvalue" Lorentzian signature
and how the spectral gap varies with algebraic connectivity.
"""

import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def graph_laplacian(adj):
    return np.diag(adj.sum(axis=1)) - adj

def algebraic_connectivity(L):
    evals = np.linalg.eigvalsh(L)
    evals.sort()
    return float(evals[1]) if len(evals) > 1 else 0.0

def edge_list(adj):
    n = adj.shape[0]
    return [(i,j) for i in range(n) for j in range(i+1,n) if adj[i,j]>0]

def enumerate_spanning_trees(adj):
    n = adj.shape[0]
    edges = edge_list(adj)
    m = len(edges)
    trees = []
    for combo in combinations(range(m), n-1):
        edge_set = [edges[i] for i in combo]
        adj_tree = {i: [] for i in range(n)}
        for u,v in edge_set:
            adj_tree[u].append(v)
            adj_tree[v].append(u)
        visited = set()
        stack = [0]
        while stack:
            node = stack.pop()
            if node not in visited:
                visited.add(node)
                stack.extend(nb for nb in adj_tree[node] if nb not in visited)
        if len(visited) == n:
            trees.append(combo)
    return trees, edges

def spanning_tree_poly_eval(adj, x):
    trees, edges = enumerate_spanning_trees(adj)
    return sum(np.prod([x[e] for e in tree]) for tree in trees)

def numerical_hessian(adj, x, eps=1e-5):
    edges = edge_list(adj)
    m = len(edges)
    H = np.zeros((m, m))
    for i in range(m):
        for j in range(i, m):
            ei, ej = np.zeros(m), np.zeros(m)
            ei[i], ej[j] = eps, eps
            fpp = spanning_tree_poly_eval(adj, x+ei+ej)
            fpm = spanning_tree_poly_eval(adj, x+ei-ej)
            fmp = spanning_tree_poly_eval(adj, x-ei+ej)
            fmm = spanning_tree_poly_eval(adj, x-ei-ej)
            H[i,j] = (fpp - fpm - fmp + fmm) / (4*eps**2)
            H[j,i] = H[i,j]
    return H

def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)

def cycle_graph(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i,(i+1)%n] = 1
        A[(i+1)%n,i] = 1
    return A

def path_graph(n):
    A = np.zeros((n, n))
    for i in range(n-1):
        A[i,i+1] = 1
        A[i+1,i] = 1
    return A


fig, axes = plt.subplots(2, 3, figsize=(15, 10))

graphs = [
    ("K_4", complete_graph(4)),
    ("K_5", complete_graph(5)),
    ("C_5", cycle_graph(5)),
    ("C_6", cycle_graph(6)),
    ("P_5", path_graph(5)),
    ("P_6", path_graph(6)),
]

for idx, (name, adj) in enumerate(graphs):
    ax = axes[idx // 3][idx % 3]
    
    edges = edge_list(adj)
    m = len(edges)
    L = graph_laplacian(adj)
    lam2 = algebraic_connectivity(L)
    
    # Compute Hessian at all-ones point
    x = np.ones(m)
    H = numerical_hessian(adj, x)
    evals = np.linalg.eigvalsh(H)
    evals_sorted = np.sort(evals)[::-1]
    
    # Color: positive eigenvalues red, negative blue
    colors_bar = ['#e74c3c' if e > 1e-8 else '#3498db' for e in evals_sorted]
    
    ax.bar(range(len(evals_sorted)), evals_sorted, color=colors_bar, alpha=0.8)
    ax.axhline(y=0, color='black', linewidth=0.8)
    
    # Mark the spectral gap
    if len(evals_sorted) >= 2:
        gap = abs(evals_sorted[1])
        ax.axhline(y=evals_sorted[1], color='orange', linewidth=1.5, linestyle='--', 
                   label=f'gap = {gap:.2f}')
    
    ax.set_title(f'{name}  (λ₂={lam2:.3f}, |E|={m})', fontsize=11, fontweight='bold')
    ax.set_xlabel('Eigenvalue index', fontsize=10)
    ax.set_ylabel('Eigenvalue', fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.2)

plt.suptitle('Hessian Spectrum of Spanning Tree Polynomials\n'
             'Red = positive eigenvalue (at most 1 for Lorentzian), Blue = negative',
             fontsize=13, fontweight='bold')
plt.tight_layout()
plt.savefig('hessian_spectrum.png', dpi=150, bbox_inches='tight')
print("Saved: hessian_spectrum.png")
