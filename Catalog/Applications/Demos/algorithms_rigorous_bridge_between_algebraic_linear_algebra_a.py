"""
Newton–Tropical Bridge: Algorithms
===================================

Type-hinted implementations of the core algorithms connecting
polynomial valuation profiles to tropical geometry.
"""

from typing import List, Tuple, Optional
from math import inf


def p_adic_valuation(n: int, p: int) -> float:
    """Compute the p-adic valuation of an integer n.
    
    Returns the largest k such that p^k divides n.
    Returns infinity if n = 0.
    
    Args:
        n: The integer to evaluate
        p: The prime base
    
    Returns:
        The p-adic valuation v_p(n)
    """
    if n == 0:
        return float('inf')
    n = abs(n)
    k = 0
    while n % p == 0:
        n //= p
        k += 1
    return k


def newton_profile(coeffs: List[int], p: int) -> List[float]:
    """Compute the Newton valuation profile of a polynomial.
    
    For f(x) = coeffs[0] + coeffs[1]*x + ... + coeffs[n]*x^n,
    returns [v_p(coeffs[0]), v_p(coeffs[1]), ..., v_p(coeffs[n])].
    
    Args:
        coeffs: Polynomial coefficients [a_0, a_1, ..., a_n]
        p: Prime for the p-adic valuation
    
    Returns:
        List of p-adic valuations of coefficients
    """
    return [p_adic_valuation(c, p) for c in coeffs]


def tropical_eval(profile: List[float], t: float) -> float:
    """Evaluate the tropical polynomial at point t.
    
    Computes T_f(t) = min_i(profile[i] + i * t).
    This is the lower envelope of the Newton polygon.
    
    Args:
        profile: Newton valuation profile [v_0, v_1, ..., v_n]
        t: Evaluation point in extended reals
    
    Returns:
        The tropical evaluation min_i(v_i + i*t)
    """
    return min(v_i + i * t for i, v_i in enumerate(profile))


def dominant_terms(profile: List[float], t: float) -> List[int]:
    """Find all dominant terms at point t.
    
    Returns indices i where profile[i] + i*t achieves the minimum.
    
    Args:
        profile: Newton valuation profile
        t: Evaluation point
    
    Returns:
        List of dominant term indices
    """
    val = tropical_eval(profile, t)
    return [i for i, v_i in enumerate(profile) if abs(v_i + i * t - val) < 1e-12]


def newton_polygon_vertices(profile: List[float]) -> List[Tuple[int, float]]:
    """Compute the lower convex hull of the Newton polygon.
    
    The Newton polygon is the lower convex hull of the points
    {(i, profile[i]) : profile[i] < infinity}.
    
    Args:
        profile: Newton valuation profile
    
    Returns:
        List of (index, valuation) pairs forming the lower convex hull
    """
    # Filter out infinite valuations
    points = [(i, v) for i, v in enumerate(profile) if v < float('inf')]
    if len(points) <= 1:
        return points
    
    # Graham scan for lower hull
    points.sort()
    hull: List[Tuple[int, float]] = []
    for p in points:
        while len(hull) >= 2:
            # Check if the last point makes a left turn
            o = hull[-2]
            a = hull[-1]
            cross = (a[0] - o[0]) * (p[1] - o[1]) - (a[1] - o[1]) * (p[0] - o[0])
            if cross <= 0:
                hull.pop()
            else:
                break
        hull.append(p)
    return hull


def newton_slopes(profile: List[float]) -> List[float]:
    """Extract the slopes of the Newton polygon.
    
    These are the negatives of the slopes of the lower convex hull
    segments, which by the Newton polygon theorem equal the p-adic
    valuations of the roots.
    
    Args:
        profile: Newton valuation profile
    
    Returns:
        List of slopes (negated, so they give root valuations)
    """
    hull = newton_polygon_vertices(profile)
    if len(hull) <= 1:
        return []
    slopes = []
    for i in range(len(hull) - 1):
        x1, y1 = hull[i]
        x2, y2 = hull[i + 1]
        # Slope of segment from (x1,y1) to (x2,y2)
        # Negative slope gives root valuation
        slope = -(y2 - y1) / (x2 - x1)
        # Each segment of horizontal length (x2-x1) contributes
        # (x2-x1) roots with this valuation
        for _ in range(x2 - x1):
            slopes.append(slope)
    return sorted(slopes)


def infimal_convolution(
    profile_a: List[float], profile_b: List[float]
) -> List[float]:
    """Compute the infimal convolution of two profiles.
    
    This is the tropical product: for degrees m and n,
    result[k] = min_{i+j=k} (profile_a[i] + profile_b[j]).
    
    Args:
        profile_a: First profile of degree m
        profile_b: Second profile of degree n
    
    Returns:
        Infimal convolution of degree m+n
    """
    m = len(profile_a) - 1
    n = len(profile_b) - 1
    result = []
    for k in range(m + n + 1):
        val = float('inf')
        for i in range(max(0, k - n), min(m, k) + 1):
            j = k - i
            val = min(val, profile_a[i] + profile_b[j])
        result.append(val)
    return result


def extract_slope_certificate(
    coeffs: List[int], p: int, point_val: float
) -> dict:
    """Extract a Newton slope certificate.
    
    Given polynomial coefficients, a prime p, and a claimed
    point valuation, produces a certificate that v_p(f(a)) ≥ bound.
    
    Args:
        coeffs: Polynomial coefficients
        p: Prime
        point_val: Claimed v_p(a) for evaluation point a
    
    Returns:
        Dictionary with profile, point_val, bound, and is_valid fields
    """
    profile = newton_profile(coeffs, p)
    bound = tropical_eval(profile, point_val)
    return {
        'profile': profile,
        'point_val': point_val,
        'bound': bound,
        'is_valid': True,  # Valid by construction
        'dominant_terms': dominant_terms(profile, point_val),
    }


def tropical_discriminant_2(profile: List[float]) -> float:
    """Compute the tropical discriminant of a degree-2 profile.
    
    For profile [v(c), v(b), v(a)] of ax² + bx + c:
    tropical_disc = min(2*v(b), v(a) + v(c))
    
    Args:
        profile: Degree-2 Newton profile [v_0, v_1, v_2]
    
    Returns:
        The tropical discriminant
    """
    assert len(profile) == 3
    return min(2 * profile[1], profile[0] + profile[2])


def profile_distance(
    profile_a: List[float], profile_b: List[float]
) -> float:
    """Compute the L-infinity distance between two profiles.
    
    Args:
        profile_a: First profile
        profile_b: Second profile (same length)
    
    Returns:
        max_i |profile_a[i] - profile_b[i]|
    """
    assert len(profile_a) == len(profile_b)
    return max(abs(a - b) for a, b in zip(profile_a, profile_b)
               if a < float('inf') and b < float('inf'))
