#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for Hyperbolic Number Theory

Implements:
1. BerggrenTree: Complete enumeration of primitive Pythagorean triples
2. VelocityGroup: Relativistic velocity addition as an abelian group
3. LorentzChecker: Verification of Lorentz form invariance
4. PythagoreanCounter: Efficient counting function with caching
"""

from math import gcd, sqrt, pi, atanh, tanh, log
from typing import Tuple, List, Optional, Generator
from collections import defaultdict

Triple = Tuple[int, int, int]


class BerggrenTree:
    """
    The Berggren ternary tree of primitive Pythagorean triples.
    
    Every primitive Pythagorean triple appears exactly once as a node
    in this infinite ternary tree, rooted at (3, 4, 5).
    
    The three children of (a, b, c) are given by:
      A: (a - 2b + 2c, 2a - b + 2c, 2a - 2b + 3c)
      B: (a + 2b + 2c, 2a + b + 2c, 2a + 2b + 3c)
      C: (-a + 2b + 2c, -2a + b + 2c, -2a + 2b + 3c)
    
    Time complexity: O(N) to enumerate all triples with hyp ≤ N
    Space complexity: O(N) for the result list
    """
    
    ROOT = (3, 4, 5)
    
    @staticmethod
    def child_A(a: int, b: int, c: int) -> Triple:
        """Apply Berggren matrix A."""
        return (a - 2*b + 2*c, 2*a - b + 2*c, 2*a - 2*b + 3*c)
    
    @staticmethod
    def child_B(a: int, b: int, c: int) -> Triple:
        """Apply Berggren matrix B."""
        return (a + 2*b + 2*c, 2*a + b + 2*c, 2*a + 2*b + 3*c)
    
    @staticmethod
    def child_C(a: int, b: int, c: int) -> Triple:
        """Apply Berggren matrix C."""
        return (-a + 2*b + 2*c, -2*a + b + 2*c, -2*a + 2*b + 3*c)
    
    @classmethod
    def children(cls, triple: Triple) -> List[Triple]:
        """Return all three children of a triple."""
        a, b, c = triple
        return [cls.child_A(a, b, c), cls.child_B(a, b, c), cls.child_C(a, b, c)]
    
    @classmethod
    def enumerate(cls, max_hyp: int) -> List[Triple]:
        """
        Enumerate all primitive Pythagorean triples with hypotenuse ≤ max_hyp.
        
        Uses depth-first traversal with pruning (children always have
        larger hypotenuse, so we can stop when hyp > max_hyp).
        
        Args:
            max_hyp: Maximum hypotenuse value
            
        Returns:
            Sorted list of primitive Pythagorean triples
        """
        result = []
        stack = [cls.ROOT]
        while stack:
            triple = stack.pop()
            a, b, c = triple
            if c <= max_hyp:
                result.append(triple)
                stack.extend(cls.children(triple))
        return sorted(result, key=lambda t: (t[2], t[0]))
    
    @classmethod
    def enumerate_generator(cls, max_hyp: int) -> Generator[Triple, None, None]:
        """Memory-efficient generator version of enumerate."""
        stack = [cls.ROOT]
        while stack:
            triple = stack.pop()
            a, b, c = triple
            if c <= max_hyp:
                yield triple
                stack.extend(cls.children(triple))
    
    @classmethod
    def at_depth(cls, depth: int) -> List[Triple]:
        """Return all triples at a given depth in the tree."""
        if depth == 0:
            return [cls.ROOT]
        parents = cls.at_depth(depth - 1)
        return [child for p in parents for child in cls.children(p)]
    
    @classmethod
    def path_to_triple(cls, path: str) -> Triple:
        """
        Evaluate a Berggren path string like 'ABC' starting from root.
        
        Args:
            path: String of characters A, B, C
            
        Returns:
            The triple at the end of the path
        """
        triple = cls.ROOT
        for direction in path:
            a, b, c = triple
            if direction == 'A':
                triple = cls.child_A(a, b, c)
            elif direction == 'B':
                triple = cls.child_B(a, b, c)
            elif direction == 'C':
                triple = cls.child_C(a, b, c)
            else:
                raise ValueError(f"Invalid direction: {direction}")
        return triple
    
    @staticmethod
    def verify_pythagorean(triple: Triple) -> bool:
        """Check if a² + b² = c²."""
        a, b, c = triple
        return a**2 + b**2 == c**2
    
    @staticmethod
    def verify_primitive(triple: Triple) -> bool:
        """Check if gcd(a, b) = 1."""
        a, b, c = triple
        return gcd(abs(a), abs(b)) == 1
    
    @staticmethod
    def lorentz_form(triple: Triple) -> int:
        """Compute Q(a,b,c) = a² + b² - c²."""
        a, b, c = triple
        return a**2 + b**2 - c**2


class VelocityGroup:
    """
    The relativistic velocity addition group on (-1, 1).
    
    This implements the group operation β₁ ⊕ β₂ = (β₁ + β₂)/(1 + β₁β₂),
    which makes the open interval (-1, 1) into an abelian group isomorphic
    to (ℝ, +) via the map β ↦ arctanh(β).
    
    Connection to Pythagorean triples: every triple (a, b, c) gives a
    rational velocity β = a/c ∈ (-1, 1).
    """
    
    @staticmethod
    def add(beta1: float, beta2: float) -> float:
        """Relativistic velocity addition."""
        return (beta1 + beta2) / (1 + beta1 * beta2)
    
    @staticmethod
    def inverse(beta: float) -> float:
        """Additive inverse in the velocity group: -β."""
        return -beta
    
    @staticmethod
    def identity() -> float:
        """Identity element: 0."""
        return 0.0
    
    @classmethod
    def compose_many(cls, velocities: List[float]) -> float:
        """Compose a list of velocities via relativistic addition."""
        result = 0.0
        for v in velocities:
            result = cls.add(result, v)
        return result
    
    @staticmethod
    def to_rapidity(beta: float) -> float:
        """Convert velocity to rapidity: φ = arctanh(β)."""
        if abs(beta) >= 1:
            raise ValueError(f"|β| must be < 1, got {beta}")
        return atanh(beta)
    
    @staticmethod
    def from_rapidity(phi: float) -> float:
        """Convert rapidity to velocity: β = tanh(φ)."""
        return tanh(phi)
    
    @classmethod
    def verify_associativity(cls, b1: float, b2: float, b3: float, 
                              tol: float = 1e-14) -> bool:
        """Check (b1 ⊕ b2) ⊕ b3 = b1 ⊕ (b2 ⊕ b3)."""
        lhs = cls.add(cls.add(b1, b2), b3)
        rhs = cls.add(b1, cls.add(b2, b3))
        return abs(lhs - rhs) < tol
    
    @staticmethod
    def from_triple(triple: Triple) -> float:
        """Extract a velocity from a Pythagorean triple: β = a/c."""
        a, _, c = triple
        return a / c


class PythagoreanCounter:
    """
    Efficient counting of primitive Pythagorean triples.
    
    Uses Berggren tree enumeration with caching for repeated queries.
    """
    
    def __init__(self):
        self._cache = {}
    
    def count(self, N: int) -> int:
        """Count primitive triples with hypotenuse < N."""
        if N in self._cache:
            return self._cache[N]
        result = sum(1 for _ in BerggrenTree.enumerate_generator(N - 1))
        self._cache[N] = result
        return result
    
    def count_by_hypotenuse(self, max_hyp: int) -> dict:
        """Return a dict mapping hypotenuse → number of triples with that hypotenuse."""
        counts = defaultdict(int)
        for _, _, c in BerggrenTree.enumerate_generator(max_hyp):
            counts[c] += 1
        return dict(sorted(counts.items()))
    
    def lehmer_ratio(self, N: int) -> float:
        """Compute pythCount(N) / (N/(2π))."""
        count = self.count(N)
        expected = N / (2 * pi)
        return count / expected if expected > 0 else 0
    
    def verify_conjecture(self, N: int) -> bool:
        """Check if pythCount(N) ≥ N/7 for N ≥ 100."""
        if N < 100:
            return True  # Conjecture only claims for N ≥ 100
        return self.count(N) >= N // 7


class LorentzChecker:
    """
    Verification utilities for Lorentz form invariance.
    """
    
    @staticmethod
    def verify_preservation(triple: Triple, depth: int = 3) -> bool:
        """
        Verify that Q is preserved for all descendants up to given depth.
        
        Returns True if Q(child) = Q(parent) for all descendants.
        """
        Q_orig = BerggrenTree.lorentz_form(triple)
        
        current_level = [triple]
        for _ in range(depth):
            next_level = []
            for t in current_level:
                for child in BerggrenTree.children(t):
                    if BerggrenTree.lorentz_form(child) != Q_orig:
                        return False
                    next_level.append(child)
            current_level = next_level
        return True
    
    @staticmethod
    def verify_parity(triple: Triple) -> dict:
        """
        Check parity properties of a Pythagorean triple.
        
        Returns dict with parity analysis.
        """
        a, b, c = triple
        return {
            'triple': triple,
            'a_even': a % 2 == 0,
            'b_even': b % 2 == 0,
            'c_odd': c % 2 == 1,
            'exactly_one_even_leg': (a % 2 == 0) != (b % 2 == 0),
            'is_primitive': gcd(abs(a), abs(b)) == 1,
            'is_pythagorean': a**2 + b**2 == c**2,
        }


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Berggren Tree
    print("Berggren Tree — first 10 triples:")
    for t in BerggrenTree.enumerate(30):
        Q = BerggrenTree.lorentz_form(t)
        print(f"  {t}  Q={Q}  prim={BerggrenTree.verify_primitive(t)}")
    
    # Velocity Group
    print("\nVelocity Group:")
    vg = VelocityGroup()
    for path in ["", "A", "B", "C", "AA", "AB"]:
        t = BerggrenTree.path_to_triple(path)
        beta = vg.from_triple(t)
        rapidity = vg.to_rapidity(beta)
        print(f"  Path '{path}': {t} → β={beta:.4f}, φ={rapidity:.4f}")
    
    # Pythagorean Counting
    print("\nPythagorean Counting:")
    counter = PythagoreanCounter()
    for N in [100, 500, 1000, 5000]:
        count = counter.count(N)
        ratio = counter.lehmer_ratio(N)
        conj = counter.verify_conjecture(N)
        print(f"  N={N:5d}: count={count:4d}, ratio={ratio:.4f}, conjecture={conj}")
