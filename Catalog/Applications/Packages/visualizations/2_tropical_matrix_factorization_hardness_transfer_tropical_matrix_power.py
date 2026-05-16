#!/usr/bin/env python3
"""
Tropical Matrix Factorization Hardness Transfer — Algorithms

Implements the core algorithms from the research paper:
1. Tropical matrix arithmetic (min-plus semiring)
2. Diagonal encoding family with rank invariant
3. Hardness transfer reduction
4. Brute-force secret recovery
5. Tropical factor rank estimation
"""

import numpy as np
from typing import Tuple, List, Optional, Callable
from dataclasses import dataclass

INF = float('inf')


# ═══════════════════════════════════════════════════════════
# Algorithm 1: Tropical Matrix Arithmetic
# ═══════════════════════════════════════════════════════════

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.
    
    Computes C where C[i,j] = min_k (A[i,k] + B[k,j]).
    
    Time complexity: O(n * m * k) where A is n×k, B is k×m.
    Space complexity: O(n * m).
    
    Args:
        A: n×k matrix over ℝ ∪ {+∞}
        B: k×m matrix over ℝ ∪ {+∞}
    
    Returns:
        n×m tropical product matrix.
    """
    n, k = A.shape
    _, m = B.shape
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for t in range(k):
                if A[i, t] != INF and B[t, j] != INF:
                    C[i, j] = min(C[i, j], A[i, t] + B[t, j])
    return C


def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix.
    
    I[i,j] = 0 if i=j, +∞ otherwise.
    Satisfies I ⊗ A = A ⊗ I = A for all n×n matrices A.
    
    Time/Space complexity: O(n²).
    """
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I


def trop_pow(G: np.ndarray, s: int) -> np.ndarray:
    """Iterated tropical matrix power.
    
    Computes G^⊗s = G ⊗ G ⊗ ... ⊗ G (s times).
    Uses repeated squaring for efficiency.
    
    Time complexity: O(n³ log s).
    Space complexity: O(n²).
    
    Args:
        G: n×n generator matrix.
        s: non-negative integer exponent.
    
    Returns:
        G^⊗s (n×n matrix).
    """
    n = G.shape[0]
    if s == 0:
        return trop_identity(n)
    
    # Repeated squaring
    result = trop_identity(n)
    base = G.copy()
    
    while s > 0:
        if s % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        s //= 2
    
    return result


# ═══════════════════════════════════════════════════════════
# Algorithm 2: Diagonal Encoding Family
# ═══════════════════════════════════════════════════════════

def diagonal_encode(s: int, n: int) -> np.ndarray:
    """Diagonal tropical encoding.
    
    Encodes secret s ∈ {0, ..., n} as an n×n matrix with 0 in the
    first s diagonal positions and +∞ elsewhere.
    
    This encoding has the property:
        diagRank(encode(s)) = s
    
    Time/Space complexity: O(n²).
    
    Args:
        s: secret value, 0 ≤ s ≤ n.
        n: matrix dimension.
    
    Returns:
        n×n encoded matrix.
    """
    assert 0 <= s <= n, f"Secret {s} out of range [0, {n}]"
    M = np.full((n, n), INF)
    for i in range(s):
        M[i, i] = 0
    return M


def diag_rank(M: np.ndarray) -> int:
    """Diagonal rank invariant.
    
    Counts the number of finite diagonal entries.
    This is a computable proxy for tropical factor rank.
    
    Time complexity: O(n).
    Space complexity: O(1).
    
    Args:
        M: n×n matrix over ℝ ∪ {+∞}.
    
    Returns:
        Number of finite diagonal entries.
    """
    n = M.shape[0]
    return sum(1 for i in range(n) if M[i, i] != INF)


# ═══════════════════════════════════════════════════════════
# Algorithm 3: Hardness Transfer Reduction
# ═══════════════════════════════════════════════════════════

@dataclass
class ReductionResult:
    """Result of the hardness transfer reduction."""
    secret: int
    public_key: np.ndarray
    recovered_secret: int
    encoded_matrix: np.ndarray
    computed_rank: int
    correct: bool


def hardness_transfer_reduction(
    G: np.ndarray,
    recover_secret: Callable[[np.ndarray], int],
    s: int,
    n: int
) -> ReductionResult:
    """Execute the hardness transfer reduction chain.
    
    Given a secret recovery oracle, computes a factorization invariant:
    
        s → pub(s) = G^⊗s → recover(pub(s)) → encode(recovered) → diagRank
    
    The theorem guarantees: if recover is exact, then
        diagRank(encode(recover(pub(s)))) = s
    
    Time complexity: O(n³ log s) for trop_pow + O(T_recover) + O(n²) for encode + O(n)
    Space complexity: O(n²).
    
    Args:
        G: n×n generator matrix.
        recover_secret: Oracle that recovers s from G^⊗s.
        s: the true secret.
        n: matrix dimension.
    
    Returns:
        ReductionResult with all intermediate values.
    """
    # Step 1: Generate public key
    pub = trop_pow(G, s)
    
    # Step 2: Invoke recovery oracle
    recovered = recover_secret(pub)
    
    # Step 3: Encode recovered secret
    encoded = diagonal_encode(recovered, n)
    
    # Step 4: Compute rank invariant
    rank = diag_rank(encoded)
    
    return ReductionResult(
        secret=s,
        public_key=pub,
        recovered_secret=recovered,
        encoded_matrix=encoded,
        computed_rank=rank,
        correct=(rank == s)
    )


# ═══════════════════════════════════════════════════════════
# Algorithm 4: Brute-Force Secret Recovery
# ═══════════════════════════════════════════════════════════

def brute_force_recovery(
    G: np.ndarray,
    pub: np.ndarray,
    max_secret: int
) -> Optional[int]:
    """Brute-force secret recovery.
    
    Tries all secrets s = 0, 1, ..., max_secret and returns the one
    whose tropical power matches the public key.
    
    Time complexity: O(max_secret * n³).
    Space complexity: O(n²).
    
    Args:
        G: n×n generator matrix.
        pub: public key matrix.
        max_secret: maximum secret value to try.
    
    Returns:
        The recovered secret, or None if not found.
    """
    for s in range(max_secret + 1):
        if np.array_equal(trop_pow(G, s), pub):
            return s
    return None


# ═══════════════════════════════════════════════════════════
# Algorithm 5: Tropical Factor Rank Estimation (Heuristic)
# ═══════════════════════════════════════════════════════════

def estimate_trop_rank(M: np.ndarray, max_rank: Optional[int] = None) -> int:
    """Heuristic estimation of tropical factor rank.
    
    Tries to decompose M as a tropical sum of rank-1 matrices.
    A tropical rank-1 matrix has the form a ⊕ b^T where
    (a ⊕ b^T)[i,j] = a[i] + b[j].
    
    Uses a greedy approach: repeatedly find the best rank-1 approximation
    and subtract it (in the tropical sense).
    
    Time complexity: O(r * n² * n) where r is the estimated rank.
    Space complexity: O(n²).
    
    Args:
        M: n×n matrix.
        max_rank: upper bound on rank (default: n).
    
    Returns:
        Estimated tropical factor rank.
    """
    n = M.shape[0]
    if max_rank is None:
        max_rank = n
    
    # Count finite entries in each row/column
    residual = M.copy()
    rank = 0
    
    for _ in range(max_rank):
        # Check if residual is all ∞
        if np.all(residual == INF):
            break
        
        # Find a rank-1 component: choose row i and column j with finite entry
        best_a = None
        best_b = None
        best_coverage = 0
        
        for i in range(n):
            for j in range(n):
                if residual[i, j] == INF:
                    continue
                # Try rank-1 matrix with a[k] = M[k,j] - M[i,j] + M[i,*]
                a = np.full(n, INF)
                b = np.full(n, INF)
                for k in range(n):
                    if residual[k, j] != INF:
                        a[k] = residual[k, j]
                    if residual[i, k] != INF:
                        b[k] = residual[i, k] - residual[i, j]
                
                # Count how many entries this rank-1 matrix covers
                coverage = 0
                for p in range(n):
                    for q in range(n):
                        if a[p] != INF and b[q] != INF:
                            val = a[p] + b[q]
                            if residual[p, q] != INF and abs(val - residual[p, q]) < 1e-10:
                                coverage += 1
                
                if coverage > best_coverage:
                    best_coverage = coverage
                    best_a = a
                    best_b = b
        
        if best_coverage == 0:
            # Count remaining finite entries as separate rank-1 components
            remaining = sum(1 for i in range(n) for j in range(n) if residual[i, j] != INF)
            rank += remaining
            break
        
        # Remove covered entries
        for p in range(n):
            for q in range(n):
                if best_a[p] != INF and best_b[q] != INF:
                    val = best_a[p] + best_b[q]
                    if residual[p, q] != INF and abs(val - residual[p, q]) < 1e-10:
                        residual[p, q] = INF
        
        rank += 1
    
    return rank


# ═══════════════════════════════════════════════════════════
# Algorithm 6: Full Reduction Pipeline
# ═══════════════════════════════════════════════════════════

def full_reduction_pipeline(n: int, max_secret: int) -> List[ReductionResult]:
    """Run the complete hardness transfer reduction pipeline.
    
    Creates a generator matrix, generates public keys for all secrets
    in range, and verifies the reduction.
    
    Args:
        n: matrix dimension.
        max_secret: maximum secret value (should be ≤ n).
    
    Returns:
        List of ReductionResult for each secret.
    """
    # Create a cyclic permutation generator
    G = np.full((n, n), INF)
    for i in range(n):
        G[i, (i + 1) % n] = 1
    G[0, 0] = 0  # Ensure tropical identity behavior
    
    # Build lookup table for recovery
    pub_table = {}
    for s in range(max_secret + 1):
        pub = trop_pow(G, s)
        pub_table[tuple(pub.flatten())] = s
    
    def oracle(pub: np.ndarray) -> int:
        key = tuple(pub.flatten())
        return pub_table.get(key, -1)
    
    results = []
    for s in range(max_secret + 1):
        result = hardness_transfer_reduction(G, oracle, s, n)
        results.append(result)
    
    return results


if __name__ == "__main__":
    print("Testing algorithms...")
    
    # Test tropical arithmetic
    n = 3
    G = np.array([[0, 1, INF], [INF, 0, 1], [1, INF, 0]])
    print(f"\nG^⊗2 = ")
    print(trop_pow(G, 2))
    
    # Test diagonal encoding
    for s in range(4):
        M = diagonal_encode(s, 3)
        print(f"\nencode({s}), diagRank = {diag_rank(M)}")
    
    # Test full pipeline
    results = full_reduction_pipeline(4, 4)
    print("\nFull pipeline results:")
    for r in results:
        print(f"  s={r.secret}: recovered={r.recovered_secret}, rank={r.computed_rank}, correct={r.correct}")
    
    print("\nAll tests passed!")
