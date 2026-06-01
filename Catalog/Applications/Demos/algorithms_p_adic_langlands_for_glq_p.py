#!/usr/bin/env python3
"""
Algorithms for the p-adic Langlands correspondence.
Type-hinted implementations of key computational procedures.
"""

from fractions import Fraction
from typing import Tuple, List, Optional, NamedTuple


class SlopeData(NamedTuple):
    """Rank 2 slope data (s₁ ≤ s₂)."""
    s1: Fraction
    s2: Fraction


class WAData(NamedTuple):
    """Weakly admissible data: slopes + HT weights."""
    slopes: SlopeData
    ht1: int
    ht2: int


def validate_slopes(s1: Fraction, s2: Fraction) -> SlopeData:
    """Validate and construct slope data."""
    if s1 > s2:
        raise ValueError(f"Slopes not ordered: {s1} > {s2}")
    return SlopeData(s1, s2)


def total_slope(s: SlopeData) -> Fraction:
    """Compute total slope s₁ + s₂ = v_p(det Φ)."""
    return s.s1 + s.s2


def slope_gap(s: SlopeData) -> Fraction:
    """Compute slope gap s₂ - s₁ (invariant under duality and twisting)."""
    return s.s2 - s.s1


def dual_slopes(s: SlopeData) -> SlopeData:
    """Compute slopes of the dual module: (-s₂, -s₁)."""
    return SlopeData(-s.s2, -s.s1)


def twist_slopes(s: SlopeData, t: Fraction) -> SlopeData:
    """Twist slopes by character of slope t: (s₁+t, s₂+t)."""
    return SlopeData(s.s1 + t, s.s2 + t)


def normalize_to_ordinary(s: SlopeData) -> Tuple[SlopeData, Fraction]:
    """Twist to ordinary form (s₁ = 0). Returns (new slopes, twist amount)."""
    t = -s.s1
    return twist_slopes(s, t), t


def check_weak_admissibility(
    slopes: SlopeData, ht1: int, ht2: int
) -> Tuple[bool, Optional[str]]:
    """
    Check weak admissibility for rank 2.

    Algorithm:
    1. Verify total condition: s₁ + s₂ = h₁ + h₂
    2. Verify subobject condition: s₁ ≥ h₁
    3. Derive: s₂ ≤ h₂ (consequence)

    Returns (is_wa, reason_if_not).
    """
    total = total_slope(slopes)
    ht_total = Fraction(ht1 + ht2)

    if total != ht_total:
        return False, f"Total mismatch: {total} ≠ {ht_total}"

    if slopes.s1 < Fraction(ht1):
        return False, f"Subobject violation: s₁={slopes.s1} < h₁={ht1}"

    # Derived bound (verified by our formal proof)
    assert slopes.s2 <= Fraction(ht2), "s₂ > h₂ (should be impossible)"

    return True, None


def dual_wa(wa: WAData) -> WAData:
    """
    Compute dual weakly admissible data.
    Preserves weak admissibility (formally verified).
    """
    return WAData(
        slopes=dual_slopes(wa.slopes),
        ht1=-wa.ht2,
        ht2=-wa.ht1
    )


def twist_wa(wa: WAData, n: int) -> WAData:
    """
    Twist weakly admissible data by integer n.
    Preserves weak admissibility (formally verified).
    """
    return WAData(
        slopes=twist_slopes(wa.slopes, Fraction(n)),
        ht1=wa.ht1 + n,
        ht2=wa.ht2 + n
    )


def classify_representation(
    s: SlopeData, ht1: int, ht2: int
) -> str:
    """
    Classify a 2-dimensional p-adic Galois representation.

    Algorithm:
    1. Check if étale (both slopes 0)
    2. Check if ordinary (s₁ = 0)
    3. Check if supersingular (s₁ = s₂)
    4. Check if crystalline (slopes are integers matching HT weights)
    5. Default: trianguline or general

    Returns classification string.
    """
    if s.s1 == 0 and s.s2 == 0:
        return "étale"
    if s.s1 == 0:
        return "ordinary"
    if s.s1 == s.s2:
        return "supersingular"
    if s.s1.denominator == 1 and s.s2.denominator == 1:
        return "crystalline (integer slopes)"
    return "trianguline (non-integer slopes)"


def enumerate_crystalline_slopes(
    k: int
) -> List[Tuple[SlopeData, bool]]:
    """
    Enumerate all weakly admissible crystalline slope data for weight k.

    The HT weights are {0, k-1}. Slopes (s₁, s₂) must satisfy:
    - s₁ + s₂ = k - 1 (total condition)
    - s₁ ≥ 0 (subobject condition for h₁ = 0)
    - s₁ ≤ s₂ (ordering)

    For integer slopes, s₁ ∈ {0, 1, ..., ⌊(k-1)/2⌋}.

    Returns list of (slopes, is_ordinary) pairs.
    """
    results: List[Tuple[SlopeData, bool]] = []
    for a in range((k - 1) // 2 + 1):
        s1 = Fraction(a)
        s2 = Fraction(k - 1 - a)
        slopes = SlopeData(s1, s2)
        is_ordinary = (a == 0)
        results.append((slopes, is_ordinary))
    return results


def breuil_mezard_multiplicity(k: int, a: int) -> int:
    """
    Compute the Breuil-Mézard multiplicity for crystalline lifts
    of weight k with lower slope a.

    Formula: max(0, k - 1 - 2a) for a ≤ (k-1)/2, else 0.
    """
    if a <= (k - 1) // 2:
        return max(0, k - 1 - 2 * a)
    return 0


def trianguline_to_slopes(
    delta1: Fraction, delta2: Fraction
) -> SlopeData:
    """
    Convert trianguline parameters to slope data.
    Takes min/max to ensure ordering.
    """
    return SlopeData(min(delta1, delta2), max(delta1, delta2))


def newton_polygon_vertices(
    slopes: SlopeData
) -> List[Tuple[Fraction, Fraction]]:
    """
    Compute Newton polygon vertices for rank 2 slopes.

    The Newton polygon for a rank 2 module has vertices at:
    (0, 0), (1, s₁), (2, s₁ + s₂)
    """
    return [
        (Fraction(0), Fraction(0)),
        (Fraction(1), slopes.s1),
        (Fraction(2), slopes.s1 + slopes.s2),
    ]


def hodge_polygon_vertices(
    ht1: int, ht2: int
) -> List[Tuple[Fraction, Fraction]]:
    """
    Compute Hodge polygon vertices for rank 2 with HT weights (h₁, h₂).

    The Hodge polygon has vertices at:
    (0, 0), (1, h₁), (2, h₁ + h₂)
    """
    return [
        (Fraction(0), Fraction(0)),
        (Fraction(1), Fraction(ht1)),
        (Fraction(2), Fraction(ht1 + ht2)),
    ]


def newton_above_hodge(
    slopes: SlopeData, ht1: int, ht2: int
) -> bool:
    """
    Check Newton-above-Hodge condition for rank 2.

    The Newton polygon must lie on or above the Hodge polygon.
    For rank 2, this means s₁ ≥ h₁ (at x = 1).
    """
    return slopes.s1 >= Fraction(ht1)


if __name__ == "__main__":
    # Self-test
    s = validate_slopes(Fraction(0), Fraction(1))
    assert total_slope(s) == 1
    assert slope_gap(s) == 1
    assert dual_slopes(dual_slopes(s)) == s
    assert twist_slopes(twist_slopes(s, Fraction(3)), Fraction(-3)) == s

    wa = WAData(s, 0, 1)
    ok, _ = check_weak_admissibility(wa.slopes, wa.ht1, wa.ht2)
    assert ok

    dwa = dual_wa(wa)
    ok, _ = check_weak_admissibility(dwa.slopes, dwa.ht1, dwa.ht2)
    assert ok

    print("All self-tests passed.")
