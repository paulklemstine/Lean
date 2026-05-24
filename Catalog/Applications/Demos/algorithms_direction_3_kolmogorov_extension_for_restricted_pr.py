#!/usr/bin/env python3
"""
Algorithms for Kolmogorov Extension on Restricted Products

Implements the key computational methods from the research:
1. Cylinder mass computation via the product formula
2. Support refinement algorithm for comparing cylinders
3. Projective compatibility verification
4. Translation invariance testing

All algorithms work with exact rational arithmetic (fractions.Fraction).
"""

from fractions import Fraction
from typing import Dict, List, Set, Tuple, Optional
from itertools import product
import math


class CylinderSet:
    """
    A basic cylinder in a restricted product.

    A cylinder is specified by:
    - A support S (finite set of coordinate indices)
    - For each i ∈ S, a set A_i of allowed values
    - For each i ∉ S, values are constrained to K_i (the default set)

    This corresponds to basicCylinder G K S A in the Lean formalization.
    """

    def __init__(self, support: Dict[int, Set[int]], group_orders: Dict[int, int],
                 default_sets: Optional[Dict[int, Set[int]]] = None):
        """
        Args:
            support: Dict mapping coordinate index → set of allowed values.
            group_orders: Dict mapping coordinate index → order of the group.
            default_sets: Dict mapping coordinate index → default (compact-open) set.
                         Defaults to {0} for each coordinate.
        """
        self.support = dict(support)
        self.group_orders = dict(group_orders)
        self.default_sets = default_sets or {i: {0} for i in group_orders}

    def enlarge_support(self, new_indices: Set[int]) -> 'CylinderSet':
        """
        Support enlargement: add new coordinates using their default sets.

        This is the computational analogue of basicCylinder_measure_support_enlarge:
        the cylinder set is unchanged, but the support representation grows.

        Complexity: O(|new_indices|)
        """
        new_support = dict(self.support)
        for i in new_indices:
            if i not in new_support:
                new_support[i] = set(self.default_sets.get(i, {0}))
        return CylinderSet(new_support, self.group_orders, self.default_sets)

    def common_refinement(self, other: 'CylinderSet') -> Tuple['CylinderSet', 'CylinderSet']:
        """
        Refine two cylinders to a common support.

        Returns new cylinders over the union support S₁ ∪ S₂,
        with default sets on new coordinates. This is the computational
        analogue of basicCylinder_common_refinement.

        Complexity: O(|S₁| + |S₂|)
        """
        all_indices = set(self.support.keys()) | set(other.support.keys())
        new_self = self.enlarge_support(all_indices)
        new_other = other.enlarge_support(all_indices)
        return new_self, new_other


def cylinder_mass(
    support: Dict[int, Set[int]],
    group_orders: Dict[int, int],
    local_measures: Optional[Dict[int, Dict[int, Fraction]]] = None
) -> Fraction:
    """
    Compute the cylinder mass from compatible finite marginals.

    By the cylinder mass formula (cylinderMass_of_local_eq_prod):
        mass(C_{S,A}) = ∏_{i ∈ S} μ_i(A_i)

    For uniform measures: μ_i(A_i) = |A_i| / |G_i|.

    Args:
        support: Dict mapping coordinate index → set of allowed values.
        group_orders: Dict mapping coordinate index → order of the group.
        local_measures: Optional custom local measures. If None, uses uniform.

    Returns:
        Exact cylinder mass as a Fraction.

    Complexity: O(|S|) where S is the support.
    """
    mass = Fraction(1)
    for i, allowed in support.items():
        if local_measures and i in local_measures:
            # Custom measure: sum of point masses
            coord_mass = sum(local_measures[i].get(v, Fraction(0)) for v in allowed)
        else:
            # Uniform measure
            n = group_orders[i]
            coord_mass = Fraction(len(allowed), n)
        mass *= coord_mass
    return mass


def support_refinement_compare(
    cyl1: CylinderSet, cyl2: CylinderSet,
    group_orders: Dict[int, int]
) -> Tuple[Fraction, Fraction]:
    """
    Support refinement algorithm: compare two cylinders by reducing to
    a common finite support.

    This implements the key algorithmic step in the well-definedness proof:
    1. Find the union support S₁ ∪ S₂
    2. Enlarge both cylinders to the union support
    3. Compare masses over the common support

    The geometric equality is guaranteed by basicCylinder_measure_support_enlarge.
    The measure equality follows from cylinder_value_wellDefined.

    Args:
        cyl1, cyl2: Two cylinder sets to compare.
        group_orders: Orders of the groups at each coordinate.

    Returns:
        Tuple of (mass_1, mass_2) computed over the common support.

    Complexity: O(|S₁ ∪ S₂|)
    """
    refined1, refined2 = cyl1.common_refinement(cyl2)
    mass1 = cylinder_mass(refined1.support, group_orders)
    mass2 = cylinder_mass(refined2.support, group_orders)
    return mass1, mass2


def verify_projective_compatibility(
    group_orders: Dict[int, int],
    S: Set[int],
    T: Set[int],
    constraint: Dict[int, Set[int]]
) -> Tuple[Fraction, Fraction, bool]:
    """
    Verify projective compatibility: ν_T marginal to S equals ν_S.

    For product measures, the marginal of ν_T to coordinates S ⊆ T
    is computed by integrating out coordinates T \ S (which contribute
    factor 1 for probability measures).

    Args:
        group_orders: Orders of the groups.
        S: Smaller support.
        T: Larger support (S ⊆ T).
        constraint: Coordinate constraints (on S-coordinates).

    Returns:
        (mass_S, mass_T_marginal, compatible): masses and whether they match.

    Complexity: O(|T|)
    """
    assert S <= T, f"S must be a subset of T"

    # ν_S(constraint)
    mass_S = cylinder_mass(
        {i: constraint[i] for i in constraint if i in S},
        group_orders
    )

    # ν_T(constraint × full groups on T\S)
    marginal_constraint = dict(constraint)
    for j in T:
        if j not in S:
            marginal_constraint[j] = set(range(group_orders[j]))
    mass_T = cylinder_mass(marginal_constraint, group_orders)

    return mass_S, mass_T, mass_S == mass_T


def verify_translation_invariance(
    group_orders: Dict[int, int],
    support: Dict[int, Set[int]],
    translation: Dict[int, int],
    num_random_tests: int = 0
) -> Tuple[Fraction, Fraction, bool]:
    """
    Verify translation invariance: mass(g · C) = mass(C).

    For uniform measures on finite groups, left translation by any element
    preserves the measure. This is the discrete Haar invariance property.

    Args:
        group_orders: Orders of the groups.
        support: Original cylinder constraint.
        translation: Finitely supported translation vector.
        num_random_tests: Additional random tests to perform.

    Returns:
        (original_mass, translated_mass, invariant): masses and whether they match.

    Complexity: O(|S| · max_group_order)
    """
    # Original mass
    original_mass = cylinder_mass(support, group_orders)

    # Translated mass: x → g·x ∈ A iff x ∈ g⁻¹·A
    translated_support = {}
    for i, allowed in support.items():
        n = group_orders[i]
        g = translation.get(i, 0)
        translated_support[i] = {(a - g) % n for a in allowed}

    translated_mass = cylinder_mass(translated_support, group_orders)

    return original_mass, translated_mass, original_mass == translated_mass


def verify_finite_additivity(
    group_orders: Dict[int, int],
    support_base: Dict[int, Set[int]],
    partition_coord: int,
    partition: List[Set[int]]
) -> Tuple[Fraction, Fraction, bool]:
    """
    Verify finite additivity: if A_j = ⊔_k B_k is a disjoint partition,
    then μ(C_{S, A with A_j=⊔B_k}) = Σ_k μ(C_{S, A with A_j=B_k}).

    Args:
        group_orders: Orders of the groups.
        support_base: Base constraint on other coordinates.
        partition_coord: Index of the coordinate being partitioned.
        partition: List of disjoint subsets forming the partition.

    Returns:
        (union_mass, sum_mass, additive): masses and whether they match.

    Complexity: O(|partition| · |S|)
    """
    # Verify disjointness
    all_elements = set()
    for part in partition:
        assert part.isdisjoint(all_elements), "Partition parts must be disjoint"
        all_elements |= part

    # Union mass
    union_support = dict(support_base)
    union_support[partition_coord] = all_elements
    union_mass = cylinder_mass(union_support, group_orders)

    # Sum of part masses
    sum_mass = Fraction(0)
    for part in partition:
        part_support = dict(support_base)
        part_support[partition_coord] = part
        sum_mass += cylinder_mass(part_support, group_orders)

    return union_mass, sum_mass, union_mass == sum_mass


# ── Example usage ──────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms for Kolmogorov Extension on Restricted Products")
    print("=" * 60)
    print()

    # Set up arithmetic example: first 5 primes
    primes = [2, 3, 5, 7, 11]
    orders = {i: p for i, p in enumerate(primes)}

    # 1. Cylinder mass computation
    print("1. Cylinder Mass (Product Formula)")
    support = {0: {0}, 1: {0, 1}}
    mass = cylinder_mass(support, orders)
    print(f"   Support: {support}")
    print(f"   Mass = {mass} = {float(mass):.6f}")
    print()

    # 2. Support refinement
    print("2. Support Refinement Algorithm")
    cyl1 = CylinderSet({0: {0}}, orders)
    cyl2 = CylinderSet({1: {0, 1}}, orders)
    m1, m2 = support_refinement_compare(cyl1, cyl2, orders)
    print(f"   Cylinder 1 mass: {m1}")
    print(f"   Cylinder 2 mass: {m2}")
    print()

    # 3. Projective compatibility
    print("3. Projective Compatibility Check")
    S = {0, 1}
    T = {0, 1, 2, 3}
    constraint = {0: {0, 1}, 1: {0}}
    ms, mt, compat = verify_projective_compatibility(orders, S, T, constraint)
    print(f"   ν_S = {ms}, ν_T marginal = {mt}, compatible: {compat}")
    print()

    # 4. Translation invariance
    print("4. Translation Invariance Check")
    support = {0: {0}, 1: {0, 2}}
    translation = {0: 1, 1: 1}
    mo, mt, inv = verify_translation_invariance(orders, support, translation)
    print(f"   Original = {mo}, translated = {mt}, invariant: {inv}")
    print()

    # 5. Finite additivity
    print("5. Finite Additivity Check")
    base = {0: {0}}
    partition = [{0}, {1, 2}, {3, 4}]  # partition of ℤ/5ℤ
    mu, ms, add = verify_finite_additivity(orders, base, 2, partition)
    print(f"   Union mass = {mu}, sum of parts = {ms}, additive: {add}")
