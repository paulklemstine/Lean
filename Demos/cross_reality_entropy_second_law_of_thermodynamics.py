#!/usr/bin/env python3
"""Numerical demonstrations of entropy balance in finite branch ensembles."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, log
from typing import Sequence


Vector = Sequence[float]


@dataclass(frozen=True)
class BalanceReport:
    """Computed branchwise and total entropy-balance diagnostics."""

    microscopic_losses: tuple[float, ...]
    environmental_exports: tuple[float, ...]
    net_productions: tuple[float, ...]
    weighted_change: float
    direct_change: float
    weak_second_law: bool
    strict_second_law: bool


def validate_distribution(probabilities: Vector, *, tolerance: float = 1e-10) -> None:
    """Raise ValueError unless probabilities form a finite probability vector."""
    if not probabilities:
        raise ValueError("A probability distribution must be nonempty.")
    if any(value < -tolerance for value in probabilities):
        raise ValueError("Probabilities must be nonnegative.")
    if not isclose(sum(probabilities), 1.0, abs_tol=tolerance, rel_tol=tolerance):
        raise ValueError(f"Probabilities sum to {sum(probabilities)}, not 1.")


def shannon_entropy(probabilities: Vector, *, base: float = 2.0) -> float:
    """Return finite Shannon entropy, using the convention 0 log 0 = 0."""
    validate_distribution(probabilities)
    if base <= 0.0 or isclose(base, 1.0):
        raise ValueError("The logarithm base must be positive and different from 1.")
    return -sum(value * log(value, base) for value in probabilities if value > 0.0)


def total_entropy(
    weights: Vector,
    microscopic: Sequence[Vector],
    environment: Vector,
    *,
    base: float = 2.0,
) -> float:
    """Compute mixing entropy plus weighted microscopic and environmental entropy."""
    validate_distribution(weights)
    if not (len(weights) == len(microscopic) == len(environment)):
        raise ValueError("Weights, branches, and environments must have equal lengths.")
    conditional = sum(
        weight * (shannon_entropy(distribution, base=base) + env)
        for weight, distribution, env in zip(weights, microscopic, environment)
    )
    return shannon_entropy(weights, base=base) + conditional


def pushforward_distribution(
    probabilities: Vector, mapping: Sequence[int], output_size: int
) -> tuple[float, ...]:
    """Push a finite distribution through a deterministic state map."""
    validate_distribution(probabilities)
    if len(probabilities) != len(mapping):
        raise ValueError("The map must specify one output for each input state.")
    if output_size <= 0 or any(index < 0 or index >= output_size for index in mapping):
        raise ValueError("Every mapped index must lie in the output state space.")
    output = [0.0] * output_size
    for probability, target in zip(probabilities, mapping):
        output[target] += probability
    return tuple(output)


def entropy_balance_report(
    weights: Vector,
    initial_microscopic: Sequence[Vector],
    final_microscopic: Sequence[Vector],
    initial_environment: Vector,
    final_environment: Vector,
    *,
    base: float = 2.0,
    tolerance: float = 1e-10,
) -> BalanceReport:
    """Evaluate the exact change identity and weak/strict compensation criteria."""
    validate_distribution(weights, tolerance=tolerance)
    count = len(weights)
    if not all(
        len(values) == count
        for values in (
            initial_microscopic,
            final_microscopic,
            initial_environment,
            final_environment,
        )
    ):
        raise ValueError("All branch-indexed inputs must have the same length.")

    losses = tuple(
        shannon_entropy(before, base=base) - shannon_entropy(after, base=base)
        for before, after in zip(initial_microscopic, final_microscopic)
    )
    exports = tuple(
        after - before
        for before, after in zip(initial_environment, final_environment)
    )
    productions = tuple(exported - lost for exported, lost in zip(exports, losses))
    weighted_change = sum(
        weight * production for weight, production in zip(weights, productions)
    )
    direct_change = total_entropy(
        weights, final_microscopic, final_environment, base=base
    ) - total_entropy(weights, initial_microscopic, initial_environment, base=base)

    weak = all(production >= -tolerance for production in productions)
    strict = weak and any(
        weight > tolerance and production > tolerance
        for weight, production in zip(weights, productions)
    )
    if not isclose(weighted_change, direct_change, abs_tol=tolerance, rel_tol=tolerance):
        raise AssertionError("The direct and branchwise entropy changes disagree.")
    return BalanceReport(
        losses,
        exports,
        productions,
        weighted_change,
        direct_change,
        weak,
        strict,
    )


def print_report(title: str, report: BalanceReport) -> None:
    """Print a compact, readable balance report."""
    print(f"\n{title}\n{'=' * len(title)}")
    for index, (loss, exported, production) in enumerate(
        zip(
            report.microscopic_losses,
            report.environmental_exports,
            report.net_productions,
        ),
        start=1,
    ):
        print(
            f"Branch {index}: loss={loss: .6f}, export={exported: .6f}, "
            f"production={production: .6f}"
        )
    print(f"Weighted change: {report.weighted_change: .6f}")
    print(f"Direct change:   {report.direct_change: .6f}")
    print(f"Weak certificate:   {report.weak_second_law}")
    print(f"Strict certificate: {report.strict_second_law}")


def demo_local_decrease_with_global_growth() -> None:
    """Show local microscopic ordering together with strict total growth."""
    weights = (0.50, 0.30, 0.20)
    initial = ((0.5, 0.5), (0.9, 0.1), (0.75, 0.25))
    final = ((1.0, 0.0), (0.8, 0.2), (1.0, 0.0))
    losses = tuple(
        shannon_entropy(before) - shannon_entropy(after)
        for before, after in zip(initial, final)
    )
    # Every branch exports 0.05 bits more than its own microscopic loss.
    environment_initial = (0.0, 0.0, 0.0)
    environment_final = tuple(loss + 0.05 for loss in losses)
    report = entropy_balance_report(
        weights, initial, final, environment_initial, environment_final
    )
    print_report("Local decrease with strict ensemble growth", report)


def demo_zero_weight_strictness() -> None:
    """Show that surplus confined to a zero-weight branch cannot force strictness."""
    weights = (0.60, 0.40, 0.0)
    unchanged = ((0.5, 0.5), (0.25, 0.75), (0.5, 0.5))
    report = entropy_balance_report(
        weights,
        unchanged,
        unchanged,
        (0.0, 0.0, 0.0),
        (0.0, 0.0, 5.0),
    )
    print_report("Zero-weight surplus and equality", report)


def demo_deterministic_erasure() -> None:
    """Push distributions through deterministic maps and compensate their losses."""
    weights = (0.7, 0.3)
    initial = ((0.5, 0.5), (0.25, 0.75))
    maps = ((0, 0), (0, 1))  # Erasure in branch 1; identity in branch 2.
    final = tuple(
        pushforward_distribution(distribution, mapping, 2)
        for distribution, mapping in zip(initial, maps)
    )
    losses = tuple(
        shannon_entropy(before) - shannon_entropy(after)
        for before, after in zip(initial, final)
    )
    # Exact compensation in branch 1 and strict surplus in positive-weight branch 2.
    environment_initial = (0.0, 0.0)
    environment_final = (losses[0], losses[1] + 0.2)
    report = entropy_balance_report(
        weights, initial, final, environment_initial, environment_final
    )
    print_report("Deterministic erasure with environmental compensation", report)


def main() -> None:
    """Run all numerical examples."""
    demo_local_decrease_with_global_growth()
    demo_zero_weight_strictness()
    demo_deterministic_erasure()


if __name__ == "__main__":
    main()
