#!/usr/bin/env python3
"""
Algorithms for polynomial identity testing and matrix product verification.

Implements the algebraic verification algorithms whose soundness is
formally proved in the companion Lean 4 formalization.
"""

import random
from typing import List, Tuple, Optional
import numpy as np


# ============================================================
# Finite Field Arithmetic (Z/pZ for prime p)
# ============================================================

class FiniteFieldPoly:
    """Polynomial over Z/pZ.

    Coefficients are stored as a list where coeffs[i] is the
    coefficient of x^i. The list is normalized so that the leading
    coefficient is nonzero (except for the zero polynomial).

    Args:
        coeffs: List of integer coefficients.
        p: Prime modulus defining the field F_p.
    """

    def __init__(self, coeffs: List[int], p: int):
        self.p = p
        self.coeffs = [c % p for c in coeffs]
        # Normalize: remove trailing zeros
        while self.coeffs and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @property
    def degree(self) -> int:
        """Return the degree of the polynomial (-1 for zero polynomial)."""
        return len(self.coeffs) - 1

    @property
    def is_zero(self) -> bool:
        return len(self.coeffs) == 0

    def eval(self, x: int) -> int:
        """Evaluate the polynomial at x in F_p.

        Uses Horner's method for efficiency.

        Time complexity: O(deg(p))
        """
        if self.is_zero:
            return 0
        result = 0
        for c in reversed(self.coeffs):
            result = (result * x + c) % self.p
        return result

    def __sub__(self, other: 'FiniteFieldPoly') -> 'FiniteFieldPoly':
        n = max(len(self.coeffs), len(other.coeffs))
        result = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            result.append((a - b) % self.p)
        return FiniteFieldPoly(result, self.p)

    def count_roots(self) -> Tuple[int, List[int]]:
        """Count and enumerate all roots in F_p.

        Time complexity: O(p * deg(p))

        Returns:
            (count, roots) where roots is the list of roots.
        """
        roots = [x for x in range(self.p) if self.eval(x) == 0]
        return len(roots), roots

    def __repr__(self) -> str:
        if self.is_zero:
            return "0"
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}x" if c != 1 else "x")
            else:
                terms.append(f"{c}x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"


# ============================================================
# Algorithm 1: Schwartz-Zippel Polynomial Identity Test
# ============================================================

def schwartz_zippel_test(p: FiniteFieldPoly, q: FiniteFieldPoly,
                         num_tests: int = 1) -> Tuple[bool, List[int]]:
    """Schwartz-Zippel polynomial identity test.

    Tests whether p = q by evaluating at random points.

    Soundness guarantee (formally proved):
        If p ≠ q, each test detects the difference with probability
        ≥ 1 - max(deg(p), deg(q)) / |F|.

    Args:
        p: First polynomial over F_q.
        q: Second polynomial over F_q.
        num_tests: Number of independent random tests.

    Returns:
        (likely_equal, test_points) where likely_equal is True if all
        tests passed, and test_points are the random points used.

    Time complexity: O(num_tests * max(deg(p), deg(q)))
    Space complexity: O(num_tests)
    """
    field_size = p.p
    assert p.p == q.p, "Polynomials must be over the same field"

    test_points = []
    for _ in range(num_tests):
        a = random.randint(0, field_size - 1)
        test_points.append(a)
        if p.eval(a) != q.eval(a):
            return False, test_points

    return True, test_points


# ============================================================
# Algorithm 2: Freivalds' Matrix Product Verification
# ============================================================

def freivalds_verify(A: np.ndarray, B: np.ndarray, C: np.ndarray,
                     p: int, num_tests: int = 1) -> Tuple[bool, float]:
    """Freivalds' randomized matrix product verification.

    Tests whether A * B = C (mod p) using random vector projections.

    Soundness guarantee (formally proved):
        If A * B ≠ C, each test detects the error with probability
        ≥ 1 - 1/p. With t independent tests, the error probability
        is at most (1/p)^t.

    Args:
        A: m×n matrix with integer entries.
        B: n×k matrix with integer entries.
        C: m×k matrix with integer entries.
        p: Prime modulus defining the field.
        num_tests: Number of independent random tests.

    Returns:
        (likely_correct, error_bound) where likely_correct is True if
        all tests passed, and error_bound is the upper bound on
        false acceptance probability.

    Time complexity: O(num_tests * (m*n + n*k + m*k))
        — Compare to O(m*n*k) for naive matrix multiplication.
        — For square n×n matrices: O(num_tests * n²) vs O(n³).
    Space complexity: O(max(m, n, k))
    """
    _, k = B.shape

    for _ in range(num_tests):
        # Sample random vector r ∈ F_p^k
        r = np.array([random.randint(0, p - 1) for _ in range(k)])

        # Compute B*r first, then A*(B*r) — avoids computing A*B
        Br = B @ r % p
        ABr = A @ Br % p
        Cr = C @ r % p

        if not np.array_equal(ABr % p, Cr % p):
            return False, 0.0

    error_bound = (1.0 / p) ** num_tests
    return True, error_bound


# ============================================================
# Algorithm 3: Batched Polynomial Identity Testing
# ============================================================

def batched_pit(polynomials: List[Tuple[FiniteFieldPoly, FiniteFieldPoly]],
                num_tests: int = 1) -> List[Tuple[bool, int]]:
    """Batched polynomial identity testing for multiple pairs.

    Tests whether p_i = q_i for each pair (p_i, q_i), using a
    single random point per test round (amortized verification).

    The key insight: by evaluating all polynomials at the same random
    point, we can test multiple identities simultaneously.

    Args:
        polynomials: List of (p, q) pairs to test for equality.
        num_tests: Number of independent random evaluations.

    Returns:
        List of (likely_equal, disagreement_count) for each pair.

    Time complexity: O(num_tests * sum(deg(p_i) + deg(q_i)))
    """
    if not polynomials:
        return []

    field_size = polynomials[0][0].p
    results = [(True, 0)] * len(polynomials)

    for _ in range(num_tests):
        a = random.randint(0, field_size - 1)
        for i, (pi, qi) in enumerate(polynomials):
            if pi.eval(a) != qi.eval(a):
                equal, count = results[i]
                results[i] = (False, count + 1)

    return results


# ============================================================
# Algorithm 4: Streaming Matrix Product Verification
# ============================================================

class StreamingFreivalds:
    """Streaming verification of matrix product A * B = C.

    Processes rows of A and C in a streaming fashion while keeping
    B in memory. Useful when A and C are too large to store.

    Soundness: Same as standard Freivalds — error ≤ 1/p per test.

    Space complexity: O(n*k + k) where B is n×k.
    """

    def __init__(self, B: np.ndarray, p: int):
        """Initialize with matrix B and field modulus.

        Args:
            B: The n×k matrix (kept in memory).
            p: Prime field modulus.
        """
        self.B = B
        self.p = p
        self.n, self.k = B.shape
        # Pre-sample random vector
        self.r = np.array([random.randint(0, p - 1) for _ in range(self.k)])
        # Pre-compute B*r
        self.Br = B @ self.r % p
        self.row_index = 0
        self.passed = True

    def process_row(self, a_row: np.ndarray, c_row: np.ndarray) -> bool:
        """Process one row of A and the corresponding row of C.

        Args:
            a_row: Row i of matrix A (length n).
            c_row: Row i of matrix C (length k).

        Returns:
            True if this row is consistent, False otherwise.
        """
        # (A*B*r)[i] = a_row · (B*r)
        abr_i = int(np.dot(a_row, self.Br)) % self.p
        # (C*r)[i] = c_row · r
        cr_i = int(np.dot(c_row, self.r)) % self.p

        if abr_i != cr_i:
            self.passed = False
            return False

        self.row_index += 1
        return True

    @property
    def result(self) -> Tuple[bool, float]:
        """Return (likely_correct, error_bound)."""
        return self.passed, 1.0 / self.p


if __name__ == "__main__":
    random.seed(42)
    np.random.seed(42)

    # Demo: Schwartz-Zippel
    print("=== Schwartz-Zippel PIT Demo ===")
    p1 = FiniteFieldPoly([1, 2, 3], 101)  # 1 + 2x + 3x^2
    p2 = FiniteFieldPoly([1, 2, 3], 101)  # same
    p3 = FiniteFieldPoly([1, 2, 4], 101)  # different

    result, points = schwartz_zippel_test(p1, p2, num_tests=10)
    print(f"p1 = p2? {result} (should be True)")

    result, points = schwartz_zippel_test(p1, p3, num_tests=10)
    print(f"p1 = p3? {result} (should be False)")

    # Demo: Freivalds
    print("\n=== Freivalds Demo ===")
    n = 100
    p = 101
    A = np.random.randint(0, p, (n, n))
    B = np.random.randint(0, p, (n, n))
    C = A @ B % p

    result, bound = freivalds_verify(A, B, C, p, num_tests=5)
    print(f"A*B = C? {result}, error_bound = {bound:.2e}")

    C_bad = C.copy()
    C_bad[0, 0] = (C_bad[0, 0] + 1) % p
    result, bound = freivalds_verify(A, B, C_bad, p, num_tests=5)
    print(f"A*B = C_bad? {result} (should be False)")

    # Demo: Streaming
    print("\n=== Streaming Freivalds Demo ===")
    verifier = StreamingFreivalds(B, p)
    for i in range(n):
        verifier.process_row(A[i], C[i])
    result, bound = verifier.result
    print(f"Streaming result: {result}, bound = {bound:.4f}")
