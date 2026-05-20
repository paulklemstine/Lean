#!/usr/bin/env python3
"""
MPS Min-Cut Principle: Core Algorithms

Implements the key algorithms from the research paper:
1. MPS tensor contraction
2. Flattening rank computation via SVD
3. Exhaustive bipartition enumeration
4. Integrated information rank computation
5. Contiguous min-cut computation (linear-time)

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from itertools import combinations
from typing import List, Tuple, Optional, Dict, FrozenSet
from dataclasses import dataclass


@dataclass
class MPSState:
    """
    A Matrix Product State (MPS) with open boundary conditions.

    Attributes
    ----------
    tensors : list of np.ndarray
        tensors[i] has shape (D_i, d_i, D_{i+1}) where D_i are bond dimensions
        and d_i are physical dimensions.
    n : int
        Number of sites (chain length).
    bond_dims : list of int
        Bond dimensions [D_0, ..., D_n] with D_0 = D_n = 1.
    phys_dims : list of int
        Physical dimensions [d_0, ..., d_{n-1}].
    """
    tensors: List[np.ndarray]
    n: int
    bond_dims: List[int]
    phys_dims: List[int]

    @classmethod
    def random(cls, n: int, phys_dim: int, bond_dims: List[int],
               seed: int = 42) -> 'MPSState':
        """
        Generate a random MPS with given bond dimensions.

        Complexity: O(n * d * D^2) where D = max bond dimension.
        """
        rng = np.random.default_rng(seed)
        assert len(bond_dims) == n + 1
        assert bond_dims[0] == 1 and bond_dims[-1] == 1
        tensors = []
        for i in range(n):
            A = rng.standard_normal((bond_dims[i], phys_dim, bond_dims[i + 1]))
            tensors.append(A)
        return cls(tensors=tensors, n=n, bond_dims=bond_dims,
                   phys_dims=[phys_dim] * n)


def contract_mps(mps: MPSState) -> np.ndarray:
    """
    Contract MPS tensors into a full state tensor.

    Algorithm:
        Sequential matrix multiplication along the chain.
        Start from site 0, contract with site 1, etc.

    Complexity: O(n * d * D^2 * d^n) in the worst case, since the
    intermediate tensor grows exponentially.

    Parameters
    ----------
    mps : MPSState

    Returns
    -------
    psi : np.ndarray of shape (d_0, d_1, ..., d_{n-1})
    """
    result = mps.tensors[0]  # shape (1, d_0, D_1)
    for i in range(1, mps.n):
        result = np.einsum('...i,ijk->...jk', result, mps.tensors[i])
    return result.reshape(mps.phys_dims)


def compute_flattening(psi: np.ndarray, S: FrozenSet[int], n: int) -> np.ndarray:
    """
    Compute the flattening (matricization) of tensor ψ across bipartition S | S^c.

    Algorithm:
        1. Permute tensor axes: S indices first, then S^c indices.
        2. Reshape into a 2D matrix.

    Complexity: O(d^n) for the permutation and reshape.

    Parameters
    ----------
    psi : np.ndarray of shape (d,) * n
    S : frozenset of site indices
    n : number of sites

    Returns
    -------
    M : 2D np.ndarray, the flattening matrix
    """
    S_list = sorted(S)
    Sc_list = sorted(set(range(n)) - S)
    perm = S_list + Sc_list
    psi_perm = np.transpose(psi, perm)
    d = psi.shape[0]
    row_dim = d ** len(S_list)
    col_dim = d ** len(Sc_list)
    return psi_perm.reshape(row_dim, col_dim)


def compute_flat_rank(psi: np.ndarray, S: FrozenSet[int], n: int,
                      tol: float = 1e-10) -> int:
    """
    Compute the flattening rank of ψ across bipartition S | S^c.

    Algorithm:
        1. Compute the flattening matrix M.
        2. Compute SVD of M.
        3. Count singular values above tolerance.

    Complexity: O(d^n * min(|S|, n-|S|)) for SVD.

    Parameters
    ----------
    psi : np.ndarray of shape (d,) * n
    S : frozenset of site indices
    n : number of sites
    tol : numerical tolerance for rank computation

    Returns
    -------
    rank : int
    """
    M = compute_flattening(psi, S, n)
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


def compute_integrated_info_rank(psi: np.ndarray, n: int,
                                  tol: float = 1e-10) -> Tuple[int, FrozenSet[int]]:
    """
    Compute the integrated information rank Φ#(ψ):
    the minimum flattening rank over all nontrivial bipartitions.

    Algorithm:
        Exhaustive enumeration of all 2^n - 2 nontrivial bipartitions.

    Complexity: O(2^n * d^n * n) — exponential in n.

    Parameters
    ----------
    psi : np.ndarray of shape (d,) * n
    n : number of sites
    tol : numerical tolerance

    Returns
    -------
    min_rank : int
        The integrated information rank.
    min_S : frozenset
        A minimizing bipartition.
    """
    min_rank = float('inf')
    min_S = None
    for size in range(1, n):
        for combo in combinations(range(n), size):
            S = frozenset(combo)
            r = compute_flat_rank(psi, S, n, tol)
            if r < min_rank:
                min_rank = r
                min_S = S
    return int(min_rank), min_S


def compute_contiguous_min_cut_rank(psi: np.ndarray, n: int,
                                     tol: float = 1e-10) -> Tuple[int, int]:
    """
    Compute the contiguous min-cut rank:
    the minimum flattening rank over all prefix cuts {0, ..., k-1}.

    Algorithm:
        Linear scan over n-1 prefix cuts.

    Complexity: O(n * d^n) — linear in n (exponential in d^n for SVD).

    This is the KEY computational advantage: instead of checking 2^n - 2
    bipartitions, we only check n - 1 prefix cuts, and by the min-cut
    principle, the result is the same.

    Parameters
    ----------
    psi : np.ndarray of shape (d,) * n
    n : number of sites
    tol : numerical tolerance

    Returns
    -------
    min_rank : int
        The contiguous min-cut rank.
    min_k : int
        The minimizing prefix length.
    """
    min_rank = float('inf')
    min_k = None
    for k in range(1, n):
        S = frozenset(range(k))
        r = compute_flat_rank(psi, S, n, tol)
        if r < min_rank:
            min_rank = r
            min_k = k
    return int(min_rank), min_k


def compute_cut_edges(n: int, S: FrozenSet[int]) -> List[int]:
    """
    Compute the cut edges for bipartition S on the path graph.

    A cut edge is an edge (i, i+1) where exactly one of i, i+1 is in S.

    Complexity: O(n).

    Parameters
    ----------
    n : number of vertices
    S : subset of {0, ..., n-1}

    Returns
    -------
    edges : list of edge indices (0-based)
    """
    return [i for i in range(n - 1) if (i in S) != (i + 1 in S)]


def compute_edge_cut_min_bond(bond_dims: List[int], S: FrozenSet[int],
                               n: int) -> int:
    """
    Compute the minimum bond dimension among cut edges for bipartition S.

    Complexity: O(n).

    Parameters
    ----------
    bond_dims : list of bond dimensions [D_0, ..., D_n]
    S : subset of {0, ..., n-1}
    n : number of sites

    Returns
    -------
    min_bond : int, minimum D_{e+1} over cut edges e, or 0 if no cut edges
    """
    edges = compute_cut_edges(n, S)
    if not edges:
        return 0
    return min(bond_dims[e + 1] for e in edges)


def verify_min_cut_principle(mps: MPSState, tol: float = 1e-10,
                              verbose: bool = False) -> bool:
    """
    Verify the MPS min-cut principle for a given MPS:
    Φ#(ψ) = min_k flatRank(ψ, {0,...,k-1})

    Complexity: O(2^n * d^n * n) for full verification.

    Returns True if the principle holds.
    """
    psi = contract_mps(mps)
    n = mps.n
    int_rank, int_S = compute_integrated_info_rank(psi, n, tol)
    cont_rank, cont_k = compute_contiguous_min_cut_rank(psi, n, tol)

    if verbose:
        print(f"  Integrated info rank: {int_rank} (minimizer: {set(int_S)})")
        print(f"  Contiguous min-cut rank: {cont_rank} (at k={cont_k})")
        print(f"  Principle holds: {int_rank == cont_rank}")

    return int_rank == cont_rank


# Example usage
if __name__ == '__main__':
    print("MPS Min-Cut Principle: Algorithm Demonstrations")
    print("=" * 50)

    # Example 1: Small MPS
    mps = MPSState.random(n=4, phys_dim=2, bond_dims=[1, 2, 3, 2, 1])
    psi = contract_mps(mps)
    print(f"\nExample: n=4, d=2, bonds=[1,2,3,2,1]")
    print(f"  Full tensor shape: {psi.shape}")

    int_rank, int_S = compute_integrated_info_rank(psi, 4)
    cont_rank, cont_k = compute_contiguous_min_cut_rank(psi, 4)
    print(f"  Integrated info rank Φ# = {int_rank}")
    print(f"  Contiguous min-cut rank = {cont_rank}")
    print(f"  Min-cut principle: {'VERIFIED' if int_rank == cont_rank else 'FAILED'}")

    # Example 2: Computational speedup
    print(f"\n  Computational complexity comparison:")
    for n in range(3, 9):
        n_all = 2**n - 2
        n_prefix = n - 1
        speedup = n_all / n_prefix
        print(f"    n={n}: all bipartitions={n_all}, prefix cuts={n_prefix}, "
              f"speedup={speedup:.1f}x")
