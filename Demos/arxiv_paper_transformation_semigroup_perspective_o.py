#!/usr/bin/env python3
"""Numerical demonstrations for the magma monoid of binary operations.

An operation on {0,...,n-1} is represented by an immutable square table.
The script checks the composition law, the idempotence criterion, diagonal
image equality, the central involution, and a concrete obstruction to
regularity. It uses only the Python standard library.
"""

from __future__ import annotations

from itertools import product as cartesian_product
from typing import Callable, Iterable, TypeAlias

Table: TypeAlias = tuple[tuple[int, ...], ...]
Pair: TypeAlias = tuple[int, int]


def validate(table: Table) -> int:
    """Return the table size, raising ValueError if it is not an operation."""
    n = len(table)
    if n == 0 or any(len(row) != n for row in table):
        raise ValueError("the operation table must be nonempty and square")
    if any(value < 0 or value >= n for row in table for value in row):
        raise ValueError("all entries must lie in range(n)")
    return n


def from_function(n: int, function: Callable[[int, int], int]) -> Table:
    """Construct an operation table from a callable."""
    table = tuple(tuple(function(a, b) for b in range(n)) for a in range(n))
    validate(table)
    return table


def magma_product(first: Table, second: Table) -> Table:
    """Return first ⋆ second, where (f ⋆ g)(a,b)=g(f(a,b),f(b,a))."""
    n = validate(first)
    if validate(second) != n:
        raise ValueError("operations must have the same underlying set")
    return from_function(
        n, lambda a, b: second[first[a][b]][first[b][a]]
    )


def opposite(table: Table) -> Table:
    """Reverse the two arguments of an operation."""
    n = validate(table)
    return from_function(n, lambda a, b: table[b][a])


def pairmorph(table: Table, pair: Pair) -> Pair:
    """Apply the pair transformation P_f(a,b)=(f(a,b),f(b,a))."""
    validate(table)
    a, b = pair
    return table[a][b], table[b][a]


def all_pairs(n: int) -> Iterable[Pair]:
    """Iterate through the ordered pairs on range(n)."""
    return cartesian_product(range(n), repeat=2)


def pair_image(table: Table) -> set[Pair]:
    """Compute the full image of the pair transformation."""
    n = validate(table)
    return {pairmorph(table, pair) for pair in all_pairs(n)}


def diagonal_image(table: Table) -> set[Pair]:
    """Compute images of diagonal inputs (x,x)."""
    n = validate(table)
    return {pairmorph(table, (x, x)) for x in range(n)}


def commutative_image(table: Table) -> set[Pair]:
    """Compute diagonal points occurring in the full pair image."""
    return {pair for pair in pair_image(table) if pair[0] == pair[1]}


def is_magma_idempotent(table: Table) -> bool:
    """Test f ⋆ f = f using the image-fixation characterization."""
    return all(pairmorph(table, q) == q for q in pair_image(table))


def left_selector(n: int) -> Table:
    """Return λ(a,b)=a, the magma-monoid identity."""
    return from_function(n, lambda a, _b: a)


def right_selector(n: int) -> Table:
    """Return ρ(a,b)=b, the central involutive unit."""
    return from_function(n, lambda _a, b: b)


def print_table(name: str, table: Table) -> None:
    """Print a labeled operation table."""
    print(f"{name}:")
    for row in table:
        print("  ", " ".join(map(str, row)))


def demonstrate() -> None:
    """Run reproducible examples of all principal results."""
    n = 3
    minimum = from_function(n, min)
    maximum = from_function(n, max)
    lam = left_selector(n)
    rho = right_selector(n)

    print("MAGMA MONOID ON X = {0, 1, 2}\n")
    print_table("minimum", minimum)
    print(f"minimum is magma-idempotent: {is_magma_idempotent(minimum)}")
    print(f"C_min = {sorted(commutative_image(minimum))}")
    print(f"D_min = {sorted(diagonal_image(minimum))}\n")

    # Composition law P_(f⋆g) = P_g ∘ P_f.
    composed = magma_product(minimum, maximum)
    composition_holds = all(
        pairmorph(composed, p) == pairmorph(maximum, pairmorph(minimum, p))
        for p in all_pairs(n)
    )
    print(f"pair-transformation composition law holds: {composition_holds}")

    # Identity and central involution laws.
    print(f"λ ⋆ min = min: {magma_product(lam, minimum) == minimum}")
    print(f"min ⋆ λ = min: {magma_product(minimum, lam) == minimum}")
    print(f"ρ ⋆ ρ = λ: {magma_product(rho, rho) == lam}")
    print(
        "ρ reverses maximum on both sides: "
        f"{magma_product(rho, maximum) == opposite(maximum) == magma_product(maximum, rho)}"
    )

    # A two-element operation with C_f != D_f, hence not regular.
    obstruction: Table = ((0, 1), (1, 0))
    print("\nDIAGONAL OBSTRUCTION ON X = {0, 1}")
    print_table("exclusive-equality operation", obstruction)
    c_set = commutative_image(obstruction)
    d_set = diagonal_image(obstruction)
    print(f"commutative image C_f = {sorted(c_set)}")
    print(f"diagonal image D_f    = {sorted(d_set)}")
    print(f"C_f = D_f: {c_set == d_set}")
    print("Conclusion: this operation is not regular and not magma-idempotent.")


if __name__ == "__main__":
    demonstrate()
