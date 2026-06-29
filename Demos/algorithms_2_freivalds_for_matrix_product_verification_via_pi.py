#!/usr/bin/env python3
"""
Algorithms for Freivalds' Matrix Product Verification

Implements the core algorithms from the research paper with full
documentation, type hints, complexity analysis, and example usage.
"""

import numpy as np
from typing import Optional, Tuple, List
import time


class FreivaldsVerifier:
    """
    Freivalds' randomized matrix product verifier over Z/qZ.
    
    Given matrices A (m×n), B (n×k), and a claimed product C (m×k),
    verifies whether A*B = C using random vector probes.
    
    Time complexity per check: O(nk + mn) = O(n²) for square matrices
    Space complexity: O(n) for the random vector
    
    Error guarantee: If A*B ≠ C, each check detects the error with 
    probability ≥ 1 - 1/q. After t independent checks, the false
    accept probability is at most (1/q)^t.
    """
    
    def __init__(self, q: int):
        """
        Initialize with prime modulus q.
        
        Args:
            q: A prime number defining the finite field F_q = Z/qZ.
               Larger q gives lower error probability per round.
        """
        self.q = q
    
    def single_check(self, A: np.ndarray, B: np.ndarray, C: np.ndarray,
                     r: Optional[np.ndarray] = None) -> bool:
        """
        Perform one round of Freivalds' check.
        
        Computes A*(B*r) and C*r modulo q, and checks equality.
        
        Args:
            A: Matrix of shape (m, n) with entries in {0, ..., q-1}
            B: Matrix of shape (n, k) with entries in {0, ..., q-1}
            C: Claimed product, shape (m, k) with entries in {0, ..., q-1}
            r: Optional test vector of shape (k,). If None, drawn uniformly.
            
        Returns:
            True if check passes (accept), False if check fails (reject).
            
        Complexity: O(nk + mk) arithmetic operations mod q.
        """
        k = B.shape[1]
        if r is None:
            r = np.random.randint(0, self.q, size=k)
        
        # Key insight: compute B*r first, then A*(B*r)
        # This avoids computing the full product A*B
        Br = (B @ r) % self.q
        ABr = (A @ Br) % self.q
        Cr = (C @ r) % self.q
        
        return np.array_equal(ABr, Cr)
    
    def verify(self, A: np.ndarray, B: np.ndarray, C: np.ndarray,
               num_rounds: int = 1) -> Tuple[bool, float]:
        """
        Perform multiple independent rounds of Freivalds' check.
        
        Args:
            A, B, C: Matrices as in single_check.
            num_rounds: Number of independent verification rounds.
            
        Returns:
            (accepted, error_bound): 
                accepted: True if all rounds passed.
                error_bound: Upper bound on false accept probability.
                
        Complexity: O(t * (nk + mk)) where t = num_rounds.
        """
        for _ in range(num_rounds):
            if not self.single_check(A, B, C):
                return False, 0.0
        
        error_bound = (1.0 / self.q) ** num_rounds
        return True, error_bound
    
    def adaptive_verify(self, A: np.ndarray, B: np.ndarray, C: np.ndarray,
                        target_error: float = 1e-6) -> Tuple[bool, int, float]:
        """
        Adaptively choose the number of rounds to achieve a target error bound.
        
        Args:
            A, B, C: Matrices as in single_check.
            target_error: Desired upper bound on false accept probability.
            
        Returns:
            (accepted, rounds_used, actual_error_bound)
            
        The number of rounds is ceil(log(1/target_error) / log(q)).
        """
        import math
        num_rounds = max(1, math.ceil(math.log(1 / target_error) / math.log(self.q)))
        
        accepted, error_bound = self.verify(A, B, C, num_rounds)
        return accepted, num_rounds, error_bound


def benchmark_freivalds_vs_direct(sizes: List[int], q: int = 101) -> dict:
    """
    Benchmark Freivalds' verification against direct matrix multiplication.
    
    Args:
        sizes: List of matrix dimensions to test.
        q: Prime modulus.
        
    Returns:
        Dictionary with timing results for each size.
    """
    results = {}
    verifier = FreivaldsVerifier(q)
    
    for n in sizes:
        # Generate random matrices
        A = np.random.randint(0, q, size=(n, n))
        B = np.random.randint(0, q, size=(n, n))
        C = (A @ B) % q
        
        # Time direct verification (recompute A*B)
        start = time.time()
        for _ in range(10):
            direct = (A @ B) % q
            _ = np.array_equal(direct, C)
        direct_time = (time.time() - start) / 10
        
        # Time Freivalds (single round)
        start = time.time()
        for _ in range(10):
            verifier.single_check(A, B, C)
        freivalds_time = (time.time() - start) / 10
        
        results[n] = {
            'direct_time': direct_time,
            'freivalds_time': freivalds_time,
            'speedup': direct_time / max(freivalds_time, 1e-10),
        }
        
        print(f"n={n:>5}: Direct={direct_time:.6f}s, "
              f"Freivalds={freivalds_time:.6f}s, "
              f"Speedup={results[n]['speedup']:.1f}x")
    
    return results


def kernel_analysis(D: np.ndarray, q: int) -> dict:
    """
    Analyze the kernel structure of a disagreement matrix D over F_q.
    
    Args:
        D: Square matrix with entries in {0, ..., q-1}.
        q: Prime modulus.
        
    Returns:
        Dictionary with kernel size, dimension, and sample vectors.
    """
    n = D.shape[0]
    total = q ** n
    
    kernel_vectors = []
    for idx in range(total):
        r = np.zeros(n, dtype=int)
        temp = idx
        for i in range(n):
            r[i] = temp % q
            temp //= q
        if np.array_equal((D @ r) % q, np.zeros(n, dtype=int)):
            kernel_vectors.append(r.copy())
    
    # Estimate dimension from log_q of kernel size
    import math
    kernel_size = len(kernel_vectors)
    dim_estimate = round(math.log(kernel_size) / math.log(q)) if kernel_size > 0 else 0
    
    return {
        'kernel_size': kernel_size,
        'total_space': total,
        'dimension_estimate': dim_estimate,
        'bound_q_n_minus_1': q ** (n - 1),
        'bound_holds': kernel_size <= q ** (n - 1),
        'sample_vectors': kernel_vectors[:5],
    }


# ============================================================
# Example usage
# ============================================================
if __name__ == "__main__":
    print("=" * 60)
    print("Freivalds' Algorithm: Implementation and Benchmarks")
    print("=" * 60)
    
    # Basic usage
    print("\n--- Basic Verification ---")
    q = 101
    n = 5
    verifier = FreivaldsVerifier(q)
    
    np.random.seed(42)
    A = np.random.randint(0, q, size=(n, n))
    B = np.random.randint(0, q, size=(n, n))
    C_correct = (A @ B) % q
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
    
    # Verify correct product
    accepted, error = verifier.verify(A, B, C_correct, num_rounds=5)
    print(f"Correct product: accepted={accepted}, error_bound={error:.2e}")
    
    # Verify incorrect product
    accepted, error = verifier.verify(A, B, C_wrong, num_rounds=5)
    print(f"Wrong product:   accepted={accepted}, error_bound={error:.2e}")
    
    # Adaptive verification
    print("\n--- Adaptive Verification ---")
    accepted, rounds, error = verifier.adaptive_verify(A, B, C_correct, target_error=1e-10)
    print(f"Target error 1e-10: rounds_needed={rounds}, accepted={accepted}, bound={error:.2e}")
    
    # Benchmarks
    print("\n--- Performance Benchmarks ---")
    sizes = [10, 50, 100, 200, 500]
    benchmark_freivalds_vs_direct(sizes, q=101)
    
    # Kernel analysis
    print("\n--- Kernel Analysis ---")
    q_small = 3
    n_small = 3
    D = np.array([[1, 0, 0], [0, 0, 0], [0, 0, 0]])  # Rank 1
    result = kernel_analysis(D, q_small)
    print(f"Rank-1 matrix over F_{q_small}^{n_small}:")
    print(f"  Kernel size: {result['kernel_size']}")
    print(f"  Bound q^(n-1) = {result['bound_q_n_minus_1']}")
    print(f"  Bound holds: {result['bound_holds']}")
    print(f"  Estimated dimension: {result['dimension_estimate']}")
