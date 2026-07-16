#!/usr/bin/env python3
"""Numerical demonstrations for stable Kneser graphs.

Uses only the Python standard library. It enumerates cyclically stable sets,
checks the canonical coloring theorem in sample instances, certifies the exact
three-color boundary case on nine points, and displays the threshold
counterexample.
"""

from __future__ import annotations

from itertools import combinations
from typing import Dict, Iterable, List, Sequence, Tuple

StableSet = Tuple[int, ...]


def is_linear_stable(points: Sequence[int], s: int) -> bool:
    """Return whether every two selected points differ by at least s."""
    ordered = sorted(points)
    return all(y - x >= s for x, y in combinations(ordered, 2))


def cyclic_gaps(points: Sequence[int], n: int) -> Tuple[int, ...]:
    """Return consecutive clockwise gaps, including the wrap-around gap."""
    ordered = tuple(sorted(points))
    if not ordered:
        return ()
    return tuple(ordered[i + 1] - ordered[i] for i in range(len(ordered) - 1)) + (
        n + ordered[0] - ordered[-1],
    )


def is_cyclic_stable(points: Sequence[int], n: int, s: int) -> bool:
    """Return whether points form a cyclically s-stable subset of [0,n)."""
    ordered = tuple(sorted(points))
    return (
        len(set(ordered)) == len(ordered)
        and all(0 <= x < n for x in ordered)
        and all(gap >= s for gap in cyclic_gaps(ordered, n))
    )


def enumerate_cyclic_stable(n: int, s: int, k: int) -> List[StableSet]:
    """Enumerate all cyclically s-stable k-subsets of [0,n)."""
    return [
        candidate
        for candidate in combinations(range(n), k)
        if is_cyclic_stable(candidate, n, s)
    ]


def canonical_color(points: Sequence[int], r: int) -> int:
    """Compute min(min(points), r-1) for a nonempty set and positive r."""
    if not points or r <= 0:
        raise ValueError("points must be nonempty and r must be positive")
    return min(min(points), r - 1)


def disjoint(left: Iterable[int], right: Iterable[int]) -> bool:
    """Return whether two finite collections have empty intersection."""
    return set(left).isdisjoint(right)


def verify_canonical_coloring(n: int, s: int, k: int, r: int) -> bool:
    """Exhaustively check canonical properness for one finite instance."""
    if n != r + s * (k - 1):
        raise ValueError("the theorem requires n = r + s*(k-1)")
    vertices = enumerate_cyclic_stable(n, s, k)
    for index, left in enumerate(vertices):
        for right in vertices[index + 1 :]:
            if disjoint(left, right):
                if canonical_color(left, r) == canonical_color(right, r):
                    return False
    return True


def color_histogram(n: int, s: int, k: int, r: int) -> Dict[int, int]:
    """Count cyclically stable vertices in each canonical color."""
    counts = {color: 0 for color in range(r)}
    for vertex in enumerate_cyclic_stable(n, s, k):
        counts[canonical_color(vertex, r)] += 1
    return counts


def boundary_certificate() -> Tuple[StableSet, StableSet, StableSet]:
    """Return the three pairwise-disjoint stable triples on nine points."""
    triples = ((0, 3, 6), (1, 4, 7), (2, 5, 8))
    assert all(is_cyclic_stable(triple, 9, 3) for triple in triples)
    assert all(disjoint(a, b) for a, b in combinations(triples, 2))
    return triples


def threshold_counterexample() -> Tuple[StableSet, StableSet, int, int]:
    """Return two disjoint stable pairs and their equal capped colors."""
    left, right, r = (1, 4), (2, 5), 2
    assert is_linear_stable(left, 3) and is_linear_stable(right, 3)
    assert disjoint(left, right)
    left_color = canonical_color(left, r)
    right_color = canonical_color(right, r)
    assert left_color == right_color
    return left, right, left_color, right_color


def main() -> None:
    """Run and print all demonstrations."""
    n, s, k, r = 9, 3, 3, 3
    vertices = enumerate_cyclic_stable(n, s, k)
    print("Stable Kneser numerical demonstration")
    print("=" * 40)
    print(f"Parameters: n={n}, s={s}, k={k}, r={r}")
    print(f"Cyclically stable triples: {len(vertices)}")
    print(f"Canonical color histogram: {color_histogram(n, s, k, r)}")
    print(f"Canonical coloring is proper: {verify_canonical_coloring(n, s, k, r)}")

    certificate = boundary_certificate()
    print("\nThree-clique lower-bound certificate:")
    for triple in certificate:
        print(f"  {triple}, cyclic gaps={cyclic_gaps(triple, 9)}")
    print("These pairwise-disjoint vertices force at least three colors.")
    print("Together with the proper three-coloring, the chromatic number is 3.")

    left, right, left_color, right_color = threshold_counterexample()
    print("\nThreshold counterexample:")
    print(f"  A={left}, B={right}, disjoint={disjoint(left, right)}")
    print(f"  capped colors: c(A)={left_color}, c(B)={right_color}")
    print("Thus capped-minimum coloring can fail without the sharp threshold.")

    print("\nAdditional valid instance:")
    n2, s2, k2, r2 = 8, 2, 3, 4
    print(
        f"  (n,s,k,r)=({n2},{s2},{k2},{r2}), "
        f"vertices={len(enumerate_cyclic_stable(n2, s2, k2))}, "
        f"proper={verify_canonical_coloring(n2, s2, k2, r2)}"
    )


if __name__ == "__main__":
    main()
