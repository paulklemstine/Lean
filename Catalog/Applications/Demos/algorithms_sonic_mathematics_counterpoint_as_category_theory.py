#!/usr/bin/env python3
"""
Algorithms: Voice Leading Algebra for Counterpoint Analysis

Type-hinted implementations of the core VLA algorithms.
"""

from typing import Set, Tuple, List, Dict, Optional
from dataclasses import dataclass


@dataclass(frozen=True)
class VoiceLeading:
    """A voice leading: pair of voice motions in semitones mod n."""
    delta_upper: int
    delta_lower: int
    
    def apply(self, interval: int, n: int = 12) -> int:
        """Apply this voice leading to an interval."""
        return (interval + self.delta_upper - self.delta_lower) % n
    
    def compose(self, other: 'VoiceLeading', n: int = 12) -> 'VoiceLeading':
        """Compose two voice leadings by adding motions."""
        return VoiceLeading(
            (self.delta_upper + other.delta_upper) % n,
            (self.delta_lower + other.delta_lower) % n
        )
    
    def is_parallel(self, n: int = 12) -> bool:
        """Check for parallel motion."""
        return (self.delta_upper % n == self.delta_lower % n and 
                self.delta_upper % n != 0)
    
    def motion_type(self) -> str:
        """Classify the motion type."""
        if self.delta_upper == 0 and self.delta_lower == 0:
            return "stationary"
        elif self.delta_upper == self.delta_lower:
            return "parallel"
        elif self.delta_upper == 0 or self.delta_lower == 0:
            return "oblique"
        else:
            return "similar/contrary"


@dataclass
class VoiceLeadingAlgebra:
    """
    A Voice Leading Algebra over Z/nZ.
    
    Parameters:
        n: modulus (number of pitch classes)
        consonances: set of consonant interval classes
        perfects: set of perfect consonance classes (subset of consonances)
    """
    n: int
    consonances: Set[int]
    perfects: Set[int]
    
    def __post_init__(self):
        assert self.perfects.issubset(self.consonances), \
            "Perfect consonances must be a subset of consonances"
        assert len(self.consonances) > 0, \
            "Must have at least one consonant interval"
    
    def is_valid(self, interval: int, vl: VoiceLeading) -> bool:
        """Check if a voice leading is valid from the given interval."""
        if interval % self.n not in self.consonances:
            return False
        target = vl.apply(interval, self.n)
        if target not in self.consonances:
            return False
        if (interval % self.n in self.perfects and 
            target == interval % self.n and 
            vl.is_parallel(self.n)):
            return False
        return True
    
    def all_voice_leadings(self) -> List[VoiceLeading]:
        """Enumerate all possible voice leadings."""
        return [VoiceLeading(du, dl) for du in range(self.n) for dl in range(self.n)]
    
    def valid_transitions(self, source: int, target: int) -> List[VoiceLeading]:
        """Find all valid voice leadings from source to target interval."""
        result = []
        for vl in self.all_voice_leadings():
            if self.is_valid(source, vl) and vl.apply(source, self.n) == target:
                result.append(vl)
        return result
    
    def adjacency_matrix(self) -> Dict[Tuple[int, int], int]:
        """Compute the adjacency matrix of the counterpoint quiver."""
        matrix = {}
        intervals = sorted(self.consonances)
        for i in intervals:
            for j in intervals:
                matrix[(i, j)] = len(self.valid_transitions(i, j))
        return matrix
    
    def is_strongly_connected(self) -> bool:
        """Check if the counterpoint quiver is strongly connected."""
        intervals = sorted(self.consonances)
        for i in intervals:
            for j in intervals:
                if len(self.valid_transitions(i, j)) == 0:
                    return False
        return True
    
    def check_compositionality(self) -> Optional[Tuple[int, int, VoiceLeading, VoiceLeading]]:
        """
        Check if valid voice leadings are closed under composition.
        Returns a counterexample (i, j, v1, v2) if not, None if they are.
        """
        intervals = sorted(self.consonances)
        for i in intervals:
            for j in intervals:
                for v1 in self.valid_transitions(i, j):
                    for k in intervals:
                        for v2 in self.valid_transitions(j, k):
                            comp = v1.compose(v2, self.n)
                            if not self.is_valid(i, comp):
                                return (i, j, v1, v2)
        return None
    
    def parallel_self_transition_count(self, interval: int) -> int:
        """Count parallel self-transitions from an interval."""
        count = 0
        for a in range(self.n):
            vl = VoiceLeading(a, a)
            if (self.is_valid(interval, vl) and 
                vl.apply(interval, self.n) == interval):
                count += 1
        return count
    
    def inversion_closed(self) -> bool:
        """Check if consonances are closed under inversion (negation mod n)."""
        for i in self.consonances:
            if (-i) % self.n not in self.consonances:
                return False
        return True
    
    def inversion_failures(self) -> Set[int]:
        """Find consonant intervals whose inversion is not consonant."""
        return {i for i in self.consonances if (-i) % self.n not in self.consonances}


def standard_12tet() -> VoiceLeadingAlgebra:
    """The standard 12-TET Voice Leading Algebra."""
    return VoiceLeadingAlgebra(
        n=12,
        consonances={0, 3, 4, 7, 8, 9},
        perfects={0, 7}
    )


def tension_rank(interval: int) -> int:
    """Compute the tension rank of an interval in 12-TET."""
    ranks = {0: 0, 7: 1, 4: 2, 3: 3, 9: 4, 8: 5}
    return ranks.get(interval % 12, 6)


def find_obstruction_witness(vla: VoiceLeadingAlgebra) -> Optional[dict]:
    """
    Find a witness for the Counterpoint Obstruction (non-compositionality).
    
    Returns a dict with keys: source, intermediate, v1, v2, composite, reason
    or None if composition is always valid.
    """
    result = vla.check_compositionality()
    if result is None:
        return None
    
    i, j, v1, v2 = result
    comp = v1.compose(v2, vla.n)
    k = v2.apply(j, vla.n)
    
    return {
        "source": i,
        "intermediate": j,
        "target": k,
        "v1": (v1.delta_upper, v1.delta_lower),
        "v2": (v2.delta_upper, v2.delta_lower),
        "composite": (comp.delta_upper, comp.delta_lower),
        "reason": "parallel perfect consonance in composite"
    }


if __name__ == "__main__":
    vla = standard_12tet()
    
    print("=== Voice Leading Algebra: 12-TET ===")
    print(f"Consonances: {sorted(vla.consonances)}")
    print(f"Perfects: {sorted(vla.perfects)}")
    print(f"Strongly connected: {vla.is_strongly_connected()}")
    print(f"Inversion closed: {vla.inversion_closed()}")
    print(f"Inversion failures: {vla.inversion_failures()}")
    print()
    
    witness = find_obstruction_witness(vla)
    if witness:
        print(f"Obstruction witness found:")
        for k, v in witness.items():
            print(f"  {k}: {v}")
    print()
    
    print("Parallel self-transition counts:")
    for i in sorted(vla.consonances):
        count = vla.parallel_self_transition_count(i)
        kind = "perfect" if i in vla.perfects else "imperfect"
        print(f"  interval {i:2d} ({kind:9s}): {count} transitions")
    print()
    
    print("Adjacency matrix:")
    matrix = vla.adjacency_matrix()
    intervals = sorted(vla.consonances)
    for i in intervals:
        row = [matrix[(i, j)] for j in intervals]
        print(f"  {i:2d}: {row}")
