#!/usr/bin/env python3
"""
Visualization: CSS Code Parameters from Chain Complexes
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def gf2_rank(matrix):
    if matrix.size == 0:
        return 0
    m = matrix.copy() % 2
    rows, cols = m.shape
    rank = 0
    for col in range(cols):
        pivot = None
        for row in range(rank, rows):
            if m[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        m[[rank, pivot]] = m[[pivot, rank]]
        for row in range(rows):
            if row != rank and m[row, col] == 1:
                m[row] = (m[row] + m[rank]) % 2
        rank += 1
    return rank


def make_toric_chain(L):
    n_v = L * L
    n_e = 2 * L * L
    def v(i, j):
        return (i % L) * L + (j % L)
    edges = []
    for i in range(L):
        for j in range(L):
            edges.append((v(i, j), v(i, (j+1)%L)))
            edges.append((v(i, j), v((i+1)%L, j)))
    d1 = np.zeros((n_v, n_e), dtype=int)
    for idx, (a, b) in enumerate(edges):
        d1[a, idx] ^= 1
        d1[b, idx] ^= 1
    n_f = L * L
    d2 = np.zeros((n_e, n_f), dtype=int)
    emap = {e: i for i, e in enumerate(edges)}
    for i in range(L):
        for j in range(L):
            fi = i * L + j
            d2[emap[(v(i,j), v(i,(j+1)%L))], fi] = 1
            d2[emap[(v(i,(j+1)%L), v((i+1)%L,(j+1)%L))], fi] = 1
            d2[emap[(v((i+1)%L,j), v((i+1)%L,(j+1)%L))], fi] = 1
            d2[emap[(v(i,j), v((i+1)%L,j))], fi] = 1
    return d1 % 2, d2 % 2


def plot_euler_characteristic():
    """Visualize the Euler characteristic relation β₁ + rank(∂₁) + rank(∂₂) = n."""
    fig, ax = plt.subplots(figsize=(10, 6))

    labels, bettis, rank1s, rank2s, totals = [], [], [], [], []

    # Repetition codes
    for nq in [3, 5, 7, 9]:
        d1 = np.zeros((nq - 1, nq), dtype=int)
        for i in range(nq - 1):
            d1[i, i] = 1; d1[i, i+1] = 1
        d2 = np.zeros((nq, 0), dtype=int)
        r1 = gf2_rank(d1)
        r2 = 0
        n1 = nq
        betti = n1 - r1 - r2
        labels.append(f'Rep({nq})')
        bettis.append(betti); rank1s.append(r1); rank2s.append(r2); totals.append(n1)

    # Toric codes
    for L in [2, 3, 4]:
        d1, d2 = make_toric_chain(L)
        r1 = gf2_rank(d1)
        r2 = gf2_rank(d2)
        n1 = d1.shape[1]
        betti = n1 - r1 - r2
        labels.append(f'Toric({L})')
        bettis.append(betti); rank1s.append(r1); rank2s.append(r2); totals.append(n1)

    x = np.arange(len(labels))
    width = 0.25

    ax.bar(x - width, bettis, width, label='β₁ (logical qubits)', color='#2196F3')
    ax.bar(x, rank1s, width, label='rank(∂₁)', color='#FF9800')
    ax.bar(x + width, rank2s, width, label='rank(∂₂)', color='#4CAF50')
    ax.plot(x, totals, 'kD-', linewidth=2, markersize=8, label='n₁ (total)', zorder=5)

    ax.set_xlabel('Code', fontsize=12)
    ax.set_ylabel('Dimension', fontsize=12)
    ax.set_title('Euler Characteristic: β₁ + rank(∂₁) + rank(∂₂) = n₁', fontsize=14, fontweight='bold')
    ax.set_xticks(x)
    ax.set_xticklabels(labels, rotation=45, ha='right')
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('euler_characteristic.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved euler_characteristic.png")


def plot_toric_scaling():
    """Plot how toric code parameters scale with lattice size."""
    sizes = list(range(2, 8))
    ns, ks = [], []
    for L in sizes:
        n_e = 2 * L * L
        # For torus: β₁ = 2 always, rank(d1) = L²-1, rank(d2) = L²-1, n = 2L²
        # Verify for small sizes
        d1, d2 = make_toric_chain(L)
        r1 = gf2_rank(d1)
        r2 = gf2_rank(d2)
        betti = n_e - r1 - r2
        ns.append(n_e)
        ks.append(betti)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(10, 4))

    ax1.plot(sizes, ns, 'bo-', linewidth=2, markersize=8)
    ax1.set_xlabel('Lattice size L')
    ax1.set_ylabel('Physical qubits n = 2L²')
    ax1.set_title('Physical Qubits Scale Quadratically')
    ax1.grid(True, alpha=0.3)

    ax2.plot(sizes, ks, 'rs-', linewidth=2, markersize=8)
    ax2.set_xlabel('Lattice size L')
    ax2.set_ylabel('Logical qubits k = β₁')
    ax2.set_title('Logical Qubits = Topological Invariant')
    ax2.set_ylim(0, 4)
    ax2.grid(True, alpha=0.3)

    plt.suptitle('Toric Code: Topology Determines Quantum Parameters', fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig('toric_code_scaling.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved toric_code_scaling.png")


if __name__ == "__main__":
    plot_euler_characteristic()
    plot_toric_scaling()
    print("\nAll visualizations saved!")
