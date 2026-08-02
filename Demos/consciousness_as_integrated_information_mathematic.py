#!/usr/bin/env python3
"""Numerical demonstrations of integrated information as a directed minimum cut.

The script uses only the Python standard library. It exhaustively evaluates all
nonempty proper subsets, reports a minimum-information partition, checks the
cut-connectivity equivalence, and demonstrates multiplicative approximation
transfer on a concrete surrogate.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from math import isclose
from typing import Callable, Iterable, Iterator, Sequence

Matrix = Sequence[Sequence[float]]
Subset = frozenset[int]
CutFunction = Callable[[Subset], float]


@dataclass(frozen=True)
class MinimumPartition:
    """The value and a witness attaining a finite cut minimum."""

    value: float
    subset: Subset


def validate_weights(weights: Matrix) -> None:
    """Require a square nonnegative matrix with at least two vertices."""
    n = len(weights)
    if n < 2:
        raise ValueError("A system must contain at least two components.")
    if any(len(row) != n for row in weights):
        raise ValueError("The weight matrix must be square.")
    if any(value < 0 for row in weights for value in row):
        raise ValueError("Interaction weights must be nonnegative.")


def admissible_subsets(n: int) -> Iterator[Subset]:
    """Generate every nonempty proper subset of {0, ..., n - 1}."""
    if n < 2:
        raise ValueError("At least two components are required.")
    vertices = range(n)
    for size in range(1, n):
        for chosen in combinations(vertices, size):
            yield frozenset(chosen)


def directed_cut_weight(weights: Matrix, subset: Subset) -> float:
    """Sum all weights directed from subset to its complement."""
    n = len(weights)
    return sum(
        weights[i][j]
        for i in subset
        for j in range(n)
        if j not in subset
    )


def minimize_cuts(n: int, cut_value: CutFunction) -> MinimumPartition:
    """Exhaustively minimize a cut function over nontrivial bipartitions."""
    iterator = admissible_subsets(n)
    first = next(iterator)
    best = MinimumPartition(float(cut_value(first)), first)
    for subset in iterator:
        value = float(cut_value(subset))
        if value < best.value:
            best = MinimumPartition(value, subset)
    return best


def integrated_information(weights: Matrix) -> MinimumPartition:
    """Compute weighted integrated information and one minimizing partition."""
    validate_weights(weights)
    return minimize_cuts(
        len(weights), lambda subset: directed_cut_weight(weights, subset)
    )


def is_cut_connected(weights: Matrix, tolerance: float = 1e-12) -> bool:
    """Return whether every nontrivial cut has positive outgoing weight."""
    validate_weights(weights)
    return all(
        directed_cut_weight(weights, subset) > tolerance
        for subset in admissible_subsets(len(weights))
    )


def format_subset(subset: Iterable[int]) -> str:
    """Format a subset using mathematical braces."""
    return "{" + ", ".join(str(i) for i in sorted(subset)) + "}"


def print_cut_table(weights: Matrix) -> None:
    """Print all directed cut values for a small matrix."""
    for subset in admissible_subsets(len(weights)):
        value = directed_cut_weight(weights, subset)
        print(f"  A = {format_subset(subset):9s}  C_w(A) = {value:.3f}")


def demonstrate_network(name: str, weights: Matrix) -> None:
    """Report all cuts and test positivity against cut-connectivity."""
    result = integrated_information(weights)
    connected = is_cut_connected(weights)
    print(f"\n{name}")
    print("-" * len(name))
    print_cut_table(weights)
    print(
        f"Phi = {result.value:.3f}, attained at "
        f"A* = {format_subset(result.subset)}"
    )
    print(f"Every nontrivial cut is positive: {connected}")
    print(
        "The equivalence Phi > 0 iff cut-connected holds: "
        f"{(result.value > 0) == connected}"
    )


def demonstrate_approximation(weights: Matrix, factor: float = 1.5) -> None:
    """Check approximation transfer for a nonuniform bounded surrogate.

    The multiplier depends on subset parity but always lies in [1, factor].
    This allows the surrogate minimizer to differ while preserving the theorem's
    pointwise assumptions.
    """
    if factor < 1:
        raise ValueError("The approximation factor must be at least one.")
    validate_weights(weights)
    n = len(weights)

    def original(subset: Subset) -> float:
        return directed_cut_weight(weights, subset)

    def surrogate(subset: Subset) -> float:
        fraction = (sum(subset) % 3) / 2.0
        multiplier = 1.0 + (factor - 1.0) * fraction
        return multiplier * original(subset)

    for subset in admissible_subsets(n):
        true_value = original(subset)
        approx_value = surrogate(subset)
        assert true_value <= approx_value + 1e-12
        assert approx_value <= factor * true_value + 1e-12

    true_min = minimize_cuts(n, original)
    surrogate_min = minimize_cuts(n, surrogate)
    lower_ok = true_min.value <= surrogate_min.value + 1e-12
    upper_ok = surrogate_min.value <= factor * true_min.value + 1e-12

    print("\nMultiplicative approximation transfer")
    print("-------------------------------------")
    print(f"Original Phi:  {true_min.value:.3f}")
    print(f"Surrogate Phi: {surrogate_min.value:.3f}")
    print(
        f"Certified interval: [{true_min.value:.3f}, "
        f"{factor * true_min.value:.3f}]"
    )
    print(f"Lower bound satisfied: {lower_ok}")
    print(f"Upper bound satisfied: {upper_ok}")
    assert lower_ok and upper_ok


def main() -> None:
    """Run connected, disconnected, bottleneck, and approximation examples."""
    directed_cycle: Matrix = (
        (0.0, 1.0, 0.0),
        (0.0, 0.0, 1.0),
        (1.0, 0.0, 0.0),
    )
    broken_cycle: Matrix = (
        (0.0, 1.0, 0.0),
        (0.0, 0.0, 1.0),
        (0.0, 0.0, 0.0),
    )
    bottleneck_network: Matrix = (
        (0.0, 3.0, 0.1, 0.0),
        (3.0, 0.0, 0.0, 0.0),
        (0.0, 0.0, 0.0, 3.0),
        (0.1, 0.0, 3.0, 0.0),
    )

    demonstrate_network("Directed three-cycle", directed_cycle)
    demonstrate_network("Broken directed cycle", broken_cycle)
    demonstrate_network("Two modules joined by a weak bottleneck", bottleneck_network)
    demonstrate_approximation(bottleneck_network, factor=1.5)

    # Direct numerical checks of the two qualitative examples.
    assert isclose(integrated_information(directed_cycle).value, 1.0)
    assert isclose(integrated_information(broken_cycle).value, 0.0)


if __name__ == "__main__":
    main()
