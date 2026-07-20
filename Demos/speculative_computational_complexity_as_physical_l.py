#!/usr/bin/env python3
"""Numerical demonstrations of complexity transfer and one-bit erasure cost.

Only the thermodynamic statements are numerical.  The finite reduction graph and
hierarchy examples illustrate the set-theoretic transfer mechanisms of the results;
they do not decide any unresolved complexity-class equality.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from math import exp, isclose, log
from typing import Iterable, Mapping, Sequence


@dataclass(frozen=True)
class JarzynskiReport:
    expected_work: float
    free_energy: float
    exponential_average: float
    jarzynski_target: float
    equality_residual: float
    landauer_gap: float


def validate_pmf(probabilities: Sequence[float], *, tolerance: float = 1e-12) -> None:
    """Validate nonnegative, normalized finite probabilities."""
    if not probabilities:
        raise ValueError("A finite ensemble must contain at least one trajectory.")
    if any(p < 0.0 for p in probabilities):
        raise ValueError("Probabilities must be nonnegative.")
    if not isclose(sum(probabilities), 1.0, abs_tol=tolerance, rel_tol=tolerance):
        raise ValueError("Probabilities must sum to one.")


def analyze_erasure(
    probabilities: Sequence[float],
    work_values: Sequence[float],
    *,
    boltzmann: float = 1.0,
    temperature: float = 1.0,
) -> JarzynskiReport:
    """Compute the finite Jarzynski average and one-bit Landauer comparison."""
    validate_pmf(probabilities)
    if len(probabilities) != len(work_values):
        raise ValueError("Probability and work arrays must have equal lengths.")
    if boltzmann <= 0.0 or temperature <= 0.0:
        raise ValueError("Boltzmann constant and temperature must be positive.")

    thermal = boltzmann * temperature
    free_energy = thermal * log(2.0)
    expected_work = sum(p * w for p, w in zip(probabilities, work_values))
    exponential_average = sum(
        p * exp(-w / thermal) for p, w in zip(probabilities, work_values)
    )
    target = exp(-free_energy / thermal)
    return JarzynskiReport(
        expected_work=expected_work,
        free_energy=free_energy,
        exponential_average=exponential_average,
        jarzynski_target=target,
        equality_residual=exponential_average - target,
        landauer_gap=expected_work - free_energy,
    )


def saturating_protocol(
    outcomes: int, *, boltzmann: float = 1.0, temperature: float = 1.0
) -> JarzynskiReport:
    """Construct a constant-work protocol saturating the one-bit lower bound."""
    if outcomes <= 0:
        raise ValueError("The outcome count must be positive.")
    probability = 1.0 / outcomes
    work = boltzmann * temperature * log(2.0)
    return analyze_erasure(
        [probability] * outcomes,
        [work] * outcomes,
        boltzmann=boltzmann,
        temperature=temperature,
    )


def two_trajectory_jarzynski_protocol(
    negative_work: float,
    *,
    boltzmann: float = 1.0,
    temperature: float = 1.0,
) -> tuple[list[float], list[float], JarzynskiReport]:
    """Build an exact two-trajectory ensemble with one negative-work event.

    The first event has probability 1/4.  The second work value is solved from
    the Jarzynski equality.  A solution requires the first weighted exponential
    term to be below the one-bit target.
    """
    thermal = boltzmann * temperature
    if thermal <= 0.0:
        raise ValueError("The thermal scale must be positive.")
    probabilities = [0.25, 0.75]
    target = 0.5
    remainder = target - probabilities[0] * exp(-negative_work / thermal)
    if remainder <= 0.0:
        raise ValueError("Negative-work event is too extreme for these probabilities.")
    second_exponential = remainder / probabilities[1]
    second_work = -thermal * log(second_exponential)
    work_values = [negative_work, second_work]
    report = analyze_erasure(
        probabilities,
        work_values,
        boltzmann=boltzmann,
        temperature=temperature,
    )
    return probabilities, work_values, report


def reduction_closure(
    known_efficient: Iterable[str], reductions: Mapping[str, Iterable[str]]
) -> set[str]:
    """Propagate efficiency backward through edges A -> B meaning A reduces to B."""
    reverse: dict[str, set[str]] = {}
    for source, targets in reductions.items():
        reverse.setdefault(source, set())
        for target in targets:
            reverse.setdefault(target, set()).add(source)

    efficient = set(known_efficient)
    queue: deque[str] = deque(efficient)
    while queue:
        target = queue.popleft()
        for source in reverse.get(target, set()):
            if source not in efficient:
                efficient.add(source)
                queue.append(source)
    return efficient


def stable_hierarchy_labels(collapse_level: int, highest_level: int) -> dict[int, int]:
    """Return representatives after stable adjacent collapse at collapse_level."""
    if collapse_level < 0 or highest_level < collapse_level:
        raise ValueError("Require 0 <= collapse_level <= highest_level.")
    return {
        level: (collapse_level if level >= collapse_level else level)
        for level in range(highest_level + 1)
    }


def print_report(title: str, report: JarzynskiReport) -> None:
    print(f"\n{title}")
    print(f"  expected work       = {report.expected_work:.12f}")
    print(f"  k T log(2)          = {report.free_energy:.12f}")
    print(f"  exponential average = {report.exponential_average:.12f}")
    print(f"  Jarzynski target    = {report.jarzynski_target:.12f}")
    print(f"  equality residual   = {report.equality_residual:+.3e}")
    print(f"  Landauer gap        = {report.landauer_gap:+.12f}")


def main() -> None:
    print("COMPLEXITY TRANSFER AND THERMODYNAMIC ERASURE DEMONSTRATIONS")

    reductions = {
        "SAT": ["DEMON"],
        "CLIQUE": ["SAT"],
        "HAMILTONIAN-CYCLE": ["SAT"],
        "EASY-BASELINE": [],
    }
    closure = reduction_closure({"DEMON", "EASY-BASELINE"}, reductions)
    print("\nFinite reduction-closure illustration")
    print("  efficient after propagation:", ", ".join(sorted(closure)))

    labels = stable_hierarchy_labels(2, 7)
    print("\nStable hierarchy-collapse illustration")
    print("  level -> representative:", labels)

    report = saturating_protocol(4)
    print_report("Constant-work protocol (equality case)", report)

    probabilities, works, fluctuating = two_trajectory_jarzynski_protocol(-0.2)
    print("\nExact fluctuating protocol")
    print("  probabilities =", probabilities)
    print("  work values   =", [round(w, 12) for w in works])
    print_report("Jarzynski analysis with a negative-work trajectory", fluctuating)

    zero_work = analyze_erasure([0.5, 0.5], [0.0, 0.0])
    print_report("Attempted zero-work erasure (fails Jarzynski equality)", zero_work)
    print("\nConclusion: exact one-bit Jarzynski protocols have positive mean work;")
    print("zero work gives exponential average 1 rather than the required 1/2.")


if __name__ == "__main__":
    main()
