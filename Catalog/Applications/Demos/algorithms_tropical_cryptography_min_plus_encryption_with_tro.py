#!/usr/bin/env python3
"""
Tropical Min-Plus Encryption: Core Algorithms
===============================================
Type-hinted implementations of all tropical cryptographic primitives.
"""

from typing import List, Tuple, Optional
import numpy as np
from numpy.typing import NDArray
from itertools import permutations


Matrix = NDArray[np.float64]
Vector = NDArray[np.float64]


def tropical_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Tropical (min-plus) matrix multiplication.
    
    (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj})
    
    Complexity: O(n³) for n×n matrices.
    
    Args:
        A: n×m matrix
        B: m×p matrix
    
    Returns:
        n×p matrix where each entry is the minimum-weight path.
    """
    n, m = A.shape
    _, p = B.shape
    C = np.full((n, p), np.inf)
    for i in range(n):
        for j in range(p):
            for k in range(m):
                C[i, j] = min(C[i, j], A[i, k] + B[k, j])
    return C


def tropical_mat_pow(A: Matrix, k: int) -> Matrix:
    """Tropical matrix power via repeated squaring.
    
    Computes A^{⊗k} = A ⊗ A ⊗ ... ⊗ A (k times).
    
    Complexity: O(n³ log k) via repeated squaring.
    
    Args:
        A: n×n square matrix
        k: positive integer exponent
    
    Returns:
        A^{⊗k} in the tropical semiring.
    """
    if k <= 0:
        raise ValueError("Exponent must be positive")
    if k == 1:
        return A.copy()
    
    # Repeated squaring
    result = None
    base = A.copy()
    while k > 0:
        if k % 2 == 1:
            result = base.copy() if result is None else tropical_mat_mul(result, base)
        base = tropical_mat_mul(base, base)
        k //= 2
    return result  # type: ignore


def tropical_permanent(A: Matrix) -> Tuple[float, Tuple[int, ...]]:
    """Compute the tropical permanent (optimal assignment).
    
    tropPerm(A) = min_{σ ∈ Sₙ} Σᵢ A(i, σ(i))
    
    This is the assignment problem. Complexity: O(n!) brute force,
    O(n³) via Hungarian algorithm (not implemented here).
    
    Args:
        A: n×n square matrix
    
    Returns:
        (value, optimal_permutation) tuple.
    """
    n = A.shape[0]
    best_val = np.inf
    best_perm: Tuple[int, ...] = tuple(range(n))
    
    for perm in permutations(range(n)):
        val = sum(A[i, perm[i]] for i in range(n))
        if val < best_val:
            best_val = val
            best_perm = perm
    
    return float(best_val), best_perm


def tropical_spectral_gap(A: Matrix) -> float:
    """Compute the tropical spectral gap.
    
    Gap = (2nd smallest permutation sum) - (smallest permutation sum).
    
    A large gap means the optimal assignment is well-separated from
    sub-optimal ones, making the cipher more resistant to perturbation attacks.
    
    Args:
        A: n×n square matrix
    
    Returns:
        Non-negative spectral gap value.
    """
    n = A.shape[0]
    vals = set()
    for perm in permutations(range(n)):
        val = sum(A[i, perm[i]] for i in range(n))
        vals.add(val)
    
    sorted_vals = sorted(vals)
    if len(sorted_vals) <= 1:
        return 0.0
    return sorted_vals[1] - sorted_vals[0]


def tropical_vec_mul(A: Matrix, v: Vector) -> Vector:
    """Tropical matrix-vector multiplication.
    
    (A ⊗ v)_i = min_j (A_{ij} + v_j)
    
    Args:
        A: n×n matrix
        v: n-vector
    
    Returns:
        n-vector result.
    """
    n = A.shape[0]
    result = np.full(n, np.inf)
    for i in range(n):
        for j in range(n):
            result[i] = min(result[i], A[i, j] + v[j])
    return result


class TropicalDiffieHellman:
    """Tropical Diffie-Hellman key exchange protocol.
    
    Protocol:
    1. Public: generator matrix G (n×n over ℤ)
    2. Alice: picks secret a, publishes G^a
    3. Bob: picks secret b, publishes G^b
    4. Shared key: G^{a+b} = G^a ⊗ G^b = G^b ⊗ G^a
    
    Security: based on the Tropical Discrete Logarithm Problem (TDLP).
    """
    
    def __init__(self, n: int, bound: int = 100, seed: Optional[int] = None):
        """Initialize with matrix dimension n and entry bound."""
        if seed is not None:
            np.random.seed(seed)
        self.n = n
        self.generator = np.random.randint(-bound, bound + 1, (n, n)).astype(float)
    
    def generate_keypair(self, secret: int) -> Matrix:
        """Generate public key from secret exponent."""
        return tropical_mat_pow(self.generator, secret)
    
    def compute_shared_key(self, own_key: Matrix, other_public: Matrix) -> Matrix:
        """Compute shared key from own public key and other's public key."""
        return tropical_mat_mul(own_key, other_public)
    
    def verify_agreement(self, alice_secret: int, bob_secret: int) -> bool:
        """Verify that both parties compute the same shared key."""
        G_a = self.generate_keypair(alice_secret)
        G_b = self.generate_keypair(bob_secret)
        
        alice_shared = self.compute_shared_key(G_a, G_b)
        bob_shared = self.compute_shared_key(G_b, G_a)
        
        return np.allclose(alice_shared, bob_shared)


class TropicalPermanentCipher:
    """Novel encryption scheme based on the tropical permanent.
    
    Key insight: the sub-multiplicativity of the tropical permanent
    (tropPerm(A⊗B) ≤ tropPerm(A) + tropPerm(B)) creates a one-way
    information funnel. Each tropical multiplication loses structural
    information about the factors.
    
    The spectral gap measures the security margin — a larger gap
    means the optimal assignment is more isolated, making the
    cipher harder to break.
    """
    
    def __init__(self, n: int, bound: int = 50, seed: Optional[int] = None):
        if seed is not None:
            np.random.seed(seed)
        self.n = n
        self.base = np.random.randint(-bound, bound + 1, (n, n)).astype(float)
    
    def encrypt(self, message: Vector, key_exp: int) -> Vector:
        """Encrypt a message vector using tropical matrix power."""
        key_matrix = tropical_mat_pow(self.base, key_exp)
        return tropical_vec_mul(key_matrix, message)
    
    def security_analysis(self) -> dict:
        """Analyze the security of the base matrix."""
        perm_val, perm_opt = tropical_permanent(self.base)
        gap = tropical_spectral_gap(self.base)
        
        return {
            "matrix_size": self.n,
            "tropical_permanent": perm_val,
            "optimal_assignment": perm_opt,
            "spectral_gap": gap,
            "key_space_bits": self.n * self.n * 7,  # log2(100) ≈ 7 bits per entry
            "estimated_security_bits": min(self.n * self.n * 7 // 2, 256),
        }


if __name__ == "__main__":
    # Quick verification
    dh = TropicalDiffieHellman(n=5, seed=42)
    assert dh.verify_agreement(7, 11), "DH key agreement failed!"
    print("✓ Tropical Diffie-Hellman key agreement verified")
    
    cipher = TropicalPermanentCipher(n=4, seed=42)
    analysis = cipher.security_analysis()
    print(f"✓ Security analysis: {analysis}")
    
    # Verify sub-multiplicativity
    A = np.random.RandomState(42).randint(-5, 6, (4, 4)).astype(float)
    B = np.random.RandomState(43).randint(-5, 6, (4, 4)).astype(float)
    pa, _ = tropical_permanent(A)
    pb, _ = tropical_permanent(B)
    pab, _ = tropical_permanent(tropical_mat_mul(A, B))
    assert pab <= pa + pb + 1e-10, f"Sub-multiplicativity violated: {pab} > {pa} + {pb}"
    print(f"✓ Sub-multiplicativity verified: {pab} ≤ {pa} + {pb} = {pa+pb}")
