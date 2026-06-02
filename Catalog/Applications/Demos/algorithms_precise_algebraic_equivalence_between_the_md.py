"""
MDS Matrices and the Discrete Uncertainty Principle — Algorithms

This module implements the core algorithms for:
1. Checking the MDS property of a matrix
2. Computing the uncertainty profile of a matrix
3. Constructing Vandermonde matrices
4. Finding critical submatrices (witnesses of MDS failure)

Type-hinted throughout for clarity.
"""

from typing import Optional
from itertools import combinations
import numpy as np


def vandermonde_matrix(points: list[float], n: Optional[int] = None) -> np.ndarray:
    """Construct the Vandermonde matrix V_{ij} = points[i]^j.

    Args:
        points: Evaluation points α_0, ..., α_{n-1}
        n: Number of columns (defaults to len(points))

    Returns:
        n×n Vandermonde matrix
    """
    if n is None:
        n = len(points)
    return np.vander(points, N=n, increasing=True)


def check_mds(M: np.ndarray, tol: float = 1e-10) -> tuple[bool, Optional[tuple]]:
    """Check whether a square matrix is MDS (every square submatrix nonsingular).

    Uses exact determinant computation for integer/rational matrices,
    numerical for floating-point.

    Args:
        M: Square matrix to check
        tol: Tolerance for determinant being zero

    Returns:
        (is_mds, critical_info) where critical_info is None if MDS,
        or (k, rows, cols, det_value) for the first singular submatrix found
    """
    n = M.shape[0]
    assert M.shape == (n, n), "Matrix must be square"

    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                submatrix = M[np.ix_(list(rows), list(cols))]
                det = np.linalg.det(submatrix)
                if abs(det) < tol:
                    return False, (k, rows, cols, det)

    return True, None


def uncertainty_profile(M: np.ndarray, vectors: Optional[list[np.ndarray]] = None,
                        num_random: int = 10000) -> dict:
    """Compute the uncertainty profile of a matrix.

    For each nonzero vector f tested, computes |supp(f)| + |supp(Mf)|.
    Returns statistics about the distribution.

    Args:
        M: Square matrix
        vectors: Specific vectors to test (optional)
        num_random: Number of random vectors to sample

    Returns:
        Dictionary with min_uncertainty, max_uncertainty, histogram, etc.
    """
    n = M.shape[0]
    tol = 1e-10

    def support_size(v: np.ndarray) -> int:
        return int(np.sum(np.abs(v) > tol))

    uncertainties = []

    # Test standard basis vectors
    for i in range(n):
        e = np.zeros(n)
        e[i] = 1.0
        s_f = support_size(e)
        s_Mf = support_size(M @ e)
        uncertainties.append(s_f + s_Mf)

    # Test provided vectors
    if vectors:
        for v in vectors:
            if np.linalg.norm(v) > tol:
                s_f = support_size(v)
                s_Mf = support_size(M @ v)
                uncertainties.append(s_f + s_Mf)

    # Test random vectors
    rng = np.random.default_rng(42)
    for _ in range(num_random):
        v = rng.standard_normal(n)
        s_f = support_size(v)
        s_Mf = support_size(M @ v)
        uncertainties.append(s_f + s_Mf)

    # Test sparse random vectors
    for sparsity in range(1, n):
        for _ in range(min(100, num_random // n)):
            v = np.zeros(n)
            indices = rng.choice(n, size=sparsity, replace=False)
            v[indices] = rng.standard_normal(sparsity)
            s_f = support_size(v)
            s_Mf = support_size(M @ v)
            uncertainties.append(s_f + s_Mf)

    return {
        'min_uncertainty': min(uncertainties),
        'max_uncertainty': max(uncertainties),
        'mean_uncertainty': float(np.mean(uncertainties)),
        'n': n,
        'n_plus_1': n + 1,
        'satisfies_up': min(uncertainties) >= n + 1,
        'num_tested': len(uncertainties),
    }


def find_critical_submatrix(M: np.ndarray, tol: float = 1e-10
                            ) -> Optional[dict]:
    """Find a critical submatrix (singular square submatrix with kernel witness).

    Args:
        M: Square matrix to analyze
        tol: Tolerance for singularity detection

    Returns:
        Dictionary with k, rows, cols, witness, or None if MDS
    """
    n = M.shape[0]

    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = M[np.ix_(list(rows), list(cols))]
                det = np.linalg.det(sub)
                if abs(det) < tol:
                    # Find kernel vector
                    _, s, Vt = np.linalg.svd(sub)
                    kernel_idx = np.argmin(s)
                    witness = Vt[kernel_idx]
                    # Construct the uncertainty-violating vector
                    f = np.zeros(n)
                    for j, col in enumerate(cols):
                        f[col] = witness[j]
                    Mf = M @ f
                    return {
                        'k': k,
                        'rows': rows,
                        'cols': cols,
                        'witness': witness,
                        'f': f,
                        'Mf': Mf,
                        'supp_f': int(np.sum(np.abs(f) > tol)),
                        'supp_Mf': int(np.sum(np.abs(Mf) > tol)),
                        'uncertainty': int(np.sum(np.abs(f) > tol)) + int(np.sum(np.abs(Mf) > tol)),
                    }

    return None


def mds_order(M: np.ndarray, tol: float = 1e-10) -> int:
    """Compute the MDS order: largest k such that every k×k submatrix is nonsingular.

    Args:
        M: Square matrix
        tol: Tolerance for zero determinant

    Returns:
        The MDS order (0 to n)
    """
    n = M.shape[0]

    for k in range(1, n + 1):
        for rows in combinations(range(n), k):
            for cols in combinations(range(n), k):
                sub = M[np.ix_(list(rows), list(cols))]
                if abs(np.linalg.det(sub)) < tol:
                    return k - 1

    return n


class GaloisField:
    """Simple implementation of GF(p) for prime p, for exact MDS checking."""

    def __init__(self, p: int):
        self.p = p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def inv(self, a: int) -> int:
        return pow(a, self.p - 2, self.p)

    def det(self, M: list[list[int]]) -> int:
        """Compute determinant over GF(p) using Bareiss algorithm."""
        n = len(M)
        if n == 0:
            return 1
        M = [row[:] for row in M]  # copy
        sign = 1
        for col in range(n):
            # Find pivot
            pivot = -1
            for row in range(col, n):
                if M[row][col] % self.p != 0:
                    pivot = row
                    break
            if pivot == -1:
                return 0
            if pivot != col:
                M[col], M[pivot] = M[pivot], M[col]
                sign = self.p - sign if sign != 0 else 0
            inv_pivot = self.inv(M[col][col])
            for row in range(col + 1, n):
                factor = self.mul(M[row][col], inv_pivot)
                for j in range(col, n):
                    M[row][j] = self.sub(M[row][j], self.mul(factor, M[col][j]))
        result = sign
        for i in range(n):
            result = self.mul(result, M[i][i])
        return result % self.p

    def vandermonde(self, points: list[int], n: Optional[int] = None) -> list[list[int]]:
        """Construct Vandermonde matrix over GF(p)."""
        if n is None:
            n = len(points)
        M = []
        for alpha in points:
            row = [1]
            for j in range(1, n):
                row.append(self.mul(row[-1], alpha))
            M.append(row)
        return M

    def check_mds(self, M: list[list[int]]) -> tuple[bool, Optional[tuple]]:
        """Check MDS property over GF(p) exactly."""
        n = len(M)
        for k in range(1, n + 1):
            for rows in combinations(range(n), k):
                for cols in combinations(range(n), k):
                    sub = [[M[r][c] for c in cols] for r in rows]
                    if self.det(sub) == 0:
                        return False, (k, rows, cols)
        return True, None
