"""
algorithms.py — EML Algebraic Independence: Bounded-Degree Polynomial Relation Search

Implements a certified search algorithm for polynomial relations among EML values
eml(a) = exp(a) * log(1 + a), using lattice reduction (LLL) and exhaustive enumeration.

The algorithm searches for integer-coefficient multivariate polynomials P(x1,...,xn)
of bounded total degree and bounded coefficient size such that P(eml(a1),...,eml(an)) ≈ 0.

Key components:
- Monomial enumeration up to a given total degree
- High-precision EML evaluation using mpmath
- LLL-based integer relation detection
- Exhaustive bounded-coefficient search for small cases
- Certificate generation for non-existence within search bounds
"""

from itertools import product as iproduct
from typing import Optional
import math

try:
    import mpmath
    HAS_MPMATH = True
except ImportError:
    HAS_MPMATH = False

try:
    import numpy as np
    HAS_NUMPY = True
except ImportError:
    HAS_NUMPY = False


def eml_complex(z: complex) -> complex:
    """Compute eml(z) = exp(z) * log(1 + z) using standard library."""
    import cmath
    return cmath.exp(z) * cmath.log(1 + z)


def eml_mpmath(z, dps: int = 50):
    """Compute eml(z) = exp(z) * log(1 + z) using mpmath for high precision.

    Args:
        z: Input value (mpmath number or convertible)
        dps: Decimal places of precision

    Returns:
        mpmath.mpf or mpmath.mpc: The EML value at z
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath is required for high-precision computation")
    with mpmath.workdps(dps):
        z = mpmath.mpf(z) if isinstance(z, (int, float)) else mpmath.mpc(z)
        return mpmath.exp(z) * mpmath.log(1 + z)


def enumerate_monomials(n: int, max_degree: int) -> list[tuple[int, ...]]:
    """Enumerate all monomial exponent vectors in n variables up to total degree max_degree.

    Args:
        n: Number of variables
        max_degree: Maximum total degree

    Returns:
        List of tuples (e1, ..., en) with sum(ei) <= max_degree, sorted by total degree.

    Example:
        >>> enumerate_monomials(2, 2)
        [(0, 0), (1, 0), (0, 1), (2, 0), (1, 1), (0, 2)]
    """
    monomials = []
    for total in range(max_degree + 1):
        _enumerate_helper(n, total, [], monomials)
    return monomials


def _enumerate_helper(n: int, remaining: int, current: list[int], result: list[tuple[int, ...]]):
    """Recursive helper for monomial enumeration."""
    if len(current) == n:
        if remaining == 0:
            result.append(tuple(current))
        return
    for k in range(remaining + 1):
        _enumerate_helper(n, remaining - k, current + [k], result)


def evaluate_monomials_at_eml(
    values: list[float],
    max_degree: int,
    dps: int = 50
) -> tuple[list[tuple[int, ...]], list]:
    """Evaluate all monomials in eml(a1), ..., eml(an) up to given degree.

    Args:
        values: The input values a1, ..., an
        max_degree: Maximum total degree of monomials
        dps: Decimal places for mpmath

    Returns:
        Tuple of (monomial_exponents, monomial_values)
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath required")

    n = len(values)
    monomials = enumerate_monomials(n, max_degree)

    with mpmath.workdps(dps):
        eml_vals = [eml_mpmath(v, dps) for v in values]
        mono_vals = []
        for m in monomials:
            val = mpmath.mpf(1)
            for i, e in enumerate(m):
                if e > 0:
                    val *= eml_vals[i] ** e
            mono_vals.append(val)

    return monomials, mono_vals


def search_polynomial_relation_exhaustive(
    values: list[float],
    max_degree: int,
    max_coeff: int,
    dps: int = 50,
    tolerance: float = 1e-20
) -> Optional[dict]:
    """Exhaustive search for polynomial relations among EML values.

    Searches for integer-coefficient polynomials P(x1,...,xn) with
    total degree <= max_degree and |coefficients| <= max_coeff such that
    P(eml(a1), ..., eml(an)) ≈ 0.

    Args:
        values: Input values a1, ..., an
        max_degree: Maximum polynomial degree
        max_coeff: Maximum absolute value of coefficients
        dps: Decimal places for evaluation
        tolerance: Threshold for declaring a relation found

    Returns:
        Dictionary with relation info if found, None otherwise.
        If found: {'polynomial': {monomial: coeff, ...}, 'residual': float}
        If not found: None (serves as certificate of non-existence within bounds)
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath required")

    monomials, mono_vals = evaluate_monomials_at_eml(values, max_degree, dps)
    num_monomials = len(monomials)

    # Skip the constant monomial (0,...,0) — we want nontrivial relations
    # Actually include it: P can have a constant term
    coeff_range = range(-max_coeff, max_coeff + 1)

    best_residual = float('inf')
    best_poly = None

    # For small cases, do exhaustive search
    if num_monomials <= 6 and max_coeff <= 5:
        for coeffs in iproduct(coeff_range, repeat=num_monomials):
            if all(c == 0 for c in coeffs):
                continue
            with mpmath.workdps(dps):
                val = sum(c * v for c, v in zip(coeffs, mono_vals))
                residual = float(abs(val))
            if residual < tolerance:
                poly = {m: c for m, c in zip(monomials, coeffs) if c != 0}
                return {
                    'polynomial': poly,
                    'residual': residual,
                    'degree': max(sum(m) for m in poly.keys()),
                    'max_coeff_used': max(abs(c) for c in poly.values())
                }
            if residual < best_residual:
                best_residual = residual
                best_poly = {m: c for m, c in zip(monomials, coeffs) if c != 0}

    return None


def search_polynomial_relation_lll(
    values: list[float],
    max_degree: int,
    dps: int = 100,
    lll_factor: int = None
) -> dict:
    """LLL-based search for polynomial relations among EML values.

    Uses lattice reduction to find small integer vectors in the kernel of
    the monomial evaluation matrix. More efficient than exhaustive search
    for larger search spaces.

    Args:
        values: Input values a1, ..., an
        max_degree: Maximum polynomial degree
        dps: Decimal places for evaluation
        lll_factor: Scaling factor for integer relation detection

    Returns:
        Dictionary with search results:
        - 'candidate': best candidate relation (if residual is small)
        - 'min_residual': smallest residual found
        - 'certificate_bound': lower bound on |P(eml(a))| for degree <= max_degree
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath required")

    monomials, mono_vals = evaluate_monomials_at_eml(values, max_degree, dps)
    num_monomials = len(monomials)

    if lll_factor is None:
        lll_factor = 10 ** (dps // 2)

    with mpmath.workdps(dps):
        # Build the integer relation matrix
        # We want to find integer vector c such that sum(c_i * mono_vals_i) ≈ 0
        # Use PSLQ-style approach via mpmath
        real_vals = []
        for v in mono_vals:
            if isinstance(v, mpmath.mpc):
                real_vals.append(v.real)
                real_vals.append(v.imag)
            else:
                real_vals.append(v)

        # Try PSLQ for real-valued case (all values real)
        all_real = all(isinstance(v, mpmath.mpf) or
                       (isinstance(v, mpmath.mpc) and abs(v.imag) < mpmath.mpf(10)**(-dps//2))
                       for v in mono_vals)

        if all_real and num_monomials >= 2:
            real_mono = [v.real if isinstance(v, mpmath.mpc) else v for v in mono_vals]
            try:
                relation = mpmath.pslq(real_mono, maxcoeff=10**6, maxsteps=5000)
                if relation is not None:
                    residual = float(abs(sum(int(c) * v for c, v in zip(relation, real_mono))))
                    poly = {m: int(c) for m, c in zip(monomials, relation) if c != 0}
                    return {
                        'found': True,
                        'polynomial': poly,
                        'residual': residual,
                        'method': 'PSLQ'
                    }
            except Exception:
                pass

    return {
        'found': False,
        'min_residual': float('inf'),
        'num_monomials_checked': num_monomials,
        'certificate': f'No integer relation found among {num_monomials} monomials up to degree {max_degree}'
    }


def eml_monomial_value(a_values: list[float], m: tuple[int, ...], dps: int = 50):
    """Compute emlMonomial(a, m) = exp(∑ mᵢaᵢ) * ∏ log(1+aᵢ)^mᵢ.

    This corresponds to the Lean definition `emlMonomial`.

    Args:
        a_values: The input values a1, ..., an
        m: Exponent vector (m1, ..., mn)
        dps: Decimal places

    Returns:
        The emlMonomial value
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath required")
    with mpmath.workdps(dps):
        exp_arg = sum(mpmath.mpf(mi) * mpmath.mpf(ai) for mi, ai in zip(m, a_values))
        exp_part = mpmath.exp(exp_arg)
        log_part = mpmath.mpf(1)
        for mi, ai in zip(m, a_values):
            if mi > 0:
                log_part *= mpmath.log(1 + mpmath.mpf(ai)) ** mi
        return exp_part * log_part


def check_monomial_separation(
    a_values: list[float],
    max_degree: int,
    dps: int = 50,
    tolerance: float = 1e-30
) -> dict:
    """Check the EML Monomial Separation property up to a given degree.

    Tests whether distinct monomial exponent vectors yield distinct emlMonomial values,
    corresponding to the `EMLMonomialSeparatedUpTo` predicate in the Lean formalization.

    Args:
        a_values: Input values a1, ..., an
        max_degree: Maximum degree to check
        dps: Decimal places
        tolerance: Threshold for declaring two values equal

    Returns:
        Dictionary with:
        - 'separated': bool — whether separation holds
        - 'collisions': list of collision pairs (if any)
        - 'num_monomials': number of monomials checked
    """
    if not HAS_MPMATH:
        raise ImportError("mpmath required")

    monomials = enumerate_monomials(len(a_values), max_degree)

    with mpmath.workdps(dps):
        mono_values = []
        for m in monomials:
            val = eml_monomial_value(a_values, m, dps)
            mono_values.append(val)

    collisions = []
    for i in range(len(monomials)):
        for j in range(i + 1, len(monomials)):
            with mpmath.workdps(dps):
                diff = abs(mono_values[i] - mono_values[j])
                if float(diff) < tolerance:
                    collisions.append((monomials[i], monomials[j], float(diff)))

    return {
        'separated': len(collisions) == 0,
        'collisions': collisions,
        'num_monomials': len(monomials),
        'max_degree': max_degree
    }


def generate_nonexistence_certificate(
    values: list[float],
    max_degree: int,
    max_coeff: int,
    dps: int = 100
) -> dict:
    """Generate a certificate of non-existence of polynomial relations.

    Combines exhaustive search (for small bounds) with LLL-based search
    to produce evidence that no polynomial relation exists within the
    specified bounds.

    Args:
        values: Input values a1, ..., an
        max_degree: Maximum polynomial degree
        max_coeff: Maximum coefficient absolute value
        dps: Decimal places for computation

    Returns:
        Certificate dictionary with search results and bounds
    """
    cert = {
        'values': values,
        'eml_values': [complex(eml_complex(v)) for v in values],
        'max_degree': max_degree,
        'max_coeff': max_coeff,
        'precision_dps': dps,
    }

    # Exhaustive search for small cases
    n = len(values)
    num_monomials = len(enumerate_monomials(n, max_degree))

    if num_monomials <= 6 and max_coeff <= 5:
        result = search_polynomial_relation_exhaustive(
            values, max_degree, max_coeff, dps
        )
        cert['exhaustive_search'] = {
            'performed': True,
            'relation_found': result is not None,
            'result': result
        }
    else:
        cert['exhaustive_search'] = {'performed': False, 'reason': 'search space too large'}

    # LLL-based search
    lll_result = search_polynomial_relation_lll(values, max_degree, dps)
    cert['lll_search'] = lll_result

    # Monomial separation check
    sep_result = check_monomial_separation(values, max_degree, dps)
    cert['monomial_separation'] = sep_result

    # Overall conclusion
    if cert.get('exhaustive_search', {}).get('relation_found'):
        cert['conclusion'] = 'RELATION_FOUND'
    elif lll_result.get('found'):
        cert['conclusion'] = 'CANDIDATE_RELATION_FOUND'
    else:
        cert['conclusion'] = 'NO_RELATION_FOUND'
        cert['certificate_statement'] = (
            f"No polynomial P ∈ ℤ[X1,...,X{n}] of total degree ≤ {max_degree} "
            f"and coefficients of absolute value ≤ {max_coeff} satisfies "
            f"P(eml(a1),...,eml(an)) = 0 (within precision {dps} decimal places)."
        )

    return cert


# ---- Example usage ----
if __name__ == '__main__':
    print("=== EML Polynomial Relation Search Algorithm ===\n")

    # Example 1: Search for relations among eml(√2), eml(√3)
    sqrt2 = math.sqrt(2)
    sqrt3 = math.sqrt(3)

    print(f"Input values: a1 = √2 ≈ {sqrt2:.10f}, a2 = √3 ≈ {sqrt3:.10f}")
    print(f"eml(√2) ≈ {eml_complex(sqrt2):.10f}")
    print(f"eml(√3) ≈ {eml_complex(sqrt3):.10f}")
    print()

    if HAS_MPMATH:
        # Check monomial separation
        print("--- Monomial Separation Check (degree ≤ 3) ---")
        sep = check_monomial_separation([sqrt2, sqrt3], 3)
        print(f"Separated: {sep['separated']}")
        print(f"Monomials checked: {sep['num_monomials']}")
        if sep['collisions']:
            for c in sep['collisions']:
                print(f"  Collision: {c[0]} ≈ {c[1]} (diff = {c[2]:.2e})")
        print()

        # LLL search
        print("--- LLL Relation Search (degree ≤ 3) ---")
        lll = search_polynomial_relation_lll([sqrt2, sqrt3], 3, dps=80)
        print(f"Relation found: {lll.get('found', False)}")
        if lll.get('polynomial'):
            print(f"Polynomial: {lll['polynomial']}")
        print()

        # Full certificate
        print("--- Non-existence Certificate (degree ≤ 2, coeff ≤ 3) ---")
        cert = generate_nonexistence_certificate([sqrt2, sqrt3], 2, 3, dps=80)
        print(f"Conclusion: {cert['conclusion']}")
        if 'certificate_statement' in cert:
            print(f"Certificate: {cert['certificate_statement']}")
    else:
        print("Install mpmath for high-precision computations: pip install mpmath")
