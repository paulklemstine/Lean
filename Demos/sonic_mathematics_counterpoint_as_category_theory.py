#!/usr/bin/env python3
"""Numerical demonstrations for the generated counterpoint category.

The script implements the definitions directly, checks the explicit
nontransitivity witness, enumerates the seven-state canonical motion table,
computes reflexive-transitive closure, and reports mutual-reachability classes.
It uses only the Python standard library.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Sequence, Set, Tuple

Pitch = int
Dyad = Tuple[Pitch, Pitch]
Edge = Tuple[Dyad, Dyad]

CONSONANCES: frozenset[int] = frozenset({0, 3, 4, 7, 8, 9, 12})
PERFECT_CONSONANCES: frozenset[int] = frozenset({0, 7, 12})
CANONICAL_INTERVALS: Tuple[int, ...] = (0, 3, 4, 7, 8, 9, 12)
INTERVAL_NAMES: Mapping[int, str] = {
    0: "unison",
    3: "minor third",
    4: "major third",
    7: "perfect fifth",
    8: "minor sixth",
    9: "major sixth",
    12: "octave",
}


def vertical_interval(x: Dyad) -> int:
    """Return upper-voice pitch minus lower-voice pitch."""
    return x[1] - x[0]


def is_consonant(interval: int) -> bool:
    """Decide membership in the seven allowed simple consonances."""
    return abs(interval) in CONSONANCES


def is_perfect(interval: int) -> bool:
    """Decide whether an interval is unison, fifth, or octave in size."""
    return abs(interval) in PERFECT_CONSONANCES


def is_stepwise(x: Dyad, y: Dyad) -> bool:
    """Check that each voice moves by at most two semitones."""
    return abs(y[0] - x[0]) <= 2 and abs(y[1] - x[1]) <= 2


def is_similar_motion(x: Dyad, y: Dyad) -> bool:
    """Check strict equal-direction motion of both voices."""
    upward = x[0] < y[0] and x[1] < y[1]
    downward = y[0] < x[0] and y[1] < x[1]
    return upward or downward


def is_permitted_motion(x: Dyad, y: Dyad) -> bool:
    """Apply the local counterpoint predicate to one ordered dyad pair."""
    ix, iy = vertical_interval(x), vertical_interval(y)
    forbidden_perfect_motion = (
        is_perfect(ix) and is_perfect(iy) and is_similar_motion(x, y)
    )
    return (
        is_consonant(ix)
        and is_consonant(iy)
        and is_stepwise(x, y)
        and not forbidden_perfect_motion
    )


def canonical_dyad(interval: int) -> Dyad:
    """Realize an interval above a stationary bass at pitch zero."""
    return (0, interval)


def canonical_motion(source: int, target: int) -> bool:
    """Test permitted motion between canonical interval representatives."""
    return is_permitted_motion(canonical_dyad(source), canonical_dyad(target))


def enumerate_canonical_motions() -> Set[Tuple[int, int]]:
    """Return all legal ordered motions on the seven canonical intervals."""
    return {
        (source, target)
        for source in CANONICAL_INTERVALS
        for target in CANONICAL_INTERVALS
        if canonical_motion(source, target)
    }


def adjacency_from_edges(
    vertices: Sequence[int], edges: Iterable[Tuple[int, int]]
) -> Dict[int, Set[int]]:
    """Construct a directed adjacency map, retaining isolated vertices."""
    adjacency = {vertex: set() for vertex in vertices}
    for source, target in edges:
        adjacency[source].add(target)
    return adjacency


def reachable_from(source: int, adjacency: Mapping[int, Set[int]]) -> Set[int]:
    """Compute reflexive reachability by breadth-first search."""
    reached: Set[int] = {source}
    queue: deque[int] = deque([source])
    while queue:
        current = queue.popleft()
        for target in adjacency[current]:
            if target not in reached:
                reached.add(target)
                queue.append(target)
    return reached


def transitive_closure(
    vertices: Sequence[int], edges: Iterable[Tuple[int, int]]
) -> Set[Tuple[int, int]]:
    """Return all reflexively and transitively reachable ordered pairs."""
    adjacency = adjacency_from_edges(vertices, edges)
    return {
        (source, target)
        for source in vertices
        for target in reachable_from(source, adjacency)
    }


def mutual_reachability_classes(
    vertices: Sequence[int], closure: Set[Tuple[int, int]]
) -> List[Set[int]]:
    """Partition vertices by reachability in both directions."""
    unseen = set(vertices)
    classes: List[Set[int]] = []
    while unseen:
        representative = min(unseen)
        component = {
            vertex
            for vertex in unseen
            if (representative, vertex) in closure
            and (vertex, representative) in closure
        }
        classes.append(component)
        unseen -= component
    return classes


def demonstrate_nontransitivity() -> None:
    """Print and assert the explicit two-step counterexample."""
    x, y, z = (0, 3), (2, 5), (4, 7)
    xy = is_permitted_motion(x, y)
    yz = is_permitted_motion(y, z)
    xz = is_permitted_motion(x, z)
    print("Nontransitivity witness")
    print(f"  x={x}, y={y}, z={z}")
    print(f"  permitted x→y: {xy}")
    print(f"  permitted y→z: {yz}")
    print(f"  permitted x→z: {xz}")
    print(f"  direct voice displacements: ({z[0]-x[0]}, {z[1]-x[1]})")
    assert xy and yz and not xz


def demonstrate_canonical_model() -> None:
    """Enumerate the finite model and display its reachability quotient."""
    edges = enumerate_canonical_motions()
    closure = transitive_closure(CANONICAL_INTERVALS, edges)
    classes = mutual_reachability_classes(CANONICAL_INTERVALS, closure)

    print("\nCanonical seven-state motion table")
    print(f"  intervals: {CANONICAL_INTERVALS}")
    print(f"  number of directed one-step motions: {len(edges)}")
    for source in CANONICAL_INTERVALS:
        targets = sorted(target for left, target in edges if left == source)
        labels = ", ".join(f"{target} ({INTERVAL_NAMES[target]})" for target in targets)
        print(f"  {source:>2} ({INTERVAL_NAMES[source]:>13}) → {labels}")

    print("\nMutual-reachability classes")
    for component in classes:
        print("  {" + ", ".join(str(x) for x in sorted(component)) + "}")

    assert len(CANONICAL_INTERVALS) == 7
    assert len(edges) == 15
    assert (3, 4) in edges and (4, 3) in edges
    assert classes == [{0}, {3, 4}, {7, 8, 9}, {12}]


def demonstrate_stationary_identity() -> None:
    """Check stationary permitted motion at representative consonant dyads."""
    examples = [canonical_dyad(interval) for interval in CANONICAL_INTERVALS]
    results = [is_permitted_motion(x, x) for x in examples]
    print("\nStationary consonant motions")
    print(f"  all seven canonical identities permitted: {all(results)}")
    assert all(results)


def demonstrate_tree_leaf_obstruction() -> None:
    """Verify the degree-sum and leaf conclusions on representative trees."""
    trees: Dict[str, Tuple[int, Set[Tuple[int, int]]]] = {
        "single vertex": (1, set()),
        "five-vertex path": (5, {(0, 1), (1, 2), (2, 3), (3, 4)}),
        "five-vertex star": (5, {(0, 1), (0, 2), (0, 3), (0, 4)}),
    }
    print("\nTree degree sums and leaf obstructions")
    for name, (size, edges) in trees.items():
        degrees = [0] * size
        for left, right in edges:
            degrees[left] += 1
            degrees[right] += 1
        leaves = [vertex for vertex, degree in enumerate(degrees) if degree <= 1]
        print(
            f"  {name}: degrees={degrees}, sum={sum(degrees)}="
            f"2({size}-1), low-degree vertices={leaves}"
        )
        assert len(edges) == size - 1
        assert sum(degrees) == 2 * (size - 1)
        assert leaves
        assert all(degrees[vertex] < 2 for vertex in leaves)


def main() -> None:
    """Run all numerical demonstrations and internal consistency checks."""
    demonstrate_nontransitivity()
    demonstrate_stationary_identity()
    demonstrate_canonical_model()
    demonstrate_tree_leaf_obstruction()
    print("\nAll demonstrations completed successfully.")


if __name__ == "__main__":
    main()
