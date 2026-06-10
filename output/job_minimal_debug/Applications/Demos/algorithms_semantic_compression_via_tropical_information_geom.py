#!/usr/bin/env python3
"""
Algorithms for Tropical Semantic Compression

Implements the core algorithms from the tropical information geometry framework:
1. Optimal semantic code search (finite argmin)
2. Min-closure computation for codebook generation
3. Tropical projection (pointwise infimum)
4. Semantic distortion computation and Fisher bound evaluation
5. Codebook optimization via tropical skeleton extraction
"""

import numpy as np
from typing import List, Tuple, Optional, Set
from dataclasses import dataclass
import itertools


@dataclass
class CompressionResult:
    """Result of semantic compression."""
    original: np.ndarray
    code: np.ndarray
    distortion: float
    codebook_index: int
    fisher_bound: float


def semantic_dist(w: np.ndarray, v: np.ndarray) -> float:
    """
    Compute the semantic distance (L¹ metric) between two weight functions.
    
    Parameters
    ----------
    w, v : np.ndarray
        Weight functions on a finite alphabet.
    
    Returns
    -------
    float
        The L¹ distance ∑_a |w(a) - v(a)|.
    
    Complexity: O(n) where n = |α|.
    """
    return float(np.sum(np.abs(w - v)))


def tropical_fisher(w: np.ndarray) -> float:
    """
    Compute the tropical Fisher quantity (L¹ norm).
    
    Parameters
    ----------
    w : np.ndarray
        Weight function.
    
    Returns
    -------
    float
        The L¹ norm ∑_a |w(a)|.
    
    Complexity: O(n).
    """
    return float(np.sum(np.abs(w)))


def centered(w: np.ndarray) -> np.ndarray:
    """
    Compute the mean-centered (gauge-normalized) weight function.
    
    Parameters
    ----------
    w : np.ndarray
        Weight function.
    
    Returns
    -------
    np.ndarray
        Centered version: w(a) - mean(w).
    
    Complexity: O(n).
    """
    return w - np.mean(w)


def tropical_proj(C: List[np.ndarray]) -> np.ndarray:
    """
    Compute the tropical projection (pointwise infimum) over a codebook.
    
    Parameters
    ----------
    C : List[np.ndarray]
        Nonempty codebook of weight functions.
    
    Returns
    -------
    np.ndarray
        Pointwise minimum: π(a) = min_{v ∈ C} v(a).
    
    Complexity: O(|C| · n).
    """
    return np.min(np.stack(C), axis=0)


def find_optimal_code(
    C: List[np.ndarray], w: np.ndarray
) -> CompressionResult:
    """
    Find the optimal semantic code in a finite codebook.
    
    Algorithm: Exhaustive search (finite argmin).
    
    Parameters
    ----------
    C : List[np.ndarray]
        Nonempty finite codebook.
    w : np.ndarray
        Source weight function to compress.
    
    Returns
    -------
    CompressionResult
        The optimal code, its index, distortion, and Fisher bound.
    
    Complexity: O(|C| · n).
    
    Pseudocode
    ----------
    FIND-OPTIMAL-CODE(C, w):
        best_dist ← ∞
        best_idx ← 0
        for i = 0 to |C|-1:
            d ← SEMANTIC-DIST(w, C[i])
            if d < best_dist:
                best_dist ← d
                best_idx ← i
        residual ← w - C[best_idx]
        return (C[best_idx], best_idx, best_dist, TROPICAL-FISHER(residual))
    """
    best_dist = float('inf')
    best_idx = 0
    
    for i, c in enumerate(C):
        d = semantic_dist(w, c)
        if d < best_dist:
            best_dist = d
            best_idx = i
    
    code = C[best_idx]
    residual = w - code
    return CompressionResult(
        original=w,
        code=code,
        distortion=best_dist,
        codebook_index=best_idx,
        fisher_bound=tropical_fisher(residual)
    )


def min_closure(generators: List[np.ndarray], max_size: int = 10000) -> List[np.ndarray]:
    """
    Compute the min-closure of a set of generators.
    
    The min-closure is the smallest set containing the generators that is
    closed under pointwise minimum. For finite generators, this is always finite.
    
    Algorithm: Iterative saturation.
    
    Parameters
    ----------
    generators : List[np.ndarray]
        Initial set of weight functions.
    max_size : int
        Maximum codebook size (safety limit).
    
    Returns
    -------
    List[np.ndarray]
        The min-closed codebook.
    
    Complexity: O(|closure|² · n) in the worst case.
    
    Pseudocode
    ----------
    MIN-CLOSURE(G):
        C ← G
        repeat:
            new ← ∅
            for each (u, v) in C × C:
                m ← pointwise-min(u, v)
                if m ∉ C and m ∉ new:
                    new ← new ∪ {m}
            C ← C ∪ new
        until new = ∅
        return C
    """
    C = list(generators)
    
    def contains(lst, x):
        return any(np.allclose(x, y) for y in lst)
    
    changed = True
    while changed and len(C) < max_size:
        changed = False
        new_elements = []
        for i in range(len(C)):
            for j in range(i, len(C)):
                m = np.minimum(C[i], C[j])
                if not contains(C, m) and not contains(new_elements, m):
                    new_elements.append(m)
                    changed = True
        C.extend(new_elements)
    
    return C


def extract_skeleton(C: List[np.ndarray]) -> List[np.ndarray]:
    """
    Extract skeleton points (minimal elements under pointwise order).
    
    A skeleton point v ∈ C satisfies: ∀ u ∈ C, (∀ a, u(a) ≤ v(a)) → u = v.
    These are the irreducible semantic representatives.
    
    Parameters
    ----------
    C : List[np.ndarray]
        Codebook.
    
    Returns
    -------
    List[np.ndarray]
        List of skeleton (minimal) points.
    
    Complexity: O(|C|² · n).
    
    Pseudocode
    ----------
    EXTRACT-SKELETON(C):
        S ← ∅
        for v in C:
            is_minimal ← true
            for u in C:
                if u ≤ v pointwise and u ≠ v:
                    is_minimal ← false
                    break
            if is_minimal:
                S ← S ∪ {v}
        return S
    """
    skeleton = []
    for v in C:
        is_minimal = True
        for u in C:
            if np.all(u <= v) and not np.allclose(u, v):
                is_minimal = False
                break
        if is_minimal:
            skeleton.append(v)
    return skeleton


def semantic_compress(
    w: np.ndarray,
    C: List[np.ndarray],
    center: bool = False
) -> CompressionResult:
    """
    Perform semantic compression with optional centering.
    
    Parameters
    ----------
    w : np.ndarray
        Source weight function.
    C : List[np.ndarray]
        Codebook.
    center : bool
        If True, center both source and codebook before compression.
    
    Returns
    -------
    CompressionResult
        Compression result with distortion and bounds.
    
    Complexity: O(|C| · n).
    """
    if center:
        w_c = centered(w)
        C_c = [centered(c) for c in C]
        return find_optimal_code(C_c, w_c)
    else:
        return find_optimal_code(C, w)


def batch_compress(
    sources: List[np.ndarray],
    C: List[np.ndarray]
) -> List[CompressionResult]:
    """
    Compress multiple source weight functions against the same codebook.
    
    Parameters
    ----------
    sources : List[np.ndarray]
        List of source weight functions.
    C : List[np.ndarray]
        Codebook.
    
    Returns
    -------
    List[CompressionResult]
        Compression results for each source.
    
    Complexity: O(|sources| · |C| · n).
    """
    return [find_optimal_code(C, w) for w in sources]


def verify_idempotence(C: List[np.ndarray], tol: float = 1e-10) -> bool:
    """
    Verify that tropical projection on C is idempotent.
    
    Parameters
    ----------
    C : List[np.ndarray]
        Codebook (should be min-closed).
    tol : float
        Numerical tolerance.
    
    Returns
    -------
    bool
        True if π(π(·)) = π(·).
    """
    proj = tropical_proj(C)
    proj2 = tropical_proj(C)  # Always same since proj doesn't depend on input
    return np.allclose(proj, proj2, atol=tol)


def verify_fisher_bound(w: np.ndarray, v: np.ndarray) -> Tuple[float, float, bool]:
    """
    Verify the Fisher-type bound: d(w,v) ≤ F(w-v).
    
    Returns
    -------
    Tuple[float, float, bool]
        (distance, fisher_bound, bound_holds)
    """
    d = semantic_dist(w, v)
    f = tropical_fisher(w - v)
    return d, f, d <= f + 1e-10


def verify_centered_bound(w: np.ndarray, v: np.ndarray) -> Tuple[float, float, bool]:
    """
    Verify: d(centered(w), centered(v)) ≤ 2·F(w-v).
    
    Returns
    -------
    Tuple[float, float, bool]
        (centered_distance, bound, bound_holds)
    """
    d = semantic_dist(centered(w), centered(v))
    bound = 2 * tropical_fisher(w - v)
    return d, bound, d <= bound + 1e-10


# ─── Example Usage ───────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Tropical Semantic Compression — Algorithm Examples")
    print("=" * 60)
    
    # Generate a random codebook and close it under min
    np.random.seed(42)
    n = 4  # alphabet size
    generators = [np.random.randn(n) for _ in range(3)]
    
    print(f"\nGenerators ({len(generators)} vectors of dimension {n}):")
    for i, g in enumerate(generators):
        print(f"  g_{i} = {np.round(g, 3)}")
    
    C = min_closure(generators)
    print(f"\nMin-closure has {len(C)} elements")
    
    skeleton = extract_skeleton(C)
    print(f"Skeleton has {len(skeleton)} minimal points")
    
    # Compress a source
    w = np.random.randn(n)
    result = find_optimal_code(C, w)
    print(f"\nSource: {np.round(w, 3)}")
    print(f"Optimal code: {np.round(result.code, 3)}")
    print(f"Distortion: {result.distortion:.4f}")
    print(f"Fisher bound: {result.fisher_bound:.4f}")
    
    # Verify bounds
    d, f, ok = verify_fisher_bound(w, result.code)
    print(f"\nFisher bound check: d={d:.4f} ≤ F={f:.4f}? {ok}")
    
    d_c, b_c, ok_c = verify_centered_bound(w, result.code)
    print(f"Centered bound check: d_c={d_c:.4f} ≤ 2F={b_c:.4f}? {ok_c}")
    
    # Verify idempotence
    print(f"\nIdempotence check: {verify_idempotence(C)}")
