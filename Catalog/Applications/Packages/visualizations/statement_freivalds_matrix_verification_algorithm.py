"""
Freivalds' Algorithm and Related Randomized Verification Algorithms

This module implements Freivalds' matrix multiplication verification algorithm
and related randomized algebraic verification methods over finite fields.

All algorithms work over Z/qZ for a prime q, implementing exact finite-field
arithmetic throughout.
"""

import numpy as np
from typing import List, Tuple, Optional
import random


class FiniteField:
    """Arithmetic operations over Z/qZ for prime q."""

    def __init__(self, q: int):
        if not self._is_prime(q):
            raise ValueError(f"{q} is not prime")
        self.q = q

    @staticmethod
    def _is_prime(n: int) -> bool:
        if n < 2:
            return False
        for i in range(2, int(n**0.5) + 1):
            if n % i == 0:
                return False
        return True

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.q

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.q

    def neg(self, a: int) -> int:
        return (-a) % self.q

    def inv(self, a: int) -> int:
        """Multiplicative inverse via Fermat's little theorem: a^{q-2} mod q."""
        if a % self.q == 0:
            raise ZeroDivisionError("Cannot invert zero")
        return pow(a, self.q - 2, self.q)

    def random_element(self) -> int:
        return random.randint(0, self.q - 1)

    def random_vector(self, n: int) -> np.ndarray:
        return np.array([self.random_element() for _ in range(n)], dtype=np.int64)

    def mat_mul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Matrix multiplication over Z/qZ."""
        return (A @ B) % self.q

    def mat_vec_mul(self, M: np.ndarray, v: np.ndarray) -> np.ndarray:
        """Matrix-vector multiplication over Z/qZ."""
        return (M @ v) % self.q

    def dot_product(self, u: np.ndarray, v: np.ndarray) -> int:
        """Dot product over Z/qZ."""
        return int(np.sum(u * v)) % self.q


def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    K: np.ndarray,
    q: int,
    num_trials: int = 1
) -> Tuple[bool, float]:
    """
    Freivalds' randomized matrix multiplication verification.

    Checks whether K = A*B over Z/qZ using random vector tests.

    Args:
        A: m x n matrix (entries in {0, ..., q-1})
        B: n x p matrix
        K: m x p claimed product matrix
        q: prime field size
        num_trials: number of independent random trials

    Returns:
        (accepted, confidence) where:
        - accepted: True if all trials passed
        - confidence: 1 - (1/q)^num_trials (probability of catching error if K != AB)

    Complexity: O(num_trials * (m*p + n*p)) field operations
    """
    F = FiniteField(q)
    p = B.shape[1]

    for _ in range(num_trials):
        r = F.random_vector(p)
        # Compute K*r and A*(B*r) separately to avoid forming A*B
        Kr = F.mat_vec_mul(K, r)
        Br = F.mat_vec_mul(B, r)
        ABr = F.mat_vec_mul(A, Br)

        if not np.array_equal(Kr, ABr):
            return False, 1.0  # Definite rejection

    confidence = 1 - (1 / q) ** num_trials
    return True, confidence


def batched_freivalds_verify(
    matrices: List[Tuple[np.ndarray, np.ndarray, np.ndarray]],
    q: int,
    num_trials: int = 1
) -> Tuple[bool, float]:
    """
    Batched Freivalds verification for multiple matrix products.

    Given k claims A_i * B_i = C_i, verifies all simultaneously using
    random linear combinations: check sum_i alpha_i * (A_i*B_i - C_i) * r = 0.

    Args:
        matrices: list of (A_i, B_i, C_i) tuples
        q: prime field size
        num_trials: number of independent trials

    Returns:
        (accepted, confidence)

    Complexity: O(num_trials * k * (m*p + n*p)) field operations
    """
    F = FiniteField(q)
    k = len(matrices)

    for _ in range(num_trials):
        m = matrices[0][0].shape[0]
        p = matrices[0][1].shape[1]
        r = F.random_vector(p)
        alphas = [F.random_element() for _ in range(k)]

        combined = np.zeros(m, dtype=np.int64)
        for i, (A, B, C) in enumerate(matrices):
            Br = F.mat_vec_mul(B, r)
            ABr = F.mat_vec_mul(A, Br)
            Cr = F.mat_vec_mul(C, r)
            diff = (ABr - Cr) % q
            combined = (combined + alphas[i] * diff) % q

        if not np.all(combined == 0):
            return False, 1.0

    confidence = 1 - (1 / q) ** num_trials
    return True, confidence


def random_linear_fingerprint(
    v: np.ndarray,
    q: int,
    fingerprint_size: int = 1
) -> np.ndarray:
    """
    Compute a random linear fingerprint of a vector over Z/qZ.

    The fingerprint is R*v where R is a random fingerprint_size x len(v) matrix.
    Two different vectors collide with probability at most 1/q per fingerprint
    coordinate, by the hyperplane counting theorem.

    Args:
        v: input vector (entries in {0, ..., q-1})
        q: prime field size
        fingerprint_size: number of fingerprint coordinates

    Returns:
        fingerprint vector of length fingerprint_size
    """
    F = FiniteField(q)
    n = len(v)
    R = np.array([[F.random_element() for _ in range(n)]
                   for _ in range(fingerprint_size)], dtype=np.int64)
    return F.mat_vec_mul(R, v)


def streaming_matrix_verify(
    q: int,
    m: int,
    n: int,
    p: int
) -> 'StreamingVerifier':
    """
    Create a streaming verifier for matrix multiplication.

    Returns a StreamingVerifier object that can process matrix entries
    one at a time and verify A*B = K using O(m + p) space.
    """
    return StreamingVerifier(q, m, n, p)


class StreamingVerifier:
    """
    Streaming Freivalds verifier using O(m + p) space.

    Instead of storing the full matrices, maintains random linear
    sketches that suffice for verification.
    """

    def __init__(self, q: int, m: int, n: int, p: int):
        self.F = FiniteField(q)
        self.q = q
        self.m = m
        self.n = n
        self.p = p
        # Random test vector
        self.r = self.F.random_vector(p)
        # Accumulate K*r, A*(B*r) incrementally
        self.Kr = np.zeros(m, dtype=np.int64)
        self.Br = np.zeros(n, dtype=np.int64)
        self.ABr = np.zeros(m, dtype=np.int64)

    def add_K_entry(self, i: int, j: int, val: int):
        """Process entry K[i,j] = val."""
        self.Kr[i] = (self.Kr[i] + val * self.r[j]) % self.q

    def add_B_entry(self, i: int, j: int, val: int):
        """Process entry B[i,j] = val."""
        self.Br[i] = (self.Br[i] + val * self.r[j]) % self.q

    def add_A_entry(self, i: int, j: int, val: int):
        """Process entry A[i,j] = val. Call after all B entries."""
        self.ABr[i] = (self.ABr[i] + val * self.Br[j]) % self.q

    def verify(self) -> bool:
        """Check if K*r == A*(B*r)."""
        return np.array_equal(self.Kr, self.ABr)


def count_kernel_elements(
    M: np.ndarray,
    q: int
) -> int:
    """
    Exactly count |{r in F_q^p : M*r = 0}| by exhaustive enumeration.
    Only practical for small dimensions and field sizes.

    Args:
        M: m x p matrix over Z/qZ
        q: prime field size

    Returns:
        Number of vectors r in the kernel of M over Z/qZ
    """
    p = M.shape[1]
    count = 0

    def enumerate_vectors(dim, q):
        if dim == 0:
            yield np.array([], dtype=np.int64)
            return
        for rest in enumerate_vectors(dim - 1, q):
            for val in range(q):
                yield np.append(rest, val)

    for r in enumerate_vectors(p, q):
        if np.all((M @ r) % q == 0):
            count += 1

    return count


# --- Example usage ---

if __name__ == "__main__":
    print("Freivalds' Algorithm — Implementation Examples")
    print("=" * 60)

    # Example 1: Basic verification
    q = 7
    n = 5
    A = np.random.randint(0, q, (n, n)).astype(np.int64)
    B = np.random.randint(0, q, (n, n)).astype(np.int64)
    K_correct = (A @ B) % q
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q

    print(f"\n1. Basic Freivalds over Z/{q}Z, {n}x{n} matrices")
    accepted, conf = freivalds_verify(A, B, K_correct, q, num_trials=5)
    print(f"   Correct product: accepted={accepted}, confidence={conf:.6f}")
    accepted, conf = freivalds_verify(A, B, K_wrong, q, num_trials=5)
    print(f"   Wrong product:   accepted={accepted}, confidence={conf:.6f}")

    # Example 2: Kernel counting
    print(f"\n2. Kernel counting over Z/{q}Z")
    M = np.array([[1, 2, 3], [0, 0, 0]], dtype=np.int64)  # Rank 1
    kernel_size = count_kernel_elements(M, q)
    print(f"   Rank-1 matrix M, kernel size = {kernel_size}")
    print(f"   Predicted q^(p-1) = {q**2}")

    M2 = np.array([[1, 2, 3], [4, 5, 6]], dtype=np.int64)  # Rank 2
    kernel_size2 = count_kernel_elements(M2, q)
    print(f"   Rank-2 matrix M, kernel size = {kernel_size2}")
    print(f"   Predicted q^(p-2) = {q**1}")

    # Example 3: Fingerprinting
    print(f"\n3. Random linear fingerprinting")
    v1 = np.array([1, 2, 3, 4, 5], dtype=np.int64)
    v2 = np.array([1, 2, 3, 4, 6], dtype=np.int64)  # Differs in last entry
    collisions = 0
    trials = 10000
    for _ in range(trials):
        f1 = random_linear_fingerprint(v1, q, 1)
        f2 = random_linear_fingerprint(v2, q, 1)
        if np.array_equal(f1, f2):
            collisions += 1
    print(f"   Collision rate: {collisions/trials:.4f} (theoretical bound: {1/q:.4f})")
