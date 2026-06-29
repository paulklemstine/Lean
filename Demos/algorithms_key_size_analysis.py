#!/usr/bin/env python3
"""
Tropical Matrix Factorization: Algorithms

Complete implementations with complexity analysis:
1. Tropical matrix multiplication - O(nmr)
2. CNF-to-tropical reduction - O(cv)
3. Assignment extraction from selection - O(v)
4. Greedy rectangle cover - O(nm·r)
5. Tropical rank upper bound via greedy cover - O(n²m²)
"""

import numpy as np
from itertools import product as cartprod
from typing import List, Tuple, Set, Optional

INF = float('inf')
TropMatrix = np.ndarray


def trop_mat_mul(A: TropMatrix, B: TropMatrix) -> TropMatrix:
    """
    Tropical matrix multiplication: (A⊗B)(i,j) = min_k(A(i,k) + B(k,j)).

    Time:  O(n·m·r) where A is n×r and B is r×m
    Space: O(n·m) for the output

    >>> A = np.array([[0, INF], [INF, 0]])
    >>> B = np.array([[1, 2], [3, 4]])
    >>> trop_mat_mul(A, B)
    array([[1., 2.], [3., 4.]])
    """
    n, r = A.shape
    r2, m = B.shape
    assert r == r2, f"Dimension mismatch: {r} ≠ {r2}"

    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for k in range(r):
                if A[i, k] != INF and B[k, j] != INF:
                    C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def cnf_to_tropical_matrix(
    clauses: List[List[Tuple[str, int]]],
    num_vars: int
) -> TropMatrix:
    """
    Convert CNF formula to tropical incidence matrix.

    Each literal (sign, var_idx) maps to column 2*var_idx (positive)
    or 2*var_idx+1 (negative). Entry is 0 if literal in clause, INF otherwise.

    Time:  O(c·v) where c = len(clauses), v = num_vars
    Space: O(c·2v) for the output matrix

    Args:
        clauses: List of clauses, each a list of (sign, var_idx) pairs
                 sign is '+' for positive, '-' for negative
        num_vars: Number of variables

    Returns:
        {0, INF} matrix of size c × 2v
    """
    c = len(clauses)
    m = 2 * num_vars
    M = np.full((c, m), INF)

    for i, clause in enumerate(clauses):
        for sign, var_idx in clause:
            col = 2 * var_idx if sign == '+' else 2 * var_idx + 1
            if 0 <= col < m:
                M[i, col] = 0

    return M


def assignment_to_selection(
    assignment: List[bool],
    num_vars: int
) -> List[int]:
    """
    Convert Boolean assignment to consistent column selection.

    If variable k is True, select column 2k; if False, select 2k+1.

    Time:  O(v)
    Space: O(v)

    Args:
        assignment: Boolean values for each variable
        num_vars: Number of variables

    Returns:
        List of selected column indices
    """
    return [2 * k if assignment[k] else 2 * k + 1
            for k in range(num_vars)]


def selection_to_assignment(
    selection: List[int],
    num_vars: int
) -> List[bool]:
    """
    Extract Boolean assignment from column selection.

    Even column index → True, Odd → False.

    Time:  O(v)
    Space: O(v)
    """
    return [selection[k] % 2 == 0 for k in range(num_vars)]


def verify_selection_covers(
    M: TropMatrix,
    selection: List[int]
) -> bool:
    """
    Check if a column selection covers all rows of a tropical matrix.

    A selection covers row i if M[i, sel[k]] = 0 for some k.

    Time:  O(c·v) where c = rows, v = len(selection)
    """
    c = M.shape[0]
    for i in range(c):
        if not any(M[i, s] == 0 for s in selection):
            return False
    return True


def greedy_rectangle_cover(
    M: TropMatrix
) -> List[Tuple[Set[int], Set[int]]]:
    """
    Greedy algorithm for rectangle cover of zero entries in a {0,INF} matrix.

    Repeatedly finds the largest monochromatic rectangle covering
    uncovered zero entries.

    Time:  O(n²·m²·r) where r is the cover size
    Space: O(n·m)

    Returns:
        List of (row_set, col_set) pairs forming an exact rectangle cover
    """
    n, m = M.shape
    uncovered = {(i, j) for i in range(n) for j in range(m) if M[i, j] == 0}
    rectangles = []

    while uncovered:
        best_rect = None
        best_count = 0

        # Try all pairs of a zero entry as seed
        seed = next(iter(uncovered))
        i0, j0 = seed

        # Expand from seed: find maximal rectangle
        # Try all possible row/column subsets (greedy heuristic)
        for i_start in range(n):
            for j_start in range(m):
                if (i_start, j_start) not in uncovered:
                    continue
                # Expand rows
                rows = {i_start}
                cols = {j_start}

                # Add columns that work with current rows
                for j in range(m):
                    if all((i, j) in uncovered or M[i, j] == 0
                           for i in rows):
                        cols.add(j)

                # Add rows that work with current columns
                for i in range(n):
                    if all(M[i, j] == 0 for j in cols):
                        rows.add(i)

                # Verify and count
                rect_entries = {(i, j) for i in rows for j in cols if M[i, j] == 0}
                valid = all(M[i, j] == 0 for i in rows for j in cols)
                if valid and len(rect_entries & uncovered) > best_count:
                    best_rect = (rows, cols)
                    best_count = len(rect_entries & uncovered)

        if best_rect is None:
            # Fallback: single entry
            entry = next(iter(uncovered))
            best_rect = ({entry[0]}, {entry[1]})

        rows, cols = best_rect
        for i in rows:
            for j in cols:
                uncovered.discard((i, j))
        rectangles.append(best_rect)

    return rectangles


def tropical_rank_upper_bound(M: TropMatrix) -> int:
    """
    Compute an upper bound on the tropical rank of a {0,INF} matrix
    using greedy rectangle cover.

    Time:  O(n²·m²) amortized
    Space: O(n·m)

    Returns:
        Upper bound on tropical rank (= size of greedy cover)
    """
    cover = greedy_rectangle_cover(M)
    return len(cover)


def construct_factorization_from_cover(
    cover: List[Tuple[Set[int], Set[int]]],
    n: int, m: int
) -> Tuple[TropMatrix, TropMatrix]:
    """
    Construct tropical factor matrices from a rectangle cover.

    Given cover with r rectangles, produces A (n×r) and B (r×m)
    such that A ⊗ B reconstructs the covered pattern.

    Time:  O(r·(n+m))
    Space: O(n·r + r·m)
    """
    r = len(cover)
    A = np.full((n, r), INF)
    B = np.full((r, m), INF)

    for k, (rows, cols) in enumerate(cover):
        for i in rows:
            A[i, k] = 0
        for j in cols:
            B[k, j] = 0

    return A, B


def security_dimensions(security_param: int) -> Tuple[int, int, int]:
    """
    Compute matrix dimensions for a given security parameter.

    Returns (n, m, r) where n = m = 2·λ², r = λ².

    Time:  O(1)
    """
    lam_sq = security_param ** 2
    return 2 * lam_sq, 2 * lam_sq, lam_sq


# ─────────────────────────────────────────────────────────────
# Self-test
# ─────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Running algorithm self-tests...\n")

    # Test 1: Tropical matrix multiplication
    I = np.array([[0, INF], [INF, 0]])
    M = np.array([[1, 2], [3, 4]])
    assert np.array_equal(trop_mat_mul(I, M), M), "Identity test failed"
    print("✓ Tropical matrix multiplication (identity)")

    # Test 2: CNF to tropical matrix
    clauses = [[('+', 0), ('+', 1)], [('-', 0), ('+', 2)]]
    M = cnf_to_tropical_matrix(clauses, 3)
    assert M.shape == (2, 6), "Shape test failed"
    assert M[0, 0] == 0 and M[0, 2] == 0, "Literal encoding failed"
    assert M[0, 1] == INF, "Non-literal should be INF"
    print("✓ CNF-to-tropical reduction")

    # Test 3: Assignment-selection roundtrip
    assign = [True, False, True]
    sel = assignment_to_selection(assign, 3)
    assign2 = selection_to_assignment(sel, 3)
    assert assign == assign2, "Roundtrip failed"
    print("✓ Assignment ↔ selection roundtrip")

    # Test 4: Selection coverage
    clauses = [[('+', 0), ('+', 1)], [('-', 0), ('+', 2)]]
    M = cnf_to_tropical_matrix(clauses, 3)
    sel_good = assignment_to_selection([True, True, True], 3)  # x₁=T, x₂=T, x₃=T
    assert verify_selection_covers(M, sel_good), "Should cover"
    print("✓ Selection coverage verification")

    # Test 5: Rectangle cover
    M_zt = np.array([[0, 0, INF], [0, INF, 0], [INF, 0, 0]])
    cover = greedy_rectangle_cover(M_zt)
    A, B = construct_factorization_from_cover(cover, 3, 3)
    M_recon = trop_mat_mul(A, B)
    assert np.array_equal(M_zt, M_recon), "Reconstruction failed"
    print(f"✓ Rectangle cover (size {len(cover)}) → factorization")

    # Test 6: Security dimensions
    n, m, r = security_dimensions(128)
    assert n == 2 * 128**2 and m == 2 * 128**2 and r == 128**2
    print(f"✓ Security dimensions for λ=128: n={n}, m={m}, r={r}")

    print("\nAll self-tests passed!")
