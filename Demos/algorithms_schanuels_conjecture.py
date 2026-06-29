#!/usr/bin/env python3
"""
algorithms.py — Certified Linear Independence and Schanuel Configuration Analysis

Implements the core algorithms from the formal Schanuel package:
1. Exact rational matrix rank computation
2. ℚ-linear independence certification
3. Rational relation finding (dependency witnesses)
4. Schanuel deficiency analysis

All algorithms use exact rational arithmetic (fractions.Fraction) to match
the formal verification guarantee: no floating-point approximation errors.
"""

from fractions import Fraction
from typing import List, Tuple, Optional
import copy


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Exact Gaussian Elimination over ℚ
# ═══════════════════════════════════════════════════════════════════════

def gaussian_elimination(M: List[List[Fraction]]) -> Tuple[List[List[Fraction]], List[int]]:
    """
    Perform Gaussian elimination with partial pivoting over ℚ.
    
    Args:
        M: m × n matrix of Fraction entries
        
    Returns:
        (row_echelon_form, pivot_columns): the reduced matrix and list of pivot column indices
        
    Complexity: O(m·n·min(m,n)) Fraction operations
    """
    rows = [row[:] for row in M]
    m = len(rows)
    if m == 0:
        return rows, []
    n = len(rows[0])
    
    pivot_columns = []
    pivot_row = 0
    
    for col in range(n):
        # Find nonzero entry in this column at or below pivot_row
        found = None
        for row in range(pivot_row, m):
            if rows[row][col] != Fraction(0):
                found = row
                break
        if found is None:
            continue
        
        # Swap rows
        rows[pivot_row], rows[found] = rows[found], rows[pivot_row]
        pivot_columns.append(col)
        
        # Scale pivot row
        pivot_val = rows[pivot_row][col]
        for j in range(n):
            rows[pivot_row][j] /= pivot_val
        
        # Eliminate column in all other rows
        for row in range(m):
            if row != pivot_row and rows[row][col] != Fraction(0):
                factor = rows[row][col]
                for j in range(n):
                    rows[row][j] -= factor * rows[pivot_row][j]
        
        pivot_row += 1
    
    return rows, pivot_columns


def rational_rank(M: List[List[Fraction]]) -> int:
    """
    Compute the exact rank of a rational matrix.
    
    Args:
        M: m × n matrix of Fraction entries
        
    Returns:
        rank (int)
        
    Complexity: O(m·n·min(m,n)) Fraction operations
    """
    _, pivots = gaussian_elimination(M)
    return len(pivots)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: ℚ-Linear Independence Certification  
# ═══════════════════════════════════════════════════════════════════════

def certify_independence(coord_matrix: List[List[Fraction]]) -> Tuple[bool, int, int]:
    """
    Certify ℚ-linear independence of complex numbers from their coordinate
    representation in a ℚ-linearly independent basis.
    
    This implements the computational side of the formally verified theorem:
    
        coordinate_matrix_full_rank_implies_q_linearIndependent:
        If M has full column rank and z_j = ∑_i M_{ij} · basis_i with
        basis ℚ-linearly independent, then z is ℚ-linearly independent.
    
    Args:
        coord_matrix: m × n matrix M where columns represent coordinates
                      of the target elements in a ℚ-independent basis
                      
    Returns:
        (is_independent, rank, num_elements):
            is_independent: True iff M has full column rank (rank = n)
            rank: the computed rank
            num_elements: n (number of columns = elements being tested)
    """
    m = len(coord_matrix)
    n = len(coord_matrix[0]) if m > 0 else 0
    r = rational_rank(coord_matrix)
    return r == n, r, n


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Rational Relation Finder (Dependency Witness)
# ═══════════════════════════════════════════════════════════════════════

def find_rational_relation(coord_matrix: List[List[Fraction]]) -> Optional[List[Fraction]]:
    """
    Find a nontrivial rational relation among the columns of M, if one exists.
    
    If rank(M) < n, returns q : ℚ^n with q ≠ 0 and M·q = 0.
    This witnesses that the encoded complex numbers are ℚ-linearly dependent,
    corresponding to the hypothesis of not_linearIndependent_of_rational_relation.
    
    Args:
        coord_matrix: m × n matrix of Fraction entries
        
    Returns:
        None if columns are independent, otherwise a nonzero vector q
        in the kernel of M.
    """
    m = len(coord_matrix)
    n = len(coord_matrix[0]) if m > 0 else 0
    
    is_indep, r, _ = certify_independence(coord_matrix)
    if is_indep:
        return None
    
    # Augment M with identity to track column operations
    # Solve M·q = 0 using RREF
    rref, pivots = gaussian_elimination(coord_matrix)
    
    # Find a free variable (column not in pivot set)
    free_cols = [j for j in range(n) if j not in pivots]
    if not free_cols:
        return None
    
    # Construct kernel vector: set free variable = 1, solve for pivot variables
    free_col = free_cols[0]
    q = [Fraction(0)] * n
    q[free_col] = Fraction(1)
    
    for row_idx, pivot_col in enumerate(pivots):
        q[pivot_col] = -rref[row_idx][free_col]
    
    return q


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Schanuel Configuration Analyzer
# ═══════════════════════════════════════════════════════════════════════

class SchanuelAnalysis:
    """
    Analysis result for a Schanuel configuration.
    
    Packages the outcome of applying the formal theorem chain to a 
    concrete tuple of algebraic numbers.
    """
    def __init__(self, n: int, is_independent: bool, rank: int,
                 relation: Optional[List[Fraction]] = None):
        self.n = n
        self.is_independent = is_independent
        self.rank = rank
        self.relation = relation
    
    @property 
    def schanuel_applicable(self) -> bool:
        """Whether the Schanuel lower bound predicate is non-vacuous."""
        return self.is_independent
    
    @property
    def guaranteed_transcendentals(self) -> int:
        """
        Under Schanuel, the minimum number of transcendental exponentials.
        By schanuel_implies_exists_transcendental_exp, this is ≥ 1 when n ≥ 1
        and all z_i are algebraic and ℚ-linearly independent.
        """
        if self.is_independent and self.n > 0:
            return 1  # The theorem guarantees ∃ i, Transcendental (exp z_i)
        return 0
    
    def summary(self) -> str:
        lines = [f"Schanuel Analysis (n = {self.n}):"]
        lines.append(f"  Matrix rank: {self.rank}")
        lines.append(f"  ℚ-linearly independent: {self.is_independent}")
        if self.is_independent:
            lines.append(f"  Schanuel lower bound: applicable (trdeg ≥ {self.n})")
            lines.append(f"  Guaranteed transcendental exponentials: ≥ {self.guaranteed_transcendentals}")
            lines.append(f"  (by schanuel_implies_exists_transcendental_exp)")
        else:
            lines.append(f"  Schanuel lower bound: VACUOUS (tuple is dependent)")
            if self.relation:
                rel_str = " + ".join(f"({q})·z_{j}" for j, q in enumerate(self.relation) if q != 0)
                lines.append(f"  Witness relation: {rel_str} = 0")
            lines.append(f"  (by schanuel_vacuous_on_dependent_tuples)")
        return "\n".join(lines)


def analyze_schanuel_config(coord_matrix: List[List[Fraction]]) -> SchanuelAnalysis:
    """
    Full Schanuel analysis of a tuple of algebraic numbers given by coordinates.
    
    Args:
        coord_matrix: m × n matrix where column j gives the coordinates of z_j
                      in a ℚ-linearly independent basis
                      
    Returns:
        SchanuelAnalysis object with certification results
    """
    is_indep, rank, n = certify_independence(coord_matrix)
    relation = None if is_indep else find_rational_relation(coord_matrix)
    return SchanuelAnalysis(n=n, is_independent=is_indep, rank=rank, relation=relation)


# ═══════════════════════════════════════════════════════════════════════
# Example Usage
# ═══════════════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Algorithms for Schanuel Conjecture Framework")
    print("=" * 50)
    print()
    
    # Example: z = (1, √2, √3) in basis {1, √2, √3}
    M = [[Fraction(1), Fraction(0), Fraction(0)],
         [Fraction(0), Fraction(1), Fraction(0)],
         [Fraction(0), Fraction(0), Fraction(1)]]
    
    result = analyze_schanuel_config(M)
    print(result.summary())
    print()
    
    # Example: z = (1, √2, 1+√2) — dependent
    M2 = [[Fraction(1), Fraction(0), Fraction(1)],
          [Fraction(0), Fraction(1), Fraction(1)]]
    
    result2 = analyze_schanuel_config(M2)
    print(result2.summary())
    print()
    
    # Example: z = (√2, √3) — pair test for schanuel_pair_forces_transcendence
    M3 = [[Fraction(1), Fraction(0)],
          [Fraction(0), Fraction(1)]]
    
    result3 = analyze_schanuel_config(M3)
    print(result3.summary())
    print("  → By schanuel_pair_forces_transcendence:")
    print("    Transcendental(exp(√2)) ∨ Transcendental(exp(√3))")
