"""
Tropical (Min-Plus) Cryptography: Core Algorithms

Type-hinted implementations of tropical matrix operations and the
Tropical Diffie-Hellman key exchange protocol.
"""

from typing import List, Optional, Tuple
import math

# Tropical infinity
INF = float('inf')

# Type alias: a tropical matrix is a list of lists of floats (or int)
TropMat = List[List[float]]


def trop_add(a: float, b: float) -> float:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a + b (with infinity handling)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_mat_mul(A: TropMat, B: TropMat) -> TropMat:
    """
    Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).
    
    Equivalent to one step of all-pairs shortest path extension.
    Time complexity: O(n³).
    """
    n = len(A)
    C: TropMat = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i][k], B[k][j])
                C[i][j] = trop_add(C[i][j], val)
    return C


def trop_mat_identity(n: int) -> TropMat:
    """
    Tropical identity matrix: 0 on diagonal, ∞ elsewhere.
    
    In min-plus: staying at a vertex costs 0, no edge between distinct vertices.
    """
    I: TropMat = [[INF] * n for _ in range(n)]
    for i in range(n):
        I[i][i] = 0
    return I


def trop_mat_pow(A: TropMat, k: int) -> TropMat:
    """
    Tropical matrix power via repeated squaring: A^{⊗k}.
    
    Computes the minimum-weight k-step path matrix.
    Time complexity: O(n³ log k).
    
    Algorithm:
      1. Initialize result = I (tropical identity)
      2. While k > 0:
         a. If k is odd, result = result ⊗ A
         b. A = A ⊗ A
         c. k = k >> 1
    """
    n = len(A)
    result = trop_mat_identity(n)
    base = [row[:] for row in A]  # Deep copy
    while k > 0:
        if k & 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k >>= 1
    return result


def trop_trace(A: TropMat) -> float:
    """
    Tropical trace: min of diagonal entries.
    
    Represents the minimum-weight closed walk of the given length
    visiting any single vertex.
    """
    return min(A[i][i] for i in range(len(A)))


def kleene_star(A: TropMat, max_steps: Optional[int] = None) -> TropMat:
    """
    Tropical Kleene star: A* = I ⊕ A ⊕ A² ⊕ ... ⊕ A^{n-1}.
    
    Computes the all-pairs shortest path matrix (Floyd-Warshall equivalent).
    Converges in at most n steps for matrices without negative cycles.
    
    Args:
        A: Square tropical matrix (weighted adjacency matrix).
        max_steps: Maximum number of iterations (default: n).
    
    Returns:
        The shortest-path closure matrix.
    """
    n = len(A)
    if max_steps is None:
        max_steps = n
    
    result = trop_mat_identity(n)
    power = trop_mat_identity(n)
    
    for step in range(1, max_steps + 1):
        power = trop_mat_mul(power, A)
        # Tropical addition (entrywise min)
        for i in range(n):
            for j in range(n):
                result[i][j] = trop_add(result[i][j], power[i][j])
    
    return result


def trop_eigenvalue_estimate(A: TropMat, max_k: int = 100) -> float:
    """
    Estimate the tropical eigenvalue (minimum mean cycle weight).
    
    λ(A) = lim_{k→∞} tr(A^k) / k = min_k tr(A^k) / k.
    
    This is the key quantity for the eigenvalue attack on TDLP.
    """
    n = len(A)
    best = INF
    power = trop_mat_identity(n)
    
    for k in range(1, max_k + 1):
        power = trop_mat_mul(power, A)
        tr = trop_trace(power)
        if tr != INF:
            mean = tr / k
            best = min(best, mean)
    
    return best


def eigenvalue_attack(A: TropMat, B: TropMat) -> Optional[int]:
    """
    Eigenvalue attack on the Tropical Discrete Logarithm Problem.
    
    Given A and B = A^k, attempt to recover k using the fact that
    tr(A^k) ≈ k * λ(A) for the tropical eigenvalue λ(A).
    
    For diagonal matrices, this is exact: k = B_{ii} / A_{ii}.
    For general matrices, uses the trace-based estimator.
    
    Returns:
        Estimated value of k, or None if attack fails.
    """
    n = len(A)
    
    # Strategy 1: Diagonal attack
    for i in range(n):
        if A[i][i] != 0 and A[i][i] != INF:
            if B[i][i] != INF:
                k_est = B[i][i] / A[i][i]
                if k_est == int(k_est) and k_est > 0:
                    # Verify
                    k = int(k_est)
                    if trop_mat_pow(A, k) == B:
                        return k
    
    # Strategy 2: Trace-based attack
    lambda_A = trop_eigenvalue_estimate(A, max_k=n)
    if lambda_A != INF and lambda_A != 0:
        tr_B = trop_trace(B)
        if tr_B != INF:
            k_est = tr_B / lambda_A
            for k in [int(k_est), int(k_est) + 1, max(0, int(k_est) - 1)]:
                if k > 0 and trop_mat_pow(A, k) == B:
                    return k
    
    # Strategy 3: Brute force (for small k)
    power = trop_mat_identity(n)
    for k in range(1, 1000):
        power = trop_mat_mul(power, A)
        if power == B:
            return k
    
    return None


class TropicalDiffieHellman:
    """
    Tropical Diffie-Hellman Key Exchange Protocol.
    
    Protocol:
      1. Public parameters: generator matrix G ∈ TropMat(n)
      2. Alice: picks secret a, publishes G^a
      3. Bob: picks secret b, publishes G^b
      4. Shared key: G^{a+b} = (G^a)^1 ⊗ G^b... 
         Wait — in tropical DH, the shared key is G^{ab}:
         Alice computes (G^b)^a, Bob computes (G^a)^b.
         Both equal G^{ab} since tropical matrix powers commute.
    """
    
    def __init__(self, generator: TropMat):
        self.generator = generator
        self.n = len(generator)
    
    def public_key(self, secret: int) -> TropMat:
        """Compute public key G^secret."""
        return trop_mat_pow(self.generator, secret)
    
    def shared_key(self, my_secret: int, their_public: TropMat) -> TropMat:
        """Compute shared key (their_public)^{my_secret}."""
        return trop_mat_pow(their_public, my_secret)
    
    def verify_correctness(self, a: int, b: int) -> bool:
        """Verify that both parties compute the same shared key."""
        pub_a = self.public_key(a)
        pub_b = self.public_key(b)
        key_alice = self.shared_key(a, pub_b)
        key_bob = self.shared_key(b, pub_a)
        return key_alice == key_bob


def generate_random_tropical_matrix(n: int, max_val: int = 100,
                                     inf_prob: float = 0.1) -> TropMat:
    """Generate a random n×n tropical matrix for testing."""
    import random
    A: TropMat = []
    for i in range(n):
        row = []
        for j in range(n):
            if random.random() < inf_prob:
                row.append(INF)
            else:
                row.append(random.randint(0, max_val))
        A.append(row)
    return A
