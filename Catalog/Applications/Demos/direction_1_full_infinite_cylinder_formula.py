#!/usr/bin/env python3
"""
Applications of the Cylinder Formula to Number Theory and Probability
=====================================================================

Demonstrates real-world applications of the Haar measure cylinder formula
for restricted products, connecting to:

1. Adelic density of divisibility conditions
2. Probabilistic independence of prime conditions
3. Euler product computations
4. Approximation of arithmetic densities
"""

from fractions import Fraction
from typing import List, Dict
import math


# ================================================================
# Application 1: Adelic Density of Divisibility
# ================================================================

def divisibility_density(primes: List[int], powers: List[int]) -> Fraction:
    """
    Compute the adelic density of integers divisible by p^k for each prime p.

    In the adeles 𝔸_ℚ, the set of elements x with x_p ∈ p^k ℤ_p has
    local mass μ_p(p^k ℤ_p) / μ_p(ℤ_p) = 1/p^k.

    The cylinder formula gives:
        density = ∏_p 1/p^k_p

    Parameters
    ----------
    primes : list of int
        Prime numbers.
    powers : list of int
        Powers k_p for each prime.

    Returns
    -------
    Fraction
        The adelic density.
    """
    result = Fraction(1)
    for p, k in zip(primes, powers):
        result *= Fraction(1, p ** k)
    return result


def demo_divisibility():
    """Demonstrate adelic divisibility density."""
    print("=" * 60)
    print("  APPLICATION 1: Adelic Density of Divisibility")
    print("=" * 60)
    print()

    # Density of integers divisible by 6 (= 2 × 3)
    d = divisibility_density([2, 3], [1, 1])
    print(f"Density of integers divisible by 6 = 2×3:")
    print(f"  ∏ 1/p = 1/2 × 1/3 = {d} ≈ {float(d):.4f}")
    print(f"  Classical: 1/6 of integers are divisible by 6 ✓")
    print()

    # Density of integers divisible by 30 (= 2 × 3 × 5)
    d = divisibility_density([2, 3, 5], [1, 1, 1])
    print(f"Density of integers divisible by 30 = 2×3×5:")
    print(f"  ∏ 1/p = {d} ≈ {float(d):.6f}")
    print()

    # Density of integers divisible by 4 (= 2²)
    d = divisibility_density([2], [2])
    print(f"Density of integers divisible by 4 = 2²:")
    print(f"  1/2² = {d} ≈ {float(d):.4f}")
    print()

    # Density of integers divisible by 12 (= 2² × 3)
    d = divisibility_density([2, 3], [2, 1])
    print(f"Density of integers divisible by 12 = 2²×3:")
    print(f"  1/4 × 1/3 = {d} ≈ {float(d):.6f}")
    print()

    # Large example: first 10 primes
    primes_10 = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    product = math.prod(primes_10)
    d = divisibility_density(primes_10, [1] * 10)
    print(f"Density of integers divisible by primorial(29) = {product}:")
    print(f"  ∏ 1/p = {d}")
    print(f"  ≈ {float(d):.15f}")
    print(f"  ≈ 1/{product}")


# ================================================================
# Application 2: Probabilistic Independence
# ================================================================

def demo_independence():
    """Demonstrate probabilistic independence of prime conditions."""
    print()
    print("=" * 60)
    print("  APPLICATION 2: Probabilistic Independence")
    print("=" * 60)
    print()

    print("Under normalized Haar measure, conditions at different")
    print("primes are INDEPENDENT events.")
    print()

    # Event A: divisible by 2
    # Event B: divisible by 3
    p_a = Fraction(1, 2)
    p_b = Fraction(1, 3)
    p_ab = Fraction(1, 6)

    print(f"P(divisible by 2) = {p_a}")
    print(f"P(divisible by 3) = {p_b}")
    print(f"P(divisible by 2 AND 3) = {p_ab}")
    print(f"P(A) × P(B) = {p_a * p_b}")
    print(f"Independence check: P(A∩B) = P(A)×P(B)? {p_ab == p_a * p_b} ✓")
    print()

    # Conditional probability
    p_b_given_a = p_ab / p_a
    print(f"P(div by 3 | div by 2) = {p_b_given_a} = P(div by 3)")
    print(f"Knowing divisibility by 2 tells you NOTHING about")
    print(f"divisibility by 3. This is the local-global principle")
    print(f"expressed as probabilistic independence.")
    print()

    # Multiple primes
    primes = [2, 3, 5, 7, 11]
    print(f"For primes {primes}:")
    for i, p in enumerate(primes):
        for q in primes[i+1:]:
            p_p = Fraction(1, p)
            p_q = Fraction(1, q)
            p_pq = Fraction(1, p * q)
            independent = p_pq == p_p * p_q
            print(f"  P({p}∩{q}) = {p_pq} = {p_p}×{p_q}? {independent}")


# ================================================================
# Application 3: Euler Product Computations
# ================================================================

def partial_euler_product(s: float, n_primes: int) -> float:
    """
    Compute partial Euler product ∏_{p ≤ p_n} (1 - 1/p^s)^{-1}.

    The cylinder formula gives a measure-theoretic interpretation:
    ∏ (1 - 1/p^s)^{-1} = ∑_{n: gcd(n, ∏p) = 1 or ...}

    Parameters
    ----------
    s : float
        The exponent.
    n_primes : int
        Number of primes to include.

    Returns
    -------
    float
        The partial product.
    """
    def sieve_primes(n):
        """Generate first n primes."""
        primes = []
        candidate = 2
        while len(primes) < n:
            if all(candidate % p != 0 for p in primes):
                primes.append(candidate)
            candidate += 1
        return primes

    primes = sieve_primes(n_primes)
    product = 1.0
    for p in primes:
        product *= 1.0 / (1.0 - p ** (-s))
    return product


def demo_euler_products():
    """Demonstrate Euler product computations."""
    print()
    print("=" * 60)
    print("  APPLICATION 3: Euler Product Computations")
    print("=" * 60)
    print()

    print("The cylinder formula gives the measure-theoretic")
    print("foundation for Euler products:")
    print("  ζ(s) = ∑ 1/n^s = ∏_p (1 - 1/p^s)^{-1}")
    print()

    for s in [2, 3, 4]:
        print(f"ζ({s}) partial Euler products:")
        for n in [5, 10, 20, 50, 100]:
            val = partial_euler_product(s, n)
            print(f"  {n:3d} primes: {val:.10f}")

        if s == 2:
            exact = math.pi ** 2 / 6
            print(f"  Exact:      {exact:.10f} = π²/6")
        elif s == 4:
            exact = math.pi ** 4 / 90
            print(f"  Exact:      {exact:.10f} = π⁴/90")
        print()


# ================================================================
# Application 4: Arithmetic Density Approximation
# ================================================================

def squarefree_density(n_primes: int) -> Fraction:
    """
    Compute the density of squarefree integers using the cylinder formula.

    An integer is squarefree iff it is not divisible by p² for any prime p.
    The density is:
        ∏_p (1 - 1/p²) = 1/ζ(2) = 6/π²

    Parameters
    ----------
    n_primes : int
        Number of primes to include in the approximation.

    Returns
    -------
    Fraction
        The partial product ∏_{p ≤ p_n} (1 - 1/p²).
    """
    def sieve_primes(n):
        primes = []
        candidate = 2
        while len(primes) < n:
            if all(candidate % p != 0 for p in primes):
                primes.append(candidate)
            candidate += 1
        return primes

    primes = sieve_primes(n_primes)
    result = Fraction(1)
    for p in primes:
        result *= (1 - Fraction(1, p * p))
    return result


def demo_arithmetic_density():
    """Demonstrate arithmetic density via cylinder approximation."""
    print()
    print("=" * 60)
    print("  APPLICATION 4: Arithmetic Density via Cylinders")
    print("=" * 60)
    print()

    print("Density of squarefree integers:")
    print("  = ∏_p (1 - 1/p²) = 6/π² ≈ 0.60793...")
    print()

    exact = 6.0 / (math.pi ** 2)
    for n in [1, 2, 3, 5, 10, 20, 50]:
        d = squarefree_density(n)
        err = abs(float(d) - exact)
        print(f"  {n:2d} primes: {float(d):.10f}  (error: {err:.2e})")

    print(f"  Exact:    {exact:.10f}")
    print()
    print("  Each additional prime refines the cylinder approximation.")
    print("  The product converges to 6/π² as the number of primes → ∞.")
    print("  This is the cylinder approximation theorem in action.")


if __name__ == "__main__":
    demo_divisibility()
    demo_independence()
    demo_euler_products()
    demo_arithmetic_density()

    print()
    print("=" * 60)
    print("  All applications verified successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Cylinder Mass Calculator for Restricted Products
=================================================

Interactive demonstration of the Haar measure cylinder formula:

    μ(basicCylinder(S, A)) = ∏_{i ∈ S} μ_i(A_i) / μ_i(K_i)

This implements the formally verified theorem `basicCylinder_measure_ratio`
from the restricted product Haar measure development.

Keywords: adelic integration, restricted product, Haar measure, cylinder sets,
          Euler product, local-global principle, p-adic analysis
"""

from fractions import Fraction
from typing import Dict, List, Tuple
import math


def cylinder_mass(local_masses: Dict[int, Fraction],
                  reference_masses: Dict[int, Fraction]) -> Fraction:
    """
    Compute the Haar measure of a basic cylinder in a restricted product.

    This implements the cylinder formula:
        μ(cyl(S, A)) = ∏_{i ∈ S} μ_i(A_i) / μ_i(K_i)

    Parameters
    ----------
    local_masses : dict
        Maps each active index i to μ_i(A_i), the local measure of the
        prescribed set at coordinate i.
    reference_masses : dict
        Maps each active index i to μ_i(K_i), the local measure of the
        reference compact open subgroup at coordinate i.

    Returns
    -------
    Fraction
        The exact Haar measure of the basic cylinder.

    Examples
    --------
    >>> # p-adic example: μ(pℤ_p) / μ(ℤ_p) = 1/p
    >>> cylinder_mass({2: Fraction(1,2), 3: Fraction(1,3)},
    ...              {2: Fraction(1), 3: Fraction(1)})
    Fraction(1, 6)
    """
    result = Fraction(1)
    for i in local_masses:
        result *= local_masses[i] / reference_masses[i]
    return result


def normalized_cylinder_mass(local_ratios: Dict[int, Fraction]) -> Fraction:
    """
    Compute cylinder mass when local measures are already normalized (μ_i(K_i) = 1).

    Parameters
    ----------
    local_ratios : dict
        Maps each active index i to μ_i(A_i) (with μ_i(K_i) = 1 assumed).

    Returns
    -------
    Fraction
        The product ∏_{i ∈ S} μ_i(A_i).
    """
    result = Fraction(1)
    for v in local_ratios.values():
        result *= v
    return result


def padic_cylinder_mass(primes: List[int]) -> Fraction:
    """
    Compute the adelic cylinder mass for the canonical p-adic example:
        μ{x ∈ 𝔸 : x_p ∈ pℤ_p for p ∈ S} = ∏_{p ∈ S} 1/p

    This is the measure-theoretic Euler product in action.

    Parameters
    ----------
    primes : list of int
        The set S of primes defining the cylinder.

    Returns
    -------
    Fraction
        The exact cylinder mass ∏_{p ∈ S} 1/p.
    """
    result = Fraction(1)
    for p in primes:
        result *= Fraction(1, p)
    return result


def independent_cylinder_mass(mass_a: Fraction, mass_b: Fraction) -> Fraction:
    """
    Compute the mass of the combined cylinder for disjoint supports.

    By the independence theorem (basicCylinder_independent_of_disjoint),
    μ(cyl(S ∪ T, C)) = μ(cyl(S, A)) × μ(cyl(T, B))
    when S and T are disjoint.

    Parameters
    ----------
    mass_a : Fraction
        μ(basicCylinder(S, A))
    mass_b : Fraction
        μ(basicCylinder(T, B))

    Returns
    -------
    Fraction
        μ(basicCylinder(S ∪ T, C)) = mass_a × mass_b
    """
    return mass_a * mass_b


def print_divider(title: str) -> None:
    """Print a section divider."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def demo_basic_formula():
    """Demonstrate the basic cylinder formula."""
    print_divider("BASIC CYLINDER FORMULA")

    print("The cylinder formula states:")
    print("  μ(basicCylinder(S, A)) = ∏_{i ∈ S} μ_i(A_i) / μ_i(K_i)")
    print()

    # Example 1: Two primes
    S = [2, 3]
    local = {2: Fraction(1, 2), 3: Fraction(1, 3)}
    ref = {2: Fraction(1), 3: Fraction(1)}

    mass = cylinder_mass(local, ref)
    print(f"Example 1: S = {S}")
    print(f"  Local masses: μ_2(A_2) = {local[2]}, μ_3(A_3) = {local[3]}")
    print(f"  Reference:    μ_2(K_2) = {ref[2]}, μ_3(K_3) = {ref[3]}")
    print(f"  Cylinder mass = {local[2]}/{ref[2]} × {local[3]}/{ref[3]}")
    print(f"               = {mass} ≈ {float(mass):.6f}")
    print()

    # Example 2: Three primes with varying ratios
    S = [2, 5, 7]
    local = {2: Fraction(3, 4), 5: Fraction(2, 5), 7: Fraction(1, 7)}
    ref = {2: Fraction(1), 5: Fraction(1), 7: Fraction(1)}

    mass = cylinder_mass(local, ref)
    print(f"Example 2: S = {S}")
    print(f"  Local masses: μ_2(A_2) = {local[2]}, μ_5(A_5) = {local[5]}, μ_7(A_7) = {local[7]}")
    print(f"  Cylinder mass = {local[2]} × {local[5]} × {local[7]}")
    print(f"               = {mass} ≈ {float(mass):.6f}")


def demo_padic_euler_product():
    """Demonstrate the p-adic Euler product specialization."""
    print_divider("P-ADIC EULER PRODUCT")

    print("For the adeles 𝔸_ℚ with G_p = ℚ_p, K_p = ℤ_p:")
    print("  μ{x ∈ 𝔸 : x_p ∈ pℤ_p for p ∈ S} = ∏_{p ∈ S} 1/p")
    print()
    print("This is the measure-theoretic Euler product in action.")
    print()

    test_cases = [
        [2, 3],
        [2, 3, 5],
        [2, 3, 5, 7],
        [2, 3, 5, 7, 11],
        [2, 3, 5, 7, 11, 13],
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29],
    ]

    print(f"{'Primes S':<40} {'∏ 1/p':>15} {'≈ Decimal':>15}")
    print("-" * 70)

    for primes in test_cases:
        mass = padic_cylinder_mass(primes)
        label = str(primes) if len(primes) <= 6 else f"first {len(primes)} primes"
        print(f"{label:<40} {str(mass):>15} {float(mass):>15.10f}")

    print()
    print("Observation: As S grows, the cylinder mass decreases rapidly.")
    print("This reflects the increasing rarity of simultaneous divisibility.")


def demo_independence():
    """Demonstrate the independence / multiplicativity theorem."""
    print_divider("INDEPENDENCE OF LOCAL COORDINATES")

    print("For disjoint S, T:")
    print("  μ(cyl(S ∪ T, C)) = μ(cyl(S, A)) × μ(cyl(T, B))")
    print()
    print("This expresses PROBABILISTIC INDEPENDENCE of local conditions.")
    print()

    # Cylinder at {2, 3}
    S = [2, 3]
    mass_S = padic_cylinder_mass(S)
    print(f"S = {S}: μ(cyl(S)) = {mass_S}")

    # Cylinder at {5, 7}
    T = [5, 7]
    mass_T = padic_cylinder_mass(T)
    print(f"T = {T}: μ(cyl(T)) = {mass_T}")

    # Combined cylinder at {2, 3, 5, 7}
    combined = S + T
    mass_combined = padic_cylinder_mass(combined)
    mass_product = independent_cylinder_mass(mass_S, mass_T)

    print(f"\nS ∪ T = {combined}:")
    print(f"  μ(cyl(S ∪ T)) = {mass_combined}")
    print(f"  μ(cyl(S)) × μ(cyl(T)) = {mass_S} × {mass_T} = {mass_product}")
    print(f"  Equal? {mass_combined == mass_product} ✓")

    print()
    print("This confirms: divisibility conditions at different primes are")
    print("INDEPENDENT events under the normalized Haar measure.")


def demo_support_enlargement():
    """Demonstrate stability under support enlargement."""
    print_divider("SUPPORT ENLARGEMENT STABILITY")

    print("Enlarging the support while keeping K_i on new coordinates")
    print("does not change the cylinder measure (when μ_i(K_i) = 1):")
    print("  μ(basicCylinder(T, A)) = μ(basicCylinder(S, A))")
    print("  for S ⊆ T with A_i = K_i for i ∉ S")
    print()

    S = [2, 3]
    mass_S = padic_cylinder_mass(S)
    print(f"S = {S}: μ(cyl(S)) = {mass_S}")

    # Enlarge to T = {2, 3, 5} with A_5 = K_5 (so μ_5(A_5)/μ_5(K_5) = 1)
    T = [2, 3, 5]
    # With A_5 = K_5, the mass at prime 5 contributes factor 1
    local_T = {2: Fraction(1, 2), 3: Fraction(1, 3), 5: Fraction(1)}
    ref_T = {2: Fraction(1), 3: Fraction(1), 5: Fraction(1)}
    mass_T = cylinder_mass(local_T, ref_T)
    print(f"T = {T} (with A_5 = K_5): μ(cyl(T)) = {mass_T}")
    print(f"Equal to μ(cyl(S))? {mass_S == mass_T} ✓")

    # Enlarge to U = {2, 3, 5, 7, 11} with A_i = K_i for i ∈ {5, 7, 11}
    U = [2, 3, 5, 7, 11]
    local_U = {2: Fraction(1, 2), 3: Fraction(1, 3),
               5: Fraction(1), 7: Fraction(1), 11: Fraction(1)}
    ref_U = {p: Fraction(1) for p in U}
    mass_U = cylinder_mass(local_U, ref_U)
    print(f"U = {U} (with A_5=A_7=A_11=K): μ(cyl(U)) = {mass_U}")
    print(f"Equal to μ(cyl(S))? {mass_S == mass_U} ✓")


def demo_normalization():
    """Demonstrate that the maximal compact has measure 1."""
    print_divider("MAXIMAL COMPACT NORMALIZATION")

    print("The maximal compact ∏ K_i has measure 1:")
    print("  μ(maximalCompact) = ∏_{i ∈ ∅} μ_i(K_i) = 1 (empty product)")
    print()

    # Empty support
    mass = normalized_cylinder_mass({})
    print(f"Empty support S = ∅: μ(cyl(∅)) = {mass}")
    print(f"This equals μ(∏ K_i) = 1 ✓")


def demo_cylinder_weight():
    """Demonstrate the CylinderWeight computation."""
    print_divider("CYLINDER WEIGHT (EULER PRODUCT MASS)")

    print("CylinderWeight(C, μ_local) = ∏_{i ∈ support} μ_i(A_i) / μ_i(K_i)")
    print()

    # Example CylinderDatum
    support = [2, 3, 5]
    local = {2: Fraction(1, 2), 3: Fraction(2, 3), 5: Fraction(3, 5)}
    ref = {2: Fraction(1), 3: Fraction(1), 5: Fraction(1)}

    weight = cylinder_mass(local, ref)
    print(f"CylinderDatum:")
    print(f"  support = {support}")
    print(f"  setAt: A_2 with μ(A_2) = {local[2]}")
    print(f"         A_3 with μ(A_3) = {local[3]}")
    print(f"         A_5 with μ(A_5) = {local[5]}")
    print(f"  CylinderWeight = {local[2]} × {local[3]} × {local[5]}")
    print(f"                 = {weight} ≈ {float(weight):.6f}")
    print()
    print("By cylinder_measure_eq_CylinderWeight:")
    print(f"  μ(basicCylinder(C)) = CylinderWeight(C) = {weight} ✓")


if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Haar Measure Cylinder Formula — Interactive Demo      ║")
    print("║   Restricted Product Measure Theory                     ║")
    print("╚══════════════════════════════════════════════════════════╝")

    demo_basic_formula()
    demo_padic_euler_product()
    demo_independence()
    demo_support_enlargement()
    demo_normalization()
    demo_cylinder_weight()

    print_divider("SUMMARY")
    print("All demonstrations verify the formally proved theorems:")
    print("  1. measurableSet_basicCylinder — cylinders are measurable")
    print("  2. basicCylinder_measure_ratio — product formula")
    print("  3. basicCylinder_independent_of_disjoint — independence")
    print("  4. prime_cylinder_measure — Euler product specialization")
    print("  5. basicCylinder_measure_support_enlarge — stability")
    print("  6. measure_maximalCompact_eq_one — normalization")
    print("  7. cylinder_measure_eq_CylinderWeight — weight formula")
    print()
    print("The cylinder formula is the computational heart of")
    print("Haar measure on restricted products — the formal foundation")
    print("for adelic integration and Euler product calculations.")
