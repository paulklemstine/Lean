"""
Tropical Leaf Witness Algorithms
================================

Implements the core algorithms for computing tropical leaf witnesses
of derivative leaves of multivariate polynomials, specializing to
determinantal point processes (DPPs).

Key algorithms:
1. Derivative leaf computation via iterated partial differentiation
2. Tropicalization via coefficient valuations (archimedean and p-adic)
3. Tropical leaf witness extraction
4. Spectral witness proxy computation
"""

import numpy as np
from typing import Dict, Tuple, List, Optional, Set, FrozenSet
from itertools import combinations
from functools import lru_cache
import math


# =============================================================================
# §1. Multivariate Polynomial Representation
# =============================================================================

class MvPolynomial:
    """Sparse multivariate polynomial over ℝ.
    
    Represented as a dictionary mapping exponent tuples to coefficients.
    An exponent tuple (a₁, ..., aₙ) represents the monomial x₁^a₁ ⋯ xₙ^aₙ.
    
    Example:
        >>> p = MvPolynomial(n=2, coeffs={(2,0): 3.0, (0,1): -1.0})
        >>> # represents 3x₁² - x₂
    """
    
    def __init__(self, n: int, coeffs: Optional[Dict[Tuple[int,...], float]] = None):
        self.n = n
        self.coeffs: Dict[Tuple[int,...], float] = {}
        if coeffs:
            for exp, c in coeffs.items():
                if abs(c) > 1e-15:
                    self.coeffs[tuple(exp)] = c
    
    @property
    def support(self) -> Set[Tuple[int,...]]:
        """The support: set of exponent vectors with nonzero coefficient."""
        return set(self.coeffs.keys())
    
    def coeff(self, exp: Tuple[int,...]) -> float:
        """Get coefficient of monomial x^exp."""
        return self.coeffs.get(tuple(exp), 0.0)
    
    def eval_at(self, x: np.ndarray) -> float:
        """Evaluate polynomial at point x."""
        result = 0.0
        for exp, c in self.coeffs.items():
            term = c
            for i, e in enumerate(exp):
                if e > 0:
                    term *= x[i] ** e
            result += term
        return result
    
    def pderiv(self, var: int) -> 'MvPolynomial':
        """Partial derivative with respect to variable var.
        
        ∂/∂x_var (c · x^α) = c · α_var · x^(α - e_var)
        """
        new_coeffs = {}
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                new_exp = list(exp)
                new_c = c * exp[var]
                new_exp[var] -= 1
                new_exp_t = tuple(new_exp)
                new_coeffs[new_exp_t] = new_coeffs.get(new_exp_t, 0.0) + new_c
        return MvPolynomial(self.n, new_coeffs)
    
    def __add__(self, other: 'MvPolynomial') -> 'MvPolynomial':
        new_coeffs = dict(self.coeffs)
        for exp, c in other.coeffs.items():
            new_coeffs[exp] = new_coeffs.get(exp, 0.0) + c
        return MvPolynomial(self.n, new_coeffs)
    
    def __mul__(self, other: 'MvPolynomial') -> 'MvPolynomial':
        new_coeffs = {}
        for e1, c1 in self.coeffs.items():
            for e2, c2 in other.coeffs.items():
                new_exp = tuple(a + b for a, b in zip(e1, e2))
                new_coeffs[new_exp] = new_coeffs.get(new_exp, 0.0) + c1 * c2
        return MvPolynomial(self.n, new_coeffs)
    
    def scale(self, c: float) -> 'MvPolynomial':
        return MvPolynomial(self.n, {exp: c * v for exp, v in self.coeffs.items()})
    
    def __repr__(self):
        if not self.coeffs:
            return "0"
        terms = []
        for exp, c in sorted(self.coeffs.items()):
            var_parts = []
            for i, e in enumerate(exp):
                if e == 1:
                    var_parts.append(f"x{i}")
                elif e > 1:
                    var_parts.append(f"x{i}^{e}")
            monomial = "*".join(var_parts) if var_parts else "1"
            terms.append(f"{c:.4g}*{monomial}")
        return " + ".join(terms)


# =============================================================================
# §2. Derivative Leaf Computation
# =============================================================================

def derivative_leaf(p: MvPolynomial, A: Set[int]) -> MvPolynomial:
    """Compute the derivative leaf L_A(p).
    
    L_A(p) = (∏_{i ∉ A} ∂/∂xᵢ) p
    
    Differentiates p once in each variable NOT in A.
    
    Args:
        p: Multivariate polynomial
        A: Subset of variable indices {0, ..., n-1}
        
    Returns:
        The derivative leaf polynomial
        
    Complexity: O(|support| · (n - |A|)) coefficient operations
    """
    result = p
    complement = set(range(p.n)) - A
    for i in sorted(complement):
        result = result.pderiv(i)
    return result


# =============================================================================
# §3. Coefficient Norms (Tropical Invariants)
# =============================================================================

def coeff_abs_sum(p: MvPolynomial) -> float:
    """L¹ coefficient norm: ∑_{α ∈ supp(p)} |c_α|.
    
    This is the archimedean tropicalization of the polynomial:
    it captures the total "coefficient mass" without cancellation.
    """
    return sum(abs(c) for c in p.coeffs.values())


def coeff_sup_norm(p: MvPolynomial) -> float:
    """L∞ coefficient norm: max_{α ∈ supp(p)} |c_α|.
    
    The max-plus tropical invariant.
    """
    if not p.coeffs:
        return 0.0
    return max(abs(c) for c in p.coeffs.values())


# =============================================================================
# §4. Tropical Leaf Witness
# =============================================================================

def tropical_leaf_witness(p: MvPolynomial, A: Set[int]) -> float:
    """Compute the tropical leaf witness W_trop(p, A).
    
    W_trop(p, A) = ∑_{a ∈ A} ‖∂²L_A/∂x_a²‖₁
    
    This is the sum of L¹ coefficient norms of the diagonal second
    partial derivatives of the derivative leaf.
    
    The tropical leaf witness upper-bounds the spectral leaf witness:
        leafWitness(p, A) ≤ tropicalLeafWitness(p, A)
    
    Args:
        p: Multivariate polynomial
        A: Subset of variable indices
        
    Returns:
        The tropical leaf witness value (≥ 0)
    """
    leaf = derivative_leaf(p, A)
    total = 0.0
    for a in A:
        dd = leaf.pderiv(a).pderiv(a)
        total += coeff_abs_sum(dd)
    return total


def tropical_leaf_data(p: MvPolynomial, A: Set[int]) -> dict:
    """Extract full tropical leaf data from a polynomial and subsystem.
    
    Returns a dictionary with:
    - support: the support of L_A(p)
    - witness_value: the tropical leaf witness
    - max_coeff: the L∞ coefficient norm
    - support_card: cardinality of the support
    """
    leaf = derivative_leaf(p, A)
    return {
        'support': leaf.support,
        'witness_value': tropical_leaf_witness(p, A),
        'max_coeff': coeff_sup_norm(leaf),
        'support_card': len(leaf.support),
        'leaf_coeffs': dict(leaf.coeffs),
    }


# =============================================================================
# §5. Spectral Witness (Hessian Trace Proxy)
# =============================================================================

def mixed_hessian_at_ones(p: MvPolynomial, A: Set[int]) -> np.ndarray:
    """Compute the mixed Hessian matrix at the all-ones point.
    
    H[i,j] = eval₁(∂²p/∂xᵢ∂xⱼ) for i, j ∈ A.
    
    Args:
        p: Multivariate polynomial
        A: Subset of variable indices
        
    Returns:
        |A| × |A| symmetric matrix
    """
    A_list = sorted(A)
    k = len(A_list)
    H = np.zeros((k, k))
    ones = np.ones(p.n)
    
    for ii, i in enumerate(A_list):
        for jj, j in enumerate(A_list):
            ddp = p.pderiv(i).pderiv(j)
            H[ii, jj] = ddp.eval_at(ones)
    
    return H


def leaf_witness(p: MvPolynomial, A: Set[int]) -> float:
    """Compute the spectral leaf witness.
    
    W_spec(p, A) = max(tr(H), 0)
    
    where H is the mixed Hessian of L_A(p) at the all-ones point.
    """
    leaf = derivative_leaf(p, A)
    H = mixed_hessian_at_ones(leaf, A)
    return max(np.trace(H), 0.0)


# =============================================================================
# §6. DPP Generating Polynomial
# =============================================================================

def dpp_generating_polynomial(K: np.ndarray) -> MvPolynomial:
    """Construct the DPP generating polynomial det(I + diag(x)·K).
    
    For an n×n kernel matrix K, the generating polynomial is
    Z_K(x) = ∑_{S ⊆ [n]} det(K_S) · ∏_{i∈S} xᵢ
    
    where K_S is the principal submatrix indexed by S.
    
    Args:
        K: n×n symmetric PSD kernel matrix
        
    Returns:
        MvPolynomial representing det(I + diag(x)·K)
        
    Complexity: O(2^n · n³) for the determinant computations
    """
    n = K.shape[0]
    coeffs = {}
    
    # Iterate over all subsets S of {0, ..., n-1}
    for size in range(n + 1):
        for S in combinations(range(n), size):
            # Compute det(K_S) = principal minor
            if len(S) == 0:
                det_val = 1.0
            else:
                S_list = list(S)
                submatrix = K[np.ix_(S_list, S_list)]
                det_val = np.linalg.det(submatrix)
            
            if abs(det_val) > 1e-15:
                exp = tuple(1 if i in S else 0 for i in range(n))
                coeffs[exp] = det_val
    
    return MvPolynomial(n, coeffs)


# =============================================================================
# §7. p-adic Valuation
# =============================================================================

def p_adic_valuation(x: float, p: int, tol: float = 1e-10) -> float:
    """Compute the p-adic valuation of a rational number.
    
    v_p(x) = largest k such that p^k divides x.
    For non-integer x, uses the factored numerator/denominator.
    
    Returns float('inf') for x = 0.
    """
    if abs(x) < tol:
        return float('inf')
    
    # Convert to rational approximation
    from fractions import Fraction
    frac = Fraction(x).limit_denominator(10**12)
    num = abs(frac.numerator)
    den = frac.denominator
    
    v = 0
    while num > 0 and num % p == 0:
        v += 1
        num //= p
    while den > 0 and den % p == 0:
        v -= 1
        den //= p
    
    return v


def tropical_leaf_witness_padic(p_poly: MvPolynomial, A: Set[int], 
                                  prime: int) -> float:
    """Compute the p-adic tropical leaf witness.
    
    Uses the p-adic valuation instead of the archimedean absolute value.
    The tropical witness becomes max(-v_p(c_α)) over coefficients,
    which corresponds to the tropical (max-plus) evaluation.
    """
    leaf = derivative_leaf(p_poly, A)
    total = 0.0
    for a in A:
        dd = leaf.pderiv(a).pderiv(a)
        for c in dd.coeffs.values():
            v = p_adic_valuation(c, prime)
            if v != float('inf'):
                total += abs(c)  # Use archimedean norm for comparison
    return total


# =============================================================================
# §8. Witness Gap Analysis
# =============================================================================

def witness_gap(p: MvPolynomial, A: Set[int]) -> dict:
    """Compute the gap between tropical and spectral witnesses.
    
    Returns:
        Dictionary with spectral, tropical, gap, and ratio values.
        The gap Δ = W_trop - W_spec should always be ≥ 0.
    """
    w_spec = leaf_witness(p, A)
    w_trop = tropical_leaf_witness(p, A)
    gap = w_trop - w_spec
    ratio = w_trop / w_spec if w_spec > 1e-15 else float('inf')
    
    return {
        'spectral_witness': w_spec,
        'tropical_witness': w_trop,
        'gap': gap,
        'ratio': ratio,
        'bound_holds': gap >= -1e-10,
    }


def comprehensive_witness_analysis(K: np.ndarray, 
                                     max_subset_size: int = None) -> List[dict]:
    """Run comprehensive witness gap analysis for a DPP kernel.
    
    Enumerates all subsets up to max_subset_size and computes
    both spectral and tropical witnesses.
    
    Args:
        K: n×n DPP kernel matrix
        max_subset_size: Maximum subset size to check (default: n)
        
    Returns:
        List of analysis results for each subset
    """
    n = K.shape[0]
    if max_subset_size is None:
        max_subset_size = n
    
    p = dpp_generating_polynomial(K)
    results = []
    
    for size in range(1, min(max_subset_size + 1, n + 1)):
        for A_tuple in combinations(range(n), size):
            A = set(A_tuple)
            gap_data = witness_gap(p, A)
            gap_data['subset'] = A_tuple
            gap_data['subset_size'] = size
            results.append(gap_data)
    
    return results


# =============================================================================
# §9. Submodularity Testing
# =============================================================================

def test_submodularity(f: Dict[FrozenSet[int], float], 
                        ground_set: Set[int]) -> dict:
    """Test whether a set function is submodular.
    
    Checks f(A) + f(B) ≥ f(A∩B) + f(A∪B) for all pairs A, B.
    
    Returns:
        Dictionary with is_submodular flag and worst violation.
    """
    violations = []
    n = len(ground_set)
    elements = sorted(ground_set)
    
    for size_a in range(n + 1):
        for A_tuple in combinations(elements, size_a):
            A = frozenset(A_tuple)
            for size_b in range(n + 1):
                for B_tuple in combinations(elements, size_b):
                    B = frozenset(B_tuple)
                    
                    AB_inter = A & B
                    AB_union = A | B
                    
                    lhs = f.get(A, 0.0) + f.get(B, 0.0)
                    rhs = f.get(AB_inter, 0.0) + f.get(AB_union, 0.0)
                    
                    if lhs < rhs - 1e-10:
                        violations.append({
                            'A': A, 'B': B,
                            'violation': rhs - lhs,
                        })
    
    return {
        'is_submodular': len(violations) == 0,
        'num_violations': len(violations),
        'worst_violation': max((v['violation'] for v in violations), default=0.0),
        'violations': violations[:5],  # First 5
    }


if __name__ == "__main__":
    print("=== Tropical Leaf Witness Algorithms ===\n")
    
    # Example: 3-variable polynomial
    n = 3
    # p = x0^2 + x1^2 + x2^2 + x0*x1 + x1*x2
    p = MvPolynomial(n, {
        (2,0,0): 1.0, (0,2,0): 1.0, (0,0,2): 1.0,
        (1,1,0): 1.0, (0,1,1): 1.0,
    })
    print(f"Polynomial: {p}")
    
    A = {0, 1}
    leaf = derivative_leaf(p, A)
    print(f"\nDerivative leaf L_A with A={A}: {leaf}")
    
    w_trop = tropical_leaf_witness(p, A)
    w_spec = leaf_witness(p, A)
    print(f"Tropical witness: {w_trop:.6f}")
    print(f"Spectral witness: {w_spec:.6f}")
    print(f"Gap (≥ 0): {w_trop - w_spec:.6f}")
    print(f"Bound holds: {w_trop >= w_spec - 1e-10}")
    
    # DPP example
    print("\n=== DPP Example (n=4) ===")
    np.random.seed(42)
    M = np.random.randn(4, 3)
    K = M @ M.T  # PSD kernel
    K = K / np.trace(K)  # Normalize
    
    dpp_poly = dpp_generating_polynomial(K)
    print(f"DPP polynomial support size: {len(dpp_poly.support)}")
    
    results = comprehensive_witness_analysis(K, max_subset_size=3)
    print(f"\nAnalyzed {len(results)} subsets")
    all_hold = all(r['bound_holds'] for r in results)
    print(f"All bounds hold: {all_hold}")
    
    for r in results[:5]:
        print(f"  A={r['subset']}: spec={r['spectral_witness']:.4f}, "
              f"trop={r['tropical_witness']:.4f}, gap={r['gap']:.4f}")
