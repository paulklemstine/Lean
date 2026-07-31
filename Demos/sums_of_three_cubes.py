#!/usr/bin/env python3
"""Numerical demonstrations for sums of three cubes.

The program verifies the complete modulo-nine classification, prints explicit
local witnesses, demonstrates the two-parameter polynomial identity, checks the
nonzero family for 6*t^3, and performs an optional bounded meet-in-the-middle
search. It uses only the Python standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, Optional, Tuple

Triple = Tuple[int, int, int]


@dataclass(frozen=True)
class LocalResult:
    """Result of deciding the three-cube congruence modulo nine."""

    target: int
    residue: int
    witness: Optional[Triple]

    @property
    def solvable(self) -> bool:
        return self.witness is not None


MOD_NINE_WITNESSES: Dict[int, Triple] = {
    0: (0, 0, 0),
    1: (1, 0, 0),
    2: (1, 1, 0),
    3: (1, 1, 1),
    6: (-1, -1, -1),
    7: (-1, -1, 0),
    8: (-1, 0, 0),
}


def cube_sum(triple: Triple) -> int:
    """Return x^3 + y^3 + z^3 for a triple of integers."""

    x, y, z = triple
    return x**3 + y**3 + z**3


def classify_mod_nine(target: int) -> LocalResult:
    """Decide local representability modulo nine and return a small witness."""

    residue = target % 9
    return LocalResult(target, residue, MOD_NINE_WITNESSES.get(residue))


def all_cube_residues(modulus: int) -> set[int]:
    """Compute the image of the cubing map modulo a positive modulus."""

    if modulus <= 0:
        raise ValueError("modulus must be positive")
    return {x**3 % modulus for x in range(modulus)}


def all_three_cube_residues(modulus: int) -> set[int]:
    """Compute every sum-of-three-cubes residue modulo a positive modulus."""

    cubes = all_cube_residues(modulus)
    return {(a + b + c) % modulus for a in cubes for b in cubes for c in cubes}


def vieta_triple(a: int, b: int) -> Tuple[int, Triple]:
    """Return the target and triple from a^3+b^3+(-a-b)^3=-3ab(a+b)."""

    triple = (a, b, -a - b)
    target = -3 * a * b * (a + b)
    assert cube_sum(triple) == target
    return target, triple


def six_times_cube_triple(t: int) -> Tuple[int, Triple]:
    """Return the nonzero representation of 6*t^3; require t != 0."""

    if t == 0:
        raise ValueError("t must be nonzero to make all coordinates nonzero")
    triple = (2 * t, -t, -t)
    target = 6 * t**3
    assert all(value != 0 for value in triple)
    assert cube_sum(triple) == target
    return target, triple


def bounded_representation(target: int, bound: int) -> Optional[Triple]:
    """Find a representation with |x|,|y|,|z| <= bound, if one exists.

    The meet-in-the-middle table uses O(bound^2) time and memory, followed by
    O(bound) expected-time hash lookups. A None result is only a bounded-search
    statement, not a proof of global nonrepresentability.
    """

    if bound < 0:
        raise ValueError("bound must be nonnegative")
    values = range(-bound, bound + 1)
    pair_sums: Dict[int, Tuple[int, int]] = {}
    for x in values:
        for y in values:
            pair_sums.setdefault(x**3 + y**3, (x, y))
    for z in values:
        pair = pair_sums.get(target - z**3)
        if pair is not None:
            triple = (pair[0], pair[1], z)
            assert cube_sum(triple) == target
            return triple
    return None


def demonstrate_targets(targets: Iterable[int]) -> None:
    """Print local classifications and bounded examples for selected targets."""

    print("Exact modulo-nine classification")
    print("-" * 38)
    for target in targets:
        result = classify_mod_nine(target)
        if result.witness is None:
            print(f"k={target:4d}: residue {result.residue}; forbidden modulo 9")
        else:
            witness_sum = cube_sum(result.witness) % 9
            print(
                f"k={target:4d}: residue {result.residue}; "
                f"witness {result.witness}, cubic sum residue {witness_sum}"
            )


def main() -> None:
    """Run all demonstrations and internal consistency checks."""

    cubes = all_cube_residues(9)
    sums = all_three_cube_residues(9)
    assert cubes == {0, 1, 8}
    assert sums == {0, 1, 2, 3, 6, 7, 8}
    print(f"Cube residues modulo 9: {sorted(cubes)}")
    print(f"Three-cube target residues modulo 9: {sorted(sums)}")
    print(f"Forbidden target residues: {sorted(set(range(9)) - sums)}\n")

    demonstrate_targets([-14, -4, 0, 1, 2, 3, 4, 5, 6, 7, 8, 13])

    print("\nTwo-parameter identity examples")
    print("-" * 38)
    for a, b in [(2, -1), (4, 2), (-3, 5)]:
        target, triple = vieta_triple(a, b)
        print(f"a={a:2d}, b={b:2d}: {triple} -> {target}")

    print("\nNonzero representations of 6*t^3")
    print("-" * 38)
    for t in [-3, -1, 1, 2, 3]:
        target, triple = six_times_cube_triple(t)
        print(f"t={t:2d}: {triple} -> {target}")

    print("\nBounded meet-in-the-middle search (bound 25)")
    print("-" * 48)
    for target in [6, 9, 12, 18, 33]:
        triple = bounded_representation(target, 25)
        print(f"k={target:2d}: {triple if triple is not None else 'not found in box'}")


if __name__ == "__main__":
    main()
