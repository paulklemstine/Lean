"""
Algorithms for Lorentzian Ground-State Family Analysis

Implements certificate-search, certificate-verification, and analysis pipelines
for transfer-matrix-generated amplitude polynomials on qubit chains.

Key algorithms:
- Transfer matrix amplitude generation
- Weight marginal computation  
- Lorentzian certificate verification (Hessian signature check)
- Recursive certificate construction
- Complexity analysis
"""

import numpy as np
from typing import Tuple, List, Dict, Optional
from itertools import product as cartesian_product
from math import comb, log2


# =============================================================================
# Core Data Structures
# =============================================================================

class TransferMatrix:
    """A 2x2 nonnegative transfer matrix for qubit chain evolution."""
    
    def __init__(self, mat: np.ndarray):
        assert mat.shape == (2, 2), "Transfer matrix must be 2x2"
        self.mat = mat.astype(float)
    
    @property
    def is_nonneg(self) -> bool:
        return np.all(self.mat >= -1e-15)
    
    @property
    def is_totally_nonneg(self) -> bool:
        """Check total nonnegativity: all entries ≥ 0 and det ≥ 0."""
        return self.is_nonneg and np.linalg.det(self.mat) >= -1e-15
    
    @property
    def determinant(self) -> float:
        return float(np.linalg.det(self.mat))
    
    @classmethod
    def tfim(cls, alpha: float, beta: float) -> 'TransferMatrix':
        """TFIM-like symmetric transfer matrix.
        T(a,b) = alpha if a==b, beta if a!=b.
        Ferromagnetic: alpha >= beta >= 0.
        """
        return cls(np.array([[alpha, beta], [beta, alpha]]))
    
    @classmethod
    def from_ising_params(cls, J: float, h: float) -> 'TransferMatrix':
        """Transfer matrix from Ising coupling J and transverse field h.
        Uses the parametrization: T(a,b) = exp(J*(2*delta_{ab}-1)) * sqrt(cosh(h))
        Simplified: alpha = exp(J), beta = exp(-J)
        """
        alpha = np.exp(J) 
        beta = np.exp(-J)
        return cls.tfim(alpha, beta)
    
    def __repr__(self):
        return f"TransferMatrix({self.mat})"


class AmplitudeFamily:
    """Amplitude family for n qubits: ψ : {0,1}^n → ℝ."""
    
    def __init__(self, n: int, values: Optional[np.ndarray] = None):
        self.n = n
        if values is not None:
            assert values.shape == (2**n,), f"Expected {2**n} values, got {values.shape}"
            self.values = values.astype(float)
        else:
            self.values = np.ones(2**n)
    
    def __call__(self, config: Tuple[int, ...]) -> float:
        """Evaluate amplitude at a configuration."""
        idx = sum(b * (2**i) for i, b in enumerate(config))
        return float(self.values[idx])
    
    @property
    def is_nonneg(self) -> bool:
        return np.all(self.values >= -1e-15)
    
    def weight_marginal(self, k: int) -> float:
        """Compute the weight-k marginal: S_k = Σ_{|σ|=k} ψ(σ)."""
        total = 0.0
        for idx in range(2**self.n):
            config = tuple((idx >> i) & 1 for i in range(self.n))
            if sum(config) == k:
                total += self.values[idx]
        return total
    
    def all_weight_marginals(self) -> np.ndarray:
        """Compute all weight marginals S_0, S_1, ..., S_n."""
        marginals = np.zeros(self.n + 1)
        for idx in range(2**self.n):
            config = tuple((idx >> i) & 1 for i in range(self.n))
            w = sum(config)
            marginals[w] += self.values[idx]
        return marginals
    
    def is_weight_log_concave(self) -> bool:
        """Check weight log-concavity: S_k² ≥ S_{k-1} · S_{k+1}."""
        S = self.all_weight_marginals()
        for k in range(1, self.n):
            if S[k]**2 < S[k-1] * S[k+1] - 1e-12:
                return False
        return True
    
    def partition_function(self) -> float:
        """Total partition function Z = Σ_σ ψ(σ)."""
        return float(np.sum(self.values))


# =============================================================================
# Transfer Matrix Amplitude Generation
# =============================================================================

def chain_amplitude(n: int, v: np.ndarray, T: TransferMatrix) -> AmplitudeFamily:
    """Generate product-form chain amplitude for n sites.
    
    ψ(σ₀,...,σ_{n-1}) = v(σ₀) · ∏_{i=0}^{n-2} T(σ_i, σ_{i+1})
    
    Args:
        n: Number of sites
        v: Initial vector (2,)
        T: Transfer matrix
    
    Returns:
        AmplitudeFamily with the chain amplitudes
    """
    if n == 0:
        return AmplitudeFamily(0, np.array([1.0]))
    
    values = np.zeros(2**n)
    for idx in range(2**n):
        config = tuple((idx >> i) & 1 for i in range(n))
        amp = v[config[0]]
        for i in range(n - 1):
            amp *= T.mat[config[i], config[i+1]]
        values[idx] = amp
    
    return AmplitudeFamily(n, values)


def state_vector_evolution(n: int, v: np.ndarray, T: TransferMatrix) -> np.ndarray:
    """Compute the state vector at site n via transfer matrix evolution.
    
    s_0 = [1, 1]
    s_1 = v
    s_{m+2}(b) = Σ_a s_{m+1}(a) * T(a, b)
    
    Returns:
        2-component state vector
    """
    if n == 0:
        return np.array([1.0, 1.0])
    if n == 1:
        return v.copy()
    
    state = v.copy()
    for _ in range(n - 1):
        state = T.mat.T @ state
    return state


# =============================================================================
# Lorentzian Certificate Verification
# =============================================================================

def hessian_of_degree2_derivative(psi: AmplitudeFamily, 
                                   deriv_indices: List[int]) -> np.ndarray:
    """Compute the Hessian matrix of the amplitude polynomial after
    taking partial derivatives specified by deriv_indices.
    
    For a multiaffine homogeneous polynomial of degree n in 2n variables
    (x_i, y_i for i=0,...,n-1), after taking (n-2) derivatives, we get
    a degree-2 polynomial whose Hessian we analyze.
    
    Args:
        psi: Amplitude family
        deriv_indices: List of (n-2) pairs (site, value) specifying derivatives
    
    Returns:
        Hessian matrix of the resulting degree-2 polynomial
    """
    n = psi.n
    if n < 2:
        return np.zeros((2*n, 2*n))
    
    # For multiaffine polynomials, the Hessian after derivatives
    # reduces to analyzing 2x2 blocks
    dim = 2 * n
    H = np.zeros((dim, dim))
    
    # The generating polynomial is P = Σ_σ ψ(σ) ∏_i X_{i,σ(i)}
    # Derivatives ∂/∂X_{j,a} pull out the coefficient where σ(j)=a
    # After n-2 derivatives, we have a degree-2 polynomial in 2 variables
    
    # For the Hessian analysis, we check the "at most one positive eigenvalue" condition
    remaining_sites = list(range(n))
    for site, _ in deriv_indices:
        if site in remaining_sites:
            remaining_sites.remove(site)
    
    if len(remaining_sites) < 2:
        return np.zeros((4, 4))
    
    s1, s2 = remaining_sites[0], remaining_sites[1]
    H = np.zeros((4, 4))
    
    for a1 in range(2):
        for a2 in range(2):
            coeff = 0.0
            for idx in range(2**n):
                config = tuple((idx >> i) & 1 for i in range(n))
                if config[s1] == a1 and config[s2] == a2:
                    # Check if config matches all derivative conditions
                    match = True
                    for site, val in deriv_indices:
                        if config[site] != val:
                            match = False
                            break
                    if match:
                        coeff += psi.values[idx]
            
            # Place in Hessian: variables are x_{s1}, y_{s1}, x_{s2}, y_{s2}
            # Monomial X_{s1,a1} X_{s2,a2} contributes to H at the corresponding positions
            row = 2 * 0 + a1  # x_{s1} if a1=0, y_{s1} if a1=1
            col = 2 * 1 + a2
            H[row, col] += coeff
            H[col, row] += coeff
    
    return H


def has_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if a symmetric matrix has at most one positive eigenvalue
    (Lorentzian signature).
    
    Args:
        H: Symmetric matrix
        tol: Tolerance for eigenvalue sign determination
    
    Returns:
        True if at most one eigenvalue is positive
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def verify_lorentzian_certificate(psi: AmplitudeFamily) -> Dict:
    """Full Lorentzian certificate verification.
    
    Checks:
    1. Nonnegativity of coefficients
    2. Weight log-concavity (necessary condition)
    3. Hessian signature analysis for all degree-2 derivative leaves
    
    Returns:
        Dictionary with verification results
    """
    result = {
        'n': psi.n,
        'is_nonneg': psi.is_nonneg,
        'is_weight_log_concave': psi.is_weight_log_concave(),
        'weight_marginals': psi.all_weight_marginals().tolist(),
        'partition_function': psi.partition_function(),
        'hessian_checks_passed': 0,
        'hessian_checks_total': 0,
        'all_hessians_lorentzian': True,
        'certificate_depth': psi.n,
        'is_certified_lorentzian': False,
    }
    
    if psi.n < 2:
        result['is_certified_lorentzian'] = result['is_nonneg']
        return result
    
    # Check all degree-2 derivative leaves
    n = psi.n
    # For multiaffine degree-n polynomial, derivative leaves are obtained by
    # choosing n-2 variables to differentiate
    from itertools import combinations
    
    sites = list(range(n))
    total_checks = 0
    passed_checks = 0
    
    for chosen_sites in combinations(sites, n - 2):
        for values in cartesian_product([0, 1], repeat=n-2):
            deriv_indices = list(zip(chosen_sites, values))
            H = hessian_of_degree2_derivative(psi, deriv_indices)
            total_checks += 1
            if has_lorentzian_signature(H):
                passed_checks += 1
            else:
                result['all_hessians_lorentzian'] = False
    
    result['hessian_checks_passed'] = passed_checks
    result['hessian_checks_total'] = total_checks
    result['is_certified_lorentzian'] = (
        result['is_nonneg'] and 
        result['is_weight_log_concave'] and
        result['all_hessians_lorentzian']
    )
    
    return result


# =============================================================================
# Certificate Complexity Analysis
# =============================================================================

def certificate_complexity(n: int, d: int = None) -> Dict:
    """Compute certificate complexity bounds for a degree-d polynomial in 2n variables.
    
    For chain-generated families:
    - Certificate depth = n (one level per site)
    - Number of quadratic leaves = C(2n, d-2) ≤ (2n)^(d-2)
    - Each leaf requires O(n²) work for eigenvalue check
    - Total verification: O(n^d)
    
    For the chain inductive scheme:
    - Depth = n
    - Verification per step = O(1) (2x2 matrix check)
    - Total = O(n)
    
    Args:
        n: Number of sites
        d: Polynomial degree (defaults to n for multiaffine)
    
    Returns:
        Dictionary with complexity metrics
    """
    if d is None:
        d = n
    
    brute_force_leaves = comb(2*n, max(d-2, 0)) if d >= 2 else 1
    brute_force_per_leaf = (2*n)**2
    brute_force_total = brute_force_leaves * brute_force_per_leaf
    
    chain_depth = n
    chain_per_step = 4  # 2x2 matrix operations
    chain_total = chain_depth * chain_per_step
    
    return {
        'n': n,
        'degree': d,
        'brute_force': {
            'quadratic_leaves': brute_force_leaves,
            'work_per_leaf': brute_force_per_leaf,
            'total_work': brute_force_total,
        },
        'chain_inductive': {
            'depth': chain_depth,
            'work_per_step': chain_per_step,
            'total_work': chain_total,
        },
        'speedup_ratio': brute_force_total / max(chain_total, 1),
    }


# =============================================================================
# TFIM Analysis
# =============================================================================

def tfim_ground_state_coefficients(n: int, J: float, h: float) -> AmplitudeFamily:
    """Compute TFIM chain amplitude family.
    
    Uses transfer matrix method:
    T = [[exp(J), exp(-J)], [exp(-J), exp(J)]]
    v = [1, 1] (uniform initial)
    
    The amplitudes are NOT the quantum ground state of the TFIM Hamiltonian
    (which would require diagonalization), but rather the transfer-matrix-
    generated statistical mechanical amplitudes, which serve as a proxy
    for studying Lorentzian structure.
    """
    alpha = np.exp(J)
    beta = np.exp(-J)
    T = TransferMatrix.tfim(alpha, beta)
    v = np.array([1.0, 1.0])
    return chain_amplitude(n, v, T)


def scan_tfim_lorentzianity(n: int, J_range: np.ndarray, h_range: np.ndarray) -> np.ndarray:
    """Scan TFIM parameter space for Lorentzian certification.
    
    Args:
        n: Chain length
        J_range: Array of J values
        h_range: Array of h values (used as scale for beta)
    
    Returns:
        2D array of certification results (1 = certified, 0 = not)
    """
    results = np.zeros((len(J_range), len(h_range)))
    
    for i, J in enumerate(J_range):
        for j, h_val in enumerate(h_range):
            alpha = np.exp(J)
            beta = np.exp(-J) * h_val  # Incorporate field
            if beta < 0:
                continue
            T = TransferMatrix.tfim(alpha, beta)
            v = np.array([1.0, 1.0])
            psi = chain_amplitude(n, v, T)
            results[i, j] = 1.0 if psi.is_weight_log_concave() else 0.0
    
    return results


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Lorentzian Ground-State Family Analysis")
    print("=" * 60)
    
    # Example 1: Independent (constant) amplitudes
    print("\n--- Example 1: Independent amplitudes (f ≡ 1) ---")
    for n in range(1, 8):
        psi = AmplitudeFamily(n)  # All ones
        S = psi.all_weight_marginals()
        lc = psi.is_weight_log_concave()
        print(f"  n={n}: marginals={[int(s) for s in S]}, "
              f"log-concave={lc}, Z={psi.partition_function():.0f}")
    
    # Example 2: TFIM chain
    print("\n--- Example 2: TFIM chain (J=1.0) ---")
    for n in range(2, 10):
        psi = tfim_ground_state_coefficients(n, J=1.0, h=0.5)
        S = psi.all_weight_marginals()
        lc = psi.is_weight_log_concave()
        print(f"  n={n}: log-concave={lc}, Z={psi.partition_function():.4f}")
    
    # Example 3: Certificate complexity
    print("\n--- Example 3: Certificate complexity ---")
    for n in [4, 8, 12, 16, 20]:
        cc = certificate_complexity(n)
        print(f"  n={n}: brute_force={cc['brute_force']['total_work']}, "
              f"chain={cc['chain_inductive']['total_work']}, "
              f"speedup={cc['speedup_ratio']:.1f}x")
    
    # Example 4: Full certificate verification
    print("\n--- Example 4: Full certificate verification (n=4) ---")
    psi = tfim_ground_state_coefficients(4, J=1.0, h=0.5)
    cert = verify_lorentzian_certificate(psi)
    for key, val in cert.items():
        print(f"  {key}: {val}")
