#!/usr/bin/env python3
"""Numerical demonstrations for triangle shadows and Fibonacci primitive divisors."""

from __future__ import annotations

from itertools import combinations
from math import comb, isqrt
from typing import Iterable

Edge = tuple[int, int]


def normalize_edges(edges: Iterable[Edge]) -> set[Edge]:
    """Normalize undirected edges as ordered pairs and reject loops."""
    result: set[Edge] = set()
    for u, v in edges:
        if u == v:
            raise ValueError("A simple graph cannot contain loops")
        result.add((min(u, v), max(u, v)))
    return result


def triangle_family(vertices: Iterable[int], edges: Iterable[Edge]) -> set[frozenset[int]]:
    """Return all three-vertex cliques of a finite simple graph."""
    verts = sorted(set(vertices))
    edge_set = normalize_edges(edges)
    triangles: set[frozenset[int]] = set()
    for a, b, c in combinations(verts, 3):
        if {(a, b), (a, c), (b, c)} <= edge_set:
            triangles.add(frozenset((a, b, c)))
    return triangles


def lower_shadow(family: Iterable[frozenset[int]]) -> set[frozenset[int]]:
    """Return all subsets obtained by deleting one point from each nonempty set."""
    shadow: set[frozenset[int]] = set()
    for member in family:
        for point in member:
            shadow.add(member - {point})
    return shadow


def complete_core_graph(n: int, k: int) -> tuple[list[int], set[Edge]]:
    """Construct K_k together with n-k isolated vertices."""
    if not 0 <= k <= n:
        raise ValueError("Require 0 <= k <= n")
    vertices = list(range(n))
    edges = {(u, v) for u, v in combinations(range(k), 2)}
    return vertices, edges


def fibonacci_up_to(n: int) -> list[int]:
    """Return [F_0, ..., F_n]."""
    if n < 0:
        raise ValueError("The index must be nonnegative")
    values = [0, 1]
    for _ in range(2, n + 1):
        values.append(values[-1] + values[-2])
    return values[: n + 1]


def prime_factors(value: int) -> list[int]:
    """Return the distinct prime factors of a positive integer by trial division."""
    if value < 1:
        raise ValueError("Factorization requires a positive integer")
    factors: list[int] = []
    candidate = 2
    remainder = value
    while candidate <= isqrt(remainder):
        if remainder % candidate == 0:
            factors.append(candidate)
            while remainder % candidate == 0:
                remainder //= candidate
        candidate = 3 if candidate == 2 else candidate + 2
    if remainder > 1:
        factors.append(remainder)
    return factors


def primitive_prime_divisors(n: int) -> list[int]:
    """Find prime factors of F_n absent from F_1,...,F_(n-1)."""
    if n < 1:
        raise ValueError("Require n >= 1")
    fibs = fibonacci_up_to(n)
    return [
        p
        for p in prime_factors(fibs[n])
        if all(fibs[j] % p != 0 for j in range(1, n))
    ]


def rank_of_apparition_mod(p: int, search_limit: int) -> int | None:
    """Return the first positive Fibonacci index divisible by p, if within the limit."""
    if p < 2:
        raise ValueError("The modulus must be at least 2")
    previous, current = 0, 1
    for index in range(1, search_limit + 1):
        if current % p == 0:
            return index
        previous, current = current, (previous + current) % p
    return None


def graph_demo() -> None:
    """Demonstrate equality for K_k plus isolated vertices."""
    n, k = 9, 6
    vertices, edges = complete_core_graph(n, k)
    triangles = triangle_family(vertices, edges)
    shadow = lower_shadow(triangles)
    edge_sets = {frozenset(edge) for edge in edges}
    print("TRIANGLE-SHADOW DEMONSTRATION")
    print(f"Graph: K_{k} plus {n-k} isolated vertices")
    print(f"Triangles: {len(triangles)} = C({k},3) = {comb(k, 3)}")
    print(f"Shadow pairs: {len(shadow)} = C({k},2) = {comb(k, 2)}")
    print(f"Edges: {len(edges)}")
    print(f"Every shadow pair is an edge: {shadow <= edge_sets}")
    assert len(triangles) == comb(k, 3)
    assert len(edges) == comb(k, 2)
    assert shadow <= edge_sets


def fibonacci_demo() -> None:
    """Display primitive divisors and their first occurrence for sample indices."""
    print("\nFIBONACCI PRIMITIVE-DIVISOR DEMONSTRATION")
    fibs = fibonacci_up_to(20)
    for n in (13, 14, 15, 16, 18, 20):
        primitive = primitive_prime_divisors(n)
        ranks = {p: rank_of_apparition_mod(p, n) for p in primitive}
        print(f"n={n:2d}, F_n={fibs[n]}, primitive primes={primitive}, ranks={ranks}")
        assert primitive
        assert all(rank == n for rank in ranks.values())


def main() -> None:
    graph_demo()
    fibonacci_demo()


if __name__ == "__main__":
    main()
