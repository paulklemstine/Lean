#!/usr/bin/env python3
"""Finite experiments for infinite trees, observation limits, and cyclic ranks."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Dict, Hashable, Iterable, List, Optional, Sequence, Set, Tuple, TypeVar

Label = TypeVar("Label", bound=Hashable)
Node = TypeVar("Node", bound=Hashable)
Address = Tuple[int, ...]
Observation = Set[Tuple[Address, Label]]


def self_unravelling_value(address: Address, label: Label) -> Optional[Label]:
    """Return label exactly on addresses made entirely of zeroes."""
    return label if all(index == 0 for index in address) else None


def unary_truncation(max_depth: int, label: Label) -> Observation[Label]:
    """Materialize the unary self-unravelling through max_depth."""
    if max_depth < 0:
        raise ValueError("max_depth must be nonnegative")
    return {(tuple(0 for _ in range(depth)), label) for depth in range(max_depth + 1)}


def chain_limit(stages: Iterable[Observation[Label]]) -> Observation[Label]:
    """Compute the union, hence the least upper bound, of finite observations."""
    limit: Observation[Label] = set()
    for stage in stages:
        limit.update(stage)
    return limit


def is_increasing(stages: Sequence[Observation[Label]]) -> bool:
    """Test whether each observation is included in its successor."""
    return all(left <= right for left, right in zip(stages, stages[1:]))


@dataclass(frozen=True)
class RankingResult:
    """Acyclicity result and a decreasing natural-number ranking when one exists."""

    acyclic: bool
    rank: Optional[Dict[Node, int]]
    cycle: Optional[List[Node]]


def decreasing_rank(graph: Dict[Node, Set[Node]]) -> RankingResult:
    """Detect a cycle or rank every node above all of its dependencies.

    An edge x -> y means that x depends on y.  On an acyclic graph the returned
    rank satisfies rank[y] < rank[x] on every edge.
    """
    all_nodes: Set[Node] = set(graph)
    for dependencies in graph.values():
        all_nodes.update(dependencies)
    adjacency = {node: set(graph.get(node, set())) for node in all_nodes}
    color: Dict[Node, int] = {node: 0 for node in all_nodes}
    stack: List[Node] = []
    rank: Dict[Node, int] = {}

    def visit(node: Node) -> Optional[List[Node]]:
        color[node] = 1
        stack.append(node)
        for dependency in adjacency[node]:
            if color[dependency] == 0:
                found = visit(dependency)
                if found is not None:
                    return found
            elif color[dependency] == 1:
                start = stack.index(dependency)
                return stack[start:] + [dependency]
        stack.pop()
        color[node] = 2
        rank[node] = 0 if not adjacency[node] else 1 + max(rank[d] for d in adjacency[node])
        return None

    for node in all_nodes:
        if color[node] == 0:
            cycle = visit(node)
            if cycle is not None:
                return RankingResult(False, None, cycle)
    return RankingResult(True, rank, None)


def liar_models() -> List[Tuple[bool, bool]]:
    """Enumerate Boolean pairs satisfying reflection and the liar equation."""
    return [
        (provable, liar)
        for provable in (False, True)
        for liar in (False, True)
        if (provable == liar) and (liar == (not provable))
    ]


def run_demo() -> None:
    """Print representative calculations for all principal results."""
    print("UNARY SELF-UNRAVELLING")
    tree = unary_truncation(8, "A")
    for address, label in sorted(tree, key=lambda item: len(item[0])):
        print(f"depth={len(address):2d}, address={address!s:26s}, label={label}")
    assert all(self_unravelling_value((0,) * n, "A") == "A" for n in range(9))
    assert self_unravelling_value((0, 1), "A") is None

    print("\nINCREASING OBSERVATIONS AND THEIR LIMIT")
    stages = [unary_truncation(depth, "A") for depth in range(6)]
    limit = chain_limit(stages)
    print("stage sizes:", [len(stage) for stage in stages])
    print("increasing:", is_increasing(stages))
    print("limit size:", len(limit), "equals final stage:", limit == stages[-1])
    assert is_increasing(stages)
    assert all(stage <= limit for stage in stages)

    print("\nSTRICTLY DECREASING RANKS")
    dag = {"theorem": {"lemma-1", "lemma-2"}, "lemma-1": {"axiom"},
           "lemma-2": {"axiom"}, "axiom": set()}
    dag_result = decreasing_rank(dag)
    print("acyclic graph ranks:", dag_result.rank)
    assert dag_result.acyclic and dag_result.rank is not None
    assert all(dag_result.rank[y] < dag_result.rank[x] for x, ys in dag.items() for y in ys)

    cycle_graph = {"A": {"B"}, "B": {"C"}, "C": {"A"}}
    cycle_result = decreasing_rank(cycle_graph)
    print("cyclic graph rankable:", cycle_result.acyclic)
    print("cycle witness:", cycle_result.cycle)
    assert not cycle_result.acyclic

    self_loop_result = decreasing_rank({"self": {"self"}})
    print("self-loop rankable:", self_loop_result.acyclic)
    assert not self_loop_result.acyclic

    print("\nLIAR EQUATIONS")
    rows = []
    for provable in (False, True):
        for liar in (False, True):
            reflection = provable == liar
            negating_fixed_point = liar == (not provable)
            rows.append((provable, liar, reflection, negating_fixed_point))
    for row in rows:
        print("Provable=%-5s Liar=%-5s reflection=%-5s liar-equation=%-5s" % row)
    print("simultaneous models:", liar_models())
    assert liar_models() == []


if __name__ == "__main__":
    run_demo()
