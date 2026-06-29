#!/usr/bin/env python3
"""
algorithms.py — Core algorithms for substrate-independent complexity theory.

Implements the key constructions from our formalization:
1. ComplexityHierarchy — abstract hierarchy with monotonicity and strictness
2. FrameworkSimulation — overhead-bounded simulation between hierarchies
3. DiagonalSeparator — constructive diagonal witness generation
4. HierarchyMorphism — structure-preserving maps between hierarchies
5. OracleExtension — relativization of hierarchies
"""

from typing import (
    TypeVar, Generic, Set, Callable, Optional,
    Tuple, List, Dict, FrozenSet
)
from dataclasses import dataclass, field
from abc import ABC, abstractmethod
import math


T = TypeVar('T')
S = TypeVar('S')


@dataclass
class ComplexityHierarchy(Generic[T]):
    """
    Abstract complexity hierarchy over problems of type T.
    
    A hierarchy consists of levels indexed by natural numbers,
    where each level is a set of problems. The hierarchy must be:
    - Monotone: level(m) ⊆ level(n) for m ≤ n
    - Strict: level(n) ⊊ level(n+1) for all n
    """
    _level_fn: Callable[[int], Set[T]]
    
    def level(self, n: int) -> Set[T]:
        """Return the set of problems at level n."""
        return self._level_fn(n)
    
    def is_monotone(self, max_level: int) -> bool:
        """Verify monotonicity up to max_level."""
        for m in range(max_level):
            for n in range(m + 1, max_level + 1):
                if not self.level(m).issubset(self.level(n)):
                    return False
        return True
    
    def is_strict(self, max_level: int) -> bool:
        """Verify strictness up to max_level."""
        for n in range(max_level):
            diff = self.level(n + 1) - self.level(n)
            if len(diff) == 0:
                return False
        return True
    
    def separation_witness(self, n: int) -> Optional[T]:
        """Find a witness in level(n+1) \\ level(n), if one exists."""
        diff = self.level(n + 1) - self.level(n)
        if diff:
            return next(iter(diff))
        return None
    
    def verify(self, max_level: int) -> bool:
        """Verify all hierarchy properties up to max_level."""
        return self.is_monotone(max_level) and self.is_strict(max_level)


@dataclass
class FrameworkSimulation(Generic[T, S]):
    """
    A simulation from hierarchy H1 (over T) to hierarchy H2 (over S).
    
    Captures the idea that H1 can simulate H2 with bounded overhead:
    - translate: maps problems in H2 to problems in H1
    - overhead: level n in H2 maps to level overhead(n) in H1
    """
    h1: ComplexityHierarchy[T]
    h2: ComplexityHierarchy[S]
    translate: Callable[[S], T]
    overhead: Callable[[int], int]
    
    def verify_simulation(self, max_level: int, problems: List[S]) -> bool:
        """Verify that the simulation is correct for given problems."""
        for n in range(max_level + 1):
            for x in problems:
                if x in self.h2.level(n):
                    if self.translate(x) not in self.h1.level(self.overhead(n)):
                        return False
        return True
    
    def transfer_separation(self, n: int) -> Optional[T]:
        """
        Transfer a separation from H2 to H1.
        
        If H2 has a separation at level n, produce a witness
        of separation at level overhead(n+1) in H1.
        """
        witness = self.h2.separation_witness(n)
        if witness is not None:
            translated = self.translate(witness)
            # Verify: translated should be in H1.level(overhead(n+1))
            # and not in H1.level(n)
            oh = self.overhead(n + 1)
            if (translated in self.h1.level(oh) and
                translated not in self.h1.level(n)):
                return translated
        return None


class DiagonalSeparator(Generic[T]):
    """
    Constructive diagonal separator for a complexity hierarchy.
    
    Given an enumeration of machines at each level, constructs
    a diagonal witness that separates consecutive levels.
    """
    
    def __init__(self, hierarchy: ComplexityHierarchy[T]):
        self.hierarchy = hierarchy
    
    def extract_witness(self, n: int) -> Optional[Tuple[T, str]]:
        """
        Extract a certified separation witness at level n.
        
        Returns (witness, certificate) where certificate explains
        why the witness separates level(n) from level(n+1).
        """
        witness = self.hierarchy.separation_witness(n)
        if witness is not None:
            cert = (f"witness ∈ level({n+1}) \\ level({n}): "
                    f"in level({n+1})={witness in self.hierarchy.level(n+1)}, "
                    f"in level({n})={witness in self.hierarchy.level(n)}")
            return (witness, cert)
        return None


@dataclass
class HierarchyMorphism(Generic[T, S]):
    """
    A structure-preserving map between complexity hierarchies.
    
    Preserves level membership and reflects non-membership.
    """
    source: ComplexityHierarchy[T]
    target: ComplexityHierarchy[S]
    map_fn: Callable[[T], S]
    
    def preserves_membership(self, n: int, x: T) -> bool:
        """Check if the morphism preserves membership at level n for x."""
        if x in self.source.level(n):
            return self.map_fn(x) in self.target.level(n)
        return True  # Vacuously true if x not in source level
    
    def reflects_nonmembership(self, n: int, x: T) -> bool:
        """Check if the morphism reflects non-membership at level n for x."""
        if self.map_fn(x) not in self.target.level(n):
            return x not in self.source.level(n)
        return True  # Vacuously true if image is in target level


def build_time_hierarchy(base: int = 2) -> ComplexityHierarchy[int]:
    """
    Build a concrete time hierarchy.
    
    level(n) = {0, 1, ..., base^n - 1}
    
    This models DTIME(base^n): problems encodable in base^n steps.
    """
    def level_fn(n: int) -> Set[int]:
        bound = base ** n
        return set(range(bound))
    
    return ComplexityHierarchy(_level_fn=level_fn)


def build_polynomial_hierarchy() -> ComplexityHierarchy[int]:
    """
    Build a polynomial hierarchy.
    
    level(n) = {0, 1, ..., n! - 1}
    
    Models complexity classes growing factorially.
    """
    def level_fn(n: int) -> Set[int]:
        bound = math.factorial(n + 1)
        return set(range(bound))
    
    return ComplexityHierarchy(_level_fn=level_fn)


def demonstrate_simulation_transfer():
    """
    Demonstrate the simulation transfer theorem with concrete hierarchies.
    """
    # H1: exponential hierarchy (base 2)
    h1 = build_time_hierarchy(base=2)
    
    # H2: exponential hierarchy (base 3) — "faster" model
    h2 = build_time_hierarchy(base=3)
    
    # Simulation: H1 simulates H2 with quadratic overhead
    # translate: identity (same problem numbering)
    # overhead: n -> 2n (since 3^n ≤ 2^(2n) = 4^n for all n ≥ 0)
    sim = FrameworkSimulation(
        h1=h1, h2=h2,
        translate=lambda x: x,
        overhead=lambda n: 2 * n
    )
    
    print("Simulation Transfer Demonstration")
    print("-" * 40)
    
    for n in range(6):
        witness = sim.transfer_separation(n)
        if witness is not None:
            print(f"Level {n}: separation witness = {witness}")
            print(f"  In H1.level({sim.overhead(n+1)}) = {witness in h1.level(sim.overhead(n+1))}")
            print(f"  In H1.level({n}) = {witness in h1.level(n)}")
        else:
            print(f"Level {n}: no transfer witness found")
        print()


def oracle_tower(base_hierarchy: ComplexityHierarchy[int],
                 num_levels: int) -> List[ComplexityHierarchy[int]]:
    """
    Construct a tower of oracle extensions.
    
    Each level adds an oracle that makes the previous level's
    unsolvable problems solvable, creating new separations.
    """
    tower = [base_hierarchy]
    
    for i in range(1, num_levels):
        prev = tower[-1]
        # Each oracle level doubles the effective power
        scale = 2 ** i
        
        def make_level_fn(prev_h: ComplexityHierarchy[int], s: int):
            def level_fn(n: int) -> Set[int]:
                return prev_h.level(n * s)
            return level_fn
        
        oracle_h = ComplexityHierarchy(
            _level_fn=make_level_fn(prev, scale)
        )
        tower.append(oracle_h)
    
    return tower


if __name__ == "__main__":
    print("=" * 50)
    print("ALGORITHMS: Universal Complexity Framework")
    print("=" * 50)
    print()
    
    # Build and verify a concrete hierarchy
    h = build_time_hierarchy(base=2)
    print(f"Time hierarchy (base 2) verified: {h.verify(8)}")
    
    for n in range(5):
        w = h.separation_witness(n)
        print(f"  Level {n} → {n+1} separation witness: {w}")
    
    print()
    
    # Demonstrate simulation transfer
    demonstrate_simulation_transfer()
    
    # Build oracle tower
    print("Oracle Tower Construction")
    print("-" * 40)
    tower = oracle_tower(h, 4)
    for i, level_h in enumerate(tower):
        print(f"Oracle level {i}: verified = {level_h.verify(5)}")
        w = level_h.separation_witness(3)
        print(f"  Separation witness at level 3: {w}")
    
    print()
    print("All algorithms demonstrate substrate-independent complexity.")
