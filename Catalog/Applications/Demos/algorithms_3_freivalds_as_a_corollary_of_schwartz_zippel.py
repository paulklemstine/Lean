#!/usr/bin/env python3
"""
Algorithms: Schwartz–Zippel PIT and Freivalds' Verification

Implementations of the core algorithms with full documentation,
type hints, complexity analysis, and example usage.
"""

import random
import numpy as np
from typing import Dict, Tuple, List, Optional


# =============================================================================
# Core Finite Field Arithmetic
# =============================================================================

class FiniteField:
    """
    Arithmetic in Z/qZ for prime q.
    
    This is a minimal implementation for demonstration purposes.
    For production use, consider galois or sympy.
    """
    
    def __init__(self, q: int):
        """Initialize with prime modulus q."""
        if q < 2:
            raise ValueError(f"Modulus must be ≥ 2, got {q}")
        self.q = q
    
    def add(self, a: int, b: int) -> int:
        return (a + b) % self.q
    
    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.q
    
    def neg(self, a: int) -> int:
        return (-a) % self.q
    
    def inv(self, a: int) -> int:
        """Multiplicative inverse via extended Euclidean algorithm."""
        if a % self.q == 0:
            raise ZeroDivisionError("Cannot invert zero")
        return pow(a, self.q - 2, self.q)
    
    def random_element(self) -> int:
        return random.randint(0, self.q - 1)
    
    def random_vector(self, n: int) -> List[int]:
        return [self.random_element() for _ in range(n)]
    
    def random_matrix(self, m: int, n: int) -> np.ndarray:
        return np.array([[self.random_element() for _ in range(n)] for _ in range(m)])
    
    def mat_mul(self, A: np.ndarray, B: np.ndarray) -> np.ndarray:
        """Matrix multiplication mod q."""
        return np.mod(A @ B, self.q)
    
    def mat_vec(self, M: np.ndarray, v: np.ndarray) -> np.ndarray:
        """Matrix-vector multiplication mod q."""
        return np.mod(M @ v, self.q)


# =============================================================================
# Multivariate Polynomial
# =============================================================================

class MvPolynomial:
    """
    Sparse multivariate polynomial over Z/qZ.
    
    Represented as a dictionary: exponent tuple → coefficient.
    Example: x²y + 3z is {(2,1,0): 1, (0,0,1): 3}
    """
    
    def __init__(self, coeffs: Dict[Tuple[int, ...], int], q: int):
        """
        Args:
            coeffs: Map from exponent tuples to coefficients (mod q).
            q: Prime modulus.
        """
        self.q = q
        self.coeffs: Dict[Tuple[int, ...], int] = {}
        for exp, coeff in coeffs.items():
            c = coeff % q
            if c != 0:
                self.coeffs[exp] = c
    
    @property
    def n_vars(self) -> int:
        """Number of variables."""
        if not self.coeffs:
            return 0
        return len(next(iter(self.coeffs.keys())))
    
    @property
    def total_degree(self) -> int:
        """Maximum sum of exponents over all monomials."""
        if not self.coeffs:
            return -1  # Convention: zero polynomial has degree -∞
        return max(sum(exp) for exp in self.coeffs.keys())
    
    @property
    def is_zero(self) -> bool:
        return len(self.coeffs) == 0
    
    def eval(self, point: Tuple[int, ...]) -> int:
        """
        Evaluate the polynomial at a point in (Z/qZ)^n.
        
        Time: O(s · n) where s = number of monomials, n = number of variables.
        """
        result = 0
        for exp, coeff in self.coeffs.items():
            term = coeff
            for i, e in enumerate(exp):
                term = (term * pow(int(point[i]), int(e), self.q)) % self.q
            result = (result + term) % self.q
        return result
    
    def __repr__(self) -> str:
        if self.is_zero:
            return "0"
        terms = []
        for exp, coeff in sorted(self.coeffs.items(), key=lambda x: (-sum(x[0]), x[0])):
            parts = [f"x{i}^{e}" if e > 1 else f"x{i}" for i, e in enumerate(exp) if e > 0]
            if parts:
                term = f"{coeff}·{'·'.join(parts)}" if coeff != 1 else '·'.join(parts)
            else:
                term = str(coeff)
            terms.append(term)
        return " + ".join(terms)


# =============================================================================
# Algorithm 1: Schwartz–Zippel PIT
# =============================================================================

def schwartz_zippel_pit(
    poly: MvPolynomial,
    num_trials: int = 1,
    verbose: bool = False
) -> bool:
    """
    Schwartz–Zippel Polynomial Identity Test.
    
    Tests whether a multivariate polynomial over Z/qZ is identically zero
    by evaluating at random points.
    
    Args:
        poly: The polynomial to test.
        num_trials: Number of independent random evaluations (k).
        verbose: Print evaluation details.
    
    Returns:
        True if the polynomial appears to be zero (might be wrong).
        False if a nonzero evaluation was found (definitely nonzero).
    
    Error Bound:
        If poly ≠ 0, Pr[returns True] ≤ (deg(poly) / q)^k
        where q is the field size and k = num_trials.
    
    Complexity:
        Time: O(k · s · n) where s = #monomials, n = #variables.
        Space: O(n) for the random point.
    
    Example:
        >>> f = MvPolynomial({(2,0): 1, (0,2): 1, (1,1): 5}, q=7)  # x²+y²+5xy over Z/7Z
        >>> schwartz_zippel_pit(f, num_trials=10)
        False  # f is nonzero, detected with high probability
    """
    q = poly.q
    n = poly.n_vars
    
    if poly.is_zero:
        return True  # Trivially zero
    
    field = FiniteField(q)
    
    for trial in range(num_trials):
        point = tuple(field.random_vector(n))
        value = poly.eval(point)
        
        if verbose:
            print(f"  Trial {trial+1}: f{point} = {value}")
        
        if value != 0:
            return False  # Definitely nonzero
    
    return True  # Likely zero (or unlucky)


# =============================================================================
# Algorithm 2: Freivalds' Algorithm
# =============================================================================

def freivalds_verify(
    A: np.ndarray,
    B: np.ndarray,
    C: np.ndarray,
    q: int,
    num_trials: int = 1,
    verbose: bool = False
) -> bool:
    """
    Freivalds' Randomized Matrix Multiplication Verification.
    
    Tests whether A·B ≡ C (mod q) by random vector sampling.
    
    Args:
        A: m×p matrix over Z/qZ.
        B: p×n matrix over Z/qZ.
        C: m×n matrix over Z/qZ (claimed product).
        q: Prime modulus.
        num_trials: Number of independent random tests (k).
        verbose: Print test details.
    
    Returns:
        True if all tests pass (A·B might equal C).
        False if any test fails (definitely A·B ≠ C).
    
    Error Bound:
        If A·B ≠ C, Pr[returns True] ≤ (1/q)^k.
        This follows from the degree-1 Schwartz–Zippel bound:
        the discrepancy D = AB - C has a nonzero row defining
        a degree-1 polynomial that vanishes on ≤ q^{n-1} of q^n inputs.
    
    Complexity:
        Time: O(k · (mp + mn)) = O(k · n · (m+p)) for each trial.
              Two matrix-vector products: B·r (p×n · n) and A·(Br) (m×p · p).
        Space: O(max(m,n,p)) for the random vector and intermediate products.
    
    Comparison with naive:
        Naive verification: compute A·B explicitly → O(m·n·p) or O(n^ω).
        Freivalds with k trials: O(k·n²) for square n×n matrices.
        Speedup: factor of n/k (or n^{ω-2}/k with fast multiplication).
    
    Example:
        >>> A = np.array([[1, 2], [3, 4]])
        >>> B = np.array([[5, 6], [7, 8]])
        >>> C = np.mod(A @ B, 11)
        >>> freivalds_verify(A, B, C, q=11, num_trials=5)
        True
    """
    field = FiniteField(q)
    n = B.shape[1]  # Number of columns of B (and C)
    
    for trial in range(num_trials):
        r = np.array(field.random_vector(n))
        
        # Compute A·(B·r) mod q  — O(pn + mp) operations
        Br = field.mat_vec(B, r)
        ABr = field.mat_vec(A, Br)
        
        # Compute C·r mod q — O(mn) operations
        Cr = field.mat_vec(C, r)
        
        if verbose:
            print(f"  Trial {trial+1}: r = {r}")
            print(f"    A·(B·r) = {ABr}")
            print(f"    C·r     = {Cr}")
            print(f"    Match: {np.array_equal(ABr, Cr)}")
        
        if not np.array_equal(ABr, Cr):
            return False  # Definitely AB ≠ C
    
    return True  # Likely AB = C


# =============================================================================
# Algorithm 3: Polynomial Fingerprinting
# =============================================================================

def polynomial_fingerprint(
    data: List[int],
    q: int,
    eval_point: Optional[int] = None
) -> int:
    """
    Polynomial fingerprinting: hash a data vector to a single field element.
    
    Encodes data = [a₀, a₁, ..., aₙ₋₁] as the polynomial
    p(x) = a₀ + a₁·x + a₂·x² + ... + aₙ₋₁·x^{n-1}
    and evaluates at a random (or specified) point r ∈ Z/qZ.
    
    By Schwartz–Zippel (degree n-1, 1 variable):
    if data₁ ≠ data₂, then Pr[fingerprint₁ = fingerprint₂] ≤ (n-1)/q.
    
    Args:
        data: List of integers (coefficients mod q).
        q: Prime modulus.
        eval_point: Evaluation point (random if None).
    
    Returns:
        The fingerprint p(r) mod q.
    
    Complexity:
        Time: O(n) using Horner's method.
        Space: O(1) beyond input.
    """
    if eval_point is None:
        eval_point = random.randint(0, q - 1)
    
    # Horner's method: p(r) = a₀ + r·(a₁ + r·(a₂ + ... ))
    result = 0
    for coeff in reversed(data):
        result = (result * eval_point + coeff) % q
    
    return result


def fingerprint_equality_test(
    data1: List[int],
    data2: List[int],
    q: int,
    num_trials: int = 1
) -> bool:
    """
    Test equality of two data vectors using polynomial fingerprinting.
    
    Args:
        data1, data2: Data vectors to compare.
        q: Prime modulus (should be >> len(data)).
        num_trials: Number of independent tests.
    
    Returns:
        True if fingerprints match (might be wrong if data1 ≠ data2).
        False if fingerprints differ (definitely data1 ≠ data2).
    
    Error: Pr[false positive] ≤ ((n-1)/q)^k where n = max(len(data1), len(data2)).
    """
    for _ in range(num_trials):
        r = random.randint(0, q - 1)
        fp1 = polynomial_fingerprint(data1, q, r)
        fp2 = polynomial_fingerprint(data2, q, r)
        if fp1 != fp2:
            return False
    return True


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    print("=" * 60)
    print("Algorithm Demonstrations")
    print("=" * 60)
    
    # --- Schwartz–Zippel PIT ---
    print("\n--- Schwartz–Zippel PIT ---")
    
    # Nonzero polynomial: x² + y² + 5xy over Z/7Z
    f_nonzero = MvPolynomial({(2, 0): 1, (0, 2): 1, (1, 1): 5}, q=7)
    print(f"f = {f_nonzero}, degree = {f_nonzero.total_degree}")
    result = schwartz_zippel_pit(f_nonzero, num_trials=5, verbose=True)
    print(f"PIT result: {'possibly zero' if result else 'definitely nonzero'}")
    
    # Zero polynomial (disguised): (x+y)² - x² - 2xy - y² = 0 over Z/7Z
    f_zero = MvPolynomial({(2, 0): 0, (0, 2): 0, (1, 1): 0}, q=7)
    print(f"\ng = {f_zero} (zero polynomial)")
    result = schwartz_zippel_pit(f_zero, num_trials=5, verbose=True)
    print(f"PIT result: {'possibly zero' if result else 'definitely nonzero'}")
    
    # --- Freivalds ---
    print("\n--- Freivalds' Algorithm ---")
    
    q = 11
    n = 3
    field = FiniteField(q)
    A = field.random_matrix(n, n)
    B = field.random_matrix(n, n)
    C_correct = field.mat_mul(A, B)
    C_wrong = C_correct.copy()
    C_wrong[1, 1] = (C_wrong[1, 1] + 1) % q
    
    print(f"\nCorrect product test:")
    result = freivalds_verify(A, B, C_correct, q, num_trials=3, verbose=True)
    print(f"Result: {'PASS' if result else 'FAIL'}")
    
    print(f"\nWrong product test:")
    result = freivalds_verify(A, B, C_wrong, q, num_trials=3, verbose=True)
    print(f"Result: {'PASS (false accept!)' if result else 'FAIL (error detected)'}")
    
    # --- Fingerprinting ---
    print("\n--- Polynomial Fingerprinting ---")
    
    q = 101
    data1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    data2 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    data3 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 11]  # Last element different
    
    print(f"data1 = {data1}")
    print(f"data2 = {data2}")
    print(f"data3 = {data3}")
    
    print(f"\ndata1 == data2? {fingerprint_equality_test(data1, data2, q, num_trials=5)}")
    print(f"data1 == data3? {fingerprint_equality_test(data1, data3, q, num_trials=5)}")
    print(f"Error bound per trial: {(len(data1)-1)/q:.4f}")
