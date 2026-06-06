#!/usr/bin/env python3
"""
Algorithms for Non-Archimedean Probability

Type-hinted implementations of the core algorithms from the formalized theory.
"""

from fractions import Fraction
from typing import FrozenSet, Set, TypeVar, Generic, Callable

T = TypeVar('T')


class SurrealElement:
    """
    A surreal-like number of the form a + b·ε where ε = 1/ω is infinitesimal.
    
    This is a first-order approximation of surreal numbers, sufficient for
    demonstrating the uniform infinitesimal measure construction.
    
    Attributes:
        standard: The standard (real) part
        infinitesimal: The coefficient of 1/ω
    """
    
    def __init__(self, standard: Fraction = Fraction(0),
                 infinitesimal: Fraction = Fraction(0)):
        self.standard = standard
        self.infinitesimal = infinitesimal
    
    def __add__(self, other: 'SurrealElement') -> 'SurrealElement':
        return SurrealElement(
            self.standard + other.standard,
            self.infinitesimal + other.infinitesimal
        )
    
    def __sub__(self, other: 'SurrealElement') -> 'SurrealElement':
        return SurrealElement(
            self.standard - other.standard,
            self.infinitesimal - other.infinitesimal
        )
    
    def __le__(self, other: 'SurrealElement') -> bool:
        if self.standard != other.standard:
            return self.standard < other.standard
        return self.infinitesimal <= other.infinitesimal
    
    def __lt__(self, other: 'SurrealElement') -> bool:
        if self.standard != other.standard:
            return self.standard < other.standard
        return self.infinitesimal < other.infinitesimal
    
    def scale(self, n: int) -> 'SurrealElement':
        """Compute n • self (scalar multiplication by natural number)."""
        return SurrealElement(self.standard * n, self.infinitesimal * n)
    
    def is_infinitesimal(self) -> bool:
        """Check if this element is a positive infinitesimal."""
        return self.standard == 0 and self.infinitesimal > 0
    
    def __repr__(self) -> str:
        parts = []
        if self.standard != 0:
            parts.append(str(self.standard))
        if self.infinitesimal != 0:
            if self.infinitesimal == 1:
                parts.append("ε")
            else:
                parts.append(f"{self.infinitesimal}ε")
        return " + ".join(parts) if parts else "0"


class UniformInfinitesimalMeasure:
    """
    A finitely additive measure assigning uniform infinitesimal weight to each point.
    
    Algorithm:
        μ(S) = |S| • ε
    
    Properties (all formally verified in Lean 4):
        - μ(∅) = 0
        - μ({x}) = ε > 0 for all x
        - μ(S ∪ T) = μ(S) + μ(T) for disjoint S, T
        - S ⊆ T → μ(S) ≤ μ(T)
        - μ(S) ≤ b for all finite S (when ε is infinitesimal w.r.t. b)
    """
    
    def __init__(self, weight: SurrealElement):
        """Initialize with infinitesimal weight ε."""
        if not weight.is_infinitesimal():
            raise ValueError("Weight must be a positive infinitesimal")
        self.weight = weight
    
    def measure(self, s: FrozenSet[T]) -> SurrealElement:
        """Compute μ(S) = |S| • ε."""
        return self.weight.scale(len(s))
    
    def measure_by_card(self, n: int) -> SurrealElement:
        """Compute μ for a set of cardinality n."""
        return self.weight.scale(n)
    
    def is_bounded_by(self, bound: SurrealElement, s: FrozenSet[T]) -> bool:
        """Check if μ(S) ≤ bound."""
        return self.measure(s) <= bound
    
    def complement_mass(self, total: SurrealElement, s: FrozenSet[T]) -> SurrealElement:
        """Compute remaining mass: total - μ(S)."""
        return total - self.measure(s)


def archimedean_witness(epsilon: float, bound: float) -> int:
    """
    Find the smallest n such that n·ε > bound.
    
    In an Archimedean ordered field, this always terminates.
    This algorithm witnesses the impossibility of infinitesimal
    probability in Archimedean settings.
    
    Algorithm:
        n ← ⌈bound/ε⌉ + 1
    
    Time complexity: O(1) (direct computation)
    
    Args:
        epsilon: A positive real number
        bound: The upper bound to exceed
    
    Returns:
        The smallest n with n·ε > bound
    """
    import math
    return math.ceil(bound / epsilon) + 1


def inclusion_exclusion_measure(
    weight: SurrealElement,
    s_card: int,
    t_card: int, 
    intersection_card: int
) -> SurrealElement:
    """
    Compute μ(S ∪ T) using inclusion-exclusion.
    
    μ(S ∪ T) = μ(S) + μ(T) - μ(S ∩ T)
             = |S|·ε + |T|·ε - |S ∩ T|·ε
             = (|S| + |T| - |S ∩ T|)·ε
    
    This is verified by the uniformFinsetMeasure_union theorem.
    """
    union_card = s_card + t_card - intersection_card
    return weight.scale(union_card)


def check_infinitesimal_property(
    element: SurrealElement,
    bound: SurrealElement,
    max_n: int = 10000
) -> bool:
    """
    Empirically check if element is additively infinitesimal w.r.t. bound.
    
    Tests n • element ≤ bound for n = 0, 1, ..., max_n.
    In a truly non-Archimedean setting, this holds for ALL n;
    we can only test finitely many.
    """
    for n in range(max_n + 1):
        if not element.scale(n) <= bound:
            return False
    return True


# Example usage
if __name__ == "__main__":
    # Create infinitesimal weight
    eps = SurrealElement(infinitesimal=Fraction(1))
    one = SurrealElement(standard=Fraction(1))
    
    # Create measure
    mu = UniformInfinitesimalMeasure(eps)
    
    # Demonstrate properties
    print("Uniform Infinitesimal Measure Demo")
    print(f"Weight: {eps}")
    print(f"μ(∅) = {mu.measure_by_card(0)}")
    print(f"μ({{x}}) = {mu.measure_by_card(1)}")
    print(f"μ(5 points) = {mu.measure_by_card(5)}")
    print(f"μ(1000 points) = {mu.measure_by_card(1000)}")
    print(f"μ(10⁶ points) ≤ 1? {mu.measure_by_card(10**6) <= one}")
    
    # Archimedean witness in ℝ
    for e in [0.1, 0.01, 0.001]:
        n = archimedean_witness(e, 1.0)
        print(f"\nArchimedean witness for ε={e}: n={n}, n·ε={n*e:.3f} > 1")
