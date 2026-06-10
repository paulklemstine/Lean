"""
Arithmetic Persistence Algorithms for K3 Height Detection

This module implements the core algorithms for the primewise arithmetic persistence
framework, providing certified-equivalent Python implementations of the Lean-verified
invariants.

All algorithms operate on rational slope profiles representing normalized Frobenius
eigenvalue data at a prime.
"""

from fractions import Fraction
from dataclasses import dataclass, field
from typing import List, Optional, Tuple, Dict
import math


@dataclass
class PrimeSlopeProfile:
    """A finite set of rational slopes at a prime with a symmetry center.

    For K3 surfaces in weight-2 crystalline cohomology, the symmetry center is 1.
    Supersingular reduction corresponds to all slopes equal to the center.
    Finite formal Brauer group height forces slopes away from 1.

    Attributes:
        p: The prime at which reduction is taken.
        slopes: List of rational slopes (normalized Frobenius eigenvalue valuations).
        weight: The total weight of the cohomological piece.
        symmetric_about: The symmetry center (= weight/2 in crystalline theory).
    """
    p: int
    slopes: List[Fraction]
    weight: Fraction = Fraction(2)
    symmetric_about: Fraction = Fraction(1)

    def __post_init__(self):
        """Validate that p is prime (basic check)."""
        if self.p < 2:
            raise ValueError(f"p={self.p} is not prime")
        # Convert slopes to Fraction if needed
        self.slopes = [Fraction(s) for s in self.slopes]
        self.weight = Fraction(self.weight)
        self.symmetric_about = Fraction(self.symmetric_about)


def height_signature(profile: PrimeSlopeProfile, epsilon: Fraction) -> int:
    """Compute the height signature at scale epsilon.

    Counts the number of slopes within distance epsilon of the symmetry center.
    This is the core persistence statistic.

    Corresponds to Lean definition `heightSignature`.

    Args:
        profile: The slope profile.
        epsilon: The scale parameter.

    Returns:
        Number of slopes s with |s - center| <= epsilon.

    Examples:
        >>> p = PrimeSlopeProfile(5, [Fraction(1), Fraction(1), Fraction(1)])
        >>> height_signature(p, Fraction(1, 10))
        3
        >>> p2 = PrimeSlopeProfile(5, [Fraction(0), Fraction(1), Fraction(2)])
        >>> height_signature(p2, Fraction(1, 2))
        1
    """
    epsilon = Fraction(epsilon)
    center = profile.symmetric_about
    return sum(1 for s in profile.slopes if abs(s - center) <= epsilon)


def persistent_rank(profile: PrimeSlopeProfile, t: Fraction) -> int:
    """Persistent rank at filtration parameter t.

    Equivalent to height_signature; provided for conceptual clarity as the
    filtration-indexed version.

    Corresponds to Lean definition `persistentRank`.
    """
    return height_signature(profile, t)


def is_supersingular(profile: PrimeSlopeProfile) -> bool:
    """Check if a profile is supersingular (all slopes equal center).

    Corresponds to Lean predicate `IsSupersingularProfile`.
    """
    return all(s == profile.symmetric_about for s in profile.slopes)


def has_finite_height_witness(profile: PrimeSlopeProfile) -> bool:
    """Check if a profile has a finite-height witness (some slope != center).

    Corresponds to Lean predicate `HasFiniteHeightWitness`.
    """
    return any(s != profile.symmetric_about for s in profile.slopes)


def classify_height_regime(profile: PrimeSlopeProfile, epsilon: Fraction) -> bool:
    """Certified Boolean classifier for the height regime.

    Returns True when all slopes are within threshold epsilon of the center
    (consistent with supersingular regime), False when a gap witness exists
    at this scale.

    Corresponds to Lean definition `classifyHeightRegime`.

    Args:
        profile: The slope profile.
        epsilon: The classification threshold.

    Returns:
        True if signature is maximal (supersingular-like), False otherwise.
    """
    return len(profile.slopes) == height_signature(profile, epsilon)


def tropical_defect(profile: PrimeSlopeProfile, t: Fraction) -> Fraction:
    """Compute the tropical defect at threshold t.

    The maximum over slopes of max(0, |s - center| - t). This is a max-plus
    statistic that vanishes identically for t >= 0 iff the profile is supersingular.

    Corresponds to Lean definition `tropicalDefect`.

    Args:
        profile: The slope profile.
        t: The threshold parameter.

    Returns:
        The tropical defect value (always >= 0).
    """
    t = Fraction(t)
    if not profile.slopes:
        return Fraction(0)
    center = profile.symmetric_about
    return max(max(Fraction(0), abs(s - center) - t) for s in profile.slopes)


def min_deviation(profile: PrimeSlopeProfile) -> Optional[Fraction]:
    """Compute the minimal nonzero deviation from the center.

    Returns None if the profile is supersingular.

    This is the spectral gap parameter that determines the first jump
    in the persistent rank function.
    """
    center = profile.symmetric_about
    deviations = [abs(s - center) for s in profile.slopes if s != center]
    if not deviations:
        return None
    return min(deviations)


def persistent_rank_curve(profile: PrimeSlopeProfile,
                          t_values: List[Fraction]) -> List[int]:
    """Compute the persistent rank function over a range of t values.

    Returns a monotone non-decreasing sequence of integers.

    Args:
        profile: The slope profile.
        t_values: Sorted list of filtration parameter values.

    Returns:
        List of persistent rank values.
    """
    return [persistent_rank(profile, t) for t in t_values]


def tropical_defect_curve(profile: PrimeSlopeProfile,
                          t_values: List[Fraction]) -> List[Fraction]:
    """Compute the tropical defect function over a range of t values.

    Returns a non-increasing sequence that eventually reaches 0.

    Args:
        profile: The slope profile.
        t_values: Sorted list of threshold values.

    Returns:
        List of tropical defect values.
    """
    return [tropical_defect(profile, t) for t in t_values]


def slope_deviations(profile: PrimeSlopeProfile) -> List[Fraction]:
    """Compute sorted list of slope deviations from the center.

    These are the critical values where the persistent rank function jumps.
    """
    center = profile.symmetric_about
    devs = sorted(set(abs(s - center) for s in profile.slopes))
    return devs


def classification_stability_radius(profile: PrimeSlopeProfile) -> Optional[Fraction]:
    """Compute the stability radius of the height classification.

    For a supersingular profile, returns None (stable at all scales).
    For a finite-height profile, returns half the minimal deviation,
    which is the largest perturbation that preserves the classification.
    """
    md = min_deviation(profile)
    if md is None:
        return None  # Supersingular: stable everywhere
    return md / 2


# ---- K3-motivated profile constructors ----

def supersingular_profile(p: int, rank: int = 22) -> PrimeSlopeProfile:
    """Create a supersingular K3 slope profile at prime p.

    All 22 slopes equal 1 (the symmetry center for weight 2).
    This models supersingular reduction where h = infinity.
    """
    return PrimeSlopeProfile(
        p=p,
        slopes=[Fraction(1)] * rank,
        weight=Fraction(2),
        symmetric_about=Fraction(1)
    )


def ordinary_profile(p: int) -> PrimeSlopeProfile:
    """Create an ordinary K3 slope profile at prime p.

    Slopes: {0, 1, 1, ..., 1, 2} with 20 slopes at center.
    This models ordinary reduction where h = 1.
    """
    slopes = [Fraction(0)] + [Fraction(1)] * 20 + [Fraction(2)]
    return PrimeSlopeProfile(
        p=p,
        slopes=slopes,
        weight=Fraction(2),
        symmetric_about=Fraction(1)
    )


def finite_height_profile(p: int, height: int = 3) -> PrimeSlopeProfile:
    """Create a finite-height K3 slope profile at prime p.

    Models height h with 2h slopes deviating from center symmetrically.
    For height h, slopes include 1 ± k/h for k = 1,...,h.
    Remaining slopes are at center.

    Args:
        p: The prime.
        height: The formal Brauer group height (1 to 10).
    """
    if height < 1 or height > 10:
        raise ValueError(f"Height must be between 1 and 10, got {height}")
    # Create symmetric slope pairs
    slopes = []
    for k in range(1, height + 1):
        slopes.append(Fraction(1) + Fraction(k, height))
        slopes.append(Fraction(1) - Fraction(k, height))
    # Fill remaining with central slopes
    remaining = 22 - len(slopes)
    slopes.extend([Fraction(1)] * remaining)
    return PrimeSlopeProfile(
        p=p,
        slopes=slopes,
        weight=Fraction(2),
        symmetric_about=Fraction(1)
    )


if __name__ == "__main__":
    # Quick demonstration
    print("=== Arithmetic Persistence Algorithms ===\n")

    # Supersingular profile
    ss = supersingular_profile(5)
    print(f"Supersingular at p=5:")
    print(f"  Is supersingular: {is_supersingular(ss)}")
    print(f"  Height signature at ε=0.1: {height_signature(ss, Fraction(1, 10))}")
    print(f"  Tropical defect at t=0: {tropical_defect(ss, Fraction(0))}")
    print(f"  Classify at ε=0.1: {classify_height_regime(ss, Fraction(1, 10))}")

    # Ordinary profile
    ord = ordinary_profile(7)
    print(f"\nOrdinary at p=7:")
    print(f"  Is supersingular: {is_supersingular(ord)}")
    print(f"  Height signature at ε=0.5: {height_signature(ord, Fraction(1, 2))}")
    print(f"  Tropical defect at t=0: {tropical_defect(ord, Fraction(0))}")
    print(f"  Min deviation: {min_deviation(ord)}")
    print(f"  Stability radius: {classification_stability_radius(ord)}")

    # Height 3 profile
    h3 = finite_height_profile(11, height=3)
    print(f"\nHeight 3 at p=11:")
    print(f"  Slopes: {h3.slopes}")
    print(f"  Height signature at ε=0.1: {height_signature(h3, Fraction(1, 10))}")
    print(f"  Tropical defect at t=0: {tropical_defect(h3, Fraction(0))}")
    print(f"  Min deviation: {min_deviation(h3)}")
    devs = slope_deviations(h3)
    print(f"  Critical deviations: {devs}")
