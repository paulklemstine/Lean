#!/usr/bin/env python3
"""Numerical demonstrations of intrinsic witness complexity.

Faces are represented as ``frozenset[int]`` objects.  The script uses only the
Python standard library and illustrates principal certificates, family bounds,
overlap savings, antichain compression, and the width-two counterexample.
"""

from __future__ import annotations

from itertools import combinations
from math import comb
from typing import FrozenSet, Iterable, Iterator, Sequence, TypeVar

T = TypeVar("T")
Face = FrozenSet[T]
Complex = set[Face[T]]


def powerset(face: Face[T]) -> Iterator[Face[T]]:
    """Yield every subset of ``face`` exactly once."""
    items = tuple(face)
    for size in range(len(items) + 1):
        for subset in combinations(items, size):
            yield frozenset(subset)


def principal_certificate(face: Face[T]) -> Complex[T]:
    """Return the least downward-closed family containing one face."""
    return set(powerset(face))


def family_certificate(witnesses: Iterable[Face[T]]) -> Complex[T]:
    """Return the union of the principal certificates of all witnesses."""
    certificate: Complex[T] = set()
    for witness in witnesses:
        certificate.update(powerset(witness))
    return certificate


def maximal_witnesses(witnesses: Iterable[Face[T]]) -> set[Face[T]]:
    """Delete witnesses contained in another witness without changing closure."""
    family = set(witnesses)
    return {w for w in family if not any(w < other for other in family)}


def is_downward_closed(family: set[Face[T]]) -> bool:
    """Check the hereditary closure condition by explicit subset enumeration."""
    return all(subset in family for face in family for subset in powerset(face))


def two_parameter_bound(witnesses: Sequence[Face[T]]) -> int:
    """Compute q * 2^m using the actual witness count and maximum width."""
    q = len(witnesses)
    m = max((len(w) for w in witnesses), default=0)
    return q * (2**m)


def inclusion_exclusion_count(witnesses: Sequence[Face[T]]) -> int:
    """Count the family certificate from all nonempty witness intersections."""
    total = 0
    q = len(witnesses)
    for size in range(1, q + 1):
        sign = 1 if size % 2 == 1 else -1
        for chosen in combinations(witnesses, size):
            intersection = set(chosen[0])
            for witness in chosen[1:]:
                intersection.intersection_update(witness)
            total += sign * (2 ** len(intersection))
    return total


def format_face(face: Face[object]) -> str:
    """Format a face deterministically for display."""
    return "{" + ", ".join(map(str, sorted(face, key=str))) + "}"


def demonstrate_single_witness() -> None:
    """Show exact 2^|w| complexity and the forced lower bound."""
    witness: Face[int] = frozenset({1, 2, 3, 4, 5})
    certificate = principal_certificate(witness)
    expected = 2 ** len(witness)
    assert len(certificate) == expected
    assert is_downward_closed(certificate)
    print("1. Exact principal-certificate complexity")
    print(f"   witness width: {len(witness)}")
    print(f"   certificate faces: {len(certificate)} = 2^{len(witness)}")
    histogram = {r: sum(len(face) == r for face in certificate)
                 for r in range(len(witness) + 1)}
    print(f"   faces by dimension level: {histogram}")
    print(f"   binomial prediction: {[comb(len(witness), r) for r in range(6)]}\n")


def demonstrate_overlap_and_compression() -> None:
    """Compare the universal bound with exact overlap-sensitive complexity."""
    witnesses: list[Face[int]] = [
        frozenset({1, 2, 3, 4}),
        frozenset({3, 4, 5, 6}),
        frozenset({1, 2}),  # redundant: contained in the first witness
    ]
    compressed = maximal_witnesses(witnesses)
    certificate = family_certificate(witnesses)
    compressed_certificate = family_certificate(compressed)
    bound = two_parameter_bound(witnesses)
    exact_ie = inclusion_exclusion_count(witnesses)
    assert certificate == compressed_certificate
    assert exact_ie == len(certificate)
    assert len(certificate) <= bound
    assert is_downward_closed(certificate)
    print("2. Overlap savings and maximal-antichain compression")
    print(f"   input witnesses: {len(witnesses)}; maximal witnesses: {len(compressed)}")
    print(f"   universal q*2^m bound: {bound}")
    print(f"   exact generated size: {len(certificate)}")
    print(f"   inclusion-exclusion count: {exact_ie}")
    print(f"   saved faces versus bound: {bound - len(certificate)}\n")


def demonstrate_width_two_counterexample() -> None:
    """Construct the complete width-two complex on four vertices."""
    vertices = frozenset({1, 2, 3, 4})
    complex_: Complex[int] = {
        face for face in powerset(vertices) if len(face) <= 2
    }
    n = len(vertices)
    count = len(complex_)
    expected = 1 + n + comb(n, 2)
    assert is_downward_closed(complex_)
    assert count == expected == 11
    assert count != 2 * n
    print("3. Width-two counterexample to a global 2n formula")
    print(f"   vertices: {n}")
    print(f"   faces: 1 + {n} + C({n},2) = {count}")
    print(f"   proposed 2n value: {2*n}")
    print("   conclusion: width alone does not control total face count.\n")


def demonstrate_ambient_independence() -> None:
    """Show that unused ambient vertices do not change a certificate."""
    witnesses: list[Face[int]] = [
        frozenset({10, 20, 30}),
        frozenset({30, 40}),
    ]
    small = family_certificate(witnesses)
    # Adding a million conceptual ambient labels changes no witness subset.
    ambient_vertex_count = 1_000_000
    same = family_certificate(witnesses)
    assert small == same
    print("4. Independence from ambient scale")
    print(f"   conceptual ambient vertices: {ambient_vertex_count:,}")
    print(f"   designated witnesses: {len(witnesses)}")
    print(f"   generated certificate faces: {len(small)}")
    print(f"   intrinsic upper bound: {two_parameter_bound(witnesses)}")


def main() -> None:
    """Run all numerical demonstrations."""
    print("INTRINSIC WITNESS COMPLEXITY — NUMERICAL DEMONSTRATIONS\n")
    demonstrate_single_witness()
    demonstrate_overlap_and_compression()
    demonstrate_width_two_counterexample()
    demonstrate_ambient_independence()


if __name__ == "__main__":
    main()
