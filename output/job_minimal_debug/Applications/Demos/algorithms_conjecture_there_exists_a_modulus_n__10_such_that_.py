#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Beal Obstruction Theory

Implements the mathematical algorithms underlying the formal theorems:
1. Primitive Residue Solution checker
2. CRT-based obstruction decomposition
3. Cube subgroup analysis
4. Systematic obstruction search engine
"""

from math import gcd, isqrt
from typing import Optional
from functools import reduce
from collections import defaultdict


# ═══════════════════════════════════════════════════════════════════
# Algorithm 1: Primitive Residue Solution Checker
# ═══════════════════════════════════════════════════════════════════

def units_mod_n(n: int) -> list[int]:
    """
    Compute the group of units (Z/nZ)× = {a ∈ {0,...,n-1} : gcd(a,n) = 1}.

    Time complexity: O(n log n) via Euclidean gcd.
    Space complexity: O(φ(n)) where φ is Euler's totient.

    >>> units_mod_n(7)
    [1, 2, 3, 4, 5, 6]
    >>> units_mod_n(6)
    [1, 5]
    """
    if n <= 1:
        return [0] if n == 1 else []
    return [a for a in range(n) if gcd(a, n) == 1]


def power_image(n: int, exp: int) -> dict[int, set[int]]:
    """
    Compute the image of the power map u ↦ u^exp on (Z/nZ)×.

    Returns a dict mapping each image element to its preimage set.

    Time complexity: O(φ(n) · log(exp))
    Space complexity: O(φ(n))

    >>> img = power_image(7, 3)
    >>> sorted(img.keys())
    [1, 6]
    """
    result: dict[int, set[int]] = defaultdict(set)
    for u in units_mod_n(n):
        result[pow(u, exp, n)].add(u)
    return dict(result)


def has_primitive_residue_solution(n: int, x: int, y: int, z: int) -> bool:
    """
    Decide whether ∃ units a, b, c ∈ (Z/nZ)× such that a^x + b^y ≡ c^z (mod n).

    Algorithm:
    1. Compute power images Ix = {u^x : u ∈ (Z/nZ)×}, Iy, Iz
    2. For each pair (α, β) ∈ Ix × Iy, check if (α + β) mod n ∈ Iz

    Time complexity: O(φ(n)² · log(max(x,y,z)))
    Space complexity: O(φ(n))

    >>> has_primitive_residue_solution(7, 3, 3, 3)
    False
    >>> has_primitive_residue_solution(5, 3, 3, 3)
    True
    """
    if n <= 1:
        return True  # ZMod 1 is trivial

    img_x = set(power_image(n, x).keys())
    img_y = set(power_image(n, y).keys())
    img_z = set(power_image(n, z).keys())

    for ax in img_x:
        for by_ in img_y:
            if (ax + by_) % n in img_z:
                return True
    return False


def find_witness(n: int, x: int, y: int, z: int) -> Optional[tuple[int, int, int]]:
    """
    Find explicit unit witnesses (a, b, c) with a^x + b^y ≡ c^z (mod n),
    or return None if no solution exists.

    >>> find_witness(5, 3, 3, 3)
    (1, 2, 3)
    >>> find_witness(7, 3, 3, 3) is None
    True
    """
    if n <= 1:
        return (0, 0, 0)

    for a in units_mod_n(n):
        ax = pow(a, x, n)
        for b in units_mod_n(n):
            by_ = pow(b, y, n)
            target = (ax + by_) % n
            for c in units_mod_n(n):
                if pow(c, z, n) == target:
                    return (a, b, c)
    return None


# ═══════════════════════════════════════════════════════════════════
# Algorithm 2: CRT Decomposition Engine
# ═══════════════════════════════════════════════════════════════════

def is_prime(n: int) -> bool:
    """Primality test."""
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


def prime_power_factorization(n: int) -> list[tuple[int, int]]:
    """
    Return the prime power factorization of n as [(p₁, k₁), (p₂, k₂), ...].

    >>> prime_power_factorization(180)
    [(2, 2), (3, 2), (5, 1)]
    """
    factors = []
    d = 2
    while d * d <= n:
        if n % d == 0:
            k = 0
            while n % d == 0:
                n //= d
                k += 1
            factors.append((d, k))
        d += 1
    if n > 1:
        factors.append((n, 1))
    return factors


def crt_decompose(n: int, x: int, y: int, z: int) -> dict:
    """
    Decompose the obstruction check for modulus N via CRT.

    By the CRT Compression Theorem (primitiveResidueSolution_mul_iff):
    For N = p₁^k₁ · p₂^k₂ · ... · pₘ^kₘ,
    PrimitiveResidueSolution(N, x, y, z) ⟺
      ∀i, PrimitiveResidueSolution(pᵢ^kᵢ, x, y, z)

    Returns a dict with analysis of each prime power factor.

    >>> result = crt_decompose(182, 3, 3, 3)
    >>> result['obstructs']
    True
    """
    factors = prime_power_factorization(n)
    analysis = []
    all_solvable = True

    for p, k in factors:
        pk = p ** k
        solvable = has_primitive_residue_solution(pk, x, y, z)
        witness = find_witness(pk, x, y, z) if solvable else None
        analysis.append({
            'prime': p,
            'power': k,
            'modulus': pk,
            'solvable': solvable,
            'witness': witness
        })
        if not solvable:
            all_solvable = False

    return {
        'n': n,
        'signature': (x, y, z),
        'factors': analysis,
        'obstructs': not all_solvable,
        'obstructing_factors': [f for f in analysis if not f['solvable']]
    }


# ═══════════════════════════════════════════════════════════════════
# Algorithm 3: Cube Subgroup Analysis
# ═══════════════════════════════════════════════════════════════════

def cube_subgroup_analysis(p: int) -> dict:
    """
    Analyze the cube subgroup structure of (Z/pZ)× for prime p.

    The cube image C_p = {u³ : u ∈ (Z/pZ)×} is a subgroup of index gcd(3, p-1).
    Obstruction occurs when (C_p + C_p) ∩ C_p = ∅ inside (Z/pZ)×.

    >>> analysis = cube_subgroup_analysis(7)
    >>> analysis['obstructs']
    True
    >>> analysis['cube_index']
    3
    """
    if not is_prime(p):
        raise ValueError(f"{p} is not prime")

    u = units_mod_n(p)
    cubes = {pow(a, 3, p) for a in u}
    cube_index = len(u) // len(cubes) if cubes else 0

    # Compute sumset C + C restricted to units
    sumset = set()
    for a in cubes:
        for b in cubes:
            s = (a + b) % p
            if gcd(s, p) == 1:  # must be a unit
                sumset.add(s)

    intersection = sumset & cubes
    obstructs = len(intersection) == 0

    # Coset analysis: which cosets does C+C land in?
    # For p ≡ 1 (mod 3), there are 3 cosets of C_p in (Z/pZ)×
    coset_hits = defaultdict(int)
    if cube_index == 3:
        # Find a generator of the non-cube cosets
        gen = None
        for g in range(2, p):
            if pow(g, 3, p) not in cubes or g not in cubes:
                if g not in cubes and gcd(g, p) == 1:
                    gen = g
                    break
        if gen:
            coset0 = cubes  # C_p itself
            coset1 = {(gen * c) % p for c in cubes}
            coset2 = {(gen * gen * c) % p for c in cubes}
            for s in sumset:
                if s in coset0:
                    coset_hits['C_p'] += 1
                elif s in coset1:
                    coset_hits['g·C_p'] += 1
                elif s in coset2:
                    coset_hits['g²·C_p'] += 1

    return {
        'prime': p,
        'p_mod_3': p % 3,
        'cube_image': sorted(cubes),
        'cube_image_size': len(cubes),
        'cube_index': cube_index,
        'sumset_size': len(sumset),
        'intersection_size': len(intersection),
        'obstructs': obstructs,
        'coset_distribution': dict(coset_hits)
    }


# ═══════════════════════════════════════════════════════════════════
# Algorithm 4: Systematic Obstruction Search
# ═══════════════════════════════════════════════════════════════════

def obstruction_search(bound: int, x: int = 3, y: int = 3, z: int = 3,
                       prime_only: bool = True) -> dict:
    """
    Systematic search for moduli that obstruct signature (x, y, z).

    Pseudocode:
    1. For each prime p ≤ bound:
       a. Compute power images I_x, I_y, I_z in (Z/pZ)×
       b. Check if (I_x + I_y) ∩ I_z = ∅
       c. If obstructing, record p and its structural properties
    2. Classify obstructions by congruence class mod lcm(x,y,z)

    Time complexity: O(bound · p_max² · log(max_exp))
    Space complexity: O(p_max)

    >>> result = obstruction_search(50, 3, 3, 3)
    >>> sorted(result['obstructing'])
    [2, 7, 13]
    """
    obstructing = []
    non_obstructing = []

    candidates = range(2, bound + 1)
    if prime_only:
        candidates = [p for p in candidates if is_prime(p)]

    for n in candidates:
        if has_primitive_residue_solution(n, x, y, z):
            non_obstructing.append(n)
        else:
            obstructing.append(n)

    # Classify by congruence
    classification = defaultdict(list)
    for p in obstructing:
        if is_prime(p):
            classification[p % (x * y * z)].append(p)

    return {
        'bound': bound,
        'signature': (x, y, z),
        'obstructing': obstructing,
        'non_obstructing_count': len(non_obstructing),
        'obstruction_density': len(obstructing) / max(len(obstructing) + len(non_obstructing), 1),
        'classification_by_residue': dict(classification)
    }


# ═══════════════════════════════════════════════════════════════════
# Main: Run all algorithms with example output
# ═══════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("=" * 70)
    print("Algorithm 1: Primitive Residue Solution Checker")
    print("=" * 70)
    for n in [2, 3, 5, 7, 9, 11, 13, 14]:
        sol = has_primitive_residue_solution(n, 3, 3, 3)
        w = find_witness(n, 3, 3, 3)
        print(f"  N = {n:4d}: {'solvable' if sol else 'OBSTRUCTS'}"
              f"{f', witness = {w}' if w else ''}")
    print()

    print("=" * 70)
    print("Algorithm 2: CRT Decomposition")
    print("=" * 70)
    for n in [42, 91, 182, 1001, 2730]:
        result = crt_decompose(n, 3, 3, 3)
        obs_str = "OBSTRUCTS" if result['obstructs'] else "solvable"
        factors = [(f['modulus'], f['solvable']) for f in result['factors']]
        print(f"  N = {n:5d}: {obs_str}  factors = {factors}")
    print()

    print("=" * 70)
    print("Algorithm 3: Cube Subgroup Analysis")
    print("=" * 70)
    for p in [2, 3, 5, 7, 11, 13, 19, 31, 37, 43]:
        a = cube_subgroup_analysis(p)
        print(f"  p = {p:3d}: |C_p| = {a['cube_image_size']:3d}, "
              f"index = {a['cube_index']}, "
              f"{'OBSTRUCTS' if a['obstructs'] else 'solvable':>10s}")
    print()

    print("=" * 70)
    print("Algorithm 4: Obstruction Search")
    print("=" * 70)
    for sig in [(3, 3, 3), (3, 3, 5), (5, 5, 5)]:
        result = obstruction_search(100, *sig)
        print(f"  Signature {sig}: {len(result['obstructing'])} obstructing primes")
        print(f"    Primes: {result['obstructing']}")
        print(f"    Density: {result['obstruction_density']:.3f}")
    print()
