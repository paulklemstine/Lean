"""
Numerical demonstrations for the power-of-two characterization of pairwise
reflection symmetric (PRS) Latin squares.

Main facts illustrated:
  1. The multiplication (Cayley) table of a finite group is a Latin square of
     index one.
  2. That table is pairwise reflection symmetric (PRS) iff every element is its
     own inverse, i.e. the group has exponent two (x * x = e).
  3. A finite group of exponent two has order a power of two; the elementary
     abelian groups (Z/2)^k realize a PRS index-one Latin square of order 2^k.
  4. Groups whose order is NOT a power of two (cyclic Z/n, symmetric S_3, ...)
     never yield a PRS Cayley table.

The script is fully self-contained (standard library only).
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, List, Tuple


# ---------------------------------------------------------------------------
# Core combinatorial predicates
# ---------------------------------------------------------------------------

Square = List[List[int]]  # L[i][j] is the entry in row i, column j (symbols 0..n-1)


def is_latin(square: Square) -> bool:
    """Return True iff every row and every column is a permutation of 0..n-1."""
    n = len(square)
    full = set(range(n))
    rows_ok = all(set(row) == full for row in square)
    cols_ok = all({square[i][j] for i in range(n)} == full for j in range(n))
    return rows_ok and cols_ok


def pair_count(square: Square, j1: int, j2: int, p: int, q: int) -> int:
    """Number of rows i with square[i][j1] == p and square[i][j2] == q."""
    return sum(1 for i in range(len(square)) if square[i][j1] == p and square[i][j2] == q)


def is_prs(square: Square) -> bool:
    """Pairwise reflection symmetry: pairCount(j1,j2,p,q) == pairCount(j1,j2,q,p)."""
    n = len(square)
    rng = range(n)
    return all(
        pair_count(square, j1, j2, p, q) == pair_count(square, j1, j2, q, p)
        for j1, j2, p, q in product(rng, rng, rng, rng)
    )


def is_index_le_one(square: Square) -> bool:
    """Index <= 1: on distinct columns, the map i |-> (L[i][j1], L[i][j2]) is injective."""
    n = len(square)
    for j1 in range(n):
        for j2 in range(n):
            if j1 == j2:
                continue
            seen = set()
            for i in range(n):
                key = (square[i][j1], square[i][j2])
                if key in seen:
                    return False
                seen.add(key)
    return True


# ---------------------------------------------------------------------------
# Group construction of Cayley tables
# ---------------------------------------------------------------------------

def cayley_table(elements: List[object], mul: Callable[[object, object], object]) -> Square:
    """Build the Cayley table of a finite group given as (elements, product)."""
    index: Dict[object, int] = {g: i for i, g in enumerate(elements)}
    return [[index[mul(a, b)] for b in elements] for a in elements]


def is_exponent_two(elements: List[object], mul: Callable[[object, object], object],
                    identity: object) -> bool:
    """Return True iff x * x == identity for every element x."""
    return all(mul(x, x) == identity for x in elements)


def elementary_abelian_2group(k: int) -> Tuple[List[Tuple[int, ...]],
                                               Callable[..., Tuple[int, ...]],
                                               Tuple[int, ...]]:
    """(Z/2)^k: bit vectors of length k under coordinatewise XOR. Order 2^k."""
    elements = list(product((0, 1), repeat=k))
    def mul(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        return tuple((x ^ y) for x, y in zip(a, b))
    identity = tuple(0 for _ in range(k))
    return elements, mul, identity


def cyclic_group(n: int) -> Tuple[List[int], Callable[[int, int], int], int]:
    """Z/n under addition mod n. Order n."""
    elements = list(range(n))
    return elements, (lambda a, b: (a + b) % n), 0


def symmetric_group_3() -> Tuple[List[Tuple[int, ...]],
                                 Callable[..., Tuple[int, ...]],
                                 Tuple[int, ...]]:
    """S_3 as permutations of {0,1,2}, composed as functions. Order 6."""
    elements = list(product(range(3), repeat=3))
    elements = [p for p in elements if len(set(p)) == 3]  # bijections only
    def mul(a: Tuple[int, ...], b: Tuple[int, ...]) -> Tuple[int, ...]:
        # (a o b)(i) = a[b[i]]
        return tuple(a[b[i]] for i in range(3))
    identity = (0, 1, 2)
    return elements, mul, identity


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

def demo_elementary_abelian() -> None:
    print("=" * 68)
    print("Elementary abelian 2-groups (Z/2)^k  -->  PRS Latin squares of order 2^k")
    print("=" * 68)
    for k in range(1, 5):
        elements, mul, identity = elementary_abelian_2group(k)
        table = cayley_table(elements, mul)
        n = len(elements)
        print(f"k={k}: order n = 2^{k} = {n}")
        print(f"   exponent two : {is_exponent_two(elements, mul, identity)}")
        print(f"   is Latin     : {is_latin(table)}")
        print(f"   index <= 1   : {is_index_le_one(table)}")
        print(f"   is PRS       : {is_prs(table)}")
    print()


def demo_non_power_of_two() -> None:
    print("=" * 68)
    print("Groups of non-power-of-two order are NEVER PRS as Cayley tables")
    print("=" * 68)
    cases = []
    for n in (3, 5, 6, 7):
        cases.append((f"Z/{n}", cyclic_group(n)))
    cases.append(("S_3", symmetric_group_3()))
    for name, (elements, mul, identity) in cases:
        table = cayley_table(elements, mul)
        n = len(elements)
        print(f"{name:6s} (order {n}): exponent two = {is_exponent_two(elements, mul, identity)}, "
              f"Latin = {is_latin(table)}, PRS = {is_prs(table)}")
    print()


def demo_keystone_equivalence() -> None:
    """Illustrate: Cayley table is PRS  <=>  group has exponent two."""
    print("=" * 68)
    print("Keystone: (Cayley table PRS)  <=>  (group has exponent two)")
    print("=" * 68)
    trials = [
        ("Z/2",       cyclic_group(2)),
        ("Z/4",       cyclic_group(4)),   # order 4 but NOT exponent two
        ("(Z/2)^2",   elementary_abelian_2group(2)),
        ("(Z/2)^3",   elementary_abelian_2group(3)),
        ("Z/6",       cyclic_group(6)),
    ]
    for name, (elements, mul, identity) in trials:
        table = cayley_table(elements, mul)
        e2 = is_exponent_two(elements, mul, identity)
        prs = is_prs(table)
        status = "OK" if e2 == prs else "MISMATCH!"
        print(f"{name:9s} order {len(elements):2d}: exponent-two={e2!s:5s} "
              f"PRS={prs!s:5s}  [{status}]")
    print("Note: Z/4 has order 4 (a power of two) yet is NOT exponent two,")
    print("      so its Cayley table is NOT PRS -- exponent two is the true pivot.")
    print()


def show_table(name: str, table: Square) -> None:
    print(f"{name}:")
    for row in table:
        print("   " + " ".join(f"{x:2d}" for x in row))
    print()


def demo_show_small_tables() -> None:
    print("=" * 68)
    print("Explicit small PRS witnesses (XOR / addition tables)")
    print("=" * 68)
    for k in (1, 2):
        elements, mul, _ = elementary_abelian_2group(k)
        show_table(f"(Z/2)^{k}  (order {2 ** k})", cayley_table(elements, mul))


if __name__ == "__main__":
    demo_show_small_tables()
    demo_elementary_abelian()
    demo_non_power_of_two()
    demo_keystone_equivalence()
