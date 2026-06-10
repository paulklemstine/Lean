#!/usr/bin/env python3
"""
Pathwidth-Guided SAT Solving: Core Algorithms

Implements the pathwidth-guided clause retention algorithms and path
decomposition construction methods described in the research paper.
"""

import itertools
from typing import List, Set, Tuple, Dict, Optional, FrozenSet
from collections import defaultdict
import heapq

# Type aliases
Literal = Tuple[str, bool]
Clause = FrozenSet[Literal]


def clause_vars(clause: Clause) -> Set[str]:
    """Extract the set of propositional variables from a clause.

    Args:
        clause: A frozenset of (variable, polarity) pairs.

    Returns:
        Set of variable names appearing in the clause.

    Example:
        >>> clause_vars(frozenset({("x", True), ("y", False)}))
        {'x', 'y'}
    """
    return {lit[0] for lit in clause}


def build_interaction_graph(cnf: List[Clause]) -> Dict[int, Set[int]]:
    """Build the clause interaction graph adjacency list.

    Two clauses are adjacent if they share at least one variable.

    Args:
        cnf: List of clauses.

    Returns:
        Adjacency list mapping clause index to set of neighbor indices.

    Complexity: O(n^2 * m) where n = number of clauses, m = max clause size.

    Example:
        >>> cnf = [frozenset({("x", True)}), frozenset({("x", False), ("y", True)})]
        >>> g = build_interaction_graph(cnf)
        >>> g[0]
        {1}
    """
    n = len(cnf)
    adj: Dict[int, Set[int]] = defaultdict(set)
    var_to_clauses: Dict[str, Set[int]] = defaultdict(set)

    for i, clause in enumerate(cnf):
        for v in clause_vars(clause):
            var_to_clauses[v].add(i)

    for clauses in var_to_clauses.values():
        for i, j in itertools.combinations(clauses, 2):
            adj[i].add(j)
            adj[j].add(i)

    # Ensure all vertices present
    for i in range(n):
        if i not in adj:
            adj[i] = set()

    return dict(adj)


def greedy_elimination_decomposition(
    adj: Dict[int, Set[int]]
) -> List[Set[int]]:
    """Construct a path decomposition via greedy minimum-degree elimination.

    This is the standard heuristic for approximate pathwidth computation.
    At each step, eliminate the vertex with minimum degree among remaining
    vertices, adding fill edges between its neighbors.

    Args:
        adj: Adjacency list of the graph.

    Returns:
        List of bags forming a valid path decomposition.

    Complexity: O(n^2) in the worst case with fill-in.

    Example:
        >>> adj = {0: {1}, 1: {0, 2}, 2: {1}}
        >>> bags = greedy_elimination_decomposition(adj)
        >>> all(isinstance(b, set) for b in bags)
        True
    """
    vertices = set(adj.keys())
    if not vertices:
        return [set()]

    adj_copy = {v: set(adj[v]) for v in vertices}
    remaining = set(vertices)
    order = []

    while remaining:
        # Minimum degree vertex
        v = min(remaining, key=lambda x: len(adj_copy[x] & remaining))
        order.append(v)
        remaining.remove(v)
        # Add fill edges
        neighbors = adj_copy[v] & remaining
        for a, b in itertools.combinations(neighbors, 2):
            adj_copy[a].add(b)
            adj_copy[b].add(a)

    # Build bags
    bags = []
    for v in order:
        later = {u for u in adj_copy[v] if order.index(u) > order.index(v)}
        bags.append({v} | later)

    return bags


def sliding_window_decomposition(
    cnf: List[Clause],
    window_size: int = 3
) -> List[Set[int]]:
    """Construct a path decomposition using sliding-window bags.

    Orders clauses by a variable-overlap score and creates bags
    of size `window_size` by sliding a window along the ordering.

    Args:
        cnf: List of clauses.
        window_size: Size of the sliding window.

    Returns:
        List of bags forming a path decomposition.

    Complexity: O(n^2 * m) for ordering, O(n * w) for bag construction.
    """
    n = len(cnf)
    if n == 0:
        return [set()]

    # Order clauses greedily by maximum overlap with previous clause
    used = [False] * n
    order = [0]
    used[0] = True
    for _ in range(1, n):
        best_idx = -1
        best_score = -1
        last_vars = clause_vars(cnf[order[-1]])
        for j in range(n):
            if not used[j]:
                score = len(last_vars & clause_vars(cnf[j]))
                if score > best_score:
                    best_score = score
                    best_idx = j
        order.append(best_idx)
        used[best_idx] = True

    # Create sliding window bags
    bags = []
    for i in range(n):
        bag = set()
        for j in range(max(0, i - window_size + 1), min(n, i + 1)):
            bag.add(order[j])
        bags.append(bag)

    return bags


def compute_active_frontier(
    bags: List[Set[int]],
    cut: int,
    n_clauses: int
) -> Set[int]:
    """Compute the active frontier at a given cut position.

    A clause is in the frontier if its bag-support spans the cut,
    i.e., it appears in some bag at or before `cut` and some bag
    at or after `cut`.

    Args:
        bags: Path decomposition bags.
        cut: Cut position index.
        n_clauses: Total number of clauses.

    Returns:
        Set of clause indices in the active frontier.

    Complexity: O(n * |bags|).
    """
    frontier = set()
    for v in range(n_clauses):
        indices = [i for i, b in enumerate(bags) if v in b]
        if indices and min(indices) <= cut <= max(indices):
            frontier.add(v)
    return frontier


def retain_at_cut(
    bags: List[Set[int]],
    cut: int,
    n_clauses: int
) -> Set[int]:
    """Compute the retained clause set at a given cut.

    Args:
        bags: Path decomposition bags.
        cut: Cut position.
        n_clauses: Total number of clauses.

    Returns:
        Set of clause indices to retain.
    """
    if cut >= len(bags):
        return set()
    bag = bags[cut]
    frontier = compute_active_frontier(bags, cut, n_clauses)
    return bag | frontier


def max_frontier_size(bags: List[Set[int]], n_clauses: int) -> int:
    """Compute the maximum frontier size across all cuts.

    Args:
        bags: Path decomposition bags.
        n_clauses: Total number of clauses.

    Returns:
        Maximum frontier size.

    Example:
        >>> bags = [{0, 1}, {1, 2}, {2}]
        >>> max_frontier_size(bags, 3)
        2
    """
    if not bags:
        return 0
    return max(
        len(compute_active_frontier(bags, i, n_clauses))
        for i in range(len(bags))
    )


def verify_decomposition(
    bags: List[Set[int]],
    adj: Dict[int, Set[int]]
) -> Tuple[bool, str]:
    """Verify that a path decomposition satisfies all three axioms.

    Args:
        bags: List of bags.
        adj: Adjacency list of the graph.

    Returns:
        (valid, message) tuple.

    Complexity: O(|bags| * |V|^2).
    """
    # Vertex coverage
    covered = set()
    for b in bags:
        covered |= b
    for v, neighbors in adj.items():
        if neighbors and v not in covered:
            return False, f"Vertex {v} not covered"

    # Edge coverage
    for u, neighbors in adj.items():
        for v in neighbors:
            if u < v:
                if not any(u in b and v in b for b in bags):
                    return False, f"Edge ({u},{v}) not covered"

    # Interval property
    for v in covered:
        indices = [i for i, b in enumerate(bags) if v in b]
        if indices:
            lo, hi = min(indices), max(indices)
            for k in range(lo, hi + 1):
                if v not in bags[k]:
                    return False, f"Interval violated for vertex {v} at bag {k}"

    return True, "Valid path decomposition"


def pathwidth_guided_retention_report(
    cnf: List[Clause],
    method: str = "greedy"
) -> Dict:
    """Complete pathwidth-guided retention analysis.

    Args:
        cnf: List of clauses.
        method: Decomposition method ("greedy" or "sliding").

    Returns:
        Dictionary with analysis results.

    Example:
        >>> cnf = [frozenset({("x", True), ("y", False)}),
        ...        frozenset({("y", True), ("z", True)})]
        >>> report = pathwidth_guided_retention_report(cnf)
        >>> report["width"] >= 0
        True
    """
    adj = build_interaction_graph(cnf)

    if method == "greedy":
        bags = greedy_elimination_decomposition(adj)
    else:
        bags = sliding_window_decomposition(cnf)

    valid, msg = verify_decomposition(bags, adj)
    width = max(len(b) for b in bags) - 1 if bags else 0
    mfs = max_frontier_size(bags, len(cnf))

    frontier_sizes = [
        len(compute_active_frontier(bags, i, len(cnf)))
        for i in range(len(bags))
    ]

    retained_sizes = [
        len(retain_at_cut(bags, i, len(cnf)))
        for i in range(len(bags))
    ]

    return {
        "n_clauses": len(cnf),
        "n_edges": sum(len(v) for v in adj.values()) // 2,
        "width": width,
        "max_frontier_size": mfs,
        "bound_satisfied": mfs <= width + 1,
        "valid_decomposition": valid,
        "validation_message": msg,
        "frontier_sizes": frontier_sizes,
        "retained_sizes": retained_sizes,
        "bags": [sorted(b) for b in bags],
        "memory_reduction_pct": (
            (1 - sum(retained_sizes) / (len(cnf) * len(bags))) * 100
            if len(cnf) * len(bags) > 0 else 0
        ),
    }


if __name__ == "__main__":
    # Example usage
    cnf = [
        frozenset({("x1", True), ("x2", False)}),
        frozenset({("x2", True), ("x3", True)}),
        frozenset({("x3", False), ("x4", True)}),
        frozenset({("x4", False), ("x5", True)}),
    ]

    report = pathwidth_guided_retention_report(cnf)
    print("Pathwidth-Guided Retention Report")
    print("=" * 40)
    for key, value in report.items():
        if not isinstance(value, list):
            print(f"  {key}: {value}")
    print(f"\n  Frontier sizes by cut: {report['frontier_sizes']}")
    print(f"  Retained sizes by cut: {report['retained_sizes']}")
    print(f"  Bags: {report['bags']}")
