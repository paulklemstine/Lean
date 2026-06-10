#!/usr/bin/env python3
"""
Algorithms for Categorical Extraction in Affine Σ-Protocols

Implements the core algorithms from the categorical extraction framework:
1. Extraction section construction from matrix data
2. Naturality verification for system morphisms
3. Compositional extraction construction
4. Extraction rank computation
"""

from typing import List, Tuple, Dict, Optional, Callable
import itertools


# =============================================================================
# Finite Field Arithmetic
# =============================================================================

class FiniteField:
    """Arithmetic in Z/pZ."""

    def __init__(self, p: int):
        self.p = p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        return pow(a % self.p, self.p - 2, self.p)

    def neg(self, a: int) -> int:
        return (-a) % self.p


# =============================================================================
# Matrix Operations over Finite Fields
# =============================================================================

class FFMatrix:
    """Matrix over a finite field."""

    def __init__(self, field: FiniteField, data: List[List[int]]):
        self.F = field
        self.rows = len(data)
        self.cols = len(data[0]) if data else 0
        self.data = [[x % field.p for x in row] for row in data]

    def mulvec(self, v: List[int]) -> List[int]:
        """Matrix-vector multiply."""
        assert len(v) == self.cols
        return [
            sum(self.F.mul(self.data[i][j], v[j]) for j in range(self.cols)) % self.F.p
            for i in range(self.rows)
        ]

    def matmul(self, other: 'FFMatrix') -> 'FFMatrix':
        """Matrix-matrix multiply."""
        assert self.cols == other.rows
        result = []
        for i in range(self.rows):
            row = []
            for j in range(other.cols):
                val = sum(
                    self.F.mul(self.data[i][k], other.data[k][j])
                    for k in range(self.cols)
                ) % self.F.p
                row.append(val)
            result.append(row)
        return FFMatrix(self.F, result)

    @staticmethod
    def identity(field: FiniteField, n: int) -> 'FFMatrix':
        return FFMatrix(field, [[1 if i == j else 0 for j in range(n)] for i in range(n)])

    def is_mulvec_injective(self) -> bool:
        """
        Check if mulVec is injective by testing all vectors.

        Time complexity: O(p^n * m * n) where p = field size, n = cols, m = rows.
        Space complexity: O(p^n * m) for storing images.

        For large fields, use rank computation instead.
        """
        seen = set()
        for v in itertools.product(range(self.F.p), repeat=self.cols):
            img = tuple(self.mulvec(list(v)))
            if img in seen:
                return False
            seen.add(img)
        return True

    def rank(self) -> int:
        """
        Compute matrix rank over the finite field using Gaussian elimination.

        Time complexity: O(min(m,n) * m * n)
        Space complexity: O(m * n)
        """
        # Work on a copy
        mat = [row[:] for row in self.data]
        m, n = self.rows, self.cols
        rank = 0
        for col in range(n):
            # Find pivot
            pivot = None
            for row in range(rank, m):
                if mat[row][col] % self.F.p != 0:
                    pivot = row
                    break
            if pivot is None:
                continue
            # Swap
            mat[rank], mat[pivot] = mat[pivot], mat[rank]
            # Scale pivot row
            inv_pivot = self.F.inv(mat[rank][col])
            mat[rank] = [self.F.mul(x, inv_pivot) for x in mat[rank]]
            # Eliminate
            for row in range(m):
                if row != rank and mat[row][col] != 0:
                    factor = mat[row][col]
                    mat[row] = [
                        self.F.sub(mat[row][j], self.F.mul(factor, mat[rank][j]))
                        for j in range(n)
                    ]
            rank += 1
        return rank

    def has_extraction_rank(self) -> bool:
        """
        Check extraction rank using matrix rank.

        The matrix M : (m × n) has extraction rank iff rank(M) = n,
        i.e., M has full column rank, equivalently mulVec is injective.

        Time complexity: O(min(m,n) * m * n) — much faster than brute force.
        """
        return self.rank() == self.cols


# =============================================================================
# Algorithm 1: Extraction Section Construction
# =============================================================================

def construct_extraction_section(
    M: FFMatrix
) -> Optional[Callable[[List[int], List[int], int, int], List[int]]]:
    """
    Construct a natural extraction section from matrix data.

    Given M with extraction rank, returns a function ε such that:
      ε(z₁, z₂, c₁, c₂) = w
    whenever z_i = t + c_i · M·w for some t.

    Algorithm:
    1. Verify M has extraction rank (full column rank).
    2. Compute a left inverse L of M (so L·M = I).
    3. Define ε(z₁, z₂, c₁, c₂) = L · ((c₁-c₂)⁻¹ · (z₁ - z₂)).

    Time complexity: O(m·n²) for left inverse, O(m·n) per extraction.
    Space complexity: O(m·n) for storing L.

    Args:
        M: The coefficient matrix (must have extraction rank).

    Returns:
        The extraction function, or None if M lacks extraction rank.
    """
    if not M.has_extraction_rank():
        return None

    F = M.F
    m, n = M.rows, M.cols

    # Compute left inverse L such that L·M = I_n
    # Use augmented matrix [M | I_m] and row-reduce
    aug = [M.data[i][:] + [1 if i == j else 0 for j in range(m)]
           for i in range(m)]

    pivot_cols = []
    pivot_row = 0
    for col in range(n):
        # Find pivot
        found = None
        for row in range(pivot_row, m):
            if aug[row][col] % F.p != 0:
                found = row
                break
        if found is None:
            continue
        aug[pivot_row], aug[found] = aug[found], aug[pivot_row]
        inv_p = F.inv(aug[pivot_row][col])
        aug[pivot_row] = [F.mul(x, inv_p) for x in aug[pivot_row]]
        for row in range(m):
            if row != pivot_row and aug[row][col] != 0:
                factor = aug[row][col]
                aug[row] = [F.sub(aug[row][j], F.mul(factor, aug[pivot_row][j]))
                            for j in range(n + m)]
        pivot_cols.append(pivot_row)
        pivot_row += 1

    # Extract L (first n pivot rows, last m columns)
    L_data = []
    for i in range(n):
        L_data.append([aug[pivot_cols[i]][n + j] for j in range(m)])
    L = FFMatrix(F, L_data)

    # Verify L·M = I_n
    product = L.matmul(M)
    I_n = FFMatrix.identity(F, n)
    assert product.data == I_n.data, "Left inverse computation failed"

    def extraction_section(z1: List[int], z2: List[int],
                          c1: int, c2: int) -> List[int]:
        """Extract witness from two transcripts at distinct challenges."""
        inv_dc = F.inv(F.sub(c1, c2))
        # Compute (c₁-c₂)⁻¹ · (z₁ - z₂)
        diff = [F.mul(F.sub(z1[i], z2[i]), inv_dc) for i in range(m)]
        # Apply left inverse
        return L.mulvec(diff)

    return extraction_section


# =============================================================================
# Algorithm 2: Naturality Verification
# =============================================================================

def verify_naturality(
    M1: FFMatrix, M2: FFMatrix,
    phi: FFMatrix, psi: FFMatrix,
    num_samples: int = 100
) -> Tuple[bool, Optional[Dict]]:
    """
    Verify that extraction commutes with a morphism (φ, ψ).

    Checks the naturality square:
      ψ · extractImage(z₁, z₂) = extractImage(ψ·z₁, ψ·z₂)

    This is always true by linearity, but we verify computationally.

    Algorithm:
    1. Verify commutativity: M₂·φ = ψ·M₁.
    2. For random inputs, check the naturality equation.

    Time complexity: O(num_samples · m² · n)

    Args:
        M1, M2: Coefficient matrices of the two systems.
        phi: Witness map (n₂ × n₁ matrix).
        psi: Response map (m₂ × m₁ matrix).
        num_samples: Number of random samples to test.

    Returns:
        (success, counterexample_or_None)
    """
    F = M1.F

    # Check commutativity
    lhs = M2.matmul(phi)
    rhs = psi.matmul(M1)
    if lhs.data != rhs.data:
        return False, {"error": "Commutativity M₂·φ ≠ ψ·M₁ failed"}

    import random
    m1 = M1.rows
    p = F.p

    for _ in range(num_samples):
        z1 = [random.randint(0, p-1) for _ in range(m1)]
        z2 = [random.randint(0, p-1) for _ in range(m1)]
        c1 = random.randint(0, p-1)
        c2 = random.randint(0, p-1)
        if c1 == c2:
            c2 = (c1 + 1) % p

        inv_dc = F.inv(F.sub(c1, c2))

        # LHS: ψ · extractImage(z₁, z₂)
        extract = [F.mul(F.sub(z1[i], z2[i]), inv_dc) for i in range(m1)]
        lhs_val = psi.mulvec(extract)

        # RHS: extractImage(ψ·z₁, ψ·z₂)
        psi_z1 = psi.mulvec(z1)
        psi_z2 = psi.mulvec(z2)
        rhs_val = [F.mul(F.sub(psi_z1[i], psi_z2[i]), inv_dc)
                    for i in range(psi.rows)]

        if lhs_val != rhs_val:
            return False, {
                "z1": z1, "z2": z2, "c1": c1, "c2": c2,
                "lhs": lhs_val, "rhs": rhs_val
            }

    return True, None


# =============================================================================
# Algorithm 3: Compositional Extraction
# =============================================================================

def compose_extraction_sections(
    M1: FFMatrix, M2: FFMatrix
) -> Optional[Callable[[List[int], List[int], int, int], List[int]]]:
    """
    Construct the composite extraction section for S₂ ∘ S₁.

    Given:
    - M₁ : n → m₁ with extraction rank
    - M₂ : m₁ → m₂ with extraction rank

    Constructs ε_{comp} such that:
      ε_{comp}(z₁, z₂, c₁, c₂) = w
    whenever z_i = t + c_i · (M₂·M₁)·w.

    Algorithm:
    1. Construct extraction section ε₂ for M₂.
    2. Construct extraction section ε₁ for M₁.
    3. Define ε_{comp}(z₁, z₂, c₁, c₂) = ε₁(ε₂(z₁, z₂, c₁, c₂), 0, 1, 0).

    The key insight: composite transcripts are valid M₂-transcripts for
    witness M₁·w, so ε₂ recovers M₁·w. Then synthetic M₁-transcripts
    (using challenges 1 and 0) let ε₁ recover w.

    Time complexity: O(m₁·n₁ + m₂·m₁) per extraction after O(m²·n) setup.

    Returns:
        Composite extraction function, or None if either system lacks rank.
    """
    eps1 = construct_extraction_section(M1)
    eps2 = construct_extraction_section(M2)

    if eps1 is None or eps2 is None:
        return None

    F = M1.F
    n = M1.cols

    def composite_extract(z1: List[int], z2: List[int],
                         c1: int, c2: int) -> List[int]:
        # Step 1: Use ε₂ to recover M₁·w from composite transcripts
        m1w = eps2(z1, z2, c1, c2)

        # Step 2: Use ε₁ with synthetic transcripts to recover w
        # S₁.transcript(0, w, 1) = M₁·w, S₁.transcript(0, w, 0) = 0
        zero_vec = [0] * M1.rows
        w = eps1(m1w, zero_vec, 1, 0)

        return w

    return composite_extract


# =============================================================================
# Algorithm 4: Extraction Rank Analysis
# =============================================================================

def analyze_extraction_rank(M: FFMatrix) -> Dict:
    """
    Complete analysis of extraction rank for a matrix.

    Returns:
    - rank: matrix rank over the finite field
    - has_extraction_rank: whether rank = n (full column rank)
    - kernel_dimension: dimension of the kernel (n - rank)
    - extraction_possible: True iff extraction rank holds

    Time complexity: O(min(m,n) · m · n)
    """
    r = M.rank()
    return {
        "matrix_dimensions": f"{M.rows} × {M.cols}",
        "field_size": M.F.p,
        "rank": r,
        "full_column_rank": r == M.cols,
        "kernel_dimension": M.cols - r,
        "has_extraction_rank": r == M.cols,
        "extraction_possible": r == M.cols,
    }


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    F = FiniteField(7)

    print("=== Algorithm 1: Extraction Section Construction ===\n")
    M = FFMatrix(F, [[1, 2], [3, 4], [5, 6]])
    eps = construct_extraction_section(M)
    if eps:
        w = [3, 5]
        Mw = M.mulvec(w)
        t = [1, 0, 2]
        c1, c2 = 3, 1
        z1 = [F.add(t[i], F.mul(c1, Mw[i])) for i in range(3)]
        z2 = [F.add(t[i], F.mul(c2, Mw[i])) for i in range(3)]
        recovered = eps(z1, z2, c1, c2)
        print(f"  Original witness: {w}")
        print(f"  Recovered witness: {recovered}")
        print(f"  Match: {w == recovered}")
    print()

    print("=== Algorithm 2: Naturality Verification ===\n")
    M1 = FFMatrix(F, [[1, 0], [0, 1]])
    M2 = FFMatrix(F, [[1, 2], [3, 4]])
    phi = FFMatrix.identity(F, 2)
    psi = M2
    success, cex = verify_naturality(M1, M2, phi, psi)
    print(f"  Naturality verified: {success}")
    if cex:
        print(f"  Counterexample: {cex}")
    print()

    print("=== Algorithm 3: Compositional Extraction ===\n")
    M1 = FFMatrix(F, [[1, 1], [0, 1]])
    M2 = FFMatrix(F, [[1, 0], [1, 1]])
    eps_comp = compose_extraction_sections(M1, M2)
    if eps_comp:
        w = [4, 2]
        M_comp = M2.matmul(M1)
        Mw = M_comp.mulvec(w)
        t = [3, 5]
        c1, c2 = 2, 5
        z1 = [F.add(t[i], F.mul(c1, Mw[i])) for i in range(2)]
        z2 = [F.add(t[i], F.mul(c2, Mw[i])) for i in range(2)]
        recovered = eps_comp(z1, z2, c1, c2)
        print(f"  Original witness: {w}")
        print(f"  Recovered witness: {recovered}")
        print(f"  Match: {w == recovered}")
    print()

    print("=== Algorithm 4: Extraction Rank Analysis ===\n")
    for name, mat in [
        ("Identity 2×2", FFMatrix(F, [[1, 0], [0, 1]])),
        ("Rank-deficient", FFMatrix(F, [[1, 2], [2, 4]])),
        ("Tall matrix 3×2", FFMatrix(F, [[1, 2], [3, 4], [5, 6]])),
    ]:
        analysis = analyze_extraction_rank(mat)
        print(f"  {name}: {analysis}")
    print()
