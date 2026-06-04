#!/usr/bin/env python3
"""
Algorithms for Self-Referential Type Theory

Implements the core algorithms and constructions from the formalized theory:
1. Lawvere fixed point finder
2. Strange loop detector
3. Consciousness tower simulator
4. Quantifier depth classifier
5. Fixed-point lattice computation
"""

from typing import (
    Callable, TypeVar, Set, List, Tuple, Optional, Dict, FrozenSet
)

T = TypeVar('T')


def lawvere_fixed_point_finder(
    phi: Callable[[int], Callable[[int], int]],
    f: Callable[[int], int],
    domain: List[int]
) -> Optional[int]:
    """
    Find a fixed point of f : β → β given a surjective φ : α → (α → β).

    Algorithm (Lawvere's diagonal construction):
    1. Define d(x) = f(φ(x)(x)) — the diagonal twist
    2. Find a ∈ α with φ(a) = d (by surjectivity)
    3. Then φ(a)(a) = d(a) = f(φ(a)(a)), so φ(a)(a) is a fixed point

    Args:
        phi: Representation map (assumed surjective on domain)
        f: The endomorphism whose fixed point we seek
        domain: Finite approximation of the domain

    Returns:
        A fixed point b with f(b) = b, or None if not found in domain
    """
    for a in domain:
        candidate = phi(a)(a)
        if f(candidate) == candidate:
            return candidate
    return None


def is_idempotent(
    f: Callable[[int], int],
    domain: List[int]
) -> bool:
    """Check if f is idempotent: f(f(x)) = f(x) for all x in domain."""
    return all(f(f(x)) == f(x) for x in domain)


def fixed_point_set(
    f: Callable[[int], int],
    domain: List[int]
) -> Set[int]:
    """Compute the fixed-point set {x | f(x) = x}."""
    return {x for x in domain if f(x) == x}


def function_range(
    f: Callable[[int], int],
    domain: List[int]
) -> Set[int]:
    """Compute the range {f(x) | x ∈ domain}."""
    return {f(x) for x in domain}


def verify_fp_eq_range(
    f: Callable[[int], int],
    domain: List[int]
) -> bool:
    """Verify that for an idempotent f, FP(f) = Range(f)."""
    if not is_idempotent(f, domain):
        return False
    return fixed_point_set(f, domain) == function_range(f, domain)


class StrangeLoop:
    """
    A strange loop operator with tangling and absorption.

    A strange loop (op, shift) satisfies:
    - tangle: op(op(x)) = op(shift(x))
    - absorb: op(shift(x)) = op(x)

    Together these imply op is idempotent: op(op(x)) = op(x).
    """

    def __init__(
        self,
        op: Callable[[int], int],
        shift: Callable[[int], int],
        domain: List[int]
    ):
        self.op = op
        self.shift = shift
        self.domain = domain

    def verify_tangle(self) -> bool:
        """Verify op(op(x)) = op(shift(x)) for all x."""
        return all(
            self.op(self.op(x)) == self.op(self.shift(x))
            for x in self.domain
        )

    def verify_absorb(self) -> bool:
        """Verify op(shift(x)) = op(x) for all x."""
        return all(
            self.op(self.shift(x)) == self.op(x)
            for x in self.domain
        )

    def verify_idempotent(self) -> bool:
        """Verify the consequence: op is idempotent."""
        return is_idempotent(self.op, self.domain)

    def is_valid(self) -> bool:
        """Check all strange loop axioms."""
        return self.verify_tangle() and self.verify_absorb()


class ConsciousnessTower:
    """
    Simulates a consciousness tower with finite-dimensional levels.

    Level n is represented as R^(base_dim + n).
    up(n): Level n → Level (n+1) by appending 0
    down(n): Level (n+1) → Level n by truncating
    observe(n) = up(n) ∘ down(n): zeroes out the last coordinate
    """

    def __init__(self, base_dim: int = 2):
        self.base_dim = base_dim

    def level_dim(self, n: int) -> int:
        """Dimension of level n."""
        return self.base_dim + n

    def up(self, n: int, x: List[float]) -> List[float]:
        """Embed level n into level n+1."""
        assert len(x) == self.level_dim(n)
        return x + [0.0]

    def down(self, n: int, x: List[float]) -> List[float]:
        """Project level n+1 down to level n."""
        assert len(x) == self.level_dim(n + 1)
        return x[:self.level_dim(n)]

    def observe(self, n: int, x: List[float]) -> List[float]:
        """The observation operator at level n: up ∘ down."""
        return self.up(n, self.down(n, x))

    def verify_retract(self, n: int, x: List[float]) -> bool:
        """Verify down(up(x)) = x."""
        return self.down(n, self.up(n, x)) == x

    def verify_idempotent(self, n: int, x: List[float]) -> bool:
        """Verify observe(observe(x)) = observe(x)."""
        obs1 = self.observe(n, x)
        obs2 = self.observe(n, obs1)
        return obs1 == obs2

    def iterate_observe(
        self, n: int, x: List[float], k: int
    ) -> List[float]:
        """Apply observe k times."""
        result = x
        for _ in range(k):
            result = self.observe(n, result)
        return result


class QuantifierDepthClassifier:
    """
    Classifies predicates by their quantifier depth in the hierarchy.

    Level 0: Decidable predicates (no unbounded quantifiers)
    Level n+1: Predicates using quantifiers over level-n predicates

    The hierarchy is:
    - Strictly cumulative: Pred(n) ⊂ Pred(n+1)
    - Each level has a diagonal predicate not in the level below
    """

    def __init__(self):
        self.levels: Dict[int, List[str]] = {}

    def add_predicate(self, level: int, name: str) -> None:
        """Register a predicate at a given level."""
        if level not in self.levels:
            self.levels[level] = []
        self.levels[level].append(name)

    def get_all_up_to(self, level: int) -> List[str]:
        """Get all predicates up to (inclusive) given level."""
        result = []
        for n in range(level + 1):
            result.extend(self.levels.get(n, []))
        return result

    def diagonal_at(self, level: int) -> str:
        """
        The diagonal predicate at level n: definable at level n+1,
        not at level n. This is the formal barrier to self-reference.
        """
        return f"diag_{level}: 'the predicate that diagonalizes level {level}'"


class FixedPointLattice:
    """
    Computes the lattice structure of fixed-point sets.

    For a collection of idempotent endomorphisms on a finite set,
    their fixed-point sets form a lattice under inclusion:
    - Top = domain (from identity)
    - Composition of commuting idempotents gives meet
    """

    def __init__(self, domain: List[int]):
        self.domain = domain
        self.idempotents: Dict[str, Callable[[int], int]] = {}

    def add_idempotent(
        self, name: str, f: Callable[[int], int]
    ) -> bool:
        """Add an idempotent if it passes verification."""
        if is_idempotent(f, self.domain):
            self.idempotents[name] = f
            return True
        return False

    def get_fp_set(self, name: str) -> FrozenSet[int]:
        """Get the fixed-point set of a named idempotent."""
        f = self.idempotents[name]
        return frozenset(fixed_point_set(f, self.domain))

    def get_all_fp_sets(self) -> Dict[str, FrozenSet[int]]:
        """Get all fixed-point sets."""
        return {
            name: self.get_fp_set(name)
            for name in self.idempotents
        }

    def verify_fp_eq_range(self, name: str) -> bool:
        """Verify FP = Range for a named idempotent."""
        return verify_fp_eq_range(
            self.idempotents[name], self.domain
        )

    def lattice_top(self) -> FrozenSet[int]:
        """Top element = entire domain (from identity)."""
        return frozenset(self.domain)

    def commuting_meet(
        self, name1: str, name2: str
    ) -> Optional[FrozenSet[int]]:
        """
        Compute meet of two idempotents if they commute.
        For commuting idempotents f, g: FP(f∘g) = FP(f) ∩ FP(g).
        """
        f = self.idempotents[name1]
        g = self.idempotents[name2]
        # Check commutativity
        if not all(f(g(x)) == g(f(x)) for x in self.domain):
            return None
        return self.get_fp_set(name1) & self.get_fp_set(name2)


def cardinality_barrier(n: int) -> Tuple[bool, str]:
    """
    Check if a type of cardinality n can be self-referential.

    A type T with |T| = n and a surjection T → (T → T) requires
    n ≥ n^n. This is only possible for n ∈ {0, 1}.
    """
    if n == 0:
        return True, "Trivial: empty type, vacuously self-referential"
    nn = n ** n
    if n >= nn:
        return True, f"|T| = {n} ≥ {n}^{n} = {nn}: self-referential possible"
    return False, f"|T| = {n} < {n}^{n} = {nn}: too small for self-reference"


if __name__ == "__main__":
    # Quick demo
    print("Cardinality barrier for self-referential types:")
    for n in range(6):
        ok, msg = cardinality_barrier(n)
        print(f"  n={n}: {msg}")

    print("\nConsciousness tower (base_dim=2):")
    tower = ConsciousnessTower(base_dim=2)
    x = [1.0, 2.0, 3.0]
    print(f"  Level 1, x = {x}")
    print(f"  observe(x) = {tower.observe(0, x)}")
    print(f"  Idempotent: {tower.verify_idempotent(0, x)}")
