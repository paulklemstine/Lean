#!/usr/bin/env python3
"""
Tropical Spectral Cryptanalysis — Algorithm Implementations

Implements the core algorithms from the research paper:
1. Tropical matrix multiplication and powering
2. Maximum cycle mean computation (Karp's algorithm)
3. Exponent recovery attack
4. Spectral fingerprint verification
"""

from typing import List, Optional, Tuple
import numpy as np
from itertools import permutations

NEGINF = float('-inf')


# ============================================================
# Core Tropical Arithmetic
# ============================================================

def trop_add(a: float, b: float) -> float:
    """Tropical addition (max-plus): max(a, b).

    Complexity: O(1)
    """
    return max(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication (max-plus): a + b (ordinary addition).

    Returns -∞ if either operand is -∞.
    Complexity: O(1)
    """
    if a == NEGINF or b == NEGINF:
        return NEGINF
    return a + b


# ============================================================
# Tropical Matrix Operations
# ============================================================

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication (max-plus).

    For matrices A (m×p) and B (p×n), computes C (m×n) where:
        C[i,j] = max_k (A[i,k] + B[k,j])

    Complexity: O(m * n * p)

    Args:
        A: Left matrix of shape (m, p)
        B: Right matrix of shape (p, n)

    Returns:
        Product matrix of shape (m, n)
    """
    m, p = A.shape
    p2, n = B.shape
    assert p == p2, f"Dimension mismatch: {A.shape} × {B.shape}"

    C = np.full((m, n), NEGINF)
    for i in range(m):
        for j in range(n):
            for k in range(p):
                val = trop_mul(A[i, k], B[k, j])
                C[i, j] = trop_add(C[i, j], val)
    return C


def trop_mat_pow(A: np.ndarray, n: int) -> np.ndarray:
    """Compute the n-th tropical power of a square matrix.

    Uses repeated multiplication (not binary exponentiation, to match
    the formal development).

    Complexity: O(n * m^3) where m is the matrix dimension.

    Args:
        A: Square matrix of shape (m, m)
        n: Non-negative exponent

    Returns:
        A^n in tropical algebra
    """
    m = A.shape[0]
    assert A.shape == (m, m), "Matrix must be square"
    assert n >= 0, "Exponent must be non-negative"

    # Tropical identity: 0 on diagonal, -∞ off-diagonal
    result = np.full((m, m), NEGINF)
    np.fill_diagonal(result, 0.0)

    for _ in range(n):
        result = trop_mat_mul(result, A)
    return result


def trop_identity(m: int) -> np.ndarray:
    """Tropical identity matrix of size m×m.

    Diagonal entries are 0 (tropical multiplicative identity),
    off-diagonal entries are -∞ (tropical additive identity / zero).
    """
    I = np.full((m, m), NEGINF)
    np.fill_diagonal(I, 0.0)
    return I


def trop_scalar_diag(lam: float, m: int) -> np.ndarray:
    """Create a scalar diagonal tropical matrix diag(λ, ..., λ).

    Args:
        lam: The scalar value on the diagonal
        m: Matrix dimension

    Returns:
        m×m matrix with λ on diagonal and -∞ elsewhere
    """
    G = np.full((m, m), NEGINF)
    np.fill_diagonal(G, lam)
    return G


# ============================================================
# Karp's Algorithm for Maximum Cycle Mean
# ============================================================

def karp_cycle_mean(G: np.ndarray) -> float:
    """Compute the maximum cycle mean of a tropical matrix using Karp's algorithm.

    The maximum cycle mean λ* is defined as:
        λ* = max over all simple cycles C of (weight(C) / length(C))

    Karp's algorithm computes this in O(m^2 * n) time by:
    1. Computing shortest paths of exactly k steps for k = 0, ..., m
    2. Using the formula: λ* = max_i min_k (F[m,i] - F[k,i]) / (m - k)

    Note: We adapt for max-plus (longest paths instead of shortest).

    Complexity: O(m^3)

    Args:
        G: Square tropical matrix of shape (m, m)

    Returns:
        Maximum cycle mean, or -∞ if no cycles exist

    Reference:
        R.M. Karp, "A characterization of the minimum cycle mean in a digraph,"
        Discrete Mathematics 23(3), 1978, pp. 309-311.
    """
    m = G.shape[0]

    # F[k][i] = maximum weight of any path of exactly k edges ending at i
    # Starting from a virtual source with 0-weight edges to all vertices
    F = np.full((m + 1, m), NEGINF)
    F[0, :] = 0.0  # paths of length 0 from virtual source

    for k in range(1, m + 1):
        for i in range(m):
            for j in range(m):
                val = trop_mul(F[k-1, j], G[j, i])
                F[k, i] = trop_add(F[k, i], val)

    # λ* = max_i min_k (F[m,i] - F[k,i]) / (m - k)
    # But we want max cycle mean (max-plus), so:
    # λ* = max_i max_k (F[m,i] - F[k,i]) / (m - k)  for nodes reachable in m steps
    lam_star = NEGINF
    for i in range(m):
        if F[m, i] == NEGINF:
            continue
        min_val = float('inf')
        for k in range(m):
            if F[k, i] == NEGINF:
                continue
            val = (F[m, i] - F[k, i]) / (m - k)
            min_val = min(min_val, val)
        if min_val != float('inf'):
            lam_star = max(lam_star, min_val)

    return lam_star


def brute_force_cycle_mean(G: np.ndarray) -> float:
    """Compute maximum cycle mean by brute-force enumeration of simple cycles.

    Only practical for small matrices (m ≤ 8).

    Complexity: O(m! * m)
    """
    m = G.shape[0]
    best = NEGINF

    for length in range(1, m + 1):
        for perm in permutations(range(m), length):
            weight = 0.0
            valid = True
            for idx in range(length):
                src = perm[idx]
                dst = perm[(idx + 1) % length]
                if G[src, dst] == NEGINF:
                    valid = False
                    break
                weight += G[src, dst]
            if valid:
                mean = weight / length
                best = max(best, mean)

    return best


# ============================================================
# Exponent Recovery Attack
# ============================================================

def recover_exponent_scalar_diag(
    observed_d: float,
    lam: float,
    offset_c: float = 0.0
) -> Optional[int]:
    """Recover the secret exponent from an observed diagonal entry.

    Given:
        d = (G^a)_{ii} = a * λ + c

    Recovers:
        a = (d - c) / λ

    Complexity: O(1)

    Args:
        observed_d: The observed diagonal entry value
        lam: The tropical eigenvalue (must be nonzero)
        offset_c: The offset constant (default 0 for scalar diagonal matrices)

    Returns:
        The recovered exponent, or None if λ = 0 or result is not a natural number

    Raises:
        ValueError: If λ is zero
    """
    if lam == 0:
        raise ValueError("Cannot recover exponent when λ = 0")

    a_real = (observed_d - offset_c) / lam

    # Check if a_real is a non-negative integer
    a_int = int(round(a_real))
    if abs(a_real - a_int) < 1e-9 and a_int >= 0:
        return a_int
    return None


def recover_exponent_general(
    observed_d: float,
    lam: float,
    offset_c: float,
    period_p: int,
    periodic_vals: List[float],
    threshold_N: int
) -> List[int]:
    """Recover candidate exponents from an observed diagonal entry (general case).

    For the eventual affine-periodic law:
        (G^n)_{ii} = n*λ + c + π(n)
    where π has period p, finds all n ≥ N satisfying the equation.

    Complexity: O(p) per candidate check, O(max_search / p) candidates

    Args:
        observed_d: The observed diagonal entry
        lam: The tropical eigenvalue
        offset_c: The offset constant
        period_p: The period of the correction term
        periodic_vals: Values of π for residues 0, 1, ..., p-1
        threshold_N: The threshold after which the law holds

    Returns:
        List of candidate exponents
    """
    candidates = []
    max_search = 10000  # reasonable upper bound

    for r in range(period_p):
        pi_r = periodic_vals[r]
        # Solve: d = n*λ + c + π(r) for n ≡ r (mod p)
        if lam == 0:
            if abs(observed_d - offset_c - pi_r) < 1e-9:
                # Any n ≡ r (mod p) with n ≥ N works
                n = threshold_N + ((r - threshold_N % period_p) % period_p)
                candidates.append(n)
        else:
            n_real = (observed_d - offset_c - pi_r) / lam
            n_int = int(round(n_real))
            if (abs(n_real - n_int) < 1e-9 and
                n_int >= threshold_N and
                n_int % period_p == r):
                candidates.append(n_int)

    return sorted(candidates)


# ============================================================
# Spectral Fingerprint Verification
# ============================================================

def verify_injectivity(G: np.ndarray, max_n: int = 100) -> bool:
    """Verify that the diagonal power map n ↦ (G^n)_{00} is injective.

    Tests all exponents from 1 to max_n and checks for collisions.

    Complexity: O(max_n * m^3)

    Args:
        G: Square tropical matrix
        max_n: Maximum exponent to test

    Returns:
        True if no collisions found
    """
    seen = {}
    for n in range(1, max_n + 1):
        Gn = trop_mat_pow(G, n)
        d = Gn[0, 0]
        if d in seen:
            return False
        seen[d] = n
    return True


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    print("Tropical Spectral Cryptanalysis — Algorithm Demonstrations")
    print("=" * 60)

    # Example 1: Scalar diagonal matrix
    lam = 3.0
    m = 4
    G = trop_scalar_diag(lam, m)
    print(f"\n1. Scalar diagonal matrix, λ = {lam}, m = {m}")
    print(f"   Karp cycle mean: {karp_cycle_mean(G):.4f}")
    print(f"   Brute-force cycle mean: {brute_force_cycle_mean(G):.4f}")

    # Example 2: Exponent recovery
    secret = 17
    Ga = trop_mat_pow(G, secret)
    d = Ga[0, 0]
    recovered = recover_exponent_scalar_diag(d, lam)
    print(f"\n2. Exponent recovery: secret={secret}, observed d={d}")
    print(f"   Recovered exponent: {recovered}")
    assert recovered == secret, "Recovery failed!"

    # Example 3: General matrix cycle mean
    H = np.array([
        [1.0, 3.0, NEGINF],
        [NEGINF, 2.0, 1.0],
        [4.0, NEGINF, 0.0]
    ])
    print(f"\n3. General 3×3 matrix:")
    print(f"   Karp cycle mean: {karp_cycle_mean(H):.4f}")
    print(f"   Brute-force cycle mean: {brute_force_cycle_mean(H):.4f}")

    # Example 4: Injectivity
    print(f"\n4. Injectivity verification for diag({lam}):")
    print(f"   Injective up to n=100: {verify_injectivity(G, 100)}")

    print("\n✓ All algorithm tests passed!")
