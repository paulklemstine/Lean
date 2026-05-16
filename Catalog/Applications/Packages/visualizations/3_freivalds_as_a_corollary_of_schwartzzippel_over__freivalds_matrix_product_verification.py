#!/usr/bin/env python3
"""
Algorithms for Freivalds' Verification and Schwartz–Zippel Testing

Implements the core algorithms discussed in the research paper with
full documentation, type hints, and complexity analysis.
"""

import numpy as np
from typing import List, Tuple, Optional
import random


def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    C: np.ndarray,
    q: int,
    repetitions: int = 1
) -> bool:
    """
    Freivalds' randomized matrix product verification.
    
    Tests whether A * B = C over F_q using random vector multiplication.
    
    Args:
        A: m × n matrix (entries in {0, ..., q-1})
        B: n × p matrix (entries in {0, ..., q-1})
        C: m × p matrix (entries in {0, ..., q-1})
        q: Prime field size
        repetitions: Number of independent tests (k)
    
    Returns:
        True if all tests pass (A*B likely equals C),
        False if any test fails (A*B definitely ≠ C)
    
    Complexity:
        Time: O(k * (np + mn + mp)) field operations
        Space: O(max(m, n, p))
    
    Soundness:
        If A*B ≠ C: Pr[return True] ≤ (1/q)^k
        If A*B = C: Pr[return True] = 1 (always correct)
    
    Example:
        >>> A = np.array([[1, 2], [3, 4]])
        >>> B = np.array([[5, 6], [7, 8]])
        >>> C = np.array([[19, 22], [43, 50]])  # = A*B mod large prime
        >>> freivalds_verify(A, B, C, 101)
        True
    """
    m, n = A.shape
    _, p = B.shape
    
    for _ in range(repetitions):
        # Sample random vector r from F_q^p
        r = np.array([random.randint(0, q - 1) for _ in range(p)])
        
        # Compute B*r mod q
        Br = np.zeros(n, dtype=int)
        for i in range(n):
            Br[i] = sum(int(B[i][j]) * int(r[j]) for j in range(p)) % q
        
        # Compute A*(B*r) mod q
        ABr = np.zeros(m, dtype=int)
        for i in range(m):
            ABr[i] = sum(int(A[i][j]) * int(Br[j]) for j in range(n)) % q
        
        # Compute C*r mod q
        Cr = np.zeros(m, dtype=int)
        for i in range(m):
            Cr[i] = sum(int(C[i][j]) * int(r[j]) for j in range(p)) % q
        
        # Compare
        if not np.array_equal(ABr, Cr):
            return False  # Definite rejection
    
    return True  # All tests passed


def count_linear_form_solutions(
    w: List[int],
    q: int,
    b: int = 0
) -> int:
    """
    Count solutions to the linear form w·r = b over F_q.
    
    Enumerates all r ∈ F_q^p and counts those satisfying
    ∑_j w_j * r_j ≡ b (mod q).
    
    Args:
        w: Coefficient vector of length p
        q: Prime field size
        b: Right-hand side (default 0)
    
    Returns:
        Number of solutions
    
    Complexity:
        Time: O(p * q^p) — exhaustive enumeration
        Space: O(p)
    
    Note: Only practical for small q and p. For large instances,
    the answer is known analytically: exactly q^(p-1) when w ≠ 0.
    
    Example:
        >>> count_linear_form_solutions([1, 1], 3)
        3
        >>> count_linear_form_solutions([1, 2, 3], 5)
        25
    """
    from itertools import product as cartesian
    
    p = len(w)
    count = 0
    for r in cartesian(range(q), repeat=p):
        dot = sum(w[j] * r[j] for j in range(p)) % q
        if dot == b % q:
            count += 1
    return count


def schwartz_zippel_test(
    eval_poly,
    q: int,
    num_vars: int,
    repetitions: int = 1
) -> bool:
    """
    Schwartz–Zippel polynomial identity test.
    
    Tests whether a multivariate polynomial is identically zero
    by evaluating at random points.
    
    Args:
        eval_poly: Function that evaluates the polynomial at a point
                   (takes a list of length num_vars, returns int mod q)
        q: Prime field size
        num_vars: Number of variables
        repetitions: Number of independent random evaluations
    
    Returns:
        True if all evaluations are zero (polynomial is likely zero),
        False if any evaluation is nonzero (polynomial is definitely nonzero)
    
    Soundness:
        If P ≠ 0 and deg(P) = d: Pr[return True] ≤ (d/q)^k
    
    Example:
        >>> # Test if x^2 + y^2 - 1 is identically zero (it's not)
        >>> f = lambda pt: (pt[0]**2 + pt[1]**2 - 1) % 7
        >>> schwartz_zippel_test(f, 7, 2, repetitions=10)
        False
    """
    for _ in range(repetitions):
        point = [random.randint(0, q - 1) for _ in range(num_vars)]
        if eval_poly(point) % q != 0:
            return False
    return True


def kernel_size_upper_bound(q: int, p: int) -> int:
    """
    Compute the Schwartz–Zippel/Freivalds upper bound on kernel size.
    
    For a nonzero m × p matrix over F_q, the kernel has at most
    q^(p-1) elements.
    
    Args:
        q: Prime field size
        p: Number of columns
    
    Returns:
        q^(p-1), the upper bound on kernel cardinality
    
    Example:
        >>> kernel_size_upper_bound(5, 3)
        25
    """
    return q ** (p - 1)


def error_probability_bound(q: int, repetitions: int = 1) -> float:
    """
    Compute the Freivalds error probability bound.
    
    After k independent tests over F_q, the probability of
    false acceptance is at most (1/q)^k.
    
    Args:
        q: Prime field size
        repetitions: Number of independent tests
    
    Returns:
        Upper bound on false acceptance probability
    
    Example:
        >>> error_probability_bound(5, 3)
        0.008
    """
    return (1.0 / q) ** repetitions


def find_nonzero_row(M: np.ndarray, q: int) -> Optional[int]:
    """
    Find a nonzero row in a matrix over F_q.
    
    Args:
        M: m × p matrix with entries in {0, ..., q-1}
        q: Prime field size
    
    Returns:
        Index of first nonzero row, or None if M = 0
    
    Example:
        >>> M = np.array([[0, 0], [1, 2], [0, 0]])
        >>> find_nonzero_row(M, 5)
        1
    """
    m = M.shape[0]
    for i in range(m):
        if any(M[i][j] % q != 0 for j in range(M.shape[1])):
            return i
    return None


def demonstrate_kernel_bound():
    """
    Demonstrate the kernel size bound with concrete examples.
    """
    print("Kernel Size Bound Demonstration")
    print("=" * 50)
    
    from itertools import product as cartesian
    
    test_cases = [
        (2, np.array([[1, 0, 1], [0, 1, 1]])),
        (3, np.array([[1, 2], [2, 1]])),
        (5, np.array([[1, 0], [0, 1], [1, 1]])),
    ]
    
    for q, M in test_cases:
        m, p = M.shape
        M_mod = M % q
        
        # Count kernel elements
        kernel_size = 0
        for r in cartesian(range(q), repeat=p):
            r_arr = np.array(r)
            result = np.array([
                sum(int(M_mod[i][j]) * int(r_arr[j]) for j in range(p)) % q
                for i in range(m)
            ])
            if all(result[i] == 0 for i in range(m)):
                kernel_size += 1
        
        bound = kernel_size_upper_bound(q, p)
        row_idx = find_nonzero_row(M_mod, q)
        
        print(f"\nM = {M_mod.tolist()} over F_{q}")
        print(f"  Size: {m}×{p}")
        print(f"  Nonzero row index: {row_idx}")
        print(f"  Kernel size: {kernel_size}")
        print(f"  Bound q^(p-1): {bound}")
        print(f"  Satisfies bound: {kernel_size <= bound}")


if __name__ == "__main__":
    demonstrate_kernel_bound()
    
    print("\n" + "=" * 50)
    print("Freivalds Verification Example")
    print("=" * 50)
    
    q = 7
    A = np.array([[1, 2], [3, 4]]) % q
    B = np.array([[5, 6], [0, 1]]) % q
    
    # Compute correct product
    C_correct = np.zeros_like(A)
    for i in range(2):
        for j in range(2):
            C_correct[i][j] = sum(int(A[i][k]) * int(B[k][j]) for k in range(2)) % q
    
    C_wrong = C_correct.copy()
    C_wrong[0][0] = (C_wrong[0][0] + 1) % q
    
    print(f"\nA = {A.tolist()}")
    print(f"B = {B.tolist()}")
    print(f"C_correct = {C_correct.tolist()}")
    print(f"C_wrong = {C_wrong.tolist()}")
    
    # Run many trials
    n_trials = 1000
    correct_accepts = sum(freivalds_verify(A, B, C_correct, q) for _ in range(n_trials))
    wrong_accepts = sum(freivalds_verify(A, B, C_wrong, q) for _ in range(n_trials))
    
    print(f"\nWith correct product: {correct_accepts}/{n_trials} accepted")
    print(f"With wrong product: {wrong_accepts}/{n_trials} accepted")
    print(f"Error rate: {wrong_accepts/n_trials:.4f} (predicted: {1/q:.4f})")
    
    # Amplified
    print(f"\nAmplified (k=5):")
    wrong_accepts_amp = sum(
        freivalds_verify(A, B, C_wrong, q, repetitions=5)
        for _ in range(n_trials)
    )
    print(f"Error rate: {wrong_accepts_amp/n_trials:.6f} (predicted: {error_probability_bound(q, 5):.6f})")
