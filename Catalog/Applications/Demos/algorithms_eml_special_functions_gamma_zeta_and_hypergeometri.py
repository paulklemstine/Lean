#!/usr/bin/env python3
"""
Algorithms: EML Special Functions

Type-hinted implementations of the core algorithms from the research.
"""

from typing import List, Tuple, Callable
import math


def rising_factorial(a: float, n: int) -> float:
    """
    Compute the Pochhammer symbol (rising factorial).

    (a)_n = a * (a+1) * ... * (a+n-1)

    Time: O(n)
    Space: O(1)
    """
    result = 1.0
    for k in range(n):
        result *= (a + k)
    return result


def hypergeometric_2f1(a: float, b: float, c: float, z: float,
                        tol: float = 1e-15, max_terms: int = 1000) -> float:
    """
    Compute ₂F₁(a, b; c; z) via direct series summation.

    Uses the recurrence: c_{n+1} = c_n * (a+n)(b+n) / ((c+n)(n+1))

    Convergence: |z| < 1 (radius of convergence = 1 by Theorem 23)
    Special cases:
        - 2F1(a, b; c; 0) = 1  (Theorem 7)
        - 2F1(0, b; c; z) = 1  (Theorem 8)
        - 2F1(-m, b; c; z) = polynomial of degree m  (Theorem 25)

    Args:
        a, b, c: Parameters (c must not be 0, -1, -2, ...)
        z: Argument (|z| < 1 for convergence)
        tol: Convergence tolerance
        max_terms: Maximum number of terms

    Returns:
        Approximate value of 2F1(a, b; c; z)
    """
    if abs(z) >= 1:
        raise ValueError(f"|z| = {abs(z)} >= 1: series may not converge")

    total = 1.0
    term = 1.0

    for n in range(max_terms):
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z
        total += term
        if abs(term) < tol * abs(total):
            break

    return total


def eml_operator(x: float, y: float) -> float:
    """
    The EML operator: eml(x, y) = exp(x) - log(y).

    Properties (from Lean proofs):
        - Differentiable in x everywhere (Theorem 17a)
        - Differentiable in y for y != 0 (Theorem 17b)
        - Strictly monotone increasing in x
        - Singularity only at y = 0 (log branch point)
    """
    if y <= 0:
        raise ValueError(f"y = {y} <= 0: log(y) undefined")
    return math.exp(x) - math.log(y)


def eml_diagonal(z: float) -> float:
    """
    EML diagonal: emlDiag(z) = exp(z) - log(z).

    Smooth on (0, ∞) (Theorem 16).
    """
    if z <= 0:
        raise ValueError(f"z = {z} <= 0: log(z) undefined")
    return math.exp(z) - math.log(z)


def log_gamma_decomposition(n: int) -> List[float]:
    """
    Decompose log(n!) into individual log terms (Theorem 9).

    Returns the list [log(1), log(2), ..., log(n)] whose sum equals log(n!).
    """
    return [math.log(k + 1) for k in range(n)]


def classify_singularity(spectrum_type: str) -> dict:
    """
    Classify a singularity type in the EML framework.

    EML Singularity Types:
        - 'removable': Function extends continuously (meromorphic ✓, EML-compatible ✓)
        - 'pole': Finite-order blow-up (meromorphic ✓, EML-compatible ✓)
        - 'logBranch': Log branch point (meromorphic ✗, EML-compatible ✓)
        - 'essential': Essential singularity (meromorphic ✗, EML-compatible ✗)

    Returns dict with classification properties.
    """
    classifications = {
        'removable': {'meromorphic': True, 'eml_compatible': True,
                      'description': 'Fictitious singularity, function extends continuously'},
        'pole': {'meromorphic': True, 'eml_compatible': True,
                 'description': 'Finite-order blow-up, controlled by Laurent expansion'},
        'logBranch': {'meromorphic': False, 'eml_compatible': True,
                      'description': 'Logarithmic branch point, multi-valued but EML-handled'},
        'essential': {'meromorphic': False, 'eml_compatible': False,
                      'description': 'Casorati-Weierstrass behavior, outside EML class'},
    }

    if spectrum_type not in classifications:
        raise ValueError(f"Unknown singularity type: {spectrum_type}")

    return classifications[spectrum_type]


def stirling_lower_bound(n: int) -> Tuple[float, float]:
    """
    Compute Stirling lower bound and actual log(n!) (Theorem 11).

    Returns (lower_bound, actual) where lower_bound = n*log(n) - n + 1.
    """
    if n < 1:
        raise ValueError("n must be >= 1")
    lower = n * math.log(n) - n + 1
    actual = math.log(math.factorial(n))
    return lower, actual


def pochhammer_eml_representation(a: float, n: int) -> List[float]:
    """
    Express rising factorial factors through EML (Theorems 13-14).

    Each factor (a+k) of (a)_n satisfies:
        eml'(log(a+k), 1) = a + k

    Returns the list of factors and their EML representations.
    """
    if a <= 0:
        raise ValueError("a must be positive for log decomposition")

    factors = []
    for k in range(n):
        val = a + k
        eml_val = eml_operator(math.log(val), 1)
        factors.append({
            'k': k,
            'factor': val,
            'eml_representation': eml_val,
            'log_component': math.log(val),
        })
    return factors


if __name__ == "__main__":
    # Quick verification
    print("=== Algorithm Verification ===\n")

    print("2F1(1/2, 1; 3/2; z^2) = arcsin(z)/z")
    z = 0.5
    h = hypergeometric_2f1(0.5, 1, 1.5, z**2)
    expected = math.asin(z) / z
    print(f"  2F1(1/2, 1; 3/2; {z}^2) = {h:.10f}")
    print(f"  arcsin({z})/{z} = {expected:.10f}")
    print(f"  Error: {abs(h - expected):.2e}\n")

    print("Singularity classification:")
    for stype in ['removable', 'pole', 'logBranch', 'essential']:
        info = classify_singularity(stype)
        print(f"  {stype:12s}: meromorphic={info['meromorphic']}, "
              f"eml_compatible={info['eml_compatible']}")

    print("\nStirling bounds:")
    for n in [5, 10, 20, 50]:
        lower, actual = stirling_lower_bound(n)
        print(f"  n={n:2d}: bound={lower:.2f}, actual={actual:.2f}, gap={actual-lower:.3f}")
