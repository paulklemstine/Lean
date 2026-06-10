#!/usr/bin/env python3
"""
Markov-Trace Dynamics: Core Algorithms

Type-hinted implementations of the key algorithms from
the Markov-Trace Dynamics research.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Iterator
import math


# ============================================================
# Algorithm 1: Chebyshev Trace Computation
# ============================================================

def cheb_trace(t: int, n: int) -> int:
    """Compute chebTrace(t, n) in O(n) time using the linear recurrence.

    Pseudocode:
        T[0] = 2, T[1] = t
        for i = 2..n: T[i] = t * T[i-1] - T[i-2]
        return T[n]

    This computes tr(A^n) for any A in SL₂(ℤ) with tr(A) = t.
    """
    if n == 0:
        return 2
    if n == 1:
        return t
    prev, curr = 2, t
    for _ in range(n - 1):
        prev, curr = curr, t * curr - prev
    return curr


def cheb_trace_fast(t: int, n: int) -> int:
    """Compute chebTrace(t, n) in O(log n) time using the doubling formula.

    Uses the identities:
        T(2k) = T(k)² - 2
        T(2k+1) = T(k+1) * T(k) - t  (variant of addition formula)

    Pseudocode:
        If n == 0: return 2
        Write n in binary. Starting from T(1) = t, T(0) = 2,
        repeatedly apply doubling formulas following the bit pattern.
    """
    if n == 0:
        return 2
    if n == 1:
        return t

    # Use matrix exponentiation via the companion matrix
    # [[t, -1], [1, 0]]^n gives [[T(n+1), -T(n)], [T(n), -T(n-1)]]
    # But we can do it with scalar recurrence using doubling:
    # T(2k) = T(k)^2 - 2
    # T(2k+1) = t * T(k)^2 - T(k) * T(k-1) - t  ... complex
    # Simpler: use the pair (T(k), T(k+1)) and double
    def double_step(tk: int, tk1: int) -> tuple[int, int]:
        """(T(k), T(k+1)) -> (T(2k), T(2k+1))"""
        t2k = tk * tk - 2
        t2k1 = tk1 * tk - t
        return t2k, t2k1

    def double_step_odd(tk: int, tk1: int) -> tuple[int, int]:
        """(T(k), T(k+1)) -> (T(2k+1), T(2k+2))"""
        t2k1 = tk1 * tk - t
        t2k2 = tk1 * tk1 - 2
        return t2k1, t2k2

    # Binary expansion of n
    bits = bin(n)[2:]  # e.g., '101' for n=5

    a, b = 2, t  # T(0), T(1)
    for bit in bits[1:]:
        if bit == '0':
            a, b = double_step(a, b)
        else:
            a, b = double_step_odd(a, b)
    return a


# ============================================================
# Algorithm 2: Markov Tree Generation
# ============================================================

@dataclass(frozen=True)
class MarkovTriple:
    """A solution (x, y, z) to x² + y² + z² = 3xyz with x ≤ y ≤ z."""
    x: int
    y: int
    z: int

    def __post_init__(self):
        assert self.x <= self.y <= self.z
        assert self.x**2 + self.y**2 + self.z**2 == 3 * self.x * self.y * self.z

    def vieta_up(self) -> MarkovTriple:
        """Apply ascending Vieta: replace x with 3yz - x."""
        new_val = 3 * self.y * self.z - self.x
        return MarkovTriple(*sorted([new_val, self.y, self.z]))

    def vieta_children(self) -> list[MarkovTriple]:
        """Generate all three Vieta children."""
        children = set()
        for vals in [
            (3*self.y*self.z - self.x, self.y, self.z),
            (self.x, 3*self.x*self.z - self.y, self.z),
            (self.x, self.y, 3*self.x*self.y - self.z),
        ]:
            t = tuple(sorted(vals))
            if t[0] >= 1:  # Only positive triples
                children.add(MarkovTriple(*t))
        return list(children)


def generate_markov_triples(max_depth: int = 10) -> Iterator[MarkovTriple]:
    """BFS generation of the Markov tree.

    Pseudocode:
        Start with (1, 1, 1)
        BFS queue, at each node generate 3 Vieta children
        Skip duplicates and parent nodes
        Yield new triples in BFS order
    """
    root = MarkovTriple(1, 1, 1)
    visited: set[MarkovTriple] = set()
    queue = [root]

    for _ in range(max_depth):
        next_queue = []
        for triple in queue:
            if triple in visited:
                continue
            visited.add(triple)
            yield triple
            for child in triple.vieta_children():
                if child not in visited:
                    next_queue.append(child)
        queue = next_queue


# ============================================================
# Algorithm 3: Trace Orbit Signature
# ============================================================

@dataclass
class TraceOrbitSignature:
    """The trace orbit signature of a hyperbolic SL₂ element.

    Captures the spectral shadow: the complete sequence n ↦ tr(A^n).
    Determined entirely by the trace parameter t = tr(A).
    """
    trace_param: int

    def __post_init__(self):
        if abs(self.trace_param) < 3:
            raise ValueError(f"Trace parameter {self.trace_param} is not hyperbolic (need |t| ≥ 3)")

    def eval(self, n: int) -> int:
        """Compute the n-th value of the signature."""
        return cheb_trace(self.trace_param, n)

    def growth_rate(self) -> float:
        """Return the dominant eigenvalue (asymptotic growth rate)."""
        t = self.trace_param
        return (t + math.sqrt(t**2 - 4)) / 2

    def signature(self, length: int = 10) -> list[int]:
        """Return the first `length` values of the signature."""
        return [self.eval(n) for n in range(length)]

    def lower_bound(self, n: int) -> int:
        """Return the exponential lower bound (t-1)^n."""
        return (self.trace_param - 1) ** n


# ============================================================
# Algorithm 4: Fricke Surface Exploration
# ============================================================

def fricke_kappa(x: int, y: int, z: int) -> int:
    """Compute the Fricke invariant κ = x² + y² + z² - xyz."""
    return x**2 + y**2 + z**2 - x * y * z


def fricke_vieta(x: int, y: int, z: int) -> tuple[int, int, int]:
    """Apply the Fricke-Vieta involution: (x,y,z) → (x, y, xy-z)."""
    return (x, y, x * y - z)


def find_fricke_triples(kappa: int, bound: int = 100) -> list[tuple[int, int, int]]:
    """Find integer triples on the Fricke surface x²+y²+z²-xyz = κ.

    Brute-force search within [-bound, bound]³.
    """
    triples = []
    for x in range(-bound, bound + 1):
        for y in range(x, bound + 1):
            for z in range(y, bound + 1):
                if x**2 + y**2 + z**2 - x*y*z == kappa:
                    triples.append((x, y, z))
    return triples


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Test fast vs slow chebTrace
    print("Verifying fast chebTrace vs linear recurrence:")
    for t in [3, 5, 7, 10]:
        for n in range(20):
            slow = cheb_trace(t, n)
            fast = cheb_trace_fast(t, n)
            assert slow == fast, f"Mismatch at t={t}, n={n}: {slow} vs {fast}"
        print(f"  t={t}: all match for n=0..19 ✓")

    print()
    print("Markov triples (first 15):")
    for i, triple in enumerate(generate_markov_triples(8)):
        if i >= 15:
            break
        print(f"  {triple}")

    print()
    print("Trace orbit signatures:")
    for t in [3, 4, 5]:
        sig = TraceOrbitSignature(t)
        print(f"  t={t}: {sig.signature(8)}")
        print(f"    Growth rate: {sig.growth_rate():.4f}")
        print(f"    Lower bounds: {[sig.lower_bound(n) for n in range(8)]}")

    print()
    print("Fricke surface triples for κ = 4 (first 10):")
    for triple in find_fricke_triples(4, 20)[:10]:
        print(f"  {triple}: κ = {fricke_kappa(*triple)}")
