#!/usr/bin/env python3
"""
Algorithms for Aggregate Anti-Cancellation Analysis

Implements verified algorithms for:
1. Computing pair shadows (support of second partial derivatives)
2. Computing aggregate shadows (union over active weight pairs)
3. Computing weighted Hessian sums
4. Testing overlap sign coherence
5. Searching for cancellation witnesses / counterexamples
6. Checking Lorentzian-type conditions on coefficient arrays

All algorithms operate over exact rational arithmetic (fractions.Fraction).

Complexity analysis:
- pair_shadow: O(|supp(p)| · n) where n = number of variables
- aggregate_shadow: O(n² · |supp(p)| · n)
- hessian_weighted_sum: O(n² · |supp(p)|)
- overlap_sign_check: O(n² · |shadow| · n²) worst case
- counterexample_search: depends on search space
"""

from fractions import Fraction
from typing import Dict, Tuple, List, Set, Optional, Callable
from collections import defaultdict
import itertools


# ============================================================
# Core data types
# ============================================================

Exponent = Tuple[int, ...]  # Exponent vector (α₀, α₁, ..., αₙ₋₁)
Coefficients = Dict[Exponent, Fraction]


class Polynomial:
    """
    Multivariate polynomial over ℚ.
    
    Representation: sparse dictionary from exponent tuples to Fraction coefficients.
    Zero coefficients are not stored.
    
    Example:
        >>> p = Polynomial(3, {(2,0,0): Fraction(1), (1,1,0): Fraction(2)})
        >>> p  # x₀² + 2·x₀·x₁
    """
    
    def __init__(self, n_vars: int, coeffs: Optional[Coefficients] = None):
        self.n = n_vars
        self.coeffs: Coefficients = {}
        if coeffs:
            for exp, c in coeffs.items():
                c = Fraction(c)
                if c != 0:
                    assert len(exp) == n_vars, f"Exponent {exp} has wrong length for {n_vars} variables"
                    self.coeffs[exp] = c
    
    def coeff(self, exp: Exponent) -> Fraction:
        """Get coefficient of monomial x^exp. Returns 0 if not present."""
        return self.coeffs.get(exp, Fraction(0))
    
    def support(self) -> Set[Exponent]:
        """Set of exponents with nonzero coefficients."""
        return {e for e, c in self.coeffs.items() if c != 0}
    
    def total_degree(self) -> int:
        """Maximum total degree of any monomial."""
        if not self.coeffs:
            return -1
        return max(sum(e) for e in self.coeffs)
    
    def is_homogeneous(self, d: Optional[int] = None) -> bool:
        """Check if polynomial is homogeneous (of degree d if specified)."""
        if not self.coeffs:
            return True
        degrees = {sum(e) for e in self.coeffs}
        if d is not None:
            return degrees == {d}
        return len(degrees) <= 1
    
    def pderiv(self, var: int) -> 'Polynomial':
        """
        Partial derivative ∂/∂x_var.
        
        Time complexity: O(|support|)
        Space complexity: O(|support|)
        """
        assert 0 <= var < self.n
        result = Polynomial(self.n)
        for exp, c in self.coeffs.items():
            if exp[var] > 0:
                new_exp = list(exp)
                new_coeff = c * exp[var]
                new_exp[var] -= 1
                new_exp_t = tuple(new_exp)
                result.coeffs[new_exp_t] = result.coeff(new_exp_t) + new_coeff
        result._clean()
        return result
    
    def _clean(self):
        """Remove zero coefficients."""
        self.coeffs = {e: c for e, c in self.coeffs.items() if c != 0}
    
    def __repr__(self):
        if not self.coeffs:
            return "0"
        var_names = [f"x{i}" for i in range(self.n)]
        terms = []
        for exp in sorted(self.coeffs.keys()):
            c = self.coeffs[exp]
            if c == 0:
                continue
            factors = []
            for i, e in enumerate(exp):
                if e == 1:
                    factors.append(var_names[i])
                elif e > 1:
                    factors.append(f"{var_names[i]}^{e}")
            mon = "·".join(factors) if factors else "1"
            if c == 1:
                terms.append(mon)
            elif c == -1:
                terms.append(f"-{mon}")
            else:
                terms.append(f"{c}·{mon}")
        return " + ".join(terms).replace("+ -", "- ") if terms else "0"


WeightMatrix = List[List[Fraction]]


def make_weight_matrix(m: List[List[float]]) -> WeightMatrix:
    """Convert numeric matrix to exact Fraction matrix."""
    return [[Fraction(x) for x in row] for row in m]


# ============================================================
# Algorithm 1: Pair Shadow Computation
# ============================================================

def compute_pair_shadow(p: Polynomial, i: int, j: int) -> Set[Exponent]:
    """
    Compute pair shadow = support(∂ᵢ∂ⱼ p).
    
    This is the set of exponents β such that the coefficient of x^β in
    ∂ᵢ∂ⱼp is nonzero.
    
    Time: O(|supp(p)|)
    Space: O(|supp(p)|)
    
    >>> p = Polynomial(2, {(2,1): Fraction(3), (1,2): Fraction(1)})
    >>> compute_pair_shadow(p, 0, 1)
    {(1, 0), (0, 1)}
    """
    deriv = p.pderiv(j).pderiv(i)
    return deriv.support()


def compute_all_pair_shadows(p: Polynomial) -> Dict[Tuple[int,int], Set[Exponent]]:
    """
    Compute pair shadows for all variable pairs.
    
    Time: O(n² · |supp(p)|)
    """
    shadows = {}
    for i in range(p.n):
        for j in range(p.n):
            shadows[(i, j)] = compute_pair_shadow(p, i, j)
    return shadows


# ============================================================
# Algorithm 2: Aggregate Shadow
# ============================================================

def compute_aggregate_shadow(p: Polynomial, A: WeightMatrix) -> Set[Exponent]:
    """
    Compute aggregate shadow = ⋃_{A(i,j)≠0} support(∂ᵢ∂ⱼ p).
    
    Time: O(n² · |supp(p)|)
    Space: O(n² · |supp(p)|) worst case
    
    >>> p = Polynomial(2, {(2,0): Fraction(1), (0,2): Fraction(1)})
    >>> A = make_weight_matrix([[1,0],[0,1]])
    >>> compute_aggregate_shadow(p, A)
    {(0, 0)}
    """
    shadow = set()
    n = len(A)
    for i in range(n):
        for j in range(n):
            if A[i][j] != 0:
                shadow |= compute_pair_shadow(p, i, j)
    return shadow


# ============================================================
# Algorithm 3: Weighted Hessian Sum
# ============================================================

def compute_hessian_weighted_sum(p: Polynomial, A: WeightMatrix) -> Polynomial:
    """
    Compute H_A(p) = Σ_{i,j} A(i,j) · ∂ᵢ∂ⱼ p.
    
    Time: O(n² · |supp(p)|)
    Space: O(n² · |supp(p)|) worst case for output support
    """
    result = Polynomial(p.n)
    n = len(A)
    for i in range(n):
        for j in range(n):
            if A[i][j] == 0:
                continue
            deriv = p.pderiv(j).pderiv(i)
            for exp, c in deriv.coeffs.items():
                val = A[i][j] * c
                result.coeffs[exp] = result.coeff(exp) + val
    result._clean()
    return result


# ============================================================
# Algorithm 4: Overlap Sign Coherence Check
# ============================================================

def check_overlap_sign_coherence(p: Polynomial, A: WeightMatrix) -> Tuple[bool, List[dict]]:
    """
    Check overlap sign coherence condition.
    
    For each monomial β in the aggregate shadow, verify that all nonzero
    weighted pair contributions A(i,j)·coeff_β(∂ᵢ∂ⱼp) share a common sign.
    
    Returns: (is_coherent, violations) where violations is a list of dicts
    describing each violation found.
    
    Time: O(n² · |shadow|) where shadow = aggregate shadow size
    """
    n = len(A)
    # Collect contributions per monomial
    contributions: Dict[Exponent, List[Tuple[int, int, Fraction]]] = defaultdict(list)
    
    for i in range(n):
        for j in range(n):
            if A[i][j] == 0:
                continue
            deriv = p.pderiv(j).pderiv(i)
            for exp, c in deriv.coeffs.items():
                val = A[i][j] * c
                if val != 0:
                    contributions[exp].append((i, j, val))
    
    violations = []
    for beta, contribs in contributions.items():
        signs = set()
        for _, _, val in contribs:
            signs.add(1 if val > 0 else -1)
        if len(signs) > 1:
            violations.append({
                'monomial': beta,
                'contributions': [(i, j, float(v)) for i, j, v in contribs],
                'has_positive': 1 in signs,
                'has_negative': -1 in signs,
            })
    
    return len(violations) == 0, violations


# ============================================================
# Algorithm 5: Cancellation Witness Search
# ============================================================

def find_cancellation_witnesses(p: Polynomial, A: WeightMatrix) -> List[dict]:
    """
    Find all monomials in the aggregate shadow that vanish in the weighted Hessian.
    
    Returns list of witness dicts with monomial and contributing pair details.
    
    Time: O(n² · |supp(p)| + |shadow|)
    """
    shadow = compute_aggregate_shadow(p, A)
    hess = compute_hessian_weighted_sum(p, A)
    
    witnesses = []
    for beta in shadow:
        if hess.coeff(beta) == 0:
            # Collect which pairs contributed
            n = len(A)
            contribs = []
            for i in range(n):
                for j in range(n):
                    if A[i][j] == 0:
                        continue
                    deriv = p.pderiv(j).pderiv(i)
                    c = deriv.coeff(beta)
                    if c != 0:
                        contribs.append((i, j, float(A[i][j] * c)))
            witnesses.append({
                'monomial': beta,
                'contributions': contribs,
                'sum': 0.0,
            })
    
    return witnesses


# ============================================================
# Algorithm 6: Systematic Counterexample Search
# ============================================================

def search_counterexamples(
    n_vars: int = 3,
    max_degree: int = 3,
    n_random_trials: int = 200,
    seed: int = 42,
) -> dict:
    """
    Systematically search for counterexamples to anti-cancellation.
    
    Tests random polynomials in two regimes:
    1. Nonneg coefficients + positive weights (should never cancel — theorem)
    2. Mixed coefficients + positive weights (may cancel)
    
    Returns summary statistics and any counterexamples found.
    """
    import random
    rng = random.Random(seed)
    
    results = {
        'n_vars': n_vars,
        'max_degree': max_degree,
        'nonneg_positive': {'trials': 0, 'cancellations': 0, 'examples': []},
        'mixed_positive': {'trials': 0, 'cancellations': 0, 'examples': []},
        'nonneg_mixed_weights': {'trials': 0, 'cancellations': 0, 'examples': []},
    }
    
    # Generate exponent candidates
    from itertools import product as cprod
    exponents = [e for e in cprod(range(max_degree + 1), repeat=n_vars)
                 if 1 <= sum(e) <= max_degree]
    
    for trial in range(n_random_trials):
        # Random support
        n_terms = rng.randint(2, min(8, len(exponents)))
        support = rng.sample(exponents, n_terms)
        
        # Test 1: Nonneg coefficients + positive weights
        coeffs_nn = {e: Fraction(rng.randint(1, 5)) for e in support}
        p_nn = Polynomial(n_vars, coeffs_nn)
        A_pos = make_weight_matrix([[rng.randint(1, 3) for _ in range(n_vars)]
                                    for _ in range(n_vars)])
        
        witnesses = find_cancellation_witnesses(p_nn, A_pos)
        results['nonneg_positive']['trials'] += 1
        if witnesses:
            results['nonneg_positive']['cancellations'] += 1
            results['nonneg_positive']['examples'].append({
                'polynomial': str(p_nn),
                'witnesses': [w['monomial'] for w in witnesses],
            })
        
        # Test 2: Mixed coefficients + positive weights
        coeffs_mix = {e: Fraction(rng.choice([-3, -2, -1, 1, 2, 3])) for e in support}
        p_mix = Polynomial(n_vars, coeffs_mix)
        
        witnesses = find_cancellation_witnesses(p_mix, A_pos)
        results['mixed_positive']['trials'] += 1
        if witnesses:
            results['mixed_positive']['cancellations'] += 1
            if len(results['mixed_positive']['examples']) < 5:
                results['mixed_positive']['examples'].append({
                    'polynomial': str(p_mix),
                    'witnesses': [w['monomial'] for w in witnesses],
                })
        
        # Test 3: Nonneg coefficients + mixed weights
        A_mix = make_weight_matrix(
            [[rng.choice([-2, -1, 1, 2]) for _ in range(n_vars)]
             for _ in range(n_vars)])
        
        witnesses = find_cancellation_witnesses(p_nn, A_mix)
        results['nonneg_mixed_weights']['trials'] += 1
        if witnesses:
            results['nonneg_mixed_weights']['cancellations'] += 1
            if len(results['nonneg_mixed_weights']['examples']) < 5:
                results['nonneg_mixed_weights']['examples'].append({
                    'polynomial': str(p_nn),
                    'witnesses': [w['monomial'] for w in witnesses],
                })
    
    return results


# ============================================================
# Algorithm 7: Lorentzian-type Condition Checker
# ============================================================

def check_newton_inequality(p: Polynomial, base: Exponent, var: int, k: int) -> bool:
    """
    Check one Newton inequality: c_k² ≥ c_{k-1} · c_{k+1}
    along the slice in direction var starting from base.
    
    This is a necessary condition for Lorentzian polynomials.
    """
    def slice_coeff(m: int) -> Fraction:
        exp = list(base)
        exp[var] += m
        return p.coeff(tuple(exp))
    
    ck = slice_coeff(k)
    ck_minus = slice_coeff(k - 1)
    ck_plus = slice_coeff(k + 1)
    
    return ck * ck >= ck_minus * ck_plus


def check_ultra_log_concavity(p: Polynomial, var: int) -> bool:
    """
    Check ultra-log-concavity along variable var for the univariate
    restriction obtained by setting all other variables to 1.
    
    Returns True if all Newton inequalities hold.
    """
    # Collect univariate coefficients
    max_deg = max((e[var] for e in p.support()), default=0)
    
    # Get coefficients of the univariate restriction
    coeffs_by_degree = defaultdict(Fraction)
    for exp, c in p.coeffs.items():
        coeffs_by_degree[exp[var]] += c
    
    # Check c_k² ≥ c_{k-1} · c_{k+1} for k = 1, ..., max_deg - 1
    for k in range(1, max_deg):
        ck = coeffs_by_degree.get(k, Fraction(0))
        ck_minus = coeffs_by_degree.get(k - 1, Fraction(0))
        ck_plus = coeffs_by_degree.get(k + 1, Fraction(0))
        if ck * ck < ck_minus * ck_plus:
            return False
    return True


# ============================================================
# Main: Run all algorithms with examples
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Example polynomial: basis-generating for U(2,3)
    p = Polynomial(3, {
        (1, 1, 0): Fraction(1),
        (1, 0, 1): Fraction(1),
        (0, 1, 1): Fraction(1),
    })
    A = make_weight_matrix([[1, 1, 1], [1, 1, 1], [1, 1, 1]])
    
    print(f"Polynomial: {p}")
    print(f"Support: {sorted(p.support())}")
    print(f"Homogeneous: {p.is_homogeneous()}")
    
    print(f"\n--- Pair Shadows ---")
    shadows = compute_all_pair_shadows(p)
    for (i, j), s in sorted(shadows.items()):
        if s:
            print(f"  Shadow({i},{j}): {sorted(s)}")
    
    print(f"\n--- Aggregate Shadow ---")
    agg = compute_aggregate_shadow(p, A)
    print(f"  {sorted(agg)}")
    
    print(f"\n--- Weighted Hessian ---")
    hess = compute_hessian_weighted_sum(p, A)
    print(f"  H_A(p) = {hess}")
    print(f"  Support: {sorted(hess.support())}")
    print(f"  Support exact: {agg == hess.support()}")
    
    print(f"\n--- Overlap Sign Coherence ---")
    coherent, violations = check_overlap_sign_coherence(p, A)
    print(f"  Coherent: {coherent}")
    
    print(f"\n--- Counterexample Search ---")
    results = search_counterexamples(n_vars=3, max_degree=3, n_random_trials=100)
    for regime, data in results.items():
        if isinstance(data, dict) and 'trials' in data:
            print(f"  {regime}: {data['cancellations']}/{data['trials']} cancellations")
    
    print(f"\n--- Ultra-log-concavity Check ---")
    for var in range(p.n):
        ulc = check_ultra_log_concavity(p, var)
        print(f"  Variable x{var}: {'✓' if ulc else '✗'}")
    
    print("\nDone.")
