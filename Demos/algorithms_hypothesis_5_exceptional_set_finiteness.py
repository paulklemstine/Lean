#!/usr/bin/env python3
"""
Algorithms for Exceptional Set Finiteness Analysis

This module implements the core algorithms from the research paper:
1. Modular orbit computation and periodicity detection
2. Obstruction witness search (certified screening)
3. KL divergence estimation for digit distributions
4. Stabilization analysis for the finiteness conjecture

All algorithms correspond to formally verified counterparts in Lean 4.
"""

import math
from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
from dataclasses import dataclass


@dataclass
class ObstructionWitness:
    """A witness for modular degeneracy of a quadratic orbit."""
    parameter_c: int
    prime_p: int
    preperiod: int
    period: int
    orbit_mod_p: List[int]


@dataclass
class BenfordAnalysis:
    """Analysis of leading-digit distribution for a parameter."""
    parameter_c: int
    kl_divergence: float
    digit_frequencies: Dict[int, float]
    sample_size: int
    is_anomalous: bool


def sieve_primes(n: int) -> List[int]:
    """
    Sieve of Eratosthenes.

    Time: O(n log log n)
    Space: O(n)
    """
    if n < 2:
        return []
    is_prime = [True] * (n + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(n**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, n + 1, i):
                is_prime[j] = False
    return [i for i in range(2, n + 1) if is_prime[i]]


def compute_orbit_mod(c: int, x0: int, p: int, max_steps: int) -> Tuple[List[int], Optional[Tuple[int, int]]]:
    """
    Compute orbit of x under T_c modulo p, detecting periodicity.

    Returns:
        (orbit_values, periodicity_info)
        where periodicity_info = (preperiod, period) if detected, else None.

    Time: O(max_steps)
    Space: O(min(max_steps, p)) due to pigeonhole
    """
    orbit = []
    seen: Dict[int, int] = {}
    x = x0 % p
    for step in range(max_steps + 1):
        if x in seen:
            preperiod = seen[x]
            period = step - preperiod
            return orbit, (preperiod, period)
        seen[x] = step
        orbit.append(x)
        x = (x * x + c) % p
    return orbit, None


def find_obstruction_witnesses(
    c: int,
    primes: List[int],
    max_depth: int,
    x0: int = 0
) -> List[ObstructionWitness]:
    """
    Find all prime witnesses for modular degeneracy of T_c orbit.

    For each prime p, checks if the orbit starting at x0 is eventually
    periodic mod p within max_depth steps.

    Time: O(|primes| * max_depth)
    Space: O(max_depth)
    """
    witnesses = []
    for p in primes:
        orbit, info = compute_orbit_mod(c, x0, p, max_depth)
        if info is not None:
            pre, per = info
            witnesses.append(ObstructionWitness(
                parameter_c=c,
                prime_p=p,
                preperiod=pre,
                period=per,
                orbit_mod_p=orbit
            ))
    return witnesses


def certified_obstruction_search(
    C: int,
    P: int,
    N: int,
    x0: int = 0
) -> Dict[int, List[ObstructionWitness]]:
    """
    Certified screening procedure for exceptional parameters.

    Scans c ∈ [-C, C], tests all primes p ≤ P, up to iterate depth N.

    Soundness guarantee (formally verified):
        Every returned parameter has a finite-depth obstruction at
        some prime p ≤ P for the orbit starting at x0.

    Time: O(C * π(P) * N) where π(P) = number of primes ≤ P
    Space: O(C * π(P))

    Returns: dict mapping c to list of obstruction witnesses.
    """
    primes = sieve_primes(P)
    results: Dict[int, List[ObstructionWitness]] = {}
    for c in range(-C, C + 1):
        witnesses = find_obstruction_witnesses(c, primes, N, x0)
        if witnesses:
            results[c] = witnesses
    return results


def leading_digit(n: int, base: int = 10) -> Optional[int]:
    """Extract the leading digit of |n| in the given base."""
    if n == 0:
        return None
    n = abs(n)
    while n >= base:
        n //= base
    return n


def benford_probability(d: int, base: int = 10) -> float:
    """Benford's law probability for leading digit d in given base."""
    return math.log(1 + 1/d, base)


def analyze_benford_compliance(
    c: int,
    x0: int,
    N: int,
    base: int = 10
) -> BenfordAnalysis:
    """
    Analyze how well the orbit of T_c conforms to Benford's law.

    Computes empirical digit frequencies and KL divergence from
    the Benford distribution.

    Time: O(N * digit_length) where digit_length is the number of
          digits in the orbit values (grows exponentially!)
    Space: O(N) for storing the orbit

    Note: For large N, orbit values grow as ~x^(2^N), so this is
    only practical for small N or modular computation.
    """
    digit_counts: Dict[int, int] = defaultdict(int)
    total = 0
    x = x0

    for _ in range(N):
        x = x * x + c
        d = leading_digit(x, base)
        if d is not None:
            digit_counts[d] += 1
            total += 1

    if total == 0:
        return BenfordAnalysis(c, float('inf'), {}, 0, True)

    # Compute frequencies and KL divergence
    frequencies = {d: digit_counts[d] / total for d in range(1, base)}
    kl = 0.0
    for d in range(1, base):
        p_emp = frequencies.get(d, 0)
        q_benford = benford_probability(d, base)
        if p_emp > 0:
            kl += p_emp * math.log(p_emp / q_benford)

    return BenfordAnalysis(
        parameter_c=c,
        kl_divergence=kl,
        digit_frequencies=frequencies,
        sample_size=total,
        is_anomalous=kl > 0.1
    )


def stabilization_analysis(
    radii: List[int],
    P: int = 100,
    N: int = 20
) -> List[Tuple[int, int, float]]:
    """
    Test the finiteness prediction by tracking candidate count vs radius.

    Returns: list of (radius, count, density) tuples.

    The finiteness conjecture predicts:
    - count stabilizes (bounded)
    - density → 0

    Refutation criterion:
    - count grows linearly with radius
    - density stays constant
    """
    results = []
    for R in radii:
        search = certified_obstruction_search(R, P, N)
        count = len(search)
        density = count / (2 * R + 1)
        results.append((R, count, density))
    return results


# ─── Example usage ───────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Obstruction Witness Search (C=20, P=50, N=15) ===\n")
    results = certified_obstruction_search(20, 50, 15)
    for c in sorted(results.keys()):
        witnesses = results[c]
        smallest_prime = min(w.prime_p for w in witnesses)
        print(f"  c = {c:>4}: {len(witnesses)} witness primes, "
              f"smallest = {smallest_prime}")

    print(f"\n  Total flagged: {len(results)} / 41 parameters\n")

    print("=== Benford Compliance Analysis (|c| ≤ 10, N=20) ===\n")
    for c in range(-10, 11):
        analysis = analyze_benford_compliance(c, 0, 20)
        status = "⚠ ANOMALOUS" if analysis.is_anomalous else "  Benford"
        print(f"  c = {c:>4}: KL = {analysis.kl_divergence:.4f}  {status}")

    print("\n=== Stabilization Analysis ===\n")
    stab = stabilization_analysis([5, 10, 20, 50, 100])
    print(f"  {'Radius':>8} {'Count':>8} {'Density':>10}")
    print(f"  {'-'*30}")
    for r, cnt, dens in stab:
        print(f"  {r:>8} {cnt:>8} {dens:>10.4f}")
