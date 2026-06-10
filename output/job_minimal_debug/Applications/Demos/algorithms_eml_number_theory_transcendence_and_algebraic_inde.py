#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for EML transcendence analysis.

Type-hinted implementations of the key mathematical constructions
from the research on Schanuel's conjecture and EML numbers.
"""

from typing import Callable
import math


def eml(x: float, y: float) -> float:
    """
    The EML function: eml(x, y) = exp(x) - log(y).
    
    Properties (proved in Lean):
    - eml(1, 1) = e (transcendental)
    - If exp(x) and log(y) are algebraically independent, eml(x,y) is transcendental
    - eml is strictly monotone increasing in x, strictly monotone decreasing in y
    """
    if y <= 0:
        raise ValueError(f"y must be positive, got {y}")
    return math.exp(x) - math.log(y)


def schanuel_tuple(z: list[complex]) -> list[complex]:
    """
    Compute the Schanuel combined 2n-tuple.
    
    Given z = [z₁, ..., zₙ], returns [z₁, ..., zₙ, e^z₁, ..., e^zₙ].
    
    Under Schanuel's conjecture, if z₁,...,zₙ are ℚ-linearly independent,
    at least n of these 2n values are algebraically independent over ℚ.
    """
    import cmath
    return z + [cmath.exp(zi) for zi in z]


def exp_tower(n: int, base: float = 1.0) -> float:
    """
    Compute the n-th iterated exponential: exp^n(base).
    
    exp_tower(0) = base
    exp_tower(1) = exp(base)
    exp_tower(2) = exp(exp(base))
    ...
    
    Under Schanuel's conjecture, all elements of the tower
    starting from n=1 (with base=1) are transcendental.
    """
    result = base
    for _ in range(n):
        if result > 700:  # overflow protection
            return float('inf')
        result = math.exp(result)
    return result


def check_polynomial_vanishing(
    values: list[float],
    max_degree: int = 3,
    tolerance: float = 1e-10
) -> list[tuple[tuple[int, ...], float]]:
    """
    Heuristic test for algebraic independence.
    
    Given a list of real numbers, checks if any polynomial
    of degree ≤ max_degree with small integer coefficients
    approximately vanishes at the given values.
    
    Returns a list of (exponent_vector, value) pairs where
    the polynomial nearly vanishes.
    
    This is a numerical heuristic; algebraic independence
    is only rigorously established by formal proof.
    """
    from itertools import product as iterproduct
    
    n = len(values)
    near_vanishing: list[tuple[tuple[int, ...], float]] = []
    
    # Generate all monomials up to degree max_degree
    def monomial_value(exponents: tuple[int, ...]) -> float:
        result = 1.0
        for v, e in zip(values, exponents):
            result *= v ** e
        return result
    
    # Check sparse polynomials with coefficients in {-2,-1,0,1,2}
    coeff_range = range(-2, 3)
    exponent_range = range(max_degree + 1)
    
    monomials = list(iterproduct(exponent_range, repeat=n))
    monomials = [m for m in monomials if 0 < sum(m) <= max_degree]
    
    # Check pairs of monomials
    for i, m1 in enumerate(monomials):
        for c1 in coeff_range:
            if c1 == 0:
                continue
            for m2 in monomials[i+1:]:
                for c2 in coeff_range:
                    if c2 == 0:
                        continue
                    val = c1 * monomial_value(m1) + c2 * monomial_value(m2)
                    if abs(val) < tolerance:
                        near_vanishing.append(
                            ((c1, m1, c2, m2), val)
                        )
    
    return near_vanishing


def transcendence_cascade_analysis(depth: int = 5) -> dict:
    """
    Analyze the transcendence cascade e, e^e, e^(e^e), ...
    
    For each level, computes:
    - The numerical value (when computable)
    - The number of digits
    - Growth rate analysis
    
    Returns a dictionary with the analysis results.
    """
    results: dict = {"levels": []}
    
    for n in range(depth):
        val = exp_tower(n + 1)
        level_info: dict = {
            "level": n + 1,
            "notation": f"exp^{n+1}(1)",
        }
        
        if val == float('inf'):
            level_info["value"] = "overflow"
            level_info["digits"] = "> 10^308"
        else:
            level_info["value"] = val
            level_info["digits"] = len(str(int(val))) if val >= 1 else 1
            level_info["log_value"] = math.log10(val) if val > 0 else None
        
        results["levels"].append(level_info)
    
    return results


def eml_transcendence_witness(
    x: float, y: float
) -> dict:
    """
    Compute the EML value and analyze its transcendence properties.
    
    Under Schanuel's conjecture:
    - If exp(x) and log(y) are algebraically independent, eml(x,y) is transcendental
    - eml(1,1) = e (transcendental)
    - eml(e, exp(-e)) = e^e + e (transcendental under Schanuel)
    """
    exp_x = math.exp(x)
    log_y = math.log(y) if y > 0 else float('nan')
    eml_val = exp_x - log_y
    
    return {
        "x": x,
        "y": y,
        "exp_x": exp_x,
        "log_y": log_y,
        "eml_value": eml_val,
        "components_equal": abs(exp_x - log_y) < 1e-15,
        "transcendence_note": (
            "Transcendental under Schanuel if exp(x) and log(y) "
            "are algebraically independent"
        ),
    }


if __name__ == "__main__":
    # Quick demonstration
    e = math.e
    
    print("EML Transcendence Analysis")
    print("-" * 40)
    
    # Key EML values
    for x, y, name in [
        (1, 1, "eml(1,1) = e"),
        (e, 1, "eml(e,1) = e^e"),
        (e, math.exp(-e), "eml(e, exp(-e)) = e^e + e"),
    ]:
        result = eml_transcendence_witness(x, y)
        print(f"\n{name}:")
        print(f"  Value: {result['eml_value']:.10f}")
    
    # Cascade analysis
    print("\n\nTranscendence Cascade:")
    cascade = transcendence_cascade_analysis(4)
    for level in cascade["levels"]:
        val_str = f"{level['value']:.6f}" if isinstance(level['value'], float) else level['value']
        print(f"  {level['notation']:15s} = {val_str}")
    
    # Independence check
    print("\n\nAlgebraic Independence Test for {e, e^e}:")
    near = check_polynomial_vanishing([e, e**e], max_degree=2)
    if not near:
        print("  No near-vanishing polynomials found (consistent with independence)")
    else:
        for poly, val in near[:5]:
            print(f"  Near-vanishing: {poly} ≈ {val:.2e}")
