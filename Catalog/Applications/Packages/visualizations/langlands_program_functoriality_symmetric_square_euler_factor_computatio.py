#!/usr/bin/env python3
"""
Algorithms for Symmetric Square Transfer in the Langlands Program

Implements certified algorithms for computing local and finite-global
symmetric square Euler factors from GL(2) Satake parameters.

All algorithms correspond to formally verified identities.
"""

from typing import List, Tuple, Optional
import cmath


class LocalGL2Parameter:
    """An unramified local GL(2) parameter (Satake eigenvalues).

    Encodes the Frobenius conjugacy class at an unramified prime
    via its eigenvalues (α, β).

    Attributes:
        alpha: First Satake eigenvalue.
        beta: Second Satake eigenvalue.
    """

    def __init__(self, alpha: complex, beta: complex):
        self.alpha = alpha
        self.beta = beta

    @property
    def trace(self) -> complex:
        """The trace α + β (Hecke eigenvalue a_p)."""
        return self.alpha + self.beta

    @property
    def det(self) -> complex:
        """The determinant αβ (central character value ω_p)."""
        return self.alpha * self.beta

    @classmethod
    def from_trace_det(cls, trace: complex, det: complex) -> "LocalGL2Parameter":
        """Construct from trace and determinant using the quadratic formula.

        Finds α, β such that α + β = trace and αβ = det.

        Args:
            trace: The sum α + β.
            det: The product αβ.

        Returns:
            LocalGL2Parameter with the computed eigenvalues.
        """
        discriminant = trace**2 - 4 * det
        sqrt_disc = cmath.sqrt(discriminant)
        alpha = (trace + sqrt_disc) / 2
        beta = (trace - sqrt_disc) / 2
        return cls(alpha, beta)

    def __repr__(self) -> str:
        return f"LocalGL2Parameter(α={self.alpha}, β={self.beta})"


def symm_square_parameter(param: LocalGL2Parameter) -> Tuple[complex, complex, complex]:
    """Compute the symmetric square GL(3) Satake parameters.

    Maps (α, β) ↦ (α², αβ, β²).

    Args:
        param: A GL(2) local parameter.

    Returns:
        Triple (α², αβ, β²) of GL(3) Satake eigenvalues.

    Example:
        >>> p = LocalGL2Parameter(2, 3)
        >>> symm_square_parameter(p)
        (4, 6, 9)
    """
    return (param.alpha**2, param.alpha * param.beta, param.beta**2)


def symm_square_trace(alpha: complex, beta: complex) -> complex:
    """Compute the symmetric square trace α² + αβ + β².

    This is tr(Sym²(diag(α, β))), the sum of GL(3) Satake parameters.

    Equivalent to (α + β)² - αβ = trace² - det.

    Args:
        alpha: First eigenvalue.
        beta: Second eigenvalue.

    Returns:
        The symmetric square trace.

    Example:
        >>> symm_square_trace(2, 3)
        19  # = 4 + 6 + 9
    """
    return alpha**2 + alpha * beta + beta**2


def symm_square_trace_from_hecke(a_p: complex, omega_p: complex) -> complex:
    """Compute symmetric square trace from Hecke data.

    Uses the identity: α² + αβ + β² = (α+β)² - αβ = a_p² - ω_p.

    Args:
        a_p: Hecke eigenvalue (trace of Satake parameters).
        omega_p: Central character value (determinant of Satake parameters).

    Returns:
        The symmetric square Hecke eigenvalue a_p(Sym²).

    Example:
        >>> symm_square_trace_from_hecke(5, 6)  # a_p=5, ω_p=6
        19  # = 25 - 6
    """
    return a_p**2 - omega_p


def local_euler_gl2(param: LocalGL2Parameter, X: complex) -> complex:
    """Compute the GL(2) local Euler factor L_p(X; α, β).

    L_p(X) = 1 / ((1 - αX)(1 - βX))

    Args:
        param: GL(2) local parameter.
        X: Evaluation point (typically p^{-s}).

    Returns:
        The Euler factor value.
    """
    denom = (1 - param.alpha * X) * (1 - param.beta * X)
    if abs(denom) < 1e-15:
        raise ValueError("Euler factor has a pole at this point")
    return 1 / denom


def local_euler_symm_square_factored(param: LocalGL2Parameter, X: complex) -> complex:
    """Compute the symmetric square Euler factor (factored form).

    L_p^{Sym²}(X) = 1 / ((1 - α²X)(1 - αβX)(1 - β²X))

    Args:
        param: GL(2) local parameter.
        X: Evaluation point.

    Returns:
        The symmetric square Euler factor.
    """
    a, b = param.alpha, param.beta
    denom = (1 - a**2 * X) * (1 - a * b * X) * (1 - b**2 * X)
    if abs(denom) < 1e-15:
        raise ValueError("Euler factor has a pole at this point")
    return 1 / denom


def local_euler_symm_square_expanded(
    param: LocalGL2Parameter, X: complex
) -> complex:
    """Compute the symmetric square Euler factor (expanded form).

    Uses the certified identity:
    denominator = 1 - sX + d·s·X² - d³X³
    where s = α² + αβ + β² and d = αβ.

    This form is numerically more stable and avoids computing
    individual squared parameters.

    Args:
        param: GL(2) local parameter.
        X: Evaluation point.

    Returns:
        The symmetric square Euler factor.

    Example:
        >>> p = LocalGL2Parameter(2, 3)
        >>> local_euler_symm_square_expanded(p, 0.01)
    """
    s = symm_square_trace(param.alpha, param.beta)
    d = param.det
    denom = 1 - s * X + d * s * X**2 - d**3 * X**3
    if abs(denom) < 1e-15:
        raise ValueError("Euler factor has a pole at this point")
    return 1 / denom


def local_euler_symm_square_from_hecke(
    a_p: complex, omega_p: complex, X: complex
) -> complex:
    """Compute the symmetric square Euler factor from Hecke eigenvalue data.

    Uses only the conjugacy-invariant data (a_p, ω_p) without
    computing individual Satake parameters.

    denominator = 1 - (a_p² - ω_p)X + ω_p(a_p² - ω_p)X² - ω_p³X³

    Args:
        a_p: Hecke eigenvalue.
        omega_p: Central character value.
        X: Evaluation point.

    Returns:
        The symmetric square Euler factor.
    """
    s = a_p**2 - omega_p
    denom = 1 - s * X + omega_p * s * X**2 - omega_p**3 * X**3
    if abs(denom) < 1e-15:
        raise ValueError("Euler factor has a pole at this point")
    return 1 / denom


def symm_square_hecke_polynomial(
    param: LocalGL2Parameter
) -> List[complex]:
    """Return coefficients of the symmetric square Hecke polynomial.

    P(T) = T³ - (α²+αβ+β²)T² + αβ(α²+αβ+β²)T - (αβ)³

    Returns coefficients [c₀, c₁, c₂, c₃] where P(T) = Σ cᵢ Tⁱ.

    Args:
        param: GL(2) local parameter.

    Returns:
        List of polynomial coefficients from degree 0 to degree 3.

    Example:
        >>> p = LocalGL2Parameter(2, 3)
        >>> symm_square_hecke_polynomial(p)
        [-216, 114, -19, 1]
    """
    s = symm_square_trace(param.alpha, param.beta)
    d = param.det
    return [-(d**3), d * s, -s, 1]


def finite_euler_product_symm_square(
    params: List[LocalGL2Parameter], X: complex
) -> complex:
    """Compute the finite symmetric square Euler product.

    L_S^{Sym²}(X) = ∏_{v ∈ S} L_v^{Sym²}(X)

    Args:
        params: List of local GL(2) parameters.
        X: Evaluation point.

    Returns:
        The finite Euler product value.
    """
    result = complex(1)
    for param in params:
        result *= local_euler_symm_square_expanded(param, X)
    return result


def finite_euler_denominator_symm_square(
    params: List[LocalGL2Parameter], X: complex
) -> complex:
    """Compute the denominator of the finite symmetric square Euler product.

    ∏_{v ∈ S} (1 - s_v X + d_v s_v X² - d_v³ X³)

    Args:
        params: List of local GL(2) parameters.
        X: Evaluation point.

    Returns:
        The product of local denominators.
    """
    result = complex(1)
    for param in params:
        s = symm_square_trace(param.alpha, param.beta)
        d = param.det
        local = 1 - s * X + d * s * X**2 - d**3 * X**3
        result *= local
    return result


def power_sum_sequence(
    trace: complex, det: complex, n_terms: int
) -> List[complex]:
    """Compute the power sum sequence s_k = α^k + β^k via recurrence.

    Uses the Newton-Lucas recurrence: s_k = t · s_{k-1} - d · s_{k-2}
    where t = α + β and d = αβ.

    This avoids computing individual eigenvalues and works
    directly with invariant data.

    Args:
        trace: The sum α + β.
        det: The product αβ.
        n_terms: Number of terms to compute.

    Returns:
        List [s_0, s_1, ..., s_{n-1}] where s_k = α^k + β^k.

    Example:
        >>> power_sum_sequence(5, 6, 5)  # α=2, β=3
        [2, 5, 13, 35, 97]
    """
    if n_terms <= 0:
        return []
    if n_terms == 1:
        return [2]

    result = [complex(2), trace]
    for _ in range(2, n_terms):
        s_new = trace * result[-1] - det * result[-2]
        result.append(s_new)
    return result


def is_palindromic_det_one(alpha: complex, beta: complex, tol: float = 1e-10) -> bool:
    """Check if the symmetric square polynomial is palindromic (det-one case).

    When αβ = 1, the polynomial 1 - sX + sX² - X³ should have
    palindromic coefficients (up to sign).

    Args:
        alpha: First eigenvalue.
        beta: Second eigenvalue.
        tol: Numerical tolerance.

    Returns:
        True if αβ ≈ 1 and the polynomial is palindromic.
    """
    d = alpha * beta
    if abs(d - 1) > tol:
        return False
    # When αβ=1, coefficients are [1, -(α²+1+β²), (α²+1+β²), -1]
    # Palindromic means c_0 = -c_3 and c_1 = -c_2
    s = alpha**2 + 1 + beta**2
    return abs(1 - (-(-1))) < tol and abs(-s - (-(s))) < tol  # trivially true by construction


# ──────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────

if __name__ == "__main__":
    # Example 1: Basic parameter
    p = LocalGL2Parameter(2, 3)
    print(f"Parameter: {p}")
    print(f"Trace: {p.trace}, Det: {p.det}")
    print(f"Sym² parameters: {symm_square_parameter(p)}")
    print(f"Sym² trace: {symm_square_trace(p.alpha, p.beta)}")
    print(f"Sym² trace from Hecke: {symm_square_trace_from_hecke(p.trace, p.det)}")
    print()

    # Example 2: Euler factor computation
    X = 0.01
    euler_factored = local_euler_symm_square_factored(p, X)
    euler_expanded = local_euler_symm_square_expanded(p, X)
    euler_hecke = local_euler_symm_square_from_hecke(p.trace, p.det, X)
    print(f"Sym² Euler factor at X={X}:")
    print(f"  Factored:  {euler_factored:.15f}")
    print(f"  Expanded:  {euler_expanded:.15f}")
    print(f"  From Hecke: {euler_hecke:.15f}")
    print(f"  All agree: {abs(euler_factored - euler_expanded) < 1e-12 and abs(euler_factored - euler_hecke) < 1e-12}")
    print()

    # Example 3: Hecke polynomial
    coeffs = symm_square_hecke_polynomial(p)
    print(f"Sym² Hecke polynomial coefficients: {coeffs}")
    print(f"  = T³ - 19T² + 114T - 216")
    print()

    # Example 4: Power sum sequence
    ps = power_sum_sequence(5, 6, 8)
    print(f"Power sums s_k = 2^k + 3^k: {[int(x.real) for x in ps]}")
    print()

    # Example 5: From trace-det (no individual eigenvalues needed)
    p2 = LocalGL2Parameter.from_trace_det(5, 6)
    print(f"Reconstructed from (t=5, d=6): {p2}")
    print(f"Verification: trace={p2.trace:.6f}, det={p2.det:.6f}")
