#!/usr/bin/env python3
"""
algorithms.py — Register Allocation Algorithms with Type Hints

Implements the key algorithms from the research:
1. Interval graph construction
2. PEO construction (by right endpoint)
3. Greedy coloring on PEO
4. Register pressure computation
5. Spill set selection
"""

from typing import List, Tuple, Set, Optional, Dict
from dataclasses import dataclass


@dataclass
class IntervalGraph:
    """An interval graph representing variable interference."""
    n: int
    intervals: List[Tuple[int, int]]
    adj: List[List[bool]]

    @classmethod
    def from_intervals(cls, intervals: List[Tuple[int, int]]) -> 'IntervalGraph':
        """Build an interval graph from liveness intervals.

        Two variables interfere iff their intervals overlap.
        Time complexity: O(n²)
        """
        n = len(intervals)
        adj = [[False] * n for _ in range(n)]
        for i in range(n):
            for j in range(i + 1, n):
                a1, b1 = intervals[i]
                a2, b2 = intervals[j]
                if a1 <= b2 and a2 <= b1:
                    adj[i][j] = True
                    adj[j][i] = True
        return cls(n=n, intervals=intervals, adj=adj)


@dataclass
class PerfectEliminationOrdering:
    """A perfect elimination ordering for a chordal graph."""
    order: List[int]
    positions: List[int]  # position[v] = index of v in order

    @classmethod
    def from_intervals(cls, intervals: List[Tuple[int, int]]) -> 'PerfectEliminationOrdering':
        """Construct PEO by sorting vertices by right endpoint.

        For interval graphs, ordering by right endpoint always gives a valid PEO.
        Time complexity: O(n log n)
        """
        indexed = sorted(enumerate(intervals), key=lambda x: x[1][1])
        order = [idx for idx, _ in indexed]
        positions = [0] * len(intervals)
        for pos, v in enumerate(order):
            positions[v] = pos
        return cls(order=order, positions=positions)


@dataclass
class RegisterAllocation:
    """Result of register allocation."""
    coloring: List[int]       # coloring[v] = register assigned to v (-1 if spilled)
    num_colors: int           # number of registers used
    spilled: Set[int]         # set of spilled variable indices
    clique_number: int        # ω(G) = minimum registers needed
    max_degree: int           # Δ(G) = maximum degree
    pressure_profile: List[int]  # register pressure at each PEO position


def compute_register_pressure(
    graph: IntervalGraph,
    peo: PerfectEliminationOrdering
) -> List[int]:
    """Compute register pressure at each PEO position.

    Pressure P(i) = |{later neighbors of σ(i)}| + 1
    The maximum pressure equals the clique number.
    Time complexity: O(n + m)
    """
    n = graph.n
    pressure = []
    for idx in range(n):
        v = peo.order[idx]
        later_nbrs = sum(
            1 for j in range(idx + 1, n)
            if graph.adj[v][peo.order[j]]
        )
        pressure.append(later_nbrs + 1)
    return pressure


def greedy_color_on_peo(
    graph: IntervalGraph,
    peo: PerfectEliminationOrdering,
    k: int
) -> List[int]:
    """Greedy coloring using PEO with k available colors.

    Process vertices in PEO order, assigning smallest available color.
    For chordal graphs, this uses exactly ω(G) colors.
    Time complexity: O(n + m)

    Returns: coloring array, or [-1]*n if k is insufficient.
    """
    n = graph.n
    color = [-1] * n

    # Process in REVERSE PEO order for optimal chordal coloring
    for idx in range(n - 1, -1, -1):
        v = peo.order[idx]
        used: Set[int] = set()
        for j in range(n):
            if graph.adj[v][j] and color[j] >= 0:
                used.add(color[j])

        # Find smallest available color < k
        c = 0
        while c in used and c < k:
            c += 1

        if c >= k:
            return [-1] * n  # insufficient colors
        color[v] = c

    return color


def compute_clique_number(graph: IntervalGraph) -> int:
    """Compute clique number using register pressure profile.

    For chordal graphs, ω(G) = max register pressure = max P(i).
    Time complexity: O(n + m) for chordal graphs
    """
    peo = PerfectEliminationOrdering.from_intervals(graph.intervals)
    pressure = compute_register_pressure(graph, peo)
    return max(pressure) if pressure else 0


def select_spill_set(
    graph: IntervalGraph,
    k: int,
    weights: Optional[List[float]] = None
) -> Set[int]:
    """Select variables to spill when k < ω(G).

    Uses degree-based heuristic: iteratively spill the variable with
    the highest degree (or lowest weight/degree ratio if weighted).

    Returns: set of variable indices to spill.
    """
    if weights is None:
        weights = [1.0] * graph.n

    omega = compute_clique_number(graph)
    if k >= omega:
        return set()

    spilled: Set[int] = set()
    remaining_adj = [row[:] for row in graph.adj]

    while True:
        # Recompute clique number on remaining graph
        remaining_intervals = [
            graph.intervals[i] if i not in spilled else (0, -1)
            for i in range(graph.n)
        ]
        # Compute degrees
        degrees = [
            sum(1 for j in range(graph.n)
                if j not in spilled and remaining_adj[i][j])
            for i in range(graph.n)
        ]

        # Check if k colors suffice
        max_pressure = 0
        peo = PerfectEliminationOrdering.from_intervals(graph.intervals)
        for idx in range(graph.n):
            v = peo.order[idx]
            if v in spilled:
                continue
            later_nbrs = sum(
                1 for j in range(idx + 1, graph.n)
                if peo.order[j] not in spilled and graph.adj[v][peo.order[j]]
            )
            max_pressure = max(max_pressure, later_nbrs + 1)

        if max_pressure <= k:
            break

        # Spill vertex with highest degree / lowest weight ratio
        candidates = [
            (i, degrees[i] / max(weights[i], 1e-10))
            for i in range(graph.n) if i not in spilled and degrees[i] > 0
        ]
        if not candidates:
            break
        victim = max(candidates, key=lambda x: x[1])[0]
        spilled.add(victim)

    return spilled


def allocate_registers(
    intervals: List[Tuple[int, int]],
    k: int,
    weights: Optional[List[float]] = None
) -> RegisterAllocation:
    """Complete register allocation algorithm.

    1. Build interval graph
    2. Construct PEO
    3. Compute clique number
    4. If k ≥ ω: greedy color (no spills)
    5. If k < ω: select spill set, then greedy color remainder

    Args:
        intervals: liveness intervals [(start, end), ...]
        k: number of available registers
        weights: optional variable access frequencies for spill selection

    Returns: RegisterAllocation with coloring, spills, and analysis
    """
    graph = IntervalGraph.from_intervals(intervals)
    peo = PerfectEliminationOrdering.from_intervals(intervals)
    pressure = compute_register_pressure(graph, peo)
    omega = max(pressure) if pressure else 0
    degrees = [sum(graph.adj[i]) for i in range(graph.n)]
    max_deg = max(degrees) if degrees else 0

    spilled = select_spill_set(graph, k, weights)

    # Color unspilled vertices: build subgraph without spilled
    if spilled:
        # Mask spilled vertices in adjacency
        sub_adj = [[graph.adj[i][j] and i not in spilled and j not in spilled
                    for j in range(graph.n)] for i in range(graph.n)]
        sub_graph = IntervalGraph(n=graph.n, intervals=graph.intervals, adj=sub_adj)
        coloring = greedy_color_on_peo(sub_graph, peo, k)
    else:
        coloring = greedy_color_on_peo(graph, peo, k)
    for v in spilled:
        coloring[v] = -1

    num_colors = max(c for c in coloring if c >= 0) + 1 if any(c >= 0 for c in coloring) else 0

    return RegisterAllocation(
        coloring=coloring,
        num_colors=num_colors,
        spilled=spilled,
        clique_number=omega,
        max_degree=max_deg,
        pressure_profile=pressure,
    )


# ─── Example usage ───

if __name__ == "__main__":
    # Example: 8 variables from a simple SSA program
    intervals = [
        (0, 3), (1, 5), (2, 4), (3, 7),
        (5, 8), (6, 9), (4, 6), (7, 10),
    ]

    print("Register Allocation Algorithm Demo")
    print("=" * 50)

    for k in [2, 3, 4, 6]:
        result = allocate_registers(intervals, k)
        print(f"\nWith k={k} registers (ω={result.clique_number}, Δ={result.max_degree}):")
        for i in range(len(intervals)):
            if i in result.spilled:
                print(f"  v{i}: SPILLED")
            else:
                print(f"  v{i}: R{result.coloring[i]}")
        print(f"  Registers used: {result.num_colors}, Spilled: {len(result.spilled)}")
