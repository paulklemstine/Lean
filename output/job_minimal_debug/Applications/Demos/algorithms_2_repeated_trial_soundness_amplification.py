"""
Algorithms for Freivalds' Randomized Matrix Verification

Implements the core algorithms with full documentation, type hints,
and complexity analysis.
"""

import numpy as np
from typing import Tuple, Optional, List
from dataclasses import dataclass


@dataclass
class VerificationResult:
    """Result of a Freivalds verification run."""
    accepted: bool
    num_trials: int
    field_size: int
    error_bound: float
    trial_results: List[bool]


class FreivaldsVerifier:
    """Freivalds' randomized matrix multiplication verifier over F_q.

    Given matrices A (m×n), B (n×p), and claimed product K (m×p),
    verifies whether K = A*B over the finite field F_q using
    independent random vector tests.

    Time Complexity: O(t * (m*n + n*p + m*p)) per verification
                   = O(t * n * max(m,p)) for square matrices
    Space Complexity: O(max(m,n,p)) for the random vector and intermediate results
    Error Probability: ≤ 1/q^t when K ≠ AB

    Args:
        q: Prime field size (must be prime)
        seed: Optional random seed for reproducibility
    """

    def __init__(self, q: int, seed: Optional[int] = None):
        if q < 2:
            raise ValueError(f"Field size must be at least 2, got {q}")
        self.q = q
        self.rng = np.random.default_rng(seed)

    def single_check(self, A: np.ndarray, B: np.ndarray,
                     K: np.ndarray) -> bool:
        """Perform a single Freivalds check.

        Picks a random vector r ∈ F_q^p and tests whether
        K*r ≡ A*(B*r) (mod q).

        Args:
            A: m×n matrix over F_q
            B: n×p matrix over F_q
            K: m×p claimed product matrix over F_q

        Returns:
            True if the check passes (accept), False otherwise (reject)

        Time: O(m*n + n*p + m*p)
        """
        p = B.shape[1]
        r = self.rng.integers(0, self.q, size=(p, 1))

        # Compute B*r first (n×1), then A*(B*r) (m×1)
        # This is O(np + mn) instead of O(mnp) for A*(B*r) vs (AB)*r
        Br = B @ r % self.q
        ABr = A @ Br % self.q
        Kr = K @ r % self.q

        return np.array_equal(Kr % self.q, ABr % self.q)

    def verify(self, A: np.ndarray, B: np.ndarray, K: np.ndarray,
               t: int = 1) -> VerificationResult:
        """Verify K = AB using t independent Freivalds checks.

        Accepts only if ALL t checks pass.

        Args:
            A: m×n matrix over F_q
            B: n×p matrix over F_q
            K: m×p claimed product matrix over F_q
            t: Number of independent trials (default: 1)

        Returns:
            VerificationResult with accept/reject decision and metadata

        Time: O(t * (m*n + n*p))
        Error: ≤ 1/q^t when K ≠ AB
        """
        trial_results = [self.single_check(A, B, K) for _ in range(t)]
        accepted = all(trial_results)
        error_bound = (1.0 / self.q) ** t

        return VerificationResult(
            accepted=accepted,
            num_trials=t,
            field_size=self.q,
            error_bound=error_bound,
            trial_results=trial_results
        )

    def adaptive_verify(self, A: np.ndarray, B: np.ndarray,
                        K: np.ndarray,
                        target_error: float = 1e-10) -> VerificationResult:
        """Verify with enough trials to achieve target error probability.

        Automatically determines t such that 1/q^t ≤ target_error.

        Args:
            A, B, K: Matrices as in verify()
            target_error: Desired upper bound on error probability

        Returns:
            VerificationResult with sufficient trials for target error
        """
        import math
        t = max(1, math.ceil(-math.log(target_error) / math.log(self.q)))
        return self.verify(A, B, K, t)


def compute_kernel_cardinality(D: np.ndarray, q: int) -> int:
    """Compute |ker(D)| over F_q by exhaustive enumeration.

    For small matrices, enumerates all vectors in F_q^p and counts
    those satisfying D*r = 0 mod q.

    Args:
        D: m×p matrix over F_q
        q: Prime field size

    Returns:
        Number of vectors r ∈ F_q^p with D*r ≡ 0 (mod q)

    Warning: Exponential in p! Only for small dimensions.
    """
    p = D.shape[1]
    count = 0

    # Enumerate all vectors in F_q^p
    for idx in range(q ** p):
        r = np.array([(idx // (q ** j)) % q for j in range(p)]).reshape(-1, 1)
        if np.all((D @ r) % q == 0):
            count += 1

    return count


def verify_cardinality_bound(q: int, m: int, p: int,
                              num_matrices: int = 100) -> Tuple[bool, List[dict]]:
    """Empirically verify the cardinality bound |ker(D)| ≤ q^(p-1).

    Generates random nonzero matrices D and checks the bound.

    Args:
        q: Prime field size
        m: Number of rows
        p: Number of columns
        num_matrices: Number of random matrices to test

    Returns:
        (all_passed, results) where results contains per-matrix data
    """
    rng = np.random.default_rng(42)
    results = []
    all_passed = True

    for trial in range(num_matrices):
        D = rng.integers(0, q, size=(m, p))
        if np.all(D == 0):
            D[0, 0] = 1  # Ensure nonzero

        ker_size = compute_kernel_cardinality(D, q)
        bound = q ** (p - 1)
        passed = ker_size <= bound

        results.append({
            'trial': trial,
            'kernel_size': ker_size,
            'bound': bound,
            'passed': passed,
            'ratio': ker_size / (q ** p) if q ** p > 0 else 0
        })

        if not passed:
            all_passed = False

    return all_passed, results


# Example usage
if __name__ == "__main__":
    print("=" * 60)
    print("FREIVALDS VERIFIER — ALGORITHM DEMO")
    print("=" * 60)

    # Create verifier over F_7
    verifier = FreivaldsVerifier(q=7, seed=42)

    # Random matrices
    m, n, p = 5, 4, 5
    A = np.random.randint(0, 7, size=(m, n))
    B = np.random.randint(0, 7, size=(n, p))

    # Correct product
    K_correct = (A @ B) % 7
    # Wrong product
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % 7

    print("\n--- Verifying correct product ---")
    result = verifier.verify(A, B, K_correct, t=10)
    print(f"  Accepted: {result.accepted}")
    print(f"  Trials: {result.num_trials}")
    print(f"  Error bound: {result.error_bound:.2e}")

    print("\n--- Verifying wrong product ---")
    result = verifier.verify(A, B, K_wrong, t=10)
    print(f"  Accepted: {result.accepted}")
    print(f"  Trial results: {result.trial_results}")
    print(f"  Error bound: {result.error_bound:.2e}")

    print("\n--- Adaptive verification (target error 1e-15) ---")
    result = verifier.adaptive_verify(A, B, K_wrong, target_error=1e-15)
    print(f"  Trials needed: {result.num_trials}")
    print(f"  Accepted: {result.accepted}")
    print(f"  Actual error bound: {result.error_bound:.2e}")

    # Verify cardinality bound for small dimensions
    print("\n--- Kernel cardinality verification (F_3, 2×3 matrices) ---")
    passed, results = verify_cardinality_bound(q=3, m=2, p=3, num_matrices=50)
    max_ratio = max(r['ratio'] for r in results)
    print(f"  All bounds satisfied: {passed}")
    print(f"  Maximum |ker|/q^p ratio: {max_ratio:.4f} (bound: {1/3:.4f})")
