"""
Hyperbolic Arithmetic: Core Algorithms
======================================

Type-hinted implementations of the key algorithms from the hyperbolic number theory
framework: SL₂(ℤ) arithmetic, Möbius transformations on the Poincaré disk,
orbit enumeration, and trace spectrum computation.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import List, Tuple, Set, Dict, Optional
import math
import cmath


@dataclass(frozen=True)
class SL2Z:
    """An element of SL₂(ℤ): a 2×2 integer matrix with determinant 1."""
    a: int
    b: int
    c: int
    d: int

    def __post_init__(self) -> None:
        assert self.a * self.d - self.b * self.c == 1, \
            f"Determinant must be 1, got {self.a * self.d - self.b * self.c}"

    @staticmethod
    def identity() -> SL2Z:
        return SL2Z(1, 0, 0, 1)

    def mul(self, other: SL2Z) -> SL2Z:
        return SL2Z(
            self.a * other.a + self.b * other.c,
            self.a * other.b + self.b * other.d,
            self.c * other.a + self.d * other.c,
            self.c * other.b + self.d * other.d,
        )

    def inv(self) -> SL2Z:
        return SL2Z(self.d, -self.b, -self.c, self.a)

    def trace(self) -> int:
        return self.a + self.d

    def is_hyperbolic(self) -> bool:
        return abs(self.trace()) > 2

    def is_parabolic(self) -> bool:
        return abs(self.trace()) == 2

    def is_elliptic(self) -> bool:
        return abs(self.trace()) < 2

    def mobius_act(self, z: complex) -> complex:
        """Apply the Möbius transformation g·z = (az+b)/(cz+d)."""
        num = self.a * z + self.b
        den = self.c * z + self.d
        if abs(den) < 1e-15:
            return complex(float('inf'), 0)
        return num / den

    def pow(self, n: int) -> SL2Z:
        """Compute g^n (n ≥ 0)."""
        if n == 0:
            return SL2Z.identity()
        if n < 0:
            return self.inv().pow(-n)
        result = SL2Z.identity()
        base = self
        while n > 0:
            if n % 2 == 1:
                result = result.mul(base)
            base = base.mul(base)
            n //= 2
        return result

    def __repr__(self) -> str:
        return f"SL2Z({self.a}, {self.b}, {self.c}, {self.d})"


# Standard generators
S = SL2Z(0, -1, 1, 0)
T = SL2Z(1, 1, 0, 1)


def hyperbolic_distance(z: complex, w: complex) -> float:
    """Compute the hyperbolic distance d(z,w) in the Poincaré disk model.
    
    d(z,w) = 2·artanh(|z-w|/|1-z̄w|)
    """
    if abs(z) >= 1 or abs(w) >= 1:
        return float('inf')
    num = abs(z - w)
    den = abs(1 - z.conjugate() * w)
    if den < 1e-15:
        return float('inf')
    tau = num / den
    if tau >= 1:
        return float('inf')
    return math.log((1 + tau) / (1 - tau))


def enumerate_orbit(generators: List[SL2Z], max_word_length: int) -> Dict[SL2Z, int]:
    """BFS enumeration of group elements by word length.
    
    Returns a dict mapping each element to its word length.
    """
    visited: Dict[SL2Z, int] = {SL2Z.identity(): 0}
    frontier: Set[SL2Z] = {SL2Z.identity()}
    
    all_gens = generators + [g.inv() for g in generators]
    
    for length in range(1, max_word_length + 1):
        new_frontier: Set[SL2Z] = set()
        for g in frontier:
            for gen in all_gens:
                product = g.mul(gen)
                if product not in visited:
                    visited[product] = length
                    new_frontier.add(product)
        frontier = new_frontier
        if not frontier:
            break
    
    return visited


def counting_function(base_point: complex, orbit: Dict[SL2Z, int], R: float) -> int:
    """Count orbit points within hyperbolic distance R of base_point."""
    count = 0
    for g in orbit:
        gz = g.mobius_act(base_point)
        if abs(gz) < 1:  # still in disk
            d = hyperbolic_distance(base_point, gz)
            if d <= R:
                count += 1
    return count


def chebyshev_trace_sequence(g: SL2Z, n_terms: int) -> List[int]:
    """Compute the trace sequence tr(g^0), tr(g^1), ..., tr(g^{n-1})
    using the Chebyshev recurrence: tr(g^{n+2}) = tr(g)·tr(g^{n+1}) - tr(g^n).
    """
    if n_terms == 0:
        return []
    traces = [2]  # tr(g^0) = 2
    if n_terms == 1:
        return traces
    traces.append(g.trace())  # tr(g^1) = tr(g)
    t = g.trace()
    for i in range(2, n_terms):
        traces.append(t * traces[-1] - traces[-2])
    return traces


def fricke_character(g: SL2Z, h: SL2Z) -> Tuple[int, int, int]:
    """Compute the Fricke character (tr(g), tr(h), tr(gh))."""
    return (g.trace(), h.trace(), g.mul(h).trace())


def vieta_involution(x: int, y: int, z: int) -> Tuple[int, int, int]:
    """Apply the Vieta involution on the Markov surface: (x,y,z) -> (x,y,xy-z)."""
    return (x, y, x * y - z)


def markov_tree(depth: int) -> List[Tuple[int, int, int]]:
    """Generate the Markov tree from the root triple using Vieta involutions.
    
    The Markov equation here is x² + y² + z² - xyz = κ.
    Starting from various roots, we apply all three Vieta involutions.
    """
    # Start from (1,1,2) which satisfies 1+1+4-2 = 4
    # Actually for the standard Markov equation x²+y²+z² = 3xyz,
    # (1,1,1) is the root with x²+y²+z²-3xyz = 0
    # Our equation is x²+y²+z² - xyz = κ, different normalization
    root = (3, 3, 3)  # 9+9+9-27 = 0, on standard Markov surface with κ=0
    
    triples: Set[Tuple[int, int, int]] = set()
    queue = [root]
    
    for _ in range(depth):
        new_queue = []
        for (x, y, z) in queue:
            # Three Vieta involutions
            for triple in [
                (x * y - z, x, y),
                (x, x * z - y, z),
                (x, y, y * z - x),
            ]:
                canonical = tuple(sorted(triple))
                if canonical not in triples and all(t > 0 for t in canonical):
                    triples.add(canonical)
                    new_queue.append(triple)
        queue = new_queue
    
    return sorted(triples)


def upper_half_to_disk(z: complex) -> complex:
    """Map from the upper half-plane to the Poincaré disk via the Cayley transform.
    
    w = (z - i) / (z + i)
    """
    i = complex(0, 1)
    return (z - i) / (z + i)


def disk_to_upper_half(w: complex) -> complex:
    """Map from the Poincaré disk to the upper half-plane (inverse Cayley).
    
    z = i(1 + w) / (1 - w)
    """
    i = complex(0, 1)
    return i * (1 + w) / (1 - w)


if __name__ == "__main__":
    # Quick demo
    print("=== SL₂(ℤ) Generators ===")
    print(f"S = {S}, trace = {S.trace()}, {'elliptic' if S.is_elliptic() else 'other'}")
    print(f"T = {T}, trace = {T.trace()}, {'parabolic' if T.is_parabolic() else 'other'}")
    
    ST = S.mul(T)
    print(f"ST = {ST}, trace = {ST.trace()}")
    print(f"Fricke character of (S,T) = {fricke_character(S, T)}")
    
    print("\n=== Chebyshev Trace Sequence for ST ===")
    traces = chebyshev_trace_sequence(ST, 10)
    print(f"tr((ST)^n) for n=0..9: {traces}")
    
    print("\n=== Orbit Enumeration ===")
    orbit = enumerate_orbit([S, T], max_word_length=4)
    print(f"Elements with word length ≤ 4: {len(orbit)}")
    
    print("\n=== Counting Function ===")
    for R in [1.0, 2.0, 3.0, 4.0, 5.0]:
        N = counting_function(complex(0, 0), orbit, R)
        ratio = N / math.exp(R) if R > 0 else 0
        print(f"N({R:.1f}) = {N}, N(R)/e^R = {ratio:.4f}, target 3/π ≈ {3/math.pi:.4f}")
