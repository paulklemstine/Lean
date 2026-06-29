"""
Newton–Tropical Bridge: Core Algorithms

Type-hinted implementations of the key algorithms from the Newton–Tropical Bridge
theory, including tropical evaluation, slope certificate verification, and
divisibility depth certification.
"""

from typing import List, Tuple, Optional


def tropical_eval(profile: List[float], t: float) -> float:
    """Compute the tropical evaluation T_f(t) = min_i(profile[i] + i * t).

    Args:
        profile: Newton profile [v(a_0), v(a_1), ..., v(a_n)]
        t: Evaluation point (typically v(a) for some element a)

    Returns:
        The tropical evaluation, i.e., the minimum of all tropical terms.

    Time complexity: O(n) where n = len(profile) - 1.
    """
    if not profile:
        raise ValueError("Profile must be non-empty")
    return min(profile[i] + i * t for i in range(len(profile)))


def tropical_term(profile: List[float], t: float, i: int) -> float:
    """Compute the i-th tropical term: profile[i] + i * t.

    Args:
        profile: Newton profile
        t: Evaluation point
        i: Index of the term

    Returns:
        The value profile[i] + i * t.
    """
    return profile[i] + i * t


def find_dominant_index(profile: List[float], t: float) -> Tuple[int, float]:
    """Find the index that achieves the minimum in tropical evaluation.

    Args:
        profile: Newton profile
        t: Evaluation point

    Returns:
        Tuple of (dominant_index, gap_to_second_best).
        Gap is float('inf') if profile has length 1.
    """
    n = len(profile)
    if n == 0:
        raise ValueError("Profile must be non-empty")

    terms = [profile[i] + i * t for i in range(n)]
    sorted_terms = sorted(enumerate(terms), key=lambda x: x[1])
    dominant_idx = sorted_terms[0][0]

    if n == 1:
        return dominant_idx, float('inf')

    gap = sorted_terms[1][1] - sorted_terms[0][1]
    return dominant_idx, gap


def verify_slope_certificate(
    profile: List[float],
    t: float,
    claimed_dominant: int
) -> Tuple[bool, float]:
    """Verify a slope certificate for the given profile and evaluation point.

    A slope certificate is valid if:
    1. The claimed dominant index achieves the minimum.
    2. All other indices have strictly larger tropical terms.

    Args:
        profile: Newton profile
        t: Evaluation point
        claimed_dominant: The index claimed to be dominant

    Returns:
        Tuple of (is_valid, gap). Gap is the minimum difference between
        the dominant term and all others, or 0 if invalid.
    """
    n = len(profile)
    if claimed_dominant < 0 or claimed_dominant >= n:
        return False, 0.0

    dom_val = tropical_term(profile, t, claimed_dominant)
    gap = float('inf')

    for i in range(n):
        if i != claimed_dominant:
            diff = tropical_term(profile, t, i) - dom_val
            if diff < 0:
                return False, 0.0
            gap = min(gap, diff)

    if gap <= 0:
        return False, 0.0

    return True, gap


def generate_divisibility_certificate(
    coeff_valuations: List[float],
    point_valuation: float,
    target_depth: float
) -> Optional[dict]:
    """Generate a divisibility depth certificate.

    Verifies that v(f(a)) >= target_depth by checking that all tropical
    terms are >= target_depth.

    Args:
        coeff_valuations: List of v(a_i) for each coefficient
        point_valuation: v(a) for the evaluation point
        target_depth: The target divisibility depth k

    Returns:
        A certificate dict if valid, None if the bound cannot be certified.
    """
    n = len(coeff_valuations)
    for i in range(n):
        term_val = coeff_valuations[i] + i * point_valuation
        if term_val < target_depth:
            return None

    return {
        "coeff_valuations": coeff_valuations,
        "point_valuation": point_valuation,
        "target_depth": target_depth,
        "tropical_eval": tropical_eval(coeff_valuations, point_valuation),
        "valid": True,
    }


def newton_polygon_breakpoints(profile: List[float]) -> List[Tuple[float, int, int]]:
    """Compute the breakpoints of the tropical evaluation function.

    The tropical evaluation t -> min_i(profile[i] + i*t) is piecewise linear.
    Breakpoints occur where two tropical terms are equal and both achieve
    the minimum.

    Args:
        profile: Newton profile

    Returns:
        List of (breakpoint_t, left_index, right_index) sorted by t.
        At each breakpoint, the dominant term transitions from left_index
        to right_index as t increases.
    """
    n = len(profile)
    if n <= 1:
        return []

    # Compute lower convex hull of points (i, profile[i])
    # The breakpoints are where consecutive hull edges meet
    # For the lower envelope of affine functions y = profile[i] + i*t,
    # the breakpoint between indices i and j is at t = (profile[i] - profile[j]) / (j - i)

    # Build lower convex hull using Graham scan on the points
    hull: List[int] = []
    for i in range(n):
        while len(hull) >= 2:
            # Check if hull[-1] is above the line from hull[-2] to i
            i1, i2 = hull[-2], hull[-1]
            # Slope from i1 to i2: (profile[i2] - profile[i1]) / (i2 - i1)
            # Slope from i1 to i:  (profile[i] - profile[i1]) / (i - i1)
            # Remove i2 if slope(i1,i2) >= slope(i1,i)
            cross = (profile[i2] - profile[i1]) * (i - i1) - \
                    (profile[i] - profile[i1]) * (i2 - i1)
            if cross >= 0:
                hull.pop()
            else:
                break
        hull.append(i)

    breakpoints = []
    for k in range(len(hull) - 1):
        i, j = hull[k], hull[k + 1]
        # Breakpoint: profile[i] + i*t = profile[j] + j*t
        # => t = (profile[i] - profile[j]) / (j - i)
        t_break = (profile[i] - profile[j]) / (j - i)
        breakpoints.append((t_break, i, j))

    return breakpoints


def tropical_concavity_check(
    profile: List[float],
    t1: float,
    t2: float,
    w1: float,
    w2: float
) -> Tuple[bool, float]:
    """Numerically verify the concavity inequality for tropical evaluation.

    Checks: T_f(w1*t1 + w2*t2) >= w1*T_f(t1) + w2*T_f(t2)

    Args:
        profile: Newton profile
        t1, t2: Evaluation points
        w1, w2: Convex combination weights (should satisfy w1 + w2 = 1)

    Returns:
        Tuple of (holds, margin) where margin is the difference
        (LHS - RHS).
    """
    lhs = tropical_eval(profile, w1 * t1 + w2 * t2)
    rhs = w1 * tropical_eval(profile, t1) + w2 * tropical_eval(profile, t2)
    margin = lhs - rhs
    return margin >= -1e-12, margin


def p_adic_valuation(n: int, p: int) -> int:
    """Compute the p-adic valuation of n (how many times p divides n).

    Args:
        n: An integer
        p: A prime number

    Returns:
        v_p(n), the largest k such that p^k divides n.
        Returns float('inf') equivalent (999999) for n = 0.
    """
    if n == 0:
        return 999999  # Represents infinity
    if p <= 1:
        raise ValueError("p must be a prime (> 1)")

    n = abs(n)
    count = 0
    while n % p == 0:
        n //= p
        count += 1
    return count


def bridge_theorem_numerical_test(
    coeffs: List[int],
    a: int,
    p: int
) -> Tuple[float, float, bool]:
    """Numerically test the bridge theorem v(f(a)) >= T_f(v(a)).

    Args:
        coeffs: Polynomial coefficients [a_0, a_1, ..., a_n]
        a: Evaluation point
        p: Prime for p-adic valuation

    Returns:
        Tuple of (v(f(a)), T_f(v(a)), bridge_holds).
    """
    # Compute f(a)
    fa = sum(c * a**i for i, c in enumerate(coeffs))

    # Compute v(f(a))
    v_fa = p_adic_valuation(fa, p)

    # Compute Newton profile: v(a_i)
    profile = [float(p_adic_valuation(c, p)) for c in coeffs]

    # Compute v(a)
    v_a = float(p_adic_valuation(a, p))

    # Compute tropical evaluation
    trop = tropical_eval(profile, v_a)

    return float(v_fa), trop, v_fa >= trop
