#!/usr/bin/env python3
"""
Algorithms for MDS Matrices and Uncertainty Principles

Type-hinted implementations of the core algorithms from the research.
"""

from typing import List, Tuple, Optional, Dict, Set
import numpy as np
from itertools import combinations


# ============================================================
# Core GF(p) Arithmetic
# ============================================================

def gf_add(a: int, b: int, p: int) -> int:
    """Addition in GF(p)."""
    return (a + b) % p


def gf_mul(a: int, b: int, p: int) -> int:
    """Multiplication in GF(p)."""
    return (a * b) % p


def gf_inv(a: int, p: int) -> int:
    """Multiplicative inverse in GF(p) using Fermat's little theorem."""
    assert a % p != 0, f"{a} is zero in GF({p})"
    return pow(a, p - 2, p)


def gf_det(M: List[List[int]], p: int) -> int:
    """Determinant of a matrix over GF(p) via Gaussian elimination.
    
    Args:
        M: Square matrix as list of lists (entries in {0, ..., p-1})
        p: Prime modulus
        
    Returns:
        Determinant in {0, ..., p-1}
    """
    n = len(M)
    if n == 0:
        return 1
    
    # Work on a copy
    A = [[M[i][j] % p for j in range(n)] for i in range(n)]
    det_val = 1
    
    for col in range(n):
        # Find pivot row
        pivot = -1
        for row in range(col, n):
            if A[row][col] != 0:
                pivot = row
                break
        if pivot == -1:
            return 0
        
        # Swap rows if needed
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]
            det_val = (-det_val) % p
        
        # Multiply determinant by pivot
        det_val = gf_mul(det_val, A[col][col], p)
        
        # Eliminate below
        inv_pivot = gf_inv(A[col][col], p)
        for row in range(col + 1, n):
            factor = gf_mul(A[row][col], inv_pivot, p)
            for j in range(col, n):
                A[row][j] = gf_add(A[row][j], -gf_mul(factor, A[col][j], p), p)
    
    return det_val


# ============================================================
# Algorithm 1: MDS Verification
# ============================================================

def is_mds(M: List[List[int]], p: int) -> bool:
    """Check if an n×n matrix M over GF(p) is MDS.
    
    A matrix is MDS if every square submatrix has nonzero determinant.
    
    Complexity: O(sum_{k=1}^{n} C(n,k)^2 * k^3) field operations
    
    Args:
        M: n×n matrix over GF(p)
        p: Prime modulus
        
    Returns:
        True if M is MDS
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if gf_det(sub, p) == 0:
                    return False
    return True


def find_singular_submatrix(M: List[List[int]], p: int) -> Optional[Tuple[Tuple[int, ...], Tuple[int, ...]]]:
    """Find a singular square submatrix of M, or None if M is MDS.
    
    Args:
        M: n×n matrix over GF(p)
        p: Prime modulus
        
    Returns:
        (rows, cols) of a singular submatrix, or None if MDS
    """
    n = len(M)
    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = [[M[r][c] for c in cols] for r in rows]
                if gf_det(sub, p) == 0:
                    return (rows, cols)
    return None


# ============================================================
# Algorithm 2: Uncertainty Violation Search
# ============================================================

def mat_mul_vec(M: List[List[int]], v: List[int], p: int) -> List[int]:
    """Matrix-vector product over GF(p)."""
    n = len(M)
    return [sum(gf_mul(M[i][j], v[j], p) for j in range(len(v))) % p for i in range(n)]


def support(v: List[int], p: int) -> Set[int]:
    """Support of a vector over GF(p)."""
    return {i for i, x in enumerate(v) if x % p != 0}


def support_size(v: List[int], p: int) -> int:
    """Size of the support of v over GF(p)."""
    return len(support(v, p))


def find_uncertainty_violator(M: List[List[int]], p: int) -> Optional[Tuple[List[int], int]]:
    """Find a nonzero vector violating |supp(f)| + |supp(Mf)| >= n+1.
    
    Uses the constructive proof: find a singular submatrix, then find
    a kernel vector and extend by zeros.
    
    Args:
        M: n×n matrix over GF(p)
        p: Prime modulus
        
    Returns:
        (f, support_sum) if violator found, None if M is MDS
    """
    result = find_singular_submatrix(M, p)
    if result is None:
        return None
    
    rows, cols = result
    k = len(rows)
    n = len(M)
    
    # Find kernel vector of the k×k submatrix
    sub = [[M[r][c] for c in cols] for r in rows]
    kernel_vec = find_kernel_vector(sub, p)
    if kernel_vec is None:
        return None
    
    # Extend by zeros
    f = [0] * n
    for i, c in enumerate(cols):
        f[c] = kernel_vec[i]
    
    Mf = mat_mul_vec(M, f, p)
    s = support_size(f, p) + support_size(Mf, p)
    return (f, s)


def find_kernel_vector(M: List[List[int]], p: int) -> Optional[List[int]]:
    """Find a nonzero vector in the kernel of M over GF(p).
    
    Returns None if M is invertible.
    """
    n = len(M)
    if n == 0:
        return None
    
    # Row reduce [M | I]
    A = [[M[i][j] % p for j in range(n)] for i in range(n)]
    
    # Gaussian elimination to find null space
    pivot_cols: List[int] = []
    for col in range(n):
        pivot = -1
        for row in range(len(pivot_cols), n):
            if A[row][col] != 0:
                pivot = row
                break
        if pivot == -1:
            continue
        
        # Swap
        r = len(pivot_cols)
        A[r], A[pivot] = A[pivot], A[r]
        
        # Scale pivot row
        inv_val = gf_inv(A[r][col], p)
        A[r] = [gf_mul(x, inv_val, p) for x in A[r]]
        
        # Eliminate
        for row in range(n):
            if row != r and A[row][col] != 0:
                factor = A[row][col]
                A[row] = [gf_add(A[row][j], -gf_mul(factor, A[r][j], p), p)
                          for j in range(n)]
        
        pivot_cols.append(col)
    
    if len(pivot_cols) == n:
        return None  # Full rank
    
    # Find a free variable
    free_cols = [j for j in range(n) if j not in pivot_cols]
    if not free_cols:
        return None
    
    free_col = free_cols[0]
    v = [0] * n
    v[free_col] = 1
    for i, pc in enumerate(pivot_cols):
        v[pc] = (-A[i][free_col]) % p
    
    return v


# ============================================================
# Algorithm 3: Uncertainty Profile Computation
# ============================================================

def uncertainty_profile(M: List[List[int]], p: int) -> Dict:
    """Compute the full uncertainty profile of M over GF(p).
    
    For each support size s, computes the minimum |supp(Mf)| over all
    nonzero f with |supp(f)| = s.
    
    Warning: Exponential in n (enumerates all vectors).
    
    Args:
        M: n×n matrix over GF(p)
        p: Prime modulus
        
    Returns:
        Dictionary with keys 'min_support_sum', 'profile', 'is_mds'
    """
    n = len(M)
    profile: Dict[int, int] = {}
    min_sum = n + 2
    
    # Enumerate nonzero vectors
    for code in range(1, p**n):
        f = [(code // (p**i)) % p for i in range(n)]
        Mf = mat_mul_vec(M, f, p)
        sf = support_size(f, p)
        sMf = support_size(Mf, p)
        
        if sf not in profile or sMf < profile[sf]:
            profile[sf] = sMf
        
        s = sf + sMf
        if s < min_sum:
            min_sum = s
    
    return {
        "min_support_sum": min_sum,
        "is_mds": min_sum >= n + 1,
        "profile": dict(sorted(profile.items())),
    }


# ============================================================
# Algorithm 4: MDS Matrix Construction
# ============================================================

def vandermonde_matrix(points: List[int], p: int) -> List[List[int]]:
    """Construct Vandermonde matrix V_{ij} = points[i]^j over GF(p).
    
    Args:
        points: Distinct evaluation points in GF(p)
        p: Prime modulus
        
    Returns:
        n×n Vandermonde matrix
    """
    n = len(points)
    return [[pow(points[i], j, p) for j in range(n)] for i in range(n)]


def cauchy_matrix(xs: List[int], ys: List[int], p: int) -> List[List[int]]:
    """Construct Cauchy matrix C_{ij} = 1/(x_i - y_j) over GF(p).
    
    Requires all x_i - y_j ≠ 0 in GF(p).
    
    Args:
        xs: Row parameters (distinct elements of GF(p))
        ys: Column parameters (distinct elements of GF(p), disjoint from xs)
        p: Prime modulus
        
    Returns:
        n×n Cauchy matrix
    """
    n = len(xs)
    return [[gf_inv((xs[i] - ys[j]) % p, p) for j in range(n)] for i in range(n)]


if __name__ == "__main__":
    # Quick test
    p = 7
    V = vandermonde_matrix([1, 2, 3, 4], p)
    print(f"Vandermonde [1,2,3,4] over GF(7) is MDS: {is_mds(V, p)}")
    
    profile = uncertainty_profile(V, p)
    print(f"Min support sum: {profile['min_support_sum']}")
    print(f"Profile: {profile['profile']}")
    
    # Non-MDS example
    M_bad = [[1, 1, 0], [0, 1, 1], [1, 0, 1]]
    print(f"\nTriangular-ish matrix over GF(3) is MDS: {is_mds(M_bad, 3)}")
    viol = find_uncertainty_violator(M_bad, 3)
    if viol:
        f, s = viol
        print(f"Violator: f={f}, support sum={s}")
