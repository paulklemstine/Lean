"""
Algorithms for Hyperbolic Number Theory
========================================

Core algorithms for computing with SL(2,R) matrices,
hyperbolic lattice points, and the hyperbolic zeta function.
"""

import math
from typing import List, Tuple, Dict, Optional, Set


class SL2RMatrix:
    """
    A 2x2 real matrix with determinant 1.

    Represents an element of SL(2,R), the isometry group of the
    hyperbolic plane.

    Time complexity: O(1) for all basic operations.
    Space complexity: O(1).
    """

    __slots__ = ('a', 'b', 'c', 'd')

    def __init__(self, a: float, b: float, c: float, d: float):
        self.a, self.b, self.c, self.d = float(a), float(b), float(c), float(d)

    @staticmethod
    def identity() -> 'SL2RMatrix':
        return SL2RMatrix(1, 0, 0, 1)

    def det(self) -> float:
        return self.a * self.d - self.b * self.c

    def mul(self, other: 'SL2RMatrix') -> 'SL2RMatrix':
        """Matrix multiplication. O(1)."""
        return SL2RMatrix(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inv(self) -> 'SL2RMatrix':
        """Matrix inverse (for det=1 matrices). O(1)."""
        return SL2RMatrix(self.d, -self.b, -self.c, self.a)

    def trace(self) -> float:
        """Trace a + d. O(1)."""
        return self.a + self.d

    def classify(self) -> str:
        """Classify as hyperbolic/elliptic/parabolic. O(1)."""
        t = abs(self.trace())
        if t > 2 + 1e-12:
            return "hyperbolic"
        elif t < 2 - 1e-12:
            return "elliptic"
        return "parabolic"

    def power(self, n: int) -> 'SL2RMatrix':
        """
        Compute M^n using binary exponentiation.

        Time complexity: O(log n).
        """
        if n == 0:
            return SL2RMatrix.identity()
        if n < 0:
            return self.inv().power(-n)
        result = SL2RMatrix.identity()
        base = self
        while n > 0:
            if n % 2 == 1:
                result = result.mul(base)
            base = base.mul(base)
            n //= 2
        return result

    def displacement(self) -> float:
        """
        Displacement: |tr(M)| - 2.
        Nonneg for hyperbolic/parabolic elements.
        """
        return abs(self.trace()) - 2

    def translation_length(self) -> float:
        """
        Hyperbolic translation length for hyperbolic elements.
        ℓ(M) = 2 * arccosh(|tr(M)|/2)
        """
        t = abs(self.trace()) / 2
        if t <= 1:
            return 0.0
        return 2 * math.acosh(t)

    def __repr__(self) -> str:
        return f"SL2R[{self.a:.3f} {self.b:.3f}; {self.c:.3f} {self.d:.3f}]"

    def __eq__(self, other: object) -> bool:
        if not isinstance(other, SL2RMatrix):
            return False
        return (abs(self.a - other.a) < 1e-10 and abs(self.b - other.b) < 1e-10 and
                abs(self.c - other.c) < 1e-10 and abs(self.d - other.d) < 1e-10)

    def __hash__(self) -> int:
        return hash((round(self.a, 8), round(self.b, 8),
                      round(self.c, 8), round(self.d, 8)))


def chebyshev_trace_sequence(M: SL2RMatrix, n_terms: int) -> List[float]:
    """
    Compute traces tr(M^0), tr(M^1), ..., tr(M^{n-1}) using the
    Chebyshev recurrence: tr(M^{k+2}) = tr(M) * tr(M^{k+1}) - tr(M^k).

    This is O(n) time and O(n) space, much faster than computing M^k
    directly which would be O(n log n) with binary exponentiation.

    Args:
        M: An SL(2,R) matrix.
        n_terms: Number of terms to compute.

    Returns:
        List of traces [tr(M^0), tr(M^1), ..., tr(M^{n-1})].
    """
    if n_terms <= 0:
        return []
    traces = [2.0]  # tr(M^0) = tr(I) = 2
    if n_terms == 1:
        return traces
    traces.append(M.trace())  # tr(M^1) = tr(M)
    t = M.trace()
    for k in range(2, n_terms):
        traces.append(t * traces[k - 1] - traces[k - 2])
    return traces


def enumerate_psl2z_elements(max_depth: int) -> List[SL2RMatrix]:
    """
    Enumerate elements of PSL(2,Z) by word length in generators S, T.

    Uses BFS from the identity using the standard generators:
      S = [[0, -1], [1, 0]]  (z -> -1/z)
      T = [[1, 1], [0, 1]]   (z -> z+1)

    Time complexity: O(3^d) where d = max_depth.
    Space complexity: O(3^d).

    Args:
        max_depth: Maximum word length.

    Returns:
        List of distinct SL(2,Z) elements.
    """
    S = SL2RMatrix(0, -1, 1, 0)
    T = SL2RMatrix(1, 1, 0, 1)
    Ti = SL2RMatrix(1, -1, 0, 1)

    elements: Dict[Tuple[int, ...], SL2RMatrix] = {}
    queue = [(SL2RMatrix.identity(), ())]

    def matrix_key(M: SL2RMatrix) -> Tuple[int, ...]:
        return (round(M.a), round(M.b), round(M.c), round(M.d))

    elements[matrix_key(SL2RMatrix.identity())] = SL2RMatrix.identity()

    for depth in range(max_depth):
        next_queue = []
        for M, word in queue:
            for g, name in [(S, 'S'), (T, 'T'), (Ti, 'Ti')]:
                N = M.mul(g)
                key = matrix_key(N)
                if key not in elements:
                    elements[key] = N
                    next_queue.append((N, word + (name,)))
        queue = next_queue

    return list(elements.values())


def hyperbolic_lattice_count(elements: List[SL2RMatrix], R: float) -> int:
    """
    Count lattice points with translation length ≤ R.

    Time complexity: O(n) where n = len(elements).

    Args:
        elements: List of SL(2,R) elements.
        R: Radius threshold.

    Returns:
        Number of elements with translation_length ≤ R.
    """
    return sum(1 for M in elements if M.translation_length() <= R)


def partial_hyperbolic_zeta(norms: List[float], s: float) -> float:
    """
    Compute the partial hyperbolic zeta function:
      ζ_H(s) = ∑_{n > 0} 1/n^{2s}

    Time complexity: O(|norms|).

    Args:
        norms: List of positive real norms.
        s: Complex frequency parameter.

    Returns:
        Value of the partial zeta sum.
    """
    return sum(1.0 / (n ** (2 * s)) for n in norms if n > 0)


def verify_trace_product_identity(M: SL2RMatrix, N: SL2RMatrix,
                                   tol: float = 1e-10) -> bool:
    """
    Verify tr(MN) + tr(MN^{-1}) = tr(M) * tr(N).

    Returns True if the identity holds within tolerance.
    """
    lhs = M.mul(N).trace() + M.mul(N.inv()).trace()
    rhs = M.trace() * N.trace()
    return abs(lhs - rhs) < tol


def verify_conjugation_invariance(M: SL2RMatrix, N: SL2RMatrix,
                                   tol: float = 1e-10) -> bool:
    """
    Verify tr(NMN^{-1}) = tr(M).

    Returns True if the identity holds within tolerance.
    """
    conj_trace = N.mul(M).mul(N.inv()).trace()
    return abs(conj_trace - M.trace()) < tol


# ═══════════════════════════════════════════════════════════════
# Example usage
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("Hyperbolic Number Theory — Algorithm Examples")
    print("=" * 50)

    # Chebyshev sequence
    M = SL2RMatrix(2, 1, 1, 1)
    traces = chebyshev_trace_sequence(M, 10)
    print(f"\nChebyshev trace sequence for M with tr(M)={M.trace()}:")
    for i, t in enumerate(traces):
        print(f"  tr(M^{i}) = {t:.0f}")

    # Enumerate PSL(2,Z)
    elements = enumerate_psl2z_elements(5)
    print(f"\nPSL(2,Z) elements up to word length 5: {len(elements)}")

    # Count by type
    types = {"hyperbolic": 0, "elliptic": 0, "parabolic": 0}
    for e in elements:
        types[e.classify()] += 1
    print(f"  Hyperbolic: {types['hyperbolic']}")
    print(f"  Elliptic: {types['elliptic']}")
    print(f"  Parabolic: {types['parabolic']}")

    # Zeta function
    norms = sorted(set(e.translation_length() for e in elements if e.translation_length() > 0.01))
    print(f"\nPartial hyperbolic zeta function ({len(norms)} terms):")
    for s in [1.0, 1.5, 2.0, 3.0]:
        z = partial_hyperbolic_zeta(norms, s)
        print(f"  ζ_H({s}) = {z:.6f}")
