#!/usr/bin/env python3
"""
Algorithms: Schwartz-Zippel PIT and Freivalds' Verification

Complete implementations of the key algorithms with type hints,
docstrings, complexity analysis, and example usage.
"""

from typing import Dict, Tuple, List, Optional
import numpy as np
from functools import reduce


# ============================================================================
# Algorithm 1: Freivalds' Randomized Matrix Verification
# ============================================================================

class FreivaldsVerifier:
    """
    Freivalds' algorithm for randomized matrix multiplication verification.

    Given n×n matrices A, B, C over Z/pZ, tests whether A*B = C
    using O(n²) operations per trial instead of O(n^ω) for direct multiplication.

    Error guarantee: If A*B ≠ C, each independent trial detects the error
    with probability ≥ 1 - 1/p. After k trials, error probability ≤ (1/p)^k.

    Time complexity: O(k * n²) field operations
    Space complexity: O(n) for the random vector
    """

    def __init__(self, prime: int):
        """
        Args:
            prime: The prime modulus defining the field Z/pZ.
        """
        self.p = prime

    def verify(self, A: np.ndarray, B: np.ndarray, C: np.ndarray,
               num_trials: int = 1) -> bool:
        """
        Test whether A*B ≡ C (mod p).

        Args:
            A: n×n integer matrix
            B: n×n integer matrix
            C: n×n integer matrix (claimed product)
            num_trials: Number of independent random trials

        Returns:
            True if all trials pass (consistent with A*B = C).
            False if any trial detects an error (definitely A*B ≠ C).

        Complexity:
            Time: O(num_trials * n²)
            Space: O(n)
        """
        n = A.shape[0]
        assert A.shape == B.shape == C.shape == (n, n)

        for _ in range(num_trials):
            # Step 1: Generate random vector r ∈ (Z/pZ)^n
            r = np.random.randint(0, self.p, size=(n, 1))

            # Step 2: Compute B*r (O(n²))
            Br = B @ r % self.p

            # Step 3: Compute A*(B*r) (O(n²))
            ABr = A @ Br % self.p

            # Step 4: Compute C*r (O(n²))
            Cr = C @ r % self.p

            # Step 5: Compare
            if not np.array_equal(ABr % self.p, Cr % self.p):
                return False  # Definitely incorrect

        return True  # Probably correct

    def error_bound(self, num_trials: int = 1) -> float:
        """
        Upper bound on the probability of a false positive.

        Args:
            num_trials: Number of independent trials

        Returns:
            Upper bound (1/p)^num_trials on error probability.
        """
        return (1.0 / self.p) ** num_trials


# ============================================================================
# Algorithm 2: Schwartz-Zippel Polynomial Identity Testing
# ============================================================================

class SparsePolynomial:
    """
    A sparse multivariate polynomial over Z/pZ.

    Represented as a dictionary mapping exponent tuples to coefficients.
    E.g., 3*x0^2*x1 + 2*x0 is {(2,1): 3, (1,0): 2}.
    """

    def __init__(self, coeffs: Dict[Tuple[int, ...], int], num_vars: int, prime: int):
        """
        Args:
            coeffs: Mapping from exponent tuples to nonzero coefficients.
            num_vars: Number of variables.
            prime: Field characteristic.
        """
        self.coeffs = {k: v % prime for k, v in coeffs.items() if v % prime != 0}
        self.num_vars = num_vars
        self.p = prime

    def evaluate(self, point: Tuple[int, ...]) -> int:
        """
        Evaluate polynomial at a point over Z/pZ.

        Args:
            point: Tuple of field elements (x₀, x₁, ..., x_{n-1}).

        Returns:
            f(point) mod p.

        Complexity: O(|support| * n) field operations.
        """
        assert len(point) == self.num_vars
        result = 0
        for exps, coeff in self.coeffs.items():
            term = coeff
            for i, e in enumerate(exps):
                term = (term * pow(point[i], e, self.p)) % self.p
            result = (result + term) % self.p
        return result

    @property
    def total_degree(self) -> int:
        """Total degree of the polynomial."""
        if not self.coeffs:
            return -1  # Convention: zero polynomial has degree -1
        return max(sum(exps) for exps in self.coeffs.keys())

    @property
    def is_zero(self) -> bool:
        """Whether the polynomial is identically zero."""
        return len(self.coeffs) == 0

    def __add__(self, other: 'SparsePolynomial') -> 'SparsePolynomial':
        """Add two polynomials."""
        assert self.num_vars == other.num_vars and self.p == other.p
        result = dict(self.coeffs)
        for k, v in other.coeffs.items():
            result[k] = (result.get(k, 0) + v) % self.p
        return SparsePolynomial(result, self.num_vars, self.p)

    def __neg__(self) -> 'SparsePolynomial':
        """Negate a polynomial."""
        return SparsePolynomial(
            {k: (-v) % self.p for k, v in self.coeffs.items()},
            self.num_vars, self.p
        )

    def __sub__(self, other: 'SparsePolynomial') -> 'SparsePolynomial':
        """Subtract two polynomials."""
        return self + (-other)


class SchwartzZippelPIT:
    """
    Schwartz-Zippel Polynomial Identity Testing.

    Tests whether a polynomial f is identically zero by evaluating at random points.

    Soundness: If f ≠ 0 and deg(f) ≤ d, then
        Pr[f(r) = 0 for random r ∈ S^n] ≤ d / |S|

    Time complexity: O(T_eval) per trial, where T_eval is the evaluation cost.
    """

    def __init__(self, prime: int):
        """
        Args:
            prime: Characteristic of the field Z/pZ.
        """
        self.p = prime

    def test_identity(self, poly: SparsePolynomial,
                      num_trials: int = 10) -> Tuple[bool, Optional[Tuple[int, ...]]]:
        """
        Test whether a polynomial is identically zero.

        Args:
            poly: Polynomial to test.
            num_trials: Number of random evaluation points to try.

        Returns:
            (is_probably_zero, witness):
            - (True, None) if all evaluations returned 0.
            - (False, point) if a nonzero evaluation was found at `point`.

        Complexity: O(num_trials * |support| * n) field operations.
        """
        for _ in range(num_trials):
            point = tuple(int(x) for x in np.random.randint(0, self.p, size=poly.num_vars))
            val = poly.evaluate(point)
            if val != 0:
                return False, point
        return True, None

    def error_bound(self, degree: int, num_trials: int = 1) -> float:
        """
        Upper bound on false zero probability.

        Args:
            degree: Upper bound on total degree.
            num_trials: Number of independent trials.

        Returns:
            (degree/p)^num_trials upper bound on error.
        """
        return (degree / self.p) ** num_trials


# ============================================================================
# Algorithm 3: Polynomial Fingerprinting
# ============================================================================

class PolynomialFingerprint:
    """
    Polynomial fingerprinting for equality testing.

    Encodes a sequence (s₁, ..., s_n) as the polynomial
    f_s(X) = s₁ + s₂X + s₃X² + ... + s_nX^{n-1}

    Two distinct sequences s ≠ t have Pr[f_s(r) = f_t(r)] ≤ (n-1)/p
    for a random r ∈ Z/pZ.

    Space complexity: O(log p) bits (only need to store the fingerprint value).
    """

    def __init__(self, prime: int):
        self.p = prime
        self.r = np.random.randint(0, prime)

    def fingerprint(self, sequence: List[int]) -> int:
        """
        Compute the polynomial fingerprint of a sequence.

        Args:
            sequence: List of integers.

        Returns:
            f_s(r) mod p where r is the random evaluation point.

        Complexity: O(n) field operations (Horner's method).
        """
        # Horner's method: evaluate s₁ + s₂r + s₃r² + ... + s_nr^{n-1}
        result = 0
        for coeff in reversed(sequence):
            result = (result * self.r + coeff) % self.p
        return result

    def test_equality(self, seq1: List[int], seq2: List[int]) -> bool:
        """
        Test whether two sequences are equal using fingerprinting.

        Args:
            seq1, seq2: Sequences to compare.

        Returns:
            True if fingerprints match (probably equal).
            False if fingerprints differ (definitely not equal).
        """
        return self.fingerprint(seq1) == self.fingerprint(seq2)

    def error_bound(self, max_length: int) -> float:
        """
        Upper bound on false equality probability.

        Args:
            max_length: Maximum length of the sequences.

        Returns:
            (max_length - 1) / p upper bound on error.
        """
        return (max_length - 1) / self.p


# ============================================================================
# Example Usage
# ============================================================================

def example_freivalds():
    """Example: Verify matrix multiplication."""
    print("=" * 60)
    print("Example: Freivalds' Algorithm")
    print("=" * 60)

    n, p = 50, 101
    verifier = FreivaldsVerifier(prime=p)

    # Create matrices and correct product
    A = np.random.randint(0, p, (n, n))
    B = np.random.randint(0, p, (n, n))
    C_correct = A @ B % p

    # Test correct product
    result = verifier.verify(A, B, C_correct, num_trials=5)
    print(f"Correct product test: {'PASS' if result else 'FAIL'}")

    # Test incorrect product (single entry error)
    C_wrong = C_correct.copy()
    C_wrong[0, 0] = (C_wrong[0, 0] + 1) % p
    result = verifier.verify(A, B, C_wrong, num_trials=5)
    print(f"Incorrect product test: {'PASS (false positive!)' if result else 'FAIL (correctly detected)'}")
    print(f"Error bound for 5 trials: {verifier.error_bound(5):.2e}")
    print()


def example_schwartz_zippel():
    """Example: Polynomial identity testing."""
    print("=" * 60)
    print("Example: Schwartz-Zippel PIT")
    print("=" * 60)

    p = 97
    pit = SchwartzZippelPIT(prime=p)

    # Test a nonzero polynomial
    f = SparsePolynomial({(2, 0): 1, (0, 2): 1, (1, 1): 3}, num_vars=2, prime=p)
    is_zero, witness = pit.test_identity(f)
    print(f"f = x² + y² + 3xy: {'zero' if is_zero else f'nonzero (witness: {witness})'}")

    # Test the zero polynomial
    g = SparsePolynomial({}, num_vars=2, prime=p)
    is_zero, witness = pit.test_identity(g)
    print(f"g = 0: {'zero' if is_zero else f'nonzero (witness: {witness})'}")

    # Test f - f (should be zero)
    h = f - f
    is_zero, witness = pit.test_identity(h)
    print(f"f - f: {'zero' if is_zero else f'nonzero (witness: {witness})'}")
    print()


def example_fingerprinting():
    """Example: Polynomial fingerprinting for string comparison."""
    print("=" * 60)
    print("Example: Polynomial Fingerprinting")
    print("=" * 60)

    fp = PolynomialFingerprint(prime=10007)

    # Equal sequences
    s1 = list(range(1000))
    s2 = list(range(1000))
    print(f"Equal sequences (len=1000): match={fp.test_equality(s1, s2)}")

    # Different sequences
    s3 = list(range(1000))
    s3[500] = (s3[500] + 1)
    print(f"Different sequences: match={fp.test_equality(s1, s3)}")
    print(f"Error bound: {fp.error_bound(1000):.6f}")
    print()


if __name__ == "__main__":
    np.random.seed(42)
    example_freivalds()
    example_schwartz_zippel()
    example_fingerprinting()
