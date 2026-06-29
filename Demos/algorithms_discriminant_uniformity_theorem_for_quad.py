#!/usr/bin/env python3
"""
Algorithms for Discriminant Uniformity and Quadratic Splitting Types

Type-hinted implementations of the core algorithms from the research.
"""
from typing import Dict, List, Tuple, Set


def compute_discriminant(b: int, c: int, p: int) -> int:
    """
    Compute the discriminant b² - 4c of the monic quadratic x² + bx + c over Z/pZ.

    Algorithm: Direct computation modulo p.
    Complexity: O(1)

    Args:
        b: coefficient of x in x² + bx + c
        c: constant term in x² + bx + c
        p: prime modulus

    Returns:
        (b² - 4c) mod p
    """
    return (b * b - 4 * c) % p


def compute_fiber(d: int, p: int) -> List[Tuple[int, int]]:
    """
    Compute the fiber of the discriminant map over d ∈ Z/pZ.

    For odd primes, uses the explicit formula c = (b² - d) · 4⁻¹ mod p.
    For p = 2, uses direct enumeration.

    Complexity: O(p)

    Args:
        d: target discriminant value
        p: prime modulus

    Returns:
        List of pairs (b, c) with b² - 4c ≡ d (mod p)
    """
    if p == 2:
        # In Z/2Z, 4 = 0, so b² - 4c = b² = b
        # Fiber of d is {(d, 0), (d, 1)}
        return [(d % 2, c) for c in range(2)]

    # For odd primes, 4 is invertible
    inv4 = pow(4, p - 2, p)  # Fermat's little theorem
    fiber = []
    for b in range(p):
        c = ((b * b - d) * inv4) % p
        fiber.append((b, c))
    return fiber


def classify_quadratic(b: int, c: int, p: int) -> str:
    """
    Classify a monic quadratic x² + bx + c over Z/pZ by splitting type.

    Uses the Euler criterion for quadratic residues.

    Algorithm:
    1. Compute discriminant d = b² - 4c mod p
    2. If d = 0: ramified
    3. If d^((p-1)/2) ≡ 1 (mod p): split (d is a square)
    4. Otherwise: inert (d is a non-square)

    Complexity: O(log p) for the Euler criterion

    Args:
        b, c: coefficients of x² + bx + c
        p: prime modulus

    Returns:
        One of "split", "ramified", "inert"
    """
    d = compute_discriminant(b, c, p)
    if d == 0:
        return "ramified"
    if p == 2:
        return "split"  # every nonzero element of Z/2Z is a square
    # Euler criterion: d is a square iff d^((p-1)/2) ≡ 1 (mod p)
    if pow(d, (p - 1) // 2, p) == 1:
        return "split"
    return "inert"


def splitting_type_counts(p: int) -> Dict[str, int]:
    """
    Count the number of quadratics of each splitting type over Z/pZ.

    By the Discriminant Uniformity Theorem:
    - ramified: p (fiber over 0)
    - split: p · (p-1)/2 (fiber over each of (p-1)/2 nonzero squares)
    - inert: p · (p-1)/2 (fiber over each of (p-1)/2 non-squares)

    For p = 2: ramified = 2, split = 2, inert = 0.

    Complexity: O(1)

    Args:
        p: prime modulus

    Returns:
        Dictionary with counts for each splitting type
    """
    if p == 2:
        return {"ramified": 2, "split": 2, "inert": 0}
    return {
        "ramified": p,
        "split": p * (p - 1) // 2,
        "inert": p * (p - 1) // 2,
    }


def quadratic_residues(p: int) -> Set[int]:
    """
    Compute the set of quadratic residues modulo p.

    Algorithm: Square each element of Z/pZ.
    Complexity: O(p)

    Args:
        p: prime modulus

    Returns:
        Set of squares in Z/pZ
    """
    return {(x * x) % p for x in range(p)}


def separability_density_exact(p: int) -> Tuple[int, int]:
    """
    Compute the exact separability density as a fraction (numerator, denominator).

    By the Discriminant Uniformity Theorem, exactly p out of p² quadratics
    have zero discriminant, so the separability density is (p² - p) / p² = (p-1)/p.

    Complexity: O(1)

    Args:
        p: prime modulus

    Returns:
        (p - 1, p) — the numerator and denominator of the density
    """
    return (p - 1, p)


def irreducibility_fraction(p: int) -> Tuple[int, int]:
    """
    Compute the fraction of monic quadratics over Z/pZ that are irreducible.

    A monic quadratic is irreducible iff its discriminant is a non-square.
    There are (p-1)/2 non-squares for odd p, each contributing p quadratics.
    Total irreducible = p · (p-1)/2 out of p² total.
    Fraction = (p-1)/(2p).

    Complexity: O(1)

    Args:
        p: odd prime modulus

    Returns:
        (p - 1, 2 * p) — the numerator and denominator
    """
    if p == 2:
        return (0, 4)  # no irreducible quadratics over F_2
    return (p - 1, 2 * p)


def frobenius_cycle_type(splitting_type: str) -> List[int]:
    """
    Map a quadratic splitting type to the corresponding Frobenius cycle type.

    The Frobenius correspondence for degree 2:
    - split → [1, 1] (identity on 2 elements)
    - ramified → [1, 1] (degenerate)
    - inert → [2] (transposition)

    Args:
        splitting_type: one of "split", "ramified", "inert"

    Returns:
        Partition of 2 representing the cycle type
    """
    if splitting_type == "inert":
        return [2]
    return [1, 1]


if __name__ == "__main__":
    # Quick self-test
    for p in [2, 3, 5, 7, 11]:
        counts = splitting_type_counts(p)
        total = sum(counts.values())
        assert total == p * p, f"Total mismatch for p={p}: {total} != {p*p}"
        print(f"p={p}: {counts}, total={total}")

    print("\nIrreducibility fractions:")
    for p in [3, 5, 7, 11, 13, 101]:
        num, den = irreducibility_fraction(p)
        print(f"  p={p}: {num}/{den} = {num/den:.4f}, limit 1/2 = 0.5000")
