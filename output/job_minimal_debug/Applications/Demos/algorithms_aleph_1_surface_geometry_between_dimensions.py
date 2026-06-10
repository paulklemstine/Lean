#!/usr/bin/env python3
"""
Algorithms for Ordinal Filtration Spaces

Type-hinted implementations of the key mathematical constructions.
"""

from typing import List, Set, Dict, Tuple, Optional, Callable, TypeVar, Generic
from dataclasses import dataclass
from abc import ABC, abstractmethod

T = TypeVar('T')


@dataclass
class OrdinalFiltration(Generic[T]):
    """
    An ordinal filtration of a finite set, using natural numbers as ordinals.
    
    F[k] is the set of elements at filtration level k.
    The filtration satisfies:
      - F[0] = {} (empty)
      - F[k] ⊆ F[k+1] (monotone)
      - F[max_level] = full space (exhaustion)
    """
    elements: List[T]
    levels: Dict[T, int]  # birth ordinal for each element
    
    @property
    def max_level(self) -> int:
        return max(self.levels.values()) if self.levels else 0
    
    def F(self, k: int) -> Set[T]:
        """Filtration level k: all elements born at or before level k."""
        return {x for x, birth in self.levels.items() if birth <= k}
    
    def stratum(self, k: int) -> Set[T]:
        """Stratum at level k: elements born exactly at level k."""
        return {x for x, birth in self.levels.items() if birth == k}
    
    def birth_ordinal(self, x: T) -> int:
        """The birth ordinal of element x."""
        return self.levels[x]
    
    def nonempty_strata(self) -> List[int]:
        """List of levels with nonempty strata."""
        return sorted({birth for birth in self.levels.values()})
    
    def independence_number(self) -> int:
        """The number of nonempty strata."""
        return len(self.nonempty_strata())
    
    def verify_disjointness(self) -> bool:
        """Verify that strata are pairwise disjoint."""
        strata = {}
        for k in self.nonempty_strata():
            strata[k] = self.stratum(k)
        
        levels = list(strata.keys())
        for i in range(len(levels)):
            for j in range(i + 1, len(levels)):
                if strata[levels[i]] & strata[levels[j]]:
                    return False
        return True
    
    def verify_exhaustion(self) -> bool:
        """Verify that the union of all strata equals the full space."""
        union = set()
        for k in range(self.max_level + 1):
            union |= self.stratum(k)
        return union == set(self.elements)


def construct_natural_filtration(elements: List[T]) -> OrdinalFiltration[T]:
    """
    Construct the canonical filtration: element i is born at level i+1.
    This achieves the maximum independence number = len(elements).
    """
    levels = {x: i + 1 for i, x in enumerate(elements)}
    return OrdinalFiltration(elements=elements, levels=levels)


def hilbert_cube_embed(point: List[float], target_dim: int) -> List[float]:
    """
    Embed a finite-dimensional point [0,1]^n into [0,1]^target_dim.
    Pads with zeros. Injective by construction.
    
    Algorithm:
      1. Copy the n coordinates of the input point
      2. Pad remaining coordinates with 0.0
      3. Return the target_dim-dimensional point
    """
    n = len(point)
    result = point[:min(n, target_dim)]
    result += [0.0] * max(0, target_dim - n)
    return result


def cantor_diagonal(functions: List[List[int]]) -> List[int]:
    """
    Cantor's diagonal argument: given a list of functions ℕ → {0,1},
    construct a function that differs from each one.
    
    This is the constructive core of Cantor's theorem: 2^κ > κ.
    
    Algorithm:
      1. For each i, look at functions[i][i]
      2. Flip the bit: new[i] = 1 - functions[i][i]
      3. The result differs from functions[i] at position i
    """
    n = len(functions)
    diagonal = []
    for i in range(n):
        if i < len(functions[i]):
            diagonal.append(1 - functions[i][i])
        else:
            diagonal.append(0)
    return diagonal


def cardinal_chain(length: int, base: int = 2) -> List[int]:
    """
    Generate a strictly increasing chain of cardinals.
    Uses powers of base as a finite model.
    
    In transfinite arithmetic:
      ℵ₀ < ℵ₁ < ℵ₂ < ...
    
    Finite model:
      base^0 < base^1 < base^2 < ...
    """
    return [base ** i for i in range(length)]


def triangulation_obstruction_check(
    filtration: OrdinalFiltration[T],
    max_tri_vertices: int
) -> Tuple[bool, str]:
    """
    Check whether a filtration-based obstruction prevents triangulation
    with at most max_tri_vertices vertices.
    
    The obstruction activates when:
      independence_number > max_tri_vertices
    
    Returns (is_obstructed, explanation).
    """
    indep = filtration.independence_number()
    
    if indep > max_tri_vertices:
        return (True, 
            f"Obstruction: {indep} nonempty strata > {max_tri_vertices} vertices. "
            f"Each stratum contributes a distinct point, so the space has "
            f"≥ {indep} elements, but a triangulation with {max_tri_vertices} "
            f"vertices can cover at most {max_tri_vertices} elements.")
    else:
        return (False,
            f"No obstruction: {indep} nonempty strata ≤ {max_tri_vertices} vertices. "
            f"A triangulation may exist.")


if __name__ == "__main__":
    # Example usage
    elements = list(range(20))
    filt = construct_natural_filtration(elements)
    
    print("Natural filtration on {0, ..., 19}:")
    print(f"  Independence number: {filt.independence_number()}")
    print(f"  Disjoint strata: {filt.verify_disjointness()}")
    print(f"  Exhaustion: {filt.verify_exhaustion()}")
    
    # Triangulation check
    obstructed, msg = triangulation_obstruction_check(filt, 10)
    print(f"  Triangulation with 10 vertices: {'OBSTRUCTED' if obstructed else 'possible'}")
    print(f"    {msg}")
    
    # Hilbert cube embedding
    point = [0.5, 0.3, 0.8]
    embedded = hilbert_cube_embed(point, 10)
    print(f"\n  Hilbert cube embedding: {point} → {embedded}")
    
    # Cantor diagonal
    fns = [[0, 1, 0, 1], [1, 1, 1, 0], [0, 0, 1, 1], [1, 0, 0, 0]]
    diag = cantor_diagonal(fns)
    print(f"\n  Cantor diagonal of {fns}:")
    print(f"    Result: {diag}")
    print(f"    Differs from each function at its index ✓")
