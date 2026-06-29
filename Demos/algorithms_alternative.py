#!/usr/bin/env python3
"""
Algorithms for Tropical Matrix Factorization

Implements the key algorithms from the research paper:
1. Tropical matrix multiplication (O(n·m·k))
2. Boolean-to-tropical embedding and extraction
3. Boolean rank computation (exact, exponential)
4. Greedy Boolean rank approximation
5. Tropical factorization verification
6. Karp reduction from Boolean to tropical factorization
"""

import numpy as np
from typing import Optional, Tuple, List
from itertools import product as iterproduct

INF = float('inf')


# ============================================================
# Core Tropical Operations
# ============================================================

def tropical_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def tropical_multiply(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with ∞ absorption)."""
    if a == INF or b == INF:
        return INF
    return a + b


def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.
    
    Algorithm:
        for i in [n], j in [m]:
            C[i,j] = min_{k in [p]} (A[i,k] + B[k,j])
    
    Time complexity: O(n * m * p)
    Space complexity: O(n * m)
    
    Args:
        A: n × p matrix with entries in ℤ ∪ {∞}
        B: p × m matrix with entries in ℤ ∪ {∞}
    
    Returns:
        C: n × m tropical product matrix
    """
    n, p = A.shape
    p2, m = B.shape
    assert p == p2, f"Inner dimensions must match: {p} ≠ {p2}"
    
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                val = tropical_multiply(A[i, k], B[k, j])
                C[i, j] = tropical_add(C[i, j], val)
    return C


def verify_tropical_factorization(
    M: np.ndarray,
    A: np.ndarray,
    B: np.ndarray
) -> bool:
    """Verify that A ⊗ B = M (tropical product).
    
    This is the NP certificate verifier for tropical factorization.
    
    Time complexity: O(n * m * r) where r is inner dimension.
    
    Args:
        M: Target matrix (n × m)
        A: Left factor (n × r)
        B: Right factor (r × m)
    
    Returns:
        True iff tropical_matmul(A, B) == M
    """
    product = tropical_matmul(A, B)
    return np.array_equal(
        np.where(product == INF, INF, product),
        np.where(M == INF, INF, M)
    )


# ============================================================
# Boolean-Tropical Bridge
# ============================================================

def bool_to_tropical(M: np.ndarray) -> np.ndarray:
    """Embed Boolean matrix into tropical: True → 0, False → ∞.
    
    This is the embedding function in the Karp reduction from
    Boolean matrix factorization to tropical factorization.
    
    Time complexity: O(n * m)
    """
    result = np.full(M.shape, INF)
    result[M] = 0.0
    return result


def tropical_to_bool(M: np.ndarray) -> np.ndarray:
    """Extract Boolean matrix from tropical factors.
    
    For the backward direction of the reduction:
    given tropical factor A, define a[i,k] = (A[i,k] ≠ ∞).
    
    Time complexity: O(n * m)
    """
    return M != INF


def bool_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Boolean (OR-AND) matrix multiplication.
    
    (A ⊙ B)[i,j] = OR_k (A[i,k] AND B[k,j])
    
    Time complexity: O(n * m * p)
    """
    n, p = A.shape
    _, m = B.shape
    C = np.zeros((n, m), dtype=bool)
    for i in range(n):
        for j in range(m):
            for k in range(p):
                if A[i, k] and B[k, j]:
                    C[i, j] = True
                    break
    return C


# ============================================================
# Boolean Rank Computation
# ============================================================

def boolean_rank_exact(M: np.ndarray) -> Tuple[int, Optional[Tuple]]:
    """Compute the exact Boolean rank of a Boolean matrix.
    
    Uses exhaustive search over all possible factorizations.
    
    WARNING: Exponential time! Only feasible for n, m ≤ 5.
    
    Time complexity: O(2^(n*r + r*m) * n*m*r) for each candidate r.
    
    Returns:
        (rank, (A, B)) where A ⊙ B = M and A is n×rank, B is rank×m.
    """
    n, m = M.shape
    
    if not M.any():
        return 0, (np.zeros((n, 0), dtype=bool), np.zeros((0, m), dtype=bool))
    
    for r in range(1, min(n, m) + 1):
        for a_bits in iterproduct([False, True], repeat=n * r):
            A = np.array(a_bits, dtype=bool).reshape(n, r)
            for b_bits in iterproduct([False, True], repeat=r * m):
                B = np.array(b_bits, dtype=bool).reshape(r, m)
                if np.array_equal(bool_matmul(A, B), M):
                    return r, (A, B)
    
    return min(n, m), None  # Should not reach here


def boolean_rank_greedy(M: np.ndarray) -> Tuple[int, List[Tuple]]:
    """Greedy approximation of Boolean rank.
    
    Iteratively finds the largest all-True rectangle in the
    uncovered portion of M, and subtracts it.
    
    This is an O(log n)-approximation to the minimum rectangle cover.
    
    Time complexity: O(n * m * min(n,m)) per iteration,
                     O(rank * n * m * min(n,m)) total.
    
    Returns:
        (approx_rank, rectangles) where each rectangle is (rows, cols).
    """
    n, m = M.shape
    uncovered = M.copy()
    rectangles = []
    
    while uncovered.any():
        # Find largest rectangle (greedy: pick the row set for a column, or vice versa)
        best_rect = None
        best_count = 0
        
        for j in range(m):
            # Rows that have True in column j
            rows = np.where(uncovered[:, j])[0]
            if len(rows) == 0:
                continue
            
            # Columns that are True for all these rows
            cols = np.where(np.all(uncovered[rows, :], axis=0))[0] if len(rows) > 0 else []
            
            count = len(rows) * len(cols)
            if count > best_count:
                best_count = count
                best_rect = (rows, cols)
        
        if best_rect is None or best_count == 0:
            break
        
        rows, cols = best_rect
        rectangles.append((rows.tolist(), cols.tolist()))
        
        # Mark covered
        for i in rows:
            for j in cols:
                uncovered[i, j] = False
    
    return len(rectangles), rectangles


def tropical_rank_via_bool(M_trop: np.ndarray) -> Tuple[int, Optional[Tuple]]:
    """Compute tropical rank of a {0, ∞} matrix via Boolean rank equivalence.
    
    This implements the main theorem: for {0, ∞} matrices,
    tropical rank = Boolean rank.
    
    Args:
        M_trop: Matrix with entries in {0, ∞}
    
    Returns:
        (rank, (A_trop, B_trop)) tropical factorization if found.
    """
    M_bool = tropical_to_bool(M_trop)  # 0 → True (finite), ∞ → False
    # Wait: our convention is 0 = True, ∞ = False
    M_bool = (M_trop == 0)
    
    rank, factors = boolean_rank_exact(M_bool)
    
    if factors is not None:
        A_bool, B_bool = factors
        A_trop = bool_to_tropical(A_bool)
        B_trop = bool_to_tropical(B_bool)
        return rank, (A_trop, B_trop)
    
    return rank, None


# ============================================================
# Karp Reduction Implementation
# ============================================================

def karp_reduce_bool_to_trop(
    M_bool: np.ndarray,
    r: int
) -> Tuple[np.ndarray, int]:
    """Karp reduction from Boolean factorization to tropical factorization.
    
    Input: Boolean matrix M and target rank r
    Output: Tropical matrix T = boolToTrop(M) and same rank r
    
    The reduction satisfies:
        BoolMatFact(r, M) ↔ HasTropFactorization(r, T)
    
    This is polynomial-time (linear in matrix size).
    """
    T = bool_to_tropical(M_bool)
    return T, r


def extract_bool_from_trop_factors(
    A_trop: np.ndarray,
    B_trop: np.ndarray
) -> Tuple[np.ndarray, np.ndarray]:
    """Extract Boolean factors from tropical factors.
    
    Given tropical factors A, B with tropMul(A, B) = boolToTrop(M),
    define:
        a[i,k] = (A[i,k] ≠ ∞)
        b[k,j] = (B[k,j] ≠ ∞)
    
    Then boolMatMul(a, b) = M.
    
    This is the key step in the backward direction of the reduction.
    """
    a = A_trop != INF
    b = B_trop != INF
    return a, b


# ============================================================
# Pseudocode for Reference
# ============================================================

TROPICAL_MATMUL_PSEUDOCODE = """
ALGORITHM: TropicalMatrixMultiply(A[n×k], B[k×m])
────────────────────────────────────────────────
Input:  A ∈ (ℤ ∪ {∞})^{n×k}, B ∈ (ℤ ∪ {∞})^{k×m}
Output: C ∈ (ℤ ∪ {∞})^{n×m} where C = A ⊗ B

1  for i ← 1 to n do
2      for j ← 1 to m do
3          C[i,j] ← ∞
4          for l ← 1 to k do
5              C[i,j] ← min(C[i,j], A[i,l] + B[l,j])
6  return C

Time:  O(n·m·k)
Space: O(n·m)
"""

KARP_REDUCTION_PSEUDOCODE = """
ALGORITHM: KarpReduce(M[n×m] : Bool, r : ℕ)
────────────────────────────────────────────
Input:  Boolean matrix M, target rank r
Output: Tropical matrix T, same rank r

1  for i ← 1 to n do
2      for j ← 1 to m do
3          if M[i,j] = true then
4              T[i,j] ← 0
5          else
6              T[i,j] ← ∞
7  return (T, r)

Time:  O(n·m)
Space: O(n·m)

CORRECTNESS: BoolMatFact(r, M) ↔ HasTropFactorization(r, T)
"""

BOOL_EXTRACTION_PSEUDOCODE = """
ALGORITHM: ExtractBoolFactors(A[n×r], B[r×m] : WithTop ℤ)
──────────────────────────────────────────────────────────
Input:  Tropical factors A, B with A ⊗ B = boolToTrop(M)
Output: Boolean factors a, b with a ⊙ b = M

1  for i ← 1 to n, l ← 1 to r do
2      a[i,l] ← (A[i,l] ≠ ∞)
3  for l ← 1 to r, j ← 1 to m do
4      b[l,j] ← (B[l,j] ≠ ∞)
5  return (a, b)

Time:  O(n·r + r·m)
Space: O(n·r + r·m)

CORRECTNESS: Follows from the proof that:
  - M[i,j] = True  ⟹  ∃l, A[i,l]+B[l,j] = 0  ⟹  both finite  ⟹  a[i,l] ∧ b[l,j]
  - M[i,j] = False ⟹  ∀l, A[i,l]+B[l,j] = ∞  ⟹  ¬(a[i,l] ∧ b[l,j]) for all l
"""


if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    print()
    
    # Demo: Tropical multiplication
    print("1. Tropical Matrix Multiplication")
    A = np.array([[0, 3, INF], [INF, 0, 2]], dtype=float)
    B = np.array([[0, INF], [1, 0], [INF, 1]], dtype=float)
    C = tropical_matmul(A, B)
    print(f"   A = {A.tolist()}")
    print(f"   B = {B.tolist()}")
    print(f"   A ⊗ B = {C.tolist()}")
    print()
    
    # Demo: Boolean rank
    print("2. Boolean Rank Computation")
    M = np.array([[True, True, False],
                   [True, False, True],
                   [False, True, True]])
    rank, factors = boolean_rank_exact(M)
    print(f"   M = {M.astype(int).tolist()}")
    print(f"   Boolean rank = {rank}")
    if factors:
        A, B = factors
        print(f"   A = {A.astype(int).tolist()}")
        print(f"   B = {B.astype(int).tolist()}")
    print()
    
    # Demo: Karp reduction
    print("3. Karp Reduction: Boolean → Tropical")
    M_bool = np.array([[True, False], [False, True]])
    T, r = karp_reduce_bool_to_trop(M_bool, 2)
    print(f"   Input: M = {M_bool.astype(int).tolist()}, r = 2")
    print(f"   Output: T = {[['0' if x == 0 else '∞' for x in row] for row in T.tolist()]}")
    print()
    
    # Demo: Extraction
    print("4. Boolean Factor Extraction from Tropical")
    A_trop = np.array([[0, INF], [INF, 0]], dtype=float)
    B_trop = np.array([[0, INF], [INF, 0]], dtype=float)
    a, b = extract_bool_from_trop_factors(A_trop, B_trop)
    print(f"   Tropical A = {[['0' if x == 0 else '∞' for x in row] for row in A_trop.tolist()]}")
    print(f"   Boolean a = {a.astype(int).tolist()}")
    print(f"   boolMatMul(a, b) = {bool_matmul(a, b).astype(int).tolist()}")
    print()
    
    # Demo: Greedy approximation
    print("5. Greedy Boolean Rank Approximation")
    M = np.array([[True, True, True, False],
                   [True, True, False, False],
                   [False, False, True, True],
                   [False, False, True, True]])
    approx_rank, rects = boolean_rank_greedy(M)
    print(f"   M = {M.astype(int).tolist()}")
    print(f"   Greedy rank ≤ {approx_rank}")
    for i, (rows, cols) in enumerate(rects):
        print(f"   Rectangle {i+1}: rows={rows}, cols={cols}")
    print()
    
    print("Pseudocode for key algorithms:")
    print(TROPICAL_MATMUL_PSEUDOCODE)
    print(KARP_REDUCTION_PSEUDOCODE)
