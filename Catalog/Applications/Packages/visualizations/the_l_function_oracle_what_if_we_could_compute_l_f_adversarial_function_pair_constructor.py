#!/usr/bin/env python3
"""
L-Function Oracle Hierarchy — Core Algorithms

Implements the algorithmic content of the oracle hierarchy theorems:

1. AdversarialConstructor: builds indistinguishable function pairs
2. VanishingOrderDetector: finds vanishing order from derivative oracle
3. FactorExtractor: recovers prime factors from separating invariants
4. RHUpToChecker: checks RH up to height T from zero certificate data

Each algorithm includes complexity analysis and correctness guarantees
matching the formally verified theorems.
"""

import math
import numpy as np
from typing import Callable, List, Optional, Tuple, Set
from dataclasses import dataclass


# =============================================================================
# Algorithm 1: Adversarial Function Pair Constructor
# =============================================================================

@dataclass
class AdversarialPair:
    """A pair of functions agreeing on Q but differing in vanishing at target."""
    F: Callable[[complex], complex]
    G: Callable[[complex], complex]
    query_set: List[complex]
    target: complex
    F_at_target: complex
    G_at_target: complex


def construct_adversarial_pair(
    Q: List[complex],
    target: complex = 1.0 + 0j
) -> AdversarialPair:
    """
    Construct two functions F, G that agree on Q but differ at target.

    Algorithm:
        F(z) = ∏_{q ∈ Q} (z - q)    (vanishing polynomial)
        G(z) = 0                      (zero function)

    Complexity: O(|Q|) per evaluation
    Correctness: F(q) = G(q) = 0 for all q ∈ Q; F(target) ≠ 0 if target ∉ Q

    Args:
        Q: List of query points (must not contain target)
        target: The point where behavior differs

    Returns:
        AdversarialPair with F(target) ≠ 0 and G(target) = 0

    Raises:
        ValueError: if target is in Q
    """
    if any(abs(q - target) < 1e-15 for q in Q):
        raise ValueError(f"target {target} must not be in Q")

    def vanish_poly(z: complex) -> complex:
        result = 1.0 + 0j
        for q in Q:
            result *= (z - q)
        return result

    F = vanish_poly
    G = lambda z: 0.0 + 0j

    return AdversarialPair(
        F=F, G=G,
        query_set=list(Q),
        target=target,
        F_at_target=F(target),
        G_at_target=G(target)
    )


def construct_adversarial_pair_with_order(
    Q: List[complex],
    target: complex = 1.0 + 0j,
    order_F: int = 0,
    order_G: int = 1
) -> AdversarialPair:
    """
    Construct functions with specified vanishing orders at target,
    agreeing on Q.

    Algorithm:
        F(z) = (z - target)^{order_F} · ∏(z - q)
        G(z) = (z - target)^{order_G} · ∏(z - q)

    Both vanish on Q (due to ∏(z-q) factor), but have different
    orders of vanishing at target.

    Complexity: O(|Q| + max(order_F, order_G)) per evaluation
    """
    if any(abs(q - target) < 1e-15 for q in Q):
        raise ValueError(f"target {target} must not be in Q")

    def make_fn(order: int) -> Callable[[complex], complex]:
        def fn(z: complex) -> complex:
            result = (z - target) ** order
            for q in Q:
                result *= (z - q)
            return result
        return fn

    F = make_fn(order_F)
    G = make_fn(order_G)

    return AdversarialPair(
        F=F, G=G,
        query_set=list(Q),
        target=target,
        F_at_target=F(target),
        G_at_target=G(target)
    )


# =============================================================================
# Algorithm 2: Vanishing Order Detector
# =============================================================================

@dataclass
class VanishingOrderResult:
    """Result of vanishing order detection."""
    order: Optional[int]
    derivatives: List[complex]
    first_nonzero_value: Optional[complex]
    confidence: float


def detect_vanishing_order(
    derivative_oracle: Callable[[int], complex],
    max_order: int = 100,
    tolerance: float = 1e-10
) -> VanishingOrderResult:
    """
    Detect the vanishing order using a derivative oracle.

    Algorithm:
        For n = 0, 1, 2, ..., max_order:
            Query f^(n)(s₀) from oracle
            If |f^(n)(s₀)| > tolerance:
                Return n as the vanishing order

    Complexity: O(n*) queries where n* is the vanishing order
    Correctness: By the uniqueness theorem (derivative_oracle_detects_vanishing_order),
                 the returned order is the unique vanishing order.

    Args:
        derivative_oracle: Function n ↦ f^(n)(s₀) returning the n-th derivative
        max_order: Maximum order to check
        tolerance: Threshold for considering a value nonzero

    Returns:
        VanishingOrderResult with the detected order
    """
    derivatives = []
    for n in range(max_order + 1):
        d_n = derivative_oracle(n)
        derivatives.append(d_n)
        if abs(d_n) > tolerance:
            return VanishingOrderResult(
                order=n,
                derivatives=derivatives,
                first_nonzero_value=d_n,
                confidence=abs(d_n) / tolerance
            )

    return VanishingOrderResult(
        order=None,
        derivatives=derivatives,
        first_nonzero_value=None,
        confidence=0.0
    )


def simulate_derivative_oracle(
    f: Callable[[complex], complex],
    s0: complex,
    h: float = 1e-6
) -> Callable[[int], complex]:
    """
    Simulate a derivative oracle using numerical differentiation.

    Uses the Cauchy integral formula discretization:
        f^(n)(s₀) = n! / (2πi) ∮ f(z)/(z-s₀)^{n+1} dz
                   ≈ n!/r^n · (1/N) Σ f(s₀ + r·e^{2πik/N}) · e^{-2πink/N}

    Args:
        f: The function to differentiate
        s0: The point of evaluation
        h: Radius for contour integration
    """
    def oracle(n: int) -> complex:
        N = max(2 * n + 10, 32)  # number of quadrature points
        r = h
        total = 0.0 + 0j
        for k in range(N):
            theta = 2 * np.pi * k / N
            z = s0 + r * np.exp(1j * theta)
            total += f(z) * np.exp(-1j * n * theta)
        # f^(n)(s0) = n! * total / (N * r^n)
        return math.factorial(n) * total / (N * r**n)

    return oracle


# =============================================================================
# Algorithm 3: Factor Extractor from Separating Invariants
# =============================================================================

@dataclass
class FactorResult:
    """Result of factor extraction."""
    n: int
    factor: int
    cofactor: int
    separating_invariant: int
    verified: bool


def extract_factor(
    n: int,
    separating_invariant: int
) -> FactorResult:
    """
    Extract a nontrivial factor of n using a separating invariant.

    Algorithm:
        Compute g = gcd(separating_invariant, n)
        If 1 < g < n, then g is a nontrivial factor.

    Complexity: O(log(n)) via Euclidean algorithm
    Correctness: By factor_from_separating_invariant, if n = p·q with
                 p | a and q ∤ a, then gcd(a, n) = p.

    Args:
        n: The number to factor
        separating_invariant: Value a with p|a and q∤a for factors p,q of n

    Returns:
        FactorResult with the extracted factor
    """
    g = math.gcd(separating_invariant, n)
    is_nontrivial = 1 < g < n

    return FactorResult(
        n=n,
        factor=g,
        cofactor=n // g if g > 0 else 0,
        separating_invariant=separating_invariant,
        verified=is_nontrivial
    )


def simulate_euler_factor_oracle(
    n: int,
    primes_up_to: int = 100
) -> List[Tuple[int, int]]:
    """
    Simulate an Euler factor oracle for a semiprime n = p·q.

    For each small prime ℓ, compute a_ℓ = ℓ + 1 - |E(F_ℓ)| for a random
    "elliptic curve" (here simulated). The traces a_ℓ mod p and a_ℓ mod q
    provide separating information.

    This is a simplified model of how real L-function Euler factor data
    can separate prime components.
    """
    traces = []
    for ell in range(2, primes_up_to + 1):
        if is_prime(ell):
            # Simulated trace: in practice, this comes from counting points
            # on an elliptic curve mod ℓ
            a_ell = (ell * ell + 1) % n  # toy model
            traces.append((ell, a_ell))
    return traces


def is_prime(n: int) -> bool:
    """Simple primality test."""
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


# =============================================================================
# Algorithm 4: RH Up To Height T Checker
# =============================================================================

@dataclass
class RHCheckResult:
    """Result of checking RH up to height T."""
    T: float
    zeros_found: List[complex]
    all_on_critical_line: bool
    max_deviation: float
    num_zeros: int


def check_rh_up_to(
    zero_certificates: List[complex],
    T: float,
    critical_line_re: float = 0.5,
    tolerance: float = 1e-10
) -> RHCheckResult:
    """
    Check the Riemann Hypothesis up to height T given certified zeros.

    Algorithm:
        Filter zeros with |Im(z)| ≤ T
        Check whether all filtered zeros satisfy Re(z) = 1/2

    Complexity: O(|zeros|) to filter and check
    Correctness: By exists_decider_RHUpTo, this is decidable given
                 a complete certified zero list.

    Args:
        zero_certificates: Certified list of all zeros
        T: Height bound
        critical_line_re: Real part of critical line (default 1/2)
        tolerance: Tolerance for checking Re(z) = 1/2

    Returns:
        RHCheckResult with verification status
    """
    relevant_zeros = [z for z in zero_certificates if abs(z.imag) <= T]

    if not relevant_zeros:
        return RHCheckResult(
            T=T,
            zeros_found=[],
            all_on_critical_line=True,
            max_deviation=0.0,
            num_zeros=0
        )

    deviations = [abs(z.real - critical_line_re) for z in relevant_zeros]
    max_dev = max(deviations)

    return RHCheckResult(
        T=T,
        zeros_found=relevant_zeros,
        all_on_critical_line=max_dev < tolerance,
        max_deviation=max_dev,
        num_zeros=len(relevant_zeros)
    )


# =============================================================================
# Example usage
# =============================================================================

if __name__ == "__main__":
    print("L-Function Oracle Hierarchy — Algorithm Demonstrations\n")

    # Algorithm 1: Adversarial construction
    print("1. Adversarial Pair Construction:")
    Q = [0.0, 2.0, -1.0, 0.5 + 1j, 0.5 - 1j]
    pair = construct_adversarial_pair(Q)
    print(f"   Query set: {Q}")
    print(f"   F(1) = {pair.F_at_target:.6f} (≠ 0)")
    print(f"   G(1) = {pair.G_at_target:.6f} (= 0)")
    for q in Q:
        print(f"   F({q}) = {pair.F(q):.6f} = G({q}) = {pair.G(q):.6f}")
    print()

    # Algorithm 2: Vanishing order detection
    print("2. Vanishing Order Detection:")
    test_fns = [
        ("z³", lambda z: z**3, 3),
        ("sin(z)", lambda z: np.sin(z), 1),
        ("1-cos(z)", lambda z: 1 - np.cos(z), 2),
    ]
    for name, f, expected in test_fns:
        oracle = simulate_derivative_oracle(f, 0.0 + 0j)
        result = detect_vanishing_order(oracle)
        print(f"   {name}: detected order = {result.order} (expected {expected})")
    print()

    # Algorithm 3: Factor extraction
    print("3. Factor Extraction:")
    semiprimes = [(15, 6), (77, 21), (143, 33), (10403, 202)]
    for n, a in semiprimes:
        result = extract_factor(n, a)
        print(f"   n = {n}, a = {a}: factor = {result.factor}, "
              f"cofactor = {result.cofactor}")
    print()

    # Algorithm 4: RH checker
    print("4. RH Up To Height T:")
    # Simulated Riemann zeta zeros (known to high precision)
    known_zeros = [
        0.5 + 14.134725j, 0.5 + 21.022040j, 0.5 + 25.010858j,
        0.5 + 30.424876j, 0.5 + 32.935062j, 0.5 + 37.586178j,
    ]
    for T in [15, 25, 40]:
        result = check_rh_up_to(known_zeros, T)
        print(f"   T = {T}: {result.num_zeros} zeros, "
              f"all on critical line: {result.all_on_critical_line}, "
              f"max deviation: {result.max_deviation:.2e}")
