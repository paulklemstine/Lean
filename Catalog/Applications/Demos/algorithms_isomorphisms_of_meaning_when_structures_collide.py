#!/usr/bin/env python3
"""
Algorithms for Semantic Fiber Theory

Type-hinted implementations of the core algorithms from the research.
"""

from typing import TypeVar, Callable, Set, FrozenSet, List, Tuple, Dict
from math import gcd
from itertools import product
from collections import defaultdict

T = TypeVar('T')


def compute_automorphisms_cyclic(n: int) -> List[Callable[[int], int]]:
    """
    Compute the automorphism group of ℤ/nℤ.

    Automorphisms of ℤ/nℤ are multiplication by units mod n.

    Args:
        n: The group order

    Returns:
        List of automorphisms, each as a function int -> int
    """
    units = [k for k in range(1, n) if gcd(k, n) == 1]
    return [lambda x, k=k: (k * x) % n for k in units]


def compute_orbits_generic(
    elements: List[T],
    automorphisms: List[Callable[[T], T]]
) -> List[FrozenSet[T]]:
    """
    Compute orbits of a group action on a set.

    The semantic fiber of a structure S with automorphism group Aut(S)
    acting on a set X is the set of orbits Aut(S) \\ X.

    Args:
        elements: The set being acted on
        automorphisms: List of automorphisms (as functions)

    Returns:
        List of orbits (each as a frozenset)
    """
    visited: Set[T] = set()
    orbits: List[FrozenSet[T]] = []

    for x in elements:
        if x not in visited:
            orbit = frozenset(phi(x) for phi in automorphisms)
            orbits.append(orbit)
            visited |= set(orbit)

    return orbits


def semantic_fiber_size(n: int) -> int:
    """
    Compute the semantic fiber size (number of orbits of Aut(ℤ/nℤ) on ℤ/nℤ).

    This is the number of semantically distinct pointed groups over ℤ/nℤ.

    Args:
        n: The group order

    Returns:
        Number of semantic classes
    """
    auts = compute_automorphisms_cyclic(n)
    elements = list(range(n))
    return len(compute_orbits_generic(elements, auts))


def burnside_count(
    elements: List[T],
    automorphisms: List[Callable[[T], T]]
) -> float:
    """
    Apply Burnside's lemma to count orbits.

    |orbits| = (1/|G|) Σ_{g ∈ G} |Fix(g)|

    Args:
        elements: The set being acted on
        automorphisms: The group acting on it

    Returns:
        Number of orbits (as float, should be integer)
    """
    total_fixed = sum(
        sum(1 for x in elements if phi(x) == x)
        for phi in automorphisms
    )
    return total_fixed / len(automorphisms)


def is_semantically_rigid(n: int) -> bool:
    """
    Check if ℤ/nℤ is semantically rigid (Aut = {id}).

    A structure is rigid iff every element is in its own orbit,
    equivalently iff the automorphism group is trivial.

    Args:
        n: The group order

    Returns:
        True iff the group is semantically rigid
    """
    # Aut(ℤ/nℤ) is trivial iff φ(n) = 1 iff n ∈ {1, 2}
    euler_phi = sum(1 for k in range(1, n) if gcd(k, n) == 1)
    return euler_phi == 1


def ring_structures_on_Z2() -> List[Dict[str, Tuple[Tuple[int, int], ...]]]:
    """
    Enumerate ring structures on ℤ² = ℤ × ℤ by specifying
    multiplication of basis elements.

    A ring structure on ℤ² is determined by:
    - e₁ · e₁ = (a₁₁, a₁₂)
    - e₁ · e₂ = (a₂₁, a₂₂)
    - e₂ · e₁ = (b₁₁, b₁₂)
    - e₂ · e₂ = (b₂₁, b₂₂)

    subject to associativity and distributivity (distributivity is free
    since we extend bilinearly).

    Returns representative ring structures including ℤ[i] and ℤ×ℤ.
    """
    structures = []

    # ℤ × ℤ (componentwise): e₁² = e₁, e₂² = e₂, e₁e₂ = 0
    structures.append({
        "name": "ℤ × ℤ",
        "e1e1": (1, 0), "e1e2": (0, 0),
        "e2e1": (0, 0), "e2e2": (0, 1),
        "is_domain": False,
        "has_unity": True,
    })

    # ℤ[i]: e₁ = 1, e₂ = i, so e₁² = e₁, e₁e₂ = e₂, e₂² = -e₁
    structures.append({
        "name": "ℤ[i]",
        "e1e1": (1, 0), "e1e2": (0, 1),
        "e2e1": (0, 1), "e2e2": (-1, 0),
        "is_domain": True,
        "has_unity": True,
    })

    # ℤ[√2]: e₁ = 1, e₂ = √2, so e₂² = 2·e₁
    structures.append({
        "name": "ℤ[√2]",
        "e1e1": (1, 0), "e1e2": (0, 1),
        "e2e1": (0, 1), "e2e2": (2, 0),
        "is_domain": True,
        "has_unity": True,
    })

    # Zero multiplication: all products = 0
    structures.append({
        "name": "Zero ring",
        "e1e1": (0, 0), "e1e2": (0, 0),
        "e2e1": (0, 0), "e2e2": (0, 0),
        "is_domain": False,
        "has_unity": False,
    })

    return structures


def torsor_decomposition(
    n: int, reference_unit: int, target_unit: int
) -> int:
    """
    Decompose an isomorphism of ℤ/nℤ relative to a reference.

    Given reference iso φ₀: x ↦ reference_unit·x and target iso φ: x ↦ target_unit·x,
    find the unique α ∈ Aut(ℤ/nℤ) such that φ = φ₀ ∘ α.

    α must satisfy: target_unit·x = reference_unit·(α_unit·x) mod n
    So α_unit = reference_unit⁻¹ · target_unit mod n.

    Args:
        n: Group order
        reference_unit: The unit defining the reference isomorphism
        target_unit: The unit defining the target isomorphism

    Returns:
        The unit defining the automorphism α
    """
    # Find inverse of reference_unit mod n
    ref_inv = pow(reference_unit, -1, n)
    return (ref_inv * target_unit) % n


if __name__ == "__main__":
    print("=== Semantic Fiber Theory: Algorithm Demonstrations ===\n")

    # Semantic fiber sizes for cyclic groups
    print("Semantic fiber sizes for ℤ/nℤ:")
    for n in range(2, 20):
        sf = semantic_fiber_size(n)
        rigid = is_semantically_rigid(n)
        print(f"  n={n:2d}: fiber size = {sf:2d}, rigid = {rigid}")

    print()

    # Ring structures on ℤ²
    print("Ring structures on ℤ²:")
    for ring in ring_structures_on_Z2():
        print(f"  {ring['name']}: domain={ring['is_domain']}, unity={ring['has_unity']}")

    print()

    # Torsor decomposition example
    n = 7
    ref = 1  # Reference: identity
    print(f"Torsor decomposition for ℤ/{n}ℤ (reference = id):")
    for k in range(1, n):
        if gcd(k, n) == 1:
            alpha = torsor_decomposition(n, ref, k)
            print(f"  φ: x↦{k}x = φ₀ ∘ α where α: x↦{alpha}x")
