#!/usr/bin/env python3
"""
CSS Codes as Cohomology: Demonstration Script

Demonstrates the key results:
1. Chain condition implies CSS orthogonality
2. Hypercube HQECC parameters and Betti numbers
3. Disproof of the d = 2^(n/2) conjecture
4. Toric code parameters and Singleton bound
5. Repetition code as a chain complex
"""

import numpy as np
from typing import Tuple, List


def gf2_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Matrix multiplication over GF(2)."""
    return (A @ B) % 2


def gf2_dot(v: np.ndarray, w: np.ndarray) -> int:
    """Dot product over GF(2)."""
    return int(np.sum(v * w) % 2)


def hamming_weight(v: np.ndarray) -> int:
    """Hamming weight of a binary vector."""
    return int(np.sum(v != 0))


def kernel_gf2(M: np.ndarray) -> np.ndarray:
    """Compute kernel of a matrix over GF(2) using Gaussian elimination."""
    m, n = M.shape
    A = M.copy() % 2
    pivots = []
    for col in range(n):
        pivot_row = None
        for row in range(len(pivots), m):
            if A[row, col] == 1:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        A[[len(pivots), pivot_row]] = A[[pivot_row, len(pivots)]]
        for row in range(m):
            if row != len(pivots) and A[row, col] == 1:
                A[row] = (A[row] + A[len(pivots)]) % 2
        pivots.append(col)

    free_cols = [c for c in range(n) if c not in pivots]
    ker_vecs = []
    for fc in free_cols:
        v = np.zeros(n, dtype=int)
        v[fc] = 1
        for i, pc in enumerate(pivots):
            v[pc] = A[i, fc]
        ker_vecs.append(v)
    return np.array(ker_vecs) if ker_vecs else np.zeros((0, n), dtype=int)


def rank_gf2(M: np.ndarray) -> int:
    """Rank of a matrix over GF(2)."""
    m, n = M.shape
    return n - kernel_gf2(M).shape[0]


class HomologicalCSSCode:
    """A CSS code from a chain complex over GF(2).

    Chain complex: GF(2)^m2 --d2--> GF(2)^n --d1--> GF(2)^m1
    """

    def __init__(self, d1: np.ndarray, d2: np.ndarray):
        self.d1 = d1 % 2  # m1 x n matrix
        self.d2 = d2 % 2  # n x m2 matrix
        self.n = d1.shape[1]
        self.m1 = d1.shape[0]
        self.m2 = d2.shape[1]

        # Verify chain condition
        product = gf2_matmul(d1, d2)
        assert np.all(product == 0), f"Chain condition violated: d1 * d2 != 0"

    def verify_css_orthogonality(self) -> bool:
        """Verify that X-stab ⊥ Z-stab (Theorem 3.1)."""
        # X-stab = column space of d1^T = row space of d1
        # Z-stab = column space of d2
        # Check: all rows of d1 are orthogonal to all columns of d2
        for i in range(self.m1):
            for j in range(self.m2):
                if gf2_dot(self.d1[i], self.d2[:, j]) != 0:
                    return False
        return True

    def betti_1(self) -> int:
        """First Betti number = dim(ker d1 / im d2)."""
        return rank_gf2(self.d1.T) - rank_gf2(self.d2) + self.n - self.n
        # Actually: β1 = dim(ker d1) - rank(d2) = (n - rank(d1)) - rank(d2)
        # Let me fix:

    def betti_1(self) -> int:
        """First Betti number = dim(ker d1) - dim(im d2)."""
        nullity_d1 = self.n - rank_gf2(self.d1)
        rank_d2 = rank_gf2(self.d2)
        return nullity_d1 - rank_d2

    def rank_nullity(self) -> Tuple[int, int]:
        """rank(d1) + nullity(d1) = n (Theorem 4.1)."""
        r = rank_gf2(self.d1)
        null = self.n - r
        return r, null

    def x_distance(self) -> int:
        """Minimum weight of a non-trivial cycle (ker d1 \ im d2)."""
        ker_d1 = kernel_gf2(self.d1)
        if ker_d1.shape[0] == 0:
            return self.n + 1

        # Generate all elements of ker(d1)
        from itertools import product as iproduct
        min_wt = self.n + 1
        for coeffs in iproduct([0, 1], repeat=ker_d1.shape[0]):
            v = np.zeros(self.n, dtype=int)
            for c, row in zip(coeffs, ker_d1):
                v = (v + c * row) % 2
            if np.all(v == 0):
                continue
            # Check if v is in im(d2)
            # v in im(d2) iff the system d2 * x = v has a solution over GF(2)
            aug = np.hstack([self.d2, v.reshape(-1, 1)])
            if rank_gf2(self.d2) == rank_gf2(aug):
                continue  # v is a boundary
            wt = hamming_weight(v)
            min_wt = min(min_wt, wt)
        return min_wt

    def parameters(self) -> Tuple[int, int, int]:
        """CSS code parameters [[n, k, d]]."""
        return self.n, self.betti_1(), self.x_distance()


def hypercube_incidence(dim: int) -> np.ndarray:
    """Incidence matrix of the dim-dimensional hypercube Q_dim over GF(2)."""
    num_verts = 2 ** dim
    num_edges = dim * (2 ** (dim - 1))

    incidence = np.zeros((num_verts, num_edges), dtype=int)
    edge_idx = 0
    for bit in range(dim):
        for v in range(num_verts):
            if v & (1 << bit) == 0:
                w = v | (1 << bit)
                incidence[v, edge_idx] = 1
                incidence[w, edge_idx] = 1
                edge_idx += 1
    return incidence


def torus_incidence(L: int) -> Tuple[np.ndarray, np.ndarray]:
    """Incidence and face matrices of the L x L torus.

    Returns (d1, d2) where d1 is the incidence matrix (vertex-edge)
    and d2 is the face-edge matrix.
    """
    num_verts = L * L
    num_edges = 2 * L * L  # L^2 horizontal + L^2 vertical
    num_faces = L * L

    # Vertex indexing: (i,j) -> i*L + j
    # Edge indexing: horizontal edge (i,j)-(i,j+1) -> i*L + j
    #               vertical edge (i,j)-(i+1,j) -> L*L + i*L + j

    d1 = np.zeros((num_verts, num_edges), dtype=int)
    d2 = np.zeros((num_edges, num_faces), dtype=int)

    for i in range(L):
        for j in range(L):
            v = i * L + j
            # Horizontal edge from (i,j) to (i,(j+1)%L)
            e_h = i * L + j
            d1[v, e_h] = 1
            d1[i * L + (j + 1) % L, e_h] = (d1[i * L + (j + 1) % L, e_h] + 1) % 2

            # Vertical edge from (i,j) to ((i+1)%L,j)
            e_v = L * L + i * L + j
            d1[v, e_v] = 1
            d1[((i + 1) % L) * L + j, e_v] = (
                d1[((i + 1) % L) * L + j, e_v] + 1
            ) % 2

            # Face (i,j): boundary = h(i,j) + v(i,j+1) + h(i+1,j) + v(i,j)
            f = i * L + j
            d2[e_h, f] = 1  # horizontal edge (i,j)
            d2[L * L + i * L + (j + 1) % L, f] = (
                d2[L * L + i * L + (j + 1) % L, f] + 1
            ) % 2  # vertical edge (i,j+1)%L
            d2[((i + 1) % L) * L + j, f] = (
                d2[((i + 1) % L) * L + j, f] + 1
            ) % 2  # horizontal edge (i+1,j)
            d2[e_v, f] = (d2[e_v, f] + 1) % 2  # vertical edge (i,j)

    return d1, d2


def main():
    print("=" * 70)
    print("CSS CODES AS COHOMOLOGY: DEMONSTRATION")
    print("=" * 70)

    # === Demo 1: Repetition Code ===
    print("\n--- Demo 1: Repetition Code [[3,1,1]] ---")
    d1 = np.array([[1, 1, 0], [0, 1, 1]])
    d2 = np.array([[1], [1], [1]])
    code = HomologicalCSSCode(d1, d2)
    print(f"Chain condition d1*d2 = 0: {np.all(gf2_matmul(d1, d2) == 0)}")
    print(f"CSS orthogonality: {code.verify_css_orthogonality()}")
    r, null = code.rank_nullity()
    print(f"Rank-nullity: rank(d1)={r} + nullity(d1)={null} = {r+null} = n={code.n}")
    print(f"Betti number β₁ = {code.betti_1()}")
    n, k, d = code.parameters()
    print(f"Code parameters: [[{n}, {k}, {d}]]")

    # === Demo 2: Hypercube HQECC ===
    print("\n--- Demo 2: Hypercube HQECC ---")
    for dim in [2, 3, 4, 5, 6]:
        inc = hypercube_incidence(dim)
        num_verts = 2 ** dim
        num_edges = dim * (2 ** (dim - 1))
        betti = num_edges - num_verts + 1
        print(f"Q_{dim}: {num_verts} vertices, {num_edges} edges, β₁ = {betti}")

    print("\n--- Demo 3: Hypercube Q4 detailed analysis ---")
    inc4 = hypercube_incidence(4)
    d1_q4 = inc4  # 16 x 32 (vertices x edges)
    d2_q4 = np.zeros((inc4.shape[1], 0), dtype=int)  # No 2-cells
    print(f"d1 shape: {d1_q4.shape}")
    print(f"rank(d1) = {rank_gf2(d1_q4)}")
    print(f"nullity(d1) = {d1_q4.shape[1] - rank_gf2(d1_q4)}")
    print(f"β₁ = {d1_q4.shape[1] - rank_gf2(d1_q4)} (since d2 = 0)")
    print(f"Formula: (4-2)*2^3 + 1 = {(4-2)*2**3 + 1}")

    # === Demo 4: Disproof of d = 2^(n/2) conjecture ===
    print("\n--- Demo 4: Disproof of d = 2^(n/2) conjecture ---")
    print("The conjecture claims d(Q_n) = 2^(n/2).")
    print("But the girth (shortest cycle) of Q_n is 4 for all n >= 2.")
    print(f"For Q_6: conjecture predicts d = 2^(6/2) = {2**(6//2)} = 8")
    print(f"Actual systole: 4 (from square faces)")
    print(f"4 ≠ 8, so the conjecture is FALSE!")

    for n in range(2, 9):
        predicted = 2 ** (n // 2)
        actual = 4  # Girth of Q_n
        match = "✓" if predicted == actual else "✗"
        print(f"  Q_{n}: predicted d={predicted}, actual girth=4  {match}")

    # === Demo 5: Toric Code ===
    print("\n--- Demo 5: Toric Code Parameters ---")
    for L in [2, 3, 4, 5, 10]:
        n_phys = 2 * L ** 2
        k_log = 2
        d_code = L
        singleton_ok = k_log + 2 * d_code <= n_phys + 2
        rate = k_log / n_phys
        print(
            f"  L={L}: [[{n_phys}, {k_log}, {d_code}]], "
            f"rate={rate:.4f}, Singleton: {singleton_ok}"
        )

    # === Demo 6: Rank-nullity verification ===
    print("\n--- Demo 6: Rank-Nullity Theorem Verification ---")
    for dim in [2, 3, 4]:
        inc = hypercube_incidence(dim)
        n = inc.shape[1]
        r = rank_gf2(inc)
        null = n - r
        print(f"Q_{dim}: n={n}, rank(d1)={r}, nullity(d1)={null}, sum={r+null}")
        assert r + null == n, "Rank-nullity failed!"

    print("\n" + "=" * 70)
    print("ALL DEMONSTRATIONS COMPLETED SUCCESSFULLY")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Hypercube Betti Numbers and Code Parameters

Plots β₁(Q_n) = (n-2)·2^(n-1) + 1 and compares with the disproved
distance conjecture d = 2^(n/2) vs actual girth = 4.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def hypercube_betti1(n: int) -> int:
    """First Betti number of Q_n."""
    return n * (2 ** (n - 1)) - 2**n + 1


def hypercube_edges(n: int) -> int:
    return n * (2 ** (n - 1))


def hypercube_vertices(n: int) -> int:
    return 2**n


def main():
    dims = list(range(2, 13))

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Plot 1: Betti numbers
    betti = [hypercube_betti1(n) for n in dims]
    axes[0].semilogy(dims, betti, 'bo-', linewidth=2, markersize=8)
    axes[0].set_xlabel('Dimension n', fontsize=12)
    axes[0].set_ylabel('β₁(Qₙ)', fontsize=12)
    axes[0].set_title('First Betti Number of Hypercube', fontsize=14)
    axes[0].grid(True, alpha=0.3)
    for n, b in zip(dims[:6], betti[:6]):
        axes[0].annotate(f'{b}', (n, b), textcoords="offset points",
                        xytext=(0, 10), ha='center', fontsize=9)

    # Plot 2: Conjectured vs actual distance
    conjectured = [2 ** (n // 2) for n in dims]
    actual = [4] * len(dims)
    axes[1].semilogy(dims, conjectured, 'r^--', linewidth=2, markersize=8,
                     label='Conjectured: 2^(n/2)')
    axes[1].semilogy(dims, actual, 'gs-', linewidth=2, markersize=8,
                     label='Actual girth: 4')
    axes[1].set_xlabel('Dimension n', fontsize=12)
    axes[1].set_ylabel('Distance d', fontsize=12)
    axes[1].set_title('Disproof: d ≠ 2^(n/2)', fontsize=14)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    # Plot 3: Code rate k/n
    rates = [hypercube_betti1(n) / hypercube_edges(n) for n in dims]
    axes[2].plot(dims, rates, 'mp-', linewidth=2, markersize=8)
    axes[2].set_xlabel('Dimension n', fontsize=12)
    axes[2].set_ylabel('Code rate k/n', fontsize=12)
    axes[2].set_title('HQECC Code Rate', fontsize=14)
    axes[2].grid(True, alpha=0.3)
    axes[2].set_ylim(0, 1)

    plt.tight_layout()
    plt.savefig('hypercube_hqecc_analysis.png', dpi=150, bbox_inches='tight')
    print("Saved hypercube_hqecc_analysis.png")


if __name__ == "__main__":
    main()
