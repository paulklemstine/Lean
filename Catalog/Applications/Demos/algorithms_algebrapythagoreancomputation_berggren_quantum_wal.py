#!/usr/bin/env python3
"""
Berggren Quantum Walk Algorithms

Implementation of core algorithms from the research:
1. Kernel extraction from a quantum walk
2. Moment table validation
3. GNS realization from a valid moment table
4. Phase gauge equivalence detection
"""

import numpy as np
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass


GENERATORS = ['A', 'B', 'C']


def generate_words(max_length: int) -> List[str]:
    """Generate all Berggren words up to given length.

    Args:
        max_length: Maximum word length

    Returns:
        List of words ordered by length, then lexicographically
    """
    from itertools import product as cart_product
    words = ['']
    for length in range(1, max_length + 1):
        for combo in cart_product(GENERATORS, repeat=length):
            words.append(''.join(combo))
    return words


@dataclass
class QuantumWalk:
    """A Berggren quantum walk."""
    unitaries: Dict[str, np.ndarray]  # 'A','B','C' -> unitary matrix
    psi0: np.ndarray                   # initial state
    obs: np.ndarray                    # observation vector
    dim: int                           # dimension

    def eval_word(self, word: str) -> np.ndarray:
        """Evaluate U(word) = U(w_k) ... U(w_1)."""
        result = np.eye(self.dim, dtype=complex)
        for g in word:
            result = self.unitaries[g] @ result
        return result

    def eval_state(self, word: str) -> np.ndarray:
        """Evaluate U(word) · ψ₀."""
        return self.eval_word(word) @ self.psi0

    def kernel(self, u: str, v: str) -> complex:
        """K(u,v) = ⟨U(u)ψ₀, U(v)ψ₀⟩."""
        return np.vdot(self.eval_state(u), self.eval_state(v))

    def amplitude(self, w: str) -> complex:
        """amp(w) = ⟨obs, U(w)ψ₀⟩."""
        return np.vdot(self.obs, self.eval_state(w))


def extract_kernel_matrix(walk: QuantumWalk, words: List[str]) -> np.ndarray:
    """
    Algorithm 1: Extract the kernel matrix from a quantum walk.

    Args:
        walk: A Berggren quantum walk
        words: List of words to evaluate

    Returns:
        Hermitian positive semi-definite kernel matrix K[i,j] = K(words[i], words[j])

    Complexity: O(|words|² · dim²)
    """
    m = len(words)
    # First compute all evolved states
    states = np.zeros((m, walk.dim), dtype=complex)
    for i, w in enumerate(words):
        states[i] = walk.eval_state(w)

    # Compute kernel matrix as Gram matrix
    K = states.conj() @ states.T
    return K


def validate_moment_table(
    table: Dict[Tuple[str, str], complex],
    words: List[str],
    tol: float = 1e-12
) -> Dict[str, bool]:
    """
    Algorithm 2: Validate a moment table.

    Checks:
    - Hermitian symmetry: H(u,v) = conj(H(v,u))
    - Positivity: Re(H(w,w)) >= 0
    - Shift compatibility: H(gu, gv) = H(u, v)

    Args:
        table: Dict mapping (word, word) -> complex amplitude
        words: List of words in the table
        tol: Numerical tolerance

    Returns:
        Dict with validation results
    """
    results = {}

    # Hermitian check
    max_herm_err = 0
    for u in words:
        for v in words:
            if (u, v) in table and (v, u) in table:
                err = abs(table[(u, v)] - table[(v, u)].conjugate())
                max_herm_err = max(max_herm_err, err)
    results['hermitian'] = max_herm_err < tol
    results['hermitian_error'] = max_herm_err

    # Positivity check
    min_diag = float('inf')
    for w in words:
        if (w, w) in table:
            min_diag = min(min_diag, table[(w, w)].real)
    results['positive'] = min_diag >= -tol
    results['min_diagonal'] = min_diag

    # Shift compatibility (where data available)
    max_shift_err = 0
    for g in GENERATORS:
        for u in words:
            for v in words:
                gu = g + u
                gv = g + v
                if (gu, gv) in table and (u, v) in table:
                    err = abs(table[(gu, gv)] - table[(u, v)])
                    max_shift_err = max(max_shift_err, err)
    results['shift_compatible'] = max_shift_err < tol
    results['shift_error'] = max_shift_err

    results['valid'] = all([
        results['hermitian'],
        results['positive'],
        results['shift_compatible']
    ])

    return results


def compute_stable_rank(
    kernel_matrix: np.ndarray,
    tol: float = 1e-10
) -> int:
    """
    Compute the stable rank of a kernel matrix.

    The stable rank is the number of eigenvalues above tolerance.

    Args:
        kernel_matrix: Hermitian PSD kernel matrix
        tol: Threshold for considering an eigenvalue as zero

    Returns:
        Stable rank
    """
    eigenvalues = np.linalg.eigvalsh(kernel_matrix)
    return int(np.sum(eigenvalues > tol))


def gns_realization(
    table: Dict[Tuple[str, str], complex],
    basis_words: List[str],
    all_words: List[str]
) -> Optional[QuantumWalk]:
    """
    Algorithm 3: GNS realization from a valid moment table.

    Given a valid moment table and a basis of words, construct a minimal
    quantum walk realizing the table.

    Args:
        table: Valid moment table
        basis_words: Words forming a basis for the kernel row space
        all_words: All words in the table

    Returns:
        QuantumWalk realizing the table, or None if construction fails

    Complexity: O(r³) for Cholesky + O(r² · |words|) for state extraction
    """
    r = len(basis_words)
    if r == 0:
        return None

    # Step 1: Build Gram matrix on basis words
    G = np.zeros((r, r), dtype=complex)
    for i in range(r):
        for j in range(r):
            key = (basis_words[i], basis_words[j])
            if key in table:
                G[i, j] = table[key]
            else:
                return None

    # Step 2: Verify PSD and compute Cholesky
    eigenvalues = np.linalg.eigvalsh(G)
    if np.min(eigenvalues) < -1e-10:
        return None  # Not PSD

    # Regularize slightly for numerical stability
    G += np.eye(r) * max(0, -np.min(eigenvalues) + 1e-14)

    try:
        L = np.linalg.cholesky(G)
    except np.linalg.LinAlgError:
        return None

    # Step 3: Compute state vectors for basis words
    # v_i = L[i, :] (rows of Cholesky factor)
    # Then ⟨v_i, v_j⟩ = (L L†)[i,j] = G[i,j] ✓

    # Step 4: Compute decomposition coefficients for shifted words
    # For each generator g, need to express g*basis_i in terms of basis
    unitaries = {}
    for g in GENERATORS:
        U_g = np.zeros((r, r), dtype=complex)
        for i in range(r):
            shifted = g + basis_words[i]
            if shifted not in [w for w in all_words]:
                # Need coefficient decomposition
                # From stable rank: shifted word = ∑ coeffs_j * basis_j
                # Solve: table(shifted, basis_k) = ∑_j coeffs_j * table(basis_j, basis_k)
                rhs = np.array([table.get((shifted, basis_words[k]), 0) for k in range(r)])
                try:
                    coeffs = np.linalg.solve(G, rhs)
                    U_g[:, i] = L @ coeffs
                except np.linalg.LinAlgError:
                    U_g[:, i] = np.zeros(r)
            else:
                rhs = np.array([table.get((shifted, basis_words[k]), 0) for k in range(r)])
                try:
                    coeffs = np.linalg.solve(G, rhs)
                    U_g[:, i] = L @ coeffs
                except np.linalg.LinAlgError:
                    U_g[:, i] = np.zeros(r)

        # Polar decomposition to ensure unitarity
        U_polar, S, Vh = np.linalg.svd(U_g)
        unitaries[g] = U_polar @ Vh

    # Step 5: Determine psi0
    # psi0 corresponds to the identity word
    identity_coeffs = np.zeros(r)
    if '' in basis_words:
        identity_coeffs[basis_words.index('')] = 1.0
    else:
        rhs = np.array([table.get(('', basis_words[k]), 0) for k in range(r)])
        try:
            identity_coeffs = np.linalg.solve(G, rhs)
        except np.linalg.LinAlgError:
            identity_coeffs = np.zeros(r)

    psi0 = L @ identity_coeffs

    return QuantumWalk(
        unitaries=unitaries,
        psi0=psi0,
        obs=psi0.copy(),
        dim=r
    )


def detect_phase_gauge_equivalence(
    Q1: QuantumWalk,
    Q2: QuantumWalk,
    max_length: int = 4,
    tol: float = 1e-10
) -> Tuple[bool, float]:
    """
    Algorithm 4: Detect phase gauge equivalence.

    Two walks are phase-gauge equivalent if they have the same kernel.

    Args:
        Q1, Q2: Quantum walks (must have same dimension)
        max_length: Maximum word length to check
        tol: Tolerance for kernel comparison

    Returns:
        (equivalent, max_difference)
    """
    words = generate_words(max_length)
    max_diff = 0
    for u in words:
        for v in words:
            diff = abs(Q1.kernel(u, v) - Q2.kernel(u, v))
            max_diff = max(max_diff, diff)
    return max_diff < tol, max_diff


# --- Example usage ---
if __name__ == '__main__':
    print("=" * 60)
    print("Berggren Quantum Walk Algorithms — Test Suite")
    print("=" * 60)

    # Create a test walk
    np.random.seed(42)
    n = 3

    def random_unitary(dim):
        Z = (np.random.randn(dim, dim) + 1j * np.random.randn(dim, dim)) / np.sqrt(2)
        Q, R = np.linalg.qr(Z)
        return Q @ np.diag(np.diag(R) / np.abs(np.diag(R)))

    U = {g: random_unitary(n) for g in GENERATORS}
    psi0 = np.array([1.0, 0.0, 0.0], dtype=complex)
    Q = QuantumWalk(U, psi0, psi0.copy(), n)

    # Test kernel extraction
    words = generate_words(3)
    K = extract_kernel_matrix(Q, words)
    print(f"\n1. Kernel extraction: {K.shape[0]}×{K.shape[1]} matrix")
    print(f"   Rank: {compute_stable_rank(K)}")
    print(f"   Hermitian: {np.allclose(K, K.conj().T)}")
    print(f"   Min eigenvalue: {np.min(np.linalg.eigvalsh(K)):.2e}")

    # Test validation
    table = {}
    for i, u in enumerate(words):
        for j, v in enumerate(words):
            table[(u, v)] = K[i, j]
    results = validate_moment_table(table, words)
    print(f"\n2. Moment table validation: {results}")

    # Test GNS realization
    basis = ['', 'A', 'B']  # First 3 words as basis
    Q_realized = gns_realization(table, basis, words)
    if Q_realized:
        print(f"\n3. GNS realization: dimension {Q_realized.dim}")
        equiv, diff = detect_phase_gauge_equivalence(Q, Q_realized, max_length=2)
        print(f"   Kernel match: {diff:.2e}")
    else:
        print("\n3. GNS realization: failed (expected for non-basis words)")

    # Test phase gauge equivalence
    phi = np.pi / 4
    V = random_unitary(n)
    U2 = {g: V @ Ug @ V.conj().T for g, Ug in U.items()}
    psi0_2 = V @ psi0
    Q2 = QuantumWalk(U2, psi0_2, V @ psi0, n)
    equiv, diff = detect_phase_gauge_equivalence(Q, Q2)
    print(f"\n4. Phase gauge equivalence: {equiv} (max diff: {diff:.2e})")

    print("\nAll tests complete.")
