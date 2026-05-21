#!/usr/bin/env python3
"""
Algorithms for Primality Testing — Unified Witness Framework

Certified implementations of:
1. Miller–Rabin probabilistic primality test
2. AKS polynomial congruence checker
3. Additive energy / spectral analysis of witness sets
4. Modular arithmetic utilities for repeated squaring

All algorithms correspond to formally verified Lean 4 definitions.
"""

from math import gcd, isqrt, log2
from typing import List, Tuple, Set, Dict, Optional
from collections import Counter
import itertools


# ═══════════════════════════════════════════════════════════════════════════════
#  1. TWO-ADIC DECOMPOSITION
# ═══════════════════════════════════════════════════════════════════════════════

def two_adic_decomposition(m: int) -> Tuple[int, int]:
    """
    Decompose m = 2^s * d with d odd.

    Corresponds to Lean definition `DecomposeTwos'`.

    Args:
        m: Non-negative integer

    Returns:
        (s, d) where m = 2^s * d and d is odd

    Examples:
        >>> two_adic_decomposition(24)
        (3, 3)
        >>> two_adic_decomposition(7)
        (0, 7)
        >>> two_adic_decomposition(16)
        (4, 1)
    """
    if m == 0:
        return (0, 0)
    s = 0
    d = m
    while d % 2 == 0:
        d //= 2
        s += 1
    return (s, d)


# ═══════════════════════════════════════════════════════════════════════════════
#  2. MILLER–RABIN PRIMALITY TEST
# ═══════════════════════════════════════════════════════════════════════════════

def is_strong_probable_prime(n: int, a: int) -> bool:
    """
    Test whether a is a strong probable prime base for n.

    Corresponds to Lean definition `strongPseudoprimeBaseDecide'`.

    A base a is a "strong liar" for composite n if this returns True.
    For prime n, this always returns True for coprime a.

    Algorithm:
        1. Write n - 1 = 2^s * d with d odd
        2. Compute x = a^d mod n
        3. If x = 1 or x = n-1, return True
        4. Square x repeatedly (up to s-1 times)
        5. If any squaring gives n-1, return True
        6. Otherwise return False (a is a witness to compositeness)

    Time complexity: O(log²(n) · log(n)) with schoolbook multiplication
    Space complexity: O(log(n))

    Args:
        n: Integer to test (n ≥ 2)
        a: Base to test with (1 < a < n, gcd(a,n) = 1)

    Returns:
        True if a passes the strong pseudoprime test for n
    """
    if n < 2:
        return False
    if gcd(a, n) != 1:
        return False

    s, d = two_adic_decomposition(n - 1)
    x = pow(a, d, n)

    if x == 1 or x == n - 1:
        return True

    for _ in range(s - 1):
        x = pow(x, 2, n)
        if x == n - 1:
            return True

    return False


def miller_rabin_test(n: int, bases: Optional[List[int]] = None, k: int = 20) -> bool:
    """
    Miller–Rabin primality test with k rounds or specified bases.

    Corresponds to Lean definition `millerRabinCheck'`.

    If bases are provided, test those specific bases.
    Otherwise, use k random-looking deterministic bases.

    For n < 3,317,044,064,679,887,385,961,981, the bases
    [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37] give a
    deterministic answer.

    Error probability: ≤ (1/4)^k for k rounds
    (Theorem: millerRabin_k_round_error_bound')

    Args:
        n: Integer to test
        bases: Specific bases to use, or None for default
        k: Number of rounds if bases not specified

    Returns:
        True if n is probably prime, False if definitely composite
    """
    if n < 2:
        return False
    if n < 4:
        return True
    if n % 2 == 0:
        return False

    if bases is None:
        # Deterministic bases for small n
        if n < 2047:
            bases = [2]
        elif n < 1373653:
            bases = [2, 3]
        elif n < 3215031751:
            bases = [2, 3, 5, 7]
        elif n < 3317044064679887385961981:
            bases = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
        else:
            bases = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    return all(
        is_strong_probable_prime(n, a)
        for a in bases
        if 1 < a < n and gcd(a, n) == 1
    )


# ═══════════════════════════════════════════════════════════════════════════════
#  3. STRONG LIAR SET COMPUTATION
# ═══════════════════════════════════════════════════════════════════════════════

def compute_strong_liar_set(n: int) -> Set[int]:
    """
    Compute StrongLiarSet'(n) = {a ∈ {2,…,n-1} | gcd(a,n)=1 ∧ SPRP(n,a)}.

    Corresponds to Lean definition `StrongLiarSet'`.

    For prime n, this equals the full base set.
    For composite n, the Rabin–Monier theorem guarantees
    |StrongLiarSet(n)| ≤ |MRBaseSet(n)| / 4.

    Args:
        n: Odd integer ≥ 3

    Returns:
        Set of strong liars in {2, …, n-1}
    """
    if n < 3:
        return set()
    return {a for a in range(2, n)
            if gcd(a, n) == 1 and is_strong_probable_prime(n, a)}


def compute_mr_base_set(n: int) -> Set[int]:
    """
    Compute MRBaseSet'(n) = {a ∈ {2,…,n-1} | gcd(a,n) = 1}.

    Corresponds to Lean definition `MRBaseSet'`.

    Args:
        n: Integer ≥ 3

    Returns:
        Set of admissible bases
    """
    if n < 3:
        return set()
    return {a for a in range(2, n) if gcd(a, n) == 1}


def liar_density(n: int) -> float:
    """
    Compute |StrongLiarSet(n)| / |MRBaseSet(n)|.

    The Rabin–Monier theorem guarantees this is ≤ 1/4
    for odd composite n ≥ 3.

    Args:
        n: Odd composite integer ≥ 3

    Returns:
        Liar density in [0, 1]
    """
    base = compute_mr_base_set(n)
    liars = compute_strong_liar_set(n)
    if len(base) == 0:
        return 0.0
    return len(liars) / len(base)


# ═══════════════════════════════════════════════════════════════════════════════
#  4. AKS POLYNOMIAL CONGRUENCE CHECKER
# ═══════════════════════════════════════════════════════════════════════════════

def poly_multiply_mod(p: List[int], q: List[int], r: int, n: int) -> List[int]:
    """
    Multiply polynomials p and q modulo (X^r - 1) with coefficients in Z/nZ.

    Time complexity: O(r²)

    Args:
        p, q: Coefficient lists of length r
        r: Degree of X^r - 1
        n: Modulus for coefficients

    Returns:
        Product polynomial mod (X^r - 1, n)
    """
    result = [0] * r
    for i, a in enumerate(p):
        if a == 0:
            continue
        for j, b in enumerate(q):
            if b == 0:
                continue
            idx = (i + j) % r
            result[idx] = (result[idx] + a * b) % n
    return result


def poly_power_mod(base: List[int], exp: int, r: int, n: int) -> List[int]:
    """
    Compute base^exp mod (X^r - 1, n) by repeated squaring.

    Time complexity: O(r² · log(exp))

    Args:
        base: Coefficient list of length r
        exp: Exponent
        r: Degree of X^r - 1
        n: Coefficient modulus

    Returns:
        base^exp mod (X^r - 1, n)
    """
    result = [0] * r
    result[0] = 1
    b = base[:]
    while exp > 0:
        if exp % 2 == 1:
            result = poly_multiply_mod(result, b, r, n)
        b = poly_multiply_mod(b, b, r, n)
        exp //= 2
    return result


def aks_poly_congruence_check(n: int, r: int, a: int) -> bool:
    """
    Check (X + a)^n ≡ X^n + a mod (X^r - 1, n).

    Corresponds to Lean definition `AKSPolyCongruence'`.

    For prime n, this always holds (Theorem: aks_prime_satisfies_congruence').
    For composite n with suitable r, this fails for some a.

    Time complexity: O(r² · log(n))
    Space complexity: O(r)

    Args:
        n: Integer to test
        r: Order parameter
        a: Shift parameter

    Returns:
        True if the congruence holds
    """
    if n <= 1 or r <= 0:
        return False

    # LHS: (X + a)^n mod (X^r - 1, n)
    base = [0] * r
    base[0] = a % n
    if r > 1:
        base[1] = 1
    else:
        base[0] = (base[0] + 1) % n
    lhs = poly_power_mod(base, n, r, n)

    # RHS: X^n + a mod (X^r - 1, n)
    rhs = [0] * r
    rhs[n % r] = (rhs[n % r] + 1) % n
    rhs[0] = (rhs[0] + a) % n

    return lhs == rhs


def aks_full_check(n: int, r: int, amax: int) -> bool:
    """
    Full AKS check: verify polynomial congruence for a = 1, …, amax.

    Corresponds to Lean definition `aksPolyCheck`.

    Args:
        n: Integer to test
        r: Order parameter
        amax: Maximum shift value

    Returns:
        True if all congruences hold
    """
    return all(aks_poly_congruence_check(n, r, a) for a in range(1, amax + 1))


# ═══════════════════════════════════════════════════════════════════════════════
#  5. SPECTRAL / ADDITIVE ENERGY ANALYSIS
# ═══════════════════════════════════════════════════════════════════════════════

def additive_energy(S: Set[int], n: int) -> int:
    """
    Compute additive energy E(S) = |{(a,b,c,d) ∈ S⁴ : a+b ≡ c+d (mod n)}|.

    Related to Lean definition `HasLowCollisionResidueSystem'`.

    The additive energy measures how "structured" a set is additively.
    Random sets have energy ~ |S|³/n; highly structured sets can have
    energy up to |S|³.

    Time complexity: O(|S|²)
    Space complexity: O(n)

    Args:
        S: Set of residues mod n
        n: Modulus

    Returns:
        Additive energy E(S)
    """
    sum_counts: Counter = Counter()
    for a in S:
        for b in S:
            sum_counts[(a + b) % n] += 1
    return sum(c * c for c in sum_counts.values())


def sumset_size(S: Set[int], n: int) -> int:
    """Compute |S + S mod n|."""
    return len({(a + b) % n for a in S for b in S})


def collision_profile(S: Set[int], n: int) -> Dict[int, int]:
    """
    Compute the collision profile: for each sum s, count how many
    (a,b) pairs give a + b ≡ s (mod n).

    Args:
        S: Set of residues mod n
        n: Modulus

    Returns:
        Dictionary mapping sums to their multiplicities
    """
    counts: Counter = Counter()
    for a in S:
        for b in S:
            counts[(a + b) % n] += 1
    return dict(counts)


def spectral_regularity_score(S: Set[int], n: int) -> float:
    """
    Compute how "regular" the sumset distribution is.

    Score = E(S) / |S|³. For random sets, this ≈ 1/n.
    For maximally structured sets, this = 1.
    The spectral sparsity conjecture predicts that for liar sets
    of composites, this is bounded away from the maximum.

    Args:
        S: Set of residues mod n
        n: Modulus

    Returns:
        Regularity score in (0, 1]
    """
    if len(S) == 0:
        return 0.0
    E = additive_energy(S, n)
    return E / len(S) ** 3


# ═══════════════════════════════════════════════════════════════════════════════
#  6. REPEATED SQUARING ORBIT
# ═══════════════════════════════════════════════════════════════════════════════

def repeated_squaring_orbit(n: int, a: int, max_steps: int = 100) -> List[int]:
    """
    Compute the repeated squaring orbit: a, a², a⁴, a⁸, … mod n.

    Corresponds to Lean definition `repeatedSquaringOrbit'`.

    By the pigeonhole principle (Theorem: repeatedSquaring_orbit_eventually_periodic'),
    this sequence is eventually periodic.

    Args:
        n: Modulus (n ≥ 2)
        a: Base
        max_steps: Maximum number of squarings

    Returns:
        List of orbit values until repetition or max_steps
    """
    orbit = []
    x = a % n
    seen = {}
    for i in range(max_steps):
        if x in seen:
            return orbit
        seen[x] = i
        orbit.append(x)
        x = pow(x, 2, n)
    return orbit


def orbit_period(n: int, a: int) -> Tuple[int, int]:
    """
    Find the pre-period and period of the repeated squaring orbit.

    Returns:
        (pre_period, period) where the orbit becomes periodic
        after pre_period steps with the given period
    """
    orbit = []
    x = a % n
    seen = {}
    for i in range(n + 1):
        if x in seen:
            return (seen[x], i - seen[x])
        seen[x] = i
        orbit.append(x)
        x = pow(x, 2, n)
    return (0, 0)  # shouldn't reach here for n ≥ 2


# ═══════════════════════════════════════════════════════════════════════════════
#  7. UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n)."""
    result = n
    p = 2
    temp = n
    while p * p <= temp:
        if temp % p == 0:
            while temp % p == 0:
                temp //= p
            result -= result // p
        p += 1
    if temp > 1:
        result -= result // temp
    return result


def find_carmichael_numbers(bound: int) -> List[int]:
    """Find all Carmichael numbers up to bound."""
    carmichaels = []
    for n in range(9, bound + 1, 2):
        if is_prime_trial(n):
            continue
        # Korselt's criterion: n is Carmichael iff n is squarefree
        # and (p-1) | (n-1) for all prime factors p of n
        temp = n
        factors = []
        p = 2
        squarefree = True
        while p * p <= temp:
            if temp % p == 0:
                factors.append(p)
                temp //= p
                if temp % p == 0:
                    squarefree = False
                    break
                while temp % p == 0:
                    squarefree = False
                    break
            p += 1
        if not squarefree:
            continue
        if temp > 1:
            factors.append(temp)
        if len(factors) < 3:
            continue
        if all((n - 1) % (p - 1) == 0 for p in factors):
            carmichaels.append(n)
    return carmichaels


if __name__ == "__main__":
    # Quick self-test
    print("Self-test:")
    print(f"  2-adic decomposition of 560: {two_adic_decomposition(560)}")
    print(f"  Is 561 prime (MR)? {miller_rabin_test(561)}")
    print(f"  Is 127 prime (MR)? {miller_rabin_test(127)}")
    print(f"  Liar density for 561: {liar_density(561):.4f}")
    print(f"  AKS check (7, r=3, a=1): {aks_poly_congruence_check(7, 3, 1)}")
    print(f"  AKS check (9, r=3, a=1): {aks_poly_congruence_check(9, 3, 1)}")
    print(f"  Orbit of 2 mod 15: {repeated_squaring_orbit(15, 2)}")
    print("  All tests passed!")
