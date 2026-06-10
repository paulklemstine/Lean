"""
Algorithms for Higher-Order Minor Perturbation Certification

Implements the certified perturbation bound computation and scanning procedures
for k×k principal minors of symmetric PSD kernels.
"""

import numpy as np
from itertools import combinations
from math import factorial
from typing import List, Tuple, Optional, Dict


def minor_perturb_poly(k: int, M: float) -> float:
    """
    Compute the certified perturbation polynomial P(k, M) = k · k! · M^(k-1).
    
    This is the Lipschitz constant for the determinant map restricted to
    k×k matrices with entries bounded by M, measured in entrywise max norm.
    
    Args:
        k: Subset size (order of the minor)
        M: Entry magnitude bound (max |K_ij|)
    
    Returns:
        P(k, M) = k · k! · M^(k-1)
    
    Time complexity: O(k) for factorial computation
    Space complexity: O(1)
    
    Examples:
        >>> minor_perturb_poly(0, 1.0)
        0.0
        >>> minor_perturb_poly(1, 5.0)
        1.0
        >>> minor_perturb_poly(2, 1.0)
        4.0
        >>> minor_perturb_poly(3, 1.0)
        18.0
    """
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


def certified_minor_bound(k: int, M: float, eta: float) -> float:
    """
    Compute the certified bound on |det(K_S) - det(K'_S)|.
    
    For any k-subset S and matrices K, K' with:
      - |K_ij| ≤ M and |K'_ij| ≤ M for all i,j
      - |K_ij - K'_ij| ≤ η for all i,j
    
    We have: |det(K_S) - det(K'_S)| ≤ P(k, M) · η
    
    Args:
        k: Subset size
        M: Entry magnitude bound
        eta: Entrywise perturbation bound
    
    Returns:
        Certified upper bound P(k, M) · η
    """
    return minor_perturb_poly(k, M) * eta


def critical_perturbation(k: int, M: float, delta: float) -> float:
    """
    Compute the critical perturbation budget η* for positivity preservation.
    
    If all k-minors of K are ≥ δ, then positivity is preserved for all
    K' with |K_ij - K'_ij| ≤ η whenever η < η*.
    
    Args:
        k: Subset size
        M: Entry magnitude bound
        delta: Minimum minor value (positivity margin)
    
    Returns:
        η* = δ / P(k, M), the critical perturbation threshold
    """
    P = minor_perturb_poly(k, M)
    if P <= 0:
        return float('inf')
    return delta / P


class HigherOrderNegDepCertificate:
    """
    Higher-Order Negative Dependence Certificate.
    
    Bundles the certification data for k-wise correlation stability
    under kernel perturbation.
    
    Attributes:
        n: Matrix dimension
        k: Subset size (order)
        M: Entry magnitude bound
        eta: Perturbation budget
        poly_bound: Certified bound P(k,M)·η
    """
    
    def __init__(self, n: int, k: int, M: float, eta: float):
        """
        Construct a certificate.
        
        Args:
            n: Matrix dimension
            k: Subset size
            M: Entry magnitude bound (must be ≥ 0)
            eta: Perturbation budget (must be ≥ 0)
        """
        assert M >= 0, "Entry bound M must be nonneg"
        assert eta >= 0, "Perturbation budget η must be nonneg"
        
        self.n = n
        self.k = k
        self.M = M
        self.eta = eta
        self.poly_bound = certified_minor_bound(k, M, eta)
    
    def is_valid_for(self, K: np.ndarray, K_prime: np.ndarray) -> bool:
        """
        Verify that the certificate conditions hold for given matrices.
        
        Checks:
          1. K and K' have entries bounded by M
          2. |K - K'| entrywise ≤ η
        
        Args:
            K: Original kernel matrix
            K_prime: Perturbed kernel matrix
        
        Returns:
            True if certificate conditions are satisfied
        """
        if np.max(np.abs(K)) > self.M + 1e-10:
            return False
        if np.max(np.abs(K_prime)) > self.M + 1e-10:
            return False
        if np.max(np.abs(K - K_prime)) > self.eta + 1e-10:
            return False
        return True
    
    def certify_all_minors(self, K: np.ndarray, K_prime: np.ndarray) -> Dict:
        """
        Scan all k-subsets and verify the certified bound.
        
        For each k-subset S, computes |det(K_S) - det(K'_S)| and
        verifies it is ≤ poly_bound.
        
        Time complexity: O(C(n,k) · k^3) where C(n,k) = n!/(k!(n-k)!)
        Space complexity: O(k^2)
        
        Args:
            K: Original kernel matrix
            K_prime: Perturbed kernel matrix
        
        Returns:
            Dictionary with certification results
        """
        results = {
            'n': self.n,
            'k': self.k,
            'M': self.M,
            'eta': self.eta,
            'certified_bound': self.poly_bound,
            'all_valid': True,
            'max_error': 0.0,
            'n_subsets': 0,
            'violations': []
        }
        
        for S in combinations(range(self.n), self.k):
            idx = list(S)
            det_K = np.linalg.det(K[np.ix_(idx, idx)])
            det_Kp = np.linalg.det(K_prime[np.ix_(idx, idx)])
            error = abs(det_K - det_Kp)
            
            results['n_subsets'] += 1
            results['max_error'] = max(results['max_error'], error)
            
            if error > self.poly_bound + 1e-10:
                results['all_valid'] = False
                results['violations'].append({
                    'subset': S,
                    'error': error,
                    'bound': self.poly_bound
                })
        
        results['tightness'] = (results['max_error'] / self.poly_bound 
                                if self.poly_bound > 0 else 0)
        
        return results
    
    def positivity_margin_check(self, K: np.ndarray) -> Dict:
        """
        Check positivity margins and compute critical perturbation budgets.
        
        For each k-subset, computes det(K_S) and determines the minimum
        margin. Then computes the critical η for positivity preservation.
        
        Args:
            K: Kernel matrix (should be PSD)
        
        Returns:
            Dictionary with margin analysis
        """
        margins = []
        for S in combinations(range(self.n), self.k):
            idx = list(S)
            det_K = np.linalg.det(K[np.ix_(idx, idx)])
            margins.append((S, det_K))
        
        min_margin_S, min_margin = min(margins, key=lambda x: x[1])
        eta_critical = critical_perturbation(self.k, self.M, min_margin)
        
        return {
            'min_margin': min_margin,
            'min_margin_subset': min_margin_S,
            'eta_critical': eta_critical,
            'current_eta': self.eta,
            'positivity_guaranteed': self.eta < eta_critical if min_margin > 0 else False,
            'all_margins': margins
        }
    
    def __repr__(self) -> str:
        return (f"HigherOrderNegDepCertificate(n={self.n}, k={self.k}, "
                f"M={self.M:.4f}, η={self.eta:.6f}, "
                f"bound={self.poly_bound:.6f})")


def scan_principal_minors(K: np.ndarray, k: int) -> Dict:
    """
    Scan all k-subsets of a matrix and compute principal minor statistics.
    
    Args:
        K: Square matrix
        k: Subset size
    
    Returns:
        Dictionary with minor statistics
    """
    n = K.shape[0]
    minors = []
    for S in combinations(range(n), k):
        idx = list(S)
        det_val = np.linalg.det(K[np.ix_(idx, idx)])
        minors.append((S, det_val))
    
    values = [m[1] for m in minors]
    return {
        'n': n,
        'k': k,
        'count': len(minors),
        'min': min(values),
        'max': max(values),
        'mean': np.mean(values),
        'std': np.std(values),
        'all_nonneg': all(v >= -1e-10 for v in values),
        'minors': minors
    }


# Example usage
if __name__ == "__main__":
    np.random.seed(42)
    
    # Generate PSD matrix
    n = 6
    A = np.random.randn(n, n) / np.sqrt(n)
    K = A @ A.T
    
    # Perturb
    eta = 0.01
    E = np.random.uniform(-eta, eta, (n, n))
    E = (E + E.T) / 2
    K_prime = K + E
    
    M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))
    actual_eta = np.max(np.abs(K - K_prime))
    
    print("Certificate Construction and Verification")
    print("=" * 50)
    
    for k in range(1, 5):
        cert = HigherOrderNegDepCertificate(n, k, M, actual_eta)
        print(f"\n{cert}")
        
        results = cert.certify_all_minors(K, K_prime)
        print(f"  Subsets scanned: {results['n_subsets']}")
        print(f"  Max error: {results['max_error']:.8f}")
        print(f"  Certified bound: {results['certified_bound']:.8f}")
        print(f"  Tightness: {results['tightness']:.4f}")
        print(f"  All valid: {results['all_valid']}")
        
        margin = cert.positivity_margin_check(K)
        print(f"  Min margin: {margin['min_margin']:.6f}")
        print(f"  Critical η: {margin['eta_critical']:.6f}")
        print(f"  Positivity guaranteed: {margin['positivity_guaranteed']}")
