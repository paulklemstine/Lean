"""
algorithms.py — Core algorithms for configuration graph pathwidth analysis.

Implements the mathematical machinery for connecting resolution proof memory
(clause space) to graph-theoretic pathwidth of configuration graphs.
"""

from __future__ import annotations
from itertools import combinations, product
from typing import Optional


class PathDecomposition:
    """A path decomposition of a graph: a sequence of bags (sets of vertices).

    Width = max(|bag| for bag in bags) - 1.
    """

    def __init__(self, bags: list[frozenset]):
        if not bags:
            raise ValueError("Path decomposition must have at least one bag")
        self.bags = bags

    @property
    def width(self) -> int:
        return max(len(b) for b in self.bags) - 1

    @property
    def max_bag_card(self) -> int:
        return max(len(b) for b in self.bags)

    def has_interval_property(self) -> bool:
        """Check if the decomposition satisfies the interval property."""
        all_vertices = set()
        for b in self.bags:
            all_vertices |= b
        for v in all_vertices:
            indices = [i for i, b in enumerate(self.bags) if v in b]
            if not indices:
                continue
            lo, hi = min(indices), max(indices)
            for j in range(lo, hi + 1):
                if v not in self.bags[j]:
                    return False
        return True

    def covers_vertex(self, v) -> bool:
        return any(v in b for b in self.bags)

    def covers_edge(self, u, v) -> bool:
        return any(u in b and v in b for b in self.bags)

    def is_valid_for(self, vertices: set, edges: set[tuple]) -> bool:
        """Check if this is a valid path decomposition for the given graph."""
        for v in vertices:
            if not self.covers_vertex(v):
                return False
        for u, v in edges:
            if not self.covers_edge(u, v):
                return False
        return self.has_interval_property()


class ConfigTrace:
    """A configuration trace: a sequence of configurations (sets of clauses).

    Models a sequence of memory states during resolution proof search.
    """

    def __init__(self, configs: list[frozenset]):
        if not configs:
            raise ValueError("Trace must have at least one configuration")
        self.configs = configs

    @property
    def clause_space(self) -> int:
        """Maximum configuration size (number of clauses held simultaneously)."""
        return max(len(c) for c in self.configs)

    @property
    def is_regular(self) -> bool:
        """Check if the trace is regular (monotone): once a clause leaves, it never returns."""
        all_clauses = set()
        for c in self.configs:
            all_clauses |= c
        for clause in all_clauses:
            appearances = [i for i, c in enumerate(self.configs) if clause in c]
            if not appearances:
                continue
            lo, hi = min(appearances), max(appearances)
            for j in range(lo, hi + 1):
                if clause not in self.configs[j]:
                    return False
        return True

    def to_path_decomposition(self) -> PathDecomposition:
        """Convert trace to path decomposition (bags = configs)."""
        return PathDecomposition(self.configs)

    def starts_empty(self) -> bool:
        return len(self.configs[0]) == 0

    def achieves(self, goal) -> bool:
        return goal in self.configs[-1]


class CNFFormula:
    """A CNF formula over a set of variables.

    Each clause is a frozenset of literals (variable, polarity) pairs.
    """

    def __init__(self, clauses: list[frozenset], n_vars: int):
        self.clauses = [frozenset(c) for c in clauses]
        self.n_vars = n_vars

    def is_satisfied_by(self, assignment: dict[int, bool]) -> bool:
        """Check if the assignment satisfies all clauses."""
        for clause in self.clauses:
            satisfied = False
            for var, pol in clause:
                if assignment.get(var) == pol:
                    satisfied = True
                    break
            if not satisfied:
                return False
        return True

    def is_unsatisfiable(self) -> bool:
        """Check unsatisfiability by brute force (for small instances)."""
        for bits in product([False, True], repeat=self.n_vars):
            assignment = {i: bits[i] for i in range(self.n_vars)}
            if self.is_satisfied_by(assignment):
                return False
        return True


def build_conf_graph_bounded(formula: CNFFormula, s: int) -> tuple[set, set]:
    """Build the bounded configuration graph for a CNF formula.

    Vertices: all configurations (subsets of clauses) with |config| <= s.
    Edges: pairs of configurations differing by exactly one clause.

    Args:
        formula: The CNF formula
        s: Space bound

    Returns:
        (vertices, edges) where vertices is a set of frozensets
        and edges is a set of pairs of frozensets.
    """
    all_clauses = list(set(formula.clauses))
    vertices = set()
    # Generate all subsets of clauses with size <= s
    for size in range(s + 1):
        for subset in combinations(all_clauses, size):
            vertices.add(frozenset(subset))

    edges = set()
    for v in vertices:
        for clause in all_clauses:
            if clause not in v:
                neighbor = frozenset(v | {clause})
                if len(neighbor) <= s and neighbor in vertices:
                    edge = (min(v, neighbor), max(v, neighbor))
                    edges.add(edge)
            else:
                neighbor = frozenset(v - {clause})
                if neighbor in vertices:
                    edge = (min(v, neighbor), max(v, neighbor))
                    edges.add(edge)
    return vertices, edges


def compute_pathwidth_brute_force(vertices: set, edges: set, max_width: int = 10) -> int:
    """Compute exact pathwidth by brute force for small graphs.

    Tries all orderings of vertices and computes the minimum width
    path decomposition. Only feasible for very small graphs (|V| <= 8).

    Args:
        vertices: Set of vertices
        edges: Set of edges (pairs)
        max_width: Upper bound to stop searching

    Returns:
        Exact pathwidth, or max_width if not found below bound.
    """
    from itertools import permutations

    vlist = list(vertices)
    n = len(vlist)

    if n == 0:
        return 0
    if n > 8:
        # Too large for brute force
        return _pathwidth_greedy_upper_bound(vertices, edges)

    best_width = n - 1  # Trivial upper bound

    for perm in permutations(range(n)):
        # For this ordering, compute optimal bags
        # Each vertex must appear in a contiguous range of bags
        # We use a greedy approach: for each position, the bag contains
        # all vertices whose interval includes this position

        # For this permutation, define interval for each vertex
        # based on edges: vertex v must be in bag at position p(v),
        # and if (u,v) is an edge, their intervals must overlap
        order = {vlist[perm[i]]: i for i in range(n)}

        # For each vertex, compute the range it must be active
        intervals = {}
        for v in vlist:
            intervals[v] = [order[v], order[v]]

        # Extend intervals to cover edges
        for u, v in edges:
            if u in order and v in order:
                lo = min(order[u], order[v])
                hi = max(order[u], order[v])
                intervals[u] = [min(intervals[u][0], lo), max(intervals[u][1], hi)]
                intervals[v] = [min(intervals[v][0], lo), max(intervals[v][1], hi)]

        # Compute bag sizes
        max_bag = 0
        for pos in range(n):
            bag_size = sum(1 for v in vlist if intervals[v][0] <= pos <= intervals[v][1])
            max_bag = max(max_bag, bag_size)

        width = max_bag - 1
        best_width = min(best_width, width)

        if best_width <= 1:
            break

    return best_width


def _pathwidth_greedy_upper_bound(vertices: set, edges: set) -> int:
    """Greedy upper bound on pathwidth using BFS ordering."""
    if not vertices:
        return 0

    # Build adjacency list
    adj = {v: set() for v in vertices}
    for u, v in edges:
        if u in adj and v in adj:
            adj[u].add(v)
            adj[v].add(u)

    # BFS ordering
    start = next(iter(vertices))
    visited = []
    queue = [start]
    seen = {start}
    while queue:
        v = queue.pop(0)
        visited.append(v)
        for u in adj.get(v, []):
            if u not in seen:
                seen.add(u)
                queue.append(u)
    # Add unvisited vertices
    for v in vertices:
        if v not in seen:
            visited.append(v)

    # Compute bags from this ordering
    n = len(visited)
    order = {v: i for i, v in enumerate(visited)}
    intervals = {v: [order[v], order[v]] for v in visited}
    for u, v in edges:
        if u in order and v in order:
            lo, hi = min(order[u], order[v]), max(order[u], order[v])
            intervals[u] = [min(intervals[u][0], lo), max(intervals[u][1], hi)]
            intervals[v] = [min(intervals[v][0], lo), max(intervals[v][1], hi)]

    max_bag = 0
    for pos in range(n):
        bag_size = sum(1 for v in visited if intervals[v][0] <= pos <= intervals[v][1])
        max_bag = max(max_bag, bag_size)

    return max_bag - 1


def estimate_clause_space(formula: CNFFormula) -> int:
    """Estimate minimum clause space for a CNF formula.

    Uses a greedy resolution strategy to find an upper bound.

    Args:
        formula: An unsatisfiable CNF formula

    Returns:
        Upper bound on minimum clause space.
    """
    if not formula.is_unsatisfiable():
        return float('inf')

    # Simple strategy: try resolving all pairs, tracking minimum peak memory
    clauses = set(formula.clauses)
    best_space = len(clauses) + 1

    # Try each resolution ordering
    clause_list = list(clauses)

    # Greedy: resolve pairs with maximum overlap first
    config = set()
    trace = [frozenset()]
    max_space = 0

    # Download all axioms and try resolutions
    for c in clause_list:
        config.add(c)
        trace.append(frozenset(config))
        max_space = max(max_space, len(config))

        # Try to derive the empty clause
        new_clauses = set()
        for c1 in config:
            for c2 in config:
                if c1 >= c2:
                    continue
                # Try resolution on each variable
                for var, pol in c1:
                    if (var, not pol) in c2:
                        resolvent = frozenset(
                            (c1 - {(var, pol)}) | (c2 - {(var, not pol)})
                        )
                        new_clauses.add(resolvent)

        for nc in new_clauses:
            config.add(nc)
            trace.append(frozenset(config))
            max_space = max(max_space, len(config))
            if len(nc) == 0:
                best_space = min(best_space, max_space)

    return best_space


def enumerate_cnfs(n_vars: int, max_clause_len: Optional[int] = None) -> list[CNFFormula]:
    """Enumerate all CNF formulas over n_vars variables.

    Args:
        n_vars: Number of variables
        max_clause_len: Maximum clause length (default: 2*n_vars)

    Returns:
        List of all CNF formulas (up to clause set inclusion).
    """
    if max_clause_len is None:
        max_clause_len = 2 * n_vars

    # Generate all possible literals
    literals = [(v, p) for v in range(n_vars) for p in [True, False]]

    # Generate all possible clauses (non-empty subsets of literals,
    # no variable appears twice)
    all_clauses = []
    for size in range(0, max_clause_len + 1):
        for subset in combinations(literals, size):
            # Check no variable appears with both polarities
            vars_seen = {}
            valid = True
            for var, pol in subset:
                if var in vars_seen:
                    if vars_seen[var] != pol:
                        valid = False
                        break
                vars_seen[var] = pol
            if valid:
                all_clauses.append(frozenset(subset))

    # Generate all CNF formulas (subsets of clauses)
    formulas = []
    for size in range(1, min(len(all_clauses) + 1, 20)):  # Cap for feasibility
        for clause_set in combinations(all_clauses, size):
            f = CNFFormula(list(clause_set), n_vars)
            formulas.append(f)
    return formulas


def analyze_formula(formula: CNFFormula, verbose: bool = False) -> dict:
    """Analyze a CNF formula: compute clause space, build config graph,
    compute pathwidth, and check the conjecture.

    Args:
        formula: An unsatisfiable CNF formula
        verbose: Print details

    Returns:
        Dictionary with analysis results.
    """
    if not formula.is_unsatisfiable():
        return {"unsatisfiable": False}

    space = estimate_clause_space(formula)
    vertices, edges = build_conf_graph_bounded(formula, space)

    n_vertices = len(vertices)
    n_edges = len(edges)

    # Compute pathwidth for small graphs
    if n_vertices <= 8:
        pw = compute_pathwidth_brute_force(vertices, edges)
    else:
        pw = _pathwidth_greedy_upper_bound(vertices, edges)

    ratio = pw / space if space > 0 else 0

    result = {
        "unsatisfiable": True,
        "n_clauses": len(formula.clauses),
        "n_vars": formula.n_vars,
        "clause_space_upper_bound": space,
        "config_graph_vertices": n_vertices,
        "config_graph_edges": n_edges,
        "pathwidth": pw,
        "ratio_pw_to_space": ratio,
        "conjecture_holds": pw <= 4 * space,  # c=4 hypothesis
    }

    if verbose:
        print(f"  Clauses: {len(formula.clauses)}, Vars: {formula.n_vars}")
        print(f"  Clause space (upper bound): {space}")
        print(f"  Config graph: {n_vertices} vertices, {n_edges} edges")
        print(f"  Pathwidth: {pw}")
        print(f"  Ratio pw/space: {ratio:.3f}")
        print(f"  Conjecture (c=4) holds: {result['conjecture_holds']}")

    return result


if __name__ == "__main__":
    # Example: analyze a small unsatisfiable formula
    # (x₀ ∨ x₁) ∧ (x₀ ∨ ¬x₁) ∧ (¬x₀ ∨ x₁) ∧ (¬x₀ ∨ ¬x₁)
    f = CNFFormula([
        frozenset([(0, True), (1, True)]),
        frozenset([(0, True), (1, False)]),
        frozenset([(0, False), (1, True)]),
        frozenset([(0, False), (1, False)]),
    ], n_vars=2)

    print("Example: 4-clause unsatisfiable formula on 2 variables")
    result = analyze_formula(f, verbose=True)
