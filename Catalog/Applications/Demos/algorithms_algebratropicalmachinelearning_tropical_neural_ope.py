#!/usr/bin/env python3
"""
Algorithms for Tropical Operadic Realization Theory

Implements the core algorithms from the research paper with full docstrings,
type hints, complexity analysis, and example usage.
"""

import numpy as np
from typing import Tuple, List, Dict, Optional, NamedTuple
from dataclasses import dataclass


# ============================================================
# Data Structures
# ============================================================

@dataclass
class CanonicalRealization:
    """A canonical (reduced + separated) realization of an evaluation table.
    
    Attributes:
        rank: Number of states (= operational rank)
        encode: Maps context indices to state indices
        decode: Maps (state, observable) to integer cost
        is_reduced: Whether encode is surjective
        is_separated: Whether decode profiles are distinct
    """
    rank: int
    encode: np.ndarray  # shape (n_contexts,)
    decode: np.ndarray  # shape (rank, n_observables)
    is_reduced: bool
    is_separated: bool
    
    @property
    def is_canonical(self) -> bool:
        return self.is_reduced and self.is_separated


@dataclass
class TropicalFactorization:
    """A tropical (min-plus) matrix factorization.
    
    Represents M = L ⊗_trop R where:
    (L ⊗ R)[i,k] = min_j (L[i,j] + R[j,k])
    
    Attributes:
        left: Left factor, shape (n_rows, rank)
        right: Right factor, shape (rank, n_cols)
        rank: Factorization rank
    """
    left: np.ndarray
    right: np.ndarray
    rank: int


class NerodeClass(NamedTuple):
    """A Nerode equivalence class."""
    class_id: int
    members: List[int]
    profile: np.ndarray


# ============================================================
# Algorithm 1: Canonical Realization
# ============================================================

def compute_canonical_realization(M: np.ndarray) -> CanonicalRealization:
    """
    Compute the canonical minimal realization of an evaluation table.
    
    This implements the Nerode quotient construction: states correspond
    to distinct response profiles (rows of M).
    
    Algorithm:
        1. Compute set of unique rows of M
        2. Map each context to its profile's index
        3. Use unique rows as the decode table
    
    Complexity:
        Time: O(n · m · log(n)) where n = |C|, m = |O|
        Space: O(r · m) where r = rank(M)
    
    Args:
        M: Evaluation table, shape (n_contexts, n_observables), integer-valued
    
    Returns:
        CanonicalRealization with rank = operational_rank(M)
    
    Example:
        >>> M = np.array([[1, 2], [3, 4], [1, 2]])
        >>> R = compute_canonical_realization(M)
        >>> R.rank
        2
        >>> R.encode
        array([0, 1, 0])
    """
    n_contexts, n_observables = M.shape
    unique_rows, encode = np.unique(M, axis=0, return_inverse=True)
    rank = len(unique_rows)
    
    return CanonicalRealization(
        rank=rank,
        encode=encode,
        decode=unique_rows,
        is_reduced=(len(set(encode)) == rank),
        is_separated=(rank == len(unique_rows))  # always true by construction
    )


# ============================================================
# Algorithm 2: Operational Rank
# ============================================================

def operational_rank(M: np.ndarray) -> int:
    """
    Compute the operational rank of an evaluation table.
    
    The operational rank is |image(M)| = number of distinct row profiles.
    This equals the state count of the minimal realization.
    
    Complexity: O(n · m · log(n))
    
    Args:
        M: Evaluation table, shape (n_contexts, n_observables)
    
    Returns:
        Number of distinct response profiles
    
    Example:
        >>> M = np.array([[1,2],[3,4],[1,2],[5,6]])
        >>> operational_rank(M)
        3
    """
    return len(np.unique(M, axis=0))


# ============================================================
# Algorithm 3: Nerode Equivalence Classes
# ============================================================

def compute_nerode_classes(M: np.ndarray) -> List[NerodeClass]:
    """
    Compute the Nerode equivalence classes of M.
    
    Two contexts c₁, c₂ are Nerode-equivalent iff M[c₁,:] = M[c₂,:].
    
    Complexity: O(n · m · log(n))
    
    Args:
        M: Evaluation table, shape (n_contexts, n_observables)
    
    Returns:
        List of NerodeClass objects
    
    Example:
        >>> M = np.array([[1,2],[3,4],[1,2]])
        >>> classes = compute_nerode_classes(M)
        >>> len(classes)
        2
    """
    profile_to_members: Dict[tuple, List[int]] = {}
    for c in range(M.shape[0]):
        key = tuple(M[c, :])
        if key not in profile_to_members:
            profile_to_members[key] = []
        profile_to_members[key].append(c)
    
    return [
        NerodeClass(
            class_id=i,
            members=members,
            profile=np.array(list(profile))
        )
        for i, (profile, members) in enumerate(profile_to_members.items())
    ]


# ============================================================
# Algorithm 4: Tropical Matrix Multiplication
# ============================================================

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.
    
    (A ⊗ B)[i,k] = min_j (A[i,j] + B[j,k])
    
    Complexity: O(n · m · r) where A is n×r and B is r×m
    
    Args:
        A: Left matrix, shape (n, r)
        B: Right matrix, shape (r, m)
    
    Returns:
        Min-plus product, shape (n, m)
    
    Example:
        >>> A = np.array([[0, 5], [5, 0]])
        >>> B = np.array([[1, 2], [3, 4]])
        >>> tropical_matmul(A, B)
        array([[1, 2],
               [4, 5]])
    """
    n, r = A.shape
    r2, m = B.shape
    assert r == r2, f"Inner dimensions must match: {r} vs {r2}"
    
    # Efficient vectorized computation
    # A[:, j:j+1] + B[j:j+1, :] gives the j-th "tropical term"
    result = np.full((n, m), np.inf)
    for j in range(r):
        result = np.minimum(result, A[:, j:j+1] + B[j:j+1, :])
    return result


# ============================================================
# Algorithm 5: Tropical Factorization
# ============================================================

def compute_tropical_factorization(M: np.ndarray) -> TropicalFactorization:
    """
    Compute a tropical (min-plus) factorization of M through Fin(n).
    
    Uses the indicator construction:
    - L[c, s] = 0 if c == s, else B (large bound)
    - R[s, o] = M[s, o]
    
    Then M[c, o] = min_s (L[c,s] + R[s,o]) = M[c,o] because:
    - For s = c: L[c,c] + R[c,o] = 0 + M[c,o] = M[c,o]
    - For s ≠ c: L[c,s] + R[s,o] = B + M[s,o] ≥ M[c,o] (if B large enough)
    
    Complexity: O(n · m)
    
    Args:
        M: Evaluation table, shape (n, m)
    
    Returns:
        TropicalFactorization with rank = n
    """
    n, m = M.shape
    B = 1 + 2 * int(np.max(np.abs(M)))
    
    L = np.full((n, n), B, dtype=np.int64)
    np.fill_diagonal(L, 0)
    
    R = M.copy().astype(np.int64)
    
    return TropicalFactorization(left=L, right=R, rank=n)


# ============================================================
# Algorithm 6: Equivalence Checking
# ============================================================

def are_equivalent(M1: np.ndarray, M2: np.ndarray) -> bool:
    """
    Check if two evaluation tables have isomorphic canonical realizations.
    
    Two tables are equivalent iff they have the same multiset of
    response profiles.
    
    Complexity: O(n · m · log(n))
    
    Args:
        M1, M2: Evaluation tables (may have different numbers of contexts)
    
    Returns:
        True iff the canonical realizations are isomorphic
    
    Example:
        >>> M1 = np.array([[1,2],[3,4],[1,2]])
        >>> M2 = np.array([[3,4],[1,2]])
        >>> are_equivalent(M1, M2)
        True
    """
    profiles1 = set(map(tuple, np.unique(M1, axis=0)))
    profiles2 = set(map(tuple, np.unique(M2, axis=0)))
    return profiles1 == profiles2


# ============================================================
# Algorithm 7: Architecture Compression
# ============================================================

def compress_realization(
    n_states: int,
    encode: np.ndarray,
    decode: np.ndarray,
    M: np.ndarray
) -> Tuple[CanonicalRealization, float]:
    """
    Compress an arbitrary realization to its canonical minimal form.
    
    Given a (possibly overcomplete) realization, computes the canonical
    realization and reports the compression ratio.
    
    Complexity: O(n · m · log(n))
    
    Args:
        n_states: Number of states in original realization
        encode: Original encode map, shape (n_contexts,)
        decode: Original decode table, shape (n_states, n_observables)
        M: The evaluation table being realized
    
    Returns:
        (canonical_realization, compression_ratio)
    """
    canonical = compute_canonical_realization(M)
    ratio = n_states / canonical.rank if canonical.rank > 0 else float('inf')
    return canonical, ratio


# ============================================================
# Algorithm 8: Reconstruction from Response Table
# ============================================================

def reconstruct_from_responses(
    responses: Dict[Tuple[int, int], int]
) -> Tuple[np.ndarray, CanonicalRealization]:
    """
    Reconstruct a canonical minimal architecture from a finite response table.
    
    Given a dictionary mapping (context, observable) pairs to integer costs,
    builds the evaluation table and computes the canonical realization.
    
    This is the "certified reconstruction" algorithm: the output provably
    realizes the input data with minimal state count.
    
    Args:
        responses: Dictionary mapping (context_idx, observable_idx) to cost
    
    Returns:
        (evaluation_table, canonical_realization)
    
    Example:
        >>> responses = {(0,0): 1, (0,1): 2, (1,0): 3, (1,1): 4, (2,0): 1, (2,1): 2}
        >>> M, R = reconstruct_from_responses(responses)
        >>> R.rank
        2
    """
    contexts = sorted(set(c for c, _ in responses.keys()))
    observables = sorted(set(o for _, o in responses.keys()))
    
    n_c = max(contexts) + 1
    n_o = max(observables) + 1
    
    M = np.zeros((n_c, n_o), dtype=np.int64)
    for (c, o), val in responses.items():
        M[c, o] = val
    
    return M, compute_canonical_realization(M)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Operadic Realization — Algorithm Examples")
    print("=" * 60)
    
    # Example 1: Canonical realization
    M = np.array([
        [1, 2, 3],
        [4, 5, 6],
        [1, 2, 3],
        [7, 8, 9],
        [4, 5, 6],
    ])
    
    R = compute_canonical_realization(M)
    print(f"\n1. Canonical realization of 5×3 table:")
    print(f"   Rank: {R.rank}, Canonical: {R.is_canonical}")
    print(f"   Encode: {R.encode}")
    
    # Example 2: Nerode classes
    classes = compute_nerode_classes(M)
    print(f"\n2. Nerode classes: {len(classes)}")
    for nc in classes:
        print(f"   Class {nc.class_id}: contexts {nc.members}")
    
    # Example 3: Tropical factorization
    F = compute_tropical_factorization(M)
    M_check = tropical_matmul(F.left.astype(float), F.right.astype(float))
    print(f"\n3. Tropical factorization rank: {F.rank}")
    print(f"   Correct: {np.allclose(M, M_check)}")
    
    # Example 4: Equivalence
    M2 = np.array([[4,5,6],[7,8,9],[1,2,3]])
    print(f"\n4. Tables equivalent: {are_equivalent(M, M2)}")
    
    # Example 5: Reconstruction
    responses = {(i, j): M[i, j] for i in range(5) for j in range(3)}
    _, R2 = reconstruct_from_responses(responses)
    print(f"\n5. Reconstruction from {len(responses)} responses: rank = {R2.rank}")
