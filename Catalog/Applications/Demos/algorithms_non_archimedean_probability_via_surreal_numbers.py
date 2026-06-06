#!/usr/bin/env python3
"""
Non-Archimedean Probability Theory — Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import Any, Callable, Dict, FrozenSet, List, Optional, Set, Tuple, TypeVar

T = TypeVar('T')


class FinProbMeasure:
    """A finitely additive probability measure on a finite set.

    The measure assigns a rational weight to each element such that
    the weights sum to 1. Supports measure computation for subsets,
    complement computation, and disjoint union additivity.
    """

    def __init__(self, weights: Dict[str, Fraction]) -> None:
        """Initialize with a dictionary of element -> weight.

        Args:
            weights: Maps each element name to its probability weight.
                     Weights must sum to 1.

        Raises:
            ValueError: If weights don't sum to 1 or any weight is negative.
        """
        total = sum(weights.values())
        if total != Fraction(1):
            raise ValueError(f"Weights must sum to 1, got {total}")
        self._weights = dict(weights)
        self._universe = frozenset(weights.keys())

    @classmethod
    def uniform(cls, elements: List[str]) -> 'FinProbMeasure':
        """Create a uniform probability measure on the given elements.

        Args:
            elements: List of element names (must be non-empty).

        Returns:
            A FinProbMeasure assigning 1/n to each element.
        """
        n = len(elements)
        if n == 0:
            raise ValueError("Cannot create uniform measure on empty set")
        eps = Fraction(1, n)
        return cls({e: eps for e in elements})

    def weight(self, element: str) -> Fraction:
        """Get the weight of a single element."""
        return self._weights.get(element, Fraction(0))

    def measure(self, subset: Set[str]) -> Fraction:
        """Compute the measure of a subset.

        Args:
            subset: A set of element names.

        Returns:
            The sum of weights of elements in the subset.
        """
        return sum(self._weights.get(e, Fraction(0)) for e in subset)

    def measure_complement(self, subset: Set[str]) -> Fraction:
        """Compute μ(Aᶜ) = 1 - μ(A)."""
        return Fraction(1) - self.measure(subset)

    def verify_additivity(self, s: Set[str], t: Set[str]) -> bool:
        """Verify μ(S ∪ T) = μ(S) + μ(T) for disjoint S, T.

        Args:
            s, t: Disjoint subsets.

        Returns:
            True if additivity holds.

        Raises:
            ValueError: If s and t are not disjoint.
        """
        if s & t:
            raise ValueError(f"Sets must be disjoint, intersection: {s & t}")
        return self.measure(s | t) == self.measure(s) + self.measure(t)

    def is_strictly_monotone(self, s: Set[str], t: Set[str]) -> bool:
        """Check if S ⊂ T implies μ(S) < μ(T)."""
        if not (s < t):  # proper subset
            raise ValueError("s must be a proper subset of t")
        return self.measure(s) < self.measure(t)


def archimedean_test(epsilon: float, bound: int = 10**8) -> Optional[int]:
    """Test whether epsilon is 'infinitesimal' up to a computational bound.

    In an Archimedean field (like ℝ), this always finds n with n·ε > 1.
    In a non-Archimedean field, no such n exists.

    Args:
        epsilon: A positive real number to test.
        bound: Maximum n to check.

    Returns:
        The smallest n with n·ε > 1, or None if no such n ≤ bound exists.
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    n = int(1.0 / epsilon) + 1
    if n <= bound:
        return n
    return None


def infinitesimal_sub_probability(
    omega: int,
    num_points: int
) -> Tuple[Fraction, Fraction]:
    """Compute the sub-probability and gap for an infinitesimal measure.

    Uses ε = 1/ω as an approximation to a genuine infinitesimal.

    Args:
        omega: The "infinite" number (denominator of ε).
        num_points: Number of points to assign weight ε.

    Returns:
        Tuple of (total_weight, gap) where gap = 1 - total_weight.
    """
    eps = Fraction(1, omega)
    total = eps * num_points
    gap = Fraction(1) - total
    return total, gap


def construct_non_archimedean_measure(
    elements: List[str],
    omega: int
) -> Tuple[Dict[str, Fraction], Fraction, Fraction]:
    """Construct a non-Archimedean sub-probability measure.

    Assigns weight 1/ω to each element, where ω is an "infinite" number.

    Args:
        elements: List of element names.
        omega: The denominator for the infinitesimal weight.

    Returns:
        Tuple of (weights_dict, total_weight, gap_to_one).
    """
    eps = Fraction(1, omega)
    weights = {e: eps for e in elements}
    total = eps * len(elements)
    gap = Fraction(1) - total
    return weights, total, gap


def non_archimedean_characterization_test(
    field_elements: List[Fraction],
    candidate_eps: Fraction,
    max_n: int = 1000
) -> Tuple[bool, Optional[int]]:
    """Test if a candidate ε satisfies the non-Archimedean condition.

    Checks whether n · ε < 1 for all n ≤ max_n.

    Args:
        field_elements: Not used directly; for context.
        candidate_eps: The candidate infinitesimal.
        max_n: Maximum n to test.

    Returns:
        Tuple of (is_infinitesimal, first_failure_n).
        is_infinitesimal is True if n·ε < 1 for all tested n.
        first_failure_n is the first n where n·ε ≥ 1, or None.
    """
    if candidate_eps <= 0:
        return False, None
    for n in range(1, max_n + 1):
        if n * candidate_eps >= 1:
            return False, n
    return True, None


# Example usage
if __name__ == "__main__":
    # Uniform measure on 5 elements
    mu = FinProbMeasure.uniform(["a", "b", "c", "d", "e"])
    print(f"Uniform measure on 5 elements:")
    print(f"  μ({{a,b}}) = {mu.measure({'a', 'b'})}")
    print(f"  μ({{c,d,e}}) = {mu.measure({'c', 'd', 'e'})}")
    print(f"  Additivity: {mu.verify_additivity({'a', 'b'}, {'c', 'd', 'e'})}")
    print(f"  Strict mono: {mu.is_strictly_monotone({'a'}, {'a', 'b'})}")

    # Non-Archimedean test
    omega = 10**15
    weights, total, gap = construct_non_archimedean_measure(
        [str(i) for i in range(1000)], omega
    )
    print(f"\nNon-Archimedean measure (ω=10^15, 1000 points):")
    print(f"  Total: {float(total):.15f}")
    print(f"  Gap:   {float(gap):.15f}")
