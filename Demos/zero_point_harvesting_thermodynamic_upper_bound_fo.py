#!/usr/bin/env python3
"""Numerical demonstrations of finite-horizon energy-accounting bounds."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose
from typing import Sequence


@dataclass(frozen=True)
class AuditResult:
    """Summary of a finite conservative harvesting trajectory."""

    stored: tuple[float, ...]
    total_injected: float
    total_harvested: float
    net_export: float
    extraction_bound: float
    average_net_output: float
    cyclic: bool


def simulate_process(
    initial_storage: float,
    injected: Sequence[float],
    harvested: Sequence[float],
    *,
    tolerance: float = 1e-10,
) -> AuditResult:
    """Construct storage from the balance law and audit all derived bounds.

    The recurrence is S[t+1] = S[t] + I[t] - H[t].  Inputs must be
    nonnegative and the resulting storage may never fall below zero.
    """
    if len(injected) != len(harvested):
        raise ValueError("injected and harvested sequences must have equal length")
    if initial_storage < -tolerance:
        raise ValueError("initial storage must be nonnegative")
    if any(x < -tolerance for x in injected):
        raise ValueError("injected energies must be nonnegative")
    if any(x < -tolerance for x in harvested):
        raise ValueError("harvested energies must be nonnegative")

    stored = [float(initial_storage)]
    for cycle, (energy_in, energy_out) in enumerate(zip(injected, harvested)):
        next_storage = stored[-1] + float(energy_in) - float(energy_out)
        if next_storage < -tolerance:
            raise ValueError(
                f"cycle {cycle} would create negative storage ({next_storage:g})"
            )
        stored.append(max(0.0, next_storage))

    total_injected = float(sum(injected))
    total_harvested = float(sum(harvested))
    net_export = total_harvested - total_injected
    extraction_bound = initial_storage + total_injected
    horizon = len(injected)
    average = net_export / horizon if horizon else 0.0

    assert isclose(
        stored[-1] + total_harvested,
        initial_storage + total_injected,
        abs_tol=tolerance,
    )
    assert total_harvested <= extraction_bound + tolerance
    assert net_export <= initial_storage + tolerance

    return AuditResult(
        stored=tuple(stored),
        total_injected=total_injected,
        total_harvested=total_harvested,
        net_export=net_export,
        extraction_bound=extraction_bound,
        average_net_output=average,
        cyclic=isclose(stored[-1], initial_storage, abs_tol=tolerance),
    )


def print_result(title: str, result: AuditResult) -> None:
    """Print an audit in a compact human-readable form."""
    print(f"\n{title}")
    print("-" * len(title))
    print(f"stored trajectory:   {result.stored}")
    print(f"total input:         {result.total_injected:.3f}")
    print(f"total output:        {result.total_harvested:.3f}")
    print(f"net export:          {result.net_export:.3f}")
    print(f"absolute bound:      {result.extraction_bound:.3f}")
    print(f"average net/cycle:   {result.average_net_output:.3f}")
    print(f"cyclic:              {result.cyclic}")


def demonstrate_amortization(initial_storage: float, horizons: Sequence[int]) -> None:
    """Display the universal upper bound S0/N at selected horizons."""
    print("\nAmortization of a finite initial reserve")
    print("----------------------------------------")
    for horizon in horizons:
        if horizon <= 0:
            raise ValueError("horizons must be positive")
        print(
            f"N = {horizon:4d}: average net output <= "
            f"{initial_storage / horizon:.6f} energy units/cycle"
        )


def main() -> None:
    """Run depletion, cyclicity, ground-state, and rate demonstrations."""
    depletion = simulate_process(
        initial_storage=10.0,
        injected=[2.0, 1.0, 0.0, 3.0],
        harvested=[4.0, 3.0, 2.0, 1.0],
    )
    print_result("Depletion-supported finite surplus", depletion)

    cyclic = simulate_process(
        initial_storage=5.0,
        injected=[2.0, 0.0, 1.0],
        harvested=[1.0, 1.0, 1.0],
    )
    print_result("Ideal cyclic conversion", cyclic)
    assert isclose(cyclic.total_harvested, cyclic.total_injected)

    ground_state = simulate_process(
        initial_storage=0.0,
        injected=[0.0] * 5,
        harvested=[0.0] * 5,
    )
    print_result("Unpowered zero-reserve process", ground_state)
    assert ground_state.total_harvested == 0.0

    demonstrate_amortization(12.0, [1, 10, 100, 1000, 1201])

    try:
        simulate_process(0.0, [0.0], [1.0])
    except ValueError as error:
        print("\nRejected impossible ground-state trajectory")
        print("-------------------------------------------")
        print(error)


if __name__ == "__main__":
    main()
