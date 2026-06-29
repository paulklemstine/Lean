"""Visualize the per-cut Schmidt-rank landscape and the multi-cut Phi (MIP).

Generates a bar chart: for a chosen tensor-network state, each bar is the
single-cut integrated information (rank - 1) of one non-trivial bipartition; the
dashed line marks Phi = the minimum over cuts (the Minimum Information Partition).

Requires matplotlib. Run: python viz_phi_landscape.py
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Iterable

import matplotlib.pyplot as plt

Matrix = list[list[complex]]


def matrix_rank(mat: Matrix, tol: float = 1e-9) -> int:
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


def reshape_across_cut(amps: dict[tuple[int, ...], complex], dims: list[int],
                       cut: frozenset[int]) -> Matrix:
    n = len(dims)
    a_parties = sorted(cut)
    b_parties = [p for p in range(n) if p not in cut]

    def configs(parties: list[int]) -> list[tuple[int, ...]]:
        return list(product(*[range(dims[p]) for p in parties])) if parties else [()]

    a_cfg, b_cfg = configs(a_parties), configs(b_parties)
    ai = {c: i for i, c in enumerate(a_cfg)}
    bi = {c: j for j, c in enumerate(b_cfg)}
    mat: Matrix = [[0j for _ in b_cfg] for _ in a_cfg]
    for cfg, amp in amps.items():
        mat[ai[tuple(cfg[p] for p in a_parties)]][bi[tuple(cfg[p] for p in b_parties)]] = complex(amp)
    return mat


def nontrivial_cuts(n: int) -> list[frozenset[int]]:
    cuts = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            if 0 in combo:
                cuts.append(frozenset(combo))
    return cuts


def ghz(n: int) -> dict[tuple[int, ...], complex]:
    return {(0,) * n: 1.0, (1,) * n: 1.0}


def main() -> None:
    n = 4
    dims = [2] * n
    amps = ghz(n)
    cuts = nontrivial_cuts(n)
    labels, values = [], []
    for c in cuts:
        labels.append("{" + ",".join(map(str, sorted(c))) + "}")
        values.append(max(matrix_rank(reshape_across_cut(amps, dims, c)) - 1, 0))
    phi = min(values)

    plt.figure(figsize=(10, 4))
    plt.bar(range(len(values)), values, color="#4477aa")
    plt.axhline(phi, color="#cc3311", linestyle="--", label=f"Phi (MIP) = {phi}")
    plt.xticks(range(len(values)), labels, rotation=45, ha="right")
    plt.ylabel("single-cut Phi  (rank - 1)")
    plt.title(f"Cut landscape of GHZ_{n}  (Phi = min over cuts)")
    plt.legend()
    plt.tight_layout()
    plt.savefig("phi_landscape.png", dpi=150)
    print("wrote phi_landscape.png")


if __name__ == "__main__":
    main()
