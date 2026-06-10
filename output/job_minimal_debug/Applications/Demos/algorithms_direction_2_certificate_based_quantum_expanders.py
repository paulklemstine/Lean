"""
Certificate-Based Quantum Expanders — Algorithms

Implements the core algorithms for constructing and verifying quantum expanders:
1. Quantum Singer condition verification
2. Spectral gap computation
3. Irreducibility testing
4. Certified quantum expander construction

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Tuple, List, Optional


def quantum_channel(U: np.ndarray, V: np.ndarray, rho: np.ndarray) -> np.ndarray:
    """
    Compute the quantum averaging channel Φ_{U,V}(ρ).
    
    Φ(ρ) = ¼(UρU† + U†ρU + VρV† + V†ρV)
    
    Args:
        U: n×n unitary matrix
        V: n×n unitary matrix
        rho: n×n density matrix or Hermitian matrix
        
    Returns:
        Φ(ρ): n×n matrix
        
    Time complexity: O(n³) for matrix multiplication
    Space complexity: O(n²)
    """
    Ud = U.conj().T
    Vd = V.conj().T
    return 0.25 * (U @ rho @ Ud + Ud @ rho @ U + V @ rho @ Vd + Vd @ rho @ V)


def build_superoperator(U: np.ndarray, V: np.ndarray) -> np.ndarray:
    """
    Build the n²×n² superoperator matrix of Φ_{U,V}.
    
    The superoperator acts on vectorized matrices: vec(Φ(ρ)) = S · vec(ρ).
    
    Args:
        U, V: n×n unitary matrices
        
    Returns:
        S: n²×n² superoperator matrix
        
    Time complexity: O(n⁴) to construct
    Space complexity: O(n⁴)
    """
    n = U.shape[0]
    dim = n * n
    S = np.zeros((dim, dim), dtype=complex)
    
    for i in range(n):
        for j in range(n):
            E = np.zeros((n, n), dtype=complex)
            E[i, j] = 1.0
            PhiE = quantum_channel(U, V, E)
            S[:, i * n + j] = PhiE.flatten()
    
    return S


def compute_spectral_gap(U: np.ndarray, V: np.ndarray) -> Tuple[float, np.ndarray]:
    """
    Compute the spectral gap of Φ_{U,V} on the traceless subspace.
    
    The spectral gap is γ = 1 - λ₂, where λ₂ is the second-largest
    eigenvalue of Φ restricted to traceless matrices.
    
    Args:
        U, V: n×n unitary matrices
        
    Returns:
        gap: spectral gap γ > 0 (if pair is irreducible)
        eigenvalues: all eigenvalues of the superoperator, sorted descending
        
    Time complexity: O(n⁶) — dominated by eigenvalue computation of n²×n² matrix
    Space complexity: O(n⁴)
    """
    S = build_superoperator(U, V)
    eigenvalues = np.linalg.eigvals(S)
    eigenvalues_real = np.sort(np.real(eigenvalues))[::-1]
    
    # Largest eigenvalue should be 1 (identity is fixed point)
    lambda_2 = eigenvalues_real[1] if len(eigenvalues_real) > 1 else 0
    gap = 1 - lambda_2
    
    return gap, eigenvalues_real


def check_irreducibility(U: np.ndarray, V: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if (U, V) is an irreducible pair.
    
    Tests whether the joint commutant {M : MU = UM, MV = VM} is 1-dimensional
    (scalar matrices only).
    
    Args:
        U, V: n×n matrices
        tol: numerical tolerance for singular value cutoff
        
    Returns:
        True if the pair is irreducible
        
    Time complexity: O(n⁶) — SVD of a 4n²×2n² matrix
    Space complexity: O(n⁴)
    
    Algorithm:
        Build the linear system [M, U] = 0, [M, V] = 0 in real coordinates.
        Compute the nullity. Irreducible iff nullity = 2 (real dimension of ℂ).
    """
    n = U.shape[0]
    dim = n * n
    rows = []
    
    for gen in [U, V]:
        for i in range(n):
            for j in range(n):
                row_re = np.zeros(2 * dim)
                row_im = np.zeros(2 * dim)
                for k in range(n):
                    g_re, g_im = gen[k, j].real, gen[k, j].imag
                    row_re[i * n + k] += g_re
                    row_re[dim + i * n + k] -= g_im
                    row_im[i * n + k] += g_im
                    row_im[dim + i * n + k] += g_re
                    
                    g_re2, g_im2 = gen[i, k].real, gen[i, k].imag
                    row_re[k * n + j] -= g_re2
                    row_re[dim + k * n + j] += g_im2
                    row_im[k * n + j] -= g_im2
                    row_im[dim + k * n + j] -= g_re2
                rows.extend([row_re, row_im])
    
    A = np.array(rows)
    _, s, _ = np.linalg.svd(A)
    kernel_dim = np.sum(s < tol)
    return kernel_dim == 2


def verify_quantum_singer(U: np.ndarray, V: np.ndarray) -> Tuple[bool, float]:
    """
    Verify the quantum Singer condition and compute the parameter δ.
    
    The condition requires that for every projection P onto an eigenspace of U
    and every projection Q onto an eigenspace of V:
        |Tr(PQ)|² / (Tr(P) · Tr(Q)) ≤ 1 - δ
    
    Args:
        U, V: n×n unitary matrices
        
    Returns:
        (satisfies, delta): whether condition holds and the parameter δ
        
    Time complexity: O(n³) — eigendecomposition + overlap computation
    Space complexity: O(n²)
    """
    n = U.shape[0]
    evals_U, evecs_U = np.linalg.eig(U)
    evals_V, evecs_V = np.linalg.eig(V)
    
    max_ratio = 0.0
    
    # Group eigenvalues
    unique_U = []
    used = set()
    for i, e in enumerate(evals_U):
        key = round(e.real, 8) + 1j * round(e.imag, 8)
        if key not in used:
            used.add(key)
            mask = np.abs(evals_U - e) < 1e-8
            unique_U.append(mask)
    
    unique_V = []
    used = set()
    for i, e in enumerate(evals_V):
        key = round(e.real, 8) + 1j * round(e.imag, 8)
        if key not in used:
            used.add(key)
            mask = np.abs(evals_V - e) < 1e-8
            unique_V.append(mask)
    
    for mask_U in unique_U:
        vecs_U = evecs_U[:, mask_U]
        P = vecs_U @ vecs_U.conj().T
        tr_P = np.real(np.trace(P))
        if tr_P < 0.5:
            continue
        
        for mask_V in unique_V:
            vecs_V = evecs_V[:, mask_V]
            Q = vecs_V @ vecs_V.conj().T
            tr_Q = np.real(np.trace(Q))
            if tr_Q < 0.5:
                continue
            
            tr_PQ = np.trace(P @ Q)
            ratio = np.abs(tr_PQ)**2 / (tr_P * tr_Q)
            max_ratio = max(max_ratio, ratio)
    
    delta = 1 - max_ratio
    return delta > 0, delta


def construct_clock_shift_expander(n: int) -> Tuple[np.ndarray, np.ndarray]:
    """
    Construct the clock-shift quantum expander pair for dimension n.
    
    U = diag(1, ω, ω², ..., ω^{n-1})  (clock matrix)
    V = cyclic permutation matrix       (shift matrix)
    
    where ω = e^{2πi/n}.
    
    This pair is always irreducible and forms a quantum expander.
    
    Args:
        n: dimension ≥ 2
        
    Returns:
        (U, V): pair of n×n unitary matrices
        
    Time complexity: O(n²)
    """
    omega = np.exp(2j * np.pi / n)
    U = np.diag([omega**k for k in range(n)])
    V = np.zeros((n, n), dtype=complex)
    for i in range(n):
        V[i, (i + 1) % n] = 1.0
    return U, V


def mixing_time(U: np.ndarray, V: np.ndarray, epsilon: float = 1e-6) -> int:
    """
    Compute the mixing time: minimum k such that for all density matrices ρ,
    ‖Φ^k(ρ) - I/n‖_F ≤ ε.
    
    Uses the spectral gap to bound: k ≥ log(1/ε) / log(1/(1-γ)).
    
    Args:
        U, V: n×n unitary matrices
        epsilon: target accuracy
        
    Returns:
        Mixing time (number of iterations)
    """
    gap, _ = compute_spectral_gap(U, V)
    if gap <= 0:
        return -1  # No mixing
    
    n = U.shape[0]
    # Initial distance at most sqrt(n-1)/n (from maximally polarized state)
    initial_dist = np.sqrt((n - 1) / n)
    k = int(np.ceil(np.log(initial_dist / epsilon) / np.log(1 / (1 - gap))))
    return k


# =============================================================================
# Example usage
# =============================================================================
if __name__ == "__main__":
    print("Certificate-Based Quantum Expanders — Algorithm Demonstrations")
    print("=" * 60)
    
    for n in [2, 3, 4, 5]:
        U, V = construct_clock_shift_expander(n)
        irr = check_irreducibility(U, V)
        gap, evals = compute_spectral_gap(U, V)
        singer_ok, delta = verify_quantum_singer(U, V)
        mix_t = mixing_time(U, V)
        
        print(f"\nn = {n}: Clock-Shift Expander")
        print(f"  Irreducible: {irr}")
        print(f"  Spectral gap: γ = {gap:.6f}")
        print(f"  Singer condition: δ = {delta:.6f} (satisfied: {singer_ok})")
        print(f"  Mixing time (ε=10⁻⁶): {mix_t} iterations")
        print(f"  Top eigenvalues: {np.round(evals[:5], 4)}")
