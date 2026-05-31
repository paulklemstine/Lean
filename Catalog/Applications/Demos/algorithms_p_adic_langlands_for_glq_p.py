#!/usr/bin/env python3
"""
Algorithms for the p-adic Langlands Correspondence for GL₂(ℚ_p).

Type-hinted implementations of Newton-Hodge polygon theory,
weak admissibility checking, and classification algorithms.
"""
from fractions import Fraction
from typing import List, Tuple, Optional
from dataclasses import dataclass


@dataclass(frozen=True)
class HodgeTateWeights:
    """Hodge-Tate weights (w₁ ≤ w₂) for a 2d p-adic representation."""
    w1: int
    w2: int

    def __post_init__(self) -> None:
        assert self.w1 <= self.w2, f"Weights not ordered: {self.w1} > {self.w2}"

    def tH(self) -> int:
        """Total Hodge number."""
        return self.w1 + self.w2

    def is_classical(self) -> bool:
        """Whether weights correspond to a modular form weight k ≥ 2."""
        return self.w1 == 0 and self.w2 >= 1

    def dual(self) -> "HodgeTateWeights":
        """Dual weights under V ↦ V*(1)."""
        return HodgeTateWeights(-self.w2, -self.w1)

    def hodge_polygon(self) -> List[Tuple[int, Fraction]]:
        """The Hodge polygon vertices: (0,0), (1,w₁), (2,w₁+w₂)."""
        return [(0, Fraction(0)),
                (1, Fraction(self.w1)),
                (2, Fraction(self.w1 + self.w2))]


@dataclass(frozen=True)
class NewtonSlopes:
    """Newton slopes (s₁ ≤ s₂) for a 2d filtered φ-module."""
    s1: Fraction
    s2: Fraction

    def __post_init__(self) -> None:
        assert self.s1 <= self.s2, f"Slopes not ordered: {self.s1} > {self.s2}"

    def tN(self) -> Fraction:
        """Total Newton number."""
        return self.s1 + self.s2

    def newton_polygon(self) -> List[Tuple[int, Fraction]]:
        """The Newton polygon vertices: (0,0), (1,s₁), (2,s₁+s₂)."""
        return [(0, Fraction(0)),
                (1, self.s1),
                (2, self.s1 + self.s2)]

    def tropical_invariant(self) -> Fraction:
        """Tropical invariant: min(s₁, s₂) = s₁ (since s₁ ≤ s₂)."""
        return self.s1


def check_weak_admissibility(
    weights: HodgeTateWeights,
    slopes: NewtonSlopes
) -> Tuple[bool, Optional[str]]:
    """
    Check if (weights, slopes) form a weakly admissible datum.

    Returns:
        (is_admissible, failure_reason)
    """
    # Check endpoint matching
    if slopes.tN() != Fraction(weights.tH()):
        return False, f"Endpoint mismatch: tN={slopes.tN()} != tH={weights.tH()}"

    # Check Newton above Hodge
    if slopes.s1 < Fraction(weights.w1):
        return False, f"Newton below Hodge: s₁={slopes.s1} < w₁={weights.w1}"

    return True, None


def classify_representation(
    weights: HodgeTateWeights,
    slopes: NewtonSlopes
) -> str:
    """
    Classify a weakly admissible datum as ordinary, supersingular,
    or non-ordinary with computed monodromy defect.
    """
    ok, reason = check_weak_admissibility(weights, slopes)
    if not ok:
        return f"NOT ADMISSIBLE: {reason}"

    if slopes.s1 == Fraction(weights.w1) and slopes.s2 == Fraction(weights.w2):
        return "ORDINARY"
    elif slopes.s1 == slopes.s2:
        return "SUPERSINGULAR"
    else:
        defect = slopes.s1 - Fraction(weights.w1)
        return f"NON-ORDINARY (monodromy_defect={defect})"


def monodromy_defect(
    weights: HodgeTateWeights,
    slopes: NewtonSlopes
) -> Fraction:
    """
    Compute the monodromy defect δ = s₁ - w₁.
    Satisfies: δ = s₁ - w₁ = w₂ - s₂ (symmetry).
    """
    return slopes.s1 - Fraction(weights.w1)


def enumerate_admissible_slopes(
    weights: HodgeTateWeights,
    max_denominator: int = 1
) -> List[NewtonSlopes]:
    """
    Enumerate all weakly admissible slope pairs with denominators ≤ max_denominator.
    Uses the interlacing constraint: w₁ ≤ s₁ ≤ (w₁+w₂)/2.
    """
    results: List[NewtonSlopes] = []
    total = Fraction(weights.tH())
    upper = total / 2

    for d in range(1, max_denominator + 1):
        lo = int(Fraction(weights.w1 * d).numerator)
        hi = int((upper * d).numerator)
        for num in range(lo, hi + 1):
            s1 = Fraction(num, d)
            s2 = total - s1
            if s1 <= s2 and s1 >= Fraction(weights.w1):
                results.append(NewtonSlopes(s1, s2))

    # Deduplicate
    seen = set()
    unique = []
    for s in results:
        key = (s.s1, s.s2)
        if key not in seen:
            seen.add(key)
            unique.append(s)

    return sorted(unique, key=lambda s: s.s1)


def filtration_jumps(
    weights: HodgeTateWeights,
    a: int,
    b: int
) -> int:
    """Count filtration jumps in [a, b] for the given weights."""
    count = 0
    if a <= weights.w1 <= b:
        count += 1
    if a <= weights.w2 <= b:
        count += 1
    return count


def newton_above_hodge_check(
    weights: HodgeTateWeights,
    slopes: NewtonSlopes
) -> bool:
    """Verify Newton polygon is ≥ Hodge polygon at all evaluation points."""
    hp = weights.hodge_polygon()
    np_ = slopes.newton_polygon()
    return all(np_[i][1] >= hp[i][1] for i in range(3))


def slope_interlacing_check(
    weights: HodgeTateWeights,
    slopes: NewtonSlopes
) -> bool:
    """Verify the full interlacing: w₁ ≤ s₁ ≤ s₂ ≤ w₂."""
    return (Fraction(weights.w1) <= slopes.s1 <= slopes.s2 <= Fraction(weights.w2))


def breuil_mezard_multiplicity(p: int, alpha_is_pm_one: bool) -> int:
    """
    Breuil-Mézard multiplicity for weight 2 deformation rings.

    Args:
        p: prime number
        alpha_is_pm_one: whether the Frobenius eigenvalue ratio is ±1

    Returns:
        multiplicity (1 or 2)
    """
    return 2 if alpha_is_pm_one else 1


def sen_polynomial_coefficients(weights: HodgeTateWeights) -> List[int]:
    """
    Compute coefficients of the Sen polynomial (X + w₁)(X + w₂).
    Returns [constant, linear, quadratic] = [w₁w₂, w₁+w₂, 1].
    """
    return [weights.w1 * weights.w2, weights.w1 + weights.w2, 1]


if __name__ == "__main__":
    # Self-test
    w = HodgeTateWeights(0, 3)
    slopes = enumerate_admissible_slopes(w, max_denominator=2)
    print(f"Admissible slopes for weights {w}:")
    for s in slopes:
        cls = classify_representation(w, s)
        print(f"  {s} -> {cls}")

    # Verify duality involution
    assert w.dual().dual() == w
    print(f"\nDuality involution verified for {w}")

    # Verify Sen polynomial
    coeffs = sen_polynomial_coefficients(w)
    print(f"Sen polynomial for {w}: X² + {coeffs[1]}X + {coeffs[0]}")
    print("All tests passed.")
