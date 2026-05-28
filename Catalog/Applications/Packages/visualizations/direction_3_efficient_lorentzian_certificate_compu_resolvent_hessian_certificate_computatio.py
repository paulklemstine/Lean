"""
Algorithms for Lorentzian Hessian Certificate Computation

This module implements the core algorithms for computing and verifying
Lorentzian certificates for DPP (Determinantal Point Process) kernels.

Key algorithms:
1. Resolvent Hessian computation (O(n³))
2. Certificate construction and verification
3. Signature defect estimation
4. Conditional negative semidefiniteness testing
"""

import numpy as np
from typing import Tuple, Optional, NamedTuple


class LorentzianCertificate(NamedTuple):
    """A Lorentzian Hessian certificate for a DPP kernel.
    
    Fields:
        hessian: The resolvent Hessian matrix H (n×n, symmetric, zero diagonal)
        weight: The weight vector w = diag((I+K)⁻¹) (all positive)
        determinant: det(I+K) > 0
        resolvent: The full resolvent matrix (I+K)⁻¹
        signature_defect: Number of positive eigenvalues minus 1 (should be 0)
        is_valid: Whether the certificate passes all checks
    """
    hessian: np.ndarray
    weight: np.ndarray
    determinant: float
    resolvent: np.ndarray
    signature_defect: int
    is_valid: bool


def compute_resolvent(K: np.ndarray) -> Tuple[np.ndarray, float]:
    """Compute the resolvent L = (I+K)⁻¹ and determinant det(I+K).
    
    Args:
        K: Symmetric PSD matrix (n×n)
    
    Returns:
        L: The resolvent matrix (I+K)⁻¹
        det_A: The determinant det(I+K)
    
    Complexity: O(n³) via LU decomposition
    """
    n = K.shape[0]
    A = np.eye(n) + K
    L = np.linalg.inv(A)
    det_A = np.linalg.det(A)
    return L, det_A


def assemble_hessian(L: np.ndarray, det_A: float) -> np.ndarray:
    """Assemble the resolvent Hessian from resolvent entries.
    
    Formula: H[i,j] = det(A) * (L[i,i]*L[j,j] - L[i,j]²) for i≠j
             H[i,i] = 0
    
    Args:
        L: Resolvent matrix (I+K)⁻¹
        det_A: Determinant det(I+K)
    
    Returns:
        H: The resolvent Hessian matrix (n×n)
    
    Complexity: O(n²) for assembly
    """
    n = L.shape[0]
    diag = np.diag(L)
    # Outer product of diagonal: diag_i * diag_j
    rank1_term = np.outer(diag, diag)
    # Hadamard square: L_ij^2
    hadamard_sq = L ** 2
    # H = det_A * (rank1 - hadamard_sq), then zero the diagonal
    H = det_A * (rank1_term - hadamard_sq)
    np.fill_diagonal(H, 0.0)
    return H


def compute_certificate(K: np.ndarray, tol: float = 1e-10) -> LorentzianCertificate:
    """Compute a complete Lorentzian Hessian certificate for a DPP kernel.
    
    This is the main algorithm. Given a symmetric PSD contraction kernel K,
    it computes:
    1. The resolvent L = (I+K)⁻¹  [O(n³)]
    2. The determinant det(I+K)     [O(n³)]
    3. The Hessian matrix H          [O(n²)]
    4. The weight vector w = diag(L) [O(n)]
    5. The signature defect          [O(n³) via eigendecomposition]
    
    Total complexity: O(n³)
    
    Args:
        K: Symmetric PSD contraction kernel (n×n)
        tol: Tolerance for eigenvalue positivity
    
    Returns:
        LorentzianCertificate with all certificate data
    """
    L, det_A = compute_resolvent(K)
    H = assemble_hessian(L, det_A)
    w = np.diag(L)
    
    # Compute signature defect
    eigenvalues = np.linalg.eigvalsh(H)
    num_positive = int(np.sum(eigenvalues > tol))
    defect = max(0, num_positive - 1)
    
    # Validate certificate
    is_symmetric = np.allclose(H, H.T, atol=tol)
    is_zero_diag = np.allclose(np.diag(H), 0, atol=tol)
    weights_positive = np.all(w > -tol)
    cond_nsd = verify_conditional_nsd(H, w, tol=tol)
    
    is_valid = is_symmetric and is_zero_diag and weights_positive and cond_nsd and defect == 0
    
    return LorentzianCertificate(
        hessian=H,
        weight=w,
        determinant=det_A,
        resolvent=L,
        signature_defect=defect,
        is_valid=is_valid
    )


def verify_conditional_nsd(H: np.ndarray, w: np.ndarray, 
                           num_tests: int = 500, tol: float = 1e-10) -> bool:
    """Verify conditional negative semidefiniteness by random sampling.
    
    Tests that v^T H v ≤ 0 for random vectors v with ∑ w_i v_i = 0.
    
    Args:
        H: Symmetric matrix
        w: Positive weight vector
        num_tests: Number of random vectors to test
        tol: Tolerance for positivity
    
    Returns:
        True if all tests pass (no violations found)
    """
    n = H.shape[0]
    rng = np.random.default_rng(42)
    
    for _ in range(num_tests):
        v = rng.standard_normal(n)
        # Project to hyperplane ∑ w_i v_i = 0
        c = np.dot(w, v) / np.dot(w, w)
        v = v - c * w
        
        qf = v @ H @ v
        if qf > tol * np.linalg.norm(H, 'fro') * np.linalg.norm(v) ** 2:
            return False
    return True


def compute_hadamard_square_quadform(L: np.ndarray, v: np.ndarray) -> float:
    """Compute the Hadamard-square quadratic form: ∑_{i,j} L_{ij}² v_i v_j.
    
    This is ≥ 0 when L is PSD (Schur product theorem).
    
    Args:
        L: Matrix (n×n)
        v: Vector (n,)
    
    Returns:
        The value of the quadratic form
    """
    return v @ (L ** 2) @ v


def generate_psd_contraction(n: int, rank: Optional[int] = None,
                              seed: Optional[int] = None) -> np.ndarray:
    """Generate a random symmetric PSD contraction kernel.
    
    Args:
        n: Matrix dimension
        rank: Optional rank constraint (default: full rank)
        seed: Random seed
    
    Returns:
        K: Symmetric PSD contraction (eigenvalues in [0, 1])
    """
    rng = np.random.default_rng(seed)
    
    if rank is None:
        rank = n
    rank = min(rank, n)
    
    # Generate random orthogonal matrix
    A = rng.standard_normal((n, n))
    Q, _ = np.linalg.qr(A)
    
    # Random eigenvalues in [0, 1], with (n - rank) zeros
    eigenvalues = np.zeros(n)
    eigenvalues[:rank] = rng.uniform(0, 1, rank)
    
    K = Q @ np.diag(eigenvalues) @ Q.T
    K = (K + K.T) / 2
    return K


def quadratic_form_on_hyperplane(H: np.ndarray, w: np.ndarray, 
                                  v_raw: np.ndarray) -> float:
    """Evaluate the Hessian quadratic form after projecting v to the
    weighted zero-sum hyperplane ∑ w_i v_i = 0.
    
    Args:
        H: Hessian matrix
        w: Weight vector
        v_raw: Input vector (will be projected)
    
    Returns:
        v^T H v where v is the projection of v_raw
    """
    c = np.dot(w, v_raw) / np.dot(w, w)
    v = v_raw - c * w
    return v @ H @ v


# Example usage
if __name__ == "__main__":
    print("=== Lorentzian Certificate Algorithm Demo ===\n")
    
    # Generate a 10x10 PSD contraction
    K = generate_psd_contraction(10, seed=42)
    print(f"Generated {K.shape[0]}×{K.shape[0]} PSD contraction")
    print(f"Eigenvalues of K: {np.sort(np.linalg.eigvalsh(K))[::-1]}")
    
    # Compute certificate
    cert = compute_certificate(K)
    print(f"\nCertificate:")
    print(f"  det(I+K) = {cert.determinant:.6f}")
    print(f"  Weight vector (first 5): {cert.weight[:5]}")
    print(f"  Signature defect: {cert.signature_defect}")
    print(f"  Certificate valid: {cert.is_valid}")
    
    # Show eigenvalues of Hessian
    eigs = np.linalg.eigvalsh(cert.hessian)
    print(f"\nHessian eigenvalues:")
    print(f"  Positive: {eigs[eigs > 1e-10]}")
    print(f"  Negative: {eigs[eigs < -1e-10]}")
    print(f"  Near zero: {np.sum(np.abs(eigs) < 1e-10)}")
