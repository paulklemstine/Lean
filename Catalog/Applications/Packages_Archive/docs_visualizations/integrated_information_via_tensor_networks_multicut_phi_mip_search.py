from __future__ import annotations
from itertools import combinations


def nontrivial_cuts(n: int) -> list[frozenset[int]]:
    """Representative non-trivial bipartitions: proper subsets containing party 0.

    Yields 2^(n-1) - 1 cuts, one per (cut, complement) pair.
    """
    cuts: list[frozenset[int]] = []
    for size in range(1, n):
        for combo in combinations(range(n), size):
            if 0 in combo:
                cuts.append(frozenset(combo))
    return cuts


def phi_multicut(amplitudes: dict[tuple[int, ...], complex],
                 local_dims: list[int]) -> tuple[int, frozenset[int]]:
    """Multi-cut integrated information and a realizing Minimum Information Partition.

    phi = min over non-trivial cuts A of (Schmidt rank across A) - 1.
    Returns (phi, mip_cut). Requires phi_cut from the Schmidt-rank algorithm.
    """
    from _alg_schmidt import phi_cut  # single-cut Schmidt-rank deficit

    n = len(local_dims)
    assert n >= 2, "need at least two parties for a non-trivial cut"
    best_phi: int | None = None
    best_cut: frozenset[int] = frozenset()
    for cut in nontrivial_cuts(n):
        value = phi_cut(amplitudes, local_dims, cut)
        if best_phi is None or value < best_phi:
            best_phi, best_cut = value, cut
    assert best_phi is not None
    return best_phi, best_cut
