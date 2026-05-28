#!/usr/bin/env python3
"""
Algorithms for Entropy Monotonicity under Derivative Transport

Implements the core algorithms from the research paper:
1. Shannon entropy computation for polynomial coefficients
2. Derivative transport (coefficient transformation under differentiation)
3. Derivative entropy tower with certified monotonicity check
4. KL divergence decomposition under reweighting
5. Lorentzian property verification (degree 2)

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import Dict, Tuple, List, Optional
from math import factorial, log, comb


# ─────────────────────────────────────────────────────────────
# Algorithm 1: Multi-index Generation
# ─────────────────────────────────────────────────────────────

def generate_multi_indices(n: int, d: int) -> List[Tuple[int, ...]]:
    """Generate all multi-indices α ∈ ℕⁿ with |α| = d.
    
    Args:
        n: Number of variables
        d: Total degree
    
    Returns:
        List of n-tuples summing to d
    
    Complexity: O(C(n+d-1, d)) time and space
    
    Example:
        >>> generate_multi_indices(2, 2)
        [(0, 2), (1, 1), (2, 0)]
    """
    if n == 0:
        return [()] if d == 0 else []
    if n == 1:
        return [(d,)]
    result = []
    for k in range(d + 1):
        for rest in generate_multi_indices(n - 1, d - k):
            result.append((k,) + rest)
    return result


# ─────────────────────────────────────────────────────────────
# Algorithm 2: Shannon Entropy
# ─────────────────────────────────────────────────────────────

def shannon_entropy(coefficients: np.ndarray) -> float:
    """Compute Shannon entropy H(p) = -Σ pᵢ log pᵢ of normalized coefficients.
    
    Normalizes the input coefficients to form a probability distribution,
    then computes the Shannon entropy using the convention 0·log(0) = 0.
    
    Args:
        coefficients: Non-negative coefficient array
    
    Returns:
        Shannon entropy in nats (natural log)
    
    Raises:
        ValueError: If all coefficients are zero or any are negative
    
    Complexity: O(n) where n = len(coefficients)
    
    Example:
        >>> shannon_entropy(np.array([1.0, 3.0, 3.0, 1.0]))  # (x+y)³
        1.386...
    """
    c = np.asarray(coefficients, dtype=float)
    if np.any(c < 0):
        raise ValueError("Coefficients must be non-negative")
    total = np.sum(c)
    if total <= 0:
        raise ValueError("Total coefficient sum must be positive")
    
    p = c / total
    # Apply convention: 0 * log(0) = 0
    mask = p > 0
    return -np.sum(p[mask] * np.log(p[mask]))


# ─────────────────────────────────────────────────────────────
# Algorithm 3: KL Divergence with Decomposition
# ─────────────────────────────────────────────────────────────

def kl_divergence(p: np.ndarray, q: np.ndarray) -> float:
    """Compute KL divergence D_KL(p || q) = Σ pᵢ log(pᵢ/qᵢ).
    
    Args:
        p: First probability distribution (must be positive where p > 0)
        q: Second probability distribution (must be positive where p > 0)
    
    Returns:
        KL divergence (always ≥ 0 by Gibbs' inequality)
    
    Complexity: O(n) where n = len(p)
    """
    p = np.asarray(p, dtype=float)
    q = np.asarray(q, dtype=float)
    mask = p > 0
    if np.any(q[mask] <= 0):
        return float('inf')
    return np.sum(p[mask] * np.log(p[mask] / q[mask]))


def kl_reweight_decomposition(p: np.ndarray, w: np.ndarray) -> Dict[str, float]:
    """Compute KL divergence decomposition for reweighted distribution.
    
    For q = reweight(p, w), computes:
    - D_KL(q || p)
    - Σ qᵢ log wᵢ
    - log S where S = Σ wⱼpⱼ
    
    Verifies the identity: D_KL(q || p) = Σ qᵢ log wᵢ - log S
    
    Args:
        p: Probability distribution (positive entries)
        w: Positive weights
    
    Returns:
        Dictionary with 'kl_divergence', 'weighted_log_sum', 'log_normalizer',
        'identity_error' (should be ~0)
    
    Complexity: O(n)
    """
    p = np.asarray(p, dtype=float)
    w = np.asarray(w, dtype=float)
    
    S = np.sum(w * p)
    q = w * p / S
    
    dkl = kl_divergence(q, p)
    weighted_log = np.sum(q * np.log(w))
    log_S = np.log(S)
    
    return {
        'kl_divergence': dkl,
        'weighted_log_sum': weighted_log,
        'log_normalizer': log_S,
        'identity_error': abs(dkl - (weighted_log - log_S)),
        'weighted_jensen_satisfied': weighted_log >= log_S - 1e-12
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 4: Derivative Transport
# ─────────────────────────────────────────────────────────────

def derivative_transport(
    coeffs: Dict[Tuple[int, ...], float],
    variable: int
) -> Dict[Tuple[int, ...], float]:
    """Apply derivative transport: c'_β = (β_var + 1) · c_{β + e_var}.
    
    This computes the coefficients of ∂p/∂x_{variable}.
    
    Args:
        coeffs: Dictionary mapping multi-indices to coefficients
        variable: Index of variable to differentiate with respect to
    
    Returns:
        New coefficient dictionary for the derivative
    
    Complexity: O(|supp(p)|) time, O(|supp(∂p)|) space
    
    Example:
        >>> # p(x,y) = x² + 2xy + y²
        >>> coeffs = {(2,0): 1.0, (1,1): 2.0, (0,2): 1.0}
        >>> derivative_transport(coeffs, 0)
        {(1, 0): 2.0, (0, 1): 2.0}
    """
    new_coeffs: Dict[Tuple[int, ...], float] = {}
    for alpha, c in coeffs.items():
        if alpha[variable] > 0:
            beta = list(alpha)
            beta[variable] -= 1
            beta_tuple = tuple(beta)
            # c'_β = α_var · c_α
            new_coeffs[beta_tuple] = new_coeffs.get(beta_tuple, 0.0) + alpha[variable] * c
    return new_coeffs


# ─────────────────────────────────────────────────────────────
# Algorithm 5: Derivative Entropy Tower
# ─────────────────────────────────────────────────────────────

class DerivativeEntropyTower:
    """The entropy tower of a polynomial: entropy at each derivative level.
    
    This is a new invariant capturing the "information content" of the
    coefficient geometry as differentiation concentrates mass.
    
    Attributes:
        tower: List of entropy values, one per derivative level
        is_monotone: Whether the tower is monotonically decreasing
        total_drop: Total entropy decrease from top to bottom
        n_vars: Number of variables
        degree: Polynomial degree
    """
    
    def __init__(self, tower: List[float], n_vars: int, degree: int):
        self.tower = tower
        self.n_vars = n_vars
        self.degree = degree
        self.is_monotone = all(
            tower[i] >= tower[i+1] - 1e-10 
            for i in range(len(tower) - 1)
        )
        self.total_drop = tower[0] - tower[-1] if tower else 0.0
    
    def __repr__(self) -> str:
        lines = [f"DerivativeEntropyTower(n={self.n_vars}, d={self.degree})"]
        for k, h in enumerate(self.tower):
            arrow = " ↓" if k > 0 else ""
            lines.append(f"  Level {k}: H = {h:.6f}{arrow}")
        lines.append(f"  Monotone: {self.is_monotone}")
        lines.append(f"  Total drop: {self.total_drop:.6f}")
        return "\n".join(lines)


def compute_entropy_tower(
    coeffs: Dict[Tuple[int, ...], float],
    n_vars: int,
    degree: int,
    variable: int = 0
) -> DerivativeEntropyTower:
    """Compute the derivative entropy tower.
    
    Repeatedly differentiates with respect to the specified variable
    and records the Shannon entropy at each level.
    
    Args:
        coeffs: Initial polynomial coefficients
        n_vars: Number of variables
        degree: Polynomial degree
        variable: Variable index to differentiate (default: 0)
    
    Returns:
        DerivativeEntropyTower instance with certified monotonicity check
    
    Complexity: O(d · |supp(p)|) time, O(|supp(p)|) space
    """
    tower = []
    current = coeffs.copy()
    
    for k in range(degree + 1):
        vals = np.array(list(current.values()))
        if np.sum(vals) <= 0:
            break
        tower.append(shannon_entropy(vals))
        
        if k < degree:
            current = derivative_transport(current, variable)
            if not current:
                # Derivative is zero — remaining tower entries are 0
                tower.extend([0.0] * (degree - k))
                break
    
    return DerivativeEntropyTower(tower, n_vars, degree)


# ─────────────────────────────────────────────────────────────
# Algorithm 6: Lorentzian Verification (Degree 2)
# ─────────────────────────────────────────────────────────────

def verify_lorentzian_degree2(hessian: np.ndarray) -> Dict[str, object]:
    """Verify the Lorentzian property for a degree-2 polynomial.
    
    A degree-2 homogeneous polynomial p(x) = Σ a_{ij} xᵢxⱼ is Lorentzian iff:
    1. All coefficients a_{ij} ≥ 0
    2. The Hessian matrix has at most one positive eigenvalue
    
    Args:
        hessian: Symmetric matrix of second-order coefficients
    
    Returns:
        Dictionary with 'is_lorentzian', 'eigenvalues', 'nonneg_coeffs',
        'num_positive_eigenvalues'
    
    Complexity: O(n³) for eigenvalue computation
    """
    H = np.asarray(hessian, dtype=float)
    n = H.shape[0]
    
    # Check nonnegativity
    nonneg = np.all(H >= -1e-12)
    
    # Compute eigenvalues
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    num_positive = np.sum(eigenvalues > 1e-12)
    
    return {
        'is_lorentzian': nonneg and num_positive <= 1,
        'eigenvalues': eigenvalues,
        'nonneg_coeffs': nonneg,
        'num_positive_eigenvalues': int(num_positive)
    }


# ─────────────────────────────────────────────────────────────
# Algorithm 7: Complete Homogeneous Symmetric Polynomial
# ─────────────────────────────────────────────────────────────

def complete_homogeneous_symmetric(n: int, d: int) -> Dict[Tuple[int, ...], float]:
    """Generate coefficients of (x₁ + ... + xₙ)^d.
    
    The coefficient of x^α is the multinomial coefficient d!/(α₁!...αₙ!).
    
    Args:
        n: Number of variables
        d: Degree
    
    Returns:
        Coefficient dictionary
    
    Complexity: O(C(n+d-1, d)) time and space
    """
    indices = generate_multi_indices(n, d)
    coeffs = {}
    for alpha in indices:
        coeff = factorial(d)
        for a in alpha:
            coeff //= factorial(a)
        coeffs[alpha] = float(coeff)
    return coeffs


# ─────────────────────────────────────────────────────────────
# Algorithm 8: Quantitative Bound Verification
# ─────────────────────────────────────────────────────────────

def quantitative_entropy_bound(n: int, d: int) -> float:
    """Compute the conjectured lower bound on total entropy collapse.
    
    Bound: (1/2) log C(n+d-1, d-1) - (d-1)/2 log(d)
    
    Args:
        n: Number of variables
        d: Degree
    
    Returns:
        Lower bound value in nats
    """
    binom_val = comb(n + d - 1, d - 1)
    if binom_val <= 0 or d <= 0:
        return 0.0
    return 0.5 * log(binom_val) - (d - 1) / 2 * log(d)


def verify_quantitative_bound(
    n: int, d: int, num_trials: int = 100, seed: int = 42
) -> Dict[str, object]:
    """Verify the quantitative entropy collapse bound for given parameters.
    
    Args:
        n: Number of variables
        d: Degree
        num_trials: Number of random Lorentzian polynomials to test
        seed: Random seed for reproducibility
    
    Returns:
        Dictionary with verification results
    """
    np.random.seed(seed)
    bound = quantitative_entropy_bound(n, d)
    
    # Test complete homogeneous symmetric polynomial
    coeffs = complete_homogeneous_symmetric(n, d)
    tower = compute_entropy_tower(coeffs, n, d)
    hd_drop = tower.total_drop
    
    # Test random Lorentzian polynomials
    drops = []
    for _ in range(num_trials):
        try:
            # Generate product of random linear forms
            rc: Dict[Tuple[int, ...], float] = {(0,) * n: 1.0}
            for _ in range(d):
                linear = np.random.exponential(1.0, n)
                new_rc: Dict[Tuple[int, ...], float] = {}
                for alpha, c in rc.items():
                    for i in range(n):
                        new_alpha = list(alpha)
                        new_alpha[i] += 1
                        new_alpha_t = tuple(new_alpha)
                        new_rc[new_alpha_t] = new_rc.get(new_alpha_t, 0.0) + c * linear[i]
                rc = new_rc
            
            rt = compute_entropy_tower(rc, n, d)
            drops.append(rt.total_drop)
        except Exception:
            pass
    
    return {
        'n': n,
        'd': d,
        'bound': bound,
        'hd_drop': hd_drop,
        'hd_satisfies': hd_drop >= bound - 1e-6,
        'min_random_drop': min(drops) if drops else None,
        'all_random_satisfy': all(dr >= bound - 1e-6 for dr in drops) if drops else None,
        'num_tested': len(drops)
    }


# ─────────────────────────────────────────────────────────────
# Main: Example usage
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Entropy Monotonicity Algorithms — Example Usage")
    print("=" * 55)
    
    # Example 1: Entropy tower
    print("\n1. Entropy tower for (x+y+z)³:")
    coeffs = complete_homogeneous_symmetric(3, 3)
    tower = compute_entropy_tower(coeffs, 3, 3)
    print(tower)
    
    # Example 2: KL decomposition
    print("\n2. KL decomposition under reweighting:")
    p = np.array([0.3, 0.5, 0.2])
    w = np.array([1.0, 2.0, 3.0])
    result = kl_reweight_decomposition(p, w)
    print(f"   D_KL = {result['kl_divergence']:.8f}")
    print(f"   Σ qᵢ log wᵢ = {result['weighted_log_sum']:.8f}")
    print(f"   log S = {result['log_normalizer']:.8f}")
    print(f"   Identity error: {result['identity_error']:.2e}")
    print(f"   Jensen satisfied: {result['weighted_jensen_satisfied']}")
    
    # Example 3: Lorentzian verification
    print("\n3. Lorentzian verification (degree 2):")
    H1 = np.array([[1, 10], [10, 1]])  # Lorentzian
    H2 = np.array([[100, 1], [1, 100]])  # Not Lorentzian
    print(f"   [[1,10],[10,1]]: {verify_lorentzian_degree2(H1)['is_lorentzian']}")
    print(f"   [[100,1],[1,100]]: {verify_lorentzian_degree2(H2)['is_lorentzian']}")
    
    # Example 4: Quantitative bound
    print("\n4. Quantitative bound verification:")
    for n, d in [(3, 2), (4, 3), (5, 2)]:
        result = verify_quantitative_bound(n, d, num_trials=50)
        print(f"   n={n}, d={d}: bound={result['bound']:.4f}, "
              f"h_d drop={result['hd_drop']:.4f}, "
              f"all satisfy: {result['all_random_satisfy']}")
