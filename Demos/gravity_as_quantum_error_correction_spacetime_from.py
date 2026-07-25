#!/usr/bin/env python3
"""Numerical demonstrations for code-distance and graph-geodesic results."""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
from typing import Dict, Iterable, List, Mapping, Sequence, Tuple


Graph = Mapping[int, Sequence[int]]


@dataclass(frozen=True)
class CodeParameters:
    """Parameters [[n,k,d]] of a quantum stabilizer code."""

    n: int
    k: int
    d: int

    def singleton_margin(self) -> int:
        """Return n + 2 - (2d + k); validity means this is nonnegative."""
        return self.n + 2 - (2 * self.d + self.k)

    def is_singleton_valid(self) -> bool:
        return self.singleton_margin() >= 0

    def is_singleton_saturated(self) -> bool:
        return self.singleton_margin() == 0


def path_graph(vertex_count: int) -> Dict[int, List[int]]:
    """Construct the unweighted path on vertices 0,...,vertex_count-1."""
    if vertex_count <= 0:
        raise ValueError("vertex_count must be positive")
    graph: Dict[int, List[int]] = {v: [] for v in range(vertex_count)}
    for v in range(vertex_count - 1):
        graph[v].append(v + 1)
        graph[v + 1].append(v)
    return graph


def shortest_path(graph: Graph, source: int, target: int) -> Tuple[int, List[int]]:
    """Compute unweighted distance and one shortest path by breadth-first search."""
    if source not in graph or target not in graph:
        raise ValueError("source and target must be vertices of the graph")
    queue = deque([source])
    parent: Dict[int, int | None] = {source: None}
    while queue:
        current = queue.popleft()
        if current == target:
            break
        for neighbor in graph[current]:
            if neighbor not in parent:
                parent[neighbor] = current
                queue.append(neighbor)
    if target not in parent:
        raise ValueError("target is unreachable from source")
    route: List[int] = []
    cursor: int | None = target
    while cursor is not None:
        route.append(cursor)
        cursor = parent[cursor]
    route.reverse()
    return len(route) - 1, route


def analyze_realization(params: CodeParameters, graph: Graph,
                        source: int, target: int) -> Dict[str, int | bool | List[int]]:
    """Compare code distance with graph distance and evaluate Singleton slack."""
    distance, route = shortest_path(graph, source, target)
    geometric_margin = params.n + 2 - (2 * distance + params.k)
    return {
        "graph_distance": distance,
        "shortest_path": route,
        "metric_realization": distance == params.d,
        "singleton_valid": params.is_singleton_valid(),
        "singleton_saturated": params.is_singleton_saturated(),
        "geometric_margin": geometric_margin,
    }


def tanner_radial_cardinality_obstruction(variable_count: int,
                                           check_count: int,
                                           radial_count: int) -> Dict[str, int | bool]:
    """Apply the necessary vertex-count condition for graph isomorphism."""
    tanner_count = variable_count + check_count
    return {
        "tanner_vertices": tanner_count,
        "radial_vertices": radial_count,
        "isomorphism_ruled_out_by_cardinality": tanner_count != radial_count,
    }


def defect_capacity_bound(n: int, graph_distance: int) -> Tuple[int, int]:
    """Return unshifted defect delta=n-2l and the bound k<=delta+2."""
    delta = n - 2 * graph_distance
    return delta, delta + 2


def positive_rate_family(rate_numerator: int, sizes: Iterable[int]) -> List[Tuple[int, int, int]]:
    """Generate illustrative (n,k,minimum defect) triples with k=floor(r*n)/100."""
    if not 0 <= rate_numerator <= 100:
        raise ValueError("rate_numerator must be between 0 and 100")
    rows: List[Tuple[int, int, int]] = []
    for n in sizes:
        k = (rate_numerator * n) // 100
        minimum_defect = max(0, k - 2)
        rows.append((n, k, minimum_defect))
    return rows


def main() -> None:
    five_qubit = CodeParameters(n=5, k=1, d=3)
    radial_chain = path_graph(4)
    analysis = analyze_realization(five_qubit, radial_chain, 0, 3)

    print("Five-qubit radial metric demonstration")
    print("---------------------------------------")
    print(f"parameters: [[{five_qubit.n},{five_qubit.k},{five_qubit.d}]]")
    print(f"shortest route: {analysis['shortest_path']}")
    print(f"endpoint distance: {analysis['graph_distance']}")
    print(f"exact metric realization: {analysis['metric_realization']}")
    print(f"Singleton saturation: {analysis['singleton_saturated']}")
    print(f"geometric margin: {analysis['geometric_margin']} (zero means equality)\n")

    obstruction = tanner_radial_cardinality_obstruction(5, 4, 4)
    print("Tanner-versus-radial cardinality test")
    print("-------------------------------------")
    for key, value in obstruction.items():
        print(f"{key}: {value}")

    print("\nPositive-rate defect lower bounds at rate 20%")
    print("------------------------------------------------")
    print(" n    k    required delta >= k-2")
    for n, k, delta in positive_rate_family(20, [20, 50, 100, 200]):
        print(f"{n:3d}  {k:3d}  {delta:8d}")


if __name__ == "__main__":
    main()
