#!/usr/bin/env python3
"""
Counterpoint Category Algorithms

Type-hinted implementations of the core algorithms from the
counterpoint-as-category-theory formalization.
"""

from typing import List, Tuple, Dict, Set, Optional
from dataclasses import dataclass
from enum import Enum


class CInterval(Enum):
    """Consonant interval classes in first-species counterpoint."""
    UNISON = 0   # perfect
    MIN3 = 3     # imperfect
    MAJ3 = 4     # imperfect
    PERF5 = 7    # perfect
    MIN6 = 8     # imperfect
    MAJ6 = 9     # imperfect
    
    @property
    def is_perfect(self) -> bool:
        return self in (CInterval.UNISON, CInterval.PERF5)
    
    @property
    def is_imperfect(self) -> bool:
        return not self.is_perfect
    
    @property
    def complement(self) -> 'CInterval':
        """Voice exchange involution."""
        comp_map = {
            CInterval.UNISON: CInterval.UNISON,
            CInterval.MIN3: CInterval.MAJ6,
            CInterval.MAJ3: CInterval.MIN6,
            CInterval.PERF5: CInterval.PERF5,
            CInterval.MIN6: CInterval.MAJ3,
            CInterval.MAJ6: CInterval.MIN3,
        }
        return comp_map[self]


class MotionKind(Enum):
    """Types of relative motion between two voices."""
    CONTRARY = 0   # opposite directions
    OBLIQUE = 1    # one stays
    SIMILAR = 2    # same direction, different amount
    PARALLEL = 3   # same direction, same amount


def is_permitted(motion: MotionKind, target: CInterval) -> bool:
    """
    Whether a motion kind is permitted for a transition TO a target interval.
    
    Rules of strict first-species counterpoint:
    - Parallel motion to a perfect consonance: FORBIDDEN
    - Similar motion to a perfect consonance: FORBIDDEN
    - All other motions: PERMITTED
    """
    if target.is_perfect:
        return motion in (MotionKind.CONTRARY, MotionKind.OBLIQUE)
    return True


def permitted_motions(target: CInterval) -> List[MotionKind]:
    """List all permitted motion kinds for a given target interval."""
    return [m for m in MotionKind if is_permitted(m, target)]


def permitted_motion_count(target: CInterval) -> int:
    """Count permitted motion kinds for a given target."""
    return len(permitted_motions(target))


@dataclass
class WeightMatrix:
    """
    The counterpoint weight matrix W ∈ M₆(ℕ).
    
    W(i,j) = number of permitted motion kinds from interval i to interval j.
    Key property: W depends only on the column (target), not the row (source).
    """
    intervals: List[CInterval]
    matrix: Dict[Tuple[CInterval, CInterval], int]
    
    @classmethod
    def build(cls) -> 'WeightMatrix':
        intervals = list(CInterval)
        matrix = {}
        for src in intervals:
            for tgt in intervals:
                matrix[(src, tgt)] = permitted_motion_count(tgt)
        return cls(intervals=intervals, matrix=matrix)
    
    def trace(self) -> int:
        return sum(self.matrix[(i, i)] for i in self.intervals)
    
    def total(self) -> int:
        return sum(self.matrix.values())
    
    def row_sum(self, src: CInterval) -> int:
        return sum(self.matrix[(src, tgt)] for tgt in self.intervals)
    
    def col_sum(self, tgt: CInterval) -> int:
        return sum(self.matrix[(src, tgt)] for src in self.intervals)
    
    def w_squared(self, a: CInterval, c: CInterval) -> int:
        """Compute (W²)(a,c) = sum_b W(a,b) * W(b,c)."""
        return sum(
            self.matrix[(a, b)] * self.matrix[(b, c)]
            for b in self.intervals
        )
    
    def verify_rank_one(self) -> bool:
        """Verify W² = trace(W) · W."""
        tr = self.trace()
        return all(
            self.w_squared(a, c) == tr * self.matrix[(a, c)]
            for a in self.intervals
            for c in self.intervals
        )


def strictness_accessibility(strictness: int, target: CInterval) -> int:
    """
    Compute accessibility under parameterized strictness.
    
    Strictness levels:
    0: No restrictions (all 4 motions always permitted)
    1: No parallel perfect consonances
    2: No parallel or similar to perfect consonances (standard model)
    3: Only contrary motion to perfect consonances
    """
    if not target.is_perfect:
        return 4  # imperfect always fully accessible
    
    if strictness == 0:
        return 4
    elif strictness == 1:
        return 3  # all except parallel
    elif strictness == 2:
        return 2  # only contrary and oblique
    else:
        return 1  # only contrary


def verify_poset_conjecture() -> Tuple[bool, str]:
    """
    Test the conjecture: Is the counterpoint transition relation a partial order?
    
    Returns (is_poset, explanation).
    """
    # Check antisymmetry
    for a in CInterval:
        for b in CInterval:
            if a != b:
                # Both are reachable (transition_complete)
                a_to_b = any(is_permitted(m, b) for m in MotionKind)
                b_to_a = any(is_permitted(m, a) for m in MotionKind)
                if a_to_b and b_to_a:
                    return (False, 
                        f"Antisymmetry fails: {a.name} → {b.name} and "
                        f"{b.name} → {a.name}, but {a.name} ≠ {b.name}")
    return (True, "Relation is antisymmetric")


def compute_border_counts() -> Dict[str, int]:
    """Compute morphism counts for perfect/imperfect subquivers and borders."""
    W = WeightMatrix.build()
    
    perfect = [i for i in CInterval if i.is_perfect]
    imperfect = [i for i in CInterval if i.is_imperfect]
    
    perf_perf = sum(W.matrix[(s, t)] for s in perfect for t in perfect)
    perf_imp = sum(W.matrix[(s, t)] for s in perfect for t in imperfect)
    imp_perf = sum(W.matrix[(s, t)] for s in imperfect for t in perfect)
    imp_imp = sum(W.matrix[(s, t)] for s in imperfect for t in imperfect)
    
    return {
        'perfect_to_perfect': perf_perf,
        'perfect_to_imperfect': perf_imp,
        'imperfect_to_perfect': imp_perf,
        'imperfect_to_imperfect': imp_imp,
        'total': perf_perf + perf_imp + imp_perf + imp_imp,
    }


if __name__ == "__main__":
    # Run all algorithms
    print("=== Weight Matrix ===")
    W = WeightMatrix.build()
    print(f"Trace: {W.trace()}")
    print(f"Total: {W.total()}")
    print(f"Rank-1 (W² = 20·W): {W.verify_rank_one()}")
    
    print("\n=== Poset Conjecture ===")
    is_poset, explanation = verify_poset_conjecture()
    print(f"Is poset: {is_poset}")
    print(f"Reason: {explanation}")
    
    print("\n=== Border Counts ===")
    counts = compute_border_counts()
    for k, v in counts.items():
        print(f"  {k}: {v}")
    
    print("\n=== Strictness Sweep ===")
    for s in range(4):
        perf_access = strictness_accessibility(s, CInterval.PERF5)
        imp_access = strictness_accessibility(s, CInterval.MIN3)
        print(f"  Level {s}: perfect={perf_access}, imperfect={imp_access}")
