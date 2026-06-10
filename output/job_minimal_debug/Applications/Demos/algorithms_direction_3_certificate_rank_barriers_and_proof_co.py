#!/usr/bin/env python3
"""
Certificate Rank Barriers — Algorithms

Implements the core algorithms for constructing and analyzing certificate-consistency
matrices for subset-indexed proof systems.

Algorithms:
    1. Subset enumeration with canonical ordering
    2. Certificate-consistency matrix construction
    3. Rank computation over arbitrary fields (Gaussian elimination mod p)
    4. Separation property verification
    5. Powerset coefficient computation
    6. Compression ratio analysis

Time complexity: O(2^n × 2^n) for matrix construction, O(2^{3n}) for rank.
Space complexity: O(2^{2n}) for the matrix.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass


# ============================================================================
# Algorithm 1: Subset Enumeration
# ============================================================================

def enumerate_subsets(n: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all subsets of {0, ..., n-1} in graded lexicographic order.

    Pseudocode:
        for k = 0, 1, ..., n:
            for each k-element subset S of {0,...,n-1} in lex order:
                yield S

    Time: O(2^n)
    Space: O(2^n)

    Args:
        n: Size of the ground set.

    Returns:
        List of tuples, each representing a subset.
    """
    result = []
    for k in range(n + 1):
        for combo in combinations(range(n), k):
            result.append(combo)
    return result


def subset_to_index(subset: Tuple[int, ...], n: int) -> int:
    """
    Convert a subset to its binary encoding index.

    The subset {i_1, ..., i_k} maps to ∑ 2^{i_j}.

    Time: O(|subset|)
    """
    idx = 0
    for i in subset:
        idx |= (1 << i)
    return idx


def index_to_subset(idx: int, n: int) -> Tuple[int, ...]:
    """Convert a binary index back to a subset tuple."""
    return tuple(i for i in range(n) if idx & (1 << i))


# ============================================================================
# Algorithm 2: Certificate-Consistency Matrix Construction
# ============================================================================

def build_consistency_matrix(n: int, field_char: int = 0) -> np.ndarray:
    """
    Construct the canonical coefficient-consistency matrix.

    The matrix is the 2^n × 2^n identity matrix indexed by subsets of {0,...,n-1}.
    Row S corresponds to the constraint "verify coefficient c(S)".
    Column T corresponds to the certificate variable for subset T.

    Pseudocode:
        dim = 2^n
        M = zero matrix of size dim × dim
        for each subset S (row index i):
            M[i, i] = 1

    Time: O(2^n)  [sparse construction]
    Space: O(2^{2n})  [dense storage]

    Args:
        n: Size of the ground set.
        field_char: Characteristic of the field (0 for Q).

    Returns:
        numpy array of shape (2^n, 2^n).
    """
    dim = 2 ** n
    M = np.eye(dim, dtype=int if field_char > 0 else float)
    if field_char > 0:
        M = M % field_char
    return M


def build_general_consistency_matrix(
    n: int,
    constraint_vectors: Optional[Dict[int, Dict[int, float]]] = None
) -> np.ndarray:
    """
    Build a general certificate-consistency matrix from custom constraint vectors.

    Args:
        n: Size of the ground set.
        constraint_vectors: Dict mapping row index to {col_index: value}.
            If None, uses the canonical (identity) system.

    Returns:
        numpy array.
    """
    dim = 2 ** n
    if constraint_vectors is None:
        return build_consistency_matrix(n)

    M = np.zeros((dim, dim), dtype=float)
    for row, cols in constraint_vectors.items():
        for col, val in cols.items():
            M[row, col] = val
    return M


# ============================================================================
# Algorithm 3: Rank Computation
# ============================================================================

def gaussian_elimination_mod_p(matrix: np.ndarray, p: int) -> Tuple[int, np.ndarray]:
    """
    Perform Gaussian elimination over GF(p) and return rank + reduced form.

    Pseudocode:
        rank = 0
        for each column c:
            find pivot row r ≥ rank with M[r,c] ≠ 0 mod p
            if no pivot: continue
            swap rows rank and r
            scale row rank by M[rank,c]^{-1} mod p
            for each other row r':
                subtract M[r',c] × row rank from row r'
            rank += 1
        return rank

    Time: O(m × n × min(m,n)) where m,n are matrix dimensions
    Space: O(m × n)
    """
    m, n_cols = matrix.shape
    mat = matrix.copy() % p
    rank = 0
    pivot_cols = []

    for col in range(n_cols):
        pivot_row = None
        for row in range(rank, m):
            if mat[row, col] % p != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        mat[[rank, pivot_row]] = mat[[pivot_row, rank]]
        inv = pow(int(mat[rank, col]), p - 2, p)
        mat[rank] = (mat[rank] * inv) % p

        for row in range(m):
            if row != rank and mat[row, col] % p != 0:
                factor = mat[row, col]
                mat[row] = (mat[row] - factor * mat[rank]) % p

        pivot_cols.append(col)
        rank += 1

    return rank, mat


def compute_rank(matrix: np.ndarray, field_char: int = 0) -> int:
    """
    Compute the rank of a matrix over a specified field.

    Args:
        matrix: Input matrix.
        field_char: 0 for Q/R, prime p for GF(p).

    Returns:
        Integer rank.
    """
    if field_char == 0:
        return int(np.linalg.matrix_rank(matrix))
    else:
        rank, _ = gaussian_elimination_mod_p(matrix.astype(int), field_char)
        return rank


# ============================================================================
# Algorithm 4: Separation Property Verification
# ============================================================================

@dataclass
class SeparationWitness:
    """Witness that a certificate system has the separation property."""
    subset_index: int
    witness_column: int
    nonzero_value: float
    all_others_zero: bool


def verify_separation_property(matrix: np.ndarray) -> Tuple[bool, List[SeparationWitness]]:
    """
    Verify the subset-separation property of a certificate system.

    For each row i, find a column j such that M[i,j] ≠ 0 and M[k,j] = 0
    for all k ≠ i.

    Time: O(2^{2n})
    Space: O(2^n)

    Returns:
        (is_separating, list of witnesses)
    """
    m, n_cols = matrix.shape
    witnesses = []
    is_separating = True

    for i in range(m):
        found = False
        for j in range(n_cols):
            if matrix[i, j] != 0:
                all_zero = all(matrix[k, j] == 0 for k in range(m) if k != i)
                if all_zero:
                    witnesses.append(SeparationWitness(
                        subset_index=i,
                        witness_column=j,
                        nonzero_value=float(matrix[i, j]),
                        all_others_zero=True
                    ))
                    found = True
                    break
        if not found:
            is_separating = False
            witnesses.append(SeparationWitness(
                subset_index=i,
                witness_column=-1,
                nonzero_value=0.0,
                all_others_zero=False
            ))

    return is_separating, witnesses


# ============================================================================
# Algorithm 5: Powerset Coefficient Computation
# ============================================================================

def powerset_coefficient(f: List[float], subset: Tuple[int, ...]) -> float:
    """
    Compute c_f(S) = ∏_{i ∈ S} f(i).

    Time: O(|S|)
    """
    result = 1.0
    for i in subset:
        result *= f[i]
    return result


def all_powerset_coefficients(f: List[float]) -> Dict[Tuple[int, ...], float]:
    """
    Compute all 2^n powerset coefficients for a given assignment f.

    Time: O(n × 2^n)
    """
    n = len(f)
    subsets = enumerate_subsets(n)
    return {S: powerset_coefficient(f, S) for S in subsets}


def verify_powerset_identity(f: List[float]) -> Tuple[bool, float, float]:
    """
    Verify ∏(1 + f_i) = ∑_S c_f(S).

    Returns: (matches, lhs, rhs)
    """
    n = len(f)
    lhs = 1.0
    for fi in f:
        lhs *= (1.0 + fi)

    coeffs = all_powerset_coefficients(f)
    rhs = sum(coeffs.values())

    return (abs(lhs - rhs) < 1e-10, lhs, rhs)


# ============================================================================
# Algorithm 6: Compression Ratio Analysis
# ============================================================================

@dataclass
class CompressionAnalysis:
    """Analysis of the compression gap for a given n."""
    n: int
    human_cost: int
    auto_cost: int
    ratio: float
    is_gap: bool  # True if auto > K * human for some threshold K


def analyze_compression_gap(n_max: int, threshold_K: int = 10) -> List[CompressionAnalysis]:
    """
    Analyze the proof compression gap for n = 0, ..., n_max.

    Human cost: n + 1 (inductive proof)
    Automation cost: 2^n (certificate rank)

    Time: O(n_max)
    """
    results = []
    for n in range(n_max + 1):
        human = n + 1
        auto = 2 ** n
        ratio = auto / human
        is_gap = auto > threshold_K * human
        results.append(CompressionAnalysis(n, human, auto, ratio, is_gap))
    return results


# ============================================================================
# Main: Example Usage
# ============================================================================

if __name__ == "__main__":
    print("Certificate Rank Barrier — Algorithm Demos")
    print("=" * 50)

    # Demo 1: Matrix construction and rank
    for n in range(5):
        M = build_consistency_matrix(n)
        r = compute_rank(M)
        print(f"n={n}: matrix size {M.shape}, rank={r}, expected={2**n}")

    print()

    # Demo 2: Separation property
    for n in range(4):
        M = build_consistency_matrix(n)
        is_sep, witnesses = verify_separation_property(M)
        print(f"n={n}: separating={is_sep}")

    print()

    # Demo 3: Compression gap
    results = analyze_compression_gap(15)
    print(f"{'n':>3} | {'human':>6} | {'auto':>8} | {'ratio':>8} | {'gap(K=10)?':>10}")
    for r in results:
        print(f"{r.n:>3} | {r.human_cost:>6} | {r.auto_cost:>8} | "
              f"{r.ratio:>8.1f} | {'YES' if r.is_gap else 'no':>10}")
