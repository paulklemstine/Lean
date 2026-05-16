#!/usr/bin/env python3
"""
Algorithms for the Finite-Field Polynomial Method.

Implements the core computational procedures underlying the evaluation-kernel
framework:
1. Evaluation matrix construction and rank computation over finite fields
2. Kernel extraction (finding vanishing polynomials)
3. Polynomial identity testing via Schwartz-Zippel
4. Reed-Muller encoding and minimum distance estimation

All arithmetic is performed modulo a prime p (working over F_p).
"""

from typing import List, Tuple, Dict, Optional
from itertools import product
import numpy as np


def mod_inv(a: int, p: int) -> int:
    """
    Compute the modular inverse of a mod p using Fermat's little theorem.

    Parameters
    ----------
    a : int
        Element to invert (must be nonzero mod p).
    p : int
        Prime modulus.

    Returns
    -------
    int
        The inverse a^{-1} mod p, or 0 if a ≡ 0 mod p.

    Complexity
    ----------
    Time: O(log p) via fast exponentiation.
    Space: O(1).

    Example
    -------
    >>> mod_inv(3, 7)
    5
    >>> (3 * 5) % 7
    1
    """
    a = int(a) % p
    if a == 0:
        return 0
    return pow(a, p - 2, p)


def gaussian_elimination_Fp(A: np.ndarray, p: int) -> Tuple[int, List[np.ndarray]]:
    """
    Gaussian elimination over F_p.

    Computes the rank and a basis for the (right) kernel of the matrix A
    over the finite field F_p.

    Parameters
    ----------
    A : np.ndarray
        An m × n integer matrix (entries will be reduced mod p).
    p : int
        Prime modulus.

    Returns
    -------
    rank : int
        The rank of A over F_p.
    kernel_basis : List[np.ndarray]
        A list of n-dimensional integer vectors forming a basis for ker(A).
        Each vector v satisfies A @ v ≡ 0 (mod p).

    Complexity
    ----------
    Time: O(m · n · min(m, n)) field operations.
    Space: O(m · n).

    Example
    -------
    >>> A = np.array([[1, 2, 3], [4, 5, 6]], dtype=int)
    >>> rank, ker = gaussian_elimination_Fp(A, 7)
    >>> rank
    2
    >>> len(ker)
    1
    """
    A = A.copy().astype(int) % p
    m, n = A.shape
    pivot_cols = []
    row = 0

    for col in range(n):
        pivot_row = None
        for r in range(row, m):
            if A[r, col] % p != 0:
                pivot_row = r
                break
        if pivot_row is None:
            continue

        A[[row, pivot_row]] = A[[pivot_row, row]]
        pivot_cols.append(col)

        inv = mod_inv(A[row, col], p)
        A[row] = (A[row] * inv) % p
        for r in range(m):
            if r != row and A[r, col] % p != 0:
                factor = A[r, col]
                A[r] = (A[r] - factor * A[row]) % p
        row += 1

    rank = len(pivot_cols)
    free_cols = [c for c in range(n) if c not in pivot_cols]
    kernel_basis = []

    for fc in free_cols:
        vec = np.zeros(n, dtype=int)
        vec[fc] = 1
        for i, pc in enumerate(pivot_cols):
            vec[pc] = (-A[i, fc]) % p
        kernel_basis.append(vec % p)

    return rank, kernel_basis


def enumerate_box_monomials(n: int, d: int) -> List[Tuple[int, ...]]:
    """
    Enumerate all monomials x^α with α_i < d for all i.

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Degree bound per variable.

    Returns
    -------
    List[Tuple[int, ...]]
        List of exponent tuples, each of length n, with entries in {0, ..., d-1}.
        The list has exactly d^n elements.

    Complexity
    ----------
    Time: O(d^n).
    Space: O(d^n).

    Example
    -------
    >>> enumerate_box_monomials(2, 2)
    [(0, 0), (0, 1), (1, 0), (1, 1)]
    """
    return list(product(range(d), repeat=n))


def build_evaluation_matrix(
    monomials: List[Tuple[int, ...]],
    points: List[Tuple[int, ...]],
    p: int
) -> np.ndarray:
    """
    Build the evaluation matrix for multivariate monomials on a point set.

    The matrix A has A[i, j] = monomial_j(point_i) mod p, where
    monomial_j(x) = x_0^{e_0} · x_1^{e_1} · ... · x_{n-1}^{e_{n-1}}.

    Parameters
    ----------
    monomials : List[Tuple[int, ...]]
        List of exponent tuples defining the monomials.
    points : List[Tuple[int, ...]]
        List of evaluation points in F_p^n.
    p : int
        Prime modulus.

    Returns
    -------
    np.ndarray
        An |points| × |monomials| integer matrix with entries in {0, ..., p-1}.

    Complexity
    ----------
    Time: O(|points| · |monomials| · n) where n = number of variables.
    Space: O(|points| · |monomials|).
    """
    m = len(points)
    k = len(monomials)
    A = np.zeros((m, k), dtype=int)
    for i, pt in enumerate(points):
        for j, mono in enumerate(monomials):
            val = 1
            for dim_idx, e in enumerate(mono):
                val = (val * pow(int(pt[dim_idx]), int(e), p)) % p
            A[i, j] = val
    return A


def find_vanishing_polynomial(
    n: int, d: int, points: List[Tuple[int, ...]], p: int
) -> Optional[Dict[Tuple[int, ...], int]]:
    """
    Find a nonzero polynomial of box-degree < d vanishing on all given points.

    Implements the core algorithm of the polynomial method:
    1. Enumerate box-degree monomials (dimension = d^n).
    2. Build the evaluation matrix.
    3. Compute the kernel via Gaussian elimination over F_p.
    4. Return a nonzero kernel vector as polynomial coefficients.

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Box degree bound (each variable's exponent < d).
    points : List[Tuple[int, ...]]
        Evaluation points in F_p^n.
    p : int
        Prime modulus.

    Returns
    -------
    Optional[Dict[Tuple[int, ...], int]]
        A dictionary mapping exponent tuples to nonzero coefficients,
        representing a polynomial vanishing on all points.
        Returns None if no such polynomial exists (|points| ≥ d^n).

    Complexity
    ----------
    Time: O(d^n · |points| · min(d^n, |points|)) for Gaussian elimination.
    Space: O(d^n · |points|).

    Example
    -------
    >>> poly = find_vanishing_polynomial(1, 3, [(1,), (2,)], 5)
    >>> poly is not None
    True
    """
    monomials = enumerate_box_monomials(n, d)
    if len(points) >= len(monomials):
        return None

    A = build_evaluation_matrix(monomials, points, p)
    rank, kernel = gaussian_elimination_Fp(A, p)

    if not kernel:
        return None

    vec = kernel[0]
    result = {}
    for j, mono in enumerate(monomials):
        if vec[j] != 0:
            result[mono] = int(vec[j])
    return result


def polynomial_identity_test_schwartz_zippel(
    poly_coeffs: Dict[Tuple[int, ...], int],
    n: int, p: int,
    num_tests: int = 100
) -> Tuple[bool, float]:
    """
    Randomized polynomial identity test using the Schwartz-Zippel approach.

    Tests whether a multivariate polynomial is identically zero by
    evaluating at random points. If the polynomial is nonzero of degree d,
    the probability of a false zero is at most d/p per test.

    Parameters
    ----------
    poly_coeffs : Dict[Tuple[int, ...], int]
        Polynomial as {exponent_tuple: coefficient}.
    n : int
        Number of variables.
    p : int
        Prime modulus (field size).
    num_tests : int
        Number of random evaluation points to test.

    Returns
    -------
    likely_zero : bool
        True if all tests returned zero (polynomial likely identically zero).
    confidence : float
        Confidence level (1 - (d/p)^num_tests for nonzero polynomials).

    Complexity
    ----------
    Time: O(num_tests · |poly_coeffs| · n).
    Space: O(n).
    """
    import random
    random.seed(42)

    total_degree = max(sum(exp) for exp in poly_coeffs.keys()) if poly_coeffs else 0
    zeros_found = 0

    for _ in range(num_tests):
        point = tuple(random.randint(0, p - 1) for _ in range(n))
        val = 0
        for exponents, coeff in poly_coeffs.items():
            term = coeff
            for i, e in enumerate(exponents):
                term = (term * pow(int(point[i]), int(e), p)) % p
            val = (val + term) % p
        if val == 0:
            zeros_found += 1

    likely_zero = (zeros_found == num_tests)
    if total_degree > 0 and p > 0:
        false_zero_prob = (total_degree / p) ** num_tests
        confidence = 1.0 - false_zero_prob
    else:
        confidence = 1.0

    return likely_zero, confidence


def reed_muller_encode(
    message: List[int], n: int, d: int, p: int
) -> List[int]:
    """
    Reed-Muller encoding: map a message to polynomial evaluations.

    The message is interpreted as coefficients of a polynomial with
    box-degree < d, and the codeword is the evaluation of that polynomial
    on all of F_p^n.

    Parameters
    ----------
    message : List[int]
        Message vector of length d^n (coefficients for each monomial).
    n : int
        Number of variables.
    d : int
        Box degree bound.
    p : int
        Prime field size.

    Returns
    -------
    List[int]
        Codeword of length p^n (evaluations on all of F_p^n).

    Complexity
    ----------
    Time: O(p^n · d^n · n).
    Space: O(p^n).
    """
    monomials = enumerate_box_monomials(n, d)
    assert len(message) == len(monomials), \
        f"Message length {len(message)} != d^n = {len(monomials)}"

    all_points = list(product(range(p), repeat=n))
    codeword = []

    for pt in all_points:
        val = 0
        for j, mono in enumerate(monomials):
            term = message[j]
            for i, e in enumerate(mono):
                term = (term * pow(int(pt[i]), int(e), p)) % p
            val = (val + term) % p
        codeword.append(val)

    return codeword


def estimate_minimum_distance(n: int, d: int, p: int, num_samples: int = 1000) -> int:
    """
    Estimate the minimum distance of a Reed-Muller code by sampling.

    Parameters
    ----------
    n : int
        Number of variables.
    d : int
        Box degree bound.
    p : int
        Prime field size.
    num_samples : int
        Number of random nonzero codewords to sample.

    Returns
    -------
    int
        Estimated minimum Hamming weight among sampled nonzero codewords.

    Complexity
    ----------
    Time: O(num_samples · p^n · d^n · n).
    Space: O(p^n + d^n).
    """
    import random
    random.seed(42)

    dim = d ** n
    min_weight = p ** n  # Start with maximum possible

    for _ in range(num_samples):
        # Random nonzero message
        msg = [random.randint(0, p - 1) for _ in range(dim)]
        if all(m == 0 for m in msg):
            msg[0] = 1

        codeword = reed_muller_encode(msg, n, d, p)
        weight = sum(1 for c in codeword if c != 0)
        min_weight = min(min_weight, weight)

    return min_weight


if __name__ == "__main__":
    print("Finite-Field Polynomial Method — Algorithm Demonstrations")
    print("=" * 60)

    # Demo: Find vanishing polynomial
    print("\n1. Finding a vanishing polynomial over F_5")
    points = [(0, 0), (1, 0), (0, 1), (1, 1), (2, 0), (0, 2), (2, 2)]
    poly = find_vanishing_polynomial(n=2, d=3, points=points, p=5)
    if poly:
        print(f"   Found polynomial with {len(poly)} nonzero terms")
        for exp, coeff in sorted(poly.items()):
            print(f"     {coeff} · x^{exp}")
        # Verify
        for pt in points:
            val = 0
            for exp, coeff in poly.items():
                term = coeff
                for i, e in enumerate(exp):
                    term = (term * pow(pt[i], e, 5)) % 5
                val = (val + term) % 5
            assert val == 0, f"Failed at {pt}"
        print("   All evaluations verified = 0 ✓")

    # Demo: Schwartz-Zippel test
    print("\n2. Schwartz-Zippel identity test")
    # Test the zero polynomial
    zero_poly: Dict[Tuple[int, ...], int] = {(0, 0): 0}
    is_zero, conf = polynomial_identity_test_schwartz_zippel(zero_poly, 2, 7)
    print(f"   Zero polynomial: likely_zero={is_zero}, confidence={conf:.6f}")

    # Test a nonzero polynomial
    nonzero_poly = {(1, 0): 1, (0, 1): 1, (0, 0): 6}  # x + y - 1 mod 7
    is_zero, conf = polynomial_identity_test_schwartz_zippel(nonzero_poly, 2, 7)
    print(f"   x + y - 1 mod 7: likely_zero={is_zero}, confidence={conf:.6f}")

    # Demo: Reed-Muller encoding
    print("\n3. Reed-Muller code parameters")
    for n, d, p in [(1, 2, 3), (2, 2, 3), (1, 3, 5), (2, 2, 5)]:
        dim = d ** n
        length = p ** n
        est_dist = estimate_minimum_distance(n, d, p, num_samples=200)
        rate = dim / length
        print(f"   RM({p},{n},{d}): length={length}, dim={dim}, "
              f"rate={rate:.3f}, est_min_dist={est_dist}")
