"""
Newton Ratio Profile Algorithms
================================

Stable algorithms for computing elementary symmetric polynomials,
Newton ratios, and Newton profile energy from spectral data.

All algorithms avoid direct computation of large products by using
the recursive structure of elementary symmetric polynomials.
"""

import numpy as np
from typing import List, Tuple, Optional


def esymm_from_spectrum(spectrum: np.ndarray) -> np.ndarray:
    """Compute all elementary symmetric polynomials e_0, ..., e_n
    from a spectrum of n values using the stable recursive algorithm.
    
    Uses the identity: e_k(x_1,...,x_{n+1}) = e_k(x_1,...,x_n) + x_{n+1} * e_{k-1}(x_1,...,x_n)
    
    Time complexity: O(n^2)
    Space complexity: O(n)
    
    Args:
        spectrum: Array of n real values (eigenvalues)
    
    Returns:
        Array of n+1 values: e_0, e_1, ..., e_n
    
    Example:
        >>> esymm_from_spectrum(np.array([1.0, 2.0, 3.0]))
        array([ 1.,  6., 11.,  6.])
    """
    n = len(spectrum)
    e = np.zeros(n + 1)
    e[0] = 1.0
    
    for i in range(n):
        # Process x_{i+1}: update e_k for k = min(i+1, n) down to 1
        for k in range(min(i + 1, n), 0, -1):
            e[k] = e[k] + spectrum[i] * e[k - 1]
    
    return e


def newton_ratios(spectrum: np.ndarray) -> np.ndarray:
    """Compute Newton ratios rho_k = e_k^2 / (e_{k-1} * e_{k+1})
    for k = 1, ..., n-1.
    
    Uses stable recursive esymm computation.
    
    Time complexity: O(n^2) for esymm, O(n) for ratios
    Space complexity: O(n)
    
    Args:
        spectrum: Array of n positive real values
    
    Returns:
        Array of n-1 Newton ratios rho_1, ..., rho_{n-1}
        Returns inf where denominator is zero.
    """
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    ratios = np.zeros(n - 1)
    
    for k in range(1, n):
        denom = e[k - 1] * e[k + 1]
        if abs(denom) < 1e-300:
            ratios[k - 1] = np.inf
        else:
            ratios[k - 1] = e[k] ** 2 / denom
    
    return ratios


def newton_profile_energy(spectrum: np.ndarray) -> float:
    """Compute the Newton profile energy: max_k |log rho_k|.
    
    This is the key order parameter. Bounded values indicate
    a "gapped" algebraic phase; divergence indicates criticality.
    
    Args:
        spectrum: Array of positive real values
    
    Returns:
        Newton profile energy (non-negative real)
    """
    ratios = newton_ratios(spectrum)
    # Filter out inf and zero values
    valid = ratios[(ratios > 0) & np.isfinite(ratios)]
    if len(valid) == 0:
        return 0.0
    return np.max(np.abs(np.log(valid)))


def newton_defects(spectrum: np.ndarray) -> np.ndarray:
    """Compute Newton defects Delta_k = e_k^2 - e_{k-1} * e_{k+1}.
    
    By Newton's inequality, these are always non-negative for
    non-negative spectra.
    
    Args:
        spectrum: Array of non-negative real values
    
    Returns:
        Array of Newton defects for k = 1, ..., n-1
    """
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    defects = np.zeros(n - 1)
    
    for k in range(1, n):
        defects[k - 1] = e[k] ** 2 - e[k - 1] * e[k + 1]
    
    return defects


def ssh_correlation_matrix(L: int, delta: float) -> np.ndarray:
    """Build the subsystem correlation matrix for the half-filled
    SSH (Su-Schrieffer-Heeger) chain.
    
    The SSH model has alternating hopping parameters t1 = 1+delta, t2 = 1-delta.
    At half filling, the correlation matrix C_ij = <c_i^dagger c_j>
    restricted to a subsystem of size L.
    
    Args:
        L: Subsystem size (number of sites)
        delta: Dimerization parameter (-1 < delta < 1)
              delta = 0 is the critical point
              delta != 0 is the gapped phase
    
    Returns:
        L x L correlation matrix with eigenvalues in [0, 1]
    """
    # Total system size (much larger than subsystem)
    N_total = max(4 * L, 100)
    if N_total % 2 != 0:
        N_total += 1
    
    # Build SSH Hamiltonian
    H = np.zeros((N_total, N_total))
    for i in range(N_total - 1):
        if i % 2 == 0:
            t = 1.0 + delta  # intracell hopping
        else:
            t = 1.0 - delta  # intercell hopping
        H[i, i + 1] = t
        H[i + 1, i] = t
    
    # Diagonalize
    eigenvalues, eigenvectors = np.linalg.eigh(H)
    
    # Half-filling: occupy lowest N_total/2 states
    n_occ = N_total // 2
    occ_states = eigenvectors[:, :n_occ]
    
    # Full correlation matrix
    C_full = occ_states @ occ_states.T
    
    # Restrict to subsystem [0, L)
    C_sub = C_full[:L, :L]
    
    return C_sub


def ssh_newton_profile(L: int, delta: float) -> Tuple[np.ndarray, float]:
    """Compute Newton ratio profile for SSH chain subsystem.
    
    Args:
        L: Subsystem size
        delta: Dimerization parameter
    
    Returns:
        Tuple of (Newton ratios array, Newton profile energy)
    """
    C = ssh_correlation_matrix(L, delta)
    eigenvalues = np.linalg.eigvalsh(C)
    # Clip to [0,1] for numerical stability
    eigenvalues = np.clip(eigenvalues, 1e-15, 1 - 1e-15)
    
    ratios = newton_ratios(eigenvalues)
    energy = newton_profile_energy(eigenvalues)
    
    return ratios, energy


def check_geometric_rigidity(spectrum: np.ndarray, tol: float = 1e-8) -> Tuple[bool, float]:
    """Check if a spectrum's esymm sequence is approximately geometric.
    
    Returns (is_geometric, max_deviation) where max_deviation measures
    how far from geometric the sequence is.
    
    This implements the computational test for Theorem 1 (geometric rigidity):
    if all Newton defects are near zero, the esymm sequence should be
    close to geometric.
    """
    e = esymm_from_spectrum(spectrum)
    n = len(spectrum)
    
    if n < 2 or e[0] <= 0 or e[1] <= 0:
        return False, float('inf')
    
    # If geometric: e_k = a * b^k, so e_k / e_{k-1} = b for all k
    ratios = []
    for k in range(1, n + 1):
        if e[k - 1] > tol:
            ratios.append(e[k] / e[k - 1])
    
    if len(ratios) < 2:
        return True, 0.0
    
    ratios = np.array(ratios)
    max_dev = np.max(np.abs(ratios - ratios[0])) / max(abs(ratios[0]), 1e-15)
    
    return max_dev < tol, max_dev


if __name__ == "__main__":
    # Example usage
    print("=== Newton Ratio Profile Algorithms ===\n")
    
    # Test with a simple spectrum
    spectrum = np.array([1.0, 2.0, 3.0, 4.0])
    e = esymm_from_spectrum(spectrum)
    print(f"Spectrum: {spectrum}")
    print(f"Elementary symmetric polynomials: {e}")
    print(f"Newton ratios: {newton_ratios(spectrum)}")
    print(f"Newton defects: {newton_defects(spectrum)}")
    print(f"Newton profile energy: {newton_profile_energy(spectrum):.6f}")
    print()
    
    # Test geometric rigidity with constant spectrum
    const_spectrum = np.array([2.0, 2.0, 2.0, 2.0])
    is_geom, dev = check_geometric_rigidity(const_spectrum)
    print(f"Constant spectrum {const_spectrum}:")
    print(f"  Geometric: {is_geom}, deviation: {dev:.2e}")
    print(f"  Newton defects: {newton_defects(const_spectrum)}")
    print()
    
    # Test SSH model
    print("=== SSH Model Test ===")
    for delta in [0.0, 0.3, 0.5]:
        for L in [4, 8, 12]:
            _, energy = ssh_newton_profile(L, delta)
            print(f"  delta={delta:.1f}, L={L:2d}: Newton energy = {energy:.4f}")
