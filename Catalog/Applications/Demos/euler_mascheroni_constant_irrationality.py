#!/usr/bin/env python3
"""
Applications of Euler–Mascheroni constant theory.

Demonstrates practical uses of the formal approximation infrastructure:
  1. Certified computation: bounding γ with proven error guarantees
  2. Prime counting estimates using γ
  3. Random matrix theory connections
  4. Information-theoretic applications
  5. Coupon collector problem
"""

import math
from typing import Tuple, List


# High-precision γ
GAMMA = 0.5772156649015328606065120900824024310421593359


def certified_gamma_bounds(n: int) -> Tuple[float, float]:
    """
    Return certified bounds [lower, upper] on γ using n harmonic terms.

    By our formal theorems:
      H_n - log(n+1) < γ < H_n - log(n)

    These bounds are *proven correct* in our formal development.

    Args:
        n: Number of harmonic terms

    Returns:
        (lower_bound, upper_bound) with guaranteed lower ≤ γ ≤ upper

    Example:
        >>> lo, hi = certified_gamma_bounds(10000)
        >>> hi - lo
        9.999500033330834e-05
    """
    h_n = sum(1.0 / k for k in range(1, n + 1))
    return h_n - math.log(n + 1), h_n - math.log(n)


# ─── Application 1: Prime Counting ───────────────────────────────────────────

def mertens_estimate(n: int) -> Tuple[float, float]:
    """
    Mertens' theorem: sum_{p ≤ n} 1/p ≈ log(log(n)) + M
    where M = γ + sum_p (log(1 - 1/p) + 1/p) ≈ 0.2615...

    The Euler–Mascheroni constant is the dominant term in M.

    Returns actual sum of reciprocal primes and the Mertens estimate.
    """
    def sieve(limit):
        is_prime = [True] * (limit + 1)
        is_prime[0] = is_prime[1] = False
        for i in range(2, int(limit**0.5) + 1):
            if is_prime[i]:
                for j in range(i*i, limit + 1, i):
                    is_prime[j] = False
        return [i for i in range(2, limit + 1) if is_prime[i]]

    primes = sieve(n)
    actual_sum = sum(1.0 / p for p in primes)

    # Mertens' constant M ≈ 0.2615
    MERTENS = 0.2614972128476427
    estimate = math.log(math.log(n)) + MERTENS if n > 1 else 0

    return actual_sum, estimate


# ─── Application 2: Coupon Collector Problem ─────────────────────────────────

def coupon_collector_expected(n: int) -> float:
    """
    Expected number of draws to collect all n distinct coupons.

    E[T_n] = n · H_n ≈ n · (log(n) + γ)

    The Euler–Mascheroni constant provides the correction term.

    Args:
        n: Number of distinct coupon types

    Returns:
        Expected number of draws
    """
    return n * sum(1.0 / k for k in range(1, n + 1))


def coupon_collector_gamma_correction(n: int) -> Tuple[float, float, float]:
    """
    Show the role of γ in the coupon collector formula.

    Returns (n·log(n), n·(log(n)+γ), n·H_n) showing that γ provides
    the essential correction from n·log(n) to the true expectation.
    """
    h_n = sum(1.0 / k for k in range(1, n + 1))
    naive = n * math.log(n)
    corrected = n * (math.log(n) + GAMMA)
    exact = n * h_n
    return naive, corrected, exact


# ─── Application 3: Laplace Transform and Exponential Integral ───────────────

def exponential_integral_gamma(x: float, terms: int = 100) -> float:
    """
    The exponential integral Ei(x) for x > 0 involves γ:
      Ei(x) = γ + log(x) + sum_{n=1}^∞ x^n / (n · n!)

    Args:
        x: Positive real number
        terms: Number of series terms

    Returns:
        Ei(x)
    """
    result = GAMMA + math.log(abs(x))
    term = x
    factorial = 1
    for n in range(1, terms + 1):
        factorial *= n
        result += term / (n * factorial)
        term *= x
        if abs(term / (n * factorial)) < 1e-15:
            break
    return result


# ─── Application 4: Extreme Value Theory ─────────────────────────────────────

def gumbel_distribution_mean():
    """
    The Gumbel distribution (type-I extreme value) has mean = γ.

    The Gumbel distribution models the maximum of many independent
    samples from exponential-like distributions. Its PDF is:
      f(x) = exp(-(x + exp(-x)))

    The mean of this distribution is exactly γ.

    Returns:
        Dictionary with Gumbel distribution properties
    """
    return {
        'mean': GAMMA,
        'median': -math.log(math.log(2)),
        'mode': 0.0,
        'variance': math.pi**2 / 6,
        'skewness': 12 * math.sqrt(6) * 1.2020569031595942 / math.pi**3,
        'description': (
            'The Gumbel distribution arises as the limit distribution '
            'of the maximum of n independent exponential random variables. '
            'Its mean equals the Euler-Mascheroni constant γ.'
        ),
    }


# ─── Application 5: Digamma Function ─────────────────────────────────────────

def digamma_at_one():
    """
    The digamma function ψ(1) = -γ.

    The digamma function is ψ(x) = d/dx log(Γ(x)) = Γ'(x)/Γ(x).
    At x = 1: ψ(1) = -γ.

    More generally: ψ(n) = H_{n-1} - γ for positive integers n.
    """
    return {
        'psi_1': -GAMMA,
        'relation': 'ψ(n) = H_{n-1} - γ for positive integers n',
        'values': {n: sum(1.0/k for k in range(1, n)) - GAMMA for n in range(1, 11)},
    }


# ─── Main Demo ───────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATIONS OF EULER–MASCHERONI CONSTANT THEORY")
    print("=" * 70)

    # Application 1: Certified bounds
    print("\n─── APPLICATION 1: Certified Bounds on γ ───")
    for n in [10, 100, 1000, 10000, 100000]:
        lo, hi = certified_gamma_bounds(n)
        print(f"  n={n:>6}: {lo:.14f} < γ < {hi:.14f}  (width {hi-lo:.2e})")

    # Application 2: Mertens' theorem
    print("\n─── APPLICATION 2: Mertens' Theorem (Reciprocal Primes) ───")
    print(f"  Mertens' constant involves γ: M = γ + Σ(log(1-1/p) + 1/p)")
    for n in [100, 1000, 10000, 100000]:
        actual, estimate = mertens_estimate(n)
        print(f"  n={n:>6}: Σ(1/p) = {actual:.6f}, estimate = {estimate:.6f}, "
              f"error = {abs(actual-estimate):.4e}")

    # Application 3: Coupon collector
    print("\n─── APPLICATION 3: Coupon Collector Problem ───")
    print(f"  E[T_n] = n·H_n ≈ n·(log n + γ)")
    for n in [10, 50, 100, 365]:
        naive, corrected, exact = coupon_collector_gamma_correction(n)
        print(f"  n={n:>3}: n·log(n)={naive:.1f}, "
              f"n·(log n+γ)={corrected:.1f}, n·H_n={exact:.1f}")

    # Application 4: Extreme value theory
    print("\n─── APPLICATION 4: Gumbel Distribution ───")
    gumbel = gumbel_distribution_mean()
    print(f"  The Gumbel distribution (extreme value type I):")
    print(f"  Mean = γ = {gumbel['mean']:.16f}")
    print(f"  Variance = π²/6 = {gumbel['variance']:.10f}")
    print(f"  {gumbel['description']}")

    # Application 5: Digamma function
    print("\n─── APPLICATION 5: Digamma Function ───")
    psi = digamma_at_one()
    print(f"  ψ(1) = -γ = {psi['psi_1']:.16f}")
    print(f"  Relation: {psi['relation']}")
    print(f"  Values:")
    for n, val in list(psi['values'].items())[:6]:
        print(f"    ψ({n}) = {val:.10f}")

    # Application 6: Exponential integral
    print("\n─── APPLICATION 6: Exponential Integral ───")
    print(f"  Ei(x) = γ + log(x) + Σ x^n/(n·n!)")
    for x in [0.5, 1.0, 2.0, 5.0]:
        ei = exponential_integral_gamma(x)
        print(f"  Ei({x}) = {ei:.10f}")


#!/usr/bin/env python3
"""
Demonstration of the Euler–Mascheroni constant approximation theory.

This script provides concrete numerical illustrations of the theorems
formalized in our Lean 4 development:
  1. Convergence of H_n - log(n) to γ
  2. The O(1/n) convergence rate bounds
  3. Rational approximation quality for irrationality criteria
  4. Scheme invariance between log(n) and log(n+1) renormalization
"""

import math
from fractions import Fraction

# Known high-precision value of γ
GAMMA = 0.5772156649015328606065120900824024310421593359

def harmonic(n: int) -> float:
    """Compute H_n = sum_{k=1}^{n} 1/k."""
    return sum(1.0 / k for k in range(1, n + 1))

def harmonic_exact(n: int) -> Fraction:
    """Compute H_n exactly using rational arithmetic."""
    return sum(Fraction(1, k) for k in range(1, n + 1))

def euler_mascheroni_seq(n: int) -> float:
    """Compute a_n = H_n - log(n)."""
    if n < 1:
        return 0.0
    return harmonic(n) - math.log(n)

def euler_mascheroni_seq_alt(n: int) -> float:
    """Compute b_n = H_n - log(n+1) (alternative scheme)."""
    return harmonic(n) - math.log(n + 1)


def demo_convergence():
    """Demonstrate convergence of the Euler-Mascheroni sequence."""
    print("=" * 70)
    print("DEMO 1: Convergence of H_n - log(n) to γ")
    print("=" * 70)
    print(f"\nKnown value: γ ≈ {GAMMA:.16f}")
    print(f"\n{'n':>10} {'H_n - log(n)':>20} {'Error':>15} {'1/n bound':>12}")
    print("-" * 60)

    for n in [1, 2, 5, 10, 50, 100, 1000, 10000, 100000]:
        a_n = euler_mascheroni_seq(n)
        error = a_n - GAMMA
        bound = 1.0 / n
        print(f"{n:>10} {a_n:>20.14f} {error:>15.2e} {bound:>12.2e}")

    print("\nObservation: The error is always positive (sequence approaches")
    print("from above) and bounded by 1/n, confirming our formal theorem.")


def demo_bounds():
    """Demonstrate the two-sided bounds on the convergence rate."""
    print("\n" + "=" * 70)
    print("DEMO 2: Convergence Rate Bounds")
    print("=" * 70)
    print(f"\nTheorem: 0 < a_n - γ < 1/n for n ≥ 1")
    print(f"\n{'n':>10} {'a_n - γ':>18} {'1/(2(n+1))':>14} {'1/n':>12} {'Ratio (a_n-γ)/(1/n)':>22}")
    print("-" * 78)

    for n in [1, 2, 5, 10, 50, 100, 1000, 10000]:
        a_n = euler_mascheroni_seq(n)
        diff = a_n - GAMMA
        lower = 1.0 / (2 * (n + 1))
        upper = 1.0 / n
        ratio = diff * n  # normalized ratio
        print(f"{n:>10} {diff:>18.12f} {lower:>14.8f} {upper:>12.8f} {ratio:>22.8f}")

    print("\nObservation: The ratio (a_n - γ)·n converges to 1/2,")
    print("showing the precise asymptotic a_n - γ ~ 1/(2n).")


def demo_irrationality_criterion():
    """Demonstrate the irrationality criterion threshold."""
    print("\n" + "=" * 70)
    print("DEMO 3: Irrationality Criterion — The 1/q² Barrier")
    print("=" * 70)
    print(f"\nTheorem: If |x - p/q| < 1/(2q²) for infinitely many p/q ≠ x,")
    print(f"then x is irrational.")
    print(f"\nCompare: rational x = 1/3 can be approximated to O(1/q) but NOT O(1/q²)")
    print()

    x_rat = Fraction(1, 3)
    x_float = float(x_rat)

    print(f"Target: x = 1/3 = {x_float:.16f}")
    print(f"\n{'q':>8} {'best p':>8} {'|x-p/q|':>18} {'1/(2q²)':>18} {'1/q':>12} {'< 1/(2q²)?':>12}")
    print("-" * 80)

    for q in [1, 2, 3, 5, 10, 30, 100, 1000]:
        # Find best p/q approximation to 1/3
        p = round(x_float * q)
        if p == q * x_float:
            # p/q = x exactly, use next best
            p_alt = p + 1  # or p - 1
            error_alt = abs(x_float - p_alt / q)
            p_used = p_alt
        else:
            p_used = p
        error = abs(x_float - p_used / q)
        threshold = 1.0 / (2 * q * q) if q > 0 else float('inf')
        one_over_q = 1.0 / q if q > 0 else float('inf')
        beats = "YES" if error < threshold and error > 0 else "NO"
        print(f"{q:>8} {p_used:>8} {error:>18.12f} {threshold:>18.12f} {one_over_q:>12.8f} {beats:>12}")

    print("\nFor rational x = 1/3, approximants with p/q ≠ x satisfy")
    print("|1/3 - p/q| ≥ 1/(3q), which exceeds 1/(2q²) for q > 3/2.")
    print("So no irrational-quality approximations exist beyond q = 1.")


def demo_scheme_invariance():
    """Demonstrate scheme invariance: log(n) vs log(n+1)."""
    print("\n" + "=" * 70)
    print("DEMO 4: Scheme Invariance — log(n) vs log(n+1)")
    print("=" * 70)
    print(f"\nBoth H_n - log(n) and H_n - log(n+1) converge to γ.")
    print(f"\n{'n':>10} {'H_n - log(n)':>18} {'H_n - log(n+1)':>18} {'difference':>15}")
    print("-" * 65)

    for n in [1, 2, 5, 10, 50, 100, 1000, 10000]:
        scheme1 = euler_mascheroni_seq(n)
        scheme2 = euler_mascheroni_seq_alt(n)
        diff = scheme1 - scheme2
        print(f"{n:>10} {scheme1:>18.14f} {scheme2:>18.14f} {diff:>15.10f}")

    print(f"\nDifference = log(1 + 1/n) → 0, confirming both converge to γ.")
    print(f"γ is trapped between the two sequences: H_n - log(n+1) < γ < H_n - log(n)")


def demo_continued_fraction():
    """Analyze the continued fraction of γ."""
    print("\n" + "=" * 70)
    print("DEMO 5: Continued Fraction Expansion of γ")
    print("=" * 70)

    # Compute continued fraction partial quotients
    def continued_fraction(x: float, n_terms: int = 30) -> list:
        """Compute first n_terms of the continued fraction expansion."""
        result = []
        for _ in range(n_terms):
            a = int(math.floor(x))
            result.append(a)
            frac = x - a
            if abs(frac) < 1e-12:
                break
            x = 1.0 / frac
        return result

    cf = continued_fraction(GAMMA, 25)
    print(f"\nγ = [{cf[0]}; {', '.join(str(a) for a in cf[1:])}]")
    print(f"\nPartial quotients: {cf}")

    # Compute convergents
    print(f"\n{'k':>4} {'a_k':>6} {'p_k/q_k':>20} {'|γ - p_k/q_k|':>20} {'1/(2q_k²)':>18}")
    print("-" * 72)

    p_prev, p_curr = 1, cf[0]
    q_prev, q_curr = 0, 1

    for k in range(len(cf)):
        a_k = cf[k]
        if k == 0:
            p_k, q_k = a_k, 1
        elif k == 1:
            p_k = a_k * cf[0] + 1
            q_k = a_k
        else:
            p_k = a_k * p_curr + p_prev
            q_k = a_k * q_curr + q_prev

        error = abs(GAMMA - p_k / q_k) if q_k > 0 else 0
        threshold = 1.0 / (2 * q_k * q_k) if q_k > 0 else 0
        beats = "✓" if error < threshold else ""

        print(f"{k:>4} {a_k:>6} {p_k:>10}/{q_k:<9} {error:>20.2e} {threshold:>18.2e} {beats}")

        p_prev, p_curr = p_curr, p_k
        q_prev, q_curr = q_curr, q_k

    print("\n✓ marks convergents that beat the 1/(2q²) irrationality threshold.")
    print("If infinitely many convergents beat this threshold, γ is irrational.")


if __name__ == "__main__":
    demo_convergence()
    demo_bounds()
    demo_irrationality_criterion()
    demo_scheme_invariance()
    demo_continued_fraction()
    print("\n" + "=" * 70)
    print("All demonstrations complete.")
    print("=" * 70)
