#!/usr/bin/env python3
"""Numerical demonstrations for finite quantum-surreal measurement.

Floating-point parameters approximate infinitesimal limits; surreal labels are
represented by strings because their magnitude never enters the Born weights.
"""
from __future__ import annotations

from dataclasses import dataclass
from math import isclose, sqrt
from typing import Hashable, Iterable, Sequence

Label = Hashable


@dataclass(frozen=True)
class Branch:
    """A labelled branch with a real amplitude."""

    label: Label
    amplitude: float


def born_probabilities(branches: Iterable[Branch]) -> dict[Label, float]:
    """Combine equal labels and return normalized squared amplitudes.

    Raises:
        ValueError: if the combined state has zero squared norm.
    """
    combined: dict[Label, float] = {}
    for branch in branches:
        combined[branch.label] = combined.get(branch.label, 0.0) + branch.amplitude
    norm_sq = sum(amplitude * amplitude for amplitude in combined.values())
    if norm_sq == 0.0:
        raise ValueError("Born probabilities are undefined for the zero state")
    return {
        label: amplitude * amplitude / norm_sq
        for label, amplitude in combined.items()
    }


def equal_amplitude_demo(scales: Sequence[float]) -> list[tuple[float, float, float]]:
    """Show that a common nonzero scale leaves both branch weights at one half."""
    rows: list[tuple[float, float, float]] = []
    for scale in scales:
        probabilities = born_probabilities(
            [Branch("0", scale), Branch("epsilon (infinitesimal label)", scale)]
        )
        rows.append((scale, probabilities["0"], probabilities["epsilon (infinitesimal label)"]))
    return rows


def suppressed_amplitude_demo(
    deltas: Sequence[float],
) -> list[tuple[float, float, float]]:
    """Approach the standard-part limit using amplitudes 1 and delta."""
    rows: list[tuple[float, float, float]] = []
    for delta in deltas:
        probabilities = born_probabilities(
            [Branch("ordinary branch", 1.0), Branch("small-amplitude branch", delta)]
        )
        rows.append(
            (
                delta,
                probabilities["ordinary branch"],
                probabilities["small-amplitude branch"],
            )
        )
    return rows


def permute_labels(
    amplitudes: Sequence[float], labels: Sequence[Label]
) -> dict[Label, float]:
    """Attach amplitudes to labels and calculate their Born probabilities."""
    if len(amplitudes) != len(labels):
        raise ValueError("amplitudes and labels must have equal lengths")
    return born_probabilities(Branch(label, amplitude) for label, amplitude in zip(labels, amplitudes))


def lexicographic_standard_part(weight: tuple[float, int]) -> float:
    """Return the ordinary coordinate of an (ordinary, infinitesimal) weight."""
    return weight[0]


def discrete_bridge_demo(atom_count: int) -> tuple[float, list[float]]:
    """Return standard parts of total mass and purely infinitesimal atoms."""
    if atom_count < 1:
        raise ValueError("atom_count must be positive")
    total_weight = (1.0, atom_count)
    atom_weights = [(0.0, 1) for _ in range(atom_count)]
    return (
        lexicographic_standard_part(total_weight),
        [lexicographic_standard_part(weight) for weight in atom_weights],
    )


def print_table(title: str, headings: Sequence[str], rows: Sequence[Sequence[object]]) -> None:
    """Print a compact aligned table without third-party dependencies."""
    rendered = [[str(value) for value in row] for row in rows]
    widths = [len(heading) for heading in headings]
    for row in rendered:
        widths = [max(width, len(value)) for width, value in zip(widths, row)]
    print(f"\n{title}")
    print(" | ".join(heading.ljust(width) for heading, width in zip(headings, widths)))
    print("-+-".join("-" * width for width in widths))
    for row in rendered:
        print(" | ".join(value.ljust(width) for value, width in zip(row, widths)))


def main() -> None:
    """Run all demonstrations and assert the key finite identities."""
    scales = [1.0 / sqrt(2.0), 1e-3, 1e-12, 1e-100]
    equal_rows = equal_amplitude_demo(scales)
    assert all(isclose(left, 0.5) and isclose(right, 0.5) for _, left, right in equal_rows)
    print_table(
        "Equal amplitudes: label magnitude and common scale do not affect weights",
        ("common amplitude", "P(0)", "P(epsilon label)"),
        [(f"{a:.3e}", f"{p0:.12f}", f"{pe:.12f}") for a, p0, pe in equal_rows],
    )

    deltas = [1e-1, 1e-2, 1e-4, 1e-8]
    suppressed_rows = suppressed_amplitude_demo(deltas)
    print_table(
        "Relative amplitude suppression approaches the standard-part collapse",
        ("delta", "P(ordinary)", "P(small amplitude)"),
        [(f"{d:.0e}", f"{p0:.12f}", f"{p1:.12e}") for d, p0, p1 in suppressed_rows],
    )
    assert suppressed_rows[-1][2] < suppressed_rows[0][2]
    assert all(isclose(p0 + p1, 1.0) for _, p0, p1 in suppressed_rows)

    first = permute_labels([2.0, 1.0], ["zero", "epsilon"])
    second = permute_labels([2.0, 1.0], ["infinity", "minus omega"])
    assert list(first.values()) == list(second.values()) == [0.8, 0.2]
    print("\nRelabelling test:", first, "->", second)

    total, atoms = discrete_bridge_demo(4)
    assert total == 1.0 and atoms == [0.0] * 4
    print("Discrete bridge: standard total =", total, "; atom standard parts =", atoms)


if __name__ == "__main__":
    main()
