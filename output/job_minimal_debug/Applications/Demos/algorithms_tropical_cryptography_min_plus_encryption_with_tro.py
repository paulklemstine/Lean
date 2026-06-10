#!/usr/bin/env python3
"""
Tropical Cryptography: Core Algorithms

Type-hinted implementations of tropical matrix operations,
Diffie-Hellman key exchange, and security analysis tools.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Optional, List, Tuple
import math

INF = float('inf')

# --- Core Tropical Arithmetic ---

def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity handling)."""
    if a == INF or b == INF:
        return INF
    return a + b

# --- Tropical Matrix Operations ---

Matrix = List[List[float]]

def make_matrix(n: int, fill: float = INF) -> Matrix:
    """Create an n×n matrix filled with a given value."""
    return [[fill] * n for _ in range(n)]

def identity_matrix(n: int) -> Matrix:
    """Tropical identity: 0 on diagonal, ∞ elsewhere."""
    I = make_matrix(n, INF)
    for i in range(n):
        I[i][i] = 0
    return I

def trop_mat_mul(A: Matrix, B: Matrix) -> Matrix:
    """Tropical matrix multiplication: (A⊗B)_ij = min_k(A_ik + B_kj)."""
    n = len(A)
    C = make_matrix(n, INF)
    for i in range(n):
        for j in range(n):
            for k in range(n):
                C[i][j] = trop_add(C[i][j], trop_mul(A[i][k], B[k][j]))
    return C

def trop_mat_add(A: Matrix, B: Matrix) -> Matrix:
    """Tropical matrix addition: (A⊕B)_ij = min(A_ij, B_ij)."""
    n = len(A)
    return [[trop_add(A[i][j], B[i][j]) for j in range(n)] for i in range(n)]

def trop_mat_pow(A: Matrix, k: int) -> Matrix:
    """Tropical matrix power via repeated squaring: O(n³ log k)."""
    n = len(A)
    if k == 0:
        return identity_matrix(n)
    if k == 1:
        return [row[:] for row in A]
    if k % 2 == 0:
        half = trop_mat_pow(A, k // 2)
        return trop_mat_mul(half, half)
    else:
        return trop_mat_mul(A, trop_mat_pow(A, k - 1))

def trop_trace(A: Matrix) -> float:
    """Tropical trace: min of diagonal entries."""
    return min(A[i][i] for i in range(len(A)))

def matrices_equal(A: Matrix, B: Matrix) -> bool:
    """Check if two tropical matrices are equal."""
    n = len(A)
    return all(A[i][j] == B[i][j] for i in range(n) for j in range(n))

# --- Kleene Star (All-Pairs Shortest Paths) ---

def kleene_prefix(A: Matrix, k: int) -> Matrix:
    """Compute I ⊕ A ⊕ A² ⊕ ... ⊕ A^k."""
    n = len(A)
    result = identity_matrix(n)
    Ai = [row[:] for row in A]
    for _ in range(k):
        result = trop_mat_add(result, Ai)
        Ai = trop_mat_mul(A, Ai)
    return result

def kleene_star(A: Matrix) -> Matrix:
    """Compute A* = I ⊕ A ⊕ A² ⊕ ... (converges for non-negative matrices).
    Uses n iterations (sufficient for n×n matrices without negative cycles)."""
    n = len(A)
    return kleene_prefix(A, n)

# --- Stagnation Detection ---

def detect_stagnation(A: Matrix, max_k: int = 10000) -> Optional[int]:
    """Find the stagnation index: smallest k with A^k = A^(k+1).
    Returns None if stagnation is not detected within max_k iterations."""
    n = len(A)
    Ak = [row[:] for row in A]
    for k in range(1, max_k + 1):
        Ak1 = trop_mat_mul(A, Ak)
        if matrices_equal(Ak, Ak1):
            return k
        Ak = Ak1
    return None

# --- Diagonal TDLP Attack ---

def diagonal_tdlp_attack(D: Matrix, Dk: Matrix) -> Optional[int]:
    """Recover exponent k from diagonal matrix D and D^k.
    Returns k if recoverable, None otherwise."""
    n = len(D)
    for i in range(n):
        d = D[i][i]
        dk = Dk[i][i]
        if d != INF and d != 0 and dk != INF:
            k = dk / d
            if k == int(k) and k > 0:
                return int(k)
    return None

# --- Tropical Diffie-Hellman Key Exchange ---

@dataclass
class TropicalDHKeyExchange:
    """Tropical Diffie-Hellman key exchange protocol."""
    n: int              # Matrix size
    B: int              # Entry bound
    G: Matrix           # Public generator matrix
    
    @staticmethod
    def setup(n: int, B: int = 100) -> 'TropicalDHKeyExchange':
        """Generate public parameters."""
        import random
        G = [[random.randint(0, B) for _ in range(n)] for _ in range(n)]
        return TropicalDHKeyExchange(n=n, B=B, G=G)
    
    def generate_public_key(self, secret: int) -> Matrix:
        """Compute G^⊗secret."""
        return trop_mat_pow(self.G, secret)
    
    def compute_shared_key(self, other_public: Matrix, my_secret: int) -> Matrix:
        """Compute (other_public)^⊗my_secret."""
        return trop_mat_pow(other_public, my_secret)
    
    def key_space_size(self) -> float:
        """Compute log2 of the key space size: n² * log2(B+1)."""
        return self.n * self.n * math.log2(self.B + 1)
    
    def verify_correctness(self, a: int, b: int) -> bool:
        """Verify that G^(ab) computed both ways gives the same result."""
        Ga = self.generate_public_key(a)
        Gb = self.generate_public_key(b)
        alice_key = self.compute_shared_key(Gb, a)
        bob_key = self.compute_shared_key(Ga, b)
        return matrices_equal(alice_key, bob_key)

# --- Security Analysis ---

@dataclass
class SecurityAnalysis:
    """Analyze security properties of a tropical DH instance."""
    
    @staticmethod
    def stagnation_security(A: Matrix, security_bits: int = 128) -> dict:
        """Analyze whether the matrix's stagnation index provides adequate security."""
        k0 = detect_stagnation(A, max_k=min(2**20, 2**security_bits))
        if k0 is not None:
            effective_bits = math.log2(k0) if k0 > 0 else 0
            secure = effective_bits >= security_bits
        else:
            effective_bits = float('inf')
            secure = True
        return {
            'stagnation_index': k0,
            'effective_bits': effective_bits,
            'target_bits': security_bits,
            'secure': secure
        }
    
    @staticmethod
    def diagonal_vulnerability(A: Matrix) -> bool:
        """Check if the matrix is diagonal (trivially breakable)."""
        n = len(A)
        for i in range(n):
            for j in range(n):
                if i != j and A[i][j] != INF:
                    return False
        return True
    
    @staticmethod
    def trace_attack(A: Matrix, Ak: Matrix) -> Optional[float]:
        """Attempt to recover k using tropical trace comparison.
        Returns k estimate if the trace gives useful information."""
        trA = trop_trace(A)
        trAk = trop_trace(Ak)
        if trA != INF and trA != 0 and trAk != INF:
            return trAk / trA
        return None

# --- Tropical Convex Combination ---

def trop_lin_comb(a: float, b: float, x: List[float], y: List[float]) -> List[float]:
    """Tropical linear combination: min(a + x_i, b + y_i) for each i."""
    return [trop_add(trop_mul(a, xi), trop_mul(b, yi)) for xi, yi in zip(x, y)]


if __name__ == "__main__":
    # Quick test
    dh = TropicalDHKeyExchange.setup(n=4, B=50)
    assert dh.verify_correctness(7, 13), "DH correctness failed!"
    print(f"Key space: 2^{dh.key_space_size():.1f} bits")
    print(f"Stagnation: {detect_stagnation(dh.G, max_k=200)}")
    print("All tests passed!")
