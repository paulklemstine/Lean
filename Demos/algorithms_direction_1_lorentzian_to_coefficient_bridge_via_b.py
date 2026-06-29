"""
Algorithms for Lorentzian-to-Coefficient Bridge

Implements the core algorithms for:
1. Computing bivariate specialization coefficients
2. Testing k-fold log-concavity
3. Computing the Lorentzian depth of coefficient sequences
4. Polynomial multiplication (convolution) for products of linear forms
"""
import math
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass
class LogConcavityReport:
    """Report from k-fold log-concavity analysis."""
    depth: int
    is_valid: bool
    level_ratios: List[List[float]]
    messages: List[str]


def bivariate_specialization(degree: int, alpha: float, beta: float) -> List[float]:
    """
    Compute the bivariate specialization coefficient sequence.
    
    For (alpha*x + beta*y)^d, returns [a(0), a(1), ..., a(d)] where
    a(m) = C(d, m) * alpha^m * beta^(d-m).
    
    Args:
        degree: Degree d of the polynomial
        alpha: Coefficient of x
        beta: Coefficient of y
    
    Returns:
        List of d+1 coefficients
    
    Time: O(d)
    Space: O(d)
    """
    if degree < 0:
        return []
    return [
        math.comb(degree, m) * alpha**m * beta**(degree - m)
        for m in range(degree + 1)
    ]


def polynomial_product(polys: List[List[float]]) -> List[float]:
    """
    Compute the product of multiple univariate polynomials.
    
    Each polynomial is represented as a list of coefficients [a0, a1, ...].
    
    Args:
        polys: List of polynomials to multiply
    
    Returns:
        Product polynomial coefficients
    
    Time: O(d1 * d2 * ... * dk) where di is the degree of polynomial i
    Space: O(sum of degrees)
    """
    if not polys:
        return [1.0]
    
    result = polys[0][:]
    for poly in polys[1:]:
        new_result = [0.0] * (len(result) + len(poly) - 1)
        for i, a in enumerate(result):
            for j, b in enumerate(poly):
                new_result[i + j] += a * b
        result = new_result
    
    return result


def linear_form_product_coefficients(
    forms: List[Tuple[float, float]]
) -> List[float]:
    """
    Compute coefficients of a product of linear forms in two variables.
    
    Given forms [(α₁, β₁), ..., (αₙ, βₙ)], computes the coefficient sequence
    of ∏ᵢ (αᵢx + βᵢy) = Σₘ aₘ x^m y^(d-m).
    
    Args:
        forms: List of (alpha, beta) pairs for each linear form
    
    Returns:
        Coefficient sequence [a(0), a(1), ..., a(d)]
    
    Time: O(d²) where d = len(forms)
    Space: O(d)
    """
    polys = [[alpha, beta] for alpha, beta in forms]
    return polynomial_product(polys)


def compute_ratio_sequence(seq: List[float]) -> List[float]:
    """
    Compute the ratio sequence r(m) = a(m+1)/a(m).
    
    Args:
        seq: Input sequence (must be positive)
    
    Returns:
        Ratio sequence of length len(seq)-1
    
    Time: O(n)
    Space: O(n)
    """
    return [seq[m + 1] / seq[m] for m in range(len(seq) - 1)]


def compute_lc_ratios(seq: List[float]) -> List[float]:
    """
    Compute log-concavity ratios: a(m)² / (a(m-1) · a(m+1)) for m in [1, d-1].
    
    Values ≥ 1 indicate log-concavity at that position.
    
    Args:
        seq: Input sequence of length d+1
    
    Returns:
        List of d-1 ratios
    
    Time: O(d)
    Space: O(d)
    """
    d = len(seq) - 1
    ratios = []
    for m in range(1, d):
        if seq[m - 1] > 0 and seq[m + 1] > 0:
            ratios.append(seq[m]**2 / (seq[m - 1] * seq[m + 1]))
        else:
            ratios.append(float('inf'))
    return ratios


def test_k_fold_log_concavity(
    seq: List[float],
    max_depth: int = 10
) -> LogConcavityReport:
    """
    Determine the k-fold log-concavity depth of a positive sequence.
    
    Iteratively computes ratio sequences and checks log-concavity at each level.
    Returns the maximum depth k such that the sequence is k-fold log-concave.
    
    Algorithm:
    1. Check if sequence is positive → depth ≥ 0
    2. Check log-concavity → depth ≥ 1
    3. Compute ratio sequence, check its log-concavity → depth ≥ 2
    4. Repeat until failure or max_depth
    
    Args:
        seq: Input sequence (must be positive)
        max_depth: Maximum depth to test
    
    Returns:
        LogConcavityReport with the determined depth
    
    Time: O(d · k) where d = len(seq), k = returned depth
    Space: O(d)
    """
    messages = []
    level_ratios = []
    current = seq[:]
    depth = 0
    
    # Check positivity (depth 0)
    if not all(x > 0 for x in current):
        messages.append("Sequence is not positive.")
        return LogConcavityReport(0, False, [], messages)
    
    messages.append("Depth 0: positive ✓")
    
    for level in range(max_depth):
        if len(current) < 3:
            messages.append(f"Depth {level + 1}: sequence too short, vacuously true ✓")
            depth = level + 1
            break
        
        ratios = compute_lc_ratios(current)
        level_ratios.append(ratios)
        
        if min(ratios) < 1.0 - 1e-10:
            messages.append(
                f"Depth {level + 1}: NOT log-concave (min ratio = {min(ratios):.8f})"
            )
            break
        
        depth = level + 1
        messages.append(
            f"Depth {depth}: log-concave ✓ (min ratio = {min(ratios):.8f})"
        )
        
        # Compute ratio sequence for next level
        current = compute_ratio_sequence(current)
        if not all(x > 0 for x in current):
            messages.append(f"  Ratio sequence has non-positive terms, stopping.")
            break
    
    return LogConcavityReport(depth, True, level_ratios, messages)


def reversed_cauchy_schwarz_ratio(d: int, m: int) -> float:
    """
    Compute the reversed Cauchy-Schwarz ratio for binomial coefficients:
    C(d,m)² / (C(d,m-1) · C(d,m+1)) = (d-m+1)(m+1) / (m(d-m))
    
    This ratio is always ≥ 1, with surplus exactly (d+1)/(m(d-m)).
    
    Args:
        d: Degree
        m: Index (1 ≤ m ≤ d-1)
    
    Returns:
        The ratio, which measures how much the sequence exceeds log-concavity
    """
    if m < 1 or m >= d:
        return float('inf')
    return (d - m + 1) * (m + 1) / (m * (d - m))


def geometric_perturbation(seq: List[float], r: float) -> List[float]:
    """
    Apply geometric perturbation: a(m) → a(m) · r^m.
    
    This preserves log-concavity (proved in the Lean formalization).
    
    Args:
        seq: Input sequence
        r: Perturbation parameter (must be > 0)
    
    Returns:
        Perturbed sequence
    
    Time: O(d)
    Space: O(d)
    """
    return [seq[m] * r**m for m in range(len(seq))]


def hadamard_product(a: List[float], b: List[float]) -> List[float]:
    """
    Compute the Hadamard (pointwise) product of two sequences.
    
    If both inputs are log-concave and positive, the output is also
    log-concave (proved in the Lean formalization).
    
    Args:
        a, b: Input sequences (same length)
    
    Returns:
        Pointwise product sequence
    
    Time: O(d)
    Space: O(d)
    """
    assert len(a) == len(b), "Sequences must have the same length"
    return [a[m] * b[m] for m in range(len(a))]


def conjecture_test(
    d: int,
    forms: List[Tuple[float, float]],
    expected_depth: Optional[int] = None
) -> dict:
    """
    Test the Lorentzian Bivariate Specialization Conjecture.
    
    For a product of linear forms ∏(αᵢx + βᵢy), the conjecture predicts that
    the coefficient sequence is min(k, d-2)-fold log-concave, where k is the
    Lorentzian depth of the polynomial.
    
    Products of d linear forms with positive coefficients are Lorentzian of
    depth d-2, so the prediction is (d-2)-fold log-concavity.
    
    Args:
        d: Expected degree
        forms: List of (alpha, beta) pairs
        expected_depth: Expected k-fold depth (default: len(forms) - 2)
    
    Returns:
        Dictionary with test results
    """
    if expected_depth is None:
        expected_depth = len(forms) - 2
    
    coeffs = linear_form_product_coefficients(forms)
    assert len(coeffs) == d + 1, f"Expected degree {d}, got {len(coeffs) - 1}"
    
    report = test_k_fold_log_concavity(coeffs, max_depth=expected_depth + 2)
    
    return {
        "degree": d,
        "num_forms": len(forms),
        "coefficients": coeffs,
        "expected_depth": expected_depth,
        "actual_depth": report.depth,
        "conjecture_holds": report.depth >= expected_depth,
        "messages": report.messages,
        "level_ratios": report.level_ratios,
    }


# Example usage
if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")
    
    # Test 1: Bivariate specialization
    print("1. Bivariate specialization of (2x + 3y)^5:")
    seq = bivariate_specialization(5, 2.0, 3.0)
    print(f"   Coefficients: {[f'{c:.0f}' for c in seq]}")
    report = test_k_fold_log_concavity(seq)
    for msg in report.messages:
        print(f"   {msg}")
    
    # Test 2: Product of distinct linear forms
    print("\n2. Product of linear forms (x+y)(2x+y)(x+3y)(3x+2y):")
    forms = [(1, 1), (2, 1), (1, 3), (3, 2)]
    coeffs = linear_form_product_coefficients(forms)
    print(f"   Coefficients: {[f'{c:.0f}' for c in coeffs]}")
    report = test_k_fold_log_concavity(coeffs)
    for msg in report.messages:
        print(f"   {msg}")
    
    # Test 3: Conjecture test
    print("\n3. Conjecture test (7 linear forms):")
    forms7 = [(1, 1), (2, 1), (1, 2), (3, 1), (1, 3), (2, 3), (3, 2)]
    result = conjecture_test(7, forms7)
    print(f"   Expected depth: {result['expected_depth']}")
    print(f"   Actual depth: {result['actual_depth']}")
    print(f"   Conjecture holds: {result['conjecture_holds']}")
    for msg in result['messages']:
        print(f"   {msg}")
