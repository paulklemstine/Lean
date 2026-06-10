#!/usr/bin/env python3
"""
Algorithms for Computing Integrated Information via Tensor Networks

Implements:
1. Exact computation of integrated information rank for small systems
2. MPS construction and contraction
3. Cut-rank profile computation
4. Efficient bipartition enumeration

All algorithms correspond to the formal definitions in the Lean formalization.

Complexity:
- Integrated info rank: O(2^n * d^n * min(d^n, d^n)) for n sites, local dim d
  (exponential in n due to bipartition enumeration and SVD)
- MPS contraction: O(n * d * D^2) per amplitude, O(d^n * n * d * D^2) total
- Cut-rank for MPS: O(D * d^(n/2)) per cut via the MPS structure
"""

import numpy as np
from typing import List, Tuple, Optional, Callable
from itertools import combinations


def enumerate_nontrivial_bipartitions(n: int) -> List[List[int]]:
    """
    Enumerate all nontrivial bipartitions of {0, ..., n-1}.
    
    A bipartition A is nontrivial if A is nonempty and A ≠ {0,...,n-1}.
    We enumerate subsets A of size 1 to n-1.
    
    Args:
        n: number of sites
    
    Returns:
        List of lists, each representing the 'left' partition.
    
    Complexity: O(2^n) partitions returned.
    
    Example:
        >>> enumerate_nontrivial_bipartitions(3)
        [[0], [1], [2], [0, 1], [0, 2], [1, 2]]
    """
    sites = list(range(n))
    partitions = []
    for k in range(1, n):
        for combo in combinations(sites, k):
            partitions.append(list(combo))
    return partitions


def flatten_state(psi: np.ndarray, partition_left: List[int]) -> np.ndarray:
    """
    Compute the bipartition flattening (matricization) of a tensor state.
    
    Given a tensor ψ of shape (d₀, d₁, ..., d_{n-1}) and a subset A of
    indices, produce a matrix M where:
    - rows are indexed by tuples of indices for sites in A
    - columns are indexed by tuples of indices for sites not in A
    - M[row, col] = ψ[combined index]
    
    This corresponds to the `flatten` definition in the Lean formalization.
    
    Args:
        psi: n-dimensional numpy array (tensor state)
        partition_left: list of indices forming the left partition
    
    Returns:
        2D numpy array (the flattening matrix)
    
    Complexity: O(d^n) to transpose and reshape.
    
    Example:
        >>> psi = np.random.randn(2, 2, 2)
        >>> M = flatten_state(psi, [0, 2])
        >>> M.shape
        (4, 2)
    """
    n = psi.ndim
    partition_right = sorted(set(range(n)) - set(partition_left))
    
    perm = list(partition_left) + partition_right
    psi_perm = np.transpose(psi, perm)
    
    left_dim = int(np.prod([psi.shape[i] for i in partition_left]))
    right_dim = int(np.prod([psi.shape[i] for i in partition_right]))
    
    return psi_perm.reshape(left_dim, right_dim)


def matrix_rank(M: np.ndarray, tol: float = 1e-10) -> int:
    """
    Compute the numerical rank of a matrix via SVD.
    
    Args:
        M: 2D numpy array
        tol: singular values below this threshold are treated as zero
    
    Returns:
        Integer rank
    
    Complexity: O(min(m,n) * max(m,n)^2) for an m×n matrix.
    """
    if M.size == 0:
        return 0
    sv = np.linalg.svd(M, compute_uv=False)
    return int(np.sum(sv > tol))


def integrated_info_rank(psi: np.ndarray, tol: float = 1e-10) -> int:
    """
    Compute the integrated information rank Φ#(ψ).
    
    This is the minimum flattening rank over all nontrivial bipartitions:
        Φ#(ψ) = min_{A ⊊ I, A≠∅} rank(Flat_A(ψ))
    
    Corresponds to `integratedInfoRank` in the Lean formalization.
    
    Args:
        psi: n-dimensional numpy array (tensor state)
        tol: tolerance for rank computation
    
    Returns:
        Integer (the integrated information rank)
    
    Complexity: O(2^n * SVD cost) where SVD cost depends on dimensions.
    
    Example:
        >>> psi = np.tensordot(np.array([1, 0]), np.array([0, 1]), axes=0)
        >>> integrated_info_rank(psi)
        1
    """
    n = psi.ndim
    if n < 2:
        return 0
    
    min_rank = float('inf')
    for partition in enumerate_nontrivial_bipartitions(n):
        M = flatten_state(psi, partition)
        r = matrix_rank(M, tol)
        min_rank = min(min_rank, r)
        if min_rank <= 1:  # Early termination: can't go lower than 1 for nonzero states
            break
    
    return int(min_rank)


def cut_rank_profile(psi: np.ndarray, tol: float = 1e-10) -> List[int]:
    """
    Compute the contiguous-cut rank profile of a chain tensor state.
    
    For each k = 0, ..., n-2, compute rank(Flat_{0,...,k}(ψ)).
    This is the CutRankProfile in the Lean formalization.
    
    Args:
        psi: n-dimensional numpy array
        tol: tolerance for rank computation
    
    Returns:
        List of n-1 integers (ranks for each contiguous cut)
    
    Complexity: O(n * SVD cost).
    """
    n = psi.ndim
    ranks = []
    for k in range(n - 1):
        M = flatten_state(psi, list(range(k + 1)))
        ranks.append(matrix_rank(M, tol))
    return ranks


def construct_mps(tensors: List[np.ndarray]) -> np.ndarray:
    """
    Contract an MPS (Matrix Product State) tensor train into a full tensor.
    
    Each tensor[k] has shape (d_k, D_{k-1}, D_k) where:
    - d_k is the physical (local) dimension
    - D_{k-1} is the left bond dimension
    - D_k is the right bond dimension
    
    For open boundary conditions: D_0 = D_n = 1.
    
    ψ(i₁,...,iₙ) = ∑_{α} A₁[i₁]_{1,α₁} · A₂[i₂]_{α₁,α₂} · ... · Aₙ[iₙ]_{α_{n-1},1}
    
    Args:
        tensors: list of 3D arrays, each of shape (d_k, D_{k-1}, D_k)
    
    Returns:
        Full tensor state as n-dimensional array
    
    Complexity: O(d^n * n * D^2) where D = max bond dimension.
    """
    n = len(tensors)
    dims = [t.shape[0] for t in tensors]
    
    from itertools import product as cartesian_product
    
    shape = tuple(dims)
    psi = np.zeros(shape, dtype=complex)
    
    for idx in cartesian_product(*[range(d) for d in dims]):
        mat = tensors[0][idx[0]]  # shape (D_0, D_1)
        for k in range(1, n):
            mat = mat @ tensors[k][idx[k]]  # matrix multiplication
        psi[idx] = mat[0, 0]  # D_0 = D_n = 1, so this is scalar
    
    return psi


def random_mps_tensors(n: int, d: int, D: int) -> List[np.ndarray]:
    """
    Generate random MPS tensors with given bond dimension.
    
    Args:
        n: number of sites
        d: local dimension
        D: internal bond dimension
    
    Returns:
        List of n tensors, each of shape (d, D_left, D_right)
    """
    tensors = []
    for k in range(n):
        D_left = 1 if k == 0 else D
        D_right = 1 if k == n - 1 else D
        A = np.random.randn(d, D_left, D_right) + 1j * np.random.randn(d, D_left, D_right)
        tensors.append(A)
    return tensors


def is_phi_faithful(psi: np.ndarray, tol: float = 1e-10) -> bool:
    """
    Check if a state is Phi-faithful (has positive integrated information).
    
    A state is Phi-faithful if Φ#(ψ) > 1, meaning it cannot be decomposed
    across any nontrivial bipartition.
    
    Corresponds to `PhiFaithful` in the Lean formalization.
    
    Args:
        psi: tensor state
        tol: tolerance
    
    Returns:
        True if the state has positive integrated information
    """
    return integrated_info_rank(psi, tol) > 1


def bond_dimension_of_state(psi: np.ndarray, tol: float = 1e-10) -> int:
    """
    Compute the minimal bond dimension required to represent a state as MPS.
    
    This is the maximum contiguous-cut rank over all cuts.
    
    Args:
        psi: tensor state
        tol: tolerance
    
    Returns:
        Minimum bond dimension D such that state is representable as MPS(D)
    """
    ranks = cut_rank_profile(psi, tol)
    return max(ranks) if ranks else 0


if __name__ == "__main__":
    np.random.seed(42)
    
    print("=== Algorithm Demonstrations ===\n")
    
    # Demo 1: Product state
    a = np.array([1, 1j]) / np.sqrt(2)
    b = np.array([1, -1]) / np.sqrt(2)
    c = np.array([0, 1])
    psi_prod = np.tensordot(np.tensordot(a, b, axes=0), c, axes=0)
    
    print(f"Product state |a⟩⊗|b⟩⊗|c⟩:")
    print(f"  Φ# = {integrated_info_rank(psi_prod)}")
    print(f"  Cut ranks = {cut_rank_profile(psi_prod)}")
    print(f"  Phi-faithful? {is_phi_faithful(psi_prod)}")
    print()
    
    # Demo 2: GHZ-like entangled state
    psi_ghz = np.zeros((2, 2, 2), dtype=complex)
    psi_ghz[0, 0, 0] = 1 / np.sqrt(2)
    psi_ghz[1, 1, 1] = 1 / np.sqrt(2)
    
    print(f"GHZ state (|000⟩ + |111⟩)/√2:")
    print(f"  Φ# = {integrated_info_rank(psi_ghz)}")
    print(f"  Cut ranks = {cut_rank_profile(psi_ghz)}")
    print(f"  Phi-faithful? {is_phi_faithful(psi_ghz)}")
    print(f"  Min bond dim = {bond_dimension_of_state(psi_ghz)}")
    print()
    
    # Demo 3: Random MPS
    tensors = random_mps_tensors(5, 2, 3)
    psi_mps = construct_mps(tensors)
    psi_mps = psi_mps / np.sqrt(np.sum(np.abs(psi_mps)**2))
    
    print(f"Random MPS (n=5, d=2, D=3):")
    print(f"  Φ# = {integrated_info_rank(psi_mps)}")
    print(f"  Cut ranks = {cut_rank_profile(psi_mps)}")
    print(f"  Phi-faithful? {is_phi_faithful(psi_mps)}")
    print(f"  Min bond dim = {bond_dimension_of_state(psi_mps)}")
    
    # Demo 4: All bipartition ranks
    print(f"\n  All bipartition ranks:")
    for part in enumerate_nontrivial_bipartitions(5):
        M = flatten_state(psi_mps, part)
        r = matrix_rank(M)
        if len(part) <= 2:
            print(f"    Partition {part}: rank = {r}")
