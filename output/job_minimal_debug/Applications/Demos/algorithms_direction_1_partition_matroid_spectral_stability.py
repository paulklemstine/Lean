#!/usr/bin/env python3
"""
Partition Matroid Spectral Stability — Algorithms

Implements the core algorithms for:
1. Enumerating quadratic leaf profiles of partition matroids
2. Constructing leaf Hessian matrices
3. Computing spectral gaps and stability radii
4. Certifying Lorentzian signature under perturbation

All algorithms correspond to formally verified theorems in the Lean development.
"""

import numpy as np
from typing import List, Tuple, Optional
from itertools import product as iterproduct
from dataclasses import dataclass


@dataclass
class PartitionMatroidData:
    """Data for a partition matroid U_{r1,n1} ⊕ ... ⊕ U_{rk,nk}.

    Attributes:
        block_sizes: List of block sizes [n1, ..., nk]
        block_ranks: List of block ranks [r1, ..., rk]
    """
    block_sizes: List[int]
    block_ranks: List[int]

    def __post_init__(self):
        assert len(self.block_sizes) == len(self.block_ranks)
        for n, r in zip(self.block_sizes, self.block_ranks):
            assert 0 <= r <= n, f"Rank {r} must be between 0 and size {n}"

    @property
    def num_blocks(self) -> int:
        return len(self.block_sizes)

    @property
    def total_rank(self) -> int:
        return sum(self.block_ranks)

    @property
    def total_size(self) -> int:
        return sum(self.block_sizes)


@dataclass
class LeafProfile:
    """A quadratic leaf profile for a partition matroid.

    Attributes:
        derivs: Number of derivatives taken in each block
        residual: Residual degree in each block (r_i - a_i)
        leaf_type: 'single-block' or 'two-block'
        active_blocks: Indices of blocks with nonzero residual degree
    """
    derivs: Tuple[int, ...]
    residual: Tuple[int, ...]
    leaf_type: str
    active_blocks: List[int]


def enumerate_quadratic_leaves(P: PartitionMatroidData) -> List[LeafProfile]:
    """Enumerate all degree-2 leaf profiles.

    Algorithm:
        Generate all tuples a = (a_1, ..., a_k) with 0 ≤ a_i ≤ r_i
        and ∑ a_i = R - 2 where R = ∑ r_i.

    Time complexity: O(∏ (r_i + 1))
    Space complexity: O(k) per profile

    Returns:
        List of LeafProfile objects, each classified as single-block
        or two-block by the classification theorem.
    """
    target = P.total_rank - 2
    if target < 0:
        return []

    ranges = [range(r + 1) for r in P.block_ranks]
    profiles = []

    for a in iterproduct(*ranges):
        if sum(a) != target:
            continue

        residual = tuple(r - ai for r, ai in zip(P.block_ranks, a))
        active = [i for i, d in enumerate(residual) if d > 0]

        if len(active) == 1 and residual[active[0]] == 2:
            leaf_type = "single-block"
        elif len(active) == 2 and all(residual[i] == 1 for i in active):
            leaf_type = "two-block"
        else:
            raise ValueError(f"Unexpected residual pattern: {residual}")

        profiles.append(LeafProfile(
            derivs=a,
            residual=residual,
            leaf_type=leaf_type,
            active_blocks=active
        ))

    return profiles


def build_leaf_hessian(P: PartitionMatroidData, leaf: LeafProfile) -> np.ndarray:
    """Construct the Hessian matrix for a quadratic leaf.

    For single-block leaves: returns J - I on m variables where
    m = n_i - r_i + 2 (the number of remaining variables in the block).

    For two-block leaves: returns the off-diagonal block matrix
    [[0, J], [J^T, 0]] on n_i + n_j variables.

    The scalar coefficient from differentiating the elementary symmetric
    polynomial is normalized to 1 for spectral analysis.

    Args:
        P: Partition matroid data
        leaf: Quadratic leaf profile

    Returns:
        Hessian matrix as numpy array
    """
    if leaf.leaf_type == "single-block":
        i = leaf.active_blocks[0]
        m = P.block_sizes[i] - P.block_ranks[i] + 2
        return build_single_block_hessian(m)

    elif leaf.leaf_type == "two-block":
        i, j = leaf.active_blocks
        n1 = P.block_sizes[i]
        n2 = P.block_sizes[j]
        return build_two_block_hessian(n1, n2)

    else:
        raise ValueError(f"Unknown leaf type: {leaf.leaf_type}")


def build_single_block_hessian(m: int) -> np.ndarray:
    """Build the J - I Hessian for a single-block quadratic leaf.

    This is the Hessian of e_2(x_1, ..., x_m), the elementary symmetric
    polynomial of degree 2. Its eigenvalues are m-1 (once) and -1 (m-1 times).

    Args:
        m: Number of variables in the block

    Returns:
        m × m matrix J - I
    """
    return np.ones((m, m)) - np.eye(m)


def build_two_block_hessian(n1: int, n2: int) -> np.ndarray:
    """Build the off-diagonal block Hessian for a two-block bilinear leaf.

    The Hessian of (∑ x_{E1})(∑ x_{E2}) has the form [[0, J], [J^T, 0]]
    where J is the n1 × n2 all-ones matrix.

    Eigenvalues: +√(n1·n2) (once), -√(n1·n2) (once), 0 (n1+n2-2 times).

    Args:
        n1: Size of block 1
        n2: Size of block 2

    Returns:
        (n1+n2) × (n1+n2) matrix
    """
    n = n1 + n2
    H = np.zeros((n, n))
    H[:n1, n1:] = 1.0
    H[n1:, :n1] = 1.0
    return H


def compute_spectral_gap(H: np.ndarray) -> float:
    """Compute the spectral gap of a Hessian matrix.

    The spectral gap is the minimum absolute value of negative eigenvalues.
    This determines the perturbation tolerance for Lorentzian stability.

    For single-block leaves (J-I): gap = 1
    For two-block leaves: gap = √(n1·n2) if n1+n2 = 2, else 0 (rank deficient)

    Args:
        H: Symmetric matrix

    Returns:
        Spectral gap (0 if no negative eigenvalues or rank-deficient kernel
        intersects every hyperplane)
    """
    eigs = np.linalg.eigvalsh(H)
    neg_eigs = eigs[eigs < -1e-10]
    if len(neg_eigs) == 0:
        return 0.0
    return float(min(abs(neg_eigs)))


def compute_stability_radius(P: PartitionMatroidData) -> float:
    """Compute the certified stability radius for a partition matroid.

    The stability radius is the minimum spectral gap across all single-block
    quadratic leaves. Two-block leaves have HasAtMostOnePositiveEigenvalue
    but may lack a positive spectral gap for large blocks.

    For single-block leaves, the gap is always 1, so the stability radius
    for perturbations of single-block Hessians is 1.

    Args:
        P: Partition matroid data

    Returns:
        Certified stability radius (perturbation tolerance)
    """
    leaves = enumerate_quadratic_leaves(P)
    if not leaves:
        return float('inf')

    single_block_leaves = [l for l in leaves if l.leaf_type == "single-block"]
    if not single_block_leaves:
        return 0.0

    # All single-block leaves have gap 1 (proved in Lean)
    return 1.0


def certify_lorentzian(H: np.ndarray, E: np.ndarray, gap: float) -> bool:
    """Certify that a perturbed Hessian preserves Lorentzian signature.

    Uses the perturbation theorem: if H has gapped signature with gap ε,
    and |Q_E(v)| ≤ δ·‖v‖² for all v, and δ < ε, then H + E has at most
    one positive eigenvalue.

    Args:
        H: Original Hessian with gapped Lorentzian signature
        E: Perturbation matrix
        gap: Spectral gap of H

    Returns:
        True if the perturbation is within the certified stability radius
    """
    E_eigs = np.linalg.eigvalsh(E)
    delta = max(abs(E_eigs))
    return delta < gap


def full_analysis(P: PartitionMatroidData) -> dict:
    """Perform complete spectral analysis of a partition matroid.

    Args:
        P: Partition matroid data

    Returns:
        Dictionary containing:
        - leaves: List of leaf profiles with spectral data
        - stability_radius: Certified stability radius
        - summary: Human-readable summary
    """
    leaves = enumerate_quadratic_leaves(P)
    results = []

    for leaf in leaves:
        H = build_leaf_hessian(P, leaf)
        eigs = np.linalg.eigvalsh(H)
        gap = compute_spectral_gap(H)
        n_pos = int(np.sum(eigs > 1e-10))

        results.append({
            'profile': leaf,
            'hessian_size': H.shape[0],
            'eigenvalues': eigs.tolist(),
            'spectral_gap': gap,
            'num_positive_eigenvalues': n_pos,
            'is_lorentzian': n_pos <= 1,
        })

    stability = compute_stability_radius(P)

    summary_lines = [
        f"Partition matroid with {P.num_blocks} blocks",
        f"Block sizes: {P.block_sizes}, Block ranks: {P.block_ranks}",
        f"Total quadratic leaves: {len(leaves)}",
        f"  Single-block: {sum(1 for l in leaves if l.leaf_type == 'single-block')}",
        f"  Two-block: {sum(1 for l in leaves if l.leaf_type == 'two-block')}",
        f"All leaves Lorentzian: {all(r['is_lorentzian'] for r in results)}",
        f"Certified stability radius: {stability}",
    ]

    return {
        'leaves': results,
        'stability_radius': stability,
        'summary': '\n'.join(summary_lines),
    }


if __name__ == "__main__":
    # Example usage
    print("=== Algorithm Demo ===\n")

    # Example 1: Simple partition matroid
    P1 = PartitionMatroidData([3, 2], [2, 1])
    result1 = full_analysis(P1)
    print(result1['summary'])
    print()

    # Example 2: Three-block partition matroid
    P2 = PartitionMatroidData([4, 3, 2], [2, 2, 1])
    result2 = full_analysis(P2)
    print(result2['summary'])
    print()

    # Example 3: Perturbation certification
    print("=== Perturbation Certification ===\n")
    H = build_single_block_hessian(4)
    for scale in [0.5, 0.9, 1.1]:
        E = scale * np.random.randn(4, 4)
        E = (E + E.T) / 2
        E = E / max(abs(np.linalg.eigvalsh(E))) * scale
        certified = certify_lorentzian(H, E, gap=1.0)
        print(f"  δ = {scale:.1f}: Certified = {certified}")
