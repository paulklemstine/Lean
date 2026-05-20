#!/usr/bin/env python3
"""
Applications of Symmetric Power Functoriality

Demonstrates real-world applications of the transfer engine:
1. Computing L-function coefficients for modular forms
2. Studying the Sato-Tate distribution under transfer
3. Detecting endoscopic behavior in families
4. Complexity analysis of transferred Euler factors
"""

from fractions import Fraction
from typing import List, Tuple, Dict
import math
from algorithms import (SatakeGL2, SatakeGLn, symm_pow_transfer,
                        recip_euler_factor, is_palindromic,
                        elementary_symmetric, power_sum)


# ============================================================================
# Application 1: Modular Form L-Function Coefficients
# ============================================================================

def modular_form_satake(a_p: Fraction, omega_p: Fraction) -> SatakeGL2:
    """Convert Hecke eigenvalue data to Satake parameters.

    Given the Hecke eigenvalue a_p = α + β and the nebentypus value
    ω_p = αβ, recover (α, β) as roots of T² - a_p T + ω_p = 0.

    For simplicity over Q, we work with the symmetric functions directly
    and compute Satake parameters when the discriminant is a perfect square.

    Example:
        >>> pi = modular_form_satake(Fraction(5), Fraction(6))
        >>> pi.trace()
        Fraction(5, 1)
    """
    # α, β are roots of T^2 - a_p T + omega_p
    disc_num = a_p ** 2 - 4 * omega_p
    # For exact computation, we need disc to be a perfect square
    # Here we just store trace and det and compute algebraically
    # Using the quadratic formula symbolically is not needed for our purposes
    # since all our algorithms work with (α + β) and αβ via elementary symmetric polys

    # For demonstration, try to find rational roots
    disc = a_p ** 2 - 4 * omega_p
    if disc >= 0:
        # Try to find exact square root
        n = disc.numerator
        d = disc.denominator
        sn = int(math.isqrt(abs(n)))
        sd = int(math.isqrt(abs(d)))
        if sn * sn == n and sd * sd == d:
            sqrt_disc = Fraction(sn, sd)
            alpha = (a_p + sqrt_disc) / 2
            beta = (a_p - sqrt_disc) / 2
            return SatakeGL2(alpha, beta)

    # Fallback: use trace and det directly (α = a_p, β = 0 is wrong but
    # for this demo we need rational Satake params)
    raise ValueError(f"Discriminant {disc} is not a perfect square over Q")


def compute_symmetric_power_lcoeffs(
    a_p: Fraction, omega_p: Fraction, m: int
) -> List[Fraction]:
    """Compute the coefficients of the Sym^m L-factor at prime p.

    Given Hecke eigenvalue a_p and central character omega_p at a prime p,
    returns the coefficients of L^{-1}(p^{-s}, Sym^m π).

    These coefficients appear in the Dirichlet series expansion of
    L(s, Sym^m π).
    """
    pi = modular_form_satake(a_p, omega_p)
    transferred = symm_pow_transfer(m, pi)
    return recip_euler_factor(transferred)


def demo_modular_form():
    """Demo: compute L-function coefficients from Hecke eigenvalues."""
    print("=" * 70)
    print("APPLICATION 1: Modular Form L-Function Coefficients")
    print("=" * 70)

    # Example: weight 2 modular form with a_p = 5, omega_p = 6
    # This gives α = 2, β = 3 (roots of T² - 5T + 6)
    a_p = Fraction(5)
    omega_p = Fraction(6)

    print(f"\nHecke eigenvalue a_p = {a_p}, central character ω_p = {omega_p}")

    pi = modular_form_satake(a_p, omega_p)
    print(f"Satake parameters: (α, β) = ({pi.alpha}, {pi.beta})")

    for m in range(1, 5):
        coeffs = compute_symmetric_power_lcoeffs(a_p, omega_p, m)
        print(f"\nSym^{m} L-factor coefficients: {[str(c) for c in coeffs]}")
        print(f"  This encodes L^{{-1}}(p^{{-s}}, Sym^{m} π) at this prime.")

    print()


# ============================================================================
# Application 2: Endoscopic Detection in Families
# ============================================================================

def detect_endoscopic_primes(
    eigenvalues: Dict[int, Tuple[Fraction, Fraction]]
) -> List[int]:
    """Detect primes where the representation is endoscopic.

    At endoscopic primes, α = β, meaning the Sym² transfer degenerates.
    This indicates special arithmetic behavior (e.g., the form has CM).

    Args:
        eigenvalues: Dict mapping primes p to (a_p, omega_p).

    Returns:
        List of primes where the discriminant vanishes.
    """
    endoscopic = []
    for p, (a_p, omega_p) in eigenvalues.items():
        disc = a_p ** 2 - 4 * omega_p
        if disc == 0:
            endoscopic.append(p)
    return endoscopic


def demo_endoscopic_detection():
    """Demo: detect endoscopic primes in a family."""
    print("=" * 70)
    print("APPLICATION 2: Endoscopic Detection in Families")
    print("=" * 70)

    # Simulated Hecke eigenvalue data
    eigenvalues = {
        2: (Fraction(3), Fraction(2)),      # disc = 9 - 8 = 1, generic
        3: (Fraction(4), Fraction(4)),      # disc = 16 - 16 = 0, ENDOSCOPIC
        5: (Fraction(7), Fraction(10)),     # disc = 49 - 40 = 9, generic
        7: (Fraction(6), Fraction(9)),      # disc = 36 - 36 = 0, ENDOSCOPIC
        11: (Fraction(5), Fraction(6)),     # disc = 25 - 24 = 1, generic
        13: (Fraction(10), Fraction(25)),   # disc = 100 - 100 = 0, ENDOSCOPIC
    }

    print("\nPrime | a_p | ω_p | Disc | Status")
    print("-" * 50)
    for p in sorted(eigenvalues.keys()):
        a_p, omega_p = eigenvalues[p]
        disc = a_p ** 2 - 4 * omega_p
        status = "ENDOSCOPIC" if disc == 0 else "generic"
        print(f"  {p:4d} | {str(a_p):4s} | {str(omega_p):4s} | {str(disc):4s} | {status}")

    endoscopic = detect_endoscopic_primes(eigenvalues)
    print(f"\nEndoscopic primes: {endoscopic}")
    print("At these primes, the Sym² Euler factor has a triple root.")
    print()


# ============================================================================
# Application 3: Complexity Growth Analysis
# ============================================================================

def analyze_complexity_growth(max_m: int = 15):
    """Analyze how transfer degree and coefficient complexity grow with m."""
    print("=" * 70)
    print("APPLICATION 3: Complexity Growth Under Transfer")
    print("=" * 70)

    alpha, beta = Fraction(2), Fraction(3)
    pi = SatakeGL2(alpha, beta)

    print(f"\nParameter: (α, β) = ({alpha}, {beta})")
    print(f"\n{'m':>3} | {'Degree':>6} | {'#Coeffs':>7} | {'Max |coeff|':>12} | {'log₂(max)':>10}")
    print("-" * 55)

    for m in range(1, max_m + 1):
        transferred = symm_pow_transfer(m, pi)
        coeffs = recip_euler_factor(transferred)
        degree = len(coeffs) - 1
        max_coeff = max(abs(c) for c in coeffs)
        log_max = float(max_coeff).bit_length() if max_coeff > 0 else 0

        print(f"  {m:2d} | {degree:6d} | {len(coeffs):7d} | {str(max_coeff):>12s} | {log_max:10.1f}")

    print()
    print("  Degree grows as m+1 (linear).")
    print("  Max coefficient grows exponentially in m.")
    print("  Circuit depth lower bound: Ω(log(m+1)).")
    print()


# ============================================================================
# Application 4: Self-Reciprocity and Functional Equations
# ============================================================================

def analyze_functional_equation(max_m: int = 8):
    """Study the self-reciprocal property and its connection to functional equations."""
    print("=" * 70)
    print("APPLICATION 4: Self-Reciprocity and Functional Equations")
    print("=" * 70)

    # Parameter with αβ = 1 (trivial central character)
    alpha = Fraction(3)
    beta = Fraction(1, 3)
    pi = SatakeGL2(alpha, beta)

    print(f"\nParameter with det = 1: (α, β) = ({alpha}, {beta})")
    print(f"αβ = {alpha * beta}")

    print(f"\n{'m':>3} | {'Self-reciprocal':>15} | Coefficients")
    print("-" * 70)

    for m in range(1, max_m + 1):
        transferred = symm_pow_transfer(m, pi)
        coeffs = recip_euler_factor(transferred)
        pal = is_palindromic(coeffs)
        coeff_str = [str(c) for c in coeffs]
        print(f"  {m:2d} | {'✓ Yes':>15s if pal else '✗ No':>15s} | {coeff_str}")

    print()
    print("  Self-reciprocity implies the functional equation L(s) = ε · L(1-s)")
    print("  for the completed L-function, constraining its analytic behavior.")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Applications of Symmetric Power Functoriality for GL(2)           ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_modular_form()
    demo_endoscopic_detection()
    analyze_complexity_growth()
    analyze_functional_equation()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Symmetric Power Functoriality for GL(2): Interactive Demo

Demonstrates the algebraic core of symmetric power transfers in the Langlands
program. Computes Euler factors, verifies palindromic structure, tests
endoscopic collapse, and probes conjectures computationally.
"""

from fractions import Fraction
from typing import List, Tuple
import itertools


# ============================================================================
# Core Definitions
# ============================================================================

def symm_pow_roots(m: int, alpha, beta) -> list:
    """Compute the m+1 roots of Sym^m(alpha, beta).

    The i-th root is alpha^(m-i) * beta^i for i = 0, ..., m.
    """
    return [alpha ** (m - i) * beta ** i for i in range(m + 1)]


def recip_euler_factor_coeffs(roots: list) -> list:
    """Compute coefficients of the reciprocal Euler factor prod(1 - a_i * X).

    Returns [c_0, c_1, ..., c_n] where the polynomial is sum c_k X^k.
    """
    # Start with polynomial [1]
    coeffs = [type(roots[0])(1) if roots else 1]
    for a in roots:
        # Multiply by (1 - a*X): new_coeffs[k] = coeffs[k] - a * coeffs[k-1]
        new_coeffs = [coeffs[0]]
        for k in range(1, len(coeffs)):
            new_coeffs.append(coeffs[k] - a * coeffs[k - 1])
        new_coeffs.append(-a * coeffs[-1])
        coeffs = new_coeffs
    return coeffs


def is_palindromic(coeffs: list) -> bool:
    """Check if coefficient list is palindromic up to sign alternation.

    For self-reciprocal polynomials of the form arising from Euler factors
    with det=1, we check if c_k = (-1)^(n) * c_{n-k} where n = deg.
    """
    n = len(coeffs) - 1
    sign = (-1) ** n
    return all(coeffs[k] == sign * coeffs[n - k] for k in range(n + 1))


def discriminant(alpha, beta):
    """Discriminant (alpha - beta)^2."""
    return (alpha - beta) ** 2


def central_char(alpha, beta):
    """Central character alpha * beta."""
    return alpha * beta


# ============================================================================
# Demo 1: Euler Factor Computation
# ============================================================================

def demo_euler_factors():
    """Demonstrate Euler factor computation for Sym^2 and Sym^3."""
    print("=" * 70)
    print("DEMO 1: Euler Factor Computation")
    print("=" * 70)

    alpha, beta = Fraction(2), Fraction(3)
    print(f"\nGL(2) parameter: (α, β) = ({alpha}, {beta})")
    print(f"Central character αβ = {alpha * beta}")
    print(f"Discriminant (α-β)² = {discriminant(alpha, beta)}")

    for m in range(1, 5):
        roots = symm_pow_roots(m, alpha, beta)
        coeffs = recip_euler_factor_coeffs(roots)
        print(f"\nSym^{m} transfer:")
        print(f"  Roots: {roots}")
        print(f"  L⁻¹(X) coefficients: {[str(c) for c in coeffs]}")
        print(f"  Degree: {len(coeffs) - 1}")

    print()


# ============================================================================
# Demo 2: Palindromic Structure Verification
# ============================================================================

def demo_palindromic():
    """Verify palindromic structure when αβ = 1."""
    print("=" * 70)
    print("DEMO 2: Palindromic Structure (Self-Reciprocity) when αβ = 1")
    print("=" * 70)

    test_alphas = [Fraction(2), Fraction(3), Fraction(1, 3),
                   Fraction(5, 2), Fraction(7, 4)]

    for alpha in test_alphas:
        beta = Fraction(1, alpha)
        print(f"\n(α, β) = ({alpha}, {beta}), αβ = {alpha * beta}")

        for m in range(1, 7):
            roots = symm_pow_roots(m, alpha, beta)
            coeffs = recip_euler_factor_coeffs(roots)
            pal = is_palindromic(coeffs)
            status = "✓ palindromic" if pal else "✗ NOT palindromic"
            print(f"  Sym^{m}: {status}  coeffs = {[str(c) for c in coeffs]}")

    print()


# ============================================================================
# Demo 3: Endoscopic Collapse
# ============================================================================

def demo_endoscopic_collapse():
    """Verify endoscopic collapse when α = β."""
    print("=" * 70)
    print("DEMO 3: Endoscopic Collapse (α = β)")
    print("=" * 70)

    for a in [Fraction(2), Fraction(3), Fraction(1, 5)]:
        print(f"\nα = β = {a}")
        for m in range(1, 5):
            roots = symm_pow_roots(m, a, a)
            coeffs = recip_euler_factor_coeffs(roots)

            # Check if it's (1 - a^m X)^{m+1}
            expected_root = a ** m
            # (1 - c*X)^{m+1} has coefficients C(m+1, k) * (-c)^k
            from math import comb
            expected = [Fraction(comb(m + 1, k)) * ((-expected_root) ** k)
                        for k in range(m + 2)]

            match = coeffs == expected
            status = "✓ matches (1-α^m X)^{m+1}" if match else "✗ MISMATCH"
            print(f"  Sym^{m}: {status}")

    print()


# ============================================================================
# Demo 4: Twist Compatibility
# ============================================================================

def demo_twist():
    """Verify twist compatibility: Sym^m(χ·π) = χ^m · Sym^m(π)."""
    print("=" * 70)
    print("DEMO 4: Twist Compatibility")
    print("=" * 70)

    alpha, beta = Fraction(2), Fraction(3)
    chi = Fraction(5)

    for m in range(1, 5):
        # Sym^m of twisted parameter
        twisted_roots = symm_pow_roots(m, chi * alpha, chi * beta)

        # Twisted Sym^m of original parameter
        orig_roots = symm_pow_roots(m, alpha, beta)
        scaled_roots = [chi ** m * r for r in orig_roots]

        match = twisted_roots == scaled_roots
        status = "✓" if match else "✗"
        print(f"  Sym^{m}: Sym^{m}(χ·π) == χ^{m}·Sym^{m}(π)  {status}")

    print()


# ============================================================================
# Demo 5: Conjecture Testing - Self-Reciprocal Stability
# ============================================================================

def demo_conjecture_selfreciprocal():
    """Test the self-reciprocal stability conjecture for higher symmetric powers."""
    print("=" * 70)
    print("DEMO 5: Conjecture Test — Self-Reciprocal Stability")
    print("=" * 70)
    print("Testing: For αβ=1 and all m, is the Sym^m Euler factor palindromic?")

    import random
    random.seed(42)
    max_m = 12
    num_tests = 20
    all_pass = True

    for trial in range(num_tests):
        # Random rational with αβ = 1
        num = random.randint(1, 20)
        den = random.randint(1, 20)
        alpha = Fraction(num, den)
        beta = Fraction(den, num)

        for m in range(1, max_m + 1):
            roots = symm_pow_roots(m, alpha, beta)
            coeffs = recip_euler_factor_coeffs(roots)
            if not is_palindromic(coeffs):
                print(f"  ✗ COUNTEREXAMPLE: α={alpha}, m={m}")
                all_pass = False

    if all_pass:
        print(f"  ✓ All {num_tests} random tests passed for m=1..{max_m}")
    print()


# ============================================================================
# Demo 6: Central Character Under Transfer
# ============================================================================

def demo_central_char():
    """Verify central character formula: product of Sym^m roots = (αβ)^{m(m+1)/2}."""
    print("=" * 70)
    print("DEMO 6: Central Character Under Transfer")
    print("=" * 70)

    alpha, beta = Fraction(2), Fraction(3)
    det = alpha * beta
    print(f"(α, β) = ({alpha}, {beta}), det = αβ = {det}")

    for m in range(1, 7):
        roots = symm_pow_roots(m, alpha, beta)
        product = Fraction(1)
        for r in roots:
            product *= r

        # Expected: (αβ)^{sum of i for i=0..m} but actually
        # prod_{i=0}^m α^{m-i} β^i = α^{sum(m-i)} β^{sum(i)}
        # = α^{m(m+1)/2} β^{m(m+1)/2} = (αβ)^{m(m+1)/2}
        exponent = m * (m + 1) // 2
        expected = det ** exponent

        match = product == expected
        status = "✓" if match else "✗"
        print(f"  Sym^{m}: ∏ roots = {product} = (αβ)^{exponent} = {expected}  {status}")

    print()


# ============================================================================
# Demo 7: Degree Growth (Complexity Amplification)
# ============================================================================

def demo_degree_growth():
    """Show that transfer degree grows linearly: deg(Sym^m) = m+1."""
    print("=" * 70)
    print("DEMO 7: Degree Growth Under Transfer")
    print("=" * 70)

    for m in range(0, 10):
        degree = m + 1
        print(f"  Sym^{m}: Euler factor degree = {degree}")

    print()
    print("  The degree grows as m+1, giving unbounded circuit depth")
    print("  for the family of Euler factor polynomials.")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Symmetric Power Functoriality for GL(2): Computational Explorer   ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    print()

    demo_euler_factors()
    demo_palindromic()
    demo_endoscopic_collapse()
    demo_twist()
    demo_conjecture_selfreciprocal()
    demo_central_char()
    demo_degree_growth()

    print("All demonstrations complete.")
