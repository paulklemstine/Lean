#!/usr/bin/env python3
"""Numerical demonstrations of ordinal-guarded proof graphs.

The script models the implication/assumption fragment described in the paper,
checks local typing and strict natural-number rank descent, detects dependency
cycles, constructs canonical ranks for acyclic graphs, and unfolds accepted
nodes into explicit derivation trees.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Optional, Sequence, Tuple, Union


@dataclass(frozen=True)
class Atom:
    """An atomic proposition."""

    name: str

    def __str__(self) -> str:
        return self.name


@dataclass(frozen=True)
class Imp:
    """An implication formula."""

    left: "Formula"
    right: "Formula"

    def __str__(self) -> str:
        return f"({self.left} -> {self.right})"


Formula = Union[Atom, Imp]
Context = Tuple[Formula, ...]


@dataclass(frozen=True)
class AssumptionRule:
    """A leaf justified by membership in its context."""


@dataclass(frozen=True)
class ImpIntroRule:
    """Implication introduction with one dependency child."""

    antecedent: Formula
    consequent: Formula
    child: str


Rule = Union[AssumptionRule, ImpIntroRule]


@dataclass(frozen=True)
class Node:
    """A labelled node in a candidate proof graph."""

    context: Context
    conclusion: Formula
    rule: Rule
    rank: int


@dataclass(frozen=True)
class Derivation:
    """An explicitly unfolded ordinary derivation tree."""

    context: Context
    conclusion: Formula
    rule_name: str
    children: Tuple["Derivation", ...] = ()


def dependencies(node: Node) -> Tuple[str, ...]:
    """Return all direct dependency identifiers of a node."""

    if isinstance(node.rule, ImpIntroRule):
        return (node.rule.child,)
    return ()


def validate_graph(graph: Mapping[str, Node]) -> List[str]:
    """Return all local-typing and rank-descent errors.

    An empty result certifies that every dependency is well typed and strictly
    lowers the supplied natural-number rank.
    """

    errors: List[str] = []
    for name, node in graph.items():
        if node.rank < 0:
            errors.append(f"{name}: rank must be nonnegative")
        if isinstance(node.rule, AssumptionRule):
            if node.conclusion not in node.context:
                errors.append(f"{name}: assumption is absent from its context")
            continue

        rule = node.rule
        if rule.child not in graph:
            errors.append(f"{name}: missing child {rule.child!r}")
            continue
        child = graph[rule.child]
        expected = Imp(rule.antecedent, rule.consequent)
        if node.conclusion != expected:
            errors.append(f"{name}: conclusion is not {expected}")
        if child.context != (rule.antecedent,) + node.context:
            errors.append(f"{name}: child context does not add the antecedent")
        if child.conclusion != rule.consequent:
            errors.append(f"{name}: child conclusion is not the consequent")
        if child.rank >= node.rank:
            errors.append(
                f"{name}: rank does not decrease ({node.rank} -> {child.rank})"
            )
    return errors


def find_cycle(graph: Mapping[str, Node]) -> Optional[List[str]]:
    """Return one directed dependency cycle, or ``None`` if none exists."""

    state: Dict[str, int] = {name: 0 for name in graph}
    stack: List[str] = []
    position: Dict[str, int] = {}

    def visit(name: str) -> Optional[List[str]]:
        state[name] = 1
        position[name] = len(stack)
        stack.append(name)
        for child in dependencies(graph[name]):
            if child not in graph:
                continue
            if state[child] == 0:
                cycle = visit(child)
                if cycle is not None:
                    return cycle
            elif state[child] == 1:
                return stack[position[child] :] + [child]
        stack.pop()
        position.pop(name)
        state[name] = 2
        return None

    for name in graph:
        if state[name] == 0:
            cycle = visit(name)
            if cycle is not None:
                return cycle
    return None


def construct_minimal_ranks(graph: Mapping[str, Node]) -> Dict[str, int]:
    """Construct longest-path ranks for an acyclic dependency graph.

    Raises ``ValueError`` when a cycle is present. The resulting rank is zero at
    sinks and one plus the largest child rank elsewhere.
    """

    cycle = find_cycle(graph)
    if cycle is not None:
        raise ValueError("cyclic dependency: " + " -> ".join(cycle))
    memo: Dict[str, int] = {}

    def height(name: str) -> int:
        if name in memo:
            return memo[name]
        child_names = [c for c in dependencies(graph[name]) if c in graph]
        memo[name] = 0 if not child_names else 1 + max(height(c) for c in child_names)
        return memo[name]

    for name in graph:
        height(name)
    return memo


def unfold(graph: Mapping[str, Node], root: str) -> Derivation:
    """Unfold a validated guarded graph node into an ordinary derivation."""

    errors = validate_graph(graph)
    if errors:
        raise ValueError("invalid graph:\n  " + "\n  ".join(errors))
    node = graph[root]
    if isinstance(node.rule, AssumptionRule):
        return Derivation(node.context, node.conclusion, "assumption")
    child = unfold(graph, node.rule.child)
    return Derivation(node.context, node.conclusion, "implication introduction", (child,))


def format_context(context: Context) -> str:
    """Render a context compactly."""

    return "[" + ", ".join(map(str, context)) + "]"


def print_derivation(tree: Derivation, indent: str = "") -> None:
    """Pretty-print an ordinary derivation tree."""

    print(f"{indent}{format_context(tree.context)} |- {tree.conclusion}  [{tree.rule_name}]")
    for child in tree.children:
        print_derivation(child, indent + "  ")


def identity_example() -> Dict[str, Node]:
    """Build the valid height-one derivation of P -> P."""

    p = Atom("P")
    return {
        "root": Node((), Imp(p, p), ImpIntroRule(p, p, "leaf"), rank=1),
        "leaf": Node((p,), p, AssumptionRule(), rank=0),
    }


def pure_loop_example() -> Dict[str, Node]:
    """Build a direct self-loop that necessarily fails strict descent."""

    p = Atom("P")
    return {
        "loop": Node((), Imp(p, p), ImpIntroRule(p, p, "loop"), rank=0),
    }


def shared_dag_example() -> Dict[str, Node]:
    """Build a small acyclic dependency chain and assign canonical ranks."""

    p, q = Atom("P"), Atom("Q")
    # This graph is used to demonstrate rank construction independently of
    # local proof typing; only its dependency shape matters for that algorithm.
    return {
        "top": Node((), Imp(p, q), ImpIntroRule(p, q, "middle"), rank=0),
        "middle": Node((p,), q, ImpIntroRule(q, q, "leaf"), rank=0),
        "leaf": Node((q, p), q, AssumptionRule(), rank=0),
    }


def main() -> None:
    """Run three demonstrations and print their mathematical conclusions."""

    print("=== 1. Height-one identity ===")
    identity = identity_example()
    print("validation errors:", validate_graph(identity))
    print("dependency cycle:", find_cycle(identity))
    print("constructed ranks:", construct_minimal_ranks(identity))
    print_derivation(unfold(identity, "root"))

    print("\n=== 2. Unsupported self-loop ===")
    loop = pure_loop_example()
    print("validation errors:")
    for error in validate_graph(loop):
        print(" -", error)
    print("dependency cycle:", " -> ".join(find_cycle(loop) or []))
    try:
        construct_minimal_ranks(loop)
    except ValueError as error:
        print("rank construction rejected:", error)

    print("\n=== 3. Canonical ranks on an acyclic graph ===")
    dag = shared_dag_example()
    print("dependency cycle:", find_cycle(dag))
    print("longest-path ranks:", construct_minimal_ranks(dag))


if __name__ == "__main__":
    main()
