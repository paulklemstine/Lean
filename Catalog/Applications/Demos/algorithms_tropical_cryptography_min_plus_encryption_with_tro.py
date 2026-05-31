"""
Tropical (Min-Plus) Matrix Algebra and Cryptographic Primitives

Type-hinted implementations of tropical matrix operations and
the Tropical Diffie-Hellman key exchange protocol.
"""

from __future__ import annotations
import math
from typing import List, Optional, Tuple

INF = float('inf')

# Type aliases
TropVal = float  # float('inf') represents tropical zero (infinity)
TropMatrix = List[List[TropVal]]
TropVector = List[TropVal]


def trop_add(a: TropVal, b: TropVal) -> TropVal:
    """Tropical addition: min(a, b)."""
    return min(a, b)


def trop_mul(a: TropVal, b: TropVal) -> TropVal:
    """Tropical multiplication: a + b (with infinity handling)."""
    if a == INF or b == INF:
        return INF
    return a + b


def trop_identity(n: int) -> TropMatrix:
    """Tropical identity matrix: 0 on diagonal, INF off diagonal."""
    return [[0 if i == j else INF for j in range(n)] for i in range(n)]


def trop_mat_mul(A: TropMatrix, B: TropMatrix) -> TropMatrix:
    """Tropical matrix multiplication: (A ⊗ B)_{ij} = min_k (A_{ik} + B_{kj}).

    Time complexity: O(n^3) where n is the matrix dimension.
    """
    n = len(A)
    C: TropMatrix = [[INF] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                val = trop_mul(A[i][k], B[k][j])
                C[i][j] = trop_add(C[i][j], val)
    return C


def trop_mat_pow(A: TropMatrix, k: int) -> TropMatrix:
    """Tropical matrix power A^{⊗k} by repeated squaring.

    Time complexity: O(n^3 * log(k)).
    """
    n = len(A)
    if k == 0:
        return trop_identity(n)
    if k == 1:
        return [row[:] for row in A]

    result = trop_identity(n)
    base = [row[:] for row in A]
    while k > 0:
        if k % 2 == 1:
            result = trop_mat_mul(result, base)
        base = trop_mat_mul(base, base)
        k //= 2
    return result


def trop_mat_vec_mul(A: TropMatrix, v: TropVector) -> TropVector:
    """Tropical matrix-vector multiplication: (A ⊗ v)_i = min_j (A_{ij} + v_j)."""
    n = len(A)
    result: TropVector = [INF] * n
    for i in range(n):
        for j in range(n):
            result[i] = trop_add(result[i], trop_mul(A[i][j], v[j]))
    return result


def trop_eigenvalue_estimate(A: TropMatrix) -> Optional[TropVal]:
    """Estimate the tropical eigenvalue of A using the shortest-path method.

    The tropical eigenvalue is the minimum average weight of a cycle
    in the directed graph with weight matrix A. This is computed via
    the Karp/Howard algorithm approach.

    Returns None if the matrix has no finite diagonal cycle.
    """
    n = len(A)
    # Compute A^1, A^2, ..., A^n
    powers = [trop_identity(n)]
    for k in range(1, n + 1):
        powers.append(trop_mat_mul(powers[-1], A))

    # Karp's algorithm: λ = min_i max_k (A^n[i][i] - A^k[i][i]) / (n - k)
    min_avg = INF
    for i in range(n):
        if powers[n][i][i] == INF:
            continue
        max_val = -INF
        for k in range(n):
            if powers[k][i][i] == INF:
                continue
            avg = (powers[n][i][i] - powers[k][i][i]) / (n - k)
            max_val = max(max_val, avg)
        if max_val < min_avg:
            min_avg = max_val

    return min_avg if min_avg != INF else None


class TropicalDiffieHellman:
    """Tropical Diffie-Hellman Key Exchange Protocol.

    Protocol:
    1. Public parameter: tropical matrix G of dimension n×n
    2. Alice chooses secret a, publishes pub_A = G^{⊗a}
    3. Bob chooses secret b, publishes pub_B = G^{⊗b}
    4. Shared key = G^{⊗(a*b)} = (G^{⊗a})^{⊗b} = (G^{⊗b})^{⊗a}
    """

    def __init__(self, generator: TropMatrix) -> None:
        self.generator = generator
        self.n = len(generator)

    def public_key(self, secret: int) -> TropMatrix:
        """Compute public key G^{⊗secret}."""
        return trop_mat_pow(self.generator, secret)

    def shared_key(self, other_public: TropMatrix, my_secret: int) -> TropMatrix:
        """Compute shared key (other_public)^{⊗my_secret}."""
        return trop_mat_pow(other_public, my_secret)

    def verify_key_agreement(self, alice_secret: int, bob_secret: int) -> bool:
        """Verify that Alice and Bob compute the same shared key."""
        pub_a = self.public_key(alice_secret)
        pub_b = self.public_key(bob_secret)

        key_alice = self.shared_key(pub_b, alice_secret)
        key_bob = self.shared_key(pub_a, bob_secret)

        return key_alice == key_bob


def attempt_tdlp_eigenvalue(A: TropMatrix, B: TropMatrix) -> Optional[int]:
    """Attempt to solve the Tropical Discrete Logarithm Problem
    using the eigenvalue method.

    Given A and B = A^{⊗k}, try to recover k using:
    λ(B) = k * λ(A), so k = λ(B) / λ(A).

    Returns the recovered k, or None if the method fails.
    """
    lambda_a = trop_eigenvalue_estimate(A)
    lambda_b = trop_eigenvalue_estimate(B)

    if lambda_a is None or lambda_b is None:
        return None
    if lambda_a == 0:
        return None  # Division by zero — eigenvalue method fails

    k_est = lambda_b / lambda_a
    k = round(k_est)

    # Verify
    if k >= 0 and trop_mat_pow(A, k) == B:
        return k
    return None


def attempt_tdlp_brute_force(A: TropMatrix, B: TropMatrix,
                              max_k: int = 1000) -> Optional[int]:
    """Brute-force search for k such that A^{⊗k} = B."""
    current = trop_identity(len(A))
    for k in range(max_k + 1):
        if current == B:
            return k
        current = trop_mat_mul(current, A)
    return None


def generate_random_tropical_matrix(n: int, max_val: int = 100,
                                     seed: Optional[int] = None) -> TropMatrix:
    """Generate a random n×n tropical matrix with entries in [0, max_val]."""
    import random
    if seed is not None:
        random.seed(seed)
    return [[random.randint(0, max_val) for _ in range(n)] for _ in range(n)]


def print_tropical_matrix(M: TropMatrix, name: str = "M") -> None:
    """Pretty-print a tropical matrix."""
    n = len(M)
    print(f"{name} =")
    for i in range(n):
        row_str = "  ["
        for j in range(n):
            if M[i][j] == INF:
                row_str += "  ∞"
            else:
                row_str += f"{M[i][j]:3.0f}"
            if j < n - 1:
                row_str += ", "
        row_str += "]"
        print(row_str)


if __name__ == "__main__":
    # Quick test
    G = [[1, 3], [2, 0]]
    dh = TropicalDiffieHellman(G)
    assert dh.verify_key_agreement(5, 7)
    print("Key agreement verified for 2×2 matrix with secrets (5, 7)")
