#!/usr/bin/env python3
"""Finite numerical demonstrations of the relational do-calculus theory.

The examples use abstract query labels and three finite primitive-rule relations.
They demonstrate equivalence closure, path certificates, countermodels, and a
literal exhaustive quantification over all set partitions for a tiny universe.
No third-party packages are required.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from itertools import product
from typing import Dict, Iterable, Iterator, List, Optional, Sequence, Set, Tuple


@dataclass(frozen=True, order=True)
class Query:
    """A well-formed finite query represented by disjoint bit masks."""

    target: int
    observed: int
    intervened: int

    def __post_init__(self) -> None:
        if (self.target & self.observed) or (self.target & self.intervened) or (
            self.observed & self.intervened
        ):
            raise ValueError("target, observed, and intervened must be disjoint")

    def pretty(self, names: Sequence[str]) -> str:
        def members(mask: int) -> str:
            return "{" + ",".join(name for i, name in enumerate(names) if mask & (1 << i)) + "}"
        return f"P({members(self.target)} | {members(self.observed)}, do({members(self.intervened)}))"


RuleEdge = Tuple[Query, Query]
Rules = Dict[str, Set[RuleEdge]]


def enumerate_queries(n: int) -> List[Query]:
    """Enumerate all 4^n well-formed queries by assigning one of four roles."""
    queries: List[Query] = []
    for roles in product(range(4), repeat=n):
        masks = [0, 0, 0]
        for variable, role in enumerate(roles):
            if role:
                masks[role - 1] |= 1 << variable
        queries.append(Query(*masks))
    return queries


def primitive_neighbors(query: Query, universe: Sequence[Query], rules: Rules) -> Iterator[Tuple[Query, str, bool]]:
    """Yield neighbors, rule labels, and whether the approved edge was reversed."""
    for other in universe:
        for rule, edges in rules.items():
            if (query, other) in edges:
                yield other, rule, False
            elif (other, query) in edges:
                yield other, rule, True


def derivation_path(
    source: Query, target: Query, universe: Sequence[Query], rules: Rules
) -> Optional[List[Tuple[Query, Optional[str], bool]]]:
    """Return a shortest primitive-step path, or None when no derivation exists."""
    queue = deque([source])
    predecessor: Dict[Query, Tuple[Optional[Query], Optional[str], bool]] = {
        source: (None, None, False)
    }
    while queue:
        current = queue.popleft()
        if current == target:
            break
        for neighbor, rule, reversed_edge in primitive_neighbors(current, universe, rules):
            if neighbor not in predecessor:
                predecessor[neighbor] = (current, rule, reversed_edge)
                queue.append(neighbor)
    if target not in predecessor:
        return None
    result: List[Tuple[Query, Optional[str], bool]] = []
    cursor: Optional[Query] = target
    while cursor is not None:
        previous, rule, reversed_edge = predecessor[cursor]
        result.append((cursor, rule, reversed_edge))
        cursor = previous
    result.reverse()
    return result


def component_partition(universe: Sequence[Query], rules: Rules) -> List[Set[Query]]:
    """Compute the least equivalence relation as connected components."""
    unseen = set(universe)
    components: List[Set[Query]] = []
    while unseen:
        root = min(unseen)
        component: Set[Query] = {root}
        queue = deque([root])
        unseen.remove(root)
        while queue:
            current = queue.popleft()
            for neighbor, _, _ in primitive_neighbors(current, universe, rules):
                if neighbor in unseen:
                    unseen.remove(neighbor)
                    component.add(neighbor)
                    queue.append(neighbor)
        components.append(component)
    return components


def set_partitions(items: Sequence[int]) -> Iterator[Tuple[Tuple[int, ...], ...]]:
    """Generate each set partition once in canonical block order."""
    if not items:
        yield ()
        return
    first, *rest = items
    for partition in set_partitions(rest):
        yield ((first,),) + partition
        for i in range(len(partition)):
            block = tuple(sorted((first,) + partition[i]))
            yield partition[:i] + (block,) + partition[i + 1 :]


def exhaustive_identify(size: int, primitive_edges: Set[Tuple[int, int]], source: int, target: int) -> Tuple[bool, Optional[Tuple[Tuple[int, ...], ...]]]:
    """Quantify over every equivalence relation, represented as a partition."""
    for partition in set_partitions(list(range(size))):
        block_of = {item: block_id for block_id, block in enumerate(partition) for item in block}
        validates_rules = all(block_of[a] == block_of[b] for a, b in primitive_edges)
        if validates_rules and block_of[source] != block_of[target]:
            return False, partition
    return True, None


def main() -> None:
    names = ["X", "Y"]
    universe = enumerate_queries(len(names))
    print(f"Two variables produce {len(universe)} = 4^2 well-formed queries.")

    q0 = Query(target=0b10, observed=0b01, intervened=0)
    q1 = Query(target=0b10, observed=0, intervened=0)
    q2 = Query(target=0b10, observed=0, intervened=0b01)
    rules: Rules = {
        "observation insertion/deletion": {(q0, q1)},
        "action-observation exchange": {(q1, q2)},
        "action insertion/deletion": set(),
    }

    path = derivation_path(q0, q2, universe, rules)
    assert path is not None
    print("\nPositive derivation certificate:")
    for index, (query, rule, reversed_edge) in enumerate(path):
        if index == 0:
            print("  ", query.pretty(names))
        else:
            direction = " (used in reverse)" if reversed_edge else ""
            print(f"    -- {rule}{direction} -->")
            print("  ", query.pretty(names))

    isolated = Query(target=0b01, observed=0, intervened=0)
    no_path = derivation_path(q0, isolated, universe, rules)
    assert no_path is None
    components = component_partition(universe, rules)
    source_class = next(c for c in components if q0 in c)
    isolated_class = next(c for c in components if isolated in c)
    print("\nNegative certificate:")
    print(f"  source component size = {len(source_class)}")
    print(f"  isolated component size = {len(isolated_class)}")
    print("  The component partition validates every primitive edge but separates the pair.")

    tiny_edges = {(0, 1), (1, 2), (3, 4)}
    positive, _ = exhaustive_identify(5, tiny_edges, 0, 2)
    negative, countermodel = exhaustive_identify(5, tiny_edges, 0, 4)
    assert positive and not negative and countermodel is not None
    print("\nLiteral universal-theory enumeration on five abstract queries:")
    print(f"  identify(q0, q2) = {positive}")
    print(f"  identify(q0, q4) = {negative}")
    print(f"  separating admissible partition = {countermodel}")


if __name__ == "__main__":
    main()
