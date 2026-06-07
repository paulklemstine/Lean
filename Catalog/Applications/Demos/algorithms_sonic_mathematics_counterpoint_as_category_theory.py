#!/usr/bin/env python3
"""
Algorithms for Counterpoint Category Theory

Type-hinted implementations of the core algorithms used in analyzing
the categorical structure of first-species counterpoint.
"""

from math import gcd
from typing import Optional
from dataclasses import dataclass, field


# ============================================================
# Algorithm 1: Consonance Classification via Group Theory
# ============================================================

def additive_order(k: int, n: int) -> int:
    """
    Compute the additive order of k in Z/nZ.

    The additive order is the smallest positive integer m such that
    m * k ≡ 0 (mod n). Equivalently, ord(k) = n / gcd(n, k).

    Args:
        k: Element of Z/nZ
        n: Modulus (must be positive)

    Returns:
        The additive order of k in Z/nZ
    """
    if n <= 0:
        raise ValueError("Modulus must be positive")
    k = k % n
    if k == 0:
        return 1
    return n // gcd(n, k)


def classify_consonance(interval: int, n: int = 12,
                        consonant_set: Optional[set[int]] = None) -> str:
    """
    Classify a consonant interval as perfect or imperfect using
    the group-theoretic characterization.

    An interval is perfect iff its additive order in Z/nZ is 1 (trivial)
    or n (generates the full group).

    Args:
        interval: Interval in semitones
        n: Size of the pitch class group (default 12 for standard tuning)
        consonant_set: Set of consonant intervals (default: {0,3,4,7,8,9})

    Returns:
        'perfect', 'imperfect', or 'dissonant'
    """
    if consonant_set is None:
        consonant_set = {0, 3, 4, 7, 8, 9}

    interval = interval % n
    if interval not in consonant_set:
        return 'dissonant'

    order = additive_order(interval, n)
    if order == 1 or order == n:
        return 'perfect'
    else:
        return 'imperfect'


# ============================================================
# Algorithm 2: Transition Graph Construction
# ============================================================

@dataclass
class TransitionGraph:
    """
    The counterpoint transition graph.

    Vertices are consonant intervals. An edge from i to j exists iff
    the voice leading from interval i to interval j is valid in
    first-species counterpoint.

    The key rule: parallel motion (i → i) is forbidden for perfect consonances.
    All other transitions between consonant intervals are valid.
    """
    n: int = 12
    consonant: set[int] = field(default_factory=lambda: {0, 3, 4, 7, 8, 9})
    perfect: set[int] = field(default_factory=lambda: {0, 7})

    def is_valid_transition(self, src: int, tgt: int) -> bool:
        """Check if the transition from src to tgt is valid."""
        src, tgt = src % self.n, tgt % self.n
        if src not in self.consonant or tgt not in self.consonant:
            return False
        if src == tgt and src in self.perfect:
            return False
        return True

    def all_valid_transitions(self) -> list[tuple[int, int]]:
        """Enumerate all valid transitions."""
        return [(s, t) for s in sorted(self.consonant)
                for t in sorted(self.consonant)
                if self.is_valid_transition(s, t)]

    def adjacency_matrix(self) -> list[list[int]]:
        """Return the adjacency matrix of the transition graph."""
        vertices = sorted(self.consonant)
        idx = {v: i for i, v in enumerate(vertices)}
        m = len(vertices)
        matrix = [[0] * m for _ in range(m)]
        for s, t in self.all_valid_transitions():
            matrix[idx[s]][idx[t]] = 1
        return matrix

    def is_strongly_connected(self) -> bool:
        """Check if every vertex can reach every other vertex."""
        vertices = sorted(self.consonant)
        if not vertices:
            return True
        for start in vertices:
            # BFS from start
            visited = {start}
            queue = [start]
            while queue:
                curr = queue.pop(0)
                for v in vertices:
                    if v not in visited and self.is_valid_transition(curr, v):
                        visited.add(v)
                        queue.append(v)
            if visited != set(vertices):
                return False
        return True


# ============================================================
# Algorithm 3: Subgroup Diamond Construction
# ============================================================

def cyclic_subgroup(k: int, n: int) -> frozenset[int]:
    """Compute the cyclic subgroup ⟨k⟩ in Z/nZ."""
    return frozenset((m * k) % n for m in range(n))


def subgroup_diamond(consonant_set: set[int], n: int = 12) -> dict:
    """
    Construct the subgroup diamond from consonant intervals.

    Returns a dictionary mapping each distinct subgroup to its generators
    and inclusion relationships.
    """
    subgroups: dict[frozenset[int], list[int]] = {}
    for k in sorted(consonant_set):
        sg = cyclic_subgroup(k, n)
        if sg not in subgroups:
            subgroups[sg] = []
        subgroups[sg].append(k)

    # Build Hasse diagram (immediate containment)
    sorted_sgs = sorted(subgroups.keys(), key=len)
    hasse: dict[frozenset[int], list[frozenset[int]]] = {sg: [] for sg in sorted_sgs}

    for i, sg1 in enumerate(sorted_sgs):
        for sg2 in sorted_sgs[i+1:]:
            if sg1 < sg2:  # strict subset
                # Check if there's an intermediate subgroup
                is_immediate = True
                for sg3 in sorted_sgs:
                    if sg1 < sg3 < sg2:
                        is_immediate = False
                        break
                if is_immediate:
                    hasse[sg1].append(sg2)

    return {
        'subgroups': {tuple(sorted(sg)): gens for sg, gens in subgroups.items()},
        'hasse_edges': [(tuple(sorted(s)), tuple(sorted(t)))
                        for s, ts in hasse.items() for t in ts],
        'num_elements': len(subgroups),
        'is_diamond': len(subgroups) == 4  # Expected for standard consonances
    }


# ============================================================
# Algorithm 4: Rigidity Check
# ============================================================

def check_rigidity(consonant_set: set[int], n: int = 12) -> dict:
    """
    Check if the consonance set is rigid under Aut(Z/nZ).

    An automorphism of Z/nZ is multiplication by a unit u (gcd(u, n) = 1).
    The consonance set is rigid if only u = 1 preserves it.

    Returns:
        Dictionary with units, their images of the consonance set,
        and which ones preserve it.
    """
    units = [u for u in range(n) if gcd(u, n) == 1]
    results = {}

    for u in units:
        image = frozenset((u * k) % n for k in consonant_set)
        preserves = image == frozenset(consonant_set)
        results[u] = {
            'image': sorted(image),
            'preserves': preserves
        }

    preserving_units = [u for u, r in results.items() if r['preserves']]

    return {
        'units': units,
        'results': results,
        'preserving_units': preserving_units,
        'is_rigid': preserving_units == [1],
        'automorphism_group_order': len(preserving_units)
    }


# ============================================================
# Algorithm 5: Generalized Counterpoint Systems
# ============================================================

def analyze_counterpoint_system(n: int, consonant_set: set[int],
                                 perfect_set: set[int]) -> dict:
    """
    Analyze a generalized counterpoint system over Z/nZ.

    This generalizes the standard 12-TET system to arbitrary equal temperaments.

    Args:
        n: Number of pitch classes
        consonant_set: Set of consonant intervals
        perfect_set: Set of perfect consonances (subset of consonant_set)

    Returns:
        Complete analysis of the system
    """
    imperfect_set = consonant_set - perfect_set

    # Check the perfect ↔ extreme order characterization
    extreme_order = set()
    for k in consonant_set:
        order = additive_order(k, n)
        if order == 1 or order == n:
            extreme_order.add(k)

    characterization_holds = extreme_order == perfect_set

    # Check complement closure
    complement_closed = all((-k) % n in consonant_set for k in consonant_set)
    complement_exceptions = [k for k in consonant_set if (-k) % n not in consonant_set]

    # Build transition graph
    graph = TransitionGraph(n, consonant_set, perfect_set)
    num_transitions = len(graph.all_valid_transitions())
    connected = graph.is_strongly_connected()

    # Diamond structure
    diamond = subgroup_diamond(consonant_set, n)

    # Rigidity
    rigidity = check_rigidity(consonant_set, n)

    return {
        'n': n,
        'consonant_count': len(consonant_set),
        'perfect_count': len(perfect_set),
        'imperfect_count': len(imperfect_set),
        'perfect_iff_extreme_order': characterization_holds,
        'complement_closed': complement_closed,
        'complement_exceptions': complement_exceptions,
        'transition_count': num_transitions,
        'strongly_connected': connected,
        'diamond_elements': diamond['num_elements'],
        'is_diamond': diamond['is_diamond'],
        'is_rigid': rigidity['is_rigid'],
    }


# ============================================================
# Main: Run all analyses
# ============================================================

if __name__ == '__main__':
    print("Standard 12-TET Analysis:")
    print("-" * 40)
    result = analyze_counterpoint_system(12, {0, 3, 4, 7, 8, 9}, {0, 7})
    for k, v in result.items():
        print(f"  {k}: {v}")

    print()
    print("Exploring other equal temperaments:")
    print()

    # 19-TET (meantone-like): consonances at 0, 5, 6, 11, 13, 14
    # (approximations of standard consonances)
    for n_tet, cons, perf in [
        (19, {0, 5, 6, 11, 13, 14}, {0, 11}),
        (24, {0, 6, 8, 14, 16, 18}, {0, 14}),
        (7, {0, 2, 4}, {0, 4}),  # Diatonic "scale" as Z/7Z
    ]:
        print(f"  {n_tet}-TET with consonances {sorted(cons)}, perfect {sorted(perf)}:")
        r = analyze_counterpoint_system(n_tet, cons, perf)
        holds = "✓" if r['perfect_iff_extreme_order'] else "✗"
        print(f"    Perfect ↔ extreme order: {holds}")
        print(f"    Transitions: {r['transition_count']}, Connected: {r['strongly_connected']}")
        print(f"    Rigid: {r['is_rigid']}, Diamond elements: {r['diamond_elements']}")
        print()
