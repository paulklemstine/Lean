#!/usr/bin/env python3
"""
Universal Computational Complexity: Core Algorithms

Type-hinted implementations of the key constructions from
the universal complexity theory framework.
"""

from typing import (
    Callable, Dict, FrozenSet, Generic, List, Optional, 
    Set, Tuple, TypeVar
)
from dataclasses import dataclass
from functools import reduce
import math

T = TypeVar('T')
U = TypeVar('U')
V = TypeVar('V')


# ─── Diagonal Construction ───────────────────────────────────────────

def computational_diagonal(family: List[FrozenSet[int]], n: int) -> FrozenSet[int]:
    """
    Compute the diagonal set for a family of languages.
    
    D(family) = {k | k < len(family) and k ∉ family[k]}
    
    This is the universal construction underlying all complexity
    hierarchy theorems. It takes any enumerable family of decision
    procedures and produces a language not in the family.
    
    Args:
        family: List of sets (languages), one per program index
        n: Universe size (check indices 0..n-1)
    
    Returns:
        The diagonal set (as a frozenset)
    """
    return frozenset(
        k for k in range(min(len(family), n))
        if k not in family[k]
    )


def verify_diagonal_separation(
    family: List[FrozenSet[int]], 
    n: int
) -> List[Tuple[int, int]]:
    """
    Verify that the diagonal set differs from every family member.
    
    Returns list of (index, witness) pairs where witness is an element
    that distinguishes the diagonal from family[index].
    """
    diag = computational_diagonal(family, n)
    witnesses: List[Tuple[int, int]] = []
    
    for i, lang in enumerate(family):
        if i >= n:
            break
        # Find a witness of disagreement
        diff = diag.symmetric_difference(lang & frozenset(range(n)))
        if diff:
            witness = min(diff)
            witnesses.append((i, witness))
        # If diff is empty over our finite universe, the diagonal 
        # may coincidentally equal lang on {0..n-1} but still differs 
        # on element i itself (by construction)
    
    return witnesses


# ─── Resource Hierarchy ──────────────────────────────────────────────

@dataclass
class ResourceHierarchy(Generic[T]):
    """
    Abstract resource hierarchy: a monotone family of problem classes.
    
    Represents DTIME, DSPACE, NTIME, circuit depth, or any other
    resource-bounded complexity measure.
    """
    class_at: Callable[[int], Set[T]]
    max_level: int
    
    def is_monotone(self, levels: Optional[List[int]] = None) -> bool:
        """Check that class_at is monotone on given levels."""
        if levels is None:
            levels = list(range(self.max_level))
        for i in range(len(levels) - 1):
            m, n = levels[i], levels[i + 1]
            if m <= n and not self.class_at(m).issubset(self.class_at(n)):
                return False
        return True
    
    def is_proper(self, max_check: Optional[int] = None) -> bool:
        """Check that the hierarchy is proper (strict at each level)."""
        limit = max_check or self.max_level
        for n in range(limit):
            cn = self.class_at(n)
            cn1 = self.class_at(n + 1)
            if cn == cn1 or not cn.issubset(cn1):
                return False
        return True
    
    def witness_at(self, n: int) -> Optional[T]:
        """Find an element in class_at(n+1) \\ class_at(n), if it exists."""
        diff = self.class_at(n + 1) - self.class_at(n)
        if diff:
            return min(diff)  # type: ignore
        return None
    
    def separation_chain(self, max_level: Optional[int] = None) -> List[Optional[T]]:
        """Compute witnesses at each level, forming a separation chain."""
        limit = max_level or self.max_level
        return [self.witness_at(n) for n in range(limit)]


# ─── Model Simulation ────────────────────────────────────────────────

@dataclass
class ModelSimulation(Generic[T, U]):
    """
    A simulation from one resource hierarchy to another.
    
    Consists of an embedding (injective map) and an overhead function,
    such that problems solvable at level n in the source are solvable
    at level overhead(n) in the target.
    """
    embed: Callable[[T], U]
    overhead: Callable[[int], int]
    
    def transfer_class(self, source_class: Set[T]) -> Set[U]:
        """Map a complexity class through the simulation."""
        return {self.embed(x) for x in source_class}
    
    def overhead_at(self, n: int) -> int:
        """Compute the overhead at resource level n."""
        return self.overhead(n)


def compose_simulations(
    s1: ModelSimulation[T, U], 
    s2: ModelSimulation[U, V]
) -> ModelSimulation[T, V]:
    """
    Compose two simulations: S1 (A→B) and S2 (B→C) → (A→C).
    
    The composed overhead is s2.overhead ∘ s1.overhead.
    This is the key algebraic property: simulation is transitive.
    """
    return ModelSimulation(
        embed=lambda x: s2.embed(s1.embed(x)),
        overhead=lambda n: s2.overhead(s1.overhead(n))
    )


def verify_separation_transfer(
    sim: ModelSimulation[T, U],
    source_class_m: Set[T],
    source_class_n: Set[T],
) -> bool:
    """
    Verify that a strict separation transfers through a simulation.
    
    If source_class_m ⊊ source_class_n, then
    sim.embed(source_class_m) ⊊ sim.embed(source_class_n).
    """
    # Check strict containment in source
    if not (source_class_m < source_class_n):
        return False  # Not a strict separation
    
    # Check that image preserves strict containment
    image_m = sim.transfer_class(source_class_m)
    image_n = sim.transfer_class(source_class_n)
    
    return image_m < image_n


# ─── Hypercomputation Hierarchy ──────────────────────────────────────

@dataclass
class HypercomputationalModel:
    """
    A transfinite tower of computation levels.
    
    Each level k has an enumeration of languages. The tower is
    cumulative: all languages at level k are also available at level k+1.
    The key theorem: the diagonal at each level escapes that level
    but is captured at the next.
    """
    level_languages: Dict[int, List[FrozenSet[int]]]
    universe_size: int
    
    def diagonal_at(self, k: int) -> FrozenSet[int]:
        """Compute the diagonal language at level k."""
        return computational_diagonal(
            self.level_languages.get(k, []), 
            self.universe_size
        )
    
    def is_cumulative(self, max_k: int) -> bool:
        """Verify that the tower is cumulative."""
        for k in range(max_k):
            langs_k = set(self.level_languages.get(k, []))
            langs_k1 = set(self.level_languages.get(k + 1, []))
            if not langs_k.issubset(langs_k1):
                return False
        return True
    
    def build_tower(self, max_k: int) -> None:
        """
        Construct the hypercomputation tower up to level max_k.
        
        At each level, add the diagonal from the previous level
        as a newly computable language.
        """
        if 0 not in self.level_languages:
            # Initialize level 0 with some base languages
            base: List[FrozenSet[int]] = []
            for i in range(self.universe_size):
                base.append(frozenset(
                    j for j in range(self.universe_size) 
                    if (i + j) % 3 == 0
                ))
            self.level_languages[0] = base
        
        for k in range(max_k):
            if k + 1 not in self.level_languages:
                # Level k+1 = Level k + diagonal of level k + new languages
                prev = list(self.level_languages[k])
                diag_k = self.diagonal_at(k)
                new_level = prev + [diag_k]
                # Add some additional languages for richness
                for i in range(self.universe_size):
                    new_level.append(frozenset(
                        j for j in range(self.universe_size)
                        if (i * j + k) % (k + 2) == 0
                    ))
                self.level_languages[k + 1] = new_level
    
    def verify_strict_hierarchy(self, max_k: int) -> List[bool]:
        """
        Verify that each level strictly extends the previous.
        Returns a list of booleans, one per level transition.
        """
        results: List[bool] = []
        for k in range(max_k):
            diag_k = self.diagonal_at(k)
            langs_k = set(self.level_languages.get(k, []))
            langs_k1 = set(self.level_languages.get(k + 1, []))
            
            # Diagonal should be in level k+1 but not level k
            in_next = diag_k in langs_k1
            not_in_current = diag_k not in langs_k
            results.append(in_next and not_in_current)
        
        return results


# ─── Polynomial Simulation Conjecture Testing ────────────────────────

def test_polynomial_simulation(
    overhead: Callable[[int], int],
    max_n: int = 100,
    max_degree: int = 10
) -> Tuple[bool, Optional[int]]:
    """
    Test whether an overhead function is polynomially bounded.
    
    Returns (is_poly, best_degree) where best_degree is the smallest
    degree c such that overhead(n) ≤ n^c + c for all tested n.
    """
    for c in range(1, max_degree + 1):
        is_bounded = all(
            overhead(n) <= n ** c + c
            for n in range(1, max_n + 1)
        )
        if is_bounded:
            return True, c
    return False, None


# ─── Main demonstration ──────────────────────────────────────────────

if __name__ == "__main__":
    print("Universal Computational Complexity: Algorithm Demonstrations")
    print("=" * 60)
    
    # 1. Diagonal construction
    print("\n1. Diagonal Construction")
    family = [
        frozenset({0, 2, 4}),
        frozenset({1, 3, 5}),
        frozenset({0, 1, 2}),
        frozenset({3, 4, 5}),
        frozenset({0, 4}),
        frozenset({1, 2, 3, 5}),
    ]
    diag = computational_diagonal(family, 6)
    print(f"  Family: {[sorted(s) for s in family]}")
    print(f"  Diagonal: {sorted(diag)}")
    witnesses = verify_diagonal_separation(family, 6)
    for idx, wit in witnesses:
        print(f"  D ≠ L_{idx}: witness = {wit}")
    
    # 2. Resource hierarchy  
    print("\n2. Resource Hierarchy (polynomial degree)")
    poly_hierarchy = ResourceHierarchy(
        class_at=lambda n: {i for i in range(100) if i <= n},
        max_level=10
    )
    print(f"  Monotone: {poly_hierarchy.is_monotone()}")
    print(f"  Proper: {poly_hierarchy.is_proper()}")
    chain = poly_hierarchy.separation_chain(8)
    print(f"  Separation chain: {chain}")
    
    # 3. Simulation composition
    print("\n3. Simulation Composition")
    sim_ab: ModelSimulation[int, int] = ModelSimulation(
        embed=lambda x: 2 * x,
        overhead=lambda n: 2 * n + 1
    )
    sim_bc: ModelSimulation[int, int] = ModelSimulation(
        embed=lambda x: 3 * x,
        overhead=lambda n: 3 * n + 2
    )
    sim_ac = compose_simulations(sim_ab, sim_bc)
    for n in range(5):
        print(f"  overhead_AC({n}) = {sim_ac.overhead_at(n)} "
              f"= h_BC(h_AB({n})) = h_BC({sim_ab.overhead_at(n)})")
    
    # 4. Hypercomputation tower
    print("\n4. Hypercomputation Tower")
    model = HypercomputationalModel(level_languages={}, universe_size=8)
    model.build_tower(5)
    strict = model.verify_strict_hierarchy(5)
    for k, is_strict in enumerate(strict):
        status = "STRICT ✓" if is_strict else "COLLAPSED ✗"
        print(f"  Level {k} → Level {k+1}: {status}")
    
    # 5. Polynomial simulation test
    print("\n5. Polynomial Simulation Conjecture Test")
    test_overheads = [
        ("2n + 1", lambda n: 2 * n + 1),
        ("n²", lambda n: n ** 2),
        ("n³ + n", lambda n: n ** 3 + n),
        ("2^n", lambda n: 2 ** n),
    ]
    for name, overhead in test_overheads:
        is_poly, degree = test_polynomial_simulation(overhead, max_n=50)
        status = f"polynomial (degree {degree})" if is_poly else "NOT polynomial"
        print(f"  h(n) = {name:10s} → {status}")
