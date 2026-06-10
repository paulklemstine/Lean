#!/usr/bin/env python3
"""
algorithms.py — Algorithms for Valuated M-Convex Exchange Analysis

Implements:
1. ValuatedExchangeChecker: verify exchange property with optimal K
2. DerivativeTransportAnalyzer: compute transport constants under differentiation
3. LogConcavityVerifier: check reversed log-concavity on exchange slices
"""

from itertools import combinations
from typing import Dict, Tuple, List, Optional, Set
import math


# ─── Core Types ────────────────────────────────────────────────────────────

Exponent = Tuple[int, ...]
Polynomial = Dict[Exponent, float]


# ─── Algorithm 1: Valuated Exchange Checker ────────────────────────────────

class ValuatedExchangeChecker:
    """
    Check the valuated exchange property for a polynomial.

    Given p with support S and coefficients c, verifies:
      ∀ a,b ∈ S, ∀ i with b_i < a_i:
        ∃ j with a_j < b_j such that
          c(a)·c(b) ≤ K · c(a')·c(b')
    where a' = a - e_i + e_j, b' = b + e_i - e_j.

    Time complexity: O(|S|² · n²) where n = number of variables
    Space complexity: O(|S|)
    """

    def __init__(self, poly: Polynomial):
        """Initialize with a polynomial (dict: exponent -> coefficient)."""
        self.poly = {k: v for k, v in poly.items() if abs(v) > 1e-15}
        self.support = list(self.poly.keys())
        self.n = len(self.support[0]) if self.support else 0

    def exchange_down(self, a: Exponent, i: int, j: int) -> Optional[Exponent]:
        """Compute a - e_i + e_j, None if a[i] == 0."""
        if a[i] == 0:
            return None
        v = list(a)
        v[i] -= 1
        v[j] += 1
        return tuple(v)

    def exchange_up(self, b: Exponent, i: int, j: int) -> Optional[Exponent]:
        """Compute b + e_i - e_j, None if b[j] == 0."""
        if b[j] == 0:
            return None
        v = list(b)
        v[i] += 1
        v[j] -= 1
        return tuple(v)

    def check(self, K: float = 1.0) -> Tuple[bool, float, List[dict]]:
        """
        Check ValuatedExchange(p, K).

        Returns:
            (holds, optimal_K, violations)
            - holds: whether the property holds with constant K
            - optimal_K: minimal K for which it holds
            - violations: list of exchange squares where K is tight

        Pseudocode:
            optimal_K ← 0
            for each (a, b) in S × S:
                for each i with b[i] < a[i]:
                    best_ratio ← ∞
                    for each j with a[j] < b[j]:
                        a' ← exchange_down(a, i, j)
                        b' ← exchange_up(b, i, j)
                        if a' ∈ S and b' ∈ S:
                            ratio ← c(a)·c(b) / (c(a')·c(b'))
                            best_ratio ← min(best_ratio, ratio)
                    optimal_K ← max(optimal_K, best_ratio)
            return (optimal_K ≤ K, optimal_K)
        """
        optimal_K = 0.0
        violations = []

        for a in self.support:
            for b in self.support:
                for i in range(self.n):
                    if b[i] >= a[i]:
                        continue
                    best_ratio = float('inf')
                    best_witness = None
                    for j in range(self.n):
                        if a[j] >= b[j]:
                            continue
                        a_prime = self.exchange_down(a, i, j)
                        b_prime = self.exchange_up(b, i, j)
                        if a_prime is None or b_prime is None:
                            continue
                        if a_prime not in self.poly or b_prime not in self.poly:
                            continue
                        lhs = self.poly[a] * self.poly[b]
                        rhs = self.poly[a_prime] * self.poly[b_prime]
                        if abs(rhs) > 1e-15:
                            ratio = lhs / rhs
                            if ratio < best_ratio:
                                best_ratio = ratio
                                best_witness = (j, a_prime, b_prime, ratio)

                    if best_ratio != float('inf'):
                        optimal_K = max(optimal_K, best_ratio)
                        if best_ratio > K + 1e-12:
                            violations.append({
                                'a': a, 'b': b, 'i': i,
                                'witness': best_witness,
                                'ratio': best_ratio
                            })

        return (optimal_K <= K + 1e-12, optimal_K, violations)


# ─── Algorithm 2: Derivative Transport Analyzer ───────────────────────────

class DerivativeTransportAnalyzer:
    """
    Analyze how the valuated exchange constant transforms under differentiation.

    Uses the coefficient transport identity:
        coeff_m(∂_i p) = (m_i + 1) · coeff_{m + e_i}(p)

    to predict the derivative exchange constant from the original.

    Time complexity: O(|S| · n) for derivative computation +
                     O(|S'|² · n²) for exchange checking
    """

    def __init__(self, poly: Polynomial):
        self.poly = {k: v for k, v in poly.items() if abs(v) > 1e-15}
        self.n = len(list(self.poly.keys())[0]) if self.poly else 0

    def partial_derivative(self, var: int) -> Polynomial:
        """Compute ∂_{var} p using the coefficient transport identity."""
        result: Polynomial = {}
        for exp, coeff in self.poly.items():
            if exp[var] > 0:
                new_exp = list(exp)
                new_exp[var] -= 1
                new_exp_t = tuple(new_exp)
                c = coeff * exp[var]
                result[new_exp_t] = result.get(new_exp_t, 0.0) + c
        return {k: v for k, v in result.items() if abs(v) > 1e-15}

    def analyze_transport(self) -> Dict[int, dict]:
        """
        For each variable, compute derivative and check exchange property.

        Returns dict: var -> {
            'derivative': Polynomial,
            'optimal_K': float,
            'holds_K1': bool,
            'rescaling_bound': float  # theoretical upper bound
        }
        """
        results = {}
        # First check original
        checker = ValuatedExchangeChecker(self.poly)
        _, orig_K, _ = checker.check()

        for var in range(self.n):
            dp = self.partial_derivative(var)
            if not dp:
                results[var] = {
                    'derivative': dp,
                    'optimal_K': 0.0,
                    'holds_K1': True,
                    'original_K': orig_K,
                }
                continue

            dp_checker = ValuatedExchangeChecker(dp)
            _, dp_K, _ = dp_checker.check()

            results[var] = {
                'derivative': dp,
                'optimal_K': dp_K,
                'holds_K1': dp_K <= 1.0 + 1e-12,
                'original_K': orig_K,
            }

        return results


# ─── Algorithm 3: Log-Concavity Verifier ──────────────────────────────────

class LogConcavityVerifier:
    """
    Verify the reversed log-concavity consequence of valuated exchange.

    For each m in support and pair (i,j), checks:
        c(m + e_i - e_j) · c(m - e_i + e_j) ≤ K · c(m)²

    This is the Lorentzian signature condition on exchange slices.
    """

    def __init__(self, poly: Polynomial):
        self.poly = {k: v for k, v in poly.items() if abs(v) > 1e-15}
        self.support = set(self.poly.keys())
        self.n = len(list(self.poly.keys())[0]) if self.poly else 0

    def check_slice_logconcavity(self, K: float = 1.0) -> Tuple[bool, float, List[dict]]:
        """
        Check reversed log-concavity on all exchange slices.

        Returns (holds, optimal_K, tight_cases).
        """
        optimal_K = 0.0
        tight_cases = []

        for m in self.support:
            for i in range(self.n):
                for j in range(self.n):
                    if i == j:
                        continue
                    if m[i] == 0 or m[j] == 0:
                        continue
                    # m + e_i - e_j
                    plus = list(m)
                    plus[i] += 1
                    plus[j] -= 1
                    plus_t = tuple(plus)
                    # m - e_i + e_j
                    minus = list(m)
                    minus[i] -= 1
                    minus[j] += 1
                    minus_t = tuple(minus)

                    if plus_t not in self.support or minus_t not in self.support:
                        continue

                    lhs = self.poly[plus_t] * self.poly[minus_t]
                    rhs = self.poly[m] ** 2

                    if abs(rhs) > 1e-15:
                        ratio = lhs / rhs
                        optimal_K = max(optimal_K, ratio)
                        if ratio > K + 1e-12:
                            tight_cases.append({
                                'm': m, 'i': i, 'j': j,
                                'ratio': ratio
                            })

        return (optimal_K <= K + 1e-12, optimal_K, tight_cases)


# ─── Utility Functions ────────────────────────────────────────────────────

def basis_vectors(n: int, d: int) -> List[Exponent]:
    """Generate all d-element subset indicator vectors in {0,1}^n."""
    vecs = []
    for S in combinations(range(n), d):
        v = [0] * n
        for i in S:
            v[i] = 1
        vecs.append(tuple(v))
    return vecs

def weighted_uniform_poly(n: int, d: int, weights: List[float]) -> Polynomial:
    """Create weighted uniform matroid polynomial with given weights."""
    bases = basis_vectors(n, d)
    return {bases[i]: weights[i] for i in range(min(len(bases), len(weights)))
            if abs(weights[i]) > 1e-15}


# ─── Example Usage ────────────────────────────────────────────────────────

if __name__ == "__main__":
    import random
    random.seed(42)

    print("Algorithm 1: ValuatedExchangeChecker")
    print("-" * 50)
    # U(2,3) with equal weights
    p = weighted_uniform_poly(3, 2, [1.0, 1.0, 1.0])
    checker = ValuatedExchangeChecker(p)
    holds, opt_K, violations = checker.check(1.0)
    print(f"U(2,3) equal weights: holds={holds}, optimal K={opt_K:.4f}")

    # U(2,3) with unequal weights
    p2 = weighted_uniform_poly(3, 2, [1.0, 2.0, 3.0])
    checker2 = ValuatedExchangeChecker(p2)
    holds2, opt_K2, _ = checker2.check(1.0)
    print(f"U(2,3) weights [1,2,3]: holds={holds2}, optimal K={opt_K2:.4f}")

    print("\nAlgorithm 2: DerivativeTransportAnalyzer")
    print("-" * 50)
    analyzer = DerivativeTransportAnalyzer(p2)
    results = analyzer.analyze_transport()
    for var, info in results.items():
        print(f"∂_{var}: optimal K = {info['optimal_K']:.4f}, K=1 holds: {info['holds_K1']}")

    print("\nAlgorithm 3: LogConcavityVerifier")
    print("-" * 50)
    # Need a polynomial with richer support for meaningful log-concavity
    p3 = weighted_uniform_poly(4, 2, [1.0, 2.0, 1.5, 0.8, 1.2, 1.0])
    verifier = LogConcavityVerifier(p3)
    holds3, opt_K3, tight = verifier.check_slice_logconcavity(1.0)
    print(f"U(2,4) reversed log-concavity: holds={holds3}, optimal K={opt_K3:.4f}")
    if tight:
        print(f"  Tight cases: {len(tight)}")
        for tc in tight[:3]:
            print(f"    m={tc['m']}, i={tc['i']}, j={tc['j']}, ratio={tc['ratio']:.4f}")
