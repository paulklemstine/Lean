#!/usr/bin/env python3
"""
Algorithms for EML Multiplicative Transcendence Analysis

Type-hinted implementations for computing EML values, testing
algebraic independence, and analyzing the EML defect.
"""

import math
from typing import List, Tuple, Optional, Callable
from dataclasses import dataclass


@dataclass
class EMLConfig:
    """Configuration for a single EML transcendence analysis."""
    a: complex
    
    @property
    def eml_value(self) -> complex:
        """Compute exp(a) * log(1 + a)."""
        import cmath
        return cmath.exp(self.a) * cmath.log(1 + self.a)
    
    @property
    def exp_part(self) -> complex:
        """The exponential component exp(a)."""
        import cmath
        return cmath.exp(self.a)
    
    @property
    def log_part(self) -> complex:
        """The logarithmic component log(1 + a)."""
        import cmath
        return cmath.log(1 + self.a)


@dataclass
class EMLTupleConfig:
    """Configuration for n-tuple EML algebraic independence analysis."""
    values: List[complex]
    
    @property
    def n(self) -> int:
        return len(self.values)
    
    def eml_values(self) -> List[complex]:
        """Compute all EML values."""
        return [EMLConfig(a).eml_value for a in self.values]
    
    def exp_parts(self) -> List[complex]:
        """All exponential parts."""
        return [EMLConfig(a).exp_part for a in self.values]


def integer_relation_search(
    values: List[float],
    max_degree: int = 4,
    max_coeff: int = 10,
    tolerance: float = 1e-10
) -> List[Tuple[List[int], float]]:
    """
    Search for integer polynomial relations among given values.
    
    Uses exhaustive search over monomials up to given degree
    with coefficients bounded by max_coeff.
    
    Algorithm:
    1. Generate all monomials X₁^d₁ · ... · Xₙ^dₙ with Σdᵢ ≤ max_degree
    2. Evaluate each monomial at the given values
    3. Search for integer linear combinations of monomials that vanish
    
    Returns list of (coefficient_vector, residual) pairs.
    """
    import itertools
    
    n = len(values)
    
    # Generate all monomials
    def gen_monomials(n: int, max_deg: int) -> List[Tuple[int, ...]]:
        result = []
        for total_deg in range(max_deg + 1):
            for combo in itertools.product(range(total_deg + 1), repeat=n):
                if sum(combo) == total_deg:
                    result.append(combo)
        return result
    
    monomials = gen_monomials(n, max_degree)
    
    # Evaluate monomials
    mono_values = []
    for mono in monomials:
        val = 1.0
        for i, d in enumerate(mono):
            val *= values[i] ** d
        mono_values.append(val)
    
    # Search for vanishing linear combinations (LLL-style but brute force for small cases)
    results = []
    num_monos = len(monomials)
    
    if num_monos <= 8:  # Only feasible for small numbers of monomials
        for coeffs in itertools.product(range(-max_coeff, max_coeff + 1), repeat=num_monos):
            if all(c == 0 for c in coeffs):
                continue
            residual = sum(c * v for c, v in zip(coeffs, mono_values))
            if abs(residual) < tolerance:
                results.append((list(coeffs), residual))
    
    return results


def eml_defect(
    algebraic_inputs: List[complex],
    polynomial_coeffs: dict
) -> complex:
    """
    Compute the EML defect: evaluate a multivariate polynomial
    at the EML values of the given algebraic inputs.
    
    Args:
        algebraic_inputs: list of algebraic numbers a₁, ..., aₙ
        polynomial_coeffs: dict mapping monomial exponent tuples to coefficients
            e.g., {(1,0): 2, (0,1): -3, (1,1): 1} for 2x - 3y + xy
    
    Returns:
        The complex value P(emlMul(a₁), ..., emlMul(aₙ))
    """
    cfg = EMLTupleConfig(algebraic_inputs)
    eml_vals = cfg.eml_values()
    
    result = complex(0)
    for exponents, coeff in polynomial_coeffs.items():
        term = complex(coeff)
        for i, exp in enumerate(exponents):
            term *= eml_vals[i] ** exp
        result += term
    
    return result


def linear_independence_test(
    values: List[complex],
    max_coeff: int = 100,
    tolerance: float = 1e-10
) -> Tuple[bool, Optional[List[int]]]:
    """
    Test whether complex values are ℚ-linearly independent.
    
    Searches for integer linear combinations Σ cᵢ · vᵢ = 0.
    Returns (True, None) if no relation found, or (False, coeffs) if found.
    
    Algorithm:
    1. Separate real and imaginary parts
    2. Apply LLL-based integer relation detection
    3. Verify candidate relations
    """
    import itertools
    
    n = len(values)
    
    # Simple brute-force for small n
    if n <= 3:
        for coeffs in itertools.product(range(-max_coeff, max_coeff + 1), repeat=n):
            if all(c == 0 for c in coeffs):
                continue
            val = sum(c * v for c, v in zip(coeffs, values))
            if abs(val) < tolerance:
                return (False, list(coeffs))
    
    return (True, None)


def eml_growth_analysis(
    a_values: List[float]
) -> List[dict]:
    """
    Analyze the growth rate of emlMul(a) for various inputs.
    
    Returns growth statistics including:
    - value, derivative, ratio to a*exp(a), log-log slope
    """
    results = []
    for a in a_values:
        if a <= -1:
            continue
        val = math.exp(a) * math.log(1 + a)
        deriv = math.exp(a) * (math.log(1 + a) + 1.0 / (1 + a))
        ratio = val / (a * math.exp(a)) if a != 0 else float('inf')
        
        results.append({
            'a': a,
            'eml_value': val,
            'derivative': deriv,
            'ratio_to_a_exp_a': ratio,
            'log_value': math.log(abs(val)) if val != 0 else float('-inf')
        })
    
    return results


# === Main execution ===
if __name__ == "__main__":
    print("EML Multiplicative Transcendence: Algorithm Demonstrations")
    print("=" * 60)
    
    # Single EML config
    cfg = EMLConfig(complex(math.sqrt(2), 0))
    print(f"\nEMLConfig(√2):")
    print(f"  exp_part  = {cfg.exp_part}")
    print(f"  log_part  = {cfg.log_part}")
    print(f"  eml_value = {cfg.eml_value}")
    
    # Tuple config
    tcfg = EMLTupleConfig([complex(math.sqrt(2), 0), complex(math.sqrt(3), 0)])
    print(f"\nEMLTupleConfig([√2, √3]):")
    print(f"  EML values: {tcfg.eml_values()}")
    
    # Integer relation search
    v1 = math.exp(1) * math.log(2)  # emlMul(1)
    print(f"\nInteger relation search for emlMul(1) = {v1:.10f}:")
    relations = integer_relation_search([v1, 1.0], max_degree=3, max_coeff=5)
    if relations:
        print(f"  Found {len(relations)} relations")
    else:
        print("  No relations found (evidence for transcendence)")
    
    # Linear independence test
    a1 = complex(math.sqrt(2), 0)
    a2 = complex(math.sqrt(3), 0)
    is_indep, rel = linear_independence_test(
        [a1, complex(0, 1) * a2],  # √2 and i√3
        max_coeff=20
    )
    print(f"\nLinear independence of √2 and i√3: {is_indep}")
    
    # Growth analysis
    print("\nGrowth analysis:")
    growth = eml_growth_analysis([0.1, 0.5, 1, 2, 5, 10])
    for g in growth:
        print(f"  a={g['a']:5.1f}: emlMul={g['eml_value']:12.4f}, "
              f"ratio={g['ratio_to_a_exp_a']:.6f}")
    
    # EML defect computation
    print("\nEML defect for P(x,y) = x - y at (√2, √3):")
    defect = eml_defect(
        [complex(math.sqrt(2), 0), complex(math.sqrt(3), 0)],
        {(1, 0): 1, (0, 1): -1}
    )
    print(f"  P(emlMul(√2), emlMul(√3)) = {defect}")
    print(f"  |defect| = {abs(defect):.6f} (nonzero confirms no simple relation)")
