#!/usr/bin/env python3
"""Numerical demonstrations of factorial coordinates and triangle shadows.

The script uses only the Python standard library. It demonstrates:
1. mixed-radix and factoradic place-value agreement;
2. factoradic extraction, reconstruction, and exhaustive uniqueness;
3. triangle/edge counting and the sharp Kruskal--Katona threshold.
"""

from __future__ import annotations

from itertools import combinations, product
from math import comb, factorial
from typing import Iterable, Sequence

Edge = tuple[int, int]


def radix_products(radices: Sequence[int]) -> list[int]:
    """Return B_i = product(radices[:i]) for all supplied positions."""
    products: list[int] = []
    running = 1
    for radix in radices:
        if radix <= 0:
            raise ValueError("radices must be positive")
        products.append(running)
        running *= radix
    return products


def mixed_radix_value(digits: Sequence[int], radices: Sequence[int]) -> int:
    """Evaluate digits against the running products of the radices."""
    if len(digits) != len(radices):
        raise ValueError("digits and radices must have equal length")
    return sum(d * place for d, place in zip(digits, radix_products(radices)))


def factoradic_value(digits: Sequence[int]) -> int:
    """Evaluate little-endian digits as sum(d_i * i!)."""
    return sum(digit * factorial(i) for i, digit in enumerate(digits))


def factoradic_digits(n: int, k: int) -> list[int]:
    """Extract k little-endian digits floor(n / i!) mod (i + 1)."""
    if n < 0 or k < 0:
        raise ValueError("n and k must be nonnegative")
    if n >= factorial(k):
        raise ValueError("sharp reconstruction hypothesis n < k! is required")
    return [(n // factorial(i)) % (i + 1) for i in range(k)]


def valid_factoradic(digits: Sequence[int]) -> bool:
    """Check 0 <= d_i <= i at every position."""
    return all(0 <= digit <= i for i, digit in enumerate(digits))


def all_factoradic_codes(k: int) -> Iterable[tuple[int, ...]]:
    """Generate all length-k valid codes in lexicographic product order."""
    if k < 0:
        raise ValueError("k must be nonnegative")
    return product(*(range(i + 1) for i in range(k)))


def normalize_edges(edges: Iterable[Edge]) -> set[Edge]:
    """Normalize undirected edges and reject loops."""
    result: set[Edge] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("simple graphs cannot contain loops")
        result.add((u, v) if u < v else (v, u))
    return result


def complete_graph_edges(k: int, n: int | None = None) -> set[Edge]:
    """Return K_k on vertices 0,...,k-1, with optional isolated vertices."""
    if k < 0 or (n is not None and n < k):
        raise ValueError("require 0 <= k <= n")
    return set(combinations(range(k), 2))


def graph_triangles(n: int, edges: Iterable[Edge]) -> set[tuple[int, int, int]]:
    """Enumerate all triangles of a simple graph on vertices range(n)."""
    edge_set = normalize_edges(edges)
    if any(u < 0 or v >= n for u, v in edge_set):
        raise ValueError("edge endpoint outside range(n)")
    return {
        (a, b, c)
        for a, b, c in combinations(range(n), 3)
        if (a, b) in edge_set and (a, c) in edge_set and (b, c) in edge_set
    }


def triangle_shadow(triangles: Iterable[tuple[int, int, int]]) -> set[Edge]:
    """Return all pairs obtained by deleting one vertex from a triangle."""
    shadow: set[Edge] = set()
    for triangle in triangles:
        shadow.update(combinations(sorted(triangle), 2))
    return shadow


def triangle_edge_certificate(n: int, edges: Iterable[Edge], k: int) -> dict[str, int | bool]:
    """Count graph data and check the binomial triangle-to-edge implication."""
    edge_set = normalize_edges(edges)
    triangles = graph_triangles(n, edge_set)
    shadow = triangle_shadow(triangles)
    hypothesis = 3 <= k <= n and len(triangles) >= comb(k, 3)
    conclusion = len(edge_set) >= comb(k, 2)
    return {
        "vertices": n,
        "k": k,
        "edges": len(edge_set),
        "triangles": len(triangles),
        "shadow_pairs": len(shadow),
        "triangle_threshold": comb(k, 3) if k >= 3 else 0,
        "edge_threshold": comb(k, 2) if k >= 2 else 0,
        "shadow_is_contained_in_edges": shadow <= edge_set,
        "hypothesis_holds": hypothesis,
        "conclusion_holds": conclusion,
        "implication_verified": (not hypothesis) or conclusion,
    }


def demonstrate_factoradics() -> None:
    """Print bridge, reconstruction, and finite-bijection examples."""
    n, k = 463, 6
    digits = factoradic_digits(n, k)
    radices = [i + 1 for i in range(k)]
    places = radix_products(radices)
    print("FACTORIAL / MIXED-RADIX BRIDGE")
    print(f"n={n}, k={k}, digits (low to high)={digits}")
    print(f"mixed-radix places={places}")
    print(f"factorial places={[factorial(i) for i in range(k)]}")
    print(f"digits valid: {valid_factoradic(digits)}")
    print(f"factoradic reconstruction: {factoradic_value(digits)}")
    print(f"mixed-radix reconstruction: {mixed_radix_value(digits, radices)}")

    test_k = 7
    codes = list(all_factoradic_codes(test_k))
    values = [factoradic_value(code) for code in codes]
    expected = set(range(factorial(test_k)))
    print("\nFINITE CODE CLASSIFICATION")
    print(f"length {test_k} codes: {len(codes)} = {test_k}! = {factorial(test_k)}")
    print(f"all values unique: {len(values) == len(set(values))}")
    print(f"values are exactly [0, {test_k}!): {set(values) == expected}")


def demonstrate_graphs() -> None:
    """Print sharp and non-complete graph examples."""
    print("\nTRIANGLE SHADOW / EDGE BRIDGE")
    n, k = 9, 6
    sharp_edges = complete_graph_edges(k, n)
    sharp = triangle_edge_certificate(n, sharp_edges, k)
    print("K_6 plus three isolated vertices (sharp case):")
    for key, value in sharp.items():
        print(f"  {key}: {value}")

    extra_edges = sharp_edges | {(6, 0), (6, 1), (7, 2), (7, 3), (8, 4)}
    enriched = triangle_edge_certificate(n, extra_edges, k)
    print("\nThe same clique with additional edges:")
    for key, value in enriched.items():
        print(f"  {key}: {value}")


def main() -> None:
    demonstrate_factoradics()
    demonstrate_graphs()


if __name__ == "__main__":
    main()
