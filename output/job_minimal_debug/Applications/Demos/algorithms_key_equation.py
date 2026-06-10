#!/usr/bin/env python3
"""
Reed–Solomon Decoding Algorithms

Implements the Welch–Berlekamp decoder and supporting algorithms
for Reed–Solomon error correction over finite fields.
"""

from typing import List, Tuple, Optional
import numpy as np


class GaloisField:
    """
    Arithmetic in GF(p) for prime p.
    
    Provides addition, subtraction, multiplication, division, and
    inversion modulo a prime p.
    """
    
    def __init__(self, p: int):
        """Initialize GF(p) for prime p."""
        self.p = p
        self._verify_prime(p)
    
    @staticmethod
    def _verify_prime(p: int):
        if p < 2:
            raise ValueError(f"p = {p} must be >= 2")
        for i in range(2, int(p**0.5) + 1):
            if p % i == 0:
                raise ValueError(f"p = {p} is not prime")
    
    def add(self, a: int, b: int) -> int:
        return (a + b) % self.p
    
    def sub(self, a: int, b: int) -> int:
        return (a - b) % self.p
    
    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p
    
    def inv(self, a: int) -> int:
        if a % self.p == 0:
            raise ZeroDivisionError("Cannot invert zero in GF(p)")
        return pow(a, self.p - 2, self.p)
    
    def div(self, a: int, b: int) -> int:
        return self.mul(a, self.inv(b))
    
    def neg(self, a: int) -> int:
        return (-a) % self.p
    
    def __repr__(self) -> str:
        return f"GF({self.p})"


class GFPolynomial:
    """
    Polynomial over GF(p).
    
    Represented as a list of coefficients [a_0, a_1, ..., a_d]
    where the polynomial is a_0 + a_1*X + ... + a_d*X^d.
    
    Args:
        coeffs: List of integer coefficients (will be reduced mod p).
        field: The GaloisField instance.
    """
    
    def __init__(self, coeffs: List[int], field: GaloisField):
        self.field = field
        self.coeffs = [c % field.p for c in coeffs]
        self._normalize()
    
    def _normalize(self):
        """Remove trailing zeros (but keep at least one coefficient)."""
        while len(self.coeffs) > 1 and self.coeffs[-1] == 0:
            self.coeffs.pop()
    
    @property
    def degree(self) -> int:
        """Return the degree of the polynomial (-1 for the zero polynomial)."""
        if self.is_zero():
            return -1
        return len(self.coeffs) - 1
    
    def is_zero(self) -> bool:
        return self.coeffs == [0]
    
    def eval(self, x: int) -> int:
        """Evaluate the polynomial at x using Horner's method.
        
        Time complexity: O(degree)
        """
        result = 0
        for c in reversed(self.coeffs):
            result = self.field.add(self.field.mul(result, x), c)
        return result
    
    def __add__(self, other: 'GFPolynomial') -> 'GFPolynomial':
        n = max(len(self.coeffs), len(other.coeffs))
        a = self.coeffs + [0] * (n - len(self.coeffs))
        b = other.coeffs + [0] * (n - len(other.coeffs))
        return GFPolynomial([self.field.add(a[i], b[i]) for i in range(n)], self.field)
    
    def __sub__(self, other: 'GFPolynomial') -> 'GFPolynomial':
        n = max(len(self.coeffs), len(other.coeffs))
        a = self.coeffs + [0] * (n - len(self.coeffs))
        b = other.coeffs + [0] * (n - len(other.coeffs))
        return GFPolynomial([self.field.sub(a[i], b[i]) for i in range(n)], self.field)
    
    def __mul__(self, other: 'GFPolynomial') -> 'GFPolynomial':
        if self.is_zero() or other.is_zero():
            return GFPolynomial([0], self.field)
        n = len(self.coeffs) + len(other.coeffs) - 1
        result = [0] * n
        for i, a in enumerate(self.coeffs):
            for j, b in enumerate(other.coeffs):
                result[i + j] = self.field.add(result[i + j], self.field.mul(a, b))
        return GFPolynomial(result, self.field)
    
    def scale(self, c: int) -> 'GFPolynomial':
        """Multiply all coefficients by scalar c."""
        return GFPolynomial([self.field.mul(c, coeff) for coeff in self.coeffs], self.field)
    
    def divmod(self, other: 'GFPolynomial') -> Tuple['GFPolynomial', 'GFPolynomial']:
        """
        Polynomial division with remainder.
        
        Returns (quotient, remainder) such that self = quotient * other + remainder
        and degree(remainder) < degree(other).
        
        Time complexity: O(degree(self) * degree(other))
        """
        if other.is_zero():
            raise ZeroDivisionError("Cannot divide by zero polynomial")
        
        remainder = list(self.coeffs)
        divisor = other.coeffs
        quotient = [0] * max(1, len(remainder) - len(divisor) + 1)
        
        for i in range(len(remainder) - len(divisor), -1, -1):
            if len(remainder) > i + len(divisor) - 1:
                coeff = self.field.div(remainder[i + len(divisor) - 1], divisor[-1])
                quotient[i] = coeff
                for j in range(len(divisor)):
                    remainder[i + j] = self.field.sub(
                        remainder[i + j], self.field.mul(coeff, divisor[j]))
        
        return GFPolynomial(quotient, self.field), GFPolynomial(remainder, self.field)
    
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
                terms.append(f"{c}*X" if c != 1 else "X")
            else:
                terms.append(f"{c}*X^{i}" if c != 1 else f"X^{i}")
        return " + ".join(terms) if terms else "0"
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, GFPolynomial):
            return NotImplemented
        return self.coeffs == other.coeffs


def welch_berlekamp_decode(
    field: GaloisField,
    eval_points: List[int],
    received: List[int],
    k: int,
    t: int
) -> Optional[GFPolynomial]:
    """
    Welch–Berlekamp decoder for Reed–Solomon codes.
    
    Given n evaluation points, a received word with at most t errors,
    and message degree bound k, finds the unique transmitted polynomial
    p of degree < k satisfying p(a_i) = r(i) at all non-error positions.
    
    Algorithm:
    1. Set up the key equation: find Q (deg < k+t) and monic E (deg ≤ t)
       such that Q(a_i) = r(i) · E(a_i) for all i.
    2. This is a linear system in the coefficients of Q and E.
    3. Solve using Gaussian elimination.
    4. Compute p = Q / E (polynomial division, no remainder).
    
    Args:
        field: The finite field GF(p).
        eval_points: List of n distinct evaluation points in GF(p).
        received: List of n received values.
        k: Message polynomial degree bound (degree < k).
        t: Maximum number of errors.
    
    Returns:
        The decoded polynomial p, or None if decoding fails.
    
    Time complexity: O(n^2) for the linear system solve.
    Space complexity: O(n^2) for the matrix.
    
    Example:
        >>> F = GaloisField(11)
        >>> points = list(range(7))
        >>> # Encode p(X) = X^2 + 3X + 2
        >>> p = GFPolynomial([2, 3, 1], F)
        >>> codeword = [p.eval(x) for x in points]
        >>> # Corrupt 2 positions
        >>> received = list(codeword)
        >>> received[1] = (received[1] + 5) % 11
        >>> received[4] = (received[4] + 9) % 11
        >>> # Decode
        >>> decoded = welch_berlekamp_decode(F, points, received, k=3, t=2)
        >>> print(decoded)  # Should recover p
    """
    n = len(eval_points)
    assert len(received) == n, "Received word length must match number of evaluation points"
    assert k + 2 * t <= n, f"Decoding bound violated: k + 2t = {k + 2*t} > n = {n}"
    
    # Number of unknowns:
    # Q has k+t coefficients: q_0, ..., q_{k+t-1}
    # E has t coefficients (monic, so e_0, ..., e_{t-1}, with leading coeff 1)
    num_q_coeffs = k + t
    num_e_coeffs = t  # E is monic of degree exactly t
    num_vars = num_q_coeffs + num_e_coeffs
    
    # Build the linear system
    # For each evaluation point a_i with received value r_i:
    # Q(a_i) = r_i * E(a_i)
    # q_0 + q_1*a_i + ... + q_{k+t-1}*a_i^{k+t-1} = r_i*(e_0 + e_1*a_i + ... + e_{t-1}*a_i^{t-1} + a_i^t)
    # Rearranging:
    # q_0 + q_1*a_i + ... - r_i*e_0 - r_i*e_1*a_i - ... = r_i * a_i^t
    
    matrix = []
    rhs_vec = []
    
    for i in range(n):
        ai = eval_points[i]
        ri = received[i]
        
        row = []
        # Q coefficients: a_i^j for j = 0, ..., k+t-1
        ai_pow = 1
        for j in range(num_q_coeffs):
            row.append(ai_pow)
            ai_pow = field.mul(ai_pow, ai)
        
        # E coefficients (negated, multiplied by r_i): -r_i * a_i^j for j = 0, ..., t-1
        ai_pow = 1
        for j in range(num_e_coeffs):
            row.append(field.neg(field.mul(ri, ai_pow)))
            ai_pow = field.mul(ai_pow, ai)
        
        # RHS: r_i * a_i^t
        rhs_val = field.mul(ri, ai_pow)
        
        matrix.append([x % field.p for x in row])
        rhs_vec.append(rhs_val % field.p)
    
    # Solve using Gaussian elimination
    solution = _gauss_solve(field, matrix, rhs_vec, num_vars)
    
    if solution is None:
        return None
    
    # Extract Q and E
    q_coeffs = solution[:num_q_coeffs]
    e_coeffs = solution[num_q_coeffs:] + [1]  # Add monic leading coefficient
    
    Q = GFPolynomial(q_coeffs, field)
    E = GFPolynomial(e_coeffs, field)
    
    # Verify key equation
    for i in range(n):
        q_val = Q.eval(eval_points[i])
        e_val = E.eval(eval_points[i])
        expected = field.mul(received[i], e_val)
        if q_val != expected:
            return None  # Key equation not satisfied
    
    # Divide Q by E
    quotient, remainder = Q.divmod(E)
    
    if not remainder.is_zero():
        return None  # E does not divide Q
    
    if quotient.degree >= k:
        return None  # Degree bound violated
    
    return quotient


def _gauss_solve(
    field: GaloisField, 
    matrix: List[List[int]], 
    rhs: List[int], 
    num_vars: int
) -> Optional[List[int]]:
    """
    Solve a linear system over GF(p) using Gaussian elimination with partial pivoting.
    
    Args:
        field: The finite field.
        matrix: m × num_vars coefficient matrix.
        rhs: m-element right-hand side vector.
        num_vars: Number of variables.
    
    Returns:
        Solution vector, or None if no unique solution exists.
    
    Time complexity: O(m * num_vars^2)
    """
    m = len(matrix)
    # Augmented matrix [A | b]
    aug = [matrix[i][:] + [rhs[i]] for i in range(m)]
    
    pivot_cols = []
    row_idx = 0
    
    for col in range(num_vars):
        # Find pivot in current column
        pivot = None
        for r in range(row_idx, m):
            if aug[r][col] != 0:
                pivot = r
                break
        
        if pivot is None:
            continue
        
        # Swap rows
        aug[row_idx], aug[pivot] = aug[pivot], aug[row_idx]
        pivot_cols.append(col)
        
        # Scale pivot row
        inv = field.inv(aug[row_idx][col])
        aug[row_idx] = [field.mul(inv, x) for x in aug[row_idx]]
        
        # Eliminate column
        for r in range(m):
            if r != row_idx and aug[r][col] != 0:
                factor = aug[r][col]
                for j in range(num_vars + 1):
                    aug[r][j] = field.sub(aug[r][j], field.mul(factor, aug[row_idx][j]))
        
        row_idx += 1
    
    # Check for inconsistency
    for r in range(row_idx, m):
        if aug[r][-1] != 0:
            return None
    
    # Extract solution (free variables set to 0)
    solution = [0] * num_vars
    for idx, col in enumerate(pivot_cols):
        solution[col] = aug[idx][-1]
    
    return solution


def reed_solomon_encode(
    field: GaloisField,
    eval_points: List[int],
    message_coeffs: List[int]
) -> List[int]:
    """
    Encode a message as a Reed–Solomon codeword.
    
    Args:
        field: The finite field.
        eval_points: List of n distinct evaluation points.
        message_coeffs: Coefficients of the message polynomial [a_0, ..., a_{k-1}].
    
    Returns:
        Codeword: list of n evaluations p(a_0), ..., p(a_{n-1}).
    
    Time complexity: O(n * k) where k = len(message_coeffs).
    """
    p = GFPolynomial(message_coeffs, field)
    return [p.eval(x) for x in eval_points]


def introduce_errors(
    field: GaloisField,
    codeword: List[int],
    error_positions: List[int],
    error_values: List[int]
) -> List[int]:
    """
    Introduce errors into a codeword at specified positions.
    
    Args:
        field: The finite field.
        codeword: Original codeword.
        error_positions: Indices where errors occur.
        error_values: Error magnitudes (added to codeword values).
    
    Returns:
        Corrupted received word.
    """
    received = list(codeword)
    for pos, val in zip(error_positions, error_values):
        received[pos] = field.add(received[pos], val)
    return received


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Reed–Solomon Welch–Berlekamp Decoder")
    print("=" * 50)
    
    # Setup
    F = GaloisField(11)
    n, k, t = 7, 3, 2
    eval_points = list(range(n))
    
    # Encode
    message = [2, 3, 1]  # p(X) = X^2 + 3X + 2
    codeword = reed_solomon_encode(F, eval_points, message)
    print(f"\nField: {F}")
    print(f"Parameters: n={n}, k={k}, t={t}")
    print(f"Message: {message} → p(X) = X² + 3X + 2")
    print(f"Codeword: {codeword}")
    
    # Corrupt
    received = introduce_errors(F, codeword, [1, 4], [5, 9])
    print(f"Received (2 errors): {received}")
    
    # Decode
    decoded = welch_berlekamp_decode(F, eval_points, received, k, t)
    
    if decoded is not None:
        print(f"\nDecoded polynomial: {decoded}")
        print(f"Original polynomial: {GFPolynomial(message, F)}")
        print(f"Match: {decoded == GFPolynomial(message, F)}")
        
        # Show corrected codeword
        corrected = [decoded.eval(x) for x in eval_points]
        print(f"Corrected codeword: {corrected}")
        print(f"Original codeword:  {codeword}")
        print(f"Codewords match: {corrected == codeword}")
    else:
        print("Decoding failed!")
