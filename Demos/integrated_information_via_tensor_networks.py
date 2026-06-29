"""Numerical demonstration of multi-cut integrated information for tensor networks.

This script is fully self-contained: it implements complex matrix rank (via
Gaussian elimination with partial pivoting), tensor reshaping across a cut, the
single-cut integrated information ``phi_cut(M) = rank(M) - 1``, and the multi-cut
integrated information ``phi = min over non-trivial cuts of (rank - 1)``, the
Minimum Information Partition (MIP) of Tononi's Integrated Information Theory cast
in the language of tensor-network Schmidt ranks.

It reproduces the worked examples of the accompanying paper:
  * product state         -> phi = 0
  * Bell state            -> phi = 1  (bond-dimension-2 maximum)
  * GHZ_3                  -> phi = 1
  * W_3                    -> phi = 1
  * Bell (x) idle qubit   -> phi = 0  (MIP isolates the idle qubit)
  * maximally entangled   -> phi = D - 1  (tightness of the bond bound)

No third-party libraries are required (standard library only).
"""

from __future__ import annotations

from itertools import combinations, product
from typing import Callable, Iterable

Complex = complex
Matrix = list[list[Complex]]


# --------------------------------------------------------------------------- #
# Linear algebra: rank of a complex matrix by Gaussian elimination.
# --------------------------------------------------------------------------- #
def matrix_rank(mat: Matrix, tol: float = 1e-9) -> int:
    """Return the rank of a complex matrix via Gaussian elimination.

    Uses partial pivoting on absolute value and a tolerance to decide which
    entries count as non-zero. Complexity O(min(r, c) * r * c).
    """
    # Work on a mutable float-complex copy.
    rows = [list(map(complex, r)) for r in mat]
    if not rows or not rows[0]:
        return 0
    n_rows = len(rows)
    n_cols = len(rows[0])
    rank = 0
    pivot_row = 0
    for col in range(n_cols):
        if pivot_row >= n_rows:
            break
        # Find the row at or below pivot_row with the largest magnitude in col.
        best = pivot_row
        best_mag = abs(rows[pivot_row][col])
        for r in range(pivot_row + 1, n_rows):
            if abs(rows[r][col]) > best_mag:
                best = r
                best_mag = abs(rows[r][col])
        if best_mag <= tol:
            continue  # Column is (numerically) zero below the pivot.
        rows[pivot_row], rows[best] = rows[best], rows[pivot_row]
        pivot_val = rows[pivot_row][col]
        # Eliminate this column from all other rows.
        for r in range(n_rows):
            if r == pivot_row:
                continue
            factor = rows[r][col] / pivot_val
            if factor != 0:
                for c in range(col, n_cols):
                    rows[r][c] -= factor * rows[pivot_row][c]
        pivot_row += 1
        rank += 1
    return rank


# --------------------------------------------------------------------------- #
# Tensor reshaping across a cut.
# --------------------------------------------------------------------------- #
def reshape_across_cut(
    amplitudes: dict[tuple[int, ...], Complex],
    local_dims: list[int],
    cut: frozenset[int],
) -> Matrix:
    """Reshape an n-party amplitude tensor into the coefficient matrix M_A.

    ``amplitudes`` maps each configuration (a tuple of local indices, one per
    party) to a complex amplitude; missing configurations are treated as 0.
    Rows are indexed by configurations of the parties in ``cut`` (side A);
    columns by configurations of the complement.
    """
    n = len(local_dims)
    a_parties = sorted(cut)
    b_parties = [p for p in range(n) if p not in cut]

    def configs(parties: list[int]) -> list[tuple[int, ...]]:
        ranges = [range(local_dims[p]) for p in parties]
        return list(product(*ranges)) if parties else [()]

    a_configs = configs(a_parties)
    b_configs = configs(b_parties)
    a_index = {cfg: i for i, cfg in enumerate(a_configs)}
    b_index = {cfg: j for j, cfg in enumerate(b_configs)}

    mat: Matrix = [[0j for _ in b_configs] for _ in a_configs]
    for full_cfg, amp in amplitudes.items():
        a_key = tuple(full_cfg[p] for p in a_parties)
        b_key = tuple(full_cfg[p] for p in b_parties)
        mat[a_index[a_key]][b_index[b_key]] = complex(amp)
    return mat


# --------------------------------------------------------------------------- #
# Integrated information.
# --------------------------------------------------------------------------- #
def phi_cut(mat: Matrix) -> int:
    """Single-cut integrated information phi_cut(M) = rank(M) - 1 (>= 0)."""
    return max(matrix_rank(mat) - 1, 0)


def nontrivial_cuts(n: int) -> list[frozenset[int]]:
    """Representative non-trivial bipartitions of {0, ..., n-1}.

    To avoid counting a cut and its complement twice, we take only subsets that
    contain party 0 and are proper. This gives 2^(n-1) - 1 representatives.
    """
    parties = list(range(n))
    cuts: list[frozenset[int]] = []
    for size in range(1, n):
        for combo in combinations(parties, size):
            if 0 in combo:
                comp = frozenset(parties) - frozenset(combo)
                if comp:  # proper, automatically true here
                    cuts.append(frozenset(combo))
    return cuts


def phi_multicut(
    amplitudes: dict[tuple[int, ...], Complex],
    local_dims: list[int],
) -> tuple[int, frozenset[int]]:
    """Multi-cut integrated information phi and a realizing MIP cut.

    phi = min over non-trivial cuts A of (rank(M_A) - 1).
    Returns (phi, mip_cut).
    """
    n = len(local_dims)
    assert n >= 2, "need at least two parties for a non-trivial cut"
    best_phi: int | None = None
    best_cut: frozenset[int] = frozenset()
    for cut in nontrivial_cuts(n):
        value = phi_cut(reshape_across_cut(amplitudes, local_dims, cut))
        if best_phi is None or value < best_phi:
            best_phi = value
            best_cut = cut
    assert best_phi is not None
    return best_phi, best_cut


# --------------------------------------------------------------------------- #
# State builders.
# --------------------------------------------------------------------------- #
def normalized(
    terms: Iterable[tuple[tuple[int, ...], Complex]],
) -> dict[tuple[int, ...], Complex]:
    """Build a (formally) normalized amplitude dictionary from term list.

    Normalization does not affect the rank / phi, but we include it for realism.
    """
    amps: dict[tuple[int, ...], Complex] = {}
    for cfg, c in terms:
        amps[cfg] = amps.get(cfg, 0j) + complex(c)
    norm = sum(abs(v) ** 2 for v in amps.values()) ** 0.5
    if norm == 0:
        return amps
    return {k: v / norm for k, v in amps.items()}


def product_state(n: int) -> dict[tuple[int, ...], Complex]:
    """|0...0>: a fully unentangled product state of n qubits."""
    return normalized([((0,) * n, 1.0)])


def bell_state() -> dict[tuple[int, ...], Complex]:
    """(|00> + |11>)/sqrt(2)."""
    return normalized([((0, 0), 1.0), ((1, 1), 1.0)])


def ghz_state(n: int) -> dict[tuple[int, ...], Complex]:
    """(|0...0> + |1...1>)/sqrt(2)."""
    return normalized([((0,) * n, 1.0), ((1,) * n, 1.0)])


def w_state(n: int) -> dict[tuple[int, ...], Complex]:
    """(|10...0> + ... + |0...01>)/sqrt(n): single excitation, symmetric."""
    terms = []
    for i in range(n):
        cfg = tuple(1 if j == i else 0 for j in range(n))
        terms.append((cfg, 1.0))
    return normalized(terms)


def bell_times_idle() -> dict[tuple[int, ...], Complex]:
    """(|00> + |11>) (x) |0>: a Bell pair beside an idle third qubit."""
    return normalized([((0, 0, 0), 1.0), ((1, 1, 0), 1.0)])


def maximally_entangled(d: int) -> dict[tuple[int, ...], Complex]:
    """Sum_i |i>|i> on d (x) d: identity coefficient matrix, Schmidt rank d."""
    return normalized([((i, i), 1.0) for i in range(d)])


# --------------------------------------------------------------------------- #
# Driver.
# --------------------------------------------------------------------------- #
def _report(
    name: str,
    amps: dict[tuple[int, ...], Complex],
    dims: list[int],
    expected: int,
) -> None:
    phi, mip = phi_multicut(amps, dims)
    flag = "OK " if phi == expected else "!! "
    mip_str = "{" + ",".join(map(str, sorted(mip))) + "}"
    print(f"{flag}{name:<28} phi = {phi}  (expected {expected})  MIP = {mip_str}")


def main() -> None:
    print("Multi-cut integrated information of tensor-network states")
    print("=" * 64)

    _report("product |00>", product_state(2), [2, 2], 0)
    _report("Bell (|00>+|11>)", bell_state(), [2, 2], 1)
    _report("GHZ_3", ghz_state(3), [2, 2, 2], 1)
    _report("W_3", w_state(3), [2, 2, 2], 1)
    _report("Bell (x) idle qubit", bell_times_idle(), [2, 2, 2], 0)
    _report("product |000>", product_state(3), [2, 2, 2], 0)

    print("-" * 64)
    print("Tightness of the bond-dimension bound  (phi = D - 1):")
    for d in range(1, 6):
        amps = maximally_entangled(d)
        phi, _ = phi_multicut(amps, [d, d])
        flag = "OK " if phi == d - 1 else "!! "
        print(f"{flag}  D = {d}: maximally entangled  phi = {phi}  (D - 1 = {d - 1})")

    print("-" * 64)
    print("Single-cut check: identity coefficient matrix I_D has phi_cut = D - 1:")
    for d in range(1, 6):
        identity: Matrix = [[1.0 if i == j else 0.0 for j in range(d)] for i in range(d)]
        print(f"   I_{d}: phi_cut = {phi_cut(identity)}  (D - 1 = {d - 1})")


if __name__ == "__main__":
    main()
