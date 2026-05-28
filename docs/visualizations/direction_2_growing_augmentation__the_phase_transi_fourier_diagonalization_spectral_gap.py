#!/usr/bin/env python3
"""
Algorithms for Spectral Analysis of Cayley Walks on (Z/nZ)^2

Implements exact Fourier diagonalization for computing spectral gaps
of augmented Cayley walks on the discrete torus.

Time complexity: O(n^2 * |S|) per spectral gap computation
Space complexity: O(|S|)
"""
import numpy as np
from typing import List, Tuple, Dict

def inner_product_zn2(k: Tuple[int, int], s: Tuple[int, int], n: int) -> int:
    """Compute ⟨k, s⟩ = k1*s1 + k2*s2 mod n."""
    return (k[0] * s[0] + k[1] * s[1]) % n

def laplace_eigenvalue(n: int, S: List[Tuple[int, int]], 
                       k: Tuple[int, int]) -> float:
    """Compute λ_S(k) = Σ_{s∈S} (1 - cos(2π⟨k,s⟩/n)).
    
    Args:
        n: Group order (Z/nZ)^2
        S: Generating set as list of (a,b) pairs
        k: Character index (k1,k2)
    
    Returns:
        Laplacian eigenvalue at character k
        
    Complexity: O(|S|)
    """
    total = 0.0
    for s in S:
        ip = inner_product_zn2(k, s, n)
        total += 1 - np.cos(2 * np.pi * ip / n)
    return total

def compute_spectral_gap(n: int, S: List[Tuple[int, int]]) -> float:
    """Compute the spectral gap via Fourier diagonalization.
    
    gap(S) = min_{k ≠ (0,0)} λ_S(k)
    
    Args:
        n: Group order
        S: Generating set
    
    Returns:
        Spectral gap (minimum nontrivial eigenvalue)
        
    Complexity: O(n^2 * |S|) — iterates over all n^2-1 nontrivial characters
    """
    min_eig = float('inf')
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            eig = laplace_eigenvalue(n, S, (k1, k2))
            min_eig = min(min_eig, eig)
    return min_eig

def compute_all_eigenvalues(n: int, S: List[Tuple[int, int]]) -> np.ndarray:
    """Compute all n^2 Laplacian eigenvalues (including trivial).
    
    Returns: n×n array where entry [k1,k2] = λ_S(k1,k2)
    """
    eigs = np.zeros((n, n))
    for k1 in range(n):
        for k2 in range(n):
            eigs[k1, k2] = laplace_eigenvalue(n, S, (k1, k2))
    return eigs

def compute_fourier_bias(n: int, A: List[Tuple[int, int]]) -> float:
    """Compute the Fourier bias: max_{k≠0} |Σ_{a∈A} cos(2π⟨k,a⟩/n)|.
    
    Low bias means A is pseudorandom in the Fourier-analytic sense.
    
    Complexity: O(n^2 * |A|)
    """
    max_bias = 0.0
    for k1 in range(n):
        for k2 in range(n):
            if k1 == 0 and k2 == 0:
                continue
            cos_sum = sum(np.cos(2 * np.pi * inner_product_zn2((k1,k2), a, n) / n) 
                         for a in A)
            max_bias = max(max_bias, abs(cos_sum))
    return max_bias

def spectral_gap_ratio(n: int, S_local: List[Tuple[int, int]], 
                       S_aug: List[Tuple[int, int]]) -> float:
    """Compute gap(S_aug) / gap(S_local)."""
    gap_local = compute_spectral_gap(n, S_local)
    gap_aug = compute_spectral_gap(n, S_aug)
    return gap_aug / gap_local if gap_local > 0 else float('inf')

def local_generators(n: int) -> List[Tuple[int, int]]:
    """Standard local generators: {(1,0), (-1,0), (0,1), (0,-1)}."""
    return [(1, 0), (n-1, 0), (0, 1), (0, n-1)]

def axis_augmentation(n: int) -> List[Tuple[int, int]]:
    """Axis-aligned augmentation: {(j,0) : j} ∪ {(0,j) : j}.
    
    This is the canonical supercritical augmentation family.
    Size: 2n-1 (linear in n).
    """
    S = set()
    for j in range(n):
        S.add((j, 0))
        S.add((0, j))
    return list(S)

def random_symmetric_augmentation(n: int, k: int, 
                                   rng=None) -> List[Tuple[int, int]]:
    """Generate a random symmetric augmentation of ~2k elements."""
    if rng is None:
        rng = np.random.default_rng()
    S = set()
    attempts = 0
    while len(S) < 2 * k and attempts < 10 * k:
        a1 = rng.integers(0, n)
        a2 = rng.integers(0, n)
        if (a1, a2) == (0, 0):
            attempts += 1
            continue
        S.add((a1, a2))
        S.add(((-a1) % n, (-a2) % n))
        attempts += 1
    return list(S)

def is_subcritical(k: int, C: int, n: int) -> bool:
    """Check subcritical condition: k^3 ≤ C * n^2."""
    return k**3 <= C * n**2

def is_supercritical(k: int, C: int, n: int) -> bool:
    """Check supercritical condition: C * n^2 ≤ k^3."""
    return C * n**2 <= k**3

# Example usage
if __name__ == '__main__':
    print("Spectral Gap Computation Examples")
    print("=" * 50)
    
    for n in [8, 12, 16]:
        S = local_generators(n)
        gap = compute_spectral_gap(n, S)
        theoretical = 4 * np.sin(np.pi / n)**2
        
        print(f"\nn = {n}")
        print(f"  Local gap: {gap:.8f}")
        print(f"  4sin²(π/n): {theoretical:.8f}")
        print(f"  Match: {abs(gap - theoretical) < 1e-10}")
        
        # Augmented gap
        A = axis_augmentation(n)
        S_aug = list(set(S + A))
        gap_aug = compute_spectral_gap(n, S_aug)
        print(f"  Augmented gap (axis): {gap_aug:.6f}")
        print(f"  Ratio: {gap_aug/gap:.4f}")
        
        # Fourier bias of random augmentation
        rng = np.random.default_rng(42)
        A_rand = random_symmetric_augmentation(n, n//2, rng)
        bias = compute_fourier_bias(n, A_rand)
        print(f"  Random aug bias (|A|={len(A_rand)}): {bias:.4f}")
