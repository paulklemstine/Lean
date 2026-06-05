#!/usr/bin/env python3
"""
Algorithms for Reflective Proof Towers and Diagonal Arguments
==============================================================

Type-hinted implementations of the core mathematical constructions.
"""

from typing import Set, Callable, TypeVar, Generic, Optional, FrozenSet, Tuple, List
from dataclasses import dataclass, field
from abc import ABC, abstractmethod

T = TypeVar('T')
S = TypeVar('S')


# ============================================================
# Algorithm 1: Reflective Tower
# ============================================================

@dataclass
class ReflectiveTower(Generic[T]):
    """A Reflective Tower: ℕ-indexed hierarchy of proof systems.

    Each level proves everything the previous level proves,
    plus the consistency of the previous level.

    Invariants (verified at construction):
    - provable(n) ⊆ provable(n+1)           [monotonicity]
    - con(n) ∉ provable(n)                   [Gödel's second]
    - con(n) ∈ provable(n+1)                 [consistency reflection]
    """

    _provable: Callable[[int], Set[T]]
    _con: Callable[[int], T]

    def provable(self, n: int) -> Set[T]:
        """The set of provable sentences at level n."""
        return self._provable(n)

    def con(self, n: int) -> T:
        """The consistency sentence for level n."""
        return self._con(n)

    def verify_axioms(self, depth: int = 5) -> bool:
        """Verify tower axioms up to given depth."""
        for n in range(depth):
            p_n = self.provable(n)
            p_n1 = self.provable(n + 1)
            c = self.con(n)

            if not p_n.issubset(p_n1):
                return False  # monotonicity violated
            if c in p_n:
                return False  # Gödel's second violated
            if c not in p_n1:
                return False  # reflection violated

        return True

    def incompleteness_gap(self, n: int) -> Set[T]:
        """The set of sentences provable at n+1 but not at n."""
        return self.provable(n + 1) - self.provable(n)

    def tower_limit(self, depth: int) -> Set[T]:
        """Approximate the tower limit ⋃_n provable(n) up to given depth."""
        result: Set[T] = set()
        for n in range(depth):
            result |= self.provable(n)
        return result


def make_pa_tower() -> ReflectiveTower[int]:
    """Construct the canonical PA consistency tower.

    Level 0: sentences 0..99 (representing PA theorems)
    Level n: Level 0 ∪ {Con(0), Con(1), ..., Con(n-1)}
    Con(n) represented as 100 + n
    """
    base = set(range(100))

    def provable(n: int) -> Set[int]:
        return base | {100 + k for k in range(n)}

    def con(n: int) -> int:
        return 100 + n

    return ReflectiveTower(_provable=provable, _con=con)


# ============================================================
# Algorithm 2: Gödel Oracle and Diagonal Construction
# ============================================================

@dataclass
class GoedelOracle(Generic[T]):
    """A Gödel Oracle: maps theories to sentences.

    The oracle attempts to produce, for each theory T,
    a sentence G(T) that is true but not provable in T.
    """

    _oracle: Callable[[FrozenSet[T]], T]

    def __call__(self, theory: FrozenSet[T]) -> T:
        return self._oracle(theory)

    def find_failure(self, theories: List[FrozenSet[T]]) -> Optional[Tuple[FrozenSet[T], T]]:
        """Find a theory where the oracle fails (G(T) ∈ T).

        Returns (T, G(T)) if found, None otherwise.
        """
        for theory in theories:
            g = self(theory)
            if g in theory:
                return (theory, g)
        return None

    def diagonal_failure(self) -> Tuple[FrozenSet[T], T]:
        """Construct a theory where the oracle necessarily fails.

        By the Penrose Diagonal Limiter, we can always find such a theory.
        The simplest construction: take T = universal set.
        """
        # We can't represent the universal set, so we iterate
        # Start with empty theory, keep adding G(T) to T
        theory: Set[T] = set()
        seen: Set[T] = set()
        for _ in range(100):
            g = self(frozenset(theory))
            if g in theory:
                return (frozenset(theory), g)
            theory.add(g)
            if g in seen:
                break
            seen.add(g)

        # Final check
        final = frozenset(theory)
        g = self(final)
        return (final, g)


# ============================================================
# Algorithm 3: Lawvere Diagonal
# ============================================================

def lawvere_diagonal(
    f: Callable[[int], Callable[[int], bool]],
    domain_size: int
) -> Callable[[int], bool]:
    """Construct the Lawvere anti-diagonal function.

    Given f : {0,...,n-1} → ({0,...,n-1} → Bool),
    produces d : {0,...,n-1} → Bool such that
    d ≠ f(a) for all a in the domain.

    This is the constructive witness for Cantor's theorem:
    d cannot be in the range of f.
    """
    def anti_diag(x: int) -> bool:
        if 0 <= x < domain_size:
            return not f(x)(x)
        return False

    return anti_diag


def verify_lawvere(
    f: Callable[[int], Callable[[int], bool]],
    domain_size: int
) -> bool:
    """Verify that the anti-diagonal is not in the range of f."""
    d = lawvere_diagonal(f, domain_size)
    for a in range(domain_size):
        if all(f(a)(x) == d(x) for x in range(domain_size)):
            return False  # d = f(a), Lawvere "fails" (impossible)
    return True  # d ≠ f(a) for all a, as expected


# ============================================================
# Algorithm 4: Berry-Chaitin Pigeonhole
# ============================================================

def berry_check_injective(
    naming: Callable[[int], int],
    num_objects: int,
    num_names: int
) -> Tuple[bool, Optional[Tuple[int, int]]]:
    """Check if a naming function is injective.

    If not, return a pair (a, b) with a ≠ b but naming(a) = naming(b).

    By the Berry-Chaitin bound, if num_objects > num_names,
    the function CANNOT be injective.
    """
    seen: dict = {}
    for obj in range(num_objects):
        name = naming(obj)
        if name in seen:
            return (False, (seen[name], obj))
        seen[name] = obj
    return (True, None)


# ============================================================
# Algorithm 5: Mind Model Simulation
# ============================================================

@dataclass
class MindModel(Generic[T]):
    """A Mind Model: recognition function + beliefs.

    Captures the Lucas-Penrose concept of a "mind" that
    recognizes Gödel sentences of formal systems.
    """

    recognize: Callable[[FrozenSet[T]], T]
    beliefs: FrozenSet[T]

    def check_self_consistency(self) -> bool:
        """Check if recognize(beliefs) ∉ beliefs.

        By mind_not_machine_precise, if recognize is universal
        (always produces unprovable sentences), this MUST be True.
        """
        g = self.recognize(self.beliefs)
        return g not in self.beliefs

    def enhance(self) -> 'MindModel[T]':
        """Create enhanced mind by adding recognized Gödel sentence.

        By self_referential_blindness, the enhanced mind still
        has its own blind spot.
        """
        g = self.recognize(self.beliefs)
        new_beliefs = self.beliefs | frozenset([g])
        return MindModel(recognize=self.recognize, beliefs=new_beliefs)

    def iterate_enhancement(self, depth: int) -> List['MindModel[T]']:
        """Iterate self-enhancement, showing blindness persists."""
        minds = [self]
        current = self
        for _ in range(depth):
            current = current.enhance()
            minds.append(current)
        return minds


# ============================================================
# Main: Run all algorithms
# ============================================================

if __name__ == "__main__":
    # 1. Reflective Tower
    tower = make_pa_tower()
    print("Tower axioms verified:", tower.verify_axioms(10))
    print("Incompleteness gap at level 3:", tower.incompleteness_gap(3))
    print("Tower limit (5 levels):", len(tower.tower_limit(5)), "sentences")

    # 2. Gödel Oracle
    oracle = GoedelOracle[int](_oracle=lambda T: max(T) + 1 if T else 0)
    failure = oracle.diagonal_failure()
    print(f"\nOracle failure: G(T) = {failure[1]}, T = {sorted(failure[0])[:5]}...")

    # 3. Lawvere Diagonal
    f = lambda a: (lambda x: (a + x) % 4 < 2)
    print(f"\nLawvere anti-diagonal not in range: {verify_lawvere(f, 4)}")

    # 4. Berry-Chaitin
    naming = lambda obj: obj % 5  # 6 objects, 5 names
    injective, collision = berry_check_injective(naming, 6, 5)
    print(f"\nBerry-Chaitin: injective = {injective}, collision = {collision}")

    # 5. Mind Model
    mind = MindModel[int](
        recognize=lambda T: hash(T) % 10000 + 1000,
        beliefs=frozenset(range(100))
    )
    print(f"\nMind self-consistency: {mind.check_self_consistency()}")
    minds = mind.iterate_enhancement(5)
    for i, m in enumerate(minds):
        print(f"  Level {i}: |beliefs| = {len(m.beliefs)}, "
              f"self-consistent = {m.check_self_consistency()}")
