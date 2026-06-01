#!/usr/bin/env python3
"""
Algorithms for the Langlands GL₂/ℚ Correspondence

Type-hinted implementations of the core algorithms used in the
Langlands correspondence for GL₂ over the rationals.
"""

from typing import List, Tuple, Optional, Dict
import math


# ============================================================
# Algorithm 1: Ramanujan Tau via q-expansion
# ============================================================

def ramanujan_tau_qexpansion(n: int) -> List[int]:
    """
    Compute τ(1), τ(2), ..., τ(n) via the q-expansion of
    Δ(q) = q·∏_{m≥1} (1 - q^m)^24.
    
    Algorithm: Iteratively multiply the power series by (1-q^m)^24
    for m = 1, 2, ..., n, maintaining coefficients mod exact integer arithmetic.
    
    Complexity: O(n² · 24) = O(n²) integer operations.
    
    Args:
        n: Compute tau values up to n
        
    Returns:
        List where result[i] = τ(i+1) for i = 0, ..., n-1
    """
    coeffs: List[int] = [0] * (n + 1)
    coeffs[0] = 1
    
    for m in range(1, n + 1):
        for _ in range(24):
            for k in range(n, m - 1, -1):
                coeffs[k] -= coeffs[k - m]
    
    # Δ(q) = q·∏..., so τ(k) = coeffs[k-1]
    return [coeffs[i] for i in range(n)]


def hecke_eigenvalue_recursion(
    a_p: int,
    p: int,
    k: int,
    max_power: int
) -> List[int]:
    """
    Compute a(p^r) for r = 0, 1, ..., max_power using the Hecke recursion:
    a(p^{r+1}) = a(p)·a(p^r) - p^{k-1}·a(p^{r-1})
    
    This is the key recursion of the Langlands correspondence: it shows
    that the Hecke eigenvalue at p determines the eigenform at all prime powers.
    
    Args:
        a_p: The Hecke eigenvalue a(p)
        p: The prime
        k: The weight of the eigenform
        max_power: Maximum exponent r
        
    Returns:
        List [a(p^0), a(p^1), ..., a(p^max_power)]
    """
    if max_power < 0:
        return []
    
    result: List[int] = [0] * (max_power + 1)
    result[0] = 1  # a(1) = 1
    
    if max_power >= 1:
        result[1] = a_p
    
    pk_minus_1 = p ** (k - 1)
    
    for r in range(2, max_power + 1):
        result[r] = a_p * result[r - 1] - pk_minus_1 * result[r - 2]
    
    return result


# ============================================================
# Algorithm 2: Frobenius Discriminant Analysis
# ============================================================

def frobenius_analysis(
    a_p: float,
    p: int,
    k: int
) -> Dict[str, float]:
    """
    Analyze the Frobenius at prime p for a weight-k eigenform.
    
    Computes:
    - The Hecke polynomial X² - a_p·X + p^{k-1}
    - The discriminant Δ = a_p² - 4·p^{k-1}
    - The Frobenius eigenvalues (real or complex)
    - The Ramanujan ratio |a_p| / (2·p^{(k-1)/2})
    
    Args:
        a_p: Hecke eigenvalue at p
        p: Prime
        k: Weight
        
    Returns:
        Dictionary with analysis results
    """
    det_val = p ** (k - 1)
    disc = a_p ** 2 - 4 * det_val
    ramanujan_bound = 2 * p ** ((k - 1) / 2)
    ramanujan_ratio = abs(a_p) / ramanujan_bound if ramanujan_bound > 0 else float('inf')
    
    result: Dict[str, float] = {
        'p': p,
        'a_p': a_p,
        'det': det_val,
        'discriminant': disc,
        'ramanujan_bound': ramanujan_bound,
        'ramanujan_ratio': ramanujan_ratio,
        'satisfies_ramanujan': 1.0 if abs(a_p) <= ramanujan_bound else 0.0,
    }
    
    if disc >= 0:
        result['eigenvalue_1'] = (a_p + math.sqrt(disc)) / 2
        result['eigenvalue_2'] = (a_p - math.sqrt(disc)) / 2
        result['eigenvalue_type'] = 0.0  # real
    else:
        result['eigenvalue_real'] = a_p / 2
        result['eigenvalue_imag'] = math.sqrt(-disc) / 2
        result['eigenvalue_abs'] = math.sqrt((a_p / 2) ** 2 + (-disc) / 4)
        result['eigenvalue_type'] = 1.0  # complex conjugate
    
    return result


# ============================================================
# Algorithm 3: Elliptic Curve Point Counting
# ============================================================

def point_count_naive(a_coeffs: Tuple[int, ...], p: int) -> int:
    """
    Count points on a short Weierstrass elliptic curve over F_p.
    
    For y² + a1·xy + a3·y = x³ + a2·x² + a4·x + a6 (mod p).
    
    Args:
        a_coeffs: Tuple (a1, a2, a3, a4, a6) of Weierstrass coefficients
        p: Prime (field size)
        
    Returns:
        Number of F_p-rational points (including point at infinity)
    """
    a1, a2, a3, a4, a6 = a_coeffs
    count = 1  # point at infinity
    
    for x in range(p):
        for y in range(p):
            lhs = (y * y + a1 * x * y + a3 * y) % p
            rhs = (x * x * x + a2 * x * x + a4 * x + a6) % p
            if lhs == rhs:
                count += 1
    
    return count


def ap_from_curve(a_coeffs: Tuple[int, ...], p: int) -> int:
    """
    Compute a_p = p + 1 - #E(F_p) for an elliptic curve.
    
    This is the Eichler-Shimura invariant: it equals the Hecke eigenvalue
    of the corresponding weight-2 modular form.
    """
    return p + 1 - point_count_naive(a_coeffs, p)


# ============================================================
# Algorithm 4: Satake Parameters
# ============================================================

def satake_parameters(
    a_p: float,
    p: int,
    k: int
) -> Tuple[complex, complex]:
    """
    Compute the Satake parameters (α_p, β_p) from the Hecke eigenvalue.
    
    These are the roots of X² - a_p·X + p^{k-1}:
    α_p, β_p = (a_p ± √(a_p² - 4·p^{k-1})) / 2
    
    Satisfying:
    - α_p + β_p = a_p (trace)
    - α_p · β_p = p^{k-1} (determinant)
    
    If the Ramanujan conjecture holds, |α_p| = |β_p| = p^{(k-1)/2}.
    """
    det_val = p ** (k - 1)
    disc = a_p ** 2 - 4 * det_val
    
    if disc >= 0:
        sqrt_disc = math.sqrt(disc)
        alpha = complex((a_p + sqrt_disc) / 2, 0)
        beta = complex((a_p - sqrt_disc) / 2, 0)
    else:
        real_part = a_p / 2
        imag_part = math.sqrt(-disc) / 2
        alpha = complex(real_part, imag_part)
        beta = complex(real_part, -imag_part)
    
    return alpha, beta


def satake_angle(a_p: float, p: int, k: int) -> float:
    """
    Compute the Satake angle θ_p ∈ [0, π] defined by
    a_p = 2·p^{(k-1)/2}·cos(θ_p).
    
    This is the angle used in the Sato-Tate distribution.
    """
    bound = 2 * p ** ((k - 1) / 2)
    if bound == 0:
        return 0.0
    cos_theta = max(-1.0, min(1.0, a_p / bound))
    return math.acos(cos_theta)


# ============================================================
# Algorithm 5: L-function Euler Product (Partial)
# ============================================================

def euler_factor(a_p: float, p: int, k: int, s: float) -> float:
    """
    Compute the Euler factor at prime p for the L-function of a weight-k eigenform:
    L_p(s) = (1 - a_p·p^{-s} + p^{k-1-2s})^{-1}
    
    The full L-function is L(f, s) = ∏_p L_p(s).
    """
    term = 1 - a_p * p**(-s) + p**(k - 1 - 2*s)
    if abs(term) < 1e-15:
        return float('inf')
    return 1.0 / term


def partial_l_function(
    coeffs: Dict[int, float],
    k: int,
    s: float,
    max_prime: int = 100
) -> float:
    """
    Compute a partial Euler product for L(f, s).
    
    Args:
        coeffs: Dictionary mapping primes to Hecke eigenvalues
        k: Weight
        s: Complex variable (real part only)
        max_prime: Include primes up to this bound
        
    Returns:
        Partial L-function value
    """
    result = 1.0
    p = 2
    while p <= max_prime:
        if _is_prime(p) and p in coeffs:
            result *= euler_factor(coeffs[p], p, k, s)
        p += 1
    return result


def _is_prime(n: int) -> bool:
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


# ============================================================
# Algorithm 6: Sato-Tate Test
# ============================================================

def sato_tate_test(
    compute_ap: callable,
    k: int,
    max_prime: int,
    num_bins: int = 10
) -> Dict[str, any]:
    """
    Run the Sato-Tate equidistribution test.
    
    Computes the empirical distribution of Satake angles θ_p
    and compares with the Sato-Tate measure (2/π)sin²θ.
    
    Args:
        compute_ap: Function p -> a_p
        k: Weight of the eigenform
        max_prime: Include primes up to this bound
        num_bins: Number of histogram bins
        
    Returns:
        Dictionary with observed and predicted distributions
    """
    primes = [p for p in range(2, max_prime + 1) if _is_prime(p)]
    angles = []
    
    for p in primes:
        a_p = compute_ap(p)
        theta = satake_angle(a_p, p, k)
        angles.append(theta)
    
    # Histogram
    bin_size = math.pi / num_bins
    observed = [0] * num_bins
    
    for theta in angles:
        idx = min(int(theta / bin_size), num_bins - 1)
        observed[idx] += 1
    
    total = len(angles)
    
    result = {
        'num_primes': total,
        'bins': [],
    }
    
    for i in range(num_bins):
        lo = i * bin_size
        hi = (i + 1) * bin_size
        obs_freq = observed[i] / total if total > 0 else 0
        # Sato-Tate: (2/π)∫sin²θ dθ = (1/π)[(θ - sin(2θ)/2)]
        st_pred = (1 / math.pi) * ((hi - lo) - 0.5 * (math.sin(2 * hi) - math.sin(2 * lo)))
        result['bins'].append({
            'lo': lo,
            'hi': hi,
            'count': observed[i],
            'observed': obs_freq,
            'predicted': st_pred,
        })
    
    return result


if __name__ == "__main__":
    # Quick test
    taus = ramanujan_tau_qexpansion(10)
    print("τ(1..10):", taus)
    
    # Hecke recursion test
    powers = hecke_eigenvalue_recursion(-24, 2, 12, 5)
    print("a(2^r) for r=0..5:", powers)
    
    # Point count for 11a1
    E_11a1 = (0, -1, 1, 0, 0)  # y² + y = x³ - x²
    for p in [2, 3, 5, 7, 13]:
        print(f"a_{p}(11a1) = {ap_from_curve(E_11a1, p)}")
    
    # Satake at p=2
    alpha, beta = satake_parameters(-24, 2, 12)
    print(f"Satake at p=2: α={alpha}, β={beta}")
    print(f"|α| = {abs(alpha):.4f}, 2^(11/2) = {2**(11/2):.4f}")
