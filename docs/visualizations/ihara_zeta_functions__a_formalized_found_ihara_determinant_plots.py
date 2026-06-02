#!/usr/bin/env python3
"""Visualization: Ihara determinant as a function of u for various graphs."""

import numpy as np
import matplotlib.pyplot as plt


def adjacency_matrix(edges, n):
    A = np.zeros((n, n))
    for i, j in edges:
        A[i, j] = 1.0
        A[j, i] = 1.0
    return A


def ihara_det_regular(A, q, u):
    n = A.shape[0]
    I = np.eye(n)
    M = (1 + q * u**2) * I - u * A
    return np.linalg.det(M)


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def cycle_graph(n):
    edges = [(i, (i+1) % n) for i in range(n)]
    return adjacency_matrix(edges, n)


def petersen_graph():
    edges = [
        (0,1),(1,2),(2,3),(3,4),(4,0),
        (5,7),(7,9),(9,6),(6,8),(8,5),
        (0,5),(1,6),(2,7),(3,8),(4,9),
    ]
    return adjacency_matrix(edges, 10)


fig, axes = plt.subplots(2, 2, figsize=(12, 10))
u_vals = np.linspace(-0.95, 0.95, 500)

# K3
A = complete_graph(3)
det_vals = [ihara_det_regular(A, 1, u) for u in u_vals]
axes[0,0].plot(u_vals, det_vals, 'b-', linewidth=2)
axes[0,0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0,0].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[0,0].set_title('K₃ (2-regular, q=1)', fontsize=14)
axes[0,0].set_xlabel('u')
axes[0,0].set_ylabel('det((1+u²)I - uA)')
axes[0,0].set_ylim(-5, 10)

# K4
A = complete_graph(4)
det_vals = [ihara_det_regular(A, 2, u) for u in u_vals]
axes[0,1].plot(u_vals, det_vals, 'r-', linewidth=2)
axes[0,1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0,1].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[0,1].set_title('K₄ (3-regular, q=2)', fontsize=14)
axes[0,1].set_xlabel('u')
axes[0,1].set_ylabel('det((1+2u²)I - uA)')
axes[0,1].set_ylim(-20, 50)

# Cycle C6
A = cycle_graph(6)
det_vals = [ihara_det_regular(A, 1, u) for u in u_vals]
axes[1,0].plot(u_vals, det_vals, 'g-', linewidth=2)
axes[1,0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1,0].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[1,0].set_title('C₆ (2-regular cycle, q=1)', fontsize=14)
axes[1,0].set_xlabel('u')
axes[1,0].set_ylabel('det((1+u²)I - uA)')
axes[1,0].set_ylim(-10, 30)

# Petersen
A = petersen_graph()
det_vals = [ihara_det_regular(A, 2, u) for u in u_vals]
axes[1,1].plot(u_vals, det_vals, 'm-', linewidth=2)
axes[1,1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1,1].axvline(x=0, color='gray', linestyle='--', alpha=0.5)
axes[1,1].set_title('Petersen (3-regular, q=2)', fontsize=14)
axes[1,1].set_xlabel('u')
axes[1,1].set_ylabel('det((1+2u²)I - uA)')
axes[1,1].set_ylim(-1e4, 5e4)

plt.suptitle('Ihara Determinant: Zeros = Poles of ζ_G(u)', fontsize=16, y=1.02)
plt.tight_layout()
plt.savefig('ihara_determinant.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved ihara_determinant.png")
