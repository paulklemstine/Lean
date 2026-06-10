#!/usr/bin/env python3
"""
Applications of the Euler-Mascheroni constant framework.

This module demonstrates real-world applications and cross-domain connections:
1. Entropy renormalization interpretation
2. Coupon collector problem (expected number of coupons)  
3. Certified numerical table generation
4. Convergence rate analysis for asymptotic expansions
5. Approximation quality metrics
"""

import math
from typing import List, Tuple, Dict

GAMMA = 0.57721566490153286060651209008240243104215933593992


def harmonic(n: int) -> float:
    """H_n = 1 + 1/2 + ... + 1/n"""
    return sum(1.0 / k for k in range(1, n + 1))


# ============================================================================
# Application 1: Entropy Renormalization
# ============================================================================

def reciprocal_weight_mass(n: int) -> float:
    """
    The reciprocal-weighted mass: W_n = H_n = Σ_{k=1}^{n} 1/k.
    
    This is the normalization constant for the reciprocal probability
    distribution on {1, 2, ..., n}.
    """
    return harmonic(n)


def reciprocal_entropy(n: int) -> float:
    """
    Shannon entropy of the reciprocal distribution on {1, ..., n}:
        H(P_n) = -Σ_{k=1}^{n} p_k log(p_k)
    where p_k = (1/k) / H_n.
    
    The gap between log(n) and H(P_n) involves γ in the limit.
    """
    hn = harmonic(n)
    if hn == 0:
        return 0.0
    entropy = 0.0
    for k in range(1, n + 1):
        pk = (1.0 / k) / hn
        if pk > 0:
            entropy -= pk * math.log(pk)
    return entropy


def entropy_renormalization_demo():
    """
    Show how γ appears as the limiting gap between
    discrete reciprocal entropy and continuous log normalization.
    """
    print("=== Entropy Renormalization Interpretation ===\n")
    print("The reciprocal distribution P_n on {1,...,n}: p_k = (1/k) / H_n")
    print("γ appears in the asymptotic gap: H_n - log(n) → γ\n")
    
    print(f"{'n':>6} | {'H_n':>12} | {'log(n)':>12} | {'H_n - log(n)':>14} | {'H(P_n)':>12}")
    print("-" * 65)
    
    for n in [2, 5, 10, 20, 50, 100, 500, 1000]:
        hn = harmonic(n)
        logn = math.log(n)
        gap = hn - logn
        ent = reciprocal_entropy(n)
        print(f"{n:>6} | {hn:>12.6f} | {logn:>12.6f} | {gap:>14.10f} | {ent:>12.6f}")
    
    print(f"\n  γ = {GAMMA:.10f} (limit of H_n - log(n))")


# ============================================================================
# Application 2: Coupon Collector Problem
# ============================================================================

def coupon_collector_expected(n: int) -> float:
    """
    Expected number of trials to collect all n distinct coupons.
    E[T_n] = n * H_n ≈ n * (log(n) + γ)
    """
    return n * harmonic(n)


def coupon_collector_demo():
    """
    The coupon collector problem: how many random draws (with replacement)
    to see all n types? The answer involves harmonic numbers and thus γ.
    """
    print("\n=== Coupon Collector Problem ===\n")
    print("Expected draws to collect all n types: E[T_n] = n × H_n ≈ n(ln n + γ)\n")
    
    print(f"{'n':>6} | {'E[T_n] exact':>14} | {'n(ln n + γ)':>14} | {'Abs Error':>12}")
    print("-" * 55)
    
    for n in [5, 10, 20, 50, 100, 200, 1000]:
        exact = coupon_collector_expected(n)
        approx = n * (math.log(n) + GAMMA)
        err = abs(exact - approx)
        print(f"{n:>6} | {exact:>14.4f} | {approx:>14.4f} | {err:>12.6f}")


# ============================================================================
# Application 3: Certified Numerical Table
# ============================================================================

def generate_certified_table(max_n: int = 20) -> List[Dict]:
    """
    Generate a table of certified approximations to γ.
    Each entry comes with a machine-verified error bound.
    """
    table = []
    for n in range(max_n):
        en = harmonic(n + 1) - math.log(n + 1)  # eulerRenorm
        bound = 1.0 / (n + 1)  # proven bound
        actual_err = abs(en - GAMMA)
        
        table.append({
            'n': n,
            'eulerRenorm': en,
            'certified_bound': bound,
            'actual_error': actual_err,
            'bound_valid': actual_err <= bound + 1e-15
        })
    return table


def certified_table_demo():
    """Display a certified numerical table."""
    print("\n=== Certified Approximation Table ===\n")
    print("Each bound is machine-verified: |E_n - γ| ≤ 1/(n+1)\n")
    
    table = generate_certified_table(15)
    print(f"{'n':>4} | {'E_n':>18} | {'|E_n - γ|':>14} | {'1/(n+1)':>14} | {'Valid':>5}")
    print("-" * 62)
    
    for entry in table:
        print(f"{entry['n']:>4} | {entry['eulerRenorm']:>18.15f} | "
              f"{entry['actual_error']:>14.10f} | "
              f"{entry['certified_bound']:>14.10f} | "
              f"{'✓' if entry['bound_valid'] else '✗':>5}")


# ============================================================================
# Application 4: Asymptotic Expansion Quality
# ============================================================================

def asymptotic_expansion_demo():
    """
    Show the asymptotic expansion of H_n:
        H_n = log(n) + γ + 1/(2n) - 1/(12n²) + 1/(120n⁴) - ...
    and demonstrate how each correction term improves accuracy.
    """
    print("\n=== Asymptotic Expansion Quality ===\n")
    print("H_n ≈ log(n) + γ + 1/(2n) - 1/(12n²) + 1/(120n⁴) - ...\n")
    
    print(f"{'n':>6} | {'0 terms':>12} | {'1 term':>12} | {'2 terms':>12} | {'3 terms':>12}")
    print(f"{'':>6} | {'error':>12} | {'error':>12} | {'error':>12} | {'error':>12}")
    print("-" * 65)
    
    for n in [10, 20, 50, 100, 500, 1000]:
        hn = harmonic(n)
        
        # 0 terms: log(n) + γ
        a0 = math.log(n) + GAMMA
        # 1 term: + 1/(2n)
        a1 = a0 + 1.0 / (2 * n)
        # 2 terms: - 1/(12n²)
        a2 = a1 - 1.0 / (12 * n**2)
        # 3 terms: + 1/(120n⁴)
        a3 = a2 + 1.0 / (120 * n**4)
        
        print(f"{n:>6} | {abs(hn - a0):>12.2e} | {abs(hn - a1):>12.2e} | "
              f"{abs(hn - a2):>12.2e} | {abs(hn - a3):>12.2e}")


# ============================================================================
# Application 5: Approximation Quality Metrics
# ============================================================================

def irrationality_measure_estimate():
    """
    Estimate the irrationality measure of γ using continued fraction convergents.
    
    If γ is irrational (still open!), the irrationality measure μ satisfies:
    for infinitely many p/q, |γ - p/q| < 1/q^μ.
    
    We estimate μ from the best rational approximations.
    """
    print("\n=== Irrationality Measure Estimation ===\n")
    print("Best rational approximations to γ (from continued fraction):\n")
    
    # Continued fraction coefficients of γ (known to many terms)
    cf_coeffs = [0, 1, 1, 2, 1, 2, 1, 4, 3, 13, 5, 1, 1, 8, 1, 2, 4, 1, 1, 40]
    
    # Compute convergents
    p_prev, p_curr = 1, cf_coeffs[0]
    q_prev, q_curr = 0, 1
    
    print(f"{'k':>4} | {'p_k/q_k':>20} | {'|γ - p/q|':>14} | {'q^2|γ-p/q|':>14}")
    print("-" * 60)
    
    for k, a in enumerate(cf_coeffs):
        if k == 0:
            p_curr = a
            q_curr = 1
        else:
            p_new = a * p_curr + p_prev
            q_new = a * q_curr + q_prev
            p_prev, p_curr = p_curr, p_new
            q_prev, q_curr = q_curr, q_new
        
        if q_curr > 0:
            approx = p_curr / q_curr
            err = abs(GAMMA - approx)
            quality = q_curr**2 * err if err > 0 else 0
            
            if k < 15:
                print(f"{k:>4} | {p_curr:>9}/{q_curr:<9} | {err:>14.10f} | {quality:>14.6f}")
    
    print("\n  If q²|γ-p/q| stays bounded, irrationality measure ≈ 2 (typical for 'generic' irrationals)")
    print("  Large fluctuations suggest interesting arithmetic structure")


if __name__ == "__main__":
    entropy_renormalization_demo()
    coupon_collector_demo()
    certified_table_demo()
    asymptotic_expansion_demo()
    irrationality_measure_estimate()
    
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Demo: Euler-Mascheroni Constant — Certified Approximation and Convergence Analysis

This script demonstrates:
1. Computation of partial sums of the accelerated series for γ
2. Display of certified error bounds
3. Testing the Richardson-style conjecture for 1 ≤ n ≤ N
4. Comparison of convergence rates: naive vs accelerated vs Richardson-corrected

The Euler-Mascheroni constant γ ≈ 0.5772156649... is defined as
  γ = lim_{n→∞} (H_n - log n)
where H_n = 1 + 1/2 + ... + 1/n is the n-th harmonic number.
"""

import math
from typing import List, Tuple

# Reference value of γ (known to high precision)
GAMMA_REF = 0.57721566490153286060651209008240243104215933593992

def harmonic(n: int) -> float:
    """Compute the n-th harmonic number H_n = 1 + 1/2 + ... + 1/n."""
    return sum(1.0 / k for k in range(1, n + 1))

def euler_renorm(n: int) -> float:
    """Euler renormalization sequence: E_n = H_{n+1} - log(n+1)."""
    return harmonic(n + 1) - math.log(n + 1)

def gamma_series_term(m: int) -> float:
    """Accelerated series term: a_m = 1/(m+1) - log(1 + 1/(m+1))."""
    t = 1.0 / (m + 1)
    return t - math.log(1 + t)

def gamma_approx(N: int) -> float:
    """Partial sum of accelerated series: sum_{m=0}^{N-1} a_m."""
    return sum(gamma_series_term(m) for m in range(N))

def gamma_error_bound(N: int) -> float:
    """Certified error bound: 1/(N+1)."""
    return 1.0 / (N + 1)

def gamma_richardson(n: int) -> float:
    """Richardson-corrected approximation: E_n - 1/(2(n+1))."""
    return euler_renorm(n) - 1.0 / (2 * (n + 1))


def section_separator(title: str) -> None:
    print(f"\n{'=' * 70}")
    print(f"  {title}")
    print(f"{'=' * 70}\n")


def demo_convergence_comparison():
    """Compare convergence rates of different approximation methods."""
    section_separator("CONVERGENCE COMPARISON")
    
    print(f"Reference value: γ = {GAMMA_REF:.20f}\n")
    print(f"{'n':>6} | {'E_n (naive)':>20} | {'γ approx (accel)':>20} | {'Richardson':>20}")
    print(f"{'':>6} | {'error':>20} | {'error':>20} | {'error':>20}")
    print("-" * 95)
    
    for n in [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]:
        en = euler_renorm(n)
        ga = gamma_approx(n + 1)
        ri = gamma_richardson(n)
        
        err_naive = abs(en - GAMMA_REF)
        err_accel = abs(ga - GAMMA_REF)
        err_rich = abs(ri - GAMMA_REF)
        
        print(f"{n:>6} | {err_naive:>20.15f} | {err_accel:>20.15f} | {err_rich:>20.15f}")


def demo_certified_bounds():
    """Show certified error bounds and actual errors."""
    section_separator("CERTIFIED ERROR BOUNDS")
    
    print("The certified bound guarantees |γ - gammaApprox(N+1)| ≤ 1/(N+1)")
    print(f"\n{'N':>6} | {'Actual Error':>18} | {'Certified Bound':>18} | {'Bound Holds?':>12}")
    print("-" * 65)
    
    for N in [1, 2, 5, 10, 20, 50, 100, 500, 1000]:
        actual = abs(GAMMA_REF - gamma_approx(N + 1))
        bound = gamma_error_bound(N)
        holds = actual <= bound
        
        print(f"{N:>6} | {actual:>18.15f} | {bound:>18.15f} | {'✓' if holds else '✗':>12}")


def demo_monotonicity():
    """Verify antitonicity of the Euler renormalization sequence."""
    section_separator("MONOTONICITY (ANTITONICITY) VERIFICATION")
    
    print("Verifying E_{n+1} ≤ E_n (the sequence is decreasing):\n")
    
    violations = 0
    for n in range(200):
        if euler_renorm(n + 1) > euler_renorm(n) + 1e-15:  # small tolerance for float
            print(f"  VIOLATION at n={n}: E_{n} = {euler_renorm(n)}, E_{n+1} = {euler_renorm(n+1)}")
            violations += 1
    
    if violations == 0:
        print(f"  ✓ No violations found for n = 0, 1, ..., 199")
        print(f"  ✓ E_0 = {euler_renorm(0):.15f}")
        print(f"  ✓ E_199 = {euler_renorm(199):.15f}")
        print(f"  ✓ All values positive (min = {min(euler_renorm(n) for n in range(200)):.15f})")


def demo_series_terms():
    """Show individual terms of the accelerated series."""
    section_separator("ACCELERATED SERIES TERMS")
    
    print("The accelerated series: γ = Σ_{m=0}^∞ [1/(m+1) - log(1 + 1/(m+1))]")
    print(f"\n{'m':>6} | {'a_m':>20} | {'Upper bound':>20} | {'a_m ≤ bound?':>12}")
    print(f"{'':>6} | {'':>20} | {'1/(2(m+1)²)':>20} | {'':>12}")
    print("-" * 65)
    
    for m in range(20):
        term = gamma_series_term(m)
        bound = 1.0 / (2 * (m + 1)**2)
        holds = term <= bound + 1e-15
        
        print(f"{m:>6} | {term:>20.15f} | {bound:>20.15f} | {'✓' if holds else '✗':>12}")


def demo_richardson_conjecture():
    """Test the Richardson error bound conjecture."""
    section_separator("RICHARDSON CONJECTURE TEST")
    
    print("Conjecture: |A_n - γ| ≤ 1/(6(n+1)²) for all n ≥ 1")
    print("where A_n = E_n - 1/(2(n+1))\n")
    
    max_n = 1000
    violations = []
    max_ratio = 0.0
    
    print(f"{'n':>6} | {'|A_n - γ|':>20} | {'1/(6(n+1)²)':>20} | {'Ratio':>10} | {'Holds?':>7}")
    print("-" * 75)
    
    for n in range(1, max_n + 1):
        actual = abs(gamma_richardson(n) - GAMMA_REF)
        bound = 1.0 / (6 * (n + 1)**2)
        ratio = actual / bound if bound > 0 else 0
        holds = actual <= bound + 1e-15
        
        if ratio > max_ratio:
            max_ratio = ratio
        
        if not holds:
            violations.append(n)
        
        if n <= 10 or n in [20, 50, 100, 200, 500, 1000]:
            print(f"{n:>6} | {actual:>20.15f} | {bound:>20.15f} | {ratio:>10.6f} | {'✓' if holds else '✗':>7}")
    
    print(f"\nResults for n = 1 to {max_n}:")
    if violations:
        print(f"  ✗ CONJECTURE VIOLATED at n = {violations[:10]}")
    else:
        print(f"  ✓ Conjecture holds for all tested values")
    print(f"  Maximum ratio (actual/bound): {max_ratio:.6f}")


def demo_second_order_correction():
    """Test the second-order Richardson correction."""
    section_separator("SECOND-ORDER CORRECTION TEST")
    
    print("B_n = E_n - 1/(2(n+1)) + 1/(12(n+1)²)")
    print("Conjecture: |B_n - γ| = O(n⁻⁴)\n")
    
    print(f"{'n':>6} | {'|B_n - γ|':>20} | {'n⁴ × |B_n - γ|':>20}")
    print("-" * 55)
    
    for n in [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000]:
        bn = euler_renorm(n) - 1.0/(2*(n+1)) + 1.0/(12*(n+1)**2)
        err = abs(bn - GAMMA_REF)
        scaled = (n+1)**4 * err if err > 0 else 0
        
        print(f"{n:>6} | {err:>20.15e} | {scaled:>20.10f}")


def demo_log_convexity():
    """Test log-convexity of the error sequence."""
    section_separator("LOG-CONVEXITY OF ERROR TEST")
    
    print("Testing: e_n² ≤ e_{n-1} × e_{n+1} where e_n = E_n - γ\n")
    
    violations = 0
    tested = 0
    
    for n in range(1, 500):
        e_prev = euler_renorm(n - 1) - GAMMA_REF
        e_curr = euler_renorm(n) - GAMMA_REF
        e_next = euler_renorm(n + 1) - GAMMA_REF
        
        if e_prev > 0 and e_curr > 0 and e_next > 0:
            tested += 1
            if e_curr**2 > e_prev * e_next + 1e-20:
                violations += 1
                if violations <= 5:
                    print(f"  Violation at n={n}: e²={e_curr**2:.6e}, e_prev*e_next={e_prev*e_next:.6e}")
    
    if violations == 0:
        print(f"  ✓ Log-convexity holds for all {tested} tested values (n = 1 to 499)")
    else:
        print(f"  ✗ {violations} violations found out of {tested} tests")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║  Euler-Mascheroni Constant: Certified Approximation Laboratory     ║")
    print("║  γ = lim_{n→∞} (H_n - log n) ≈ 0.5772156649...                    ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_convergence_comparison()
    demo_certified_bounds()
    demo_monotonicity()
    demo_series_terms()
    demo_richardson_conjecture()
    demo_second_order_correction()
    demo_log_convexity()
    
    section_separator("SUMMARY")
    print("Key proven results (verified in Lean 4):")
    print("  1. eulerRenorm_antitone: The sequence E_n is strictly decreasing")
    print("  2. eulerRenorm_pos: Each E_n > 0 (lower bounded)")
    print("  3. eulerRenorm_tendsto: E_n → γ (existence of limit)")
    print("  4. euler_error_upper: E_n - γ ≤ 1/(n+1) (quantitative convergence)")
    print("  5. gammaSeriesTerm_le: a_m ≤ 1/(2(m+1)²) (series acceleration)")
    print("  6. gammaApprox_certified: Certified error bound for approximation")
    print("  7. gamma_approximation_complexity: Linear complexity bound")
    print("  8. exists_gamma_certificate: Reusable approximation certificate for γ")
    print("  9. gammaRichardson_tendsto: Richardson correction converges to γ")
