#!/usr/bin/env python3
"""
Applications of the symmetric-cube trace-determinant identity.

Demonstrates real-world uses in:
1. Modular form L-function computation
2. Functorial lift verification
3. Hecke eigenvalue processing
4. Euler product partial sums
"""

import cmath
import math
from typing import List, Tuple


# ---------------------------------------------------------------------------
# Core computation (self-contained, no local imports)
# ---------------------------------------------------------------------------

def symm_cube_from_trace_det(t: complex, d: complex, X: complex) -> complex:
    """Sym³ Euler denominator from trace and determinant."""
    c1 = t**3 - 2 * t * d
    c2 = d * t**4 - 3 * d**2 * t**2 + 2 * d**3
    c3 = d**3 * c1
    c4 = d**6
    return 1 - c1 * X + c2 * X**2 - c3 * X**3 + c4 * X**4


def symm_cube_from_eigenvalues(alpha: complex, beta: complex, X: complex) -> complex:
    """Sym³ Euler denominator from explicit eigenvalues (for comparison)."""
    return (
        (1 - alpha**3 * X)
        * (1 - alpha**2 * beta * X)
        * (1 - alpha * beta**2 * X)
        * (1 - beta**3 * X)
    )


def symm_power_character(n: int, t: complex, d: complex) -> complex:
    """Character of Sym^n via recurrence."""
    if n == 0:
        return 1
    if n == 1:
        return t
    a, b = 1, t
    for _ in range(2, n + 1):
        a, b = b, t * b - d * a
    return b


# ---------------------------------------------------------------------------
# Application 1: Modular form Sym³ L-function
# ---------------------------------------------------------------------------

def ramanujan_tau(n: int) -> int:
    """
    Compute Ramanujan's tau function τ(n) for small n.
    τ(n) is the n-th Fourier coefficient of the modular discriminant Δ.
    """
    # Use the product formula: Δ = q ∏_{n≥1} (1-q^n)^24
    # We compute coefficients up to q^n
    if n < 1:
        return 0
    max_terms = n + 1
    coeffs = [0] * max_terms
    coeffs[0] = 1
    # Multiply by (1 - q^k)^24 for k = 1, ..., n
    for k in range(1, max_terms):
        # (1 - q^k)^24: use binomial expansion truncated
        # More efficient: multiply by (1-q^k) twenty-four times
        for _ in range(24):
            for j in range(max_terms - 1, k - 1, -1):
                coeffs[j] -= coeffs[j - k]
    # Δ = q · product, so τ(n) = coeffs[n-1]
    return coeffs[n - 1] if n - 1 < max_terms else 0


def modular_form_sym3_lfunction():
    """
    Compute the Sym³ L-function partial Euler product for the
    Ramanujan Δ function at s = 14 (well inside convergence region).
    """
    print("=" * 65)
    print("APPLICATION 1: Sym³ L-function of Ramanujan's Δ function")
    print("=" * 65)
    print()
    print("The Ramanujan Δ function is a weight-12 cusp form.")
    print("At each prime p, the Hecke eigenvalue is τ(p).")
    print("Satake parameters satisfy: t_p = τ(p)/p^{11/2}, d_p = 1.")
    print()

    # Small primes
    primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    print(f"{'p':>4} {'τ(p)':>10} {'t_p':>12} {'Sym³ factor':>20}")
    print("-" * 50)

    partial_product = 1.0
    s = 14.0  # Evaluation point

    for p in primes:
        tau_p = ramanujan_tau(p)
        t_p = tau_p / p ** (11 / 2)
        d_p = 1.0  # Trivial nebentypus
        X = p ** (-s)

        # Compute Sym³ local factor using trace-det formula
        local_denom = symm_cube_from_trace_det(t_p, d_p, X)
        local_factor = 1.0 / local_denom.real

        partial_product *= local_factor
        print(f"{p:4d} {tau_p:10d} {t_p:12.6f} {local_denom.real:20.15f}")

    print()
    print(f"Partial Euler product L(14, Sym³Δ) ≈ {partial_product:.15f}")
    print(f"(Using {len(primes)} primes)")
    print()

    # Show the speedup: no need to compute eigenvalues
    print("Key insight: We never computed α_p or β_p!")
    print("The trace-det formula gives the local factor directly from τ(p).")


# ---------------------------------------------------------------------------
# Application 2: Functorial lift verification
# ---------------------------------------------------------------------------

def verify_functorial_lift():
    """
    Verify that the Sym³ local factor computed from GL₂ data
    matches what a GL₄ functorial lift would produce.
    """
    print()
    print("=" * 65)
    print("APPLICATION 2: Functorial lift verification")
    print("=" * 65)
    print()
    print("Given GL₂ Satake parameters (α, β), the Sym³ lift to GL₄")
    print("has parameters (α³, α²β, αβ², β³).")
    print("We verify the GL₄ standard L-factor matches our formula.")
    print()

    test_cases = [
        (2.0, 3.0, "Real integers"),
        (1 + 1j, 2 - 1j, "Complex"),
        (cmath.exp(0.5j), cmath.exp(-0.3j), "Unit circle (tempered)"),
    ]

    for alpha, beta, desc in test_cases:
        t = alpha + beta
        d = alpha * beta
        X = 0.05

        # GL₂ method: use trace-det formula
        gl2_result = symm_cube_from_trace_det(t, d, X)

        # GL₄ method: standard L-factor with lifted parameters
        lifted = [alpha**3, alpha**2 * beta, alpha * beta**2, beta**3]
        gl4_result = 1.0
        for w in lifted:
            gl4_result *= (1 - w * X)

        error = abs(gl2_result - gl4_result)
        print(f"  [{desc}] α={alpha}, β={beta}")
        print(f"    GL₂ trace-det: {gl2_result}")
        print(f"    GL₄ standard:  {gl4_result}")
        print(f"    Error: {error:.2e}")
        print()


# ---------------------------------------------------------------------------
# Application 3: Hecke eigenvalue table
# ---------------------------------------------------------------------------

def hecke_eigenvalue_table():
    """
    For a range of Hecke eigenvalue/nebentypus pairs, compute
    all Sym³ coefficients and display the trace-det advantage.
    """
    print("=" * 65)
    print("APPLICATION 3: Sym³ coefficient table from Hecke data")
    print("=" * 65)
    print()
    print("For trivial nebentypus (d=1), the Sym³ Euler factor depends")
    print("only on the normalized Hecke eigenvalue t = a_p / p^{(k-1)/2}.")
    print()

    print(f"{'t':>6} {'e₁':>10} {'e₂':>10} {'e₃':>10} {'e₄':>6}")
    print("-" * 46)

    for t_val in [-2, -1.5, -1, -0.5, 0, 0.5, 1, 1.5, 2]:
        d_val = 1  # Trivial nebentypus
        e1 = t_val**3 - 2 * t_val * d_val
        e2 = d_val * t_val**4 - 3 * d_val**2 * t_val**2 + 2 * d_val**3
        e3 = d_val**3 * e1
        e4 = d_val**6
        print(f"{t_val:6.1f} {e1:10.4f} {e2:10.4f} {e3:10.4f} {e4:6.0f}")

    print()
    print("Note: e₃ = e₁ when d = 1 (self-reciprocal symmetry).")
    print("The Ramanujan conjecture bounds |t| ≤ 2, so |e₁| ≤ 4.")


# ---------------------------------------------------------------------------
# Application 4: Euler product convergence
# ---------------------------------------------------------------------------

def euler_product_convergence():
    """
    Study convergence of the Sym³ Euler product as more primes are included.
    Uses a simple model where t_p = 2cos(θ_p) for random angles (Sato-Tate).
    """
    print()
    print("=" * 65)
    print("APPLICATION 4: Sym³ Euler product convergence (Sato-Tate model)")
    print("=" * 65)
    print()

    import random
    random.seed(12345)

    # Generate primes up to 1000
    def sieve(n: int) -> List[int]:
        is_prime = [True] * (n + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(n**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, n + 1, i):
                    is_prime[j] = False
        return [i for i in range(n + 1) if is_prime[i]]

    primes = sieve(500)

    # Sato-Tate distribution: t_p = 2cos(θ_p) where θ_p ~ sin²θ dθ on [0,π]
    # For simulation, use random angles
    s_values = [7, 10, 14]

    for s in s_values:
        print(f"\n  s = {s}:")
        log_product = 0.0
        checkpoints = [10, 25, 50, len(primes)]

        for i, p in enumerate(primes):
            # Random Sato-Tate angle
            theta = random.uniform(0, math.pi)
            t_p = 2 * math.cos(theta)
            d_p = 1.0  # Weight 2, trivial character

            X = p ** (-s)
            local = symm_cube_from_trace_det(t_p, d_p, X).real
            if local > 0:
                log_product += math.log(1.0 / local)

            if i + 1 in checkpoints:
                print(f"    After {i+1:3d} primes (up to p={p:4d}): "
                      f"log L(s) ≈ {log_product:.10f}, "
                      f"L(s) ≈ {math.exp(log_product):.10f}")


# ---------------------------------------------------------------------------
# Application 5: Comparison of computation methods
# ---------------------------------------------------------------------------

def method_comparison():
    """
    Compare the trace-det method vs eigenvalue method in terms of
    operation count and numerical stability.
    """
    print()
    print("=" * 65)
    print("APPLICATION 5: Computation method comparison")
    print("=" * 65)
    print()

    # Count operations for each method
    print("Operation count comparison:")
    print()
    print("  Eigenvalue method (from Hecke eigenvalue a_p, character χ(p)):")
    print("    1. Form t = a_p / p^{(k-1)/2}     — 1 division, 1 power")
    print("    2. Solve t² - 4d < 0? (complex)    — 1 mult, 1 sub, 1 sqrt")
    print("    3. α = (t + √disc)/2               — 1 add, 1 div")
    print("    4. β = (t - √disc)/2               — 1 sub, 1 div")
    print("    5. Form α³, α²β, αβ², β³           — ~8 multiplications")
    print("    6. Expand 4-term product            — ~15 multiplications")
    print("    Total: ~30 operations + 1 square root")
    print()
    print("  Trace-det method (direct from t, d):")
    print("    1. c₁ = t³ - 2td                   — 2 mult, 1 sub")
    print("    2. c₂ = dt⁴ - 3d²t² + 2d³          — 5 mult, 2 sub/add")
    print("    3. c₃ = d³ · c₁                    — 1 mult (reuse d³)")
    print("    4. c₄ = d⁶                         — 1 mult (reuse d³)")
    print("    5. Horner evaluation                — 4 mult, 4 add")
    print("    Total: ~13 operations, NO square root")
    print()
    print("  Speedup factor: ~2.3x fewer operations")
    print("  Numerical advantage: No square root → no branch cuts, ")
    print("  no complex arithmetic if t, d are real.")
    print()

    # Demonstrate with a case where eigenvalue method needs complex arithmetic
    # but trace-det stays real
    print("  Example where trace-det avoids complex numbers:")
    t, d = 1.5, 1.0
    disc = t**2 - 4 * d  # = 2.25 - 4 = -1.75 < 0!
    print(f"    t = {t}, d = {d}")
    print(f"    Discriminant t²-4d = {disc} < 0 → eigenvalues are COMPLEX")
    print(f"    But trace-det formula uses only real arithmetic:")
    e1 = t**3 - 2*t*d
    e2 = d*t**4 - 3*d**2*t**2 + 2*d**3
    e3 = d**3 * e1
    e4 = d**6
    print(f"    e₁ = {e1:.6f}")
    print(f"    e₂ = {e2:.6f}")
    print(f"    e₃ = {e3:.6f}")
    print(f"    e₄ = {e4:.6f}")
    print(f"    All coefficients are REAL — no complex arithmetic needed!")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    modular_form_sym3_lfunction()
    verify_functorial_lift()
    hecke_eigenvalue_table()
    euler_product_convergence()
    method_comparison()

    print()
    print("=" * 65)
    print("All applications demonstrated successfully.")
    print("=" * 65)
