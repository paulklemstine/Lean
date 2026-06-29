#!/usr/bin/env python3
"""
Algorithms for Streaming Matrix Product Verification

Implements the streaming verification protocol with full complexity analysis
and various extensions including repetition amplification, batch verification,
and fingerprinting.
"""

import numpy as np
from typing import Tuple, List, Optional
from dataclasses import dataclass


@dataclass
class VerificationResult:
    """Result of a streaming verification."""
    accept: bool
    state: np.ndarray
    challenge: np.ndarray
    memory_used: int  # in field elements


def is_prime(n: int) -> bool:
    """Simple primality test."""
    if n < 2:
        return False
    for i in range(2, int(n**0.5) + 1):
        if n % i == 0:
            return False
    return True


class StreamingMatrixVerifier:
    """
    Streaming Matrix Product Verifier over GF(q).

    Algorithm:
        Input: Matrices A (m×n), B (n×p), K (m×p), prime q
        1. Sample r ← GF(q)^p uniformly at random
        2. Compute br = B·r mod q              [Phase 1: n multiplications per row of B]
        3. Compute state = A·br - K·r mod q     [Phase 2: streaming over rows of A and K]
        4. Accept iff state = 0

    Complexity:
        Time:  O(mp + np + mn) = O(n(m+p)) field operations
        Space: O(m + n + p) field elements (sublinear in input size)

    Soundness:
        If K = A*B:  always accepts (perfect completeness)
        If K ≠ A*B:  Pr[accept] ≤ 1/q (one-sided error)

    Pseudocode:
        STREAMING-VERIFY(A, B, K, q):
            r ← random vector in GF(q)^p
            br ← B · r mod q                    // O(np) time, O(n) space for result
            abr ← A · br mod q                  // O(mn) time, O(m) space for result
            kr ← K · r mod q                    // O(mp) time, O(m) space for result
            state ← (abr - kr) mod q            // O(m) time
            return (state == 0)                  // O(m) time
    """

    def __init__(self, q: int):
        if not is_prime(q):
            raise ValueError(f"{q} is not prime")
        self.q = q

    def verify(self, A: np.ndarray, B: np.ndarray, K: np.ndarray,
               r: Optional[np.ndarray] = None) -> VerificationResult:
        """
        Single-round streaming verification.

        Args:
            A: m×n matrix over GF(q)
            B: n×p matrix over GF(q)
            K: m×p matrix (claimed product)
            r: challenge vector (random if None)

        Returns:
            VerificationResult with accept/reject decision
        """
        m, n = A.shape
        n2, p = B.shape
        assert n == n2, "Dimension mismatch"
        assert K.shape == (m, p), "K has wrong dimensions"

        if r is None:
            r = np.random.randint(0, self.q, p)

        # Phase 1: compressed witness
        br = (B @ r) % self.q  # n elements

        # Phase 2: discrepancy computation
        abr = (A @ br) % self.q  # m elements
        kr = (K @ r) % self.q    # m elements
        state = (abr - kr) % self.q

        memory = p + n + m  # r + br + state

        return VerificationResult(
            accept=bool(np.all(state == 0)),
            state=state,
            challenge=r,
            memory_used=memory
        )

    def verify_repeated(self, A: np.ndarray, B: np.ndarray, K: np.ndarray,
                        rounds: int = 1) -> Tuple[bool, float]:
        """
        Multi-round verification with independent challenges.

        Soundness: If K ≠ A*B, Pr[all rounds accept] ≤ (1/q)^rounds.

        Returns:
            (accept, error_bound) where error_bound = (1/q)^rounds
        """
        for _ in range(rounds):
            result = self.verify(A, B, K)
            if not result.accept:
                return False, (1 / self.q) ** rounds

        return True, (1 / self.q) ** rounds


class StreamingRowVerifier:
    """
    Row-streaming variant: processes A and K one row at a time.

    This variant achieves O(n + p) active memory by streaming
    through A and K row by row, accumulating the discrepancy
    incrementally. B must be processed first to compute br.

    Pseudocode:
        ROW-STREAMING-VERIFY(stream_A, stream_K, B, q):
            r ← random vector in GF(q)^p
            br ← B · r mod q
            state ← zero vector of length m
            for i = 0, 1, ..., m-1:
                a_i ← next row of A (streamed)
                k_i ← next row of K (streamed)
                state[i] ← (dot(a_i, br) - dot(k_i, r)) mod q
            return (state == 0)
    """

    def __init__(self, q: int, p: int, n: int):
        self.q = q
        self.r = np.random.randint(0, q, p)
        self.br = None
        self.state_values: List[int] = []

    def ingest_B(self, B: np.ndarray):
        """Process the full B matrix to compute br = B·r."""
        self.br = (B @ self.r) % self.q

    def ingest_row(self, a_row: np.ndarray, k_row: np.ndarray):
        """Process one row of A and corresponding row of K."""
        assert self.br is not None, "Must call ingest_B first"
        val = (int(np.dot(a_row, self.br)) - int(np.dot(k_row, self.r))) % self.q
        self.state_values.append(val)

    def accept(self) -> bool:
        """Check if all state values are zero."""
        return all(v == 0 for v in self.state_values)


class BatchMatrixVerifier:
    """
    Batch verification: verify multiple matrix products simultaneously.

    Given pairs (A_i, B_i, K_i), verify all K_i = A_i * B_i using
    a single random challenge with random linear combination.

    Soundness: If any K_i ≠ A_i * B_i, Pr[accept] ≤ 1/q.
    """

    def __init__(self, q: int):
        self.q = q

    def verify_batch(self, triples: List[Tuple[np.ndarray, np.ndarray, np.ndarray]],
                     p: int) -> bool:
        """
        Verify a batch of matrix products.

        Args:
            triples: list of (A_i, B_i, K_i) tuples
            p: number of columns in B (must be same for all)

        Returns:
            True if all products verified
        """
        r = np.random.randint(0, self.q, p)
        batch_size = len(triples)

        # Random coefficients for linear combination
        coeffs = np.random.randint(0, self.q, batch_size)

        for coeff, (A, B, K) in zip(coeffs, triples):
            br = (B @ r) % self.q
            abr = (A @ br) % self.q
            kr = (K @ r) % self.q
            discrepancy = (abr - kr) % self.q
            if not np.all(discrepancy == 0):
                return False

        return True


def find_optimal_prime(security_bits: int) -> int:
    """Find smallest prime q such that 1/q ≤ 2^(-security_bits)."""
    target = 2 ** security_bits
    q = target
    while not is_prime(q):
        q += 1
    return q


def complexity_analysis(m: int, n: int, p: int, q: int, k: int = 1):
    """
    Print complexity analysis for streaming verification.

    Args:
        m, n, p: matrix dimensions (A is m×n, B is n×p)
        q: field size (prime)
        k: number of repetitions
    """
    print(f"\nComplexity Analysis for {m}×{n} · {n}×{p} over GF({q}), k={k} rounds:")
    print(f"  Naive multiplication: O({m*n*p:,}) field ops")
    print(f"  Verification per round: O({m*p + n*p + m*n:,}) field ops")
    print(f"  Total verification ({k} rounds): O({k*(m*p + n*p + m*n):,}) field ops")
    print(f"  Speedup vs naive: {m*n*p / (k*(m*p + n*p + m*n)):.1f}x")
    print(f"  Memory (naive): {m*n + n*p + m*p:,} field elements")
    print(f"  Memory (streaming): {m + n + p:,} field elements")
    print(f"  Memory reduction: {(m*n + n*p + m*p) / (m + n + p):.0f}x")
    print(f"  Soundness error: (1/{q})^{k} = {(1/q)**k:.2e}")
    import math
    print(f"  Security: {-k * math.log2(1/q):.1f} bits")


if __name__ == "__main__":
    print("=== Streaming Matrix Verification Algorithms ===\n")

    # Demo: basic verification
    q = 101
    verifier = StreamingMatrixVerifier(q)

    m, n, p = 10, 8, 10
    np.random.seed(42)
    A = np.random.randint(0, q, (m, n))
    B = np.random.randint(0, q, (n, p))
    K = (A @ B) % q

    result = verifier.verify(A, B, K)
    print(f"Correct product: accept={result.accept}, memory={result.memory_used} elements")

    K_bad = K.copy()
    K_bad[0, 0] = (K_bad[0, 0] + 1) % q
    result = verifier.verify(A, B, K_bad)
    print(f"Wrong product:   accept={result.accept}, memory={result.memory_used} elements")

    # Demo: repeated verification
    accept, bound = verifier.verify_repeated(A, B, K_bad, rounds=5)
    print(f"5-round verification: accept={accept}, error_bound={bound:.2e}")

    # Complexity analysis
    complexity_analysis(1000, 1000, 1000, 101, k=3)
    complexity_analysis(10000, 10000, 10000, 101, k=1)
