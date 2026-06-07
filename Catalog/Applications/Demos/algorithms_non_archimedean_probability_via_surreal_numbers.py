"""
Non-Archimedean Probability: Core Algorithms

Type-hinted implementations of the key algorithms from the research.
"""

from fractions import Fraction
from typing import FrozenSet, Set, Dict, TypeVar, Callable

T = TypeVar('T')


def uniform_inf_measure(epsilon: Fraction, S: Set[T]) -> Fraction:
    """
    Compute the uniform infinitesimal measure of a finite set.

    μ_ε(S) = |S| · ε

    Args:
        epsilon: The infinitesimal weight (positive element of the field)
        S: A finite set

    Returns:
        The measure |S| · ε
    """
    return len(S) * epsilon


def weighted_measure(weights: Dict[T, Fraction], S: Set[T]) -> Fraction:
    """
    Compute the weighted measure of a finite set.

    μ_w(S) = Σ_{x ∈ S} w(x)

    Args:
        weights: Weight function mapping elements to field values
        S: A finite set (subset of the weight function's domain)

    Returns:
        The sum of weights over S
    """
    return sum(weights.get(x, Fraction(0)) for x in S)


def conditional_probability(
    measure: Callable[[Set[T]], Fraction],
    A: Set[T],
    B: Set[T]
) -> Fraction:
    """
    Compute conditional probability P(A|B) = μ(A∩B) / μ(B).

    For uniform infinitesimal measures, this equals |A∩B|/|B|,
    independent of the infinitesimal (universality theorem).

    Args:
        measure: A finitely additive measure function
        A: The event to condition on
        B: The conditioning event (must have positive measure)

    Returns:
        P(A|B) = μ(A∩B) / μ(B)

    Raises:
        ZeroDivisionError: if μ(B) = 0
    """
    return measure(A & B) / measure(B)


def is_infinitesimal(epsilon: Fraction, bound: int = 10000) -> bool:
    """
    Test whether ε satisfies the infinitesimal condition up to bound n.

    An element ε is infinitesimal if:
    1. ε > 0
    2. ε < 1/(n+1) for all n ∈ ℕ

    In a rational (Archimedean) field, this always returns False for
    sufficiently large bound. In a genuine non-Archimedean field,
    it would return True for all bounds.

    Args:
        epsilon: Element to test
        bound: Maximum n to check

    Returns:
        True if ε > 0 and ε < 1/(n+1) for all n ≤ bound
    """
    if epsilon <= 0:
        return False
    return all(epsilon < Fraction(1, n + 1) for n in range(bound))


def archimedean_bound(epsilon: Fraction) -> int:
    """
    Find the smallest N such that N · ε ≥ 1.

    By the Archimedean property of ℚ, such N always exists for ε > 0.
    This is Theorem 5 (archimedean_measure_bound).

    Args:
        epsilon: A positive rational number

    Returns:
        Smallest N with N · ε ≥ 1
    """
    if epsilon <= 0:
        raise ValueError("epsilon must be positive")
    N = 1
    while N * epsilon < 1:
        N += 1
    return N


def infinitesimal_stratification(
    epsilon: Fraction,
    order: int
) -> Fraction:
    """
    Compute ε^order, the order-k infinitesimal.

    By Theorem 4, if ε is infinitesimal, then ε^k is infinitesimal
    for all k ≥ 1, and ε^{k+1} is dominated by ε^k:
    (n+1) · ε^{k+1} < ε^k for all n.

    Args:
        epsilon: The base infinitesimal
        order: The power k ≥ 1

    Returns:
        ε^k
    """
    result = Fraction(1)
    for _ in range(order):
        result *= epsilon
    return result


def verify_finite_additivity(
    epsilon: Fraction,
    S: Set[int],
    T: Set[int]
) -> bool:
    """
    Verify that μ_ε(S∪T) = μ_ε(S) + μ_ε(T) for disjoint S, T.

    This is Theorem 2 (uniform_inf_measure_additive).

    Args:
        epsilon: Weight parameter
        S, T: Disjoint finite sets

    Returns:
        True if additivity holds (always True for disjoint sets)
    """
    if S & T:
        raise ValueError("Sets must be disjoint")
    lhs = uniform_inf_measure(epsilon, S | T)
    rhs = uniform_inf_measure(epsilon, S) + uniform_inf_measure(epsilon, T)
    return lhs == rhs


if __name__ == "__main__":
    # Quick verification
    eps = Fraction(1, 10**9)

    # Finite additivity
    S, T = {0, 1, 2}, {3, 4}
    assert verify_finite_additivity(eps, S, T)

    # Conditional universality
    A, B = {0, 1}, {0, 1, 2, 3}
    for N in [7, 100, 10**6]:
        e = Fraction(1, N)
        mu = lambda s, e=e: uniform_inf_measure(e, s)
        cp = conditional_probability(mu, A, B)
        assert cp == Fraction(1, 2)  # |A∩B|/|B| = 2/4 = 1/2

    # Archimedean bound
    assert archimedean_bound(Fraction(1, 100)) == 100

    print("All algorithm tests passed.")
