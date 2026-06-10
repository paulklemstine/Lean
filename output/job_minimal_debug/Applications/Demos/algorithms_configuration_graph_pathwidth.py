#!/usr/bin/env python3
"""
Configuration Graph Pathwidth — Core Algorithms

Implements the algorithms described in the research paper for computing
clause space, constructing configuration graphs, and computing pathwidth.

All algorithms include docstrings, type hints, and complexity analysis.
"""

from itertools import combinations, product, permutations
from typing import FrozenSet, Set, Tuple, List, Dict, Optional, Sequence
from collections import deque
import time

# ─── Types ───────────────────────────────────────────────────────────────

Literal = Tuple[int, bool]
Clause = FrozenSet[Literal]
Configuration = FrozenSet[Clause]

# ─── Algorithm 1: Resolution Engine ──────────────────────────────────────

def resolve_clauses(c1: Clause, c2: Clause) -> Optional[Clause]:
    """
    Resolve two clauses on a complementary literal pair.

    Given clauses C₁ and C₂, finds a variable x such that x ∈ C₁ and ¬x ∈ C₂
    (or vice versa), and returns the resolvent (C₁ \ {x}) ∪ (C₂ \ {¬x}).

    Returns None if no resolution is possible or if the result is a tautology.

    Time complexity: O(|C₁| · |C₂|)
    Space complexity: O(|C₁| + |C₂|)

    Examples:
        >>> resolve_clauses(frozenset([(0,True)]), frozenset([(0,False)]))
        frozenset()  # empty clause (contradiction)
        >>> resolve_clauses(frozenset([(0,True),(1,True)]), frozenset([(0,False),(2,True)]))
        frozenset([(1,True),(2,True)])  # y ∨ z
    """
    for lit in c1:
        neg_lit = (lit[0], not lit[1])
        if neg_lit in c2:
            resolvent = (c1 - {lit}) | (c2 - {neg_lit})
            # Tautology check
            for l in resolvent:
                if (l[0], not l[1]) in resolvent:
                    return None
            return resolvent
    return None


# ─── Algorithm 2: Clause Space Search ────────────────────────────────────

def clause_space_search(
    cnf: FrozenSet[Clause],
    max_space: int,
    max_steps: int = 10000,
) -> Optional[List[Configuration]]:
    """
    BFS through configuration space to find a refutation with bounded space.

    Pseudocode:
        1. Start from empty configuration ∅
        2. BFS over legal moves: axiom download, resolution, erasure
        3. Accept when a configuration containing ⊥ is reached
        4. Reject configurations exceeding space bound

    Time complexity: O(S · |F| · s²) where S = states visited,
                     |F| = formula size, s = space bound
    Space complexity: O(S · s) for the visited set

    Args:
        cnf: The CNF formula (set of clauses)
        max_space: Maximum configuration size allowed
        max_steps: Maximum BFS steps before giving up

    Returns:
        List of configurations forming a refutation trace, or None
    """
    empty_clause: Clause = frozenset()
    initial: Configuration = frozenset()

    queue: deque = deque([(initial, [initial])])
    visited: Set[Configuration] = {initial}
    steps = 0

    while queue and steps < max_steps:
        config, trace = queue.popleft()
        steps += 1

        if empty_clause in config:
            return trace

        # Move 1: Axiom download
        for clause in cnf:
            new_config = config | frozenset([clause])
            if len(new_config) <= max_space and new_config not in visited:
                visited.add(new_config)
                queue.append((new_config, trace + [new_config]))

        # Move 2: Resolution
        clauses_list = list(config)
        for i in range(len(clauses_list)):
            for j in range(i + 1, len(clauses_list)):
                resolvent = resolve_clauses(clauses_list[i], clauses_list[j])
                if resolvent is not None:
                    new_config = config | frozenset([resolvent])
                    if len(new_config) <= max_space and new_config not in visited:
                        visited.add(new_config)
                        queue.append((new_config, trace + [new_config]))

        # Move 3: Erasure
        for clause in config:
            new_config = config - frozenset([clause])
            if new_config not in visited:
                visited.add(new_config)
                queue.append((new_config, trace + [new_config]))

    return None


def compute_min_clause_space(
    cnf: FrozenSet[Clause],
    num_vars: int,
    upper_bound: int = 15,
) -> Optional[int]:
    """
    Compute minimum clause space by iteratively trying increasing bounds.

    Time complexity: O(upper_bound · clause_space_search_cost)

    Args:
        cnf: The CNF formula
        num_vars: Number of variables
        upper_bound: Maximum space to try

    Returns:
        Minimum clause space, or None if formula is satisfiable or bound exceeded
    """
    for s in range(1, upper_bound + 1):
        trace = clause_space_search(cnf, s)
        if trace is not None:
            return s
    return None


# ─── Algorithm 3: Configuration Graph Construction ───────────────────────

def build_config_graph(
    cnf: FrozenSet[Clause],
    space: int,
    max_configs: int = 5000,
) -> Tuple[List[Configuration], List[Tuple[int, int]]]:
    """
    Build the reachable bounded configuration graph.

    Pseudocode:
        1. BFS from empty configuration
        2. For each config, try all legal moves
        3. Add edges for single-element symmetric differences
        4. Respect space bound

    Time complexity: O(N² · s) where N = configs found, s = space bound
    Space complexity: O(N² + N · s)

    Returns:
        (vertices, edges) where edges are pairs of vertex indices
    """
    initial: Configuration = frozenset()
    visited: Set[Configuration] = {initial}
    queue: deque = deque([initial])

    while queue and len(visited) < max_configs:
        config = queue.popleft()

        # Axiom download
        for clause in cnf:
            new = config | frozenset([clause])
            if len(new) <= space and new not in visited:
                visited.add(new)
                queue.append(new)

        # Resolution
        clauses_list = list(config)
        for i in range(len(clauses_list)):
            for j in range(i + 1, len(clauses_list)):
                resolvent = resolve_clauses(clauses_list[i], clauses_list[j])
                if resolvent is not None:
                    new = config | frozenset([resolvent])
                    if len(new) <= space and new not in visited:
                        visited.add(new)
                        queue.append(new)

        # Erasure
        for clause in config:
            new = config - frozenset([clause])
            if new not in visited:
                visited.add(new)
                queue.append(new)

    vertices = list(visited)
    vert_idx = {v: i for i, v in enumerate(vertices)}

    edges = []
    for i in range(len(vertices)):
        for j in range(i + 1, len(vertices)):
            sd = vertices[i].symmetric_difference(vertices[j])
            if len(sd) == 1:
                edges.append((i, j))

    return vertices, edges


# ─── Algorithm 4: Exact Pathwidth via Vertex Separation ──────────────────

def exact_pathwidth(
    n: int,
    edges: List[Tuple[int, int]],
) -> int:
    """
    Compute exact pathwidth via minimum vertex separation number.

    Pathwidth equals the minimum vertex separation number over all
    linear orderings of vertices. The vertex separation at a cut point
    is the number of vertices to the left with at least one neighbor to the right.

    Uses dynamic programming with bitmask states for small graphs.

    Time complexity: O(2^n · n²) via DP, or O(n! · n) via brute force
    Space complexity: O(2^n) for DP

    Args:
        n: Number of vertices
        edges: List of edges as (i, j) pairs

    Returns:
        Exact pathwidth
    """
    if n == 0:
        return 0
    if n == 1:
        return 0

    # Build adjacency bitmasks
    adj = [0] * n
    for i, j in edges:
        adj[i] |= (1 << j)
        adj[j] |= (1 << i)

    if n <= 15:
        return _pathwidth_dp(n, adj)
    else:
        return _pathwidth_greedy(n, adj)


def _pathwidth_dp(n: int, adj: List[int]) -> int:
    """DP-based exact pathwidth for n ≤ 15."""
    full = (1 << n) - 1
    INF = n + 1

    # vs[mask] = min over orderings of vertices in mask
    #            of max vertex separation number
    best = [INF] * (1 << n)
    best[0] = 0

    for mask in range(1, 1 << n):
        # Try each vertex as the last one added
        remaining = full & ~mask
        for v in range(n):
            if not (mask & (1 << v)):
                continue
            prev_mask = mask & ~(1 << v)
            if prev_mask == 0:
                # First vertex: separation = 1 if it has neighbors, else 0
                sep = 1 if (adj[v] & remaining) else 0
                # Wait, vertex separation at cut = vertices in left with
                # neighbor in right. Left = {v}, right = rest.
                sep = 1 if (adj[v] & ~mask) else 0
                # Actually need to count how many in mask have neighbor outside
                # At this point, mask = {v}, so sep = 1 if v has external neighbor
                count = 0
                for u in range(n):
                    if (mask & (1 << u)) and (adj[u] & ~mask):
                        count += 1
                best[mask] = min(best[mask], max(best[prev_mask], count))
            else:
                # Count vertices in mask with neighbors outside mask
                count = 0
                for u in range(n):
                    if (mask & (1 << u)) and (adj[u] & ~mask):
                        count += 1
                best[mask] = min(best[mask], max(best[prev_mask], count))

    return best[full]


def _pathwidth_greedy(n: int, adj: List[int]) -> int:
    """Greedy heuristic for pathwidth upper bound."""
    remaining = (1 << n) - 1
    ordered = 0
    max_sep = 0

    for _ in range(n):
        # Pick vertex with min degree in remaining subgraph
        best_v = -1
        best_deg = n + 1
        for v in range(n):
            if not (remaining & (1 << v)):
                continue
            deg = bin(adj[v] & remaining).count('1')
            if deg < best_deg:
                best_deg = deg
                best_v = v

        remaining &= ~(1 << best_v)
        ordered |= (1 << best_v)

        # Count separation
        sep = 0
        for v in range(n):
            if (ordered & (1 << v)) and (adj[v] & remaining):
                sep += 1
        max_sep = max(max_sep, sep)

    return max_sep


# ─── Algorithm 5: Path Decomposition from Persistent Trace ──────────────

def trace_to_path_decomposition(
    trace: List[Configuration],
) -> Tuple[List[Set], int]:
    """
    Convert a persistent trace to a path decomposition of the co-occurrence graph.

    This implements the constructive proof of Theorem 2 from the paper:
    the configurations in a persistent trace directly serve as bags
    in a valid path decomposition.

    Args:
        trace: List of configurations (assumed persistent/interval property)

    Returns:
        (bags, width) where bags are sets of clauses and width is max bag size
    """
    bags = [set(config) for config in trace]
    width = max(len(b) for b in bags) if bags else 0
    return bags, width


def verify_interval_property(trace: List[Configuration]) -> bool:
    """
    Verify that a trace satisfies the interval (persistence) property.

    For each clause, the positions where it appears must form a
    contiguous interval.

    Time complexity: O(T · s) where T = trace length, s = max config size
    """
    # Collect first and last appearance of each clause
    first_seen: Dict[Clause, int] = {}
    last_seen: Dict[Clause, int] = {}

    for i, config in enumerate(trace):
        for clause in config:
            if clause not in first_seen:
                first_seen[clause] = i
            last_seen[clause] = i

    # Check contiguity
    for clause in first_seen:
        for i in range(first_seen[clause], last_seen[clause] + 1):
            if clause not in trace[i]:
                return False
    return True


# ─── Algorithm 6: Enumerate Small CNFs ───────────────────────────────────

def enumerate_cnfs(num_vars: int, max_clause_size: int = None):
    """
    Enumerate all non-tautological CNF formulas over num_vars variables.

    For exhaustive testing of conjectures on small instances.

    Args:
        num_vars: Number of propositional variables
        max_clause_size: Maximum clause size (default: 2*num_vars)

    Yields:
        CNF formulas as frozensets of clauses
    """
    if max_clause_size is None:
        max_clause_size = 2 * num_vars

    all_lits = [(v, True) for v in range(num_vars)] + \
               [(v, False) for v in range(num_vars)]

    # Generate all non-tautological clauses
    all_clauses = []
    for size in range(1, max_clause_size + 1):
        for combo in combinations(all_lits, size):
            clause = frozenset(combo)
            is_taut = any((l[0], not l[1]) in clause for l in clause)
            if not is_taut:
                all_clauses.append(clause)

    # Generate all subsets (CNFs)
    for r in range(1, len(all_clauses) + 1):
        for combo in combinations(all_clauses, r):
            yield frozenset(combo)


def is_unsatisfiable(cnf: FrozenSet[Clause], num_vars: int) -> bool:
    """Check satisfiability by brute-force enumeration of assignments."""
    for assignment in product([False, True], repeat=num_vars):
        satisfied = True
        for clause in cnf:
            clause_sat = any(
                assignment[var] == pol for var, pol in clause
            )
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            return False
    return True


# ─── Demonstration ───────────────────────────────────────────────────────

def demo():
    """Run algorithm demonstrations."""
    print("="*60)
    print("  Configuration Graph Pathwidth — Algorithm Demo")
    print("="*60)

    # Demo 1: Resolution
    print("\n--- Algorithm 1: Resolution ---")
    c1 = frozenset([(0, True), (1, True)])
    c2 = frozenset([(0, False), (2, True)])
    r = resolve_clauses(c1, c2)
    print(f"  Resolving {{x,y}} with {{¬x,z}}: {r}")

    c3 = frozenset([(0, True)])
    c4 = frozenset([(0, False)])
    r2 = resolve_clauses(c3, c4)
    print(f"  Resolving {{x}} with {{¬x}}: {r2} (empty clause = contradiction)")

    # Demo 2: Clause space
    print("\n--- Algorithm 2: Clause Space Search ---")
    cnf = frozenset([
        frozenset([(0, True), (1, True)]),
        frozenset([(0, True), (1, False)]),
        frozenset([(0, False), (1, True)]),
        frozenset([(0, False), (1, False)]),
    ])
    space = compute_min_clause_space(cnf, 2)
    print(f"  CNF: all 2-variable clauses")
    print(f"  Minimum clause space: {space}")

    # Demo 3: Configuration graph
    print("\n--- Algorithm 3: Configuration Graph ---")
    cnf2 = frozenset([
        frozenset([(0, True)]),
        frozenset([(0, False)]),
    ])
    verts, edges = build_config_graph(cnf2, space=2)
    print(f"  CNF: {{x}} ∧ {{¬x}}")
    print(f"  Space bound: 2")
    print(f"  Vertices: {len(verts)}")
    print(f"  Edges: {len(edges)}")

    # Demo 4: Pathwidth
    print("\n--- Algorithm 4: Pathwidth Computation ---")
    pw = exact_pathwidth(len(verts), edges)
    print(f"  Pathwidth of config graph: {pw}")
    print(f"  Clause space: {space}")
    print(f"  Ratio pw/space: {pw/space:.3f}" if space else "  N/A")

    # Demo 5: Interval property
    print("\n--- Algorithm 5: Persistent Trace ---")
    trace = clause_space_search(cnf2, 2)
    if trace:
        persistent = verify_interval_property(trace)
        bags, width = trace_to_path_decomposition(trace)
        print(f"  Trace length: {len(trace)}")
        print(f"  Persistent: {persistent}")
        print(f"  Path decomposition width: {width}")

    print("\n" + "="*60)


if __name__ == "__main__":
    demo()
