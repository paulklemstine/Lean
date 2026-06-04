#!/usr/bin/env python3
"""
algorithms.py — Jigsaw Puzzle Assembly Algorithms

Type-hinted implementations of key algorithms:
1. Complement propagation (1-D assembly)
2. SAT-to-puzzle reduction
3. Grid Betti number computation
4. Constraint graph analysis
"""

from typing import List, Tuple, Optional, Dict, Set
from enum import Enum
from dataclasses import dataclass


class EdgeType(Enum):
    """Edge types for jigsaw pieces."""
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"


def complement(e: EdgeType) -> EdgeType:
    """Complement involution: tab ↔ blank, flat ↔ flat."""
    match e:
        case EdgeType.TAB:
            return EdgeType.BLANK
        case EdgeType.BLANK:
            return EdgeType.TAB
        case EdgeType.FLAT:
            return EdgeType.FLAT


@dataclass
class Piece:
    """A jigsaw piece with four directional edges."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType


@dataclass
class Literal:
    """A SAT literal: variable index and polarity."""
    var: int
    positive: bool


@dataclass
class Clause:
    """A 3-SAT clause: disjunction of exactly 3 literals."""
    literals: List[Literal]

    def __post_init__(self) -> None:
        assert len(self.literals) == 3


@dataclass
class Formula:
    """A 3-CNF formula."""
    num_vars: int
    clauses: List[Clause]


# ============================================================
# Algorithm 1: Complement Propagation
# ============================================================

def propagate_row(pieces: List[Piece]) -> bool:
    """
    Check if a row of pieces forms a valid assembly.
    Uses complement propagation: O(n) time.

    Returns True if all horizontal adjacencies are compatible.
    """
    for i in range(len(pieces) - 1):
        if complement(pieces[i].right) != pieces[i + 1].left:
            return False
    return True


def determine_left_edges(right_edges: List[EdgeType], first_left: EdgeType) -> List[EdgeType]:
    """
    Given a sequence of right edges and the first left edge,
    determine all left edges by complement propagation.

    This implements the Spanning Tree Propagation theorem:
    left[i+1] = complement(right[i]).
    """
    lefts = [first_left]
    for r in right_edges[:-1]:
        lefts.append(complement(r))
    return lefts


# ============================================================
# Algorithm 2: SAT-to-Puzzle Reduction
# ============================================================

def bool_to_edge(b: bool) -> EdgeType:
    """Encode a Boolean as an edge: True → tab, False → blank."""
    return EdgeType.TAB if b else EdgeType.BLANK


def evaluate_literal(assignment: List[bool], lit: Literal) -> bool:
    """Evaluate a literal under an assignment."""
    val = assignment[lit.var]
    return val if lit.positive else not val


def literal_edge(assignment: List[bool], lit: Literal) -> EdgeType:
    """Compute the edge encoding of a literal under an assignment."""
    return bool_to_edge(evaluate_literal(assignment, lit))


def check_satisfaction(formula: Formula, assignment: List[bool]) -> bool:
    """
    Check if an assignment satisfies a formula.
    Equivalent to checking if each clause has at least one tab edge.
    """
    for clause in formula.clauses:
        if not any(evaluate_literal(assignment, lit) for lit in clause.literals):
            return False
    return True


def sat_to_puzzle_edges(
    formula: Formula, assignment: List[bool]
) -> List[List[EdgeType]]:
    """
    Convert a SAT assignment to puzzle edge configuration.

    Returns a list of edge lists, one per clause.
    Each clause's edges are the literal edge encodings.
    The formula is satisfied iff each clause list contains at least one TAB.
    """
    result: List[List[EdgeType]] = []
    for clause in formula.clauses:
        edges = [literal_edge(assignment, lit) for lit in clause.literals]
        result.append(edges)
    return result


def find_all_satisfying(formula: Formula) -> List[List[bool]]:
    """Brute-force find all satisfying assignments."""
    solutions: List[List[bool]] = []
    for bits in range(2 ** formula.num_vars):
        assignment = [(bits >> i) & 1 == 1 for i in range(formula.num_vars)]
        if check_satisfaction(formula, assignment):
            solutions.append(assignment)
    return solutions


# ============================================================
# Algorithm 3: Grid Betti Number
# ============================================================

def grid_internal_edges(m: int, n: int) -> int:
    """Number of internal edges in an m×n grid."""
    return m * (n - 1) + (m - 1) * n


def grid_betti1(m: int, n: int) -> int:
    """First Betti number of the m×n grid graph."""
    return (m - 1) * (n - 1)


def verify_euler_poincare(m: int, n: int) -> bool:
    """Verify E + 1 = V + β₁ for an m×n grid."""
    E = grid_internal_edges(m, n)
    V = m * n
    beta = grid_betti1(m, n)
    return E + 1 == V + beta


def constraint_density(m: int, n: int) -> float:
    """Constraint density E/V for an m×n grid."""
    V = m * n
    if V == 0:
        return 0.0
    return grid_internal_edges(m, n) / V


# ============================================================
# Algorithm 4: Constraint Graph Analysis
# ============================================================

def grid_constraint_graph(m: int, n: int) -> Dict[Tuple[int, int], List[Tuple[int, int]]]:
    """
    Build the adjacency list of the constraint graph for an m×n grid.
    Vertices are (i, j) cells; edges connect adjacent cells.
    """
    graph: Dict[Tuple[int, int], List[Tuple[int, int]]] = {}
    for i in range(m):
        for j in range(n):
            neighbors: List[Tuple[int, int]] = []
            if j + 1 < n:
                neighbors.append((i, j + 1))
            if j - 1 >= 0:
                neighbors.append((i, j - 1))
            if i + 1 < m:
                neighbors.append((i + 1, j))
            if i - 1 >= 0:
                neighbors.append((i - 1, j))
            graph[(i, j)] = neighbors
    return graph


def find_spanning_tree(
    graph: Dict[Tuple[int, int], List[Tuple[int, int]]]
) -> Set[Tuple[Tuple[int, int], Tuple[int, int]]]:
    """Find a spanning tree of the constraint graph using BFS."""
    if not graph:
        return set()

    start = next(iter(graph))
    visited: Set[Tuple[int, int]] = {start}
    tree_edges: Set[Tuple[Tuple[int, int], Tuple[int, int]]] = set()
    queue = [start]

    while queue:
        v = queue.pop(0)
        for u in graph[v]:
            if u not in visited:
                visited.add(u)
                tree_edges.add((min(v, u), max(v, u)))
                queue.append(u)

    return tree_edges


def count_independent_cycles(m: int, n: int) -> int:
    """
    Count independent cycles = E - V + 1 = β₁.
    Verified against the closed-form formula.
    """
    graph = grid_constraint_graph(m, n)
    tree = find_spanning_tree(graph)
    total_edges = grid_internal_edges(m, n)
    tree_edges = len(tree)
    cycles = total_edges - tree_edges
    assert cycles == grid_betti1(m, n), f"Cycle count mismatch: {cycles} vs {grid_betti1(m, n)}"
    return cycles


# ============================================================
# Algorithm 5: Involution Analysis
# ============================================================

def involution_orbits(elements: List, involution) -> Tuple[List, List[Tuple]]:
    """
    Decompose a finite set under an involution into fixed points and free orbits.
    Returns (fixed_points, free_orbits) where each free orbit is a pair.
    """
    fixed: List = []
    free_orbits: List[Tuple] = []
    seen: Set = set()

    for e in elements:
        if id(e) in seen:
            continue
        c = involution(e)
        if c == e:
            fixed.append(e)
        else:
            free_orbits.append((e, c))
            seen.add(id(e))
            seen.add(id(c))

    return fixed, free_orbits


# ============================================================
# Main Demo
# ============================================================

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # 1. Complement propagation
    print("1. Complement Propagation:")
    right_edges = [EdgeType.TAB, EdgeType.BLANK, EdgeType.TAB]
    left_edges = determine_left_edges(right_edges, EdgeType.FLAT)
    print(f"   Right edges: {[e.value for e in right_edges]}")
    print(f"   Left edges:  {[e.value for e in left_edges]}")

    # 2. SAT reduction
    print("\n2. SAT-to-Puzzle Reduction:")
    formula = Formula(
        num_vars=3,
        clauses=[
            Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
            Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
        ]
    )
    solutions = find_all_satisfying(formula)
    print(f"   Formula: (x₀ ∨ x₁ ∨ ¬x₂) ∧ (¬x₀ ∨ x₂ ∨ x₂)")
    print(f"   Satisfying assignments: {len(solutions)}")
    for sol in solutions:
        edges = sat_to_puzzle_edges(formula, sol)
        print(f"   {sol} → edges: {[[e.value for e in c] for c in edges]}")

    # 3. Betti numbers
    print("\n3. Betti Numbers:")
    for m, n in [(1, 10), (3, 3), (10, 10)]:
        assert verify_euler_poincare(m, n)
        print(f"   {m}×{n}: β₁ = {grid_betti1(m, n)}, density = {constraint_density(m, n):.3f}")

    # 4. Independent cycles
    print("\n4. Independent Cycle Count (via spanning tree):")
    for m, n in [(2, 2), (3, 3), (5, 5)]:
        cycles = count_independent_cycles(m, n)
        print(f"   {m}×{n}: {cycles} independent cycles")

    # 5. Involution orbits
    print("\n5. Involution Orbit Decomposition:")
    fixed, free = involution_orbits(list(EdgeType), complement)
    print(f"   Fixed points: {[e.value for e in fixed]}")
    print(f"   Free orbits:  {[(a.value, b.value) for a, b in free]}")
    print(f"   Parity: |S| mod 2 = {len(EdgeType.__members__) % 2} = |Fix| mod 2 = {len(fixed) % 2} ✓")

    print("\nAll algorithms verified ✓")
