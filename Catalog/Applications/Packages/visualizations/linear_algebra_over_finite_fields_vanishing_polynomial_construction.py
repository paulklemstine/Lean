#!/usr/bin/env python3
"""
Algorithms for the Evaluation-Kernel Framework.

Implements the key computational procedures underlying the polynomial method:
1. Polynomial construction over finite fields
2. Evaluation matrix computation
3. Kernel extraction via Gaussian elimination over GF(p)
4. Dimension computation for bounded-degree spaces
"""

from math import comb
from itertools import product as cart_product
from typing import List, Tuple, Optional, Dict


# ============================================================
# Finite Field Arithmetic (GF(p) for prime p)
# ============================================================

class GF:
    """Simple finite field GF(p) arithmetic for prime p."""
    
    def __init__(self, p: int):
        """Initialize GF(p). Assumes p is prime."""
        self.p = p
    
    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p
    
    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p
    
    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p
    
    def neg(self, a: int) -> int:
        return (-a) % self.p
    
    def inv(self, a: int) -> int:
        """Multiplicative inverse via Fermat's little theorem."""
        if a % self.p == 0:
            raise ValueError("Cannot invert zero in GF(p)")
        return pow(a, self.p - 2, self.p)
    
    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))
    
    def pow(self, a: int, n: int) -> int:
        return pow(a, n, self.p)


# ============================================================
# Algorithm 1: Bounded-Degree Monomial Enumeration
# ============================================================

def enumerate_bounded_monomials(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all monomials in n variables with total degree < d.
    
    Returns list of exponent tuples (e_1, ..., e_n) with sum(e_i) < d.
    
    Complexity: O(C(d+n-1, n)) time and space.
    
    >>> enumerate_bounded_monomials(2, 3)
    [(0, 0), (0, 1), (0, 2), (1, 0), (1, 1), (2, 0)]
    """
    if n == 0:
        return [()] if d > 0 else []
    
    monomials = []
    
    def backtrack(var: int, remaining: int, current: List[int]):
        if var == n:
            monomials.append(tuple(current))
            return
        for e in range(remaining):
            current.append(e)
            backtrack(var + 1, remaining - e, current)
            current.pop()
    
    backtrack(0, d, [])
    return monomials


def monomial_space_dimension(n: int, d: int) -> int:
    """
    Compute dim M(n, d) = C(d+n-1, n), the number of monomials in n variables
    with total degree < d.
    
    This is the stars-and-bars formula.
    
    Complexity: O(min(n, d)) time.
    
    >>> monomial_space_dimension(2, 3)
    6
    >>> monomial_space_dimension(3, 4)
    20
    """
    if d == 0:
        return 0
    if n == 0:
        return 1 if d > 0 else 0
    return comb(d + n - 1, n)


# ============================================================
# Algorithm 2: Evaluation Matrix Construction
# ============================================================

def build_evaluation_matrix(
    field: GF,
    n: int,
    d: int,
    points: List[Tuple[int, ...]]
) -> List[List[int]]:
    """
    Build the evaluation matrix A where A[i][j] = monomial_j(point_i).
    
    The matrix has |points| rows and dim M(n,d) columns.
    Each entry is the evaluation of a monomial at a point, computed over GF(p).
    
    Args:
        field: The finite field GF(p)
        n: Number of variables
        d: Degree bound (total degree < d)
        points: List of evaluation points in GF(p)^n
    
    Returns:
        Evaluation matrix as list of lists (over GF(p))
    
    Complexity: O(|E| · dim · n) field operations
    """
    monomials = enumerate_bounded_monomials(n, d)
    matrix = []
    
    for point in points:
        row = []
        for exponents in monomials:
            val = 1
            for i in range(n):
                val = field.mul(val, field.pow(point[i], exponents[i]))
            row.append(val)
        matrix.append(row)
    
    return matrix


# ============================================================
# Algorithm 3: Gaussian Elimination over GF(p)
# ============================================================

def gaussian_elimination_gfp(
    matrix: List[List[int]],
    p: int
) -> Tuple[int, List[List[int]]]:
    """
    Perform Gaussian elimination on a matrix over GF(p).
    
    Returns (rank, reduced_matrix).
    
    Complexity: O(min(rows, cols) · rows · cols) field operations
    """
    field = GF(p)
    rows = len(matrix)
    if rows == 0:
        return 0, matrix
    cols = len(matrix[0])
    
    # Deep copy
    M = [row[:] for row in matrix]
    
    pivot_row = 0
    pivot_cols = []
    
    for col in range(cols):
        # Find pivot in this column
        found = -1
        for r in range(pivot_row, rows):
            if M[r][col] % p != 0:
                found = r
                break
        
        if found == -1:
            continue
        
        # Swap rows
        M[pivot_row], M[found] = M[found], M[pivot_row]
        pivot_cols.append(col)
        
        # Scale pivot row
        inv = field.inv(M[pivot_row][col])
        M[pivot_row] = [field.mul(x, inv) for x in M[pivot_row]]
        
        # Eliminate column
        for r in range(rows):
            if r != pivot_row and M[r][col] % p != 0:
                factor = M[r][col]
                M[r] = [field.sub(M[r][j], field.mul(factor, M[pivot_row][j]))
                        for j in range(cols)]
        
        pivot_row += 1
    
    return len(pivot_cols), M


# ============================================================
# Algorithm 4: Kernel Extraction
# ============================================================

def find_kernel_basis(
    matrix: List[List[int]],
    p: int
) -> List[List[int]]:
    """
    Find a basis for the kernel (null space) of a matrix over GF(p).
    
    Uses Gaussian elimination to find the reduced row echelon form,
    then extracts kernel vectors from the free variables.
    
    Args:
        matrix: The matrix (list of rows) over GF(p)
        p: The prime defining GF(p)
    
    Returns:
        List of kernel basis vectors
    
    Complexity: O(min(rows, cols) · rows · cols + cols · nullity) 
    """
    field = GF(p)
    rows = len(matrix)
    if rows == 0:
        # Kernel is all of the column space
        cols = 0
        return []
    cols = len(matrix[0])
    
    # Transpose: we want kernel of A, i.e., Ax = 0
    # Work with the transpose to find column relations
    rank, rref = gaussian_elimination_gfp(matrix, p)
    
    # Identify pivot and free columns
    pivot_cols = []
    pivot_row = 0
    for col in range(cols):
        if pivot_row < rows and rref[pivot_row][col] % p == 1:
            # Check it's really a pivot
            is_pivot = True
            for r in range(rows):
                if r != pivot_row and rref[r][col] % p != 0:
                    is_pivot = False
                    break
            if is_pivot:
                pivot_cols.append(col)
                pivot_row += 1
    
    free_cols = [c for c in range(cols) if c not in pivot_cols]
    
    # Extract kernel vectors
    kernel_basis = []
    for fc in free_cols:
        vec = [0] * cols
        vec[fc] = 1
        for i, pc in enumerate(pivot_cols):
            vec[pc] = field.neg(rref[i][fc])
        kernel_basis.append(vec)
    
    return kernel_basis


# ============================================================
# Algorithm 5: Vanishing Polynomial Construction
# ============================================================

def construct_vanishing_polynomial(
    field: GF,
    n: int,
    d: int,
    points: List[Tuple[int, ...]]
) -> Optional[Dict[Tuple[int, ...], int]]:
    """
    Construct a nonzero polynomial of total degree < d vanishing on all given points.
    
    Returns the polynomial as a dictionary mapping exponent tuples to coefficients,
    or None if no such polynomial exists (which happens when |points| ≥ dim M(n,d)).
    
    This is the main algorithm: it builds the evaluation matrix, computes its kernel,
    and extracts a vanishing polynomial from a kernel vector.
    
    Args:
        field: The finite field GF(p)
        n: Number of variables
        d: Degree bound
        points: Points where the polynomial should vanish
    
    Returns:
        Dictionary {exponent_tuple: coefficient} or None
    
    Complexity: O(|E| · dim² + dim³) field operations where dim = C(d+n-1, n)
    
    >>> gf5 = GF(5)
    >>> poly = construct_vanishing_polynomial(gf5, 1, 3, [(0,), (1,)])
    >>> poly is not None
    True
    """
    dim = monomial_space_dimension(n, d)
    
    if len(points) >= dim:
        return None  # Cannot guarantee existence
    
    monomials = enumerate_bounded_monomials(n, d)
    matrix = build_evaluation_matrix(field, n, d, points)
    
    kernel = find_kernel_basis(matrix, field.p)
    
    if not kernel:
        return None  # Shouldn't happen when |points| < dim
    
    # Take the first kernel vector as our polynomial
    coeffs = kernel[0]
    poly = {}
    for i, m in enumerate(monomials):
        if coeffs[i] % field.p != 0:
            poly[m] = coeffs[i] % field.p
    
    return poly


def polynomial_to_string(poly: Dict[Tuple[int, ...], int], var_names: List[str] = None) -> str:
    """Pretty-print a polynomial given as {exponent_tuple: coefficient}."""
    if not poly:
        return "0"
    
    n = len(next(iter(poly)))
    if var_names is None:
        var_names = [f"x_{i}" for i in range(n)]
    
    terms = []
    for exps, coeff in sorted(poly.items()):
        if coeff == 0:
            continue
        
        factors = []
        for i, e in enumerate(exps):
            if e == 0:
                continue
            elif e == 1:
                factors.append(var_names[i])
            else:
                factors.append(f"{var_names[i]}^{e}")
        
        if not factors:
            terms.append(str(coeff))
        elif coeff == 1:
            terms.append("·".join(factors))
        else:
            terms.append(f"{coeff}·" + "·".join(factors))
    
    return " + ".join(terms) if terms else "0"


# ============================================================
# Algorithm 6: Verify Vanishing
# ============================================================

def verify_vanishing(
    field: GF,
    poly: Dict[Tuple[int, ...], int],
    points: List[Tuple[int, ...]]
) -> bool:
    """
    Verify that a polynomial vanishes on all given points.
    
    Args:
        field: The finite field
        poly: Polynomial as {exponent_tuple: coefficient}
        points: Points to check
    
    Returns:
        True if poly vanishes on all points
    """
    n = len(next(iter(poly))) if poly else 0
    
    for point in points:
        val = 0
        for exps, coeff in poly.items():
            term = coeff
            for i in range(n):
                term = field.mul(term, field.pow(point[i], exps[i]))
            val = field.add(val, term)
        if val % field.p != 0:
            return False
    return True


# ============================================================
# Main: Run examples
# ============================================================

if __name__ == "__main__":
    print("Evaluation-Kernel Framework — Algorithm Demonstrations")
    print("=" * 60)
    print()
    
    # Example 1: Univariate
    print("Example 1: Univariate vanishing polynomial")
    gf7 = GF(7)
    points_1d = [(1,), (3,), (5,)]
    poly = construct_vanishing_polynomial(gf7, 1, 5, points_1d)
    if poly:
        print(f"  Points: {[p[0] for p in points_1d]}")
        print(f"  Polynomial: {polynomial_to_string(poly, ['X'])}")
        print(f"  Vanishes: {verify_vanishing(gf7, poly, points_1d)}")
    print()
    
    # Example 2: Bivariate
    print("Example 2: Bivariate vanishing polynomial over GF(5)")
    gf5 = GF(5)
    points_2d = [(0, 0), (1, 1), (2, 3)]
    poly = construct_vanishing_polynomial(gf5, 2, 3, points_2d)
    if poly:
        print(f"  Points: {points_2d}")
        print(f"  Polynomial: {polynomial_to_string(poly, ['x', 'y'])}")
        print(f"  Vanishes: {verify_vanishing(gf5, poly, points_2d)}")
    print()
    
    # Example 3: Higher dimension
    print("Example 3: 3-variable vanishing polynomial over GF(3)")
    gf3 = GF(3)
    points_3d = [(0, 0, 0), (1, 0, 0), (0, 1, 0), (0, 0, 1)]
    dim_3d = monomial_space_dimension(3, 3)
    print(f"  dim M(3, 3) = {dim_3d}")
    print(f"  |E| = {len(points_3d)} < {dim_3d}")
    poly = construct_vanishing_polynomial(gf3, 3, 3, points_3d)
    if poly:
        print(f"  Polynomial: {polynomial_to_string(poly, ['x', 'y', 'z'])}")
        print(f"  Vanishes: {verify_vanishing(gf3, poly, points_3d)}")
    print()
    
    # Example 4: Dimension table
    print("Dimension table dim M(n, d) = C(d+n-1, n):")
    print(f"{'':>6}", end="")
    for d in range(1, 8):
        print(f"{'d='+str(d):>8}", end="")
    print()
    for n in range(1, 6):
        print(f"{'n='+str(n):>6}", end="")
        for d in range(1, 8):
            print(f"{monomial_space_dimension(n, d):>8}", end="")
        print()
