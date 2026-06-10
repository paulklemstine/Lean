"""
Smith Normal Form and Rational Metric Graph Algorithms

Exact arithmetic algorithms for computing invariant factors of
integer-scaled weighted Laplacians on rational metric graphs.

Application keywords: tropical Jacobian, Smith normal form, metric graph,
chip-firing, critical group, weighted Laplacian, Matrix-Tree theorem.
"""

from __future__ import annotations
from fractions import Fraction
from math import gcd
from functools import reduce
from typing import List, Tuple, Dict, Optional


def lcm(a: int, b: int) -> int:
    """Least common multiple of two positive integers."""
    return abs(a * b) // gcd(a, b) if a and b else 0


def common_denominator(fractions_list: List[Fraction]) -> int:
    """Find a common denominator for a list of fractions.

    Args:
        fractions_list: List of Fraction objects.

    Returns:
        Positive integer D such that D * q is an integer for all q.
    """
    if not fractions_list:
        return 1
    return reduce(lcm, [f.denominator for f in fractions_list])


def weighted_laplacian_Q(
    n: int,
    adj: List[Tuple[int, int]],
    lengths: Dict[Tuple[int, int], Fraction]
) -> List[List[Fraction]]:
    """Compute the weighted Laplacian matrix over ℚ.

    Args:
        n: Number of vertices (0, 1, ..., n-1).
        adj: List of edges as (i, j) pairs.
        lengths: Dict mapping edge (i,j) -> Fraction length.

    Returns:
        n×n matrix as list of lists of Fractions.

    Example:
        >>> L = weighted_laplacian_Q(2, [(0,1)], {(0,1): Fraction(3,1)})
        >>> L[0][0]
        Fraction(1, 3)
    """
    L = [[Fraction(0)] * n for _ in range(n)]
    for (i, j) in adj:
        c = Fraction(1, 1) / lengths[(i, j)]
        L[i][j] -= c
        L[j][i] -= c
        L[i][i] += c
        L[j][j] += c
    return L


def reduced_laplacian(L: List[List[Fraction]], base: int = 0) -> List[List[Fraction]]:
    """Compute the reduced Laplacian by deleting row/column of base vertex.

    Args:
        L: Full Laplacian matrix.
        base: Index of the base vertex to delete.

    Returns:
        (n-1)×(n-1) reduced Laplacian.
    """
    n = len(L)
    indices = [i for i in range(n) if i != base]
    return [[L[i][j] for j in indices] for i in indices]


def scale_to_integer(M: List[List[Fraction]]) -> Tuple[int, List[List[int]]]:
    """Scale a rational matrix to integer entries.

    Args:
        M: Matrix with Fraction entries.

    Returns:
        (D, M_int) where D is the common denominator and M_int = D * M.
    """
    all_entries = [M[i][j] for i in range(len(M)) for j in range(len(M[0]))]
    D = common_denominator(all_entries)
    M_int = [[int(D * M[i][j]) for j in range(len(M[0]))] for i in range(len(M))]
    return D, M_int


def matrix_det(M: List[List[int]]) -> int:
    """Compute determinant of an integer matrix using Fraction arithmetic.

    Uses Gaussian elimination over ℚ for exact computation.

    Args:
        M: Square integer matrix.

    Returns:
        Integer determinant.

    Complexity: O(n³) arithmetic operations.
    """
    n = len(M)
    A = [[Fraction(M[i][j]) for j in range(n)] for i in range(n)]
    det = Fraction(1)
    for col in range(n):
        pivot = None
        for row in range(col, n):
            if A[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return 0
        if pivot != col:
            A[col], A[pivot] = A[pivot], A[col]
            det = -det
        det *= A[col][col]
        for row in range(col + 1, n):
            factor = A[row][col] / A[col][col]
            for j in range(col, n):
                A[row][j] -= factor * A[col][j]
    return int(det)


def smith_normal_form(M: List[List[int]]) -> Tuple[List[int], List[List[int]], List[List[int]]]:
    """Compute the Smith Normal Form of an integer matrix.

    Given M ∈ ℤ^{m×n}, find unimodular U, V and diagonal d₁|d₂|...|dᵣ
    such that U * M * V = diag(d₁, ..., dᵣ, 0, ..., 0).

    Args:
        M: Integer matrix.

    Returns:
        (diag, U, V) where diag is the list of diagonal entries.

    Complexity: O(n³ log(max_entry)) arithmetic operations.

    Example:
        >>> diag, U, V = smith_normal_form([[2, 4], [6, 8]])
        >>> diag
        [2, 4]
    """
    m = len(M)
    n = len(M[0]) if m > 0 else 0

    # Work with copies
    A = [row[:] for row in M]
    # Track U and V as identity matrices
    U = [[1 if i == j else 0 for j in range(m)] for i in range(m)]
    V = [[1 if i == j else 0 for j in range(n)] for i in range(n)]

    def swap_rows(mat, i, j):
        mat[i], mat[j] = mat[j], mat[i]

    def swap_cols(mat, i, j):
        for row in mat:
            row[i], row[j] = row[j], row[i]

    def add_row_multiple(mat, target, source, factor):
        for j in range(len(mat[0])):
            mat[target][j] += factor * mat[source][j]

    def add_col_multiple(mat, target, source, factor):
        for row in mat:
            row[target] += factor * row[source]

    def negate_row(mat, i):
        for j in range(len(mat[0])):
            mat[i][j] = -mat[i][j]

    r = min(m, n)
    for k in range(r):
        # Find pivot
        found = False
        for i in range(k, m):
            for j in range(k, n):
                if A[i][j] != 0:
                    if not found or abs(A[i][j]) < abs(A[k][k]):
                        if i != k:
                            swap_rows(A, k, i)
                            swap_rows(U, k, i)
                        if j != k:
                            swap_cols(A, k, j)
                            swap_cols(V, k, j)
                        found = True
        if not found:
            break

        # Ensure all entries in row k and col k are divisible by A[k][k]
        changed = True
        while changed:
            changed = False
            # Eliminate column
            for i in range(k + 1, m):
                if A[i][k] != 0:
                    q = A[i][k] // A[k][k]
                    add_row_multiple(A, i, k, -q)
                    add_row_multiple(U, i, k, -q)
                    if A[i][k] != 0:
                        swap_rows(A, k, i)
                        swap_rows(U, k, i)
                        changed = True
                        break
            if changed:
                continue
            # Eliminate row
            for j in range(k + 1, n):
                if A[k][j] != 0:
                    q = A[k][j] // A[k][k]
                    add_col_multiple(A, j, k, -q)
                    add_col_multiple(V, j, k, -q)
                    if A[k][j] != 0:
                        swap_cols(A, k, j)
                        swap_cols(V, k, j)
                        changed = True
                        break

        # Make diagonal entry positive
        if A[k][k] < 0:
            negate_row(A, k)
            negate_row(U, k)

    diag = [A[i][i] if i < min(m, n) else 0 for i in range(min(m, n))]

    # Ensure divisibility chain: d_i | d_{i+1}
    changed = True
    while changed:
        changed = False
        for i in range(len(diag) - 1):
            if diag[i] != 0 and diag[i + 1] != 0 and diag[i + 1] % diag[i] != 0:
                g = gcd(diag[i], diag[i + 1])
                l = abs(diag[i] * diag[i + 1]) // g
                diag[i] = g
                diag[i + 1] = l
                changed = True

    return diag, U, V


def cycle_graph_laplacian(lengths: List[Fraction]) -> List[List[Fraction]]:
    """Construct the weighted Laplacian of a cycle graph.

    Args:
        lengths: Edge lengths ℓ₁, ℓ₂, ..., ℓₙ for the cycle
                 with edges 0-1, 1-2, ..., (n-1)-0.

    Returns:
        n×n weighted Laplacian matrix over ℚ.
    """
    n = len(lengths)
    adj = [(i, (i + 1) % n) for i in range(n)]
    length_dict = {(i, (i + 1) % n): lengths[i] for i in range(n)}
    return weighted_laplacian_Q(n, adj, length_dict)


def weighted_tree_number_cycle(lengths: List[Fraction]) -> Fraction:
    """Compute the weighted tree number of a cycle graph analytically.

    For Cₙ with lengths ℓ₁,...,ℓₙ:
        τ(Cₙ) = (∏ 1/ℓᵢ) · (∑ ℓᵢ)

    Args:
        lengths: Edge lengths.

    Returns:
        Exact weighted tree number as Fraction.
    """
    prod_inv = Fraction(1)
    for l in lengths:
        prod_inv *= Fraction(1, 1) / l
    sum_lengths = sum(lengths, Fraction(0))
    return prod_inv * sum_lengths


def theta_graph_laplacian(
    lengths_path1: List[Fraction],
    lengths_path2: List[Fraction],
    lengths_path3: List[Fraction]
) -> Tuple[int, List[Tuple[int, int]], Dict[Tuple[int, int], Fraction]]:
    """Construct a theta graph from three internally disjoint paths.

    A theta graph has two distinguished vertices s, t connected by
    three internally disjoint paths.

    Args:
        lengths_path1, 2, 3: Edge lengths along each path.

    Returns:
        (n, adj, lengths) tuple for use with weighted_laplacian_Q.
    """
    # Vertices: 0 = s, 1 = t, then internal vertices
    n1, n2, n3 = len(lengths_path1), len(lengths_path2), len(lengths_path3)
    # Path i has (n_i - 1) internal vertices
    n = 2 + max(0, n1 - 1) + max(0, n2 - 1) + max(0, n3 - 1)
    adj = []
    lengths = {}

    def add_path(path_lengths, start_internal_idx):
        """Add a path from vertex 0 to vertex 1."""
        k = len(path_lengths)
        if k == 1:
            adj.append((0, 1))
            lengths[(0, 1)] = path_lengths[0]
        else:
            # 0 -> internal[0] -> internal[1] -> ... -> internal[k-2] -> 1
            internals = list(range(start_internal_idx, start_internal_idx + k - 1))
            adj.append((0, internals[0]))
            lengths[(0, internals[0])] = path_lengths[0]
            for i in range(len(internals) - 1):
                adj.append((internals[i], internals[i + 1]))
                lengths[(internals[i], internals[i + 1])] = path_lengths[i + 1]
            adj.append((internals[-1], 1))
            lengths[(internals[-1], 1)] = path_lengths[-1]

    idx = 2
    add_path(lengths_path1, idx)
    idx += max(0, n1 - 1)
    add_path(lengths_path2, idx)
    idx += max(0, n2 - 1)
    add_path(lengths_path3, idx)

    return n, adj, lengths


def verify_product_invariants_eq_det(M_int: List[List[int]]) -> Dict:
    """Verify that product of SNF invariants equals |det(M)|.

    Args:
        M_int: Integer matrix.

    Returns:
        Dict with det, invariant_factors, product, verified fields.
    """
    det_val = matrix_det(M_int)
    diag, U, V = smith_normal_form(M_int)
    product = 1
    for d in diag:
        product *= d

    return {
        "det": det_val,
        "abs_det": abs(det_val),
        "invariant_factors": diag,
        "product": product,
        "abs_product": abs(product),
        "verified": abs(product) == abs(det_val)
    }


if __name__ == "__main__":
    # Example: Cycle graph C₃ with rational lengths
    lengths = [Fraction(1, 2), Fraction(1, 3), Fraction(1, 5)]
    L = cycle_graph_laplacian(lengths)
    L_red = reduced_laplacian(L)
    D, M = scale_to_integer(L_red)

    print("=== Cycle Graph C₃ ===")
    print(f"Edge lengths: {lengths}")
    print(f"Common denominator D = {D}")
    print(f"Reduced Laplacian (rational):")
    for row in L_red:
        print(f"  {row}")
    print(f"Integer-scaled matrix (D * L_red):")
    for row in M:
        print(f"  {row}")

    result = verify_product_invariants_eq_det(M)
    print(f"Determinant: {result['det']}")
    print(f"Invariant factors: {result['invariant_factors']}")
    print(f"Product = |det|: {result['verified']}")

    # Weighted tree number
    tau = weighted_tree_number_cycle(lengths)
    print(f"Weighted tree number τ = {tau}")
    print(f"D^(n-1) * τ = {D**(len(lengths)-1) * tau} (should match det)")
