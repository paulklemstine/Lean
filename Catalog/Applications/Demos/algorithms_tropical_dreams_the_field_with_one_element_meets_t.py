#!/usr/bin/env python3
"""
Algorithms for Tropical 𝔽₁-Skeleton Extraction

Provides efficient algorithms for:
1. Extracting sup-irreducible (𝔽₁-point) elements from finite lattices
2. Computing 𝔽₁-cardinality
3. Verifying generation by extreme points
4. Computing the Birkhoff representation (lower sets of sup-irreducibles)
5. Möbius function computation for finite posets
"""

from typing import (
    TypeVar, Generic, List, Set, FrozenSet, Dict, Tuple, 
    Callable, Optional, Any
)
from functools import reduce
from itertools import combinations
from math import gcd

T = TypeVar('T')


class FiniteLattice(Generic[T]):
    """A finite lattice represented by its elements and join/meet operations.
    
    Attributes:
        elements: list of all lattice elements
        sup: binary supremum (join) operation
        inf: binary infimum (meet) operation
        bot: bottom element
        top: top element
        le: partial order relation
    """

    def __init__(
        self,
        elements: List[T],
        sup: Callable[[T, T], T],
        inf: Callable[[T, T], T],
        bot: T,
        top: T,
        le: Optional[Callable[[T, T], bool]] = None,
    ):
        self.elements = list(elements)
        self.sup = sup
        self.inf = inf
        self.bot = bot
        self.top = top
        if le is not None:
            self.le = le
        else:
            # Derive ≤ from inf: a ≤ b iff a ⊓ b = a
            self.le = lambda a, b: inf(a, b) == a

    def is_sup_irred(self, x: T) -> bool:
        """Check if x is sup-irreducible.
        
        An element x is sup-irreducible if:
        1. x is not minimal (x ≠ ⊥ in a bounded lattice)
        2. For all a, b: a ⊔ b = x implies a = x or b = x
        
        Time complexity: O(n²) where n = |elements|
        Space complexity: O(1) additional
        """
        if x == self.bot:
            return False
        for a in self.elements:
            for b in self.elements:
                if self.sup(a, b) == x and a != x and b != x:
                    return False
        return True

    def sup_irred_elements(self) -> List[T]:
        """Extract all sup-irreducible elements.
        
        Time complexity: O(n³) where n = |elements|
        Space complexity: O(k) where k = number of sup-irreducibles
        
        Returns:
            List of sup-irreducible elements, the '𝔽₁-points' of the lattice
        """
        return [x for x in self.elements if self.is_sup_irred(x)]

    def f1_cardinality(self) -> int:
        """Compute the 𝔽₁-cardinality = number of sup-irreducible elements.
        
        Time complexity: O(n³)
        """
        return len(self.sup_irred_elements())

    def sup_of_subset(self, subset: List[T]) -> T:
        """Compute the supremum of a subset."""
        if not subset:
            return self.bot
        return reduce(self.sup, subset)

    def verify_generation(self) -> bool:
        """Verify that every element is the sup of sup-irreducibles below it.
        
        This checks the generation theorem: for all x,
            x = ⊔ {e | e is sup-irreducible and e ≤ x}
        
        Time complexity: O(n³ + n·k) where k = #sup-irreducibles
        
        Returns:
            True if generation holds for all elements
        """
        irreds = self.sup_irred_elements()
        for x in self.elements:
            below = [e for e in irreds if self.le(e, x)]
            generated = self.sup_of_subset(below)
            if generated != x:
                return False
        return True

    def birkhoff_map(self, x: T) -> FrozenSet[T]:
        """Map x to its lower set of sup-irreducibles (Birkhoff representation).
        
        For a finite distributive lattice, this gives an order isomorphism
        to the lattice of lower sets of the poset of sup-irreducibles.
        
        Args:
            x: a lattice element
            
        Returns:
            The set {e | e is sup-irreducible and e ≤ x}
        """
        irreds = self.sup_irred_elements()
        return frozenset(e for e in irreds if self.le(e, x))

    def verify_birkhoff_bijection(self) -> bool:
        """Verify that the Birkhoff map is a bijection (injectivity check).
        
        Time complexity: O(n² · k)
        
        Returns:
            True if the Birkhoff map is injective (hence bijective onto its image)
        """
        images = {}
        for x in self.elements:
            img = self.birkhoff_map(x)
            if img in images:
                return False
            images[img] = x
        return True

    def mobius_function(self) -> Dict[Tuple[T, T], int]:
        """Compute the Möbius function μ(a, b) for all pairs.
        
        Uses the recursive definition:
            μ(a, a) = 1
            μ(a, b) = -Σ_{a ≤ c < b} μ(a, c)  for a < b
            μ(a, b) = 0  if a ≰ b
        
        Time complexity: O(n³)
        Space complexity: O(n²)
        """
        mu: Dict[Tuple[T, T], int] = {}
        for a in self.elements:
            for b in self.elements:
                if a == b:
                    mu[(a, b)] = 1
                elif self.le(a, b):
                    mu[(a, b)] = -sum(
                        mu.get((a, c), 0)
                        for c in self.elements
                        if self.le(a, c) and self.le(c, b) and c != b
                    )
                else:
                    mu[(a, b)] = 0
        return mu

    def euler_characteristic(self) -> int:
        """Compute the Euler characteristic via the Möbius function.
        
        Returns μ(⊥, ⊤) which equals the reduced Euler characteristic
        of the order complex of the proper part of the lattice, times (-1).
        """
        mu = self.mobius_function()
        return mu.get((self.bot, self.top), 0)


# ─────────────────────────────────────────────────────────────────────────────
# Factory functions for standard lattices
# ─────────────────────────────────────────────────────────────────────────────

def boolean_lattice(n: int) -> FiniteLattice[FrozenSet[int]]:
    """Create the Boolean lattice B_n = P({1,...,n}) under ⊆.
    
    Sup = union, inf = intersection.
    
    Args:
        n: size of the ground set
        
    Returns:
        FiniteLattice instance
        
    Example:
        >>> L = boolean_lattice(3)
        >>> L.f1_cardinality()
        3
    """
    ground = set(range(1, n + 1))
    elements = []
    for r in range(n + 1):
        for combo in combinations(sorted(ground), r):
            elements.append(frozenset(combo))
    
    return FiniteLattice(
        elements=elements,
        sup=lambda a, b: a | b,
        inf=lambda a, b: a & b,
        bot=frozenset(),
        top=frozenset(ground),
        le=lambda a, b: a <= b,
    )


def divisor_lattice(n: int) -> FiniteLattice[int]:
    """Create the divisor lattice of n under divisibility.
    
    Sup = lcm, inf = gcd.
    
    Args:
        n: positive integer
        
    Returns:
        FiniteLattice instance
        
    Example:
        >>> L = divisor_lattice(12)
        >>> L.sup_irred_elements()
        [2, 3, 4]
    """
    divs = sorted(d for d in range(1, n + 1) if n % d == 0)
    lcm_fn = lambda a, b: a * b // gcd(a, b)
    
    return FiniteLattice(
        elements=divs,
        sup=lcm_fn,
        inf=gcd,
        bot=1,
        top=n,
        le=lambda a, b: b % a == 0,
    )


def chain_lattice(n: int) -> FiniteLattice[int]:
    """Create the chain (total order) lattice {0, 1, ..., n}.
    
    Sup = max, inf = min.
    
    Args:
        n: maximum element
        
    Returns:
        FiniteLattice instance
    """
    return FiniteLattice(
        elements=list(range(n + 1)),
        sup=max,
        inf=min,
        bot=0,
        top=n,
        le=lambda a, b: a <= b,
    )


def product_lattice(
    L1: FiniteLattice, L2: FiniteLattice
) -> FiniteLattice[Tuple]:
    """Create the product of two finite lattices.
    
    Elements are pairs (a, b) with componentwise operations.
    """
    elements = [(a, b) for a in L1.elements for b in L2.elements]
    return FiniteLattice(
        elements=elements,
        sup=lambda x, y: (L1.sup(x[0], y[0]), L2.sup(x[1], y[1])),
        inf=lambda x, y: (L1.inf(x[0], y[0]), L2.inf(x[1], y[1])),
        bot=(L1.bot, L2.bot),
        top=(L1.top, L2.top),
        le=lambda x, y: L1.le(x[0], y[0]) and L2.le(x[1], y[1]),
    )


# ─────────────────────────────────────────────────────────────────────────────
# Optimized extraction for Boolean lattices
# ─────────────────────────────────────────────────────────────────────────────

def boolean_sup_irred_fast(n: int) -> List[FrozenSet[int]]:
    """Fast extraction of sup-irreducibles from B_n.
    
    By the theorem finset_supIrred_iff_singleton, these are exactly
    the singletons {1}, {2}, ..., {n}.
    
    Time complexity: O(n)
    Space complexity: O(n)
    """
    return [frozenset({i}) for i in range(1, n + 1)]


# ─────────────────────────────────────────────────────────────────────────────
# Example usage
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("=== Boolean Lattice B_4 ===")
    L = boolean_lattice(4)
    print(f"Elements: {len(L.elements)}")
    print(f"Sup-irreducibles: {[set(s) for s in L.sup_irred_elements()]}")
    print(f"F1-cardinality: {L.f1_cardinality()}")
    print(f"Generation verified: {L.verify_generation()}")
    print(f"Birkhoff bijection: {L.verify_birkhoff_bijection()}")
    print(f"Euler characteristic μ(⊥,⊤): {L.euler_characteristic()}")
    print()

    print("=== Divisor Lattice D_30 ===")
    L = divisor_lattice(30)
    print(f"Elements: {L.elements}")
    print(f"Sup-irreducibles: {L.sup_irred_elements()}")
    print(f"F1-cardinality: {L.f1_cardinality()}")
    print(f"Generation verified: {L.verify_generation()}")
    print(f"Birkhoff bijection: {L.verify_birkhoff_bijection()}")
    print()

    print("=== Chain Lattice C_4 ===")
    L = chain_lattice(4)
    print(f"Elements: {L.elements}")
    print(f"Sup-irreducibles: {L.sup_irred_elements()}")
    print(f"F1-cardinality: {L.f1_cardinality()}")
    print(f"Generation verified: {L.verify_generation()}")
    print()

    print("=== Product C_2 × C_2 ===")
    L = product_lattice(chain_lattice(2), chain_lattice(2))
    print(f"Elements: {L.elements}")
    print(f"Sup-irreducibles: {L.sup_irred_elements()}")
    print(f"F1-cardinality: {L.f1_cardinality()}")
    print(f"Generation verified: {L.verify_generation()}")
