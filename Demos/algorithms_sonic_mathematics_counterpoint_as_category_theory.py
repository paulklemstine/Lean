#!/usr/bin/env python3
"""
Counterpoint Category Theory — Core Algorithms

Type-hinted implementations of the mathematical structures and
algorithms for the Counterpoint Quiver.
"""

from __future__ import annotations
from dataclasses import dataclass
from typing import Set, Dict, List, Tuple, Optional, FrozenSet


@dataclass(frozen=True)
class VoiceLeading:
    """A voice leading: pair of bass and soprano motions in Z/nZ."""
    bass: int
    soprano: int
    n: int = 12

    def target(self, source: int) -> int:
        """Compute the target interval from a given source."""
        return (source + self.soprano - self.bass) % self.n

    def is_parallel(self) -> bool:
        """Check if both voices move by the same nonzero amount."""
        return self.bass % self.n == self.soprano % self.n and self.bass % self.n != 0

    def compose(self, other: VoiceLeading) -> VoiceLeading:
        """Sequential composition: apply self, then other."""
        return VoiceLeading(
            bass=(self.bass + other.bass) % self.n,
            soprano=(self.soprano + other.soprano) % self.n,
            n=self.n
        )

    def motion_type(self) -> str:
        """Classify the motion type of this voice leading."""
        b, s = self.bass % self.n, self.soprano % self.n
        if b == s:
            return "parallel" if b != 0 else "stationary"
        if b == 0 or s == 0:
            return "oblique"
        # Check direction (treating motion > n/2 as "down")
        b_up = b <= self.n // 2
        s_up = s <= self.n // 2
        if b_up == s_up:
            return "similar"
        return "contrary"


@dataclass
class CounterpointSystem:
    """
    A counterpoint system over Z/nZ.

    Parameterized by:
    - n: the number of pitch classes (12 for standard, 19/31 for microtonal)
    - consonant: set of consonant intervals
    - perfect: subset of perfect consonances (subject to parallel-motion restriction)
    """
    n: int
    consonant: FrozenSet[int]
    perfect: FrozenSet[int]

    def __post_init__(self) -> None:
        assert self.perfect <= self.consonant, "Perfect must be subset of consonant"
        assert len(self.consonant) > 0, "Must have at least one consonance"
        assert len(self.perfect) > 0, "Must have at least one perfect consonance"
        assert len(self.consonant - self.perfect) > 0, "Must have imperfect consonances"

    @property
    def imperfect(self) -> FrozenSet[int]:
        return self.consonant - self.perfect

    def is_permitted(self, source: int, target: int, vl: VoiceLeading) -> bool:
        """Check if a voice leading is permitted."""
        if source not in self.consonant or target not in self.consonant:
            return False
        if vl.target(source) != target:
            return False
        if target in self.perfect and vl.is_parallel():
            return False
        return True

    def permitted_vls(self, source: int, target: int) -> List[VoiceLeading]:
        """Enumerate all permitted voice leadings from source to target."""
        result = []
        for b in range(self.n):
            for s in range(self.n):
                vl = VoiceLeading(b, s, self.n)
                if self.is_permitted(source, target, vl):
                    result.append(vl)
        return result

    def adjacency_matrix(self) -> Dict[Tuple[int, int], int]:
        """Compute the adjacency matrix (counting permitted VLs)."""
        adj: Dict[Tuple[int, int], int] = {}
        for s in self.consonant:
            for t in self.consonant:
                adj[(s, t)] = len(self.permitted_vls(s, t))
        return adj

    def incoming_count(self, target: int) -> int:
        """Count total incoming voice leadings to a target interval."""
        return sum(len(self.permitted_vls(s, target)) for s in self.consonant)

    def is_strongly_connected(self) -> bool:
        """Check if every pair of consonant intervals has a permitted VL."""
        for s in self.consonant:
            for t in self.consonant:
                if not self.permitted_vls(s, t):
                    return False
        return True

    def find_non_composable(self) -> Optional[Tuple[int, int, int, VoiceLeading, VoiceLeading]]:
        """Find a pair of composable permitted VLs whose composition is forbidden."""
        for i in self.consonant:
            for j in self.consonant:
                for vl1 in self.permitted_vls(i, j):
                    for k in self.consonant:
                        for vl2 in self.permitted_vls(j, k):
                            comp = vl1.compose(vl2)
                            if not self.is_permitted(i, k, comp):
                                return (i, j, k, vl1, vl2)
        return None

    def bottleneck_analysis(self) -> Dict[int, int]:
        """Compute incoming VL counts for each consonant interval."""
        return {t: self.incoming_count(t) for t in sorted(self.consonant)}

    def verify_bottleneck(self) -> bool:
        """Verify that all perfect consonances have fewer incoming VLs than imperfect."""
        analysis = self.bottleneck_analysis()
        for p in self.perfect:
            for q in self.imperfect:
                if analysis[p] >= analysis[q]:
                    return False
        return True


# Standard 12-TET system
STANDARD_12TET = CounterpointSystem(
    n=12,
    consonant=frozenset({0, 3, 4, 7, 8, 9}),
    perfect=frozenset({0, 7})
)


def shortest_path(sys: CounterpointSystem, source: int, target: int) -> List[VoiceLeading]:
    """Find shortest path of permitted VLs from source to target (BFS)."""
    from collections import deque

    if source == target:
        return []

    queue: deque = deque([(source, [])])
    visited: Set[int] = {source}

    while queue:
        current, path = queue.popleft()
        for next_int in sys.consonant:
            if next_int in visited:
                continue
            vls = sys.permitted_vls(current, next_int)
            if vls:
                new_path = path + [vls[0]]
                if next_int == target:
                    return new_path
                visited.add(next_int)
                queue.append((next_int, new_path))

    return []  # Not reachable (shouldn't happen for connected system)


def counterpoint_graph_stats(sys: CounterpointSystem) -> Dict[str, object]:
    """Compute comprehensive statistics for a counterpoint system."""
    adj = sys.adjacency_matrix()
    intervals = sorted(sys.consonant)

    total_edges = sum(adj.values())
    self_loops = sum(adj[(i, i)] for i in intervals)
    cross_edges = total_edges - self_loops

    bottleneck = sys.bottleneck_analysis()
    min_incoming = min(bottleneck.values())
    max_incoming = max(bottleneck.values())

    return {
        "n": sys.n,
        "num_consonant": len(sys.consonant),
        "num_perfect": len(sys.perfect),
        "total_edges": total_edges,
        "self_loops": self_loops,
        "cross_edges": cross_edges,
        "min_incoming": min_incoming,
        "max_incoming": max_incoming,
        "bottleneck_ratio": min_incoming / max_incoming if max_incoming > 0 else 0,
        "strongly_connected": sys.is_strongly_connected(),
        "has_non_composable": sys.find_non_composable() is not None,
    }


if __name__ == "__main__":
    print("Standard 12-TET Counterpoint System")
    print("=" * 50)

    stats = counterpoint_graph_stats(STANDARD_12TET)
    for key, value in stats.items():
        print(f"  {key}: {value}")

    print("\nBottleneck analysis:")
    names = {0: "P1", 3: "m3", 4: "M3", 7: "P5", 8: "m6", 9: "M6"}
    for interval, count in STANDARD_12TET.bottleneck_analysis().items():
        kind = "PERFECT" if interval in STANDARD_12TET.perfect else "imperfect"
        print(f"  {names[interval]} ({kind}): {count} incoming VLs")

    nc = STANDARD_12TET.find_non_composable()
    if nc:
        i, j, k, vl1, vl2 = nc
        print(f"\nNon-composable example:")
        print(f"  {names[i]} -> {names[j]}: VL({vl1.bass}, {vl1.soprano})")
        print(f"  {names[j]} -> {names[k]}: VL({vl2.bass}, {vl2.soprano})")
        comp = vl1.compose(vl2)
        print(f"  Composition: VL({comp.bass}, {comp.soprano}) — FORBIDDEN")
