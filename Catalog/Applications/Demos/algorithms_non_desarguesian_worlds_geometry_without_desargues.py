#!/usr/bin/env python3
"""
Algorithms for Non-Desarguesian Geometry

Type-hinted implementations of the core algorithms for computing
nucleus spectra, associator profiles, and collineation group bounds.
"""

from typing import Tuple, List, Set, Dict
from dataclasses import dataclass
import itertools


# --- GF(p) and GF(p²) Arithmetic ---

def gfp_add(a: int, b: int, p: int) -> int:
    """Addition in GF(p)."""
    return (a + b) % p

def gfp_mul(a: int, b: int, p: int) -> int:
    """Multiplication in GF(p)."""
    return (a * b) % p

def gfp_sub(a: int, b: int, p: int) -> int:
    """Subtraction in GF(p)."""
    return (a - b) % p


Elem = Tuple[int, int]  # Element of GF(p²) as a pair


def gf_add(x: Elem, y: Elem, p: int) -> Elem:
    """Addition in GF(p²)."""
    return (gfp_add(x[0], y[0], p), gfp_add(x[1], y[1], p))

def gf_sub(x: Elem, y: Elem, p: int) -> Elem:
    """Subtraction in GF(p²)."""
    return (gfp_sub(x[0], y[0], p), gfp_sub(x[1], y[1], p))


# --- Hall Multiplication ---

def find_nonsquare(p: int) -> int:
    """Find the smallest non-square in GF(p)."""
    squares = {(x * x) % p for x in range(p)}
    for a in range(1, p):
        if a not in squares:
            return a
    raise ValueError(f"No non-square found in GF({p})")


def hall_mul(x: Elem, y: Elem, p: int, nonsquare: int) -> Elem:
    """
    Hall multiplication on GF(p²) = GF(p)[α]/(α² - nonsquare).

    x ○ y = x · y           if y ∈ GF(p) (y[1] == 0)
    x ○ y = Frob(x) · y     if y ∉ GF(p) (y[1] != 0)

    where Frob(a + bα) = a + (p-1)bα and · is field multiplication.
    """
    if y[1] == 0:
        # y is in base field: scalar multiply
        return (gfp_mul(x[0], y[0], p), gfp_mul(x[1], y[0], p))
    else:
        # y is NOT in base field: apply Frobenius then field multiply
        # Frobenius: (a, b) ↦ (a, (p-1)*b)
        fx = (x[0], gfp_mul(p - 1, x[1], p))
        # Field multiply: (a+bα)(c+dα) = (ac + bd·nonsquare) + (ad + bc)α
        return (
            gfp_add(gfp_mul(fx[0], y[0], p), gfp_mul(gfp_mul(fx[1], y[1], p), nonsquare, p), p),
            gfp_add(gfp_mul(fx[0], y[1], p), gfp_mul(fx[1], y[0], p), p)
        )


# --- Nucleus Spectrum Computation ---

@dataclass
class NucleusSpectrum:
    """The nucleus spectrum of a quasifield."""
    order: int
    left_nuc_size: int
    mid_nuc_size: int
    right_nuc_size: int
    left_nuc: List[Elem]
    mid_nuc: List[Elem]
    right_nuc: List[Elem]

    @property
    def is_balanced(self) -> bool:
        return (self.left_nuc_size == self.mid_nuc_size ==
                self.right_nuc_size)

    @property
    def is_desarguesian(self) -> bool:
        return (self.left_nuc_size == self.order and
                self.mid_nuc_size == self.order and
                self.right_nuc_size == self.order)

    @property
    def defect(self) -> int:
        return (3 * self.order - self.left_nuc_size -
                self.mid_nuc_size - self.right_nuc_size)

    @property
    def nucleus_index(self) -> int:
        min_nuc = min(self.left_nuc_size, self.mid_nuc_size,
                      self.right_nuc_size)
        return self.order // min_nuc if min_nuc > 0 else 0

    def __repr__(self) -> str:
        return (f"NucleusSpectrum(order={self.order}, "
                f"spectrum=({self.left_nuc_size}, {self.mid_nuc_size}, "
                f"{self.right_nuc_size}), "
                f"balanced={self.is_balanced}, "
                f"defect={self.defect})")


def compute_nucleus_spectrum(p: int) -> NucleusSpectrum:
    """
    Compute the nucleus spectrum of the Hall quasifield of order p².

    Algorithm:
    1. Enumerate all elements of GF(p²) = GF(p) × GF(p)
    2. For each element x, test if x is in each nucleus by checking
       the associativity condition against all pairs
    3. Return the spectrum (|Nₗ|, |Nₘ|, |Nᵣ|)

    Complexity: O(p^8) — checks p² elements against p⁴ pairs each
    """
    nonsquare = find_nonsquare(p)
    elements = [(a, b) for a in range(p) for b in range(p)]
    order = p * p

    def mul(x: Elem, y: Elem) -> Elem:
        return hall_mul(x, y, p, nonsquare)

    left_nuc: List[Elem] = []
    mid_nuc: List[Elem] = []
    right_nuc: List[Elem] = []

    for x in elements:
        in_left = all(
            mul(x, mul(b, c)) == mul(mul(x, b), c)
            for b, c in itertools.product(elements, repeat=2)
        )
        in_mid = all(
            mul(a, mul(x, c)) == mul(mul(a, x), c)
            for a, c in itertools.product(elements, repeat=2)
        )
        in_right = all(
            mul(a, mul(b, x)) == mul(mul(a, b), x)
            for a, b in itertools.product(elements, repeat=2)
        )
        if in_left: left_nuc.append(x)
        if in_mid: mid_nuc.append(x)
        if in_right: right_nuc.append(x)

    return NucleusSpectrum(
        order=order,
        left_nuc_size=len(left_nuc),
        mid_nuc_size=len(mid_nuc),
        right_nuc_size=len(right_nuc),
        left_nuc=left_nuc,
        mid_nuc=mid_nuc,
        right_nuc=right_nuc,
    )


# --- Associator Analysis ---

@dataclass
class AssociatorProfile:
    """Complete analysis of the associator map."""
    total_triples: int
    non_associating: int
    associator_image_size: int
    missing_from_image: List[Elem]
    defect_profile: Dict[Elem, int]
    density_numerator: int
    density_denominator: int


def analyze_associators(p: int) -> AssociatorProfile:
    """
    Compute the full associator profile of the Hall quasifield of order p².

    Returns the number of non-associating triples, the associator image,
    the defect profile per element, and the density in lowest terms.
    """
    nonsquare = find_nonsquare(p)
    elements = [(a, b) for a in range(p) for b in range(p)]

    def mul(x: Elem, y: Elem) -> Elem:
        return hall_mul(x, y, p, nonsquare)

    def sub(x: Elem, y: Elem) -> Elem:
        return gf_sub(x, y, p)

    total = len(elements) ** 3
    non_assoc = 0
    assoc_image: Set[Elem] = set()
    defect_profile: Dict[Elem, int] = {x: 0 for x in elements}

    for a, b, c in itertools.product(elements, repeat=3):
        lhs = mul(mul(a, b), c)
        rhs = mul(a, mul(b, c))
        val = sub(lhs, rhs)
        assoc_image.add(val)
        if val != (0, 0):
            non_assoc += 1
            defect_profile[a] += 1

    missing = [x for x in elements if x not in assoc_image]

    # Reduce fraction
    from math import gcd
    g = gcd(non_assoc, total)

    return AssociatorProfile(
        total_triples=total,
        non_associating=non_assoc,
        associator_image_size=len(assoc_image),
        missing_from_image=missing,
        defect_profile=defect_profile,
        density_numerator=non_assoc // g,
        density_denominator=total // g,
    )


# --- Collineation Group Bounds ---

def pgl_order(n: int) -> int:
    """Order of PGL(3, n)."""
    return n**3 * (n**3 - 1) * (n**2 - 1)

def hall_collineation_order(q: int) -> int:
    """Order of the collineation group of the Hall plane of order q²."""
    return q**2 * (q**2 - 1) * q * (q - 1)

def symmetry_loss_ratio(q: int) -> float:
    """Ratio |PGL(3,q²)| / |Hall collineation group|."""
    pgl = pgl_order(q**2)
    hall = hall_collineation_order(q)
    return pgl / hall if hall > 0 else float('inf')


if __name__ == "__main__":
    print("Computing nucleus spectrum for p=3 (Hall quasifield of order 9)...")
    spectrum = compute_nucleus_spectrum(3)
    print(spectrum)
    print()

    print("Computing associator profile...")
    profile = analyze_associators(3)
    print(f"Non-associating triples: {profile.non_associating}/{profile.total_triples}")
    print(f"Density: {profile.density_numerator}/{profile.density_denominator}")
    print(f"Associator image size: {profile.associator_image_size}")
    print(f"Missing from image: {profile.missing_from_image}")
    print(f"Defect profile: {profile.defect_profile}")
    print()

    print("Symmetry loss ratios:")
    for q in range(3, 10):
        print(f"  q={q}: ratio = {symmetry_loss_ratio(q):.1f}, "
              f"q⁴ = {q**4}")
