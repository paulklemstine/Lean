"""Algorithm implementations for the Tropical Hodge Theory package.

These are the constructive routines described in the research paper:
weighted-coboundary construction, the codifferential and Laplacians,
Dirichlet-energy evaluation, harmonic (Hodge) projection via the normal
equations, and spectral computation of the harmonic dimension / spectral gap.
Pure Python, type-hinted, no third-party dependencies.
"""

from __future__ import annotations

from typing import List, Sequence, Tuple

Matrix = List[List[float]]
Vector = List[float]


def transpose(a: Matrix) -> Matrix:
    """Transpose of a matrix."""
    return [list(col) for col in zip(*a)] if a else []


def matmul(a: Matrix, b: Matrix) -> Matrix:
    """Matrix product a @ b."""
    bt = transpose(b)
    return [[sum(x * y for x, y in zip(r, c)) for c in bt] for r in a]


def matvec(a: Matrix, v: Vector) -> Vector:
    """Matrix-vector product a @ v."""
    return [sum(aij * vj for aij, vj in zip(row, v)) for row in a]


def diag(d: Sequence[float]) -> Matrix:
    """Diagonal matrix from a sequence."""
    n = len(d)
    return [[d[i] if i == j else 0.0 for j in range(n)] for i in range(n)]


def weighted_ip(w: Vector, u: Vector, v: Vector) -> float:
    """Weighted inner product sum_i w_i u_i v_i."""
    return sum(wi * ui * vi for wi, ui, vi in zip(w, u, v))


def codifferential(d: Matrix, src_weight: Vector, tgt_weight: Vector) -> Matrix:
    """Build delta = diag(1/src) @ d^T @ diag(tgt), the weighted adjoint of d.

    Complexity: O(n*m) to form d^T plus O(n*m) for the two diagonal scalings,
    i.e. O(n*m) overall (diagonal multiplies are linear, not cubic).
    """
    inv_src = [1.0 / w for w in src_weight]
    dt = transpose(d)  # m x n
    # delta[j][i] = inv_src[j] * d[i][j] * tgt[i]
    return [[inv_src[j] * dt[j][i] * tgt_weight[i] for i in range(len(d))]
            for j in range(len(dt))]


def dirichlet_energy(d: Matrix, tgt_weight: Vector, v: Vector) -> float:
    """Return <d v, d v>_tgt, the (non-negative) Dirichlet energy of v.

    By the energy identity this equals <Lap_up v, v>_src. Complexity O(nnz(d)+n).
    """
    dv = matvec(d, v)
    return weighted_ip(tgt_weight, dv, dv)


def solve_spd(a: Matrix, b: Vector, ridge: float = 1e-10) -> Vector:
    """Solve (A + ridge*I) x = b for a symmetric positive-(semi)definite A
    via Gaussian elimination with partial pivoting. The tiny ridge term
    regularizes the (possibly singular) up-Laplacian so a least-squares-style
    particular solution is returned. Complexity O(k^3) for a k x k system.
    """
    k = len(a)
    m = [[a[i][j] + (ridge if i == j else 0.0) for j in range(k)] + [b[i]]
         for i in range(k)]
    for col in range(k):
        piv = max(range(col, k), key=lambda r: abs(m[r][col]))
        m[col], m[piv] = m[piv], m[col]
        pivot = m[col][col]
        if abs(pivot) < 1e-15:
            continue
        for r in range(k):
            if r != col and abs(m[r][col]) > 1e-15:
                f = m[r][col] / pivot
                m[r] = [m[r][c] - f * m[col][c] for c in range(k + 1)]
    return [m[i][k] / m[i][i] if abs(m[i][i]) > 1e-15 else 0.0 for i in range(k)]


def hodge_projection(d: Matrix, src_weight: Vector, tgt_weight: Vector,
                     x: Vector) -> Tuple[Vector, Vector]:
    """Compute the orthogonal Hodge decomposition x = (d u) + h with delta h = 0.

    Steps (the normal equations of the research paper, Section 5.2):
        b   = delta x                       (right-hand side, length m)
        u   solves  Lap_up u = b            (Lap_up = delta @ d, SPSD)
        flowing = d u ;  harmonic = x - flowing
    Returns (flowing, harmonic). Complexity dominated by the m x m solve, O(m^3).
    """
    delta = codifferential(d, src_weight, tgt_weight)
    lap_up = matmul(delta, d)
    b = matvec(delta, x)
    u = solve_spd(lap_up, b)
    flowing = matvec(d, u)
    harmonic = [xi - fi for xi, fi in zip(x, flowing)]
    return flowing, harmonic
