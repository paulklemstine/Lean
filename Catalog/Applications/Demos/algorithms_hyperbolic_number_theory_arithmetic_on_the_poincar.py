#!/usr/bin/env python3
"""
Hyperbolic Number Theory: Core Algorithms
==========================================

Type-hinted implementations of the key algorithms from the formalization.
"""

import math
from typing import List, Tuple, Optional
from dataclasses import dataclass
from enum import Enum


# ============================================================
# Core Types
# ============================================================

class SL2Class(Enum):
    ELLIPTIC = "elliptic"
    PARABOLIC = "parabolic"
    HYPERBOLIC = "hyperbolic"


@dataclass
class SL2Z:
    """2×2 integer matrix with determinant 1."""
    a: int
    b: int
    c: int
    d: int

    def __post_init__(self) -> None:
        det = self.a * self.d - self.b * self.c
        if det != 1:
            raise ValueError(f"Determinant is {det}, not 1")

    @property
    def trace(self) -> int:
        return self.a + self.d

    def classify(self) -> SL2Class:
        t = abs(self.trace)
        if t < 2:
            return SL2Class.ELLIPTIC
        elif t == 2:
            return SL2Class.PARABOLIC
        else:
            return SL2Class.HYPERBOLIC

    def __mul__(self, other: 'SL2Z') -> 'SL2Z':
        return SL2Z(
            a=self.a * other.a + self.b * other.c,
            b=self.a * other.b + self.b * other.d,
            c=self.c * other.a + self.d * other.c,
            d=self.c * other.b + self.d * other.d,
        )

    def inv(self) -> 'SL2Z':
        return SL2Z(a=self.d, b=-self.b, c=-self.c, d=self.a)

    @staticmethod
    def identity() -> 'SL2Z':
        return SL2Z(1, 0, 0, 1)

    @staticmethod
    def T() -> 'SL2Z':
        return SL2Z(1, 1, 0, 1)

    @staticmethod
    def S() -> 'SL2Z':
        return SL2Z(0, -1, 1, 0)


@dataclass(frozen=True)
class EinsteinVelocity:
    """A subluminal velocity: a real number in (-1, 1)."""
    value: float

    def __post_init__(self) -> None:
        if abs(self.value) >= 1.0:
            raise ValueError(f"|value| = {abs(self.value)} >= 1, not subluminal")

    def __add__(self, other: 'EinsteinVelocity') -> 'EinsteinVelocity':
        result = (self.value + other.value) / (1 + self.value * other.value)
        return EinsteinVelocity(result)

    def __neg__(self) -> 'EinsteinVelocity':
        return EinsteinVelocity(-self.value)

    def rapidity(self) -> float:
        return math.log((1 + self.value) / (1 - self.value)) / 2


# ============================================================
# Algorithm 1: Einstein Addition with Closure Verification
# ============================================================

def einstein_add(a: float, b: float) -> float:
    """
    Einstein addition (relativistic velocity addition).

    For |a| < 1 and |b| < 1, returns (a+b)/(1+ab) ∈ (-1,1).

    Proof of closure: (1+ab)² - (a+b)² = (1-a²)(1-b²) > 0
    when |a| < 1 and |b| < 1.
    """
    return (a + b) / (1 + a * b)


def einstein_add_chain(values: List[float]) -> float:
    """
    Left-fold Einstein addition over a list of subluminal velocities.
    By associativity (proved in Lean), the fold direction doesn't matter.
    """
    result = 0.0
    for v in values:
        result = einstein_add(result, v)
    return result


# ============================================================
# Algorithm 2: Rapidity Map (Group Isomorphism)
# ============================================================

def rapidity(x: float) -> float:
    """
    The rapidity map: artanh(x) = log((1+x)/(1-x))/2.

    This is a group isomorphism from ((-1,1), ⊕) to (ℝ, +):
        rapidity(a ⊕ b) = rapidity(a) + rapidity(b)

    Proved formally in Lean as theorem rapidity_additive.
    """
    if abs(x) >= 1:
        raise ValueError(f"|x| >= 1")
    return math.log((1 + x) / (1 - x)) / 2


def inverse_rapidity(r: float) -> float:
    """Inverse rapidity: tanh(r) maps ℝ → (-1,1)."""
    return math.tanh(r)


# ============================================================
# Algorithm 3: SL₂(ℤ) Trace Classification
# ============================================================

def classify_by_trace(t: int) -> SL2Class:
    """
    Classify an SL₂(ℤ) element by its trace.

    - Elliptic: |tr| < 2 (finite order, rotation)
    - Parabolic: |tr| = 2 (cusp, unipotent)
    - Hyperbolic: |tr| > 2 (geodesic translation)

    Proved in Lean:
        elliptic_trace_bounded, parabolic_iff_trace_pm2, hyperbolic_iff_trace_large
    """
    if abs(t) < 2:
        return SL2Class.ELLIPTIC
    elif abs(t) == 2:
        return SL2Class.PARABOLIC
    else:
        return SL2Class.HYPERBOLIC


# ============================================================
# Algorithm 4: Hyperbolic Prime Counting
# ============================================================

def is_prime(n: int) -> bool:
    """Primality test."""
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


def hyp_prime_count(n: int) -> int:
    """
    Count 'hyperbolic primes' up to n: primes p with p > 2.

    These correspond to potential traces of primitive hyperbolic
    elements in SL₂(ℤ). Proved monotone and eventually positive in Lean.
    """
    return sum(1 for k in range(3, n + 1) if is_prime(k))


def hyp_prime_density_ratio(n: int) -> float:
    """
    Compute π_H(n) · log(n) / n.

    By the prime number theorem, this ratio → 1 as n → ∞.
    """
    if n <= 2:
        return 0.0
    return hyp_prime_count(n) * math.log(n) / n


# ============================================================
# Algorithm 5: Poincaré Disk Distance
# ============================================================

def poincare_distance(z: complex, w: complex) -> float:
    """
    Hyperbolic distance on the Poincaré disk.

    d(z,w) = 2·artanh(|z-w| / |1 - w̄z|)

    The denominator |1 - w̄z| > 0 is guaranteed when |z| < 1 and |w| < 1.
    This was proved formally as cross_ratio_denom_pos in Lean.
    """
    num = abs(z - w)
    den = abs(1 - w.conjugate() * z)
    if den == 0:
        raise ValueError("Points on the boundary")
    return 2 * math.atanh(num / den)


def cross_ratio_mod_sq(z: complex, w: complex) -> float:
    """
    Cross-ratio modulus squared: |z-w|² / |1 - w̄z|².

    Used in the Poincaré metric formula.
    """
    num = abs(z - w) ** 2
    den = abs(1 - w.conjugate() * z) ** 2
    return num / den


# ============================================================
# Algorithm 6: SL₂(ℤ) Orbit Generation
# ============================================================

def generate_sl2z_orbit(
    basepoint: complex,
    max_word_length: int = 6
) -> List[Tuple[complex, SL2Z]]:
    """
    Generate orbit points of the modular group action on the upper half-plane,
    then map to the Poincaré disk via the Cayley transform.

    Uses generators T (translation) and S (inversion).
    """
    T = SL2Z.T()
    S = SL2Z.S()

    def moebius_action(g: SL2Z, z: complex) -> complex:
        return (g.a * z + g.b) / (g.c * z + g.d)

    def cayley_transform(z: complex) -> complex:
        return (z - 1j) / (z + 1j)

    orbit: List[Tuple[complex, SL2Z]] = []
    visited: set = set()
    queue = [(SL2Z.identity(), 0)]
    generators = [T, T.inv(), S]

    while queue:
        g, depth = queue.pop(0)
        key = (g.a, g.b, g.c, g.d)
        if key in visited or depth > max_word_length:
            continue
        visited.add(key)

        z = moebius_action(g, basepoint)
        w = cayley_transform(z)

        if abs(w) < 1:
            orbit.append((w, g))

        if depth < max_word_length:
            for gen in generators:
                queue.append((g * gen, depth + 1))

    return orbit


if __name__ == "__main__":
    # Quick self-test
    v1 = EinsteinVelocity(0.5)
    v2 = EinsteinVelocity(0.3)
    v3 = v1 + v2
    print(f"0.5 ⊕ 0.3 = {v3.value:.6f}")
    print(f"rapidity(0.5 ⊕ 0.3) = {v3.rapidity():.6f}")
    print(f"rapidity(0.5) + rapidity(0.3) = {v1.rapidity() + v2.rapidity():.6f}")

    # SL₂(ℤ) examples
    T = SL2Z.T()
    S = SL2Z.S()
    print(f"\nT = {T}, trace = {T.trace}, class = {T.classify().value}")
    print(f"S = {S}, trace = {S.trace}, class = {S.classify().value}")
    print(f"T·S = {T * S}, trace = {(T * S).trace}, class = {(T * S).classify().value}")

    # Prime counting
    for n in [100, 1000, 10000]:
        print(f"π_H({n}) = {hyp_prime_count(n)}, density ratio = {hyp_prime_density_ratio(n):.4f}")
