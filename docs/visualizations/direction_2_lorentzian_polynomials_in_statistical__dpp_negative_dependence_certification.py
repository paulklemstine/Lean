#!/usr/bin/env python3
"""
Algorithms for DPP Negative Dependence Certification and Lorentzian Recognition

Implements verified algorithms for:
1. Computing DPP partition function coefficients
2. Certifying pairwise negative dependence
3. Hessian-based Lorentzian recognition
4. Spectral analysis of DPP kernels

Each algorithm includes docstrings, type hints, and example usage.
"""

import numpy as np
from itertools import combinations
from typing import Optional, Tuple, Dict, List


class DPPKernel:
    """
    A Determinantal Point Process kernel.
    
    Wraps a symmetric positive semidefinite matrix K and provides
    methods for computing partition function coefficients, inclusion
    probabilities, and negative dependence certificates.
    
    Attributes:
        K: The kernel matrix (n x n, symmetric PSD)
        n: Dimension
        eigenvalues: Eigenvalues of K (computed lazily)
    
    Example:
        >>> K = DPPKernel.random(n=5)
        >>> K.verify_psd()
        True
        >>> K.pair_inclusion(0, 1) <= K.single_inclusion(0) * K.single_inclusion(1)
        True
    """
    
    def __init__(self, K: np.ndarray):
        """Initialize with a symmetric PSD matrix."""
        assert K.shape[0] == K.shape[1], "K must be square"
        self.K = (K + K.T) / 2  # Symmetrize
        self.n = K.shape[0]
        self._eigenvalues = None
        self._coefficients = None
    
    @classmethod
    def random(cls, n: int, rank: Optional[int] = None) -> 'DPPKernel':
        """Generate a random DPP kernel."""
        if rank is None:
            rank = n
        A = np.random.randn(rank, n)
        return cls(A.T @ A)
    
    @classmethod
    def diagonal(cls, weights: np.ndarray) -> 'DPPKernel':
        """Create a diagonal DPP kernel."""
        return cls(np.diag(weights))
    
    @classmethod
    def rank_one(cls, v: np.ndarray) -> 'DPPKernel':
        """Create a rank-one DPP kernel K = v v^T."""
        return cls(np.outer(v, v))
    
    @property
    def eigenvalues(self) -> np.ndarray:
        """Eigenvalues of K (cached)."""
        if self._eigenvalues is None:
            self._eigenvalues = np.linalg.eigvalsh(self.K)
        return self._eigenvalues
    
    def verify_psd(self) -> bool:
        """Verify that K is positive semidefinite."""
        return np.all(self.eigenvalues >= -1e-10)
    
    def verify_symmetric(self) -> bool:
        """Verify that K is symmetric."""
        return np.allclose(self.K, self.K.T)
    
    def principal_minor(self, S: tuple) -> float:
        """Compute det(K_S) for subset S."""
        S = list(S)
        if len(S) == 0:
            return 1.0
        return np.linalg.det(self.K[np.ix_(S, S)])
    
    def single_inclusion(self, i: int) -> float:
        """Pr[i ∈ S] = K_ii."""
        return self.K[i, i]
    
    def pair_inclusion(self, i: int, j: int) -> float:
        """Pr[i,j ∈ S] = K_ii * K_jj - K_ij * K_ji."""
        return self.K[i, i] * self.K[j, j] - self.K[i, j] * self.K[j, i]
    
    def correlation_ratio(self, i: int, j: int) -> float:
        """
        Compute Pr[i,j ∈ S] / (Pr[i ∈ S] * Pr[j ∈ S]).
        
        For DPPs this is always <= 1 (negative dependence).
        Values close to 1 indicate near-independence.
        Values close to 0 indicate strong repulsion.
        """
        product = self.single_inclusion(i) * self.single_inclusion(j)
        if abs(product) < 1e-15:
            return float('nan')
        return self.pair_inclusion(i, j) / product
    
    def covariance(self, i: int, j: int) -> float:
        """
        Compute Cov(1_i, 1_j) = Pr[i,j ∈ S] - Pr[i ∈ S]*Pr[j ∈ S].
        
        For symmetric PSD K, this equals -(K_ij)^2.
        """
        return self.pair_inclusion(i, j) - self.single_inclusion(i) * self.single_inclusion(j)


def certify_pairwise_negative_dependence(K: DPPKernel) -> Tuple[bool, List[dict]]:
    """
    Algorithm 1: Certify Pairwise Negative Dependence
    
    For a DPP kernel K, verify that for all pairs (i, j):
        Pr[i,j ∈ S] ≤ Pr[i ∈ S] * Pr[j ∈ S]
    
    Mathematically, this is equivalent to K_ij^2 ≥ 0 for symmetric K,
    which is always true. The algorithm verifies this numerically.
    
    Time complexity: O(n^2)
    Space complexity: O(n^2)
    
    Args:
        K: A DPPKernel instance
    
    Returns:
        (certified, details): bool and list of per-pair details
    
    Example:
        >>> K = DPPKernel.random(5)
        >>> certified, details = certify_pairwise_negative_dependence(K)
        >>> assert certified
    """
    n = K.n
    details = []
    certified = True
    
    for i in range(n):
        for j in range(i + 1, n):
            pw = K.pair_inclusion(i, j)
            product = K.single_inclusion(i) * K.single_inclusion(j)
            gap = product - pw  # Should be K_ij^2 >= 0
            ratio = K.correlation_ratio(i, j)
            
            ok = gap >= -1e-10
            if not ok:
                certified = False
            
            details.append({
                'i': i, 'j': j,
                'pair_weight': pw,
                'product': product,
                'gap': gap,
                'ratio': ratio,
                'certified': ok,
                'exact_gap': K.K[i, j] ** 2  # Should equal gap for symmetric K
            })
    
    return certified, details


def compute_partition_function(K: DPPKernel) -> Dict[tuple, float]:
    """
    Algorithm 2: Compute DPP Partition Function Coefficients
    
    Computes all coefficients of Z_K(x) = det(I + diag(x) K).
    The coefficient of ∏_{i∈S} x_i is det(K_S).
    
    Time complexity: O(2^n * n^3) — exponential in n
    Space complexity: O(2^n)
    
    For practical use, n ≤ 20 is recommended.
    
    Args:
        K: A DPPKernel instance
    
    Returns:
        Dictionary mapping subsets (sorted tuples) to coefficients
    """
    n = K.n
    coeffs = {tuple(): 1.0}
    
    for d in range(1, n + 1):
        for S in combinations(range(n), d):
            coeffs[S] = K.principal_minor(S)
    
    return coeffs


def hessian_lorentzian_recognizer(K: DPPKernel, d: int) -> Dict:
    """
    Algorithm 3: Hessian-Based Lorentzian Recognizer
    
    Tests whether the degree-d homogeneous component of Z_K is Lorentzian
    using the Brändén-Huh Hessian signature criterion.
    
    For the degree-d component, the algorithm:
    1. Computes all coefficients of the homogeneous component
    2. Checks that all coefficients are nonneg
    3. For d >= 2, checks Hessian signatures of derivative leaves
    
    Time complexity: O(C(n,d) * n^2) for coefficient extraction
    Space complexity: O(C(n,d))
    
    Args:
        K: A DPPKernel instance
        d: Degree of the homogeneous component
    
    Returns:
        Dictionary with recognition results
    """
    n = K.n
    
    # Trivial cases
    if d > n:
        return {'is_lorentzian': True, 'reason': 'zero polynomial (d > n)', 'degree': d}
    
    if d <= 1:
        # Degree 0 and 1 are always Lorentzian (with nonneg coefficients)
        coeffs = compute_partition_function(K)
        hom = {S: c for S, c in coeffs.items() if len(S) == d}
        all_nonneg = all(c >= -1e-12 for c in hom.values())
        return {
            'is_lorentzian': all_nonneg,
            'reason': f'degree {d}, nonneg check: {all_nonneg}',
            'degree': d,
            'num_terms': len(hom)
        }
    
    # For d >= 2, compute coefficients and check Hessian
    coeffs = compute_partition_function(K)
    hom = {S: c for S, c in coeffs.items() if len(S) == d}
    
    # Check nonnegativity
    all_nonneg = all(c >= -1e-12 for c in hom.values())
    if not all_nonneg:
        return {
            'is_lorentzian': False,
            'reason': 'negative coefficient',
            'degree': d,
            'num_terms': len(hom)
        }
    
    # For d == 2, directly check the Hessian
    if d == 2:
        H = np.zeros((n, n))
        for S, c in hom.items():
            i, j = S
            H[i, j] = c
            H[j, i] = c
        
        eigenvalues = np.linalg.eigvalsh(H)
        num_positive = np.sum(eigenvalues > 1e-10)
        
        return {
            'is_lorentzian': num_positive <= 1,
            'reason': f'Hessian has {num_positive} positive eigenvalue(s)',
            'degree': d,
            'num_terms': len(hom),
            'hessian_eigenvalues': eigenvalues,
            'num_positive_eigenvalues': int(num_positive)
        }
    
    # For d > 2, check all (d-2)-th order derivative leaves
    # Each derivative is specified by choosing d-2 variables to differentiate
    num_checks = 0
    num_pass = 0
    
    for deriv_vars in combinations(range(n), d - 2):
        # After differentiating d-2 times, we get a quadratic form
        # Its coefficient matrix has entries indexed by the remaining variables
        # For multiaffine polynomials, this simplifies greatly
        
        # The coefficient of x_i x_j in the derivative is:
        # the coefficient of the monomial x_{v1}...x_{vd-2} x_i x_j in the original
        H = np.zeros((n, n))
        for i in range(n):
            for j in range(i, n):
                S = tuple(sorted(set(deriv_vars) | {i, j}))
                if len(S) == d:  # Valid if all indices distinct
                    c = hom.get(S, 0.0)
                    H[i, j] = c
                    H[j, i] = c
        
        eigenvalues = np.linalg.eigvalsh(H)
        num_positive = np.sum(eigenvalues > 1e-10)
        num_checks += 1
        if num_positive <= 1:
            num_pass += 1
    
    return {
        'is_lorentzian': num_pass == num_checks,
        'reason': f'{num_pass}/{num_checks} derivative leaves pass Hessian test',
        'degree': d,
        'num_terms': len(hom),
        'num_checks': num_checks,
        'num_pass': num_pass
    }


def spectral_partition_analysis(K: DPPKernel) -> Dict:
    """
    Algorithm 4: Spectral Analysis of DPP Partition Function
    
    Analyzes the partition function through the spectral lens:
    Z_K(t,...,t) = det(I + tK) = ∏(1 + t*λ_i)
    
    This connects:
    - Elementary symmetric polynomials e_d(λ) to homogeneous components
    - Spectral gap to concentration properties
    - Condition number to computational stability
    
    Args:
        K: A DPPKernel instance
    
    Returns:
        Dictionary with spectral analysis results
    """
    eigenvalues = K.eigenvalues
    n = K.n
    
    # Elementary symmetric polynomials of eigenvalues
    # e_d(λ) = sum of products of d eigenvalues
    esym = np.zeros(n + 1)
    esym[0] = 1.0
    for k in range(n):
        for d in range(min(k + 1, n), 0, -1):
            esym[d] += eigenvalues[k] * esym[d - 1]
    
    # Total mass
    total_mass = np.prod(1 + eigenvalues)
    
    # Expected subset size
    expected_size = sum(eigenvalues / (1 + eigenvalues))
    
    return {
        'eigenvalues': eigenvalues,
        'elementary_symmetric': esym,
        'total_mass': total_mass,
        'expected_subset_size': expected_size,
        'spectral_gap': eigenvalues[-1] - eigenvalues[-2] if n >= 2 else 0,
        'condition_number': eigenvalues[-1] / max(eigenvalues[0], 1e-15)
    }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  DPP Negative Dependence Certification Algorithms")
    print("=" * 60)
    
    # Create a random DPP kernel
    np.random.seed(42)
    K = DPPKernel.random(n=5)
    
    print("\n--- Algorithm 1: Negative Dependence Certification ---")
    certified, details = certify_pairwise_negative_dependence(K)
    print(f"Certified: {certified}")
    print(f"Number of pairs checked: {len(details)}")
    print(f"Min gap: {min(d['gap'] for d in details):.8f}")
    print(f"Max ratio: {max(d['ratio'] for d in details if not np.isnan(d['ratio'])):.6f}")
    
    print("\n--- Algorithm 2: Partition Function ---")
    coeffs = compute_partition_function(K)
    print(f"Total terms: {len(coeffs)}")
    for d in range(K.n + 1):
        hom = {S: c for S, c in coeffs.items() if len(S) == d}
        total = sum(hom.values())
        print(f"  Degree {d}: {len(hom)} terms, sum = {total:.6f}")
    
    print("\n--- Algorithm 3: Lorentzian Recognition ---")
    for d in range(K.n + 1):
        result = hessian_lorentzian_recognizer(K, d)
        print(f"  Degree {d}: Lorentzian={result['is_lorentzian']}, {result['reason']}")
    
    print("\n--- Algorithm 4: Spectral Analysis ---")
    spectral = spectral_partition_analysis(K)
    print(f"Eigenvalues: {np.round(spectral['eigenvalues'], 4)}")
    print(f"Total mass Z_K(1,...,1): {spectral['total_mass']:.6f}")
    print(f"Expected subset size: {spectral['expected_subset_size']:.4f}")
    print(f"Spectral gap: {spectral['spectral_gap']:.4f}")
