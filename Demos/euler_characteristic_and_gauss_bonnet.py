#!/usr/bin/env python3
"""Numerical demonstrations of Euler characteristic, curvature, and index laws."""

from __future__ import annotations

from dataclasses import dataclass
from math import isclose, pi
from typing import Iterable, Sequence


@dataclass(frozen=True)
class CellCounts:
    vertices: int
    edges: int
    faces: int

    def euler_characteristic(self) -> int:
        return self.vertices - self.edges + self.faces

    def is_closed_triangular_incidence(self) -> bool:
        return 3 * self.faces == 2 * self.edges


@dataclass(frozen=True)
class CriticalCounts:
    zero: int
    one: int
    two: int

    def index(self) -> int:
        return self.zero - self.one + self.two


def expected_total_curvature(counts: CellCounts) -> float:
    """Return the Gauss--Bonnet total 2*pi*chi."""
    return 2.0 * pi * counts.euler_characteristic()


def curvature_from_genus(genus: int) -> float:
    """Return 4*pi*(1-g) for a closed connected orientable surface."""
    if genus < 0:
        raise ValueError("genus must be nonnegative")
    return 4.0 * pi * (1 - genus)


def genus_from_euler(chi: int) -> int:
    """Recover orientable genus when chi has the required form 2-2g."""
    if (2 - chi) % 2 != 0:
        raise ValueError("Euler characteristic does not determine integral orientable genus")
    genus = (2 - chi) // 2
    if genus < 0:
        raise ValueError("the resulting genus is negative")
    return genus


def angle_defects(vertex_angle_sums: Sequence[float]) -> list[float]:
    """Compute K(v)=2*pi minus the incident-angle sum at each vertex."""
    return [2.0 * pi - total for total in vertex_angle_sums]


def total_angle_defect(vertex_angle_sums: Sequence[float]) -> float:
    return sum(angle_defects(vertex_angle_sums))


def critical_counts(counts: CellCounts, vertex_edge_pairs: int,
                    edge_face_pairs: int) -> CriticalCounts:
    """Compute unpaired cell counts after validating pairing capacities."""
    p, q = vertex_edge_pairs, edge_face_pairs
    if min(p, q) < 0:
        raise ValueError("pair counts must be nonnegative")
    if p > counts.vertices or p + q > counts.edges or q > counts.faces:
        raise ValueError("pair counts exceed available cells")
    return CriticalCounts(counts.vertices - p, counts.edges - p - q,
                          counts.faces - q)


def apply_move(counts: CellCounts, move: str) -> CellCounts:
    """Apply a count-level elementary subdivision move."""
    increments = {
        "edge_split": (1, 1, 0),
        "face_split": (0, 1, 1),
        "stellar": (1, 3, 2),
        "vertex_insertion": (1, 3, 2),
    }
    if move not in increments:
        raise ValueError(f"unknown move: {move}")
    dv, de, df = increments[move]
    return CellCounts(counts.vertices + dv, counts.edges + de,
                      counts.faces + df)


def subdivision_history(counts: CellCounts, moves: Iterable[str]) -> CellCounts:
    """Apply a finite history and assert Euler invariance at every step."""
    chi = counts.euler_characteristic()
    current = counts
    for move in moves:
        current = apply_move(current, move)
        assert current.euler_characteristic() == chi
    return current


def gauss_bonnet_residual(counts: CellCounts,
                          vertex_angle_sums: Sequence[float]) -> float:
    """Difference between measured total defect and 2*pi*chi."""
    if len(vertex_angle_sums) != counts.vertices:
        raise ValueError("one angle sum is required per vertex")
    return total_angle_defect(vertex_angle_sums) - expected_total_curvature(counts)


def print_examples() -> None:
    examples = {
        "tetrahedral sphere": CellCounts(4, 6, 4),
        "octahedral sphere": CellCounts(6, 12, 8),
        "icosahedral sphere": CellCounts(12, 30, 20),
        "seven-vertex torus": CellCounts(7, 21, 14),
        "genus-two mesh": CellCounts(10, 30, 18),
    }
    print("Cell-count and curvature table")
    for name, counts in examples.items():
        chi = counts.euler_characteristic()
        genus = genus_from_euler(chi)
        total = expected_total_curvature(counts)
        print(f"{name:24s} chi={chi:2d}  genus={genus}  "
              f"total curvature={total: .9f}")
        assert isclose(total, curvature_from_genus(genus))

    tetra = examples["tetrahedral sphere"]
    tetra_angle_sums = [pi, pi, pi, pi]
    defects = angle_defects(tetra_angle_sums)
    print("\nTetrahedron defects:", [round(x, 9) for x in defects])
    assert isclose(sum(defects), 4.0 * pi)
    assert isclose(gauss_bonnet_residual(tetra, tetra_angle_sums), 0.0,
                   abs_tol=1e-12)

    genus_two = examples["genus-two mesh"]
    critical = critical_counts(genus_two, vertex_edge_pairs=9,
                               edge_face_pairs=17)
    print("Genus-two critical counts:", critical,
          "index=", critical.index())
    assert critical == CriticalCounts(1, 4, 1)
    assert critical.index() == genus_two.euler_characteristic()

    refined = subdivision_history(
        tetra,
        ["edge_split", "face_split", "stellar", "vertex_insertion"],
    )
    print("Refinement history:", tetra, "->", refined,
          "with chi=", refined.euler_characteristic())


if __name__ == "__main__":
    print_examples()
