"""
Hadamard Matrix Algorithms — Verified Constructions

This module implements the core algorithms for Hadamard matrix construction,
normalization, and analysis. Each algorithm mirrors a formally verified
theorem in the Lean 4 development.

Algorithms:
    1. Sylvester construction (recursive Kronecker product)
    2. Normalization procedure (sign-flip to first row/column all +1)
    3. Hadamard code generator (±1 → binary encoding)
    4. Hadamard verification (check orthogonality)
    5. Excess computation
"""

from __future__ import annotations
import numpy as np
from typing import Optional


def sylvester_matrix(k: int) -> np.ndarray:
    """
    Construct the Sylvester-Hadamard matrix of order 2^k.

    Uses the recursive definition:
        H_0 = [[1]]
        H_{k+1} = [[H_k, H_k], [H_k, -H_k]]

    This is equivalent to the k-fold Kronecker product of [[1,1],[1,-1]].

    Complexity: O(4^k) time and space (the matrix has 4^k entries).

    Args:
        k: Non-negative integer. The matrix has order 2^k.

    Returns:
        A 2^k × 2^k numpy integer array with entries ±1.

    Examples:
        >>> sylvester_matrix(0)
        array([[1]])
        >>> sylvester_matrix(1)
        array([[ 1,  1],
               [ 1, -1]])
        >>> sylvester_matrix(2)
        array([[ 1,  1,  1,  1],
               [ 1, -1,  1, -1],
               [ 1,  1, -1, -1],
               [ 1, -1, -1,  1]])
    """
    if k < 0:
        raise ValueError(f"k must be non-negative, got {k}")
    H = np.array([[1]], dtype=int)
    seed = np.array([[1, 1], [1, -1]], dtype=int)
    for _ in range(k):
        H = np.kron(H, seed)
    return H


def kronecker_hadamard(H1: np.ndarray, H2: np.ndarray) -> np.ndarray:
    """
    Construct the Kronecker (tensor) product of two matrices.

    If H1 is m×m and H2 is n×n, returns the (mn)×(mn) matrix H1 ⊗ H2.
    When both inputs are Hadamard, the output is Hadamard (formally verified).

    Args:
        H1: First matrix.
        H2: Second matrix.

    Returns:
        The Kronecker product H1 ⊗ H2.
    """
    return np.kron(H1, H2)


def is_hadamard(H: np.ndarray) -> bool:
    """
    Verify that a matrix is Hadamard.

    Checks:
        1. All entries are ±1.
        2. H * H^T = n * I.

    Args:
        H: Square integer matrix to check.

    Returns:
        True if H is a valid Hadamard matrix.
    """
    n = H.shape[0]
    if H.shape != (n, n):
        return False
    if not np.all(np.abs(H) == 1):
        return False
    product = H @ H.T
    expected = n * np.eye(n, dtype=int)
    return np.array_equal(product, expected)


def normalize_hadamard(H: np.ndarray) -> np.ndarray:
    """
    Normalize a Hadamard matrix so that the first row and column are all +1.

    Algorithm:
        1. Multiply each column j by H[0, j] (makes first row all +1).
        2. Multiply each row i by the new H[i, 0] (makes first column all +1).

    This mirrors the formal proof: H'[i][j] = H[0][0] * H[i][0] * H[0][j] * H[i][j].

    Args:
        H: A Hadamard matrix (entries ±1, H * H^T = n * I).

    Returns:
        A normalized Hadamard matrix with first row and column all +1.
    """
    H_norm = H.copy()
    # Step 1: Fix first row
    signs_row = H_norm[0, :].copy()
    H_norm = H_norm * signs_row[np.newaxis, :]
    # Step 2: Fix first column
    signs_col = H_norm[:, 0].copy()
    H_norm = H_norm * signs_col[:, np.newaxis]
    return H_norm


def hadamard_code(H: np.ndarray) -> np.ndarray:
    """
    Generate the binary Hadamard code from a Hadamard matrix.

    Maps each entry: +1 → 0, -1 → 1.
    Each row of the result is a binary codeword.

    Args:
        H: A Hadamard matrix.

    Returns:
        An n × n binary matrix (entries 0 or 1).
    """
    return ((1 - H) // 2).astype(int)


def hamming_distance(u: np.ndarray, v: np.ndarray) -> int:
    """
    Compute the Hamming distance between two binary vectors.

    Args:
        u, v: Binary vectors of the same length.

    Returns:
        Number of positions where u and v differ.
    """
    return int(np.sum(u != v))


def hadamard_excess(H: np.ndarray) -> int:
    """
    Compute the excess of a Hadamard matrix: the sum of all entries.

    For a Hadamard matrix of order n, the excess σ(H) satisfies σ(H)² ≤ n³
    (formally verified).

    Args:
        H: A Hadamard matrix.

    Returns:
        The sum of all entries.
    """
    return int(np.sum(H))


def verify_code_equidistance(H: np.ndarray) -> dict:
    """
    Verify that the Hadamard code has equidistant property.

    For a Hadamard matrix of order n, all distinct codeword pairs
    should have Hamming distance exactly n/2 (formally verified).

    Args:
        H: A Hadamard matrix.

    Returns:
        Dictionary with verification results.
    """
    n = H.shape[0]
    code = hadamard_code(H)
    distances = set()
    for i in range(n):
        for j in range(i + 1, n):
            d = hamming_distance(code[i], code[j])
            distances.add(d)

    return {
        "order": n,
        "num_codewords": n,
        "code_length": n,
        "all_distances": sorted(distances),
        "is_equidistant": len(distances) == 1,
        "expected_distance": n // 2,
        "verified": distances == {n // 2},
    }


def walsh_hadamard_transform(x: np.ndarray, k: int) -> np.ndarray:
    """
    Compute the Walsh-Hadamard transform of a vector.

    WHT(x) = H_k · x where H_k is the Sylvester matrix of order 2^k.
    Satisfies the energy identity: ‖WHT(x)‖² = 2^k · ‖x‖² (formally verified).

    Args:
        x: Input vector of length 2^k.
        k: Order parameter (matrix is 2^k × 2^k).

    Returns:
        The transformed vector H_k · x.
    """
    n = 2**k
    if len(x) != n:
        raise ValueError(f"Input vector length {len(x)} != 2^{k} = {n}")
    H = sylvester_matrix(k)
    return H @ x


def verify_energy_identity(x: np.ndarray, k: int) -> dict:
    """
    Verify the Walsh-Hadamard energy identity: ‖Hx‖² = n·‖x‖².

    Args:
        x: Input vector of length 2^k.
        k: Order parameter.

    Returns:
        Dictionary with verification results.
    """
    n = 2**k
    Hx = walsh_hadamard_transform(x, k)
    lhs = int(np.sum(Hx**2))
    rhs = n * int(np.sum(x**2))
    return {
        "n": n,
        "input_energy": int(np.sum(x**2)),
        "output_energy": lhs,
        "expected_output_energy": rhs,
        "ratio": lhs / max(int(np.sum(x**2)), 1),
        "verified": lhs == rhs,
    }


def paley_matrix_type_I(q: int) -> Optional[np.ndarray]:
    """
    Attempt to construct a Paley-type I Hadamard matrix of order q+1.

    Requires q to be a prime power with q ≡ 3 (mod 4).
    Uses the quadratic residue character χ over GF(q).

    The conference matrix C has C[i][j] = χ(i - j) for i, j ∈ GF(q),
    and the Hadamard matrix is I + C bordered by a row/column of +1s.

    Args:
        q: A prime with q ≡ 3 (mod 4).

    Returns:
        A (q+1) × (q+1) Hadamard matrix, or None if q doesn't satisfy conditions.
    """
    def _is_prime(n):
        if n < 2: return False
        for p in range(2, int(n**0.5) + 1):
            if n % p == 0: return False
        return True

    def _legendre(a, p):
        a = a % p
        if a == 0: return 0
        if pow(a, (p - 1) // 2, p) == 1: return 1
        return -1

    if not _is_prime(q) or q % 4 != 3:
        return None

    n = q + 1
    # Build quadratic residue matrix Q[i][j] = legendre((j-i) mod q, q)
    Q = np.zeros((q, q), dtype=int)
    for i in range(q):
        for j in range(q):
            Q[i, j] = _legendre((j - i) % q, q)

    # Paley Type I: H = [[-1, j^T], [j, Q + I]]
    j_vec = np.ones(q, dtype=int)
    H = np.zeros((n, n), dtype=int)
    H[0, 0] = -1
    H[0, 1:] = j_vec
    H[1:, 0] = j_vec
    H[1:, 1:] = Q + np.eye(q, dtype=int)

    if is_hadamard(H):
        return H
    return None


if __name__ == "__main__":
    # Quick self-test
    for k in range(5):
        H = sylvester_matrix(k)
        assert is_hadamard(H), f"Sylvester matrix of order 2^{k} failed verification"
    print("All Sylvester matrices verified.")

    H4 = sylvester_matrix(2)
    result = verify_code_equidistance(H4)
    assert result["verified"], "Code equidistance check failed"
    print(f"Hadamard code of order {result['order']}: distance = {result['expected_distance']}")

    x = np.array([1, 2, 3, 4])
    energy = verify_energy_identity(x, 2)
    assert energy["verified"], "Energy identity check failed"
    print(f"Energy identity verified: ratio = {energy['ratio']}")
