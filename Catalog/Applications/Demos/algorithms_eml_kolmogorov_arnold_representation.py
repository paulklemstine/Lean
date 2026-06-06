#!/usr/bin/env python3
"""
EML-KA Algorithms: Core implementations for EML-Kolmogorov-Arnold representations.

Type-hinted implementations of the mathematical objects formalized in Lean 4.
"""

import numpy as np
from typing import List, Tuple, Callable, Optional
from dataclasses import dataclass


@dataclass
class KADecomp:
    """A weighted Kolmogorov-Arnold decomposition for bivariate functions.
    
    Represents f(x,y) = Σ_q w_q * Φ_q(φ₁_q(x) + φ₂_q(y))
    
    Attributes:
        phi1: Inner functions for the first variable
        phi2: Inner functions for the second variable
        Phi: Outer functions
        w: Weights
    """
    phi1: List[Callable[[float], float]]
    phi2: List[Callable[[float], float]]
    Phi: List[Callable[[float], float]]
    w: List[float]
    
    @property
    def num_terms(self) -> int:
        return len(self.w)
    
    def eval(self, x: float, y: float) -> float:
        """Evaluate the KA decomposition at (x, y)."""
        return sum(
            w_q * Phi_q(phi1_q(x) + phi2_q(y))
            for w_q, Phi_q, phi1_q, phi2_q 
            in zip(self.w, self.Phi, self.phi1, self.phi2)
        )
    
    def eval_grid(self, xs: np.ndarray, ys: np.ndarray) -> np.ndarray:
        """Evaluate on a meshgrid."""
        X, Y = np.meshgrid(xs, ys)
        result = np.zeros_like(X)
        for w_q, Phi_q, phi1_q, phi2_q in zip(self.w, self.Phi, self.phi1, self.phi2):
            inner = np.vectorize(phi1_q)(X) + np.vectorize(phi2_q)(Y)
            result += w_q * np.vectorize(Phi_q)(inner)
        return result


def rpow_monomial_ka(a: float, b: float) -> KADecomp:
    """Create 1-term EML-KA decomposition for x^a * y^b.
    
    Uses the identity: x^a * y^b = exp(a*log(x) + b*log(y))
    
    Args:
        a: Exponent for first variable
        b: Exponent for second variable
    
    Returns:
        KADecomp with inner functions a*log(·) and b*log(·), outer exp
    """
    return KADecomp(
        phi1=[lambda x, a=a: a * np.log(x)],
        phi2=[lambda y, b=b: b * np.log(y)],
        Phi=[np.exp],
        w=[1.0]
    )


def power_sum_ka(n: int) -> KADecomp:
    """Create 2-term EML-KA decomposition for x^n + y^n.
    
    Uses: x^n + y^n = exp(n*log(x)) + exp(n*log(y))
    
    Args:
        n: Power for the sum
    
    Returns:
        KADecomp with 2 terms
    """
    return KADecomp(
        phi1=[lambda x, n=n: float(n) * np.log(x), lambda _: 0.0],
        phi2=[lambda _: 0.0, lambda y, n=n: float(n) * np.log(y)],
        Phi=[np.exp, np.exp],
        w=[1.0, 1.0]
    )


def arith_mean_ka() -> KADecomp:
    """Create 2-term weighted EML-KA for (x+y)/2.
    
    Uses: (x+y)/2 = (1/2)*exp(log(x)) + (1/2)*exp(log(y))
    """
    return KADecomp(
        phi1=[np.log, lambda _: 0.0],
        phi2=[lambda _: 0.0, np.log],
        Phi=[np.exp, np.exp],
        w=[0.5, 0.5]
    )


def polynomial_ka(coeffs: List[float], 
                   exp_a: List[int], 
                   exp_b: List[int]) -> KADecomp:
    """Create M-term EML-KA for polynomial Σ c_i * x^a_i * y^b_i.
    
    Each monomial c_i * x^a_i * y^b_i becomes one EML-KA term:
    c_i * exp(a_i * log(x) + b_i * log(y))
    
    Args:
        coeffs: Polynomial coefficients
        exp_a: Exponents for x
        exp_b: Exponents for y
    
    Returns:
        KADecomp with len(coeffs) terms
    """
    return KADecomp(
        phi1=[lambda x, a=a: float(a) * np.log(x) for a in exp_a],
        phi2=[lambda y, b=b: float(b) * np.log(y) for b in exp_b],
        Phi=[np.exp for _ in coeffs],
        w=list(coeffs)
    )


def ka_exp_product(d1: KADecomp, d2: KADecomp) -> KADecomp:
    """Compute product of two 1-term exp-based KA decompositions.
    
    When both use exp as outer function with weight 1:
    exp(f1+g1) * exp(f2+g2) = exp((f1+f2) + (g1+g2))
    
    This demonstrates the multiplicative closure property.
    """
    assert d1.num_terms == 1 and d2.num_terms == 1
    phi1_1, phi1_2 = d1.phi1[0], d2.phi1[0]
    phi2_1, phi2_2 = d1.phi2[0], d2.phi2[0]
    return KADecomp(
        phi1=[lambda x: phi1_1(x) + phi1_2(x)],
        phi2=[lambda y: phi2_1(y) + phi2_2(y)],
        Phi=[np.exp],
        w=[1.0]
    )


def nvar_monomial_eval(xs: List[float], alphas: List[float]) -> float:
    """Evaluate n-variable monomial via EML: ∏ x_i^a_i = exp(Σ a_i * log(x_i))"""
    return np.exp(sum(a * np.log(x) for x, a in zip(xs, alphas)))


def log_sum_exp(a: float, b: float) -> float:
    """Numerically stable log-sum-exp (smooth max)."""
    m = max(a, b)
    return m + np.log(np.exp(a - m) + np.exp(b - m))


def renyi_power_sum_eml(alpha: float, p: float) -> float:
    """Rényi power sum via EML-KA: p^α + (1-p)^α = exp(α*log p) + exp(α*log(1-p))"""
    return np.exp(alpha * np.log(p)) + np.exp(alpha * np.log(1 - p))


def am_gm_gap(x: float, y: float) -> float:
    """Compute AM-GM gap: (x+y)/2 - sqrt(xy), always ≥ 0."""
    return (x + y) / 2 - np.exp((np.log(x) + np.log(y)) / 2)


def eml_ka_complexity(func_type: str) -> dict:
    """Return EML-KA complexity analysis for standard functions.
    
    Args:
        func_type: One of 'monomial', 'power_sum', 'polynomial', 'addition',
                  'multiplication', 'division'
    
    Returns:
        Dictionary with complexity info
    """
    info = {
        'monomial': {
            'terms': 1, 'depth': 2, 'description': 'x^a * y^b = exp(a*log(x) + b*log(y))',
            'barrier': False
        },
        'multiplication': {
            'terms': 1, 'depth': 2, 'description': 'x*y = exp(log(x) + log(y))',
            'barrier': False
        },
        'division': {
            'terms': 1, 'depth': 2, 'description': 'x/y = exp(log(x) - log(y))',
            'barrier': False
        },
        'power_sum': {
            'terms': 2, 'depth': 2, 'description': 'x^n + y^n requires 2 exp-of-log terms',
            'barrier': False
        },
        'addition': {
            'terms': 2, 'depth': 2, 'description': 'x+y = exp(log(x)) + exp(log(y))',
            'barrier': True, 'barrier_proof': 'Cannot be a single monomial c*x^a*y^b'
        },
        'polynomial': {
            'terms': 'M (number of monomials)', 'depth': 2,
            'description': 'Each monomial is one EML-KA term',
            'barrier': False
        }
    }
    return info.get(func_type, {'error': f'Unknown function type: {func_type}'})


if __name__ == "__main__":
    # Test all algorithms
    print("Testing EML-KA Algorithms...")
    
    # Test monomial
    d = rpow_monomial_ka(2.5, 1.3)
    x, y = 3.0, 2.0
    assert abs(d.eval(x, y) - x**2.5 * y**1.3) < 1e-10
    print("✓ rpow_monomial_ka")
    
    # Test power sum
    d = power_sum_ka(3)
    assert abs(d.eval(x, y) - (x**3 + y**3)) < 1e-10
    print("✓ power_sum_ka")
    
    # Test arithmetic mean
    d = arith_mean_ka()
    assert abs(d.eval(x, y) - (x+y)/2) < 1e-10
    print("✓ arith_mean_ka")
    
    # Test polynomial
    d = polynomial_ka([3, 2, 1], [2, 1, 1], [1, 3, 0])
    expected = 3*x**2*y + 2*x*y**3 + x
    assert abs(d.eval(x, y) - expected) < 1e-10
    print("✓ polynomial_ka")
    
    # Test n-variable
    result = nvar_monomial_eval([2.0, 3.0, 4.0], [1.0, 2.0, 0.5])
    expected = 2.0**1 * 3.0**2 * 4.0**0.5
    assert abs(result - expected) < 1e-10
    print("✓ nvar_monomial_eval")
    
    print("\nAll tests passed!")
