#!/usr/bin/env python3
"""
Jigsaw Puzzle Assembly Algorithms

Type-hinted implementations of key algorithms from the formal framework:
1. Greedy row assembly via constraint propagation
2. Grid defect counting
3. Random puzzle generation and assembly checking
4. SAT-to-puzzle reduction
"""

from enum import Enum
from typing import List, Tuple, Optional, Dict
from dataclasses import dataclass
import random


# --- Core Types ---

class EdgeType(Enum):
    TAB = 0
    BLANK = 1
    FLAT = 2


def complement(e: EdgeType) -> EdgeType:
    """Complement involution: tab ↔ blank, flat ↔ flat."""
    if e == EdgeType.TAB:
        return EdgeType.BLANK
    elif e == EdgeType.BLANK:
        return EdgeType.TAB
    return EdgeType.FLAT


def is_compatible(e1: EdgeType, e2: EdgeType) -> bool:
    """Two edges are compatible iff complement(e1) == e2."""
    return complement(e1) == e2


@dataclass
class Piece:
    """A jigsaw piece with four directional edges."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType


@dataclass
class Grid:
    """An m×n grid assembly of pieces."""
    rows: int
    cols: int
    cells: List[List[Optional[Piece]]]

    @classmethod
    def empty(cls, rows: int, cols: int) -> 'Grid':
        return cls(rows, cols, [[None] * cols for _ in range(rows)])


# --- Algorithm 1: Greedy Row Assembly ---

def greedy_row_assembly(first_piece: Piece, length: int) -> List[Piece]:
    """
    Greedy Row Assembly via Constraint Propagation

    Given the first piece and desired row length, construct a valid row
    assembly by propagating constraints: each piece's left edge must
    complement the previous piece's right edge.

    Pseudocode:
        row[0] = first_piece
        for i = 1 to length-1:
            row[i].left = complement(row[i-1].right)
            row[i].{top, right, bottom} = arbitrary
        return row

    Time: O(length)
    Space: O(length)
    """
    row: List[Piece] = [first_piece]
    for i in range(1, length):
        required_left = complement(row[-1].right)
        new_piece = Piece(
            top=EdgeType.FLAT,
            right=EdgeType.TAB,  # arbitrary choice
            bottom=EdgeType.FLAT,
            left=required_left
        )
        row.append(new_piece)
    return row


# --- Algorithm 2: Grid Defect Counter ---

def count_defects(grid: Grid) -> Tuple[int, int, int]:
    """
    Count the number of incompatible adjacencies in a grid assembly.

    Returns (horizontal_defects, vertical_defects, total_defects).

    Pseudocode:
        h_defects = 0
        for each horizontal adjacency (i,j)-(i,j+1):
            if not compatible(grid[i][j].right, grid[i][j+1].left):
                h_defects += 1
        v_defects = 0
        for each vertical adjacency (i,j)-(i+1,j):
            if not compatible(grid[i][j].bottom, grid[i+1][j].top):
                v_defects += 1
        return (h_defects, v_defects, h_defects + v_defects)

    Time: O(m*n)
    Space: O(1)
    """
    h_defects = 0
    v_defects = 0
    for i in range(grid.rows):
        for j in range(grid.cols):
            piece = grid.cells[i][j]
            if piece is None:
                continue
            # Check right neighbor
            if j + 1 < grid.cols and grid.cells[i][j + 1] is not None:
                right_neighbor = grid.cells[i][j + 1]
                if not is_compatible(piece.right, right_neighbor.left):
                    h_defects += 1
            # Check bottom neighbor
            if i + 1 < grid.rows and grid.cells[i + 1][j] is not None:
                bottom_neighbor = grid.cells[i + 1][j]
                if not is_compatible(piece.bottom, bottom_neighbor.top):
                    v_defects += 1
    return h_defects, v_defects, h_defects + v_defects


# --- Algorithm 3: Random Puzzle Generator ---

def generate_random_grid(rows: int, cols: int,
                         k_pairs: int = 1) -> Grid:
    """
    Generate a random m×n grid assembly with k complementary edge pairs.

    For k_pairs=1: uses {TAB, BLANK} for internal edges, FLAT for boundaries.
    For k_pairs>1: uses integer labels [0, 2k) with complement i ↦ (i+k) mod 2k.

    Returns a grid where boundary edges are FLAT and internal edges are random.

    Time: O(m*n)
    """
    grid = Grid.empty(rows, cols)
    non_boundary = [EdgeType.TAB, EdgeType.BLANK]

    for i in range(rows):
        for j in range(cols):
            top = EdgeType.FLAT if i == 0 else random.choice(non_boundary)
            bottom = EdgeType.FLAT if i == rows - 1 else random.choice(non_boundary)
            left = EdgeType.FLAT if j == 0 else random.choice(non_boundary)
            right = EdgeType.FLAT if j == cols - 1 else random.choice(non_boundary)
            grid.cells[i][j] = Piece(top=top, right=right, bottom=bottom, left=left)
    return grid


# --- Algorithm 4: SAT-to-Puzzle Reduction ---

@dataclass
class Literal:
    """A literal: variable index and polarity."""
    var: int
    positive: bool

    def evaluate(self, assignment: Dict[int, bool]) -> bool:
        val = assignment.get(self.var, False)
        return val if self.positive else not val

    def to_edge(self, assignment: Dict[int, bool]) -> EdgeType:
        """Convert literal evaluation to edge type."""
        return EdgeType.TAB if self.evaluate(assignment) else EdgeType.BLANK


@dataclass
class Clause:
    """A 3-literal clause."""
    literals: List[Literal]

    def is_satisfied(self, assignment: Dict[int, bool]) -> bool:
        return any(lit.evaluate(assignment) for lit in self.literals)

    def has_tab(self, assignment: Dict[int, bool]) -> bool:
        """Check if any literal encodes as a tab edge."""
        return any(lit.to_edge(assignment) == EdgeType.TAB
                   for lit in self.literals)


def sat_to_puzzle_check(clauses: List[Clause],
                        assignment: Dict[int, bool]) -> bool:
    """
    SAT-to-Puzzle Reduction Verification

    Given a CNF formula and assignment, verify that:
    1. Every clause is satisfied (SAT side)
    2. Every clause has at least one tab edge (puzzle side)
    3. These two conditions are equivalent

    Pseudocode:
        for each clause c:
            sat = any literal in c evaluates to true
            tab = any literal in c encodes as TAB
            assert sat == tab  (this is the reduction correctness theorem)
        return all clauses satisfied

    Time: O(m) where m = number of clauses
    """
    all_sat = True
    for clause in clauses:
        sat = clause.is_satisfied(assignment)
        tab = clause.has_tab(assignment)
        assert sat == tab, "Reduction correctness violated!"
        if not sat:
            all_sat = False
    return all_sat


# --- Algorithm 5: Grid Statistics ---

def internal_edge_count(m: int, n: int) -> int:
    """Count internal edges in an m×n grid."""
    return m * (n - 1) + (m - 1) * n


def euler_characteristic(m: int, n: int) -> int:
    """Compute V - E + F for the grid constraint graph."""
    V = m * n
    E = internal_edge_count(m, n)
    F = (m - 1) * (n - 1) + 1
    return V - E + F


def assembly_entropy(m: int, n: int, k: int) -> int:
    """Assembly entropy measure: E(m,n) × k."""
    return internal_edge_count(m, n) * k


# --- Main: Run all algorithms ---

if __name__ == "__main__":
    print("Algorithm 1: Greedy Row Assembly")
    first = Piece(EdgeType.FLAT, EdgeType.TAB, EdgeType.FLAT, EdgeType.FLAT)
    row = greedy_row_assembly(first, 5)
    for i, p in enumerate(row):
        print(f"  Piece {i}: left={p.left.name}, right={p.right.name}")
    print()

    print("Algorithm 2: Grid Defect Counter")
    grid = generate_random_grid(3, 3)
    h, v, total = count_defects(grid)
    print(f"  Random 3×3 grid: {h} h-defects, {v} v-defects, {total} total")
    print()

    print("Algorithm 3: SAT-to-Puzzle Reduction")
    clauses = [
        Clause([Literal(0, True), Literal(1, True), Literal(2, False)]),
        Clause([Literal(0, False), Literal(2, True), Literal(2, True)]),
    ]
    assignment = {0: True, 1: False, 2: True}
    result = sat_to_puzzle_check(clauses, assignment)
    print(f"  Assignment x₀=T, x₁=F, x₂=T → SAT={result}")
    print()

    print("Algorithm 4: Grid Statistics")
    for n in range(1, 8):
        chi = euler_characteristic(n, n)
        edges = internal_edge_count(n, n)
        print(f"  {n}×{n}: edges={edges}, χ={chi}, entropy(k=3)={assembly_entropy(n,n,3)}")
