#!/usr/bin/env python3
"""Visualization: Closed walk count growth vs Ramanujan bound."""

import numpy as np
import matplotlib.pyplot as plt


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def walk_counts(A, max_k):
    eigenvalues = np.linalg.eigvalsh(A)
    return [sum(ev**k for ev in eigenvalues) for k in range(max_k + 1)]


def petersen_graph():
    edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),
        (5,7),(7,9),(9,6),(6,8),(8,5),
        (0,5),(1,6),(2,7),(3,8),(4,9),
    ]
    A = np.zeros((10, 10))
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


max_k = 12
ks = range(max_k + 1)

fig, axes = plt.subplots(1, 3, figsize=(15, 5))

# K4 (3-regular, q=2)
A = complete_graph(4)
n, q = 4, 2
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[0].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'bo-', label='|tr(A^k)|', markersize=6)
axes[0].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[0].set_title('K₄: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[0].set_xlabel('Walk length k')
axes[0].set_ylabel('Count (log scale)')
axes[0].legend()
axes[0].grid(True, alpha=0.3)

# K5 (4-regular, q=3)
A = complete_graph(5)
n, q = 5, 3
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[1].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'go-', label='|tr(A^k)|', markersize=6)
axes[1].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[1].set_title('K₅: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[1].set_xlabel('Walk length k')
axes[1].set_ylabel('Count (log scale)')
axes[1].legend()
axes[1].grid(True, alpha=0.3)

# Petersen (3-regular, q=2)
A = petersen_graph()
n, q = 10, 2
counts = walk_counts(A, max_k)
bound = [n * (q+1)**k for k in ks]

axes[2].semilogy(ks, [abs(c) + 1e-10 for c in counts], 'mo-', label='|tr(A^k)|', markersize=6)
axes[2].semilogy(ks, bound, 'r--', label=f'n·(q+1)^k = {n}·{q+1}^k', linewidth=2)
axes[2].set_title('Petersen: Walk Counts vs Ramanujan Bound', fontsize=12)
axes[2].set_xlabel('Walk length k')
axes[2].set_ylabel('Count (log scale)')
axes[2].legend()
axes[2].grid(True, alpha=0.3)

plt.suptitle('Ramanujan Walk Bound: |tr(A^k)| ≤ n·(q+1)^k', fontsize=14, y=1.02)
plt.tight_layout()
plt.savefig('walk_growth.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved walk_growth.png")
