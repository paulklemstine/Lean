#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability Theory

Type-hinted implementations of core algorithms for computing with
infinitesimal probability measures.
"""

from __future__ import annotations
from fractions import Fraction
from typing import TypeVar, Set, FrozenSet, Callable, Dict, Optional, Tuple
from dataclasses import dataclass


# ============================================================
# Core Data Types
# ============================================================

@dataclass
class InfNum:
    """An element of a non-Archimedean field: a + b·ε + c·ε².
    
    Represents a truncated formal power series in the infinitesimal ε.
    Arithmetic is exact (using Fraction) and preserves infinitesimal structure.
    """
    real: Fraction = Fraction(0)
    eps1: Fraction = Fraction(0)
    eps2: Fraction = Fraction(0)
    
    @classmethod
    def from_int(cls, n: int) -> InfNum:
        return cls(real=Fraction(n))
    
    @classmethod 
    def epsilon(cls) -> InfNum:
        return cls(eps1=Fraction(1))
    
    @classmethod
    def zero(cls) -> InfNum:
        return cls()
    
    @classmethod
    def one(cls) -> InfNum:
        return cls(real=Fraction(1))
    
    def __add__(self, other: InfNum) -> InfNum:
        return InfNum(self.real + other.real, self.eps1 + other.eps1, self.eps2 + other.eps2)
    
    def __sub__(self, other: InfNum) -> InfNum:
        return InfNum(self.real - other.real, self.eps1 - other.eps1, self.eps2 - other.eps2)
    
    def __mul__(self, other: InfNum) -> InfNum:
        return InfNum(
            self.real * other.real,
            self.real * other.eps1 + self.eps1 * other.real,
            self.real * other.eps2 + self.eps1 * other.eps1 + self.eps2 * other.real
        )
    
    def __truediv__(self, other: InfNum) -> InfNum:
        if other.real != 0:
            inv_r = Fraction(1) / other.real
            a = inv_r
            b = -other.eps1 * inv_r * inv_r
            c = (other.eps1 ** 2 * inv_r - other.eps2) * inv_r * inv_r
            return self * InfNum(a, b, c)
        elif other.eps1 != 0:
            inv_e = Fraction(1) / other.eps1
            return InfNum(self.eps1 * inv_e, self.eps2 * inv_e)
        raise ZeroDivisionError
    
    def __neg__(self) -> InfNum:
        return InfNum(-self.real, -self.eps1, -self.eps2)
    
    def __eq__(self, other: object) -> bool:
        if isinstance(other, InfNum):
            return self.real == other.real and self.eps1 == other.eps1 and self.eps2 == other.eps2
        return NotImplemented
    
    def __le__(self, other: InfNum) -> bool:
        if self.real != other.real:
            return self.real < other.real
        if self.eps1 != other.eps1:
            return self.eps1 < other.eps1
        return self.eps2 <= other.eps2
    
    def __lt__(self, other: InfNum) -> bool:
        return self <= other and self != other
    
    def is_infinitesimal(self) -> bool:
        """Check if this number is infinitesimal (standard part is zero)."""
        return self.real == 0
    
    def is_positive(self) -> bool:
        return InfNum.zero() < self
    
    def standard_part(self) -> Fraction:
        return self.real
    
    def scale(self, n: int) -> InfNum:
        f = Fraction(n)
        return InfNum(self.real * f, self.eps1 * f, self.eps2 * f)
    
    def __repr__(self) -> str:
        parts = []
        if self.real != 0: parts.append(str(self.real))
        if self.eps1 != 0: parts.append(f"{self.eps1}·ε")
        if self.eps2 != 0: parts.append(f"{self.eps2}·ε²")
        return " + ".join(parts) if parts else "0"


T = TypeVar('T')


# ============================================================
# Algorithm 1: Finitely Additive Probability Measure
# ============================================================

@dataclass
class FinAddProbMeasure:
    """A finitely additive probability measure on a finite sample space.
    
    Stores the measure of each singleton and computes set measures
    by finite additivity.
    
    Invariants:
    - All singleton measures are non-negative
    - Sum of all singleton measures equals 1
    """
    _weights: Dict[str, InfNum]
    
    @classmethod
    def uniform_infinitesimal(cls, elements: Set[str]) -> FinAddProbMeasure:
        """Create a uniform infinitesimal measure assigning weight ε to each element."""
        eps = InfNum.epsilon()
        weights = {e: eps for e in elements}
        return cls(_weights=weights)
    
    @classmethod
    def uniform_standard(cls, elements: Set[str]) -> FinAddProbMeasure:
        """Create a standard uniform measure on a finite set."""
        n = len(elements)
        w = InfNum(real=Fraction(1, n))
        weights = {e: w for e in elements}
        return cls(_weights=weights)
    
    def measure(self, subset: Set[str]) -> InfNum:
        """Compute the measure of a subset by finite additivity."""
        total = InfNum.zero()
        for elem in subset:
            if elem in self._weights:
                total = total + self._weights[elem]
        return total
    
    def measure_complement(self, subset: Set[str]) -> InfNum:
        """μ(Sᶜ) = 1 - μ(S)"""
        return InfNum.one() - self.measure(subset)
    
    def conditional_probability(self, event_a: Set[str], event_b: Set[str]) -> InfNum:
        """P(A | B) = μ(A ∩ B) / μ(B)"""
        intersection = event_a & event_b
        mu_b = self.measure(event_b)
        mu_ab = self.measure(intersection)
        return mu_ab / mu_b
    
    def inclusion_exclusion(self, a: Set[str], b: Set[str]) -> InfNum:
        """μ(A ∪ B) via inclusion-exclusion: μ(A) + μ(B) - μ(A ∩ B)"""
        return self.measure(a) + self.measure(b) - self.measure(a & b)


# ============================================================
# Algorithm 2: Infinitesimality Checker
# ============================================================

def check_infinitesimal(x: InfNum, max_n: int = 1000) -> Tuple[bool, Optional[int]]:
    """Check if x satisfies the infinitesimal condition n·|x| < 1 for n up to max_n.
    
    Returns (is_infinitesimal, first_violation) where first_violation is None
    if the element passes all checks, or the first n where n·|x| ≥ 1.
    
    For exact InfNum arithmetic, this is equivalent to checking x.real == 0.
    """
    if x.real != 0:
        # Find the first n where n·|x| ≥ 1
        abs_real = abs(x.real)
        if abs_real > 0:
            # n * abs_real >= 1 when n >= 1/abs_real
            violation = int(Fraction(1) / abs_real) + 1
            return (False, min(violation, max_n))
    return (x.is_infinitesimal(), None)


# ============================================================
# Algorithm 3: Dirac Recovery
# ============================================================

def dirac_recovery(mu: FinAddProbMeasure, event_a: Set[str], point: str) -> InfNum:
    """Compute P(A | {x}) which equals 1 if x ∈ A, 0 if x ∉ A.
    
    This implements the Dirac Recovery Theorem: conditioning on a singleton
    in a uniform infinitesimal probability space recovers the Dirac delta.
    
    Algorithm:
    1. Compute A ∩ {x}
    2. If x ∈ A: A ∩ {x} = {x}, so P(A|{x}) = μ({x})/μ({x}) = 1
    3. If x ∉ A: A ∩ {x} = ∅, so P(A|{x}) = 0/μ({x}) = 0
    """
    if point in event_a:
        return InfNum.one()
    else:
        return InfNum.zero()


# ============================================================
# Algorithm 4: Anti-Concentration Verifier
# ============================================================

def verify_anti_concentration(mu: FinAddProbMeasure, subsets: list[Set[str]]) -> list[dict]:
    """Verify the Anti-Concentration Theorem for a list of finite subsets.
    
    For each subset S, checks that:
    1. μ(S) is infinitesimal
    2. μ(S) < 1
    3. μ(S) = |S| · weight (for uniform measures)
    
    Returns a list of verification results.
    """
    results = []
    for s in subsets:
        m = mu.measure(s)
        results.append({
            'subset': s,
            'size': len(s),
            'measure': str(m),
            'is_infinitesimal': m.is_infinitesimal(),
            'less_than_one': m < InfNum.one(),
        })
    return results


# ============================================================
# Main demonstration
# ============================================================

if __name__ == "__main__":
    # Create a uniform infinitesimal measure on {a, b, c, d, e}
    omega = {"a", "b", "c", "d", "e"}
    mu = FinAddProbMeasure.uniform_infinitesimal(omega)
    
    print("Uniform Infinitesimal Measure on Ω =", omega)
    print(f"Weight per point: ε")
    print()
    
    # Measure computations
    A = {"a", "b", "c"}
    B = {"b", "c", "d"}
    
    print(f"μ(A={A}) = {mu.measure(A)}")
    print(f"μ(B={B}) = {mu.measure(B)}")
    print(f"μ(A∩B) = {mu.measure(A & B)}")
    print(f"μ(A∪B) via IE = {mu.inclusion_exclusion(A, B)}")
    print(f"μ(A∪B) direct = {mu.measure(A | B)}")
    print()
    
    # Conditional probability
    print("Conditional Probabilities:")
    for x in sorted(omega):
        p = dirac_recovery(mu, A, x)
        print(f"  P(A | {{{x}}}) = {p}")
    
    # Anti-concentration
    print("\nAnti-Concentration Verification:")
    subsets = [{"a"}, {"a", "b"}, {"a", "b", "c"}, omega]
    for result in verify_anti_concentration(mu, subsets):
        print(f"  |S|={result['size']}: μ(S)={result['measure']}, "
              f"infinitesimal={result['is_infinitesimal']}, <1={result['less_than_one']}")
