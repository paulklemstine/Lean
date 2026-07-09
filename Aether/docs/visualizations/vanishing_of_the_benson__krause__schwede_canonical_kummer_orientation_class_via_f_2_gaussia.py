from typing import List, Optional

Matrix = List[List[int]]
Vector = List[int]


def kummer_class(gram: Matrix) -> Vector:
    """Compute the Kummer/orientation class chi over F_2.

    chi is the unique solution of  M chi = diag(M)  over F_2, where M is the
    (nondegenerate, symmetric) Gram matrix of the cup-product form. Because
    x_i^2 = x_i over F_2, the squaring functional q(x) = x^T M x reduces to
    q(x) = sum_i M_ii x_i, i.e. it is represented by the diagonal of M.
    """
    n = len(gram)
    d: Vector = [gram[i][i] & 1 for i in range(n)]
    return _solve_f2(gram, d)


def _solve_f2(matrix: Matrix, rhs: Vector) -> Vector:
    n = len(matrix)
    aug: Matrix = [[matrix[i][j] & 1 for j in range(n)] + [rhs[i] & 1]
                   for i in range(n)]
    where: List[int] = [-1] * n
    row = 0
    for col in range(n):
        piv: Optional[int] = next(
            (r for r in range(row, n) if aug[r][col] == 1), None)
        if piv is None:
            continue
        aug[row], aug[piv] = aug[piv], aug[row]
        for r in range(n):
            if r != row and aug[r][col] == 1:
                aug[r] = [aug[r][k] ^ aug[row][k] for k in range(n + 1)]
        where[col] = row
        row += 1
    x: Vector = [0] * n
    for col in range(n):
        if where[col] != -1:
            x[col] = aug[where[col]][n]
    return x
