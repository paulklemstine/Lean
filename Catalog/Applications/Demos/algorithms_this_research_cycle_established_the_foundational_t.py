"""
Algorithms for Surreal Topology: Order Gaps, Cofinality, and Connectedness.

This module implements computational tools for exploring the topology of
ordered spaces, including gap detection, cofinality computation, and
connectedness testing.
"""

from typing import List, Tuple, Optional, Set, Callable
from fractions import Fraction
import math


def detect_order_gap(
    elements: List[Fraction],
    cut_value: float
) -> Tuple[List[Fraction], List[Fraction], bool]:
    """
    Detect a Dedekind gap at a given cut value in a set of rationals.

    A gap exists when the cut value is irrational (not equal to any element)
    and the lower/upper sets have no max/min respectively.

    Parameters
    ----------
    elements : List[Fraction]
        Sorted list of rational numbers.
    cut_value : float
        The value at which to attempt the cut (e.g., sqrt(2)).

    Returns
    -------
    lower : List[Fraction]
        Elements below the cut.
    upper : List[Fraction]
        Elements above the cut.
    is_gap : bool
        True if this forms a proper gap (no element equals the cut value).
    """
    lower = [x for x in elements if float(x) < cut_value]
    upper = [x for x in elements if float(x) > cut_value]
    on_cut = [x for x in elements if float(x) == cut_value]
    is_gap = len(on_cut) == 0 and len(lower) > 0 and len(upper) > 0
    return lower, upper, is_gap


def compute_coinitiality_witness(
    elements: List[Fraction],
    point: Fraction,
    max_depth: int = 100
) -> Tuple[List[Fraction], bool]:
    """
    Attempt to find a countable coinitial sequence above a point.

    For rational approximations, this always succeeds (rationals have
    countable coinitiality). For surreal-like structures, it would fail
    at uncountable coinitiality points.

    Parameters
    ----------
    elements : List[Fraction]
        Pool of elements to draw from.
    point : Fraction
        The reference point.
    max_depth : int
        Maximum sequence length.

    Returns
    -------
    sequence : List[Fraction]
        Decreasing sequence approaching point from above.
    is_coinitial : bool
        True if the sequence appears coinitial.
    """
    above = sorted([x for x in elements if x > point])
    if not above:
        return [], False

    sequence = []
    current_min = above[0]
    for x in above:
        if x <= current_min:
            current_min = x
            sequence.append(x)
        if len(sequence) >= max_depth:
            break

    # Check coinitiality: is every element above point bounded below by some sequence element?
    is_coinitial = all(
        any(s <= x for s in sequence)
        for x in above
    )
    return sequence, is_coinitial


def test_connectedness_rational_cut(
    cut_value: float,
    density: int = 1000,
    bound: int = 10
) -> dict:
    """
    Test disconnectedness of Q at an irrational cut.

    Generates a dense subset of Q in [-bound, bound] and checks if the
    cut at cut_value produces a proper gap (disconnection).

    Parameters
    ----------
    cut_value : float
        The irrational number at which to cut (e.g., sqrt(2)).
    density : int
        Number of rationals to generate per unit interval.
    bound : int
        Range [-bound, bound] for generating rationals.

    Returns
    -------
    dict with keys:
        'lower_count', 'upper_count', 'is_gap', 'cut_value',
        'lower_max', 'upper_min'
    """
    # Generate dense rationals
    elements = []
    for denom in range(1, density + 1):
        for numer in range(-bound * denom, bound * denom + 1):
            elements.append(Fraction(numer, denom))
    elements = sorted(set(elements))

    lower, upper, is_gap = detect_order_gap(elements, cut_value)

    result = {
        'cut_value': cut_value,
        'total_elements': len(elements),
        'lower_count': len(lower),
        'upper_count': len(upper),
        'is_gap': is_gap,
    }
    if lower:
        result['lower_max'] = float(max(lower))
    if upper:
        result['upper_min'] = float(min(upper))
    if lower and upper:
        result['gap_width'] = float(min(upper)) - float(max(lower))

    return result


def gap_free_check(
    elements: List[Fraction],
    test_cuts: List[float]
) -> Tuple[bool, Optional[float]]:
    """
    Check if a finite ordered set appears gap-free by testing multiple cuts.

    Parameters
    ----------
    elements : List[Fraction]
        Sorted list of rational numbers.
    test_cuts : List[float]
        Values at which to test for gaps.

    Returns
    -------
    is_gap_free : bool
        True if no gap found at any test cut.
    first_gap : Optional[float]
        The first cut value where a gap was found, if any.
    """
    for cut in test_cuts:
        _, _, is_gap = detect_order_gap(elements, cut)
        if is_gap:
            return False, cut
    return True, None


def dyadic_approximation_sequence(
    x: float,
    max_depth: int = 20
) -> List[Fraction]:
    """
    Compute the dyadic approximation sequence converging to x.

    This implements the surreal number construction: at each stage,
    the simplest dyadic rational in the interval is chosen.

    Parameters
    ----------
    x : float
        Target real number.
    max_depth : int
        Maximum number of approximation stages.

    Returns
    -------
    List[Fraction]
        Sequence of dyadic rational approximations.
    """
    sequence = []
    for n in range(max_depth):
        denom = 2 ** n
        best = None
        best_dist = float('inf')
        for k in range(-denom * (int(abs(x)) + 2), denom * (int(abs(x)) + 2) + 1):
            candidate = Fraction(k, denom)
            dist = abs(float(candidate) - x)
            if dist < best_dist:
                best_dist = dist
                best = candidate
        if best is not None and (not sequence or best != sequence[-1]):
            sequence.append(best)
    return sequence


def order_topology_basis(
    elements: List[Fraction],
) -> List[Tuple[Fraction, Fraction]]:
    """
    Compute the open interval basis for the order topology on a finite set.

    Parameters
    ----------
    elements : List[Fraction]
        Sorted list of elements.

    Returns
    -------
    List of (a, b) pairs representing open intervals (a, b) that form
    a topological basis.
    """
    elements = sorted(set(elements))
    basis = []
    for i in range(len(elements)):
        for j in range(i + 1, len(elements)):
            # Only include if there's actually an element between
            between = [x for x in elements if elements[i] < x < elements[j]]
            if between:
                basis.append((elements[i], elements[j]))
    return basis


def connected_components_discrete(
    elements: List[int]
) -> List[List[int]]:
    """
    Compute connected components of a subset of Z with order topology.

    In Z, the order topology is discrete, so connected components are
    maximal intervals of consecutive integers.

    Parameters
    ----------
    elements : List[int]
        Subset of integers.

    Returns
    -------
    List of connected components (maximal consecutive runs).
    """
    if not elements:
        return []
    elements = sorted(set(elements))
    components = [[elements[0]]]
    for i in range(1, len(elements)):
        if elements[i] == elements[i-1] + 1:
            components[-1].append(elements[i])
        else:
            components.append([elements[i]])
    return components
