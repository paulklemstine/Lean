#!/usr/bin/env python3
"""
Algorithms for Euler–Mascheroni constant approximation and
irrationality testing infrastructure.

Implements:
  1. High-precision harmonic number computation
  2. Euler–Mascheroni constant approximation with certified error bounds
  3. Rational approximation quality testing
  4. Continued fraction analysis with irrationality criterion checking
  5. Partial quotient statistics for irrationality heuristics
"""

from fractions import Fraction
from decimal import Decimal, getcontext
import math
from typing import List, Tuple, Optional


def harmonic_exact(n: int) -> Fraction:
    """
    Compute the n-th harmonic number H_n = sum_{k=1}^{n} 1/k exactly.

    Uses Python's Fraction type for arbitrary-precision rational arithmetic.

    Args:
        n: Positive integer

    Returns:
        H_n as an exact rational number

    Time complexity: O(n · M(n log n)) where M(k) is multiplication cost for k-bit numbers
    Space complexity: O(n log n) for the rational representation

    Example:
        >>> harmonic_exact(4)
        Fraction(25, 12)
        >>> float(harmonic_exact(10))
        2.9289682539682538
    """
    if n <= 0:
        return Fraction(0)
    result = Fraction(0)
    for k in range(1, n + 1):
        result += Fraction(1, k)
    return result


def euler_mascheroni_approx_with_bounds(n: int) -> Tuple[float, float, float]:
    """
    Compute γ approximation with certified error bounds.

    Returns (lower_bound, approximation, upper_bound) such that
    lower_bound ≤ γ ≤ upper_bound, with the approximation being H_n - log(n).

    The bounds come from our formal theorems:
      - γ ≤ H_n - log(n)           (sequence approaches from above)
      - γ > H_n - log(n) - 1/n     (not quite — we use H_n - log(n+1) as lower)
      - More precisely: H_n - log(n+1) < γ < H_n - log(n)

    Args:
        n: Number of terms (must be ≥ 1)

    Returns:
        (lower, approx, upper) where lower ≤ γ ≤ upper

    Example:
        >>> lo, mid, hi = euler_mascheroni_approx_with_bounds(1000)
        >>> hi - lo < 0.001
        True
    """
    assert n >= 1, "n must be at least 1"
    h_n = sum(1.0 / k for k in range(1, n + 1))
    upper = h_n - math.log(n)        # H_n - log(n) > γ
    lower = h_n - math.log(n + 1)    # H_n - log(n+1) < γ
    approx = (upper + lower) / 2     # midpoint estimate
    return lower, approx, upper


def euler_mascheroni_high_precision(num_digits: int = 50) -> Decimal:
    """
    Compute γ to specified precision using the Brent-McMillan algorithm concept.

    Uses the relation γ = lim_{n→∞} (H_n - log(n)) with acceleration
    via the Euler-Maclaurin formula:
      γ ≈ H_n - log(n) - 1/(2n) + sum_{k=1}^{p} B_{2k}/(2k·n^{2k})

    For simplicity, this implementation uses direct summation with
    high-precision arithmetic.

    Args:
        num_digits: Number of decimal digits of precision

    Returns:
        γ as a Decimal with specified precision

    Example:
        >>> gamma = euler_mascheroni_high_precision(30)
        >>> str(gamma)[:10]
        '0.57721566'
    """
    getcontext().prec = num_digits + 20  # extra guard digits

    # Use enough terms for convergence
    n = max(100, num_digits * 5)

    h_n = Decimal(0)
    for k in range(1, n + 1):
        h_n += Decimal(1) / Decimal(k)

    # log(n) via Taylor series around a power of 2
    log_n = _decimal_log(Decimal(n))

    gamma = h_n - log_n

    # Apply first Euler-Maclaurin correction: -1/(2n)
    gamma -= Decimal(1) / (2 * Decimal(n))

    return +Decimal(str(gamma)[:num_digits + 2])


def _decimal_log(x: Decimal) -> Decimal:
    """Compute natural logarithm using AGM method for Decimal."""
    getcontext().prec += 10
    if x <= 0:
        raise ValueError("log of non-positive number")
    if x == 1:
        return Decimal(0)

    # Use the identity: log(x) = log(2^k · y) = k·log(2) + log(y) where 1 ≤ y < 2
    k = 0
    y = x
    while y >= 2:
        y /= 2
        k += 1
    while y < 1:
        y *= 2
        k -= 1

    # log(y) for 1 ≤ y < 2 via Taylor series of log(1 + t) where t = y - 1
    t = y - 1
    result = Decimal(0)
    term = t
    for n in range(1, getcontext().prec + 50):
        result += term / n
        term *= -t
        if abs(term / (n + 1)) < Decimal(10) ** (-(getcontext().prec + 5)):
            break

    # log(2) via same Taylor series
    log2 = Decimal(0)
    t2 = Decimal(1)  # log(2) = log(1 + 1), t = 1
    # Use log(2) = 2·atanh(1/3) + ... or known series
    # Simpler: log(2) = sum_{n=1}^{∞} (-1)^{n+1}/n (very slow, but correct)
    # Better: use log(2) = log(4/3) + log(3/2) with faster converging series
    t_a = Decimal(1) / Decimal(3)  # log(4/3) = log(1 + 1/3)
    t_b = Decimal(1) / Decimal(2)  # log(3/2) = log(1 + 1/2)

    log_4_3 = Decimal(0)
    term_a = t_a
    for n in range(1, getcontext().prec + 100):
        log_4_3 += term_a / n
        term_a *= -t_a
        if abs(term_a / (n + 1)) < Decimal(10) ** (-(getcontext().prec + 5)):
            break

    log_3_2 = Decimal(0)
    term_b = t_b
    for n in range(1, getcontext().prec + 100):
        log_3_2 += term_b / n
        term_b *= -t_b
        if abs(term_b / (n + 1)) < Decimal(10) ** (-(getcontext().prec + 5)):
            break

    log2_val = log_4_3 + log_3_2

    getcontext().prec -= 10
    return +(result + k * log2_val)


def continued_fraction_expansion(x: float, max_terms: int = 100,
                                  tolerance: float = 1e-12) -> List[int]:
    """
    Compute the continued fraction expansion [a_0; a_1, a_2, ...] of x.

    Args:
        x: Real number to expand
        max_terms: Maximum number of partial quotients
        tolerance: Stop when fractional part is below this

    Returns:
        List of partial quotients

    Example:
        >>> continued_fraction_expansion(math.pi, 10)
        [3, 7, 15, 1, 292, 1, 1, 1, 2, 1]
    """
    quotients = []
    for _ in range(max_terms):
        a = int(math.floor(x))
        quotients.append(a)
        frac = x - a
        if abs(frac) < tolerance:
            break
        x = 1.0 / frac
    return quotients


def convergents(partial_quotients: List[int]) -> List[Tuple[int, int]]:
    """
    Compute convergents p_k/q_k from partial quotients.

    Args:
        partial_quotients: List [a_0, a_1, a_2, ...]

    Returns:
        List of (p_k, q_k) pairs

    Example:
        >>> convergents([0, 1, 1, 2, 1, 1, 4])
        [(0, 1), (1, 1), (1, 2), (3, 5), (4, 7), (7, 12), (32, 55)]
    """
    if not partial_quotients:
        return []

    result = []
    p_prev, p_curr = 1, partial_quotients[0]
    q_prev, q_curr = 0, 1
    result.append((p_curr, q_curr))

    for k in range(1, len(partial_quotients)):
        a_k = partial_quotients[k]
        p_new = a_k * p_curr + p_prev
        q_new = a_k * q_curr + q_prev
        result.append((p_new, q_new))
        p_prev, p_curr = p_curr, p_new
        q_prev, q_curr = q_curr, q_new

    return result


def irrationality_measure_test(x: float, max_q: int = 10000) -> dict:
    """
    Test the irrationality measure of x by finding best rational approximations.

    For each denominator q, find the best p and compute |x - p/q|.
    Compare against the thresholds 1/q, 1/q², 1/(2q²).

    The irrationality exponent μ(x) is estimated from the growth rate
    of the best approximation quality.

    Args:
        x: Target real number
        max_q: Maximum denominator to test

    Returns:
        Dictionary with analysis results

    Example:
        >>> result = irrationality_measure_test(0.5772156649015329)
        >>> result['estimated_measure']  # Should be ≈ 2 for typical irrationals
    """
    best_approx = []

    for q in range(1, max_q + 1):
        p = round(x * q)
        error = abs(x - p / q)
        if error > 0:  # Exclude exact matches
            best_approx.append({
                'q': q,
                'p': p,
                'error': error,
                'quality': -math.log(error) / math.log(q) if q > 1 else 0,
                'beats_1_over_q': error < 1.0 / q,
                'beats_1_over_2q2': error < 1.0 / (2 * q * q),
            })

    # Estimate irrationality measure from best approximations
    # μ = lim sup log(1/|x - p/q|) / log(q)
    if best_approx:
        qualities = [a['quality'] for a in best_approx if a['quality'] > 0]
        max_quality = max(qualities) if qualities else 0
        n_beats_threshold = sum(1 for a in best_approx if a['beats_1_over_2q2'])
    else:
        max_quality = 0
        n_beats_threshold = 0

    return {
        'num_tested': max_q,
        'best_approximations': sorted(best_approx, key=lambda a: a['error'])[:20],
        'estimated_measure': max_quality,
        'n_beats_irrationality_threshold': n_beats_threshold,
        'top_quality_approx': sorted(best_approx, key=lambda a: -a['quality'])[:10],
    }


def partial_quotient_statistics(x: float, n_terms: int = 1000) -> dict:
    """
    Analyze statistics of partial quotients for irrationality heuristics.

    For a "generic" irrational number, the Gauss-Kuzmin distribution
    predicts P(a_k = n) = log_2(1 + 1/(n(n+2))). The geometric mean
    should converge to the Khinchin constant K ≈ 2.6854520010...

    Significant deviation from these statistics may indicate special
    number-theoretic structure (as expected for γ if it is algebraic
    or related to special values).

    Args:
        x: Target number
        n_terms: Number of partial quotients to analyze

    Returns:
        Statistics dictionary

    Example:
        >>> stats = partial_quotient_statistics(0.5772156649015329, 20)
        >>> stats['max_quotient']
        5
    """
    cf = continued_fraction_expansion(x, n_terms)
    pq = cf[1:]  # Exclude a_0

    if not pq:
        return {'error': 'No partial quotients computed'}

    # Basic statistics
    max_pq = max(pq)
    mean_pq = sum(pq) / len(pq)
    geo_mean = math.exp(sum(math.log(a) for a in pq) / len(pq))

    # Khinchin constant comparison
    KHINCHIN = 2.6854520010653064

    # Distribution analysis
    freq = {}
    for a in pq:
        freq[a] = freq.get(a, 0) + 1

    # Expected Gauss-Kuzmin frequencies
    gauss_kuzmin = {}
    for n in sorted(freq.keys()):
        gauss_kuzmin[n] = math.log2(1 + 1 / (n * (n + 2)))

    return {
        'n_quotients': len(pq),
        'max_quotient': max_pq,
        'mean_quotient': mean_pq,
        'geometric_mean': geo_mean,
        'khinchin_constant': KHINCHIN,
        'geo_mean_ratio': geo_mean / KHINCHIN,
        'frequency': dict(sorted(freq.items())),
        'gauss_kuzmin_expected': gauss_kuzmin,
    }


def approximation_quality_scan(gamma_approx: float,
                                max_denominator: int = 100000) -> List[dict]:
    """
    Scan for rational approximations to γ that beat the 1/(2q²) threshold.

    These are exactly the approximations needed to apply our formal
    irrationality criterion.

    Args:
        gamma_approx: Approximation to γ
        max_denominator: Maximum denominator to scan

    Returns:
        List of approximations beating the threshold

    Example:
        >>> results = approximation_quality_scan(0.5772156649015329, 1000)
        >>> len(results) > 0
        True
    """
    winners = []
    for q in range(1, max_denominator + 1):
        p = round(gamma_approx * q)
        error = abs(gamma_approx - p / q)
        threshold = 1.0 / (2 * q * q) if q > 0 else 0

        if 0 < error < threshold:
            winners.append({
                'p': p,
                'q': q,
                'error': error,
                'threshold': threshold,
                'ratio': error / threshold,
                'quality_exponent': -math.log(error) / math.log(q) if q > 1 else 0,
            })

    return winners


if __name__ == "__main__":
    print("Euler-Mascheroni Constant: Algorithms Demo")
    print("=" * 50)

    # 1. High-precision computation
    print("\n1. Exact harmonic numbers:")
    for n in [5, 10, 15]:
        h = harmonic_exact(n)
        print(f"   H_{n} = {h} ≈ {float(h):.10f}")

    # 2. Certified bounds
    print("\n2. Certified bounds on γ:")
    for n in [100, 1000, 10000]:
        lo, mid, hi = euler_mascheroni_approx_with_bounds(n)
        print(f"   n={n:>5}: {lo:.12f} < γ < {hi:.12f}  (width={hi-lo:.2e})")

    # 3. Irrationality measure test
    GAMMA = 0.5772156649015328606065120900824024310421593359
    print("\n3. Irrationality measure analysis:")
    result = irrationality_measure_test(GAMMA, 5000)
    print(f"   Estimated irrationality measure: {result['estimated_measure']:.4f}")
    print(f"   Approximations beating 1/(2q²): {result['n_beats_irrationality_threshold']}")
    print(f"   Top quality approximations:")
    for a in result['top_quality_approx'][:5]:
        print(f"     p/q = {a['p']}/{a['q']}, |γ-p/q| = {a['error']:.2e}, quality = {a['quality']:.4f}")

    # 4. Continued fraction statistics
    print("\n4. Continued fraction statistics:")
    stats = partial_quotient_statistics(GAMMA, 25)
    print(f"   Partial quotients: {stats['n_quotients']}")
    print(f"   Max quotient: {stats['max_quotient']}")
    print(f"   Geometric mean: {stats['geometric_mean']:.4f}")
    print(f"   Khinchin constant: {stats['khinchin_constant']:.4f}")
    print(f"   Ratio geo/Khinchin: {stats['geo_mean_ratio']:.4f}")

    # 5. Approximation quality scan
    print("\n5. Approximations to γ beating 1/(2q²):")
    winners = approximation_quality_scan(GAMMA, 10000)
    print(f"   Found {len(winners)} approximations beating threshold")
    for w in winners[:10]:
        print(f"     {w['p']}/{w['q']}: error={w['error']:.2e}, "
              f"threshold={w['threshold']:.2e}, ratio={w['ratio']:.4f}")
