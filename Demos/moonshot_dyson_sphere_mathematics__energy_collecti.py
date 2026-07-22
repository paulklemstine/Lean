#!/usr/bin/env python3
"""Numerical demonstrations for an ideal Dyson-swarm model.

The calculations distinguish projected-area collection, a quadratic thermal
concentration metric, and energy-per-event capacities.  Only the Python
standard library is required.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import pi
from typing import Iterable

AU_METERS = 1.495978707e11
SOLAR_LUMINOSITY_WATTS = 3.828e26


@dataclass(frozen=True)
class CollectionResult:
    sphere_area_m2: float
    flux_w_m2: float
    coverage_fraction: float
    captured_power_w: float


def sphere_area(radius_m: float) -> float:
    """Return 4*pi*R^2 for a positive radius in meters."""
    if radius_m <= 0.0:
        raise ValueError("radius_m must be positive")
    return 4.0 * pi * radius_m**2


def collection_result(
    luminosity_w: float, radius_m: float, collector_area_m2: float
) -> CollectionResult:
    """Evaluate flux and captured power in the no-occlusion model."""
    if luminosity_w < 0.0 or collector_area_m2 < 0.0:
        raise ValueError("luminosity and collector area must be nonnegative")
    shell_area = sphere_area(radius_m)
    if collector_area_m2 > shell_area * (1.0 + 1e-12):
        raise ValueError("collector area exceeds full nonoverlapping coverage")
    flux = luminosity_w / shell_area
    return CollectionResult(
        shell_area, flux, collector_area_m2 / shell_area, flux * collector_area_m2
    )


def thermal_load(areas: Iterable[float]) -> float:
    """Return the quadratic concentration load sum(a_i^2)."""
    values = tuple(areas)
    if any(area < 0.0 for area in values):
        raise ValueError("panel areas must be nonnegative")
    return sum(area * area for area in values)


def uniform_allocation(total_area: float, panel_count: int) -> list[float]:
    """Return the load-minimizing equal allocation for fixed area and count."""
    if total_area < 0.0 or panel_count <= 0:
        raise ValueError("total area must be nonnegative and panel count positive")
    return [total_area / panel_count] * panel_count


def operation_capacity(energy_j: float, cost_per_operation_j: float) -> float:
    """Return E/c for a positive energy cost per operation."""
    if energy_j < 0.0 or cost_per_operation_j <= 0.0:
        raise ValueError("energy must be nonnegative and cost must be positive")
    return energy_j / cost_per_operation_j


def bit_capacity(energy_j: float, cost_per_bit_j: float) -> float:
    """Return E/c_b for a positive charged energy per bit."""
    if energy_j < 0.0 or cost_per_bit_j <= 0.0:
        raise ValueError("energy must be nonnegative and cost must be positive")
    return energy_j / cost_per_bit_j


def demonstrate_collection() -> None:
    """Print capture at several coverage fractions at one astronomical unit."""
    full_area = sphere_area(AU_METERS)
    print("GEOMETRIC COLLECTION AT ONE ASTRONOMICAL UNIT")
    for fraction in (0.01, 0.10, 0.50, 1.00):
        result = collection_result(
            SOLAR_LUMINOSITY_WATTS, AU_METERS, fraction * full_area
        )
        print(
            f"  coverage={fraction:>5.0%}  flux={result.flux_w_m2:,.2f} W/m^2"
            f"  captured={result.captured_power_w:.3e} W"
        )
    full = collection_result(SOLAR_LUMINOSITY_WATTS, AU_METERS, full_area)
    assert abs(full.captured_power_w / SOLAR_LUMINOSITY_WATTS - 1.0) < 1e-12
    print(f"  full projected area: {full_area:.3e} m^2\n")


def demonstrate_thermal_optimum() -> None:
    """Compare uniform and unequal allocations with total normalized area 12."""
    total_area = 12.0
    print("QUADRATIC THERMAL CONCENTRATION")
    for count in (1, 2, 4, 12):
        allocation = uniform_allocation(total_area, count)
        observed = thermal_load(allocation)
        theorem_value = total_area**2 / count
        assert abs(observed - theorem_value) < 1e-12
        print(f"  n={count:>2}: uniform load={observed:6.2f} = A^2/n")
    unequal = [6.0, 3.0, 2.0, 1.0]
    equal = uniform_allocation(total_area, len(unequal))
    print(f"  unequal {unequal}: load={thermal_load(unequal):.2f}")
    print(f"  uniform {equal}: load={thermal_load(equal):.2f}\n")
    assert thermal_load(equal) <= thermal_load(unequal)


def demonstrate_computation() -> None:
    """Display operation and calibrated bit capacities from energy budgets."""
    power_w = 1e26
    one_second_energy_j = power_w * 1.0
    op_cost_j = 1e-14
    throughput = operation_capacity(one_second_energy_j, op_cost_j)
    print("ENERGY-ACCOUNTED COMPUTATION")
    print(f"  {power_w:.0e} W at {op_cost_j:.0e} J/op -> {throughput:.0e} op/s")
    assert abs(throughput / 1e40 - 1.0) < 1e-12

    target_bits = 1e50
    example_energy_j = 1e30
    threshold_cost_j = example_energy_j / target_bits
    capacity = bit_capacity(example_energy_j, threshold_cost_j)
    print(
        f"  E={example_energy_j:.0e} J and c_bit={threshold_cost_j:.0e} J/bit"
        f" -> {capacity:.0e} bits"
    )
    assert capacity >= target_bits
    print("  The bit result is conditional on the stated energy and cost per bit.\n")


def main() -> None:
    demonstrate_collection()
    demonstrate_thermal_optimum()
    demonstrate_computation()


if __name__ == "__main__":
    main()
