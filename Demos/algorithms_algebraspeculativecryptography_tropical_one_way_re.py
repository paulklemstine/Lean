#!/usr/bin/env python3
"""
Tropical One-Way Kernel Duality: Core Algorithms

Implements the computational algorithms from the research paper:
- Tropical Gram matrix computation
- Kernel profile composition
- Idempotency verification
- Generator extraction
- Network reconstruction
"""

import numpy as np
from typing import List, Tuple, Set, Optional


def tropical_matrix_multiply(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical (min-plus) matrix multiplication.
    
    (A ⊗ B)[i,j] = min_k(A[i,k] + B[k,j])
    
    Time: O(n³), Space: O(n²)
    
    Args:
        A, B: n×n matrices
    Returns:
        n×n tropical product
    """
    n = A.shape[0]
    C = np.full((n, n), np.inf)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = A[i, k] + B[k, j]
                if val < C[i, j]:
                    C[i, j] = val
    return C


def tropical_matrix_power(M: np.ndarray, k: int) -> np.ndarray:
    """Compute M^⊗k via repeated squaring.
    
    Time: O(n³ log k), Space: O(n²)
    
    Args:
        M: n×n matrix
        k: exponent (non-negative)
    Returns:
        M^⊗k (tropical identity for k=0)
    """
    n = M.shape[0]
    if k == 0:
        result = np.full((n, n), np.inf)
        np.fill_diagonal(result, 0)
        return result
    
    result = M.copy()
    k -= 1
    base = M.copy()
    while k > 0:
        if k % 2 == 1:
            result = tropical_matrix_multiply(result, base)
        base = tropical_matrix_multiply(base, base)
        k //= 2
    return result


def tropical_gram(M: np.ndarray) -> np.ndarray:
    """Tropical Gram matrix: G[a,b] = min_k(M[a,k] + M[b,k]).
    
    This is the kernel profile of the network with evaluation matrix M.
    
    Time: O(n³), Space: O(n²)
    """
    n = M.shape[0]
    G = np.full((n, n), np.inf)
    for a in range(n):
        for b in range(n):
            for k in range(n):
                val = M[a, k] + M[b, k]
                if val < G[a, b]:
                    G[a, b] = val
    return G


def compose_kernels(kappa1: np.ndarray, kappa2: np.ndarray) -> np.ndarray:
    """Tropical kernel composition: (κ₁ ⊗ κ₂)(a,c) = min_b(κ₁(a,b) + κ₂(b,c)).
    
    Time: O(n³), Space: O(n²)
    """
    return tropical_matrix_multiply(kappa1, kappa2)


def verify_idempotent(kappa: np.ndarray, tol: float = 1e-10) -> Tuple[bool, float]:
    """Check κ ⊗ κ = κ with error measurement.
    
    Returns (is_idempotent, max_error)
    """
    composed = compose_kernels(kappa, kappa)
    max_err = np.max(np.abs(composed - kappa))
    return max_err < tol, max_err


def verify_metric(kappa: np.ndarray, tol: float = 1e-10) -> Tuple[bool, bool, bool]:
    """Check if κ is a tropical (pseudo)metric.
    
    Returns (zero_diagonal, symmetric, triangle_inequality)
    """
    n = kappa.shape[0]
    zero_diag = np.allclose(np.diag(kappa), 0, atol=tol)
    symmetric = np.allclose(kappa, kappa.T, atol=tol)
    triangle = True
    for a in range(n):
        for b in range(n):
            for c in range(n):
                if kappa[a, c] > kappa[a, b] + kappa[b, c] + tol:
                    triangle = False
                    break
            if not triangle:
                break
        if not triangle:
            break
    return zero_diag, symmetric, triangle


def find_generators(kappa: np.ndarray, tol: float = 1e-10) -> List[int]:
    """Find generator set: indices k where κ(a,b) = κ(a,k) + κ(k,b) for some (a,b).
    
    Time: O(n³), Space: O(n)
    """
    n = kappa.shape[0]
    generators = []
    for k in range(n):
        for a in range(n):
            found = False
            for b in range(n):
                if abs(kappa[a, b] - (kappa[a, k] + kappa[k, b])) < tol:
                    generators.append(k)
                    found = True
                    break
            if found:
                break
    return generators


def minimize_generators(kappa: np.ndarray, generators: List[int],
                       tol: float = 1e-10) -> List[int]:
    """Remove redundant generators.
    
    A generator g is redundant if removing it doesn't change the spanning:
    κ(a,b) = min_{g' ∈ G\\{g}} (κ(a,g') + κ(g',b)) for all a,b.
    
    Time: O(|G|² × n²), Space: O(n²)
    """
    minimal = list(generators)
    for g in generators:
        remaining = [x for x in minimal if x != g]
        if not remaining:
            continue
        # Check if g is redundant
        n = kappa.shape[0]
        redundant = True
        for a in range(n):
            for b in range(n):
                best = min(kappa[a, r] + kappa[r, b] for r in remaining)
                if best > kappa[a, b] + tol:
                    redundant = False
                    break
            if not redundant:
                break
        if redundant:
            minimal.remove(g)
    return minimal


def reconstruct_network(kappa: np.ndarray) -> np.ndarray:
    """Reconstruct a network matrix from a kernel profile.
    
    For a tropical metric κ, the reconstruction uses κ itself as the
    network matrix. The tropical Gram of this reconstruction equals κ
    by the idempotent kernel theorem.
    
    Time: O(1) (just copies), Space: O(n²)
    """
    return kappa.copy()


def random_tropical_metric(n: int, max_weight: float = 10.0,
                           seed: Optional[int] = None) -> np.ndarray:
    """Generate random tropical metric via Floyd-Warshall.
    
    Time: O(n³), Space: O(n²)
    """
    rng = np.random.default_rng(seed)
    W = rng.uniform(0, max_weight, (n, n))
    W = (W + W.T) / 2
    np.fill_diagonal(W, 0)
    D = W.copy()
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if D[i, k] + D[k, j] < D[i, j]:
                    D[i, j] = D[i, k] + D[k, j]
    return D


# ---- Example usage ----

if __name__ == "__main__":
    print("=== Tropical One-Way Kernel Algorithms ===\n")
    
    # Example: tropical matrix power
    M = np.array([[0, 3], [2, 0]], dtype=float)
    print(f"M = \n{M}\n")
    
    for k in [1, 2, 3, 4]:
        Mk = tropical_matrix_power(M, k)
        print(f"M^⊗{k} = \n{Mk}\n")
    
    # Example: kernel profile
    kappa = random_tropical_metric(5, seed=42)
    print(f"Random tropical metric (5×5):\n{np.round(kappa, 2)}\n")
    
    is_idem, err = verify_idempotent(kappa)
    print(f"Idempotent: {is_idem} (error: {err:.2e})")
    
    zd, sym, tri = verify_metric(kappa)
    print(f"Zero diagonal: {zd}, Symmetric: {sym}, Triangle: {tri}")
    
    gens = find_generators(kappa)
    print(f"Generators: {gens} (rank: {len(gens)})")
    
    minimal = minimize_generators(kappa, gens)
    print(f"Minimal generators: {minimal} (rank: {len(minimal)})")
