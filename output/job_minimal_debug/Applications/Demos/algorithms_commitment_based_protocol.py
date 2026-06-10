#!/usr/bin/env python3
"""
Algorithms for Commitment-Based Matrix Verification Protocols.

Implements the verification algorithms formalized in the Lean development,
including row-check verification, one-hot extraction, and binding commitment
simulation.
"""

import numpy as np
from typing import Tuple, List, Optional, Callable
from dataclasses import dataclass
import hashlib
import time


# =============================================================================
# Core Algorithm 1: Row-Product Computation
# =============================================================================

def compute_row_product(
    A: np.ndarray,
    B: np.ndarray,
    i: int
) -> np.ndarray:
    """
    Compute rowProd(A, B, i) = [sum_j A[i,j] * B[j,k] for k in range(p)].

    This is the data the prover reveals when challenged on row i.

    Time complexity: O(n * p) where A is m×n and B is n×p.
    Space complexity: O(p) for the output vector.

    Args:
        A: Matrix of shape (m, n)
        B: Matrix of shape (n, p)
        i: Row index to compute (0 <= i < m)

    Returns:
        Vector of length p representing row i of A @ B
    """
    return A[i, :] @ B


# =============================================================================
# Core Algorithm 2: One-Hot Row Extraction
# =============================================================================

def one_hot_extract(
    K: np.ndarray,
    i: int
) -> np.ndarray:
    """
    Extract row i from K using one-hot linear functional.

    Computes sum_r oneHotRow(i, r) * K[r, k] for each k.
    Mathematically equivalent to K[i, :] but expressed as a
    linear functional application.

    Time complexity: O(m * p) — linear scan over all rows.
    Space complexity: O(p) for the output.

    Args:
        K: Matrix of shape (m, p)
        i: Row index to extract

    Returns:
        Vector of length p equal to K[i, :]
    """
    m = K.shape[0]
    e_i = np.zeros(m)
    e_i[i] = 1.0
    return e_i @ K


# =============================================================================
# Core Algorithm 3: Row-Wise Verification Protocol
# =============================================================================

@dataclass
class VerificationResult:
    """Result of a matrix multiplication verification."""
    is_correct: bool
    failed_rows: List[int]
    max_error: float
    total_checks: int
    time_seconds: float


def verify_matrix_product(
    A: np.ndarray,
    B: np.ndarray,
    K: np.ndarray,
    tolerance: float = 1e-10
) -> VerificationResult:
    """
    Verify K = A @ B using row-by-row checking.

    Implements the deterministic verification protocol formalized
    in `matrix_mul_eq_iff_rowwise`: checks that for every row i
    and column k, K[i,k] = sum_j A[i,j] * B[j,k].

    Time complexity: O(m * n * p)
    Space complexity: O(p) per row check

    Args:
        A: Matrix of shape (m, n)
        B: Matrix of shape (n, p)
        K: Claimed product matrix of shape (m, p)
        tolerance: Numerical tolerance for floating-point comparison

    Returns:
        VerificationResult with pass/fail status and diagnostics
    """
    start = time.time()
    m = A.shape[0]
    failed_rows = []
    max_error = 0.0
    total_checks = 0

    for i in range(m):
        row_prod = compute_row_product(A, B, i)
        error = np.max(np.abs(K[i, :] - row_prod))
        max_error = max(max_error, error)
        total_checks += 1

        if error > tolerance:
            failed_rows.append(i)

    elapsed = time.time() - start

    return VerificationResult(
        is_correct=len(failed_rows) == 0,
        failed_rows=failed_rows,
        max_error=max_error,
        total_checks=total_checks,
        time_seconds=elapsed
    )


# =============================================================================
# Core Algorithm 4: Freivalds-Style Randomized Verification
# =============================================================================

def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    K: np.ndarray,
    num_rounds: int = 20,
    tolerance: float = 1e-10
) -> VerificationResult:
    """
    Verify K = A @ B using Freivalds' randomized algorithm.

    Instead of checking all m rows, picks random vectors r ∈ {0,1}^p
    and checks K @ r = A @ (B @ r). Each round has error probability
    at most 1/2 for incorrect products, so k rounds give error ≤ 2^(-k).

    Time complexity: O(num_rounds * (m*n + n*p + m*p))
    Space complexity: O(max(m, n, p))

    This is the probabilistic extension of the deterministic row-check
    protocol formalized in the current work.

    Args:
        A: Matrix (m × n)
        B: Matrix (n × p)
        K: Claimed product (m × p)
        num_rounds: Number of random checks
        tolerance: Numerical tolerance

    Returns:
        VerificationResult
    """
    start = time.time()
    p = B.shape[1]
    m = A.shape[0]
    failed = []
    max_error = 0.0

    for round_idx in range(num_rounds):
        # Random binary vector
        r = np.random.randint(0, 2, size=p).astype(float)

        # Check K @ r = A @ (B @ r)
        lhs = K @ r
        rhs = A @ (B @ r)

        error = np.max(np.abs(lhs - rhs))
        max_error = max(max_error, error)

        if error > tolerance:
            failed.append(round_idx)

    elapsed = time.time() - start

    return VerificationResult(
        is_correct=len(failed) == 0,
        failed_rows=failed,
        max_error=max_error,
        total_checks=num_rounds,
        time_seconds=elapsed
    )


# =============================================================================
# Core Algorithm 5: Commitment Scheme (Hash-Based)
# =============================================================================

class HashCommitmentScheme:
    """
    A binding commitment scheme using cryptographic hashing.

    Models the `CommitmentScheme` structure from the formal development.
    The binding property holds computationally (collision resistance of SHA-256).

    Commit: Matrix → bytes (hash)
    Binding: commit(M₁) = commit(M₂) → M₁ = M₂ (computationally)
    """

    def __init__(self, salt: bytes = b"matrix_commit_v1"):
        self.salt = salt

    def commit(self, M: np.ndarray) -> str:
        """Commit to a matrix by hashing its contents."""
        data = self.salt + M.tobytes()
        return hashlib.sha256(data).hexdigest()

    def verify_binding(self, M1: np.ndarray, M2: np.ndarray) -> bool:
        """Check if two matrices have the same commitment."""
        return self.commit(M1) == self.commit(M2)


# =============================================================================
# Core Algorithm 6: Full Protocol Execution
# =============================================================================

@dataclass
class ProtocolTranscript:
    """Complete transcript of the verification protocol."""
    commitment_A: str
    commitment_B: str
    challenges: List[int]
    responses: List[np.ndarray]
    checks_passed: List[bool]
    verdict: str  # "ACCEPT" or "REJECT"
    product_correct: bool
    matrices_unique: bool


def run_full_protocol(
    A: np.ndarray,
    B: np.ndarray,
    K: np.ndarray,
    challenge_rows: Optional[List[int]] = None,
    tolerance: float = 1e-10
) -> ProtocolTranscript:
    """
    Execute the full commitment-based verification protocol.

    Protocol steps:
    1. Prover commits to A and B.
    2. Verifier sends challenges (row indices).
    3. For each challenged row i, prover reveals rowProd(A, B, i).
    4. Verifier checks revealed data against K.
    5. If all checks pass and commitments are binding, K = A @ B.

    This implements the theorem `full_protocol_soundness` from the
    formal development.

    Args:
        A: Left factor matrix (m × n)
        B: Right factor matrix (n × p)
        K: Claimed product matrix (m × p)
        challenge_rows: Rows to challenge (default: all rows)
        tolerance: Numerical tolerance

    Returns:
        ProtocolTranscript with full interaction record
    """
    m = A.shape[0]

    # Step 1: Prover commits
    scheme = HashCommitmentScheme()
    c_A = scheme.commit(A)
    c_B = scheme.commit(B)

    # Step 2: Verifier challenges
    if challenge_rows is None:
        challenge_rows = list(range(m))

    # Step 3-4: Challenge-response and verification
    responses = []
    checks = []

    for i in challenge_rows:
        response = compute_row_product(A, B, i)
        responses.append(response)

        check = np.max(np.abs(K[i, :] - response)) <= tolerance
        checks.append(check)

    # Step 5: Verdict
    all_pass = all(checks)
    full_coverage = set(challenge_rows) == set(range(m))

    if all_pass and full_coverage:
        verdict = "ACCEPT"
    elif all_pass:
        verdict = "ACCEPT (partial coverage — probabilistic guarantee only)"
    else:
        verdict = "REJECT"

    return ProtocolTranscript(
        commitment_A=c_A,
        commitment_B=c_B,
        challenges=challenge_rows,
        responses=responses,
        checks_passed=checks,
        verdict=verdict,
        product_correct=all_pass,
        matrices_unique=True  # by binding property of hash commitment
    )


# =============================================================================
# Algorithm 7: Approximate Verification with Error Bounds
# =============================================================================

def verify_approximate(
    A: np.ndarray,
    B: np.ndarray,
    K: np.ndarray,
    epsilon: float
) -> Tuple[bool, float, np.ndarray]:
    """
    Verify K ≈ A @ B within tolerance epsilon per entry.

    For each row i and column k, checks |K[i,k] - sum_j A[i,j]*B[j,k]| ≤ ε.
    Returns the maximum error and per-row error bounds.

    This previews the approximate verification theorem from FUTURE_DIRECTIONS:
    row-local error bounds propagate to global error bounds.

    Args:
        A: Matrix (m × n)
        B: Matrix (n × p)
        K: Claimed approximate product (m × p)
        epsilon: Per-entry tolerance

    Returns:
        (passes, max_error, row_errors) tuple
    """
    m = A.shape[0]
    row_errors = np.zeros(m)

    for i in range(m):
        row_prod = compute_row_product(A, B, i)
        row_errors[i] = np.max(np.abs(K[i, :] - row_prod))

    max_error = np.max(row_errors)
    passes = max_error <= epsilon

    return passes, max_error, row_errors


# =============================================================================
# Main: Run all algorithms with example data
# =============================================================================

if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 70)
    print("ALGORITHMS: Commitment-Based Matrix Verification")
    print("=" * 70)

    m, n, p = 5, 4, 6
    A = np.random.randn(m, n)
    B = np.random.randn(n, p)
    K_correct = A @ B
    K_wrong = K_correct.copy()
    K_wrong[2, 3] += 0.01

    # Test deterministic verification
    print("\n--- Deterministic Row-Wise Verification ---")
    result = verify_matrix_product(A, B, K_correct)
    print(f"  Correct K: {result.is_correct}, max_error={result.max_error:.2e}, "
          f"time={result.time_seconds:.6f}s")

    result = verify_matrix_product(A, B, K_wrong)
    print(f"  Wrong K:   {result.is_correct}, max_error={result.max_error:.2e}, "
          f"failed_rows={result.failed_rows}")

    # Test Freivalds
    print("\n--- Freivalds Randomized Verification ---")
    result = freivalds_verify(A, B, K_correct, num_rounds=20)
    print(f"  Correct K: {result.is_correct}, max_error={result.max_error:.2e}")

    result = freivalds_verify(A, B, K_wrong, num_rounds=20)
    print(f"  Wrong K:   {result.is_correct}, max_error={result.max_error:.2e}")

    # Test full protocol
    print("\n--- Full Protocol Execution ---")
    transcript = run_full_protocol(A, B, K_correct)
    print(f"  Verdict: {transcript.verdict}")
    print(f"  Commitment A: {transcript.commitment_A[:16]}...")
    print(f"  All checks passed: {all(transcript.checks_passed)}")

    # Test approximate verification
    print("\n--- Approximate Verification ---")
    noise = np.random.randn(m, p) * 0.001
    K_approx = K_correct + noise
    passes, max_err, row_errs = verify_approximate(A, B, K_approx, epsilon=0.01)
    print(f"  Within ε=0.01: {passes}, max_error={max_err:.6f}")
    print(f"  Row errors: {row_errs.round(6)}")

    # Performance comparison
    print("\n--- Performance Scaling ---")
    for sz in [50, 100, 200, 500]:
        A_big = np.random.randn(sz, sz)
        B_big = np.random.randn(sz, sz)
        K_big = A_big @ B_big

        t0 = time.time()
        verify_matrix_product(A_big, B_big, K_big)
        t_det = time.time() - t0

        t0 = time.time()
        freivalds_verify(A_big, B_big, K_big, num_rounds=20)
        t_fre = time.time() - t0

        print(f"  {sz}×{sz}: deterministic={t_det:.4f}s, "
              f"Freivalds(20 rounds)={t_fre:.4f}s, "
              f"speedup={t_det/max(t_fre,1e-9):.1f}x")
