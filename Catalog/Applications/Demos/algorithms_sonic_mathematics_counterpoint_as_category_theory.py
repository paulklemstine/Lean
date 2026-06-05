#!/usr/bin/env python3
"""
Algorithms for Counterpoint Category Theory

Type-hinted implementations of the key algorithms used in the
formalization of first-species counterpoint as a directed graph.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple


def consonant_interval_classes() -> FrozenSet[int]:
    """Return the set of consonant interval classes in first-species counterpoint.

    Returns:
        The six consonant interval classes {0, 3, 4, 7, 8, 9} in ZMod 12.
    """
    return frozenset({0, 3, 4, 7, 8, 9})


def is_perfect(i: int) -> bool:
    """Check if an interval class is a perfect consonance.

    Args:
        i: Interval class in ZMod 12.

    Returns:
        True if i is unison (0) or perfect fifth (7).
    """
    return i % 12 in {0, 7}


def interval_delta(a: int, b: int) -> int:
    """Compute the interval change from a two-voice leading.

    Args:
        a: Motion of voice 1 in semitones.
        b: Motion of voice 2 in semitones.

    Returns:
        The interval change (b - a) mod 12.
    """
    return (b - a) % 12


def voice_leading_cost(a: int, b: int) -> int:
    """Compute the voice leading cost (total displacement).

    Args:
        a: Motion of voice 1.
        b: Motion of voice 2.

    Returns:
        |a| + |b|, the L1 norm of the motion vector.
    """
    return abs(a) + abs(b)


def is_valid_voice_leading(
    source: int, target: int, a: int, b: int, stepwise_bound: int = 2
) -> bool:
    """Check if a voice leading is valid under first-species rules.

    Args:
        source: Starting interval class.
        target: Target interval class.
        a: Motion of voice 1.
        b: Motion of voice 2.
        stepwise_bound: Maximum motion per voice.

    Returns:
        True if the voice leading satisfies all constraints.
    """
    consonant = consonant_interval_classes()
    if source % 12 not in consonant or target % 12 not in consonant:
        return False
    if abs(a) > stepwise_bound or abs(b) > stepwise_bound:
        return False
    if interval_delta(a, b) != (target - source) % 12:
        return False
    if is_perfect(target) and a == b:
        return False
    return True


def build_transition_graph(
    stepwise_bound: int = 2,
) -> Dict[int, Set[int]]:
    """Build the counterpoint transition graph.

    Args:
        stepwise_bound: Maximum semitone motion per voice.

    Returns:
        Adjacency list mapping each consonant interval to its reachable set.
    """
    consonant = sorted(consonant_interval_classes())
    graph: Dict[int, Set[int]] = {i: set() for i in consonant}

    for i in consonant:
        for j in consonant:
            for a in range(-stepwise_bound, stepwise_bound + 1):
                for b in range(-stepwise_bound, stepwise_bound + 1):
                    if is_valid_voice_leading(i, j, a, b, stepwise_bound):
                        graph[i].add(j)
                        break  # found one valid leading, move to next j
                else:
                    continue
                break

    # Actually need to check all pairs properly
    graph = {i: set() for i in consonant}
    for i in consonant:
        for j in consonant:
            found = False
            for a in range(-stepwise_bound, stepwise_bound + 1):
                for b in range(-stepwise_bound, stepwise_bound + 1):
                    if is_valid_voice_leading(i, j, a, b, stepwise_bound):
                        found = True
                        break
                if found:
                    break
            if found:
                graph[i].add(j)

    return graph


def compute_graph_diameter(graph: Dict[int, Set[int]]) -> int:
    """Compute the diameter of a directed graph via BFS.

    Args:
        graph: Adjacency list.

    Returns:
        Maximum shortest path length between any pair of vertices.
    """
    vertices = list(graph.keys())
    diameter = 0

    for start in vertices:
        distances: Dict[int, int] = {start: 0}
        queue = [start]
        while queue:
            current = queue.pop(0)
            for neighbor in graph.get(current, set()):
                if neighbor not in distances:
                    distances[neighbor] = distances[current] + 1
                    queue.append(neighbor)

        for v in vertices:
            if v in distances:
                diameter = max(diameter, distances[v])

    return diameter


def check_balanced(graph: Dict[int, Set[int]]) -> bool:
    """Check if a directed graph is balanced (in-degree = out-degree for all vertices).

    Args:
        graph: Adjacency list.

    Returns:
        True if the graph is balanced.
    """
    vertices = set(graph.keys())
    for v in vertices:
        out_degree = len(graph.get(v, set()))
        in_degree = sum(1 for u in vertices if v in graph.get(u, set()))
        if out_degree != in_degree:
            return False
    return True


def find_two_step_paths(
    graph: Dict[int, Set[int]], source: int, target: int
) -> List[int]:
    """Find all intermediate vertices for two-step paths from source to target.

    Args:
        graph: Adjacency list.
        source: Starting vertex.
        target: Ending vertex.

    Returns:
        List of intermediate vertices k such that source → k → target.
    """
    return [k for k in graph.get(source, set()) if target in graph.get(k, set())]


def minimum_cost_edge(source: int, target: int, bound: int = 2) -> Optional[Tuple[int, int, int]]:
    """Find the minimum-cost valid voice leading between two intervals.

    Args:
        source: Starting interval class.
        target: Target interval class.
        bound: Stepwise bound.

    Returns:
        Tuple (a, b, cost) or None if no valid leading exists.
    """
    best: Optional[Tuple[int, int, int]] = None
    for a in range(-bound, bound + 1):
        for b in range(-bound, bound + 1):
            if is_valid_voice_leading(source, target, a, b, bound):
                c = voice_leading_cost(a, b)
                if best is None or c < best[2]:
                    best = (a, b, c)
    return best


def adjacency_matrix(graph: Dict[int, Set[int]]) -> Tuple[List[int], List[List[int]]]:
    """Compute the adjacency matrix of the transition graph.

    Returns:
        Tuple of (vertex_order, matrix) where matrix[i][j] = 1 iff edge exists.
    """
    vertices = sorted(graph.keys())
    n = len(vertices)
    idx = {v: i for i, v in enumerate(vertices)}
    matrix = [[0] * n for _ in range(n)]
    for u in vertices:
        for v in graph.get(u, set()):
            matrix[idx[u]][idx[v]] = 1
    return vertices, matrix


if __name__ == "__main__":
    # Quick verification
    graph = build_transition_graph()
    total = sum(len(v) for v in graph.values())
    print(f"Transition graph: {len(graph)} vertices, {total} edges")
    print(f"Diameter: {compute_graph_diameter(graph)}")
    print(f"Balanced: {check_balanced(graph)}")

    vertices, matrix = adjacency_matrix(graph)
    print(f"\nAdjacency matrix (vertices: {vertices}):")
    for row in matrix:
        print(f"  {row}")
