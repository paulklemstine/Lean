"""
Algorithms for Dream Logic and Paraconsistent Reasoning
========================================================

Type-hinted implementations of the core algorithms from the research.
"""

from enum import Enum
from typing import (
    Set, FrozenSet, Dict, List, Tuple, Optional,
    Callable, TypeVar, Generic, Iterator
)
from dataclasses import dataclass


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 1: Belnap Four-Valued Logic Engine
# ═══════════════════════════════════════════════════════════════════════

class BelnapVal(Enum):
    """Belnap's four truth values with knowledge ordering."""
    NEITHER = 0  # ⊥_k: no information
    TRUE = 1     # t: true only
    FALSE = 2    # f: false only
    BOTH = 3     # ⊤_k: contradictory

    def __le__(self, other: 'BelnapVal') -> bool:
        """Knowledge ordering."""
        if self == BelnapVal.NEITHER:
            return True
        if other == BelnapVal.BOTH:
            return True
        return self == other

    def __lt__(self, other: 'BelnapVal') -> bool:
        return self <= other and self != other


def belnap_neg(v: BelnapVal) -> BelnapVal:
    """Paraconsistent negation: swaps TRUE ↔ FALSE, fixes NEITHER and BOTH."""
    return {
        BelnapVal.NEITHER: BelnapVal.NEITHER,
        BelnapVal.TRUE: BelnapVal.FALSE,
        BelnapVal.FALSE: BelnapVal.TRUE,
        BelnapVal.BOTH: BelnapVal.BOTH,
    }[v]


def belnap_conj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Truth conjunction in Belnap's logic."""
    if a == BelnapVal.FALSE or b == BelnapVal.FALSE:
        return BelnapVal.FALSE
    if a == BelnapVal.TRUE:
        return b
    if b == BelnapVal.TRUE:
        return a
    if a == BelnapVal.NEITHER and b == BelnapVal.NEITHER:
        return BelnapVal.NEITHER
    if a == BelnapVal.BOTH and b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    return BelnapVal.FALSE


def belnap_disj(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Truth disjunction in Belnap's logic."""
    if a == BelnapVal.TRUE or b == BelnapVal.TRUE:
        return BelnapVal.TRUE
    if a == BelnapVal.FALSE:
        return b
    if b == BelnapVal.FALSE:
        return a
    if a == BelnapVal.NEITHER and b == BelnapVal.NEITHER:
        return BelnapVal.NEITHER
    if a == BelnapVal.BOTH and b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    return BelnapVal.TRUE


def belnap_kjoin(a: BelnapVal, b: BelnapVal) -> BelnapVal:
    """Knowledge join: least upper bound in knowledge ordering."""
    if a == BelnapVal.NEITHER:
        return b
    if b == BelnapVal.NEITHER:
        return a
    if a == BelnapVal.BOTH or b == BelnapVal.BOTH:
        return BelnapVal.BOTH
    if a == b:
        return a
    return BelnapVal.BOTH


def is_designated(v: BelnapVal) -> bool:
    """Check if a value is designated (contains truth)."""
    return v in (BelnapVal.TRUE, BelnapVal.BOTH)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 2: Dream Space Operations
# ═══════════════════════════════════════════════════════════════════════

@dataclass
class DreamSpace:
    """A dream space: pre-topological structure without union closure.

    Attributes:
        universe: The ground set (as a frozenset)
        open_sets: Collection of open sets (frozensets)
    """
    universe: FrozenSet[int]
    open_sets: Set[FrozenSet[int]]

    def is_valid(self) -> bool:
        """Verify the dream space axioms."""
        # Empty set must be open
        if frozenset() not in self.open_sets:
            return False
        # Universe must be open
        if self.universe not in self.open_sets:
            return False
        # Finite intersection closure
        for s in self.open_sets:
            for t in self.open_sets:
                if (s & t) not in self.open_sets:
                    return False
        return True

    def is_topological(self) -> bool:
        """Check if the dream space is also a topological space.

        Tests whether ALL possible unions of open sets are open.
        Only feasible for small spaces.
        """
        open_list = list(self.open_sets)
        n = len(open_list)
        # Check all 2^n subsets of open sets
        for mask in range(1 << n):
            union = frozenset()
            for i in range(n):
                if mask & (1 << i):
                    union = union | open_list[i]
            if union not in self.open_sets:
                return False
        return True

    def dream_consequence(self, premises: FrozenSet[int], point: int) -> bool:
        """Check if point is a dream consequence of premises.

        Returns True if every open set containing premises also contains point.
        """
        for s in self.open_sets:
            if premises <= s and point not in s:
                return False
        return True


def singleton_dream_space(n: int) -> DreamSpace:
    """Construct the singleton dream space on {0, ..., n-1}.

    Open sets: ∅, {0,...,n-1}, and each singleton {i}.
    """
    universe = frozenset(range(n))
    open_sets: Set[FrozenSet[int]] = {frozenset(), universe}
    for i in range(n):
        open_sets.add(frozenset({i}))
    return DreamSpace(universe=universe, open_sets=open_sets)


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 3: Closed-World Assumption Engine
# ═══════════════════════════════════════════════════════════════════════

T = TypeVar('T')


class CWAReasoner(Generic[T]):
    """Closed-world assumption reasoner over Belnap valuations.

    Demonstrates non-monotonic reasoning: expanding the knowledge base
    can retract previously held beliefs.
    """

    def __init__(self, all_propositions: List[T]) -> None:
        self.propositions = all_propositions
        self.known_true: Set[T] = set()

    def tell(self, prop: T) -> None:
        """Add a proposition to the knowledge base."""
        self.known_true.add(prop)

    def valuation(self, prop: T) -> BelnapVal:
        """CWA valuation: known → TRUE, unknown → FALSE."""
        return BelnapVal.TRUE if prop in self.known_true else BelnapVal.FALSE

    def designated_negations(self) -> Set[T]:
        """Return all propositions whose negation is designated.

        Under CWA, these are the propositions NOT in the knowledge base.
        """
        return {p for p in self.propositions
                if is_designated(belnap_neg(self.valuation(p)))}

    def demonstrate_non_monotonicity(self) -> Optional[Tuple[Set[T], Set[T], T]]:
        """Find a witness of non-monotonicity if one exists.

        Returns (old_kb, new_kb, retracted_prop) where retracted_prop's
        negation was designated under old_kb but not under new_kb.
        """
        old_negations = self.designated_negations()
        old_kb = set(self.known_true)

        for p in self.propositions:
            if p not in self.known_true:
                # Try adding p
                self.known_true.add(p)
                new_negations = self.designated_negations()
                retracted = old_negations - new_negations
                if retracted:
                    new_kb = set(self.known_true)
                    self.known_true.remove(p)
                    return (old_kb, new_kb, next(iter(retracted)))
                self.known_true.remove(p)
        return None


# ═══════════════════════════════════════════════════════════════════════
# Algorithm 4: Dream Space Enumeration
# ═══════════════════════════════════════════════════════════════════════

def enumerate_dream_spaces(n: int) -> List[DreamSpace]:
    """Enumerate all dream spaces on {0, ..., n-1}.

    Uses brute force: checks all subsets of P({0,...,n-1}) for the
    dream space axioms. Only feasible for n ≤ 4.
    """
    universe = frozenset(range(n))
    all_subsets: List[FrozenSet[int]] = []

    # Generate all subsets of {0,...,n-1}
    for mask in range(1 << n):
        s = frozenset(i for i in range(n) if mask & (1 << i))
        all_subsets.append(s)

    dream_spaces: List[DreamSpace] = []
    num_subsets = len(all_subsets)

    # Check all subsets of P({0,...,n-1}) that include ∅ and universe
    empty_idx = all_subsets.index(frozenset())
    univ_idx = all_subsets.index(universe)
    required = {empty_idx, univ_idx}

    for mask in range(1 << num_subsets):
        # Must include ∅ and universe
        if not all(mask & (1 << i) for i in required):
            continue

        open_sets = {all_subsets[i] for i in range(num_subsets) if mask & (1 << i)}
        ds = DreamSpace(universe=universe, open_sets=open_sets)
        if ds.is_valid():
            dream_spaces.append(ds)

    return dream_spaces


if __name__ == "__main__":
    # Quick smoke test
    print("Singleton dream space on {0,...,5}:")
    ds = singleton_dream_space(6)
    print(f"  Valid: {ds.is_valid()}")
    print(f"  Topological: {ds.is_topological()}")
    print(f"  Open sets: {len(ds.open_sets)}")

    print("\nCWA Non-monotonicity demo:")
    cwa = CWAReasoner(["rain", "umbrella", "sun"])
    cwa.tell("rain")
    result = cwa.demonstrate_non_monotonicity()
    if result:
        old, new, retracted = result
        print(f"  Old KB: {old}")
        print(f"  New KB: {new}")
        print(f"  Retracted: ¬{retracted}")

    print("\nDream spaces on {0, 1}:")
    spaces = enumerate_dream_spaces(2)
    topo = sum(1 for ds in spaces if ds.is_topological())
    print(f"  Total dream spaces: {len(spaces)}")
    print(f"  Topological: {topo}")
    print(f"  Non-topological: {len(spaces) - topo}")
