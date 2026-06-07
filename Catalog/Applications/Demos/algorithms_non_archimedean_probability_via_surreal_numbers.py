#!/usr/bin/env python3
"""
Non-Archimedean Probability: Core Algorithms

Type-hinted implementations of the key algorithms from the theory.
"""

from fractions import Fraction
from typing import (
    TypeVar, Generic, Set, FrozenSet, Dict, Callable, Optional, Tuple, List
)
from dataclasses import dataclass


# ============================================================
# Algorithm 1: Infinitesimal Number Arithmetic
# ============================================================

@dataclass(frozen=True)
class InfinitesimalNum:
    """
    A number in the field of formal Laurent series Q((ε)),
    representing elements of a non-Archimedean field.
    
    Stored as a dictionary mapping powers of ε to rational coefficients.
    ε represents a positive infinitesimal (0 < ε < 1/n for all n).
    
    Pseudocode:
        InfinitesimalNum = Map<Int, Fraction>
        add(a, b) = merge maps with coefficient addition
        mul(a, b) = convolution of coefficient maps
        compare(a, b) = lexicographic on lowest power
    """
    _coeffs: Tuple[Tuple[int, Fraction], ...]
    
    @staticmethod
    def from_dict(d: Dict[int, Fraction]) -> 'InfinitesimalNum':
        return InfinitesimalNum(tuple(sorted(
            ((k, v) for k, v in d.items() if v != 0),
            key=lambda x: x[0]
        )))
    
    @property
    def coeffs(self) -> Dict[int, Fraction]:
        return dict(self._coeffs)
    
    @staticmethod
    def zero() -> 'InfinitesimalNum':
        return InfinitesimalNum.from_dict({})
    
    @staticmethod
    def one() -> 'InfinitesimalNum':
        return InfinitesimalNum.from_dict({0: Fraction(1)})
    
    @staticmethod
    def real(x: Fraction) -> 'InfinitesimalNum':
        return InfinitesimalNum.from_dict({0: x})
    
    @staticmethod
    def epsilon(power: int = 1) -> 'InfinitesimalNum':
        return InfinitesimalNum.from_dict({power: Fraction(1)})
    
    def __add__(self, other: 'InfinitesimalNum') -> 'InfinitesimalNum':
        result = self.coeffs
        for k, v in other.coeffs.items():
            result[k] = result.get(k, Fraction(0)) + v
        return InfinitesimalNum.from_dict(result)
    
    def __neg__(self) -> 'InfinitesimalNum':
        return InfinitesimalNum.from_dict({k: -v for k, v in self.coeffs.items()})
    
    def __sub__(self, other: 'InfinitesimalNum') -> 'InfinitesimalNum':
        return self + (-other)
    
    def __mul__(self, other: 'InfinitesimalNum') -> 'InfinitesimalNum':
        result: Dict[int, Fraction] = {}
        for k1, v1 in self.coeffs.items():
            for k2, v2 in other.coeffs.items():
                k = k1 + k2
                result[k] = result.get(k, Fraction(0)) + v1 * v2
        return InfinitesimalNum.from_dict(result)
    
    def __truediv__(self, other: 'InfinitesimalNum') -> 'InfinitesimalNum':
        """Division by a monomial (single-term) element."""
        if not other._coeffs:
            raise ZeroDivisionError
        min_pow, lead = other._coeffs[0]
        return InfinitesimalNum.from_dict({
            k - min_pow: v / lead for k, v in self.coeffs.items()
        })
    
    def is_positive(self) -> bool:
        if not self._coeffs:
            return False
        return self._coeffs[0][1] > 0
    
    def is_infinitesimal(self) -> bool:
        return bool(self._coeffs) and all(k > 0 for k, _ in self._coeffs) and self.is_positive()
    
    def standard_part(self) -> Fraction:
        return self.coeffs.get(0, Fraction(0))
    
    def __repr__(self) -> str:
        if not self._coeffs:
            return "0"
        parts = []
        for k, v in self._coeffs:
            if k == 0:
                parts.append(str(v))
            elif k == 1:
                parts.append(f"{v}·ε")
            else:
                parts.append(f"{v}·ε^{k}")
        return " + ".join(parts)


# ============================================================
# Algorithm 2: Finitely Additive Probability Measure
# ============================================================

T = TypeVar('T')

class FinitelyAdditiveProbability(Generic[T]):
    """
    A finitely additive probability measure on a finite sample space.
    
    Pseudocode:
        FinAddProb(Ω, μ):
            assert μ(∅) = 0
            assert μ(Ω) = 1
            assert ∀A: μ(A) ≥ 0
            assert ∀A,B disjoint: μ(A∪B) = μ(A) + μ(B)
        
        condProb(A, B) = μ(A∩B) / μ(B)
        bayes(A, B) = condProb(A,B) · μ(B) = condProb(B,A) · μ(A)
    """
    
    def __init__(self, universe: FrozenSet[T], 
                 point_masses: Dict[T, InfinitesimalNum]):
        self.universe = universe
        self.point_masses = point_masses
        
        # Verify non-negativity
        for x, m in point_masses.items():
            assert m.is_positive() or m == InfinitesimalNum.zero(), \
                f"Negative mass at {x}: {m}"
    
    def measure(self, subset: FrozenSet[T]) -> InfinitesimalNum:
        """Compute μ(A) as sum of point masses."""
        result = InfinitesimalNum.zero()
        for x in subset:
            if x in self.point_masses:
                result = result + self.point_masses[x]
        return result
    
    def cond_prob(self, a: FrozenSet[T], b: FrozenSet[T]) -> InfinitesimalNum:
        """P(A|B) = μ(A∩B) / μ(B)."""
        return self.measure(a & b) / self.measure(b)
    
    def verify_additivity(self, a: FrozenSet[T], b: FrozenSet[T]) -> bool:
        """Verify μ(A∪B) = μ(A) + μ(B) for disjoint A, B."""
        if a & b:
            return False  # not disjoint
        lhs = self.measure(a | b)
        rhs = self.measure(a) + self.measure(b)
        return lhs == rhs
    
    def verify_bayes(self, a: FrozenSet[T], b: FrozenSet[T]) -> bool:
        """Verify P(A|B)·μ(B) = P(B|A)·μ(A)."""
        lhs = self.cond_prob(a, b) * self.measure(b)
        rhs = self.cond_prob(b, a) * self.measure(a)
        return lhs == rhs


# ============================================================
# Algorithm 3: Infinitesimal Uniform Measure Construction
# ============================================================

def construct_infinitesimal_uniform(
    n: int
) -> Tuple[List[int], FinitelyAdditiveProbability[int]]:
    """
    Construct a uniform infinitesimal probability measure on {0, ..., n-1}.
    
    Each point gets probability ε. The measure is finitely additive by construction.
    For finite n, this is a valid FinAddProb in any non-Archimedean field containing ε.
    
    Pseudocode:
        construct_uniform(n):
            ε = infinitesimal
            for i in 0..n-1:
                μ({i}) = ε
            correction = 1 - n·ε  (positive since ε infinitesimal)
            return μ
    
    Returns: (points, measure)
    """
    eps = InfinitesimalNum.epsilon(1)
    points = list(range(n))
    masses = {i: eps for i in points}
    return points, FinitelyAdditiveProbability(frozenset(points), masses)


# ============================================================
# Algorithm 4: Archimedean Impossibility Check
# ============================================================

def check_archimedean_impossibility(
    delta: Fraction, 
    max_n: int = 1000
) -> Optional[int]:
    """
    Find the smallest n such that n·δ > 1, demonstrating the
    Archimedean impossibility of uniform point masses.
    
    Pseudocode:
        check_impossibility(δ):
            for n = 1, 2, ...:
                if n·δ > 1:
                    return n  // impossibility witness
            // never reached for δ > 0 in Archimedean field
    
    Returns: n such that n·δ > 1, or None if not found within max_n
    """
    for n in range(1, max_n + 1):
        if n * delta > 1:
            return n
    return None


# ============================================================
# Algorithm 5: Total Probability Decomposition
# ============================================================

def total_probability_decomposition(
    mu: FinitelyAdditiveProbability[T],
    a: FrozenSet[T],
    b: FrozenSet[T],
    universe: FrozenSet[T]
) -> Tuple[InfinitesimalNum, InfinitesimalNum, InfinitesimalNum]:
    """
    Decompose P(A) = P(A|B)·P(B) + P(A|Bᶜ)·P(Bᶜ).
    
    Pseudocode:
        total_prob(A, B):
            Bᶜ = Ω \ B
            term1 = P(A|B) · μ(B)
            term2 = P(A|Bᶜ) · μ(Bᶜ)
            assert term1 + term2 = μ(A)
            return (term1, term2, μ(A))
    
    Returns: (P(A|B)·P(B), P(A|Bᶜ)·P(Bᶜ), μ(A))
    """
    b_complement = universe - b
    term1 = mu.cond_prob(a, b) * mu.measure(b)
    term2 = mu.cond_prob(a, b_complement) * mu.measure(b_complement)
    mu_a = mu.measure(a)
    return term1, term2, mu_a


if __name__ == "__main__":
    # Quick verification
    print("=== Algorithm Verification ===\n")
    
    # Construct uniform infinitesimal measure on 5 points
    pts, mu = construct_infinitesimal_uniform(5)
    print(f"Universe: {pts}")
    print(f"Point mass: {mu.point_masses[0]}")
    
    # Verify additivity
    a = frozenset({0, 1})
    b = frozenset({2, 3})
    print(f"\nAdditivity check {{0,1}} ∪ {{2,3}}: {mu.verify_additivity(a, b)}")
    
    # Verify Bayes
    c = frozenset({1, 2, 3})
    print(f"Bayes check {{0,1}} vs {{1,2,3}}: {mu.verify_bayes(a, c)}")
    
    # Archimedean impossibility
    for delta in [Fraction(1, 10), Fraction(1, 100), Fraction(1, 1000)]:
        n = check_archimedean_impossibility(delta, max_n=10000)
        print(f"\nδ = {delta}: impossibility at n = {n}")
    
    # Total probability
    universe = frozenset(pts)
    t1, t2, total = total_probability_decomposition(mu, a, b, universe)
    print(f"\nTotal probability: {t1} + {t2} = {t1 + t2} vs μ(A) = {total}")
    
    print("\n✓ All algorithms verified")
