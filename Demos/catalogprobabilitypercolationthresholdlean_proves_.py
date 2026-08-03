#!/usr/bin/env python3
"""Numerical demonstrations of monotone threshold percolation couplings.

The same key field is reused at every threshold.  The script demonstrates
nested site configurations, persistence of horizontal grid crossings, and
persistence of bond connectivity on a finite graph.  It uses only Python's
standard library.
"""

from __future__ import annotations

from collections import deque
from dataclasses import dataclass
import random
from typing import Dict, Iterable, List, Mapping, Sequence, Set, Tuple

Vertex = Tuple[int, int]
Edge = Tuple[int, int]


@dataclass(frozen=True)
class CrossingResult:
    """Crossing status and one witness path at a specified threshold."""

    threshold: float
    open_count: int
    crosses: bool
    path: Tuple[Vertex, ...]


def site_threshold_config(
    keys: Mapping[Vertex, float], threshold: float
) -> Set[Vertex]:
    """Return precisely the sites whose keys are at most ``threshold``."""
    return {vertex for vertex, key in keys.items() if key <= threshold}


def bond_threshold_config(
    keys: Mapping[Edge, float], threshold: float
) -> Set[Edge]:
    """Return precisely the normalized edges whose keys are at most threshold."""
    return {edge for edge, key in keys.items() if key <= threshold}


def grid_neighbors(vertex: Vertex, n: int) -> Iterable[Vertex]:
    """Yield nearest neighbors of a vertex in an n by n square grid."""
    row, col = vertex
    for drow, dcol in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        nxt = (row + drow, col + dcol)
        if 0 <= nxt[0] < n and 0 <= nxt[1] < n:
            yield nxt


def horizontal_crossing_path(
    n: int, open_sites: Set[Vertex]
) -> Tuple[Vertex, ...]:
    """Find an open left-to-right path, returning an empty tuple if absent."""
    starts = [(row, 0) for row in range(n) if (row, 0) in open_sites]
    queue = deque(starts)
    parent: Dict[Vertex, Vertex | None] = {start: None for start in starts}

    while queue:
        current = queue.popleft()
        if current[1] == n - 1:
            path: List[Vertex] = []
            cursor: Vertex | None = current
            while cursor is not None:
                path.append(cursor)
                cursor = parent[cursor]
            return tuple(reversed(path))
        for neighbor in grid_neighbors(current, n):
            if neighbor in open_sites and neighbor not in parent:
                parent[neighbor] = current
                queue.append(neighbor)
    return ()


def crossing_sweep(
    n: int, keys: Mapping[Vertex, float], thresholds: Sequence[float]
) -> List[CrossingResult]:
    """Evaluate nested grid configurations at nondecreasing thresholds."""
    if n <= 0:
        raise ValueError("n must be positive")
    if any(a > b for a, b in zip(thresholds, thresholds[1:])):
        raise ValueError("thresholds must be nondecreasing")

    results: List[CrossingResult] = []
    previous_open: Set[Vertex] = set()
    crossing_seen = False
    for threshold in thresholds:
        current_open = site_threshold_config(keys, threshold)
        assert previous_open <= current_open, "threshold configurations must nest"
        path = horizontal_crossing_path(n, current_open)
        crosses = bool(path)
        assert not crossing_seen or crosses, "a crossing cannot disappear"
        crossing_seen = crossing_seen or crosses
        results.append(CrossingResult(threshold, len(current_open), crosses, path))
        previous_open = current_open
    return results


def graph_connected(
    vertex_count: int, open_edges: Set[Edge], source: int, target: int
) -> bool:
    """Test endpoint connectivity in a finite undirected bond configuration."""
    adjacency: List[List[int]] = [[] for _ in range(vertex_count)]
    for u, v in open_edges:
        adjacency[u].append(v)
        adjacency[v].append(u)
    queue = deque([source])
    seen = {source}
    while queue:
        u = queue.popleft()
        if u == target:
            return True
        for v in adjacency[u]:
            if v not in seen:
                seen.add(v)
                queue.append(v)
    return False


def estimate_crossing_probabilities(
    n: int, thresholds: Sequence[float], trials: int, seed: int
) -> List[float]:
    """Estimate crossing probabilities using one common key field per trial."""
    rng = random.Random(seed)
    counts = [0] * len(thresholds)
    for _ in range(trials):
        keys = {(row, col): rng.random() for row in range(n) for col in range(n)}
        results = crossing_sweep(n, keys, thresholds)
        for i, result in enumerate(results):
            counts[i] += int(result.crosses)
    estimates = [count / trials for count in counts]
    assert all(a <= b for a, b in zip(estimates, estimates[1:]))
    return estimates


def render_grid(n: int, open_sites: Set[Vertex], path: Set[Vertex]) -> str:
    """Render closed sites, open sites, and a crossing witness as ASCII."""
    rows: List[str] = []
    for row in range(n):
        symbols = []
        for col in range(n):
            vertex = (row, col)
            symbols.append("*" if vertex in path else "o" if vertex in open_sites else ".")
        rows.append(" ".join(symbols))
    return "\n".join(rows)


def main() -> None:
    """Run deterministic and Monte Carlo demonstrations."""
    n = 8
    thresholds = [0.20, 0.35, 0.50, 0.65, 0.80]
    rng = random.Random(20260802)
    site_keys = {(row, col): rng.random() for row in range(n) for col in range(n)}

    print("SITE COUPLING ON AN 8 x 8 GRID")
    print("The same 64 keys are reused at every threshold.\n")
    results = crossing_sweep(n, site_keys, thresholds)
    for result in results:
        print(
            f"p={result.threshold:.2f}  open={result.open_count:2d}/{n*n}  "
            f"horizontal crossing={result.crosses}"
        )
    final = results[-1]
    final_open = site_threshold_config(site_keys, final.threshold)
    print("\nFinal grid: '*' is a witness path, 'o' is open, '.' is closed")
    print(render_grid(n, final_open, set(final.path)))

    print("\nBOND COUPLING ON A SIX-VERTEX GRAPH")
    bond_keys: Dict[Edge, float] = {
        (0, 1): 0.12,
        (1, 2): 0.31,
        (2, 5): 0.58,
        (0, 3): 0.22,
        (3, 4): 0.47,
        (4, 5): 0.76,
        (1, 4): 0.66,
    }
    connected_seen = False
    previous_edges: Set[Edge] = set()
    for threshold in thresholds:
        edges = bond_threshold_config(bond_keys, threshold)
        assert previous_edges <= edges
        connected = graph_connected(6, edges, 0, 5)
        assert not connected_seen or connected
        connected_seen = connected_seen or connected
        print(
            f"p={threshold:.2f}  open bonds={len(edges):d}/{len(bond_keys)}  "
            f"0 connected to 5={connected}"
        )
        previous_edges = edges

    print("\nCOUPLED MONTE CARLO CROSSING ESTIMATES")
    estimates = estimate_crossing_probabilities(
        n=8, thresholds=thresholds, trials=2000, seed=104729
    )
    for threshold, estimate in zip(thresholds, estimates):
        print(f"p={threshold:.2f}  estimated crossing probability={estimate:.4f}")
    print("\nAll pointwise nesting and persistence assertions passed.")


if __name__ == "__main__":
    main()
