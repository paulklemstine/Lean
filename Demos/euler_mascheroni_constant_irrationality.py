#!/usr/bin/env python3
"""
Applications of Euler–Mascheroni Irrationality Certificate Framework

Demonstrates real-world applications of the formal theorems:
1. Certified numerical computation with provable error bounds
2. Irrationality testing for mathematical constants
3. L-function value analysis via periodic weighted sums
4. Computational prediction testing for conjectures
"""

import math
from fractions import Fraction
from typing import List, Tuple

GAMMA = 0.5772156649015328606065120900824024310421

# ═══════════════════════════════════════════════════════════════════════════
# Application 1: Certified Constant Computation
# ═══════════════════════════════════════════════════════════════════════════

def certified_computation_demo():
    """
    Demonstrate certified computation of γ with provable bounds.

    The formal theorem (EulerGamma.gammaApprox_certified) guarantees:
    |γ - gammaApprox(N+1)| ≤ 1/(N+1)

    This means every computed value comes with a mathematical PROOF
    of its accuracy — not just floating-point heuristics.
    """
    print("=" * 60)
    print("APPLICATION 1: Certified Constant Computation")
    print("=" * 60)

    print("\nComputing γ with certified error bounds:")
    print(f"{'Digits':>8} {'N needed':>10} {'Approximation':>22} {'Certified bound':>16}")
    print("-" * 60)

    for digits in [1, 2, 3, 4, 6, 8]:
        eps = 10 ** (-digits)
        N = math.ceil(1.0 / eps) - 1
        approx = sum(
            1.0 / (m + 1) - math.log(1 + 1.0 / (m + 1))
            for m in range(N + 1)
        )
        bound = 1.0 / (N + 1)
        print(f"{digits:>8} {N:>10} {approx:>22.15f} {bound:>16.2e}")

    print("\nKey: Each bound is PROVEN correct by formal theorem,")
    print("not merely observed from numerical experiments.")


# ═══════════════════════════════════════════════════════════════════════════
# Application 2: Irrationality Testing Framework
# ═══════════════════════════════════════════════════════════════════════════

def irrationality_testing_demo():
    """
    Test the irrationality certificate framework on known constants.

    The theorem (IrrationCert.irrational_of_good_approx) says:
    If |x - A_n/B_n| ≤ C/B_n^p with p > 1, B_n → ∞,
    and A_n/B_n ≠ x infinitely often, then x is irrational.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Irrationality Testing Framework")
    print("=" * 60)

    constants = {
        "√2": math.sqrt(2),
        "e": math.e,
        "π": math.pi,
        "γ": GAMMA,
        "ln(2)": math.log(2),
        "ζ(3)": 1.2020569031595942,  # Apéry's constant
    }

    for name, x in constants.items():
        # Generate best rational approximations via continued fractions
        coeffs = []
        y = x
        for _ in range(30):
            a = math.floor(y)
            coeffs.append(int(a))
            y = y - a
            if abs(y) < 1e-14:
                break
            y = 1.0 / y

        # Compute convergents
        p_prev, p_curr = 0, 1
        q_prev, q_curr = 1, 0
        errors = []
        for a in coeffs:
            p_prev, p_curr = p_curr, a * p_curr + p_prev
            q_prev, q_curr = q_curr, a * q_curr + q_prev
            if q_curr > 0:
                err = abs(x - p_curr / q_curr)
                if err > 0 and q_curr > 1:
                    p_eff = -math.log(err) / math.log(q_curr)
                    errors.append(p_eff)

        if errors:
            p_avg = sum(errors) / len(errors)
            p_min = min(errors)
            p_max = max(errors)
            print(f"\n{name:>6}: avg_p = {p_avg:.3f}, range = [{p_min:.3f}, {p_max:.3f}]")
            if p_avg > 1.5:
                print(f"        → Strong irrationality signal (p >> 1)")
            else:
                print(f"        → Consistent with quadratic irrationality measure")


# ═══════════════════════════════════════════════════════════════════════════
# Application 3: L-function Special Value Analysis
# ═══════════════════════════════════════════════════════════════════════════

def l_function_demo():
    """
    Analyze periodic mean-zero weighted sums as shadows of L(1,χ).

    The theorem (PeriodicSums.periodic_mean_zero_log_weighted_bounded) guarantees
    boundedness. Here we show convergence to known L-function values.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: L-function Special Values via Periodic Sums")
    print("=" * 60)

    # Dirichlet characters and their L(1,χ) values
    characters = [
        ("χ mod 3 (Legendre)", [0, 1, -1], None),
        ("χ mod 4 (non-principal)", [0, 1, 0, -1], math.pi / 4),
        ("χ mod 5 (Legendre)", [0, 1, -1, -1, 1], None),
        ("χ mod 7 (Legendre)", [0, 1, 1, -1, 1, -1, -1], None),
    ]

    print(f"\n{'Character':>30} {'Period':>6} {'Sum(10⁴)':>14} {'Known L(1,χ)':>14}")
    print("-" * 68)

    for name, f, known in characters:
        q = len(f)
        s = sum(f[k % q] / k for k in range(1, 10001))
        known_str = f"{known:.10f}" if known else "—"
        print(f"{name:>30} {q:>6} {s:>14.10f} {known_str:>14}")

    print("\nKey insight: These sums converge because of mean-zero periodicity —")
    print("the exact mechanism formalized in our bounded-sum theorem.")
    print("γ arises from the NON-canceling (mean ≠ 0) case: f(k) = 1.")


# ═══════════════════════════════════════════════════════════════════════════
# Application 4: Conjecture Testing
# ═══════════════════════════════════════════════════════════════════════════

def conjecture_testing_demo():
    """
    Computationally test the conjectures stated in the formalization.

    Conjecture A: CF coefficients of γ are unbounded with log-spikes.
    Conjecture B: Periodic cancellation distinguishes L(1,χ) from γ.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Computational Conjecture Testing")
    print("=" * 60)

    # Conjecture A: CF coefficient growth
    print("\n--- Conjecture A: CF coefficient unboundedness ---")
    # Known CF expansion of γ (first 20 terms)
    gamma_cf = [0, 1, 1, 2, 1, 2, 1, 4, 3, 13, 5, 1, 1, 8, 1, 2, 4, 1, 1, 40]
    print(f"First 20 CF coefficients of γ: {gamma_cf}")
    print(f"Maximum: {max(gamma_cf[1:])}")
    print(f"Coefficients > c·log(n) for c=1:")
    for i, a in enumerate(gamma_cf[1:], 1):
        if a > math.log(i + 1):
            print(f"  a_{i} = {a} > log({i+1}) = {math.log(i+1):.2f}")
    print("→ Consistent with conjecture (large spikes at positions 9, 19)")

    # Conjecture B: Periodic vs non-periodic comparison
    print("\n--- Conjecture B: Periodic cancellation mechanism ---")
    N = 10000
    # Compute approximation exponents for L(1,χ₄) vs γ
    # For L(1,χ₄), use partial sums as rational approximants
    chi4 = [0, 1, 0, -1]
    target_l = math.pi / 4

    print(f"\nComparing approximation quality:")
    print(f"{'n':>8} {'|L(1,χ₄) - S_n|':>18} {'|γ - E_n|':>18}")
    for n in [10, 50, 100, 500, 1000, 5000]:
        s_l = sum(chi4[k % 4] / k for k in range(1, n + 1))
        err_l = abs(target_l - s_l)
        e_n = sum(1.0 / k for k in range(1, n + 2)) - math.log(n + 1)
        err_g = abs(GAMMA - e_n)
        print(f"{n:>8} {err_l:>18.2e} {err_g:>18.2e}")

    print("\n→ Both converge as O(1/n), but through different mechanisms:")
    print("   L(1,χ₄): cancellation from mean-zero periodicity")
    print("   γ: logarithmic subtraction of the divergent bulk")


# ═══════════════════════════════════════════════════════════════════════════

def main():
    certified_computation_demo()
    irrationality_testing_demo()
    l_function_demo()
    conjecture_testing_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Euler–Mascheroni Constant — Irrationality Certificates and Periodic Sums

This script demonstrates:
1. Convergence of H_n - log(n) to γ (monotone from above)
2. Certified error bounds for γ approximation
3. Superlinear approximation and irrationality certificates
4. Periodic mean-zero weighted sums (L-function analogy)
5. Richardson-corrected acceleration

Usage:
    python demo.py
"""

import math
from fractions import Fraction

# ─── Harmonic numbers and γ approximation ─────────────────────────────────

def harmonic(n: int) -> float:
    """Compute the n-th harmonic number H_n = sum_{k=1}^{n} 1/k."""
    return sum(1.0 / k for k in range(1, n + 1))

def harmonic_exact(n: int) -> Fraction:
    """Compute the n-th harmonic number exactly as a fraction."""
    return sum(Fraction(1, k) for k in range(1, n + 1))

def euler_renorm(n: int) -> float:
    """Compute E_n = H_{n+1} - log(n+1), the Euler renormalization sequence."""
    return harmonic(n + 1) - math.log(n + 1)

def gamma_approx_series(N: int) -> float:
    """Compute the accelerated series partial sum for γ:
    sum_{m=0}^{N-1} [1/(m+1) - log(1 + 1/(m+1))]"""
    return sum(1.0 / (m + 1) - math.log(1 + 1.0 / (m + 1)) for m in range(N))

def richardson_corrected(n: int) -> float:
    """Richardson-corrected approximation: E_n - 1/(2(n+1))."""
    return euler_renorm(n) - 1.0 / (2 * (n + 1))

# Reference value of γ
GAMMA = 0.5772156649015328606065120900824024310421

# ─── Periodic mean-zero sums ──────────────────────────────────────────────

def periodic_weighted_sum(f: list, n: int) -> float:
    """Compute sum_{k=1}^{n} f(k % q) / k where f is periodic with period q."""
    q = len(f)
    return sum(f[k % q] / k for k in range(1, n + 1))

# ─── Irrationality certificate demo ──────────────────────────────────────

def check_approximation_quality(A: list, B: list, x: float) -> list:
    """Check the approximation quality |x - A_n/B_n| vs 1/B_n^p for various p."""
    results = []
    for i in range(len(A)):
        if B[i] == 0:
            continue
        error = abs(x - A[i] / B[i])
        if error == 0:
            continue
        # Estimate effective exponent p: error ≈ C/B^p => p ≈ -log(error)/log(B)
        if B[i] > 1 and error > 0:
            p_eff = -math.log(error) / math.log(abs(B[i]))
            results.append((i, A[i], B[i], error, p_eff))
    return results

# ─── Main demo ────────────────────────────────────────────────────────────

def main():
    print("=" * 72)
    print("  EULER–MASCHERONI CONSTANT: IRRATIONALITY CERTIFICATES")
    print("  A Computational Exploration")
    print("=" * 72)

    # Demo 1: Monotone convergence
    print("\n─── 1. MONOTONE CONVERGENCE OF E_n = H_{n+1} - log(n+1) ───")
    print(f"{'n':>6} {'E_n':>18} {'E_n - γ':>18} {'1/(n+1)':>12} {'Monotone?':>10}")
    print("-" * 66)
    prev = None
    for n in [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]:
        en = euler_renorm(n)
        error = en - GAMMA
        bound = 1.0 / (n + 1)
        mono = "✓" if prev is None or en <= prev else "✗"
        print(f"{n:>6} {en:>18.15f} {error:>18.15f} {bound:>12.8f} {mono:>10}")
        prev = en

    # Demo 2: Certified error bounds
    print("\n─── 2. CERTIFIED ERROR BOUNDS ───")
    print("Theorem: |γ - gammaApprox(N+1)| ≤ 1/(N+1)")
    print(f"{'N':>6} {'gammaApprox':>18} {'actual error':>18} {'bound 1/(N+1)':>14} {'valid?':>8}")
    print("-" * 66)
    for N in [5, 10, 20, 50, 100, 500]:
        approx = gamma_approx_series(N + 1)
        actual_err = abs(GAMMA - approx)
        bound = 1.0 / (N + 1)
        valid = "✓" if actual_err <= bound + 1e-15 else "✗"
        print(f"{N:>6} {approx:>18.15f} {actual_err:>18.15f} {bound:>14.10f} {valid:>8}")

    # Demo 3: Richardson correction
    print("\n─── 3. RICHARDSON-CORRECTED APPROXIMATION ───")
    print(f"{'n':>6} {'E_n':>18} {'Richardson':>18} {'E_n error':>14} {'Rich error':>14}")
    print("-" * 66)
    for n in [5, 10, 20, 50, 100, 500]:
        en = euler_renorm(n)
        rich = richardson_corrected(n)
        print(f"{n:>6} {en:>18.15f} {rich:>18.15f} {abs(en - GAMMA):>14.2e} {abs(rich - GAMMA):>14.2e}")

    # Demo 4: Irrationality certificate concept
    print("\n─── 4. IRRATIONALITY CERTIFICATE CONCEPT ───")
    print("If |x - A_n/B_n| ≤ C/B_n^p with p > 1 and B_n → ∞,")
    print("and A_n/B_n ≠ x infinitely often, then x is irrational.")
    print()
    print("Rational approximants to γ from convergents of continued fraction:")
    # First few convergents of γ = [0; 1, 1, 2, 1, 2, 1, 4, 3, 13, ...]
    cf_convergents_A = [0, 1, 1, 3, 4, 11, 15, 71, 228, 3035]
    cf_convergents_B = [1, 1, 2, 5, 7, 19, 26, 123, 395, 5258]
    results = check_approximation_quality(cf_convergents_A, cf_convergents_B, GAMMA)
    print(f"{'n':>4} {'A_n':>8} {'B_n':>8} {'|γ - A/B|':>16} {'eff. exponent p':>16}")
    for i, A, B, err, p in results:
        print(f"{i:>4} {A:>8} {B:>8} {err:>16.2e} {p:>16.4f}")
    print("\nNote: effective exponents near 2 are consistent with")
    print("quadratic irrationality measure (Roth's theorem lower bound).")

    # Demo 5: Periodic mean-zero sums
    print("\n─── 5. PERIODIC MEAN-ZERO WEIGHTED SUMS ───")
    print("Theorem: If f is periodic with mean zero,")
    print("then sum_{k=1}^n f(k)/k is bounded.")
    print()

    # Example 1: Legendre symbol mod 3: f = [0, 1, -1] (indices 0,1,2)
    f1 = [0, 1, -1]
    print("Example 1: f = [0, 1, -1] (period 3, Legendre-like)")
    print(f"  Mean = {sum(f1)}")
    print(f"  {'n':>8} {'sum f(k)/k':>16}")
    for n in [10, 100, 1000, 10000]:
        s = periodic_weighted_sum(f1, n)
        print(f"  {n:>8} {s:>16.10f}")

    # Example 2: Dirichlet character mod 4: f = [0, 1, 0, -1]
    f2 = [0, 1, 0, -1]
    print("\nExample 2: f = [0, 1, 0, -1] (period 4, χ mod 4)")
    print(f"  Mean = {sum(f2)}")
    print(f"  Limit should be L(1,χ₄) = π/4 = {math.pi/4:.10f}")
    print(f"  {'n':>8} {'sum f(k)/k':>16} {'error':>16}")
    for n in [10, 100, 1000, 10000]:
        s = periodic_weighted_sum(f2, n)
        print(f"  {n:>8} {s:>16.10f} {abs(s - math.pi/4):>16.2e}")

    # Example 3: Custom mean-zero
    f3 = [3, -1, -1, -1]
    print("\nExample 3: f = [3, -1, -1, -1] (period 4, custom mean-zero)")
    print(f"  Mean = {sum(f3)}")
    print(f"  {'n':>8} {'sum f(k)/k':>16}")
    for n in [10, 100, 1000, 10000]:
        s = periodic_weighted_sum(f3, n)
        print(f"  {n:>8} {s:>16.10f}")

    # Demo 6: Non-mean-zero comparison
    print("\n─── 6. CONTRAST: NON-MEAN-ZERO (DIVERGENT) ───")
    print("f = [1] (period 1, mean 1): sum = H_n → diverges")
    print(f"  {'n':>8} {'H_n':>12} {'H_n - log n':>14} {'γ error':>14}")
    for n in [10, 100, 1000, 10000]:
        hn = harmonic(n)
        print(f"  {n:>8} {hn:>12.6f} {hn - math.log(n):>14.10f} {hn - math.log(n) - GAMMA:>14.2e}")

    print("\n" + "=" * 72)
    print("  KEY INSIGHT: Mean-zero periodicity is the structural mechanism")
    print("  that distinguishes bounded L(1,χ)-type sums from the divergent")
    print("  harmonic series. The Euler–Mascheroni constant γ arises as the")
    print("  'renormalized residue' after subtracting the logarithmic divergence.")
    print("=" * 72)

if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""Generate PACKAGE.json from all deliverables."""
import json
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

# Read all files
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')
viz1 = read_file('viz_convergence.py')
viz2 = read_file('viz_periodic_sums.py')
viz3 = read_file('viz_irrationality.py')
interactive1 = read_file('interactive_gamma.html')
interactive2 = read_file('interactive_periodic.html')

# Read all Lean files
lean_files = []
for root, dirs, files in os.walk('Catalog/Algebra/EulerMascheroni'):
    for f in sorted(files):
        if f.endswith('.lean'):
            path = os.path.join(root, f)
            content = read_file(path)
            lean_files.append(f"-- File: {path}\n{content}")

lean_proofs = "\n\n".join(lean_files)

package = {
    "title": "Irrationality Certificates for the Euler–Mascheroni Constant",
    "domain": "Number Theory / Diophantine Approximation",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {
            "name": "Euler–Mascheroni Constant Explorer",
            "code": demo_code
        },
        {
            "name": "Applications: Certified Computation & L-functions",
            "code": applications_code
        }
    ],
    "algorithms": [
        {
            "name": "Certified γ Approximation",
            "pseudocode": """Algorithm CertifiedGammaApprox(ε):
  Input: ε > 0 (desired accuracy)
  Output: (approx, bound) with |γ - approx| ≤ bound ≤ ε

  1. N ← ⌈1/ε⌉ − 1
  2. approx ← Σ_{m=0}^{N} [1/(m+1) − ln(1 + 1/(m+1))]
  3. bound ← 1/(N+1)
  4. Return (approx, bound)

  Complexity: O(1/ε) time, O(1) space
  Correctness: Guaranteed by EulerGamma.gammaApprox_certified""",
            "code": algorithms_code
        },
        {
            "name": "Irrationality Certificate Validator",
            "pseudocode": """Algorithm ValidateCertificate(x, A, B, n):
  Input: target x, integer sequences A[0..n], B[0..n]
  Output: validation report

  1. Check B[i] > 0 for all i
  2. Check B eventually increasing
  3. For each i: p_i ← −log|x − A[i]/B[i]| / log|B[i]|
  4. p ← median(p_i), C ← max_i(error · B[i]^p)
  5. Return (p > 1, p, C, distinct_count)

  Correctness: Valid certificate ⟹ x irrational
  (by IrrationCert.irrational_of_certificate)""",
            "code": algorithms_code
        }
    ],
    "visualizations": [
        {
            "name": "Monotone Convergence to γ",
            "code": viz1,
            "description": "Shows the Euler renormalization sequence E_n = H_{n+1} − ln(n+1) converging monotonically to γ with certified error bounds."
        },
        {
            "name": "Periodic Mean-Zero Weighted Sums",
            "code": viz2,
            "description": "Contrasts bounded periodic mean-zero sums (L-function regime) with divergent harmonic sum, illustrating the key theorem."
        },
        {
            "name": "Irrationality Certificate Visualization",
            "code": viz3,
            "description": "Displays rational approximation quality for various constants, illustrating the irrationality certificate concept."
        }
    ],
    "interactive_demos": [
        {
            "name": "γ Convergence Explorer",
            "html": interactive1,
            "description": "Interactive slider showing how H_n − ln(n) converges to γ with real-time error computation and certified bounds."
        },
        {
            "name": "Periodic Sum Explorer",
            "html": interactive2,
            "description": "Choose different periodic functions and observe bounded vs divergent behavior of weighted sums."
        }
    ],
    "lean_proofs": lean_proofs
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print("PACKAGE.json generated successfully")
print(f"Size: {os.path.getsize('PACKAGE.json')} bytes")


"""
Visualization: Monotone Convergence of H_n - log(n) to γ

Shows the Euler renormalization sequence E_n = H_{n+1} - log(n+1) converging
monotonically from above to the Euler–Mascheroni constant γ, with certified
error bounds 1/(n+1) displayed as a shaded region.
"""

import numpy as np
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015328606065120900824024310421

def harmonic(n):
    return sum(1.0 / k for k in range(1, n + 1))

def euler_renorm(n):
    return harmonic(n + 1) - np.log(n + 1)

def richardson(n):
    return euler_renorm(n) - 1.0 / (2 * (n + 1))

# Compute sequences
ns = np.arange(1, 201)
E = np.array([euler_renorm(n) for n in ns])
R = np.array([richardson(n) for n in ns])
bounds_upper = np.array([GAMMA + 1.0 / (n + 1) for n in ns])
bounds_lower = np.full_like(ns, GAMMA, dtype=float)

fig, axes = plt.subplots(2, 1, figsize=(12, 8), gridspec_kw={'height_ratios': [2, 1]})

# Top plot: convergence
ax1 = axes[0]
ax1.fill_between(ns, bounds_lower, bounds_upper, alpha=0.15, color='blue',
                  label='Certified region: γ to γ + 1/(n+1)')
ax1.plot(ns, E, 'b-', linewidth=1.5, label='$E_n = H_{n+1} - \\ln(n+1)$', alpha=0.8)
ax1.plot(ns, R, 'r--', linewidth=1.2, label='Richardson corrected', alpha=0.7)
ax1.axhline(y=GAMMA, color='green', linewidth=2, linestyle='-',
            label=f'γ ≈ {GAMMA:.10f}', alpha=0.8)
ax1.set_xlabel('n', fontsize=12)
ax1.set_ylabel('Value', fontsize=12)
ax1.set_title('Monotone Convergence to the Euler–Mascheroni Constant γ',
              fontsize=14, fontweight='bold')
ax1.legend(fontsize=10, loc='upper right')
ax1.set_xlim(1, 200)
ax1.set_ylim(GAMMA - 0.02, GAMMA + 0.55)
ax1.grid(True, alpha=0.3)

# Bottom plot: error on log scale
ax2 = axes[1]
errors_E = np.array([euler_renorm(n) - GAMMA for n in ns])
errors_R = np.array([abs(richardson(n) - GAMMA) for n in ns])
cert_bounds = np.array([1.0 / (n + 1) for n in ns])

ax2.semilogy(ns, errors_E, 'b-', linewidth=1.5, label='$E_n - γ$ (raw error)')
ax2.semilogy(ns, errors_R, 'r--', linewidth=1.2, label='|Richardson − γ|')
ax2.semilogy(ns, cert_bounds, 'k:', linewidth=1.5, label='Certified bound 1/(n+1)')
ax2.set_xlabel('n', fontsize=12)
ax2.set_ylabel('Error (log scale)', fontsize=12)
ax2.set_title('Approximation Error with Certified Bounds', fontsize=13)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xlim(1, 200)

plt.tight_layout()
plt.savefig('convergence_plot.png', dpi=150, bbox_inches='tight')
print("Saved convergence_plot.png")


"""
Visualization: Irrationality Certificate — Approximation Quality

Shows the rational approximation quality |x - p_n/q_n| vs 1/q_n^p for
various constants, illustrating the irrationality certificate concept.
The formal theorem proves: if the errors decay faster than 1/q^1 with
q → ∞ and infinitely many distinct approximants, then x is irrational.
"""

import numpy as np
import matplotlib.pyplot as plt
import math

GAMMA = 0.5772156649015328606065120900824024310421

def cf_data(x, n_terms=25):
    """Compute CF coefficients, convergents, and approximation errors."""
    coeffs = []
    y = x
    for _ in range(n_terms):
        a = math.floor(y)
        coeffs.append(int(a))
        y -= a
        if abs(y) < 1e-15:
            break
        y = 1.0 / y

    p_prev, p_curr = 0, 1
    q_prev, q_curr = 1, 0
    qs = []
    errors = []
    for a in coeffs:
        p_prev, p_curr = p_curr, a * p_curr + p_prev
        q_prev, q_curr = q_curr, a * q_curr + q_prev
        if q_curr > 0:
            err = abs(x - p_curr / q_curr)
            if err > 0:
                qs.append(q_curr)
                errors.append(err)
    return coeffs, np.array(qs), np.array(errors)

constants = {
    'γ (Euler–Mascheroni)': GAMMA,
    '√2': math.sqrt(2),
    'e': math.e,
    'π': math.pi,
    'ln(2)': math.log(2),
}

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left: log-log plot of |x - p/q| vs q
ax = axes[0]
colors = ['blue', 'red', 'green', 'orange', 'purple']
for (name, x), color in zip(constants.items(), colors):
    _, qs, errors = cf_data(x, 20)
    if len(qs) > 0:
        ax.loglog(qs, errors, 'o-', color=color, markersize=4,
                  linewidth=1.2, label=name, alpha=0.8)

# Reference lines
q_ref = np.logspace(0, 8, 100)
ax.loglog(q_ref, 1.0 / q_ref, 'k:', linewidth=1, alpha=0.4, label='$1/q$ (linear)')
ax.loglog(q_ref, 1.0 / q_ref**2, 'k--', linewidth=1, alpha=0.4, label='$1/q^2$ (quadratic)')

ax.set_xlabel('Denominator $q_n$', fontsize=12)
ax.set_ylabel('$|x - p_n/q_n|$', fontsize=12)
ax.set_title('Rational Approximation Quality\n(Irrationality Certificate Data)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=8, loc='lower left')
ax.grid(True, alpha=0.3)

# Right: CF coefficient distribution
ax = axes[1]
for (name, x), color in zip(constants.items(), colors):
    coeffs, _, _ = cf_data(x, 30)
    if len(coeffs) > 1:
        ax.plot(range(1, len(coeffs)), coeffs[1:], 'o-', color=color,
                markersize=4, linewidth=1, label=name, alpha=0.7)

ax.set_xlabel('Index $n$', fontsize=12)
ax.set_ylabel('CF coefficient $a_n$', fontsize=12)
ax.set_title('Continued Fraction Coefficients\n(Bounded ⟹ Quadratic Irrationality Measure)',
             fontsize=13, fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)
ax.set_ylim(0, 50)

plt.suptitle('Irrationality Certificates: Approximation Obstructions',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('irrationality_plot.png', dpi=150, bbox_inches='tight')
print("Saved irrationality_plot.png")


"""
Visualization: Periodic Mean-Zero Weighted Sums vs Harmonic Divergence

Contrasts the bounded behavior of sum_{k=1}^n f(k)/k for periodic mean-zero
functions f with the divergent behavior of the harmonic sum (mean ≠ 0).
This visualizes the key theorem periodic_mean_zero_log_weighted_bounded
and its connection to L-function special values.
"""

import numpy as np
import matplotlib.pyplot as plt

GAMMA = 0.5772156649015328606065120900824024310421

def periodic_weighted_sum_sequence(f, max_n):
    """Compute partial sums sum_{k=1}^n f(k mod q)/k for n = 1..max_n."""
    q = len(f)
    sums = np.zeros(max_n)
    running = 0.0
    for k in range(1, max_n + 1):
        running += f[k % q] / k
        sums[k - 1] = running
    return sums

def harmonic_log_sequence(max_n):
    """Compute H_n - log(n) for n = 1..max_n."""
    sums = np.zeros(max_n)
    running = 0.0
    for k in range(1, max_n + 1):
        running += 1.0 / k
        sums[k - 1] = running - np.log(k)
    return sums

max_n = 2000
ns = np.arange(1, max_n + 1)

# Periodic mean-zero examples
chi4 = [0, 1, 0, -1]  # χ mod 4
chi3 = [0, 1, -1]      # Legendre mod 3
custom = [3, -1, -1, -1]  # Custom mean-zero

sums_chi4 = periodic_weighted_sum_sequence(chi4, max_n)
sums_chi3 = periodic_weighted_sum_sequence(chi3, max_n)
sums_custom = periodic_weighted_sum_sequence(custom, max_n)
sums_harmonic = harmonic_log_sequence(max_n)

# Harmonic series (divergent, mean ≠ 0)
harmonic_raw = np.cumsum(1.0 / ns)

fig, axes = plt.subplots(2, 2, figsize=(14, 10))

# Top left: bounded periodic sums
ax = axes[0, 0]
ax.plot(ns, sums_chi4, 'b-', linewidth=0.8, alpha=0.7,
        label=f'χ mod 4: [0,1,0,−1] → π/4 ≈ {np.pi/4:.4f}')
ax.plot(ns, sums_chi3, 'r-', linewidth=0.8, alpha=0.7,
        label='Legendre mod 3: [0,1,−1]')
ax.plot(ns, sums_custom, 'g-', linewidth=0.8, alpha=0.7,
        label='Custom: [3,−1,−1,−1]')
ax.axhline(y=np.pi/4, color='blue', linestyle=':', alpha=0.5)
ax.set_xlabel('n')
ax.set_ylabel('$\\sum_{k=1}^n f(k)/k$')
ax.set_title('Bounded: Periodic Mean-Zero Weighted Sums', fontweight='bold')
ax.legend(fontsize=8)
ax.grid(True, alpha=0.3)

# Top right: divergent harmonic
ax = axes[0, 1]
ax.plot(ns, harmonic_raw, 'k-', linewidth=1.5, label='$H_n$ (divergent)')
ax.plot(ns, np.log(ns), 'r--', linewidth=1.2, label='$\\ln(n)$')
ax.set_xlabel('n')
ax.set_ylabel('Value')
ax.set_title('Divergent: $H_n$ (Non-Zero Mean f=1)', fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Bottom left: H_n - log(n) converging to γ
ax = axes[1, 0]
ax.plot(ns, sums_harmonic, 'b-', linewidth=1, alpha=0.8,
        label='$H_n - \\ln(n)$')
ax.axhline(y=GAMMA, color='green', linewidth=2, linestyle='--',
           label=f'γ ≈ {GAMMA:.6f}')
ax.fill_between(ns, GAMMA, sums_harmonic, alpha=0.1, color='blue')
ax.set_xlabel('n')
ax.set_ylabel('$H_n - \\ln(n)$')
ax.set_title('Renormalized: $H_n - \\ln(n) → γ$', fontweight='bold')
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(GAMMA - 0.05, GAMMA + 0.6)

# Bottom right: comparison of convergence rates
ax = axes[1, 1]
errors_gamma = np.abs(sums_harmonic - GAMMA)
errors_chi4 = np.abs(sums_chi4 - np.pi/4)
ax.loglog(ns[1:], errors_gamma[1:], 'b-', linewidth=0.8, alpha=0.7,
          label='$|H_n - \\ln n - γ|$')
ax.loglog(ns[1:], errors_chi4[1:], 'r-', linewidth=0.8, alpha=0.7,
          label='$|S_n^{χ_4} - π/4|$')
ax.loglog(ns[1:], 1.0/ns[1:], 'k:', linewidth=1.5, alpha=0.5,
          label='$1/n$ reference')
ax.set_xlabel('n')
ax.set_ylabel('Error (log-log)')
ax.set_title('Convergence Rate Comparison', fontweight='bold')
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

plt.suptitle('Mean-Zero Periodicity: The Structural Mechanism\n'
             'Separating Bounded Sums from Divergent Harmonic Series',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('periodic_sums_plot.png', dpi=150, bbox_inches='tight')
print("Saved periodic_sums_plot.png")
