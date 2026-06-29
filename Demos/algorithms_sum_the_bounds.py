#!/usr/bin/env python3
"""
Algorithms for extensive complexity accumulation.

Implements the summation bound framework computationally, including:
- Uniform bound computation
- Bridge theorem application
- Tightness analysis
- Weighted extensions
"""

from typing import Callable, List, Sequence, Tuple
import math


def uniform_sum_bound(lengths: Sequence[float], C: float) -> Tuple[float, float, bool]:
    """
    Apply the uniform summation bound.

    Given a sequence of lengths and a per-element bound C,
    compute the total, the bound T*C, and verify the bound holds.

    Args:
        lengths: Sequence of per-step lengths.
        C: Uniform upper bound on each length.

    Returns:
        (total, bound, holds): The actual total, the bound T*C,
        and whether the bound is satisfied.

    Raises:
        ValueError: If any length exceeds C.

    Example:
        >>> uniform_sum_bound([1, 3, 2, 4, 1], 5)
        (11, 25, True)
    """
    T = len(lengths)
    total = sum(lengths)
    bound = T * C

    # Verify precondition
    for i, l in enumerate(lengths):
        if l > C + 1e-12:  # small tolerance for floating point
            raise ValueError(f"Length at index {i} is {l}, exceeding bound C={C}")

    return total, bound, total <= bound + 1e-12


def bridge_bound(
    lengths: Sequence[float],
    intermediate_bounds: Sequence[float],
    C: float
) -> Tuple[float, float, float, bool]:
    """
    Apply the bridge theorem: ℓ(t) ≤ b(t) ≤ C implies ∑ℓ ≤ T*C.

    Args:
        lengths: Actual per-step lengths.
        intermediate_bounds: Per-step bounds from a catalog theorem.
        C: Uniform bound on the intermediate bounds.

    Returns:
        (total_lengths, total_bounds, uniform_bound, holds)

    Example:
        >>> bridge_bound([1, 2, 3], [3, 4, 5], 5)
        (6, 12, 15, True)
    """
    T = len(lengths)
    assert len(intermediate_bounds) == T

    total_l = sum(lengths)
    total_b = sum(intermediate_bounds)
    bound = T * C

    # Verify chain: ℓ(t) ≤ b(t) ≤ C
    for i in range(T):
        assert lengths[i] <= intermediate_bounds[i] + 1e-12, \
            f"ℓ({i}) = {lengths[i]} > b({i}) = {intermediate_bounds[i]}"
        assert intermediate_bounds[i] <= C + 1e-12, \
            f"b({i}) = {intermediate_bounds[i]} > C = {C}"

    return total_l, total_b, bound, total_l <= bound + 1e-12


def pointwise_comparison(
    f: Sequence[float],
    g: Sequence[float]
) -> Tuple[float, float, bool]:
    """
    Pointwise comparison principle: if f(a) ≤ g(a) for all a, then ∑f ≤ ∑g.

    Args:
        f: First sequence (lower bounds).
        g: Second sequence (upper bounds).

    Returns:
        (sum_f, sum_g, holds)

    Example:
        >>> pointwise_comparison([1, 2, 3], [4, 5, 6])
        (6, 15, True)
    """
    assert len(f) == len(g)
    for i in range(len(f)):
        assert f[i] <= g[i] + 1e-12, f"f({i}) = {f[i]} > g({i}) = {g[i]}"

    sum_f = sum(f)
    sum_g = sum(g)
    return sum_f, sum_g, sum_f <= sum_g + 1e-12


def tightness_ratio(lengths: Sequence[float], C: float) -> float:
    """
    Compute the tightness ratio ∑ℓ / (T*C).

    A ratio of 1.0 means the bound is tight; lower means more slack.

    Args:
        lengths: Per-step lengths.
        C: Uniform bound.

    Returns:
        Ratio in [0, 1].
    """
    T = len(lengths)
    if T == 0 or C == 0:
        return 0.0
    return sum(lengths) / (T * C)


def weighted_sum_bound(
    lengths: Sequence[float],
    weights: Sequence[float]
) -> Tuple[float, float, bool]:
    """
    Weighted comparison: if ℓ(t) ≤ w(t) for all t, then ∑ℓ ≤ ∑w.

    This is the non-uniform version of the summation bound, where each
    step may have a different bound.

    Args:
        lengths: Actual per-step lengths.
        weights: Per-step bounds.

    Returns:
        (total_lengths, total_weights, holds)

    Example:
        >>> weighted_sum_bound([1, 3, 2], [2, 5, 4])
        (6, 11, True)
    """
    return pointwise_comparison(lengths, weights)


def golay_block_total(T: int) -> int:
    """
    Compute total length of T Golay code blocks.

    Each Golay block has length 24 = 2 * 12.

    Args:
        T: Number of blocks.

    Returns:
        T * 24

    Example:
        >>> golay_block_total(10)
        240
    """
    return T * 24


def average_length_bound(
    lengths: Sequence[float],
    C: float
) -> Tuple[float, float, bool]:
    """
    Average length bound: if ℓ(t) ≤ C for all t, then (∑ℓ)/T ≤ C.

    Args:
        lengths: Per-step lengths.
        C: Uniform bound.

    Returns:
        (average, C, holds)

    Example:
        >>> average_length_bound([1, 3, 2, 4], 5)
        (2.5, 5, True)
    """
    T = len(lengths)
    if T == 0:
        return 0.0, C, True
    avg = sum(lengths) / T
    return avg, C, avg <= C + 1e-12


if __name__ == "__main__":
    # Example usage
    print("Uniform bound:", uniform_sum_bound([1, 3, 2, 4, 1], 5))
    print("Bridge bound:", bridge_bound([1, 2, 3], [3, 4, 5], 5))
    print("Pointwise:", pointwise_comparison([1, 2, 3], [4, 5, 6]))
    print("Golay total:", golay_block_total(100))
    print("Average bound:", average_length_bound([1, 3, 2, 4], 5))
    print("Tightness:", tightness_ratio([1, 3, 2, 4, 1], 5))
