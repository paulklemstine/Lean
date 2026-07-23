"""Numerical demonstrations for matrix product factorizations (MPFs) in
association schemes.

An MPF is an identity A_R @ A_S = A_U where A_R, A_S, A_U are zero-one adjacency
matrices of relations on a finite vertex set, and the *ordinary* integer matrix
product is again a zero-one matrix. The central facts demonstrated here are:

  * (A_R @ A_S)[x, z] counts intermediate vertices y with x R y and y S z;
  * an MPF holds iff every target edge has exactly one such witness and every
    non-edge has none (the "unique-witness criterion");
  * valencies multiply:  u = r * s;
  * for the complement target J - I:  r * s = n - 1;
  * the pentagon (5-cycle): distance-one times distance-two equals J - I,
    saturating 2 * 2 = 5 - 1.

The code is self-contained (standard library only) with full type hints.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, List, Tuple

Relation = Callable[[int, int], bool]
Matrix = List[List[int]]


# --------------------------------------------------------------------------- #
# Core constructions
# --------------------------------------------------------------------------- #
def adjacency(n: int, rel: Relation) -> Matrix:
    """Zero-one adjacency matrix of a relation on vertices {0, ..., n-1}."""
    return [[1 if rel(x, y) else 0 for y in range(n)] for x in range(n)]


def mat_mul(a: Matrix, b: Matrix) -> Matrix:
    """Ordinary integer matrix product."""
    n = len(a)
    m = len(b[0])
    k = len(b)
    return [[sum(a[i][t] * b[t][j] for t in range(k)) for j in range(m)]
            for i in range(n)]


def out_degree(n: int, rel: Relation, x: int) -> int:
    """Number of outgoing neighbours of x under rel."""
    return sum(1 for y in range(n) if rel(x, y))


def is_regular(n: int, rel: Relation) -> Tuple[bool, int]:
    """Return (True, k) if the relation has constant valency k, else (False, -1)."""
    degs = {out_degree(n, rel, x) for x in range(n)}
    if len(degs) == 1:
        return True, degs.pop()
    return False, -1


def is_zero_one(mat: Matrix) -> bool:
    """Test whether every entry of a matrix is 0 or 1."""
    return all(entry in (0, 1) for row in mat for entry in row)


def two_step_witnesses(n: int, r: Relation, s: Relation,
                       x: int, z: int) -> List[int]:
    """List of intermediate vertices y with x R y and y S z."""
    return [y for y in range(n) if r(x, y) and s(y, z)]


# --------------------------------------------------------------------------- #
# Standard relations on Z/n
# --------------------------------------------------------------------------- #
def circulant(n: int, steps: Tuple[int, ...]) -> Relation:
    """Relation x ~ y iff (y - x) mod n is one of the given step sizes."""
    step_set = {s % n for s in steps}
    return lambda x, y: ((y - x) % n) in step_set


def distinct(x: int, y: int) -> bool:
    """The complement relation with adjacency matrix J - I."""
    return x != y


# --------------------------------------------------------------------------- #
# Demonstrations
# --------------------------------------------------------------------------- #
def demo_pentagon() -> None:
    """The headline example: A_1 @ A_2 = J - I on the 5-cycle."""
    print("=" * 68)
    print("PENTAGON (5-cycle): distance-one x distance-two = J - I")
    print("=" * 68)
    n = 5
    r1 = circulant(n, (1, -1))   # distance one: the outline C_5
    r2 = circulant(n, (2, -2))   # distance two: the pentagram
    a1 = adjacency(n, r1)
    a2 = adjacency(n, r2)
    j_minus_i = adjacency(n, distinct)

    product_matrix = mat_mul(a1, a2)
    print("\nA_1 (distance one):")
    for row in a1:
        print("  ", row)
    print("\nA_2 (distance two):")
    for row in a2:
        print("  ", row)
    print("\nA_1 @ A_2:")
    for row in product_matrix:
        print("  ", row)
    print("\nJ - I:")
    for row in j_minus_i:
        print("  ", row)

    print("\nA_1 @ A_2 == J - I ?  ", product_matrix == j_minus_i)
    print("product is zero-one ?  ", is_zero_one(product_matrix))

    _, r = is_regular(n, r1)
    _, s = is_regular(n, r2)
    print(f"\nvalencies: r = {r}, s = {s}")
    print(f"complement valency restriction: r * s = {r * s},  n - 1 = {n - 1}")
    print(f"saturated ?  {r * s == n - 1}")

    print("\nunique-witness check (each distinct pair has exactly one y):")
    all_unique = True
    for x, z in product(range(n), range(n)):
        w = two_step_witnesses(n, r1, r2, x, z)
        expected = 0 if x == z else 1
        if len(w) != expected:
            all_unique = False
        if x != z:
            print(f"  ({x}->{z}): witnesses {w}")
    print("all edges have a unique witness, all loops none ?  ", all_unique)


def demo_valency_multiplication() -> None:
    """Illustrate u = r * s on a genuine MPF and show a non-example."""
    print("\n" + "=" * 68)
    print("VALENCY MULTIPLICATION:  u = r * s")
    print("=" * 68)
    n = 5
    r1 = circulant(n, (1, -1))
    r2 = circulant(n, (2, -2))
    prod = mat_mul(adjacency(n, r1), adjacency(n, r2))
    # Reconstruct the target relation from the product matrix.
    target: Relation = lambda x, y: prod[x][y] == 1
    _, r = is_regular(n, r1)
    _, s = is_regular(n, r2)
    _, u = is_regular(n, target)
    print(f"5-cycle MPF:   r = {r}, s = {s}, u = {u},  r * s = {r * s}")
    print(f"u == r * s ?   {u == r * s}")

    print("\nNon-example: squaring the 6-cycle outline (product is NOT zero-one)")
    n6 = 6
    c6 = circulant(n6, (1, -1))
    sq = mat_mul(adjacency(n6, c6), adjacency(n6, c6))
    print("A(C_6) @ A(C_6):")
    for row in sq:
        print("  ", row)
    print("zero-one ?  ", is_zero_one(sq), "(diagonal counts = 2, so no MPF)")


def demo_search() -> None:
    """Search circulant schemes on n vertices for MPFs of J - I."""
    print("\n" + "=" * 68)
    print("SEARCH: circulant factorizations of J - I on Z/n")
    print("=" * 68)
    for n in range(3, 11):
        found: List[str] = []
        # candidate symmetric single-distance relations on Z/n
        max_d = n // 2
        rels = {d: circulant(n, (d, -d)) for d in range(1, max_d + 1)}
        jmi = adjacency(n, distinct)
        for d1, d2 in product(rels, rels):
            prod = mat_mul(adjacency(n, rels[d1]), adjacency(n, rels[d2]))
            if prod == jmi:
                found.append(f"dist-{d1} x dist-{d2}")
        tag = ", ".join(found) if found else "none"
        print(f"  n = {n:2d}:  {tag}")
    print("\nOnly n = 5 yields a nontrivial two-distance factorization of J - I,")
    print("matching the theorem that the 5-cycle is the minimal witness.")


def main() -> None:
    demo_pentagon()
    demo_valency_multiplication()
    demo_search()


if __name__ == "__main__":
    main()
