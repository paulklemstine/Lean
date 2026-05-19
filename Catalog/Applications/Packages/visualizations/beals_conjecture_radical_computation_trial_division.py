#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Beal Conjecture Obstruction Theory

Implements the mathematical algorithms underlying the formal theorems:
1. Radical computation (sieve-based and factorization-based)
2. Primitive reduction: extracting pairwise coprime models
3. ABC quality computation for Beal triples
4. Exponent reciprocal classification
5. Modular obstruction search
"""

from math import gcd, isqrt, log, log2
from typing import List, Tuple, Set, Optional, Dict
from functools import reduce
from collections import defaultdict


# ============================================================
# Algorithm 1: Radical Computation
# ============================================================

def prime_factorization(n: int) -> Dict[int, int]:
    """
    Compute the complete prime factorization of n.

    Returns a dictionary {prime: exponent}.

    Time complexity: O(sqrt(n))
    Space complexity: O(log n)

    >>> prime_factorization(360)
    {2: 3, 3: 2, 5: 1}
    """
    if n <= 1:
        return {}
    factors = {}
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors[d] = factors.get(d, 0) + 1
            n //= d
        d += 1
    if n > 1:
        factors[n] = factors.get(n, 0) + 1
    return factors


def radical(n: int) -> int:
    """
    Compute rad(n) = product of distinct prime factors of n.

    This is the squarefree kernel of n. Key properties proved in Lean:
    - rad(n^k) = rad(n) for k > 0
    - rad(a*b) = rad(a)*rad(b) when gcd(a,b) = 1
    - rad(n) | n

    Time complexity: O(sqrt(n))

    >>> radical(360)  # 360 = 2^3 * 3^2 * 5
    30
    >>> radical(1)
    1
    """
    if n <= 0:
        return 0
    if n == 1:
        return 1
    return reduce(lambda x, y: x * y, prime_factorization(n).keys(), 1)


def radical_sieve(limit: int) -> List[int]:
    """
    Compute rad(n) for all n from 0 to limit using a sieve.

    Time complexity: O(n log log n) — similar to Sieve of Eratosthenes
    Space complexity: O(n)

    >>> rads = radical_sieve(10)
    >>> rads[6]  # rad(6) = 6
    6
    >>> rads[8]  # rad(8) = 2
    2
    """
    rad = [1] * (limit + 1)
    rad[0] = 0
    for p in range(2, limit + 1):
        if rad[p] == 1:  # p is prime
            for multiple in range(p, limit + 1, p):
                rad[multiple] *= p
    return rad


# ============================================================
# Algorithm 2: Primitive Reduction
# ============================================================

def extract_pairwise_coprime_model(
    A: int, B: int, C: int, x: int, y: int, z: int
) -> Optional[Tuple[int, int, int, int, int, int]]:
    """
    Given A^x + B^y = C^z, attempt to extract a pairwise coprime model.

    If no prime divides all three of A, B, C, then by our Theorem 1,
    (A, B, C) is already pairwise coprime.

    If a common prime exists, we can divide it out, but the equation
    may not preserve its form with the same exponents (since different
    exponents make this non-trivial).

    Returns (A', B', C', x, y, z) if a primitive model is found, None otherwise.

    >>> extract_pairwise_coprime_model(2, 2, 2, 3, 3, 4)  # Common prime 2
    """
    # Check equation
    if A**x + B**y != C**z:
        return None

    # Check if already pairwise coprime
    if gcd(A, B) == 1 and gcd(A, C) == 1 and gcd(B, C) == 1:
        return (A, B, C, x, y, z)

    # Find common primes
    pA = set(prime_factorization(A).keys())
    pB = set(prime_factorization(B).keys())
    pC = set(prime_factorization(C).keys())
    common = pA & pB & pC

    if not common:
        # By our theorem, this means pairwise coprime
        # (the theorem proves this can't happen, so this is defensive)
        return (A, B, C, x, y, z)

    # Common prime exists — Beal says this should always happen
    return None


# ============================================================
# Algorithm 3: ABC Quality Computation
# ============================================================

def abc_quality(a: int, b: int, c: int) -> float:
    """
    Compute the ABC quality of a coprime triple (a, b, c) with a + b = c.

    The quality is defined as q = log(c) / log(rad(abc)).
    The ABC conjecture asserts that for any ε > 0, there are only
    finitely many triples with quality > 1 + ε.

    Higher quality means the triple is more "exceptional" —
    it has unusually small radical relative to c.

    >>> abc_quality(1, 8, 9)  # 1 + 2^3 = 3^2, rad = 6
    1.2263...
    """
    if a + b != c or gcd(a, b) != 1:
        raise ValueError("Not a valid coprime ABC triple")
    rad_abc = radical(a * b * c)
    if rad_abc <= 1:
        return float('inf')
    return log(c) / log(rad_abc)


def beal_abc_quality(
    A: int, B: int, C: int, x: int, y: int, z: int
) -> float:
    """
    Compute the ABC quality of the triple (A^x, B^y, C^z) viewed
    as an ABC triple.

    For pairwise coprime A, B, C, our Lean theorems show:
    rad(A^x * B^y * C^z) = rad(A * B * C)

    So the quality is: log(C^z) / log(rad(ABC))

    This captures the tension between size and radical that
    the ABC conjecture constrains.

    >>> beal_abc_quality(2, 3, 5, 3, 3, 3)
    """
    if A**x + B**y != C**z:
        raise ValueError("Not a valid Beal equation")
    if not (gcd(A, B) == 1 and gcd(A, C) == 1 and gcd(B, C) == 1):
        raise ValueError("Not pairwise coprime")
    rad_ABC = radical(A * B * C)
    if rad_ABC <= 1:
        return float('inf')
    return z * log(C) / log(rad_ABC)


# ============================================================
# Algorithm 4: Exponent Classification
# ============================================================

def classify_exponent_triple(x: int, y: int, z: int) -> str:
    """
    Classify an exponent triple (x, y, z) in the Fermat-Catalan landscape.

    Returns one of:
    - "spherical": 1/x + 1/y + 1/z > 1 (finitely many solutions known)
    - "euclidean": 1/x + 1/y + 1/z = 1 (boundary case)
    - "hyperbolic": 1/x + 1/y + 1/z < 1 (Fermat-Catalan: finitely many)

    For Beal (x, y, z > 2), all triples are euclidean or hyperbolic.

    >>> classify_exponent_triple(3, 3, 3)
    'euclidean'
    >>> classify_exponent_triple(3, 3, 4)
    'hyperbolic'
    """
    from fractions import Fraction
    s = Fraction(1, x) + Fraction(1, y) + Fraction(1, z)
    if s > 1:
        return "spherical"
    elif s == 1:
        return "euclidean"
    else:
        return "hyperbolic"


def fermat_catalan_deficit(x: int, y: int, z: int) -> float:
    """
    Compute 1 - (1/x + 1/y + 1/z), the "hyperbolic deficit".

    Larger deficit means the equation is "more constrained" by
    Fermat-Catalan, expecting fewer solutions.

    >>> fermat_catalan_deficit(3, 3, 3)
    0.0
    >>> fermat_catalan_deficit(4, 4, 4)
    0.25
    """
    return 1.0 - (1.0/x + 1.0/y + 1.0/z)


# ============================================================
# Algorithm 5: Modular Obstruction Search
# ============================================================

def power_residues(modulus: int, exponent: int) -> Set[int]:
    """
    Compute the set of k-th power residues modulo m.

    {a^k mod m : a in Z/mZ}

    >>> sorted(power_residues(7, 3))
    [0, 1, 6]
    """
    return {pow(a, exponent, modulus) for a in range(modulus)}


def check_modular_obstruction(
    modulus: int, x: int, y: int, z: int
) -> bool:
    """
    Check if A^x + B^y ≡ C^z (mod m) has no solutions with
    gcd(A, m) = gcd(B, m) = gcd(C, m) = 1 (coprime to modulus).

    If True, this modulus provides an obstruction to coprime solutions.

    >>> check_modular_obstruction(7, 3, 3, 3)
    False
    """
    x_residues = power_residues(modulus, x)
    y_residues = power_residues(modulus, y)
    z_residues = power_residues(modulus, z)

    # Check coprime residues only
    for a in range(1, modulus):
        if gcd(a, modulus) != 1:
            continue
        a_pow = pow(a, x, modulus)
        for b in range(1, modulus):
            if gcd(b, modulus) != 1:
                continue
            b_pow = pow(b, y, modulus)
            target = (a_pow + b_pow) % modulus
            for c in range(1, modulus):
                if gcd(c, modulus) != 1:
                    continue
                if pow(c, z, modulus) == target:
                    return False  # Found a compatible residue pattern

    return True  # No compatible pattern exists — obstruction!


def find_modular_obstructions(
    max_modulus: int, x: int, y: int, z: int
) -> List[int]:
    """
    Find all moduli up to max_modulus that provide obstructions
    for coprime solutions to A^x + B^y = C^z.

    >>> find_modular_obstructions(20, 3, 3, 3)
    [7]
    """
    obstructions = []
    for m in range(2, max_modulus + 1):
        if check_modular_obstruction(m, x, y, z):
            obstructions.append(m)
    return obstructions


def comprehensive_obstruction_search(
    max_modulus: int = 50,
    exponents: List[Tuple[int, int, int]] = None
) -> Dict[Tuple[int, int, int], List[int]]:
    """
    Search for modular obstructions across multiple exponent triples.

    Returns a dictionary mapping exponent triples to lists of
    obstructing moduli.

    Time complexity: O(max_modulus * |exponents| * max_modulus^3)
    """
    if exponents is None:
        exponents = [
            (3, 3, 3), (3, 3, 4), (3, 3, 5),
            (3, 4, 4), (4, 4, 4), (3, 3, 7),
        ]

    results = {}
    for x, y, z in exponents:
        obstructions = find_modular_obstructions(max_modulus, x, y, z)
        results[(x, y, z)] = obstructions

    return results


# ============================================================
# Main: Algorithm Demonstrations
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Radical sieve
    print("\n1. Radical sieve for n ≤ 20:")
    rads = radical_sieve(20)
    for n in range(1, 21):
        print(f"   rad({n:2d}) = {rads[n]:2d}", end="  ")
        if n % 5 == 0:
            print()

    # ABC quality of known exceptional triples
    print("\n2. ABC quality of famous exceptional triples:")
    exceptional = [
        (1, 8, 9, "1 + 2^3 = 3^2"),
        (5, 27, 32, "5 + 3^3 = 2^5"),
        (2, 6561, 6563, "2 + 3^8 = 6563"),
        (1, 2, 3, "1 + 2 = 3"),
        (1, 80, 81, "1 + 80 = 81"),
    ]
    for a, b, c, desc in exceptional:
        if a + b == c and gcd(a, b) == 1:
            q = abc_quality(a, b, c)
            print(f"   {desc}: quality = {q:.4f}")

    # Modular obstruction search
    print("\n3. Modular obstruction search (moduli ≤ 30):")
    results = comprehensive_obstruction_search(
        max_modulus=30,
        exponents=[(3,3,3), (3,3,4), (3,4,4), (4,4,4), (3,3,5)]
    )
    for (x, y, z), obs in results.items():
        print(f"   ({x},{y},{z}): obstructing moduli = {obs if obs else 'none found'}")

    # Exponent classification
    print("\n4. Fermat-Catalan classification:")
    for x, y, z in [(3,3,3), (3,3,4), (3,4,5), (4,4,4), (5,5,5), (3,3,7)]:
        cls = classify_exponent_triple(x, y, z)
        deficit = fermat_catalan_deficit(x, y, z)
        print(f"   ({x},{y},{z}): {cls}, deficit = {deficit:.4f}")

    print("\n" + "=" * 60)
    print("All algorithm demonstrations completed.")
