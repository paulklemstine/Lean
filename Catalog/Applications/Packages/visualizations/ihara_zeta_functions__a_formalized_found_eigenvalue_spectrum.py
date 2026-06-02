#!/usr/bin/env python3
"""Visualization: Eigenvalue spectrum and Ramanujan bounds."""

import numpy as np
import matplotlib.pyplot as plt


def complete_graph(n):
    return np.ones((n, n)) - np.eye(n)


def cycle_graph(n):
    A = np.zeros((n, n))
    for i in range(n):
        A[i, (i+1) % n] = 1
        A[(i+1) % n, i] = 1
    return A


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


fig, axes = plt.subplots(2, 2, figsize=(12, 10))

graphs = [
    ("K₃ (q=1)", complete_graph(3), 1),
    ("K₄ (q=2)", complete_graph(4), 2),
    ("Petersen (q=2)", petersen_graph(), 2),
    ("C₈ (q=1)", cycle_graph(8), 1),
]

for idx, (name, A, q) in enumerate(graphs):
    ax = axes[idx // 2, idx % 2]
    evals = sorted(np.linalg.eigvalsh(A))
    bound = 2 * np.sqrt(q)
    degree = q + 1

    # Plot eigenvalues
    ax.scatter(evals, [0]*len(evals), s=100, c='blue', zorder=5, label='Eigenvalues')

    # Mark trivial eigenvalues
    ax.axvline(x=degree, color='green', linestyle=':', alpha=0.7, label=f'±(q+1) = ±{degree}')
    ax.axvline(x=-degree, color='green', linestyle=':', alpha=0.7)

    # Ramanujan bound
    ax.axvspan(-bound, bound, alpha=0.15, color='red', label=f'|λ| ≤ 2√{q} ≈ {bound:.2f}')

    # Check Ramanujan
    non_trivial = [ev for ev in evals if abs(abs(ev) - degree) > 1e-10]
    is_ram = all(abs(ev) <= bound + 1e-10 for ev in non_trivial)

    ax.set_title(f'{name} — {"Ramanujan ✓" if is_ram else "NOT Ramanujan ✗"}', fontsize=13)
    ax.set_xlabel('Eigenvalue λ')
    ax.set_yticks([])
    ax.legend(loc='upper left', fontsize=8)
    ax.set_xlim(min(evals) - 1, max(evals) + 1)

plt.suptitle('Graph Spectra and the Ramanujan Bound', fontsize=15, y=1.02)
plt.tight_layout()
plt.savefig('spectrum.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved spectrum.png")
