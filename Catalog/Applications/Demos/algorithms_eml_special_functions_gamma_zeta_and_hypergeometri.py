#!/usr/bin/env python3
"""
Algorithms for EML Special Functions: Gamma, Zeta, and Hypergeometric

Type-hinted implementations of the key mathematical objects and algorithms
studied in this research cycle.
"""

from typing import Callable, List, Tuple, Optional
import math
import cmath


# ============================================================
# EML Framework
# ============================================================

def eml(x: float, y: float) -> float:
    """
    The EML (exp-minus-log) function.

    eml(x, y) = exp(x) - log(y)

    This is the fundamental building block of the EML framework,
    combining exponential growth with logarithmic correction.

    Args:
        x: Exponential argument
        y: Logarithmic argument (must be positive)

    Returns:
        exp(x) - log(y)
    """
    if y <= 0:
        raise ValueError(f"y must be positive, got {y}")
    return math.exp(x) - math.log(y)


def eml_diag(z: float) -> float:
    """
    EML diagonal: eml(z, z) = exp(z) - log(z).

    The diagonal restriction captures the competition between
    exponential and logarithmic growth at the same point.
    """
    if z <= 0:
        raise ValueError(f"z must be positive, got {z}")
    return math.exp(z) - math.log(z)


def eml_gamma_transform(x: float) -> float:
    """
    EML-Gamma transform: exp(Γ(x)) - log(x).

    Measures the 'EML excess' of the Gamma function over logarithmic growth.
    """
    if x <= 0:
        raise ValueError(f"x must be positive, got {x}")
    return math.exp(math.gamma(x)) - math.log(x)


# ============================================================
# Pochhammer Symbol
# ============================================================

def pochhammer(a: complex, n: int) -> complex:
    """
    Rising Pochhammer symbol (a)_n = a(a+1)(a+2)···(a+n-1).

    Also known as the rising factorial. Satisfies:
    - (a)_0 = 1
    - (a)_{n+1} = (a)_n · (a + n)
    - (1)_n = n!

    The last identity is proved formally as pochhammer_one_eq_factorial.

    Args:
        a: Base parameter (complex)
        n: Number of factors (non-negative integer)

    Returns:
        The rising Pochhammer symbol (a)_n
    """
    if n < 0:
        raise ValueError(f"n must be non-negative, got {n}")
    result: complex = 1
    for k in range(n):
        result *= (a + k)
    return result


# ============================================================
# Gauss Hypergeometric Function
# ============================================================

def hypergeometric_2F1(
    a: complex, b: complex, c: complex, z: complex,
    max_terms: int = 200, tol: float = 1e-15
) -> complex:
    """
    Gauss hypergeometric function ₂F₁(a, b; c; z).

    Computed as the partial sum:
        ₂F₁(a,b;c;z) = Σ_{n=0}^{N} (a)_n (b)_n / ((c)_n · n!) · z^n

    Converges for |z| < 1 (radius of convergence = 1).

    Special cases (proved formally):
    - ₂F₁(a,b;c;0) = 1  (hypergeometric_at_zero)
    - ₂F₁(1,b;b;z) = 1/(1-z)  (hypergeometric_c_eq_b_partial)

    Args:
        a, b: Upper parameters
        c: Lower parameter (must not be a non-positive integer)
        z: Argument (|z| < 1 for convergence)
        max_terms: Maximum number of terms
        tol: Convergence tolerance

    Returns:
        Approximate value of ₂F₁(a,b;c;z)
    """
    result: complex = 0
    term: complex = 1  # (a)_0 * (b)_0 / ((c)_0 * 0!) * z^0 = 1

    for n in range(max_terms):
        result += term
        if abs(term) < tol and n > 0:
            break
        # Update: term_{n+1} = term_n * (a+n)(b+n) / ((c+n)(n+1)) * z
        term *= (a + n) * (b + n) / ((c + n) * (n + 1)) * z

    return result


# ============================================================
# Gauss Hypergeometric ODE
# ============================================================

class GaussHypergeometricODE:
    """
    The Gauss hypergeometric differential equation:
        z(1-z)y'' + [c - (a+b+1)z]y' - ab·y = 0

    This is the prototype EML differential equation, with:
    - p(z) = z(1-z)     [coefficient of y'']
    - q(z) = c-(a+b+1)z [coefficient of y']
    - r(z) = -ab         [coefficient of y]

    Regular singular points at z = 0, 1, ∞ (proved: gauss_ode_regular_singular).
    The regularity at z=0 is witnessed by lim_{z→0} z·q(z)/p(z) = c
    (proved: gauss_ode_q_bounded_at_zero).
    """

    def __init__(self, a: float, b: float, c: float):
        self.a = a
        self.b = b
        self.c = c

    def p(self, z: float) -> float:
        """Coefficient of y'': z(1-z)"""
        return z * (1 - z)

    def q(self, z: float) -> float:
        """Coefficient of y': c - (a+b+1)z"""
        return self.c - (self.a + self.b + 1) * z

    def r(self, z: float) -> float:
        """Coefficient of y: -ab"""
        return -(self.a * self.b)

    def singular_points(self) -> List[float]:
        """
        Returns the finite singular points of the ODE.
        These are the zeros of p(z) = z(1-z): z = 0 and z = 1.
        """
        return [0.0, 1.0]

    def is_regular_at(self, z0: float, eps: float = 1e-8) -> bool:
        """
        Check if z0 is a regular singular point.
        A singular point z0 is regular if:
          lim_{z→z0} (z-z0)·q(z)/p(z) is finite
        """
        z = z0 + eps
        if abs(self.p(z)) < 1e-14:
            return False
        ratio = (z - z0) * self.q(z) / self.p(z)
        return abs(ratio) < 1e8

    def indicial_exponents(self, z0: float) -> Tuple[complex, complex]:
        """
        Compute the indicial exponents at a regular singular point z0.
        For z0 = 0: exponents are 0 and 1-c.
        For z0 = 1: exponents are 0 and c-a-b.
        """
        if abs(z0) < 1e-10:
            return (0, 1 - self.c)
        elif abs(z0 - 1) < 1e-10:
            return (0, self.c - self.a - self.b)
        else:
            raise ValueError(f"{z0} is not a singular point")


# ============================================================
# Growth Comparison Algorithm
# ============================================================

def growth_crossover(f: Callable[[float], float],
                     g: Callable[[float], float],
                     start: float = 1.0,
                     end: float = 20.0,
                     step: float = 0.1) -> Optional[float]:
    """
    Find the approximate crossover point where f(x) overtakes g(x).

    Returns the smallest x in [start, end] where f(x) > g(x),
    or None if no crossover is found.
    """
    x = start
    while x <= end:
        if f(x) > g(x):
            return x
        x += step
    return None


def gamma_vs_eml_crossover() -> Optional[float]:
    """
    Find where Γ(x) starts dominating emlDiag(x) = exp(x) - log(x).

    Formally proved that n! > exp(n) for n ≥ 6 (factorial_gt_exp_of_ge_six).
    The continuous crossover happens around x ≈ 8.
    """
    def gamma_func(x: float) -> float:
        return math.gamma(x)

    return growth_crossover(gamma_func, eml_diag, start=1.0, end=20.0, step=0.01)


# ============================================================
# Gamma Reflection Formula Verification
# ============================================================

def verify_reflection(x: float) -> Tuple[float, float, float]:
    """
    Verify the Gamma reflection formula: Γ(x)·Γ(1-x) = π/sin(πx).

    Proved formally as gamma_reflection_real.

    Returns:
        (lhs, rhs, relative_error)
    """
    lhs = math.gamma(x) * math.gamma(1 - x)
    rhs = math.pi / math.sin(math.pi * x)
    error = abs(lhs - rhs) / max(abs(rhs), 1e-15)
    return (lhs, rhs, error)


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("EML Special Functions — Algorithm Demonstrations")
    print("=" * 50)

    # Hypergeometric special values
    print("\n₂F₁ special values:")
    print(f"  ₂F₁(1/2, 1/2; 1; z) at z=0.5: {hypergeometric_2F1(0.5, 0.5, 1, 0.5):.10f}")
    print(f"  ₂F₁(1, 1; 2; z) at z=0.5:     {hypergeometric_2F1(1, 1, 2, 0.5):.10f}")
    print(f"  Expected -log(1-0.5)/0.5 = {-math.log(0.5)/0.5:.10f}")

    # Gauss ODE
    ode = GaussHypergeometricODE(0.5, 0.5, 1.0)
    print(f"\nGauss ODE (a=0.5, b=0.5, c=1):")
    print(f"  Singular points: {ode.singular_points()}")
    print(f"  Indicial exponents at 0: {ode.indicial_exponents(0)}")
    print(f"  Indicial exponents at 1: {ode.indicial_exponents(1)}")

    # Growth crossover
    crossover = gamma_vs_eml_crossover()
    print(f"\nΓ(x) > emlDiag(x) crossover at x ≈ {crossover:.2f}")
    print(f"  Γ({crossover:.2f}) ≈ {math.gamma(crossover):.2f}")
    print(f"  emlDiag({crossover:.2f}) ≈ {eml_diag(crossover):.2f}")

    # Reflection formula
    print("\nReflection formula verification:")
    for x in [0.25, 0.5, 0.75]:
        lhs, rhs, err = verify_reflection(x)
        print(f"  x={x}: error = {err:.2e}")
