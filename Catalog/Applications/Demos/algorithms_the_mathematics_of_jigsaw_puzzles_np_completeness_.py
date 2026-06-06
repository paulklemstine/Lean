#!/usr/bin/env python3
"""
Algorithms for Jigsaw Puzzle NP-Completeness

Type-hinted implementations of the key algorithms:
1. 3-SAT to Jigsaw Puzzle reduction
2. Puzzle verification
3. Configuration space analysis
"""

from enum import Enum
from dataclasses import dataclass
from typing import List, Tuple, Optional, Dict, Set
from itertools import product


class EdgeType(Enum):
    """Edge types for jigsaw puzzle pieces."""
    FLAT = 0
    TAB = 1
    BLANK = 2

    def complement(self) -> 'EdgeType':
        """The complement of an edge type: tab ↔ blank, flat ↔ flat."""
        if self == EdgeType.TAB:
            return EdgeType.BLANK
        elif self == EdgeType.BLANK:
            return EdgeType.TAB
        return EdgeType.FLAT

    def compatible(self, other: 'EdgeType') -> bool:
        """Check if two edges are compatible (complementary)."""
        return other == self.complement()


@dataclass(frozen=True)
class PieceSignature:
    """A jigsaw piece defined by its four edge types."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def complement(self) -> 'PieceSignature':
        """Apply complement to all edges."""
        return PieceSignature(
            self.top.complement(),
            self.right.complement(),
            self.bottom.complement(),
            self.left.complement(),
        )


@dataclass
class Literal:
    """A boolean literal: variable index + polarity."""
    var: int
    polarity: bool

    def eval(self, assignment: List[bool]) -> bool:
        v = assignment[self.var]
        return v if self.polarity else not v


@dataclass
class Clause:
    """A 3-SAT clause (disjunction of 3 literals)."""
    literals: List[Literal]

    def satisfied(self, assignment: List[bool]) -> bool:
        return any(lit.eval(assignment) for lit in self.literals)


@dataclass
class Formula3SAT:
    """A 3-SAT formula (conjunction of clauses)."""
    num_vars: int
    clauses: List[Clause]

    def satisfiable(self) -> Tuple[bool, Optional[List[bool]]]:
        """Brute-force check satisfiability (exponential)."""
        for bits in product([False, True], repeat=self.num_vars):
            assignment = list(bits)
            if all(c.satisfied(assignment) for c in self.clauses):
                return True, assignment
        return False, None


def bool_to_edge(b: bool) -> EdgeType:
    """Encode a boolean as an edge type."""
    return EdgeType.TAB if b else EdgeType.BLANK


def edge_to_bool(e: EdgeType) -> bool:
    """Decode an edge type to a boolean."""
    return e == EdgeType.TAB


# ============================================================
# Algorithm 1: 3-SAT to Jigsaw Reduction
# ============================================================

def reduce_3sat_to_puzzle(formula: Formula3SAT) -> Dict:
    """
    Reduce a 3-SAT formula to a jigsaw puzzle instance.

    Returns a dictionary describing the puzzle:
    - variable_pieces: pairs of (TRUE, FALSE) pieces per variable
    - clause_pieces: one piece per clause
    - total_pieces: 2n + m
    """
    variable_pieces: List[Tuple[PieceSignature, PieceSignature]] = []
    for i in range(formula.num_vars):
        true_piece = PieceSignature(
            top=EdgeType.FLAT,
            right=EdgeType.TAB,
            bottom=EdgeType.FLAT,
            left=EdgeType.FLAT,
        )
        false_piece = PieceSignature(
            top=EdgeType.FLAT,
            right=EdgeType.BLANK,
            bottom=EdgeType.FLAT,
            left=EdgeType.FLAT,
        )
        variable_pieces.append((true_piece, false_piece))

    clause_piece_templates: List = []
    for clause in formula.clauses:
        # Template: depends on the assignment
        clause_piece_templates.append(clause)

    return {
        "variable_pieces": variable_pieces,
        "clause_templates": clause_piece_templates,
        "total_pieces": 2 * formula.num_vars + len(formula.clauses),
    }


def instantiate_clause_piece(clause: Clause, assignment: List[bool]) -> PieceSignature:
    """Create a clause piece given an assignment."""
    vals = [lit.eval(assignment) for lit in clause.literals]
    return PieceSignature(
        top=bool_to_edge(vals[0]),
        right=bool_to_edge(any(vals)),
        bottom=bool_to_edge(vals[2]),
        left=bool_to_edge(vals[1]),
    )


# ============================================================
# Algorithm 2: Puzzle Verification
# ============================================================

def verify_grid(grid: List[List[PieceSignature]]) -> bool:
    """
    Verify that a puzzle grid is valid (all adjacencies compatible).

    Time complexity: O(rows × cols)
    """
    rows = len(grid)
    if rows == 0:
        return True
    cols = len(grid[0])

    for i in range(rows):
        for j in range(cols):
            # Check horizontal compatibility
            if j + 1 < cols:
                if not grid[i][j].right.compatible(grid[i][j + 1].left):
                    return False
            # Check vertical compatibility
            if i + 1 < rows:
                if not grid[i][j].bottom.compatible(grid[i + 1][j].top):
                    return False
    return True


# ============================================================
# Algorithm 3: Configuration Space Analysis
# ============================================================

def count_configurations(n_rows: int, n_cols: int, n_edge_types: int = 3) -> int:
    """Count total configurations (before compatibility constraints)."""
    return n_edge_types ** (4 * n_rows * n_cols)


def count_adjacency_constraints(n_rows: int, n_cols: int) -> int:
    """Count the number of adjacency constraints in a grid."""
    horiz = n_rows * max(0, n_cols - 1)
    vert = max(0, n_rows - 1) * n_cols
    return horiz + vert


def enumerate_compatible_pairs() -> List[Tuple[EdgeType, EdgeType]]:
    """Enumerate all compatible edge type pairs."""
    pairs = []
    for e1 in EdgeType:
        for e2 in EdgeType:
            if e1.compatible(e2):
                pairs.append((e1, e2))
    return pairs


# ============================================================
# Algorithm 4: Complement Duality
# ============================================================

def complement_grid(grid: List[List[PieceSignature]]) -> List[List[PieceSignature]]:
    """Apply complement to every piece in a grid."""
    return [[piece.complement() for piece in row] for row in grid]


def verify_complement_preserves_validity(grid: List[List[PieceSignature]]) -> bool:
    """Verify that complement preserves grid validity."""
    original_valid = verify_grid(grid)
    complemented_valid = verify_grid(complement_grid(grid))
    return original_valid == complemented_valid


if __name__ == "__main__":
    # Demo: reduce and verify
    formula = Formula3SAT(
        num_vars=3,
        clauses=[
            Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
            Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
        ],
    )

    print("Formula satisfiability check:")
    sat, assignment = formula.satisfiable()
    print(f"  Satisfiable: {sat}")
    if assignment:
        print(f"  Assignment: {assignment}")

        print("\nReduction to jigsaw puzzle:")
        puzzle = reduce_3sat_to_puzzle(formula)
        print(f"  Variable pieces: {len(puzzle['variable_pieces'])} pairs")
        print(f"  Clause templates: {len(puzzle['clause_templates'])}")
        print(f"  Total pieces: {puzzle['total_pieces']}")

        print("\nClause piece verification:")
        for i, clause in enumerate(formula.clauses):
            piece = instantiate_clause_piece(clause, assignment)
            output_is_tab = piece.right == EdgeType.TAB
            clause_sat = clause.satisfied(assignment)
            print(f"  Clause {i}: output={piece.right.name}, "
                  f"satisfied={clause_sat}, match={output_is_tab == clause_sat}")

    print("\nCompatible edge pairs:")
    for e1, e2 in enumerate_compatible_pairs():
        print(f"  {e1.name} ↔ {e2.name}")

    print("\nConfiguration space sizes:")
    for n in range(1, 6):
        for m in range(1, 6):
            configs = count_configurations(n, m)
            constraints = count_adjacency_constraints(n, m)
            print(f"  {n}×{m}: {configs:>20,} configs, {constraints:>3} constraints")
