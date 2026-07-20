#!/usr/bin/env python3
"""Numerical demonstrations for a genuinely nonassociative bicategory.

The script uses only the Python standard library.  It evaluates the twisted
unital composition, enumerates all binary bracketings, and displays the
associator pentagon for four copies of the distinguished one-cell 1.
"""

from __future__ import annotations

from dataclasses import dataclass
from functools import lru_cache
from typing import Iterator, Sequence, TypeAlias

Tree: TypeAlias = int | tuple["Tree", "Tree"]


def twisted_comp(a: int, b: int) -> int:
    """Return a ⋆ b, where 0 is the identity and a ⋆ b = a + 2b otherwise."""
    if a < 0 or b < 0:
        raise ValueError("twisted composition is defined on natural numbers")
    if a == 0:
        return b
    if b == 0:
        return a
    return a + 2 * b


def evaluate(tree: Tree) -> int:
    """Recursively evaluate a fully parenthesized twisted composite."""
    if isinstance(tree, int):
        if tree < 0:
            raise ValueError("tree leaves must be natural numbers")
        return tree
    left, right = tree
    return twisted_comp(evaluate(left), evaluate(right))


def format_tree(tree: Tree) -> str:
    """Render a binary expression tree with explicit parentheses."""
    if isinstance(tree, int):
        return str(tree)
    return f"({format_tree(tree[0])} ⋆ {format_tree(tree[1])})"


@lru_cache(maxsize=None)
def bracketings(values: tuple[int, ...]) -> tuple[Tree, ...]:
    """Enumerate all full binary bracketings of a nonempty value tuple."""
    if not values:
        raise ValueError("at least one value is required")
    if len(values) == 1:
        return (values[0],)
    result: list[Tree] = []
    for split in range(1, len(values)):
        for left in bracketings(values[:split]):
            for right in bracketings(values[split:]):
                result.append((left, right))
    return tuple(result)


def rotations_right(tree: Tree) -> Iterator[Tree]:
    """Generate trees obtained by one directed associator rotation.

    The local rule is ((X ⋆ Y) ⋆ Z) -> (X ⋆ (Y ⋆ Z)), at any subtree.
    """
    if isinstance(tree, int):
        return
    left, right = tree
    if isinstance(left, tuple):
        x, y = left
        yield (x, (y, right))
    for rotated in rotations_right(left):
        yield (rotated, right)
    for rotated in rotations_right(right):
        yield (left, rotated)


@dataclass(frozen=True)
class AssociatorEdge:
    """A directed elementary reassociation between two expression trees."""

    source: Tree
    target: Tree

    @property
    def endpoint_values(self) -> tuple[int, int]:
        return evaluate(self.source), evaluate(self.target)


def pentagon_edges(value: int = 1) -> tuple[AssociatorEdge, ...]:
    """Return every directed rotation edge among four equal leaves."""
    trees = bracketings((value,) * 4)
    allowed = set(trees)
    edges = {
        AssociatorEdge(source, target)
        for source in trees
        for target in rotations_right(source)
        if target in allowed
    }
    return tuple(sorted(edges, key=lambda e: (format_tree(e.source), format_tree(e.target))))


def demonstrate_unit_and_defect() -> None:
    """Print identity checks and the explicit 5-versus-7 defect."""
    print("DEMO 1 — Unit laws and the associativity defect")
    for a in range(6):
        assert twisted_comp(0, a) == a == twisted_comp(a, 0)
    left = twisted_comp(twisted_comp(1, 1), 1)
    right = twisted_comp(1, twisted_comp(1, 1))
    assert (left, right) == (5, 7)
    print("0 is a two-sided identity for inputs 0 through 5.")
    print(f"((1 ⋆ 1) ⋆ 1) = {left}")
    print(f"(1 ⋆ (1 ⋆ 1)) = {right}")
    print(f"Associativity defect: {right - left}\n")


def demonstrate_positive_defect_formula(limit: int = 4) -> None:
    """Check that the positive triple defect equals twice the third input."""
    print("DEMO 2 — Systematic positive associativity defects")
    rows = []
    for a in range(1, limit + 1):
        for b in range(1, limit + 1):
            for c in range(1, limit + 1):
                left = twisted_comp(twisted_comp(a, b), c)
                right = twisted_comp(a, twisted_comp(b, c))
                assert right - left == 2 * c
                if a == b == 1:
                    rows.append((c, left, right, right - left))
    print("For positive a,b,c, right − left = 2c.")
    print("Sample with a=b=1:")
    for c, left, right, defect in rows:
        print(f"  c={c}: left={left:2d}, right={right:2d}, defect={defect:2d}")
    print()


def demonstrate_pentagon() -> None:
    """Enumerate the five vertices and five directed edges of the pentagon."""
    print("DEMO 3 — The associator pentagon")
    trees = bracketings((1, 1, 1, 1))
    assert len(trees) == 5
    for index, tree in enumerate(trees, start=1):
        print(f"  V{index}: {format_tree(tree)} = {evaluate(tree)}")
    edges = pentagon_edges()
    assert len(edges) == 5
    print("Directed elementary reassociations:")
    for edge in edges:
        a, b = edge.endpoint_values
        print(f"  {format_tree(edge.source)} -> {format_tree(edge.target)}  [{a} -> {b}]")
    print(
        "Every edge represents the unique invertible comparison between its "
        "endpoints; hence both routes around the pentagon denote the same 2-cell."
    )


def main() -> None:
    demonstrate_unit_and_defect()
    demonstrate_positive_defect_formula()
    demonstrate_pentagon()


if __name__ == "__main__":
    main()
