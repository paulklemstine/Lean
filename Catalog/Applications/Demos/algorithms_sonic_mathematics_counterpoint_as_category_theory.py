#!/usr/bin/env python3
"""
Contrapuntal Quiver — Core Algorithms

Type-hinted implementations of the key algorithms from the
Contrapuntal Quiver formalization.
"""

from enum import IntEnum
from typing import Dict, FrozenSet, List, Optional, Set, Tuple
from dataclasses import dataclass


class MotionType(IntEnum):
    """Motion types in counterpoint, ordered by restrictiveness."""
    CONTRARY = 0
    OBLIQUE = 1
    SIMILAR = 2
    PARALLEL = 3


@dataclass(frozen=True)
class ContrapuntalQuiver:
    """A contrapuntal quiver over a finite vertex set.

    Attributes:
        vertices: tuple of vertex labels
        is_perfect: function classifying vertices as perfect/imperfect
        threshold: function giving the maximum permitted motion type for each edge
    """
    vertices: Tuple[int, ...]
    perfect_set: FrozenSet[int]

    def is_perfect(self, v: int) -> bool:
        return v in self.perfect_set

    def threshold(self, a: int, b: int) -> MotionType:
        """The maximum permitted motion type from a to b."""
        if self.is_perfect(b):
            return MotionType.SIMILAR
        return MotionType.PARALLEL

    def allowed(self, a: int, b: int, m: MotionType) -> bool:
        """Whether motion type m is permitted from a to b."""
        return m <= self.threshold(a, b)

    def hom_set(self, a: int, b: int) -> Set[MotionType]:
        """The set of permitted motion types from a to b."""
        return {m for m in MotionType if self.allowed(a, b, m)}

    def hom_set_size(self, a: int, b: int) -> int:
        """Size of the hom-set from a to b."""
        return len(self.hom_set(a, b))

    def out_degree(self, a: int, m: MotionType) -> int:
        """Number of targets reachable from a via motion type m."""
        return sum(1 for b in self.vertices if self.allowed(a, b, m))

    def in_degree(self, b: int, m: MotionType) -> int:
        """Number of sources that can reach b via motion type m."""
        return sum(1 for a in self.vertices if self.allowed(a, b, m))

    def total_freedom(self, a: int) -> int:
        """Total out-degree of vertex a across all motion types."""
        return sum(self.out_degree(a, m) for m in MotionType)

    def total_morphism_count(self) -> int:
        """Total number of morphisms in the quiver."""
        return sum(
            self.hom_set_size(a, b)
            for a in self.vertices
            for b in self.vertices
        )

    def restrictiveness_spectrum(self) -> Dict[int, int]:
        """Distribution of hom-set sizes."""
        spectrum: Dict[int, int] = {}
        for a in self.vertices:
            for b in self.vertices:
                size = self.hom_set_size(a, b)
                spectrum[size] = spectrum.get(size, 0) + 1
        return spectrum

    def motion_subgraph_edges(self, m: MotionType) -> List[Tuple[int, int]]:
        """Edges in the subgraph for a given motion type."""
        return [(a, b) for a in self.vertices for b in self.vertices
                if self.allowed(a, b, m)]


def build_fux_quiver() -> ContrapuntalQuiver:
    """Construct the standard Fux first-species contrapuntal quiver.

    Returns:
        The Fux quiver on 6 consonant interval classes.
    """
    return ContrapuntalQuiver(
        vertices=(0, 3, 4, 7, 8, 9),
        perfect_set=frozenset({0, 7})
    )


def verify_target_determination(quiver: ContrapuntalQuiver) -> bool:
    """Verify the Target Determination Principle.

    Checks that fuxAllowed(a1, b, m) == fuxAllowed(a2, b, m)
    for all a1, a2, b, m.

    Args:
        quiver: a contrapuntal quiver

    Returns:
        True if the principle holds
    """
    for b in quiver.vertices:
        for m in MotionType:
            values = {quiver.allowed(a, b, m) for a in quiver.vertices}
            if len(values) > 1:
                return False
    return True


def verify_downward_closure(quiver: ContrapuntalQuiver) -> bool:
    """Verify the downward-closure axiom.

    Checks that if m1 <= m2 and allowed(a, b, m2), then allowed(a, b, m1).

    Returns:
        True if the axiom holds
    """
    for a in quiver.vertices:
        for b in quiver.vertices:
            for m2 in MotionType:
                if quiver.allowed(a, b, m2):
                    for m1 in MotionType:
                        if m1 <= m2 and not quiver.allowed(a, b, m1):
                            return False
    return True


def interval_inversion(i: int) -> int:
    """Interval inversion (complement map) mod 12."""
    return (12 - i) % 12


def consonance_inversion_analysis() -> Dict[str, object]:
    """Analyze how inversion affects the consonance set.

    Returns:
        Dictionary with analysis results
    """
    consonances = {0, 3, 4, 7, 8, 9}
    results = {}

    for i in sorted(consonances):
        inv = interval_inversion(i)
        results[i] = {
            "inversion": inv,
            "survives": inv in consonances
        }

    survivors = sum(1 for v in results.values() if v["survives"])

    return {
        "pairs": results,
        "survivors": survivors,
        "total": len(consonances),
        "broken": [i for i, v in results.items() if not v["survives"]]
    }


def contrapuntal_entropy(quiver: ContrapuntalQuiver, b: int) -> float:
    """Compute the contrapuntal entropy of targeting interval b.

    H(b) = log2(|homSet(a, b)|)

    This is source-independent by Target Determination.
    """
    import math
    size = quiver.hom_set_size(quiver.vertices[0], b)
    return math.log2(size) if size > 0 else 0.0


def enumerate_all_quivers(
    vertices: Tuple[int, ...],
    perfect_set: FrozenSet[int]
) -> int:
    """Count all valid contrapuntal quivers on given vertices.

    A valid quiver must satisfy:
    1. Downward closure
    2. Contrary universality
    3. Parallel-perfect prohibition

    Due to downward closure, each edge is determined by its threshold
    motion type. The constraints are:
    - Threshold >= CONTRARY (universality)
    - If target is perfect: threshold <= SIMILAR

    Returns:
        Number of valid quivers
    """
    # Each edge has a threshold in {CONTRARY, OBLIQUE, SIMILAR, PARALLEL}
    # Constraint: if target is perfect, threshold <= SIMILAR (3 choices)
    # Constraint: if target is imperfect, threshold can be anything (4 choices)

    n_perfect_targets = sum(1 for v in vertices if v in perfect_set)
    n_imperfect_targets = len(vertices) - n_perfect_targets

    n_edges_to_perfect = len(vertices) * n_perfect_targets
    n_edges_to_imperfect = len(vertices) * n_imperfect_targets

    # Each edge to perfect has 3 threshold choices (CONTRARY, OBLIQUE, SIMILAR)
    # Each edge to imperfect has 4 threshold choices
    total = (3 ** n_edges_to_perfect) * (4 ** n_edges_to_imperfect)
    return total


if __name__ == "__main__":
    fux = build_fux_quiver()

    print("Fux Quiver Properties:")
    print(f"  Vertices: {fux.vertices}")
    print(f"  Perfect: {fux.perfect_set}")
    print(f"  Total morphisms: {fux.total_morphism_count()}")
    print(f"  Target Determination: {verify_target_determination(fux)}")
    print(f"  Downward Closure: {verify_downward_closure(fux)}")
    print(f"  Spectrum: {fux.restrictiveness_spectrum()}")

    print(f"\nFreedom scores:")
    for v in fux.vertices:
        print(f"  {v}: {fux.total_freedom(v)}")

    print(f"\nContrapuntal entropy:")
    for v in fux.vertices:
        print(f"  {v}: {contrapuntal_entropy(fux, v):.4f} bits")

    inv = consonance_inversion_analysis()
    print(f"\nInversion analysis:")
    print(f"  Survivors: {inv['survivors']}/{inv['total']}")
    print(f"  Broken: {inv['broken']}")

    n_quivers = enumerate_all_quivers(fux.vertices, fux.perfect_set)
    print(f"\nTotal valid quivers on 6 consonances: {n_quivers}")
