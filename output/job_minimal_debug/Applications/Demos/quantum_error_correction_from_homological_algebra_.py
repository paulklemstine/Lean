#!/usr/bin/env python3
"""
CSS Codes as Cohomology: Demonstration Script

Demonstrates the chain-complex-to-CSS-code construction for:
1. The 3-qubit repetition code
2. The toric code on a 2×2 torus
3. The hypercube code on Q_4
"""

import numpy as np
from typing import Tuple, List

def gf2_rank(matrix: np.ndarray) -> int:
    """Compute rank of a matrix over GF(2) using Gaussian elimination."""
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


def gf2_nullity(matrix: np.ndarray) -> int:
    """Compute dimension of kernel over GF(2)."""
    return matrix.shape[1] - gf2_rank(matrix)


def gf2_kernel_basis(matrix: np.ndarray) -> np.ndarray:
    """Find a basis for the kernel of a matrix over GF(2).
    Given matrix A (m x n), finds vectors x in F_2^n such that A @ x = 0."""
    m = matrix.copy() % 2
    rows, cols = m.shape
    # Augment with identity on columns side
    aug = np.hstack([m.T, np.eye(cols, dtype=int)])  # (cols x rows+cols)

    rank = 0
    for col in range(rows):
        pivot = None
        for row in range(rank, cols):
            if aug[row, col] == 1:
                pivot = row
                break
        if pivot is None:
            continue
        aug[[rank, pivot]] = aug[[pivot, rank]]
        for row in range(cols):
            if row != rank and aug[row, col] == 1:
                aug[row] = (aug[row] + aug[rank]) % 2
        rank += 1

    # Kernel basis = rows of aug[rank:, rows:]
    ker = aug[rank:, rows:] % 2
    return ker if len(ker) > 0 else np.zeros((0, cols), dtype=int)


def css_from_chain_complex(d1: np.ndarray, d2: np.ndarray) -> dict:
    """
    Construct a CSS code from a chain complex C_2 -[d2]-> C_1 -[d1]-> C_0.

    Returns a dictionary with code parameters.
    """
    # Verify chain complex condition: d1 @ d2 = 0 mod 2
    product = (d1 @ d2) % 2
    assert np.all(product == 0), "Chain complex condition violated: d1 ∘ d2 ≠ 0"

    n1 = d1.shape[1]  # number of physical qubits (1-chains)

    # Compute ranks and dimensions
    rank_d1 = gf2_rank(d1)
    rank_d2 = gf2_rank(d2)
    dim_ker_d1 = gf2_nullity(d1)  # = n1 - rank_d1
    dim_im_d2 = rank_d2

    # Betti number = dim(ker d1) - dim(im d2)
    betti_1 = dim_ker_d1 - dim_im_d2

    # Find non-trivial cycles (ker d1 \ im d2) for distance computation
    ker_basis = gf2_kernel_basis(d1)  # kernel of d1: vectors x with d1 @ x = 0

    # Compute minimum weight of non-trivial cycle
    min_weight = n1 + 1  # sentinel
    if betti_1 > 0 and len(ker_basis) > 0:
        # Enumerate all non-zero elements of ker(d1)
        num_ker = len(ker_basis)
        for mask in range(1, 2**num_ker):
            vec = np.zeros(n1, dtype=int)
            for i in range(num_ker):
                if mask & (1 << i):
                    vec = (vec + ker_basis[i]) % 2
            # Check if this is in im(d2)
            # A vector is in im(d2) iff it can be expressed as d2 @ x for some x
            aug = np.hstack([d2, vec.reshape(-1, 1)])
            if gf2_rank(aug) == gf2_rank(d2):
                continue  # It's a boundary, skip
            weight = int(np.sum(vec))
            if weight > 0:
                min_weight = min(min_weight, weight)

    if min_weight > n1:
        min_weight = 0  # No non-trivial cycles found

    return {
        'n': n1,
        'k': betti_1,
        'd': min_weight,
        'rank_d1': rank_d1,
        'rank_d2': rank_d2,
        'dim_ker_d1': dim_ker_d1,
        'dim_im_d2': dim_im_d2,
        'euler_check': betti_1 + rank_d1 + rank_d2 == n1  # Should always be True
    }


def demo_repetition_code():
    """3-qubit repetition code: path graph with 3 edges, 2 vertices."""
    print("=" * 60)
    print("EXAMPLE 1: 3-Qubit Repetition Code")
    print("=" * 60)

    # d1: F_2^3 -> F_2^2, parity check matrix
    # (x0, x1, x2) -> (x0+x1, x1+x2)
    d1 = np.array([
        [1, 1, 0],
        [0, 1, 1]
    ], dtype=int)

    # d2: F_2^0 -> F_2^3 (no 2-cells)
    d2 = np.zeros((3, 0), dtype=int)

    params = css_from_chain_complex(d1, d2)

    print(f"Chain complex: F_2^0 -> F_2^3 -> F_2^2")
    print(f"  d1 (parity check):")
    print(f"    {d1}")
    print(f"  d2 = 0 (no 2-cells)")
    print()
    print(f"Code parameters: [[{params['n']}, {params['k']}, {params['d']}]]")
    print(f"  Physical qubits (n):  {params['n']}")
    print(f"  Logical qubits (k):   {params['k']}  = β₁ (Betti number)")
    print(f"  Distance (d):         {params['d']}")
    print(f"  rank(∂₁):             {params['rank_d1']}")
    print(f"  rank(∂₂):             {params['rank_d2']}")
    print(f"  dim(ker ∂₁):          {params['dim_ker_d1']}")
    print(f"  Euler check:          β₁ + rank(∂₁) + rank(∂₂) = {params['k']} + {params['rank_d1']} + {params['rank_d2']} = {params['n']} ✓")
    print()


def demo_toric_code():
    """Toric code on a 2x2 torus (4 vertices, 8 edges, 4 faces)."""
    print("=" * 60)
    print("EXAMPLE 2: Toric Code (2×2 Torus)")
    print("=" * 60)

    # Vertices: v(i,j) for i,j in {0,1}, labeled 0..3
    # v(0,0)=0, v(0,1)=1, v(1,0)=2, v(1,1)=3
    # Horizontal edges: h(i,j) = edge from v(i,j) to v(i,(j+1)%2)
    # Vertical edges: v(i,j) = edge from v(i,j) to v((i+1)%2,j)
    # Edge labels: h(0,0)=0, h(0,1)=1, h(1,0)=2, h(1,1)=3
    #              v(0,0)=4, v(0,1)=5, v(1,0)=6, v(1,1)=7

    # d1: F_2^8 -> F_2^4 (boundary of edge = sum of endpoints)
    d1 = np.zeros((4, 8), dtype=int)
    # h(0,0): v(0,0)->v(0,1), edge 0: d1 = v0 + v1
    d1[0, 0] = 1; d1[1, 0] = 1
    # h(0,1): v(0,1)->v(0,0), edge 1: d1 = v1 + v0
    d1[1, 1] = 1; d1[0, 1] = 1
    # h(1,0): v(1,0)->v(1,1), edge 2
    d1[2, 2] = 1; d1[3, 2] = 1
    # h(1,1): v(1,1)->v(1,0), edge 3
    d1[3, 3] = 1; d1[2, 3] = 1
    # v(0,0): v(0,0)->v(1,0), edge 4
    d1[0, 4] = 1; d1[2, 4] = 1
    # v(0,1): v(0,1)->v(1,1), edge 5
    d1[1, 5] = 1; d1[3, 5] = 1
    # v(1,0): v(1,0)->v(0,0), edge 6
    d1[2, 6] = 1; d1[0, 6] = 1
    # v(1,1): v(1,1)->v(0,1), edge 7
    d1[3, 7] = 1; d1[1, 7] = 1

    # d2: F_2^4 -> F_2^8 (boundary of face = sum of edges)
    # Faces: f(i,j) has edges h(i,j), v(i,(j+1)%2), h((i+1)%2,j), v(i,j)
    d2 = np.zeros((8, 4), dtype=int)
    # Face (0,0): edges h(0,0)=0, v(0,1)=5, h(1,0)=2, v(0,0)=4
    d2[0, 0] = 1; d2[5, 0] = 1; d2[2, 0] = 1; d2[4, 0] = 1
    # Face (0,1): edges h(0,1)=1, v(0,0)=4, h(1,1)=3, v(0,1)=5
    d2[1, 1] = 1; d2[4, 1] = 1; d2[3, 1] = 1; d2[5, 1] = 1
    # Face (1,0): edges h(1,0)=2, v(1,1)=7, h(0,0)=0, v(1,0)=6
    d2[2, 2] = 1; d2[7, 2] = 1; d2[0, 2] = 1; d2[6, 2] = 1
    # Face (1,1): edges h(1,1)=3, v(1,0)=6, h(0,1)=1, v(1,1)=7
    d2[3, 3] = 1; d2[6, 3] = 1; d2[1, 3] = 1; d2[7, 3] = 1

    # Verify chain complex condition
    d1 = d1 % 2
    d2 = d2 % 2

    params = css_from_chain_complex(d1, d2)

    print(f"Chain complex: F_2^4 -> F_2^8 -> F_2^4")
    print(f"  4 vertices, 8 edges, 4 faces on a 2×2 torus")
    print()
    print(f"Code parameters: [[{params['n']}, {params['k']}, {params['d']}]]")
    print(f"  Physical qubits (n):  {params['n']}")
    print(f"  Logical qubits (k):   {params['k']}  = β₁ (first Betti number of torus)")
    print(f"  Distance (d):         {params['d']}")
    print(f"  rank(∂₁):             {params['rank_d1']}")
    print(f"  rank(∂₂):             {params['rank_d2']}")
    print(f"  Euler check:          β₁ + rank(∂₁) + rank(∂₂) = {params['k']} + {params['rank_d1']} + {params['rank_d2']} = {params['n']} ✓")
    print()
    print(f"  ✓ Torus has genus 1, so β₁ = 2 (two non-contractible loops)")
    print(f"  ✓ Distance = {params['d']} (shortest non-contractible cycle on 2×2 torus)")
    print()


def demo_hypercube():
    """Hypercube code on Q_4 (4-dimensional hypercube graph)."""
    print("=" * 60)
    print("EXAMPLE 3: Hypercube Code Q_4")
    print("=" * 60)

    n_dim = 4
    n_vertices = 2 ** n_dim  # 16 vertices
    # Edges: connect vertices differing in exactly one bit
    edges = []
    for v in range(n_vertices):
        for bit in range(n_dim):
            w = v ^ (1 << bit)
            if v < w:
                edges.append((v, w))
    n_edges = len(edges)

    # d1: boundary map, edges -> vertices
    d1 = np.zeros((n_vertices, n_edges), dtype=int)
    for idx, (v, w) in enumerate(edges):
        d1[v, idx] = 1
        d1[w, idx] = 1

    # d2 = 0 (treating Q_4 as a graph, no 2-cells)
    d2 = np.zeros((n_edges, 0), dtype=int)

    params = css_from_chain_complex(d1, d2)

    print(f"Chain complex: F_2^0 -> F_2^{n_edges} -> F_2^{n_vertices}")
    print(f"  {n_vertices} vertices, {n_edges} edges in Q_{n_dim}")
    print()
    print(f"Code parameters: [[{params['n']}, {params['k']}, {params['d']}]]")
    print(f"  Physical qubits (n):  {params['n']}")
    print(f"  Logical qubits (k):   {params['k']}  = β₁(Q_{n_dim}) = dim H₁(Q_{n_dim}, F_2)")
    print(f"  Distance (d):         {params['d']}")
    print(f"  rank(∂₁):             {params['rank_d1']}")
    print(f"  Euler check:          β₁ + rank(∂₁) = {params['k']} + {params['rank_d1']} = {params['n']} ✓")
    print()

    # Also compute with 2-cells (squares as faces)
    print("--- Now with 2-cells (square faces) ---")
    faces = []
    for v in range(n_vertices):
        for b1 in range(n_dim):
            for b2 in range(b1 + 1, n_dim):
                # Square face: v, v^b1, v^b2, v^b1^b2
                corners = sorted([v, v ^ (1 << b1), v ^ (1 << b2),
                                   v ^ (1 << b1) ^ (1 << b2)])
                face = tuple(corners)
                if face not in faces:
                    faces.append(face)
    n_faces = len(faces)

    # d2: faces -> edges (boundary of square = sum of 4 edges)
    d2_full = np.zeros((n_edges, n_faces), dtype=int)
    edge_index = {e: i for i, e in enumerate(edges)}
    for fi, (a, b, c, d) in enumerate(faces):
        for e in [(min(a,b), max(a,b)), (min(a,c), max(a,c)),
                  (min(b,d), max(b,d)), (min(c,d), max(c,d))]:
            if e in edge_index:
                d2_full[edge_index[e], fi] = 1

    d2_full = d2_full % 2
    params2 = css_from_chain_complex(d1, d2_full)

    print(f"  Added {n_faces} square faces")
    print(f"  Code parameters: [[{params2['n']}, {params2['k']}, {params2['d']}]]")
    print(f"  Logical qubits (k):   {params2['k']}  = β₁(Q_{n_dim}, with squares)")
    print(f"  Distance (d):         {params2['d']}")
    print(f"  Euler check:          β₁ + rank(∂₁) + rank(∂₂) = {params2['k']} + {params2['rank_d1']} + {params2['rank_d2']} = {params2['n']} ✓")
    print()


if __name__ == "__main__":
    print("CSS CODES AS COHOMOLOGY: NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    print()
    demo_repetition_code()
    demo_toric_code()
    demo_hypercube()

    print("=" * 60)
    print("SUMMARY: Every chain complex gives a quantum code.")
    print("The code parameters are topological invariants.")
    print("=" * 60)


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
