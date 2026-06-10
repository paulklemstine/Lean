#!/usr/bin/env python3
"""
Beal Obstruction Theory — Algorithms

Implements the core algorithms from the research:
1. Primitive residue solution enumeration
2. CRT-compressed multi-modulus obstruction search
3. ABC threshold computation
4. Obstruction certificate generation and verification
"""

from math import gcd, prod
from itertools import product as cartesian_product
from functools import reduce
from typing import Optional


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Primitive Residue Solution Enumeration
# ─────────────────────────────────────────────────────────────────────

def euler_totient(n: int) -> int:
    """Compute Euler's totient function φ(n).

    Time complexity: O(√n)
    """
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


def units_mod_n(N: int) -> list[int]:
    """Return all units modulo N (integers 0 ≤ a < N with gcd(a,N) = 1).

    Time complexity: O(N log N)
    """
    return [a for a in range(N) if gcd(a, N) == 1]


def enumerate_primitive_residue_solutions(
    N: int, x: int, y: int, z: int
) -> list[tuple[int, int, int]]:
    """
    Enumerate all primitive residue solutions modulo N for signature (x, y, z).

    A primitive residue solution is (a, b, c) ∈ (ℤ/Nℤ)* × (ℤ/Nℤ)* × (ℤ/Nℤ)*
    satisfying a^x + b^y ≡ c^z (mod N).

    Time complexity: O(φ(N)³) where φ is Euler's totient.
    Space complexity: O(φ(N)² + |solutions|)

    Parameters
    ----------
    N : int > 0
        The modulus.
    x, y, z : int ≥ 0
        Exponent signature.

    Returns
    -------
    list of (int, int, int)
    """
    units = units_mod_n(N)

    # Precompute c^z lookup table: maps residue → list of c values
    cz_table: dict[int, list[int]] = {}
    for c in units:
        r = pow(c, z, N)
        cz_table.setdefault(r, []).append(c)

    solutions = []
    for a in units:
        ax = pow(a, x, N)
        for b in units:
            by_ = pow(b, y, N)
            target = (ax + by_) % N
            if target in cz_table:
                for c in cz_table[target]:
                    solutions.append((a, b, c))

    return solutions


def has_primitive_residue_solution(N: int, x: int, y: int, z: int) -> bool:
    """
    Check if any primitive residue solution exists modulo N.

    Optimized: returns True as soon as the first solution is found.

    Time complexity: O(φ(N)²) average, O(φ(N)³) worst case.
    """
    units = units_mod_n(N)

    cz_set: set[int] = set()
    for c in units:
        cz_set.add(pow(c, z, N))

    for a in units:
        ax = pow(a, x, N)
        for b in units:
            by_ = pow(b, y, N)
            if (ax + by_) % N in cz_set:
                return True
    return False


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Multi-Modulus Obstruction Search
# ─────────────────────────────────────────────────────────────────────

def find_single_modulus_obstruction(
    x: int, y: int, z: int, max_N: int = 1000
) -> Optional[int]:
    """
    Search for a single modulus N ≤ max_N that provides a complete
    obstruction for signature (x, y, z).

    An obstruction means: no primitive residue solution exists mod N,
    implying no coprime integer solution exists (by our theorem).

    Time complexity: O(max_N · φ(max_N)²)

    Returns
    -------
    int or None
        The smallest obstructing modulus, or None if not found.
    """
    for N in range(2, max_N + 1):
        if not has_primitive_residue_solution(N, x, y, z):
            return N
    return None


def find_multi_modulus_obstruction(
    x: int, y: int, z: int,
    candidate_moduli: list[int],
    max_product: int = 10**6
) -> Optional[list[int]]:
    """
    Search for a set of pairwise coprime moduli whose combined
    CRT product provides an obstruction.

    Strategy: greedily select moduli that minimize the surviving
    solution count in their local residue sets.

    Parameters
    ----------
    x, y, z : int
        Exponent signature.
    candidate_moduli : list of int
        Pool of candidate moduli to consider.
    max_product : int
        Maximum allowed product of selected moduli.

    Returns
    -------
    list of int or None
        A set of obstructing moduli, or None if not found.
    """
    # First check individual moduli
    for m in candidate_moduli:
        if not has_primitive_residue_solution(m, x, y, z):
            return [m]

    # Try pairwise coprime combinations
    selected: list[int] = []
    current_product = 1

    # Sort by solution density (ascending)
    densities = []
    for m in candidate_moduli:
        count = len(enumerate_primitive_residue_solutions(m, x, y, z))
        total = euler_totient(m) ** 3
        density = count / total if total > 0 else 1.0
        densities.append((density, m))
    densities.sort()

    for _, m in densities:
        if current_product * m > max_product:
            continue
        # Check coprimality with all selected
        if all(gcd(m, s) == 1 for s in selected):
            selected.append(m)
            current_product *= m
            # Check if the CRT product gives obstruction
            if not has_primitive_residue_solution(current_product, x, y, z):
                return selected

    return None


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: ABC Threshold Computation
# ─────────────────────────────────────────────────────────────────────

def abc_exponent_threshold(K: int) -> int:
    """
    Compute the minimal exponent threshold n such that IntAbcBound(K)
    implies no primitive Beal solution with all exponents ≥ n.

    By the ABC Threshold Theorem: n = 3K + 1.

    The proof shows:
    - From IntAbcBound(K): C^z ≤ (ABC)^K
    - From base bounds: (ABC)^n < C^(3z)
    - Combining: C^(nz) < C^(3Kz)
    - For C ≥ 2: n < 3K, contradicting 3K < n.

    Parameters
    ----------
    K : int > 0
        The ABC exponent strength.

    Returns
    -------
    int
        The threshold 3K + 1.
    """
    return 3 * K + 1


def forbidden_exponent_region(K: int) -> dict:
    """
    Describe the forbidden exponent region for IntAbcBound(K).

    Returns a dictionary describing the region in exponent space
    where no primitive Beal solution can exist.
    """
    n = abc_exponent_threshold(K)
    return {
        "K": K,
        "threshold": n,
        "condition": f"x ≥ {n} and y ≥ {n} and z ≥ {n}",
        "statement": (
            f"IntAbcBound({K}) implies no pairwise coprime (A,B,C) with "
            f"A^x + B^y = C^z when x,y,z ≥ {n}."
        ),
    }


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Obstruction Certificate
# ─────────────────────────────────────────────────────────────────────

def generate_obstruction_certificate(
    N: int, x: int, y: int, z: int
) -> dict:
    """
    Generate a machine-checkable obstruction certificate.

    If no primitive residue solution exists modulo N for signature (x,y,z),
    the certificate records:
    - The modulus N
    - The exponent signature
    - The exhaustive enumeration result
    - The formal theorem it invokes

    Returns
    -------
    dict
        The obstruction certificate, or a report that no obstruction was found.
    """
    solutions = enumerate_primitive_residue_solutions(N, x, y, z)

    if not solutions:
        return {
            "type": "OBSTRUCTION_CERTIFICATE",
            "status": "VALID",
            "modulus": N,
            "signature": (x, y, z),
            "solution_count": 0,
            "theorem": "no_primitive_beal_of_no_primitive_residue_solution",
            "conclusion": (
                f"No pairwise coprime solution to A^{x} + B^{y} = C^{z} "
                f"exists among integers coprime to {N}."
            ),
            "verification": (
                f"Exhaustive check of all φ({N})³ = {euler_totient(N)**3} "
                f"unit triples modulo {N} found 0 solutions."
            ),
        }
    else:
        return {
            "type": "OBSTRUCTION_CERTIFICATE",
            "status": "NO_OBSTRUCTION",
            "modulus": N,
            "signature": (x, y, z),
            "solution_count": len(solutions),
            "sample_solutions": solutions[:5],
            "note": (
                f"Found {len(solutions)} primitive residue solutions mod {N}. "
                f"This modulus does not provide an obstruction."
            ),
        }


def verify_certificate(cert: dict) -> bool:
    """
    Verify an obstruction certificate by re-running the enumeration.

    Returns True if the certificate is valid.
    """
    if cert["status"] != "VALID":
        return False

    N = cert["modulus"]
    x, y, z = cert["signature"]
    solutions = enumerate_primitive_residue_solutions(N, x, y, z)
    return len(solutions) == 0


# ─────────────────────────────────────────────────────────────────────
# Main: Example usage
# ─────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithm 1: Primitive Residue Solution Enumeration")
    print("=" * 55)
    for sig in [(3,3,3), (4,4,4), (5,5,5)]:
        x, y, z = sig
        for N in [7, 8, 9]:
            sols = enumerate_primitive_residue_solutions(N, x, y, z)
            print(f"  ({x},{y},{z}) mod {N}: {len(sols)} solutions")

    print("\nAlgorithm 2: Obstruction Search")
    print("=" * 55)
    for sig in [(3,3,3), (4,4,4), (5,5,5), (3,5,7)]:
        x, y, z = sig
        obs = find_single_modulus_obstruction(x, y, z, max_N=100)
        if obs:
            print(f"  ({x},{y},{z}): obstruction at N = {obs}")
        else:
            print(f"  ({x},{y},{z}): no single-modulus obstruction ≤ 100")

    print("\nAlgorithm 3: ABC Threshold Table")
    print("=" * 55)
    for K in range(1, 8):
        region = forbidden_exponent_region(K)
        print(f"  K={K}: {region['statement']}")

    print("\nAlgorithm 4: Certificate Generation")
    print("=" * 55)
    cert = generate_obstruction_certificate(7, 3, 3, 3)
    print(f"  Certificate for (3,3,3) mod 7: {cert['status']}")
    if cert['status'] == 'VALID':
        verified = verify_certificate(cert)
        print(f"  Verified: {verified}")
    else:
        print(f"  {cert['note']}")
