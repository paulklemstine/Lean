#!/usr/bin/env python3
"""Numerical demonstrations of graph-supported orders and clique shadows."""

from __future__ import annotations

from itertools import combinations, permutations
from math import comb
from typing import Callable, Iterable, Sequence, TypeVar

Permutation = tuple[int, ...]
Edge = tuple[int, int]
Triangle = tuple[int, int, int]
T = TypeVar("T")


def validate_permutation(w: Sequence[int]) -> None:
    """Raise ValueError unless w is a permutation of range(len(w))."""
    if sorted(w) != list(range(len(w))):
        raise ValueError(f"not a permutation: {w}")


def inverse_permutation(w: Sequence[int]) -> Permutation:
    """Return the inverse of a finite zero-based permutation."""
    validate_permutation(w)
    inv = [0] * len(w)
    for i, value in enumerate(w):
        inv[value] = i
    return tuple(inv)


def rank_matrix(w: Sequence[int]) -> list[list[int]]:
    """Compute r_w(i,j) using two-dimensional prefix accumulation."""
    validate_permutation(w)
    n = len(w)
    matrix = [[0] * n for _ in range(n)]
    for i, value in enumerate(w):
        for row in range(i, n):
            for column in range(value, n):
                matrix[row][column] += 1
    return matrix


def bruhat_le(u: Sequence[int], v: Sequence[int]) -> bool:
    """Test u <= v by the Ehresmann rank criterion."""
    if len(u) != len(v):
        return False
    ru, rv = rank_matrix(u), rank_matrix(v)
    return all(rv[i][j] <= ru[i][j] for i in range(len(u)) for j in range(len(u)))


def graph_product_bruhat_le(u: Sequence[int], v: Sequence[int]) -> bool:
    """Compare (u,u^-1) and (v,v^-1) componentwise in Bruhat order."""
    return bruhat_le(u, v) and bruhat_le(inverse_permutation(u), inverse_permutation(v))


def principal_closure(items: Iterable[T], relation: Callable[[T, T], bool], x: T) -> set[T]:
    """Return the principal lower set {y : y <= x} in a finite relation."""
    return {y for y in items if relation(y, x)}


def normalized_edges(edges: Iterable[Edge]) -> set[Edge]:
    """Normalize undirected edges and reject loops."""
    result: set[Edge] = set()
    for a, b in edges:
        if a == b:
            raise ValueError("a simple graph cannot contain a loop")
        result.add((min(a, b), max(a, b)))
    return result


def triangles_and_shadow(n: int, edges: Iterable[Edge]) -> tuple[set[Triangle], set[Edge]]:
    """Enumerate graph triangles and the two-element shadow of their family."""
    edge_set = normalized_edges(edges)
    triangles: set[Triangle] = set()
    shadow: set[Edge] = set()
    for a, b, c in combinations(range(n), 3):
        pairs = {(a, b), (a, c), (b, c)}
        if pairs <= edge_set:
            triangles.add((a, b, c))
            shadow.update(pairs)
    return triangles, shadow


def clique_with_isolates(n: int, k: int) -> set[Edge]:
    """Construct K_k together with n-k isolated vertices."""
    if not 0 <= k <= n:
        raise ValueError("require 0 <= k <= n")
    return set(combinations(range(k), 2))


def print_matrix(matrix: Sequence[Sequence[int]]) -> None:
    for row in matrix:
        print("  " + " ".join(f"{entry:2d}" for entry in row))


def demonstrate_bruhat() -> None:
    print("\n=== Bruhat inversion and graph embedding ===")
    w: Permutation = (2, 0, 3, 1)
    inv = inverse_permutation(w)
    rw, rinv = rank_matrix(w), rank_matrix(inv)
    transpose_ok = all(rinv[i][j] == rw[j][i] for i in range(len(w)) for j in range(len(w)))
    print(f"w       = {w}")
    print(f"w^-1    = {inv}")
    print("rank matrix of w:")
    print_matrix(rw)
    print(f"inverse rank matrix is the transpose: {transpose_ok}")

    n = 4
    perms = list(permutations(range(n)))
    all_pairs_ok = all(bruhat_le(u, v) == graph_product_bruhat_le(u, v) for u in perms for v in perms)
    target: Permutation = (1, 0, 3, 2)
    closure = principal_closure(perms, bruhat_le, target)
    product_closure_labels = {u for u in perms if graph_product_bruhat_le(u, target)}
    print(f"all {len(perms) ** 2} ordered pairs satisfy the graph equivalence: {all_pairs_ok}")
    print(f"principal closure below {target} has {len(closure)} permutations")
    print(f"pullback of graph-supported product closure agrees: {closure == product_closure_labels}")


def demonstrate_triangle_shadow() -> None:
    print("\n=== Triangle shadows and edge bounds ===")
    for n, k in [(6, 6), (8, 5), (10, 4)]:
        edges = clique_with_isolates(n, k)
        triangles, shadow = triangles_and_shadow(n, edges)
        print(
            f"K_{k} plus {n-k} isolates: triangles={len(triangles)}="
            f"C({k},3)={comb(k, 3)}, shadow={len(shadow)}, edges={len(edges)}="
            f"C({k},2)={comb(k, 2)}, shadow subset edges={shadow <= edges}"
        )

    custom_edges = {(0, 1), (0, 2), (1, 2), (1, 3), (2, 3), (1, 4), (3, 4)}
    triangles, shadow = triangles_and_shadow(5, custom_edges)
    print(f"custom graph edges: {sorted(custom_edges)}")
    print(f"triangles: {sorted(triangles)}")
    print(f"triangle shadow: {sorted(shadow)}")
    print(f"shadow subset of edges: {shadow <= custom_edges}")


def main() -> None:
    demonstrate_bruhat()
    demonstrate_triangle_shadow()


if __name__ == "__main__":
    main()
