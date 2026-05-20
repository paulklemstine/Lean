#!/usr/bin/env python3
"""
Algorithms for Benford Analysis of Quadratic Dynamical Systems

This module implements the core computational algorithms underlying the
Benford universality theory for quadratic maps T_c(x) = x² + c.

Algorithms:
1. Canonical height computation via renormalized log-height convergence
2. Benford deviation measurement (KL divergence and chi-squared)
3. Escape detection and orbit classification
4. Doubling-map trajectory comparison
"""

import math
from typing import List, Tuple, Optional, Dict
from collections import Counter


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Canonical Height Computation
# ─────────────────────────────────────────────────────────────────────

def canonical_height(c: int, x: int, max_iter: int = 50,
                     tol: float = 1e-15) -> Optional[float]:
    """
    Compute the canonical height Λ_c(x) = lim_{n→∞} 2⁻ⁿ·log|T_c⁽ⁿ⁾(x)|.

    Uses the renormalized log-height convergence theorem:
    the sequence aₙ = 2⁻ⁿ·log|T_c⁽ⁿ⁾(x)| is Cauchy with geometric
    convergence rate |aₙ - Λ| ≤ log(2)/2ⁿ.

    Pseudocode:
        val ← x
        for n = 0, 1, 2, ..., max_iter:
            aₙ ← log|val| / 2ⁿ
            if n > 0 and |aₙ - aₙ₋₁| < tol:
                return aₙ
            val ← val² + c
        return aₙ

    Time complexity: O(max_iter · M(B)) where M(B) is the cost of
    multiplying B-bit integers. Since orbit values grow doubly exponentially,
    B ≈ 2^n, making this O(max_iter · M(2^max_iter)).

    For practical purposes, max_iter ≈ 50 gives 15+ digits of precision
    since the error is ≤ log(2)/2⁵⁰ ≈ 6.2 × 10⁻¹⁶.

    Args:
        c: Parameter of the quadratic map.
        x: Starting point.
        max_iter: Maximum iterations (default 50).
        tol: Convergence tolerance (default 1e-15).

    Returns:
        The canonical height Λ_c(x), or None if the orbit hits zero.
    """
    val = x
    prev_a = None
    for n in range(max_iter + 1):
        if val == 0:
            return None  # Orbit hit zero
        try:
            log_val = math.log(abs(val))
        except (ValueError, OverflowError):
            # For extremely large values, use log2 arithmetic
            if val > 0:
                log_val = math.log(2) * val.bit_length()
            else:
                log_val = math.log(2) * (-val).bit_length()

        a_n = log_val / (2 ** n)

        if prev_a is not None and abs(a_n - prev_a) < tol:
            return a_n

        prev_a = a_n

        # Next iterate
        try:
            val = val * val + c
        except OverflowError:
            return a_n  # Return best estimate

    return prev_a


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Benford Deviation Measurement
# ─────────────────────────────────────────────────────────────────────

def benford_kl_divergence(digit_counts: Dict[int, int], base: int = 10) -> float:
    """
    Compute the KL divergence from empirical digit distribution to Benford's law.

    D_KL(P || B) = Σ_{d=1}^{b-1} P(d) · log(P(d) / B(d))

    where B(d) = log_b(1 + 1/d) is the Benford prediction.

    Pseudocode:
        total ← Σ counts
        kl ← 0
        for d = 1 to b-1:
            p_d ← counts[d] / total
            b_d ← log_b(1 + 1/d)
            if p_d > 0:
                kl += p_d · log(p_d / b_d)
        return kl

    Time complexity: O(b)
    Space complexity: O(b)

    The entropy-rate hypothesis predicts D_KL decays exponentially in the
    number of orbit steps for generic c.

    Args:
        digit_counts: Dictionary mapping leading digits to their counts.
        base: Number base (default 10).

    Returns:
        KL divergence (non-negative; 0 means perfect Benford).
    """
    total = sum(digit_counts.get(d, 0) for d in range(1, base))
    if total == 0:
        return float('inf')

    kl = 0.0
    for d in range(1, base):
        p_d = digit_counts.get(d, 0) / total
        b_d = math.log(1 + 1.0 / d) / math.log(base)
        if p_d > 0:
            kl += p_d * math.log(p_d / b_d)

    return kl


def benford_chi_squared(digit_counts: Dict[int, int], base: int = 10) -> float:
    """
    Compute chi-squared statistic against Benford's law.

    χ² = Σ_{d=1}^{b-1} (O_d - E_d)² / E_d

    where E_d = N · log_b(1 + 1/d).

    Time complexity: O(b)

    Args:
        digit_counts: Dictionary mapping digits to counts.
        base: Number base (default 10).

    Returns:
        Chi-squared statistic (lower = closer to Benford).
    """
    total = sum(digit_counts.get(d, 0) for d in range(1, base))
    if total == 0:
        return float('inf')

    chi2 = 0.0
    for d in range(1, base):
        observed = digit_counts.get(d, 0)
        expected = total * math.log(1 + 1.0 / d) / math.log(base)
        if expected > 0:
            chi2 += (observed - expected) ** 2 / expected

    return chi2


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: Escape Detection and Orbit Classification
# ─────────────────────────────────────────────────────────────────────

def classify_orbit(c: int, x: int, max_iter: int = 100) -> str:
    """
    Classify the orbit of x under T_c as escaping, periodic, or preperiodic.

    Uses the escape radius R = max(2, |c| + 1): if |T_c⁽ⁿ⁾(x)| > R for
    some n, the orbit escapes to infinity.

    Pseudocode:
        R ← max(2, |c| + 1)
        seen ← {}
        val ← x
        for n = 0 to max_iter:
            if |val| > R:
                return "escaping at step n"
            if val in seen:
                return "periodic/preperiodic"
            seen.add(val)
            val ← val² + c
        return "undetermined"

    Time complexity: O(max_iter · M(B)) where B is the bit-length of orbit values
    Space complexity: O(max_iter) for the seen set

    Args:
        c: Map parameter.
        x: Starting point.
        max_iter: Maximum iterations.

    Returns:
        Classification string.
    """
    escape_radius = max(2, abs(c) + 1)
    seen = set()
    val = x

    for n in range(max_iter + 1):
        if abs(val) > escape_radius:
            return f"escaping (step {n})"
        if val in seen:
            return f"periodic/preperiodic (detected at step {n})"
        seen.add(val)
        val = val * val + c

    return f"undetermined after {max_iter} steps"


def escape_time(c: int, x: int, max_iter: int = 100) -> Optional[int]:
    """
    Compute the escape time: smallest n such that |T_c⁽ⁿ⁾(x)| > max(2, |c|+1).

    Returns None if the orbit doesn't escape within max_iter steps.
    """
    R = max(2, abs(c) + 1)
    val = x
    for n in range(max_iter + 1):
        if abs(val) > R:
            return n
        val = val * val + c
    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Doubling-Map Trajectory Comparison
# ─────────────────────────────────────────────────────────────────────

def doubling_map_comparison(c: int, x: int, base: int = 10,
                            n_steps: int = 20) -> List[Tuple[float, float, float]]:
    """
    Compare the fractional parts of log_b|T_c⁽ⁿ⁾(x)| with the doubling map
    orbit of Λ_c(x)/log(b).

    The shadowing theorem guarantees:
    |log|T_c⁽ⁿ⁾(x)| - 2ⁿ·Λ_c(x)| ≤ log(2)

    which means the fractional parts of log_b|T_c⁽ⁿ⁾(x)| and 2ⁿ·Λ_c(x)/log(b)
    can differ by at most log(2)/log(b) ≈ 0.301 in base 10.

    Pseudocode:
        Λ ← canonical_height(c, x)
        t₀ ← Λ / log(b)
        val ← x
        results ← []
        for n = 0 to n_steps:
            frac_actual ← frac(log_b(|val|))
            frac_predicted ← frac(2ⁿ · t₀)
            error ← |log|val| - 2ⁿ·Λ|
            results.append((frac_actual, frac_predicted, error))
            val ← val² + c
        return results

    Time complexity: O(n_steps · M(2^n_steps))

    Args:
        c: Map parameter.
        x: Starting point.
        base: Number base (default 10).
        n_steps: Number of orbit steps.

    Returns:
        List of (actual_fract, predicted_fract, absolute_error) tuples.
    """
    Lambda = canonical_height(c, x)
    if Lambda is None:
        return []

    t0 = Lambda / math.log(base)
    val = x
    results = []

    for n in range(n_steps + 1):
        if val == 0:
            break

        try:
            log_val = math.log(abs(val))
            logb_val = log_val / math.log(base)
            frac_actual = logb_val % 1.0
            frac_predicted = ((2 ** n) * t0) % 1.0
            error = abs(log_val - (2 ** n) * Lambda)
            results.append((frac_actual, frac_predicted, error))
        except (ValueError, OverflowError):
            break

        val = val * val + c

    return results


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Benford Universality Scanner
# ─────────────────────────────────────────────────────────────────────

def sieve_primes(n: int) -> List[int]:
    """Sieve of Eratosthenes up to n."""
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [p for p in range(2, n + 1) if is_prime[p]]


def scan_benford_universality(c_range: range, prime_bound: int = 1000,
                               n_iters: int = 15, base: int = 10) -> Dict:
    """
    Scan for Benford universality across parameters c.

    For each c in c_range, compute leading-digit frequencies of T_c⁽ⁿ⁾(p)
    for primes p ≤ prime_bound and 1 ≤ n ≤ n_iters. Report the KL divergence
    from Benford's law.

    Pseudocode:
        primes ← sieve(prime_bound)
        results ← {}
        for c in c_range:
            counts ← {}
            for p in primes:
                val ← p
                for n = 1 to n_iters:
                    val ← val² + c
                    d ← leading_digit(|val|)
                    counts[d] += 1
            results[c] ← KL_divergence(counts)
        return results

    Time complexity: O(|c_range| · |primes| · n_iters · M(B))

    Args:
        c_range: Range of c values to test.
        prime_bound: Upper bound for prime seeds.
        n_iters: Number of iterations per prime.
        base: Number base.

    Returns:
        Dictionary mapping c to (kl_divergence, chi_squared, digit_counts).
    """
    primes = sieve_primes(prime_bound)
    results = {}

    for c in c_range:
        digit_counts: Dict[int, int] = Counter()
        total = 0

        for p in primes:
            val = p
            for n in range(1, n_iters + 1):
                val = val * val + c
                if val != 0:
                    d = leading_digit(val, base)
                    if 1 <= d < base:
                        digit_counts[d] += 1
                        total += 1

        kl = benford_kl_divergence(digit_counts, base)
        chi2 = benford_chi_squared(digit_counts, base)
        results[c] = {
            'kl_divergence': kl,
            'chi_squared': chi2,
            'total_samples': total,
            'digit_counts': dict(digit_counts),
        }

    return results


if __name__ == "__main__":
    print("Canonical Height Examples:")
    for c in [0, 1, -1, 2, -2]:
        for x in [2, 3, 5, 7]:
            h = canonical_height(c, x)
            if h is not None:
                print(f"  Λ_{c}({x}) = {h:.12f}")

    print("\nOrbit Classification Examples:")
    for c in [0, 1, -1, -2]:
        for x in [0, 1, 2, 3]:
            cls = classify_orbit(c, x)
            print(f"  T_{c}, x={x}: {cls}")

    print("\nBenford Universality Scan (c ∈ [-5, 5]):")
    results = scan_benford_universality(range(-5, 6), prime_bound=500, n_iters=10)
    print(f"  {'c':>4} {'KL div':>10} {'χ²':>10} {'Samples':>8}")
    for c in sorted(results.keys()):
        r = results[c]
        print(f"  {c:>4} {r['kl_divergence']:>10.6f} {r['chi_squared']:>10.2f} {r['total_samples']:>8}")
