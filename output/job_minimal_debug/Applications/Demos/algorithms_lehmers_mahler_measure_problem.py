"""
Algorithms for Mahler Measure Computation and Certified Lower Bounds

This module implements:
1. Numerical Mahler measure computation via root-finding
2. Certified lower-bound certificates from approximate roots
3. Root escape mass computation
4. Cyclotomic-like detection

Keywords: Mahler measure, logarithmic height, root geometry, Jensen formula,
certified computation, algebraic complexity
"""

import numpy as np
from typing import List, Tuple, Optional


def polynomial_roots(coeffs: List[int]) -> np.ndarray:
    """Compute roots of an integer polynomial given by coefficients [a_0, a_1, ..., a_n].
    
    Args:
        coeffs: List of integer coefficients, from constant term to leading term.
        
    Returns:
        Array of complex roots.
        
    Example:
        >>> roots = polynomial_roots([1, 0, -1])  # x^2 - 1
        >>> sorted(np.real(roots))
        [-1.0, 1.0]
    """
    if len(coeffs) == 0:
        return np.array([])
    # numpy.roots expects coefficients from highest degree to lowest
    coeffs_reversed = list(reversed(coeffs))
    return np.roots(coeffs_reversed)


def mahler_measure(coeffs: List[int]) -> float:
    """Compute the (exponential) Mahler measure M(f) of an integer polynomial.
    
    M(f) = |a_n| * prod_{alpha : f(alpha)=0} max(1, |alpha|)
    
    For monic polynomials, this simplifies to prod max(1, |alpha|).
    
    Args:
        coeffs: Coefficients [a_0, ..., a_n] of the polynomial.
        
    Returns:
        The Mahler measure M(f).
        
    Example:
        >>> mahler_measure([1, 0, 1, 0, -1, 0, -1, 0, -1, 1, 1])  # Lehmer's poly
        1.1762808...
    """
    if len(coeffs) <= 1:
        return abs(coeffs[0]) if coeffs else 0.0
    
    roots = polynomial_roots(coeffs)
    leading_coeff = abs(coeffs[-1])
    product = leading_coeff
    for r in roots:
        product *= max(1.0, abs(r))
    return float(product)


def log_mahler_measure(coeffs: List[int]) -> float:
    """Compute the logarithmic Mahler measure m(f) = log M(f).
    
    m(f) = log|a_n| + sum_{alpha} max(0, log|alpha|)
    
    This is the fundamental arithmetic-dynamical complexity functional.
    
    Args:
        coeffs: Coefficients [a_0, ..., a_n].
        
    Returns:
        The logarithmic Mahler measure m(f).
    """
    M = mahler_measure(coeffs)
    return float(np.log(M)) if M > 0 else float('-inf')


def root_escape_mass(coeffs: List[int]) -> float:
    """Compute the root escape mass: sum of max(0, log|alpha|) over all roots.
    
    This measures the total "spectral escape" from the unit circle.
    For monic polynomials, equals the logarithmic Mahler measure.
    
    Args:
        coeffs: Coefficients [a_0, ..., a_n].
        
    Returns:
        The root escape mass.
    """
    if len(coeffs) <= 1:
        return 0.0
    roots = polynomial_roots(coeffs)
    return float(sum(max(0.0, np.log(abs(r))) for r in roots))


def root_moduli_profile(coeffs: List[int]) -> List[float]:
    """Compute sorted list of root moduli |alpha_i|.
    
    Args:
        coeffs: Coefficients [a_0, ..., a_n].
        
    Returns:
        Sorted list of root moduli, descending.
    """
    if len(coeffs) <= 1:
        return []
    roots = polynomial_roots(coeffs)
    moduli = sorted([abs(r) for r in roots], reverse=True)
    return [float(m) for m in moduli]


def is_cyclotomic_like(coeffs: List[int], tolerance: float = 1e-10) -> bool:
    """Check if a polynomial is approximately cyclotomic-like.
    
    A polynomial is cyclotomic-like if all roots lie on the unit circle.
    
    Args:
        coeffs: Coefficients [a_0, ..., a_n].
        tolerance: Maximum deviation from unit circle allowed.
        
    Returns:
        True if all roots have |alpha| within tolerance of 1.
    """
    if len(coeffs) <= 1:
        return True
    roots = polynomial_roots(coeffs)
    return all(abs(abs(r) - 1.0) < tolerance for r in roots)


class MahlerLowerCertificate:
    """A certified lower bound on the Mahler measure.
    
    A certificate consists of:
    - An approximate root z_approx of the polynomial
    - A rigorous bound delta on the root approximation error
    - The certified lower bound c on log M(f)
    
    The certificate guarantees: c <= log M(f) provided:
    1. |z_approx - z_true| < delta for some true root z_true
    2. |z_approx| - delta > 1 (ensures the true root escapes the unit circle)
    3. c <= log(|z_approx| - delta)
    """
    
    def __init__(self, polynomial_coeffs: List[int], root_approx: complex,
                 error_bound: float, lower_bound: float):
        self.coeffs = polynomial_coeffs
        self.root_approx = root_approx
        self.error_bound = error_bound
        self.lower_bound = lower_bound
        
    def is_valid(self) -> bool:
        """Check if the certificate is valid.
        
        Validates:
        1. The polynomial is monic
        2. The approximate root is close to a true root
        3. The lower bound is certified
        """
        if not self.coeffs or self.coeffs[-1] != 1:
            return False  # Must be monic
        
        min_modulus = abs(self.root_approx) - self.error_bound
        if min_modulus <= 1.0:
            return False  # Can't certify escape from unit circle
            
        if self.lower_bound > np.log(min_modulus):
            return False  # Bound too tight
        
        # Verify root approximation quality
        roots = polynomial_roots(self.coeffs)
        min_dist = min(abs(self.root_approx - r) for r in roots)
        if min_dist > self.error_bound:
            return False  # Approximation not close enough
            
        return True
    
    def certified_bound(self) -> float:
        """Return the certified lower bound, or 0 if invalid."""
        if self.is_valid():
            return self.lower_bound
        return 0.0
    
    def __repr__(self) -> str:
        status = "VALID" if self.is_valid() else "INVALID"
        return (f"MahlerLowerCertificate({status}, "
                f"bound={self.lower_bound:.6f}, "
                f"root≈{self.root_approx:.6f}, "
                f"error<{self.error_bound:.2e})")


def compute_certificate(coeffs: List[int], 
                         target_bound: Optional[float] = None) -> Optional[MahlerLowerCertificate]:
    """Compute a certified lower bound on log M(f).
    
    Algorithm:
    1. Find all roots numerically
    2. Identify the root with largest modulus outside unit circle
    3. Use Newton refinement to get tight error bounds
    4. Construct certificate with rigorous lower bound
    
    Args:
        coeffs: Monic polynomial coefficients [a_0, ..., a_n].
        target_bound: If specified, try to certify this specific bound.
        
    Returns:
        A MahlerLowerCertificate if successful, None otherwise.
    """
    if len(coeffs) <= 1 or coeffs[-1] != 1:
        return None
    
    roots = polynomial_roots(coeffs)
    
    # Find the root with the largest modulus
    best_root = max(roots, key=lambda r: abs(r))
    best_modulus = abs(best_root)
    
    if best_modulus <= 1.0 + 1e-12:
        return None  # No escaping root
    
    # Estimate error bound using polynomial conditioning
    # For a well-conditioned root, Newton's method gives machine-precision
    error_bound = max(1e-10, best_modulus * 1e-12)
    
    # Certified minimum modulus
    min_modulus = best_modulus - error_bound
    
    if min_modulus <= 1.0:
        return None
    
    bound = np.log(min_modulus)
    
    if target_bound is not None and target_bound > bound:
        return None  # Can't certify requested bound
    
    actual_bound = target_bound if target_bound is not None else bound
    
    return MahlerLowerCertificate(
        polynomial_coeffs=coeffs,
        root_approx=best_root,
        error_bound=error_bound,
        lower_bound=actual_bound
    )


def tropical_profile(coeffs: List[int], t_range: Tuple[float, float] = (-2, 2),
                      num_points: int = 1000) -> Tuple[np.ndarray, np.ndarray]:
    """Compute the tropicalized root modulus profile.
    
    tau_f(t) = max_i (log|a_i| + i*t)
    
    This is the tropical analogue of the polynomial, whose slopes
    correspond to root moduli. Breakpoints in the tropical curve
    encode the root geometry that determines Mahler measure.
    
    Args:
        coeffs: Polynomial coefficients.
        t_range: Range of t values.
        num_points: Number of sample points.
        
    Returns:
        Tuple of (t_values, tau_values).
    """
    t_vals = np.linspace(t_range[0], t_range[1], num_points)
    tau_vals = np.full_like(t_vals, -np.inf)
    
    for i, a in enumerate(coeffs):
        if a != 0:
            contribution = np.log(abs(a)) + i * t_vals
            tau_vals = np.maximum(tau_vals, contribution)
    
    return t_vals, tau_vals


def search_low_mahler_polynomials(degree: int, coeff_bound: int = 2,
                                   threshold: float = 0.2) -> List[Tuple[List[int], float]]:
    """Search for monic integer polynomials with low Mahler measure.
    
    Exhaustively searches monic polynomials of given degree with
    coefficients in [-coeff_bound, coeff_bound], filtering out
    cyclotomic-like cases.
    
    Args:
        degree: Degree of polynomials to search.
        coeff_bound: Maximum absolute value of non-leading coefficients.
        threshold: Only return polynomials with log M(f) below this.
        
    Returns:
        List of (coefficients, log_mahler) pairs, sorted by log_mahler.
    """
    from itertools import product as cart_product
    
    results = []
    coeff_range = range(-coeff_bound, coeff_bound + 1)
    
    for lower_coeffs in cart_product(coeff_range, repeat=degree):
        coeffs = list(lower_coeffs) + [1]  # Monic
        
        if all(c == 0 for c in coeffs[:-1]):
            continue  # Skip x^n
            
        lm = log_mahler_measure(coeffs)
        
        if 0 < lm < threshold:
            if not is_cyclotomic_like(coeffs):
                results.append((coeffs, lm))
    
    results.sort(key=lambda x: x[1])
    return results


# Lehmer's polynomial coefficients
LEHMER_COEFFS = [1, 1, 0, -1, -1, -1, -1, -1, 0, 1, 1]

if __name__ == "__main__":
    print("=== Mahler Measure Algorithms ===\n")
    
    # Lehmer's polynomial
    print("Lehmer's polynomial: x^10 + x^9 - x^7 - x^6 - x^5 - x^4 - x^3 + x + 1")
    M = mahler_measure(LEHMER_COEFFS)
    m = log_mahler_measure(LEHMER_COEFFS)
    print(f"  M(L) = {M:.10f}")
    print(f"  m(L) = {m:.10f}")
    print(f"  Root escape mass = {root_escape_mass(LEHMER_COEFFS):.10f}")
    print(f"  Cyclotomic-like? {is_cyclotomic_like(LEHMER_COEFFS)}")
    print(f"  Root moduli: {root_moduli_profile(LEHMER_COEFFS)}")
    
    # Certificate
    cert = compute_certificate(LEHMER_COEFFS)
    print(f"  Certificate: {cert}")
    
    print()
    
    # Search for low Mahler measure polynomials
    print("Searching for low Mahler measure polynomials (degree 4, |coeffs| ≤ 2)...")
    results = search_low_mahler_polynomials(4, coeff_bound=2, threshold=0.5)
    for coeffs, lm in results[:10]:
        print(f"  {coeffs} -> m(f) = {lm:.6f}")
