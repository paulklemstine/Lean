#!/usr/bin/env python3
"""
Algorithms for Cylinder Measure Computation on Restricted Products
=================================================================

Implements the core algorithms from the research paper:
1. Local mass computation for p-adic groups
2. Cylinder measure computation via Euler product
3. Cylinder energy computation (statistical mechanics bridge)
4. Residue class approximation for verification
"""

from fractions import Fraction
from typing import List, Dict, Optional, Tuple
import math


# ============================================================
# Algorithm 1: Local Mass Computation
# ============================================================

def compute_local_mass(
    p: int,
    valuation_min: int = 1,
    coset_count: Optional[int] = None
) -> Fraction:
    """
    Compute the local normalized mass of a p-adic constraint set.

    Given a prime p and a minimum valuation k, computes:
        localMass(p^k ℤ_p) = μ_p(p^k ℤ_p) / μ_p(ℤ_p) = 1/p^k

    More generally, for a set that is a union of `coset_count` cosets
    of p^k ℤ_p inside ℤ_p:
        localMass(A) = coset_count / p^k

    Parameters
    ----------
    p : int
        Prime number (the place)
    valuation_min : int
        Minimum p-adic valuation defining p^k ℤ_p
    coset_count : int, optional
        Number of cosets of p^k ℤ_p. Default is 1 (the subgroup itself).

    Returns
    -------
    Fraction
        Exact local mass as a rational number

    Complexity
    ----------
    Time: O(1) arithmetic operations
    Space: O(1)

    Examples
    --------
    >>> compute_local_mass(5, 1)  # 5ℤ_5 in ℤ_5
    Fraction(1, 5)
    >>> compute_local_mass(3, 2, coset_count=2)  # 2 cosets of 9ℤ_3
    Fraction(2, 9)
    """
    if p < 2:
        raise ValueError(f"p must be prime, got {p}")
    if valuation_min < 0:
        raise ValueError(f"valuation_min must be ≥ 0, got {valuation_min}")

    if coset_count is None:
        coset_count = 1

    if coset_count < 0 or coset_count > p ** valuation_min:
        raise ValueError(
            f"coset_count must be in [0, p^k] = [0, {p**valuation_min}], "
            f"got {coset_count}"
        )

    return Fraction(coset_count, p ** valuation_min)


# ============================================================
# Algorithm 2: Cylinder Measure via Euler Product
# ============================================================

def compute_cylinder_measure(
    constraints: Dict[int, Tuple[int, int]]
) -> Fraction:
    """
    Compute the Haar measure of a basic cylinder in the restricted product.

    Implements the main theorem:
        μ(basicCylinder(S, A)) = ∏_{i ∈ S} localMass_i(A_i)

    Parameters
    ----------
    constraints : dict
        Maps prime p -> (valuation_min, coset_count).
        Only primes in the support S are included.

    Returns
    -------
    Fraction
        Exact cylinder measure as a rational number

    Complexity
    ----------
    Time: O(|S|) multiplications of fractions
    Space: O(1) beyond input

    Examples
    --------
    >>> # x_2 ∈ 2ℤ_2, x_3 ∈ 3ℤ_3
    >>> compute_cylinder_measure({2: (1, 1), 3: (1, 1)})
    Fraction(1, 6)
    """
    result = Fraction(1, 1)
    for p, (val_min, count) in constraints.items():
        result *= compute_local_mass(p, val_min, count)
    return result


def compute_cylinder_measure_simple(
    primes: List[int],
    valuation_min: int = 1
) -> Fraction:
    """
    Simplified interface: all constraints have the same valuation minimum.

    Parameters
    ----------
    primes : list of int
        Finite support set S
    valuation_min : int
        Common minimum valuation for all primes

    Returns
    -------
    Fraction
        ∏_{p ∈ S} 1/p^k where k = valuation_min

    Examples
    --------
    >>> compute_cylinder_measure_simple([2, 3, 5])
    Fraction(1, 30)
    """
    return compute_cylinder_measure(
        {p: (valuation_min, 1) for p in primes}
    )


# ============================================================
# Algorithm 3: Cylinder Energy
# ============================================================

def compute_cylinder_energy(
    constraints: Dict[int, Tuple[int, int]]
) -> float:
    """
    Compute the cylinder energy: -log(μ(cylinder)).

    By the log-additivity theorem:
        E(cylinder) = -log μ(cyl) = ∑_{i ∈ S} -log(localMass_i(A_i))

    Parameters
    ----------
    constraints : dict
        Maps prime p -> (valuation_min, coset_count)

    Returns
    -------
    float
        The cylinder energy (total free energy)

    Complexity
    ----------
    Time: O(|S|) logarithm computations
    Space: O(1) beyond input

    Examples
    --------
    >>> compute_cylinder_energy({2: (1, 1), 3: (1, 1)})  # ≈ log(6)
    1.791759...
    """
    total = 0.0
    for p, (val_min, count) in constraints.items():
        mass = compute_local_mass(p, val_min, count)
        if mass == 0:
            return float('inf')
        total += -math.log(float(mass))
    return total


def compute_local_energies(
    constraints: Dict[int, Tuple[int, int]]
) -> Dict[int, float]:
    """
    Compute individual local energy contributions.

    Returns
    -------
    dict
        Maps prime p -> local energy -log(localMass_p(A_p))
    """
    result = {}
    for p, (val_min, count) in constraints.items():
        mass = compute_local_mass(p, val_min, count)
        result[p] = -math.log(float(mass)) if mass > 0 else float('inf')
    return result


# ============================================================
# Algorithm 4: Residue Class Approximation
# ============================================================

def approximate_local_mass(
    p: int,
    valuation_min: int,
    precision: int
) -> Fraction:
    """
    Approximate local mass via residue class counting at precision n.

    Counts: |p^k ℤ_p / p^n ℤ_p| / |ℤ_p / p^n ℤ_p| = p^{n-k} / p^n = 1/p^k

    This gives the exact answer for all n ≥ k, demonstrating convergence.

    Parameters
    ----------
    p : int
        Prime
    valuation_min : int
        Minimum valuation k
    precision : int
        Number of digits n for the approximation

    Returns
    -------
    Fraction
        Approximation at precision n

    Complexity
    ----------
    Time: O(1) arithmetic
    Space: O(1)
    """
    if precision < valuation_min:
        return Fraction(0, 1)  # Below precision threshold
    return Fraction(p ** (precision - valuation_min), p ** precision)


def verify_convergence(
    p: int,
    valuation_min: int = 1,
    max_precision: int = 10
) -> List[Tuple[int, Fraction, bool]]:
    """
    Verify that residue class approximations converge to the exact local mass.

    Returns
    -------
    list of (precision, approximation, is_exact)
    """
    exact = compute_local_mass(p, valuation_min)
    results = []
    for n in range(1, max_precision + 1):
        approx = approximate_local_mass(p, valuation_min, n)
        results.append((n, approx, approx == exact))
    return results


# ============================================================
# Algorithm 5: Euler Product Partial Sums
# ============================================================

def euler_product_partial(
    max_prime: int,
    valuation_min: int = 1
) -> List[Tuple[int, Fraction, float]]:
    """
    Compute partial products of the Euler product over increasing prime sets.

    For S_k = {p ≤ max_prime : p prime}, computes ∏_{p ∈ S_k} 1/p^k.

    Parameters
    ----------
    max_prime : int
        Include all primes up to this value
    valuation_min : int
        Common minimum valuation

    Returns
    -------
    list of (prime, partial_product, partial_energy)
    """
    def is_prime(n):
        if n < 2:
            return False
        for d in range(2, int(n ** 0.5) + 1):
            if n % d == 0:
                return False
        return True

    primes = [p for p in range(2, max_prime + 1) if is_prime(p)]
    results = []
    product = Fraction(1, 1)

    for p in primes:
        mass = compute_local_mass(p, valuation_min)
        product *= mass
        energy = -math.log(float(product)) if product > 0 else float('inf')
        results.append((p, product, energy))

    return results


if __name__ == "__main__":
    print("Algorithm Demonstrations")
    print("=" * 60)

    # Algorithm 1
    print("\n1. Local Mass Computation")
    print("-" * 40)
    for p in [2, 3, 5, 7]:
        m = compute_local_mass(p, 1)
        print(f"   localMass_{p}({p}ℤ_{p}) = {m}")

    # Algorithm 2
    print("\n2. Cylinder Measure (Euler Product)")
    print("-" * 40)
    constraints = {2: (1, 1), 3: (1, 1), 5: (1, 1)}
    mu = compute_cylinder_measure(constraints)
    print(f"   S = {{2,3,5}}, all v_p ≥ 1: μ = {mu}")

    constraints2 = {2: (3, 1), 3: (2, 1)}
    mu2 = compute_cylinder_measure(constraints2)
    print(f"   S = {{2,3}}, v_2 ≥ 3, v_3 ≥ 2: μ = {mu2}")

    # Algorithm 3
    print("\n3. Cylinder Energy")
    print("-" * 40)
    constraints = {2: (1, 1), 3: (1, 1), 5: (1, 1)}
    E = compute_cylinder_energy(constraints)
    local_E = compute_local_energies(constraints)
    print(f"   Total energy: {E:.6f}")
    print(f"   Sum of locals: {sum(local_E.values()):.6f}")
    print(f"   Additivity: {'✓' if abs(E - sum(local_E.values())) < 1e-14 else '✗'}")

    # Algorithm 4
    print("\n4. Residue Class Convergence (p=7)")
    print("-" * 40)
    for n, approx, exact in verify_convergence(7, 1, 6):
        print(f"   n={n}: {approx} {'(exact)' if exact else ''}")

    # Algorithm 5
    print("\n5. Euler Product Partial Sums (up to 29)")
    print("-" * 40)
    for p, prod, energy in euler_product_partial(29):
        print(f"   S up to {p:2d}: μ = {str(prod):>20s}  E = {energy:.4f}")
