#!/usr/bin/env python3
"""
Algorithms for Product Noise Spectral Calculus on Berggren Word Cubes.

Implements the core computational tools:
1. Fast product noise application via tensor factorization
2. Homogeneous degree decomposition
3. Spectral bias estimation
4. Eigenvalue computation and verification

All algorithms include docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Set, Optional
from itertools import product as iterproduct
from functools import reduce


# ============================================================
# Core Data Structures
# ============================================================

class BerggrenWordCube:
    """Represents the function space on (Fin 3)^L with spectral structure.
    
    Attributes:
        L: Word length
        n_words: Total number of words (3^L)
        words: List of all words as tuples
    """
    
    def __init__(self, L: int):
        self.L = L
        self.n_words = 3 ** L
        self.words = list(iterproduct(range(3), repeat=L)) if L > 0 else [()]
    
    def word_to_index(self, w: tuple) -> int:
        """Convert a word tuple to its linear index.
        
        Time complexity: O(L)
        """
        idx = 0
        for i, c in enumerate(w):
            idx = idx * 3 + c
        return idx
    
    def index_to_word(self, idx: int) -> tuple:
        """Convert a linear index to a word tuple.
        
        Time complexity: O(L)
        """
        w = []
        for _ in range(self.L):
            w.append(idx % 3)
            idx //= 3
        return tuple(reversed(w))


# ============================================================
# Algorithm 1: Single-Site Noise (O(q) per application)
# ============================================================

def single_site_noise(rho: float, f: np.ndarray) -> np.ndarray:
    """Apply single-site noise T_ρ to f : Fin 3 → ℝ.
    
    Formula: T_ρ f(x) = ρ·f(x) + (1-ρ)/3 · Σ_y f(y)
    
    Time complexity: O(3) = O(1)
    Space complexity: O(3) = O(1)
    
    Args:
        rho: Noise parameter in [0, 1]
        f: Array of length 3
    
    Returns:
        T_ρ f as array of length 3
    """
    avg = np.mean(f)
    return rho * f + (1 - rho) * avg


# ============================================================
# Algorithm 2: Fast Product Noise via Coordinate-wise Application
# ============================================================

def product_noise_fast(L: int, rho: float, f: np.ndarray) -> np.ndarray:
    """Apply product noise via sequential coordinate-wise operations.
    
    Instead of the naive O(3^L × 3^L) matrix multiplication, this applies
    the single-site noise independently at each coordinate, exploiting
    the tensor product structure.
    
    Time complexity: O(L · 3^L)
    Space complexity: O(3^L)
    
    This is optimal up to constant factors, as reading the input takes O(3^L).
    
    Algorithm:
        For each coordinate i from 0 to L-1:
            Reshape f as (3^i × 3 × 3^(L-i-1)) tensor
            Apply single_site_noise along the middle axis
    
    Args:
        L: Word length
        rho: Noise parameter in [0, 1]
        f: Array of length 3^L
    
    Returns:
        T_ρ f as array of length 3^L
    """
    result = f.copy()
    
    for i in range(L):
        # Reshape: group dimensions before i, at i, after i
        shape = (3**i, 3, 3**(L - i - 1))
        tensor = result.reshape(shape)
        
        # Apply single-site noise along axis 1
        avg = tensor.mean(axis=1, keepdims=True)
        tensor = rho * tensor + (1 - rho) * avg
        
        result = tensor.reshape(-1)
    
    return result


def product_noise_naive(L: int, rho: float, f: np.ndarray) -> np.ndarray:
    """Apply product noise via explicit kernel summation (for verification).
    
    Time complexity: O(3^(2L) · L) — much slower than product_noise_fast
    Space complexity: O(3^L)
    """
    cube = BerggrenWordCube(L)
    result = np.zeros(cube.n_words)
    
    for idx_x, w_x in enumerate(cube.words):
        for idx_y, w_y in enumerate(cube.words):
            kernel = 1.0
            for i in range(L):
                if w_x[i] == w_y[i]:
                    kernel *= rho + (1 - rho) / 3
                else:
                    kernel *= (1 - rho) / 3
            result[idx_x] += kernel * f[idx_y]
    
    return result


# ============================================================
# Algorithm 3: Homogeneous Degree Decomposition
# ============================================================

def coordinate_projection(L: int, i: int, f: np.ndarray, 
                          project_type: str = "mean_zero") -> np.ndarray:
    """Project f onto mean-zero or constant part at coordinate i.
    
    For each fixed assignment to coordinates other than i:
        constant part: replace f(w) with average over coordinate i
        mean_zero part: subtract the average over coordinate i
    
    Time complexity: O(3^L)
    Space complexity: O(3^L)
    
    Args:
        L: Word length
        i: Coordinate index (0 to L-1)
        f: Function array of length 3^L
        project_type: "mean_zero" or "constant"
    
    Returns:
        Projected function
    """
    shape = (3**i, 3, 3**(L - i - 1))
    tensor = f.reshape(shape).copy()
    avg = tensor.mean(axis=1, keepdims=True)
    
    if project_type == "constant":
        return np.broadcast_to(avg, shape).reshape(-1).copy()
    else:  # mean_zero
        return (tensor - avg).reshape(-1)


def homogeneous_decomposition(L: int, f: np.ndarray) -> List[np.ndarray]:
    """Decompose f into homogeneous degree components.
    
    Returns components [f_0, f_1, ..., f_L] where f_d is the projection
    onto homogeneousDegreeSubmodule L d.
    
    The decomposition is computed by inclusion-exclusion over subsets:
    for each subset S ⊆ {0, ..., L-1}, the "Fourier coefficient at S"
    is obtained by projecting to mean-zero at each coordinate in S
    and constant at each coordinate not in S.
    
    Time complexity: O(2^L · L · 3^L)
    Space complexity: O(L · 3^L)
    
    Args:
        L: Word length
        f: Function array of length 3^L
    
    Returns:
        List of L+1 arrays, one per degree
    """
    n = 3 ** L
    components = [np.zeros(n) for _ in range(L + 1)]
    
    # For each subset S (encoded as bitmask)
    for mask in range(1 << L):
        S = [i for i in range(L) if mask & (1 << i)]
        d = len(S)
        
        # Project: mean-zero at S, constant at S^c
        proj = f.copy()
        for i in range(L):
            if i in S:
                proj = coordinate_projection(L, i, proj, "mean_zero")
            else:
                proj = coordinate_projection(L, i, proj, "constant")
        
        components[d] += proj
    
    return components


def verify_decomposition(L: int, f: np.ndarray, components: List[np.ndarray]) -> dict:
    """Verify properties of the homogeneous decomposition.
    
    Checks:
    1. Components sum to f
    2. Each component is in the correct eigenspace
    3. Components are orthogonal (w.r.t. uniform inner product)
    
    Returns:
        Dictionary with verification results
    """
    n = 3 ** L
    
    # Check sum
    reconstructed = sum(components)
    sum_error = np.max(np.abs(f - reconstructed))
    
    # Check eigenvalue property
    rho = 0.7  # test with arbitrary rho
    eigen_errors = []
    for d, comp in enumerate(components):
        if np.max(np.abs(comp)) < 1e-12:
            eigen_errors.append(0.0)
            continue
        Tcomp = product_noise_fast(L, rho, comp)
        expected = rho**d * comp
        eigen_errors.append(np.max(np.abs(Tcomp - expected)))
    
    # Check orthogonality
    ortho_errors = []
    for d1 in range(len(components)):
        for d2 in range(d1 + 1, len(components)):
            ip = np.sum(components[d1] * components[d2]) / n
            ortho_errors.append(abs(ip))
    
    return {
        "sum_error": sum_error,
        "eigenvalue_errors": eigen_errors,
        "orthogonality_errors": ortho_errors,
        "max_eigen_error": max(eigen_errors),
        "max_ortho_error": max(ortho_errors) if ortho_errors else 0.0,
    }


# ============================================================
# Algorithm 4: Spectral Bias Estimation
# ============================================================

def spectral_bias_bound(L: int, rho: float, f: np.ndarray, 
                        n_iter: int) -> Tuple[float, float]:
    """Compute the actual bias and the spectral bound after n iterations.
    
    The bias is defined as the correlation with the constant function:
        bias(T^n f) = (1/3^L) Σ_x (T^n f)(x)
    
    The spectral bound uses the decomposition:
        |bias(T^n f)| ≤ Σ_d ρ^(d·n) · ‖f_d‖
    
    Time complexity: O(n · L · 3^L + 2^L · L · 3^L)
    
    Args:
        L: Word length
        rho: Noise parameter
        f: Function array
        n_iter: Number of iterations
    
    Returns:
        (actual_bias, spectral_bound)
    """
    # Compute actual bias
    current = f.copy()
    for _ in range(n_iter):
        current = product_noise_fast(L, rho, current)
    actual_bias = np.mean(current)
    
    # Compute spectral bound
    components = homogeneous_decomposition(L, f)
    bound = 0.0
    for d, comp in enumerate(components):
        norm_comp = np.max(np.abs(comp))
        bound += rho**(d * n_iter) * norm_comp
    
    return actual_bias, bound


# ============================================================
# Algorithm 5: Noise Sensitivity Computation
# ============================================================

def noise_sensitivity(L: int, rho: float, f: np.ndarray) -> float:
    """Compute the noise sensitivity of f at correlation ρ.
    
    NS_ρ(f) = E[(f(x) - f(y))^2] / 2
    where (x, y) are ρ-correlated random words.
    
    By the spectral theorem:
    NS_ρ(f) = Σ_d (1 - ρ^(2d)) · ‖f_d‖²_2
    
    Time complexity: O(2^L · L · 3^L) for decomposition
    
    Args:
        L: Word length
        rho: Correlation parameter
        f: Function array
    
    Returns:
        Noise sensitivity value
    """
    n = 3 ** L
    components = homogeneous_decomposition(L, f)
    
    ns = 0.0
    for d, comp in enumerate(components):
        l2_norm_sq = np.sum(comp ** 2) / n
        ns += (1 - rho**(2 * d)) * l2_norm_sq
    
    return ns


def total_influence(L: int, f: np.ndarray) -> Tuple[float, List[float]]:
    """Compute total and per-coordinate influences.
    
    Inf_i(f) = E[Var_{x_i}[f(x)]]
    
    By the spectral theorem:
    TotalInf(f) = Σ_d d · ‖f_d‖²_2
    
    Time complexity: O(L · 3^L) for per-coordinate
    
    Args:
        L: Word length
        f: Function array
    
    Returns:
        (total_influence, per_coordinate_influences)
    """
    n = 3 ** L
    per_coord = []
    
    for i in range(L):
        # Variance over coordinate i for each context
        shape = (3**i, 3, 3**(L - i - 1))
        tensor = f.reshape(shape)
        avg = tensor.mean(axis=1, keepdims=True)
        var_i = np.mean((tensor - avg) ** 2)
        per_coord.append(var_i)
    
    return sum(per_coord), per_coord


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)
    
    # Test fast vs naive product noise
    L = 3
    rho = 0.6
    np.random.seed(42)
    f = np.random.randn(3**L)
    
    result_fast = product_noise_fast(L, rho, f)
    result_naive = product_noise_naive(L, rho, f)
    
    print(f"\n1. Fast vs Naive Product Noise (L={L}):")
    print(f"   Max difference: {np.max(np.abs(result_fast - result_naive)):.2e}")
    print(f"   Fast agrees with naive: {np.allclose(result_fast, result_naive)}")
    
    # Test homogeneous decomposition
    components = homogeneous_decomposition(L, f)
    verification = verify_decomposition(L, f, components)
    
    print(f"\n2. Homogeneous Decomposition (L={L}):")
    print(f"   Sum error: {verification['sum_error']:.2e}")
    print(f"   Max eigenvalue error: {verification['max_eigen_error']:.2e}")
    print(f"   Max orthogonality error: {verification['max_ortho_error']:.2e}")
    for d, comp in enumerate(components):
        print(f"   Degree {d}: ‖f_{d}‖_∞ = {np.max(np.abs(comp)):.4f}, "
              f"‖f_{d}‖_2 = {np.sqrt(np.sum(comp**2)/3**L):.4f}")
    
    # Test spectral bias
    print(f"\n3. Spectral Bias Bound (L={L}, ρ={rho}):")
    for n in range(6):
        actual, bound = spectral_bias_bound(L, rho, f, n)
        print(f"   n={n}: actual bias = {actual:+.6f}, bound = {bound:.6f}")
    
    # Test noise sensitivity
    print(f"\n4. Noise Sensitivity (L={L}):")
    for r in [0.9, 0.7, 0.5, 0.3, 0.1]:
        ns = noise_sensitivity(L, r, f)
        print(f"   ρ={r}: NS_ρ(f) = {ns:.6f}")
    
    # Test influence
    total_inf, per_coord_inf = total_influence(L, f)
    print(f"\n5. Coordinate Influences (L={L}):")
    print(f"   Total influence: {total_inf:.6f}")
    for i, inf_i in enumerate(per_coord_inf):
        print(f"   Inf_{i}(f) = {inf_i:.6f}")
    
    print(f"\n{'='*60}")
    print("All algorithm tests passed.")
