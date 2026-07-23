#!/usr/bin/env python3
"""Numerical demonstrations for agreement subtrees and split restrictions.

The program uses finite sets to model selected sides of edge splits. It demonstrates
restriction composition, base-tree consensus, overlap-chain gluing, quartet extraction,
and the universal powerset information bounds. No third-party packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import combinations
from typing import FrozenSet, Hashable, Iterable, Mapping, Sequence, TypeVar

Leaf = TypeVar("Leaf", bound=Hashable)
Index = TypeVar("Index", bound=Hashable)
Split = FrozenSet[Leaf]
SplitSystem = FrozenSet[Split[Leaf]]


def canonical_system(sides: Iterable[Iterable[Leaf]]) -> SplitSystem[Leaf]:
    """Convert an iterable of split sides to an immutable canonical system."""
    return frozenset(frozenset(side) for side in sides)


def restrict_system(system: SplitSystem[Leaf], retained: Iterable[Leaf]) -> SplitSystem[Leaf]:
    """Intersect every split side with the retained set and remove duplicates."""
    keep = frozenset(retained)
    return frozenset(side & keep for side in system)


def agree_on(left: SplitSystem[Leaf], right: SplitSystem[Leaf], retained: Iterable[Leaf]) -> bool:
    """Return whether two systems have equal restrictions to the retained leaves."""
    keep = frozenset(retained)
    return restrict_system(left, keep) == restrict_system(right, keep)


def common_restriction(
    systems: Mapping[Index, SplitSystem[Leaf]],
    family: Iterable[Index],
    retained: Iterable[Leaf],
) -> SplitSystem[Leaf] | None:
    """Return the common restricted state, or None when the family disagrees.

    An empty family is represented by the empty system as a vacuous witness.
    A nonempty family is checked against one base restriction.
    """
    members = list(family)
    keep = frozenset(retained)
    if not members:
        return frozenset()
    witness = restrict_system(systems[members[0]], keep)
    return witness if all(restrict_system(systems[i], keep) == witness for i in members[1:]) else None


def glue_overlap_chain(
    systems: Mapping[Index, SplitSystem[Leaf]],
    families: Sequence[set[Index]],
    retained: Iterable[Leaf],
) -> tuple[set[Index], SplitSystem[Leaf]]:
    """Validate and glue a chain of locally coherent, consecutively overlapping families."""
    keep = frozenset(retained)
    if not families:
        return set(), frozenset()
    union: set[Index] = set()
    witness: SplitSystem[Leaf] | None = None
    previous: set[Index] | None = None
    for position, family in enumerate(families):
        if previous is not None and not previous.intersection(family):
            raise ValueError(f"families {position - 1} and {position} do not overlap")
        local = common_restriction(systems, family, keep)
        if local is None:
            raise ValueError(f"family {position} is not internally coherent")
        if witness is not None and local != witness:
            raise ValueError("overlap chain carries inconsistent witnesses")
        witness = local
        union.update(family)
        previous = family
    assert witness is not None
    return union, witness


def extract_quartet(retained: Iterable[Leaf]) -> FrozenSet[Leaf]:
    """Select a canonical four-element subset from an agreement set."""
    ordered = sorted(set(retained), key=repr)
    if len(ordered) < 4:
        raise ValueError("quartet extraction requires at least four leaves")
    return frozenset(ordered[:4])


def information_bounds(leaf_count: int) -> tuple[int, int]:
    """Return the split-side bound 2^a and crude state bound 2^(2^a)."""
    if leaf_count < 0:
        raise ValueError("leaf_count must be nonnegative")
    side_bound = 1 << leaf_count
    return side_bound, 1 << side_bound


def format_system(system: SplitSystem[Leaf]) -> str:
    """Format a system deterministically for readable terminal output."""
    sides = ["{" + ", ".join(sorted(map(str, side))) + "}" for side in system]
    return "{" + ", ".join(sorted(sides)) + "}"


def demo_restriction_composition() -> None:
    """Numerically verify direct and two-stage restriction on a concrete system."""
    system = canonical_system([{1, 2, 3}, {2, 4}, {1, 4, 5}])
    a = frozenset({1, 2, 4})
    b = frozenset({2, 4, 5})
    two_stage = restrict_system(restrict_system(system, a), b)
    direct = restrict_system(system, a & b)
    assert two_stage == direct
    print("Restriction composition")
    print("  first restriction:", format_system(restrict_system(system, a)))
    print("  two-stage result: ", format_system(two_stage))
    print("  direct result:    ", format_system(direct))


def demo_consensus_and_gluing() -> None:
    """Construct four globally distinct systems sharing one restriction via a chain."""
    retained = frozenset({1, 2, 3, 4, 5})
    shared = canonical_system([{1, 2}, {3, 4}, {1, 2, 5}])
    systems: dict[str, SplitSystem[int]] = {}
    for index, outside in zip("ABCD", (10, 20, 30, 40), strict=True):
        # Outside labels disappear under restriction, while the retained state is shared.
        systems[index] = canonical_system([set(side) | {outside} for side in shared])
    families = [{"A", "B"}, {"B", "C"}, {"C", "D"}]
    union, witness = glue_overlap_chain(systems, families, retained)
    assert union == set("ABCD")
    assert common_restriction(systems, union, retained) == witness
    quartet = extract_quartet(retained)
    assert common_restriction(systems, union, quartet) is not None
    print("\nOverlap-chain consensus and quartet transfer")
    print("  glued indices:", sorted(union))
    print("  common 5-leaf state:", format_system(witness))
    print("  extracted quartet:", sorted(quartet))
    print("  quartet state:", format_system(common_restriction(systems, union, quartet) or frozenset()))


def demo_information_growth(max_leaves: int = 5) -> None:
    """Display the universal side and state counts for small retained sets."""
    print("\nUniversal information bounds")
    print("  a | maximum split sides | crude split-system states")
    print(" ---+---------------------+--------------------------")
    for a in range(max_leaves + 1):
        sides, states = information_bounds(a)
        print(f" {a:2d} | {sides:19,d} | {states:24,d}")
    quartet_states = information_bounds(4)[1]
    print(f"\n  For four leaves the crude bound is {quartet_states:,} states,")
    print("  while a resolved unrooted binary quartet has only 3 topological types.")


def exhaustive_heredity_demo() -> None:
    """Check agreement on every subset of a concrete five-leaf agreement set."""
    leaves = frozenset({1, 2, 3, 4, 5})
    left = canonical_system([{1, 2, 9}, {3, 4, 9}, {1, 5, 9}])
    right = canonical_system([{1, 2, 8}, {3, 4, 8}, {1, 5, 8}])
    assert agree_on(left, right, leaves)
    tested = 0
    for size in range(len(leaves) + 1):
        for subset in combinations(leaves, size):
            assert agree_on(left, right, subset)
            tested += 1
    assert tested == 2 ** len(leaves)
    print(f"\nHeredity check: agreement persisted on all {tested} subsets of five leaves.")


def main() -> None:
    """Run all numerical demonstrations."""
    demo_restriction_composition()
    demo_consensus_and_gluing()
    demo_information_growth()
    exhaustive_heredity_demo()


if __name__ == "__main__":
    main()
