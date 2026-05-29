#!/usr/bin/env python3
"""
Algorithms for Valuated M-Convex Exchange Analysis

Implements algorithms for:
1. Computing minimal exchange constants
2. Checking valuated exchange properties
3. Derivative transport analysis
4. Log-concavity verification along exchange rays

All algorithms use exact rational arithmetic for mathematical correctness.
"""

import itertools
from fractions import Fraction
from typing import Dict, Tuple, List, Optional, Set

Exponent = Tuple[int, ...]
CoeffMap = Dict[Exponent, Fraction]


class ValuatedExchangeChecker:
    """Algorithm for checking and analyzing the valuated M-convex exchange property.
    
    Given a polynomial represented as a coefficient map, this class provides
    methods to:
    - Check if ValuatedExchange(p, K) holds
    - Compute the minimal K
    - Analyze exchange configurations
    - Verify log-concavity along exchange rays
    
    Time complexity:
        check_exchange: O(|supp|^2 * n^2) where n = number of variables
        minimal_K: O(|supp|^2 * n^2)
        
    Space complexity: O(|supp|)
    """
    
    def __init__(self, poly: CoeffMap, n: int):
        """Initialize with a polynomial and number of variables.
        
        Args:
            poly: Dictionary mapping exponent tuples to coefficients
            n: Number of variables
        """
        self.poly = {k: v for k, v in poly.items() if v != 0}
        self.n = n
        self.support = list(self.poly.keys())
    
    def coeff(self, exp: Exponent) -> Fraction:
        """Get coefficient of exponent vector."""
        return self.poly.get(exp, Fraction(0))
    
    @staticmethod
    def exchange_down(a: Exponent, i: int, j: int) -> Optional[Exponent]:
        """Compute a - e_i + e_j (decrease i, increase j)."""
        if a[i] < 1:
            return None
        result = list(a)
        result[i] -= 1
        result[j] += 1
        return tuple(result)
    
    @staticmethod
    def exchange_up(b: Exponent, i: int, j: int) -> Optional[Exponent]:
        """Compute b + e_i - e_j (increase i, decrease j)."""
        if b[j] < 1:
            return None
        result = list(b)
        result[i] += 1
        result[j] -= 1
        return tuple(result)
    
    def check_exchange(self, K: Fraction) -> Tuple[bool, List[dict]]:
        """Check if ValuatedExchange(p, K) holds.
        
        Algorithm:
            For each pair (a, b) in support × support:
                For each coordinate i with b_i < a_i:
                    Search for exchange witness j with a_j < b_j
                    such that the four-point inequality holds.
        
        Args:
            K: Exchange constant
            
        Returns:
            (success, violations) where violations is a list of
            dicts describing any failed exchange configurations.
        """
        violations = []
        
        for a in self.support:
            for b in self.support:
                for i in range(self.n):
                    if b[i] >= a[i]:
                        continue
                    
                    found_witness = False
                    for j in range(self.n):
                        if a[j] >= b[j]:
                            continue
                        
                        a_prime = self.exchange_down(a, i, j)
                        b_prime = self.exchange_up(b, i, j)
                        
                        if a_prime is None or b_prime is None:
                            continue
                        
                        ca = self.coeff(a)
                        cb = self.coeff(b)
                        ca_prime = self.coeff(a_prime)
                        cb_prime = self.coeff(b_prime)
                        
                        if ca_prime != 0 and cb_prime != 0:
                            if ca * cb <= K * ca_prime * cb_prime:
                                found_witness = True
                                break
                    
                    if not found_witness:
                        violations.append({
                            'a': a, 'b': b, 'coord': i,
                            'ca': self.coeff(a), 'cb': self.coeff(b)
                        })
                        return False, violations
        
        return True, violations
    
    def minimal_K(self) -> Fraction:
        """Compute the minimal exchange constant K.
        
        Algorithm:
            For each exchange configuration (a, b, i), compute the minimum
            ratio ca*cb / (ca'*cb') over all valid witnesses j.
            Return the maximum such minimum ratio.
        
        Time: O(|supp|^2 * n^2)
        
        Returns:
            Minimal K such that ValuatedExchange(p, K) holds,
            or Fraction(0) if no non-trivial exchange configurations exist.
        """
        max_ratio = Fraction(0)
        
        for a in self.support:
            for b in self.support:
                for i in range(self.n):
                    if b[i] >= a[i]:
                        continue
                    
                    best_ratio_for_config = None
                    
                    for j in range(self.n):
                        if a[j] >= b[j]:
                            continue
                        
                        a_prime = self.exchange_down(a, i, j)
                        b_prime = self.exchange_up(b, i, j)
                        
                        if a_prime is None or b_prime is None:
                            continue
                        
                        ca_prime = self.coeff(a_prime)
                        cb_prime = self.coeff(b_prime)
                        
                        if ca_prime != 0 and cb_prime != 0:
                            ca = self.coeff(a)
                            cb = self.coeff(b)
                            ratio = (ca * cb) / (ca_prime * cb_prime)
                            if best_ratio_for_config is None or ratio < best_ratio_for_config:
                                best_ratio_for_config = ratio
                    
                    if best_ratio_for_config is not None:
                        max_ratio = max(max_ratio, best_ratio_for_config)
        
        return max_ratio
    
    def exchange_configurations(self) -> List[dict]:
        """Enumerate all exchange configurations with their ratios.
        
        Returns a list of dicts, each containing:
            a, b: exponent vectors
            i: coordinate with b_i < a_i
            witnesses: list of (j, a', b', ratio) for each valid witness
        """
        configs = []
        
        for a in self.support:
            for b in self.support:
                for i in range(self.n):
                    if b[i] >= a[i]:
                        continue
                    
                    witnesses = []
                    for j in range(self.n):
                        if a[j] >= b[j]:
                            continue
                        
                        a_prime = self.exchange_down(a, i, j)
                        b_prime = self.exchange_up(b, i, j)
                        
                        if a_prime is None or b_prime is None:
                            continue
                        
                        ca = self.coeff(a)
                        cb = self.coeff(b)
                        ca_prime = self.coeff(a_prime)
                        cb_prime = self.coeff(b_prime)
                        
                        if ca_prime != 0 and cb_prime != 0:
                            ratio = (ca * cb) / (ca_prime * cb_prime)
                            witnesses.append({
                                'j': j,
                                'a_prime': a_prime,
                                'b_prime': b_prime,
                                'ratio': ratio
                            })
                    
                    if witnesses:
                        configs.append({
                            'a': a, 'b': b, 'i': i,
                            'witnesses': witnesses
                        })
        
        return configs
    
    def check_slice_logconcavity(self, i: int, j: int) -> List[dict]:
        """Check log-concavity along the (i,j)-exchange ray.
        
        For each exponent m in the support with m_i ≥ 1 and m_j ≥ 1,
        check whether:
            coeff(m)^2 ≤ K * coeff(m - e_i + e_j) * coeff(m + e_i - e_j)
            
        This is the slice log-concavity condition that bridges valuated
        exchange to Lorentzian polynomial theory.
        
        Args:
            i, j: Coordinate pair defining the exchange ray
            
        Returns:
            List of dicts with exponent, LHS, RHS, and whether inequality holds
        """
        results = []
        
        for m in self.support:
            if m[i] < 1 or m[j] < 1:
                continue
            
            cm = self.coeff(m)
            
            m_down = self.exchange_down(m, i, j)
            m_up = self.exchange_up(m, i, j)
            
            if m_down is None or m_up is None:
                continue
            
            c_down = self.coeff(m_down)
            c_up = self.coeff(m_up)
            
            lhs = cm * cm
            rhs = c_down * c_up
            
            results.append({
                'exponent': m,
                'coeff': cm,
                'coeff_down': c_down,
                'coeff_up': c_up,
                'lhs': lhs,
                'rhs': rhs,
                'logconcave': lhs <= rhs if rhs > 0 else (lhs == 0)
            })
        
        return results


def partial_derivative(poly: CoeffMap, var: int, n: int) -> CoeffMap:
    """Compute partial derivative using coefficient transport.
    
    Uses the identity: coeff_m(∂_i p) = (m_i + 1) * coeff_{m+e_i}(p)
    
    Time: O(|supp|)
    Space: O(|supp|)
    """
    result: CoeffMap = {}
    for exp, coeff in poly.items():
        if exp[var] > 0:
            new_exp = list(exp)
            new_exp[var] -= 1
            new_exp = tuple(new_exp)
            factor = Fraction(exp[var])
            if new_exp in result:
                result[new_exp] += coeff * factor
            else:
                result[new_exp] = coeff * factor
    return {k: v for k, v in result.items() if v != 0}


def derivative_transport_analysis(poly: CoeffMap, n: int) -> dict:
    """Analyze how exchange constants transform under all partial derivatives.
    
    Algorithm:
        1. Compute minimal K for the original polynomial.
        2. For each variable i, compute ∂_i p and its minimal K.
        3. Report the scaling ratio K(∂_i p) / K(p).
    
    Returns:
        Dictionary with original K, derivative K values, and scaling ratios.
    """
    checker = ValuatedExchangeChecker(poly, n)
    K_orig = checker.minimal_K()
    
    results = {'K_original': K_orig, 'derivatives': []}
    
    for var in range(n):
        dp = partial_derivative(poly, var, n)
        dp_checker = ValuatedExchangeChecker(dp, n)
        K_deriv = dp_checker.minimal_K()
        
        ratio = float(K_deriv / K_orig) if K_orig > 0 else 0.0
        
        results['derivatives'].append({
            'variable': var,
            'K_derivative': K_deriv,
            'ratio': ratio,
            'preserves_K1': K_deriv <= Fraction(1)
        })
    
    return results


def uniform_matroid_poly(n: int, d: int, 
                          weights: Optional[Dict[Tuple[int,...], Fraction]] = None) -> CoeffMap:
    """Construct weighted uniform matroid basis-generating polynomial."""
    poly: CoeffMap = {}
    for subset in itertools.combinations(range(n), d):
        exp = tuple(1 if i in subset else 0 for i in range(n))
        w = weights.get(subset, Fraction(1)) if weights else Fraction(1)
        poly[exp] = w
    return poly


if __name__ == "__main__":
    print("Valuated Exchange Algorithm Demonstration")
    print("=" * 50)
    
    # Example: U(2,4) with random weights
    n, d = 4, 2
    weights = {
        (0, 1): Fraction(3), (0, 2): Fraction(2), (0, 3): Fraction(5),
        (1, 2): Fraction(7), (1, 3): Fraction(4), (2, 3): Fraction(1)
    }
    
    poly = uniform_matroid_poly(n, d, weights)
    checker = ValuatedExchangeChecker(poly, n)
    
    print(f"\nPolynomial: U({d},{n}) with weights")
    for exp, c in sorted(poly.items()):
        print(f"  coeff{exp} = {c}")
    
    K_min = checker.minimal_K()
    print(f"\nMinimal exchange constant K = {K_min} = {float(K_min):.4f}")
    
    ok, _ = checker.check_exchange(K_min)
    print(f"ValuatedExchange(p, {K_min}): {ok}")
    
    # Exchange configurations
    configs = checker.exchange_configurations()
    print(f"\nTotal exchange configurations: {len(configs)}")
    
    # Derivative transport analysis
    analysis = derivative_transport_analysis(poly, n)
    print(f"\nDerivative transport analysis:")
    for d_info in analysis['derivatives']:
        print(f"  ∂/∂x{d_info['variable']}: K = {d_info['K_derivative']}, "
              f"ratio = {d_info['ratio']:.4f}, "
              f"preserves K=1: {d_info['preserves_K1']}")
    
    # Slice log-concavity
    print(f"\nSlice log-concavity along (0,1)-ray:")
    lc_results = checker.check_slice_logconcavity(0, 1)
    for r in lc_results:
        print(f"  exp={r['exponent']}: {r['coeff']}² = {r['lhs']} "
              f"{'≤' if r['logconcave'] else '>'} "
              f"{r['coeff_down']}·{r['coeff_up']} = {r['rhs']}")
