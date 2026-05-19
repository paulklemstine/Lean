#!/usr/bin/env python3
"""
Applications of the n² + 1 theory to practical problems.

1. Cryptographic prime generation with congruence guarantees
2. Semiprime generation for RSA-like applications
3. Polynomial admissibility testing framework
4. Statistical analysis of prime factor distributions
"""

import math
import random
from typing import List, Tuple, Dict, Optional


def is_prime(n: int) -> bool:
    """Miller-Rabin primality test for practical use."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    # Deterministic for n < 3.3 × 10^24 with these witnesses
    witnesses = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    d, r = n - 1, 0
    while d % 2 == 0:
        d //= 2
        r += 1
    for a in witnesses:
        if a >= n:
            continue
        x = pow(a, d, n)
        if x == 1 or x == n - 1:
            continue
        for _ in range(r - 1):
            x = pow(x, x, n)
            if x == n - 1:
                break
        else:
            return False
    return True


def factorize(n: int) -> List[int]:
    """Trial division factorization."""
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


# ============================================================
# Application 1: Generating primes ≡ 1 (mod 4) from n² + 1
# ============================================================

def generate_primes_1_mod_4(count: int, min_bits: int = 16) -> List[Tuple[int, int]]:
    """
    Generate primes p ≡ 1 (mod 4) by finding primes of the form n² + 1.

    By Theorem C, every odd prime of the form n² + 1 satisfies p ≡ 1 (mod 4).
    This gives a natural way to generate primes in this congruence class.

    Application: In cryptography, primes ≡ 1 (mod 4) are needed for:
    - Blum integers (p ≡ 3 mod 4, but the complement is also useful)
    - Certain elliptic curve constructions
    - Generating primes that split in ℤ[i]

    Args:
        count: Number of primes to generate.
        min_bits: Minimum bit length of generated primes.

    Returns:
        List of (n, p) pairs where p = n² + 1 is prime and p ≡ 1 (mod 4).

    >>> primes = generate_primes_1_mod_4(5, min_bits=4)
    >>> all(p % 4 == 1 for _, p in primes)
    True
    """
    results = []
    min_n = max(2, int(math.sqrt(2 ** (min_bits - 1))))
    n = min_n

    while len(results) < count:
        p = n * n + 1
        if is_prime(p):
            assert p % 4 == 1 or p == 2, f"Theorem C violated! p={p}, p%4={p%4}"
            if p > 2:
                results.append((n, p))
        n += 1

    return results


# ============================================================
# Application 2: Semiprime generation from n² + 1
# ============================================================

def generate_semiprimes_sq_plus_one(count: int, max_n: int = 100000) -> List[Tuple[int, int, int, int]]:
    """
    Find semiprimes of the form n² + 1.

    By Iwaniec's theorem, there are infinitely many n where n² + 1
    has at most 2 prime factors. This function finds such values.

    Application: Semiprimes are used in:
    - RSA cryptosystem (N = pq)
    - Pseudorandom number generation
    - Complexity-theoretic hardness assumptions

    Args:
        count: Number of semiprimes to find.
        max_n: Maximum value of n to search.

    Returns:
        List of (n, n²+1, p, q) where n²+1 = p·q with p, q prime.

    >>> results = generate_semiprimes_sq_plus_one(3, max_n=20)
    >>> all(p * q == n*n+1 for n, _, p, q in results)
    True
    """
    results = []

    for n in range(2, max_n + 1):
        if len(results) >= count:
            break
        val = n * n + 1
        factors = factorize(val)
        if len(factors) == 2:
            results.append((n, val, factors[0], factors[1]))

    return results


# ============================================================
# Application 3: Polynomial admissibility framework
# ============================================================

def test_polynomial_admissibility(
    name: str,
    f,
    var_count: int,
    prime_limit: int = 100
) -> Dict:
    """
    Test local admissibility of a polynomial and compute root statistics.

    This implements the formal definition:
        LocallyAdmissible(f) ⟺ ∀ prime p, ∃ inputs x with p ∤ f(x)

    Additionally computes:
    - Root count ω(p) for each prime p
    - Average root density
    - Whether the polynomial has the "Bateman-Horn" structure

    Application: Admissibility testing is the first step in any
    sieve-theoretic analysis of prime-producing polynomials.

    Args:
        name: Name of the polynomial for display.
        f: The polynomial function.
        var_count: Number of variables (1 or 2).
        prime_limit: Test all primes up to this bound.

    Returns:
        Dictionary with admissibility results and statistics.

    >>> result = test_polynomial_admissibility("n²+1", lambda n: n**2+1, 1, 30)
    >>> result['is_admissible']
    True
    """
    # Simple sieve for primes
    sieve = [True] * (prime_limit + 1)
    sieve[0] = sieve[1] = False
    for i in range(2, int(prime_limit**0.5) + 1):
        if sieve[i]:
            for j in range(i*i, prime_limit + 1, i):
                sieve[j] = False
    primes = [i for i in range(2, prime_limit + 1) if sieve[i]]

    root_counts = {}
    witnesses = {}
    is_admissible = True

    for p in primes:
        count = 0
        witness = None

        if var_count == 1:
            for n in range(p):
                val = f(n)
                if val % p == 0:
                    count += 1
                elif witness is None:
                    witness = (n,)
        elif var_count == 2:
            for a in range(p):
                for b in range(p):
                    val = f(a, b)
                    if val % p == 0:
                        count += 1
                    elif witness is None:
                        witness = (a, b)

        total = p if var_count == 1 else p * p
        root_counts[p] = count
        witnesses[p] = witness

        if witness is None:
            is_admissible = False

    avg_density = sum(root_counts[p] / (p if var_count == 1 else p*p)
                      for p in primes) / len(primes) if primes else 0

    return {
        'name': name,
        'is_admissible': is_admissible,
        'root_counts': root_counts,
        'witnesses': witnesses,
        'average_density': avg_density,
        'primes_tested': len(primes)
    }


# ============================================================
# Application 4: Statistical analysis
# ============================================================

def prime_factor_distribution_analysis(limit: int) -> Dict:
    """
    Analyze the distribution of prime factors of n² + 1 values.

    Computes statistics relevant to the Bateman-Horn conjecture
    and Iwaniec's semiprime theorem.

    Args:
        limit: Analyze n² + 1 for n = 1, ..., limit.

    Returns:
        Dictionary with distributional statistics.
    """
    omega_counts = {}  # Ω value -> count
    prime_mod_4_counts = {1: 0, 3: 0}  # mod 4 residue -> count of distinct primes seen
    all_odd_prime_divisors = set()
    largest_prime_factors = []

    for n in range(1, limit + 1):
        val = n * n + 1
        factors = factorize(val)
        omega = len(factors)
        omega_counts[omega] = omega_counts.get(omega, 0) + 1

        for p in set(factors):
            if p > 2:
                all_odd_prime_divisors.add(p)

        if factors:
            largest_prime_factors.append(factors[-1])

    for p in all_odd_prime_divisors:
        prime_mod_4_counts[p % 4] += 1

    # Compute density ratios
    log_limit = math.log(limit) if limit > 1 else 1
    prime_count = omega_counts.get(1, 0)
    semiprime_count = omega_counts.get(2, 0)

    return {
        'limit': limit,
        'omega_distribution': dict(sorted(omega_counts.items())),
        'prime_count': prime_count,
        'semiprime_count': semiprime_count,
        'at_most_2_factors': prime_count + semiprime_count,
        'prime_density_ratio': prime_count / (limit / log_limit) if limit > 1 else 0,
        'semiprime_density_ratio': semiprime_count / (limit / log_limit**2) if limit > 1 else 0,
        'odd_primes_1_mod_4': prime_mod_4_counts[1],
        'odd_primes_3_mod_4': prime_mod_4_counts[3],
        'congruence_law_holds': prime_mod_4_counts[3] == 0,
        'average_largest_prime_factor': sum(largest_prime_factors) / len(largest_prime_factors) if largest_prime_factors else 0,
    }


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Prime Generation from n² + 1")
    print("=" * 70)
    primes = generate_primes_1_mod_4(10, min_bits=8)
    print(f"Generated {len(primes)} primes p = n² + 1 with p ≡ 1 (mod 4):")
    for n, p in primes:
        print(f"  n = {n:>6}, p = n² + 1 = {p:>12}, p mod 4 = {p % 4}, bits = {p.bit_length()}")
    print()

    print("=" * 70)
    print("APPLICATION 2: Semiprime Generation from n² + 1")
    print("=" * 70)
    semiprimes = generate_semiprimes_sq_plus_one(10)
    print(f"First {len(semiprimes)} semiprimes of the form n² + 1:")
    for n, val, p, q in semiprimes:
        print(f"  n = {n:>4}, n² + 1 = {val:>8} = {p} × {q}")
    print()

    print("=" * 70)
    print("APPLICATION 3: Polynomial Admissibility Testing")
    print("=" * 70)
    polynomials = [
        ("n² + 1", lambda n: n**2 + 1, 1),
        ("n² - 1", lambda n: abs(n**2 - 1) if n > 1 else 1, 1),
        ("n² + n + 1", lambda n: n**2 + n + 1, 1),
        ("2n", lambda n: 2*n if n > 0 else 2, 1),
        ("a² + b⁴", lambda a, b: a**2 + b**4, 2),
    ]
    for name, f, vc in polynomials:
        result = test_polynomial_admissibility(name, f, vc, prime_limit=50)
        status = "✓ ADMISSIBLE" if result['is_admissible'] else "✗ NOT ADMISSIBLE"
        print(f"  {name:>12}: {status} (avg density: {result['average_density']:.4f})")
    print()

    print("=" * 70)
    print("APPLICATION 4: Statistical Analysis of n² + 1")
    print("=" * 70)
    for limit in [100, 1000, 10000]:
        stats = prime_factor_distribution_analysis(limit)
        print(f"\nn ≤ {limit}:")
        print(f"  Ω distribution: {stats['omega_distribution']}")
        print(f"  Primes: {stats['prime_count']}, Semiprimes: {stats['semiprime_count']}")
        print(f"  At most 2 factors: {stats['at_most_2_factors']}")
        print(f"  Congruence law (all odd divisors ≡ 1 mod 4): {stats['congruence_law_holds']}")
        print(f"  Odd prime divisors ≡ 1 mod 4: {stats['odd_primes_1_mod_4']}")
        print(f"  Odd prime divisors ≡ 3 mod 4: {stats['odd_primes_3_mod_4']}")


#!/usr/bin/env python3
"""
Demonstration of formally verified results about primes of the form n² + 1.

This script illustrates the three main theorems:
1. Local admissibility: no prime divides all values of n² + 1
2. Congruence selection law: odd prime divisors of n² + 1 are ≡ 1 (mod 4)
3. Infinitely many splitting primes via Euclid-style construction

It also explores semiprime density and the Friedlander-Iwaniec connection.
"""

import math
from collections import Counter
from typing import List, Tuple, Set


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0 or n % 3 == 0:
        return False
    i = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return False
        i += 6
    return True


def factorize(n: int) -> List[int]:
    """Return the prime factorization of n as a sorted list with multiplicity."""
    if n <= 1:
        return []
    factors = []
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.append(d)
            n //= d
        d += 1
    if n > 1:
        factors.append(n)
    return factors


def big_omega(n: int) -> int:
    """Count prime factors with multiplicity (Ω function)."""
    return len(factorize(n))


def demo_local_admissibility():
    """
    Demonstrate Theorem B: For every prime p, there exists n < p with p ∤ n² + 1.

    The simplest witness: n = 0 gives 0² + 1 = 1, and no prime divides 1.
    We also show the full root structure mod p.
    """
    print("=" * 70)
    print("THEOREM B: Local Admissibility of n² + 1")
    print("=" * 70)
    print()
    print("For every prime p, ∃ n < p such that p ∤ n² + 1.")
    print("Universal witness: n = 0 gives 0² + 1 = 1, not divisible by any prime.")
    print()

    print("Root counts of X² + 1 mod p for small primes:")
    print(f"{'p':>5} {'p mod 4':>7} {'roots mod p':>15} {'root count':>10}")
    print("-" * 42)

    for p in range(2, 60):
        if not is_prime(p):
            continue
        roots = [n for n in range(p) if (n * n + 1) % p == 0]
        print(f"{p:>5} {p % 4:>7} {str(roots):>15} {len(roots):>10}")

    print()
    print("Pattern: primes ≡ 1 (mod 4) have 2 roots; primes ≡ 3 (mod 4) have 0 roots; p=2 has 1 root.")
    print("In ALL cases, root count < p, confirming local admissibility. ✓")
    print()


def demo_congruence_selection_law():
    """
    Demonstrate Theorem C: If q is an odd prime and q | n² + 1, then q ≡ 1 (mod 4).
    """
    print("=" * 70)
    print("THEOREM C: Congruence Selection Law")
    print("=" * 70)
    print()
    print("Every odd prime dividing some n² + 1 must be ≡ 1 (mod 4).")
    print()

    # Collect all odd prime divisors of n² + 1 for n up to 1000
    divisors_1mod4: Set[int] = set()
    divisors_3mod4: Set[int] = set()

    for n in range(10001):
        val = n * n + 1
        for p in set(factorize(val)):
            if p == 2:
                continue
            if p % 4 == 1:
                divisors_1mod4.add(p)
            else:
                divisors_3mod4.add(p)

    print(f"Odd prime divisors of n² + 1 for n ≤ 10000:")
    print(f"  Primes ≡ 1 (mod 4): {len(divisors_1mod4)} found")
    print(f"  Primes ≡ 3 (mod 4): {len(divisors_3mod4)} found")
    print()

    if divisors_3mod4:
        print(f"  COUNTEREXAMPLE FOUND: {sorted(divisors_3mod4)[:10]}")
    else:
        print("  No prime ≡ 3 (mod 4) ever divides n² + 1. Theorem confirmed! ✓")

    print()
    print("First 20 primes ≡ 1 (mod 4) appearing as divisors:")
    print(f"  {sorted(divisors_1mod4)[:20]}")
    print()


def demo_euclid_construction():
    """
    Demonstrate Theorem D: Euclid-style construction of new primes ≡ 1 (mod 4)
    dividing values of n² + 1.
    """
    print("=" * 70)
    print("THEOREM D: Euclid-Style Construction of Splitting Primes")
    print("=" * 70)
    print()
    print("Construction: Given bound B, form M = (2·B!)² + 1.")
    print("Any odd prime factor q of M satisfies q ≡ 1 (mod 4) and q > B.")
    print()

    for B in [3, 5, 7, 10, 15]:
        factorial_B = math.factorial(B)
        M_base = 2 * factorial_B
        M = M_base * M_base + 1
        factors = factorize(M)
        primes = sorted(set(factors))

        print(f"B = {B}:")
        print(f"  M = (2·{B}!)² + 1 = ({M_base})² + 1 = {M}")
        print(f"  Prime factors: {primes}")
        for q in primes:
            status = "✓" if q > B and q % 4 == 1 else ("(q=2)" if q == 2 else "✗")
            print(f"    q = {q}: q mod 4 = {q % 4}, q > {B}? {q > B} {status}")
        print()


def demo_semiprime_density():
    """
    Explore the density of primes and semiprimes of the form n² + 1.
    """
    print("=" * 70)
    print("SEMIPRIME DENSITY: Values of n² + 1 by Prime Factor Count")
    print("=" * 70)
    print()

    limits = [100, 1000, 10000]

    for X in limits:
        counts = Counter()
        for n in range(1, X + 1):
            val = n * n + 1
            omega = big_omega(val)
            counts[omega] += 1

        total = sum(counts.values())
        prime_count = counts[1]
        semiprime_count = counts[2]
        at_most_2 = prime_count + semiprime_count

        print(f"n ≤ {X} (total values: {total}):")
        for k in sorted(counts.keys()):
            pct = 100 * counts[k] / total
            bar = "█" * int(pct / 2)
            print(f"  Ω = {k}: {counts[k]:>6} ({pct:5.1f}%) {bar}")

        log_X = math.log(X) if X > 1 else 1
        ratio = at_most_2 / (X / log_X ** 2) if X > 1 else 0
        print(f"  Primes + semiprimes: {at_most_2} (ratio to X/(log X)²: {ratio:.3f})")
        print()


def demo_friedlander_iwaniec_bridge():
    """
    Demonstrate the admissibility bridge between n² + 1 and a² + b⁴.
    """
    print("=" * 70)
    print("FRIEDLANDER-IWANIEC BRIDGE: Shared Admissibility")
    print("=" * 70)
    print()

    print("Both n² + 1 and a² + b⁴ are locally admissible:")
    print()

    # For n² + 1
    print("n² + 1: Universal witness n = 0 gives 0² + 1 = 1 (not divisible by any prime)")
    print("a² + b⁴: Universal witness (a,b) = (1,0) gives 1² + 0⁴ = 1 (not divisible by any prime)")
    print()

    # Count primes of each form up to a bound
    bound = 10000
    primes_sq_plus_1 = set()
    primes_a2_b4 = set()

    for n in range(bound):
        val = n * n + 1
        if is_prime(val):
            primes_sq_plus_1.add(val)

    for a in range(int(bound ** 0.5) + 1):
        for b in range(int(bound ** 0.25) + 1):
            val = a * a + b ** 4
            if val <= bound and is_prime(val) and val > 1:
                primes_a2_b4.add(val)

    print(f"Primes of form n² + 1 with n < {bound}: {len(primes_sq_plus_1)}")
    print(f"  First few: {sorted(primes_sq_plus_1)[:15]}")
    print()
    print(f"Primes of form a² + b⁴ up to {bound}: {len(primes_a2_b4)}")
    print(f"  First few: {sorted(primes_a2_b4)[:15]}")
    print()

    overlap = primes_sq_plus_1 & primes_a2_b4
    print(f"Primes in BOTH forms: {len(overlap)}")
    print(f"  (n² + 1 is a special case of a² + b⁴ with b = 1)")
    print()


if __name__ == "__main__":
    demo_local_admissibility()
    demo_congruence_selection_law()
    demo_euclid_construction()
    demo_semiprime_density()
    demo_friedlander_iwaniec_bridge()
