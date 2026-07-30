#!/usr/bin/env python3
"""Numerical demonstrations of size-indexed Landauer dissipation bounds."""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from math import log, log2
from typing import Callable, Hashable, Iterable, Sequence, TypeVar

K_B = 1.380_649e-23  # joules per kelvin, exact SI value
X = TypeVar("X")
Y = TypeVar("Y", bound=Hashable)


@dataclass(frozen=True)
class ErasureAudit:
    """Summary of cardinality loss and its ideal Landauer cost."""

    input_states: int
    output_states: int
    erased_bits: float
    temperature_kelvin: float
    landauer_joules: float


def landauer_per_bit(temperature_kelvin: float, k_b: float = K_B) -> float:
    """Return k_B T ln(2), the Landauer energy scale per erased bit."""
    if temperature_kelvin < 0 or k_b < 0:
        raise ValueError("temperature and Boltzmann constant must be nonnegative")
    return k_b * temperature_kelvin * log(2.0)


def erased_bits(input_count: int, image_count: int) -> float:
    """Compute log2(input_count) - log2(image_count)."""
    if input_count <= 0 or image_count <= 0 or image_count > input_count:
        raise ValueError("require 1 <= image_count <= input_count")
    return log2(input_count) - log2(image_count)


def audit_finite_map(
    inputs: Iterable[X],
    procedure: Callable[[X], Y],
    temperature_kelvin: float = 300.0,
) -> ErasureAudit:
    """Enumerate a finite map, count its image, and calculate erased bits and cost."""
    domain: Sequence[X] = tuple(inputs)
    if not domain:
        raise ValueError("the finite input collection must be nonempty")
    image = {procedure(value) for value in domain}
    bits = erased_bits(len(domain), len(image))
    return ErasureAudit(
        input_states=len(domain),
        output_states=len(image),
        erased_bits=bits,
        temperature_kelvin=temperature_kelvin,
        landauer_joules=bits * landauer_per_bit(temperature_kelvin),
    )


def prefix_retention_audit(
    input_bits: int, retained_bits: int, temperature_kelvin: float = 300.0
) -> ErasureAudit:
    """Audit the map that retains a fixed-length prefix of a binary word."""
    if not 0 <= retained_bits <= input_bits:
        raise ValueError("require 0 <= retained_bits <= input_bits")
    input_count = 2**input_bits
    image_count = 2**retained_bits
    bits = erased_bits(input_count, image_count)
    return ErasureAudit(
        input_count,
        image_count,
        bits,
        temperature_kelvin,
        bits * landauer_per_bit(temperature_kelvin),
    )


def finite_workload_lower_bound(
    sizes: Iterable[int],
    bit_lower_bound: Callable[[int], float],
    temperature_kelvin: float = 300.0,
) -> tuple[float, float]:
    """Return total guaranteed erased bits and the associated energy lower bound."""
    size_list = tuple(sizes)
    if any(n < 0 for n in size_list):
        raise ValueError("sizes must be nonnegative")
    bounds = tuple(bit_lower_bound(n) for n in size_list)
    if any(value < 0 for value in bounds):
        raise ValueError("this numerical demo requires nonnegative bit bounds")
    total_bits = sum(bounds)
    return total_bits, total_bits * landauer_per_bit(temperature_kelvin)


def demonstrate_enumerated_parity() -> None:
    """Enumerate parity on eight-bit words: 256 inputs collapse to two outputs."""
    words = product((0, 1), repeat=8)
    audit = audit_finite_map(words, lambda word: sum(word) % 2)
    print("1. Enumerated parity decision on 8-bit inputs")
    print(f"   states: {audit.input_states} -> {audit.output_states}")
    print(f"   erased information: {audit.erased_bits:.1f} bits")
    print(f"   Landauer cost at 300 K: {audit.landauer_joules:.6e} J")


def demonstrate_prefix_map() -> None:
    """Show exact erasure for retaining 16 bits of a 64-bit input."""
    audit = prefix_retention_audit(64, 16)
    print("\n2. Prefix retention: keep 16 of 64 bits")
    print(f"   erased information: {audit.erased_bits:.1f} bits")
    print(f"   Landauer cost at 300 K: {audit.landauer_joules:.6e} J")


def demonstrate_linear_workload() -> None:
    """Sum a linear n/2-bit guarantee over sizes 1 through 1000."""
    total_bits, total_energy = finite_workload_lower_bound(
        range(1, 1001), lambda n: n / 2.0
    )
    closed_form = 1000 * 1001 / 4.0
    assert total_bits == closed_form
    print("\n3. Workload with at least n/2 erased bits for n = 1,...,1000")
    print(f"   total guaranteed erasure: {total_bits:.0f} bits")
    print(f"   workload lower bound at 300 K: {total_energy:.6e} J")


def demonstrate_unbounded_thresholds() -> None:
    """Give witnesses for energy thresholds when b(n)=n/3."""
    per_bit = landauer_per_bit(300.0)
    thresholds = (1e-21, 1e-18, 1e-15)
    print("\n4. Witness sizes for unbounded b(n) = n/3")
    for threshold in thresholds:
        # Choose an integer n strictly above 3E/L.
        n = int(3.0 * threshold / per_bit) + 1
        bound = (n / 3.0) * per_bit
        assert bound > threshold
        print(f"   E={threshold:.1e} J: n={n}, guaranteed cost={bound:.6e} J")


def main() -> None:
    """Run all demonstrations."""
    print(f"Landauer energy per bit at 300 K: {landauer_per_bit(300.0):.6e} J")
    demonstrate_enumerated_parity()
    demonstrate_prefix_map()
    demonstrate_linear_workload()
    demonstrate_unbounded_thresholds()


if __name__ == "__main__":
    main()
