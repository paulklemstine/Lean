#!/usr/bin/env python3
"""
Tropical Low-Rank Attack: Algorithms

Implements the core algorithms for tropical matrix operations and the
low-rank attack on the tropical hidden exponent problem.
"""

import numpy as np
from typing import Tuple, Optional

INF = float('inf')


# ─── Core Tropical Arithmetic ────────────────────────────────────────────

def trop_matmul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """
    Tropical (min-plus) matrix multiplication.

    C[i,j] = min_k (A[i,k] + B[k,j])

    Parameters:
        A: n×m matrix with entries in ℝ ∪ {+∞}
        B: m×p matrix with entries in ℝ ∪ {+∞}

    Returns:
        n×p tropical product matrix

    Time complexity: O(n·m·p)
    """
    n, m = A.shape
    m2, p = B.shape
    assert m == m2, f"Inner dimensions must match: {m} vs {m2}"
    C = np.full((n, p), INF)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                val = A[i, k] + B[k, j] if A[i, k] != INF and B[k, j] != INF else INF
                if val < C[i, j]:
                    C[i, j] = val
    return C


def trop_identity(n: int) -> np.ndarray:
    """
    Tropical identity matrix: 0 on diagonal, +∞ elsewhere.

    Time complexity: O(n²)
    """
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0.0)
    return I


def trop_matpow(M: np.ndarray, a: int) -> np.ndarray:
    """
    Tropical matrix power M^a by repeated multiplication.

    Parameters:
        M: n×n tropical matrix
        a: non-negative exponent

    Returns:
        M^a (tropical identity if a=0)

    Time complexity: O(a · n³)
    """
    n = M.shape[0]
    assert M.shape == (n, n), "Matrix must be square"
    assert a >= 0, "Exponent must be non-negative"
    if a == 0:
        return trop_identity(n)
    result = M.copy()
    for _ in range(a - 1):
        result = trop_matmul(result, M)
    return result


def trop_matpow_fast(M: np.ndarray, a: int) -> np.ndarray:
    """
    Tropical matrix power by repeated squaring.

    Time complexity: O(log(a) · n³)
    """
    n = M.shape[0]
    if a == 0:
        return trop_identity(n)
    if a == 1:
        return M.copy()
    result = trop_identity(n)
    base = M.copy()
    while a > 0:
        if a % 2 == 1:
            result = trop_matmul(result, base)
        base = trop_matmul(base, base)
        a //= 2
    return result


# ─── Low-Rank Factorization ─────────────────────────────────────────────

def tropical_rank_factorization(
    G: np.ndarray, r: int
) -> Optional[Tuple[np.ndarray, np.ndarray]]:
    """
    Attempt to find a tropical rank-r factorization G = U ⊗ V.

    Uses a greedy heuristic: select r "basis" rows from G as rows of V,
    then solve for U by tropical "division" (subtraction in min-plus).

    Parameters:
        G: n×n tropical matrix
        r: target rank

    Returns:
        (U, V) such that U⊗V ≈ G, or None if factorization fails.

    Note: Finding exact tropical rank factorizations is NP-hard in general.
    This heuristic works well for matrices that genuinely have low rank.

    Time complexity: O(n²·r) for the factorization attempt
    """
    n = G.shape[0]
    assert G.shape == (n, n)

    if r >= n:
        return trop_identity(n), G.copy()

    # Select r rows greedily (maximize "coverage")
    selected = []
    remaining = list(range(n))

    for _ in range(r):
        best_row = remaining[0]
        best_score = -1
        for row in remaining:
            # Score: how many finite entries this row contributes
            score = np.sum(G[row] != INF)
            if score > best_score:
                best_score = score
                best_row = row
        selected.append(best_row)
        remaining.remove(best_row)

    V = G[selected, :]  # r × n

    # Compute U: U[i,k] = min_j (G[i,j] - V[k,j])
    # This is the "tropical left division"
    U = np.full((n, r), INF)
    for i in range(n):
        for k in range(r):
            for j in range(n):
                if G[i, j] != INF and V[k, j] != INF:
                    candidate = G[i, j] - V[k, j]
                    U[i, k] = min(U[i, k], candidate)

    return U, V


# ─── The Low-Rank Attack ────────────────────────────────────────────────

def low_rank_attack(
    G: np.ndarray,
    P: np.ndarray,
    r: int,
    max_search: int = 10000,
    U: Optional[np.ndarray] = None,
    V: Optional[np.ndarray] = None,
) -> Optional[int]:
    """
    Recover exponent a such that G^a = P, exploiting rank-r structure.

    Algorithm:
    1. Factor G = U ⊗ V (or use provided factors)
    2. Compute core H = V ⊗ U (r × r)
    3. Search: for e = 0, 1, 2, ..., check if U ⊗ H^e ⊗ V = P

    Parameters:
        G: n×n tropical matrix (generator)
        P: n×n tropical matrix (target = G^a)
        r: tropical rank bound
        max_search: maximum exponent to try
        U, V: optional pre-computed factorization

    Returns:
        The exponent a, or None if not found

    Time complexity: O(a · (n·r² + r³)) vs O(a · n³) for brute force
    """
    n = G.shape[0]

    # Step 1: Factor
    if U is None or V is None:
        result = tropical_rank_factorization(G, r)
        if result is None:
            return None
        U, V = result

    # Step 2: Compute core
    H = trop_matmul(V, U)  # r × r

    # Step 3: Search
    H_power = trop_identity(r)
    for e in range(max_search):
        candidate = trop_matmul(trop_matmul(U, H_power), V)
        if np.array_equal(candidate, P):
            return e + 1
        H_power = trop_matmul(H_power, H)

    return None


def brute_force_search(
    G: np.ndarray, P: np.ndarray, max_search: int = 10000
) -> Optional[int]:
    """
    Brute-force search for exponent a such that G^a = P.

    Time complexity: O(a · n³)
    """
    n = G.shape[0]
    G_power = trop_identity(n)
    for a in range(1, max_search + 1):
        G_power = trop_matmul(G_power, G)
        if np.array_equal(G_power, P):
            return a
    return None


# ─── Periodicity Detection ──────────────────────────────────────────────

def detect_periodicity(
    M: np.ndarray, max_steps: int = 1000
) -> Optional[Tuple[int, int]]:
    """
    Detect eventual periodicity of tropical matrix powers.

    Returns (pre_period, period) such that M^(k+period) = M^k for all k ≥ pre_period,
    or None if no periodicity detected within max_steps.

    Uses Floyd's cycle detection on the sequence of matrix fingerprints.

    Time complexity: O(max_steps · n³)
    """
    n = M.shape[0]
    powers = {}

    for k in range(max_steps):
        Mk = trop_matpow(M, k)
        key = tuple(Mk.flatten())
        if key in powers:
            pre_period = powers[key]
            period = k - pre_period
            return pre_period, period
        powers[key] = k

    return None


# ─── Verification Utilities ─────────────────────────────────────────────

def verify_sandwich_identity(
    U: np.ndarray, V: np.ndarray, a: int
) -> bool:
    """Verify (U⊗V)^a = U ⊗ (V⊗U)^(a-1) ⊗ V for given a ≥ 1."""
    assert a >= 1
    G = trop_matmul(U, V)
    H = trop_matmul(V, U)
    lhs = trop_matpow(G, a)
    rhs = trop_matmul(trop_matmul(U, trop_matpow(H, a - 1)), V)
    return np.array_equal(lhs, rhs)


def verify_collision_transfer(
    U: np.ndarray, V: np.ndarray, a: int, b: int
) -> bool:
    """Verify: H^(a-1) = H^(b-1) implies G^a = G^b."""
    assert a >= 1 and b >= 1
    H = trop_matmul(V, U)
    if not np.array_equal(trop_matpow(H, a - 1), trop_matpow(H, b - 1)):
        return True  # vacuously true
    G = trop_matmul(U, V)
    return np.array_equal(trop_matpow(G, a), trop_matpow(G, b))


if __name__ == "__main__":
    print("Tropical Low-Rank Attack Algorithms")
    print("=" * 50)

    np.random.seed(42)
    n, r = 15, 3
    secret = 25

    U = np.random.randint(0, 10, (n, r)).astype(float)
    V = np.random.randint(0, 10, (r, n)).astype(float)
    G = trop_matmul(U, V)
    P = trop_matpow(G, secret)

    print(f"Setup: {n}×{n} matrix, rank {r}, secret exponent {secret}")

    # Low-rank attack
    import time
    t0 = time.time()
    found = low_rank_attack(G, P, r, U=U, V=V)
    t1 = time.time()
    print(f"Low-rank attack: found a={found} in {(t1-t0)*1000:.1f} ms")

    # Brute force
    t0 = time.time()
    found_bf = brute_force_search(G, P)
    t1 = time.time()
    print(f"Brute force:     found a={found_bf} in {(t1-t0)*1000:.1f} ms")

    # Periodicity
    H = trop_matmul(V, U)
    result = detect_periodicity(H, max_steps=200)
    if result:
        print(f"Core periodicity: pre-period={result[0]}, period={result[1]}")
