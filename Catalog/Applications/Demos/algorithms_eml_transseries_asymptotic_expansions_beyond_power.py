#!/usr/bin/env python3
"""
Transseries Algorithms: Computational tools for asymptotic analysis.

Type-hinted implementations of the key algorithms from the transseries
formalization.
"""

from typing import Tuple, List, Callable
import math


def asymptotic_dominance_test(
    f: Callable[[float], float],
    g: Callable[[float], float],
    test_points: List[float] | None = None,
    threshold: float = 1e6,
) -> bool:
    """
    Test whether f asymptotically dominates g by checking if f(x)/g(x) 
    grows without bound.
    
    Args:
        f: The potentially dominant function
        g: The potentially dominated function
        test_points: Points at which to evaluate (default: [100, 1000, ...])
        threshold: If ratio exceeds this at the largest point, declare dominance
    
    Returns:
        True if evidence suggests f dominates g
    """
    if test_points is None:
        test_points = [100.0, 1000.0, 10000.0, 100000.0]
    
    ratios = []
    for x in test_points:
        g_val = g(x)
        if abs(g_val) < 1e-300:
            continue
        ratios.append(f(x) / g_val)
    
    if len(ratios) < 2:
        return False
    
    # Check monotonically increasing and exceeding threshold
    return all(ratios[i] < ratios[i+1] for i in range(len(ratios)-1)) and ratios[-1] > threshold


def classify_growth(
    f: Callable[[float], float],
) -> str:
    """
    Classify a function into one of the growth classes:
    'super_exponential', 'exponential', 'polynomial', 'logarithmic', 'bounded'.
    
    Uses heuristic ratio tests at large values.
    """
    # Test against exp
    try:
        ratio_exp = f(100) / math.exp(100)
    except (OverflowError, ValueError):
        return "super_exponential"
    
    if ratio_exp > 1e10:
        return "super_exponential"
    
    if ratio_exp > 1e-10:
        return "exponential"
    
    # Test against polynomial
    try:
        # Check if f(2x)/f(x) grows polynomially
        r1 = f(100) / (100 ** 10) if f(100) != 0 else 0
        r2 = f(1000) / (1000 ** 10) if f(1000) != 0 else 0
        if r2 > r1 * 0.1:
            return "polynomial"
    except (OverflowError, ValueError, ZeroDivisionError):
        pass
    
    # Test against log
    try:
        r1 = f(100) / math.log(100)
        r2 = f(10000) / math.log(10000)
        if 0.1 < r2 / r1 < 10:
            return "logarithmic"
    except (OverflowError, ValueError, ZeroDivisionError):
        pass
    
    return "bounded"


def recover_eml_coefficients(
    f: Callable[[float], float],
    x_large: float = 50.0,
    x_log: float = 1e6,
) -> Tuple[float, float, float]:
    """
    Recover the coefficients (a, b, c) from a function of the form
    f(x) = a·exp(x) + b·log(x) + c
    
    Uses the coefficient recovery theorems:
    - a = lim f(x)/exp(x)
    - b = lim (f(x) - a·exp(x))/log(x)
    - c = f(x) - a·exp(x) - b·log(x)  (exact)
    
    Args:
        f: Function to analyze
        x_large: Point for exp-scale recovery
        x_log: Point for log-scale recovery
    
    Returns:
        Tuple (a, b, c) of recovered coefficients
    """
    # Step 1: Recover a = lim f(x)/exp(x)
    a = f(x_large) / math.exp(x_large)
    
    # Step 2: Recover b from remainder
    remainder_at_log = f(x_log) - a * math.exp(x_log)
    b = remainder_at_log / math.log(x_log)
    
    # Step 3: Recover c (exact at any point)
    c = f(1.0) - a * math.exp(1.0) - b * math.log(1.0)
    
    return (a, b, c)


def transseries_add(
    coeffs1: Tuple[float, float, float],
    coeffs2: Tuple[float, float, float],
) -> Tuple[float, float, float]:
    """
    Add two EML-type transseries: (a₁,b₁,c₁) + (a₂,b₂,c₂) = (a₁+a₂, b₁+b₂, c₁+c₂).
    """
    return (coeffs1[0] + coeffs2[0], coeffs1[1] + coeffs2[1], coeffs1[2] + coeffs2[2])


def transseries_scalar_mul(
    r: float,
    coeffs: Tuple[float, float, float],
) -> Tuple[float, float, float]:
    """
    Scalar multiply: r·(a,b,c) = (ra, rb, rc).
    """
    return (r * coeffs[0], r * coeffs[1], r * coeffs[2])


def transseries_differentiate(
    coeffs: Tuple[float, float, float],
) -> Callable[[float], float]:
    """
    Differentiate a·exp(x) + b·log(x) + c to get a·exp(x) + b/x.
    
    Returns a function representing the derivative.
    Note: The derivative is NOT in the {exp, log, 1} basis — it's in
    {exp, 1/x} basis, showing Hardy field closure.
    """
    a, b, _ = coeffs
    return lambda x: a * math.exp(x) + b / x


def verify_uniqueness(
    coeffs1: Tuple[float, float, float],
    coeffs2: Tuple[float, float, float],
    test_points: List[float] | None = None,
    tol: float = 1e-10,
) -> bool:
    """
    Verify that two coefficient tuples represent the same function.
    By the uniqueness theorem, they must have identical coefficients.
    """
    if test_points is None:
        test_points = [0.5, 1.0, 2.0, 5.0, 10.0]
    
    a1, b1, c1 = coeffs1
    a2, b2, c2 = coeffs2
    
    for x in test_points:
        f1 = a1 * math.exp(x) + b1 * math.log(x) + c1
        f2 = a2 * math.exp(x) + b2 * math.log(x) + c2
        if abs(f1 - f2) > tol * max(abs(f1), abs(f2), 1.0):
            return False
    return True


if __name__ == "__main__":
    # Demo: coefficient recovery
    a_true, b_true, c_true = 2.5, -1.3, 4.7
    f = lambda x: a_true * math.exp(x) + b_true * math.log(x) + c_true
    
    a_rec, b_rec, c_rec = recover_eml_coefficients(f)
    print(f"True coefficients:      a={a_true}, b={b_true}, c={c_true}")
    print(f"Recovered coefficients: a={a_rec:.6f}, b={b_rec:.6f}, c={c_rec:.6f}")
    
    # Demo: growth classification
    print(f"\nGrowth class of exp:     {classify_growth(math.exp)}")
    print(f"Growth class of x^2:    {classify_growth(lambda x: x**2)}")
    print(f"Growth class of log:    {classify_growth(math.log)}")
    print(f"Growth class of exp∘exp: {classify_growth(lambda x: math.exp(min(x, 700)))}")
