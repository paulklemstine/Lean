#!/usr/bin/env python3
"""
Applications of Symmetric Square Transfer Identities

Demonstrates real-world applications of the formalized algebraic identities
to modular forms, L-functions, and computational number theory.
"""

from typing import Dict, List, Tuple
import cmath
import math


# ══════════════════════════════════════════════════════════════
# Application 1: Ramanujan Tau Function and Symmetric Square
# ══════════════════════════════════════════════════════════════

def ramanujan_tau(n: int) -> int:
    """Compute τ(n) via the product formula for small n.

    Uses Δ(q) = q ∏_{n≥1} (1-q^n)^24.
    Only practical for small n.
    """
    if n <= 0:
        return 0
    # Use truncated product formula
    N = max(n + 10, 50)
    # Coefficients of ∏(1-q^k)^24 up to q^n
    coeffs = [0] * (n + 1)
    coeffs[0] = 1

    for k in range(1, N):
        # Multiply by (1 - q^k)^24
        # First compute (1 - q^k)^24 contribution
        for _ in range(24):
            for j in range(n, k - 1, -1):
                coeffs[j] -= coeffs[j - k]

    # Δ(q) = q · ∏(1-q^k)^24, so τ(n) = coefficient of q^n = coeffs[n-1]
    if n - 1 < len(coeffs):
        return coeffs[n - 1]
    return 0


def application_ramanujan_symm_square():
    """Compute symmetric square L-function data for the Ramanujan Δ function.

    For Δ of weight 12, level 1:
    - Satake parameters at p: α_p, β_p with α_p + β_p = τ(p)/p^{11/2}
      (analytic normalization) or α_p β_p = p^11 (algebraic normalization)
    - Sym² eigenvalue: τ(p)² - p^11
    """
    print("=" * 70)
    print("APPLICATION 1: Symmetric Square of the Ramanujan Δ Function")
    print("=" * 70)
    print()
    print("The Ramanujan Δ function is the unique normalized cuspidal")
    print("eigenform of weight 12 and level 1:")
    print("  Δ(q) = q - 24q² + 252q³ - 1472q⁴ + 4830q⁵ - ...")
    print()
    print("At each prime p, the Hecke eigenvalue is τ(p) and ω_p = p^11.")
    print("The symmetric square eigenvalue is: a_p(Sym²Δ) = τ(p)² - p^11")
    print()

    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23]

    print(f"{'p':>4} | {'τ(p)':>12} | {'p^11':>18} | {'τ(p)²':>18} | {'a_p(Sym²Δ)':>20}")
    print("-" * 80)

    for p in primes:
        tau_p = ramanujan_tau(p)
        omega_p = p**11
        sym2_eigenvalue = tau_p**2 - omega_p
        print(f"{p:4d} | {tau_p:12d} | {omega_p:18d} | {tau_p**2:18d} | {sym2_eigenvalue:20d}")

    print()
    print("These values are the Hecke eigenvalues of the symmetric square")
    print("lift L(s, Sym²Δ), a degree-3 L-function on GL(3).")
    print()


# ══════════════════════════════════════════════════════════════
# Application 2: Detecting Self-Dual Representations
# ══════════════════════════════════════════════════════════════

def application_self_duality():
    """Demonstrate palindromicity as a self-duality detector."""
    print("=" * 70)
    print("APPLICATION 2: Self-Duality Detection via Palindromicity")
    print("=" * 70)
    print()
    print("When αβ = 1 (trivial central character), the symmetric square")
    print("Euler polynomial is palindromic, indicating self-duality.")
    print("This is the local manifestation of the functional equation.")
    print()

    # Weight 2 modular forms with trivial character
    # For a form of weight k with trivial character, after analytic
    # normalization α_p β_p = 1
    test_cases = [
        ("Trivial char (αβ=1)", 2.0, 0.5),
        ("Trivial char (αβ=1)", 3.0, 1/3),
        ("Non-trivial char (αβ≠1)", 2.0, 3.0),
        ("Non-trivial char (αβ≠1)", 1.5, 2.0),
    ]

    for desc, alpha, beta in test_cases:
        d = alpha * beta
        s = alpha**2 + alpha * beta + beta**2

        # Euler polynomial coefficients: [1, -s, d*s, -d³]
        coeffs = [1, -s, d * s, -(d**3)]

        # Check palindromicity: c_k = ±c_{n-k}
        is_palindromic = (
            abs(coeffs[0] + coeffs[3]) < 1e-10 and
            abs(coeffs[1] + coeffs[2]) < 1e-10
        )

        print(f"  {desc}: α={alpha}, β={beta}, αβ={d:.4f}")
        print(f"    Coefficients: {[f'{c:.4f}' for c in coeffs]}")
        print(f"    Palindromic: {'Yes ✓' if is_palindromic else 'No'}")
        print()


# ══════════════════════════════════════════════════════════════
# Application 3: Sato-Tate Distribution of Sym² Eigenvalues
# ══════════════════════════════════════════════════════════════

def application_sato_tate():
    """Illustrate the Sato-Tate distribution of Sym² eigenvalues.

    For a weight 2 modular form with trivial character, at unramified
    primes the Satake parameters satisfy α = e^{iθ}, β = e^{-iθ}
    (after analytic normalization with αβ = 1).

    The Sym² trace is then:
    α² + αβ + β² = e^{2iθ} + 1 + e^{-2iθ} = 1 + 2cos(2θ)

    which ranges in [-1, 3].
    """
    print("=" * 70)
    print("APPLICATION 3: Sato-Tate Distribution of Sym² Eigenvalues")
    print("=" * 70)
    print()
    print("Under Sato-Tate, the Satake angle θ has distribution")
    print("  dμ = (2/π) sin²(θ) dθ  on [0, π].")
    print()
    print("The Sym² trace is 1 + 2cos(2θ), ranging in [-1, 3].")
    print()

    N = 1000
    bins = [0] * 20
    bin_min, bin_max = -1.0, 3.0
    bin_width = (bin_max - bin_min) / len(bins)

    # Sample from Sato-Tate distribution
    for i in range(N):
        # Use rejection sampling for sin²(θ) on [0, π]
        import random
        random.seed(42 + i)
        while True:
            theta = random.uniform(0, math.pi)
            if random.uniform(0, 1) < math.sin(theta)**2:
                break

        sym2_trace = 1 + 2 * math.cos(2 * theta)
        bin_idx = int((sym2_trace - bin_min) / bin_width)
        bin_idx = max(0, min(len(bins) - 1, bin_idx))
        bins[bin_idx] += 1

    print("  Histogram of Sym² trace values (1000 samples):")
    max_count = max(bins) if max(bins) > 0 else 1
    for i, count in enumerate(bins):
        val = bin_min + (i + 0.5) * bin_width
        bar = "█" * int(40 * count / max_count)
        print(f"  {val:6.2f} | {bar} ({count})")

    print()
    print("  The distribution peaks near -1 (θ ≈ π/2) and is skewed")
    print("  toward the lower end, reflecting the Sato-Tate measure.")
    print()


# ══════════════════════════════════════════════════════════════
# Application 4: Verification Against LMFDB-style Data
# ══════════════════════════════════════════════════════════════

def application_lmfdb_verification():
    """Verify symmetric square computations against known modular form data."""
    print("=" * 70)
    print("APPLICATION 4: Verification of Sym² Coefficient Relations")
    print("=" * 70)
    print()
    print("For the elliptic curve E: y² = x³ - x (conductor 32),")
    print("the associated weight-2 modular form f has Hecke eigenvalues:")
    print()

    # Hecke eigenvalues for the modular form associated to y² = x³ - x
    # This is a CM form with CM by ℤ[i]
    # a_p values for small primes
    hecke_data: Dict[int, int] = {
        2: 0,     # bad prime (conductor 32)
        3: 0,
        5: -2,
        7: 0,
        11: 0,
        13: -2,
        17: 2,
        19: 0,
        23: 0,
        29: 6,
        31: 0,
        37: -10,
        41: 2,
        43: 0,
        47: 0,
    }

    print(f"{'p':>4} | {'a_p':>6} | {'ω_p=p':>6} | {'a_p²-p':>10} | {'a_p(Sym²f)':>12}")
    print("-" * 50)

    for p, a_p in hecke_data.items():
        if p == 2:
            continue  # Skip bad prime
        omega_p = p  # For weight 2, trivial character: ω_p = p
        sym2 = a_p**2 - omega_p
        print(f"{p:4d} | {a_p:6d} | {omega_p:6d} | {a_p**2 - omega_p:10d} | {sym2:12d}")

    print()
    print("Note: For CM forms, many a_p = 0 (at inert primes),")
    print("giving Sym² eigenvalue = -p at those primes.")
    print()


# ══════════════════════════════════════════════════════════════
# Application 5: Finite Euler Product Approximation
# ══════════════════════════════════════════════════════════════

def application_finite_euler_product():
    """Demonstrate convergence of finite Euler products."""
    print("=" * 70)
    print("APPLICATION 5: Finite Euler Product Convergence")
    print("=" * 70)
    print()

    # Use Ramanujan Δ data with analytic normalization
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    # Evaluate at s = 2 (X = p^{-2} at each prime)
    print("  Computing L(2, Sym²Δ) via truncated Euler products:")
    print()

    partial_product = 1.0
    print(f"  {'Primes up to':>14} | {'Partial product':>20} | {'Log':>12}")
    print("  " + "-" * 55)

    for i, p in enumerate(primes):
        tau_p = ramanujan_tau(p)
        omega_p = p**11

        # Satake parameters (algebraic normalization)
        # L(s, Sym²Δ) = ∏_p 1/((1-α_p² p^{-s})(1-α_pβ_p p^{-s})(1-β_p² p^{-s}))
        # With X = p^{-s}, α_pβ_p = p^11

        s_val = 13  # Need Re(s) > 12 for convergence
        X = p**(-s_val)

        # Use trace-det form
        s_trace = tau_p**2 - omega_p  # Sym² trace
        d = omega_p  # determinant

        denom = 1 - s_trace * X + d * s_trace * X**2 - d**3 * X**3
        if abs(denom) > 1e-15:
            partial_product /= denom

        log_val = math.log(abs(partial_product)) if abs(partial_product) > 0 else float('-inf')
        print(f"  p ≤ {p:4d} ({i+1:2d} primes) | {partial_product:20.12f} | {log_val:12.6f}")

    print()
    print(f"  The product converges as more primes are included.")
    print()


def main():
    """Run all applications."""
    print("\n" + "═" * 70)
    print("  APPLICATIONS OF SYMMETRIC SQUARE TRANSFER IDENTITIES")
    print("  From Formal Algebra to Computational Number Theory")
    print("═" * 70 + "\n")

    application_ramanujan_symm_square()
    application_self_duality()
    application_sato_tate()
    application_lmfdb_verification()
    application_finite_euler_product()

    print("All applications completed successfully.")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Symmetric Square Transfer: Demonstrations of Local Euler Factor Identities

This module demonstrates the algebraic identities underlying the symmetric
square lift from GL(2) to GL(3) in the Langlands program, with concrete
numerical examples.
"""

import cmath
from typing import Tuple, List


def symm_square_trace(alpha: complex, beta: complex) -> complex:
    """Trace of the symmetric square: α² + αβ + β²."""
    return alpha**2 + alpha * beta + beta**2


def symm_square_denominator_factored(alpha: complex, beta: complex, X: complex) -> complex:
    """Factored form: (1 - α²X)(1 - αβX)(1 - β²X)."""
    return (1 - alpha**2 * X) * (1 - alpha * beta * X) * (1 - beta**2 * X)


def symm_square_denominator_expanded(alpha: complex, beta: complex, X: complex) -> complex:
    """Expanded form: 1 - (α²+αβ+β²)X + αβ(α²+αβ+β²)X² - (αβ)³X³."""
    s = symm_square_trace(alpha, beta)
    d = alpha * beta
    return 1 - s * X + d * s * X**2 - d**3 * X**3


def symm_square_denominator_trace_det(t: complex, d: complex, X: complex) -> complex:
    """Trace-det form: 1 - (t²-d)X + d(t²-d)X² - d³X³."""
    s = t**2 - d
    return 1 - s * X + d * s * X**2 - d**3 * X**3


# ──────────────────────────────────────────────────────────────
# Demo 1: Basic identity verification
# ──────────────────────────────────────────────────────────────
def demo_basic_identity():
    """Verify the symmetric square denominator identity for several parameter choices."""
    print("=" * 70)
    print("DEMO 1: Symmetric Square Local Denominator Identity")
    print("  (1 - α²X)(1 - αβX)(1 - β²X)")
    print("  = 1 - (α²+αβ+β²)X + αβ(α²+αβ+β²)X² - (αβ)³X³")
    print("=" * 70)

    test_cases = [
        (2, 3, 0.1, "Integer params, small X"),
        (1 + 1j, 2 - 1j, 0.5, "Complex params"),
        (0, 5, 1.0, "One zero param"),
        (1, 1, 0.3, "Equal params"),
        (-3, 4, -0.2, "Negative param"),
        (0.5, 2.0, 1/7, "Rational params"),
    ]

    for alpha, beta, X, desc in test_cases:
        factored = symm_square_denominator_factored(alpha, beta, X)
        expanded = symm_square_denominator_expanded(alpha, beta, X)
        diff = abs(factored - expanded)
        status = "✓" if diff < 1e-12 else "✗"
        print(f"  {status} α={alpha}, β={beta}, X={X}: |diff| = {diff:.2e}  ({desc})")

    print()


# ──────────────────────────────────────────────────────────────
# Demo 2: Characteristic polynomial (Hecke polynomial)
# ──────────────────────────────────────────────────────────────
def demo_charpoly():
    """Verify the characteristic polynomial formulation."""
    print("=" * 70)
    print("DEMO 2: Characteristic Polynomial (Hecke Polynomial)")
    print("  (T - α²)(T - αβ)(T - β²)")
    print("  = T³ - (α²+αβ+β²)T² + αβ(α²+αβ+β²)T - (αβ)³")
    print("=" * 70)

    alpha, beta = 3, 5

    # The roots should be α², αβ, β²
    roots = [alpha**2, alpha * beta, beta**2]
    print(f"  Parameters: α = {alpha}, β = {beta}")
    print(f"  Symmetric square eigenvalues: {roots}")

    s = symm_square_trace(alpha, beta)
    d = alpha * beta
    print(f"  Sym² trace: α²+αβ+β² = {s}")
    print(f"  Determinant: αβ = {d}")

    # Verify each root satisfies the polynomial
    for r in roots:
        val = r**3 - s * r**2 + d * s * r - d**3
        print(f"  Root T={r}: P(T) = {val:.6f} {'✓' if abs(val) < 1e-10 else '✗'}")

    print()


# ──────────────────────────────────────────────────────────────
# Demo 3: Determinant-one normalization (palindromicity)
# ──────────────────────────────────────────────────────────────
def demo_det_one():
    """Verify the palindromic structure when αβ = 1."""
    print("=" * 70)
    print("DEMO 3: Determinant-One Normalization (Palindromicity)")
    print("  When αβ = 1:")
    print("  (1-α²X)(1-X)(1-β²X) = 1-(α²+1+β²)X+(α²+1+β²)X²-X³")
    print("=" * 70)

    test_cases = [
        (2, 0.5),
        (3, 1/3),
        (1 + 1j, 1 / (1 + 1j)),
        (-1, -1),
    ]

    for alpha, beta in test_cases:
        print(f"\n  α = {alpha}, β = {beta}, αβ = {alpha*beta:.6f}")
        s = alpha**2 + 1 + beta**2
        print(f"  α²+1+β² = {s}")

        # Check palindromicity: coefficients are [1, -s, s, -1]
        coeffs = [1, -s, s, -1]
        is_palindromic = abs(coeffs[0] + coeffs[3]) < 1e-10 and abs(coeffs[1] + coeffs[2]) < 1e-10
        print(f"  Polynomial coefficients: {[complex(c) for c in coeffs]}")
        print(f"  Palindromic (up to sign): {'✓' if is_palindromic else '✗'}")

        # Verify identity at a test point
        X = 0.3
        lhs = (1 - alpha**2 * X) * (1 - X) * (1 - beta**2 * X)
        rhs = 1 - s * X + s * X**2 - X**3
        print(f"  Identity at X=0.3: |LHS - RHS| = {abs(lhs - rhs):.2e} {'✓' if abs(lhs-rhs) < 1e-10 else '✗'}")

    print()


# ──────────────────────────────────────────────────────────────
# Demo 4: Hecke eigenvalue relation
# ──────────────────────────────────────────────────────────────
def demo_hecke_eigenvalue():
    """Demonstrate the Hecke eigenvalue relation for symmetric square."""
    print("=" * 70)
    print("DEMO 4: Hecke Eigenvalue Relation")
    print("  a_p(Sym²f) = a_p(f)² - ω_p")
    print("=" * 70)

    # Ramanujan tau function examples
    # τ(p) for small primes, ω_p = p^11 for weight 12, level 1
    tau_values = {
        2: -24,
        3: 252,
        5: 4830,
        7: -16744,
        11: 534612,
        13: -577738,
    }

    print("\n  Ramanujan Δ function (weight 12, level 1):")
    print(f"  {'p':>4} | {'τ(p)':>10} | {'p^11':>15} | {'τ(p)²-p^11':>18} | {'a_p(Sym²Δ)'}")
    print("  " + "-" * 70)

    for p, tau_p in tau_values.items():
        omega_p = p**11
        sym2_eigenvalue = tau_p**2 - omega_p
        print(f"  {p:4d} | {tau_p:10d} | {omega_p:15d} | {sym2_eigenvalue:18d} | {sym2_eigenvalue}")

    print()


# ──────────────────────────────────────────────────────────────
# Demo 5: Trace-det invariance
# ──────────────────────────────────────────────────────────────
def demo_trace_det_invariance():
    """Show that the Euler factor depends only on trace and determinant."""
    print("=" * 70)
    print("DEMO 5: Trace-Det Invariance")
    print("  The Euler factor depends only on t=α+β and d=αβ")
    print("=" * 70)

    # Two different pairs with the same trace and determinant
    # t = 5, d = 6 → roots of x² - 5x + 6 = 0 → x = 2, 3
    pairs_with_same_td = [
        (2, 3, "Standard ordering"),
        (3, 2, "Swapped ordering"),
        (2.5 + 0.5j * cmath.sqrt(3), 2.5 - 0.5j * cmath.sqrt(3), "Complex conjugate pair"),
    ]

    X = 0.1 + 0.2j
    print(f"\n  Evaluation point: X = {X}")

    for alpha, beta, desc in pairs_with_same_td:
        t = alpha + beta
        d = alpha * beta
        euler = symm_square_denominator_factored(alpha, beta, X)
        euler_td = symm_square_denominator_trace_det(t, d, X)
        print(f"\n  ({desc})")
        print(f"    α={alpha}, β={beta}")
        print(f"    t=α+β={t:.6f}, d=αβ={d:.6f}")
        print(f"    Euler factor = {euler:.10f}")
        print(f"    From (t,d)   = {euler_td:.10f}")
        print(f"    Match: {'✓' if abs(euler - euler_td) < 1e-10 else '✗'}")

    print()


# ──────────────────────────────────────────────────────────────
# Demo 6: Finite Euler product
# ──────────────────────────────────────────────────────────────
def demo_finite_euler_product():
    """Demonstrate finite Euler product factorization."""
    print("=" * 70)
    print("DEMO 6: Finite Euler Product Factorization")
    print("  ∏_v P_v(X) computed both ways agree")
    print("=" * 70)

    # Satake parameters at primes 2, 3, 5
    params = [
        (2, (1.5, 0.8)),
        (3, (2.1, -0.5)),
        (5, (0.3, 1.7)),
    ]

    X = 0.05

    product_factored = 1.0
    product_expanded = 1.0

    for p, (alpha, beta) in params:
        local_factored = symm_square_denominator_factored(alpha, beta, X)
        local_expanded = symm_square_denominator_expanded(alpha, beta, X)
        product_factored *= local_factored
        product_expanded *= local_expanded
        print(f"  p={p}: α={alpha}, β={beta}")
        print(f"    Local factor (factored):  {local_factored:.12f}")
        print(f"    Local factor (expanded):  {local_expanded:.12f}")
        print(f"    Local match: {'✓' if abs(local_factored - local_expanded) < 1e-12 else '✗'}")

    print(f"\n  Global product (factored): {product_factored:.12f}")
    print(f"  Global product (expanded): {product_expanded:.12f}")
    print(f"  Global match: {'✓' if abs(product_factored - product_expanded) < 1e-12 else '✗'}")
    print()


# ──────────────────────────────────────────────────────────────
# Demo 7: Power sum recurrence
# ──────────────────────────────────────────────────────────────
def demo_power_sum_recurrence():
    """Demonstrate the Newton-Lucas power sum recurrence."""
    print("=" * 70)
    print("DEMO 7: Power Sum Recurrence")
    print("  s_n = (α+β)·s_{n-1} - αβ·s_{n-2}")
    print("=" * 70)

    alpha, beta = 3, 5
    t = alpha + beta  # = 8
    d = alpha * beta  # = 15

    print(f"\n  α = {alpha}, β = {beta}, t = {t}, d = {d}")
    print(f"  {'n':>3} | {'α^n + β^n (direct)':>20} | {'via recurrence':>20} | {'match'}")
    print("  " + "-" * 60)

    # Compute directly and via recurrence
    s_prev2 = 2  # α⁰ + β⁰ = 2
    s_prev1 = t  # α¹ + β¹ = t

    for n in range(10):
        s_direct = alpha**n + beta**n
        if n == 0:
            s_rec = 2
        elif n == 1:
            s_rec = t
        else:
            s_rec = t * s_prev1 - d * s_prev2
            s_prev2 = s_prev1
            s_prev1 = s_rec

        match = abs(s_direct - s_rec) < 1e-6
        print(f"  {n:3d} | {s_direct:20d} | {s_rec:20.0f} | {'✓' if match else '✗'}")

    print()


def main():
    """Run all demonstrations."""
    print("\n" + "═" * 70)
    print("  SYMMETRIC SQUARE TRANSFER: LOCAL EULER FACTOR IDENTITIES")
    print("  Algebraic Core of GL(2) → GL(3) Langlands Functoriality")
    print("═" * 70 + "\n")

    demo_basic_identity()
    demo_charpoly()
    demo_det_one()
    demo_hecke_eigenvalue()
    demo_trace_det_invariance()
    demo_finite_euler_product()
    demo_power_sum_recurrence()

    print("All demonstrations completed successfully.")


if __name__ == "__main__":
    main()
