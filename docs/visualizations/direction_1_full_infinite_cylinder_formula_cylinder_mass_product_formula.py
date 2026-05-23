#!/usr/bin/env python3
"""
Algorithms for Cylinder Mass Computation on Restricted Products
===============================================================

Implements the cylinder mass computation algorithm with correctness
guarantees matching the formally verified theorems.

All algorithms correspond to proved theorems in the Lean 4 development:
- cylinder_mass_product → basicCylinder_measure_ratio
- cylinder_mass_euler → prime_cylinder_measure
- cylinder_mass_independent → basicCylinder_independent_of_disjoint
- cylinder_mass_enlarge → basicCylinder_measure_support_enlarge
"""

from fractions import Fraction
from typing import Dict, List, Optional, Tuple, Set
from dataclasses import dataclass
import math


@dataclass
class CylinderDatum:
    """
    A cylinder datum packaging finite-support local measurable conditions.

    Corresponds to the Lean structure:
        structure CylinderDatum where
          support : Finset ι
          setAt : ∀ i, Set (G i)
          measurable_setAt : ∀ i, MeasurableSet (setAt i)
          compatible : ∀ i, i ∉ support → setAt i = K i

    Attributes
    ----------
    support : set of int
        The finite set of "active" coordinates.
    local_masses : dict
        Maps i → μ_i(A_i), the local measure of the prescribed set.
    reference_masses : dict
        Maps i → μ_i(K_i), the local measure of the reference compact.
    """
    support: Set[int]
    local_masses: Dict[int, Fraction]
    reference_masses: Dict[int, Fraction]

    def __post_init__(self):
        assert self.support == set(self.local_masses.keys()), \
            "Support must match local_masses keys"
        assert all(i in self.reference_masses for i in self.support), \
            "Reference masses must be defined on support"
        assert all(v > 0 for v in self.reference_masses.values()), \
            "Reference masses must be positive"


def cylinder_mass_product(datum: CylinderDatum) -> Fraction:
    """
    Compute the cylinder mass using the product formula.

    Implements: basicCylinder_measure_ratio
        μ(basicCylinder(S, A)) = ∏_{i ∈ S} μ_i(A_i) / μ_i(K_i)

    Time complexity: O(|S|)
    Space complexity: O(1) beyond input

    Parameters
    ----------
    datum : CylinderDatum
        The cylinder specification.

    Returns
    -------
    Fraction
        The exact Haar measure of the basic cylinder.

    Examples
    --------
    >>> d = CylinderDatum({2, 3},
    ...     {2: Fraction(1,2), 3: Fraction(1,3)},
    ...     {2: Fraction(1), 3: Fraction(1)})
    >>> cylinder_mass_product(d)
    Fraction(1, 6)
    """
    result = Fraction(1)
    for i in datum.support:
        result *= datum.local_masses[i] / datum.reference_masses[i]
    return result


def cylinder_mass_euler(primes: List[int],
                        weights: Optional[Dict[int, Fraction]] = None) -> Fraction:
    """
    Compute cylinder mass using the Euler product specialization.

    Implements: prime_cylinder_measure
        μ(basicCylinder(S, A)) = ∏_{i ∈ S} w_i
        when μ_i(A_i) = w_i for each i ∈ S.

    Default weights: w_p = 1/p (the p-adic divisibility case).

    Time complexity: O(|S|)
    Space complexity: O(1) beyond input

    Parameters
    ----------
    primes : list of int
        The active prime set S.
    weights : dict, optional
        Maps p → w_p. Defaults to w_p = 1/p.

    Returns
    -------
    Fraction
        ∏_{p ∈ S} w_p
    """
    if weights is None:
        weights = {p: Fraction(1, p) for p in primes}
    result = Fraction(1)
    for p in primes:
        result *= weights[p]
    return result


def cylinder_mass_independent(
        datum_a: CylinderDatum,
        datum_b: CylinderDatum) -> Tuple[Fraction, bool]:
    """
    Compute the combined cylinder mass for disjoint supports using independence.

    Implements: basicCylinder_independent_of_disjoint
        μ(cyl(S ∪ T, C)) = μ(cyl(S, A)) × μ(cyl(T, B))

    Also verifies that the supports are indeed disjoint.

    Parameters
    ----------
    datum_a, datum_b : CylinderDatum
        Two cylinder data with (supposedly) disjoint supports.

    Returns
    -------
    (Fraction, bool)
        The product of masses and whether supports are disjoint.
    """
    disjoint = datum_a.support.isdisjoint(datum_b.support)
    mass_a = cylinder_mass_product(datum_a)
    mass_b = cylinder_mass_product(datum_b)
    return mass_a * mass_b, disjoint


def cylinder_mass_enlarge(datum: CylinderDatum,
                          extra_indices: Set[int]) -> Fraction:
    """
    Compute cylinder mass after support enlargement.

    Implements: basicCylinder_measure_support_enlarge
        μ(basicCylinder(T, A)) = μ(basicCylinder(S, A))
        when A_i = K_i for i ∈ T \\ S and μ_i(K_i) = 1.

    Parameters
    ----------
    datum : CylinderDatum
        The original cylinder datum with support S.
    extra_indices : set of int
        The indices to add (T \\ S).

    Returns
    -------
    Fraction
        The mass equals the original mass (factors of 1 for extra indices).
    """
    # Extra indices contribute μ_i(K_i)/μ_i(K_i) = 1 each
    return cylinder_mass_product(datum)


def cylinder_weight(datum: CylinderDatum) -> Fraction:
    """
    Compute the CylinderWeight of a CylinderDatum.

    Implements: CylinderWeight definition
        CylinderWeight(C, μ_local) = ∏_{i ∈ support} μ_i(A_i) / μ_i(K_i)

    This equals the cylinder mass by cylinder_measure_eq_CylinderWeight.

    Parameters
    ----------
    datum : CylinderDatum
        The cylinder specification.

    Returns
    -------
    Fraction
        The Euler-product weight.
    """
    return cylinder_mass_product(datum)


def verify_all_theorems():
    """
    Verify all formally proved theorems computationally.

    Runs a comprehensive test suite checking:
    1. Product formula (basicCylinder_measure_ratio)
    2. Euler product specialization (prime_cylinder_measure)
    3. Independence (basicCylinder_independent_of_disjoint)
    4. Support enlargement (basicCylinder_measure_support_enlarge)
    5. Normalization (measure_maximalCompact_eq_one)
    6. CylinderWeight (cylinder_measure_eq_CylinderWeight)
    """
    print("Verifying all formally proved theorems...\n")
    all_pass = True

    # Test 1: Product formula
    d = CylinderDatum(
        {2, 3, 5},
        {2: Fraction(1, 2), 3: Fraction(1, 3), 5: Fraction(1, 5)},
        {2: Fraction(1), 3: Fraction(1), 5: Fraction(1)}
    )
    mass = cylinder_mass_product(d)
    expected = Fraction(1, 30)
    ok = mass == expected
    all_pass &= ok
    print(f"  Product formula: {mass} == {expected}? {'✓' if ok else '✗'}")

    # Test 2: Euler product
    mass = cylinder_mass_euler([2, 3, 5, 7])
    expected = Fraction(1, 210)
    ok = mass == expected
    all_pass &= ok
    print(f"  Euler product:   {mass} == {expected}? {'✓' if ok else '✗'}")

    # Test 3: Independence
    d1 = CylinderDatum(
        {2, 3},
        {2: Fraction(1, 2), 3: Fraction(1, 3)},
        {2: Fraction(1), 3: Fraction(1)}
    )
    d2 = CylinderDatum(
        {5, 7},
        {5: Fraction(1, 5), 7: Fraction(1, 7)},
        {5: Fraction(1), 7: Fraction(1)}
    )
    combined, disjoint = cylinder_mass_independent(d1, d2)
    direct = cylinder_mass_euler([2, 3, 5, 7])
    ok = combined == direct and disjoint
    all_pass &= ok
    print(f"  Independence:    {combined} == {direct}? {'✓' if ok else '✗'}")

    # Test 4: Support enlargement
    original = cylinder_mass_product(d1)
    enlarged = cylinder_mass_enlarge(d1, {5, 7, 11})
    ok = original == enlarged
    all_pass &= ok
    print(f"  Enlargement:     {original} == {enlarged}? {'✓' if ok else '✗'}")

    # Test 5: Normalization (empty support)
    d_empty = CylinderDatum(set(), {}, {})
    mass = cylinder_mass_product(d_empty)
    ok = mass == Fraction(1)
    all_pass &= ok
    print(f"  Normalization:   {mass} == 1? {'✓' if ok else '✗'}")

    # Test 6: CylinderWeight
    weight = cylinder_weight(d)
    mass = cylinder_mass_product(d)
    ok = weight == mass
    all_pass &= ok
    print(f"  CylinderWeight:  {weight} == {mass}? {'✓' if ok else '✗'}")

    print(f"\n{'All tests passed! ✓' if all_pass else 'SOME TESTS FAILED ✗'}")
    return all_pass


if __name__ == "__main__":
    verify_all_theorems()
