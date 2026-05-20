#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Benford Base-Invariance Analysis

Implements the mathematical algorithms underlying the base-transfer principle
for Benford's law in prime-indexed dynamical sequences.

Algorithms:
  1. Digit extraction via logarithmic significand
  2. Benford distribution generation
  3. KL divergence computation
  4. Multiplicative independence testing
  5. Admissible base classification
  6. Equidistribution quality metrics
"""

import math
from typing import Dict, List, Tuple, Optional
from collections import Counter


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Digit Extraction
# ─────────────────────────────────────────────────────────────────────

def extract_significand(x: float, base: int) -> float:
    """
    Extract the significand of |x| in the given base.

    The significand s ∈ [1, base) satisfies x = s · base^k for some integer k.
    Computed as s = base^{frac(log_base(|x|))}.

    Complexity: O(1) time, O(1) space.

    Args:
        x: A nonzero real number.
        base: Integer base ≥ 2.

    Returns:
        The significand s ∈ [1, base).

    Example:
        >>> extract_significand(314.15, 10)
        3.1415...
        >>> extract_significand(0.0042, 10)
        4.2...
    """
    if x == 0:
        raise ValueError("Significand undefined for zero")
    x = abs(x)
    log_val = math.log(x) / math.log(base)
    frac_part = log_val - math.floor(log_val)
    return base ** frac_part


def extract_leading_digit(x: float, base: int) -> int:
    """
    Extract the leading digit of |x| in the given base.

    The leading digit d = floor(significand(x, base)) satisfies 1 ≤ d < base.
    This is equivalent to the most significant digit in the base-b representation.

    Correctness theorem (formalized in Lean):
        leading_digit(x, b) = d  ↔  ∃ k : ℤ, d · b^k ≤ |x| < (d+1) · b^k

    Complexity: O(1) time, O(1) space.

    Args:
        x: A nonzero real number.
        base: Integer base ≥ 2.

    Returns:
        The leading digit d ∈ {1, 2, ..., base-1}.

    Example:
        >>> extract_leading_digit(314.15, 10)
        3
        >>> extract_leading_digit(0.0042, 10)
        4
    """
    s = extract_significand(x, base)
    d = int(s)
    # Guard against floating-point edge cases
    return max(1, min(d, base - 1))


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Benford Distribution
# ─────────────────────────────────────────────────────────────────────

def benford_pmf(base: int) -> Dict[int, float]:
    """
    Compute the Benford probability mass function in the given base.

    P(leading digit = d) = log_base(1 + 1/d)  for d = 1, ..., base-1.

    This is the unique distribution arising from equidistribution of
    log_base(x) modulo 1, as proven in our formal development.

    Complexity: O(base) time, O(base) space.

    Args:
        base: Integer base ≥ 2.

    Returns:
        Dictionary mapping digit d to probability P(d).

    Example:
        >>> benford_pmf(10)
        {1: 0.3010..., 2: 0.1760..., ..., 9: 0.0457...}
    """
    if base < 2:
        raise ValueError(f"Base must be ≥ 2, got {base}")
    log_base = math.log(base)
    return {d: math.log(1 + 1/d) / log_base for d in range(1, base)}


def benford_cdf(base: int) -> Dict[int, float]:
    """
    Compute the Benford cumulative distribution function.

    F(d) = log_base(d + 1)  for d = 1, ..., base-1.

    Complexity: O(base) time, O(base) space.
    """
    log_base = math.log(base)
    return {d: math.log(d + 1) / log_base for d in range(1, base)}


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: KL Divergence & Statistical Tests
# ─────────────────────────────────────────────────────────────────────

def kl_divergence(p: Dict[int, float], q: Dict[int, float]) -> float:
    """
    Compute KL divergence D_KL(P || Q) = Σ_d P(d) · ln(P(d) / Q(d)).

    Uses natural logarithm (nats). For bits, divide by ln(2).

    This serves as a quantitative defect functional measuring departure
    from Benford's law. Connection to information theory:
    - D_KL = 0 iff P = Q (perfect Benford)
    - D_KL > 0 measures information-theoretic surprise
    - Small D_KL suggests equidistribution of log phases

    Complexity: O(|support|) time, O(1) space.

    Args:
        p: Observed distribution (empirical).
        q: Reference distribution (Benford).

    Returns:
        KL divergence in nats. Returns infinity if support mismatch.

    Example:
        >>> obs = {1: 0.301, 2: 0.176, ..., 9: 0.046}
        >>> ref = benford_pmf(10)
        >>> kl_divergence(obs, ref)
        0.000...  # close to Benford
    """
    kl = 0.0
    for d in q:
        p_d = p.get(d, 0.0)
        q_d = q[d]
        if p_d > 0 and q_d > 0:
            kl += p_d * math.log(p_d / q_d)
        elif p_d > 0:
            return float('inf')
    return kl


def chi_squared_benford(observed_counts: Dict[int, int], base: int) -> float:
    """
    Compute chi-squared statistic against the Benford distribution.

    χ² = Σ_d (O_d - E_d)² / E_d

    where O_d is observed count and E_d = N · P_benford(d).

    Complexity: O(base) time, O(1) space.
    """
    total = sum(observed_counts.values())
    if total == 0:
        return 0.0
    benford = benford_pmf(base)
    chi2 = 0.0
    for d in range(1, base):
        observed = observed_counts.get(d, 0)
        expected = total * benford[d]
        if expected > 0:
            chi2 += (observed - expected) ** 2 / expected
    return chi2


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Multiplicative Independence
# ─────────────────────────────────────────────────────────────────────

def minimal_base_decomposition(n: int) -> Tuple[int, int]:
    """
    Find the minimal base g and maximal exponent k such that n = g^k.

    This is the canonical decomposition: every integer n ≥ 2 has a unique
    representation n = g^k where g is not a perfect power and k ≥ 1.

    Complexity: O(log²(n)) time, O(1) space.

    Args:
        n: Integer ≥ 2.

    Returns:
        (g, k) where n = g^k and g is minimal.

    Example:
        >>> minimal_base_decomposition(8)
        (2, 3)
        >>> minimal_base_decomposition(7)
        (7, 1)
    """
    if n < 2:
        raise ValueError(f"Input must be ≥ 2, got {n}")

    max_exp = int(math.log2(n)) + 1
    for k in range(max_exp, 0, -1):
        g = round(n ** (1.0 / k))
        for candidate in [g - 1, g, g + 1]:
            if candidate >= 2 and candidate ** k == n:
                return candidate, k
    return n, 1


def are_multiplicatively_independent(a: int, b: int) -> bool:
    """
    Test if a and b are multiplicatively independent.

    Two integers a, b ≥ 2 are multiplicatively independent iff there are
    no positive integers m, n with a^m = b^n. Equivalently, iff they have
    different minimal bases in their canonical decomposition.

    Formal theorem (proven in Lean):
        MultiplicativelyIndependent a b → Irrational(log a / log b)

    Complexity: O(log²(max(a,b))) time, O(1) space.

    Args:
        a, b: Integers ≥ 2.

    Returns:
        True if multiplicatively independent.

    Example:
        >>> are_multiplicatively_independent(2, 3)
        True
        >>> are_multiplicatively_independent(4, 8)
        False  # 4 = 2², 8 = 2³, so 4³ = 8²
    """
    g_a, _ = minimal_base_decomposition(a)
    g_b, _ = minimal_base_decomposition(b)
    return g_a != g_b


# ─────────────────────────────────────────────────────────────────────
# Algorithm 5: Admissible Base Classification
# ─────────────────────────────────────────────────────────────────────

def classify_bases(max_base: int = 20) -> Dict[str, List[int]]:
    """
    Classify bases as admissible or non-admissible for Benford transfer.

    A base b ≥ 2 is admissible iff log(b)/log(2) is irrational, which
    is equivalent to b not being a power of 2.

    Non-admissible bases (powers of 2) can still exhibit Benford behavior,
    but the transfer principle only guarantees consistency across admissible bases.

    Returns dict with keys 'admissible' and 'non_admissible'.
    """
    admissible = []
    non_admissible = []
    for b in range(2, max_base + 1):
        if are_multiplicatively_independent(b, 2):
            admissible.append(b)
        else:
            non_admissible.append(b)
    return {'admissible': admissible, 'non_admissible': non_admissible}


# ─────────────────────────────────────────────────────────────────────
# Algorithm 6: Equidistribution Quality
# ─────────────────────────────────────────────────────────────────────

def fractional_part_histogram(values: List[float], bins: int = 20) -> List[float]:
    """
    Compute histogram of fractional parts of values in [0, 1).

    For equidistributed sequences, each bin should have approximately
    1/bins proportion of values.

    Args:
        values: Sequence of real numbers.
        bins: Number of histogram bins.

    Returns:
        List of bin frequencies (should be ≈ 1/bins each if equidistributed).
    """
    if not values:
        return [0.0] * bins
    counts = [0] * bins
    for v in values:
        frac = v - math.floor(v)
        bin_idx = min(int(frac * bins), bins - 1)
        counts[bin_idx] += 1
    total = len(values)
    return [c / total for c in counts]


def discrepancy_score(values: List[float], bins: int = 20) -> float:
    """
    Compute L² discrepancy of fractional parts from uniform distribution.

    D² = Σ_i (f_i - 1/bins)²

    Lower values indicate better equidistribution.
    """
    hist = fractional_part_histogram(values, bins)
    expected = 1.0 / bins
    return sum((f - expected) ** 2 for f in hist)


def log_equidistribution_score(values: List[float], base: int,
                                bins: int = 20) -> float:
    """
    Compute equidistribution quality of log_base(|x|) mod 1.

    This directly tests the equidistribution criterion that our formal
    theorems identify as the mechanism for Benford's law.
    """
    log_vals = []
    log_base = math.log(base)
    for v in values:
        if v > 0:
            log_vals.append(math.log(v) / log_base)
    return discrepancy_score(log_vals, bins)


# ─────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Benford Base-Invariance: Algorithm Examples")
    print("=" * 50)

    # Example 1: Digit extraction
    print("\n1. Digit Extraction:")
    for x in [314.15, 0.0042, 1e6, 2.718]:
        for b in [10, 7, 3]:
            d = extract_leading_digit(x, b)
            s = extract_significand(x, b)
            print(f"   x = {x:>10}, base {b}: digit = {d}, significand = {s:.4f}")

    # Example 2: Benford distribution
    print("\n2. Benford Distribution (base 10):")
    pmf = benford_pmf(10)
    for d, p in pmf.items():
        print(f"   P(d={d}) = {p:.6f}")

    # Example 3: Multiplicative independence
    print("\n3. Multiplicative Independence:")
    pairs = [(2, 3), (4, 8), (6, 10), (3, 9)]
    for a, b in pairs:
        mi = are_multiplicatively_independent(a, b)
        g_a, k_a = minimal_base_decomposition(a)
        g_b, k_b = minimal_base_decomposition(b)
        print(f"   ({a}, {b}): {'independent' if mi else 'DEPENDENT'}"
              f"  [{a}={g_a}^{k_a}, {b}={g_b}^{k_b}]")

    # Example 4: Base classification
    print("\n4. Base Classification:")
    classes = classify_bases(20)
    print(f"   Admissible (log b/log 2 irrational): {classes['admissible']}")
    print(f"   Non-admissible (powers of 2):        {classes['non_admissible']}")
