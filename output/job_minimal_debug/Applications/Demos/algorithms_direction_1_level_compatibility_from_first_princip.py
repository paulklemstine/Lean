#!/usr/bin/env python3
"""
algorithms.py — Verified algorithms for computing Haar measures on restricted products

Implements the Euler product algorithm for computing Haar measures on cylinder sets
of restricted products, with correctness guaranteed by the formalized theorem
`euler_haar_identity_finite`.

Algorithm 1: euler_product_cylinder
    Given a cylinder set specification, computes μ(C) = ∏_{i ∈ s} μ_i(C_i).
    Time complexity: O(|s|), where s is the finite support of the cylinder.
    Space complexity: O(|s|).

Algorithm 2: adelic_measure
    Specialized to Q_p: computes μ(C) for cylinders in A_Q.
    Uses the normalization μ_p(Z_p) = 1, giving μ_p(a + p^n Z_p) = p^{-n}.

Algorithm 3: haar_measure_normalize
    Given a raw Haar measure μ and a compact open set K, computes the
    normalized measure μ' = μ(K)^{-1} · μ.
"""

from fractions import Fraction
from typing import Dict, List, Optional, Tuple, Callable
from dataclasses import dataclass


# ============================================================
# Algorithm 1: General Euler Product on Cylinder Sets
# ============================================================

@dataclass
class LocalMeasure:
    """A local measure μ_i on a group G_i, represented by a function
    that maps subset descriptions to their measures.

    In practice, subsets are described by parameters (e.g., coset + exponent
    for p-adic balls).
    """
    name: str
    measure_fn: Callable[..., Fraction]
    normalizing_set_measure: Fraction = Fraction(1)


@dataclass
class CylinderSpec:
    """Specification of a basic cylinder set in a restricted product.

    support: set of indices where the cylinder differs from K_i
    component_specs: for each i in support, the specification of C_i
    """
    support: List[int]
    component_specs: Dict[int, tuple]  # index -> parameters for local measure


def euler_product_cylinder(
    local_measures: Dict[int, LocalMeasure],
    cylinder: CylinderSpec
) -> Fraction:
    """Compute the Haar measure of a cylinder set via the Euler product.

    Algorithm:
        μ(C) = ∏_{i ∈ support} μ_i(C_i)

    where C_i = K_i for i ∉ support (contributing factor 1 to the product).

    Correctness: Guaranteed by Theorem `level_compatible_automatic_finite`:
        (Measure.pi μ) (Set.univ.pi A) = ∏ i ∈ s, μ i (A i)
    when μ_i(K_i) = 1 for all i and A_i = K_i for i ∉ s.

    Args:
        local_measures: dictionary mapping index i to local measure μ_i
        cylinder: specification of the cylinder set

    Returns:
        Fraction representing μ(C)

    Raises:
        KeyError: if a required local measure is missing

    Time complexity: O(|support|)
    Space complexity: O(1) beyond input
    """
    result = Fraction(1)
    for i in cylinder.support:
        if i not in local_measures:
            raise KeyError(f"No local measure defined for index {i}")
        mu_i = local_measures[i]
        spec = cylinder.component_specs[i]
        result *= mu_i.measure_fn(*spec)
    return result


# ============================================================
# Algorithm 2: Adelic Measure (specialized to Q)
# ============================================================

def padic_haar_measure(p: int, center: int, exponent: int) -> Fraction:
    """Haar measure of the p-adic ball center + p^exponent Z_p.

    Under normalization μ_p(Z_p) = 1:
        μ_p(a + p^n Z_p) = p^{-n}

    This follows from translation invariance (μ_p is left-invariant)
    and the fact that Z_p = ⊔_{a=0}^{p^n-1} (a + p^n Z_p).

    Args:
        p: prime number
        center: center of the ball (irrelevant for the measure)
        exponent: p-adic exponent (n ≥ 0)

    Returns:
        Fraction p^{-exponent}
    """
    return Fraction(1, p ** exponent)


def real_haar_measure(a: float, b: float) -> Fraction:
    """Haar measure (Lebesgue measure) of the interval [a, b].

    Args:
        a: left endpoint
        b: right endpoint

    Returns:
        Fraction representing b - a
    """
    return Fraction(b - a).limit_denominator(10**15)


def adelic_measure(
    real_interval: Tuple[float, float],
    padic_specs: Dict[int, Tuple[int, int]]
) -> Fraction:
    """Compute the Haar measure of an adelic cylinder set.

    The cylinder is [a, b] × ∏_{p ∈ S} (c_p + p^{n_p} Z_p) × ∏_{p ∉ S} Z_p.

    Algorithm:
        μ(C) = (b - a) × ∏_{p ∈ S} p^{-n_p}

    Correctness: By `euler_haar_identity_finite`, this equals the Haar
    measure on A_Q normalized at Z_hat × [0,1].

    Args:
        real_interval: (a, b) for the archimedean component
        padic_specs: dict mapping prime p to (center, exponent)

    Returns:
        Fraction representing μ(C)

    Example:
        >>> adelic_measure((0, 1), {2: (0, 1), 3: (0, 1)})
        Fraction(1, 6)
    """
    a, b = real_interval
    result = real_haar_measure(a, b)

    for p, (center, exponent) in padic_specs.items():
        result *= padic_haar_measure(p, center, exponent)

    return result


# ============================================================
# Algorithm 3: Haar Measure Normalization
# ============================================================

def normalize_haar(
    raw_measure: Callable[..., Fraction],
    normalizing_value: Fraction
) -> Callable[..., Fraction]:
    """Normalize a Haar measure so that a designated set has measure 1.

    Given a raw Haar measure μ with μ(K) = c ≠ 0, returns the
    normalized measure μ' = c^{-1} · μ.

    By Theorem `level_compatible_from_uniqueness`, the normalized
    measure is unique: any other Haar measure with μ'(K) = 1 must
    equal this one.

    Args:
        raw_measure: function computing the raw Haar measure
        normalizing_value: μ(K), the measure of the normalizing set

    Returns:
        Function computing the normalized measure μ'(·) = μ(·)/μ(K)
    """
    if normalizing_value == 0:
        raise ValueError("Cannot normalize: normalizing set has measure 0")

    def normalized(*args, **kwargs):
        return raw_measure(*args, **kwargs) / normalizing_value

    return normalized


# ============================================================
# Algorithm 4: Tamagawa Number Computation
# ============================================================

def tamagawa_number_sl2(num_primes: int = 100) -> float:
    """Compute an approximation to the Tamagawa number τ(SL_2).

    τ(SL_2) = 1, which can be verified via:
        τ(SL_2) = ∏_p (1 - p^{-2})^{-1} × vol(SL_2(R)/SL_2(Z)) × correction

    The Euler product ∏_p (1 - p^{-2}) = 1/ζ(2) = 6/π².

    We compute the partial Euler product over the first `num_primes` primes.

    Args:
        num_primes: number of primes to include

    Returns:
        Approximate value of ∏_p (1 - p^{-2})
    """
    import sympy
    primes = list(sympy.primerange(2, sympy.prime(num_primes) + 1))

    product = Fraction(1)
    for p in primes:
        product *= Fraction(p*p - 1, p*p)

    return float(product)


# ============================================================
# Demonstrations
# ============================================================

def demo():
    """Run demonstrations of all algorithms."""
    print("Algorithm 1: General Euler Product")
    print("-" * 40)

    # Define local measures for Z/2, Z/3, Z/5
    measures = {
        2: LocalMeasure("Q_2", lambda c, n: padic_haar_measure(2, c, n)),
        3: LocalMeasure("Q_3", lambda c, n: padic_haar_measure(3, c, n)),
        5: LocalMeasure("Q_5", lambda c, n: padic_haar_measure(5, c, n)),
    }

    cyl = CylinderSpec(
        support=[2, 3, 5],
        component_specs={2: (0, 1), 3: (0, 2), 5: (0, 1)}
    )

    result = euler_product_cylinder(measures, cyl)
    print(f"  μ(2Z_2 × 9Z_3 × 5Z_5) = {result} = {float(result):.6f}")
    print(f"  Expected: 1/(2 × 9 × 5) = {Fraction(1, 90)}")
    print()

    print("Algorithm 2: Adelic Measure")
    print("-" * 40)

    examples = [
        ("Fundamental domain", (0, 1), {}),
        ("2Z_2 × 3Z_3 × [0,1]", (0, 1), {2: (0, 1), 3: (0, 1)}),
        ("(1+4Z_2) × (2+9Z_3) × [0,2]", (0, 2), {2: (1, 2), 3: (2, 2)}),
        ("4Z_2 × 9Z_3 × 25Z_5 × [0,1]", (0, 1), {2: (0, 2), 3: (0, 2), 5: (0, 2)}),
    ]

    for name, interval, specs in examples:
        mu = adelic_measure(interval, specs)
        print(f"  {name:<40} μ = {str(mu):<10} = {float(mu):.6f}")

    print()
    print("Algorithm 3: Normalization")
    print("-" * 40)

    # Raw measure: Lebesgue on R, multiply by 2
    raw = lambda a, b: Fraction(2) * real_haar_measure(a, b)
    print(f"  Raw μ([0,1]) = {raw(0, 1)}")

    normalized = normalize_haar(raw, raw(0, 1))
    print(f"  Normalized μ'([0,1]) = {normalized(0, 1)}")
    print(f"  Normalized μ'([0,3]) = {normalized(0, 3)}")
    print()

    print("Algorithm 4: Tamagawa Number")
    print("-" * 40)
    try:
        tau = tamagawa_number_sl2(50)
        import math
        expected = 6 / math.pi**2
        print(f"  ∏_{{p≤229}} (1 - p^{{-2}}) ≈ {tau:.8f}")
        print(f"  6/π² ≈ {expected:.8f}")
        print(f"  Ratio: {tau / expected:.8f} (approaches 1)")
    except ImportError:
        print("  (sympy not available, skipping Tamagawa computation)")

    print()


if __name__ == "__main__":
    demo()
