"""
algorithms.py — Core algorithms for configuration graph pathwidth analysis.

Implements:
1. CNF formula representation and operations
2. Resolution trace construction
3. Configuration graph construction
4. Pathwidth computation (exact, brute-force for small graphs)
5. Clause space computation
"""

from itertools import combinations, product
from typing import FrozenSet, Set, List, Tuple, Optional, Dict
from collections import defaultdict


# ============================================================
# Types
# ============================================================

Literal = int  # Positive = variable, Negative = negation
Clause = FrozenSet[int]
Configuration = FrozenSet[Clause]
CNF = FrozenSet[Clause]


def neg(lit: Literal) -> Literal:
    """Negate a literal."""
    return -lit


def variables_of(cnf: CNF) -> Set[int]:
    """Extract the set of variables from a CNF formula."""
    return {abs(lit) for clause in cnf for lit in clause}


# ============================================================
# Resolution
# ============================================================

def resolve(c1: Clause, c2: Clause) -> Optional[Clause]:
    """
    Resolve two clauses if they have exactly one complementary literal.
    Returns the resolvent or None if resolution is not possible.
    """
    complements = []
    for lit in c1:
        if neg(lit) in c2:
            complements.append(lit)
    if len(complements) != 1:
        return None
    lit = complements[0]
    resolvent = (c1 - {lit}) | (c2 - {neg(lit)})
    # Check for tautology
    for l in resolvent:
        if neg(l) in resolvent:
            return None
    return frozenset(resolvent)


def all_resolvents(config: Configuration) -> Set[Clause]:
    """Compute all possible resolvents from clauses in a configuration."""
    results = set()
    clauses = list(config)
    for i in range(len(clauses)):
        for j in range(i + 1, len(clauses)):
            r = resolve(clauses[i], clauses[j])
            if r is not None:
                results.add(r)
    return results


# ============================================================
# Resolution Trace Construction
# ============================================================

def find_refutation_trace(cnf: CNF, max_space: int = 10) -> Optional[List[Configuration]]:
    """
    Find a resolution refutation trace using BFS over configuration space.
    Returns a list of configurations from empty to a configuration containing
    the empty clause, or None if no refutation exists within the space bound.

    Args:
        cnf: The CNF formula to refute.
        max_space: Maximum number of clauses in any configuration.

    Returns:
        A list of configurations representing the refutation trace, or None.
    """
    empty_clause = frozenset()
    start = frozenset()  # Empty configuration

    # BFS
    queue = [(start,)]
    visited = {start}

    while queue:
        path = queue.pop(0)
        current = path[-1]

        # Check if we've derived the empty clause
        if empty_clause in current:
            return list(path)

        # Generate successors
        successors = []

        # 1. Add an axiom clause
        for clause in cnf:
            if clause not in current and len(current) + 1 <= max_space:
                new_config = frozenset(current | {clause})
                successors.append(new_config)

        # 2. Add a resolvent
        for r in all_resolvents(current):
            if r not in current and len(current) + 1 <= max_space:
                new_config = frozenset(current | {r})
                successors.append(new_config)

        # 3. Forget a clause
        for clause in current:
            new_config = frozenset(current - {clause})
            successors.append(new_config)

        for succ in successors:
            if succ not in visited:
                visited.add(succ)
                queue.append(path + (succ,))

    return None


def clause_space_of_trace(trace: List[Configuration]) -> int:
    """Compute the clause space (max configuration size) of a trace."""
    return max(len(config) for config in trace) if trace else 0


# ============================================================
# Configuration Graph
# ============================================================

def build_bounded_config_graph(
    cnf: CNF, s: int
) -> Tuple[List[Configuration], Dict[Configuration, Set[Configuration]]]:
    """
    Build the s-bounded configuration graph for a CNF formula.

    Vertices: all configurations (subsets of derivable clauses) with size ≤ s.
    Edges: configurations differing by exactly one clause (add or remove).

    Args:
        cnf: The CNF formula.
        s: The space bound.

    Returns:
        (vertices, adjacency_dict)
    """
    # First, compute all derivable clauses (up to a reasonable depth)
    all_clauses = set(cnf)
    changed = True
    while changed:
        changed = False
        new_clauses = set()
        for c1 in all_clauses:
            for c2 in all_clauses:
                r = resolve(c1, c2)
                if r is not None and r not in all_clauses:
                    new_clauses.add(r)
                    changed = True
        all_clauses |= new_clauses
        if len(all_clauses) > 100:  # Safety bound
            break

    clauses_list = sorted(all_clauses, key=lambda c: (len(c), sorted(c)))

    # Enumerate configurations of size ≤ s
    vertices = []
    for size in range(s + 1):
        for combo in combinations(clauses_list, size):
            vertices.append(frozenset(combo))

    vertex_set = set(vertices)

    # Build adjacency
    adj: Dict[Configuration, Set[Configuration]] = defaultdict(set)
    for config in vertices:
        # Add a clause
        for clause in clauses_list:
            if clause not in config and len(config) + 1 <= s:
                neighbor = frozenset(config | {clause})
                if neighbor in vertex_set:
                    adj[config].add(neighbor)
                    adj[neighbor].add(config)
        # Remove a clause
        for clause in config:
            neighbor = frozenset(config - {clause})
            if neighbor in vertex_set:
                adj[config].add(neighbor)
                adj[neighbor].add(config)

    return vertices, dict(adj)


def build_visited_graph(
    trace: List[Configuration],
) -> Tuple[List[Configuration], Dict[Configuration, Set[Configuration]]]:
    """
    Build the visited configuration graph from a trace.

    Vertices: distinct configurations in the trace.
    Edges: between consecutively visited configurations.
    """
    vertices = list(dict.fromkeys(trace))  # Unique, preserving order
    vertex_set = set(vertices)

    adj: Dict[Configuration, Set[Configuration]] = defaultdict(set)
    for i in range(len(trace) - 1):
        c1, c2 = trace[i], trace[i + 1]
        if c1 != c2:
            adj[c1].add(c2)
            adj[c2].add(c1)

    return vertices, dict(adj)


# ============================================================
# Path Decomposition and Pathwidth
# ============================================================

def verify_path_decomposition(
    bags: List[Set[int]],
    vertices: List[int],
    edges: List[Tuple[int, int]],
) -> Tuple[bool, str]:
    """
    Verify that a list of bags forms a valid path decomposition.

    Args:
        bags: List of sets of vertex indices.
        vertices: List of vertex indices.
        edges: List of (u, v) edges.

    Returns:
        (is_valid, reason)
    """
    if not bags:
        return False, "Empty bag list"

    # 1. Vertex coverage
    covered = set()
    for bag in bags:
        covered |= bag
    for v in vertices:
        if v not in covered:
            return False, f"Vertex {v} not covered"

    # 2. Edge coverage
    for u, v in edges:
        found = False
        for bag in bags:
            if u in bag and v in bag:
                found = True
                break
        if not found:
            return False, f"Edge ({u}, {v}) not covered"

    # 3. Interval property
    for v in vertices:
        indices = [i for i, bag in enumerate(bags) if v in bag]
        if indices:
            if indices != list(range(indices[0], indices[-1] + 1)):
                return False, f"Vertex {v} violates interval property"

    return True, "Valid"


def pathwidth_of_bags(bags: List[Set]) -> int:
    """Compute the width of a path decomposition (max bag size - 1)."""
    if not bags:
        return 0
    return max(len(bag) for bag in bags) - 1


def exact_pathwidth_bruteforce(
    n_vertices: int,
    edges: List[Tuple[int, int]],
    max_width: int = None,
) -> int:
    """
    Compute exact pathwidth by trying all possible path decompositions.
    Only feasible for very small graphs (n ≤ 8).

    Uses the vertex ordering approach: try all permutations of vertices,
    build the canonical path decomposition, and find the minimum width.

    Args:
        n_vertices: Number of vertices (labeled 0..n-1).
        edges: List of edges.
        max_width: Upper bound on width to search.

    Returns:
        Exact pathwidth.
    """
    from itertools import permutations

    if n_vertices == 0:
        return 0
    if n_vertices == 1:
        return 0

    if max_width is None:
        max_width = n_vertices - 1

    # Build adjacency list
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    vertices = list(range(n_vertices))

    if n_vertices > 10:
        # Too many permutations; use heuristic
        return _pathwidth_heuristic(n_vertices, edges)

    best_width = n_vertices - 1

    for perm in permutations(vertices):
        # Build path decomposition from elimination ordering
        # At step i, the bag contains vertex perm[i] and all its neighbors
        # that appear later in the ordering
        width = 0
        pos = {v: i for i, v in enumerate(perm)}
        for i, v in enumerate(perm):
            # Bag contains v and all later neighbors
            bag_size = 1 + sum(1 for u in adj[v] if pos[u] > i)
            width = max(width, bag_size)
        width -= 1  # pathwidth convention
        best_width = min(best_width, width)

    return best_width


def _pathwidth_heuristic(n_vertices: int, edges: List[Tuple[int, int]]) -> int:
    """Heuristic upper bound on pathwidth using greedy elimination."""
    adj = defaultdict(set)
    for u, v in edges:
        adj[u].add(v)
        adj[v].add(u)

    remaining = set(range(n_vertices))
    width = 0

    while remaining:
        # Pick vertex with minimum degree among remaining
        v = min(remaining, key=lambda x: len(adj[x] & remaining))
        bag_size = 1 + len(adj[v] & remaining)
        width = max(width, bag_size - 1)
        remaining.remove(v)

    return width


# ============================================================
# Minimum Clause Space
# ============================================================

def min_clause_space(cnf: CNF, max_search_space: int = 8) -> int:
    """
    Compute or estimate the minimum clause space of a CNF formula.
    Tries space bounds from 1 upward until a refutation is found.

    Args:
        cnf: The unsatisfiable CNF formula.
        max_search_space: Maximum space to try.

    Returns:
        Minimum clause space, or -1 if no refutation found.
    """
    for s in range(1, max_search_space + 1):
        trace = find_refutation_trace(cnf, max_space=s)
        if trace is not None:
            return s
    return -1


# ============================================================
# Formula Generators
# ============================================================

def all_clauses_over(variables: List[int], max_width: int = None) -> List[Clause]:
    """Generate all possible clauses over the given variables."""
    if max_width is None:
        max_width = len(variables)

    literals = []
    for v in variables:
        literals.extend([v, -v])

    clauses = []
    for width in range(1, max_width + 1):
        for combo in combinations(literals, width):
            # Check for tautology
            clause = frozenset(combo)
            is_taut = any(-lit in clause for lit in clause)
            if not is_taut:
                clauses.append(clause)
    return clauses


def is_satisfiable(cnf: CNF) -> bool:
    """Check satisfiability by brute-force truth table."""
    vars_list = sorted(variables_of(cnf))
    if not vars_list:
        return frozenset() not in cnf

    for assignment in product([True, False], repeat=len(vars_list)):
        val = {v: a for v, a in zip(vars_list, assignment)}
        satisfied = True
        for clause in cnf:
            clause_sat = False
            for lit in clause:
                if (lit > 0 and val[abs(lit)]) or (lit < 0 and not val[abs(lit)]):
                    clause_sat = True
                    break
            if not clause_sat:
                satisfied = False
                break
        if satisfied:
            return True
    return False


def enumerate_unsat_cnfs(n_vars: int, max_clause_width: int = None) -> List[CNF]:
    """
    Enumerate all unsatisfiable CNF formulas over n variables.

    Args:
        n_vars: Number of variables (1, 2, ..., n_vars).
        max_clause_width: Maximum clause width.

    Returns:
        List of unsatisfiable CNFs (as frozensets of frozensets).
    """
    variables = list(range(1, n_vars + 1))
    all_cls = all_clauses_over(variables, max_clause_width)

    unsat_cnfs = []
    # Enumerate all subsets of clauses
    for size in range(1, len(all_cls) + 1):
        for combo in combinations(all_cls, size):
            cnf = frozenset(combo)
            if not is_satisfiable(cnf):
                unsat_cnfs.append(cnf)

    return unsat_cnfs


if __name__ == "__main__":
    # Example: simple unsatisfiable formula {p, ¬p}
    p, q = 1, 2
    cnf = frozenset([frozenset([p]), frozenset([-p])])
    print(f"Formula: {{{format_clause(c) for c in cnf}}}" if False else f"Formula: {cnf}")
    print(f"Satisfiable: {is_satisfiable(cnf)}")

    space = min_clause_space(cnf)
    print(f"Minimum clause space: {space}")

    trace = find_refutation_trace(cnf, max_space=space)
    if trace:
        print(f"Trace length: {len(trace)}")
        print(f"Clause space of trace: {clause_space_of_trace(trace)}")
