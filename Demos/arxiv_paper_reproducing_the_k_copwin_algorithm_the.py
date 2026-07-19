#!/usr/bin/env python3
"""Finite backward search for the cops-and-robber game.

The script implements the mathematical update exactly: all cops move first,
then every legal robber reply must lead to an already winning state.  Staying
put is legal for every token.  Run with Python 3.10 or newer; no third-party
packages are required.
"""

from __future__ import annotations

from dataclasses import dataclass
from itertools import product
from typing import Dict, Iterable, Iterator, List, Mapping, Sequence, Set, Tuple

Vertex = int
CopPosition = Tuple[Vertex, ...]
State = Tuple[CopPosition, Vertex]
Adjacency = Dict[Vertex, Set[Vertex]]


@dataclass(frozen=True)
class SearchResult:
    """The increasing tables, first-entry ranks, and a witness cops' move."""

    tables: Tuple[frozenset[State], ...]
    rank: Mapping[State, int]
    strategy: Mapping[State, CopPosition]


def make_graph(number_of_vertices: int, edges: Iterable[Tuple[int, int]]) -> Adjacency:
    """Create a finite undirected simple graph on vertices 0,...,n-1."""
    graph: Adjacency = {v: set() for v in range(number_of_vertices)}
    for u, v in edges:
        if u == v:
            raise ValueError("Loops are unnecessary because staying is always legal")
        if u not in graph or v not in graph:
            raise ValueError("Edge endpoint outside the declared vertex set")
        graph[u].add(v)
        graph[v].add(u)
    return graph


def path_graph(n: int) -> Adjacency:
    return make_graph(n, ((v, v + 1) for v in range(n - 1)))


def cycle_graph(n: int) -> Adjacency:
    edges = [(v, v + 1) for v in range(n - 1)]
    if n > 2:
        edges.append((n - 1, 0))
    return make_graph(n, edges)


def complete_graph(n: int) -> Adjacency:
    return make_graph(n, ((u, v) for u in range(n) for v in range(u + 1, n)))


def edgeless_graph(n: int) -> Adjacency:
    return make_graph(n, ())


def legal_destinations(graph: Adjacency, vertex: Vertex) -> Tuple[Vertex, ...]:
    """Closed neighborhood: stay or move along one edge."""
    return tuple(sorted({vertex, *graph[vertex]}))


def all_states(graph: Adjacency, k: int) -> Iterator[State]:
    vertices = tuple(sorted(graph))
    for cops in product(vertices, repeat=k):
        for robber in vertices:
            yield (cops, robber)


def captured(state: State) -> bool:
    cops, robber = state
    return robber in cops


def legal_cop_moves(graph: Adjacency, cops: CopPosition) -> Iterator[CopPosition]:
    choices = [legal_destinations(graph, position) for position in cops]
    yield from product(*choices)


def forcing_move(
    graph: Adjacency, state: State, previous: Set[State] | frozenset[State]
) -> CopPosition | None:
    """Return a legal cops' move forcing capture or entry into previous."""
    cops, robber = state
    for next_cops in legal_cop_moves(graph, cops):
        if robber in next_cops:
            return next_cops
        replies = legal_destinations(graph, robber)
        if all((next_cops, next_robber) in previous for next_robber in replies):
            return next_cops
    return None


def backward_search(graph: Adjacency, k: int, max_rounds: int | None = None) -> SearchResult:
    """Build winning tables until stabilization or the requested horizon.

    Table 0 consists of captured states.  At each later stage a state is added
    exactly when the cops have one legal simultaneous move that captures at
    once or defeats every legal robber response by sending it to the preceding
    table.
    """
    if k < 0:
        raise ValueError("The number of cops must be nonnegative")
    universe = tuple(all_states(graph, k))
    current: Set[State] = {state for state in universe if captured(state)}
    tables: List[frozenset[State]] = [frozenset(current)]
    rank: Dict[State, int] = {state: 0 for state in current}
    strategy: Dict[State, CopPosition] = {}
    round_number = 0

    while max_rounds is None or round_number < max_rounds:
        following = set(current)
        witnesses: Dict[State, CopPosition] = {}
        for state in universe:
            if state in following:
                continue
            move = forcing_move(graph, state, current)
            if move is not None:
                following.add(state)
                witnesses[state] = move
        if following == current:
            break
        round_number += 1
        for state, move in witnesses.items():
            rank[state] = round_number
            strategy[state] = move
        current = following
        tables.append(frozenset(current))

    return SearchResult(tuple(tables), rank, strategy)


def has_winning_initial_placement(graph: Adjacency, k: int, result: SearchResult) -> bool:
    """Test whether some cops' placement wins against every robber placement."""
    vertices = tuple(sorted(graph))
    final = result.tables[-1]
    return any(
        all((cops, robber) in final for robber in vertices)
        for cops in product(vertices, repeat=k)
    )


def summarize(name: str, graph: Adjacency, k: int) -> None:
    result = backward_search(graph, k)
    universe_size = len(graph) ** (k + 1)
    sizes = [len(table) for table in result.tables]
    print(f"{name}, k={k}: {len(graph)} vertices, {universe_size} states")
    print(f"  table sizes: {sizes}")
    print(f"  newly won:   {[sizes[0], *[b-a for a, b in zip(sizes, sizes[1:])]]}")
    print(f"  winning initial placement exists: {has_winning_initial_placement(graph, k, result)}")
    print(f"  stabilized after {len(result.tables) - 1} strict updates")


def verify_iteration_invariant(graph: Adjacency, k: int, result: SearchResult) -> None:
    """Numerically check that rank witnesses decrease against every reply."""
    for state, state_rank in result.rank.items():
        if state_rank == 0:
            assert captured(state)
            continue
        next_cops = result.strategy[state]
        _, robber = state
        assert all(position in legal_destinations(graph, old) for old, position in zip(state[0], next_cops))
        if robber not in next_cops:
            for reply in legal_destinations(graph, robber):
                successor = (next_cops, reply)
                assert successor in result.rank
                assert result.rank[successor] < state_rank


def boundary_demo() -> None:
    graph = path_graph(5)
    result = backward_search(graph, 0)
    assert len(result.tables[-1]) == 0
    print("Zero-cop boundary on P5: no captured or finite-horizon winning states.")


def main() -> None:
    examples = [
        ("Path P5", path_graph(5), 1),
        ("Cycle C5", cycle_graph(5), 1),
        ("Cycle C5", cycle_graph(5), 2),
        ("Complete graph K5", complete_graph(5), 1),
        ("Edgeless graph E5", edgeless_graph(5), 1),
    ]
    for name, graph, k in examples:
        result = backward_search(graph, k)
        verify_iteration_invariant(graph, k, result)
        summarize(name, graph, k)
    boundary_demo()


if __name__ == "__main__":
    main()
