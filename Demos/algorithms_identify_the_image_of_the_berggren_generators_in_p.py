#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Berggren-PGL₂ dynamics.

Implements the key computational tools for studying the Berggren generators
as Möbius transformations on P¹(F_p).
"""

import numpy as np
from collections import deque
from typing import Tuple, List, Set, Dict, Optional

# ============================================================
# Algorithm 1: Projective Point Arithmetic
# ============================================================

def mod_inv(a: int, p: int) -> int:
    """Modular inverse of a mod p using Fermat's little theorem.
    
    Time: O(log p), Space: O(1)
    """
    return pow(a % p, p - 2, p)

def normalize_point(m: int, n: int, p: int) -> Optional[Tuple[int, int]]:
    """Normalize a projective point [m:n] to canonical form in P¹(F_p).
    
    Canonical form: (1, n') for affine points, (0, 1) for infinity.
    Returns None for the zero vector.
    
    Time: O(log p), Space: O(1)
    """
    m, n = m % p, n % p
    if m == 0 and n == 0:
        return None
    if m != 0:
        inv = mod_inv(m, p)
        return (1, (n * inv) % p)
    return (0, 1)

# ============================================================
# Algorithm 2: Berggren 2×2 Matrix Action
# ============================================================

# Berggren generators in PGL₂ (Euclid parametrization)
BERGGREN_A2 = ((2, -1), (1, 0))    # det = 1
BERGGREN_B2 = ((2, 1), (1, 0))     # det = -1
BERGGREN_C2 = ((1, 2), (0, 1))     # det = 1

def mat_mul_2x2(M1, M2, p: int):
    """Multiply two 2×2 matrices mod p.
    
    Time: O(log p) for modular arithmetic, Space: O(1)
    """
    return (
        ((M1[0][0]*M2[0][0] + M1[0][1]*M2[1][0]) % p,
         (M1[0][0]*M2[0][1] + M1[0][1]*M2[1][1]) % p),
        ((M1[1][0]*M2[0][0] + M1[1][1]*M2[1][0]) % p,
         (M1[1][0]*M2[0][1] + M1[1][1]*M2[1][1]) % p)
    )

def normalize_matrix(M, p: int) -> Optional[tuple]:
    """Normalize a 2×2 matrix in PGL₂(F_p).
    
    Divides by the first nonzero entry so the representation is canonical.
    Time: O(log p), Space: O(1)
    """
    for i in range(2):
        for j in range(2):
            if M[i][j] % p != 0:
                inv = mod_inv(M[i][j], p)
                return tuple(tuple((M[r][c] * inv) % p for c in range(2)) for r in range(2))
    return None

def apply_berggren(gen_idx: int, point: Tuple[int, int], p: int) -> Optional[Tuple[int, int]]:
    """Apply Berggren generator (0=A, 1=B, 2=C) to a projective point.
    
    Time: O(log p), Space: O(1)
    """
    gens = [BERGGREN_A2, BERGGREN_B2, BERGGREN_C2]
    M = gens[gen_idx]
    m, n = point
    new_m = (M[0][0] * m + M[0][1] * n) % p
    new_n = (M[1][0] * m + M[1][1] * n) % p
    return normalize_point(new_m, new_n, p)

# ============================================================
# Algorithm 3: Orbit Computation via BFS
# ============================================================

def compute_orbit(start: Tuple[int, int], p: int) -> Set[Tuple[int, int]]:
    """Compute the full Berggren orbit of a point in P¹(F_p) via BFS.
    
    Uses all three generators and their inverses.
    
    Time: O(|orbit| · 6), Space: O(|orbit|)
    
    Args:
        start: Starting point in canonical form
        p: Prime modulus
    
    Returns:
        Set of all points reachable from start
    """
    orbit = set()
    queue = deque([start])
    
    # Inverse matrices
    # A^{-1}: det=1, [[0,1],[-1,2]]
    # B^{-1}: det=-1, [[0,-1],[1,2]] ~ [[0,p-1],[1,2]]
    # C^{-1}: [[1,-2],[0,1]]
    inv_A = ((0, 1), ((-1) % p, 2))
    inv_B = ((0, (-1) % p), (1, 2))
    inv_C = ((1, (-2) % p), (0, 1))
    
    all_gens = [BERGGREN_A2, BERGGREN_B2, BERGGREN_C2, inv_A, inv_B, inv_C]
    
    while queue:
        pt = queue.popleft()
        if pt in orbit:
            continue
        orbit.add(pt)
        for M in all_gens:
            m, n = pt
            new_m = (M[0][0] * m + M[0][1] * n) % p
            new_n = (M[1][0] * m + M[1][1] * n) % p
            new_pt = normalize_point(new_m, new_n, p)
            if new_pt is not None and new_pt not in orbit:
                queue.append(new_pt)
    
    return orbit

def compute_all_orbits(p: int) -> List[Set[Tuple[int, int]]]:
    """Compute all orbits of the Berggren group on P¹(F_p).
    
    Time: O(p · 6) since action is typically transitive, Space: O(p)
    """
    all_points = [(1, n) for n in range(p)] + [(0, 1)]
    visited = set()
    orbits = []
    
    for pt in all_points:
        if pt not in visited:
            orbit = compute_orbit(pt, p)
            visited |= orbit
            orbits.append(orbit)
    
    return orbits

# ============================================================
# Algorithm 4: Group Size Enumeration
# ============================================================

def enumerate_berggren_group(p: int, max_elements: int = 50000) -> Set[tuple]:
    """Enumerate the Berggren subgroup of PGL₂(F_p).
    
    Uses BFS in the Cayley graph of PGL₂(F_p).
    
    Time: O(min(|G|, max_elements) · 6), Space: O(min(|G|, max_elements))
    """
    identity = ((1, 0), (0, 1))
    inv_A = ((0, 1), ((-1) % p, 2 % p))
    inv_B = ((0, (-1) % p), (1, 2 % p))
    inv_C = ((1, (-2) % p), (0, 1))
    
    all_gens = [BERGGREN_A2, BERGGREN_B2, BERGGREN_C2, inv_A, inv_B, inv_C]
    
    seen = set()
    norm_id = normalize_matrix(identity, p)
    seen.add(norm_id)
    queue = deque([identity])
    
    while queue and len(seen) < max_elements:
        M = queue.popleft()
        for G in all_gens:
            prod = mat_mul_2x2(M, G, p)
            key = normalize_matrix(prod, p)
            if key is not None and key not in seen:
                seen.add(key)
                queue.append(prod)
    
    return seen

# ============================================================
# Algorithm 5: Cayley Graph Construction
# ============================================================

def build_cayley_graph(p: int) -> Dict[Tuple[int, int], Dict[str, Tuple[int, int]]]:
    """Build the Cayley graph of the Berggren action on P¹(F_p).
    
    Returns adjacency dict: point -> {generator_name: target_point}.
    
    Time: O(p · 3), Space: O(p · 3)
    """
    all_points = [(1, n) for n in range(p)] + [(0, 1)]
    graph = {}
    
    for pt in all_points:
        neighbors = {}
        for name, M in [('A', BERGGREN_A2), ('B', BERGGREN_B2), ('C', BERGGREN_C2)]:
            m, n = pt
            new_m = (M[0][0] * m + M[0][1] * n) % p
            new_n = (M[1][0] * m + M[1][1] * n) % p
            target = normalize_point(new_m, new_n, p)
            if target is not None:
                neighbors[name] = target
        graph[pt] = neighbors
    
    return graph

# ============================================================
# Algorithm 6: Spectrum of Adjacency Matrix
# ============================================================

def adjacency_spectrum(p: int) -> np.ndarray:
    """Compute the spectrum of the Berggren Cayley graph on P¹(F_p).
    
    The adjacency matrix is (p+1)×(p+1) with edges from all three generators.
    
    Time: O(p³) for eigenvalue computation, Space: O(p²)
    """
    all_points = [(1, n) for n in range(p)] + [(0, 1)]
    pt_to_idx = {pt: i for i, pt in enumerate(all_points)}
    n = len(all_points)
    
    adj = np.zeros((n, n), dtype=float)
    
    for pt in all_points:
        i = pt_to_idx[pt]
        for M in [BERGGREN_A2, BERGGREN_B2, BERGGREN_C2]:
            m, nn = pt
            new_m = (M[0][0] * m + M[0][1] * nn) % p
            new_n = (M[1][0] * m + M[1][1] * nn) % p
            target = normalize_point(new_m, new_n, p)
            if target is not None:
                j = pt_to_idx[target]
                adj[i][j] += 1
    
    eigenvalues = np.sort(np.linalg.eigvalsh(adj + adj.T))[::-1]
    return eigenvalues

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("Berggren-PGL₂ Algorithms")
    print("=" * 50)
    
    # Orbit transitivity
    print("\nOrbit Transitivity Check:")
    for p in [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        orbits = compute_all_orbits(p)
        sizes = [len(o) for o in orbits]
        transitive = len(orbits) == 1 and sizes[0] == p + 1
        print(f"  p={p:2d}: {'transitive ✓' if transitive else f'NOT transitive, orbits={sizes}'}")
    
    # Group sizes
    print("\nGroup Sizes:")
    for p in [3, 5, 7, 11, 13, 17]:
        group = enumerate_berggren_group(p)
        pgl2_size = p * (p * p - 1)
        psl2_size = p * (p * p - 1) // 2
        print(f"  p={p:2d}: |Berggren|={len(group):6d}, "
              f"|PGL₂|={pgl2_size:6d}, |PSL₂|={psl2_size:6d}, "
              f"= {'PGL₂' if len(group) == pgl2_size else 'PSL₂' if len(group) == psl2_size else '???'}")
    
    # Spectral data
    print("\nSpectral Gap (symmetrized adjacency, top 4 eigenvalues):")
    for p in [5, 7, 11, 13, 17, 19, 23]:
        eigs = adjacency_spectrum(p)
        gap = eigs[0] - eigs[1] if len(eigs) > 1 else 0
        print(f"  p={p:2d}: λ = [{', '.join(f'{e:.2f}' for e in eigs[:4])}], gap={gap:.3f}")
