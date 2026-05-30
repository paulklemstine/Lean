"""
Algorithms for Hyperbolic Number Theory
========================================

Implements the core algorithms from the research:
1. Einstein addition group operations
2. SL₂(ℤ) orbit enumeration
3. Chebyshev-trace computation
4. Hyperbolic prime detection
5. Trace counting and classification

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import List, Tuple, Dict, Optional, Set
from collections import defaultdict
import math


# ============================================================
# Algorithm 1: Einstein Addition Group
# ============================================================

class EinsteinGroup:
    """
    The Einstein velocity addition group on the open interval (-1, 1).

    Operations:
    - add(a, b): Einstein addition (a + b) / (1 + a*b)
    - neg(a): Group inverse -a
    - identity(): The identity element 0

    Time complexity: O(1) per operation
    Space complexity: O(1)

    Mathematical properties (all formally proved in Lean):
    - Commutativity: add(a, b) = add(b, a)
    - Associativity: add(add(a, b), c) = add(a, add(b, c))
    - Identity: add(a, 0) = a
    - Inverse: add(a, neg(a)) = 0
    - Closure: |a|, |b| < 1 => |add(a, b)| < 1
    """

    @staticmethod
    def add(a: float, b: float) -> float:
        """Einstein addition: (a + b) / (1 + a*b).
        Time: O(1), Space: O(1)"""
        return (a + b) / (1 + a * b)

    @staticmethod
    def neg(a: float) -> float:
        """Group inverse (negation).
        Time: O(1), Space: O(1)"""
        return -a

    @staticmethod
    def identity() -> float:
        """The identity element.
        Time: O(1), Space: O(1)"""
        return 0.0

    @staticmethod
    def is_in_interval(x: float) -> bool:
        """Check if x is in the open unit interval (-1, 1).
        Time: O(1), Space: O(1)"""
        return abs(x) < 1.0

    @staticmethod
    def rapidity(v: float) -> float:
        """The rapidity (artanh): isomorphism to (ℝ, +).
        artanh(v) = 0.5 * ln((1+v)/(1-v))
        Time: O(1), Space: O(1)"""
        return 0.5 * math.log((1 + v) / (1 - v))

    @staticmethod
    def from_rapidity(phi: float) -> float:
        """Inverse rapidity (tanh): ℝ → (-1, 1).
        Time: O(1), Space: O(1)"""
        return math.tanh(phi)

    @classmethod
    def iterated_add(cls, a: float, n: int) -> float:
        """Compute a ⊕ a ⊕ ... ⊕ a (n times).
        Uses the rapidity isomorphism for O(1) computation.
        Time: O(1), Space: O(1)"""
        if n == 0:
            return 0.0
        phi = cls.rapidity(a)
        return cls.from_rapidity(n * phi)


# ============================================================
# Algorithm 2: SL₂(ℤ) Matrix Operations
# ============================================================

class SL2ZElement:
    """
    An element of SL₂(ℤ): a 2×2 integer matrix with determinant 1.

    Time complexity: O(1) per operation (integer arithmetic)
    Space complexity: O(1) per element
    """

    def __init__(self, a: int, b: int, c: int, d: int):
        """Initialize with entries [a, b; c, d].
        Raises ValueError if determinant ≠ 1."""
        if a * d - b * c != 1:
            raise ValueError(f"Determinant must be 1, got {a * d - b * c}")
        self.a, self.b, self.c, self.d = a, b, c, d

    def __repr__(self) -> str:
        return f"[{self.a} {self.b}; {self.c} {self.d}]"

    def __eq__(self, other) -> bool:
        return (self.a, self.b, self.c, self.d) == (other.a, other.b, other.c, other.d)

    def __hash__(self) -> int:
        return hash((self.a, self.b, self.c, self.d))

    @staticmethod
    def identity() -> 'SL2ZElement':
        return SL2ZElement(1, 0, 0, 1)

    @staticmethod
    def S() -> 'SL2ZElement':
        """Generator S (inversion)."""
        return SL2ZElement(0, -1, 1, 0)

    @staticmethod
    def T() -> 'SL2ZElement':
        """Generator T (translation)."""
        return SL2ZElement(1, 1, 0, 1)

    @staticmethod
    def with_trace(t: int) -> 'SL2ZElement':
        """Construct an element with given trace.
        Uses the formula [t, 1; -1, 0] which has det = 1 and trace = t."""
        return SL2ZElement(t, 1, -1, 0)

    def mul(self, other: 'SL2ZElement') -> 'SL2ZElement':
        """Matrix multiplication. Time: O(1)"""
        return SL2ZElement(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d
        )

    def inv(self) -> 'SL2ZElement':
        """Matrix inverse. Time: O(1)"""
        return SL2ZElement(self.d, -self.b, -self.c, self.a)

    def trace(self) -> int:
        """Matrix trace. Time: O(1)"""
        return self.a + self.d

    def classify(self) -> str:
        """Classify as elliptic/parabolic/hyperbolic by trace."""
        t = abs(self.trace())
        if t < 2:
            return "elliptic"
        elif t == 2:
            return "parabolic"
        else:
            return "hyperbolic"

    def entry_norm(self) -> int:
        """Max absolute value of entries."""
        return max(abs(self.a), abs(self.b), abs(self.c), abs(self.d))


# ============================================================
# Algorithm 3: Chebyshev-Trace Computation
# ============================================================

def chebyshev_trace(t: int, n: int) -> int:
    """
    Compute tr(Aⁿ) where tr(A) = t, using the Chebyshev recurrence:
        T₀ = 2, T₁ = t, Tₙ₊₂ = t·Tₙ₊₁ - Tₙ

    Time complexity: O(n)
    Space complexity: O(1)

    Args:
        t: Initial trace value (trace of A)
        n: Power to compute

    Returns:
        The trace of Aⁿ
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


def chebyshev_trace_sequence(t: int, max_n: int) -> List[int]:
    """
    Compute the full Chebyshev trace sequence up to power max_n.

    Time complexity: O(max_n)
    Space complexity: O(max_n)
    """
    result = [2]
    if max_n == 0:
        return result
    result.append(t)
    for i in range(2, max_n + 1):
        result.append(t * result[-1] - result[-2])
    return result


# ============================================================
# Algorithm 4: SL₂(ℤ) Orbit Enumeration
# ============================================================

def enumerate_sl2z_by_norm(max_norm: int) -> List[SL2ZElement]:
    """
    Enumerate all SL₂(ℤ) elements with entry norm ≤ max_norm.

    Time complexity: O(max_norm⁴) (brute force over 4 entries)
    Space complexity: O(max_norm²) (number of valid elements)
    """
    elements = []
    for a in range(-max_norm, max_norm + 1):
        for b in range(-max_norm, max_norm + 1):
            for c in range(-max_norm, max_norm + 1):
                for d in range(-max_norm, max_norm + 1):
                    if a * d - b * c == 1:
                        elements.append(SL2ZElement(a, b, c, d))
    return elements


def count_by_trace(elements: List[SL2ZElement]) -> Dict[int, int]:
    """Count elements by trace value."""
    counts: Dict[int, int] = defaultdict(int)
    for e in elements:
        counts[e.trace()] += 1
    return dict(sorted(counts.items()))


def classify_traces(max_T: int) -> Dict[str, List[int]]:
    """
    Classify all integer traces in [-T, T] by geometric type.

    Time complexity: O(T)
    Space complexity: O(T)
    """
    result: Dict[str, List[int]] = {"elliptic": [], "parabolic": [], "hyperbolic": []}
    for t in range(-max_T, max_T + 1):
        abs_t = abs(t)
        if abs_t < 2:
            result["elliptic"].append(t)
        elif abs_t == 2:
            result["parabolic"].append(t)
        else:
            result["hyperbolic"].append(t)
    return result


# ============================================================
# Algorithm 5: Hyperbolic Prime Detection
# ============================================================

def is_prime_trace(t: int, max_power: int = 20) -> bool:
    """
    Check if trace t corresponds to a primitive hyperbolic element.

    A trace t is "prime" if:
    1. |t| > 2 (hyperbolic)
    2. t is not in the range of chebyshev_trace(t₀, n) for any
       |t₀| < |t| and n ≥ 2.

    Time complexity: O(max_power * |t|)
    Space complexity: O(1)
    """
    if abs(t) <= 2:
        return False  # Not hyperbolic

    for t0 in range(-abs(t) + 1, abs(t)):
        for n in range(2, max_power + 1):
            if chebyshev_trace(t0, n) == t:
                return False
    return True


def find_prime_traces(max_T: int, max_power: int = 20) -> List[int]:
    """Find all prime traces in [3, T]."""
    return [t for t in range(3, max_T + 1) if is_prime_trace(t, max_power)]


# ============================================================
# Algorithm 6: Hilbert-Tropical Bridge
# ============================================================

def hilbert_metric_interval(p: float, q: float) -> float:
    """
    Hilbert metric on the unit interval (0, 1).
    d_H(p, q) = |log(p(1-q) / (q(1-p)))|

    Time: O(1), Space: O(1)
    """
    if p <= 0 or p >= 1 or q <= 0 or q >= 1:
        return float('inf')
    return abs(math.log(p * (1 - q) / (q * (1 - p))))


def tropical_distance(x: float, y: float) -> float:
    """
    Tropical distance: |x - y| in the max-plus algebra.

    Time: O(1), Space: O(1)
    """
    return abs(x - y)


def cayley_transform(s: complex) -> complex:
    """
    Cayley transform: s ↦ (s - 1) / (s + 1).
    Maps Re(s) = 1/2 into the unit disk.

    Time: O(1), Space: O(1)
    """
    return (s - 1) / (s + 1)


# ============================================================
# Example Usage
# ============================================================

if __name__ == "__main__":
    # Einstein group
    eg = EinsteinGroup()
    print("Einstein addition: 0.6 ⊕ 0.8 =", eg.add(0.6, 0.8))
    print("Rapidity: artanh(0.6) =", eg.rapidity(0.6))
    print("Iterated: 0.5 ⊕ 0.5 ⊕ 0.5 =", eg.iterated_add(0.5, 3))

    # Chebyshev traces
    print("\nChebyshev trace sequence for t=3:")
    print(chebyshev_trace_sequence(3, 8))

    # Prime traces
    primes = find_prime_traces(20)
    print(f"\nPrime traces up to 20: {primes}")

    # Orbit counting
    elements = enumerate_sl2z_by_norm(3)
    print(f"\nSL₂(ℤ) elements with norm ≤ 3: {len(elements)}")
    trace_counts = count_by_trace(elements)
    print(f"Trace distribution: {trace_counts}")
