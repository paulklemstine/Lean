#!/usr/bin/env python3
"""
Algorithms for Finite-Field Verification and Hyperplane Counting

Implements the algorithms described in the research paper:
1. Freivalds' matrix product verification
2. Hyperplane solution counting
3. Repeated-trial amplification
4. Streaming Freivalds verification

All arithmetic is performed modulo a prime q (i.e., over GF(q)).
"""

import numpy as np
from typing import List, Tuple, Optional, Generator
import random


class GFq:
    """Arithmetic over GF(q) for prime q."""
    
    def __init__(self, q: int):
        """Initialize GF(q). q must be prime."""
        self.q = q
    
    def add(self, a: int, b: int) -> int:
        return (a + b) % self.q
    
    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.q
    
    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.q
    
    def inv(self, a: int) -> int:
        """Multiplicative inverse via Fermat's little theorem."""
        assert a % self.q != 0, "Cannot invert zero"
        return pow(a, self.q - 2, self.q)
    
    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))
    
    def dot(self, u: np.ndarray, v: np.ndarray) -> int:
        """Dot product over GF(q)."""
        return int(np.sum(u * v)) % self.q
    
    def matvec(self, M: np.ndarray, v: np.ndarray) -> np.ndarray:
        """Matrix-vector product over GF(q)."""
        return (M @ v) % self.q
    
    def matmul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Matrix multiplication over GF(q)."""
        return (A @ B) % self.q
    
    def random_vector(self, n: int) -> np.ndarray:
        """Uniformly random vector in GF(q)^n."""
        return np.array([random.randint(0, self.q - 1) for _ in range(n)])
    
    def random_matrix(self, m: int, n: int) -> np.ndarray:
        """Uniformly random matrix in GF(q)^{m x n}."""
        return np.array([[random.randint(0, self.q - 1) for _ in range(n)] 
                         for _ in range(m)])


def freivalds_verify(
    A: np.ndarray, B: np.ndarray, K: np.ndarray, 
    q: int, num_trials: int = 1
) -> Tuple[bool, float]:
    """
    Freivalds' randomized matrix product verification.
    
    Checks whether K = A * B over GF(q) using random vector tests.
    
    Algorithm:
        For each trial:
            1. Sample r uniformly from GF(q)^p
            2. Compute y1 = K * r mod q
            3. Compute y2 = A * (B * r mod q) mod q
            4. If y1 != y2, return (False, 0.0)
        If all trials pass, return (True, 1/q^t)
    
    Args:
        A: m x n matrix (entries in {0, ..., q-1})
        B: n x p matrix
        K: m x p matrix (claimed product)
        q: prime field size
        num_trials: number of independent random tests
    
    Returns:
        (accepted, error_bound): whether the check passed, and the
        theoretical upper bound on false acceptance probability.
    
    Complexity:
        Time: O(t * (mp + np)) field operations
        Space: O(m + p) for the vectors
        
    Soundness:
        If K != A*B, Pr[accept] <= (1/q)^num_trials
    """
    gf = GFq(q)
    p = K.shape[1]
    
    for _ in range(num_trials):
        r = gf.random_vector(p)
        y1 = gf.matvec(K, r)
        y2 = gf.matvec(A, gf.matvec(B, r))
        if not np.array_equal(y1, y2):
            return (False, 0.0)
    
    error_bound = (1.0 / q) ** num_trials
    return (True, error_bound)


def count_hyperplane_solutions_exact(
    w: np.ndarray, b: int, q: int
) -> int:
    """
    Count |{r in GF(q)^p : <w, r> = b}| by exhaustive enumeration.
    
    For small p and q only. Verifies the theorem that the count
    is exactly q^(p-1) when w != 0.
    
    Args:
        w: coefficient vector (nonzero)
        b: target value
        q: field size (prime)
    
    Returns:
        Exact count of solutions.
    
    Complexity: O(q^p * p) — exponential, for verification only.
    """
    p = len(w)
    count = 0
    for code in range(q ** p):
        r = []
        val = code
        for _ in range(p):
            r.append(val % q)
            val //= q
        if sum(w[i] * r[i] for i in range(p)) % q == b:
            count += 1
    return count


def streaming_freivalds_verify(
    matrix_stream: Generator[Tuple[str, int, int, int], None, None],
    m: int, n: int, p: int, q: int
) -> bool:
    """
    Streaming Freivalds verification.
    
    Processes matrix entries one at a time, maintaining only O(m + n + p) state.
    
    The stream yields tuples (matrix_name, row, col, value) where
    matrix_name is 'A', 'B', or 'K'.
    
    Algorithm:
        1. Pre-sample random r in GF(q)^p
        2. Process B entries to compute s = B * r (accumulate in O(n) space)
        3. Process A entries to compute t = A * s (accumulate in O(m) space) 
        4. Process K entries to compute u = K * r (accumulate in O(m) space)
        5. Accept iff t = u
    
    Note: This simplified version assumes entries arrive in matrix order
    (all B entries, then all A entries, then all K entries).
    
    Args:
        matrix_stream: generator of (name, i, j, value) tuples
        m, n, p: matrix dimensions
        q: field size
    
    Returns:
        True if the check passes.
    """
    gf = GFq(q)
    r = gf.random_vector(p)
    
    # Accumulators
    Br = np.zeros(n, dtype=np.int64)  # B * r
    ABr = np.zeros(m, dtype=np.int64)  # A * (B * r)
    Kr = np.zeros(m, dtype=np.int64)   # K * r
    
    for name, i, j, val in matrix_stream:
        if name == 'B':
            # B[i,j] contributes val * r[j] to (B*r)[i]
            Br[i] = (Br[i] + val * int(r[j])) % q
        elif name == 'A':
            # A[i,j] contributes val * (B*r)[j] to (A*B*r)[i]
            ABr[i] = (ABr[i] + val * int(Br[j])) % q
        elif name == 'K':
            # K[i,j] contributes val * r[j] to (K*r)[i]
            Kr[i] = (Kr[i] + val * int(r[j])) % q
    
    return np.array_equal(ABr % q, Kr % q)


def hyperplane_density(q: int, p: int) -> float:
    """
    Compute the density of a hyperplane in GF(q)^p.
    
    density = q^(p-1) / q^p = 1/q
    
    This is the fundamental quantity controlling Freivalds' error probability.
    """
    return 1.0 / q


def amplified_error_bound(q: int, t: int) -> float:
    """
    Error bound after t independent Freivalds trials.
    
    Pr[all t trials accept | K != A*B] <= (1/q)^t
    """
    return (1.0 / q) ** t


def required_trials(q: int, target_error: float) -> int:
    """
    Minimum number of Freivalds trials to achieve target error probability.
    
    Returns smallest t such that (1/q)^t <= target_error.
    """
    import math
    if target_error >= 1.0:
        return 0
    return int(math.ceil(-math.log(target_error) / math.log(q)))


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("Freivalds' Algorithm - Example Usage")
    print("=" * 50)
    
    q = 101  # Work over GF(101)
    n = 10
    gf = GFq(q)
    
    # Generate random matrices
    A = gf.random_matrix(n, n)
    B = gf.random_matrix(n, n)
    K_correct = gf.matmul(A, B)
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q
    
    # Test correct product
    result, bound = freivalds_verify(A, B, K_correct, q, num_trials=10)
    print(f"Correct product: accepted={result}, error_bound={bound:.2e}")
    
    # Test incorrect product
    result, bound = freivalds_verify(A, B, K_wrong, q, num_trials=10)
    print(f"Wrong product:   accepted={result}, error_bound={bound:.2e}")
    
    # Required trials for various error targets
    print(f"\nTrials needed for target error over GF({q}):")
    for target in [1e-3, 1e-6, 1e-9, 1e-12, 1e-20]:
        t = required_trials(q, target)
        actual = amplified_error_bound(q, t)
        print(f"  target={target:.0e}: t={t}, actual bound={actual:.2e}")
