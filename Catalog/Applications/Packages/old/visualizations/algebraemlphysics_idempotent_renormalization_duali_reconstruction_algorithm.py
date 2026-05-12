#!/usr/bin/env python3
"""
Algorithms for Idempotent Renormalization Duality

Implements the core computational procedures from the research paper:
1. Closure operator computation
2. Admissible section enumeration
3. Extremal decomposition
4. Bellman-consistent reconstruction
5. Minimal generator family extraction
"""

from typing import (
    Callable, Dict, FrozenSet, List, Optional, Set, Tuple
)
from dataclasses import dataclass
from itertools import combinations, product


# =============================================================================
# Core Data Structures
# =============================================================================

Element = int
Scale = int
FSet = FrozenSet[Element]
Section = Dict[Scale, FSet]


@dataclass
class ClosureOp:
    """A closure operator on subsets of {0,...,n-1}.

    Properties:
    - Extensive: S ⊆ cl(S)
    - Monotone: S ⊆ T → cl(S) ⊆ cl(T)
    - Idempotent: cl(cl(S)) = cl(S)
    """
    n: int
    _cl: Callable[[FSet], FSet]

    def cl(self, s: FSet) -> FSet:
        return self._cl(s)

    def is_closed(self, s: FSet) -> bool:
        return self.cl(s) == s

    def closed_sets(self) -> List[FSet]:
        """Enumerate all closed sets. O(2^n) complexity."""
        result = []
        for k in range(self.n + 1):
            for combo in combinations(range(self.n), k):
                s = frozenset(combo)
                if self.is_closed(s):
                    result.append(s)
        return result


@dataclass
class ScaleClosureSystem:
    """A finite scale-indexed closure system.

    Attributes:
        scales: Ordered list of scale labels
        n_configs: Number of configuration elements
        closures: Closure operator at each scale
        transfers: Transfer map (s,t) -> function for s ≤ t
    """
    scales: List[Scale]
    n_configs: int
    closures: Dict[Scale, ClosureOp]
    transfers: Dict[Tuple[Scale, Scale], Callable[[FSet], FSet]]

    def is_admissible(self, section: Section) -> bool:
        """Check if section is admissible.

        Complexity: O(|S|^2 * |C|)
        """
        for s in self.scales:
            if not self.closures[s].is_closed(section[s]):
                return False
        for i, s in enumerate(self.scales):
            for j in range(i + 1, len(self.scales)):
                t = self.scales[j]
                if not self.transfers[(s, t)](section[s]) <= section[t]:
                    return False
        return True

    def is_bellman_consistent(self, section: Section) -> bool:
        """Check Bellman consistency of a section.

        The Bellman law: for all s ≤ t,
            transfer(s,t)(section[s]) ⊆ section[t]

        This is equivalent to admissibility's transfer condition.
        """
        for i, s in enumerate(self.scales):
            for j in range(i + 1, len(self.scales)):
                t = self.scales[j]
                if not self.transfers[(s, t)](section[s]) <= section[t]:
                    return False
        return True


# =============================================================================
# Algorithm 1: Enumerate Admissible Sections
# =============================================================================

def enumerate_admissible_sections(rg: ScaleClosureSystem) -> List[Section]:
    """Enumerate all admissible sections by brute force.

    Complexity: O(∏_s |closed_sets(s)| * |S|^2 * |C|)
    For small instances only.

    Returns:
        List of all admissible sections.
    """
    closed_by_scale = {
        s: rg.closures[s].closed_sets() for s in rg.scales
    }

    result = []
    for combo in product(*[closed_by_scale[s] for s in rg.scales]):
        section = dict(zip(rg.scales, combo))
        if rg.is_admissible(section):
            result.append(section)
    return result


# =============================================================================
# Algorithm 2: Extremal Decomposition
# =============================================================================

def is_extremal(
    rg: ScaleClosureSystem,
    e: Section,
    admissible: List[Section]
) -> bool:
    """Check if section e is extremal (join-irreducible).

    An admissible section e is extremal if for any admissible a, b with
    e ⊆ a ∪ b pointwise, we have e ⊆ a or e ⊆ b.

    Complexity: O(|admissible|^2 * |S| * |C|)
    """
    bot = {s: frozenset() for s in rg.scales}
    if e == bot:
        return False

    for a in admissible:
        for b in admissible:
            covered = all(e[s] <= (a[s] | b[s]) for s in rg.scales)
            if not covered:
                continue
            in_a = all(e[s] <= a[s] for s in rg.scales)
            in_b = all(e[s] <= b[s] for s in rg.scales)
            if not in_a and not in_b:
                return False
    return True


def find_extremals(
    rg: ScaleClosureSystem,
    admissible: List[Section]
) -> List[Section]:
    """Find all extremal admissible sections.

    Complexity: O(|admissible|^3 * |S| * |C|)
    """
    bot = {s: frozenset() for s in rg.scales}
    return [
        e for e in admissible
        if e != bot and is_extremal(rg, e, admissible)
    ]


def extremal_decomposition(
    rg: ScaleClosureSystem,
    x: Section,
    extremals: List[Section]
) -> Optional[List[Section]]:
    """Decompose x as a union of extremal sections.

    Returns a list of extremals whose pointwise union equals x,
    or None if decomposition fails.

    Uses greedy approach: iteratively subtract extremals.
    Complexity: O(|extremals| * |S| * |C|)
    """
    remaining = {s: set(x[s]) for s in rg.scales}
    decomp = []

    for e in extremals:
        if all(not (set(e[s]) - remaining[s]) for s in rg.scales):
            if any(e[s] for s in rg.scales):
                decomp.append(e)

    # Verify
    union = {s: frozenset() for s in rg.scales}
    for e in decomp:
        union = {s: union[s] | e[s] for s in rg.scales}

    if union == x:
        return decomp
    return None


# =============================================================================
# Algorithm 3: Reconstruction from Boundary Data
# =============================================================================

def reconstruct_step(
    rg: ScaleClosureSystem,
    current: Section
) -> Section:
    """One step of the reconstruction algorithm.

    For each scale s:
    1. Start with current[s]
    2. Add transfers from all finer scales
    3. Apply closure

    Complexity: O(|S|^2 * |C|)
    """
    new = {}
    for s in rg.scales:
        base = set(current[s])
        for t in rg.scales:
            if rg.scales.index(t) <= rg.scales.index(s):
                transferred = rg.transfers[(t, s)](current[t])
                base |= transferred
        new[s] = rg.closures[s].cl(frozenset(base))
    return new


def reconstruct_from_boundary(
    rg: ScaleClosureSystem,
    boundary: Dict[Scale, FSet],
    max_steps: int = 100
) -> Tuple[Section, int, List[int]]:
    """Reconstruct full section from boundary data.

    Args:
        rg: The scale closure system
        boundary: Partial data at some scales
        max_steps: Maximum iterations

    Returns:
        (final_section, steps_to_convergence, energy_trace)

    Complexity: O(max_steps * |S|^2 * |C|), but typically
    converges in O(|S| * log(|C|)) steps.
    """
    current = {
        s: boundary.get(s, frozenset())
        for s in rg.scales
    }

    energies = []
    for step in range(max_steps):
        energy = sum(len(current[s]) for s in rg.scales)
        energies.append(energy)

        new = reconstruct_step(rg, current)
        if new == current:
            return current, step, energies
        current = new

    return current, max_steps, energies


# =============================================================================
# Algorithm 4: Minimal Generator Family
# =============================================================================

def find_minimal_generators(
    rg: ScaleClosureSystem,
    admissible: List[Section]
) -> List[Section]:
    """Find a minimal generator family for the admissible sections.

    A generator family G has the property that every nonzero admissible
    section is a union of elements of G.

    Uses greedy elimination: start with all extremals and remove
    any that are redundant.

    Complexity: O(|extremals|^2 * |admissible| * |S| * |C|)
    """
    extremals = find_extremals(rg, admissible)
    bot = {s: frozenset() for s in rg.scales}

    # Check if G generates all admissible sections
    def generates(G):
        for x in admissible:
            if x == bot:
                continue
            # Check if x is a union of elements of G
            covered = False
            for k in range(1, len(G) + 1):
                for combo in combinations(G, k):
                    union = {s: frozenset() for s in rg.scales}
                    for g in combo:
                        union = {s: union[s] | g[s] for s in rg.scales}
                    if union == x:
                        covered = True
                        break
                if covered:
                    break
            if not covered:
                return False
        return True

    # Start with all extremals
    G = list(extremals)

    # Try removing each one
    minimal = list(G)
    for e in G:
        candidate = [g for g in minimal if g != e]
        if generates(candidate):
            minimal = candidate

    return minimal


# =============================================================================
# Algorithm 5: Bellman Consistency Verification
# =============================================================================

def verify_bellman_system(
    rg: ScaleClosureSystem
) -> Dict[str, any]:
    """Comprehensive verification of Bellman consistency for all admissible sections.

    Returns a report with:
    - Number of admissible sections
    - Number of extremals
    - Bellman consistency status for each section
    - Generator family size
    """
    admissible = enumerate_admissible_sections(rg)
    extremals = find_extremals(rg, admissible)
    bot = {s: frozenset() for s in rg.scales}

    bellman_results = []
    for sec in admissible:
        is_bell = rg.is_bellman_consistent(sec)
        bellman_results.append((sec, is_bell))

    generators = find_minimal_generators(rg, admissible)

    return {
        "n_admissible": len(admissible),
        "n_extremals": len(extremals),
        "n_generators": len(generators),
        "all_bellman_consistent": all(b for _, b in bellman_results),
        "admissible": admissible,
        "extremals": extremals,
        "generators": generators,
    }


# =============================================================================
# Utility: Create Standard Examples
# =============================================================================

def partition_closure(n: int, partition: List[Set[int]]) -> ClosureOp:
    """Create a closure operator from a partition."""
    def cl(s):
        result = set()
        for block in partition:
            if block & set(s):
                result |= block
        return frozenset(result)
    return ClosureOp(n, cl)


def make_hierarchical_system(
    n_configs: int,
    partitions: List[List[Set[int]]]
) -> ScaleClosureSystem:
    """Create a hierarchical scale closure system.

    Args:
        n_configs: Number of configuration elements
        partitions: List of partitions, from fine to coarse

    Returns:
        A ScaleClosureSystem with identity transfers
    """
    scales = list(range(len(partitions)))
    closures = {
        s: partition_closure(n_configs, partitions[s])
        for s in scales
    }
    transfers = {}
    for i in scales:
        for j in range(i, len(scales)):
            transfers[(i, j)] = lambda s: s  # identity transfer

    return ScaleClosureSystem(scales, n_configs, closures, transfers)


# =============================================================================
# Example Usage
# =============================================================================

if __name__ == "__main__":
    # Create a 3-level hierarchical system
    system = make_hierarchical_system(6, [
        [{0, 1}, {2, 3}, {4, 5}],           # Fine
        [{0, 1, 2}, {3, 4, 5}],              # Medium
        [{0, 1, 2, 3, 4, 5}],                # Coarse
    ])

    print("Hierarchical Scale Closure System")
    print("=" * 50)

    report = verify_bellman_system(system)
    print(f"Admissible sections: {report['n_admissible']}")
    print(f"Extremal sections:   {report['n_extremals']}")
    print(f"Generator family:    {report['n_generators']}")
    print(f"All Bellman consistent: {report['all_bellman_consistent']}")

    print("\nExtremal sections (phases):")
    for i, e in enumerate(report['extremals']):
        print(f"  Phase {i}: {[sorted(e[s]) for s in system.scales]}")

    print("\nMinimal generators:")
    for i, g in enumerate(report['generators']):
        print(f"  Gen {i}: {[sorted(g[s]) for s in system.scales]}")

    # Reconstruction demo
    print("\nReconstruction from boundary data {0}:")
    result, steps, energies = reconstruct_from_boundary(
        system, {0: frozenset({0})}
    )
    print(f"  Converged in {steps} steps")
    print(f"  Result: {[sorted(result[s]) for s in system.scales]}")
    print(f"  Energy trace: {energies}")
