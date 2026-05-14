#!/usr/bin/env python3
"""
Algorithms for Category-Theoretic Neural Architecture Analysis

Implements the core algorithms derived from the formal theorems:
1. Residual stack analysis (composition, invertibility, spectral radius)
2. Attention naturality measurement
3. Architecture perturbation bound computation
4. Čech coboundary complex and gluing verification
"""

import numpy as np
from typing import List, Tuple, Optional


# ============================================================
# Algorithm 1: Residual Stack Analysis
# ============================================================

def residual_layer(f: np.ndarray) -> np.ndarray:
    """
    Construct residual layer matrix I + f.
    
    Parameters:
        f: Square matrix representing the layer transformation
        
    Returns:
        I + f as a numpy array
        
    Time complexity: O(n²) where n is the matrix dimension
    Space complexity: O(n²)
    """
    n = f.shape[0]
    return np.eye(n) + f


def compose_residual_stack(layers: List[np.ndarray]) -> np.ndarray:
    """
    Compose a stack of residual layers: ∏(I + f_i).
    
    Uses the algebraic identity (I+f)(I+g) = I + (f+g+fg) iteratively.
    
    Parameters:
        layers: List of square matrices [f_1, ..., f_k]
        
    Returns:
        Product matrix ∏(I + f_i)
        
    Time complexity: O(k·n³) for k layers of dimension n (matrix multiplication)
    Space complexity: O(n²)
    
    Example:
        >>> f = np.array([[0.1, 0.2], [-0.1, 0.3]])
        >>> g = np.array([[0.2, -0.1], [0.1, 0.1]])
        >>> result = compose_residual_stack([f, g])
        >>> expected = (np.eye(2) + f) @ (np.eye(2) + g)
        >>> np.allclose(result, expected)
        True
    """
    n = layers[0].shape[0]
    result = np.eye(n)
    for f in layers:
        result = result @ (np.eye(n) + f)
    return result


def residual_stack_spectrum(layers: List[np.ndarray]) -> np.ndarray:
    """
    Compute eigenvalues of the composed residual stack.
    
    The spectral radius controls the stability of the network.
    For stable networks, all eigenvalues should have modulus ≤ 1.
    
    Parameters:
        layers: List of square layer matrices
        
    Returns:
        Array of eigenvalues (complex)
        
    Time complexity: O(k·n³ + n³) (composition + eigendecomposition)
    """
    composed = compose_residual_stack(layers)
    return np.linalg.eigvals(composed)


def check_residual_invertibility(f: np.ndarray, tol: float = 1e-10) -> Tuple[bool, float]:
    """
    Check if residual layer I + f is invertible via determinant.
    
    By Theorem 1d: residual layer is invertible ⟺ det(I + f) ≠ 0.
    
    Parameters:
        f: Square matrix
        tol: Threshold for near-zero determinant
        
    Returns:
        (is_invertible, determinant)
    """
    det = np.linalg.det(np.eye(f.shape[0]) + f)
    return (abs(det) > tol, det)


# ============================================================
# Algorithm 2: Attention Naturality Measurement
# ============================================================

def naturality_defect(W: np.ndarray, n_samples: int = 1000) -> float:
    """
    Measure how far an attention matrix W is from being a natural transformation.
    
    By Theorem 2c (Schur's lemma), W is natural ⟺ W = c·I for some scalar c.
    The naturality defect is the supremum of ‖φW - Wφ‖ over unit-norm φ.
    
    We approximate this by sampling random matrices φ.
    
    Parameters:
        W: Square attention matrix
        n_samples: Number of random matrices to test
        
    Returns:
        Maximum observed ‖φW - Wφ‖_F (Frobenius norm)
        
    Time complexity: O(n_samples · n³)
    
    Example:
        >>> n = 5
        >>> W_natural = 3.0 * np.eye(n)  # scalar = natural
        >>> naturality_defect(W_natural) < 1e-10
        True
    """
    n = W.shape[0]
    max_defect = 0.0
    for _ in range(n_samples):
        phi = np.random.randn(n, n)
        phi /= np.linalg.norm(phi, 'fro')  # normalize
        commutator = phi @ W - W @ phi
        defect = np.linalg.norm(commutator, 'fro')
        max_defect = max(max_defect, defect)
    return max_defect


def project_to_natural(W: np.ndarray) -> Tuple[np.ndarray, float]:
    """
    Project attention matrix to nearest natural transformation (scalar matrix).
    
    The nearest scalar matrix to W is (tr(W)/n) · I.
    
    Parameters:
        W: Square attention matrix
        
    Returns:
        (projected_matrix, scalar_value)
        
    Time complexity: O(n)
    """
    n = W.shape[0]
    c = np.trace(W) / n
    return c * np.eye(n), c


def attention_equivariance_score(W: np.ndarray, n_samples: int = 1000) -> float:
    """
    Score how equivariant an attention matrix is (0 = not equivariant, 1 = perfectly equivariant).
    
    Score = 1 - (naturality_defect / ‖W‖_F), clamped to [0, 1].
    
    Parameters:
        W: Square attention matrix
        n_samples: Sampling count for defect estimation
        
    Returns:
        Equivariance score in [0, 1]
    """
    W_norm = np.linalg.norm(W, 'fro')
    if W_norm < 1e-15:
        return 1.0  # zero matrix is trivially natural
    defect = naturality_defect(W, n_samples)
    return max(0.0, 1.0 - defect / W_norm)


# ============================================================
# Algorithm 3: Architecture Perturbation Bound
# ============================================================

def architecture_distance(a: np.ndarray, b: np.ndarray) -> float:
    """
    Compute L¹ architecture distance: d(a, b) = Σ|a_i - b_i|.
    
    Parameters:
        a, b: Layer parameter vectors (1D arrays)
        
    Returns:
        Non-negative distance
        
    Time complexity: O(k) where k is number of layers
    """
    return np.sum(np.abs(a - b))


def composition_perturbation_bound_two(a1: float, a2: float, 
                                        b1: float, b2: float) -> Tuple[float, float]:
    """
    Compute actual perturbation and theoretical bound for two-layer composition.
    
    Theorem 3a: |b₁b₂ - a₁a₂| ≤ |b₁-a₁|·|b₂| + |a₁|·|b₂-a₂|
    
    Parameters:
        a1, a2: Original layer weights
        b1, b2: Perturbed layer weights
        
    Returns:
        (actual_perturbation, theoretical_bound)
    """
    actual = abs(b1*b2 - a1*a2)
    bound = abs(b1-a1)*abs(b2) + abs(a1)*abs(b2-a2)
    return actual, bound


def composition_perturbation_bound_k(a: np.ndarray, b: np.ndarray) -> Tuple[float, float]:
    """
    Compute actual perturbation and telescoping bound for k-layer composition.
    
    General telescoping: |∏b_i - ∏a_i| ≤ Σ_i (∏_{j<i}|b_j|)·|b_i-a_i|·(∏_{j>i}|a_j|)
    
    Parameters:
        a, b: Layer weight arrays of length k
        
    Returns:
        (actual_perturbation, telescoping_bound)
        
    Time complexity: O(k²) (computing prefix and suffix products)
    """
    k = len(a)
    actual = abs(np.prod(b) - np.prod(a))
    
    bound = 0.0
    for i in range(k):
        prefix = np.prod(np.abs(b[:i])) if i > 0 else 1.0
        suffix = np.prod(np.abs(a[i+1:])) if i < k-1 else 1.0
        bound += prefix * abs(b[i] - a[i]) * suffix
    
    return actual, bound


def certified_architecture_search_radius(a: np.ndarray, 
                                          max_error_increase: float) -> float:
    """
    Compute maximum per-layer perturbation ensuring error increase ≤ max_error_increase.
    
    Uses the perturbation bound to certify a search radius.
    
    Parameters:
        a: Current architecture (layer weights)
        max_error_increase: Maximum allowed increase in composition error
        
    Returns:
        Maximum per-layer perturbation δ such that changing each layer by at most δ
        increases composition error by at most max_error_increase
        
    Time complexity: O(k)
    """
    k = len(a)
    # Bound: error ≤ Σ_i (∏_{j≠i} max(|a_j|, |a_j+δ|)) · δ
    # ≈ k · max(|a|)^(k-1) · δ for small δ
    max_weight = np.max(np.abs(a))
    sensitivity = k * max(max_weight, 1.0) ** (k - 1)
    if sensitivity < 1e-15:
        return float('inf')
    return max_error_increase / sensitivity


# ============================================================
# Algorithm 4: Čech Coboundary Complex and Gluing
# ============================================================

def compute_delta0(f: np.ndarray) -> np.ndarray:
    """
    Compute 0th coboundary: (δ⁰f)(i,j) = f(j) - f(i).
    
    Parameters:
        f: 0-cochain (1D array of length m)
        
    Returns:
        1-cochain (m×m matrix)
        
    Time complexity: O(m²)
    """
    m = len(f)
    return np.subtract.outer(f, f).T  # delta0[i,j] = f[j] - f[i]


def compute_delta1(g: np.ndarray) -> np.ndarray:
    """
    Compute 1st coboundary: (δ¹g)(i,j,k) = g(j,k) - g(i,k) + g(i,j).
    
    Parameters:
        g: 1-cochain (m×m matrix)
        
    Returns:
        2-cochain (m×m×m tensor)
        
    Time complexity: O(m³)
    """
    m = g.shape[0]
    result = np.zeros((m, m, m))
    for i in range(m):
        for j in range(m):
            for k in range(m):
                result[i, j, k] = g[j, k] - g[i, k] + g[i, j]
    return result


def verify_cochain_complex(f: np.ndarray) -> float:
    """
    Verify δ¹ ∘ δ⁰ = 0 for a given 0-cochain.
    
    Parameters:
        f: 0-cochain
        
    Returns:
        Maximum absolute value of δ¹(δ⁰(f)), should be ≈ 0
        
    Time complexity: O(m³)
    """
    delta0 = compute_delta0(f)
    delta1_delta0 = compute_delta1(delta0)
    return np.max(np.abs(delta1_delta0))


def check_cocycle_condition(g: np.ndarray) -> Tuple[bool, float]:
    """
    Check if a 1-cochain satisfies the cocycle condition δ¹g = 0.
    
    Parameters:
        g: 1-cochain (m×m matrix)
        
    Returns:
        (is_cocycle, max_violation)
    """
    delta1_g = compute_delta1(g)
    max_violation = np.max(np.abs(delta1_g))
    return max_violation < 1e-10, max_violation


def glue_from_cocycle(g: np.ndarray) -> Optional[np.ndarray]:
    """
    Given a 1-cocycle g (satisfying antisymmetry and cocycle condition),
    reconstruct the global 0-cochain f such that δ⁰f = g.
    
    By the gluing theorem: f(i) = g(0, i).
    
    Parameters:
        g: 1-cochain satisfying cocycle condition
        
    Returns:
        0-cochain f such that f(j) - f(i) = g(i,j), or None if g is not a cocycle
        
    Time complexity: O(m)
    """
    is_cocycle, violation = check_cocycle_condition(g)
    if not is_cocycle:
        return None
    return g[0, :]  # f(i) = g(0, i)


def check_gluing_consistency(g: np.ndarray) -> Tuple[bool, float]:
    """
    Check if local subnetwork parameters can be globally assembled.
    
    Verifies the transitivity condition: g(i,k) = g(i,j) + g(j,k) for all i,j,k.
    
    Parameters:
        g: Pairwise discrepancy matrix (1-cochain)
        
    Returns:
        (can_glue, max_inconsistency)
        
    Time complexity: O(m³)
    """
    m = g.shape[0]
    max_inconsistency = 0.0
    for i in range(m):
        for j in range(m):
            for k in range(m):
                inconsistency = abs(g[i, k] - g[i, j] - g[j, k])
                max_inconsistency = max(max_inconsistency, inconsistency)
    return max_inconsistency < 1e-10, max_inconsistency


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    np.random.seed(42)
    
    print("=== Algorithm Demonstrations ===\n")
    
    # Residual stack
    n = 4
    layers = [0.1 * np.random.randn(n, n) for _ in range(5)]
    composed = compose_residual_stack(layers)
    eigenvalues = residual_stack_spectrum(layers)
    print(f"5-layer residual stack ({n}×{n}):")
    print(f"  Spectral radius: {np.max(np.abs(eigenvalues)):.4f}")
    print(f"  Invertible: {check_residual_invertibility(layers[0])}")
    
    # Attention
    W_test = np.random.randn(n, n)
    W_proj, c = project_to_natural(W_test)
    print(f"\nAttention matrix projection:")
    print(f"  Original naturality defect: {naturality_defect(W_test, 500):.4f}")
    print(f"  Projected (c={c:.4f})·I defect: {naturality_defect(W_proj, 500):.2e}")
    print(f"  Equivariance score: {attention_equivariance_score(W_test, 500):.4f}")
    
    # Perturbation bounds
    a = np.random.randn(6)
    b = a + 0.05 * np.random.randn(6)
    actual, bound = composition_perturbation_bound_k(a, b)
    print(f"\n6-layer perturbation bound:")
    print(f"  Actual: {actual:.6f}, Bound: {bound:.6f}, Ratio: {actual/bound:.4f}")
    print(f"  Certified search radius (ε=0.01): {certified_architecture_search_radius(a, 0.01):.6f}")
    
    # Gluing
    m = 5
    f_true = np.random.randn(m)
    g = compute_delta0(f_true)
    f_reconstructed = glue_from_cocycle(g)
    print(f"\nGluing verification (m={m}):")
    print(f"  Cocycle check: {check_cocycle_condition(g)}")
    print(f"  Gluing consistency: {check_gluing_consistency(g)}")
    print(f"  Reconstruction error: {np.max(np.abs(compute_delta0(f_reconstructed) - g)):.2e}")
