"""
Tropical Isogeny Rigidity: Core Algorithms

Implements the key algorithms from the tropical isogeny rigidity theorem:
1. Min-plus matrix-vector multiplication
2. Test vector construction and matrix entry recovery
3. Full tropical matrix recovery from oracle access
4. Spectral fingerprinting
5. Congruence kernel computation
"""

import numpy as np
from typing import Callable, Optional, Tuple, List
from dataclasses import dataclass


# =============================================================================
# Algorithm 1: Min-Plus Matrix-Vector Product
# =============================================================================

def trop_mv(A: np.ndarray, v: np.ndarray) -> np.ndarray:
    """Min-plus matrix-vector product: (A⊗v)_i = min_j(A_{ij} + v_j).

    Complexity: O(g²) where g = A.shape[0].

    Args:
        A: g×g integer matrix
        v: g-dimensional integer vector

    Returns:
        g-dimensional vector with (result)_i = min_j(A_{ij} + v_j)

    Example:
        >>> A = np.array([[1, 2], [3, 4]])
        >>> v = np.array([0, 10])
        >>> trop_mv(A, v)  # [min(1+0, 2+10), min(3+0, 4+10)] = [1, 3]
        array([1., 3.])
    """
    # Broadcasting: A[i,:] + v gives row i shifted by v
    # np.min along axis 1 takes the minimum over j
    return np.min(A + v[np.newaxis, :], axis=1)


def trop_mm(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Min-plus matrix-matrix product: (A⊗B)_{ij} = min_k(A_{ik} + B_{kj}).

    Complexity: O(g³).

    Args:
        A, B: g×g integer matrices

    Returns:
        g×g matrix with (result)_{ij} = min_k(A_{ik} + B_{kj})
    """
    g = A.shape[0]
    result = np.zeros((g, g))
    for i in range(g):
        for j in range(g):
            result[i, j] = np.min(A[i, :] + B[:, j])
    return result


# =============================================================================
# Algorithm 2: Test Vector Construction
# =============================================================================

def test_vec(g: int, j: int, M: int) -> np.ndarray:
    """Construct test vector concentrating at index j.

    testVec(j, M)_k = 0 if k = j, M otherwise.

    The key property: for M large enough,
    (A ⊗ testVec(j,M))_i = A_{ij}.

    Args:
        g: Dimension
        j: Target index (0-based)
        M: Penalty value (must be large enough)

    Returns:
        g-dimensional test vector
    """
    v = np.full(g, float(M))
    v[j] = 0.0
    return v


def compute_penalty(A: np.ndarray, B: np.ndarray = None) -> int:
    """Compute minimum penalty M for test vector recovery.

    For matrix A, we need M > max_{i,j,k: k≠j} (A_{ij} - A_{ik}).
    We use M = 1 + 2 * max|A_{ij}| which suffices.

    Args:
        A: First matrix
        B: Optional second matrix (M must work for both)

    Returns:
        Integer penalty M
    """
    bound = int(np.max(np.abs(A))) * 2 + 1
    if B is not None:
        bound = max(bound, int(np.max(np.abs(B))) * 2 + 1)
    return bound


# =============================================================================
# Algorithm 3: Tropical Matrix Recovery
# =============================================================================

def recover_tropical_matrix(
    oracle: Callable[[np.ndarray], np.ndarray],
    g: int,
    M: Optional[int] = None
) -> np.ndarray:
    """Recover a tropical matrix from its min-plus action oracle.

    Algorithm:
        For each column j = 0, ..., g-1:
            1. Construct test vector v = testVec(j, M)
            2. Evaluate oracle(v) = A ⊗ v
            3. Extract column j: A_{ij} = (A ⊗ v)_i for all i

    Complexity: O(g²) oracle calls, each O(g²) time → O(g⁴) total.

    Correctness: By the entry recovery lemma (tropMV_testVec_eq),
    for M large enough, (A ⊗ testVec(j,M))_i = A_{ij}.

    Args:
        oracle: Function v ↦ A⊗v (black-box min-plus action)
        g: Matrix dimension
        M: Penalty parameter (auto-computed if None)

    Returns:
        Recovered g×g matrix A

    Pseudocode:
        RECOVER-TROPICAL-MATRIX(oracle, g, M):
          A_rec ← zeros(g, g)
          for j = 0 to g-1:
            v ← TEST-VEC(g, j, M)
            w ← oracle(v)
            for i = 0 to g-1:
              A_rec[i, j] ← w[i]
          return A_rec
    """
    if M is None:
        M = 10**9  # Default large penalty
    A_rec = np.zeros((g, g))
    for j in range(g):
        v = test_vec(g, j, M)
        w = oracle(v)
        A_rec[:, j] = w
    return A_rec


# =============================================================================
# Algorithm 4: Spectral Fingerprinting
# =============================================================================

@dataclass
class SpectralFingerprint:
    """Compressed spectral data of a harmonic correspondence.

    The fingerprint is the g×g matrix recovered from the correspondence's
    min-plus action on all test vectors.
    """
    matrix: np.ndarray
    dimension: int

    def __eq__(self, other: 'SpectralFingerprint') -> bool:
        return np.array_equal(self.matrix, other.matrix)


def compute_fingerprint(
    oracle: Callable[[np.ndarray], np.ndarray],
    g: int,
    M: Optional[int] = None
) -> SpectralFingerprint:
    """Compute the spectral fingerprint of a correspondence.

    This is the "compressed spectral data" from the main theorem.

    Args:
        oracle: The correspondence's min-plus action
        g: Dimension (genus)
        M: Penalty parameter

    Returns:
        SpectralFingerprint containing the recovered matrix
    """
    matrix = recover_tropical_matrix(oracle, g, M)
    return SpectralFingerprint(matrix=matrix, dimension=g)


def check_principal_equivalence(
    fp1: SpectralFingerprint,
    fp2: SpectralFingerprint
) -> bool:
    """Check if two correspondences are principally equivalent.

    By the master theorem, principal equivalence ↔ equal fingerprints.

    Args:
        fp1, fp2: Spectral fingerprints

    Returns:
        True iff the correspondences are principally equivalent
    """
    return fp1 == fp2


# =============================================================================
# Algorithm 5: Congruence Kernel
# =============================================================================

@dataclass
class CongruenceKernelResult:
    """Result of congruence kernel analysis."""
    is_trivial: bool
    kernel_size: int
    separating_vector: Optional[np.ndarray]  # Vector distinguishing the actions


def analyze_congruence(
    oracle_A: Callable[[np.ndarray], np.ndarray],
    oracle_B: Callable[[np.ndarray], np.ndarray],
    g: int,
    M: Optional[int] = None
) -> CongruenceKernelResult:
    """Analyze the congruence kernel of two tropical actions.

    Determines whether two min-plus actions are identical (in the
    congruence kernel) or can be distinguished (certified separation).

    Algorithm:
        1. Compute fingerprints of both actions
        2. If fingerprints agree: in congruence kernel (principally equivalent)
        3. If fingerprints differ: find separating vector

    Args:
        oracle_A, oracle_B: Min-plus action oracles
        g: Dimension
        M: Penalty parameter

    Returns:
        CongruenceKernelResult with analysis
    """
    fp_A = compute_fingerprint(oracle_A, g, M)
    fp_B = compute_fingerprint(oracle_B, g, M)

    if fp_A == fp_B:
        return CongruenceKernelResult(
            is_trivial=True,
            kernel_size=0,
            separating_vector=None
        )
    else:
        # Find the first differing entry and construct a separating vector
        diff = np.where(fp_A.matrix != fp_B.matrix)
        i, j = diff[0][0], diff[1][0]
        if M is None:
            M = 10**9
        sep_vec = test_vec(g, j, M)
        return CongruenceKernelResult(
            is_trivial=True,  # Kernel is trivial (no non-trivial collisions)
            kernel_size=0,
            separating_vector=sep_vec
        )


# =============================================================================
# Algorithm 6: Tropical Key Exchange (Prototype)
# =============================================================================

@dataclass
class TropicalPublicKey:
    """Public key in the tropical isogeny scheme."""
    fingerprint: SpectralFingerprint


@dataclass
class TropicalPrivateKey:
    """Private key: the hidden harmonic correspondence (tropical matrix)."""
    matrix: np.ndarray


def keygen(g: int, entry_range: int = 100) -> Tuple[TropicalPrivateKey, TropicalPublicKey]:
    """Generate a tropical key pair.

    Args:
        g: Dimension (genus of the tropical curve)
        entry_range: Range of matrix entries

    Returns:
        (private_key, public_key) tuple
    """
    A = np.random.randint(-entry_range, entry_range + 1, size=(g, g)).astype(float)
    sk = TropicalPrivateKey(matrix=A)

    M = compute_penalty(A)
    fp = compute_fingerprint(lambda v: trop_mv(A, v), g, M)
    pk = TropicalPublicKey(fingerprint=fp)

    return sk, pk


def verify_correspondence(
    pk: TropicalPublicKey,
    candidate: np.ndarray
) -> bool:
    """Verify that a candidate matrix matches a public key.

    Args:
        pk: Public key (spectral fingerprint)
        candidate: Candidate tropical matrix

    Returns:
        True if the candidate realizes the public key
    """
    return np.array_equal(candidate, pk.fingerprint.matrix)


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("Tropical Isogeny Rigidity: Algorithm Demonstrations\n")

    # Example 1: Matrix recovery
    g = 4
    A = np.array([
        [3, 1, 4, 1],
        [5, 9, 2, 6],
        [5, 3, 5, 8],
        [9, 7, 9, 3]
    ], dtype=float)

    M = compute_penalty(A)
    oracle = lambda v: trop_mv(A, v)
    recovered = recover_tropical_matrix(oracle, g, M)

    print(f"Original matrix A:\n{A.astype(int)}")
    print(f"\nRecovered matrix:\n{recovered.astype(int)}")
    print(f"Recovery correct: {np.array_equal(A, recovered)}\n")

    # Example 2: Fingerprinting
    fp = compute_fingerprint(oracle, g, M)
    print(f"Spectral fingerprint dimension: {fp.dimension}")
    print(f"Fingerprint matches matrix: {np.array_equal(fp.matrix, A)}\n")

    # Example 3: Key generation
    sk, pk = keygen(g=5)
    print(f"Generated key pair for genus g=5")
    print(f"Private key (matrix):\n{sk.matrix.astype(int)}")
    print(f"Public key matches private: {verify_correspondence(pk, sk.matrix)}")
