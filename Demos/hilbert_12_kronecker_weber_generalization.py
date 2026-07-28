#!/usr/bin/env python3
"""Numerical illustrations of Hilbert class field character transport.

The script models finite cyclic ideal class groups.  It builds their complex
character tables, transports characters through a finite Artin labeling, checks
round trips and character orthogonality, and illustrates the degree-one
principal-ideal criterion using supplied class numbers.
"""

from __future__ import annotations

import cmath
from dataclasses import dataclass
from typing import Iterable, Sequence

ComplexMatrix = list[list[complex]]


@dataclass(frozen=True)
class ClassFieldDiagnostic:
    """Consequences of a supplied Hilbert class field class number."""

    field_label: str
    class_number: int
    extension_degree: int
    is_principal_ideal_ring: bool
    number_of_characters: int


def cyclic_character_value(order: int, character: int, element: int) -> complex:
    """Return chi_character(element) for the cyclic group of the given order."""
    if order <= 0:
        raise ValueError("The group order must be positive.")
    angle = 2.0 * cmath.pi * (character % order) * (element % order) / order
    return cmath.exp(1j * angle)


def cyclic_character_table(order: int) -> ComplexMatrix:
    """Construct the complete character table of the cyclic group C_order."""
    return [
        [cyclic_character_value(order, k, j) for j in range(order)]
        for k in range(order)
    ]


def inverse_permutation(permutation: Sequence[int]) -> list[int]:
    """Invert a zero-based permutation."""
    n = len(permutation)
    if sorted(permutation) != list(range(n)):
        raise ValueError("Artin labeling must be a permutation of 0,...,n-1.")
    inverse = [0] * n
    for source, target in enumerate(permutation):
        inverse[target] = source
    return inverse


def transport_class_to_galois(
    class_character: Sequence[complex], artin_labeling: Sequence[int]
) -> list[complex]:
    """Pull back a class character along a finite Artin labeling.

    artin_labeling[g] is the ideal-class index assigned to Galois element g.
    """
    if len(class_character) != len(artin_labeling):
        raise ValueError("The character and Artin table must have equal size.")
    inverse_permutation(artin_labeling)  # validates the labeling
    return [class_character[c] for c in artin_labeling]


def transport_galois_to_class(
    galois_character: Sequence[complex], artin_labeling: Sequence[int]
) -> list[complex]:
    """Transport a Galois character back along the inverse Artin labeling."""
    if len(galois_character) != len(artin_labeling):
        raise ValueError("The character and Artin table must have equal size.")
    inverse = inverse_permutation(artin_labeling)
    return [galois_character[inverse[c]] for c in range(len(inverse))]


def max_orthogonality_error(table: Sequence[Sequence[complex]]) -> float:
    """Return the largest numerical error in row-character orthogonality."""
    n = len(table)
    if n == 0 or any(len(row) != n for row in table):
        raise ValueError("A character table must be a nonempty square matrix.")
    error = 0.0
    for k, row_k in enumerate(table):
        for ell, row_ell in enumerate(table):
            inner = sum(a * b.conjugate() for a, b in zip(row_k, row_ell))
            expected = complex(n if k == ell else 0)
            error = max(error, abs(inner - expected))
    return error


def diagnose(field_label: str, class_number: int) -> ClassFieldDiagnostic:
    """Apply [H:K]=h_K and the class-number-one criterion."""
    if class_number <= 0:
        raise ValueError("A class number must be positive.")
    return ClassFieldDiagnostic(
        field_label=field_label,
        class_number=class_number,
        extension_degree=class_number,
        is_principal_ideal_ring=(class_number == 1),
        number_of_characters=class_number,
    )


def format_complex(z: complex, tolerance: float = 1e-10) -> str:
    """Format a complex root of unity readably."""
    real = 0.0 if abs(z.real) < tolerance else z.real
    imag = 0.0 if abs(z.imag) < tolerance else z.imag
    if imag == 0.0:
        return f"{real:.3f}"
    if real == 0.0:
        return f"{imag:.3f}i"
    return f"{real:.3f}{imag:+.3f}i"


def print_table(table: Iterable[Iterable[complex]]) -> None:
    """Print a complex matrix."""
    for row in table:
        print("  " + "  ".join(f"{format_complex(z):>14}" for z in row))


def run_demo() -> None:
    """Run three numerical demonstrations."""
    print("DEMO 1 — Cyclic character tables and orthogonality")
    for order in (1, 2, 3, 4):
        table = cyclic_character_table(order)
        print(f"\nCharacter table for C_{order}:")
        print_table(table)
        print(f"maximum orthogonality error: {max_orthogonality_error(table):.3e}")

    print("\nDEMO 2 — Artin transport and inverse transport")
    order = 4
    class_character = cyclic_character_table(order)[1]
    # A nontrivial enumeration: Galois positions map to class positions 0, 2, 1, 3.
    artin_labeling = [0, 2, 1, 3]
    galois_character = transport_class_to_galois(class_character, artin_labeling)
    recovered = transport_galois_to_class(galois_character, artin_labeling)
    print("ideal-class character:", [format_complex(z) for z in class_character])
    print("Artin labeling:       ", artin_labeling)
    print("Galois character:     ", [format_complex(z) for z in galois_character])
    print("recovered character:  ", [format_complex(z) for z in recovered])
    print("round trip error:     ", max(abs(a - b) for a, b in zip(class_character, recovered)))

    print("\nDEMO 3 — Degree one versus principality")
    examples = [
        diagnose("Q(i)", 1),
        diagnose("Q(sqrt(-5))", 2),
        diagnose("a model field with cyclic class group C_3", 3),
    ]
    for item in examples:
        print(
            f"{item.field_label}: h={item.class_number}, [H:K]={item.extension_degree}, "
            f"principal ideal ring={item.is_principal_ideal_ring}, "
            f"characters={item.number_of_characters}"
        )


if __name__ == "__main__":
    run_demo()
