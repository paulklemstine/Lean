#!/usr/bin/env python3
"""
Algorithms for Jigsaw Puzzle Assembly and SAT Reduction

Type-hinted implementations of the core algorithms from the formalization.
"""

from enum import Enum
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Dict, Set
from itertools import product as iterproduct


# --- Core Types ---

class EdgeType(Enum):
    FLAT = 0
    TAB = 1
    BLANK = 2


def complement(e: EdgeType) -> EdgeType:
    """O(1) complement involution."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    return EdgeType.FLAT


def compatible(e1: EdgeType, e2: EdgeType) -> bool:
    """O(1) compatibility check."""
    return complement(e1) == e2


def bool_to_edge(b: bool) -> EdgeType:
    """O(1) boolean-to-edge encoding."""
    return EdgeType.TAB if b else EdgeType.BLANK


@dataclass(frozen=True)
class Piece:
    """A jigsaw piece with four directional edges."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType


# --- Grid Assembly ---

Grid = List[List[Optional[Piece]]]


def make_grid(rows: int, cols: int) -> Grid:
    """Create empty grid."""
    return [[None for _ in range(cols)] for _ in range(rows)]


def is_valid_placement(grid: Grid, rows: int, cols: int) -> bool:
    """
    Check if a grid placement is valid.

    Algorithm: Check all horizontal and vertical adjacencies.
    Time: O(rows * cols)
    Space: O(1)
    """
    for i in range(rows):
        for j in range(cols):
            if grid[i][j] is None:
                continue
            # Check right neighbor
            if j + 1 < cols and grid[i][j + 1] is not None:
                if not compatible(grid[i][j].right, grid[i][j + 1].left):
                    return False
            # Check bottom neighbor
            if i + 1 < rows and grid[i + 1][j] is not None:
                if not compatible(grid[i][j].bottom, grid[i + 1][j].top):
                    return False
    return True


# --- Topological Invariants ---

def internal_edges(m: int, n: int) -> int:
    """Number of internal edges in an m×n grid. O(1)."""
    return m * (n - 1) + (m - 1) * n


def betti1(m: int, n: int) -> int:
    """First Betti number of the m×n grid graph. O(1)."""
    return (m - 1) * (n - 1)


def euler_characteristic(m: int, n: int) -> int:
    """Euler characteristic V - E + F for the m×n grid. O(1)."""
    V = m * n
    E = internal_edges(m, n)
    F = betti1(m, n) + 1
    return V - E + F  # Always equals 2 for m, n >= 1


def constraint_variable_gap(m: int, n: int) -> int:
    """Gap between 2*V and E. Equals m + n for m, n >= 1. O(1)."""
    return 2 * m * n - internal_edges(m, n)


# --- SAT Reduction ---

@dataclass
class Literal:
    """A literal: variable index + polarity."""
    var: int
    positive: bool

    def eval(self, assignment: List[bool]) -> bool:
        val = assignment[self.var]
        return val if self.positive else not val


@dataclass
class Clause:
    """A clause: disjunction of literals."""
    literals: List[Literal]

    def satisfied(self, assignment: List[bool]) -> bool:
        return any(lit.eval(assignment) for lit in self.literals)


@dataclass
class SAT3Formula:
    """A 3-CNF formula."""
    num_vars: int
    clauses: List[Clause]

    def is_satisfied(self, assignment: List[bool]) -> bool:
        return all(c.satisfied(assignment) for c in self.clauses)

    def is_satisfiable(self) -> Tuple[bool, Optional[List[bool]]]:
        """
        Brute-force SAT solver.

        Algorithm: Enumerate all 2^n assignments.
        Time: O(2^n * m * k) where n = num_vars, m = num_clauses, k = literals/clause
        Space: O(n)
        """
        for bits in iterproduct([False, True], repeat=self.num_vars):
            assignment = list(bits)
            if self.is_satisfied(assignment):
                return True, assignment
        return False, None


def sat_to_puzzle_encoding(
    formula: SAT3Formula,
    assignment: List[bool]
) -> List[List[EdgeType]]:
    """
    Encode a SAT assignment as puzzle edge types.

    For each clause j and literal position k, output the edge type
    corresponding to whether that literal is satisfied.

    Time: O(m * k)

    Returns: List of clauses, each a list of EdgeType values.
    """
    encoding: List[List[EdgeType]] = []
    for clause in formula.clauses:
        clause_encoding: List[EdgeType] = []
        for lit in clause.literals:
            val = lit.eval(assignment)
            clause_encoding.append(bool_to_edge(val))
        encoding.append(clause_encoding)
    return encoding


def verify_reduction(formula: SAT3Formula, assignment: List[bool]) -> bool:
    """
    Verify the reduction: check that every clause has at least one tab.

    This is equivalent to checking that the assignment satisfies the formula
    (by the reduction correctness theorem).

    Time: O(m * k)
    """
    encoding = sat_to_puzzle_encoding(formula, assignment)
    return all(
        any(e == EdgeType.TAB for e in clause_enc)
        for clause_enc in encoding
    )


def reduction_piece_count(num_vars: int, num_clauses: int) -> int:
    """Piece count in the SAT-to-puzzle reduction. O(1)."""
    return 2 * num_vars + num_clauses


# --- Path Assembly ---

def enumerate_valid_path_assemblies(n: int) -> List[List[bool]]:
    """
    Enumerate all valid alternating assignments for a 1×n path.

    By the path assembly uniqueness theorem, there are exactly 2
    valid assignments (for n >= 1): one starting with True, one with False.

    Time: O(n)
    """
    if n == 0:
        return [[]]
    result: List[List[bool]] = []
    for start in [True, False]:
        path = [start]
        for i in range(1, n):
            path.append(not path[-1])
        result.append(path)
    return result


# --- Transfer Matrix (preview for future direction) ---

def transfer_matrix_2xn(n: int) -> int:
    """
    Count valid 2×n assemblies using binary edge types (tab/blank).

    Uses the transfer matrix method: each column state is a pair of
    edge types (top-right, bottom-right), and the transfer matrix
    encodes compatibility with the next column.

    Time: O(4 * n) = O(n)  (matrix is 4×4 for 2 binary edge types)
    """
    # States: (top_edge, bottom_edge) where each is True/False
    # A state s1 can transition to s2 if:
    #   - top(s1) is compatible with top(s2) horizontally
    #   - bottom(s1) is compatible with bottom(s2) horizontally
    #   - Within column, top and bottom are compatible vertically

    states = list(iterproduct([True, False], repeat=2))
    state_count = len(states)

    # Build transition matrix
    T = [[0] * state_count for _ in range(state_count)]
    for i, s1 in enumerate(states):
        for j, s2 in enumerate(states):
            # Horizontal compatibility
            h_top = compatible(bool_to_edge(s1[0]), bool_to_edge(s2[0]))
            h_bot = compatible(bool_to_edge(s1[1]), bool_to_edge(s2[1]))
            # Vertical compatibility within s2
            v_ok = compatible(bool_to_edge(s2[0]), bool_to_edge(s2[1]))
            if h_top and h_bot and v_ok:
                T[i][j] = 1

    if n <= 0:
        return 0
    if n == 1:
        # Count states with valid vertical compatibility
        return sum(1 for s in states
                   if compatible(bool_to_edge(s[0]), bool_to_edge(s[1])))

    # Matrix power T^(n-1)
    # Start with states that have valid vertical compatibility
    vec = [1 if compatible(bool_to_edge(s[0]), bool_to_edge(s[1]))
           else 0 for s in states]

    for _ in range(n - 1):
        new_vec = [0] * state_count
        for j in range(state_count):
            for i in range(state_count):
                new_vec[j] += vec[i] * T[i][j]
        vec = new_vec

    return sum(vec)


if __name__ == "__main__":
    # Quick test
    formula = SAT3Formula(
        num_vars=3,
        clauses=[
            Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
            Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
        ]
    )

    is_sat, witness = formula.is_satisfiable()
    print(f"Formula satisfiable: {is_sat}")
    if witness:
        print(f"Witness: {witness}")
        encoding = sat_to_puzzle_encoding(formula, witness)
        print(f"Puzzle encoding: {[[e.name for e in c] for c in encoding]}")
        print(f"Reduction valid: {verify_reduction(formula, witness)}")

    print(f"\nPiece count: {reduction_piece_count(3, 2)}")
    print(f"\nBetti numbers:")
    for m, n in [(2, 2), (3, 3), (5, 5), (10, 10)]:
        print(f"  β₁({m},{n}) = {betti1(m, n)}")

    print(f"\nValid 2×n assembly counts (transfer matrix):")
    for n in range(1, 8):
        count = transfer_matrix_2xn(n)
        print(f"  2×{n}: {count} valid assemblies")
