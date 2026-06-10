#!/usr/bin/env python3
"""
Algorithms for Multi-Mode Lorentzian Witness Theory

Implements the core computational pipeline:
  1. Derivative leaf enumeration
  2. Mixed Hessian construction
  3. Spectral witness computation
  4. Pairwise vs. higher-order comparison
  5. DPP polynomial generation from kernels

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from itertools import combinations
from typing import Dict, Tuple, List, Set, Optional


# ─────────────────────────────────────────────────
# §1. Multivariate Polynomial Representation
# ─────────────────────────────────────────────────

class MultivariatePoly:
    """
    Sparse multivariate polynomial over ℝ.
    
    Representation: dictionary from exponent tuples to coefficients.
    Space complexity: O(T) where T = number of nonzero terms.
    
    Example:
        3*x0^2*x1 + 2*x2 → {(2,1,0): 3.0, (0,0,1): 2.0}
    """
    
    def __init__(self, n_vars: int, terms: Optional[Dict[Tuple[int,...], float]] = None):
        self.n_vars = n_vars
        self.terms: Dict[Tuple[int,...], float] = {}
        if terms:
            for k, v in terms.items():
                if abs(v) > 1e-15:
                    self.terms[k] = v
    
    @staticmethod
    def variable(n_vars: int, idx: int) -> 'MultivariatePoly':
        """Create x_idx. Time: O(1)."""
        exp = tuple(1 if i == idx else 0 for i in range(n_vars))
        return MultivariatePoly(n_vars, {exp: 1.0})
    
    @staticmethod
    def constant(n_vars: int, val: float) -> 'MultivariatePoly':
        """Create constant polynomial. Time: O(1)."""
        if abs(val) < 1e-15:
            return MultivariatePoly(n_vars)
        return MultivariatePoly(n_vars, {tuple(0 for _ in range(n_vars)): val})
    
    def add(self, other: 'MultivariatePoly') -> 'MultivariatePoly':
        """
        Add two polynomials.
        Time: O(T1 + T2) where Ti = number of terms in each.
        """
        result = MultivariatePoly(self.n_vars, dict(self.terms))
        for exp, coeff in other.terms.items():
            result.terms[exp] = result.terms.get(exp, 0.0) + coeff
            if abs(result.terms[exp]) < 1e-15:
                del result.terms[exp]
        return result
    
    def multiply(self, other: 'MultivariatePoly') -> 'MultivariatePoly':
        """
        Multiply two polynomials.
        Time: O(T1 * T2) where Ti = number of terms in each.
        """
        result = MultivariatePoly(self.n_vars)
        for e1, c1 in self.terms.items():
            for e2, c2 in other.terms.items():
                new_exp = tuple(a + b for a, b in zip(e1, e2))
                result.terms[new_exp] = result.terms.get(new_exp, 0.0) + c1 * c2
        # Clean
        result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
        return result
    
    def scalar_multiply(self, c: float) -> 'MultivariatePoly':
        """Scale by a constant. Time: O(T)."""
        return MultivariatePoly(self.n_vars, {k: c * v for k, v in self.terms.items()})
    
    def partial_derivative(self, var: int) -> 'MultivariatePoly':
        """
        Partial derivative ∂p/∂x_var.
        Time: O(T) where T = number of terms.
        
        Each term c * x^α maps to c * α_var * x^(α - e_var) if α_var > 0.
        """
        result = MultivariatePoly(self.n_vars)
        for exp, coeff in self.terms.items():
            if exp[var] > 0:
                new_exp = list(exp)
                new_coeff = coeff * exp[var]
                new_exp[var] -= 1
                new_exp_t = tuple(new_exp)
                result.terms[new_exp_t] = result.terms.get(new_exp_t, 0.0) + new_coeff
        result.terms = {k: v for k, v in result.terms.items() if abs(v) > 1e-15}
        return result
    
    def evaluate(self, point: np.ndarray) -> float:
        """
        Evaluate at a point.
        Time: O(T * n) where T = terms, n = variables.
        """
        total = 0.0
        for exp, coeff in self.terms.items():
            total += coeff * np.prod([point[i]**exp[i] for i in range(self.n_vars)])
        return total
    
    def evaluate_at_ones(self) -> float:
        """Evaluate at the all-ones point. Time: O(T)."""
        return sum(self.terms.values())
    
    def total_degree(self) -> int:
        """Maximum total degree. Time: O(T)."""
        if not self.terms:
            return -1
        return max(sum(e) for e in self.terms.keys())
    
    def all_nonneg_coefficients(self) -> bool:
        """Check if all coefficients are ≥ 0. Time: O(T)."""
        return all(c >= -1e-15 for c in self.terms.values())


# ─────────────────────────────────────────────────
# §2. Derivative Leaf Algorithm
# ─────────────────────────────────────────────────

def compute_derivative_leaf(
    p: MultivariatePoly, 
    subset_A: Set[int]
) -> MultivariatePoly:
    """
    Compute the derivative leaf L_A(x) = (∏_{i ∉ A} ∂_i) p(x).
    
    Algorithm:
        For each variable i in the complement of A (in sorted order),
        differentiate the current polynomial with respect to x_i.
    
    Time complexity: O(|complement| * T) where T = max terms at any step.
    Space complexity: O(T) for the current polynomial.
    
    Args:
        p: Input multivariate polynomial.
        subset_A: Set of variable indices to keep (the "subsystem").
    
    Returns:
        The derivative leaf polynomial.
    """
    complement = sorted(set(range(p.n_vars)) - subset_A)
    result = p
    for var in complement:
        result = result.partial_derivative(var)
    return result


def enumerate_derivative_leaves(
    p: MultivariatePoly, 
    k: int
) -> Dict[frozenset, MultivariatePoly]:
    """
    Enumerate all derivative leaves of codimension (n-k).
    
    Computes L_A for every subset A of size k.
    
    Time complexity: O(C(n,k) * (n-k) * T).
    Space complexity: O(C(n,k) * T) to store all leaves.
    
    Args:
        p: Input polynomial in n variables.
        k: Size of subsets (number of variables to keep).
    
    Returns:
        Dictionary mapping frozenset(A) -> L_A.
    """
    n = p.n_vars
    leaves = {}
    for A_tuple in combinations(range(n), k):
        A_set = set(A_tuple)
        leaves[frozenset(A_tuple)] = compute_derivative_leaf(p, A_set)
    return leaves


# ─────────────────────────────────────────────────
# §3. Mixed Hessian Algorithm
# ─────────────────────────────────────────────────

def compute_mixed_hessian_at_ones(
    p: MultivariatePoly, 
    subset_A: Set[int]
) -> np.ndarray:
    """
    Compute the mixed Hessian matrix at the all-ones point.
    
    H[a,b] = (∂²p/∂x_{A[a]} ∂x_{A[b]}) evaluated at x = 1.
    
    Algorithm:
        For each pair (i,j) in A × A:
            1. Differentiate p twice: ∂_j(∂_i(p))
            2. Evaluate at x = (1,...,1)
    
    Time complexity: O(k² * T) where k = |A|, T = number of terms.
    Space complexity: O(k² + T).
    
    Args:
        p: Input polynomial.
        subset_A: Set of variable indices for the Hessian.
    
    Returns:
        k × k numpy array (the mixed Hessian at ones).
    """
    indices = sorted(subset_A)
    k = len(indices)
    H = np.zeros((k, k))
    
    for a, i in enumerate(indices):
        pi = p.partial_derivative(i)
        for b, j in enumerate(indices):
            pij = pi.partial_derivative(j)
            H[a, b] = pij.evaluate_at_ones()
    
    return H


# ─────────────────────────────────────────────────
# §4. Spectral Witness Algorithms
# ─────────────────────────────────────────────────

def compute_spectral_witness(M: np.ndarray) -> float:
    """
    Compute the positive spectral witness of a symmetric matrix.
    
    Returns max(λ_max, 0) where λ_max is the largest eigenvalue.
    
    Time complexity: O(k³) for a k × k matrix (eigenvalue decomposition).
    Space complexity: O(k²).
    """
    if M.shape[0] == 0:
        return 0.0
    eigenvalues = np.linalg.eigvalsh(M)
    return max(eigenvalues[-1], 0.0)


def compute_spectral_witness_proxy(M: np.ndarray) -> float:
    """
    Computable proxy matching the Lean formalization.
    
    Returns max(trace(M), 0).
    
    Time complexity: O(k) for a k × k matrix.
    Space complexity: O(1).
    """
    return max(np.trace(M), 0.0)


def count_positive_eigenvalues(M: np.ndarray, tol: float = 1e-10) -> int:
    """
    Count positive eigenvalues of a symmetric matrix.
    
    Time: O(k³). Space: O(k).
    """
    eigenvalues = np.linalg.eigvalsh(M)
    return int(np.sum(eigenvalues > tol))


def compute_leaf_witness(
    p: MultivariatePoly, 
    subset_A: Set[int]
) -> float:
    """
    Full leaf witness pipeline:
        1. Compute derivative leaf L_A
        2. Build mixed Hessian H at ones
        3. Return max eigenvalue (positive spectral witness)
    
    Time: O((n-k)*T + k²*T' + k³) where T,T' are term counts.
    """
    leaf = compute_derivative_leaf(p, subset_A)
    H = compute_mixed_hessian_at_ones(leaf, subset_A)
    return compute_spectral_witness(H)


def compute_pairwise_witness(
    p: MultivariatePoly, 
    i: int, j: int
) -> float:
    """
    Compute pairwise leaf witness for variables i and j.
    
    Returns [eval_1(∂_i ∂_j L_{i,j})]² — the squared mixed partial at ones.
    
    Time: O((n-2)*T + T').
    """
    leaf = compute_derivative_leaf(p, {i, j})
    val = leaf.partial_derivative(i).partial_derivative(j).evaluate_at_ones()
    return val ** 2


# ─────────────────────────────────────────────────
# §5. DPP Polynomial Construction
# ─────────────────────────────────────────────────

def build_dpp_polynomial(K: np.ndarray) -> MultivariatePoly:
    """
    Build the DPP partition polynomial Z_K(x) = det(I + diag(x)·K).
    
    Uses the principal minor expansion:
        Z_K(x) = ∑_S det(K_S) · ∏_{i∈S} x_i
    
    Time complexity: O(2^n * n³) (enumerate subsets, compute minors).
    Space complexity: O(2^n) for the polynomial terms.
    
    Args:
        K: n × n PSD kernel matrix.
    
    Returns:
        The DPP partition polynomial.
    """
    n = K.shape[0]
    p = MultivariatePoly(n)
    
    for size in range(n + 1):
        for S in combinations(range(n), size):
            if len(S) == 0:
                minor = 1.0
            else:
                submat = K[np.ix_(list(S), list(S))]
                minor = np.linalg.det(submat)
            
            exp = tuple(1 if i in S else 0 for i in range(n))
            p.terms[exp] = p.terms.get(exp, 0.0) + minor
    
    p.terms = {k: v for k, v in p.terms.items() if abs(v) > 1e-15}
    return p


def compute_principal_minor(K: np.ndarray, S: Set[int]) -> float:
    """
    Compute det(K_S) — the principal minor of K indexed by S.
    
    Time: O(k³) where k = |S|.
    """
    if len(S) == 0:
        return 1.0
    indices = sorted(S)
    return np.linalg.det(K[np.ix_(indices, indices)])


# ─────────────────────────────────────────────────
# §6. Comparison Pipeline
# ─────────────────────────────────────────────────

def multipartite_witness_comparison(
    p: MultivariatePoly,
    k: int = 3
) -> List[Dict]:
    """
    Compare pairwise vs. higher-order witnesses for all subsets of size k.
    
    For each k-element subset A:
        1. Compute the higher-order leaf witness
        2. Compute all C(k,2) pairwise witnesses within A
        3. Report the ratio and separation
    
    Time: O(C(n,k) * [higher_cost + C(k,2) * pairwise_cost]).
    
    Returns:
        List of dictionaries with comparison data.
    """
    n = p.n_vars
    results = []
    
    for A_tuple in combinations(range(n), k):
        A_set = set(A_tuple)
        
        # Higher-order witness
        higher_w = compute_leaf_witness(p, A_set)
        
        # Pairwise witnesses
        pairwise_data = []
        for i, j in combinations(A_tuple, 2):
            pw = compute_pairwise_witness(p, i, j)
            pairwise_data.append({
                'pair': (i, j),
                'witness': pw
            })
        
        max_pw = max(d['witness'] for d in pairwise_data) if pairwise_data else 0
        
        results.append({
            'subset': A_set,
            'higher_witness': higher_w,
            'pairwise_witnesses': pairwise_data,
            'max_pairwise': max_pw,
            'separation_ratio': higher_w / max_pw if max_pw > 1e-15 else float('inf'),
            'has_separation': higher_w > max_pw * 1.01  # 1% threshold
        })
    
    return results


def lorentzian_signature_check(
    p: MultivariatePoly,
    k: int = 3,
    tol: float = 1e-8
) -> Dict:
    """
    Verify the Lorentzian spectral signature constraint:
    each leaf Hessian should have at most one positive eigenvalue.
    
    Returns a summary with any violations.
    """
    n = p.n_vars
    violations = []
    total_checked = 0
    
    for A_tuple in combinations(range(n), k):
        A_set = set(A_tuple)
        leaf = compute_derivative_leaf(p, A_set)
        H = compute_mixed_hessian_at_ones(leaf, A_set)
        n_pos = count_positive_eigenvalues(H, tol)
        total_checked += 1
        
        if n_pos > 1:
            eigs = np.linalg.eigvalsh(H)
            violations.append({
                'subset': A_set,
                'eigenvalues': eigs.tolist(),
                'n_positive': n_pos
            })
    
    return {
        'total_checked': total_checked,
        'violations': violations,
        'all_lorentzian': len(violations) == 0
    }


# ─────────────────────────────────────────────────
# §7. Example Usage
# ─────────────────────────────────────────────────

if __name__ == "__main__":
    # Example: 4-variable DPP
    np.random.seed(42)
    n = 4
    A = np.random.randn(n, n)
    K = A @ A.T / n
    
    print("=" * 60)
    print("Algorithm Pipeline Example")
    print("=" * 60)
    print(f"\nKernel K ({n}×{n}):")
    print(np.round(K, 3))
    
    # Build polynomial
    Z = build_dpp_polynomial(K)
    print(f"\nDPP polynomial: {len(Z.terms)} terms")
    print(f"All nonneg: {Z.all_nonneg_coefficients()}")
    
    # Comparison
    results = multipartite_witness_comparison(Z, k=3)
    print("\n--- Witness Comparison (k=3) ---")
    for r in results:
        print(f"  A={r['subset']}: higher={r['higher_witness']:.4f}, "
              f"max_pair={r['max_pairwise']:.4f}, ratio={r['separation_ratio']:.2f}")
    
    # Lorentzian check
    check = lorentzian_signature_check(Z, k=3)
    print(f"\nLorentzian signature check: {'PASS' if check['all_lorentzian'] else 'FAIL'}")
    print(f"Checked {check['total_checked']} leaves, {len(check['violations'])} violations")
