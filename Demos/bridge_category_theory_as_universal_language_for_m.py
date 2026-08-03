#!/usr/bin/env python3
"""Finite demonstrations of Yoneda reconstruction and Heyting-frame laws.

The script uses only Python's standard library.  It models a finite poset as a
category and a finite topology as the frame of its open sets.
"""

from __future__ import annotations

from itertools import product
from typing import Callable, Dict, FrozenSet, Iterable, List, Sequence, Tuple

Point = int
OpenSet = FrozenSet[Point]
Restriction = Callable[[int], int]


def powerset(points: Sequence[Point]) -> List[OpenSet]:
    """Return all subsets of a finite sequence as frozensets."""
    subsets: List[OpenSet] = [frozenset()]
    for point in points:
        subsets += [subset | {point} for subset in subsets]
    return subsets


def is_topology(points: Sequence[Point], opens: Iterable[OpenSet]) -> bool:
    """Check the topology axioms for a finite family of subsets."""
    family = set(opens)
    whole = frozenset(points)
    if frozenset() not in family or whole not in family:
        return False
    # In a finite family, arbitrary unions reduce to unions of subfamilies;
    # closure under binary unions suffices by induction.
    return all((a | b) in family and (a & b) in family for a in family for b in family)


def interior(subset: OpenSet, opens: Sequence[OpenSet]) -> OpenSet:
    """Compute the largest open set contained in a subset."""
    result: OpenSet = frozenset()
    for candidate in opens:
        if candidate <= subset:
            result = result | candidate
    return result


def heyting_implication(
    antecedent: OpenSet,
    consequent: OpenSet,
    universe: OpenSet,
    opens: Sequence[OpenSet],
) -> OpenSet:
    """Compute U => W as int((X \\ U) union W)."""
    return interior((universe - antecedent) | consequent, opens)


def heyting_implication_by_universal_property(
    antecedent: OpenSet, consequent: OpenSet, opens: Sequence[OpenSet]
) -> OpenSet:
    """Join all V satisfying U intersection V subset W."""
    admissible = [v for v in opens if (antecedent & v) <= consequent]
    result: OpenSet = frozenset()
    for v in admissible:
        result = result | v
    return result


def negation(value: OpenSet, universe: OpenSet, opens: Sequence[OpenSet]) -> OpenSet:
    """Compute intuitionistic negation value => empty."""
    return heyting_implication(value, frozenset(), universe, opens)


def double_negation(value: OpenSet, universe: OpenSet, opens: Sequence[OpenSet]) -> OpenSet:
    """Compute the double-negation nucleus."""
    return negation(negation(value, universe, opens), universe, opens)


def verify_frame_laws(points: Sequence[Point], opens: Sequence[OpenSet]) -> Dict[str, bool]:
    """Exhaustively verify implication and double-negation laws."""
    universe = frozenset(points)
    implication_formula = all(
        heyting_implication(u, w, universe, opens)
        == heyting_implication_by_universal_property(u, w, opens)
        for u, w in product(opens, repeat=2)
    )
    adjunction = all(
        ((u & v) <= w)
        == (v <= heyting_implication(u, w, universe, opens))
        for u, v, w in product(opens, repeat=3)
    )
    extensive = all(u <= double_negation(u, universe, opens) for u in opens)
    monotone = all(
        not (u <= v)
        or double_negation(u, universe, opens) <= double_negation(v, universe, opens)
        for u, v in product(opens, repeat=2)
    )
    idempotent = all(
        double_negation(double_negation(u, universe, opens), universe, opens)
        == double_negation(u, universe, opens)
        for u in opens
    )
    meet_preserving = all(
        double_negation(u & v, universe, opens)
        == (double_negation(u, universe, opens) & double_negation(v, universe, opens))
        for u, v in product(opens, repeat=2)
    )
    fixes_bounds = (
        double_negation(frozenset(), universe, opens) == frozenset()
        and double_negation(universe, universe, opens) == universe
    )
    return {
        "implication formula equals universal construction": implication_formula,
        "meet-implication adjunction": adjunction,
        "double negation is extensive": extensive,
        "double negation is monotone": monotone,
        "double negation is idempotent": idempotent,
        "double negation preserves binary meets": meet_preserving,
        "double negation fixes bottom and top": fixes_bounds,
    }


def yoneda_reconstruct_chain(
    representing_object: int, section: int
) -> Dict[Tuple[int, int], int]:
    """Reconstruct a Yoneda transformation on the chain 0 <= 1 <= 2.

    There is one arrow y -> x when y <= x.  The contravariant functor has an
    integer at each object and sends the arrow y -> x to the restriction
    n |-> 2**(x-y) * n from F(x) to F(y).  For every arrow y -> x into the
    representing object x, Yoneda reconstruction assigns F(y -> x)(section).
    """
    if representing_object not in (0, 1, 2):
        raise ValueError("the representing object must be 0, 1, or 2")
    return {
        (source, representing_object): (2 ** (representing_object - source)) * section
        for source in range(representing_object + 1)
    }


def verify_yoneda_naturality(representing_object: int, section: int) -> bool:
    """Check reconstruction compatibility along every composable chain arrow."""
    alpha = yoneda_reconstruct_chain(representing_object, section)
    x = representing_object
    for z in range(x + 1):
        for y in range(z, x + 1):
            direct = alpha[(z, x)]
            via_y = (2 ** (y - z)) * alpha[(y, x)]
            if direct != via_y:
                return False
    return True


def format_open(value: OpenSet) -> str:
    """Format a finite open set deterministically."""
    return "{" + ", ".join(str(x) for x in sorted(value)) + "}"


def main() -> None:
    """Run all demonstrations and print a compact mathematical report."""
    points = [0, 1, 2]
    # Upward-closed subsets of the chain 0 < 1 < 2 form an Alexandrov topology.
    opens: List[OpenSet] = [
        frozenset(),
        frozenset({2}),
        frozenset({1, 2}),
        frozenset({0, 1, 2}),
    ]
    assert is_topology(points, opens)

    print("YONEDA RECONSTRUCTION ON THE CHAIN 0 <= 1 <= 2")
    section = 3
    reconstruction = yoneda_reconstruct_chain(2, section)
    print(f"Universal element at object 2: {section}")
    for (source, target), value in sorted(reconstruction.items()):
        print(f"  arrow {source} -> {target}: reconstructed value = {value}")
    print("Naturality along every composable arrow:", verify_yoneda_naturality(2, section))

    print("\nHEYTING IMPLICATION IN THE FRAME OF OPEN SETS")
    universe = frozenset(points)
    u = frozenset({1, 2})
    w = frozenset({2})
    implication = heyting_implication(u, w, universe, opens)
    print(f"U = {format_open(u)}, W = {format_open(w)}")
    print(f"U => W = {format_open(implication)}")
    admissible = [v for v in opens if (u & v) <= w]
    print("Admissible V with U intersection V subset W:",
          ", ".join(format_open(v) for v in admissible))

    print("\nDOUBLE NEGATION TABLE")
    for value in opens:
        image = double_negation(value, universe, opens)
        regular = image == value
        print(f"  jj({format_open(value)}) = {format_open(image)}; regular = {regular}")

    print("\nEXHAUSTIVE LAW CHECKS")
    checks = verify_frame_laws(points, opens)
    for name, passed in checks.items():
        print(f"  {name}: {passed}")
    assert all(checks.values())


if __name__ == "__main__":
    main()
