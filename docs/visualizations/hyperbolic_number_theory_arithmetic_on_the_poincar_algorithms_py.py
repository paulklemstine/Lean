"""
Hyperbolic Number Theory: Core Algorithms

Implements arithmetic on the Poincaré disk model of hyperbolic geometry,
including hyperbolic distance, Möbius transformations, lattice point counting,
and the Selberg zeta function.
"""

from __future__ import annotations
import cmath
import math
from dataclasses import dataclass
from typing import List, Tuple, Optional


# ---------------------------------------------------------------------------
# Poincaré Disk Basics
# ---------------------------------------------------------------------------

def is_in_disk(z: complex) -> bool:
    """Check if a complex number lies in the open unit disk."""
    return abs(z) < 1.0


def hyp_distance(z: complex, w: complex) -> float:
    """
    Hyperbolic distance in the Poincaré disk model:
      d(z, w) = 2 * artanh(|z - w| / |1 - conj(z)*w|)
    """
    if not (is_in_disk(z) and is_in_disk(w)):
        raise ValueError("Both points must be in the open unit disk")
    num = abs(z - w)
    den = abs(1 - z.conjugate() * w)
    if den < 1e-15:
        return float('inf')
    ratio = num / den
    ratio = min(ratio, 1.0 - 1e-15)  # numerical safety
    return 2.0 * math.atanh(ratio)


def hyp_distance_cross_ratio(z: complex, w: complex) -> float:
    """
    Compute δ(z,w) = |z-w|² / ((1-|z|²)(1-|w|²)),
    where d(z,w) = acosh(1 + 2δ).
    """
    nsq_z = abs(z) ** 2
    nsq_w = abs(w) ** 2
    return abs(z - w) ** 2 / ((1 - nsq_z) * (1 - nsq_w))


# ---------------------------------------------------------------------------
# Möbius Transformations
# ---------------------------------------------------------------------------

@dataclass
class MobiusTransform:
    """
    Möbius transformation of the Poincaré disk:
      φ(z) = rotation * (z - center) / (1 - conj(center) * z)
    """
    center: complex
    rotation: complex  # |rotation| = 1

    def __post_init__(self) -> None:
        assert is_in_disk(self.center), f"|center| = {abs(self.center)} >= 1"
        assert abs(abs(self.rotation) - 1.0) < 1e-10, "rotation must have unit modulus"

    def apply(self, z: complex) -> complex:
        """Apply the Möbius transformation to z."""
        num = self.rotation * (z - self.center)
        den = 1 - self.center.conjugate() * z
        return num / den

    @staticmethod
    def identity() -> MobiusTransform:
        return MobiusTransform(center=0j, rotation=1+0j)

    def compose(self, other: MobiusTransform) -> MobiusTransform:
        """Approximate composition by evaluating at test points."""
        # For exact composition, we would track the SL(2,R) matrices
        # Here we just provide function composition
        raise NotImplementedError("Use SL2R matrices for exact composition")

    def inverse(self) -> MobiusTransform:
        """The inverse transformation."""
        new_center = self.apply(0j)  # φ⁻¹ maps 0 to -φ.center rotated
        # φ⁻¹(z) = (z/rotation + center) / (1 + conj(center) * z/rotation)
        # = (z + rotation*center) / (rotation + conj(center)*z)
        # This is another Möbius transform with:
        inv_rot = self.rotation.conjugate()
        inv_center = -(self.rotation * self.center)
        # But need to normalize to standard form
        return MobiusTransform(
            center=-self.rotation * self.center,
            rotation=self.rotation.conjugate()
        )


# ---------------------------------------------------------------------------
# SL(2,R) Matrices for Exact Group Operations
# ---------------------------------------------------------------------------

@dataclass
class SL2R:
    """
    Element of SL(2,ℝ): matrix [[a,b],[c,d]] with ad-bc=1.
    Acts on upper half-plane by z ↦ (az+b)/(cz+d).
    """
    a: float
    b: float
    c: float
    d: float

    def det(self) -> float:
        return self.a * self.d - self.b * self.c

    def __post_init__(self) -> None:
        det = self.det()
        assert abs(det - 1.0) < 1e-8, f"det = {det}, not 1"

    def act_upper_half(self, z: complex) -> complex:
        """Act on the upper half-plane: z ↦ (az+b)/(cz+d)."""
        return (self.a * z + self.b) / (self.c * z + self.d)

    def multiply(self, other: SL2R) -> SL2R:
        """Matrix multiplication."""
        return SL2R(
            a=self.a * other.a + self.b * other.c,
            b=self.a * other.b + self.b * other.d,
            c=self.c * other.a + self.d * other.c,
            d=self.c * other.b + self.d * other.d,
        )

    def trace(self) -> float:
        return self.a + self.d

    def is_hyperbolic(self) -> bool:
        """A matrix is hyperbolic iff |trace| > 2."""
        return abs(self.trace()) > 2.0

    def geodesic_length(self) -> float:
        """For hyperbolic elements, the translation length along the axis."""
        t = abs(self.trace())
        if t <= 2.0:
            return 0.0
        return 2.0 * math.acosh(t / 2.0)

    @staticmethod
    def identity() -> SL2R:
        return SL2R(a=1, b=0, c=0, d=1)

    @staticmethod
    def generator_T() -> SL2R:
        """Translation T: z ↦ z+1."""
        return SL2R(a=1, b=1, c=0, d=1)

    @staticmethod
    def generator_S() -> SL2R:
        """Inversion S: z ↦ -1/z."""
        return SL2R(a=0, b=-1, c=1, d=0)


# ---------------------------------------------------------------------------
# PSL(2,Z) Orbit and Lattice Point Enumeration
# ---------------------------------------------------------------------------

def enumerate_psl2z_words(max_length: int) -> List[SL2R]:
    """
    Enumerate PSL(2,Z) elements as words in generators S, T, T⁻¹
    up to a given word length.
    """
    S = SL2R.generator_S()
    T = SL2R.generator_T()
    Tinv = SL2R(a=1, b=-1, c=0, d=1)

    elements: List[SL2R] = [SL2R.identity()]
    current_level = [SL2R.identity()]
    generators = [S, T, Tinv]

    for _ in range(max_length):
        next_level: List[SL2R] = []
        for g in current_level:
            for gen in generators:
                new = g.multiply(gen)
                # Deduplicate by checking if matrix is "new" (approximate)
                is_new = True
                for existing in elements:
                    if (abs(new.a - existing.a) < 1e-8 and
                        abs(new.b - existing.b) < 1e-8 and
                        abs(new.c - existing.c) < 1e-8 and
                        abs(new.d - existing.d) < 1e-8):
                        is_new = False
                        break
                    # Also check negation (PSL identification)
                    if (abs(new.a + existing.a) < 1e-8 and
                        abs(new.b + existing.b) < 1e-8 and
                        abs(new.c + existing.c) < 1e-8 and
                        abs(new.d + existing.d) < 1e-8):
                        is_new = False
                        break
                if is_new:
                    elements.append(new)
                    next_level.append(new)
        current_level = next_level

    return elements


def orbit_in_disk(base_point: complex, group_elements: List[SL2R],
                  max_count: int = 10000) -> List[complex]:
    """
    Compute the orbit of a base point in the upper half-plane,
    then map to the Poincaré disk via the Cayley transform.
    """
    orbit_uhp = []
    for g in group_elements[:max_count]:
        try:
            w = g.act_upper_half(base_point)
            if w.imag > 1e-10:  # stay in UHP
                orbit_uhp.append(w)
        except (ZeroDivisionError, OverflowError):
            continue

    # Cayley transform: UHP → Disk: z ↦ (z - i)/(z + i)
    i = 1j
    orbit_disk = [(w - i) / (w + i) for w in orbit_uhp]
    return orbit_disk


# ---------------------------------------------------------------------------
# Hyperbolic Counting Function
# ---------------------------------------------------------------------------

def hyp_counting_fn(orbit: List[complex], R: float) -> int:
    """
    Count orbit points within hyperbolic distance R of the origin.
    In the disk model, d(0, z) = 2*artanh(|z|), so |z| < tanh(R/2).
    """
    threshold = math.tanh(R / 2.0)
    return sum(1 for z in orbit if abs(z) < threshold)


def euclidean_counting_fn(orbit: List[complex], r: float) -> int:
    """Count orbit points within Euclidean distance r of origin."""
    return sum(1 for z in orbit if abs(z) <= r)


# ---------------------------------------------------------------------------
# Hyperbolic Prime Detection
# ---------------------------------------------------------------------------

def find_primitive_geodesics(elements: List[SL2R],
                              max_length: float) -> List[Tuple[float, SL2R]]:
    """
    Find primitive hyperbolic elements (hyperbolic primes) with
    geodesic length ≤ max_length.

    A hyperbolic element γ is primitive if it is not a positive power
    of another hyperbolic element.
    """
    hyperbolic_elements: List[Tuple[float, SL2R]] = []

    for g in elements:
        if g.is_hyperbolic():
            length = g.geodesic_length()
            if length <= max_length:
                hyperbolic_elements.append((length, g))

    # Sort by length
    hyperbolic_elements.sort(key=lambda x: x[0])

    # Filter to primitive elements (heuristic: remove powers)
    primitives: List[Tuple[float, SL2R]] = []
    for length, g in hyperbolic_elements:
        is_power = False
        for prim_length, _ in primitives:
            # Check if length ≈ k * prim_length for integer k ≥ 2
            if prim_length > 1e-10:
                ratio = length / prim_length
                k = round(ratio)
                if k >= 2 and abs(ratio - k) < 0.01:
                    is_power = True
                    break
        if not is_power:
            primitives.append((length, g))

    return primitives


# ---------------------------------------------------------------------------
# Selberg Zeta Function (Truncated)
# ---------------------------------------------------------------------------

def selberg_zeta_truncated(spec: List[float], s: float, K: int = 20) -> float:
    """
    Compute the truncated Selberg zeta function:
      Z_K(s) = ∏_{ℓ ∈ spec} ∏_{k=0}^{K-1} (1 - e^{-(s+k)ℓ})
    """
    result = 1.0
    for ell in spec:
        for k in range(K):
            factor = 1.0 - math.exp(-(s + k) * ell)
            result *= factor
    return result


# ---------------------------------------------------------------------------
# Hyperbolic Area Computations
# ---------------------------------------------------------------------------

def hyp_area_factor(r: float) -> float:
    """Hyperbolic area element scaling: 4/(1-r²)²."""
    if r >= 1.0:
        return float('inf')
    return 4.0 / (1.0 - r**2)**2


def hyp_polygon_area(angles: List[float]) -> float:
    """
    Hyperbolic area of an n-gon with given interior angles:
      A = (n-2)π - Σα_i
    """
    n = len(angles)
    return (n - 2) * math.pi - sum(angles)


def hyp_disk_area(R: float) -> float:
    """
    Area of a hyperbolic disk of radius R:
      A = 4π sinh²(R/2) = 2π(cosh(R) - 1)
    """
    return 2 * math.pi * (math.cosh(R) - 1)


# ---------------------------------------------------------------------------
# Hyperbolic Prime Counting Asymptotic
# ---------------------------------------------------------------------------

def hyp_prime_asymptotic(R: float) -> float:
    """Conjectured asymptotic: π_H(R) ~ e^R / R."""
    if R <= 0:
        return 0.0
    return math.exp(R) / R


def lattice_point_leading_coeff(covolume: float) -> float:
    """Leading coefficient V/(4π) for lattice point counting."""
    return covolume / (4 * math.pi)


# ---------------------------------------------------------------------------
# Hyperbolic Arithmetic System
# ---------------------------------------------------------------------------

@dataclass
class HypArithSystem:
    """
    A finite hyperbolic arithmetic system: a set of points in the disk
    with an operation and a norm function.
    """
    elements: List[complex]
    op: callable  # (complex, complex) -> complex
    hyp_norm: callable  # complex -> float

    @property
    def size(self) -> int:
        return len(self.elements)

    def count_below(self, R: float) -> int:
        """Count elements with hypNorm ≤ R."""
        return sum(1 for z in self.elements if self.hyp_norm(z) <= R)

    def find_primes(self) -> List[complex]:
        """Find elements that cannot be decomposed as op(a, b) for non-zero a, b."""
        zero = 0j
        primes = []
        for p in self.elements:
            if abs(p) < 1e-15:
                continue  # skip identity
            is_prime = True
            for a in self.elements:
                if abs(a) < 1e-15:
                    continue
                for b in self.elements:
                    if abs(b) < 1e-15:
                        continue
                    if abs(self.op(a, b) - p) < 1e-10:
                        is_prime = False
                        break
                if not is_prime:
                    break
            if is_prime:
                primes.append(p)
        return primes


def build_midpoint_system(orbit: List[complex]) -> HypArithSystem:
    """Build a HypArithSystem using the Euclidean midpoint operation."""
    def midpoint_op(z: complex, w: complex) -> complex:
        return (z + w) / 2

    def hyp_norm(z: complex) -> float:
        if abs(z) >= 1.0:
            return float('inf')
        return hyp_distance(0j, z)

    return HypArithSystem(
        elements=orbit,
        op=midpoint_op,
        hyp_norm=hyp_norm,
    )
