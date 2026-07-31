#!/usr/bin/env python3
"""Numerical demonstrations of a Pythagorean-product energy spectrum.

The script uses only Python's standard library and exact integer arithmetic.
It demonstrates nonnegativity, leg symmetry, zero-energy certificates,
strict target convexity, unique target minimization, and a bounded scan of the
Berggren tree. The tree scan is illustrative; it does not claim universal
convergence of a greedy search.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Iterable, Iterator, Sequence

Triple = tuple[int, int, int]
Matrix3 = tuple[tuple[int, int, int], tuple[int, int, int], tuple[int, int, int]]

BERGGREN_MATRICES: tuple[Matrix3, Matrix3, Matrix3] = (
    ((1, -2, 2), (2, -1, 2), (2, -2, 3)),
    ((1, 2, 2), (2, 1, 2), (2, 2, 3)),
    ((-1, 2, 2), (-2, 1, 2), (-2, 2, 3)),
)


@dataclass(frozen=True)
class EnergyReport:
    """Exact residuals and total energy for one candidate."""

    triple: Triple
    target: int
    pythagorean_residual: int
    factor_residual: int
    energy: int


def energy(a: int, b: int, c: int, target: int) -> int:
    """Return (a²+b²-c²)² + (ab-target)² using exact integers."""
    return (a * a + b * b - c * c) ** 2 + (a * b - target) ** 2


def analyze(triple: Triple, target: int) -> EnergyReport:
    """Compute both residuals and their sum-of-squares energy."""
    a, b, c = triple
    pythagorean_residual = a * a + b * b - c * c
    factor_residual = a * b - target
    return EnergyReport(
        triple=triple,
        target=target,
        pythagorean_residual=pythagorean_residual,
        factor_residual=factor_residual,
        energy=pythagorean_residual**2 + factor_residual**2,
    )


def is_zero_certificate(triple: Triple, target: int) -> bool:
    """Return whether the triple is Pythagorean and its legs multiply to target."""
    return analyze(triple, target).energy == 0


def extract_nontrivial_factor(triple: Triple, target: int) -> int | None:
    """Return the first leg when zero energy proves 1 < a < target."""
    a, _, _ = triple
    return a if is_zero_certificate(triple, target) and 1 < a < target else None


def second_difference(triple: Triple, target: int, step: int) -> int:
    """Compute E(N+h)+E(N-h)-2E(N), which equals 2h²."""
    a, b, c = triple
    return (
        energy(a, b, c, target + step)
        + energy(a, b, c, target - step)
        - 2 * energy(a, b, c, target)
    )


def unique_target_minimizer(triple: Triple) -> tuple[int, int]:
    """Return the unique minimizing target ab and its minimum energy."""
    a, b, c = triple
    target = a * b
    return target, energy(a, b, c, target)


def apply_matrix(matrix: Matrix3, triple: Triple) -> Triple:
    """Apply a 3-by-3 integer matrix to a triple."""
    return tuple(sum(row[j] * triple[j] for j in range(3)) for row in matrix)  # type: ignore[return-value]


def berggren_levels(max_depth: int) -> Iterator[tuple[int, Triple]]:
    """Yield primitive positive Pythagorean triples through max_depth."""
    if max_depth < 0:
        return
    queue: deque[tuple[int, Triple]] = deque([(0, (3, 4, 5))])
    while queue:
        depth, triple = queue.popleft()
        yield depth, triple
        if depth < max_depth:
            for matrix in BERGGREN_MATRICES:
                queue.append((depth + 1, apply_matrix(matrix, triple)))


def best_tree_candidates(target: int, max_depth: int, limit: int = 5) -> list[tuple[int, Triple, int]]:
    """Return the lowest-energy vertices in a bounded Berggren-tree scan."""
    ranked = [
        (energy(*triple, target), triple, depth)
        for depth, triple in berggren_levels(max_depth)
    ]
    ranked.sort(key=lambda item: (item[0], item[2], item[1]))
    return [(depth, triple, value) for value, triple, depth in ranked[:limit]]


def verify_identity_grid(
    triples: Sequence[Triple], targets: Iterable[int], steps: Iterable[int]
) -> None:
    """Assert the exact second-difference identity on a finite example grid."""
    for triple in triples:
        for target in targets:
            for step in steps:
                observed = second_difference(triple, target, step)
                expected = 2 * step * step
                assert observed == expected, (triple, target, step, observed, expected)


def main() -> None:
    """Run and print a collection of exact numerical demonstrations."""
    print("PYTHAGOREAN-PRODUCT ENERGY DEMONSTRATION")
    print("=" * 48)

    root = (3, 4, 5)
    root_report = analyze(root, 12)
    print("\n1. Zero-energy certificate for 12")
    print(root_report)
    print(f"Extracted proper factor: {extract_nontrivial_factor(root, 12)}")
    assert root_report.energy == 0
    assert extract_nontrivial_factor(root, 12) == 3

    print("\n2. Leg symmetry and nonnegativity")
    sample = (5, 12, 13)
    for target in (59, 60, 61):
        forward = energy(*sample, target)
        swapped = energy(sample[1], sample[0], sample[2], target)
        print(f"N={target:2d}: E(5,12,13;N)={forward}, swapped={swapped}")
        assert forward == swapped and forward >= 0

    print("\n3. Exact target spectrum around the product 5·12=60")
    for target in range(56, 65):
        print(f"N={target:2d}, E={energy(*sample, target):2d}")
    minimizing_target, minimum = unique_target_minimizer(sample)
    print(f"Unique minimizing target: {minimizing_target}; minimum energy: {minimum}")
    assert (minimizing_target, minimum) == (60, 0)

    print("\n4. Symmetric second differences")
    non_pythagorean = (2, 3, 4)
    for step in (-4, -1, 0, 1, 4):
        observed = second_difference(non_pythagorean, 17, step)
        print(f"h={step:2d}: observed={observed:2d}, expected={2 * step * step:2d}")
        assert observed == 2 * step * step
    verify_identity_grid(
        triples=(root, sample, non_pythagorean),
        targets=range(-3, 4),
        steps=range(-3, 4),
    )

    print("\n5. Bounded Berggren-tree scan for target 60")
    for depth, triple, value in best_tree_candidates(target=60, max_depth=3):
        marker = " <-- certificate" if value == 0 else ""
        print(f"depth={depth}, triple={triple}, energy={value}{marker}")
    assert is_zero_certificate((5, 12, 13), 60)

    print("\nAll exact checks passed.")


if __name__ == "__main__":
    main()
