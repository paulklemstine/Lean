#!/usr/bin/env python3
"""
Algorithms from the Schwartz-Zippel / Freivalds formalization.

Implements:
1. Freivalds' randomized matrix verification algorithm
2. Polynomial identity testing (PIT) via random evaluation
3. Schwartz-Zippel zero-set estimation
"""

import numpy as np
from typing import Dict, Tuple, Optional, List
import time


class FreivaldsVerifier:
    """Freivalds' randomized matrix multiplication verifier.
    
    Given matrices A, B, C over Z/qZ, tests whether A·B = C
    with one-sided error probability ≤ (1/q)^k after k trials.
    
    Time complexity: O(k·n²) vs O(n³) for naive verification.
    Space complexity: O(n)
    
    Example:
        >>> verifier = FreivaldsVerifier(q=7)
        >>> A = np.array([[1, 2], [3, 4]])
        >>> B = np.array([[5, 6], [7, 8]])
        >>> C = (A @ B) % 7
        >>> verifier.verify(A, B, C, trials=10)
        True
    """
    
    def __init__(self, q: int):
        """Initialize with prime modulus q."""
        self.q = q
    
    def _single_test(self, A: np.ndarray, B: np.ndarray, C: np.ndarray) -> bool:
        """Run a single Freivalds test.
        
        Returns True if the test passes (consistent with A·B = C).
        Returns False if the test fails (proves A·B ≠ C).
        
        Args:
            A, B, C: n×n matrices over Z/qZ
        
        Returns:
            bool: True if test passes
        """
        n = A.shape[0]
        r = np.random.randint(0, self.q, n)
        
        # Compute B·r first (O(n²)), then A·(B·r) (O(n²))
        # Total: O(n²) instead of O(n³) for computing A·B directly
        Br = (B @ r) % self.q
        ABr = (A @ Br) % self.q
        Cr = (C @ r) % self.q
        
        return np.array_equal(ABr, Cr)
    
    def verify(self, A: np.ndarray, B: np.ndarray, C: np.ndarray, 
               trials: int = 20) -> bool:
        """Verify whether A·B = C (mod q) using k independent trials.
        
        If A·B = C, always returns True.
        If A·B ≠ C, returns True (false positive) with probability ≤ (1/q)^trials.
        
        Args:
            A, B, C: n×n integer matrices
            trials: number of independent random tests
        
        Returns:
            bool: True if all tests pass (probably correct)
        """
        for _ in range(trials):
            if not self._single_test(A, B, C):
                return False
        return True
    
    def error_bound(self, trials: int) -> float:
        """Compute the theoretical error bound for k trials."""
        return (1 / self.q) ** trials


class PolynomialIdentityTester:
    """Polynomial Identity Testing via random evaluation (Schwartz-Zippel).
    
    Tests whether a multivariate polynomial is identically zero
    by evaluating at random points over a finite field.
    
    Error probability ≤ d/q per evaluation, where d is the total degree.
    
    Example:
        >>> pit = PolynomialIdentityTester(q=101)
        >>> # f(x,y) = x² - y² - (x-y)(x+y) = 0
        >>> f = lambda x: (x[0]**2 - x[1]**2 - (x[0]-x[1])*(x[0]+x[1])) % 101
        >>> pit.test(f, n_vars=2, degree=2, trials=10)
        True  # Correctly identifies as zero
    """
    
    def __init__(self, q: int):
        """Initialize with prime modulus q."""
        self.q = q
    
    def test(self, f, n_vars: int, degree: int, trials: int = 20) -> bool:
        """Test if polynomial f is identically zero over Z/qZ.
        
        Args:
            f: callable taking a list/array of n_vars integers, returning int mod q
            n_vars: number of variables
            degree: total degree of the polynomial
            trials: number of random evaluations
        
        Returns:
            True if f appears to be identically zero (could be false positive)
            False if f is definitely nonzero (found a nonzero evaluation)
        """
        for _ in range(trials):
            point = np.random.randint(0, self.q, n_vars)
            if f(point) % self.q != 0:
                return False
        return True
    
    def error_bound(self, degree: int, trials: int) -> float:
        """Theoretical false-positive probability."""
        return (degree / self.q) ** trials


def schwartz_zippel_zero_fraction(
    coefficients: Dict[Tuple[int, ...], int],
    n_vars: int,
    q: int,
    samples: int = 10000
) -> float:
    """Estimate the fraction of zeros of a polynomial via sampling.
    
    Args:
        coefficients: dict mapping exponent tuples to coefficients
        n_vars: number of variables
        q: prime modulus
        samples: number of random samples
    
    Returns:
        Estimated fraction of points where polynomial vanishes
    """
    zeros = 0
    for _ in range(samples):
        point = tuple(np.random.randint(0, q) for _ in range(n_vars))
        val = 0
        for exponents, coeff in coefficients.items():
            term = coeff
            for i, exp in enumerate(exponents):
                term = (term * pow(int(point[i]), int(exp), q)) % q
            val = (val + term) % q
        if val == 0:
            zeros += 1
    return zeros / samples


def benchmark_freivalds_vs_naive(sizes: List[int], q: int = 101) -> Dict:
    """Compare Freivalds verification time vs naive matrix multiplication.
    
    Args:
        sizes: list of matrix sizes to test
        q: prime modulus
    
    Returns:
        dict with timing results
    """
    results = {"sizes": sizes, "naive_times": [], "freivalds_times": []}
    verifier = FreivaldsVerifier(q)
    
    for n in sizes:
        A = np.random.randint(0, q, (n, n))
        B = np.random.randint(0, q, (n, n))
        C = (A @ B) % q
        
        # Time naive verification
        start = time.time()
        for _ in range(10):
            _ = np.array_equal((A @ B) % q, C)
        naive_time = (time.time() - start) / 10
        
        # Time Freivalds (20 trials)
        start = time.time()
        for _ in range(10):
            verifier.verify(A, B, C, trials=20)
        freivalds_time = (time.time() - start) / 10
        
        results["naive_times"].append(naive_time)
        results["freivalds_times"].append(freivalds_time)
        print(f"  n={n:>4}: naive={naive_time:.4f}s, Freivalds={freivalds_time:.4f}s, "
              f"speedup={naive_time/max(freivalds_time, 1e-9):.1f}x")
    
    return results


if __name__ == "__main__":
    print("=" * 60)
    print("Freivalds' Algorithm Benchmark")
    print("=" * 60)
    print()
    
    # Demo Freivalds
    q = 101
    verifier = FreivaldsVerifier(q)
    
    n = 100
    A = np.random.randint(0, q, (n, n))
    B = np.random.randint(0, q, (n, n))
    C_correct = (A @ B) % q
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % q
    
    print(f"Matrix size: {n}×{n}, Field: F_{q}")
    print(f"Correct product: verify = {verifier.verify(A, B, C_correct)}")
    print(f"Wrong product:   verify = {verifier.verify(A, B, C_wrong)}")
    print(f"Error bound (20 trials): {verifier.error_bound(20):.2e}")
    print()
    
    print("Timing comparison:")
    benchmark_freivalds_vs_naive([50, 100, 200, 500], q=101)
    print()
    
    # Demo PIT
    print("=" * 60)
    print("Polynomial Identity Testing")
    print("=" * 60)
    print()
    
    pit = PolynomialIdentityTester(q=101)
    
    # Test: (x+y)² - x² - 2xy - y² = 0
    def zero_poly(x):
        return ((x[0] + x[1])**2 - x[0]**2 - 2*x[0]*x[1] - x[1]**2) % 101
    
    def nonzero_poly(x):
        return (x[0]**2 + x[1]**2 + 1) % 101
    
    print(f"Testing (x+y)² - x² - 2xy - y² = 0? {pit.test(zero_poly, 2, 2)}")
    print(f"Testing x² + y² + 1 = 0?            {pit.test(nonzero_poly, 2, 2)}")
