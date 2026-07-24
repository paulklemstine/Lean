#!/usr/bin/env python3
"""Numerical demonstrations of the Erdős--Szekeres cup--cap method.

The script uses only the Python standard library.  It computes classical
thresholds, finds longest cups and caps by dynamic programming, reconstructs
witnesses, and checks the local-to-global orientation property on examples.
"""

from __future__ import annotations

from dataclasses import dataclass
from math import comb
from typing import Iterable, Literal, Sequence


@dataclass(frozen=True, order=True)
class Point:
    """A planar point with exact integer coordinates in the demonstrations."""

    x: int
    y: int


Turn = Literal[-1, 0, 1]
ChainKind = Literal["cup", "cap"]


def orientation(a: Point, b: Point, c: Point) -> int:
    """Return twice the signed area of the ordered triangle (a, b, c)."""

    return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)


def turn_sign(a: Point, b: Point, c: Point) -> Turn:
    """Return 1 for a left turn, -1 for a right turn, and 0 for collinearity."""

    value = orientation(a, b, c)
    return 1 if value > 0 else -1 if value < 0 else 0


def cup_cap_threshold(k: int, l: int) -> int:
    """Smallest integer strictly exceeding C(k+l-4, k-2)."""

    if k < 2 or l < 2:
        raise ValueError("k and l must both be at least 2")
    return comb(k + l - 4, k - 2) + 1


def happy_end_upper_bound(n: int) -> int:
    """Return the classical sufficient threshold C(2n-4, n-2)+1."""

    return cup_cap_threshold(n, n)


def is_general_position(points: Sequence[Point]) -> bool:
    """Check that no three points are collinear in O(N^3) time."""

    n = len(points)
    return all(
        orientation(points[i], points[j], points[k]) != 0
        for i in range(n)
        for j in range(i + 1, n)
        for k in range(j + 1, n)
    )


def is_chain(points: Sequence[Point], chain: Sequence[int], kind: ChainKind) -> bool:
    """Check increasing x-order and the consecutive-turn cup or cap condition."""

    if any(points[chain[i]].x >= points[chain[i + 1]].x for i in range(len(chain) - 1)):
        return False
    wanted = 1 if kind == "cup" else -1
    return all(
        turn_sign(points[chain[i]], points[chain[i + 1]], points[chain[i + 2]]) == wanted
        for i in range(len(chain) - 2)
    )


def all_triples_have_sign(
    points: Sequence[Point], chain: Sequence[int], wanted: Literal[-1, 1]
) -> bool:
    """Check the global orientation condition for every ordered triple in a chain."""

    r = len(chain)
    return all(
        turn_sign(points[chain[i]], points[chain[j]], points[chain[k]]) == wanted
        for i in range(r)
        for j in range(i + 1, r)
        for k in range(j + 1, r)
    )


def longest_cup_cap(points: Iterable[Point]) -> tuple[list[Point], list[Point]]:
    """Return one longest cup and one longest cap using O(N^3) dynamic programming.

    Points are sorted by x-coordinate. Distinct x-coordinates are required.
    Each table state (i, j) stores a longest chain whose final two points are
    i and j. Parent pointers reconstruct explicit witnesses.
    """

    ordered = sorted(points)
    n = len(ordered)
    if len({p.x for p in ordered}) != n:
        raise ValueError("all x-coordinates must be distinct")
    if n <= 1:
        return ordered.copy(), ordered.copy()

    up = [[0] * n for _ in range(n)]
    down = [[0] * n for _ in range(n)]
    up_parent: list[list[int | None]] = [[None] * n for _ in range(n)]
    down_parent: list[list[int | None]] = [[None] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            up[i][j] = down[i][j] = 2

    for j in range(n):
        for i in range(j):
            for h in range(i):
                sign = turn_sign(ordered[h], ordered[i], ordered[j])
                if sign > 0 and up[h][i] + 1 > up[i][j]:
                    up[i][j] = up[h][i] + 1
                    up_parent[i][j] = h
                elif sign < 0 and down[h][i] + 1 > down[i][j]:
                    down[i][j] = down[h][i] + 1
                    down_parent[i][j] = h

    def best_state(table: list[list[int]]) -> tuple[int, int]:
        return max(((i, j) for i in range(n) for j in range(i + 1, n)), key=lambda ij: table[ij[0]][ij[1]])

    def reconstruct(i: int, j: int, parent: list[list[int | None]]) -> list[Point]:
        indices = [j, i]
        while parent[i][j] is not None:
            h = parent[i][j]
            assert h is not None
            indices.append(h)
            i, j = h, i
        indices.reverse()
        return [ordered[t] for t in indices]

    ui, uj = best_state(up)
    di, dj = best_state(down)
    return reconstruct(ui, uj, up_parent), reconstruct(di, dj, down_parent)


def indices_of(points: Sequence[Point], chain: Sequence[Point]) -> list[int]:
    """Translate a point witness back to indices in a sorted distinct point list."""

    lookup = {point: i for i, point in enumerate(points)}
    return [lookup[point] for point in chain]


def threshold_demo() -> None:
    """Print diagonal and asymmetric cup--cap guarantees."""

    print("CLASSICAL HAPPY-END UPPER BOUNDS")
    print(" n | C(2n-4,n-2)+1")
    print("---+----------------")
    for n in range(2, 11):
        print(f"{n:2d} | {happy_end_upper_bound(n):>14d}")
    print("\nASYMMETRIC CUP--CAP THRESHOLDS")
    for k, l in [(3, 5), (4, 6), (5, 7)]:
        print(f"a {k}-cup or {l}-cap is forced at {cup_cap_threshold(k, l)} points")


def chain_demo() -> None:
    """Find explicit cup and cap witnesses in a deterministic point cloud."""

    points = [Point(x, x * x + ((17 * x + 5) % 11) - 5) for x in range(-7, 8)]
    ordered = sorted(points)
    cup, cap = longest_cup_cap(ordered)
    cup_ids = indices_of(ordered, cup)
    cap_ids = indices_of(ordered, cap)
    print("\nDYNAMIC-PROGRAMMING WITNESSES")
    print(f"general position: {is_general_position(ordered)}")
    print(f"longest cup length: {len(cup)}; points: {cup}")
    print(f"longest cap length: {len(cap)}; points: {cap}")
    print(f"cup local check: {is_chain(ordered, cup_ids, 'cup')}")
    print(f"cap local check: {is_chain(ordered, cap_ids, 'cap')}")
    print(f"cup global all-triples check: {all_triples_have_sign(ordered, cup_ids, 1)}")
    print(f"cap global all-triples check: {all_triples_have_sign(ordered, cap_ids, -1)}")


def parabola_demo() -> None:
    """Show directly that upward and downward parabolas form cups and caps."""

    cup_points = [Point(x, x * x) for x in range(-4, 5)]
    cap_points = [Point(x, -(x * x)) for x in range(-4, 5)]
    chain = list(range(9))
    print("\nLOCAL-TO-GLOBAL PARABOLA EXAMPLE")
    print(f"upward parabola is a cup: {is_chain(cup_points, chain, 'cup')}")
    print(f"all its ordered triples turn left: {all_triples_have_sign(cup_points, chain, 1)}")
    print(f"downward parabola is a cap: {is_chain(cap_points, chain, 'cap')}")
    print(f"all its ordered triples turn right: {all_triples_have_sign(cap_points, chain, -1)}")


def main() -> None:
    threshold_demo()
    chain_demo()
    parabola_demo()


if __name__ == "__main__":
    main()
