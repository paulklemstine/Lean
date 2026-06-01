#!/usr/bin/env python3
"""
Algorithms for Stratified Cake Theory

Type-hinted implementations of key algorithms from the Fundamental Theorem of Cakes.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Iterator


@dataclass(frozen=True)
class CakeData:
    """Immutable combinatorial cake datum."""
    genus: int
    boundary: int
    cherries: int
    layers: int


def euler_characteristic(cake: CakeData) -> int:
    """Compute Euler characteristic χ = 2 - 2g - b. O(1)."""
    return 2 - 2 * cake.genus - cake.boundary


def moduli_dimension_real(cake: CakeData) -> int:
    """Compute real moduli dimension 6g - 6 + 2n. O(1)."""
    return 6 * cake.genus - 6 + 2 * cake.cherries


def moduli_dimension_complex(cake: CakeData) -> int:
    """Compute complex moduli dimension 3g - 3 + n. O(1)."""
    return 3 * cake.genus - 3 + cake.cherries


def complexity(cake: CakeData) -> int:
    """Compute cake complexity 3g + b + n + k. O(1)."""
    return 3 * cake.genus + cake.boundary + cake.cherries + cake.layers


def glue(c1: CakeData, c2: CakeData) -> CakeData:
    """
    Glue two cakes along one boundary component each.
    Precondition: both cakes have at least one boundary component.
    O(1).
    """
    if c1.boundary < 1 or c2.boundary < 1:
        raise ValueError("Both cakes need at least one boundary component for gluing")
    return CakeData(
        genus=c1.genus + c2.genus,
        boundary=c1.boundary + c2.boundary - 2,
        cherries=c1.cherries + c2.cherries,
        layers=c1.layers + c2.layers,
    )


def canonical_flag(d: int) -> List[int]:
    """
    Construct the canonical complete flag stratification of depth d.
    Returns [d, d-1, ..., 1, 0] with length d+1.
    O(d).
    """
    return list(range(d, -1, -1))


def is_valid_stratification(depths: List[int], d: int) -> bool:
    """
    Check if a list of depths forms a valid layer stratification of depth d.
    O(len(depths)).
    """
    if not depths:
        return False
    if depths[0] != d:
        return False
    if depths[-1] != 0:
        return False
    return all(depths[i] > depths[i + 1] for i in range(len(depths) - 1))


def enumerate_cakes(max_complexity: int) -> Iterator[CakeData]:
    """
    Enumerate all valid cakes with complexity ≤ max_complexity.
    Yields CakeData objects in lexicographic order of (g, b, n, k).
    """
    for g in range(max_complexity // 3 + 1):
        for b in range(max_complexity - 3 * g + 1):
            for n in range(max_complexity - 3 * g - b + 1):
                for k in range(1, max_complexity - 3 * g - b - n + 1):
                    cake = CakeData(g, b, n, k)
                    if complexity(cake) <= max_complexity:
                        yield cake


def count_cakes(max_complexity: int) -> int:
    """Count the number of valid cakes with complexity ≤ max_complexity."""
    return sum(1 for _ in enumerate_cakes(max_complexity))


def frosting_total_degree(degrees: List[int]) -> int:
    """Compute total degree of a frosting sheaf. O(b)."""
    return sum(degrees)


def is_uniform_frosting(degrees: List[int]) -> bool:
    """Check if frosting is uniform (all degrees equal). O(b)."""
    if not degrees:
        return True
    return all(d == degrees[0] for d in degrees)


def moduli_table(max_genus: int, max_cherries: int) -> List[List[int]]:
    """
    Compute moduli dimension table.
    Returns a (max_genus+1) x (max_cherries+1) matrix where
    entry [g][n] = 3g - 3 + n (complex moduli dimension).
    """
    return [
        [3 * g - 3 + n for n in range(max_cherries + 1)]
        for g in range(max_genus + 1)
    ]


if __name__ == "__main__":
    # Demonstrate algorithms
    print("Cake enumeration up to complexity 10:")
    count = count_cakes(10)
    print(f"  Total cakes: {count}")

    print("\nModuli dimension table (complex) for g ∈ [0,4], n ∈ [0,5]:")
    table = moduli_table(4, 5)
    print("    g\\n  " + "  ".join(f"{n:3d}" for n in range(6)))
    for g, row in enumerate(table):
        print(f"    {g}    " + "  ".join(f"{d:3d}" for d in row))
