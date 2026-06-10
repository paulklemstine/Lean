#!/usr/bin/env python3
"""
applications.py — Practical applications of symmetric power coefficient bounds.

Demonstrates:
  1. Euler product truncation error estimation
  2. L-function evaluation with certified error bounds
  3. Weight polytope visualization
  4. Sharpness analysis along special loci
  5. Unimodality detection
"""

import numpy as np
from math import comb, log, pi, sqrt
from algorithms import (
    transfer_exponent,
    symm_euler_coefficients,
    coefficient_bound,
    max_coefficient_bound,
    tropical_transfer_envelope,
    full_analysis,
)


# ─────────────────────────────────────────────────────────────
# Application 1: Euler Product Truncation Error
# ─────────────────────────────────────────────────────────────

def euler_product_truncation_error(
    n: int, M: float, T_bound: float, num_primes: int
) -> float:
    """
    Estimate the truncation error when computing a partial Euler product
    for the Sym^n L-function.

    If we truncate after `num_primes` unramified places, each with
    |α_p|, |β_p| ≤ M and |T_p| ≤ T_bound, the tail contribution
    from each omitted factor is bounded by:

      |P_n(T_p) - 1| ≤ Σ_{k=1}^{n+1} C(n+1,k) M^{E(n,k)} T_bound^k

    Args:
        n: Symmetric power degree
        M: Bound on Satake parameter norms
        T_bound: Bound on |p^{-s}| (e.g., p^{-σ} for Re(s) = σ)
        num_primes: Number of primes included in partial product

    Returns:
        Per-factor error bound for the omitted primes
    """
    error = 0.0
    for k in range(1, n + 2):
        error += coefficient_bound(n, k, M) * T_bound ** k
    return error


def demonstrate_truncation_bounds():
    """Show how coefficient bounds control Euler product convergence."""
    print("APPLICATION 1: Euler Product Truncation Error Bounds")
    print("=" * 60)
    print()
    print("For the Sym^n L-function at s with Re(s) = σ,")
    print("each unramified factor P_n(p^{-s}) satisfies")
    print("|P_n(p^{-s}) - 1| ≤ tail_bound(n, M, p^{-σ})")
    print()

    M = 1.0  # Ramanujan bound: tempered representations
    for n in [2, 4, 8, 12]:
        print(f"\n  Sym^{n} (tempered, M=1):")
        for sigma in [1.0, 1.5, 2.0]:
            for p in [2, 5, 100]:
                T_bound = p ** (-sigma)
                err = euler_product_truncation_error(n, M, T_bound, 0)
                print(f"    p={p:>3}, σ={sigma}: "
                      f"per-factor error ≤ {err:.2e}")


# ─────────────────────────────────────────────────────────────
# Application 2: L-function Coefficient Height Growth
# ─────────────────────────────────────────────────────────────

def coefficient_height_profile(
    alpha: complex, beta: complex, n_max: int
) -> list[tuple[int, float, float]]:
    """
    Track how the maximum coefficient height grows with n.

    Returns (n, max|c_{n,k}|, theoretical_bound) for n = 0, ..., n_max.

    Args:
        alpha, beta: Satake parameters
        n_max: Maximum symmetric power

    Returns:
        List of (n, max_coeff_norm, max_bound)
    """
    M = max(abs(alpha), abs(beta))
    results = []
    for n in range(n_max + 1):
        coeffs = symm_euler_coefficients(alpha, beta, n)
        max_norm = max(abs(c) for c in coeffs)
        bound = max_coefficient_bound(n, M)
        results.append((n, max_norm, bound))
    return results


def demonstrate_height_growth():
    """Show coefficient height growth rate."""
    print("\n\nAPPLICATION 2: Coefficient Height Growth Rate")
    print("=" * 60)

    cases = [
        (2.0, 0.5, "α=2, β=1/2"),
        (1.5, 2/3, "α=3/2, β=2/3"),
    ]

    for alpha, beta, desc in cases:
        print(f"\n  {desc} (M={max(alpha,beta)}):")
        print(f"  {'n':>3} | {'max|c_{n,k}|':>14} | {'Bound':>14} | {'log ratio':>10}")
        print(f"  {'─'*3}-+-{'─'*14}-+-{'─'*14}-+-{'─'*10}")
        results = coefficient_height_profile(alpha, beta, 12)
        for n, actual, bound in results:
            ratio = actual / bound if bound > 0 else 0
            log_ratio = log(ratio) if ratio > 0 else float('-inf')
            print(f"  {n:>3} | {actual:>14.4f} | {bound:>14.4f} | {log_ratio:>10.4f}")


# ─────────────────────────────────────────────────────────────
# Application 3: Weight Polytope Analysis
# ─────────────────────────────────────────────────────────────

def weight_polytope_vertices(n: int) -> list[tuple[int, int]]:
    """
    Compute the weight lattice points for Sym^n of GL₂.

    The weights are (n-j, j) for j = 0, ..., n, lying on the line
    x + y = n in ℕ².

    Args:
        n: Symmetric power degree

    Returns:
        List of (x, y) weight coordinates
    """
    return [(n - j, j) for j in range(n + 1)]


def weight_sum_distribution(n: int, k: int) -> dict:
    """
    Analyze the distribution of weight sums for k-element subsets.

    For each k-element subset S of {0,...,n}, the weight sum is
    Σ_{j∈S} max(n-j, j) (in the M-dominant direction).

    The transfer exponent E(n,k) bounds this from above.

    Args:
        n: Symmetric power degree
        k: Subset size

    Returns:
        Dictionary with min, max, mean, and E(n,k)
    """
    from itertools import combinations

    sums = []
    for subset in combinations(range(n + 1), k):
        s = sum(subset)
        sums.append(s)

    return {
        "min_sum": min(sums),
        "max_sum": max(sums),
        "mean_sum": np.mean(sums),
        "E(n,k)": transfer_exponent(n, k),
        "k(k-1)/2": k * (k - 1) // 2,
        "num_subsets": len(sums),
    }


def demonstrate_weight_polytope():
    """Show weight polytope structure."""
    print("\n\nAPPLICATION 3: Weight Polytope Analysis")
    print("=" * 60)

    for n in [4, 6, 8]:
        print(f"\n  Sym^{n} weight analysis:")
        for k in range(1, n + 1):
            dist = weight_sum_distribution(n, k)
            print(f"    k={k}: sum ∈ [{dist['min_sum']}, {dist['max_sum']}], "
                  f"E(n,k)={dist['E(n,k)']}, "
                  f"mean={dist['mean_sum']:.1f}, "
                  f"#subsets={dist['num_subsets']}")


# ─────────────────────────────────────────────────────────────
# Application 4: Sharpness Along Special Loci
# ─────────────────────────────────────────────────────────────

def sharpness_ratio_analysis(n: int, M: float) -> list[dict]:
    """
    Analyze bound sharpness for α = M, β = 1/M (|αβ| = 1 case).

    Args:
        n: Symmetric power degree
        M: Satake parameter norm

    Returns:
        List of analysis dicts per k
    """
    alpha = complex(M)
    beta = complex(1 / M)
    coeffs = symm_euler_coefficients(alpha, beta, n)

    results = []
    for k in range(n + 2):
        norm = abs(coeffs[k])
        bound = coefficient_bound(n, k, M)
        ratio = norm / bound if bound > 0 else 0
        results.append({
            "k": k,
            "norm": norm,
            "bound": bound,
            "ratio": ratio,
            "E(n,k)": transfer_exponent(n, k),
        })
    return results


def demonstrate_sharpness():
    """Show sharpness analysis along |αβ|=1 locus."""
    print("\n\nAPPLICATION 4: Bound Sharpness on |αβ|=1 Locus")
    print("=" * 60)

    for M in [1.5, 2.0, 3.0]:
        print(f"\n  M = {M}, α=M, β=1/M:")
        for n in [4, 8]:
            print(f"  n = {n}:")
            results = sharpness_ratio_analysis(n, M)
            print(f"    {'k':>3} | {'|c|':>12} | {'bound':>12} | {'ratio':>8}")
            print(f"    {'─'*3}-+-{'─'*12}-+-{'─'*12}-+-{'─'*8}")
            for r in results:
                print(f"    {r['k']:>3} | {r['norm']:>12.4f} | {r['bound']:>12.4f} | {r['ratio']:>8.4f}")


# ─────────────────────────────────────────────────────────────
# Application 5: Unimodality Detection
# ─────────────────────────────────────────────────────────────

def check_unimodality(norms: list[float], tol: float = 1e-12) -> tuple[bool, int]:
    """
    Check if a sequence is unimodal (first non-decreasing, then non-increasing).

    Args:
        norms: Sequence of non-negative reals
        tol: Numerical tolerance

    Returns:
        (is_unimodal, peak_index)
    """
    n = len(norms)
    if n <= 2:
        return True, 0

    peak = 0
    for i in range(1, n):
        if norms[i] > norms[peak] + tol:
            peak = i

    # Check: non-decreasing up to peak
    for i in range(peak):
        if norms[i] > norms[i + 1] + tol:
            return False, peak

    # Check: non-increasing after peak
    for i in range(peak, n - 1):
        if norms[i] + tol < norms[i + 1]:
            return False, peak

    return True, peak


def demonstrate_unimodality():
    """Systematic unimodality testing."""
    print("\n\nAPPLICATION 5: Systematic Unimodality Analysis")
    print("=" * 60)

    violations = 0
    total = 0

    for alpha_r in [1.2, 1.5, 2.0, 3.0, 5.0]:
        for beta_r in [0.2, 0.5, 0.8, 1.0]:
            alpha, beta = complex(alpha_r), complex(beta_r)
            for n in range(2, 15):
                total += 1
                coeffs = symm_euler_coefficients(alpha, beta, n)
                norms = [abs(c) for c in coeffs]
                uni, peak = check_unimodality(norms)
                if not uni:
                    violations += 1
                    print(f"  VIOLATION: α={alpha_r}, β={beta_r}, n={n}")
                    print(f"    norms: {[f'{x:.4f}' for x in norms]}")

    print(f"\n  Tested {total} cases, found {violations} violations")
    if violations == 0:
        print("  Unimodality conjecture supported by all tests ✓")


if __name__ == "__main__":
    demonstrate_truncation_bounds()
    demonstrate_height_growth()
    demonstrate_weight_polytope()
    demonstrate_sharpness()
    demonstrate_unimodality()
    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of coefficient growth bounds for
symmetric power Euler factors.

Computes coefficients of P_n(T; α, β) = ∏_{j=0}^{n} (1 - α^{n-j} β^j T)
and compares them against the theoretical upper bounds:
  |c_{n,k}| ≤ C(n+1, k) · M^{E(n,k)}
where E(n,k) = kn - k(k-1)/2 is the transfer exponent and M = max(|α|, |β|).

Usage:
    python demo.py
"""

import numpy as np
from math import comb, factorial
from itertools import combinations


def transfer_exponent(n: int, k: int) -> int:
    """Compute E(n,k) = k*n - k*(k-1)//2."""
    return k * n - k * (k - 1) // 2


def symm_euler_roots(alpha: complex, beta: complex, n: int) -> list[complex]:
    """Generate the Satake root list [α^n, α^{n-1}β, ..., β^n]."""
    return [alpha ** (n - j) * beta ** j for j in range(n + 1)]


def symm_euler_poly_coeffs(alpha: complex, beta: complex, n: int) -> list[complex]:
    """
    Compute coefficients of P_n(T) = ∏_{j=0}^{n} (1 - r_j T).
    Returns [c_0, c_1, ..., c_{n+1}] where P_n(T) = Σ c_k T^k.
    """
    roots = symm_euler_roots(alpha, beta, n)
    # Start with polynomial 1
    coeffs = [complex(1)]
    for r in roots:
        # Multiply by (1 - r*T)
        new_coeffs = [complex(0)] * (len(coeffs) + 1)
        for i, c in enumerate(coeffs):
            new_coeffs[i] += c
            new_coeffs[i + 1] -= c * r
        coeffs = new_coeffs
    return coeffs


def symm_euler_coeff_via_subsets(alpha: complex, beta: complex, n: int, k: int) -> complex:
    """
    Compute c_{n,k} directly via the elementary symmetric polynomial definition:
    c_{n,k} = (-1)^k * Σ_{|S|=k} Π_{j∈S} α^{n-j} β^j
    """
    roots = symm_euler_roots(alpha, beta, n)
    total = complex(0)
    for subset in combinations(range(n + 1), k):
        prod = complex(1)
        for j in subset:
            prod *= roots[j]
        total += prod
    return ((-1) ** k) * total


def theoretical_bound(n: int, k: int, M: float) -> float:
    """Compute the sharp theoretical bound: C(n+1,k) * M^{E(n,k)}."""
    E = transfer_exponent(n, k)
    return comb(n + 1, k) * M ** E


def tropical_envelope(n: int, k: int, M: float) -> float:
    """Compute the tropical transfer envelope: log C(n+1,k) + E(n,k)*log M."""
    E = transfer_exponent(n, k)
    binom = comb(n + 1, k)
    return np.log(binom) + E * np.log(M) if binom > 0 and M > 0 else float('-inf')


def verify_concavity(n: int) -> bool:
    """Verify that E(n,k) + E(n,k+2) ≤ 2*E(n,k+1) for all valid k."""
    for k in range(n):
        lhs = transfer_exponent(n, k) + transfer_exponent(n, k + 2)
        rhs = 2 * transfer_exponent(n, k + 1)
        if lhs > rhs:
            return False
    return True


def demo_coefficient_profiles():
    """Demonstrate coefficient profiles for various parameters."""
    print("=" * 70)
    print("COEFFICIENT PROFILES FOR SYMMETRIC POWER EULER FACTORS")
    print("=" * 70)

    test_cases = [
        (2.0 + 0j, 0.5 + 0j, "α=2, β=0.5 (|αβ|=1, automorphic case)"),
        (1.5 + 0.5j, 0.3 - 0.2j, "α=1.5+0.5i, β=0.3-0.2i"),
        (3.0 + 0j, 1 / 3 + 0j, "α=3, β=1/3 (|αβ|=1)"),
        (1.0 + 0j, 1.0 + 0j, "α=β=1 (tempered case)"),
    ]

    for alpha, beta, desc in test_cases:
        print(f"\n{'─' * 60}")
        print(f"Parameters: {desc}")
        M = max(abs(alpha), abs(beta))
        m = min(abs(alpha), abs(beta))
        print(f"  M = max(|α|,|β|) = {M:.4f}, min(|α|,|β|) = {m:.4f}")
        print(f"  Sharp bound applies: min ≤ 1 → {m <= 1.0}")

        for n in [2, 4, 6]:
            coeffs = symm_euler_poly_coeffs(alpha, beta, n)
            print(f"\n  n = {n}:")
            print(f"  {'k':>3} | {'|c_{n,k}|':>14} | {'Bound':>14} | {'Ratio':>10} | {'E(n,k)':>8}")
            print(f"  {'─' * 3}-+-{'─' * 14}-+-{'─' * 14}-+-{'─' * 10}-+-{'─' * 8}")

            for k in range(n + 2):
                coeff_norm = abs(coeffs[k])
                bound = theoretical_bound(n, k, M)
                E = transfer_exponent(n, k)
                ratio = coeff_norm / bound if bound > 0 else 0
                print(f"  {k:>3} | {coeff_norm:>14.6f} | {bound:>14.6f} | {ratio:>10.6f} | {E:>8}")


def demo_tropical_envelope():
    """Demonstrate the tropical transfer envelope."""
    print("\n" + "=" * 70)
    print("TROPICAL TRANSFER ENVELOPE")
    print("=" * 70)

    alpha, beta = 2.0 + 0j, 0.5 + 0j
    M = max(abs(alpha), abs(beta))
    print(f"α = {alpha}, β = {beta}, M = {M}")

    for n in [4, 8]:
        coeffs = symm_euler_poly_coeffs(alpha, beta, n)
        print(f"\n  n = {n}: Log-coefficient vs tropical envelope")
        print(f"  {'k':>3} | {'log|c_{n,k}|':>14} | {'Envelope':>14} | {'Gap':>10}")
        print(f"  {'─' * 3}-+-{'─' * 14}-+-{'─' * 14}-+-{'─' * 10}")

        for k in range(n + 2):
            coeff_norm = abs(coeffs[k])
            log_coeff = np.log(coeff_norm) if coeff_norm > 0 else float('-inf')
            envelope = tropical_envelope(n, k, M)
            gap = envelope - log_coeff if log_coeff > float('-inf') else float('inf')
            print(f"  {k:>3} | {log_coeff:>14.6f} | {envelope:>14.6f} | {gap:>10.6f}")


def demo_concavity():
    """Verify concavity of transfer exponent for multiple n values."""
    print("\n" + "=" * 70)
    print("TRANSFER EXPONENT CONCAVITY VERIFICATION")
    print("=" * 70)

    for n in range(1, 16):
        ok = verify_concavity(n)
        exponents = [transfer_exponent(n, k) for k in range(n + 2)]
        max_E = max(exponents)
        print(f"  n={n:>2}: E(n,·) = {exponents}, max = {max_E}, concave = {ok}")


def demo_conjecture_sharpness():
    """Test Conjecture A: Sharpness along diagonal Satake parameters."""
    print("\n" + "=" * 70)
    print("CONJECTURE TEST: SHARPNESS FOR α = β = M")
    print("=" * 70)
    print("Testing whether max_k |c_{n,k}| / [C(n+1,⌊(n+1)/2⌋) · M^{n(n+1)/2}]")
    print("stays bounded (supporting sharpness) or decays (refuting it).\n")

    for M_val in [1.1, 1.5, 2.0]:
        print(f"  M = {M_val}:")
        alpha = complex(M_val)
        beta = complex(M_val)
        for n in range(2, 11):
            coeffs = symm_euler_poly_coeffs(alpha, beta, n)
            max_coeff = max(abs(c) for c in coeffs)
            bound = comb(n + 1, (n + 1) // 2) * M_val ** (n * (n + 1) // 2)
            ratio = max_coeff / bound if bound > 0 else 0
            print(f"    n={n:>2}: max|c| = {max_coeff:>16.4f}, bound = {bound:>16.4f}, ratio = {ratio:.6f}")
        print()


def demo_unimodality():
    """Test Conjecture B: Unimodality of coefficient norms."""
    print("\n" + "=" * 70)
    print("CONJECTURE TEST: UNIMODALITY OF |c_{n,k}|")
    print("=" * 70)

    test_params = [
        (2.0, 0.5), (3.0, 1 / 3), (1.5, 0.8), (2.0, 1.0), (1.1, 0.9)
    ]

    for alpha_r, beta_r in test_params:
        alpha, beta = complex(alpha_r), complex(beta_r)
        print(f"\n  α={alpha_r}, β={beta_r}:")
        for n in range(2, 13):
            coeffs = symm_euler_poly_coeffs(alpha, beta, n)
            norms = [abs(c) for c in coeffs]
            # Check unimodality: norms should first increase then decrease
            unimodal = True
            peak_found = False
            for i in range(1, len(norms)):
                if not peak_found:
                    if norms[i] < norms[i - 1]:
                        peak_found = True
                else:
                    if norms[i] > norms[i - 1]:
                        unimodal = False
                        break
            status = "✓" if unimodal else "✗ VIOLATION"
            print(f"    n={n:>2}: unimodal = {status}")


def demo_verification():
    """Cross-verify polynomial product vs subset expansion definitions."""
    print("\n" + "=" * 70)
    print("CROSS-VERIFICATION: POLYNOMIAL PRODUCT vs SUBSET EXPANSION")
    print("=" * 70)

    alpha = 1.5 + 0.7j
    beta = 0.3 - 0.4j
    print(f"  α = {alpha}, β = {beta}\n")

    for n in range(1, 8):
        coeffs_poly = symm_euler_poly_coeffs(alpha, beta, n)
        max_err = 0
        for k in range(n + 2):
            c_subset = symm_euler_coeff_via_subsets(alpha, beta, n, k)
            err = abs(coeffs_poly[k] - c_subset)
            max_err = max(max_err, err)
        print(f"  n={n}: max |poly - subset| = {max_err:.2e}", "✓" if max_err < 1e-10 else "✗")


if __name__ == "__main__":
    demo_coefficient_profiles()
    demo_tropical_envelope()
    demo_concavity()
    demo_conjecture_sharpness()
    demo_unimodality()
    demo_verification()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
