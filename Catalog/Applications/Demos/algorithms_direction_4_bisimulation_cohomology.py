#!/usr/bin/env python3
"""
Bisimulation Cohomology: Core Algorithms

Implements the algorithms for computing behavioral equivalences and
cohomological obstructions in labeled transition systems.

Algorithms:
  1. Partition refinement for bisimulation classes — O(n² · |E|)
  2. Depth-bounded trace equivalence via fixpoint — O(n² · d)
  3. H¹ obstruction detection — O(n² · d)
  4. Cocycle gap computation — O(n² · d)

where n = number of states, |E| = number of edges, d = stabilization depth.
"""

from typing import Dict, FrozenSet, List, Optional, Set, Tuple


# ─────────────────────────────────────────────────────────────────────
# Data Types
# ─────────────────────────────────────────────────────────────────────

State = int
LTS = Dict[State, Set[State]]  # state -> set of successors (unary action)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 1: Partition Refinement for Bisimulation
# ─────────────────────────────────────────────────────────────────────

def compute_bisimulation_classes(lts: LTS) -> List[FrozenSet[State]]:
    """Compute the coarsest bisimulation equivalence classes.

    Uses partition refinement (Kanellakis-Smolka algorithm variant).

    Complexity: O(n² · |E|) where n = |states|, |E| = number of transitions.

    Args:
        lts: A labeled transition system (unary action).

    Returns:
        List of frozensets, each a bisimulation equivalence class.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> classes = compute_bisimulation_classes(lts)
        >>> sorted([sorted(c) for c in classes])
        [[0], [1], [2]]
    """
    states = list(lts.keys())
    if not states:
        return []

    # Initial partition: separate states by whether they have successors
    has_succ = frozenset(s for s in states if lts[s])
    no_succ = frozenset(s for s in states if not lts[s])
    partition: List[FrozenSet[State]] = []
    if has_succ:
        partition.append(has_succ)
    if no_succ:
        partition.append(no_succ)
    if not partition:
        partition = [frozenset(states)]

    # Iterative refinement
    changed = True
    while changed:
        changed = False
        new_partition: List[FrozenSet[State]] = []
        for block in partition:
            # Compute signature for each state: which blocks are reachable
            signatures: Dict[FrozenSet[int], Set[State]] = {}
            for s in block:
                sig = frozenset(
                    i for i, b in enumerate(partition)
                    if any(sp in b for sp in lts[s])
                )
                if sig not in signatures:
                    signatures[sig] = set()
                signatures[sig].add(s)
            if len(signatures) > 1:
                changed = True
            new_partition.extend(frozenset(v) for v in signatures.values())
        partition = new_partition

    return partition


def are_bisimilar(lts: LTS, s: State, t: State) -> bool:
    """Check if two states are bisimilar.

    Args:
        lts: The LTS.
        s, t: States to compare.

    Returns:
        True iff s and t are bisimilar.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> are_bisimilar(lts, 0, 2)
        False
        >>> are_bisimilar(lts, 0, 0)
        True
    """
    classes = compute_bisimulation_classes(lts)
    return any(s in cls and t in cls for cls in classes)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 2: Depth-Bounded Trace Equivalence
# ─────────────────────────────────────────────────────────────────────

def compute_depth_equiv_classes(lts: LTS, depth: int) -> List[FrozenSet[State]]:
    """Compute depth-n equivalence classes.

    Two states are depth-n equivalent if they agree on all traces of length ≤ n.
    This is computed iteratively: depth-0 equivalence groups all states together,
    and each successive depth refines using the previous level's classes.

    Complexity: O(n² · d) where n = |states|, d = depth.

    Args:
        lts: The LTS.
        depth: Maximum trace depth to consider.

    Returns:
        List of frozensets, each a depth-n equivalence class.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> [sorted(c) for c in compute_depth_equiv_classes(lts, 0)]
        [[0, 1, 2]]
        >>> sorted([sorted(c) for c in compute_depth_equiv_classes(lts, 1)])
        [[0, 2], [1]]
        >>> sorted([sorted(c) for c in compute_depth_equiv_classes(lts, 2)])
        [[0], [1], [2]]
    """
    states = list(lts.keys())
    if not states:
        return []

    # Depth 0: all states equivalent
    partition = [frozenset(states)]

    for d in range(1, depth + 1):
        new_partition: List[FrozenSet[State]] = []
        for block in partition:
            signatures: Dict[FrozenSet[int], Set[State]] = {}
            for s in block:
                # Signature at depth d: which depth-(d-1) classes can s reach?
                sig = frozenset(
                    i for i, b in enumerate(partition)
                    if any(sp in b for sp in lts[s])
                )
                # Also distinguish "has successors" from "no successors"
                key = (bool(lts[s]), sig)
                hkey = frozenset([key])  # type: ignore
                if hkey not in signatures:
                    signatures[hkey] = set()
                signatures[hkey].add(s)
            new_partition.extend(frozenset(v) for v in signatures.values())
        partition = new_partition

    return partition


def depth_n_equivalent(lts: LTS, depth: int, s: State, t: State) -> bool:
    """Check if two states are depth-n equivalent.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> depth_n_equivalent(lts, 1, 0, 2)
        True
        >>> depth_n_equivalent(lts, 2, 0, 2)
        False
    """
    classes = compute_depth_equiv_classes(lts, depth)
    return any(s in cls and t in cls for cls in classes)


# ─────────────────────────────────────────────────────────────────────
# Algorithm 3: H¹ Obstruction Detection
# ─────────────────────────────────────────────────────────────────────

def detect_h1_obstruction(lts: LTS, s: State, t: State) -> bool:
    """Detect whether states s and t exhibit an H¹ obstruction.

    An H¹ obstruction exists when s and t are depth-1 equivalent
    (agree on all one-step experiments) but are not bisimilar.

    Complexity: O(n² · |E|) for bisimulation check.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> detect_h1_obstruction(lts, 0, 2)
        True
        >>> detect_h1_obstruction(lts, 0, 1)
        False
    """
    return depth_n_equivalent(lts, 1, s, t) and not are_bisimilar(lts, s, t)


def find_all_obstructions(lts: LTS) -> List[Tuple[State, State, int]]:
    """Find all pairs of states with H¹ obstructions and their gap depths.

    Returns:
        List of (s, t, gap_depth) tuples where gap_depth is the smallest n
        such that s and t are depth-n equivalent but not depth-(n+1) equivalent.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> find_all_obstructions(lts)
        [(0, 2, 1)]
    """
    states = sorted(lts.keys())
    obstructions = []
    for i, s in enumerate(states):
        for t in states[i + 1:]:
            if detect_h1_obstruction(lts, s, t):
                gap = find_gap_depth(lts, s, t)
                obstructions.append((s, t, gap))
    return obstructions


# ─────────────────────────────────────────────────────────────────────
# Algorithm 4: Cocycle Gap Computation
# ─────────────────────────────────────────────────────────────────────

def find_gap_depth(lts: LTS, s: State, t: State, max_depth: int = 20) -> int:
    """Find the gap depth: smallest n where depth-n equiv holds but depth-(n+1) fails.

    This is the level of the canonical 1-cocycle in the depth filtration.

    Args:
        lts: The LTS.
        s, t: States to check.
        max_depth: Maximum depth to search.

    Returns:
        The gap depth n, or -1 if no gap found within max_depth.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> find_gap_depth(lts, 0, 2)
        1
    """
    for n in range(max_depth):
        if depth_n_equivalent(lts, n, s, t) and not depth_n_equivalent(lts, n + 1, s, t):
            return n
    return -1


def stabilization_depth(lts: LTS) -> int:
    """Compute the depth at which the depth-equivalence filtration stabilizes.

    For finite LTS, this always terminates. The stabilization depth is the
    smallest n such that depth-n equivalence equals bisimulation.

    Complexity: O(n³ · d) where d is the stabilization depth.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> stabilization_depth(lts)
        2
    """
    states = sorted(lts.keys())
    bisim_classes = compute_bisimulation_classes(lts)

    for d in range(len(states) + 1):
        depth_classes = compute_depth_equiv_classes(lts, d)
        # Check if depth classes match bisimulation classes
        if set(depth_classes) == set(bisim_classes):
            return d

    return len(states)  # Upper bound


# ─────────────────────────────────────────────────────────────────────
# Visualization Helpers
# ─────────────────────────────────────────────────────────────────────

def filtration_table(lts: LTS, max_depth: Optional[int] = None) -> str:
    """Generate a table showing the depth-equivalence filtration.

    Example:
        >>> lts = {0: {1, 2}, 1: set(), 2: {1}}
        >>> print(filtration_table(lts))
        Depth | Equivalence Classes
        ------+--------------------
            0 | {0, 1, 2}
            1 | {0, 2} {1}
            2 | {0} {1} {2}  ← stabilized (= bisimulation)
    """
    if max_depth is None:
        max_depth = stabilization_depth(lts) + 1

    bisim_classes = set(compute_bisimulation_classes(lts))
    lines = ["Depth | Equivalence Classes", "------+--------------------"]

    for d in range(max_depth + 1):
        classes = compute_depth_equiv_classes(lts, d)
        class_strs = " ".join(
            "{" + ", ".join(str(s) for s in sorted(c)) + "}" for c in classes
        )
        stable = " ← stabilized (= bisimulation)" if set(classes) == bisim_classes else ""
        lines.append(f"    {d} | {class_strs}{stable}")

    return "\n".join(lines)


if __name__ == "__main__":
    # Demo with the witness system
    print("=== Witness LTS ===")
    witness: LTS = {0: {1, 2}, 1: set(), 2: {1}}
    print(f"States: {{0, 1, 2}}")
    print(f"Transitions: 0→{{1,2}}, 1→∅, 2→{{1}}")
    print()
    print(filtration_table(witness))
    print()
    print(f"Bisimulation classes: {[sorted(c) for c in compute_bisimulation_classes(witness)]}")
    print(f"H¹ obstructions: {find_all_obstructions(witness)}")
    print(f"Stabilization depth: {stabilization_depth(witness)}")

    import doctest
    results = doctest.testmod()
    if results.failed == 0:
        print(f"\nAll {results.attempted} doctests passed.")
