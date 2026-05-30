#!/usr/bin/env python3
"""
Benford Renormalization — Core Algorithms

Implements the computational machinery for Benford analysis of integer
dynamical systems, including:

1. Leading digit extraction (arbitrary base)
2. Empirical Benford frequency computation
3. Digit discrepancy measurement
4. Rational eigen-obstruction detection (spectral analysis)
5. Cocycle drift/oscillation decomposition
6. Universality conjecture testing framework

All algorithms include complexity analysis and type hints.
"""

import math
from typing import Callable, Optional
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Leading Digit Extraction
# Time: O(log_b(n)), Space: O(1)
# ═══════════════════════════════════════════════════════════════════

def leading_digit(n: int, base: int = 10) -> int:
    """
    Extract the leading (most significant) digit of n in the given base.
    
    Algorithm: Repeatedly divide by base until n < base.
    Complexity: O(log_b(n)) time, O(1) space.
    
    >>> leading_digit(314, 10)
    3
    >>> leading_digit(255, 16)
    15
    >>> leading_digit(1024, 2)
    1
    """
    if base <= 1 or n <= 0:
        return n
    while n >= base:
        n //= base
    return n


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: Benford Frequency Analysis
# Time: O(N * log_b(max(u))), Space: O(b)
# ═══════════════════════════════════════════════════════════════════

@dataclass
class BenfordAnalysis:
    """Results of Benford frequency analysis."""
    base: int
    empirical: dict[int, float]       # digit -> observed frequency
    theoretical: dict[int, float]     # digit -> Benford prediction
    discrepancy: float                # max |empirical - theoretical|
    chi_squared: float                # chi-squared statistic
    sample_size: int

def benford_theoretical(base: int, digit: int) -> float:
    """Benford-predicted frequency for digit d in given base: log_b(1+1/d)."""
    if digit <= 0:
        return 0.0
    return math.log(1 + 1/digit) / math.log(base)

def analyze_benford(sequence: list[int], base: int = 10) -> BenfordAnalysis:
    """
    Perform complete Benford analysis on a sequence.
    
    Algorithm:
    1. Extract leading digits for all elements
    2. Compute empirical frequencies
    3. Compare with theoretical Benford distribution
    4. Compute discrepancy and chi-squared statistics
    
    Complexity: O(N * log_b(max(u))) time, O(b) space.
    
    >>> result = analyze_benford([2**k for k in range(1, 1001)])
    >>> result.discrepancy < 0.01
    True
    """
    N = len(sequence)
    if N == 0:
        return BenfordAnalysis(base, {}, {}, 0.0, 0.0, 0)
    
    # Count leading digits
    counts: dict[int, int] = {d: 0 for d in range(1, base)}
    for x in sequence:
        if x >= 1:
            d = leading_digit(x, base)
            if 1 <= d < base:
                counts[d] += 1
    
    # Compute frequencies
    empirical = {d: counts[d] / N for d in range(1, base)}
    theoretical = {d: benford_theoretical(base, d) for d in range(1, base)}
    
    # Discrepancy (sup norm)
    discrepancy = max(abs(empirical[d] - theoretical[d]) for d in range(1, base))
    
    # Chi-squared statistic
    chi_sq = sum(
        (empirical[d] - theoretical[d])**2 / theoretical[d]
        for d in range(1, base)
    ) * N
    
    return BenfordAnalysis(base, empirical, theoretical, discrepancy, chi_sq, N)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Rational Eigen-Obstruction Detection
# Time: O(N * Q), Space: O(N)
# where Q = max_q parameter
# ═══════════════════════════════════════════════════════════════════

@dataclass
class ObstructionResult:
    """Results of rational eigen-obstruction detection."""
    has_obstruction: bool
    obstruction_order: int          # q value, or 0 if none found
    max_residual: float             # maximum deviation from integrality
    spectral_data: list[float]      # residuals for diagnostic

def detect_obstruction(
    sequence: list[int],
    base: int = 10,
    max_q: int = 50,
    tolerance: float = 1e-8,
    tail_fraction: float = 0.5
) -> ObstructionResult:
    """
    Detect rational eigen-obstructions in a sequence.
    
    A sequence has a rational eigen-obstruction of order q if
    q * log_b(u(k)) is approximately integral for all large k.
    
    Algorithm:
    1. Take the tail of the sequence (discard transients)
    2. For each candidate q from 1 to max_q:
       a. Compute q * log_b(u(k)) for each element
       b. Measure distance to nearest integer
       c. If all residuals < tolerance, report obstruction
    
    Complexity: O(N * max_q) time, O(N) space.
    
    >>> detect_obstruction([10**k for k in range(100)]).has_obstruction
    True
    >>> detect_obstruction([2**k for k in range(1000)]).has_obstruction
    False
    """
    if not sequence:
        return ObstructionResult(False, 0, float('inf'), [])
    
    # Take tail to avoid transients
    start = max(1, int(len(sequence) * (1 - tail_fraction)))
    tail = [x for x in sequence[start:] if x > 0]
    
    if not tail:
        return ObstructionResult(False, 0, float('inf'), [])
    
    log_b = math.log(base)
    
    for q in range(1, max_q + 1):
        residuals = []
        for x in tail:
            val = q * math.log(x) / log_b
            residual = abs(val - round(val))
            residuals.append(residual)
        
        max_res = max(residuals)
        if max_res < tolerance:
            return ObstructionResult(True, q, max_res, residuals)
    
    # Compute spectral data for the last q tested
    final_residuals = []
    for x in tail:
        val = math.log(x) / log_b
        final_residuals.append(val - math.floor(val))
    
    return ObstructionResult(False, 0, max(final_residuals) if final_residuals else 0, final_residuals)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Cocycle Decomposition
# Time: O(N), Space: O(N)
# ═══════════════════════════════════════════════════════════════════

@dataclass
class CocycleDecomposition:
    """Decomposition of the logarithmic cocycle into drift + oscillation."""
    drift_rates: list[float]       # Average log growth per step
    oscillations: list[float]      # Fractional parts (determine digits)
    mean_drift: float              # Lyapunov exponent estimate
    oscillation_variance: float    # Measure of equidistribution

def decompose_cocycle(
    sequence: list[int],
    base: int = 10
) -> CocycleDecomposition:
    """
    Decompose the logarithmic cocycle of a sequence.
    
    For each k, compute:
    - drift_rate(k) = log_b(u(k)) / k  (average growth)
    - oscillation(k) = fract(log_b(u(k)))  (digit-determining part)
    
    The oscillation component is what determines Benford statistics.
    If oscillations are equidistributed mod 1, the sequence is Benford.
    
    Complexity: O(N) time, O(N) space.
    """
    log_b = math.log(base)
    drifts = []
    oscillations = []
    
    for k, x in enumerate(sequence):
        if x <= 0:
            continue
        log_val = math.log(x) / log_b
        drift = log_val / (k + 1)
        osc = log_val - math.floor(log_val)
        drifts.append(drift)
        oscillations.append(osc)
    
    mean_drift = sum(drifts) / len(drifts) if drifts else 0
    
    # Variance of oscillation measures departure from equidistribution
    # For uniform [0,1], variance = 1/12 ≈ 0.0833
    if oscillations:
        mean_osc = sum(oscillations) / len(oscillations)
        osc_var = sum((x - mean_osc)**2 for x in oscillations) / len(oscillations)
    else:
        osc_var = 0
    
    return CocycleDecomposition(drifts, oscillations, mean_drift, osc_var)


# ═══════════════════════════════════════════════════════════════════
# Algorithm 5: Universality Conjecture Tester
# Time: O(S * K * log_b(max orbit)), Space: O(K)
# where S = number of seeds, K = orbit length
# ═══════════════════════════════════════════════════════════════════

@dataclass
class UniversalityTestResult:
    """Results of testing the Benford universality conjecture."""
    map_name: str
    base: int
    num_seeds_tested: int
    num_benford: int                # Seeds with Benford orbits
    num_obstructed: int             # Seeds with rational obstruction
    num_concordant: int             # Seeds matching conjecture prediction
    concordance_rate: float         # Fraction matching prediction
    counterexamples: list[int]      # Seeds violating conjecture (if any)

def test_universality_conjecture(
    T: Callable[[int], int],
    map_name: str,
    seeds: list[int],
    orbit_length: int = 5000,
    base: int = 10,
    benford_threshold: float = 0.03,
    obstruction_max_q: int = 30
) -> UniversalityTestResult:
    """
    Test the Benford universality conjecture for a given dynamical map.
    
    The conjecture predicts: orbit is Benford ⟺ no rational eigen-obstruction.
    
    Algorithm:
    1. For each seed n:
       a. Generate orbit T^k(n) for k = 0, ..., orbit_length
       b. Analyze Benford conformity (digit discrepancy)
       c. Detect rational eigen-obstructions
       d. Check if Benford ⟺ ¬obstruction
    2. Report concordance rate
    
    Complexity: O(S * K * log_b(max orbit)) time, O(K) space per seed.
    """
    num_benford = 0
    num_obstructed = 0
    num_concordant = 0
    counterexamples = []
    
    for seed in seeds:
        # Generate orbit
        orbit = [seed]
        n = seed
        for _ in range(orbit_length):
            try:
                n = T(n)
                if n <= 0:
                    break
                orbit.append(n)
            except (OverflowError, ValueError):
                break
        
        # Analyze
        analysis = analyze_benford(orbit, base)
        is_benford = analysis.discrepancy < benford_threshold
        
        obs = detect_obstruction(orbit, base, obstruction_max_q)
        has_obs = obs.has_obstruction
        
        if is_benford:
            num_benford += 1
        if has_obs:
            num_obstructed += 1
        
        # Check conjecture: Benford ⟺ ¬obstruction
        if is_benford == (not has_obs):
            num_concordant += 1
        else:
            counterexamples.append(seed)
    
    concordance = num_concordant / len(seeds) if seeds else 0
    
    return UniversalityTestResult(
        map_name, base, len(seeds), num_benford, num_obstructed,
        num_concordant, concordance, counterexamples
    )


# ═══════════════════════════════════════════════════════════════════
# Standard Dynamical Maps
# ═══════════════════════════════════════════════════════════════════

def collatz(n: int) -> int:
    """The 3n+1 (Collatz) map."""
    if n <= 1:
        return 4  # Avoid trivial fixed point
    return n // 2 if n % 2 == 0 else 3 * n + 1

def doubling_map(n: int) -> int:
    """The doubling map n -> 2n."""
    return 2 * n

def squaring_map(n: int) -> int:
    """The squaring map n -> n^2 (restricted to avoid overflow)."""
    return min(n * n, 10**15)

def affine_map(a: int, b: int) -> Callable[[int], int]:
    """The affine map n -> a*n + b."""
    return lambda n: a * n + b


if __name__ == "__main__":
    # Quick demo
    print("Testing 2^k sequence (should be Benford):")
    seq = [2**k for k in range(1, 1001)]
    result = analyze_benford(seq)
    print(f"  Discrepancy: {result.discrepancy:.4f}")
    print(f"  Chi-squared: {result.chi_squared:.2f}")
    
    obs = detect_obstruction(seq)
    print(f"  Obstruction: {obs.has_obstruction}")
    
    print("\nTesting 10^k sequence (should NOT be Benford):")
    seq10 = [10**k for k in range(1, 101)]
    result10 = analyze_benford(seq10)
    print(f"  Discrepancy: {result10.discrepancy:.4f}")
    
    obs10 = detect_obstruction(seq10)
    print(f"  Obstruction: {obs10.has_obstruction} (q={obs10.obstruction_order})")
    
    print("\nCollatz universality test (seeds 2-50):")
    test = test_universality_conjecture(
        collatz, "Collatz 3n+1",
        list(range(2, 51)),
        orbit_length=2000
    )
    print(f"  Concordance: {test.concordance_rate:.2%}")
    print(f"  Counterexamples: {test.counterexamples}")
