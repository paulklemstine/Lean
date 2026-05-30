#!/usr/bin/env python3
"""
Algorithms for Invariant Subspace Detection and Analysis

Implements algorithms for finding invariant subspaces, testing the invariant
subspace property, and analyzing operator structure.
"""

import numpy as np
from numpy.linalg import eig, svd, norm, qr
from typing import Optional, Tuple, List


def find_invariant_subspaces(
    T: np.ndarray,
    tol: float = 1e-10
) -> List[Tuple[complex, np.ndarray]]:
    """
    Find all eigenspace invariant subspaces of a matrix T.
    
    For each distinct eigenvalue μ, returns (μ, basis_of_E_μ).
    These are guaranteed to be T-invariant subspaces.
    
    Args:
        T: Square complex matrix (n × n)
        tol: Tolerance for eigenvalue clustering
    
    Returns:
        List of (eigenvalue, basis) pairs where basis is an orthonormal
        matrix whose columns span the eigenspace.
    
    Complexity: O(n³) for eigendecomposition
    """
    n = T.shape[0]
    eigenvalues, eigenvectors = eig(T)
    
    # Cluster eigenvalues
    visited = [False] * n
    subspaces = []
    
    for i in range(n):
        if visited[i]:
            continue
        mu = eigenvalues[i]
        # Find all eigenvectors for this eigenvalue
        cluster_indices = []
        for j in range(i, n):
            if not visited[j] and abs(eigenvalues[j] - mu) < tol:
                cluster_indices.append(j)
                visited[j] = True
        
        # Extract and orthogonalize basis
        basis = eigenvectors[:, cluster_indices]
        Q, _ = qr(basis, mode='reduced')
        Q = Q[:, :len(cluster_indices)]
        
        subspaces.append((mu, Q))
    
    return subspaces


def test_invariance(
    T: np.ndarray,
    M_basis: np.ndarray,
    tol: float = 1e-8
) -> Tuple[bool, float]:
    """
    Test whether a subspace M (given by its orthonormal basis columns)
    is invariant under T.
    
    M is T-invariant iff T(M) ⊆ M, equivalently, P_M⊥ T P_M = 0
    where P_M is the orthogonal projection onto M.
    
    Args:
        T: Square matrix (n × n)
        M_basis: Orthonormal basis columns for M (n × k)
        tol: Tolerance for invariance check
    
    Returns:
        (is_invariant, leakage) where leakage measures ‖P_M⊥ T M‖
    
    Complexity: O(n²k) for projection and multiplication
    """
    n = T.shape[0]
    # Projection onto M
    P_M = M_basis @ M_basis.conj().T
    # Projection onto M⊥
    P_perp = np.eye(n) - P_M
    
    # Leakage: how much T(M) leaks into M⊥
    leakage = norm(P_perp @ T @ M_basis)
    
    return leakage < tol, leakage


def test_reducing(
    T: np.ndarray,
    M_basis: np.ndarray,
    tol: float = 1e-8
) -> Tuple[bool, float, float]:
    """
    Test whether M is a reducing subspace for T.
    M is reducing iff both M and M⊥ are T-invariant.
    
    Args:
        T: Square matrix (n × n)
        M_basis: Orthonormal basis columns for M (n × k)
        tol: Tolerance
    
    Returns:
        (is_reducing, M_leakage, M_perp_leakage)
    
    Complexity: O(n³) for complement computation
    """
    n = T.shape[0]
    k = M_basis.shape[1]
    
    # Test M invariance
    is_M_inv, M_leak = test_invariance(T, M_basis, tol)
    
    # Compute M⊥ basis
    P_M = M_basis @ M_basis.conj().T
    P_perp = np.eye(n) - P_M
    # Get orthonormal basis for M⊥
    U, S, _ = svd(P_perp)
    M_perp_basis = U[:, :n - k]
    
    # Test M⊥ invariance
    is_perp_inv, perp_leak = test_invariance(T, M_perp_basis, tol)
    
    return is_M_inv and is_perp_inv, M_leak, perp_leak


def approximate_invariant_subspace_iteration(
    T: np.ndarray,
    dim: int,
    max_iter: int = 1000,
    tol: float = 1e-12
) -> Tuple[np.ndarray, List[float]]:
    """
    Find an approximate invariant subspace of dimension `dim` using
    subspace iteration (simultaneous power method).
    
    Algorithm:
    1. Start with random subspace V₀ of dimension `dim`
    2. Iterate: V_{k+1} = orth(T · V_k)
    3. Converges to the dominant invariant subspace
    
    Args:
        T: Square matrix (n × n)
        dim: Desired subspace dimension
        max_iter: Maximum iterations
        tol: Convergence tolerance
    
    Returns:
        (basis, convergence_history) where basis is orthonormal columns
    
    Complexity: O(n²·dim) per iteration, O(n²·dim·max_iter) total
    """
    n = T.shape[0]
    # Random initial subspace
    V = np.random.randn(n, dim) + 1j * np.random.randn(n, dim)
    V, _ = qr(V, mode='reduced')
    V = V[:, :dim]
    
    convergence = []
    
    for iteration in range(max_iter):
        # Apply T
        TV = T @ V
        # Orthogonalize
        V_new, _ = qr(TV, mode='reduced')
        V_new = V_new[:, :dim]
        
        # Measure convergence: angle between subspaces
        # sin(angle) = ‖P_new P_old⊥‖
        P_old = V @ V.conj().T
        P_new = V_new @ V_new.conj().T
        angle = norm(P_new - P_old)
        convergence.append(angle)
        
        V = V_new
        
        if angle < tol:
            break
    
    return V, convergence


def detect_nilpotency(
    T: np.ndarray,
    tol: float = 1e-8
) -> Tuple[bool, int]:
    """
    Detect if T is nilpotent and find its nilpotency index.
    
    T is nilpotent iff all eigenvalues are zero, equivalently T^n = 0
    for some n ≤ dim. The nilpotency index is the smallest such n.
    
    Args:
        T: Square matrix (n × n)
        tol: Tolerance for zero check
    
    Returns:
        (is_nilpotent, index) where index is the nilpotency degree
    
    Complexity: O(n³) per power, O(n⁴) worst case
    """
    n = T.shape[0]
    power = np.eye(n, dtype=complex)
    
    for k in range(1, n + 1):
        power = power @ T
        if norm(power) < tol:
            return True, k
    
    return False, -1


def compact_operator_truncation(
    kernel_func,
    N: int,
    interval: Tuple[float, float] = (0, 1)
) -> np.ndarray:
    """
    Approximate a compact integral operator by a finite matrix.
    
    For K[f](x) = ∫ k(x,y) f(y) dy, the N×N truncation matrix
    has entries K_{ij} = k(x_i, x_j) · Δx.
    
    Args:
        kernel_func: Kernel function k(x, y)
        N: Truncation size
        interval: Integration interval [a, b]
    
    Returns:
        N × N matrix approximating the operator
    
    Complexity: O(N²) for matrix construction
    """
    a, b = interval
    x = np.linspace(a, b, N)
    dx = (b - a) / N
    
    K = np.zeros((N, N))
    for i in range(N):
        for j in range(N):
            K[i, j] = kernel_func(x[i], x[j]) * dx
    
    return K


def spectral_decomposition_analysis(T: np.ndarray) -> dict:
    """
    Full spectral analysis of an operator, identifying all invariant
    subspace structure.
    
    Returns:
        Dictionary with eigenvalues, eigenspaces, nilpotent parts,
        and reducing subspace information.
    """
    n = T.shape[0]
    eigenvalues, eigenvectors = eig(T)
    
    # Check self-adjointness
    is_sa = norm(T - T.conj().T) < 1e-8 * norm(T)
    
    # Find eigenspaces
    subspaces = find_invariant_subspaces(T)
    
    # Check reducing for each eigenspace
    reducing_info = []
    for mu, basis in subspaces:
        is_red, m_leak, p_leak = test_reducing(T, basis)
        reducing_info.append({
            'eigenvalue': mu,
            'dimension': basis.shape[1],
            'is_reducing': is_red,
            'M_leakage': m_leak,
            'M_perp_leakage': p_leak
        })
    
    # Check nilpotency
    is_nil, nil_idx = detect_nilpotency(T)
    
    return {
        'dimension': n,
        'is_self_adjoint': is_sa,
        'is_nilpotent': is_nil,
        'nilpotency_index': nil_idx,
        'eigenspaces': reducing_info,
        'has_ISP': n >= 2  # Always true for finite dim ≥ 2
    }


# Example usage
if __name__ == "__main__":
    print("Invariant Subspace Algorithms Demo")
    print("=" * 50)
    
    # 1. Find invariant subspaces
    T = np.diag([1, 1, 2, 3, 3, 3]) + 0j
    subspaces = find_invariant_subspaces(T)
    print(f"\nT = diag(1,1,2,3,3,3)")
    for mu, basis in subspaces:
        is_inv, leak = test_invariance(T, basis)
        print(f"  E_{mu.real:.0f}: dim={basis.shape[1]}, invariant={is_inv}")
    
    # 2. Subspace iteration
    n = 20
    A = np.random.randn(n, n) + 1j * np.random.randn(n, n)
    basis, conv = approximate_invariant_subspace_iteration(A, dim=3)
    is_inv, leak = test_invariance(A, basis)
    print(f"\nSubspace iteration on {n}×{n} random matrix:")
    print(f"  Converged in {len(conv)} iterations")
    print(f"  Approximate invariance leakage: {leak:.2e}")
    
    # 3. Spectral analysis
    H = (A + A.conj().T) / 2
    analysis = spectral_decomposition_analysis(H)
    print(f"\nSpectral analysis of Hermitian matrix:")
    print(f"  Self-adjoint: {analysis['is_self_adjoint']}")
    print(f"  All eigenspaces reducing: {all(e['is_reducing'] for e in analysis['eigenspaces'])}")
