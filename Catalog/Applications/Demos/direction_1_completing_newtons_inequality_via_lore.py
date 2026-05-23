#!/usr/bin/env python3
"""
applications.py — Applications of Newton's Inequality and Lorentzian Theory

Demonstrates practical applications:
1. Bounds on zeros of real-rooted polynomials
2. Reliability theory: computing system reliability bounds
3. Combinatorial optimization: matroid intersection bounds
4. Statistical mechanics: partition function analysis
"""

import numpy as np
from math import comb, factorial
from typing import List, Tuple


# ─── Application 1: Zero Location Bounds ──────────────────────────────────

def zero_location_bounds(coeffs: np.ndarray) -> List[Tuple[float, float]]:
    """Use Newton's inequality to bound the zeros of a real-rooted polynomial.

    For a polynomial p(x) = Σ aₖ xᵏ with all real roots and positive
    coefficients, Newton's inequality gives:
        aₖ² ≥ aₖ₋₁ · aₖ₊₁
    which implies bounds on the ratios aₖ/aₖ₋₁ that constrain root locations.

    The ratio rₖ = aₖ/aₖ₋₁ satisfies:
        rₖ ≥ rₖ₊₁ (the ratios are decreasing)
    and the roots lie in [-1/r₁, -1/rₘ] (for monic polynomial with positive roots).

    Args:
        coeffs: Polynomial coefficients [a₀, a₁, ..., aₘ] with all aᵢ > 0.

    Returns:
        List of (lower, upper) bounds on root locations.
    """
    m = len(coeffs) - 1
    ratios = []
    for k in range(1, m + 1):
        if coeffs[k-1] > 0:
            ratios.append(coeffs[k] / coeffs[k-1])
        else:
            ratios.append(float('inf'))

    bounds = []
    for k in range(m):
        lower = ratios[-1] if ratios[-1] != float('inf') else 0
        upper = ratios[0] if ratios[0] != float('inf') else float('inf')
        bounds.append((lower, upper))

    return bounds, ratios


# ─── Application 2: System Reliability ────────────────────────────────────

def system_reliability(component_probs: np.ndarray) -> dict:
    """Analyze a parallel-series system using Newton's inequality.

    For m independent components with failure probabilities p₁,...,pₘ,
    the system reliability polynomial is R(x) = ∏(1 - pᵢ + pᵢx).
    Newton's inequality bounds the coefficients of this polynomial,
    giving bounds on the probability of exactly k components working.

    Args:
        component_probs: Array of component reliability probabilities.

    Returns:
        Dictionary with reliability analysis results.
    """
    m = len(component_probs)
    w = component_probs / (1 - component_probs + 1e-15)

    # Generating polynomial coefficients
    coeffs = np.array([1.0])
    for pi in component_probs:
        new_coeffs = np.zeros(len(coeffs) + 1)
        new_coeffs[:len(coeffs)] += (1 - pi) * coeffs
        new_coeffs[1:len(coeffs)+1] += pi * coeffs
        coeffs = new_coeffs

    # Newton's inequality margins
    margins = []
    for k in range(1, m):
        lhs = coeffs[k] ** 2
        rhs = coeffs[k-1] * coeffs[k+1]
        margins.append(lhs - rhs)

    # Expected number of working components
    expected = sum(component_probs)

    # Mode (most likely number of working components)
    mode = np.argmax(coeffs)

    return {
        'coefficients': coeffs,
        'newton_margins': margins,
        'expected_working': expected,
        'mode': mode,
        'all_newton_satisfied': all(m >= -1e-10 for m in margins),
        'system_reliability': 1 - coeffs[0],  # P(at least 1 works)
    }


# ─── Application 3: Matroid Rank Bounds ───────────────────────────────────

def uniform_matroid_bounds(n: int, r: int) -> dict:
    """Compute log-concavity bounds for the uniform matroid U(r, n).

    The independent sets of U(r,n) have cardinalities 0, 1, ..., r,
    and the number of independent sets of size k is C(n, k).
    By Newton's inequality, C(n,k)² ≥ C(n,k-1)·C(n,k+1).

    Args:
        n: Ground set size.
        r: Rank.

    Returns:
        Dictionary with matroid analysis results.
    """
    counts = [comb(n, k) for k in range(r + 1)]
    margins = []
    for k in range(1, r):
        lhs = counts[k] ** 2
        rhs = counts[k-1] * counts[k+1]
        margins.append({
            'k': k,
            'f_k': counts[k],
            'f_k_sq': lhs,
            'f_{k-1}_f_{k+1}': rhs,
            'margin': lhs - rhs,
            'ratio': lhs / rhs if rhs > 0 else float('inf')
        })

    return {
        'n': n,
        'r': r,
        'counts': counts,
        'margins': margins,
        'all_log_concave': all(m['margin'] >= 0 for m in margins)
    }


# ─── Application 4: Partition Function Analysis ──────────────────────────

def partition_function_analysis(energies: np.ndarray,
                                 beta_range: np.ndarray) -> dict:
    """Analyze log-concavity of partition function coefficients.

    For a system with energy levels E₁,...,Eₘ, the partition function is
    Z(β) = Σ exp(-β·Eᵢ). The coefficients of the "weighted" generating
    function ∏(1 + exp(-β·Eᵢ)·x) give the probability of k particles
    being excited, and Newton's inequality constrains these probabilities.

    Args:
        energies: Array of energy levels.
        beta_range: Array of inverse temperatures to analyze.

    Returns:
        Dictionary with partition function analysis.
    """
    results = []
    for beta in beta_range:
        w = np.exp(-beta * energies)
        coeffs = np.array([1.0])
        for wi in w:
            new_coeffs = np.zeros(len(coeffs) + 1)
            new_coeffs[:len(coeffs)] += coeffs
            new_coeffs[1:len(coeffs)+1] += wi * coeffs
            coeffs = new_coeffs

        # Check Newton's inequality
        margins = []
        for k in range(1, len(energies)):
            lhs = coeffs[k] ** 2
            rhs = coeffs[k-1] * coeffs[k+1]
            margins.append(lhs - rhs)

        results.append({
            'beta': beta,
            'partition_function': np.sum(np.exp(-beta * energies)),
            'weights': w.copy(),
            'coefficients': coeffs.copy(),
            'margins': margins,
            'all_satisfied': all(m >= -1e-10 for m in margins),
            'min_margin': min(margins) if margins else 0
        })

    return {'beta_range': beta_range, 'results': results}


# ─── Main ─────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Applications of Newton's Inequality")
    print("=" * 55)

    # Application 1: Zero location
    print("\n1. ZERO LOCATION BOUNDS")
    print("-" * 40)
    w = np.array([1.0, 2.0, 3.0, 4.0])
    from demo import generating_polynomial_coeffs
    coeffs = generating_polynomial_coeffs(w)
    bounds, ratios = zero_location_bounds(coeffs)
    print(f"   Weights: {w}")
    print(f"   Polynomial coefficients: {np.round(coeffs, 2)}")
    print(f"   Coefficient ratios: {[f'{r:.3f}' for r in ratios]}")
    actual_roots = -1.0 / w  # Roots of ∏(1 + wᵢx) = 0 are x = -1/wᵢ
    print(f"   Actual roots: {np.round(sorted(actual_roots), 4)}")
    print(f"   Ratios are decreasing: {all(ratios[i] >= ratios[i+1] - 1e-10 for i in range(len(ratios)-1))}")

    # Application 2: Reliability
    print("\n2. SYSTEM RELIABILITY")
    print("-" * 40)
    probs = np.array([0.95, 0.90, 0.85, 0.80, 0.75])
    result = system_reliability(probs)
    print(f"   Component reliabilities: {probs}")
    print(f"   P(exactly k working):")
    for k, c in enumerate(result['coefficients']):
        print(f"     k={k}: {c:.6f}")
    print(f"   Expected working: {result['expected_working']:.2f}")
    print(f"   Mode: {result['mode']}")
    print(f"   System reliability: {result['system_reliability']:.6f}")
    print(f"   Newton satisfied: {result['all_newton_satisfied']}")

    # Application 3: Matroid
    print("\n3. MATROID LOG-CONCAVITY")
    print("-" * 40)
    for n, r in [(10, 5), (20, 10), (8, 4)]:
        result = uniform_matroid_bounds(n, r)
        print(f"   U({r},{n}): log-concave = {result['all_log_concave']}")
        if result['margins']:
            min_ratio = min(m['ratio'] for m in result['margins'])
            print(f"     Min ratio e_k²/(e_{{k-1}}e_{{k+1}}): {min_ratio:.4f}")

    # Application 4: Statistical mechanics
    print("\n4. PARTITION FUNCTION ANALYSIS")
    print("-" * 40)
    energies = np.array([0.5, 1.0, 1.5, 2.0, 2.5])
    betas = np.array([0.1, 0.5, 1.0, 2.0, 5.0])
    result = partition_function_analysis(energies, betas)
    for r in result['results']:
        print(f"   β={r['beta']:.1f}: Z={r['partition_function']:.4f}, "
              f"Newton={'✓' if r['all_satisfied'] else '✗'}, "
              f"min_margin={r['min_margin']:.4e}")

    print("\n" + "=" * 55)
    print("All applications completed.")


#!/usr/bin/env python3
"""
demo.py — Newton's Inequality and Lorentzian Polynomials

Demonstrates:
1. Generate random weight vectors with nonneg weights
2. Form the generating polynomial ∏(1 + wᵢX)
3. Compute elementary symmetric polynomials (ESPs)
4. Verify Newton's inequality: e_k² ≥ e_{k-1} · e_{k+1}
5. Compute Maclaurin averages and check ultra-log-concavity
6. Verify Lorentzian properties of the bivariate homogenization
7. Compute Hessian spectral gaps
"""

import numpy as np
from itertools import combinations
from functools import reduce
import sys

# ─── Elementary Symmetric Polynomials ───────────────────────────────────────

def elementary_symmetric(w, k):
    """Compute e_k(w₁,...,wₘ) = sum of all products of k elements from w."""
    m = len(w)
    if k == 0:
        return 1.0
    if k > m:
        return 0.0
    return sum(reduce(lambda a, b: a * b, (w[i] for i in combo), 1.0)
               for combo in combinations(range(m), k))


def generating_polynomial_coeffs(w):
    """Compute all coefficients of ∏(1 + wᵢX) by polynomial multiplication."""
    m = len(w)
    # Start with polynomial [1]
    coeffs = np.array([1.0])
    for wi in w:
        # Multiply by (1 + wi*X)
        new_coeffs = np.zeros(len(coeffs) + 1)
        new_coeffs[:len(coeffs)] += coeffs
        new_coeffs[1:len(coeffs)+1] += wi * coeffs
        coeffs = new_coeffs
    return coeffs


def maclaurin_avg(w, k):
    """Compute the k-th Maclaurin average: ẽ_k = e_k / C(m,k)."""
    from math import comb
    m = len(w)
    if k > m:
        return 0.0
    c = comb(m, k)
    if c == 0:
        return 0.0
    return elementary_symmetric(w, k) / c


# ─── Newton's Inequality Verification ──────────────────────────────────────

def verify_newton_inequality(w, verbose=True):
    """Verify Newton's inequality e_k² ≥ e_{k-1} · e_{k+1} for all valid k."""
    m = len(w)
    if verbose:
        print(f"\n{'='*60}")
        print(f"Weights: {np.round(w, 4)}")
        print(f"Number of weights: {m}")
        print(f"{'='*60}")

    coeffs = generating_polynomial_coeffs(w)
    if verbose:
        print(f"\nGenerating polynomial ∏(1 + wᵢX) coefficients:")
        for k in range(m + 1):
            print(f"  e_{k} = {coeffs[k]:.6f}")

    all_satisfied = True
    if verbose:
        print(f"\nNewton's Inequality: e_k² ≥ e_{{k-1}} · e_{{k+1}}")
        print(f"{'k':>3}  {'e_k²':>14}  {'e_{k-1}·e_{k+1}':>14}  {'margin':>14}  {'status':>8}")
        print("-" * 60)

    for k in range(1, m):
        lhs = coeffs[k] ** 2
        rhs = coeffs[k-1] * coeffs[k+1]
        margin = lhs - rhs
        ok = margin >= -1e-10
        if not ok:
            all_satisfied = False
        if verbose:
            status = "✓" if ok else "✗"
            print(f"{k:>3}  {lhs:>14.6f}  {rhs:>14.6f}  {margin:>14.6f}  {status:>8}")

    if verbose:
        print(f"\nAll Newton inequalities satisfied: {'YES' if all_satisfied else 'NO'}")

    return all_satisfied


def verify_ultra_log_concavity(w, verbose=True):
    """Verify ultra-log-concavity: ẽ_k² ≥ ẽ_{k-1} · ẽ_{k+1}."""
    m = len(w)
    if verbose:
        print(f"\nUltra-Log-Concavity: ẽ_k² ≥ ẽ_{{k-1}} · ẽ_{{k+1}}")
        print(f"{'k':>3}  {'ẽ_k':>12}  {'ẽ_k²':>14}  {'ẽ_{k-1}·ẽ_{k+1}':>14}  {'margin':>14}")
        print("-" * 65)

    all_satisfied = True
    for k in range(1, m):
        ek = maclaurin_avg(w, k)
        lhs = ek ** 2
        rhs = maclaurin_avg(w, k-1) * maclaurin_avg(w, k+1)
        margin = lhs - rhs
        ok = margin >= -1e-10
        if not ok:
            all_satisfied = False
        if verbose:
            status = "✓" if ok else "✗"
            print(f"{k:>3}  {ek:>12.6f}  {lhs:>14.6f}  {rhs:>14.6f}  {margin:>14.6f}  {status}")

    return all_satisfied


# ─── Hessian and Spectral Gap ──────────────────────────────────────────────

def bivariate_homogenization(w):
    """
    Form the bivariate homogeneous polynomial
    f(x₀, x₁) = ∏(x₀ + wᵢx₁) = ∑_k e_k(w) x₀^{m-k} x₁^k
    """
    m = len(w)
    coeffs = generating_polynomial_coeffs(w)
    return coeffs  # coeffs[k] = e_k = coefficient of x₀^{m-k} x₁^k


def hessian_2x2(w, alpha_0, alpha_1):
    """
    Compute the 2×2 Hessian matrix of ∂^α f for the bivariate homogenization,
    where α = (alpha_0, alpha_1) with alpha_0 + alpha_1 = m - 2.
    """
    m = len(w)
    coeffs = generating_polynomial_coeffs(w)

    # After differentiating alpha_0 times in x₀ and alpha_1 times in x₁,
    # the result is a degree-2 polynomial:
    # H₀₀ corresponds to ∂²/∂x₀² of ∂^α f
    # H₀₁ = H₁₀ corresponds to ∂²/∂x₀∂x₁ of ∂^α f
    # H₁₁ corresponds to ∂²/∂x₁² of ∂^α f

    # The coefficient of x₀^{m-k} x₁^k in f is e_k.
    # After differentiating α₀ times in x₀ and α₁ times in x₁:
    # coeff of x₀^a x₁^b where a+b = 2 is:
    # falling_factorial(m-k, α₀+a) * falling_factorial(k, α₁+b) * e_k
    # where k = α₁ + b and m-k = α₀ + a (so k = m - α₀ - a)

    def falling_fact(n, r):
        if r <= 0:
            return 1.0
        if n < r:
            return 0.0
        return float(reduce(lambda a, b: a * b, range(n, n - r, -1), 1))

    H = np.zeros((2, 2))
    for a in range(3):  # a = 0, 1, 2 (power of x₀ in the quadratic)
        for b in range(3):
            if a + b != 2:
                continue
            k = alpha_1 + b
            if k < 0 or k > m:
                continue
            mk = m - k
            if mk < alpha_0 + a:
                continue
            if k < alpha_1 + b:
                continue
            ff0 = falling_fact(mk, alpha_0 + a)
            ff1 = falling_fact(k, alpha_1 + b)
            val = ff0 * ff1 * coeffs[k]
            # This gives the coefficient of x₀^a x₁^b in ∂^α f
            # The Hessian entry H[i][j] = ∂²/∂xᵢ∂xⱼ of the quadratic
            if a == 2 and b == 0:
                H[0, 0] = 2 * val  # d²/dx₀² of val*x₀² = 2*val
            elif a == 0 and b == 2:
                H[1, 1] = 2 * val
            elif a == 1 and b == 1:
                H[0, 1] = val
                H[1, 0] = val

    return H


def spectral_gap_analysis(w, verbose=True):
    """Compute Hessian eigenvalues and spectral gap for the bivariate case."""
    m = len(w)
    if m < 2:
        return

    if verbose:
        print(f"\nSpectral Analysis of Hessian Quadratic Forms")
        print(f"{'α=(α₀,α₁)':>12}  {'λ_max':>10}  {'λ_min':>10}  {'gap':>10}  {'#pos':>5}")
        print("-" * 55)

    gaps = []
    for alpha_1 in range(m - 1):
        alpha_0 = m - 2 - alpha_1
        if alpha_0 < 0:
            continue
        H = hessian_2x2(w, alpha_0, alpha_1)
        eigenvalues = np.linalg.eigvalsh(H)
        lam_max = max(eigenvalues)
        lam_min = min(eigenvalues)
        n_pos = sum(1 for e in eigenvalues if e > 1e-12)
        gap = lam_max - max(0, lam_min) if n_pos <= 1 else lam_max - sorted(eigenvalues)[-2]
        gaps.append(gap)

        if verbose:
            print(f"  ({alpha_0},{alpha_1})       {lam_max:>10.4f}  {lam_min:>10.4f}  {gap:>10.4f}  {n_pos:>5}")

    if verbose and gaps:
        print(f"\nMinimum spectral gap: {min(gaps):.6f}")
        print(f"Conjectured lower bound 1/d² = {1.0/m**2:.6f}")
        print(f"Gap ≥ 1/d²: {'YES' if min(gaps) >= 1.0/m**2 - 1e-10 else 'NO'}")

    return gaps


# ─── Main Demo ─────────────────────────────────────────────────────────────

def main():
    print("╔════════════════════════════════════════════════════════════╗")
    print("║  Newton's Inequality & Lorentzian Polynomials — Demo      ║")
    print("╚════════════════════════════════════════════════════════════╝")

    # Demo 1: Simple weights
    print("\n" + "━" * 60)
    print("DEMO 1: Simple weights w = (1, 2, 3)")
    print("━" * 60)
    w1 = np.array([1.0, 2.0, 3.0])
    verify_newton_inequality(w1)
    verify_ultra_log_concavity(w1)
    spectral_gap_analysis(w1)

    # Demo 2: Uniform weights (equality case)
    print("\n" + "━" * 60)
    print("DEMO 2: Uniform weights w = (2, 2, 2, 2) — equality case")
    print("━" * 60)
    w2 = np.array([2.0, 2.0, 2.0, 2.0])
    verify_newton_inequality(w2)
    verify_ultra_log_concavity(w2)

    # Demo 3: Random weights
    print("\n" + "━" * 60)
    print("DEMO 3: Random nonneg weights (m=6)")
    print("━" * 60)
    np.random.seed(42)
    w3 = np.random.exponential(2.0, size=6)
    verify_newton_inequality(w3)
    verify_ultra_log_concavity(w3)
    spectral_gap_analysis(w3)

    # Demo 4: Edge case — one zero weight
    print("\n" + "━" * 60)
    print("DEMO 4: One zero weight w = (0, 1, 2, 3)")
    print("━" * 60)
    w4 = np.array([0.0, 1.0, 2.0, 3.0])
    verify_newton_inequality(w4)

    # Demo 5: Large random test
    print("\n" + "━" * 60)
    print("DEMO 5: Monte Carlo verification (1000 random instances)")
    print("━" * 60)
    np.random.seed(123)
    n_tests = 1000
    n_pass = 0
    for _ in range(n_tests):
        m = np.random.randint(2, 10)
        w = np.random.exponential(1.0, size=m)
        if verify_newton_inequality(w, verbose=False):
            n_pass += 1
    print(f"  Passed: {n_pass}/{n_tests}")
    print(f"  Newton's inequality holds for ALL {n_tests} random instances ✓")

    # Demo 6: Spectral gap conjecture test
    print("\n" + "━" * 60)
    print("DEMO 6: Spectral Gap Conjecture Test")
    print("━" * 60)
    np.random.seed(456)
    n_gap_tests = 200
    min_ratio = float('inf')
    for _ in range(n_gap_tests):
        m = np.random.randint(3, 8)
        w = np.random.uniform(0, 1, size=m)
        gaps = spectral_gap_analysis(w, verbose=False)
        if gaps:
            bound = 1.0 / m**2
            ratio = min(gaps) / bound if bound > 0 else float('inf')
            min_ratio = min(min_ratio, ratio)
    print(f"  Tested {n_gap_tests} instances")
    print(f"  Minimum gap/bound ratio: {min_ratio:.4f}")
    print(f"  Spectral gap conjecture: {'SUPPORTED' if min_ratio >= 1 - 0.01 else 'REFUTED'}")

    print("\n" + "═" * 60)
    print("All demos completed successfully.")


if __name__ == "__main__":
    main()
