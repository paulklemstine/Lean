"""
Algorithms for Markov-Trace Dynamics on SL₂(ℤ).

Implements:
1. Chebyshev trace computation (O(n) and O(log n) variants)
2. Markov tree enumeration via BFS with Vieta involution
3. Trace orbit signature generation
4. Trace-based commitment scheme
"""

from typing import Tuple, List, Set, Dict, Optional
from collections import deque
import math


# ============================================================
# Algorithm 1: Chebyshev Trace Computation
# ============================================================

def cheb_trace(t: int, n: int) -> int:
    """
    Compute chebTrace(t, n) using the Chebyshev recurrence.

    chebTrace(t, 0) = 2
    chebTrace(t, 1) = t
    chebTrace(t, n+2) = t * chebTrace(t, n+1) - chebTrace(t, n)

    Runs in O(n) integer multiplications.

    Args:
        t: The trace value (any integer)
        n: The power index (non-negative integer)

    Returns:
        The n-th Chebyshev trace value
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev2, prev1 = 2, t
    for _ in range(2, n + 1):
        curr = t * prev1 - prev2
        prev2, prev1 = prev1, curr
    return prev1


def cheb_trace_fast(t: int, n: int) -> int:
    """
    Compute chebTrace(t, n) using matrix exponentiation in O(log n) steps.

    Uses the identity: [[chebTrace(t,n+1)], [chebTrace(t,n)]] = [[t,-1],[1,0]]^n @ [[t],[2]]

    Args:
        t: The trace value
        n: The power index

    Returns:
        The n-th Chebyshev trace value
    """
    if n == 0:
        return 2
    if n == 1:
        return t

    def mat_mul(A: Tuple, B: Tuple) -> Tuple:
        """Multiply 2x2 matrices stored as (a,b,c,d)."""
        a1, b1, c1, d1 = A
        a2, b2, c2, d2 = B
        return (
            a1 * a2 + b1 * c2,
            a1 * b2 + b1 * d2,
            c1 * a2 + d1 * c2,
            c1 * b2 + d1 * d2,
        )

    def mat_pow(M: Tuple, k: int) -> Tuple:
        """Matrix exponentiation by squaring."""
        result = (1, 0, 0, 1)  # identity
        base = M
        while k > 0:
            if k & 1:
                result = mat_mul(result, base)
            base = mat_mul(base, base)
            k >>= 1
        return result

    # [[t, -1], [1, 0]]^(n-1) @ [[t], [2]]
    M = (t, -1, 1, 0)
    Mn = mat_pow(M, n - 1)
    return Mn[0] * t + Mn[1] * 2


# ============================================================
# Algorithm 2: Markov Tree Enumeration
# ============================================================

def vieta_involution(x: int, y: int, z: int) -> Tuple[int, int, int]:
    """Apply the Vieta involution: (x, y, z) -> (x, y, 3xy - z)."""
    return (x, y, 3 * x * y - z)


def normalize_triple(x: int, y: int, z: int) -> Tuple[int, int, int]:
    """Sort a triple into canonical order (a ≤ b ≤ c)."""
    return tuple(sorted([x, y, z]))


def enumerate_markov_triples(max_z: int) -> List[Tuple[int, int, int]]:
    """
    Enumerate all Markov triples (x, y, z) with z ≤ max_z using BFS.

    Starting from (1, 1, 1), applies Vieta involutions in all three
    coordinate directions and collects canonical triples.

    Args:
        max_z: Upper bound on the largest element

    Returns:
        Sorted list of Markov triples (x, y, z) with x ≤ y ≤ z ≤ max_z
    """
    seen: Set[Tuple[int, int, int]] = set()
    queue: deque = deque()

    seed = (1, 1, 1)
    seen.add(seed)
    queue.append(seed)

    while queue:
        x, y, z = queue.popleft()

        # Apply Vieta involution to each coordinate
        children = [
            (3 * y * z - x, y, z),  # Replace x
            (x, 3 * x * z - y, z),  # Replace y
            (x, y, 3 * x * y - z),  # Replace z
        ]

        for child in children:
            canon = normalize_triple(*child)
            if canon[2] <= max_z and canon[0] > 0 and canon not in seen:
                seen.add(canon)
                queue.append(canon)

    return sorted(seen)


# ============================================================
# Algorithm 3: Trace Orbit Signature
# ============================================================

class SL2Matrix:
    """A 2x2 integer matrix with determinant 1."""

    __slots__ = ('a', 'b', 'c', 'd')

    def __init__(self, a: int, b: int, c: int, d: int):
        assert a * d - b * c == 1, f"det = {a*d - b*c} ≠ 1"
        self.a, self.b, self.c, self.d = a, b, c, d

    def trace(self) -> int:
        return self.a + self.d

    def __mul__(self, other: 'SL2Matrix') -> 'SL2Matrix':
        return SL2Matrix(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inv(self) -> 'SL2Matrix':
        return SL2Matrix(self.d, -self.b, -self.c, self.a)

    def pow(self, n: int) -> 'SL2Matrix':
        if n == 0:
            return SL2Matrix(1, 0, 0, 1)
        result = SL2Matrix(1, 0, 0, 1)
        base = self
        for _ in range(n):
            result = result * base
        return result

    def __repr__(self) -> str:
        return f"SL2([{self.a},{self.b};{self.c},{self.d}])"


def trace_orbit_signature(A: SL2Matrix, length: int) -> List[int]:
    """
    Compute the trace orbit signature of A up to A^length.

    Args:
        A: An SL₂(ℤ) matrix
        length: Number of terms to compute

    Returns:
        [tr(A⁰), tr(A¹), ..., tr(A^(length-1))]
    """
    return [A.pow(n).trace() for n in range(length)]


def trace_orbit_signature_fast(t: int, length: int) -> List[int]:
    """
    Compute the trace orbit signature using only the trace value.

    By the Trace-Power Theorem, tr(Aⁿ) = chebTrace(tr(A), n).

    Args:
        t: The trace of the matrix
        length: Number of terms

    Returns:
        [chebTrace(t, 0), chebTrace(t, 1), ..., chebTrace(t, length-1)]
    """
    return [cheb_trace(t, n) for n in range(length)]


# ============================================================
# Algorithm 4: Trace Commitment Scheme
# ============================================================

class TraceCommitment:
    """A trace-based commitment scheme."""

    def __init__(self, matrix: SL2Matrix):
        """Commit by computing the trace."""
        self._matrix = matrix
        self.commitment = matrix.trace()

    def open(self) -> SL2Matrix:
        """Open the commitment by revealing the matrix."""
        return self._matrix

    @staticmethod
    def verify(commitment: int, opening: SL2Matrix) -> bool:
        """Verify that the opening matches the commitment."""
        return opening.trace() == commitment


def generate_distinct_matrices(t: int, n: int) -> List[SL2Matrix]:
    """
    Generate n distinct SL₂(ℤ) matrices with trace t.

    Uses the family M_k = [[k, 1, k(t-k)-1, t-k]] for k = 0, 1, ..., n-1.

    Args:
        t: Target trace value
        n: Number of matrices to generate

    Returns:
        List of n distinct SL₂(ℤ) matrices with trace t
    """
    matrices = []
    for k in range(n):
        a = k
        d = t - k
        b = 1
        c = a * d - 1  # ensures det = ad - bc = 1
        matrices.append(SL2Matrix(a, b, c, d))
    return matrices


# ============================================================
# Algorithm 5: Fricke-Vogt Verification
# ============================================================

def verify_fricke_vogt(A: SL2Matrix, B: SL2Matrix) -> bool:
    """
    Verify the Fricke-Vogt identity for given matrices.

    tr(A)² + tr(B)² + tr(AB)² = tr(A)·tr(B)·tr(AB) + tr([A,B]) + 2
    """
    tA = A.trace()
    tB = B.trace()
    AB = A * B
    tAB = AB.trace()

    commutator = A * B * A.inv() * B.inv()
    tComm = commutator.trace()

    lhs = tA**2 + tB**2 + tAB**2
    rhs = tA * tB * tAB + tComm + 2

    return lhs == rhs


def verify_markov_equation(x: int, y: int, z: int) -> bool:
    """Check if (x, y, z) satisfies the Markov equation x² + y² + z² = 3xyz."""
    return x**2 + y**2 + z**2 == 3 * x * y * z


# ============================================================
# Main verification
# ============================================================

if __name__ == "__main__":
    # Test Chebyshev trace computation
    print("=== Chebyshev Trace Computation ===")
    for t in [3, 4, 5]:
        print(f"t = {t}: {[cheb_trace(t, n) for n in range(8)]}")
        # Verify fast computation matches
        assert all(cheb_trace(t, n) == cheb_trace_fast(t, n) for n in range(50))

    # Test Markov tree
    print("\n=== Markov Triples (z ≤ 100) ===")
    triples = enumerate_markov_triples(100)
    for triple in triples:
        assert verify_markov_equation(*triple)
        print(f"  {triple}")

    # Test Fricke-Vogt
    print("\n=== Fricke-Vogt Verification ===")
    S = SL2Matrix(0, -1, 1, 0)
    T = SL2Matrix(1, 1, 0, 1)
    assert verify_fricke_vogt(S, T)
    print(f"  S = {S}, tr(S) = {S.trace()}")
    print(f"  T = {T}, tr(T) = {T.trace()}")
    print(f"  Fricke-Vogt verified: True")

    # Test commitment scheme
    print("\n=== Trace Commitment ===")
    matrices = generate_distinct_matrices(7, 5)
    for m in matrices:
        print(f"  {m}, trace = {m.trace()}")
    assert all(m.trace() == 7 for m in matrices)
    assert len(set(id(m) for m in matrices)) == 5

    print("\nAll tests passed!")
