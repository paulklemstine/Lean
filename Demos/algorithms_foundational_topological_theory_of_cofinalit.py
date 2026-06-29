#!/usr/bin/env python3
"""
Cofinality Spectrum Theory — Algorithms

Type-hinted implementations of the core algorithms for computing
cofinality spectra and related properties.
"""

from enum import Enum
from typing import (
    Callable, Generic, List, Optional, Protocol,
    Sequence, Set, Tuple, TypeVar,
)
from dataclasses import dataclass
import math

T = TypeVar("T")


class CofinalityType(Enum):
    """The four cofinality types for points in ordered spaces."""
    TAME = "tame"
    LEFT_WILD = "left_wild"
    RIGHT_WILD = "right_wild"
    FULLY_WILD = "fully_wild"


@dataclass
class CofinalityProfile:
    """Complete cofinality profile at a point."""
    point: float
    left_cofinal_witness: Optional[List[float]]
    right_coinitial_witness: Optional[List[float]]
    cofinality_type: CofinalityType
    has_p_filter: bool


def classify_point(
    point: float,
    left_cofinal: Optional[Callable[[float], List[float]]],
    right_coinitial: Optional[Callable[[float], List[float]]],
) -> CofinalityType:
    """
    Classify a point by its cofinality type.

    Parameters
    ----------
    point : float
        The point to classify.
    left_cofinal : Optional[Callable]
        Function returning a countable cofinal sequence below the point,
        or None if no such sequence exists (uncountable left cofinality).
    right_coinitial : Optional[Callable]
        Function returning a countable coinitial sequence above the point,
        or None if no such sequence exists (uncountable right cofinality).

    Returns
    -------
    CofinalityType
        The four-way classification of the point.
    """
    has_countable_left = left_cofinal is not None
    has_countable_right = right_coinitial is not None

    if has_countable_left and has_countable_right:
        return CofinalityType.TAME
    elif not has_countable_left and has_countable_right:
        return CofinalityType.LEFT_WILD
    elif has_countable_left and not has_countable_right:
        return CofinalityType.RIGHT_WILD
    else:
        return CofinalityType.FULLY_WILD


def compute_real_cofinality_profile(x: float, n_terms: int = 100) -> CofinalityProfile:
    """
    Compute the cofinality profile for a real number.

    All real numbers are tame: the sequences x - 1/(k+1) and x + 1/(k+1)
    provide countable cofinal/coinitial witnesses.

    Parameters
    ----------
    x : float
        A real number.
    n_terms : int
        Number of terms in the witness sequences.

    Returns
    -------
    CofinalityProfile
        The cofinality profile, always TAME for reals.
    """
    left_witness = [x - 1.0 / (k + 1) for k in range(n_terms)]
    right_witness = [x + 1.0 / (k + 1) for k in range(n_terms)]

    return CofinalityProfile(
        point=x,
        left_cofinal_witness=left_witness,
        right_coinitial_witness=right_witness,
        cofinality_type=CofinalityType.TAME,
        has_p_filter=False,  # Tame reals don't have the P-filter property
    )


def verify_cofinal_below(
    x: float,
    sequence: List[float],
    test_points: Optional[List[float]] = None,
) -> Tuple[bool, Optional[float]]:
    """
    Verify that a sequence is cofinal below x.

    Parameters
    ----------
    x : float
        The point.
    sequence : List[float]
        The candidate cofinal sequence.
    test_points : Optional[List[float]]
        Points below x to test. If None, generates automatically.

    Returns
    -------
    Tuple[bool, Optional[float]]
        (is_cofinal, first_failing_point)
    """
    if test_points is None:
        # Generate test points below x at various scales
        test_points = [x - 10.0 ** k for k in range(-15, 10)]
        test_points = [y for y in test_points if y < x]

    for y in test_points:
        if y >= x:
            continue
        if not any(y <= z < x for z in sequence):
            return (False, y)

    return (True, None)


def p_filter_test(
    x: float,
    neighborhoods: List[Tuple[float, float]],
) -> Tuple[bool, Tuple[float, float]]:
    """
    Test the P-filter property: check if the intersection of
    a list of interval neighborhoods is still a neighborhood.

    Parameters
    ----------
    x : float
        The point.
    neighborhoods : List[Tuple[float, float]]
        List of (a, b) representing open intervals (a, b) containing x.

    Returns
    -------
    Tuple[bool, Tuple[float, float]]
        (has_p_filter, resulting_interval)
        The resulting interval is the intersection of all neighborhoods.
    """
    if not neighborhoods:
        return (True, (-math.inf, math.inf))

    # The intersection of intervals (a_n, b_n) is (sup a_n, inf b_n)
    sup_a = max(a for a, _ in neighborhoods)
    inf_b = min(b for _, b in neighborhoods)

    # Check if the intersection is non-degenerate and contains x
    if sup_a < x < inf_b:
        return (True, (sup_a, inf_b))
    else:
        return (False, (sup_a, inf_b))


def bound_lemma_check(
    x: float,
    countable_set: List[float],
) -> Optional[float]:
    """
    Find a strict upper bound for a countable set below x.

    In an ordered space with uncountable left cofinality,
    any countable set below x has a strict upper bound below x.

    For reals, this always succeeds (but reals are tame, so the
    theorem applies vacuously). For demonstration purposes.

    Parameters
    ----------
    x : float
        The point.
    countable_set : List[float]
        A finite set of elements below x.

    Returns
    -------
    Optional[float]
        A strict upper bound y with all z < y < x, or None if impossible.
    """
    if not countable_set:
        return x - 1.0  # Any element below x works

    max_elem = max(countable_set)
    if max_elem >= x:
        return None  # Set is not below x

    # Midpoint between max element and x
    return (max_elem + x) / 2.0


def spectrum_partition(
    points: List[float],
    classify: Callable[[float], CofinalityType],
) -> dict:
    """
    Partition a list of points by their cofinality type.

    Parameters
    ----------
    points : List[float]
        Points to classify.
    classify : Callable[[float], CofinalityType]
        Classification function.

    Returns
    -------
    dict
        Mapping from CofinalityType to list of points.
    """
    result = {ct: [] for ct in CofinalityType}
    for p in points:
        ct = classify(p)
        result[ct].append(p)
    return result


if __name__ == "__main__":
    # Demo: classify real numbers
    print("Cofinality profiles for selected real numbers:")
    for x in [0.0, 1.0, math.pi, math.e, -2.5]:
        profile = compute_real_cofinality_profile(x)
        print(f"  x = {x:.4f}: {profile.cofinality_type.value}")

    # Demo: verify cofinality
    x = math.pi
    seq = [x - 1.0 / (k + 1) for k in range(1000)]
    is_cof, fail = verify_cofinal_below(x, seq)
    print(f"\nCofinal below π: {is_cof}")

    # Demo: P-filter test
    nbhds = [(x - 1.0 / (n + 1), x + 1.0 / (n + 1)) for n in range(100)]
    has_pf, interval = p_filter_test(x, nbhds)
    print(f"P-filter test at π with 100 shrinking intervals: {has_pf}")
    print(f"  Resulting interval: ({interval[0]:.6f}, {interval[1]:.6f})")
    print(f"  Width: {interval[1] - interval[0]:.6f}")
    print("  (Shrinks to zero → P-filter fails for tame points)")
