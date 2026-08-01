#!/usr/bin/env python3
"""Numerical demonstrations of finite-state information–energy accounting."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, log, log2
from typing import Hashable, Sequence

BOLTZMANN_CONSTANT = 1.380649e-23  # joules per kelvin, exact SI value


@dataclass(frozen=True)
class Step:
    """One finite computation and its energetic inputs and outputs."""

    outputs: Sequence[Hashable]
    injected_joules: float = 0.0
    harvested_joules: float = 0.0


@dataclass(frozen=True)
class AuditRow:
    """Computed accounting data for one step."""

    index: int
    input_states: int
    reached_outputs: int
    erased_bits: float
    landauer_joules: float
    stored_after_joules: float
    injective: bool


def erased_bits(outputs: Sequence[Hashable]) -> float:
    """Return log2(input count / reached-output count) for an explicit map."""
    input_count = len(outputs)
    if input_count == 0:
        raise ValueError("The finite input state space must be nonempty.")
    reached_count = len(set(outputs))
    return log2(input_count / reached_count)


def cardinality_lower_bound(input_count: int, output_space_count: int) -> float:
    """Return log2(|A|)-log2(|B|), the codomain-based lower bound."""
    if input_count <= 0 or output_space_count <= 0:
        raise ValueError("Cardinalities must be positive.")
    return log2(input_count) - log2(output_space_count)


def bit_price(temperature_kelvin: float, k_b: float = BOLTZMANN_CONSTANT) -> float:
    """Return the Landauer price k_B T ln(2), in joules per bit."""
    if temperature_kelvin < 0 or k_b < 0:
        raise ValueError("Temperature and Boltzmann constant must be nonnegative.")
    return k_b * temperature_kelvin * log(2.0)


def audit_process(
    initial_stored_joules: float,
    temperature_kelvin: float,
    steps: Sequence[Step],
    k_b: float = BOLTZMANN_CONSTANT,
) -> list[AuditRow]:
    """Audit a process by applying the exact local balance at every step.

    Raises ValueError if an input space is empty, an energy flow is negative, or
    the proposed schedule would require negative stored energy.
    """
    if initial_stored_joules < 0:
        raise ValueError("Initial stored energy must be nonnegative.")
    price = bit_price(temperature_kelvin, k_b)
    stored = initial_stored_joules
    rows: list[AuditRow] = []
    tolerance = 1e-30

    for index, step in enumerate(steps):
        if step.injected_joules < 0 or step.harvested_joules < 0:
            raise ValueError("Injected and harvested energies must be nonnegative.")
        bits = erased_bits(step.outputs)
        cost = bits * price
        stored = stored + step.injected_joules - step.harvested_joules - cost
        if stored < -tolerance:
            raise ValueError(f"Step {index} exceeds the available energy budget.")
        stored = max(0.0, stored)
        rows.append(
            AuditRow(
                index=index,
                input_states=len(step.outputs),
                reached_outputs=len(set(step.outputs)),
                erased_bits=bits,
                landauer_joules=cost,
                stored_after_joules=stored,
                injective=len(set(step.outputs)) == len(step.outputs),
            )
        )
    return rows


def conservation_residual(
    initial_stored_joules: float, steps: Sequence[Step], rows: Sequence[AuditRow]
) -> float:
    """Return left minus right in the finite-horizon conservation identity."""
    terminal = initial_stored_joules if not rows else rows[-1].stored_after_joules
    left = terminal + sum(s.harvested_joules for s in steps) + sum(
        row.landauer_joules for row in rows
    )
    right = initial_stored_joules + sum(s.injected_joules for s in steps)
    return left - right


def main() -> None:
    """Run compression, reversibility, budget, and rigidity demonstrations."""
    temperature = 300.0
    price = bit_price(temperature)
    six_bit_map = [i % 16 for i in range(1024)]
    permutation = list(range(256))

    print("FINITE-STATE INFORMATION–ENERGY DEMONSTRATION")
    print(f"Landauer bit price at {temperature:.0f} K: {price:.6e} J/bit\n")

    bits = erased_bits(six_bit_map)
    cost = bits * price
    print("1. Compression of 1024 inputs onto 16 reached outputs")
    print(f"   Erased capacity: {bits:.1f} bits")
    print(f"   Minimum debit:   {cost:.6e} J")
    print(f"   At 10^15 cycles/s: {cost * 1e15:.6e} W\n")

    reversible_bits = erased_bits(permutation)
    print("2. Reversible permutation of 256 states")
    print(f"   Erased capacity: {reversible_bits:.1f} bits")
    print(f"   Injective:       {len(set(permutation)) == len(permutation)}\n")

    steps = [
        Step(six_bit_map, harvested_joules=4.0e-19),
        Step(permutation, injected_joules=1.0e-19, harvested_joules=0.5e-19),
    ]
    initial = 1.0e-18
    rows = audit_process(initial, temperature, steps)
    print("3. Two-step finite-horizon audit")
    for row in rows:
        print(
            f"   Step {row.index}: bits={row.erased_bits:.3f}, "
            f"cost={row.landauer_joules:.6e} J, "
            f"stored={row.stored_after_joules:.6e} J"
        )
    residual = conservation_residual(initial, steps, rows)
    print(f"   Conservation residual: {residual:.3e} J")
    assert isclose(residual, 0.0, abs_tol=1e-30)

    print("\n4. Closed-cycle rigidity check")
    closed_steps = [Step(permutation), Step(permutation)]
    closed_rows = audit_process(initial, temperature, closed_steps)
    cyclic = isclose(closed_rows[-1].stored_after_joules, initial, abs_tol=1e-30)
    all_reversible = all(row.injective for row in closed_rows)
    no_harvest = all(step.harvested_joules == 0.0 for step in closed_steps)
    print(f"   Stored energy returns: {cyclic}")
    print(f"   Every map injective:   {all_reversible}")
    print(f"   Every harvest zero:    {no_harvest}")


if __name__ == "__main__":
    main()
