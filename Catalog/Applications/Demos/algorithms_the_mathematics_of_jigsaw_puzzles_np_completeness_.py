"""
algorithms.py — Type-hinted implementations of jigsaw puzzle algorithms.

Implements the core structures and algorithms for:
1. Jigsaw puzzle representation and assembly validation
2. 3-SAT to Jigsaw Puzzle reduction
3. Puzzle homomorphisms and complement duality
4. Row signature constraint propagation
"""

from enum import Enum
from typing import List, Tuple, Optional, Callable, Dict, Set
from dataclasses import dataclass, field


# ── Core Types ──────────────────────────────────────────────

class EdgeType(Enum):
    """Edge types for jigsaw puzzle pieces."""
    TAB = "tab"
    BLANK = "blank"
    FLAT = "flat"

    def complement(self) -> 'EdgeType':
        """The complement involution: tab ↔ blank, flat ↦ flat."""
        if self == EdgeType.TAB:
            return EdgeType.BLANK
        elif self == EdgeType.BLANK:
            return EdgeType.TAB
        return EdgeType.FLAT

    def is_complementary(self, other: 'EdgeType') -> bool:
        """Two edges are complementary iff tab meets blank."""
        return (self == EdgeType.TAB and other == EdgeType.BLANK) or \
               (self == EdgeType.BLANK and other == EdgeType.TAB)


@dataclass(frozen=True)
class JigsawPiece:
    """A jigsaw piece with four directed edges."""
    top: EdgeType
    right: EdgeType
    bottom: EdgeType
    left: EdgeType

    def fits_horizontal(self, other: 'JigsawPiece') -> bool:
        """Can self be placed to the left of other?"""
        return self.right.is_complementary(other.left)

    def fits_vertical(self, other: 'JigsawPiece') -> bool:
        """Can self be placed above other?"""
        return self.bottom.is_complementary(other.top)

    def dual(self) -> 'JigsawPiece':
        """Complement all edges (the dual piece)."""
        return JigsawPiece(
            self.top.complement(),
            self.right.complement(),
            self.bottom.complement(),
            self.left.complement()
        )

    def signature(self) -> Tuple[EdgeType, EdgeType, EdgeType, EdgeType]:
        return (self.top, self.right, self.bottom, self.left)


# ── Puzzle Grid ─────────────────────────────────────────────

@dataclass
class PuzzleGrid:
    """A rectangular grid of jigsaw pieces."""
    rows: int
    cols: int
    pieces: List[List[JigsawPiece]]

    def is_valid_assembly(self) -> bool:
        """Check if all adjacencies are compatible."""
        # Horizontal check
        for i in range(self.rows):
            for j in range(self.cols - 1):
                if not self.pieces[i][j].fits_horizontal(self.pieces[i][j + 1]):
                    return False
        # Vertical check
        for i in range(self.rows - 1):
            for j in range(self.cols):
                if not self.pieces[i][j].fits_vertical(self.pieces[i + 1][j]):
                    return False
        return True

    def dual(self) -> 'PuzzleGrid':
        """Apply complement duality to entire grid."""
        return PuzzleGrid(
            self.rows, self.cols,
            [[p.dual() for p in row] for row in self.pieces]
        )


# ── Row Signatures ──────────────────────────────────────────

RowSignature = Tuple[EdgeType, ...]


def row_bottom_signature(grid: PuzzleGrid, row: int) -> RowSignature:
    """Extract the bottom-edge signature of a row."""
    return tuple(grid.pieces[row][j].bottom for j in range(grid.cols))


def row_top_signature(grid: PuzzleGrid, row: int) -> RowSignature:
    """Extract the top-edge signature of a row."""
    return tuple(grid.pieces[row][j].top for j in range(grid.cols))


def complement_signature(sig: RowSignature) -> RowSignature:
    """Pointwise complement of a row signature."""
    return tuple(e.complement() for e in sig)


def signatures_compatible(s1: RowSignature, s2: RowSignature) -> bool:
    """Check if two row signatures are compatible (all pairs complementary)."""
    return all(e1.is_complementary(e2) for e1, e2 in zip(s1, s2))


# ── 3-SAT Reduction ────────────────────────────────────────

@dataclass(frozen=True)
class Literal:
    """A SAT literal: variable index + polarity."""
    var: int
    polarity: bool

    def eval(self, assignment: List[bool]) -> bool:
        v = assignment[self.var]
        return v if self.polarity else not v


@dataclass(frozen=True)
class Clause:
    """A 3-SAT clause (OR of exactly 3 literals)."""
    literals: Tuple[Literal, Literal, Literal]

    def sat(self, assignment: List[bool]) -> bool:
        return any(l.eval(assignment) for l in self.literals)


@dataclass
class Formula3SAT:
    """A 3-SAT formula: n variables, m clauses."""
    num_vars: int
    clauses: List[Clause]

    def is_satisfiable(self) -> Tuple[bool, Optional[List[bool]]]:
        """Brute-force SAT check (for small instances)."""
        for bits in range(2 ** self.num_vars):
            assignment = [(bits >> i) & 1 == 1 for i in range(self.num_vars)]
            if all(c.sat(assignment) for c in self.clauses):
                return True, assignment
        return False, None


def sat_to_puzzle_reduction(formula: Formula3SAT) -> Dict:
    """
    Reduce a 3-SAT formula to a jigsaw puzzle instance.

    Returns a dictionary describing the puzzle construction:
    - variable_pieces: For each variable, TRUE and FALSE pieces
    - clause_pieces: For each clause, a piece encoding OR semantics
    - total_pieces: 2n + m (+ boundary pieces)
    """
    variable_pieces = {}
    for i in range(formula.num_vars):
        true_piece = JigsawPiece(
            top=EdgeType.FLAT,
            right=EdgeType.TAB,      # "true" assignment edge
            bottom=EdgeType.FLAT,
            left=EdgeType.FLAT
        )
        false_piece = JigsawPiece(
            top=EdgeType.FLAT,
            right=EdgeType.BLANK,    # "false" assignment edge
            bottom=EdgeType.FLAT,
            left=EdgeType.FLAT
        )
        variable_pieces[f"x{i+1}"] = {
            "TRUE": true_piece,
            "FALSE": false_piece,
            "complementary": true_piece.right.is_complementary(false_piece.right)
        }

    clause_pieces = {}
    for j, clause in enumerate(formula.clauses):
        # Output is tab iff at least one literal is satisfied
        clause_pieces[f"C{j+1}"] = {
            "clause": clause,
            "input_count": 3,
            "semantics": "output = TAB iff ∃ literal with TAB input"
        }

    return {
        "variable_pieces": variable_pieces,
        "clause_pieces": clause_pieces,
        "total_core_pieces": 2 * formula.num_vars + len(formula.clauses),
    }


# ── Puzzle Homomorphism ─────────────────────────────────────

@dataclass
class PuzzleHomomorphism:
    """Structure-preserving map between puzzle instances."""
    map_edge: Callable[[EdgeType], EdgeType]

    def map_piece(self, p: JigsawPiece) -> JigsawPiece:
        return JigsawPiece(
            self.map_edge(p.top),
            self.map_edge(p.right),
            self.map_edge(p.bottom),
            self.map_edge(p.left)
        )

    def preserves_complementarity(self) -> bool:
        """Verify this homomorphism preserves edge complementarity."""
        for e1 in EdgeType:
            for e2 in EdgeType:
                if e1.is_complementary(e2):
                    if not self.map_edge(e1).is_complementary(self.map_edge(e2)):
                        return False
        return True


# Identity and complement homomorphisms
IDENTITY_HOM = PuzzleHomomorphism(map_edge=lambda e: e)
COMPLEMENT_HOM = PuzzleHomomorphism(map_edge=lambda e: e.complement())


# ── Compatibility Counting ──────────────────────────────────

def count_compatible_pairs() -> Dict[str, int]:
    """Count all horizontally compatible piece pairs (verified: 1458)."""
    edge_types = list(EdgeType)
    all_pieces = [
        JigsawPiece(t, r, b, l)
        for t in edge_types for r in edge_types
        for b in edge_types for l in edge_types
    ]

    total = len(all_pieces) ** 2
    compatible = sum(
        1 for p in all_pieces for q in all_pieces
        if p.fits_horizontal(q)
    )

    return {
        "total_pieces": len(all_pieces),
        "total_pairs": total,
        "compatible_pairs": compatible,
        "compatibility_ratio": compatible / total
    }


if __name__ == "__main__":
    # Test the reduction
    formula = Formula3SAT(
        num_vars=3,
        clauses=[
            Clause((Literal(0, True), Literal(1, True), Literal(2, False))),
            Clause((Literal(0, False), Literal(2, True), Literal(2, True))),
        ]
    )

    sat, assignment = formula.is_satisfiable()
    print(f"Formula satisfiable: {sat}")
    if assignment:
        print(f"Assignment: {['T' if a else 'F' for a in assignment]}")

    reduction = sat_to_puzzle_reduction(formula)
    print(f"Total core pieces: {reduction['total_core_pieces']}")

    stats = count_compatible_pairs()
    print(f"Compatible pairs: {stats['compatible_pairs']}/{stats['total_pairs']}")
    print(f"Compatibility ratio: {stats['compatibility_ratio']:.4f}")

    # Verify complement duality
    print(f"\nComplement homomorphism preserves complementarity: "
          f"{COMPLEMENT_HOM.preserves_complementarity()}")
