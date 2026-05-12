#!/usr/bin/env python3
"""
Tropical Kernel Mean Duality — Core Algorithms

Implements the key algorithms from the tropical kernel duality theory:
1. Tropical Feature Factorization
2. Residuated Coefficient Computation
3. Greedy Minimal Support Extraction
4. Antichain Verification
5. Certified Prototype Reconstruction

All algorithms operate on finite tropical kernels K : X × X → ℝ
where tropical addition is max and tropical multiplication is +.
"""

import numpy as np
from dataclasses import dataclass
from typing import List, Tuple, Set, Optional


@dataclass
class TropicalKernel:
    """
    A finite tropical kernel represented as a matrix.
    
    K[i,j] represents the kernel evaluation K(x_i, x_j).
    A kernel of feature rank r factors as:
        K(x,y) = max_{k=1..r} (φ(x,k) + φ(y,k))
    
    Attributes
    ----------
    matrix : np.ndarray
        The kernel matrix of shape (n, n).
    feature_map : np.ndarray or None
        The feature map φ of shape (n, r), if known.
    """
    matrix: np.ndarray
    feature_map: Optional[np.ndarray] = None
    
    @property
    def n(self) -> int:
        return self.matrix.shape[0]
    
    @property
    def rank(self) -> Optional[int]:
        if self.feature_map is not None:
            return self.feature_map.shape[1]
        return None
    
    def section(self, x: int) -> np.ndarray:
        """Return kernel section K_x."""
        return self.matrix[x, :]
    
    def is_symmetric(self) -> bool:
        """Check symmetry."""
        return np.allclose(self.matrix, self.matrix.T)
    
    @classmethod
    def from_features(cls, phi: np.ndarray) -> 'TropicalKernel':
        """
        Construct a tropical kernel from a feature map.
        
        K(x,y) = max_i (φ(x,i) + φ(y,i))
        
        Parameters
        ----------
        phi : np.ndarray of shape (n, r)
        
        Returns
        -------
        TropicalKernel
        
        Time complexity: O(n² × r)
        Space complexity: O(n² + n×r)
        """
        n, r = phi.shape
        K = np.full((n, n), -np.inf)
        for i in range(r):
            K = np.maximum(K, np.add.outer(phi[:, i], phi[:, i]))
        return cls(matrix=K, feature_map=phi)
    
    @classmethod
    def from_distance(cls, D: np.ndarray) -> 'TropicalKernel':
        """
        Construct a tropical kernel from a distance matrix.
        
        K(x,y) = -D(x,y) (negative distance kernel).
        
        Time complexity: O(n²)
        """
        return cls(matrix=-D)


@dataclass
class SupportDecomposition:
    """
    Result of tropical kernel support decomposition.
    
    Attributes
    ----------
    support : List[int]
        Indices of support prototypes.
    coefficients : np.ndarray
        Residuated coefficients for each support element.
    is_minimal : bool
        Whether the support is minimal (no element can be removed).
    is_antichain : bool
        Whether the support forms an antichain.
    reconstruction_error : float
        Maximum absolute reconstruction error.
    """
    support: List[int]
    coefficients: np.ndarray
    is_minimal: bool
    is_antichain: bool
    reconstruction_error: float


def compute_residuated_coefficient(K: TropicalKernel, f: np.ndarray,
                                    x: int) -> float:
    """
    Compute the residuated coefficient of x for representing f via K_x.
    
    res(K, f, x) = min_y (f(y) - K(x, y))
    
    This is the largest c such that c + K(x,y) ≤ f(y) for all y.
    By the Galois connection of residuation theory, this is optimal.
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray of shape (n,)
    x : int
    
    Returns
    -------
    float : The residuated coefficient.
    
    Time complexity: O(n)
    """
    return float(np.min(f - K.matrix[x, :]))


def compute_all_residuated_coefficients(K: TropicalKernel,
                                         f: np.ndarray) -> np.ndarray:
    """
    Compute residuated coefficients for all points.
    
    Time complexity: O(n²)
    """
    return np.array([compute_residuated_coefficient(K, f, x)
                     for x in range(K.n)])


def reconstruct_from_support(K: TropicalKernel, f: np.ndarray,
                              support: List[int]) -> np.ndarray:
    """
    Reconstruct f from a support set using residuated coefficients.
    
    pred(y) = max_{x ∈ S} (res(K, f, x) + K(x, y))
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray
    support : List[int]
    
    Returns
    -------
    np.ndarray : Reconstructed function.
    
    Time complexity: O(|S| × n)
    """
    coeffs = compute_all_residuated_coefficients(K, f)
    pred = np.full(K.n, -np.inf)
    for x in support:
        pred = np.maximum(pred, coeffs[x] + K.matrix[x, :])
    return pred


def greedy_minimal_support(K: TropicalKernel, f: np.ndarray,
                            tol: float = 1e-10) -> List[int]:
    """
    Find a minimal support set by greedy backward elimination.
    
    Start with all points as support and iteratively remove elements
    that don't affect the reconstruction quality.
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray
    tol : float
        Tolerance for reconstruction accuracy.
    
    Returns
    -------
    List[int] : Minimal support set.
    
    Time complexity: O(n² × |S_final|) in practice, O(n³) worst case.
    """
    support = list(range(K.n))
    
    for x in range(K.n):
        candidate = [s for s in support if s != x]
        if len(candidate) == 0:
            continue
        pred = reconstruct_from_support(K, f, candidate)
        if np.max(np.abs(pred - f)) < tol:
            support = candidate
    
    return support


def verify_antichain(K: TropicalKernel, f: np.ndarray,
                      support: List[int],
                      tol: float = 1e-10) -> bool:
    """
    Verify that a support set forms an antichain under the
    residuated domination preorder.
    
    x dominates z if res(K,f,x) + K(x,y) ≤ res(K,f,z) + K(z,y) ∀y.
    An antichain has no domination relations.
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray
    support : List[int]
    tol : float
    
    Returns
    -------
    bool : True if support is an antichain.
    
    Time complexity: O(|S|² × n)
    """
    coeffs = compute_all_residuated_coefficients(K, f)
    for x in support:
        for z in support:
            if x == z:
                continue
            dominated = np.all(
                coeffs[x] + K.matrix[x, :] <=
                coeffs[z] + K.matrix[z, :] + tol
            )
            if dominated:
                return False
    return True


def certified_decomposition(K: TropicalKernel,
                             f: np.ndarray,
                             tol: float = 1e-10) -> SupportDecomposition:
    """
    Compute a certified minimal support decomposition.
    
    This is the main algorithm: given a tropical kernel and a target
    function, find the minimal antichain support and verify all
    certification conditions.
    
    Parameters
    ----------
    K : TropicalKernel
    f : np.ndarray
    tol : float
    
    Returns
    -------
    SupportDecomposition : Complete decomposition with certificates.
    
    Time complexity: O(n³) overall.
    """
    # Step 1: Compute all residuated coefficients
    coeffs = compute_all_residuated_coefficients(K, f)
    
    # Step 2: Find minimal support
    support = greedy_minimal_support(K, f, tol)
    
    # Step 3: Reconstruct and compute error
    pred = reconstruct_from_support(K, f, support)
    error = float(np.max(np.abs(pred - f)))
    
    # Step 4: Verify minimality
    is_minimal = True
    for x in support:
        reduced = [s for s in support if s != x]
        if len(reduced) == 0:
            continue
        reduced_pred = reconstruct_from_support(K, f, reduced)
        if np.max(np.abs(reduced_pred - f)) < tol:
            is_minimal = False
            break
    
    # Step 5: Verify antichain
    is_antichain = verify_antichain(K, f, support, tol)
    
    return SupportDecomposition(
        support=support,
        coefficients=coeffs[support],
        is_minimal=is_minimal,
        is_antichain=is_antichain,
        reconstruction_error=error,
    )


def estimate_feature_rank(K: TropicalKernel,
                           max_rank: Optional[int] = None) -> int:
    """
    Estimate the tropical feature rank of a kernel matrix.
    
    Uses the observation that rank-r kernels have at most r
    "independent directions" in their section family. We estimate
    this by finding the size of a maximal non-dominated subset.
    
    Parameters
    ----------
    K : TropicalKernel
    max_rank : int, optional
        Maximum rank to consider.
    
    Returns
    -------
    int : Estimated feature rank.
    
    Time complexity: O(n³)
    """
    n = K.n
    if max_rank is None:
        max_rank = n
    
    # Find non-dominated sections
    non_dominated = list(range(n))
    for x in range(n):
        if x not in non_dominated:
            continue
        for z in range(n):
            if z == x or z not in non_dominated:
                continue
            # Check if section z is dominated by section x
            dominated = True
            for y in range(n):
                if K.matrix[z, y] > K.matrix[x, y]:
                    dominated = False
                    break
            if dominated:
                non_dominated.remove(z)
    
    return min(len(non_dominated), max_rank)


if __name__ == "__main__":
    # Quick test
    np.random.seed(42)
    phi = np.random.randn(8, 3)
    K = TropicalKernel.from_features(phi)
    
    print(f"Kernel: {K.n}×{K.n}, rank={K.rank}")
    print(f"Symmetric: {K.is_symmetric()}")
    
    f = K.section(0)
    decomp = certified_decomposition(K, f)
    print(f"\nDecomposition of K_0:")
    print(f"  Support: {decomp.support}")
    print(f"  Coefficients: {decomp.coefficients}")
    print(f"  Minimal: {decomp.is_minimal}")
    print(f"  Antichain: {decomp.is_antichain}")
    print(f"  Error: {decomp.reconstruction_error:.2e}")
    
    rank = estimate_feature_rank(K)
    print(f"\nEstimated feature rank: {rank}")
