#!/usr/bin/env python3
"""
Applications of the Cylinder Measure Formula
=============================================

Real-world applications demonstrating how the measure-theoretic Euler
product principle connects number theory, probability, and physics.
"""

from fractions import Fraction
from typing import List, Dict, Tuple
import math


def is_prime(n: int) -> bool:
    """Check if n is prime."""
    if n < 2:
        return False
    for d in range(2, int(n**0.5) + 1):
        if n % d == 0:
            return False
    return True


def primes_up_to(n: int) -> List[int]:
    """Return all primes ≤ n."""
    return [p for p in range(2, n + 1) if is_prime(p)]


# ============================================================
# Application 1: Adelic Density of Divisibility Conditions
# ============================================================

def adelic_density_divisible_by(m: int) -> Fraction:
    """
    Compute the adelic density of integers divisible by m.

    The "probability" that a random adelic integer satisfies
    v_p(x) ≥ v_p(m) for all primes p dividing m is exactly:

        ∏_{p | m} p^{-v_p(m)} = 1/m

    This gives the adelic interpretation of natural density.

    Parameters
    ----------
    m : int
        Positive integer

    Returns
    -------
    Fraction
        The adelic density = 1/m
    """
    if m <= 0:
        raise ValueError("m must be positive")

    result = Fraction(1, 1)
    temp = m
    p = 2
    while p * p <= temp:
        if temp % p == 0:
            k = 0
            while temp % p == 0:
                k += 1
                temp //= p
            result *= Fraction(1, p ** k)
        p += 1
    if temp > 1:
        result *= Fraction(1, temp)

    return result


def demonstrate_natural_density():
    """Show that adelic density matches classical natural density."""
    print("Application 1: Adelic Density = Natural Density")
    print("=" * 60)
    print()
    print("The cylinder measure formula gives the adelic density of")
    print("'integers divisible by m' as ∏_{p|m} 1/p^{v_p(m)} = 1/m.")
    print()
    print(f"  {'m':>6s}  {'Factorization':>20s}  {'Adelic Density':>15s}  {'= 1/m?':>8s}")
    print("  " + "-" * 55)

    test_values = [2, 3, 6, 12, 30, 60, 100, 360, 1000]
    for m in test_values:
        density = adelic_density_divisible_by(m)
        expected = Fraction(1, m)
        # Simple factorization display
        factors = []
        temp = m
        p = 2
        while p * p <= temp:
            if temp % p == 0:
                k = 0
                while temp % p == 0:
                    k += 1
                    temp //= p
                factors.append(f"{p}^{k}" if k > 1 else str(p))
            p += 1
        if temp > 1:
            factors.append(str(temp))
        fact_str = " × ".join(factors) if factors else str(m)

        print(f"  {m:6d}  {fact_str:>20s}  {str(density):>15s}  "
              f"{'✓' if density == expected else '✗':>8s}")
    print()


# ============================================================
# Application 2: Probability of Coprimality
# ============================================================

def prob_coprime_to_set(primes: List[int]) -> Fraction:
    """
    Compute the probability that x is coprime to all primes in a set.

    Under normalized Haar measure, P(v_p(x) = 0 for all p ∈ S) =
    ∏_{p ∈ S} (1 - 1/p).

    As S → {all primes}, this approaches 1/ζ(1) → 0, but for finite S
    it gives the fraction of integers not divisible by any p ∈ S.

    Parameters
    ----------
    primes : list of int
        Set of primes

    Returns
    -------
    Fraction
        Probability of coprimality to all given primes
    """
    result = Fraction(1, 1)
    for p in primes:
        result *= Fraction(p - 1, p)
    return result


def euler_product_zeta(max_prime: int) -> float:
    """
    Compute partial Euler product for ζ(s)^{-1} at s=1.

    ∏_{p ≤ N} (1 - 1/p) → 0 as N → ∞ (divergence of harmonic series),
    but for ζ(2):  ∏_p (1 - 1/p^2) = 6/π^2 ≈ 0.6079...

    Returns the partial product ∏_{p ≤ max_prime} (1 - 1/p^2).
    """
    result = 1.0
    for p in primes_up_to(max_prime):
        result *= (1 - 1 / p**2)
    return result


def demonstrate_coprimality():
    """Show coprimality probabilities via cylinder measures."""
    print("Application 2: Coprimality via Cylinder Measures")
    print("=" * 60)
    print()
    print("P(gcd(x, ∏S) = 1) = ∏_{p ∈ S} (1 - 1/p)")
    print("This is the complement of the cylinder: x_p ∉ pℤ_p for all p ∈ S.")
    print()

    for k in range(1, 8):
        S = primes_up_to(2 + 3 * k)
        prob = prob_coprime_to_set(S)
        print(f"  S = primes ≤ {2+3*k:2d}: "
              f"P(coprime) = {str(prob):>20s} = {float(prob):.6f}")

    print()
    print("Approach to 6/π² via Euler product for ζ(2):")
    target = 6 / math.pi**2
    print(f"  6/π² = {target:.8f}")
    for N in [10, 50, 100, 500, 1000]:
        val = euler_product_zeta(N)
        print(f"  ∏_{{p≤{N:4d}}} (1-1/p²) = {val:.8f}  "
              f"(error: {abs(val - target):.2e})")
    print()


# ============================================================
# Application 3: Tamagawa-style Volume Computation
# ============================================================

def tamagawa_volume_orthogonal(n: int, max_prime: int = 100) -> float:
    """
    Approximate Tamagawa volume for SO(n) using local densities.

    The Tamagawa number of SO(n) involves products of local densities
    at each prime. This computes a partial product approximation.

    For SO(n) with n ≥ 3, the local density at p is approximately:
        c_p(SO(n)) ≈ ∏_{k=1}^{⌊n/2⌋} (1 - p^{-2k})

    The Tamagawa number (global volume) is:
        τ(SO(n)) = ∏_p c_p(SO(n)) × (archimedean factor)

    Parameters
    ----------
    n : int
        Dimension of the orthogonal group
    max_prime : int
        Compute product over primes up to this bound

    Returns
    -------
    float
        Partial Tamagawa volume estimate
    """
    result = 1.0
    for p in primes_up_to(max_prime):
        local_factor = 1.0
        for k in range(1, n // 2 + 1):
            local_factor *= (1 - p ** (-2 * k))
        result *= local_factor
    return result


def demonstrate_tamagawa():
    """Show Tamagawa-style volume computations."""
    print("Application 3: Tamagawa Volume Approximation")
    print("=" * 60)
    print()
    print("Local density product for SO(n):")
    print("  τ_fin(SO(n)) ≈ ∏_{p prime} ∏_{k=1}^{⌊n/2⌋} (1 - p^{-2k})")
    print()

    for n in [3, 4, 5, 6, 8]:
        for N in [50, 200, 1000]:
            vol = tamagawa_volume_orthogonal(n, N)
            print(f"  SO({n}), primes ≤ {N:4d}: τ_fin ≈ {vol:.8f}")
        print()


# ============================================================
# Application 4: Information-Theoretic Entropy
# ============================================================

def adelic_entropy(primes: List[int], valuation_min: int = 1) -> float:
    """
    Compute the adelic entropy of a cylinder constraint.

    H(S) = -∑_{p ∈ S} log(localMass_p(A_p)) · localMass_p(A_p)
         = ∑_{p ∈ S} k·log(p)/p^k     (for A_p = p^k ℤ_p)

    This measures the "information content" of knowing that
    x_p ∈ p^k ℤ_p for each p ∈ S.

    Parameters
    ----------
    primes : list of int
        Support set S
    valuation_min : int
        Common minimum valuation k

    Returns
    -------
    float
        Shannon entropy of the cylinder partition
    """
    H = 0.0
    for p in primes:
        prob = 1.0 / p ** valuation_min
        if prob > 0:
            H -= prob * math.log(prob)
    return H


def demonstrate_entropy():
    """Show information-theoretic interpretation."""
    print("Application 4: Adelic Entropy")
    print("=" * 60)
    print()
    print("Shannon entropy of cylinder constraints:")
    print("  H(S) = -∑_{p ∈ S} (1/p) · log(1/p) = ∑_{p ∈ S} log(p)/p")
    print()

    for k in range(1, 8):
        S = primes_up_to(2 + 4 * k)
        H = adelic_entropy(S)
        print(f"  S = primes ≤ {2+4*k:2d} ({len(S):2d} primes): "
              f"H = {H:.6f} nats")

    print()
    print("Per-prime entropy contributions:")
    for p in primes_up_to(30):
        contrib = math.log(p) / p
        print(f"  p = {p:2d}: log(p)/p = {contrib:.6f}")
    print()


# ============================================================
# Application 5: Arithmetic Statistics
# ============================================================

def splitting_density(
    primes: List[int],
    split_type: Dict[int, str]
) -> Fraction:
    """
    Compute the density of primes with given splitting behavior.

    In a number field K/Q, each prime p has a splitting type
    (split, inert, ramified). The density of primes with a given
    pattern at finitely many places is a cylinder measure.

    For a quadratic field Q(√d):
      - p splits: local density (p-1)/(2p) if (d/p) = 1
      - p is inert: local density (p+1)/(2p) if (d/p) = -1
      - p ramifies: local density 1/p if p | d

    Parameters
    ----------
    primes : list of int
        Primes to constrain
    split_type : dict
        Maps prime -> 'split', 'inert', or 'ramified'

    Returns
    -------
    Fraction
        Product of local densities
    """
    result = Fraction(1, 1)
    for p in primes:
        st = split_type.get(p, 'split')
        if st == 'split':
            result *= Fraction(p - 1, 2 * p)
        elif st == 'inert':
            result *= Fraction(p + 1, 2 * p)
        elif st == 'ramified':
            result *= Fraction(1, p)
    return result


def demonstrate_arithmetic_statistics():
    """Show arithmetic statistics application."""
    print("Application 5: Arithmetic Statistics")
    print("=" * 60)
    print()
    print("Splitting densities in Q(√-1):")
    print("  p splits iff p ≡ 1 (mod 4), local density = (p-1)/(2p)")
    print("  p is inert iff p ≡ 3 (mod 4), local density = (p+1)/(2p)")
    print("  p = 2 ramifies, local density = 1/2")
    print()

    # For Q(√-1), 2 ramifies, p≡1(4) split, p≡3(4) inert
    primes = [2, 3, 5, 7, 11, 13]
    split = {}
    for p in primes:
        if p == 2:
            split[p] = 'ramified'
        elif p % 4 == 1:
            split[p] = 'split'
        else:
            split[p] = 'inert'

    for k in range(1, len(primes) + 1):
        S = primes[:k]
        st = {p: split[p] for p in S}
        density = splitting_density(S, st)
        desc = ", ".join(f"{p}:{split[p][:3]}" for p in S)
        print(f"  S = {{{desc}}}")
        print(f"    density = {density} = {float(density):.8f}")
    print()


if __name__ == "__main__":
    demonstrate_natural_density()
    demonstrate_coprimality()
    demonstrate_tamagawa()
    demonstrate_entropy()
    demonstrate_arithmetic_statistics()
    print("=" * 60)
    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Cylinder Measure Formula: Interactive Demo
==========================================
Demonstrates the measure-theoretic Euler product principle for restricted products.

For a finite set of primes S, computes:
  μ(cylinder) = ∏_{p ∈ S} localMass_p(A_p)

In the p-adic case with A_p = pℤ_p ⊆ ℤ_p:
  localMass_p(pℤ_p) = μ_p(pℤ_p) / μ_p(ℤ_p) = 1/p

So the cylinder measure equals ∏_{p ∈ S} 1/p.
"""

from fractions import Fraction
from typing import List, Dict
import math


def local_mass_padic(p: int, valuation_min: int = 1) -> Fraction:
    """
    Compute the local normalized mass of {x ∈ ℚ_p : v_p(x) ≥ valuation_min}
    relative to ℤ_p = {x ∈ ℚ_p : v_p(x) ≥ 0}.

    The set p^k ℤ_p has measure p^{-k} relative to ℤ_p.

    Parameters
    ----------
    p : int
        A prime number
    valuation_min : int
        Minimum p-adic valuation (default 1, giving pℤ_p)

    Returns
    -------
    Fraction
        The local mass μ_p(p^k ℤ_p) / μ_p(ℤ_p) = 1/p^k
    """
    if valuation_min < 0:
        raise ValueError("For subsets of ℤ_p, valuation_min must be ≥ 0")
    return Fraction(1, p ** valuation_min)


def cylinder_measure(primes: List[int], valuations: Dict[int, int] = None) -> Fraction:
    """
    Compute the cylinder measure for a finite set of primes.

    Parameters
    ----------
    primes : list of int
        Finite set S of prime numbers
    valuations : dict, optional
        Map p -> minimum valuation (default: all 1, giving pℤ_p constraints)

    Returns
    -------
    Fraction
        The product ∏_{p ∈ S} localMass_p(A_p)
    """
    if valuations is None:
        valuations = {p: 1 for p in primes}

    result = Fraction(1, 1)
    for p in primes:
        k = valuations.get(p, 0)
        result *= local_mass_padic(p, k)
    return result


def residue_class_approximation(p: int, n: int, valuation_min: int = 1) -> Fraction:
    """
    Approximate the local p-adic mass using residue class counting.

    μ_p(p^k ℤ_p) / μ_p(ℤ_p) ≈ |p^k ℤ_p / p^n ℤ_p| / |ℤ_p / p^n ℤ_p|
                                = p^{n-k} / p^n = 1/p^k

    Parameters
    ----------
    p : int
        Prime
    n : int
        Precision level (number of residue classes)
    valuation_min : int
        Minimum valuation

    Returns
    -------
    Fraction
        Approximation via residue class counting
    """
    if n < valuation_min:
        return Fraction(0, 1)
    numerator = p ** (n - valuation_min)
    denominator = p ** n
    return Fraction(numerator, denominator)


def demonstrate_euler_product():
    """Main demonstration of the cylinder measure formula."""
    print("=" * 70)
    print("CYLINDER MEASURE FORMULA — EULER PRODUCT DEMONSTRATION")
    print("=" * 70)
    print()

    # Example 1: Single prime
    print("Example 1: Single prime p = 2")
    print("-" * 40)
    p = 2
    mass = local_mass_padic(p)
    print(f"  localMass_2(2ℤ_2) = μ(2ℤ_2) / μ(ℤ_2) = {mass} = {float(mass):.6f}")
    print()

    # Example 2: Product over {2, 3, 5}
    print("Example 2: Primes S = {2, 3, 5}")
    print("-" * 40)
    S = [2, 3, 5]
    mu = cylinder_measure(S)
    print(f"  μ(cylinder) = ∏_{{p ∈ S}} 1/p = {mu} = {float(mu):.6f}")
    print(f"  Individual factors: ", end="")
    for p in S:
        print(f"1/{p}", end="  ")
    print()
    print(f"  Product: {' × '.join(f'1/{p}' for p in S)} = {mu}")
    print()

    # Example 3: Residue class verification
    print("Example 3: Residue Class Approximation Convergence")
    print("-" * 40)
    p = 5
    exact = local_mass_padic(p)
    print(f"  Target: localMass_5(5ℤ_5) = {exact}")
    print(f"  {'n':>4s}  {'|5ℤ_5/5^n ℤ_5|':>16s}  {'|ℤ_5/5^n ℤ_5|':>14s}  {'Ratio':>10s}  {'Exact?':>8s}")
    for n in range(1, 7):
        approx = residue_class_approximation(p, n)
        num = p ** (n - 1)
        den = p ** n
        print(f"  {n:4d}  {num:16d}  {den:14d}  {float(approx):10.6f}  {'✓' if approx == exact else '✗':>8s}")
    print()

    # Example 4: First 10 primes
    print("Example 4: Product over first k primes")
    print("-" * 40)
    all_primes = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29]
    print(f"  {'k':>3s}  {'S':>30s}  {'∏ 1/p':>20s}  {'Value':>12s}  {'Energy':>10s}")
    for k in range(1, len(all_primes) + 1):
        S = all_primes[:k]
        mu = cylinder_measure(S)
        energy = -math.log(float(mu)) if float(mu) > 0 else float('inf')
        S_str = str(S) if k <= 5 else f"[2,...,{S[-1]}]"
        print(f"  {k:3d}  {S_str:>30s}  {str(mu):>20s}  {float(mu):12.8f}  {energy:10.4f}")
    print()

    # Example 5: Higher valuation constraints
    print("Example 5: Higher valuation constraints")
    print("-" * 40)
    print("  Constraint: x_p ∈ p^k ℤ_p for various k")
    p = 3
    print(f"  p = {p}")
    for k in range(0, 5):
        mass = local_mass_padic(p, k)
        print(f"    k = {k}: localMass(p^{k}ℤ_p) = {mass} = {float(mass):.6f}")
    print()

    # Example 6: Energy additivity
    print("Example 6: Energy Additivity (Statistical Mechanics Bridge)")
    print("-" * 40)
    S = [2, 3, 5, 7]
    mu = cylinder_measure(S)
    total_energy = -math.log(float(mu))
    print(f"  S = {S}")
    print(f"  Total energy: -log(μ(cylinder)) = {total_energy:.6f}")
    local_energies = [-math.log(float(local_mass_padic(p))) for p in S]
    print(f"  Sum of local energies: ∑ -log(1/p) = {sum(local_energies):.6f}")
    print(f"  Difference: {abs(total_energy - sum(local_energies)):.2e}")
    print(f"  Additivity verified: {'✓' if abs(total_energy - sum(local_energies)) < 1e-14 else '✗'}")
    for p, e in zip(S, local_energies):
        print(f"    -log(1/{p}) = log({p}) = {e:.6f}")
    print()

    # Example 7: Mixed constraints
    print("Example 7: Mixed valuation constraints")
    print("-" * 40)
    constraints = {2: 3, 3: 2, 5: 1}
    S = list(constraints.keys())
    mu = cylinder_measure(S, constraints)
    print(f"  Constraints: " + ", ".join(f"v_{p}(x) ≥ {k}" for p, k in constraints.items()))
    print(f"  μ(cylinder) = " + " × ".join(f"1/{p}^{k}" for p, k in constraints.items())
          + f" = {mu} = {float(mu):.8f}")


def demonstrate_independence():
    """Demonstrate finite coordinate independence."""
    print()
    print("=" * 70)
    print("FINITE COORDINATE INDEPENDENCE")
    print("=" * 70)
    print()
    print("Under normalized Haar measure on the restricted product:")
    print("  P(∀ i ∈ S, x_i ∈ A_i) = ∏ i ∈ S, P(x_i ∈ A_i)")
    print()
    print("This is exact independence of finite-coordinate events.")
    print()

    S = [2, 3, 5]
    joint = cylinder_measure(S)
    marginals = [local_mass_padic(p) for p in S]
    product = Fraction(1, 1)
    for m in marginals:
        product *= m

    print(f"  S = {S}")
    print(f"  Joint probability: P(x_2 ∈ 2ℤ_2, x_3 ∈ 3ℤ_3, x_5 ∈ 5ℤ_5) = {joint}")
    print(f"  Product of marginals: P(x_2 ∈ 2ℤ_2) × P(x_3 ∈ 3ℤ_3) × P(x_5 ∈ 5ℤ_5)")
    print(f"    = {marginals[0]} × {marginals[1]} × {marginals[2]} = {product}")
    print(f"  Independence: {'✓ Exact equality' if joint == product else '✗ Not equal'}")


if __name__ == "__main__":
    demonstrate_euler_product()
    demonstrate_independence()
    print()
    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
