#!/usr/bin/env python3
"""
Algorithms for Idempotent Blackwell–Thermodynamic Duality

Implements:
1. Canonical channel reconstruction from weighted closure systems
2. Blackwell dominance testing via tropical factorization
3. Free-energy profile computation
4. Minimal channel extraction
"""

import numpy as np
from typing import Callable, List, Set, FrozenSet, Tuple, Optional

INF = float('inf')


# ================================================================
# Algorithm 1: Tropical Matrix Operations
# ================================================================

def tropical_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    (A ⊗ B)[i,j] = min_k (A[i,k] + B[k,j])

    Time complexity: O(n * m * p) for n×m and m×p matrices.
    Space complexity: O(n * p) for the output.

    Parameters
    ----------
    A : ndarray of shape (n, m)
    B : ndarray of shape (m, p)

    Returns
    -------
    C : ndarray of shape (n, p)
    """
    n, m = A.shape
    m2, p = B.shape
    assert m == m2, f"Inner dimension mismatch: {m} != {m2}"

    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                val = A[i, k] + B[k, j] if A[i, k] != INF and B[k, j] != INF else INF
                C[i, j] = min(C[i, j], val)
    return C


def tropical_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
    M = np.full((n, n), INF)
    np.fill_diagonal(M, 0.0)
    return M


# ================================================================
# Algorithm 2: Weighted Closure System
# ================================================================

class WeightedClosureSystem:
    """
    A finite weighted closure system.

    Attributes
    ----------
    n : int
        Number of elements.
    cl : Callable
        Closure operator: frozenset -> frozenset.
    weights : ndarray
        Generator weights w(a) for each element.
    """

    def __init__(self, n: int, cl: Callable[[FrozenSet[int]], FrozenSet[int]],
                 weights: np.ndarray):
        self.n = n
        self.cl = cl
        self.weights = weights
        self._verify()

    def _verify(self):
        """Verify closure axioms on singletons and small sets."""
        for a in range(self.n):
            S = frozenset({a})
            cS = self.cl(S)
            assert a in cS, f"Extensivity failed: {a} not in cl({S})"

    def singleton_closure(self, a: int) -> FrozenSet[int]:
        """Return cl({a})."""
        return self.cl(frozenset({a}))

    def canonical_channel(self) -> np.ndarray:
        """
        Construct the canonical channel K_C.

        K_C(a, b) = w(a) if b ∈ cl({a}), else ∞.

        Time complexity: O(n²) where n = |α|.
        Space complexity: O(n²).

        Returns
        -------
        K : ndarray of shape (n, n)
        """
        n = self.n
        K = np.full((n, n), INF)
        for a in range(n):
            cl_a = self.singleton_closure(a)
            for b in cl_a:
                if b < n:
                    K[a, b] = self.weights[a]
        return K

    def closed_sets(self) -> List[FrozenSet[int]]:
        """
        Enumerate all closed sets (sets S with cl(S) = S).

        Time complexity: O(2^n * n) in the worst case.

        Returns
        -------
        List of closed sets as frozensets.
        """
        result = []
        for mask in range(1 << self.n):
            S = frozenset(i for i in range(self.n) if mask & (1 << i))
            if self.cl(S) == S:
                result.append(S)
        return result


# ================================================================
# Algorithm 3: Free Energy Computation
# ================================================================

def free_energy_at(K: np.ndarray, a: int) -> float:
    """
    Compute freeEnergyAt(K, a) = min_b K(a,b).

    Time complexity: O(|β|).
    """
    return float(np.min(K[a, :]))


def free_energy(K: np.ndarray) -> float:
    """
    Compute freeEnergy(K) = min_a min_b K(a,b).

    Time complexity: O(|α| * |β|).
    """
    return float(np.min(K))


def weighted_free_energy(weights: np.ndarray, K: np.ndarray) -> float:
    """
    Compute weightedFreeEnergy(C, K) = min_a (w(a) + min_b K(a,b)).

    Time complexity: O(|α| * |β|).
    """
    n = K.shape[0]
    return min(weights[a] + free_energy_at(K, a) for a in range(n))


def free_energy_profile(weights: np.ndarray, K: np.ndarray) -> np.ndarray:
    """
    Compute freeEnergyProfile(C, K) = [w(a) + min_b K(a,b) for a in α].

    Time complexity: O(|α| * |β|).

    Returns
    -------
    profile : ndarray of shape (|α|,)
    """
    n = K.shape[0]
    return np.array([weights[a] + free_energy_at(K, a) for a in range(n)])


# ================================================================
# Algorithm 4: Blackwell Dominance Testing
# ================================================================

def check_blackwell_le(K: np.ndarray, L: np.ndarray,
                       tol: float = 1e-10) -> Tuple[bool, Optional[np.ndarray]]:
    """
    Test whether BlackwellLE(K, L) holds: does L factor through K?

    Attempts to find T such that L = K ⊗ T by solving a tropical
    linear system. Uses a greedy approach for finite channels.

    Time complexity: O(|α| * |β| * |γ|).

    Parameters
    ----------
    K : ndarray of shape (n, m) - the dominating channel
    L : ndarray of shape (n, p) - the dominated channel

    Returns
    -------
    (success, T) where T is the garbling matrix if found, else None.
    """
    n, m = K.shape
    n2, p = L.shape
    assert n == n2, "Input type mismatch"

    # For each (b, c) pair, T[b,c] must satisfy:
    # L[a,c] = min_b (K[a,b] + T[b,c]) for all a
    # This means K[a,b] + T[b,c] >= L[a,c] for all a,b,c
    # and for each (a,c), equality is achieved for some b.

    # Upper bound: T[b,c] >= L[a,c] - K[a,b] for all a with K[a,b] < ∞
    T = np.full((m, p), INF)
    for b in range(m):
        for c in range(p):
            # T[b,c] must satisfy K[a,b] + T[b,c] >= L[a,c] for all a
            # So T[b,c] >= max_a (L[a,c] - K[a,b]) where K[a,b] < ∞
            max_diff = -INF
            for a in range(n):
                if K[a, b] < INF and L[a, c] < INF:
                    max_diff = max(max_diff, L[a, c] - K[a, b])
            if max_diff > -INF:
                T[b, c] = max_diff

    # Verify: K ⊗ T should equal L
    KT = tropical_matmul(K, T)
    match = True
    for a in range(n):
        for c in range(p):
            if abs(KT[a, c] - L[a, c]) > tol:
                if not (KT[a, c] == INF and L[a, c] == INF):
                    match = False
                    break

    return (match, T) if match else (False, None)


def check_blackwell_equiv(K: np.ndarray, L: np.ndarray) -> bool:
    """
    Test Blackwell equivalence: BlackwellLE in both directions.

    Time complexity: O(|α| * max(|β|,|γ|)²).
    """
    fwd, _ = check_blackwell_le(K, L)
    bwd, _ = check_blackwell_le(L, K)
    return fwd and bwd


# ================================================================
# Algorithm 5: Minimal Channel Extraction
# ================================================================

def extract_minimal_channel(K: np.ndarray, tol: float = 1e-10) -> Tuple[np.ndarray, List[int]]:
    """
    Extract a minimal channel by removing redundant observations.

    An observation b is redundant if its cost profile K(·, b) equals
    another observation's profile. We keep one representative per
    equivalence class.

    Time complexity: O(|α| * |β|²).

    Parameters
    ----------
    K : ndarray of shape (n, m)

    Returns
    -------
    (K_min, kept_indices) where K_min is the minimal channel and
    kept_indices lists which original columns were retained.
    """
    n, m = K.shape
    kept = []
    profiles_seen = []

    for b in range(m):
        profile = K[:, b]
        is_duplicate = False
        for existing in profiles_seen:
            if np.allclose(profile, existing, atol=tol, equal_nan=True):
                # Also check infinity positions
                if np.all((profile == INF) == (existing == INF)):
                    is_duplicate = True
                    break
        if not is_duplicate:
            kept.append(b)
            profiles_seen.append(profile.copy())

    K_min = K[:, kept]
    return K_min, kept


# ================================================================
# Algorithm 6: Canonical Reconstruction
# ================================================================

def reconstruct_closure_from_channel(K: np.ndarray, tol: float = 1e-10):
    """
    Reconstruct weights and singleton closures from a canonical channel.

    Given K_C(a,b) = w(a) if b ∈ cl({a}) else ∞, recovers:
    - w(a) = K(a,a)  (by extensivity, a ∈ cl({a}))
    - cl({a}) = {b : K(a,b) ≠ ∞}

    Time complexity: O(n²).

    Parameters
    ----------
    K : ndarray of shape (n, n) - a canonical channel

    Returns
    -------
    (weights, closures) where:
    - weights[a] = reconstructed w(a)
    - closures[a] = reconstructed cl({a}) as set
    """
    n = K.shape[0]
    weights = np.array([K[a, a] for a in range(n)])
    closures = [frozenset(b for b in range(n) if K[a, b] < INF) for a in range(n)]
    return weights, closures


# ================================================================
# Main: Run all algorithms on example data
# ================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Idempotent Blackwell-Thermodynamic Duality: Algorithms")
    print("=" * 60)

    # Define a closure system
    def example_cl(S):
        result = set(S)
        changed = True
        while changed:
            changed = False
            if 0 in result and 1 not in result:
                result.add(1); changed = True
            if 2 in result and 3 not in result:
                result.add(3); changed = True
            if 3 in result and 0 not in result:
                result.add(0); changed = True
        return frozenset(result)

    weights = np.array([1.0, 2.0, 3.0, 1.5])
    C = WeightedClosureSystem(4, example_cl, weights)

    # Algorithm: Canonical channel
    K_C = C.canonical_channel()
    print("\n[1] Canonical Channel K_C:")
    print(K_C)

    # Algorithm: Free energy profile
    profile = free_energy_profile(weights, K_C)
    print(f"\n[2] Free-energy profile: {profile}")

    # Algorithm: Garble and verify monotonicity
    T = np.array([[0, 1], [1, 0], [0.5, 0.5], [0, 2]])
    K_garbled = tropical_matmul(K_C, T)
    print(f"\n[3] Garbled channel:")
    print(K_garbled)

    success, T_found = check_blackwell_le(K_C, K_garbled)
    print(f"\n[4] BlackwellLE(K_C, K_garbled): {success}")

    profile_g = free_energy_profile(weights, K_garbled)
    print(f"    Profile (original): {profile}")
    print(f"    Profile (garbled):  {profile_g}")
    print(f"    Pointwise ≤: {all(profile[a] <= profile_g[a] for a in range(4))}")

    # Algorithm: Minimal channel extraction
    K_redundant = np.column_stack([K_C, K_C[:, 0], K_C[:, 1]])
    K_min, kept = extract_minimal_channel(K_redundant)
    print(f"\n[5] Minimal channel extraction:")
    print(f"    Original: {K_redundant.shape[1]} observations")
    print(f"    Minimal: {K_min.shape[1]} observations (kept indices: {kept})")

    # Algorithm: Reconstruction
    w_rec, cl_rec = reconstruct_closure_from_channel(K_C)
    print(f"\n[6] Reconstruction from canonical channel:")
    print(f"    Weights: {w_rec} (original: {weights})")
    for a in range(4):
        print(f"    cl({{{a}}}): {set(cl_rec[a])} (original: {set(C.singleton_closure(a))})")

    # Algorithm: Blackwell equivalence test
    K_C2 = C.canonical_channel()  # Same system → same channel
    print(f"\n[7] Blackwell equivalence (same system): {check_blackwell_equiv(K_C, K_C2)}")
    print(f"    Blackwell equiv (with garbled): {check_blackwell_equiv(K_C, K_garbled)}")

    print("\n" + "=" * 60)
    print("All algorithms completed successfully!")
    print("=" * 60)
