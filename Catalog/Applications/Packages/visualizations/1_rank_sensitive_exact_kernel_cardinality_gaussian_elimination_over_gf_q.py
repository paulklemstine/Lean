#!/usr/bin/env python3
"""
Algorithms for finite-field linear algebra and rank-sensitive verification.

Implements:
1. Gaussian elimination over GF(q) with rank computation.
2. Kernel basis computation over GF(q).
3. Rank-sensitive Freivalds verification with exact probability tracking.
4. Affine solution enumeration for M·r = b.

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Optional
import numpy as np


class GaloisField:
    """Arithmetic operations in GF(q) for prime q.

    All operations return values in {0, 1, ..., q-1}.

    Parameters
    ----------
    q : int
        A prime number defining the field GF(q).
    """

    def __init__(self, q: int):
        if q < 2:
            raise ValueError(f"q must be >= 2, got {q}")
        self.q = q

    def add(self, a: int, b: int) -> int:
        """Addition in GF(q). O(1)."""
        return (a + b) % self.q

    def sub(self, a: int, b: int) -> int:
        """Subtraction in GF(q). O(1)."""
        return (a - b) % self.q

    def mul(self, a: int, b: int) -> int:
        """Multiplication in GF(q). O(log q) via modular arithmetic."""
        return (a * b) % self.q

    def inv(self, a: int) -> int:
        """Multiplicative inverse in GF(q) using Fermat's little theorem.

        Time: O(log q) via fast exponentiation.
        Requires: a ≠ 0.
        """
        if a % self.q == 0:
            raise ZeroDivisionError("Cannot invert 0 in GF(q)")
        return pow(a, self.q - 2, self.q)

    def neg(self, a: int) -> int:
        """Additive inverse in GF(q). O(1)."""
        return (-a) % self.q


def gaussian_elimination(M: np.ndarray, q: int) -> Tuple[np.ndarray, int, List[int]]:
    """Perform Gaussian elimination over GF(q).

    Returns the row echelon form, rank, and list of pivot column indices.

    Parameters
    ----------
    M : np.ndarray
        An m×n integer matrix with entries in {0, ..., q-1}.
    q : int
        Prime field characteristic.

    Returns
    -------
    rref : np.ndarray
        Reduced row echelon form over GF(q).
    rank : int
        Rank of M over GF(q).
    pivots : List[int]
        Indices of pivot columns.

    Time Complexity: O(m·n·min(m,n))
    Space Complexity: O(m·n)
    """
    gf = GaloisField(q)
    R = M.copy() % q
    m, n = R.shape
    rank = 0
    pivots = []

    for col in range(n):
        # Find pivot row
        pivot_row = None
        for row in range(rank, m):
            if R[row, col] % q != 0:
                pivot_row = row
                break
        if pivot_row is None:
            continue

        # Swap pivot row into position
        R[[rank, pivot_row]] = R[[pivot_row, rank]]
        pivots.append(col)

        # Scale pivot row so pivot element is 1
        pivot_inv = gf.inv(int(R[rank, col]))
        R[rank] = np.array([gf.mul(int(x), pivot_inv) for x in R[rank]])

        # Eliminate all other entries in this column
        for row in range(m):
            if row != rank and R[row, col] % q != 0:
                factor = int(R[row, col])
                R[row] = np.array([gf.sub(int(R[row, j]), gf.mul(factor, int(R[rank, j])))
                                   for j in range(n)])

        rank += 1

    return R, rank, pivots


def kernel_basis(M: np.ndarray, q: int) -> List[np.ndarray]:
    """Compute a basis for ker(M) over GF(q).

    Parameters
    ----------
    M : np.ndarray
        An m×n matrix over GF(q).
    q : int
        Prime field characteristic.

    Returns
    -------
    basis : List[np.ndarray]
        A list of (p - rank(M)) linearly independent vectors in ker(M).

    Time Complexity: O(m·n·min(m,n) + n·(n-rank))
    Space Complexity: O(n·(n-rank))

    Example
    -------
    >>> M = np.array([[1, 1, 0], [0, 1, 1]])  # over GF(2)
    >>> basis = kernel_basis(M, 2)
    >>> len(basis)  # p - rank = 3 - 2 = 1
    1
    """
    gf = GaloisField(q)
    m, n = M.shape
    rref, rank, pivots = gaussian_elimination(M, q)

    free_vars = [j for j in range(n) if j not in pivots]
    basis = []

    for fv in free_vars:
        v = np.zeros(n, dtype=int)
        v[fv] = 1
        for i, pv in enumerate(pivots):
            v[pv] = gf.neg(int(rref[i, fv]))
        basis.append(v % q)

    return basis


def rank_sensitive_freivalds(
    A: np.ndarray, B: np.ndarray, C: np.ndarray, q: int,
    num_trials: int = 100
) -> Tuple[bool, int, float, float]:
    """Rank-sensitive Freivalds verification of AB = C over GF(q).

    Computes the error matrix E = AB - C, determines its rank,
    and predicts the exact false acceptance probability q^{-rank(E)}.

    Also runs random trials to empirically estimate the probability.

    Parameters
    ----------
    A : np.ndarray, shape (m, n)
    B : np.ndarray, shape (n, p)
    C : np.ndarray, shape (m, p)
    q : int
        Prime field characteristic.
    num_trials : int
        Number of random vectors to test.

    Returns
    -------
    correct : bool
        True if AB = C over GF(q).
    rank_E : int
        Rank of the error matrix E = AB - C.
    theoretical_prob : float
        Exact false acceptance probability q^{-rank(E)}.
    empirical_prob : float
        Fraction of random vectors r where Er = 0.

    Time Complexity: O(m·n·p + num_trials·(m·p))
    """
    gf = GaloisField(q)
    m, n = A.shape
    _, p = B.shape

    # Compute AB over GF(q)
    AB = np.zeros((m, p), dtype=int)
    for i in range(m):
        for j in range(p):
            s = 0
            for k in range(n):
                s = gf.add(s, gf.mul(int(A[i, k]), int(B[k, j])))
            AB[i, j] = s

    E = (AB - C) % q
    _, rank_E, _ = gaussian_elimination(E, q)

    correct = (rank_E == 0)
    theoretical_prob = q ** (-rank_E) if rank_E > 0 else 1.0

    # Empirical test
    accept_count = 0
    for _ in range(num_trials):
        r = np.random.randint(0, q, size=p)
        Er = np.zeros(m, dtype=int)
        for i in range(m):
            s = 0
            for j in range(p):
                s = gf.add(s, gf.mul(int(E[i, j]), int(r[j])))
            Er[i] = s
        if np.all(Er == 0):
            accept_count += 1

    empirical_prob = accept_count / num_trials

    return correct, rank_E, theoretical_prob, empirical_prob


def affine_solution_count(M: np.ndarray, b: np.ndarray, q: int) -> int:
    """Compute |{r : M·r = b}| using the exact cardinality formula.

    Uses rank computation to determine the answer in O(m·n·min(m,n)) time,
    without enumerating all q^p vectors.

    Parameters
    ----------
    M : np.ndarray, shape (m, p)
    b : np.ndarray, shape (m,)
    q : int

    Returns
    -------
    count : int
        The exact number of solutions, either q^(p - rank(M)) or 0.

    Time Complexity: O(m·n·min(m,n))
    """
    m, p = M.shape
    _, rank_M, _ = gaussian_elimination(M, q)

    # Check if b is in the column space by augmenting [M | b]
    augmented = np.column_stack([M, b.reshape(-1, 1)])
    _, rank_aug, _ = gaussian_elimination(augmented, q)

    if rank_aug > rank_M:
        return 0  # b is not in the image
    else:
        return q ** (p - rank_M)


# ─── Example Usage ─────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Kernel Basis Computation ===")
    M = np.array([[1, 0, 1, 0],
                  [0, 1, 0, 1],
                  [1, 1, 1, 1]])
    q = 2
    basis = kernel_basis(M, q)
    _, rank, _ = gaussian_elimination(M, q)
    print(f"M = {M.tolist()} over GF({q})")
    print(f"rank(M) = {rank}")
    print(f"Kernel dimension = {M.shape[1] - rank}")
    print(f"Kernel basis vectors:")
    for v in basis:
        print(f"  {v.tolist()}")
    print(f"|ker(M)| = {q}^{M.shape[1] - rank} = {q**(M.shape[1] - rank)}")
    print()

    print("=== Rank-Sensitive Freivalds Verification ===")
    A = np.array([[1, 2], [3, 4]])
    B = np.array([[1, 0, 1], [0, 1, 1]])
    # Correct product
    C_correct = np.array([[1, 2, 3], [3, 4, 7]])  # AB mod 5
    # Wrong product (rank-1 error)
    C_wrong = np.array([[2, 2, 3], [3, 4, 7]])  # off by 1 in (0,0)

    for label, C in [("Correct C", C_correct), ("Wrong C", C_wrong)]:
        correct, rank_E, th_prob, emp_prob = rank_sensitive_freivalds(
            A, B, C, q=5, num_trials=10000
        )
        print(f"{label}: correct={correct}, rank(E)={rank_E}")
        print(f"  Theoretical Pr[accept] = {th_prob:.6f}")
        print(f"  Empirical Pr[accept]   = {emp_prob:.6f}")
    print()

    print("=== Affine Solution Counting ===")
    M = np.array([[1, 0, 1], [0, 1, 2]])
    q = 3
    for b in [[0, 0], [1, 0], [1, 2], [0, 1]]:
        b_arr = np.array(b)
        count = affine_solution_count(M, b_arr, q)
        print(f"  |{{r : M·r = {b}}}| = {count}")
