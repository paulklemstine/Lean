#!/usr/bin/env python3
"""
algorithms.py — Certified algorithms for prime-sensitive torsion echo computation.

This module implements:
1. Smith Normal Form computation for integer matrices
2. Torsion echo extraction from Smith invariants
3. Prime separation detection
4. Flag complex construction from graphs
5. Full pipeline from graph to torsion profile

All algorithms include docstrings, type hints, and complexity analysis.
"""

from __future__ import annotations
import numpy as np
from math import gcd
from itertools import combinations
from collections import defaultdict
from typing import Optional


# ──────────────────────────────────────────────────────────────────
# Algorithm 1: p-adic Valuation
# ──────────────────────────────────────────────────────────────────

def padic_valuation(p: int, n: int) -> int:
    """
    Compute v_p(n), the p-adic valuation of integer n.

    The p-adic valuation counts the exact power of prime p dividing n.

    Args:
        p: A prime number (≥ 2)
        n: A nonzero integer

    Returns:
        The largest k such that p^k divides n, or 0 if n = 0 or p < 2.

    Time complexity: O(log_p(n))
    Space complexity: O(1)

    Examples:
        >>> padic_valuation(2, 12)
        2
        >>> padic_valuation(3, 12)
        1
        >>> padic_valuation(5, 12)
        0
    """
    if n == 0 or p < 2:
        return 0
    n = abs(n)
    v = 0
    while n % p == 0:
        n //= p
        v += 1
    return v


# ──────────────────────────────────────────────────────────────────
# Algorithm 2: Smith Normal Form
# ──────────────────────────────────────────────────────────────────

def smith_normal_form(M: np.ndarray) -> tuple[list[int], np.ndarray]:
    """
    Compute the Smith Normal Form of an integer matrix.

    The Smith Normal Form of an m×n integer matrix M is a diagonal matrix D
    such that D = U·M·V for unimodular matrices U, V, and the diagonal entries
    d_1 | d_2 | ... | d_r satisfy the divisibility chain.

    Args:
        M: An integer matrix (numpy array with dtype int)

    Returns:
        Tuple of (diagonal_entries, transformed_matrix) where diagonal_entries
        is the list of Smith invariant factors.

    Time complexity: O(min(m,n)·m·n·log(max|M_ij|)) expected
    Space complexity: O(m·n)

    Pseudocode:
        1. For k = 0, 1, ..., min(m,n)-1:
           a. Find the nonzero element with smallest absolute value in M[k:,k:]
           b. Swap it to position (k,k)
           c. Repeat until stable:
              - Eliminate column k below row k using integer division
              - Eliminate row k right of column k
              - Check divisibility of M[k,k] into all remaining entries
           d. Record |M[k,k]| as the k-th invariant factor
        2. Return the list of invariant factors
    """
    if M.size == 0:
        return [], M.copy()

    M = M.copy().astype(np.int64)
    rows, cols = M.shape
    n = min(rows, cols)
    diag = []

    for k in range(n):
        subM = M[k:, k:]
        if np.all(subM == 0):
            break

        nonzero = np.argwhere(subM != 0)
        abs_vals = np.abs(subM[nonzero[:, 0], nonzero[:, 1]])
        idx = nonzero[np.argmin(abs_vals)]
        pi, pj = idx[0] + k, idx[1] + k

        M[[k, pi]] = M[[pi, k]]
        M[:, [k, pj]] = M[:, [pj, k]]

        changed = True
        iterations = 0
        max_iter = 10000
        while changed and iterations < max_iter:
            changed = False
            iterations += 1

            for i in range(k + 1, rows):
                if M[i, k] != 0:
                    q = int(M[i, k]) // int(M[k, k])
                    M[i] -= q * M[k]
                    if M[i, k] != 0:
                        if abs(M[i, k]) < abs(M[k, k]):
                            M[[k, i]] = M[[i, k]]
                        changed = True

            for j in range(k + 1, cols):
                if M[k, j] != 0:
                    q = int(M[k, j]) // int(M[k, k])
                    M[:, j] -= q * M[:, k]
                    if M[k, j] != 0:
                        if abs(M[k, j]) < abs(M[k, k]):
                            M[:, [k, j]] = M[:, [j, k]]
                        changed = True

            for i in range(k + 1, rows):
                for j in range(k + 1, cols):
                    if int(M[i, j]) % int(M[k, k]) != 0:
                        M[i] += M[k]
                        changed = True
                        break
                if changed:
                    break

        diag.append(abs(int(M[k, k])))

    return diag, M


# ──────────────────────────────────────────────────────────────────
# Algorithm 3: Torsion Echo Computation
# ──────────────────────────────────────────────────────────────────

def torsion_echo(p: int, invariant_factors: list[int]) -> int:
    """
    Compute the torsion echo at prime p from Smith invariant factors.

    The torsion echo is defined as:
        echo_p(d) = Σ_i v_p(d_i)

    where v_p is the p-adic valuation and d_i are the invariant factors.

    Args:
        p: A prime number
        invariant_factors: List of Smith invariant factors (positive integers)

    Returns:
        The sum of p-adic valuations of all invariant factors.

    Time complexity: O(n · log_p(max(d_i)))
    Space complexity: O(1)

    Examples:
        >>> torsion_echo(2, [4, 6, 1])  # v_2(4) + v_2(6) + v_2(1) = 2+1+0
        3
        >>> torsion_echo(3, [4, 6, 1])  # v_3(4) + v_3(6) + v_3(1) = 0+1+0
        1
    """
    return sum(padic_valuation(p, d) for d in invariant_factors)


def torsion_echo_matrix(p: int, M: np.ndarray) -> int:
    """
    Compute the torsion echo of a matrix by first finding its Smith form.

    This is the certified pipeline: matrix → Smith invariants → torsion echo.

    Args:
        p: A prime number
        M: An integer matrix

    Returns:
        The torsion echo at prime p of the Smith form of M.

    Time complexity: O(SNF computation + n · log_p(max invariant))
    """
    diag, _ = smith_normal_form(M)
    return torsion_echo(p, diag)


# ──────────────────────────────────────────────────────────────────
# Algorithm 4: Prime Separation Detection
# ──────────────────────────────────────────────────────────────────

def is_prime_separated(invariant_factors: list[int],
                       primes: list[int] | None = None) -> tuple[bool, dict[int, int]]:
    """
    Detect whether the Smith data exhibits prime separation.

    Args:
        invariant_factors: Smith invariant factors
        primes: List of primes to test (default: [2, 3, 5, 7, 11, 13])

    Returns:
        Tuple of (is_separated, echo_dict) where echo_dict maps each prime
        to its torsion echo value.

    Examples:
        >>> is_prime_separated([8, 27])
        (True, {2: 3, 3: 3, 5: 0, 7: 0, 11: 0, 13: 0})
    """
    if primes is None:
        primes = [2, 3, 5, 7, 11, 13]

    echoes = {p: torsion_echo(p, invariant_factors) for p in primes}
    values = set(echoes.values())
    return len(values) > 1, echoes


# ──────────────────────────────────────────────────────────────────
# Algorithm 5: Flag Complex Construction
# ──────────────────────────────────────────────────────────────────

def build_flag_complex(n: int, edges: set[tuple[int, int]],
                       max_dim: int = 3) -> dict[int, list[tuple]]:
    """
    Build the flag (clique) complex of a graph.

    The flag complex X(G) is the simplicial complex whose k-simplices are
    the (k+1)-cliques of G. This is the natural complex for studying
    random topology via Erdős–Rényi models.

    Args:
        n: Number of vertices
        edges: Set of edges as pairs (i, j) with i < j
        max_dim: Maximum dimension of simplices to find

    Returns:
        Dictionary mapping dimension k to list of k-simplices (sorted tuples).

    Time complexity: O(n^{max_dim+1}) worst case, typically much better for sparse graphs
    Space complexity: O(total number of simplices)

    Pseudocode:
        1. Build adjacency lists from edges
        2. 0-simplices = all vertices
        3. For k = 1, ..., max_dim:
           For each (k-1)-simplex σ:
             For each vertex v > max(σ) adjacent to all vertices of σ:
               Add σ ∪ {v} as a k-simplex
    """
    adj = defaultdict(set)
    for i, j in edges:
        adj[i].add(j)
        adj[j].add(i)

    simplices = {0: [(v,) for v in range(n)]}

    for k in range(1, max_dim + 1):
        new_simplices = []
        for simplex in simplices.get(k - 1, []):
            last = simplex[-1]
            candidates = set(range(last + 1, n))
            for v in simplex:
                candidates &= adj[v]
            for v in sorted(candidates):
                new_simplices.append(simplex + (v,))
        simplices[k] = new_simplices
        if not new_simplices:
            break

    return simplices


def build_boundary_matrix(simplices_k: list[tuple],
                          simplices_km1: list[tuple]) -> np.ndarray:
    """
    Build the boundary matrix ∂_k : C_k → C_{k-1}.

    The boundary of a k-simplex [v_0, ..., v_k] is
        ∂[v_0, ..., v_k] = Σ_i (-1)^i [v_0, ..., v̂_i, ..., v_k]

    Args:
        simplices_k: List of k-simplices (sorted tuples)
        simplices_km1: List of (k-1)-simplices (sorted tuples)

    Returns:
        Integer matrix of shape (len(simplices_km1), len(simplices_k))
    """
    if not simplices_k or not simplices_km1:
        return np.zeros((len(simplices_km1), len(simplices_k)), dtype=np.int64)

    idx_map = {s: i for i, s in enumerate(simplices_km1)}
    m, n = len(simplices_km1), len(simplices_k)
    B = np.zeros((m, n), dtype=np.int64)

    for j, sigma in enumerate(simplices_k):
        for face_idx in range(len(sigma)):
            face = sigma[:face_idx] + sigma[face_idx + 1:]
            sign = (-1) ** face_idx
            if face in idx_map:
                B[idx_map[face], j] = sign

    return B


# ──────────────────────────────────────────────────────────────────
# Algorithm 6: Full Pipeline
# ──────────────────────────────────────────────────────────────────

def torsion_profile_from_graph(
    n: int,
    edges: set[tuple[int, int]],
    max_dim: int = 3,
    primes: list[int] | None = None
) -> dict[int, dict[int, int]]:
    """
    Complete pipeline: graph → flag complex → boundary matrices → torsion echoes.

    Args:
        n: Number of vertices
        edges: Edge set
        max_dim: Maximum simplicial dimension
        primes: Primes to compute echoes for

    Returns:
        Nested dict: dimension k → prime p → echo_p(∂_k)

    Example:
        >>> import numpy as np
        >>> rng = np.random.default_rng(42)
        >>> edges = {(i,j) for i in range(8) for j in range(i+1,8) if rng.random()<0.4}
        >>> profile = torsion_profile_from_graph(8, edges)
    """
    if primes is None:
        primes = [2, 3, 5, 7]

    simplices = build_flag_complex(n, edges, max_dim)
    result = {}

    for k in range(1, max_dim + 1):
        if k not in simplices or k - 1 not in simplices:
            continue
        if not simplices[k]:
            continue

        B = build_boundary_matrix(simplices[k], simplices[k - 1])
        diag, _ = smith_normal_form(B)
        nontrivial = [d for d in diag if d > 1]

        echoes = {}
        for p in primes:
            echoes[p] = torsion_echo(p, nontrivial)
        result[k] = echoes

    return result


# ──────────────────────────────────────────────────────────────────
# Algorithm 7: Statistical Comparison
# ──────────────────────────────────────────────────────────────────

def kolmogorov_smirnov_distance(sample1: list[float],
                                 sample2: list[float]) -> float:
    """
    Compute the Kolmogorov–Smirnov distance between two empirical distributions.

    The KS distance is the supremum of the absolute difference between
    the empirical CDFs of the two samples.

    Args:
        sample1, sample2: Lists of numerical observations

    Returns:
        The KS distance (float in [0, 1])

    Time complexity: O((m+n) log(m+n)) where m, n are sample sizes
    """
    all_vals = sorted(set(sample1 + sample2))
    n1, n2 = len(sample1), len(sample2)
    if n1 == 0 or n2 == 0:
        return 0.0

    s1 = sorted(sample1)
    s2 = sorted(sample2)

    max_diff = 0.0
    i1, i2 = 0, 0
    for val in all_vals:
        while i1 < n1 and s1[i1] <= val:
            i1 += 1
        while i2 < n2 and s2[i2] <= val:
            i2 += 1
        diff = abs(i1 / n1 - i2 / n2)
        max_diff = max(max_diff, diff)

    return max_diff


# ──────────────────────────────────────────────────────────────────
# Example usage
# ──────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Algorithm Demonstrations ===\n")

    # Demo 1: p-adic valuations
    print("1. p-adic valuations of 360 = 2³ × 3² × 5:")
    for p in [2, 3, 5, 7]:
        print(f"   v_{p}(360) = {padic_valuation(p, 360)}")

    # Demo 2: Smith normal form
    print("\n2. Smith Normal Form:")
    M = np.array([[2, 4, 4], [-6, 6, 12], [10, -4, -16]], dtype=np.int64)
    diag, _ = smith_normal_form(M)
    print(f"   Matrix:\n{M}")
    print(f"   Smith invariants: {diag}")

    # Demo 3: Torsion echo
    print("\n3. Torsion echoes of Smith data [2, 6, 12]:")
    test_data = [2, 6, 12]
    for p in [2, 3, 5]:
        print(f"   echo_{p} = {torsion_echo(p, test_data)}")

    # Demo 4: Prime separation
    print("\n4. Prime separation detection:")
    sep, echoes = is_prime_separated([8, 27, 5])
    print(f"   Data: [8, 27, 5]")
    print(f"   Echoes: {echoes}")
    print(f"   Separated: {sep}")

    # Demo 5: Full pipeline
    print("\n5. Full pipeline on random graph G(10, 0.35):")
    rng = np.random.default_rng(42)
    n = 10
    edges = {(i, j) for i in range(n) for j in range(i + 1, n)
             if rng.random() < 0.35}
    profile = torsion_profile_from_graph(n, edges)
    for k, echoes in profile.items():
        print(f"   Dimension {k}: {echoes}")
