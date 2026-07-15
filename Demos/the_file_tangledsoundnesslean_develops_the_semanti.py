#!/usr/bin/env python3
"""Numerical illustrations of strict finite consistency-reflection towers.

The script models only the order-theoretic consequences of the theorems: stage n
contains the base labels and n fresh reflection labels, and stage n simulates
stage m exactly when n >= m under the stated consistency and Gödel–Löb
hypotheses. It does not attempt to decide consistency.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import FrozenSet, Iterable, List, Sequence, Tuple


@dataclass(frozen=True)
class ReflectionStage:
    """A finite display model for one level of a reflection tower."""

    index: int
    theorem_labels: FrozenSet[str]


def build_reflection_tower(height: int, base_labels: Iterable[str]) -> List[ReflectionStage]:
    """Construct stages 0 through height by adjoining one fresh label per step."""
    if height < 0:
        raise ValueError("height must be nonnegative")
    labels = frozenset(base_labels)
    stages = [ReflectionStage(0, labels)]
    for n in range(height):
        labels = labels | {f"Con(S_{n})"}
        stages.append(ReflectionStage(n + 1, labels))
    return stages


def predicted_simulates(stronger_index: int, weaker_index: int) -> bool:
    """Return the finite-tower theorem's simulation prediction n >= m."""
    if stronger_index < 0 or weaker_index < 0:
        raise ValueError("stage indices must be nonnegative")
    return stronger_index >= weaker_index


def simulation_matrix(height: int) -> List[List[int]]:
    """Return M[n][m] = 1 exactly when stage n simulates stage m."""
    if height < 0:
        raise ValueError("height must be nonnegative")
    return [
        [int(predicted_simulates(n, m)) for m in range(height + 1)]
        for n in range(height + 1)
    ]


def strict_pairs(height: int) -> List[Tuple[int, int]]:
    """List all (later, earlier) pairs separated by strict reflection."""
    if height < 0:
        raise ValueError("height must be nonnegative")
    return [(n, m) for n in range(height + 1) for m in range(n)]


def has_forbidden_return_path(
    height: int, proposed_simulations: Sequence[Tuple[int, int]]
) -> bool:
    """Detect a proposed earlier-to-later simulation contradicting strictness.

    A pair (a, b) means stage a is claimed to simulate stage b. Under uniform
    consistency and Gödel–Löb hypotheses, a < b is forbidden.
    """
    if height < 0:
        raise ValueError("height must be nonnegative")
    for source, target in proposed_simulations:
        if not (0 <= source <= height and 0 <= target <= height):
            raise ValueError("simulation endpoint lies outside the tower")
        if source < target:
            return True
    return False


def format_matrix(matrix: Sequence[Sequence[int]]) -> str:
    """Format a simulation matrix with source stages as rows."""
    width = len(matrix)
    header = "      " + " ".join(f"S{m:>2}" for m in range(width))
    rows = [header]
    for n, row in enumerate(matrix):
        rows.append(f"S{n:>2} : " + "  ".join(str(value) for value in row))
    return "\n".join(rows)


def main() -> None:
    height = 6
    tower = build_reflection_tower(height, {"base arithmetic"})

    print("FINITE CONSISTENCY-REFLECTION TOWER")
    print("=" * 43)
    for stage in tower:
        added = sorted(stage.theorem_labels)
        print(f"S_{stage.index}: {len(added)} displayed axiom labels -> {added}")

    print("\nSIMULATION MATRIX (row system simulates column system)")
    matrix = simulation_matrix(height)
    print(format_matrix(matrix))

    pairs = strict_pairs(height)
    expected_count = height * (height + 1) // 2
    print(f"\nStrict later/earlier pairs: {len(pairs)}")
    print(f"Triangular-number check: {len(pairs)} = {expected_count}")
    assert len(pairs) == expected_count

    for later, earlier in pairs:
        assert tower[earlier].theorem_labels < tower[later].theorem_labels
        assert predicted_simulates(later, earlier)
        assert not predicted_simulates(earlier, later)

    harmless_claims = [(6, 0), (5, 2), (3, 3)]
    forbidden_claims = harmless_claims + [(1, 4)]
    print(
        "No forbidden return in downward claims:",
        not has_forbidden_return_path(height, harmless_claims),
    )
    print(
        "Forbidden return detected after claiming S_1 simulates S_4:",
        has_forbidden_return_path(height, forbidden_claims),
    )

    print("\nAll finite order checks passed.")
    print(
        "Interpretation: if each lower stage is consistent and satisfies the "
        "Gödel–Löb conditions, every 1 above the diagonal is a valid simulation, "
        "and every 0 below it records a strict non-simulation theorem."
    )


if __name__ == "__main__":
    main()
