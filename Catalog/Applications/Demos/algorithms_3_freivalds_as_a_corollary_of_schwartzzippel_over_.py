#!/usr/bin/env python3
"""
Algorithms for Freivalds' Verification and Schwartz–Zippel Zero Testing

Implements the key algorithms from the research paper with full
docstrings, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
import time


def freivalds_verify(
    A: np.ndarray, B: np.ndarray, C: np.ndarray,
    q: int, k: int = 1, seed: Optional[int] = None
) -> Tuple[bool, float]:
    """
    Freivalds' randomized matrix product verification.

    Checks whether A * B ≡ C (mod q) with one-sided error probability
    at most (1/q)^k.

    Algorithm:
        For each of k rounds:
            1. Sample r uniformly from (Z/qZ)^n
            2. Compute v = B*r mod q  (O(n²) operations)
            3. Compute u = A*v mod q  (O(n²) operations)
            4. Compute w = C*r mod q  (O(n²) operations)
            5. If u ≠ w, return (False, 0.0)
        Return (True, (1/q)^k)

    Args:
        A: m×n matrix (integer entries)
        B: n×p matrix (integer entries)
        C: m×p matrix (integer entries, claimed to equal A*B mod q)
        q: prime modulus
        k: number of independent repetitions (default 1)
        seed: random seed for reproducibility

    Returns:
        (accept, error_bound): accept is True if all checks pass,
        error_bound is the worst-case error probability (1/q)^k

    Complexity:
        Time: O(k * n * p) where n, p are matrix dimensions
        Space: O(max(n, p)) for the random vector
        Probability of false accept: ≤ (1/q)^k when A*B ≠ C (mod q)
        Probability of false reject: 0 (one-sided error)
    """
    rng = np.random.default_rng(seed)
    m, n = A.shape
    n2, p = B.shape
    assert n == n2, f"Dimension mismatch: A is {A.shape}, B is {B.shape}"
    assert C.shape == (m, p), f"C should be {(m,p)}, got {C.shape}"

    for _ in range(k):
        r = rng.integers(0, q, size=p)
        Br = B @ r % q
        ABr = A @ Br % q
        Cr = C @ r % q
        if not np.array_equal(ABr, Cr):
            return (False, 0.0)

    return (True, (1.0 / q) ** k)


def schwartz_zippel_test(
    eval_poly, n_vars: int, degree: int, q: int,
    k: int = 1, seed: Optional[int] = None
) -> Tuple[bool, float]:
    """
    Schwartz–Zippel polynomial identity test.

    Tests whether a multivariate polynomial P is identically zero
    over Z/qZ by evaluating at random points.

    Algorithm:
        For each of k rounds:
            1. Sample x uniformly from (Z/qZ)^n_vars
            2. Evaluate P(x)
            3. If P(x) ≠ 0, return (False, 0.0) — P is nonzero
        Return (True, (degree/q)^k) — P might be zero

    Args:
        eval_poly: callable that takes a list of n_vars integers and
                   returns the polynomial value mod q
        n_vars: number of variables
        degree: total degree of the polynomial
        q: prime modulus (field size)
        k: number of independent repetitions
        seed: random seed

    Returns:
        (is_zero, error_bound): is_zero is True if all evaluations
        were zero, error_bound is (degree/q)^k

    Complexity:
        Time: O(k * T_eval) where T_eval is the evaluation time
        Space: O(n_vars)
        False positive rate: ≤ (degree/q)^k
        False negative rate: 0
    """
    rng = np.random.default_rng(seed)

    for _ in range(k):
        x = rng.integers(0, q, size=n_vars).tolist()
        if eval_poly(x) % q != 0:
            return (False, 0.0)

    return (True, (degree / q) ** k)


def linear_form_zero_count(w: List[int], q: int) -> int:
    """
    Exactly count the zeros of a linear form over Z/qZ.

    For w = (w_1, ..., w_p), counts |{r ∈ (Z/qZ)^p : Σ w_j r_j ≡ 0}|.

    By the degree-1 Schwartz–Zippel bound, this is at most q^(p-1)
    when w ≠ 0.

    Args:
        w: coefficient vector (nonzero)
        q: prime modulus

    Returns:
        Number of zero vectors

    Complexity:
        Time: O(q^p) — exhaustive enumeration
        Space: O(p)
    """
    p = len(w)
    count = 0
    for code in range(q ** p):
        r = [(code // (q ** j)) % q for j in range(p)]
        if sum(w[j] * r[j] for j in range(p)) % q == 0:
            count += 1
    return count


def kernel_size(M: np.ndarray, q: int) -> int:
    """
    Exactly count the size of the kernel of M over Z/qZ.

    Computes |{r ∈ (Z/qZ)^p : M·r ≡ 0 (mod q)}|.

    By Freivalds–Schwartz–Zippel, this is at most q^(p-1)
    when M ≠ 0.

    Args:
        M: m×p matrix with integer entries
        q: prime modulus

    Returns:
        Kernel size

    Complexity:
        Time: O(m * p * q^p)
        Space: O(p)
    """
    m, p = M.shape
    count = 0
    for code in range(q ** p):
        r = np.array([(code // (q ** j)) % q for j in range(p)])
        if np.all((M @ r) % q == 0):
            count += 1
    return count


def benchmark_freivalds(
    sizes: List[int], q: int = 7, k: int = 3,
    seed: int = 42
) -> List[dict]:
    """
    Benchmark Freivalds' algorithm across different matrix sizes.

    Args:
        sizes: list of matrix dimensions to test
        q: prime modulus
        k: number of repetitions per check
        seed: random seed

    Returns:
        List of benchmark results with timing information
    """
    results = []
    rng = np.random.default_rng(seed)

    for n in sizes:
        A = rng.integers(0, q, (n, n))
        B = rng.integers(0, q, (n, n))
        AB = (A @ B) % q

        # Correct case
        start = time.perf_counter()
        accept, _ = freivalds_verify(A, B, AB, q, k=k, seed=seed)
        t_correct = time.perf_counter() - start

        # Incorrect case
        C = AB.copy()
        C[0, 0] = (C[0, 0] + 1) % q
        start = time.perf_counter()
        reject, error = freivalds_verify(A, B, C, q, k=k, seed=seed)
        t_wrong = time.perf_counter() - start

        # Naive verification
        start = time.perf_counter()
        naive_result = np.array_equal((A @ B) % q, AB)
        t_naive = time.perf_counter() - start

        results.append({
            'n': n,
            'freivalds_time_correct': t_correct,
            'freivalds_time_wrong': t_wrong,
            'naive_time': t_naive,
            'speedup': t_naive / max(t_correct, 1e-10),
            'correct_accepted': accept,
            'wrong_rejected': not reject,
            'error_bound': error,
        })

    return results


if __name__ == "__main__":
    print("Freivalds Algorithm Benchmarks")
    print("=" * 60)

    sizes = [10, 50, 100, 200, 500]
    results = benchmark_freivalds(sizes)

    print(f"{'n':>6} | {'Freivalds (ms)':>14} | {'Naive (ms)':>10} | "
          f"{'Speedup':>8} | {'Correct':>7}")
    print("-" * 60)
    for r in results:
        print(f"{r['n']:>6} | {r['freivalds_time_correct']*1000:>14.3f} | "
              f"{r['naive_time']*1000:>10.3f} | "
              f"{r['speedup']:>8.1f}x | "
              f"{'✓' if r['correct_accepted'] and r['wrong_rejected'] else '✗':>7}")
