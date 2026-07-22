#!/usr/bin/env python3
"""Numerical demonstrations of size-indexed Landauer reset bounds.

The script uses only the Python standard library.  It computes exact logical
state counts, ideal mean-work thresholds, exponential low-work tail bounds,
and checks a finite trajectory ensemble against the Jarzynski condition.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import exp, fsum, log
from typing import Iterable, Sequence

BOLTZMANN_CONSTANT: float = 1.380649e-23  # joules per kelvin, exact SI value


@dataclass(frozen=True)
class ResetResult:
    """Combinatorial and thermodynamic data for complete register reset."""

    bits: int
    logical_states: int
    discarded_bits: float
    temperature_kelvin: float
    minimum_mean_work_joules: float


def validate_physical_inputs(bits: int, temperature_kelvin: float) -> None:
    """Reject values outside the finite positive-temperature model."""
    if bits < 0:
        raise ValueError("bits must be nonnegative")
    if temperature_kelvin <= 0.0:
        raise ValueError("absolute temperature must be positive")


def reset_bound(
    bits: int,
    temperature_kelvin: float,
    boltzmann_constant: float = BOLTZMANN_CONSTANT,
) -> ResetResult:
    """Return state count, discarded bits, and the Landauer work threshold."""
    validate_physical_inputs(bits, temperature_kelvin)
    if boltzmann_constant <= 0.0:
        raise ValueError("Boltzmann's constant must be positive")
    states = 1 << bits
    discarded = float(bits)
    work = boltzmann_constant * temperature_kelvin * discarded * log(2.0)
    return ResetResult(bits, states, discarded, temperature_kelvin, work)


def discarded_bits_lower_bound_work(
    lower_bound_bits: float,
    temperature_kelvin: float,
    boltzmann_constant: float = BOLTZMANN_CONSTANT,
) -> float:
    """Compute k T b log(2) for a certified discarded-bit lower bound b."""
    if temperature_kelvin <= 0.0 or boltzmann_constant <= 0.0:
        raise ValueError("temperature and Boltzmann's constant must be positive")
    return boltzmann_constant * temperature_kelvin * lower_bound_bits * log(2.0)


def violation_probability_bound(
    margin_joules: float,
    temperature_kelvin: float,
    boltzmann_constant: float = BOLTZMANN_CONSTANT,
) -> float:
    """Return exp(-margin/(kT)); informative probability bounds use margin >= 0."""
    if temperature_kelvin <= 0.0 or boltzmann_constant <= 0.0:
        raise ValueError("temperature and Boltzmann's constant must be positive")
    return exp(-margin_joules / (boltzmann_constant * temperature_kelvin))


def violation_probability_bound_thermal_units(margin_in_kT: float) -> float:
    """Return the tail bound when the work deficit is specified in kT units."""
    return exp(-margin_in_kT)


def jarzynski_factor(
    probabilities: Sequence[float],
    works_joules: Sequence[float],
    free_energy_joules: float,
    temperature_kelvin: float,
    boltzmann_constant: float = BOLTZMANN_CONSTANT,
) -> float:
    """Evaluate sum p_i exp(-(W_i-Delta F)/(kT)) for a finite ensemble."""
    if len(probabilities) != len(works_joules) or not probabilities:
        raise ValueError("probability and work arrays must have equal nonzero length")
    if any(p < 0.0 for p in probabilities):
        raise ValueError("probabilities must be nonnegative")
    if abs(fsum(probabilities) - 1.0) > 1e-12:
        raise ValueError("probabilities must sum to one")
    if temperature_kelvin <= 0.0 or boltzmann_constant <= 0.0:
        raise ValueError("temperature and Boltzmann's constant must be positive")
    beta = 1.0 / (boltzmann_constant * temperature_kelvin)
    return fsum(
        p * exp(-beta * (work - free_energy_joules))
        for p, work in zip(probabilities, works_joules)
    )


def expected_work(probabilities: Sequence[float], works: Sequence[float]) -> float:
    """Compute the expected work of a finite ensemble."""
    if len(probabilities) != len(works):
        raise ValueError("arrays must have equal length")
    return fsum(p * work for p, work in zip(probabilities, works))


def format_state_count(bits: int, states: int) -> str:
    """Avoid printing enormous integers while retaining an exact description."""
    return str(states) if bits <= 64 else f"2^{bits} (exact integer has {bits + 1} bits)"


def main() -> None:
    """Print three demonstrations of the principal mathematical results."""
    temperature = 300.0
    print("SIZE-INDEXED LANDAUER BOUNDS")
    print(f"Temperature: {temperature:.1f} K\n")
    for bits in (0, 1, 8, 64, 1_000):
        result = reset_bound(bits, temperature)
        print(
            f"n={bits:4d}: states={format_state_count(bits, result.logical_states)}, "
            f"discarded={result.discarded_bits:g} bits, "
            f"E[W] >= {result.minimum_mean_work_joules:.6e} J"
        )

    print("\nLOW-WORK FLUCTUATION BOUNDS")
    thermal_energy = BOLTZMANN_CONSTANT * temperature
    for thermal_units in (1.0, 2.0, 5.0, 10.0):
        margin = thermal_units * thermal_energy
        probability = violation_probability_bound(margin, temperature)
        print(
            f"margin={thermal_units:4.1f} kT ({margin:.6e} J): "
            f"probability <= {probability:.6e}"
        )

    print("\nFINITE ENSEMBLE CHECK")
    one_bit = reset_bound(1, temperature)
    delta_f = one_bit.minimum_mean_work_joules
    # Symmetric fluctuations of +/- kT around Delta F + kT log(cosh(1))
    # are chosen so that the Jarzynski factor is exactly one up to rounding.
    shift = thermal_energy * log((exp(1.0) + exp(-1.0)) / 2.0)
    probabilities = (0.5, 0.5)
    works = (delta_f + shift - thermal_energy, delta_f + shift + thermal_energy)
    factor = jarzynski_factor(probabilities, works, delta_f, temperature)
    mean = expected_work(probabilities, works)
    print(f"Jarzynski factor: {factor:.12f} (condition requires <= 1)")
    print(f"Expected work:    {mean:.6e} J")
    print(f"Landauer floor:   {delta_f:.6e} J")
    print(f"Mean above floor: {mean - delta_f:.6e} J")


if __name__ == "__main__":
    main()
