#!/usr/bin/env python3
"""
Algorithms for Persistent Homological Quantum Error Correction

Implements the core algorithms from the research paper:
1. Chain complex → CSS code construction
2. Barcode distance prediction
3. Persistence-rate tradeoff computation
4. GF(2) rank computation
"""

import numpy as np
from typing import List, Tuple, Optional
import math


# ============================================================
# Algorithm 1: GF(2) Gaussian Elimination
# ============================================================

def gf2_rank(matrix: np.ndarray) -> int:
    """Compute the rank of a binary matrix over GF(2).

    Uses Gaussian elimination with mod-2 arithmetic.

    Time complexity: O(m * n * min(m, n))
    Space complexity: O(m * n)

    Args:
        matrix: Binary matrix (entries 0 or 1)

    Returns:
        Rank over GF(2)

    Example:
        >>> gf2_rank(np.array([[1, 0, 1], [0, 1, 1], [1, 1, 0]]))
        2
    """
    if matrix.size == 0:
        return 0
    M = matrix.copy() % 2
    m, n = M.shape
    rank = 0
    pivot_cols = []

    for col in range(n):
        # Find pivot row
        pivot_row = None
        for row in range(rank, m):
            if M[row, col] % 2 == 1:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        # Swap rows
        M[[rank, pivot_row]] = M[[pivot_row, rank]]
        pivot_cols.append(col)

        # Eliminate
        for row in range(m):
            if row != rank and M[row, col] % 2 == 1:
                M[row] = (M[row] + M[rank]) % 2

        rank += 1

    return rank


def gf2_kernel_basis(matrix: np.ndarray) -> np.ndarray:
    """Compute a basis for the kernel of a binary matrix over GF(2).

    Time complexity: O(m * n * min(m, n))

    Args:
        matrix: Binary matrix over GF(2)

    Returns:
        Matrix whose rows form a basis for ker(matrix) over GF(2)
    """
    M = matrix.copy() % 2
    m, n = M.shape
    # Augment with identity on the right
    augmented = np.hstack([M.T, np.eye(n, dtype=int)])

    # Row reduce
    rank = 0
    for col in range(m):
        pivot_row = None
        for row in range(rank, n):
            if augmented[row, col] % 2 == 1:
                pivot_row = row
                break
        if pivot_row is None:
            continue
        augmented[[rank, pivot_row]] = augmented[[pivot_row, rank]]
        for row in range(n):
            if row != rank and augmented[row, col] % 2 == 1:
                augmented[row] = (augmented[row] + augmented[rank]) % 2
        rank += 1

    # Kernel basis = rows of the augmented part for zero rows
    kernel_rows = []
    for row in range(rank, n):
        kernel_rows.append(augmented[row, m:] % 2)

    if not kernel_rows:
        return np.zeros((0, n), dtype=int)
    return np.array(kernel_rows, dtype=int)


# ============================================================
# Algorithm 2: CSS Code Construction from Chain Complex
# ============================================================

def chain_complex_to_css(
    d1: np.ndarray,
    d2: np.ndarray
) -> Tuple[np.ndarray, np.ndarray, dict]:
    """Convert a chain complex to a CSS code.

    Given boundary maps d₁: C₁ → C₀ and d₂: C₂ → C₁ with d₁∘d₂ = 0 (mod 2),
    construct the CSS code with Hx = d₁ᵀ and Hz = d₂.

    Args:
        d1: First boundary map (n_edges × n_vertices matrix over GF(2))
        d2: Second boundary map (n_faces × n_edges matrix over GF(2))

    Returns:
        Tuple of (Hx, Hz, params) where params is a dict with code parameters

    Time complexity: O(n³) for the rank computations
    """
    # Verify chain complex condition
    product = (d2 @ d1) % 2
    assert np.all(product == 0), "Chain complex condition d₂∘d₁ = 0 violated"

    Hx = d1.T % 2
    Hz = d2 % 2

    # Verify CSS orthogonality
    assert np.all((Hx @ Hz.T) % 2 == 0), "CSS orthogonality violated"

    n = Hx.shape[1]
    rank_Hx = gf2_rank(Hx)
    rank_Hz = gf2_rank(Hz)
    k = n - rank_Hx - rank_Hz

    params = {
        'n': n,
        'k': k,
        'rank_Hx': rank_Hx,
        'rank_Hz': rank_Hz,
        'rx': Hx.shape[0],
        'rz': Hz.shape[0],
    }

    return Hx, Hz, params


# ============================================================
# Algorithm 3: Barcode Distance Prediction
# ============================================================

def barcode_distance(epsilon: float, delta: float) -> int:
    """Predict the code distance from a persistence bar [ε, δ).

    Implements the Barcode Distance Conjecture:
    d ≥ ⌈δ/ε⌉

    Args:
        epsilon: Birth time of the persistence bar (> 0)
        delta: Death time of the persistence bar (> epsilon)

    Returns:
        Predicted minimum distance

    Time complexity: O(1)
    """
    assert epsilon > 0, "Birth time must be positive"
    assert delta > epsilon, "Death time must exceed birth time"
    return math.ceil(delta / epsilon)


# ============================================================
# Algorithm 4: Persistence-Rate Tradeoff
# ============================================================

def singleton_bound_check(n: int, k: int, d: int) -> dict:
    """Check the quantum Singleton bound 2d + k ≤ n + 2.

    Args:
        n: Number of physical qubits
        k: Number of logical qubits
        d: Code distance

    Returns:
        Dictionary with bound analysis
    """
    lhs = 2 * d + k
    rhs = n + 2
    satisfies = lhs <= rhs
    max_d = (n + 2 - k) // 2
    rate = k / n if n > 0 else 0
    rate_bound = 1 - 2 * (d - 1) / n + 2 / n if n > 0 else 0

    return {
        'satisfies_singleton': satisfies,
        'lhs': lhs,
        'rhs': rhs,
        'max_distance': max_d,
        'rate': rate,
        'rate_bound': rate_bound,
    }


# ============================================================
# Algorithm 5: Hamming Sum Computation
# ============================================================

def hamming_sum(n: int, t: int) -> int:
    """Compute the Hamming packing sum for n-qubit quantum codes.

    Σ_{i=0}^{t} 3^i * C(n, i)

    This is the total number of correctable Pauli errors.

    Args:
        n: Number of qubits
        t: Error correction radius

    Returns:
        Hamming sum value

    Time complexity: O(t)
    """
    total = 0
    for i in range(t + 1):
        total += (3 ** i) * math.comb(n, i)
    return total


def hamming_bound_check(n: int, k: int, d: int) -> dict:
    """Check the quantum Hamming bound.

    For a nondegenerate code: Σ_{i=0}^{t} 3^i * C(n,i) ≤ 2^(n-k)

    Args:
        n, k, d: Code parameters [[n, k, d]]

    Returns:
        Dictionary with bound analysis
    """
    t = (d - 1) // 2
    hs = hamming_sum(n, t)
    syndrome_space = 2 ** (n - k)
    satisfies = hs <= syndrome_space

    return {
        'satisfies_hamming': satisfies,
        'hamming_sum': hs,
        'syndrome_space': syndrome_space,
        't': t,
        'ratio': hs / syndrome_space if syndrome_space > 0 else float('inf'),
    }


# ============================================================
# Algorithm 6: Toric Code Construction
# ============================================================

def build_toric_code(L: int) -> Tuple[np.ndarray, np.ndarray, dict]:
    """Construct the L×L toric code.

    The torus T²(L) has L² vertices, 2L² edges, L² faces.
    The chain complex gives a [[2L², 2, L]] CSS code.

    Args:
        L: Lattice size (L ≥ 2)

    Returns:
        Tuple of (Hx, Hz, params)

    Time complexity: O(L⁴) for construction, O(L⁶) for rank computation
    """
    n_v = L * L
    n_e = 2 * L * L

    d1 = np.zeros((n_e, n_v), dtype=int)
    d2 = np.zeros((n_v, n_e), dtype=int)

    def vidx(i, j): return (i % L) * L + (j % L)
    def heidx(i, j): return (i % L) * L + (j % L)
    def veidx(i, j): return L * L + (i % L) * L + (j % L)

    for i in range(L):
        for j in range(L):
            e_h = heidx(i, j)
            d1[e_h, vidx(i, j)] = (d1[e_h, vidx(i, j)] + 1) % 2
            d1[e_h, vidx(i, (j+1) % L)] = (d1[e_h, vidx(i, (j+1) % L)] + 1) % 2

            e_v = veidx(i, j)
            d1[e_v, vidx(i, j)] = (d1[e_v, vidx(i, j)] + 1) % 2
            d1[e_v, vidx((i+1) % L, j)] = (d1[e_v, vidx((i+1) % L, j)] + 1) % 2

    for i in range(L):
        for j in range(L):
            f = vidx(i, j)
            d2[f, heidx(i, j)] = (d2[f, heidx(i, j)] + 1) % 2
            d2[f, heidx((i+1) % L, j)] = (d2[f, heidx((i+1) % L, j)] + 1) % 2
            d2[f, veidx(i, j)] = (d2[f, veidx(i, j)] + 1) % 2
            d2[f, veidx(i, (j+1) % L)] = (d2[f, veidx(i, (j+1) % L)] + 1) % 2

    return chain_complex_to_css(d1, d2)


# ============================================================
# Main: Run all algorithm demonstrations
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # GF(2) rank
    M = np.array([[1, 0, 1, 1], [0, 1, 1, 0], [1, 1, 0, 1]], dtype=int)
    print(f"GF(2) rank of 3×4 matrix: {gf2_rank(M)}")

    # Toric code
    for L in [2, 3, 4, 5]:
        Hx, Hz, params = build_toric_code(L)
        print(f"\nToric code L={L}: {params}")
        bd = barcode_distance(1.0, float(L))
        sb = singleton_bound_check(params['n'], params['k'], L)
        hb = hamming_bound_check(params['n'], params['k'], L)
        print(f"  Barcode distance prediction: d ≥ {bd}")
        print(f"  Singleton bound: {sb}")
        print(f"  Hamming bound: {hb}")
