"""Numerical demonstrations for equivariant maps of cross-polytope spheres."""
from __future__ import annotations

from dataclasses import dataclass
from math import factorial
from typing import Iterable

SignedVertex = tuple[int, int]

@dataclass(frozen=True)
class MapData:
    """Images of positive source vertices as (target axis, sign)."""
    source_dim: int
    target_dim: int
    positive_images: tuple[SignedVertex, ...]


def antipode(vertex: SignedVertex) -> SignedVertex:
    axis, sign = vertex
    return axis, -sign


def image(data: MapData, vertex: SignedVertex) -> SignedVertex:
    axis, sign = vertex
    target_axis, positive_sign = data.positive_images[axis]
    return target_axis, sign * positive_sign


def validate_map(data: MapData) -> bool:
    """Apply the coordinate-axis theorem: validity is coordinate injectivity."""
    if len(data.positive_images) != data.source_dim + 1:
        return False
    axes = []
    for axis, sign in data.positive_images:
        if not 0 <= axis <= data.target_dim or sign not in (-1, 1):
            return False
        axes.append(axis)
    return len(axes) == len(set(axes))


def collision_certificate(data: MapData) -> tuple[SignedVertex, SignedVertex] | None:
    """Return non-antipodal source vertices with antipodal images, if present."""
    seen: dict[int, tuple[int, int]] = {}
    for j, (axis, sign_j) in enumerate(data.positive_images):
        if axis in seen:
            i, sign_i = seen[axis]
            pair = ((i, 1), (j, 1 if sign_i != sign_j else -1))
            assert pair[0] != antipode(pair[1])
            assert image(data, pair[0]) == antipode(image(data, pair[1]))
            return pair
        seen[axis] = (j, sign_j)
    return None


def standard_inclusion(m: int, n: int) -> MapData:
    """Construct the standard equivariant inclusion when m <= n."""
    if m < 0 or n < 0 or m > n:
        raise ValueError("dimensions must satisfy 0 <= m <= n")
    return MapData(m, n, tuple((i, 1) for i in range(m + 1)))


def suspend(data: MapData) -> MapData:
    """Adjoin one new matched source and target coordinate axis."""
    if not validate_map(data):
        raise ValueError("only valid maps can be suspended")
    return MapData(data.source_dim + 1, data.target_dim + 1,
                   data.positive_images + ((data.target_dim + 1, 1),))


def map_exists(m: int, n: int) -> bool:
    return 0 <= m <= n


def predicted_map_count(m: int, n: int) -> int:
    """Count injections times independent signs, as suggested by the classification."""
    if m < 0 or n < 0 or m > n:
        return 0
    return 2 ** (m + 1) * factorial(n + 1) // factorial(n - m)


def existence_table(max_dim: int) -> list[list[bool]]:
    return [[map_exists(m, n) for n in range(max_dim + 1)]
            for m in range(max_dim + 1)]


def main() -> None:
    print("Existence table: rows m, columns n; 1 means C_m -> C_n exists")
    for m, row in enumerate(existence_table(6)):
        print(f"m={m}: " + " ".join("1" if x else "0" for x in row))

    inclusion = standard_inclusion(2, 4)
    print("\nStandard C_2 -> C_4 inclusion:", inclusion.positive_images)
    print("Valid:", validate_map(inclusion))
    suspended = suspend(inclusion)
    print("Suspended C_3 -> C_5 map:", suspended.positive_images)
    print("Valid after suspension:", validate_map(suspended))

    bad = MapData(2, 1, ((0, 1), (1, -1), (0, -1)))
    witness = collision_certificate(bad)
    print("\nCandidate C_2 -> C_1 valid:", validate_map(bad))
    print("Collision certificate:", witness)
    if witness:
        p, q = witness
        print("Images:", image(bad, p), image(bad, q), "(an antipodal pair)")

    print("\nPredicted numbers of maps C_m -> C_4:")
    for m in range(7):
        print(f"m={m}: {predicted_map_count(m, 4)}")

if __name__ == "__main__":
    main()
