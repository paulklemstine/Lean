#!/usr/bin/env python3
"""Numerical demonstrations for cumulative parking profiles.

The program checks admission by sorting, demonstrates rank deletion and affine
transport, enumerates admitted vectors in a finite cube, and finds a bounded
nonzero modular-kernel vector by syndrome collision.
"""

from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Optional, Sequence, Tuple

Vector = Tuple[int, ...]
Matrix = Sequence[Sequence[int]]


def validate_profile(profile: Sequence[int]) -> None:
    """Raise ValueError unless profile is positive and nondecreasing."""
    if any(bound <= 0 for bound in profile):
        raise ValueError("profile bounds must be positive")
    if any(a > b for a, b in zip(profile, profile[1:])):
        raise ValueError("profile must be nondecreasing")


def sorted_chamber(vector: Sequence[int]) -> Vector:
    """Return the nondecreasing rearrangement of a vector."""
    return tuple(sorted(vector))


def is_parking(profile: Sequence[int], vector: Sequence[int]) -> bool:
    """Test whether a positive integer vector is admitted by a profile."""
    validate_profile(profile)
    if len(profile) != len(vector):
        return False
    ordered = sorted_chamber(vector)
    return all(1 <= value <= bound for value, bound in zip(ordered, profile))


def delete_rank(
    profile: Sequence[int], sorted_vector: Sequence[int], rank: int
) -> Tuple[Vector, Vector]:
    """Delete a zero-based rank from a sorted admitted vector and its profile."""
    validate_profile(profile)
    if len(profile) != len(sorted_vector):
        raise ValueError("profile and vector lengths differ")
    if tuple(sorted(sorted_vector)) != tuple(sorted_vector):
        raise ValueError("the vector must already be sorted")
    if not is_parking(profile, sorted_vector):
        raise ValueError("the sorted vector is not admitted by the profile")
    if not 0 <= rank < len(profile):
        raise IndexError("rank is out of range")
    new_profile = tuple(profile[:rank]) + tuple(profile[rank + 1 :])
    new_vector = tuple(sorted_vector[:rank]) + tuple(sorted_vector[rank + 1 :])
    return new_profile, new_vector


def affine_dilate_value(value: int, factor: int) -> int:
    """Apply the integral affine dilation 1 + factor * (value - 1)."""
    if value <= 0 or factor < 0:
        raise ValueError("value must be positive and factor nonnegative")
    return 1 + factor * (value - 1)


def affine_dilate(
    profile: Sequence[int], vector: Sequence[int], factor: int
) -> Tuple[Vector, Vector]:
    """Dilate a profile and vector about the all-ones vector."""
    validate_profile(profile)
    if not is_parking(profile, vector):
        raise ValueError("vector is not admitted by profile")
    transformed_profile = tuple(
        affine_dilate_value(bound, factor) for bound in profile
    )
    transformed_vector = tuple(
        affine_dilate_value(value, factor) for value in vector
    )
    assert is_parking(transformed_profile, transformed_vector)
    return transformed_profile, transformed_vector


def enumerate_parking_vectors(profile: Sequence[int]) -> List[Vector]:
    """Enumerate every admitted vector using the largest-bound cube."""
    validate_profile(profile)
    largest = profile[-1] if profile else 0
    if not profile:
        return [tuple()]
    return [
        vector
        for vector in product(range(1, largest + 1), repeat=len(profile))
        if is_parking(profile, vector)
    ]


def syndrome(matrix: Matrix, vector: Sequence[int], modulus: int) -> Vector:
    """Compute A*vector modulo modulus."""
    if modulus <= 0:
        raise ValueError("modulus must be positive")
    if any(len(row) != len(vector) for row in matrix):
        raise ValueError("matrix width and vector length differ")
    return tuple(
        sum(coefficient * value for coefficient, value in zip(row, vector))
        % modulus
        for row in matrix
    )


def find_modular_kernel_collision(
    matrix: Matrix, modulus: int, radius: int
) -> Optional[Tuple[Vector, Vector, Vector]]:
    """Find u != v in [-radius,radius]^N with equal syndromes.

    Returns (u, v, z), where z = u-v is nonzero, A*z = 0 modulo modulus,
    and every coordinate of z has absolute value at most 2*radius.
    """
    if modulus <= 0 or radius < 0:
        raise ValueError("modulus must be positive and radius nonnegative")
    width = len(matrix[0]) if matrix else 0
    if any(len(row) != width for row in matrix):
        raise ValueError("matrix rows must have equal length")
    seen: Dict[Vector, Vector] = {}
    for point in product(range(-radius, radius + 1), repeat=width):
        key = syndrome(matrix, point, modulus)
        if key in seen and seen[key] != point:
            previous = seen[key]
            difference = tuple(a - b for a, b in zip(point, previous))
            assert any(value != 0 for value in difference)
            assert syndrome(matrix, difference, modulus) == (0,) * len(matrix)
            assert max(map(abs, difference), default=0) <= 2 * radius
            return point, previous, difference
        seen[key] = point
    return None


def main() -> None:
    """Run four reproducible demonstrations and print their conclusions."""
    profile = (2, 5, 7, 10)
    vector = (9, 1, 6, 4)
    ordered = sorted_chamber(vector)
    print("Profile:", profile)
    print("Vector:", vector, "sorted as", ordered)
    print("Admitted:", is_parking(profile, vector))

    reduced_profile, reduced_vector = delete_rank(profile, ordered, rank=2)
    print("\nDelete rank 3:")
    print("Reduced profile:", reduced_profile)
    print("Reduced sorted vector:", reduced_vector)
    print("Still admitted:", is_parking(reduced_profile, reduced_vector))

    dilated_profile, dilated_vector = affine_dilate(profile, vector, factor=3)
    print("\nAffine dilation with factor 3:")
    print("Transformed profile:", dilated_profile)
    print("Transformed vector:", dilated_vector)
    print("Still admitted:", is_parking(dilated_profile, dilated_vector))

    small_profile = (1, 3, 4)
    points = enumerate_parking_vectors(small_profile)
    print("\nEnumeration for profile", small_profile)
    print("Admitted vector count:", len(points))
    print("First ten vectors:", points[:10])

    matrix = ((1, 2, 3), (2, 1, 1))
    modulus = 5
    radius = small_profile[-1]
    print("\nModular collision search:")
    print(
        f"Syndromes: {modulus ** len(matrix)}; box points: "
        f"{(2 * radius + 1) ** len(matrix[0])}"
    )
    collision = find_modular_kernel_collision(matrix, modulus, radius)
    if collision is None:
        print("No collision found (the strict counting criterion did not force one).")
    else:
        first, second, witness = collision
        print("Equal-syndrome points:", first, second)
        print("Nonzero modular-kernel witness:", witness)
        print("Witness syndrome:", syndrome(matrix, witness, modulus))
        print("Infinity norm bound:", max(map(abs, witness)), "<=", 2 * radius)


if __name__ == "__main__":
    main()
