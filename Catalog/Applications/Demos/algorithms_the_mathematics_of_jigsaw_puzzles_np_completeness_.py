#!/usr/bin/env python3
"""
algorithms.py - Core algorithms for jigsaw puzzle NP-completeness theory.

Implements:
1. SAT-to-Puzzle Reduction
2. Puzzle Assembly Solver (backtracking)
3. Constraint Graph Analysis
4. Random Puzzle Generation
"""

from enum import Enum
from dataclasses import dataclass, field
from typing import List, Tuple, Optional, Set, Dict


# =============================================================================
# Core Types
# =============================================================================

class EdgeType(Enum):
    """Edge type for jigsaw puzzle pieces."""
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"


def complementary(e1: EdgeType, e2: EdgeType) -> bool:
    """Check if two edges are complementary (tab meets blank)."""
    return (e1 == EdgeType.TAB and e2 == EdgeType.BLANK) or \
           (e1 == EdgeType.BLANK and e2 == EdgeType.TAB)


def complement(e: EdgeType) -> EdgeType:
    """Return the complement of an edge type."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    return EdgeType.FLAT


@dataclass(frozen=True)
class JigsawPiece:
    """A jigsaw piece with four edges."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def fits_right(self, other: 'JigsawPiece') -> bool:
        return complementary(self.right, other.left)

    def fits_below(self, other: 'JigsawPiece') -> bool:
        return complementary(self.bottom, other.top)


@dataclass
class Literal:
    """A Boolean literal (variable index + polarity)."""
    var: int
    positive: bool

    def eval(self, assignment: Dict[int, bool]) -> bool:
        val = assignment.get(self.var, False)
        return val if self.positive else not val


@dataclass
class Clause:
    """A disjunctive clause of literals."""
    literals: List[Literal]

    def satisfied(self, assignment: Dict[int, bool]) -> bool:
        return any(lit.eval(assignment) for lit in self.literals)


@dataclass
class CNF:
    """A CNF formula."""
    num_vars: int
    clauses: List[Clause]

    def satisfiable(self) -> Optional[Dict[int, bool]]:
        """Brute-force SAT solver: try all 2^n assignments."""
        for bits in range(2 ** self.num_vars):
            assignment = {i: bool((bits >> i) & 1) for i in range(self.num_vars)}
            if all(c.satisfied(assignment) for c in self.clauses):
                return assignment
        return None


# =============================================================================
# Algorithm 1: SAT-to-Puzzle Reduction
# =============================================================================

def sat_to_puzzle(formula: CNF) -> Tuple[List[JigsawPiece], int, int]:
    """
    Reduce a CNF formula to a jigsaw puzzle instance.

    Given a formula with n variables and m clauses, constructs
    a puzzle with 2n + m pieces arranged in a 1 × (2n + m) grid.

    Returns: (pieces, rows, cols)

    Pseudocode:
        for each variable x_i:
            create TRUE_piece_i with right=TAB
            create FALSE_piece_i with right=BLANK
        for each clause C_j:
            create clause_piece_j with left=BLANK (needs TAB from satisfied literal)
        return all pieces in order
    """
    pieces: List[JigsawPiece] = []
    n = formula.num_vars
    m = len(formula.clauses)

    # Variable gadgets
    for i in range(n):
        left_edge = EdgeType.FLAT if i == 0 else EdgeType.BLANK
        true_piece = JigsawPiece(
            top=EdgeType.FLAT,
            right=EdgeType.TAB,
            bottom=EdgeType.FLAT,
            left=left_edge
        )
        false_piece = JigsawPiece(
            top=EdgeType.FLAT,
            right=EdgeType.BLANK,
            bottom=EdgeType.FLAT,
            left=left_edge if i == 0 else EdgeType.TAB
        )
        pieces.extend([true_piece, false_piece])

    # Clause gadgets
    for j in range(m):
        clause_piece = JigsawPiece(
            top=EdgeType.FLAT,
            right=EdgeType.FLAT if j == m - 1 else EdgeType.TAB,
            bottom=EdgeType.FLAT,
            left=EdgeType.BLANK
        )
        pieces.append(clause_piece)

    rows = 1
    cols = 2 * n + m
    return pieces, rows, cols


# =============================================================================
# Algorithm 2: Puzzle Assembly Solver (Backtracking)
# =============================================================================

def solve_puzzle(
    pieces: List[JigsawPiece],
    rows: int,
    cols: int
) -> Optional[List[List[JigsawPiece]]]:
    """
    Solve a jigsaw puzzle by backtracking.

    Pseudocode:
        grid = empty r×c array
        used = empty set
        def backtrack(pos):
            if pos == r*c: return True  # all placed
            i, j = pos // c, pos % c
            for piece_idx in unused pieces:
                if fits(piece, i, j, grid):
                    place piece
                    if backtrack(pos + 1): return True
                    remove piece
            return False
        return backtrack(0)
    """
    grid: List[List[Optional[JigsawPiece]]] = [
        [None] * cols for _ in range(rows)
    ]
    used: Set[int] = set()

    def fits_at(piece: JigsawPiece, r: int, c: int) -> bool:
        # Check left neighbor
        if c > 0 and grid[r][c - 1] is not None:
            if not grid[r][c - 1].fits_right(piece):
                return False
        # Check top neighbor
        if r > 0 and grid[r - 1][c] is not None:
            if not grid[r - 1][c].fits_below(piece):
                return False
        return True

    def backtrack(pos: int) -> bool:
        if pos == rows * cols:
            return True
        r, c = divmod(pos, cols)
        for idx, piece in enumerate(pieces):
            if idx not in used and fits_at(piece, r, c):
                grid[r][c] = piece
                used.add(idx)
                if backtrack(pos + 1):
                    return True
                grid[r][c] = None
                used.discard(idx)
        return False

    if backtrack(0):
        return grid
    return None


# =============================================================================
# Algorithm 3: Constraint Graph Analysis
# =============================================================================

def constraint_graph_stats(rows: int, cols: int) -> Dict[str, int]:
    """
    Compute statistics of the constraint graph for an r×c grid.

    Pseudocode:
        V = r * c
        E_horiz = r * (c - 1)
        E_vert = (r - 1) * c
        E = E_horiz + E_vert
        cycles = (r - 1) * (c - 1)
        euler = V - E + 1
        return {V, E, euler, cycles}
    """
    v = rows * cols
    e_horiz = rows * max(0, cols - 1)
    e_vert = max(0, rows - 1) * cols
    e_total = e_horiz + e_vert
    cycles = max(0, rows - 1) * max(0, cols - 1)
    euler = v - e_total + 1

    return {
        "vertices": v,
        "horizontal_edges": e_horiz,
        "vertical_edges": e_vert,
        "total_edges": e_total,
        "independent_cycles": cycles,
        "euler_characteristic": euler,
    }


# =============================================================================
# Algorithm 4: Random Puzzle Generation
# =============================================================================

def generate_solvable_puzzle(rows: int, cols: int, seed: int = 42) -> List[List[JigsawPiece]]:
    """
    Generate a random solvable puzzle by constructing it row by row.

    Pseudocode:
        for each cell (i, j):
            top = complement(grid[i-1][j].bottom) if i > 0 else FLAT
            left = complement(grid[i][j-1].right) if j > 0 else FLAT
            right = random(TAB, BLANK) if j < cols-1 else FLAT
            bottom = random(TAB, BLANK) if i < rows-1 else FLAT
            grid[i][j] = Piece(top, right, bottom, left)
    """
    import random
    rng = random.Random(seed)

    grid: List[List[JigsawPiece]] = []
    for i in range(rows):
        row: List[JigsawPiece] = []
        for j in range(cols):
            # Top edge
            if i == 0:
                top = EdgeType.FLAT
            else:
                top = complement(grid[i - 1][j].bottom)

            # Left edge
            if j == 0:
                left = EdgeType.FLAT
            else:
                left = complement(row[j - 1].right)

            # Right edge
            if j == cols - 1:
                right = EdgeType.FLAT
            else:
                right = rng.choice([EdgeType.TAB, EdgeType.BLANK])

            # Bottom edge
            if i == rows - 1:
                bottom = EdgeType.FLAT
            else:
                bottom = rng.choice([EdgeType.TAB, EdgeType.BLANK])

            row.append(JigsawPiece(top, right, bottom, left))
        grid.append(row)
    return grid


# =============================================================================
# Main: Run all algorithms
# =============================================================================

if __name__ == "__main__":
    # Test SAT-to-Puzzle reduction
    formula = CNF(
        num_vars=3,
        clauses=[
            Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
            Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
        ]
    )

    print("SAT-to-Puzzle Reduction")
    print(f"  Formula: 3 vars, 2 clauses")
    pieces, rows, cols = sat_to_puzzle(formula)
    print(f"  Puzzle: {rows}×{cols} grid, {len(pieces)} pieces")

    # Solve the formula directly
    sat_result = formula.satisfiable()
    print(f"  Formula satisfiable: {sat_result is not None}")
    if sat_result:
        print(f"  Satisfying assignment: {sat_result}")

    # Constraint graph analysis
    print("\nConstraint Graph Analysis")
    for r, c in [(1, 5), (3, 3), (5, 5), (10, 10)]:
        stats = constraint_graph_stats(r, c)
        print(f"  {r}×{c}: V={stats['vertices']}, E={stats['total_edges']}, "
              f"χ={stats['euler_characteristic']}, cycles={stats['independent_cycles']}")

    # Generate a solvable puzzle
    print("\nRandom Solvable Puzzle (3×3)")
    grid = generate_solvable_puzzle(3, 3)
    for i, row in enumerate(grid):
        for j, p in enumerate(row):
            print(f"  ({i},{j}): ({p.top.value}, {p.right.value}, {p.bottom.value}, {p.left.value})")

    # Verify it's valid
    valid = True
    for i in range(3):
        for j in range(3):
            if j < 2 and not grid[i][j].fits_right(grid[i][j + 1]):
                valid = False
            if i < 2 and not grid[i][j].fits_below(grid[i + 1][j]):
                valid = False
    print(f"  Valid assembly: {valid}")
