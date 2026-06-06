#!/usr/bin/env python3
"""
Algorithms for Dream Logic: Paraconsistent Reasoning

Type-hinted implementations of core algorithms from the formalization.
"""

from enum import IntEnum
from typing import Set, Dict, List, Tuple, FrozenSet, Optional
from dataclasses import dataclass


class TruthValue(IntEnum):
    """Belnap's four truth values."""
    NEITHER = 0
    FALSE = 1
    TRUE = 2
    BOTH = 3


# Negation lookup table
_NEG_TABLE: Dict[TruthValue, TruthValue] = {
    TruthValue.TRUE: TruthValue.FALSE,
    TruthValue.FALSE: TruthValue.TRUE,
    TruthValue.BOTH: TruthValue.BOTH,
    TruthValue.NEITHER: TruthValue.NEITHER,
}

# Conjunction lookup table (truth-order meet)
_CONJ_TABLE: Dict[Tuple[TruthValue, TruthValue], TruthValue] = {
    (TruthValue.FALSE, v): TruthValue.FALSE for v in TruthValue
} | {
    (v, TruthValue.FALSE): TruthValue.FALSE for v in TruthValue
} | {
    (TruthValue.TRUE, TruthValue.TRUE): TruthValue.TRUE,
    (TruthValue.TRUE, TruthValue.BOTH): TruthValue.BOTH,
    (TruthValue.TRUE, TruthValue.NEITHER): TruthValue.NEITHER,
    (TruthValue.BOTH, TruthValue.TRUE): TruthValue.BOTH,
    (TruthValue.BOTH, TruthValue.BOTH): TruthValue.BOTH,
    (TruthValue.BOTH, TruthValue.NEITHER): TruthValue.FALSE,
    (TruthValue.NEITHER, TruthValue.TRUE): TruthValue.NEITHER,
    (TruthValue.NEITHER, TruthValue.BOTH): TruthValue.FALSE,
    (TruthValue.NEITHER, TruthValue.NEITHER): TruthValue.NEITHER,
}

# Disjunction lookup table (truth-order join)
_DISJ_TABLE: Dict[Tuple[TruthValue, TruthValue], TruthValue] = {
    (TruthValue.TRUE, v): TruthValue.TRUE for v in TruthValue
} | {
    (v, TruthValue.TRUE): TruthValue.TRUE for v in TruthValue
} | {
    (TruthValue.FALSE, TruthValue.FALSE): TruthValue.FALSE,
    (TruthValue.FALSE, TruthValue.BOTH): TruthValue.BOTH,
    (TruthValue.FALSE, TruthValue.NEITHER): TruthValue.NEITHER,
    (TruthValue.BOTH, TruthValue.FALSE): TruthValue.BOTH,
    (TruthValue.BOTH, TruthValue.BOTH): TruthValue.BOTH,
    (TruthValue.BOTH, TruthValue.NEITHER): TruthValue.TRUE,
    (TruthValue.NEITHER, TruthValue.FALSE): TruthValue.NEITHER,
    (TruthValue.NEITHER, TruthValue.BOTH): TruthValue.TRUE,
    (TruthValue.NEITHER, TruthValue.NEITHER): TruthValue.NEITHER,
}


def belnap_neg(v: TruthValue) -> TruthValue:
    """Belnap negation: T↔F, Both and Neither are fixed points."""
    return _NEG_TABLE[v]


def belnap_conj(a: TruthValue, b: TruthValue) -> TruthValue:
    """Belnap conjunction (truth-order meet)."""
    return _CONJ_TABLE[(a, b)]


def belnap_disj(a: TruthValue, b: TruthValue) -> TruthValue:
    """Belnap disjunction (truth-order join)."""
    return _DISJ_TABLE[(a, b)]


def is_designated(v: TruthValue) -> bool:
    """Check if a truth value is designated (at least true)."""
    return v in (TruthValue.TRUE, TruthValue.BOTH)


@dataclass(frozen=True)
class DreamState:
    """A dream state with positive and negative proposition sets."""
    pos: FrozenSet[int]
    neg: FrozenSet[int]

    @property
    def contradictions(self) -> FrozenSet[int]:
        """Propositions that are both true and false."""
        return self.pos & self.neg

    @property
    def is_consistent(self) -> bool:
        """No contradictions."""
        return len(self.contradictions) == 0

    def to_bval(self, p: int) -> TruthValue:
        """Convert proposition's status to a Belnap truth value."""
        in_pos = p in self.pos
        in_neg = p in self.neg
        if in_pos and in_neg:
            return TruthValue.BOTH
        elif in_pos:
            return TruthValue.TRUE
        elif in_neg:
            return TruthValue.FALSE
        else:
            return TruthValue.NEITHER

    def consistent_pos(self) -> FrozenSet[int]:
        """Propositions that are true but NOT contradicted."""
        return self.pos - self.neg


@dataclass
class DreamFrame:
    """A dream frame: worlds with accessibility and valuations."""
    worlds: List[int]
    access: Dict[int, Set[int]]
    val: Dict[int, DreamState]

    def beliefs(self, w: int) -> Set[int]:
        """Compute belief set: propositions true at all accessible worlds."""
        accessible = self.access.get(w, set())
        if not accessible:
            return set()
        result: Optional[Set[int]] = None
        for w2 in accessible:
            world_pos = set(self.val[w2].pos)
            result = world_pos if result is None else result & world_pos
        return result or set()

    def is_coherently_open(self, w0: int, s: FrozenSet[int]) -> bool:
        """Check if s is coherently open at w0."""
        for w in self.access.get(w0, set()):
            cp = self.val[w].consistent_pos()
            if s <= cp:
                return True
        return False

    def coherent_open_sets(self, w0: int, universe: Set[int]) -> List[FrozenSet[int]]:
        """Enumerate all coherently open subsets of universe at w0."""
        result = []
        for size in range(len(universe) + 1):
            for subset in _powerset_of_size(universe, size):
                fs = frozenset(subset)
                if self.is_coherently_open(w0, fs):
                    result.append(fs)
        return result

    def contradiction_degree(self) -> int:
        """Maximum contradictions at any single world."""
        return max(len(self.val[w].contradictions) for w in self.worlds)

    def paraconsistency_certificate(self) -> Optional[Tuple[int, int]]:
        """Find (world, prop) witnessing paraconsistency, or None."""
        for w in self.worlds:
            for p in self.val[w].contradictions:
                return (w, p)
        return None


def _powerset_of_size(s: Set[int], k: int) -> List[List[int]]:
    """Generate all subsets of size k."""
    items = sorted(s)
    if k == 0:
        return [[]]
    if k > len(items):
        return []
    result = []
    for i, item in enumerate(items):
        for rest in _powerset_of_size(set(items[i+1:]), k-1):
            result.append([item] + rest)
    return result


def verify_de_morgan() -> bool:
    """Verify De Morgan laws hold for all 16 input pairs."""
    for a in TruthValue:
        for b in TruthValue:
            if belnap_neg(belnap_conj(a, b)) != belnap_disj(belnap_neg(a), belnap_neg(b)):
                return False
            if belnap_neg(belnap_disj(a, b)) != belnap_conj(belnap_neg(a), belnap_neg(b)):
                return False
    return True


def verify_explosion_fails() -> Tuple[TruthValue, TruthValue]:
    """Find witness to explosion failure: (v, w) where v and ¬v designated, w not."""
    for v in TruthValue:
        if is_designated(v) and is_designated(belnap_neg(v)):
            for w in TruthValue:
                if not is_designated(w):
                    return (v, w)
    raise AssertionError("Explosion unexpectedly valid!")


def compute_union_defect(frame: DreamFrame, w0: int, universe: Set[int]) -> int:
    """Count pairs of coherently open sets whose union is not coherently open."""
    opens = frame.coherent_open_sets(w0, universe)
    defect = 0
    for i, s in enumerate(opens):
        for t in opens[i:]:
            if not frame.is_coherently_open(w0, s | t):
                defect += 1
    return defect


if __name__ == "__main__":
    # Verify core properties
    assert verify_de_morgan(), "De Morgan laws failed!"
    v, w = verify_explosion_fails()
    print(f"Explosion fails: v={v.name}, ¬v={belnap_neg(v).name} (both designated), "
          f"w={w.name} (not designated)")

    # Compute union defect for complementary contradiction frame
    frame = DreamFrame(
        worlds=[0, 1],
        access={0: {0, 1}, 1: {0, 1}},
        val={
            0: DreamState(frozenset({0, 1}), frozenset({0})),
            1: DreamState(frozenset({0, 1}), frozenset({1})),
        }
    )
    defect = compute_union_defect(frame, 0, {0, 1})
    print(f"Union defect of complementary contradiction frame: {defect}")
    print(f"Coherently open sets: {frame.coherent_open_sets(0, {0, 1})}")
