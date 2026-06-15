from __future__ import annotations
from itertools import product

Matrix = list[list[complex]]


def matrix_rank(mat: Matrix, tol: float = 1e-9) -> int:
    """Rank of a complex matrix via Gaussian elimination with partial pivoting."""
    rows = [list(map(complex, r)) for r in mat]
    if not rows or not rows[0]:
        return 0
    n_rows, n_cols, rank, pivot_row = len(rows), len(rows[0]), 0, 0
    for col in range(n_cols):
        if pivot_row >= n_rows:
            break
        best, best_mag = pivot_row, abs(rows[pivot_row][col])
        for r in range(pivot_row + 1, n_rows):
            if abs(rows[r][col]) > best_mag:
                best, best_mag = r, abs(rows[r][col])
        if best_mag <= tol:
            continue
        rows[pivot_row], rows[best] = rows[best], rows[pivot_row]
        piv = rows[pivot_row][col]
        for r in range(n_rows):
            if r == pivot_row:
                continue
            f = rows[r][col] / piv
            if f != 0:
                for c in range(col, n_cols):
                    rows[r][c] -= f * rows[pivot_row][c]
        pivot_row += 1
        rank += 1
    return rank


def reshape_across_cut(amplitudes: dict[tuple[int, ...], complex],
                       local_dims: list[int], cut: frozenset[int]) -> Matrix:
    """Reshape an n-party amplitude tensor into the coefficient matrix M_A."""
    n = len(local_dims)
    a_parties = sorted(cut)
    b_parties = [p for p in range(n) if p not in cut]

    def configs(parties: list[int]) -> list[tuple[int, ...]]:
        return list(product(*[range(local_dims[p]) for p in parties])) if parties else [()]

    a_cfg, b_cfg = configs(a_parties), configs(b_parties)
    ai = {c: i for i, c in enumerate(a_cfg)}
    bi = {c: j for j, c in enumerate(b_cfg)}
    mat: Matrix = [[0j for _ in b_cfg] for _ in a_cfg]
    for cfg, amp in amplitudes.items():
        mat[ai[tuple(cfg[p] for p in a_parties)]][bi[tuple(cfg[p] for p in b_parties)]] = complex(amp)
    return mat


def phi_cut(amplitudes: dict[tuple[int, ...], complex],
            local_dims: list[int], cut: frozenset[int]) -> int:
    """Single-cut integrated information phi_cut = rank(M_A) - 1 (>= 0)."""
    return max(matrix_rank(reshape_across_cut(amplitudes, local_dims, cut)) - 1, 0)
