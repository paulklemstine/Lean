#!/usr/bin/env python3
"""
Invariant Subspace Algorithms

Implements computational methods for finding invariant subspaces:
1. Eigenvalue-based invariant subspace extraction
2. Schur decomposition for invariant subspace chains
3. Spectral projection computation for self-adjoint operators
4. Compact operator approximation via truncated SVD
5. Krylov subspace method for approximate invariant subspaces
"""

import numpy as np
from numpy.linalg import norm, eig, svd, qr
from typing import List, Tuple, Optional


def find_eigenspace_invariant_subspace(
    A: np.ndarray,
    tol: float = 1e-10
) -> Tuple[np.ndarray, complex, int]:
    """
    Find a nontrivial invariant subspace via eigenvalue computation.
    
    For any square complex matrix A of dimension n ≥ 2, returns an
    orthonormal basis for a nontrivial invariant subspace.
    
    Algorithm:
        1. Compute eigenvalues and eigenvectors of A.
        2. Select the eigenvalue with largest magnitude.
        3. Return the eigenspace as the invariant subspace.
    
    Args:
        A: Square complex matrix (n × n, n ≥ 2).
        tol: Tolerance for grouping eigenvalues.
    
    Returns:
        basis: Orthonormal basis for the invariant subspace (n × k).
        eigenvalue: The corresponding eigenvalue.
        dim: Dimension of the invariant subspace.
    
    Complexity: O(n³) — dominated by eigenvalue computation.
    """
    n = A.shape[0]
    assert n >= 2, "Matrix must be at least 2×2"
    assert A.shape == (n, n), "Matrix must be square"
    
    eigenvalues, eigenvectors = eig(A)
    
    # Select eigenvalue with largest magnitude
    idx = np.argmax(np.abs(eigenvalues))
    target_eval = eigenvalues[idx]
    
    # Group eigenvectors with the same eigenvalue (within tolerance)
    mask = np.abs(eigenvalues - target_eval) < tol
    basis_vectors = eigenvectors[:, mask]
    
    # Orthonormalize the basis
    basis, _ = qr(basis_vectors, mode='reduced')
    dim = basis.shape[1]
    
    # If eigenspace is all of V, pick a different eigenvalue
    if dim >= n:
        # A is a scalar matrix — any 1-d subspace works
        e1 = np.zeros(n, dtype=complex)
        e1[0] = 1.0
        return e1.reshape(-1, 1), target_eval, 1
    
    return basis, target_eval, dim


def schur_invariant_subspace_chain(
    A: np.ndarray
) -> List[Tuple[np.ndarray, int]]:
    """
    Compute a complete chain of nested invariant subspaces via Schur decomposition.
    
    The Schur decomposition A = QTQ* gives an upper triangular T and unitary Q.
    The first k columns of Q span a k-dimensional invariant subspace for each k.
    
    Algorithm:
        1. Compute Schur decomposition A = QTQ*.
        2. For each k = 1, 2, ..., n-1, the first k columns of Q 
           span a k-dimensional invariant subspace.
    
    Args:
        A: Square complex matrix (n × n).
    
    Returns:
        List of (basis, dimension) pairs for the chain:
        {0} ⊂ V₁ ⊂ V₂ ⊂ ... ⊂ V_{n-1} ⊂ ℂⁿ
    
    Complexity: O(n³) — Schur decomposition.
    """
    from scipy.linalg import schur
    
    T, Q = schur(A, output='complex')
    n = A.shape[0]
    
    chain = []
    for k in range(1, n):
        basis = Q[:, :k]
        chain.append((basis.copy(), k))
    
    return chain


def spectral_projection(
    A: np.ndarray,
    interval: Tuple[float, float],
    tol: float = 1e-10
) -> np.ndarray:
    """
    Compute the spectral projection for a self-adjoint operator
    onto eigenvalues in a given interval [a, b].
    
    For a Hermitian matrix A with spectral decomposition A = Σ λᵢ vᵢvᵢ*,
    the spectral projection E([a,b]) = Σ_{λᵢ ∈ [a,b]} vᵢvᵢ*.
    
    Algorithm:
        1. Diagonalize A (guaranteed real eigenvalues for Hermitian A).
        2. Select eigenvectors with eigenvalues in [a, b].
        3. Form the projection P = Σ vᵢvᵢ*.
    
    Args:
        A: Hermitian matrix (n × n).
        interval: Tuple (a, b) specifying the spectral interval.
        tol: Tolerance for interval membership.
    
    Returns:
        P: Spectral projection matrix (n × n).
        P is an orthogonal projection: P² = P = P*.
        Range(P) is a reducing subspace for A.
    
    Complexity: O(n³) — eigenvalue computation + projection formation.
    """
    n = A.shape[0]
    a, b = interval
    
    # Verify approximate self-adjointness
    assert norm(A - A.conj().T) < tol * norm(A) + tol, \
        f"Matrix is not self-adjoint: ‖A - A*‖ = {norm(A - A.conj().T):.2e}"
    
    # Diagonalize (eigenvalues are real for Hermitian matrices)
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    
    # Select eigenvalues in [a, b]
    mask = (eigenvalues >= a - tol) & (eigenvalues <= b + tol)
    selected = eigenvectors[:, mask]
    
    if selected.shape[1] == 0:
        return np.zeros((n, n), dtype=complex)
    
    # Form projection
    P = selected @ selected.conj().T
    
    return P


def compact_operator_eigenspaces(
    T: np.ndarray,
    rank_threshold: float = 1e-10,
    n_eigenvalues: int = 10
) -> List[Tuple[complex, np.ndarray, int]]:
    """
    Find eigenspaces of a compact operator (approximated as a finite-rank operator).
    
    Algorithm:
        1. Compute SVD to determine effective rank.
        2. Compute eigenvalues and eigenvectors.
        3. Group by eigenvalue to find eigenspaces.
        4. Each eigenspace is a nontrivial closed invariant subspace.
    
    Args:
        T: Matrix representing the compact operator.
        rank_threshold: Threshold for singular value significance.
        n_eigenvalues: Maximum number of eigenvalues to return.
    
    Returns:
        List of (eigenvalue, basis, multiplicity) tuples.
    
    Complexity: O(n³) for full eigendecomposition.
    """
    n = T.shape[0]
    
    # Determine effective rank
    _, sigma, _ = svd(T)
    effective_rank = np.sum(sigma > rank_threshold)
    
    # Compute eigenvalues
    eigenvalues, eigenvectors = eig(T)
    
    # Sort by magnitude (descending)
    order = np.argsort(-np.abs(eigenvalues))
    eigenvalues = eigenvalues[order]
    eigenvectors = eigenvectors[:, order]
    
    # Group eigenvalues (within tolerance)
    tol = 1e-8
    results = []
    visited = set()
    
    for i in range(min(n_eigenvalues, n)):
        if i in visited or np.abs(eigenvalues[i]) < rank_threshold:
            continue
        
        # Find all eigenvectors with same eigenvalue
        mask = np.abs(eigenvalues - eigenvalues[i]) < tol
        indices = np.where(mask)[0]
        for idx in indices:
            visited.add(idx)
        
        basis = eigenvectors[:, mask]
        basis, _ = qr(basis, mode='reduced')
        mult = basis.shape[1]
        
        results.append((eigenvalues[i], basis, mult))
    
    return results


def krylov_invariant_subspace(
    A: np.ndarray,
    v0: np.ndarray,
    k: int,
    reorthogonalize: bool = True
) -> Tuple[np.ndarray, np.ndarray]:
    """
    Compute an approximate invariant subspace using the Krylov method.
    
    The Krylov subspace K_k(A, v) = span{v, Av, A²v, ..., A^{k-1}v}
    is approximately invariant when it captures the dominant spectral behavior.
    
    Algorithm (Arnoldi iteration):
        1. Start with normalized v₀.
        2. For j = 1, ..., k-1:
           a. Compute w = A * v_j
           b. Orthogonalize w against v₀, ..., v_j (modified Gram-Schmidt)
           c. Normalize to get v_{j+1}
        3. The resulting orthonormal basis spans an approximate invariant subspace.
    
    Args:
        A: Square matrix (n × n).
        v0: Starting vector.
        k: Dimension of Krylov subspace.
        reorthogonalize: Whether to apply double Gram-Schmidt.
    
    Returns:
        Q: Orthonormal basis for the Krylov subspace (n × k).
        H: Upper Hessenberg matrix (k × k) — the restriction of A to K_k.
    
    Complexity: O(k · n²) — k matrix-vector products plus orthogonalization.
    """
    n = A.shape[0]
    k = min(k, n)
    
    Q = np.zeros((n, k), dtype=complex)
    H = np.zeros((k, k), dtype=complex)
    
    # Normalize starting vector
    Q[:, 0] = v0 / norm(v0)
    
    for j in range(k - 1):
        w = A @ Q[:, j]
        
        # Modified Gram-Schmidt orthogonalization
        for i in range(j + 1):
            H[i, j] = np.vdot(Q[:, i], w)
            w -= H[i, j] * Q[:, i]
        
        # Optional re-orthogonalization for numerical stability
        if reorthogonalize:
            for i in range(j + 1):
                s = np.vdot(Q[:, i], w)
                w -= s * Q[:, i]
                H[i, j] += s
        
        h_next = norm(w)
        if h_next < 1e-14:
            # Krylov subspace is exactly invariant
            Q = Q[:, :j+1]
            H = H[:j+1, :j+1]
            break
        
        H[j+1, j] = h_next
        Q[:, j+1] = w / h_next
    
    # Fill in last column of H
    if Q.shape[1] == k:
        w = A @ Q[:, k-1]
        for i in range(k):
            H[i, k-1] = np.vdot(Q[:, i], w)
    
    return Q, H[:Q.shape[1], :Q.shape[1]]


def verify_invariant_subspace(
    A: np.ndarray,
    basis: np.ndarray,
    tol: float = 1e-8
) -> Tuple[bool, float]:
    """
    Verify that the column space of `basis` is an invariant subspace of A.
    
    A subspace M is invariant under A if A(M) ⊆ M.
    Equivalently, if Q is an orthonormal basis for M, then
    (I - QQ*)AQ should be zero.
    
    Args:
        A: Square matrix.
        basis: Matrix whose columns span the candidate subspace.
        tol: Tolerance for the invariance check.
    
    Returns:
        is_invariant: Whether the subspace is approximately invariant.
        residual: The invariance residual ‖(I - QQ*)AQ‖.
    """
    n = A.shape[0]
    Q, _ = qr(basis, mode='reduced')
    
    # Project A*Q onto the orthogonal complement of Q
    AQ = A @ Q
    projection = Q @ (Q.conj().T @ AQ)
    residual_matrix = AQ - projection
    residual = norm(residual_matrix)
    
    return residual < tol, residual


if __name__ == "__main__":
    print("=" * 70)
    print("INVARIANT SUBSPACE ALGORITHMS — EXAMPLES")
    print("=" * 70)
    
    # Example 1: Eigenspace method
    print("\n--- Algorithm 1: Eigenspace Invariant Subspace ---")
    np.random.seed(42)
    A = np.random.randn(5, 5) + 1j * np.random.randn(5, 5)
    basis, ev, dim = find_eigenspace_invariant_subspace(A)
    is_inv, res = verify_invariant_subspace(A, basis)
    print(f"Matrix: 5×5 complex")
    print(f"Eigenvalue: {ev:.4f}")
    print(f"Invariant subspace dimension: {dim}")
    print(f"Invariance residual: {res:.2e}")
    print(f"Verified: {is_inv}")
    
    # Example 2: Schur chain
    print("\n--- Algorithm 2: Schur Invariant Subspace Chain ---")
    chain = schur_invariant_subspace_chain(A)
    for basis, dim in chain:
        is_inv, res = verify_invariant_subspace(A, basis)
        print(f"  dim={dim}: invariance residual = {res:.2e}, verified = {is_inv}")
    
    # Example 3: Spectral projection
    print("\n--- Algorithm 3: Spectral Projection ---")
    H = np.random.randn(6, 6)
    H = (H + H.T) / 2  # Make symmetric
    evals = np.sort(np.linalg.eigvalsh(H))
    print(f"Eigenvalues: {evals}")
    
    # Project onto lower half of spectrum
    mid = (evals[2] + evals[3]) / 2
    P = spectral_projection(H, (-np.inf, mid))
    print(f"Projection onto eigenvalues ≤ {mid:.3f}:")
    print(f"  Rank = {np.trace(np.real(P)):.0f}")
    print(f"  ‖P² - P‖ = {norm(P @ P - P):.2e}")
    print(f"  ‖P - P*‖ = {norm(P - P.conj().T):.2e}")
    is_inv, res = verify_invariant_subspace(H, P)
    print(f"  Invariance residual: {res:.2e}")
    
    # Example 4: Krylov subspace
    print("\n--- Algorithm 4: Krylov Invariant Subspace ---")
    v0 = np.random.randn(5) + 1j * np.random.randn(5)
    for k in [2, 3, 4]:
        Q, Hess = krylov_invariant_subspace(A, v0, k)
        is_inv, res = verify_invariant_subspace(A, Q)
        print(f"  K_{k}(A, v₀): dim={Q.shape[1]}, invariance residual = {res:.2e}")
