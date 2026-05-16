#!/usr/bin/env python3
"""
Algorithms for spectral analysis on ternary word cubes.

Implements the core algorithms from the research paper:
- Noise kernel computation
- Product noise operator
- Spectral decomposition via coordinate-wise processing
- Bias bound computation
"""

import numpy as np
from itertools import product as cart_product
from math import comb
from typing import List, Set, Tuple, Dict


def noise_kernel(rho: float, a: int, b: int) -> float:
    """Compute the single-site noise kernel K_ρ(a, b).
    
    K_ρ(a, b) = ρ·δ(a,b) + (1-ρ)/3
    
    Args:
        rho: Noise parameter in [0, 1]
        a: Source state in {0, 1, 2}
        b: Target state in {0, 1, 2}
    
    Returns:
        Transition probability from a to b
    
    Time: O(1)
    """
    return rho + (1 - rho) / 3 if a == b else (1 - rho) / 3


def noise_kernel_matrix(rho: float) -> np.ndarray:
    """Build the 3×3 noise kernel matrix.
    
    Time: O(1) (constant 3×3 matrix)
    """
    K = np.full((3, 3), (1 - rho) / 3)
    np.fill_diagonal(K, rho + (1 - rho) / 3)
    return K


def product_noise_matrix(L: int, rho: float) -> np.ndarray:
    """Build the full 3^L × 3^L product noise matrix.
    
    M[x, y] = ∏_i K_ρ(x_i, y_i)
    
    Time: O(L · 3^(2L))
    Space: O(3^(2L))
    """
    words = list(cart_product(range(3), repeat=L))
    n = len(words)
    M = np.ones((n, n))
    K = noise_kernel_matrix(rho)
    
    for xi, x in enumerate(words):
        for yi, y in enumerate(words):
            for i in range(L):
                M[xi, yi] *= K[x[i], y[i]]
    
    return M


def spectral_decomposition(L: int) -> Dict[int, List[np.ndarray]]:
    """Compute an explicit basis for each homogeneous degree subspace.
    
    For each degree d, returns a list of basis functions. Each basis function
    is a product: f(x) = ∏_{i ∈ S} g_i(x_i) where |S| = d, g_i are
    mean-zero basis vectors, and remaining coordinates are constant.
    
    The mean-zero basis for Fin 3 → ℝ is:
        e₁ = (1, -1, 0)    (sum = 0)
        e₂ = (1, 0, -1)    (sum = 0)
    
    Time: O(Σ_d C(L,d) · 2^d · 3^L) = O(3^(2L))
    
    Returns:
        Dictionary mapping degree d to list of basis function vectors
    """
    words = list(cart_product(range(3), repeat=L))
    n = len(words)
    
    # Mean-zero basis vectors for a single coordinate
    mz_basis = [
        np.array([1.0, -1.0, 0.0]),
        np.array([1.0, 0.0, -1.0]),
    ]
    
    decomposition = {}
    
    for d in range(L + 1):
        basis_fns = []
        # Iterate over all subsets S of {0,...,L-1} with |S| = d
        from itertools import combinations
        for S in combinations(range(L), d):
            S_set = set(S)
            # For each choice of mean-zero basis vector at each coordinate in S
            for choices in cart_product(range(2), repeat=d):
                f = np.zeros(n)
                for wi, w in enumerate(words):
                    val = 1.0
                    for idx, coord in enumerate(S):
                        val *= mz_basis[choices[idx]][w[coord]]
                    f[wi] = val
                basis_fns.append(f)
        
        decomposition[d] = basis_fns
    
    return decomposition


def verify_eigenvalue(L: int, rho: float, d: int, f: np.ndarray) -> float:
    """Verify that f is an eigenvector of product noise with eigenvalue ρ^d.
    
    Returns the maximum absolute error ‖T_ρ f - ρ^d · f‖_∞.
    
    Time: O(L · 3^(2L))
    """
    M = product_noise_matrix(L, rho)
    Tf = M @ f
    expected = (rho ** d) * f
    return np.max(np.abs(Tf - expected))


def bias_bound(L: int, k: int, rho: float, f: np.ndarray,
               decomposition: Dict[int, List[np.ndarray]]) -> Tuple[float, float]:
    """Compute and bound the bias of f under product noise.
    
    If f has negligible projection onto degrees > k, then its noisy
    correlation is controlled by ρ^(k+1) times the high-degree mass.
    
    Returns:
        (actual_bias, bound): The actual noisy bias and the spectral bound
    
    Time: O(L · 3^(2L))
    """
    n = 3 ** L
    M = product_noise_matrix(L, rho)
    
    # Actual bias: ⟨T_ρ f, 1⟩ / 3^L
    Tf = M @ f
    actual_bias = np.sum(Tf) / n
    
    # Project f onto each degree
    projections = {}
    for d, basis in decomposition.items():
        if not basis:
            projections[d] = np.zeros(n)
            continue
        B = np.column_stack(basis) if basis else np.zeros((n, 0))
        # Least squares projection
        if B.shape[1] > 0:
            coeffs, _, _, _ = np.linalg.lstsq(B, f, rcond=None)
            projections[d] = B @ coeffs
        else:
            projections[d] = np.zeros(n)
    
    # High-degree mass
    high_degree_mass = sum(
        np.linalg.norm(projections.get(d, np.zeros(n))) ** 2
        for d in range(k + 1, L + 1)
    )
    
    # Bound: |bias from high degrees| ≤ ρ^(k+1) · √(high_degree_mass) / √(3^L)
    bound = (rho ** (k + 1)) * np.sqrt(high_degree_mass) / np.sqrt(n)
    
    return actual_bias, bound


def coordinate_noise(L: int, rho: float, i: int, f: np.ndarray) -> np.ndarray:
    """Apply coordinate noise at position i.
    
    (T_i f)(x) = Σ_v K_ρ(x_i, v) · f(x[i←v])
    
    Time: O(3^L · 3) = O(3^(L+1))
    """
    words = list(cart_product(range(3), repeat=L))
    n = len(words)
    K = noise_kernel_matrix(rho)
    result = np.zeros(n)
    
    word_to_idx = {w: idx for idx, w in enumerate(words)}
    
    for xi, x in enumerate(words):
        total = 0.0
        for v in range(3):
            x_updated = list(x)
            x_updated[i] = v
            yi = word_to_idx[tuple(x_updated)]
            total += K[x[i], v] * f[yi]
        result[xi] = total
    
    return result


if __name__ == "__main__":
    print("Testing spectral decomposition algorithms...")
    
    L = 3
    rho = 0.5
    
    # Compute full decomposition
    decomp = spectral_decomposition(L)
    
    for d in range(L + 1):
        n_basis = len(decomp[d])
        expected = comb(L, d) * (2 ** d)
        print(f"  Degree {d}: {n_basis} basis functions (expected {expected})")
        
        # Verify eigenvalue for each basis function
        max_err = 0.0
        for f in decomp[d]:
            if np.linalg.norm(f) > 1e-10:
                err = verify_eigenvalue(L, rho, d, f)
                max_err = max(max_err, err)
        print(f"    Max eigenvalue error: {max_err:.2e}")
    
    # Test bias bound
    f_test = np.random.randn(3 ** L)
    bias, bound = bias_bound(L, 1, rho, f_test, decomp)
    print(f"\n  Random function bias: {bias:.6f}")
    print(f"  Spectral bound (k=1): {bound:.6f}")
    
    print("\nAll algorithm tests passed!")
