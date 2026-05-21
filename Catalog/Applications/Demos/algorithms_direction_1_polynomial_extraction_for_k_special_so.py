"""
Polynomial Extraction Algorithms for k-Special Soundness

Implements Lagrange interpolation-based witness extraction over finite fields,
demonstrating the Reed–Solomon coding-theoretic interpretation of Σ-protocol
special soundness.

Keywords: Lagrange interpolation, Reed–Solomon codes, Vandermonde matrices,
finite fields, witness extraction, polynomial reconstruction
"""

from typing import List, Tuple, Optional
import random


def mod_inverse(a: int, p: int) -> int:
    """Compute modular inverse of a modulo p using extended Euclidean algorithm.

    Args:
        a: Element to invert (must be nonzero mod p)
        p: Prime modulus

    Returns:
        a^{-1} mod p

    Raises:
        ValueError: if a ≡ 0 (mod p)

    Time complexity: O(log p)
    Space complexity: O(1)
    """
    if a % p == 0:
        raise ValueError(f"Cannot invert {a} modulo {p}: element is zero")
    return pow(a, p - 2, p)


class FiniteField:
    """Arithmetic in GF(p) for prime p.

    Provides field operations with automatic modular reduction.

    >>> F = FiniteField(7)
    >>> F.add(3, 5)
    1
    >>> F.mul(3, 5)
    1
    >>> F.inv(3)
    5
    """

    def __init__(self, p: int):
        """Initialize GF(p).

        Args:
            p: A prime number defining the field.
        """
        self.p = p

    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p

    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        return mod_inverse(a, self.p)

    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))

    def neg(self, a: int) -> int:
        return (-a) % self.p

    def zero(self) -> int:
        return 0

    def one(self) -> int:
        return 1

    def random_element(self) -> int:
        return random.randint(0, self.p - 1)

    def random_nonzero(self) -> int:
        return random.randint(1, self.p - 1)


class Polynomial:
    """Polynomial over a finite field GF(p).

    Represented as a list of coefficients [a_0, a_1, ..., a_d] where
    the polynomial is a_0 + a_1*x + ... + a_d*x^d.

    >>> F = FiniteField(7)
    >>> p = Polynomial(F, [1, 2, 3])  # 1 + 2x + 3x^2
    >>> p.eval(2)  # 1 + 4 + 12 = 17 ≡ 3 (mod 7)
    3
    """

    def __init__(self, field: FiniteField, coeffs: List[int]):
        self.field = field
        # Normalize: strip trailing zeros
        self.coeffs = [c % field.p for c in coeffs]
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()

    @property
    def degree(self) -> int:
        """Return the degree of the polynomial (-1 for the zero polynomial)."""
        if self.is_zero():
            return -1
        return len(self.coeffs) - 1

    def is_zero(self) -> bool:
        return all(c == 0 for c in self.coeffs)

    def eval(self, x: int) -> int:
        """Evaluate polynomial at x using Horner's method.

        Time complexity: O(deg)
        """
        result = 0
        for c in reversed(self.coeffs):
            result = self.field.add(self.field.mul(result, x), c)
        return result

    def __add__(self, other: 'Polynomial') -> 'Polynomial':
        n = max(len(self.coeffs), len(other.coeffs))
        result = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            result.append(self.field.add(a, b))
        return Polynomial(self.field, result)

    def __sub__(self, other: 'Polynomial') -> 'Polynomial':
        n = max(len(self.coeffs), len(other.coeffs))
        result = []
        for i in range(n):
            a = self.coeffs[i] if i < len(self.coeffs) else 0
            b = other.coeffs[i] if i < len(other.coeffs) else 0
            result.append(self.field.sub(a, b))
        return Polynomial(self.field, result)

    def __mul__(self, other: 'Polynomial') -> 'Polynomial':
        if self.is_zero() or other.is_zero():
            return Polynomial(self.field, [0])
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [0] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] = self.field.add(result[i + j], self.field.mul(a, b))
        return Polynomial(self.field, result)

    def scalar_mul(self, c: int) -> 'Polynomial':
        return Polynomial(self.field, [self.field.mul(c, a) for a in self.coeffs])

    def __eq__(self, other: 'Polynomial') -> bool:
        return self.coeffs == other.coeffs

    def __repr__(self) -> str:
        if self.is_zero():
            return "0"
        terms = []
        for i, c in enumerate(self.coeffs):
            if c == 0:
                continue
            if i == 0:
                terms.append(str(c))
            elif i == 1:
                terms.append(f"{c}*x" if c != 1 else "x")
            else:
                terms.append(f"{c}*x^{i}" if c != 1 else f"x^{i}")
        return " + ".join(terms) if terms else "0"


def lagrange_interpolation(
    field: FiniteField,
    points: List[Tuple[int, int]]
) -> Polynomial:
    """Lagrange interpolation over a finite field.

    Given k points (x_i, y_i) with distinct x_i, constructs the unique polynomial
    of degree < k passing through all points.

    This is the core extraction algorithm: given k accepting transcripts at distinct
    challenges, we reconstruct the witness polynomial.

    Args:
        field: The finite field GF(p)
        points: List of (x_i, y_i) pairs with distinct x_i values

    Returns:
        The interpolating polynomial of degree < len(points)

    Time complexity: O(k^2) field operations
    Space complexity: O(k) coefficients

    Algorithm:
        L(x) = Σ_i y_i * ∏_{j≠i} (x - x_j) / (x_i - x_j)

    >>> F = FiniteField(7)
    >>> # Interpolate through (1,3), (2,5), (4,1)
    >>> p = lagrange_interpolation(F, [(1,3), (2,5), (4,1)])
    >>> p.eval(1), p.eval(2), p.eval(4)
    (3, 5, 1)
    """
    k = len(points)
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]

    # Verify distinctness
    if len(set(xs)) != k:
        raise ValueError("Evaluation points must be distinct")

    result = Polynomial(field, [0])

    for i in range(k):
        # Build Lagrange basis polynomial L_i(x) = ∏_{j≠i} (x - x_j)/(x_i - x_j)
        basis = Polynomial(field, [1])
        for j in range(k):
            if j == i:
                continue
            # Multiply by (x - x_j) / (x_i - x_j)
            denom = field.sub(xs[i], xs[j])
            inv_denom = field.inv(denom)
            # (x - x_j) * inv_denom = inv_denom * x + (-x_j * inv_denom)
            linear = Polynomial(field, [field.neg(field.mul(xs[j], inv_denom)), inv_denom])
            basis = basis * linear

        # Add y_i * L_i(x)
        result = result + basis.scalar_mul(ys[i])

    return result


def vandermonde_matrix(field: FiniteField, xs: List[int], k: int) -> List[List[int]]:
    """Construct the Vandermonde matrix for evaluation points xs.

    V[i][j] = xs[i]^j for 0 ≤ i < len(xs), 0 ≤ j < k.

    The evaluation of a degree-(k-1) polynomial at xs is multiplication
    by this matrix: [p(x_0), ..., p(x_{n-1})]^T = V · [a_0, ..., a_{k-1}]^T.

    Reed–Solomon injectivity is equivalent to this matrix having rank k
    when len(xs) ≥ k and xs are distinct.

    Args:
        field: The finite field
        xs: Evaluation points
        k: Number of columns (= max degree + 1)

    Returns:
        The Vandermonde matrix as a list of rows

    Time complexity: O(n * k) field operations
    """
    n = len(xs)
    V = []
    for i in range(n):
        row = []
        power = 1
        for j in range(k):
            row.append(power)
            power = field.mul(power, xs[i])
        V.append(row)
    return V


def gaussian_elimination(field: FiniteField, A: List[List[int]], b: List[int]) -> Optional[List[int]]:
    """Solve Ax = b over GF(p) using Gaussian elimination with partial pivoting.

    Args:
        field: The finite field
        A: Square matrix (n x n)
        b: Right-hand side vector (length n)

    Returns:
        Solution vector x, or None if the system is singular

    Time complexity: O(n^3) field operations
    """
    n = len(b)
    # Augmented matrix
    M = [row[:] + [b[i]] for i, row in enumerate(A)]

    for col in range(n):
        # Find pivot
        pivot = None
        for row in range(col, n):
            if M[row][col] != 0:
                pivot = row
                break
        if pivot is None:
            return None

        M[col], M[pivot] = M[pivot], M[col]

        # Scale pivot row
        inv_pivot = field.inv(M[col][col])
        for j in range(n + 1):
            M[col][j] = field.mul(M[col][j], inv_pivot)

        # Eliminate
        for row in range(n):
            if row == col:
                continue
            factor = M[row][col]
            for j in range(n + 1):
                M[row][j] = field.sub(M[row][j], field.mul(factor, M[col][j]))

    return [M[i][n] for i in range(n)]


def vandermonde_extraction(
    field: FiniteField,
    points: List[Tuple[int, int]]
) -> Polynomial:
    """Extract polynomial coefficients via Vandermonde matrix inversion.

    Alternative to Lagrange interpolation using linear algebra.
    Solves V · a = y where V is the Vandermonde matrix and a are coefficients.

    Args:
        field: The finite field
        points: List of (x_i, y_i) pairs with distinct x_i

    Returns:
        The interpolating polynomial

    Time complexity: O(k^3) (due to Gaussian elimination)

    >>> F = FiniteField(7)
    >>> p = vandermonde_extraction(F, [(1,3), (2,5), (4,1)])
    >>> p.eval(1), p.eval(2), p.eval(4)
    (3, 5, 1)
    """
    k = len(points)
    xs = [p[0] for p in points]
    ys = [p[1] for p in points]

    V = vandermonde_matrix(field, xs, k)
    coeffs = gaussian_elimination(field, V, ys)

    if coeffs is None:
        raise ValueError("Vandermonde matrix is singular (points may not be distinct)")

    return Polynomial(field, coeffs)


def reed_solomon_encode(
    field: FiniteField,
    message: List[int],
    eval_points: List[int]
) -> List[int]:
    """Reed–Solomon encoding: evaluate the message polynomial at given points.

    The message [a_0, ..., a_{k-1}] defines polynomial p(x) = a_0 + a_1*x + ... + a_{k-1}*x^{k-1}.
    The codeword is [p(x_0), ..., p(x_{n-1})].

    This is exactly the evaluation map whose injectivity we prove in
    extraction_as_reed_solomon_uniqueness.

    Args:
        field: The finite field
        message: Coefficient vector of the message polynomial (length k)
        eval_points: Points at which to evaluate (length n ≥ k)

    Returns:
        Codeword (list of evaluations)

    Time complexity: O(n * k) using Horner's method
    """
    p = Polynomial(field, message)
    return [p.eval(x) for x in eval_points]


def reed_solomon_decode(
    field: FiniteField,
    codeword: List[int],
    eval_points: List[int],
    k: int
) -> List[int]:
    """Reed–Solomon unique decoding via interpolation.

    Given evaluations at n ≥ k distinct points of a degree-(k-1) polynomial,
    recover the original coefficients.

    Args:
        field: The finite field
        codeword: Evaluations [p(x_0), ..., p(x_{n-1})]
        eval_points: The evaluation points [x_0, ..., x_{n-1}]
        k: Dimension of the code (degree bound + 1)

    Returns:
        Coefficient vector of the recovered polynomial

    Time complexity: O(k^2) via Lagrange interpolation
    """
    points = list(zip(eval_points[:k], codeword[:k]))
    p = lagrange_interpolation(field, points)
    # Pad to k coefficients
    coeffs = p.coeffs + [0] * (k - len(p.coeffs))
    return coeffs[:k]


def affine_extract_1d(field: FiniteField, z1: int, z2: int, c1: int, c2: int) -> int:
    """One-dimensional affine extraction: w = (z1 - z2) * (c1 - c2)^{-1}.

    This is the k=2 specialization of Lagrange extraction.

    Args:
        field: The finite field
        z1, z2: Two responses
        c1, c2: Two distinct challenges

    Returns:
        The extracted witness w
    """
    return field.div(field.sub(z1, z2), field.sub(c1, c2))


if __name__ == "__main__":
    # Quick self-test
    F = FiniteField(17)

    # Test Lagrange interpolation
    p_orig = Polynomial(F, [3, 7, 2])  # 3 + 7x + 2x^2
    points = [(i, p_orig.eval(i)) for i in range(3)]
    p_recovered = lagrange_interpolation(F, points)
    assert p_recovered == p_orig, f"Lagrange failed: {p_recovered} != {p_orig}"

    # Test Vandermonde extraction
    p_vand = vandermonde_extraction(F, points)
    assert p_vand == p_orig, f"Vandermonde failed: {p_vand} != {p_orig}"

    # Test Reed-Solomon
    msg = [3, 7, 2]
    eval_pts = list(range(5))
    codeword = reed_solomon_encode(F, msg, eval_pts)
    recovered = reed_solomon_decode(F, codeword, eval_pts, 3)
    assert recovered == msg, f"RS decode failed: {recovered} != {msg}"

    # Test affine extraction (k=2 case)
    r, w = 5, 11
    c1, c2 = 3, 7
    z1 = F.add(r, F.mul(c1, w))
    z2 = F.add(r, F.mul(c2, w))
    w_extracted = affine_extract_1d(F, z1, z2, c1, c2)
    assert w_extracted == w % F.p, f"Affine extraction failed: {w_extracted} != {w % F.p}"

    print("All self-tests passed!")
