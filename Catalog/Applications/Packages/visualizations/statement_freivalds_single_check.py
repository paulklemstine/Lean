#!/usr/bin/env python3
"""
Algorithms for Freivalds' Randomized Matrix Verification

Implements the core algorithms with full complexity analysis:
1. Standard Freivalds checker
2. Amplified Freivalds with configurable confidence
3. Batch matrix product verification
4. Streaming matrix verification
"""

import random
import numpy as np
from typing import List, Tuple, Optional


class FreivaldsChecker:
    """
    Randomized matrix product verifier over Z/qZ.
    
    Given matrices A (m×n), B (n×p), and a claimed product K (m×p),
    verifies whether K = A·B mod q using random vector sampling.
    
    Time complexity per check: O(mp + np) = O(n·max(m,p))
    Space complexity: O(max(m, n, p))
    
    Soundness: If K ≠ A·B, each check detects the error with probability ≥ 1 - 1/q.
    Completeness: If K = A·B, every check accepts.
    """
    
    def __init__(self, q: int):
        """
        Initialize with field size q (should be prime).
        
        Args:
            q: Prime field characteristic
        """
        if q < 2:
            raise ValueError(f"Field size must be ≥ 2, got {q}")
        self.q = q
    
    def _random_vector(self, p: int) -> np.ndarray:
        """Generate a uniformly random vector in (Z/qZ)^p."""
        return np.array([random.randint(0, self.q - 1) for _ in range(p)])
    
    def single_check(self, A: np.ndarray, B: np.ndarray, 
                      K: np.ndarray, r: Optional[np.ndarray] = None) -> bool:
        """
        Single Freivalds check.
        
        Computes K·r and A·(B·r) modulo q, returns True iff they match.
        
        Time: O(mp + np) — two matrix-vector products
        Space: O(max(m, n, p)) — stores intermediate vectors
        
        Args:
            A: m×n matrix over Z/qZ
            B: n×p matrix over Z/qZ  
            K: m×p claimed product matrix
            r: Optional test vector; random if not provided
            
        Returns:
            True if check passes, False if error detected
        """
        p = B.shape[1]
        if r is None:
            r = self._random_vector(p)
        
        # Compute B·r first (n-dimensional), then A·(B·r) (m-dimensional)
        # This is O(np + mn) instead of O(mnp) for computing A·B directly
        Br = (B @ r) % self.q
        ABr = (A @ Br) % self.q
        Kr = (K @ r) % self.q
        
        return np.array_equal(Kr, ABr)
    
    def verify(self, A: np.ndarray, B: np.ndarray, K: np.ndarray,
               num_trials: int = 1) -> Tuple[bool, float]:
        """
        Verify K = A·B with repeated independent trials.
        
        Time: O(t · (mp + np)) where t = num_trials
        
        Soundness guarantee: If K ≠ A·B, the probability of false acceptance
        is at most (1/q)^t.
        
        Args:
            A, B, K: Matrices over Z/qZ
            num_trials: Number of independent random checks
            
        Returns:
            (accepted, error_bound): Whether all checks passed, and the
            theoretical upper bound on false acceptance probability.
        """
        p = B.shape[1]
        for _ in range(num_trials):
            r = self._random_vector(p)
            if not self.single_check(A, B, K, r):
                return False, 0.0
        
        error_bound = (1.0 / self.q) ** num_trials
        return True, error_bound
    
    def verify_with_confidence(self, A: np.ndarray, B: np.ndarray,
                                K: np.ndarray, 
                                target_error: float = 1e-10) -> Tuple[bool, int, float]:
        """
        Verify with adaptive trial count to achieve target error probability.
        
        Automatically determines the number of trials t such that
        (1/q)^t ≤ target_error.
        
        Args:
            A, B, K: Matrices over Z/qZ
            target_error: Desired upper bound on false acceptance probability
            
        Returns:
            (accepted, trials_used, actual_error_bound)
        """
        import math
        t = max(1, math.ceil(-math.log(target_error) / math.log(self.q)))
        accepted, error = self.verify(A, B, K, num_trials=t)
        return accepted, t, error


class BatchFreivaldsChecker(FreivaldsChecker):
    """
    Batch verification of multiple matrix product claims.
    
    Given matrices A_1·B_1 = K_1, ..., A_s·B_s = K_s,
    verifies all claims simultaneously using random linear combinations.
    """
    
    def verify_batch(self, claims: List[Tuple[np.ndarray, np.ndarray, np.ndarray]],
                      num_trials: int = 1) -> Tuple[bool, float]:
        """
        Verify multiple product claims.
        
        Args:
            claims: List of (A, B, K) triples to verify
            num_trials: Independent trials per claim
            
        Returns:
            (all_accepted, max_error_bound)
        """
        max_error = 0.0
        for A, B, K in claims:
            accepted, error = self.verify(A, B, K, num_trials)
            if not accepted:
                return False, 0.0
            max_error = max(max_error, error)
        return True, max_error


class StreamingVerifier(FreivaldsChecker):
    """
    Streaming matrix product verification.
    
    Maintains a running fingerprint that allows verification
    without storing the full matrices.
    
    This is the streaming/online variant of Freivalds' check,
    useful when matrix entries arrive one at a time.
    """
    
    def __init__(self, q: int, m: int, n: int, p: int, num_trials: int = 20):
        super().__init__(q)
        self.m = m
        self.n = n
        self.p = p
        self.num_trials = num_trials
        
        # Pre-generate random test vectors
        self.test_vectors = [self._random_vector(p) for _ in range(num_trials)]
        
        # Running fingerprints: A·(B·r) and K·r for each test vector
        self.fingerprints_AB = [np.zeros(m, dtype=int) for _ in range(num_trials)]
        self.fingerprints_K = [np.zeros(m, dtype=int) for _ in range(num_trials)]
        
        # Intermediate: B·r for each test vector
        self.Br = [np.zeros(n, dtype=int) for _ in range(num_trials)]
    
    def update_B(self, i: int, j: int, val: int):
        """Update B[i,j] = val and refresh fingerprints."""
        for t in range(self.num_trials):
            # B[i,j] contributes val * r[j] to (B·r)[i]
            self.Br[t][i] = (self.Br[t][i] + val * self.test_vectors[t][j]) % self.q
    
    def update_K(self, i: int, j: int, val: int):
        """Update K[i,j] = val and refresh fingerprints."""
        for t in range(self.num_trials):
            self.fingerprints_K[t][i] = (
                self.fingerprints_K[t][i] + val * self.test_vectors[t][j]
            ) % self.q
    
    def finalize_A(self, A: np.ndarray):
        """After all B entries are set, compute A·(B·r) fingerprints."""
        for t in range(self.num_trials):
            self.fingerprints_AB[t] = (A @ self.Br[t]) % self.q
    
    def check(self) -> bool:
        """Check if all fingerprints match."""
        return all(
            np.array_equal(self.fingerprints_AB[t], self.fingerprints_K[t])
            for t in range(self.num_trials)
        )


def hyperplane_count(w: np.ndarray, b: int, q: int) -> int:
    """
    Count |{r ∈ (Z/qZ)^p : w·r = b}| by direct enumeration.
    
    Theoretical result: q^(p-1) when w ≠ 0.
    
    Args:
        w: Nonzero weight vector of length p
        b: Target value in Z/qZ
        q: Field size (prime)
        
    Returns:
        Number of solutions
    """
    p = len(w)
    count = 0
    for code in range(q ** p):
        r = []
        val = code
        for j in range(p):
            r.append(val % q)
            val //= q
        if sum(w[j] * r[j] for j in range(p)) % q == b % q:
            count += 1
    return count


def kernel_size(M: np.ndarray, q: int) -> int:
    """
    Count |ker(M)| = |{r ∈ (Z/qZ)^p : M·r = 0}| by enumeration.
    
    Theoretical bound: ≤ q^(p-1) when M ≠ 0.
    """
    _, p = M.shape
    count = 0
    for code in range(q ** p):
        r = np.zeros(p, dtype=int)
        val = code
        for j in range(p):
            r[j] = val % q
            val //= q
        if np.all((M @ r) % q == 0):
            count += 1
    return count


if __name__ == "__main__":
    random.seed(42)
    
    print("=== Freivalds Checker Demo ===")
    print()
    
    q = 7
    m, n, p = 4, 5, 4
    checker = FreivaldsChecker(q)
    
    A = np.array([[random.randint(0, q-1) for _ in range(n)] for _ in range(m)])
    B = np.array([[random.randint(0, q-1) for _ in range(p)] for _ in range(n)])
    K_correct = (A @ B) % q
    K_wrong = K_correct.copy()
    K_wrong[0, 0] = (K_wrong[0, 0] + 1) % q
    
    # Correct product
    accepted, t, err = checker.verify_with_confidence(A, B, K_correct, target_error=1e-10)
    print(f"Correct product: accepted={accepted}, trials={t}, error_bound={err:.2e}")
    
    # Wrong product  
    accepted, t, err = checker.verify_with_confidence(A, B, K_wrong, target_error=1e-10)
    print(f"Wrong product:   accepted={accepted}, trials={t}, error_bound={err:.2e}")
    
    print()
    print("=== Hyperplane Counting ===")
    w = np.array([1, 0, 3, 2])
    for b in range(min(q, 5)):
        count = hyperplane_count(w, b, q)
        print(f"  |{{r : dot({w}, r) = {b} mod {q}}}| = {count} (expected {q**(len(w)-1)})")
