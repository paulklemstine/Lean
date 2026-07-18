#!/usr/bin/env python3
"""Numerical demonstrations for audited certificate refinement.

The script models the four certificate-tree constructors, computes the audited
cost C = length + depth + named-lemma count, performs a bottom-up simplification,
and synchronizes finite certificate and ideal traces. It uses only Python's
standard library.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Iterable, Sequence, TypeAlias


@dataclass(frozen=True)
class Hyp:
    formula: str


@dataclass(frozen=True)
class Named:
    name: str
    formula: str


@dataclass(frozen=True)
class MP:
    conclusion: str
    implication: "Tree"
    argument: "Tree"


@dataclass(frozen=True)
class Restate:
    formula: str
    child: "Tree"


Tree: TypeAlias = Hyp | Named | MP | Restate


def conclusion(tree: Tree) -> str:
    """Return the formula recorded at the root."""
    if isinstance(tree, (Hyp, Named)):
        return tree.formula
    if isinstance(tree, MP):
        return tree.conclusion
    return tree.formula


def statistics(tree: Tree) -> tuple[int, int, int]:
    """Return (node count, depth, named-lemma count) in one traversal."""
    if isinstance(tree, Hyp):
        return (1, 0, 0)
    if isinstance(tree, Named):
        return (1, 0, 1)
    if isinstance(tree, Restate):
        length, depth, lemmas = statistics(tree.child)
        return (length + 1, depth + 1, lemmas)
    left_length, left_depth, left_lemmas = statistics(tree.implication)
    right_length, right_depth, right_lemmas = statistics(tree.argument)
    return (
        1 + left_length + right_length,
        1 + max(left_depth, right_depth),
        left_lemmas + right_lemmas,
    )


def audited_cost(tree: Tree) -> int:
    """Compute C(tree) = length + depth + named-lemma count."""
    return sum(statistics(tree))


def strip_restatement(tree: Tree) -> Tree:
    """Remove one outer restatement, if present."""
    return tree.child if isinstance(tree, Restate) else tree


def simplify(tree: Tree) -> Tree:
    """Apply the conclusion-preserving bottom-up simplification pass."""
    if isinstance(tree, Hyp):
        return tree
    if isinstance(tree, Named):
        return Hyp(tree.formula)
    if isinstance(tree, MP):
        left = strip_restatement(simplify(tree.implication))
        right = strip_restatement(simplify(tree.argument))
        return MP(tree.conclusion, left, right)
    child = simplify(tree.child)
    return child if conclusion(child) == tree.formula else Restate(tree.formula, child)


def refinement_trace(tree: Tree) -> list[Tree]:
    """Repeatedly simplify until unchanged, returning the complete trace."""
    trace = [tree]
    while True:
        next_tree = simplify(trace[-1])
        if next_tree == trace[-1]:
            return trace
        if conclusion(next_tree) != conclusion(trace[-1]):
            raise AssertionError("simplification changed the conclusion")
        if audited_cost(next_tree) >= audited_cost(trace[-1]):
            raise AssertionError("a changing pass did not lower audited cost")
        trace.append(next_tree)


def earliest_constant_suffix(values: Sequence[object]) -> int:
    """Find the first index of the constant suffix of a nonempty finite trace."""
    if not values:
        raise ValueError("the trace must be nonempty")
    index = len(values) - 1
    while index > 0 and values[index - 1] == values[-1]:
        index -= 1
    return index


def common_stabilization_stage(
    costs: Sequence[int], ideals: Sequence[frozenset[str]]
) -> int:
    """Return max of the observed stable-suffix stages for costs and ideals."""
    if len(costs) != len(ideals) or not costs:
        raise ValueError("cost and ideal traces must have equal positive length")
    if any(costs[i + 1] > costs[i] for i in range(len(costs) - 1)):
        raise ValueError("cost trace must be non-increasing")
    if any(not ideals[i] <= ideals[i + 1] for i in range(len(ideals) - 1)):
        raise ValueError("ideal trace must be ascending")
    return max(earliest_constant_suffix(costs), earliest_constant_suffix(ideals))


def sqrt_two_chain() -> list[Tree]:
    """Construct the explicit restatement chain for irrationality of sqrt(2)."""
    label = "sqrt(2) is irrational"
    leaf: Tree = Hyp(label)
    one: Tree = Restate(label, leaf)
    two: Tree = Restate(label, one)
    three: Tree = Restate(label, two)
    return [three, two, one, leaf]


def print_table(headers: Sequence[str], rows: Iterable[Sequence[object]]) -> None:
    materialized = [list(map(str, row)) for row in rows]
    widths = [len(header) for header in headers]
    for row in materialized:
        widths = [max(width, len(cell)) for width, cell in zip(widths, row)]
    print(" | ".join(h.ljust(w) for h, w in zip(headers, widths)))
    print("-+-".join("-" * w for w in widths))
    for row in materialized:
        print(" | ".join(cell.ljust(w) for cell, w in zip(row, widths)))


def main() -> None:
    print("Irrationality of sqrt(2): explicit audited refinement chain")
    chain = sqrt_two_chain()
    rows = []
    for step, tree in enumerate(chain):
        length, depth, lemmas = statistics(tree)
        rows.append((step, length, depth, lemmas, audited_cost(tree)))
    print_table(("step", "length", "depth", "named lemmas", "cost"), rows)
    assert [audited_cost(tree) for tree in chain] == [7, 5, 3, 1]
    assert all(conclusion(tree) == conclusion(chain[0]) for tree in chain)
    assert simplify(chain[-1]) == chain[-1]

    print("\nBottom-up simplification of a nested modus-ponens audit")
    a, b, c = "A", "B", "C"
    complex_tree: Tree = MP(
        c,
        Restate(f"{b} -> {c}", Named("step_BC", f"{b} -> {c}")),
        Restate(b, MP(b, Restate(f"{a} -> {b}", Named("step_AB", f"{a} -> {b}")), Hyp(a))),
    )
    simple_tree = simplify(complex_tree)
    print(f"conclusion preserved: {conclusion(complex_tree) == conclusion(simple_tree)}")
    print(f"cost before: {audited_cost(complex_tree)}")
    print(f"cost after:  {audited_cost(simple_tree)}")

    print("\nSynchronized finite stabilization example")
    costs = [12, 9, 9, 6, 6, 6, 6]
    ideals = [
        frozenset(),
        frozenset({"x"}),
        frozenset({"x", "y"}),
        frozenset({"x", "y"}),
        frozenset({"x", "y", "z"}),
        frozenset({"x", "y", "z"}),
        frozenset({"x", "y", "z"}),
    ]
    stage = common_stabilization_stage(costs, ideals)
    print(f"certificate cost stabilizes at observed stage {earliest_constant_suffix(costs)}")
    print(f"key ideal stabilizes at observed stage {earliest_constant_suffix(ideals)}")
    print(f"common observed stabilization stage: {stage}")
    assert all(cost == costs[stage] and ideal == ideals[stage]
               for cost, ideal in zip(costs[stage:], ideals[stage:]))


if __name__ == "__main__":
    main()
