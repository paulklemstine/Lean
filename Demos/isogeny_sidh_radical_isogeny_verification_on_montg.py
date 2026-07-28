#!/usr/bin/env python3
"""Numerical demonstrations of radical degree-two Montgomery quotients.

The examples use prime fields for clarity. They verify source and target curve
membership, deck invariance, exact reciprocal fibers, visible target roots,
and radical normalization. This is educational code, not constant-time
cryptographic software.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from typing import DefaultDict, Iterable

Point = tuple[int, int]


@dataclass(frozen=True)
class PrimeField:
    """Small prime-field arithmetic represented by integers modulo p."""

    p: int

    def norm(self, value: int) -> int:
        return value % self.p

    def inv(self, value: int) -> int:
        value %= self.p
        if value == 0:
            raise ZeroDivisionError("zero has no multiplicative inverse")
        return pow(value, -1, self.p)

    def sqrt_all(self, value: int) -> list[int]:
        target = value % self.p
        return [candidate for candidate in range(self.p)
                if candidate * candidate % self.p == target]


def source_rhs(field: PrimeField, a: int, x: int) -> int:
    return field.norm(x**3 + a * x**2 + x)


def target_rhs(field: PrimeField, a: int, x_coord: int) -> int:
    return field.norm(x_coord**3 + a * x_coord**2 - 4 * x_coord - 4 * a)


def on_montgomery(field: PrimeField, a: int, point: Point) -> bool:
    x, y = point
    return field.norm(y * y) == source_rhs(field, a, x)


def on_two_quotient(field: PrimeField, a: int, point: Point) -> bool:
    x_coord, y_coord = point
    return field.norm(y_coord * y_coord) == target_rhs(field, a, x_coord)


def radical_two_eval(field: PrimeField, point: Point) -> Point:
    x, y = point
    x_inv = field.inv(x)
    return (
        field.norm(x + x_inv),
        field.norm(y * (1 - x_inv * x_inv)),
    )


def deck_transform(field: PrimeField, point: Point) -> Point:
    x, y = point
    x_inv = field.inv(x)
    return x_inv, field.norm(-y * x_inv * x_inv)


def radical_normalize(field: PrimeField, radical: int, point: Point) -> Point:
    x, y = point
    return field.norm(x), field.norm(radical * y)


def enumerate_source_points(field: PrimeField, a: int) -> Iterable[Point]:
    for x in range(field.p):
        for y in field.sqrt_all(source_rhs(field, a, x)):
            yield x, y


def demonstrate_curve_mapping(field: PrimeField, a: int) -> None:
    points = [point for point in enumerate_source_points(field, a) if point[0] != 0]
    assert points, "the selected example should contain a nonzero affine point"
    for point in points:
        assert on_montgomery(field, a, point)
        image = radical_two_eval(field, point)
        assert on_two_quotient(field, a, image)
        assert radical_two_eval(field, deck_transform(field, point)) == image

    sample = points[0]
    image = radical_two_eval(field, sample)
    partner = deck_transform(field, sample)
    print("Degree-two affine evaluation")
    print(f"  Field: F_{field.p}, A = {a}")
    print(f"  Source point: {sample}")
    print(f"  Deck partner: {partner}")
    print(f"  Common target: {image}")
    print(f"  Checked all {len(points)} nonzero affine source points.\n")


def demonstrate_fibers(field: PrimeField) -> None:
    fibers: DefaultDict[int, list[int]] = defaultdict(list)
    for x in range(1, field.p):
        fibers[field.norm(x + field.inv(x))].append(x)

    for members in fibers.values():
        assert 1 <= len(members) <= 2
        anchor = members[0]
        for z in members:
            assert z == anchor or field.norm(anchor * z) == 1

    singleton_count = sum(len(members) == 1 for members in fibers.values())
    pair_count = sum(len(members) == 2 for members in fibers.values())
    print("Exact reciprocal fibers")
    print(f"  {singleton_count} singleton fibers and {pair_count} reciprocal pairs")
    print("  Every collision is equality or multiplicative inversion.\n")


def demonstrate_target_roots(field: PrimeField, a: int) -> None:
    roots = [field.norm(-a), field.norm(2), field.norm(-2)]
    for root in roots:
        assert on_two_quotient(field, a, (root, 0))
    print("Visible target roots")
    print(f"  X-coordinates: {roots}; each gives a target point (X, 0).\n")


def demonstrate_radical_pipeline(field: PrimeField, a: int, radical: int) -> None:
    normalized_points = [p for p in enumerate_source_points(field, a)
                         if p[0] != 0 and p[1] != 0]
    normalized = normalized_points[0]
    b = field.norm(radical * radical)
    inverse_radical = field.inv(radical)
    twisted = normalized[0], field.norm(normalized[1] * inverse_radical)
    x, y = twisted
    assert field.norm(b * y * y) == source_rhs(field, a, x)
    restored = radical_normalize(field, radical, twisted)
    assert restored == normalized
    image = radical_two_eval(field, restored)
    assert on_two_quotient(field, a, image)

    print("Radical normalize-then-quotient pipeline")
    print(f"  r = {radical}, B = r^2 = {b}")
    print(f"  Twisted point: {twisted}")
    print(f"  Normalized point: {restored}")
    print(f"  Quotient image: {image}\n")


def main() -> None:
    field = PrimeField(101)
    a = 5
    demonstrate_curve_mapping(field, a)
    demonstrate_fibers(field)
    demonstrate_target_roots(field, a)
    demonstrate_radical_pipeline(field, a, radical=7)
    print("All numerical assertions passed.")


if __name__ == "__main__":
    main()
