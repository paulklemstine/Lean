#!/usr/bin/env python3
"""
algorithms.py — Core Algorithms for Spectral Expansion on SL₂(𝔽_p)

Implements:
1. SL₂(𝔽_p) enumeration (O(p⁴) time, O(p³) space)
2. Cayley graph adjacency matrix construction
3. Spectral gap computation via eigenvalue decomposition
4. Generation testing for matrix pairs
5. Gaussian elimination factorization in SL₂
6. Random walk simulation on Cayley graphs
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional

# ─── Finite Field Arithmetic ─────────────────────────────────────────────

def mod_inverse(a: int, p: int) -> int:
    """Compute a⁻¹ mod p using Fermat's little theorem. O(log p) time."""
    if a % p == 0:
        raise ValueError(f"{a} has no inverse mod {p}")
    return pow(a, p - 2, p)

def mat_mul_mod(A: np.ndarray, B: np.ndarray, p: int) -> np.ndarray:
    """Multiply two 2×2 integer matrices mod p. O(1) time."""
    return np.array([
        [(A[0,0]*B[0,0] + A[0,1]*B[1,0]) % p,
         (A[0,0]*B[0,1] + A[0,1]*B[1,1]) % p],
        [(A[1,0]*B[0,0] + A[1,1]*B[1,0]) % p,
         (A[1,0]*B[0,1] + A[1,1]*B[1,1]) % p]
    ], dtype=int)

def mat_det_mod(A: np.ndarray, p: int) -> int:
    """Determinant of a 2×2 matrix mod p. O(1) time."""
    return int((A[0,0]*A[1,1] - A[0,1]*A[1,0]) % p)

def mat_inv_mod(A: np.ndarray, p: int) -> np.ndarray:
    """Inverse of a 2×2 matrix mod p (requires det ≢ 0). O(log p) time."""
    d_inv = mod_inverse(mat_det_mod(A, p), p)
    return np.array([
        [(A[1,1] * d_inv) % p, ((-A[0,1]) * d_inv) % p],
        [((-A[1,0]) * d_inv) % p, (A[0,0] * d_inv) % p]
    ], dtype=int)

def mat_to_tuple(A: np.ndarray) -> Tuple[int, ...]:
    """Convert 2×2 matrix to hashable tuple."""
    return (int(A[0,0]), int(A[0,1]), int(A[1,0]), int(A[1,1]))

# ─── Algorithm 1: SL₂(𝔽_p) Enumeration ───────────────────────────────────

def enumerate_sl2(p: int) -> List[np.ndarray]:
    """
    Enumerate all elements of SL₂(𝔽_p) by brute force.

    Algorithm:
        For each (a, b, c) ∈ 𝔽_p³, compute d = (1 + bc) · a⁻¹ mod p
        (when a ≠ 0), or enumerate d separately when a = 0.

    Time complexity: O(p³) for the main loop + O(p²) for a=0 case = O(p³)
    Space complexity: O(p³) = O(|SL₂(𝔽_p)|)

    Returns: List of 2×2 numpy arrays, one per group element.
    """
    elements = []
    # Case 1: a ≠ 0
    for a in range(1, p):
        a_inv = mod_inverse(a, p)
        for b in range(p):
            for c in range(p):
                d = ((1 + b * c) * a_inv) % p
                elements.append(np.array([[a, b], [c, d]], dtype=int))
    # Case 2: a = 0 → need -bc ≡ 1 mod p, so c = -(b⁻¹) mod p
    for b in range(1, p):
        b_inv = mod_inverse(b, p)
        c = (-b_inv) % p
        for d in range(p):
            elements.append(np.array([[0, b], [c, d]], dtype=int))

    return elements

# ─── Algorithm 2: Cayley Graph Construction ───────────────────────────────

def build_cayley_graph(elements: List[np.ndarray],
                       generators: List[np.ndarray],
                       p: int) -> np.ndarray:
    """
    Build the adjacency matrix of the Cayley graph Cay(G, S).

    Algorithm:
        1. Index all group elements by hash table.
        2. For each g ∈ G and s ∈ S, compute s·g and look up its index.
        3. Set adj[idx(g), idx(s·g)] = 1.

    Time complexity: O(|G| · |S|)
    Space complexity: O(|G|²) for the adjacency matrix

    Returns: |G| × |G| adjacency matrix (numpy float array).
    """
    n = len(elements)
    elem_to_idx = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    adj = np.zeros((n, n), dtype=float)

    for i, g in enumerate(elements):
        for s in generators:
            sg = mat_mul_mod(s, g, p)
            j = elem_to_idx[mat_to_tuple(sg)]
            adj[i, j] = 1.0

    return adj

# ─── Algorithm 3: Spectral Gap Computation ────────────────────────────────

def compute_spectral_data(adj: np.ndarray,
                          degree: int) -> Dict[str, float]:
    """
    Compute spectral data of a normalized Cayley adjacency matrix.

    Algorithm:
        1. Normalize: A_norm = adj / degree
        2. Compute all eigenvalues via symmetric eigendecomposition
        3. Sort eigenvalues in decreasing order
        4. Return spectral gap = λ₁ - λ₂

    Time complexity: O(|G|³) for eigendecomposition
    Space complexity: O(|G|²)

    Returns dict with keys:
        'eigenvalues': sorted array (descending)
        'lambda_1': largest eigenvalue (should be 1)
        'lambda_2': second largest eigenvalue
        'spectral_gap': λ₁ - λ₂
        'lambda_min': smallest eigenvalue
    """
    adj_norm = adj / degree
    eigenvalues = np.linalg.eigvalsh(adj_norm)
    eig_sorted = np.sort(eigenvalues)[::-1]

    return {
        'eigenvalues': eig_sorted,
        'lambda_1': float(eig_sorted[0]),
        'lambda_2': float(eig_sorted[1]),
        'spectral_gap': float(eig_sorted[0] - eig_sorted[1]),
        'lambda_min': float(eig_sorted[-1]),
    }

# ─── Algorithm 4: Generation Test ─────────────────────────────────────────

def test_generation(generators: List[np.ndarray],
                    p: int,
                    target_order: Optional[int] = None) -> bool:
    """
    Test if a set of generators generates SL₂(𝔽_p) via BFS.

    Algorithm:
        1. Start from the identity matrix.
        2. BFS: multiply by each generator, add new elements.
        3. Continue until no new elements found.
        4. Check if |generated group| = p(p²-1).

    Time complexity: O(|G| · |S|)
    Space complexity: O(|G|)

    Returns: True if generators generate the full group.
    """
    if target_order is None:
        target_order = p * (p * p - 1)

    seen: Set[Tuple[int, ...]] = set()
    identity = np.eye(2, dtype=int)
    queue = [identity]
    seen.add(mat_to_tuple(identity))

    while queue:
        g = queue.pop(0)
        for s in generators:
            sg = mat_mul_mod(s, g, p)
            t = mat_to_tuple(sg)
            if t not in seen:
                seen.add(t)
                queue.append(sg)
                if len(seen) == target_order:
                    return True

    return len(seen) == target_order

# ─── Algorithm 5: Gaussian Elimination Factorization ──────────────────────

def gaussian_factorize_sl2(A: np.ndarray, p: int) -> List[np.ndarray]:
    """
    Factor a matrix in SL₂(𝔽_p) as a product of upper and lower unipotents.

    Algorithm (formalized in Lean as sl2_gaussian_factorization):
        Case 1 (c ≠ 0): A = U((a-1)/c) · L(c) · U((d-1)/c)
        Case 2 (c = 0): A = W⁻¹ · U(·) · L(·) · U(·) where W is the Weyl element

    Here U(x) = [[1,x],[0,1]] and L(x) = [[1,0],[x,1]].

    Time complexity: O(log p) for modular inversions
    Space complexity: O(1)

    Returns: list of elementary matrices whose product equals A.
    """
    a, b, c, d = int(A[0,0]), int(A[0,1]), int(A[1,0]), int(A[1,1])

    def upper(x):
        return np.array([[1, x % p], [0, 1]], dtype=int)

    def lower(x):
        return np.array([[1, 0], [x % p, 1]], dtype=int)

    weyl = np.array([[0, p-1], [1, 0]], dtype=int)  # [[0,-1],[1,0]] mod p
    weyl_inv = np.array([[0, 1], [p-1, 0]], dtype=int)  # [[0,1],[-1,0]] mod p

    if c % p != 0:
        c_inv = mod_inverse(c, p)
        t1 = ((a - 1) * c_inv) % p
        t3 = ((d - 1) * c_inv) % p
        return [upper(t1), lower(c), upper(t3)]
    else:
        # c = 0: multiply by Weyl element
        # W · A = [[0,-1],[1,0]] · [[a,b],[0,d]] = [[0,-d],[a,b]]
        # Now lower-left = a ≠ 0 (since ad = 1)
        a2, b2, c2, d2 = 0, (-d) % p, a, b
        c2_inv = mod_inverse(c2, p)
        t1 = ((a2 - 1) * c2_inv) % p
        t3 = ((d2 - 1) * c2_inv) % p
        return [weyl_inv, upper(t1), lower(c2), upper(t3)]

# ─── Algorithm 6: Random Walk Simulation ──────────────────────────────────

def simulate_random_walk(elements: List[np.ndarray],
                         generators: List[np.ndarray],
                         p: int,
                         num_steps: int,
                         num_walks: int = 1000) -> np.ndarray:
    """
    Simulate random walks on the Cayley graph and track distribution.

    Algorithm:
        1. Start from identity.
        2. At each step, multiply by a uniformly random generator.
        3. Track the distribution over the group.

    Time complexity: O(num_walks · num_steps)
    Space complexity: O(|G|)

    Returns: |G|-dimensional array of visit frequencies at step num_steps.
    """
    import random
    n = len(elements)
    elem_to_idx = {mat_to_tuple(e): i for i, e in enumerate(elements)}
    counts = np.zeros(n)
    identity = np.eye(2, dtype=int)

    for _ in range(num_walks):
        current = identity.copy()
        for _ in range(num_steps):
            s = random.choice(generators)
            current = mat_mul_mod(s, current, p)
        idx = elem_to_idx[mat_to_tuple(current)]
        counts[idx] += 1

    return counts / num_walks

# ─── Example Usage ────────────────────────────────────────────────────────

if __name__ == "__main__":
    p = 5
    print(f"SL₂(𝔽_{p}) algorithms demonstration")
    print(f"{'='*50}")

    # Enumerate
    elements = enumerate_sl2(p)
    print(f"  |SL₂(𝔽_{p})| = {len(elements)}")

    # Canonical generators
    u = np.array([[1, 1], [0, 1]], dtype=int)
    v = np.array([[1, 0], [1, 1]], dtype=int)
    u_inv = mat_inv_mod(u, p)
    v_inv = mat_inv_mod(v, p)
    gens = [u, u_inv, v, v_inv]

    # Test generation
    gen_result = test_generation(gens, p)
    print(f"  Canonical generators generate SL₂: {gen_result}")

    # Spectral gap
    adj = build_cayley_graph(elements, gens, p)
    data = compute_spectral_data(adj, len(gens))
    print(f"  Spectral gap: {data['spectral_gap']:.6f}")
    print(f"  λ₂: {data['lambda_2']:.6f}")

    # Gaussian factorization
    test_mat = np.array([[2, 1], [3, 2]], dtype=int)
    if mat_det_mod(test_mat, p) == 1:
        factors = gaussian_factorize_sl2(test_mat, p)
        product = np.eye(2, dtype=int)
        for f in factors:
            product = mat_mul_mod(product, f, p)
        print(f"  Gaussian factorization test: {np.array_equal(product % p, test_mat % p)}")
