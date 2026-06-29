#!/usr/bin/env python3
"""
algorithms.py — Tropical Matrix Power Algorithms

Implements efficient algorithms for computing:
1. Tropical matrix multiplication (min-plus)
2. Tropical matrix powers via repeated squaring
3. Tropical rank computation
4. Rank sequence analysis and stabilization detection
5. Power column set construction

Complexity analysis:
- Tropical matrix multiply: O(n³)
- Tropical power A^m (naive): O(n³ · m)
- Tropical power A^m (fast): O(n³ · log m) via repeated squaring
- Tropical rank: O(n²) via column hashing
- Rank sequence up to M: O(n³ · M)
- Stabilization detection: O(n³ · n) worst case (since rank bounded by n)
"""

import numpy as np
from typing import List, Tuple, Set, Optional, Dict
from collections import OrderedDict

INF = float('inf')


# =============================================================
# Core Tropical Arithmetic
# =============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b).

    Time: O(1)
    """
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b, with ∞ absorbing.

    Convention: ∞ + x = ∞ for all x.
    Time: O(1)
    """
    if a == INF or b == INF:
        return INF
    return a + b


# =============================================================
# Tropical Matrix Operations
# =============================================================

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (min-plus product).

    (A ⊗ B)_{ik} = min_j (A_{ij} + B_{jk})

    This corresponds to one step of Bellman-Ford dynamic programming:
    optimal paths through A followed by optimal paths through B.

    Time:  O(n³)
    Space: O(n²)

    Args:
        A: n×n tropical matrix
        B: n×n tropical matrix

    Returns:
        n×n tropical matrix A ⊗ B
    """
    n = A.shape[0]
    C = np.full((n, n), INF)
    for i in range(n):
        for k in range(n):
            for j in range(n):
                val = trop_mul(A[i, j], B[j, k])
                C[i, k] = trop_add(C[i, k], val)
    return C


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix.

    I_{ij} = 0 if i=j, ∞ otherwise.
    Satisfies A ⊗ I = I ⊗ A = A.

    Time:  O(n²)
    Space: O(n²)
    """
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0.0)
    return I


def trop_pow_naive(A: np.ndarray, m: int) -> np.ndarray:
    """Compute A^m by repeated multiplication.

    Time:  O(n³ · m)
    Space: O(n²)
    """
    n = A.shape[0]
    if m == 0:
        return trop_identity(n)
    result = A.copy()
    for _ in range(m - 1):
        result = trop_mat_mul(result, A)
    return result


def trop_pow_fast(A: np.ndarray, m: int) -> np.ndarray:
    """Compute A^m by repeated squaring.

    Uses the binary representation of m to compute A^m in
    O(log m) matrix multiplications.

    Time:  O(n³ · log m)
    Space: O(n²)

    Algorithm:
        result = I
        base = A
        while m > 0:
            if m is odd: result = result ⊗ base
            base = base ⊗ base
            m = m // 2
    """
    n = A.shape[0]
    if m == 0:
        return trop_identity(n)

    result = trop_identity(n)
    base = A.copy()

    while m > 0:
        if m % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        m //= 2

    return result


# =============================================================
# Tropical Rank Computation
# =============================================================

def tropical_rank(A: np.ndarray) -> int:
    """Compute the tropical rank: number of distinct columns.

    Time:  O(n²) — hash each column, count unique hashes
    Space: O(n²) worst case for storing column tuples

    Args:
        A: n×n tropical matrix

    Returns:
        Number of distinct columns (≤ n by pigeonhole)
    """
    n = A.shape[1]
    columns: Set[tuple] = set()
    for j in range(n):
        col = tuple(A[:, j])
        columns.add(col)
    return len(columns)


def column_set(A: np.ndarray) -> Set[tuple]:
    """Return the set of distinct column vectors as tuples.

    Time:  O(n²)
    Space: O(n²)
    """
    n = A.shape[1]
    return {tuple(A[:, j]) for j in range(n)}


# =============================================================
# Rank Sequence Analysis
# =============================================================

def rank_sequence(A: np.ndarray, max_power: int) -> List[int]:
    """Compute the rank sequence [rank(A^0), rank(A^1), ..., rank(A^max_power)].

    Time:  O(n³ · max_power)
    Space: O(n² + max_power)

    Args:
        A: n×n tropical matrix
        max_power: maximum power to compute

    Returns:
        List of tropical ranks for powers 0 through max_power
    """
    n = A.shape[0]
    ranks = []
    current = trop_identity(n)
    ranks.append(tropical_rank(current))

    for m in range(1, max_power + 1):
        current = trop_mat_mul(current, A)
        ranks.append(tropical_rank(current))

    return ranks


def detect_stabilization(ranks: List[int]) -> Optional[int]:
    """Find the stabilization index of a rank sequence.

    Returns the smallest N such that ranks[m] = ranks[N] for all m ≥ N,
    or None if the sequence hasn't stabilized within the given range.

    Time:  O(len(ranks))
    Space: O(1)

    Theorem guarantee: For monotone rank sequences bounded by n,
    stabilization occurs (existence proven formally).
    """
    for i in range(len(ranks)):
        if all(ranks[j] == ranks[i] for j in range(i, len(ranks))):
            return i
    return None


def count_strict_jumps(ranks: List[int]) -> int:
    """Count the number of strict increases in a rank sequence.

    By our formal theorem (strict_mono_Fin_le), this count is ≤ n
    for any monotone sequence bounded by n.

    Time:  O(len(ranks))
    Space: O(1)
    """
    count = 0
    for i in range(len(ranks) - 1):
        if ranks[i] < ranks[i + 1]:
            count += 1
    return count


def find_jump_indices(ranks: List[int]) -> List[int]:
    """Find indices where strict rank increases occur.

    Time:  O(len(ranks))
    Space: O(n) worst case
    """
    return [i for i in range(len(ranks) - 1) if ranks[i] < ranks[i + 1]]


# =============================================================
# Power Column Set
# =============================================================

def power_column_set(A: np.ndarray, M: int) -> Set[tuple]:
    """Compute the power column set: union of column sets for A^0, ..., A^M.

    The formal theorem powerColumnSet_card_ge_of_rank_jumps guarantees
    that if rank strictly increases at each of M steps, then
    |powerColumnSet| ≥ M + 1.

    Time:  O(n³ · M)
    Space: O(n² · M) worst case

    Args:
        A: n×n tropical matrix
        M: maximum power

    Returns:
        Set of distinct column vectors across all powers
    """
    all_columns: Set[tuple] = set()
    current = trop_identity(A.shape[0])

    for m in range(M + 1):
        if m > 0:
            current = trop_mat_mul(current, A)
        else:
            current = trop_identity(A.shape[0])
        all_columns |= column_set(current)

    return all_columns


def power_column_growth(A: np.ndarray, max_power: int) -> List[int]:
    """Track cumulative power column set size as powers increase.

    Returns [|PCS(A,0)|, |PCS(A,1)|, ..., |PCS(A,max_power)|].

    Time:  O(n³ · max_power)
    Space: O(n² · max_power)
    """
    all_columns: Set[tuple] = set()
    sizes = []
    current = trop_identity(A.shape[0])

    for m in range(max_power + 1):
        if m > 0:
            current = trop_mat_mul(current, A)
        else:
            current = trop_identity(A.shape[0])
        all_columns |= column_set(current)
        sizes.append(len(all_columns))

    return sizes


# =============================================================
# All-Pairs Shortest Paths (Tropical Kleene Star)
# =============================================================

def tropical_kleene_star(A: np.ndarray) -> np.ndarray:
    """Compute the tropical Kleene star A* = I ⊕ A ⊕ A² ⊕ A³ ⊕ ...

    For matrices without negative-weight cycles, A* gives all-pairs
    shortest paths. Computed via Floyd-Warshall.

    Time:  O(n³)
    Space: O(n²)

    Returns:
        n×n matrix where entry (i,j) is the shortest path from i to j
    """
    n = A.shape[0]
    D = A.copy()
    # Include zero-length paths (identity)
    for i in range(n):
        D[i, i] = min(D[i, i], 0.0)

    for k in range(n):
        for i in range(n):
            for j in range(n):
                via_k = trop_mul(D[i, k], D[k, j])
                D[i, j] = trop_add(D[i, j], via_k)

    return D


# =============================================================
# Example Usage
# =============================================================

if __name__ == "__main__":
    print("Tropical Matrix Power Algorithms — Examples")
    print("=" * 50)

    # Create a 4×4 weighted digraph
    A = np.array([
        [0.0, 2.0, INF, 5.0],
        [INF, 0.0, 3.0, INF],
        [INF, INF, 0.0, 1.0],
        [4.0, INF, INF, 0.0]
    ])

    print("\nInput matrix (4-node weighted digraph):")
    print(A)

    # Compute rank sequence
    ranks = rank_sequence(A, 10)
    print(f"\nRank sequence: {ranks}")

    # Detect stabilization
    stab = detect_stabilization(ranks)
    print(f"Stabilization index: {stab}")

    # Count jumps
    jumps = count_strict_jumps(ranks)
    jump_idx = find_jump_indices(ranks)
    print(f"Number of strict jumps: {jumps}")
    print(f"Jump indices: {jump_idx}")

    # Power column set growth
    pcs_sizes = power_column_growth(A, 10)
    print(f"\nPower column set sizes: {pcs_sizes}")

    # Shortest paths
    D = tropical_kleene_star(A)
    print(f"\nAll-pairs shortest paths (Kleene star):")
    print(D)

    # Compare with direct power computation
    print(f"\nA^4 (fast exponentiation):")
    A4 = trop_pow_fast(A, 4)
    print(A4)

    print(f"\nA^4 (naive):")
    A4n = trop_pow_naive(A, 4)
    print(A4n)

    print(f"\nResults match: {np.array_equal(A4, A4n)}")
