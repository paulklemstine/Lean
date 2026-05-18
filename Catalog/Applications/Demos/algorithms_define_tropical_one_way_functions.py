#!/usr/bin/env python3
"""
Algorithms for Tropical One-Wayness Theory

Implements the core algorithmic primitives for tropical power maps,
root extraction, gap computation, and fiber analysis.
"""

import numpy as np
from typing import Optional, List, Tuple


# ============================================================================
# Algorithm 1: Tropical Min-Plus Matrix Multiplication
# ============================================================================

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.

    Computes (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).

    Time complexity: O(n^3) for n×n matrices.
    Space complexity: O(n^2) for the output matrix.

    Args:
        A: n×m matrix with real entries (or +∞ for missing edges)
        B: m×p matrix with real entries

    Returns:
        n×p result matrix under min-plus multiplication

    Example:
        >>> A = np.array([[0, 3], [7, 1]])
        >>> B = np.array([[2, 5], [4, 0]])
        >>> tropical_matmul(A, B)
        array([[ 2.,  3.],
               [ 5.,  1.]])
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_matpow(A: np.ndarray, T: int) -> np.ndarray:
    """Compute the T-th tropical (min-plus) matrix power A^{⊗T}.

    Uses repeated squaring for efficiency.

    Time complexity: O(n^3 log T) via repeated squaring.
    Space complexity: O(n^2).

    Args:
        A: n×n square matrix
        T: Non-negative integer exponent

    Returns:
        T-th tropical power of A

    Example:
        >>> A = np.array([[0, 3], [7, 1]])
        >>> tropical_matpow(A, 3)  # A ⊗ A ⊗ A
    """
    n = A.shape[0]
    if T == 0:
        # Tropical identity: 0 on diagonal, +∞ elsewhere
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    if T == 1:
        return A.copy()

    # Repeated squaring
    result = None
    base = A.copy()
    while T > 0:
        if T % 2 == 1:
            result = base if result is None else tropical_matmul(result, base)
        base = tropical_matmul(base, base)
        T //= 2
    return result


# ============================================================================
# Algorithm 2: Tropical Diagonal Power (O(n) time)
# ============================================================================

def tropical_pow_diag(T: int, d: np.ndarray) -> np.ndarray:
    """Compute the T-th tropical diagonal power.

    For diagonal tropical matrices, the T-th power simply multiplies
    each diagonal entry by T. This is O(n) time vs O(n^3 log T) for
    general matrices.

    Time complexity: O(n)
    Space complexity: O(n)

    Args:
        T: Power exponent
        d: Vector of diagonal entries

    Returns:
        Vector T * d

    Example:
        >>> tropical_pow_diag(3, np.array([2, 5, -1]))
        array([ 6, 15, -3])
    """
    return T * d


# ============================================================================
# Algorithm 3: Tropical Root Extraction over ℤ
# ============================================================================

def tropical_root_check(T: int, d: np.ndarray) -> Tuple[bool, Optional[np.ndarray]]:
    """Check for and compute tropical T-th root over ℤ.

    A vector d has a tropical T-th root over ℤ iff all entries are
    divisible by T. If so, the unique root is d/T.

    Time complexity: O(n)
    Space complexity: O(n) for the root

    Args:
        T: Root degree (must be ≥ 1)
        d: Integer vector

    Returns:
        Tuple of (has_root, root_or_None)

    Example:
        >>> tropical_root_check(3, np.array([9, 12, 15]))
        (True, array([3, 4, 5]))
        >>> tropical_root_check(3, np.array([9, 12, 16]))
        (False, None)
    """
    assert T >= 1, "T must be at least 1"
    d_int = np.array(d, dtype=int)
    if all(x % T == 0 for x in d_int):
        return True, d_int // T
    else:
        # Find which entries obstruct
        obstructions = [i for i, x in enumerate(d_int) if x % T != 0]
        return False, None


def find_root_obstructions(T: int, d: np.ndarray) -> List[int]:
    """Find all indices where T-divisibility fails.

    These are the precise arithmetic obstructions to tropical root existence.

    Time complexity: O(n)

    Args:
        T: Root degree
        d: Integer vector

    Returns:
        List of indices i where T does not divide d[i]

    Example:
        >>> find_root_obstructions(3, np.array([9, 12, 16, 6, 7]))
        [2, 4]
    """
    return [i for i, x in enumerate(d) if int(x) % T != 0]


# ============================================================================
# Algorithm 4: Gap Computation and Analysis
# ============================================================================

def tropical_gap(d: np.ndarray) -> float:
    """Compute the tropical gap: max(d) - min(d).

    The gap is a forward invariant that scales linearly under tropical
    powering: gap(T * d) = T * gap(d).

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        d: Input vector

    Returns:
        The gap value

    Example:
        >>> tropical_gap(np.array([3, 7, -2, 5]))
        9.0
    """
    return float(np.max(d) - np.min(d))


def gap_amplification_analysis(d: np.ndarray, max_T: int = 20) -> List[Tuple[int, float, float]]:
    """Analyze gap amplification under successive tropical powers.

    Returns a table of (T, gap(T*d), T * gap(d)) showing exact linear scaling.

    Args:
        d: Input vector
        max_T: Maximum power to analyze

    Returns:
        List of (T, actual_gap, expected_gap) triples
    """
    base_gap = tropical_gap(d)
    results = []
    for T in range(1, max_T + 1):
        powered = tropical_pow_diag(T, d)
        actual = tropical_gap(powered)
        expected = T * base_gap
        results.append((T, actual, expected))
    return results


# ============================================================================
# Algorithm 5: Normalization and Fiber Analysis
# ============================================================================

def normalize(d: np.ndarray) -> np.ndarray:
    """Tropical projective normalization: subtract d[0] from all entries.

    This quotients by the additive gauge group: d ~ d + c.

    Time complexity: O(n)

    Args:
        d: Input vector

    Returns:
        Normalized vector with first entry = 0
    """
    return d - d[0]


def fiber_sample(d: np.ndarray, T: int, num_samples: int = 100) -> List[np.ndarray]:
    """Sample elements from the normalized fiber of the tropical power map.

    The normalized fiber of d under tropical T-th power contains all
    vectors d + c for c ∈ ℝ. This samples num_samples such elements.

    Args:
        d: Base vector
        T: Power exponent
        num_samples: Number of fiber elements to generate

    Returns:
        List of vectors in the fiber
    """
    samples = []
    for c in np.linspace(-10, 10, num_samples):
        samples.append(d + c)
    return samples


def verify_fiber_membership(d: np.ndarray, candidate: np.ndarray, T: int) -> bool:
    """Verify that a candidate vector is in the normalized fiber of d.

    Checks: normalize(T * candidate) == normalize(T * d)

    Args:
        d: Target vector
        candidate: Candidate preimage
        T: Power exponent

    Returns:
        True iff candidate is in the normalized fiber
    """
    norm_d = normalize(tropical_pow_diag(T, d))
    norm_candidate = normalize(tropical_pow_diag(T, candidate))
    return np.allclose(norm_d, norm_candidate)


# ============================================================================
# Algorithm 6: Full Tropical Matrix Analysis
# ============================================================================

def tropical_matrix_gap(A: np.ndarray) -> float:
    """Compute the tropical gap of a matrix: max(A) - min(A) over finite entries.

    Ignores +∞ entries (which represent missing edges in the min-plus graph).

    Args:
        A: Matrix with possibly infinite entries

    Returns:
        Gap over finite entries
    """
    finite_mask = np.isfinite(A)
    if not np.any(finite_mask):
        return 0.0
    return float(np.max(A[finite_mask]) - np.min(A[finite_mask]))


def tropical_matrix_power_gap_analysis(A: np.ndarray, max_T: int = 10) -> List[Tuple[int, float]]:
    """Analyze how the gap evolves under tropical matrix powering.

    For general matrices, the gap may grow sublinearly or superlinearly
    depending on the graph structure. For diagonal matrices, growth is
    exactly linear.

    Args:
        A: Square matrix
        max_T: Maximum power

    Returns:
        List of (T, gap(A^{⊗T})) pairs
    """
    results = []
    for T in range(1, max_T + 1):
        powered = tropical_matpow(A, T)
        gap = tropical_matrix_gap(powered)
        results.append((T, gap))
    return results


# ============================================================================
# Demonstration
# ============================================================================

if __name__ == "__main__":
    print("Tropical One-Wayness: Algorithm Demonstrations")
    print("=" * 60)

    # Demo 1: Tropical matrix multiplication
    print("\n--- Tropical Matrix Multiplication ---")
    A = np.array([[0, 3, np.inf],
                  [np.inf, 0, 2],
                  [1, np.inf, 0]], dtype=float)
    print(f"A =\n{A}")
    A2 = tropical_matmul(A, A)
    print(f"A ⊗ A =\n{A2}")
    A3 = tropical_matmul(A2, A)
    print(f"A^⊗3 =\n{A3}")

    # Demo 2: Root check
    print("\n--- Root Extraction ---")
    for T, d in [(2, [4, 6, 8]), (3, [9, 12, 16]), (5, [10, 25, 100])]:
        has_root, root = tropical_root_check(T, np.array(d))
        obst = find_root_obstructions(T, np.array(d))
        print(f"T={T}, d={d}: root={root}, obstructions at indices {obst}")

    # Demo 3: Gap analysis
    print("\n--- Gap Amplification ---")
    d = np.array([2.0, 7.0, -1.0, 4.0])
    results = gap_amplification_analysis(d, max_T=10)
    for T, actual, expected in results:
        print(f"T={T:>2}: gap = {actual:>6.1f}, T*gap(d) = {expected:>6.1f}, match = {np.isclose(actual, expected)}")

    # Demo 4: Matrix gap analysis
    print("\n--- Matrix Gap Under Powering ---")
    A = np.array([[0, 3, 7],
                  [2, 0, 5],
                  [1, 4, 0]], dtype=float)
    results = tropical_matrix_power_gap_analysis(A, max_T=8)
    for T, gap in results:
        print(f"T={T}: gap(A^⊗{T}) = {gap:.1f}")
