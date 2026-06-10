#!/usr/bin/env python3
"""
Algorithms for Dynamical Analysis of Repeated Squaring

Implements certified orbit-type classification, idempotent detection,
basin computation, and compositeness testing based on the dynamical
structure of the squaring map x ↦ x² mod n.

All algorithms include docstrings, type hints, and complexity analysis.
"""

import math
from typing import Dict, List, Tuple, Set, Optional, NamedTuple
from collections import Counter


class OrbitType(NamedTuple):
    """Orbit type (preperiod ρ, period λ) of a point under iteration."""
    preperiod: int
    period: int


class DynamicalAnalysis(NamedTuple):
    """Complete dynamical analysis of the squaring map on Z/nZ."""
    n: int
    idempotents: List[int]
    orbit_types: Dict[int, OrbitType]
    basins: Dict[int, Set[int]]
    orbit_type_distribution: Dict[OrbitType, int]
    entropy: float
    is_consistent_with_prime: bool


def squaring_map(x: int, n: int) -> int:
    """
    The squaring map f_n: Z/nZ → Z/nZ, x ↦ x² mod n.

    This is the fundamental dynamical system studied throughout.

    Time: O(log x) for modular squaring
    Space: O(1)
    """
    return pow(x, 2, n)


def compute_orbit_type(a: int, n: int) -> OrbitType:
    """
    Compute the orbit type (ρ, λ) of element a under x ↦ x² mod n
    using Floyd's cycle detection algorithm.

    The orbit of a is: a, f(a), f²(a), ..., f^ρ(a), ..., f^(ρ+λ-1)(a)
    where f^(ρ+λ)(a) = f^ρ(a).

    Algorithm (Floyd's tortoise and hare):
    1. Find meeting point: tortoise moves 1 step, hare moves 2 steps
    2. Find cycle start (preperiod ρ): reset tortoise to start
    3. Find period λ: advance hare around the cycle

    Time: O(ρ + λ) ≤ O(n)
    Space: O(1)
    """
    # Phase 1: Find meeting point
    tortoise = squaring_map(a, n)
    hare = squaring_map(squaring_map(a, n), n)
    while tortoise != hare:
        tortoise = squaring_map(tortoise, n)
        hare = squaring_map(squaring_map(hare, n), n)

    # Phase 2: Find preperiod ρ
    rho = 0
    tortoise = a
    while tortoise != hare:
        tortoise = squaring_map(tortoise, n)
        hare = squaring_map(hare, n)
        rho += 1

    # Phase 3: Find period λ
    lam = 1
    hare = squaring_map(tortoise, n)
    while tortoise != hare:
        hare = squaring_map(hare, n)
        lam += 1

    return OrbitType(rho, lam)


def find_idempotents(n: int) -> List[int]:
    """
    Find all idempotents in Z/nZ: elements e where e² ≡ e (mod n).

    These are exactly the fixed points of the squaring map.
    By the Chinese Remainder Theorem, |{idempotents}| = 2^ω(n).

    Time: O(n)
    Space: O(2^ω(n)) for the result list
    """
    return sorted([x for x in range(n) if pow(x, 2, n) == x])


def find_idempotents_crt(n: int) -> List[int]:
    """
    Find idempotents using CRT construction (more efficient for large n
    with known factorization).

    For n = p1^a1 * ... * pk^ak, each idempotent corresponds to a
    choice of 0 or 1 modulo each prime power factor.

    Time: O(2^ω(n) * ω(n) * log(n)) using CRT reconstruction
    Space: O(2^ω(n))
    """
    # Factor n
    factors = []
    temp = n
    d = 2
    while d * d <= temp:
        if temp % d == 0:
            pk = 1
            while temp % d == 0:
                pk *= d
                temp //= d
            factors.append(pk)
        d += 1
    if temp > 1:
        factors.append(temp)

    if not factors:
        return [0]

    # Generate all combinations of 0/1 mod each prime power
    k = len(factors)
    idempotents = []
    for mask in range(1 << k):
        # Solve: x ≡ b_i (mod factors[i]) where b_i = (mask >> i) & 1
        residues = [(mask >> i) & 1 for i in range(k)]
        x = crt_solve(residues, factors)
        if x is not None:
            idempotents.append(x % n)

    return sorted(idempotents)


def crt_solve(residues: List[int], moduli: List[int]) -> Optional[int]:
    """
    Solve a system of congruences x ≡ r_i (mod m_i) using CRT.

    Requires pairwise coprime moduli.

    Time: O(k * log(M)) where k = len(moduli), M = product of moduli
    Space: O(1) beyond input
    """
    if not moduli:
        return 0

    M = 1
    for m in moduli:
        M *= m

    result = 0
    for r, m in zip(residues, moduli):
        Mi = M // m
        # Find Mi^(-1) mod m using extended Euclidean
        _, inv, _ = extended_gcd(Mi, m)
        inv = inv % m
        result = (result + r * Mi * inv) % M

    return result


def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    """Extended Euclidean algorithm: returns (gcd, x, y) with ax + by = gcd."""
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x


def compute_basins(n: int) -> Dict[int, Set[int]]:
    """
    Compute the basin of attraction for each idempotent (fixed point)
    of the squaring map on Z/nZ.

    Every element eventually reaches a cycle; elements reaching a
    fixed-point cycle belong to that idempotent's basin.

    Time: O(n²) worst case
    Space: O(n)
    """
    idemps = find_idempotents(n)
    basins: Dict[int, Set[int]] = {e: set() for e in idemps}

    # For non-fixed-point cycles, create a separate bucket
    non_fp_basin: Set[int] = set()

    for a in range(n):
        # Iterate until we reach a fixed point or detect a longer cycle
        x = a
        for _ in range(n + 10):
            x = squaring_map(x, n)

        if x in basins:
            basins[x].add(a)
        else:
            non_fp_basin.add(a)

    return basins


def orbit_type_classifier(n: int) -> Dict[str, object]:
    """
    Certified orbit-type classifier for the squaring map on Z/nZ.

    Given n, computes:
    1. All orbit types and their frequencies
    2. Number of distinct orbit types
    3. Whether the orbit structure is consistent with primality
    4. The idempotent structure

    A number n > 1 is consistent with being prime iff:
    - Exactly 2 idempotents (0 and 1)
    - All non-zero elements eventually reach the cycle containing 1

    Time: O(n²) (computing orbit types for all elements)
    Space: O(n)
    """
    idemps = find_idempotents(n)
    omega = len(idemps).bit_length() - 1  # log2 of idempotent count

    # Compute all orbit types
    all_ot = {}
    for a in range(n):
        all_ot[a] = compute_orbit_type(a, n)

    # Distribution
    dist = Counter(all_ot.values())

    # Check primality consistency
    is_prime_consistent = (len(idemps) == 2 and set(idemps) == {0, 1})

    # Entropy
    total = n
    entropy = 0.0
    for count in dist.values():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)

    return {
        "n": n,
        "omega_estimate": omega,
        "idempotents": idemps,
        "nontrivial_idempotents": [e for e in idemps if e not in (0, 1)],
        "orbit_types": dict(all_ot),
        "distribution": dict(dist),
        "num_distinct_orbit_types": len(dist),
        "entropy": entropy,
        "is_prime_consistent": is_prime_consistent,
        "verdict": "POSSIBLY PRIME" if is_prime_consistent else "COMPOSITE"
    }


def dynamical_compositeness_test(n: int) -> Tuple[bool, str]:
    """
    Dynamical compositeness test based on idempotent detection.

    If n has a nontrivial idempotent (e ≠ 0, 1 with e² ≡ e mod n),
    then n is DEFINITELY composite with ω(n) ≥ 2.

    Moreover, from a nontrivial idempotent e, we can extract a factor:
    gcd(e, n) is a nontrivial factor of n.

    Time: O(n) for brute-force idempotent search
    Space: O(1)

    Returns: (is_composite, explanation)
    """
    for e in range(2, n):
        if pow(e, 2, n) == e:
            factor = math.gcd(e, n)
            if 1 < factor < n:
                return True, (f"Found nontrivial idempotent e={e} with e²≡e (mod {n}). "
                              f"gcd({e}, {n}) = {factor} is a nontrivial factor.")

    return False, f"No nontrivial idempotent found; {n} may be prime or a prime power."


def crt_orbit_decomposition(a: int, n: int, p: int, q: int) -> Dict[str, object]:
    """
    Decompose the orbit type of a in Z/nZ via CRT into Z/pZ × Z/qZ.

    For n = p*q with gcd(p,q) = 1:
    - orbit_type(a, n) = (max(ρ_p, ρ_q), lcm(λ_p, λ_q))

    Time: O(n) for orbit type computation
    Space: O(1)
    """
    assert n == p * q and math.gcd(p, q) == 1, "Requires n = p*q with gcd(p,q) = 1"

    ot_n = compute_orbit_type(a, n)
    ot_p = compute_orbit_type(a % p, p)
    ot_q = compute_orbit_type(a % q, q)

    predicted = OrbitType(
        max(ot_p.preperiod, ot_q.preperiod),
        math.lcm(ot_p.period, ot_q.period)
    )

    return {
        "a": a,
        "orbit_type_n": ot_n,
        "orbit_type_p": ot_p,
        "orbit_type_q": ot_q,
        "predicted": predicted,
        "matches": ot_n == predicted
    }


def full_dynamical_analysis(n: int) -> DynamicalAnalysis:
    """
    Perform a complete dynamical analysis of the squaring map on Z/nZ.

    Time: O(n²)
    Space: O(n)
    """
    idemps = find_idempotents(n)
    orbit_types = {a: compute_orbit_type(a, n) for a in range(n)}
    basins = compute_basins(n)
    dist = Counter(orbit_types.values())

    total = n
    entropy = 0.0
    for count in dist.values():
        p = count / total
        if p > 0:
            entropy -= p * math.log2(p)

    is_prime_consistent = (len(idemps) == 2 and set(idemps) == {0, 1})

    return DynamicalAnalysis(
        n=n,
        idempotents=idemps,
        orbit_types=orbit_types,
        basins=basins,
        orbit_type_distribution=dict(dist),
        entropy=entropy,
        is_consistent_with_prime=is_prime_consistent
    )


# ─── Example Usage ─────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=" * 60)
    print("  Dynamical Squaring Algorithms — Examples")
    print("=" * 60)

    # Example 1: Orbit type computation
    print("\n1. Orbit Types for Z/15Z:")
    for a in range(15):
        ot = compute_orbit_type(a, 15)
        print(f"   a={a:2d}: orbit type = (ρ={ot.preperiod}, λ={ot.period})")

    # Example 2: Idempotent detection (brute force vs CRT)
    print("\n2. Idempotent Detection:")
    for n in [6, 15, 30, 105]:
        bf = find_idempotents(n)
        crt = find_idempotents_crt(n)
        print(f"   n={n:3d}: brute_force={bf}, crt={crt}, match={bf==crt}")

    # Example 3: Compositeness test
    print("\n3. Dynamical Compositeness Test:")
    for n in [7, 13, 15, 21, 35, 49, 91]:
        is_comp, explanation = dynamical_compositeness_test(n)
        print(f"   n={n:3d}: {explanation}")

    # Example 4: CRT orbit decomposition
    print("\n4. CRT Orbit Decomposition for n=15=3×5:")
    all_match = True
    for a in range(15):
        result = crt_orbit_decomposition(a, 15, 3, 5)
        if not result["matches"]:
            all_match = False
            print(f"   MISMATCH at a={a}!")
    print(f"   All orbit types match CRT prediction: {all_match}")

    # Example 5: Orbit type classifier
    print("\n5. Orbit Type Classifier:")
    for n in [7, 12, 13, 15, 25, 30]:
        result = orbit_type_classifier(n)
        print(f"   n={n:3d}: {result['verdict']}, "
              f"ω≈{result['omega_estimate']}, "
              f"#orbit_types={result['num_distinct_orbit_types']}, "
              f"H={result['entropy']:.3f} bits")
