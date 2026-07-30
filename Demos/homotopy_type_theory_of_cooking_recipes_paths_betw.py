#!/usr/bin/env python3
"""Numerical demonstrations for finite cubical recipe spaces.

The program uses only the Python standard library.  A recipe state is a tuple of
Booleans and a method is a tuple of zero-based coordinate indices.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Iterable, Sequence

Recipe = tuple[bool, ...]
Method = tuple[int, ...]


def all_recipes(n: int) -> list[Recipe]:
    """Enumerate the 2**n vertices of the n-dimensional Boolean cube."""
    if n < 0:
        raise ValueError("n must be nonnegative")
    return [tuple(bits) for bits in product((False, True), repeat=n)]


def validate_method(n: int, method: Sequence[int]) -> None:
    """Check that every method coordinate belongs to range(n)."""
    invalid = [i for i in method if not 0 <= i < n]
    if invalid:
        raise ValueError(f"coordinates outside 0..{n - 1}: {invalid}")


def toggle(recipe: Recipe, coordinate: int) -> Recipe:
    """Reverse one binary ingredient choice."""
    validate_method(len(recipe), (coordinate,))
    result = list(recipe)
    result[coordinate] = not result[coordinate]
    return tuple(result)


def follow(recipe: Recipe, method: Sequence[int]) -> Recipe:
    """Execute coordinate toggles from left to right."""
    validate_method(len(recipe), method)
    result = recipe
    for coordinate in method:
        result = toggle(result, coordinate)
    return result


def signature(n: int, method: Sequence[int]) -> Recipe:
    """Return the parity vector recording odd coordinate multiplicities."""
    validate_method(n, method)
    parity = [False] * n
    for coordinate in method:
        parity[coordinate] = not parity[coordinate]
    return tuple(parity)


def xor_recipes(left: Recipe, right: Recipe) -> Recipe:
    """Compute coordinatewise exclusive-or of equally sized states."""
    if len(left) != len(right):
        raise ValueError("states must have equal dimension")
    return tuple(a != b for a, b in zip(left, right))


def canonical_method(method_signature: Recipe) -> Method:
    """Return the increasing minimal method realizing a signature."""
    return tuple(i for i, bit in enumerate(method_signature) if bit)


def is_loop(recipe: Recipe, method: Sequence[int]) -> bool:
    """Test the zero-signature loop criterion."""
    return not any(signature(len(recipe), method))


def bit_string(recipe: Recipe) -> str:
    """Format a Boolean recipe as a compact binary vector."""
    return "".join("1" if bit else "0" for bit in recipe)


@dataclass(frozen=True)
class Demonstration:
    title: str
    lines: tuple[str, ...]


def cardinality_demo(max_dimension: int = 6) -> Demonstration:
    """Compare enumerated fiber sizes with the formula 2**n."""
    rows = tuple(
        f"n={n}: enumerated={len(all_recipes(n)):2d}, formula={2**n:2d}"
        for n in range(max_dimension + 1)
    )
    assert all(len(all_recipes(n)) == 2**n for n in range(max_dimension + 1))
    return Demonstration("Binary fiber cardinalities", rows)


def endpoint_demo() -> Demonstration:
    """Exhibit endpoint classification and canonical reduction."""
    start: Recipe = (False, True, False, True)
    first: Method = (0, 2, 1, 2, 3, 0, 3)
    sig = signature(len(start), first)
    short = canonical_method(sig)
    direct = follow(start, first)
    predicted = xor_recipes(start, sig)
    reduced = follow(start, short)
    assert direct == predicted == reduced
    return Demonstration(
        "Endpoint prediction by parity signature",
        (
            f"start       = {bit_string(start)}",
            f"method      = {first}",
            f"signature   = {bit_string(sig)}",
            f"endpoint    = {bit_string(direct)}",
            f"canonical   = {short}",
            f"same result = {direct == reduced}",
        ),
    )


def path_laws_demo() -> Demonstration:
    """Check a commuting square, cancellation, and reversal loop."""
    start: Recipe = (False, True, False)
    i, j = 0, 2
    square_left = follow(start, (i, j))
    square_right = follow(start, (j, i))
    backtrack = follow(start, (i, i))
    path: Method = (0, 1, 2, 1)
    reverse_loop = path + tuple(reversed(path))
    assert square_left == square_right
    assert backtrack == start
    assert follow(start, reverse_loop) == start
    assert is_loop(start, reverse_loop)
    return Demonstration(
        "Cubical path laws",
        (
            f"commuting square endpoints: {bit_string(square_left)} and "
            f"{bit_string(square_right)}",
            f"double toggle returns:      {bit_string(backtrack)}",
            f"path + reverse returns:     {bit_string(follow(start, reverse_loop))}",
            f"reverse method signature:   {bit_string(signature(3, reverse_loop))}",
        ),
    )


def exhaustive_check(max_dimension: int = 4, max_method_length: int = 5) -> int:
    """Exhaustively test the endpoint formula over small finite cubes."""
    checked = 0
    for n in range(max_dimension + 1):
        methods: Iterable[Method]
        for length in range(max_method_length + 1):
            methods = (tuple(p) for p in product(range(n), repeat=length))
            if n == 0 and length > 0:
                continue
            for method in methods:
                sig = signature(n, method)
                for recipe in all_recipes(n):
                    assert follow(recipe, method) == xor_recipes(recipe, sig)
                    checked += 1
    return checked


def main() -> None:
    """Print three demonstrations and an exhaustive finite consistency check."""
    demos = (cardinality_demo(), endpoint_demo(), path_laws_demo())
    for demo in demos:
        print(f"\n=== {demo.title} ===")
        print("\n".join(demo.lines))
    checked = exhaustive_check()
    print(f"\nEndpoint formula checked on {checked} state-method pairs.")


if __name__ == "__main__":
    main()
