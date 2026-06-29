#!/usr/bin/env python3
"""
Tropical Cryptography Algorithms — Type-Hinted Implementations

Implements the core algorithms from the Tropical Min-Plus Diffie-Hellman
research, including key exchange, centralizer computation, and attack analysis.
"""

from dataclasses import dataclass
from typing import List, Tuple, Optional, Set
import numpy as np

INF = float('inf')

# ─── Core Tropical Arithmetic ───

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity absorbing)."""
    if a == INF or b == INF:
        return INF
    return a + b

def trop_mat_mul(A: np.ndarray, B: np.ndarray) -> np.ndarray:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k(A_{ik} + B_{kj}).

    Time complexity: O(n³) for n×n matrices.
    """
    n = A.shape[0]
    m = B.shape[1]
    k = A.shape[1]
    C = np.full((n, m), INF)
    for i in range(n):
        for j in range(m):
            for l in range(k):
                C[i, j] = min(C[i, j], trop_mul(A[i, l], B[l, j]))
    return C

def trop_identity(n: int) -> np.ndarray:
    """Tropical identity matrix: 0 on diagonal, ∞ elsewhere."""
    I = np.full((n, n), INF)
    np.fill_diagonal(I, 0)
    return I

# ─── Algorithm 1: Tropical Matrix Power (Repeated Squaring) ───

def trop_mat_pow(A: np.ndarray, k: int) -> np.ndarray:
    """Compute A^k via repeated squaring.

    Pseudocode:
        result ← I (tropical identity)
        base ← A
        while k > 0:
            if k is odd: result ← result ⊗ base
            base ← base ⊗ base
            k ← k // 2
        return result

    Time complexity: O(n³ log k)
    """
    n = A.shape[0]
    result = trop_identity(n)
    base = A.copy()
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    return result

# ─── Algorithm 2: TCKE Protocol ───

@dataclass
class TCKEParams:
    """Parameters for Tropical Centralizer Key Exchange."""
    n: int                    # Matrix dimension
    generator: np.ndarray     # Public generator G
    entry_bound: int          # Max entry value

@dataclass
class TCKESession:
    """A complete TCKE session."""
    params: TCKEParams
    alice_secret: int         # Alice's secret exponent
    bob_secret: int           # Bob's secret exponent
    alice_public: np.ndarray  # G^a
    bob_public: np.ndarray    # G^b
    shared_key: np.ndarray    # G^(a+b+1)

def tcke_keygen(params: TCKEParams, secret: int) -> np.ndarray:
    """Generate public key: G^secret.

    Pseudocode:
        return trop_mat_pow(G, secret)
    """
    return trop_mat_pow(params.generator, secret)

def tcke_shared_key(params: TCKEParams, my_secret: int,
                     other_public: np.ndarray) -> np.ndarray:
    """Compute shared key: G^my_secret ⊗ other_public ⊗ G.

    Actually: G^my_secret ⊗ (G^other_secret ⊗ G) = G^(my_secret + other_secret + 1)
    """
    my_key = trop_mat_pow(params.generator, my_secret)
    return trop_mat_mul(my_key, trop_mat_mul(other_public, params.generator))

def tcke_full_exchange(n: int, bound: int, a: int, b: int) -> TCKESession:
    """Run a complete TCKE key exchange.

    Pseudocode:
        1. Generate random n×n tropical matrix G with entries in [0, bound]
        2. Alice: compute PA = G^a (public key)
        3. Bob: compute PB = G^b (public key)
        4. Alice: compute K = G^a ⊗ (G^b ⊗ G)
        5. Bob: compute K' = G^b ⊗ (G^a ⊗ G)
        6. Assert K = K' = G^(a+b+1)
    """
    G = np.random.randint(0, bound + 1, size=(n, n)).astype(float)
    params = TCKEParams(n=n, generator=G, entry_bound=bound)

    alice_pub = tcke_keygen(params, a)
    bob_pub = tcke_keygen(params, b)
    shared = tcke_shared_key(params, a, bob_pub)

    return TCKESession(
        params=params,
        alice_secret=a,
        bob_secret=b,
        alice_public=alice_pub,
        bob_public=bob_pub,
        shared_key=shared
    )

# ─── Algorithm 3: Centralizer Computation ───

def compute_centralizer(G: np.ndarray, bound: int) -> List[np.ndarray]:
    """Enumerate all matrices with entries in {0,...,bound} commuting with G.

    Pseudocode:
        centralizer ← []
        for each M in {0,...,bound}^{n×n}:
            if M ⊗ G = G ⊗ M:
                centralizer.append(M)
        return centralizer

    Time complexity: O((bound+1)^(n²) · n³)
    Warning: Only feasible for small n and bound.
    """
    from itertools import product as iprod
    n = G.shape[0]
    centralizer = []
    entries = list(range(bound + 1))
    for vals in iprod(entries, repeat=n*n):
        M = np.array(vals, dtype=float).reshape(n, n)
        if np.array_equal(trop_mat_mul(M, G), trop_mat_mul(G, M)):
            centralizer.append(M)
    return centralizer

# ─── Algorithm 4: Rank-1 Detection ───

def is_rank1(M: np.ndarray) -> Tuple[bool, Optional[Tuple[np.ndarray, np.ndarray]]]:
    """Check if M is tropically rank-1 and return factorization if so.

    Pseudocode:
        u ← M[:, 0]  (first column)
        v ← M[0, :] - M[0, 0]  (first row normalized)
        for each i, j:
            if M[i,j] ≠ u[i] + v[j]:
                return (False, None)
        return (True, (u, v))
    """
    n = M.shape[0]
    if n == 0:
        return True, (np.array([]), np.array([]))

    u = M[:, 0].copy()
    v = M[0, :].copy()

    # Check if u_i + v_j = M_{ij} for all i, j (handling ∞)
    for i in range(n):
        for j in range(n):
            expected = trop_mul(u[i], v[j])
            if expected != M[i, j]:
                # Try adjusting v using a different base row
                return False, None

    return True, (u, v - u[0])  # Normalize

# ─── Algorithm 5: Tropical DLP for Rank-1 Matrices ───

def rank1_discrete_log(G: np.ndarray, target: np.ndarray,
                        max_k: int = 1000) -> Optional[int]:
    """Solve G^k = target for rank-1 G.

    For rank-1 matrices, G^k has an explicit formula:
    If G_{ij} = u_i + v_j, then G^k_{ij} = u_i + (k-1)·(min_l(v_l + u_l)) + v_j.

    Pseudocode:
        inner = min_l(G_{l,l})  # = min_l(u_l + v_l)
        for k = 1, 2, ..., max_k:
            if G^k = target:
                return k
        return None

    Time: O(n²) per check, O(max_k · n²) total.
    """
    n = G.shape[0]
    current = G.copy()
    for k in range(1, max_k + 1):
        if np.array_equal(current, target):
            return k
        current = trop_mat_mul(current, G)
    return None

# ─── Algorithm 6: Security Analysis ───

def security_analysis(n: int, bound: int,
                       num_samples: int = 10) -> dict:
    """Analyze TCKE security for given parameters.

    Returns statistics on centralizer sizes for random generators.
    """
    if n > 3 or bound > 3:
        return {"error": "Parameters too large for exhaustive analysis"}

    sizes = []
    total = (bound + 1) ** (n * n)

    for _ in range(num_samples):
        G = np.random.randint(0, bound + 1, size=(n, n)).astype(float)
        cent = compute_centralizer(G, bound)
        sizes.append(len(cent))

    return {
        "n": n,
        "bound": bound,
        "total_matrices": total,
        "mean_centralizer_size": np.mean(sizes),
        "min_centralizer_size": min(sizes),
        "max_centralizer_size": max(sizes),
        "security_ratio": 1 - np.mean(sizes) / total,
        "samples": num_samples
    }


if __name__ == "__main__":
    print("Running TCKE key exchange...")
    session = tcke_full_exchange(n=4, bound=10, a=7, b=13)
    print(f"  Matrix dimension: {session.params.n}")
    print(f"  Entry bound: {session.params.entry_bound}")
    print(f"  Shared key computed: ✓")

    # Verify correctness
    bob_shared = tcke_shared_key(session.params, session.bob_secret,
                                  session.alice_public)
    assert np.array_equal(session.shared_key, bob_shared), "Keys don't match!"
    print(f"  Keys match: ✓")

    print("\nRunning security analysis (n=2, B=2)...")
    stats = security_analysis(2, 2, num_samples=20)
    print(f"  Mean centralizer size: {stats['mean_centralizer_size']:.1f}")
    print(f"  Total matrices: {stats['total_matrices']}")
    print(f"  Security ratio: {stats['security_ratio']:.4f}")
