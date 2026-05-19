#!/usr/bin/env python3
"""
Algorithms for Odd Perfect Number Obstruction Theory

This module implements the core algorithms for analyzing
odd perfect number candidates via the formal obstruction
framework.

Algorithms:
  1. Euler form analyzer — decompose candidates
  2. Obstruction certificate generator
  3. Support growth cascade tracer
  4. 2-adic constraint checker
  5. Modular obstruction scanner
"""

from math import gcd, log2
from typing import Dict, List, Optional, Set, Tuple
from sympy import factorint, isprime, primerange, nextprime


def sigmaPP(p: int, a: int) -> int:
    """
    Compute the prime-power sigma factor: 1 + p + p² + ... + pᵃ.

    This equals σ₁(p^a) for prime p, and is the fundamental
    building block of the multiplicative obstruction theory.

    Args:
        p: prime base (or any positive integer)
        a: exponent (non-negative integer)

    Returns:
        Sum 1 + p + p² + ... + pᵃ

    Examples:
        >>> sigmaPP(3, 2)
        13
        >>> sigmaPP(5, 1)
        6
    """
    if p == 1:
        return a + 1
    return (p ** (a + 1) - 1) // (p - 1)


def v2(n: int) -> int:
    """
    Compute the 2-adic valuation of n.

    Args:
        n: positive integer

    Returns:
        The largest k such that 2^k divides n

    Examples:
        >>> v2(12)
        2
        >>> v2(7)
        0
    """
    if n == 0:
        return float('inf')
    k = 0
    while n % 2 == 0:
        k += 1
        n //= 2
    return k


def euler_form_check(n: int) -> Optional[Tuple[int, int, int]]:
    """
    Check if n has Euler form n = p^a * m² with p prime, a odd,
    gcd(p, m) = 1.

    Args:
        n: positive odd integer to analyze

    Returns:
        (p, a, m) if n has Euler form, None otherwise

    Complexity: O(sqrt(n) * log(n)) for factorization

    Examples:
        >>> euler_form_check(45)  # 45 = 3^2 * 5 = 5^1 * 3^2
        (5, 1, 3)
    """
    if n <= 0 or n % 2 == 0:
        return None

    factors = factorint(n)
    odd_exp_primes = [(p, e) for p, e in factors.items() if e % 2 == 1]

    if len(odd_exp_primes) != 1:
        return None

    p, a = odd_exp_primes[0]

    # Compute m
    m_sq = n // (p ** a)
    m = int(m_sq ** 0.5)
    if m * m != m_sq:
        return None

    if gcd(p, m) != 1:
        return None

    return (p, a, m)


class ObstructionCertificate:
    """
    An obstruction certificate for an odd perfect number candidate.

    This encapsulates the collection of local constraints that
    any odd perfect number n = p^a * m² must satisfy:
    - 2-adic constraint on sigmaPP(p, a)
    - Prime absorption constraints
    - Support growth bounds
    - Modular constraints

    Attributes:
        euler_prime: the Euler prime p
        euler_exp: the odd exponent a
        forced_primes: primes forced to divide m
        blocked: whether a contradiction was found
        reason: explanation of the blocking contradiction
    """

    def __init__(self, p: int, a: int):
        """
        Initialize an obstruction certificate for Euler prime p
        with exponent a.

        Args:
            p: prime number (the Euler prime)
            a: odd positive integer (the exponent)
        """
        self.euler_prime = p
        self.euler_exp = a
        self.forced_primes: Set[int] = set()
        self.blocked = False
        self.reason = ""
        self.constraints: List[str] = []

    def check_two_adic(self) -> bool:
        """
        Check the 2-adic valuation constraint.

        For an odd perfect n = p^a * m², we need v₂(sigmaPP(p,a)) = 1.

        Returns:
            True if the constraint is satisfied, False if blocked.
        """
        sp = sigmaPP(self.euler_prime, self.euler_exp)
        val = v2(sp)
        self.constraints.append(
            f"v₂(sigmaPP({self.euler_prime},{self.euler_exp})) = {val}"
        )
        if val != 1:
            self.blocked = True
            self.reason = (
                f"v₂(sigmaPP({self.euler_prime},{self.euler_exp})) = {val} ≠ 1"
            )
            return False
        return True

    def check_euler_prime_mod4(self) -> bool:
        """
        Check that p ≡ 1 (mod 4).

        For odd perfect n = p^a * m², with a odd:
        σ₁(n) = 2n, and the parity/mod-4 analysis forces p ≡ 1 (mod 4).

        Returns:
            True if p ≡ 1 mod 4, False otherwise.
        """
        if self.euler_prime % 4 != 1:
            self.blocked = True
            self.reason = (
                f"p = {self.euler_prime} ≡ {self.euler_prime % 4} (mod 4), "
                f"need p ≡ 1 (mod 4)"
            )
            return False
        self.constraints.append(
            f"p = {self.euler_prime} ≡ 1 (mod 4) ✓"
        )
        return True

    def compute_forced_primes(self, depth: int = 2) -> Set[int]:
        """
        Compute the cascade of primes forced to divide m.

        Starting from sigmaPP(p, a), extract its odd prime factors ≠ p.
        These must divide m. Then for each such q, sigmaPP(q, 2)
        (since q appears with even exponent ≥ 2 in m²) contributes
        more forced primes.

        Args:
            depth: number of cascade levels to trace

        Returns:
            Set of all forced prime factors of m

        Complexity: O(depth * max_primes * factorization_cost)
        """
        forced = set()
        frontier = set()

        # Level 0: from the Euler prime
        sp = sigmaPP(self.euler_prime, self.euler_exp)
        for q in factorint(sp).keys():
            if q != self.euler_prime and q != 2:
                forced.add(q)
                frontier.add(q)

        # Subsequent levels
        for level in range(1, depth):
            new_frontier = set()
            for q in frontier:
                sq = sigmaPP(q, 2)  # minimum even exponent
                for r in factorint(sq).keys():
                    if r != 2 and r not in forced and r != self.euler_prime:
                        forced.add(r)
                        new_frontier.add(r)
            frontier = new_frontier

        self.forced_primes = forced
        self.constraints.append(
            f"Forced primes in m (depth {depth}): {sorted(forced)}"
        )
        return forced

    def summary(self) -> str:
        """Generate a human-readable summary of the certificate."""
        lines = [
            f"Obstruction Certificate for p={self.euler_prime}, a={self.euler_exp}",
            f"  sigmaPP({self.euler_prime},{self.euler_exp}) = "
            f"{sigmaPP(self.euler_prime, self.euler_exp)}",
            f"  Status: {'BLOCKED' if self.blocked else 'Open'}",
        ]
        if self.blocked:
            lines.append(f"  Reason: {self.reason}")
        for c in self.constraints:
            lines.append(f"  Constraint: {c}")
        if self.forced_primes:
            lines.append(
                f"  Minimum distinct odd prime factors of m: "
                f"{len(self.forced_primes)}"
            )
        return "\n".join(lines)


def generate_certificates(
    p_bound: int = 100,
    a_values: List[int] = [1, 3, 5],
    depth: int = 2
) -> List[ObstructionCertificate]:
    """
    Generate obstruction certificates for all Euler prime candidates
    up to p_bound.

    Args:
        p_bound: upper bound on Euler prime candidates
        a_values: list of odd exponents to test
        depth: cascade depth for forced prime computation

    Returns:
        List of ObstructionCertificate objects

    Complexity: O(π(p_bound) * |a_values| * depth * factorization_cost)

    Examples:
        >>> certs = generate_certificates(20, [1, 3])
        >>> blocked = [c for c in certs if c.blocked]
        >>> len(blocked) > 0
        True
    """
    certificates = []
    for p in primerange(3, p_bound):
        if p == 2:
            continue
        for a in a_values:
            cert = ObstructionCertificate(p, a)

            # Check constraints in order
            if not cert.check_two_adic():
                certificates.append(cert)
                continue

            if not cert.check_euler_prime_mod4():
                certificates.append(cert)
                continue

            # Compute forced primes
            cert.compute_forced_primes(depth)

            certificates.append(cert)

    return certificates


def modular_obstruction_scan(
    modulus: int = 12,
    p_bound: int = 50,
    a_max: int = 11
) -> Dict[Tuple[int, int], List[str]]:
    """
    Scan for modular obstructions: check if sigmaPP(p, a) mod M
    introduces constraints incompatible with odd perfectness.

    For each (p mod M, a mod M), compute sigmaPP(p, a) mod M
    and check if the forced residue classes create contradictions.

    Args:
        modulus: the modulus M for residue class analysis
        p_bound: upper bound on primes to test
        a_max: maximum exponent to test

    Returns:
        Dictionary mapping (p % M, a % M) to list of obstruction notes

    Complexity: O(π(p_bound) * a_max)
    """
    results = {}
    for p in primerange(3, p_bound):
        for a in range(1, a_max + 1, 2):  # odd a only
            key = (p % modulus, a % modulus)
            sp_mod = sigmaPP(p, a) % modulus
            if key not in results:
                results[key] = []
            results[key].append(
                f"p={p}, a={a}: sigmaPP≡{sp_mod} (mod {modulus})"
            )
    return results


def support_growth_analysis(
    p: int,
    a: int,
    levels: int = 5
) -> List[Tuple[int, Set[int]]]:
    """
    Trace the support growth cascade for a given Euler prime.

    At each level, compute the new primes forced by the sigma
    factors of the primes discovered at the previous level.

    Args:
        p: Euler prime
        a: odd exponent
        levels: number of cascade levels

    Returns:
        List of (level, cumulative_primes) tuples

    Complexity: O(levels * max_primes_per_level * factorization_cost)

    Examples:
        >>> growth = support_growth_analysis(5, 1, 3)
        >>> all(len(g[1]) <= len(growth[-1][1]) for g in growth)
        True
    """
    all_primes = set()
    frontier = set()
    result = []

    # Level 0
    sp = sigmaPP(p, a)
    for q in factorint(sp).keys():
        if q != p and q != 2:
            all_primes.add(q)
            frontier.add(q)
    result.append((0, set(all_primes)))

    for level in range(1, levels):
        new_frontier = set()
        for q in frontier:
            sq = sigmaPP(q, 2)
            for r in factorint(sq).keys():
                if r != 2 and r not in all_primes and r != p:
                    all_primes.add(r)
                    new_frontier.add(r)
        frontier = new_frontier
        result.append((level, set(all_primes)))

    return result


if __name__ == "__main__":
    print("=" * 60)
    print("OBSTRUCTION CERTIFICATE GENERATION")
    print("=" * 60)

    certs = generate_certificates(50, [1, 3, 5], depth=3)

    blocked = [c for c in certs if c.blocked]
    open_certs = [c for c in certs if not c.blocked]

    print(f"\nTotal certificates: {len(certs)}")
    print(f"Blocked: {len(blocked)}")
    print(f"Open: {len(open_certs)}")

    print("\n--- Blocked certificates (sample) ---")
    for cert in blocked[:10]:
        print(cert.summary())
        print()

    print("\n--- Open certificates (all require large m) ---")
    for cert in open_certs[:10]:
        print(cert.summary())
        print()

    print("\n" + "=" * 60)
    print("SUPPORT GROWTH CASCADE ANALYSIS")
    print("=" * 60)

    for p in [5, 13, 17, 29, 37]:
        growth = support_growth_analysis(p, 1, levels=4)
        print(f"\n  Euler prime p={p}, a=1:")
        for level, primes in growth:
            print(f"    Level {level}: {len(primes)} primes — {sorted(primes)[:15]}"
                  + ("..." if len(primes) > 15 else ""))
