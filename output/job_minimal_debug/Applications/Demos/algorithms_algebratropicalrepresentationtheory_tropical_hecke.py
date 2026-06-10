#!/usr/bin/env python3
"""
Algorithms for Tropical Hecke–Crystal Realization Duality

Implements:
1. Partition refinement for observational equivalence
2. Minimal crystal reconstruction
3. Hankel–Hecke matrix computation and tropical rank
4. Crystal isomorphism checking
"""

from __future__ import annotations
from collections import defaultdict
from itertools import product
from typing import Any, Callable


def partition_refinement(
    elements: list[int],
    colors: list[str],
    operators: dict[str, dict[int, int]],
    obs: dict[int, Any]
) -> list[set[int]]:
    """
    Partition refinement algorithm for computing observational equivalence.
    
    This is the efficient version of the quotient construction:
    instead of computing full observation profiles, iteratively
    refine the partition until stable.
    
    Time complexity: O(|M| * |ι| * log|M|) with proper data structures.
    
    Args:
        elements: list of elements (states)
        colors: list of operator colors
        operators: transition functions
        obs: observation function
        
    Returns:
        List of equivalence classes (sets of elements)
    """
    # Initial partition: group by observation value
    groups: dict[Any, set[int]] = defaultdict(set)
    for m in elements:
        groups[obs[m]].add(m)
    
    partition = list(groups.values())
    
    # Iterative refinement
    changed = True
    while changed:
        changed = False
        new_partition = []
        for block in partition:
            if len(block) <= 1:
                new_partition.append(block)
                continue
            
            # Try to split this block using each color
            sub_blocks: dict[tuple, set[int]] = defaultdict(set)
            for m in block:
                # Signature: which block does T_c(m) land in, for each color c
                sig = []
                for c in colors:
                    target = operators[c][m]
                    # Find which block contains the target
                    for idx, b in enumerate(partition):
                        if target in b:
                            sig.append(idx)
                            break
                sub_blocks[tuple(sig)].add(m)
            
            if len(sub_blocks) > 1:
                changed = True
                new_partition.extend(sub_blocks.values())
            else:
                new_partition.append(block)
        
        partition = new_partition
    
    return partition


def reconstruct_crystal_efficient(
    elements: list[int],
    colors: list[str],
    operators: dict[str, dict[int, int]],
    obs: dict[int, Any]
) -> tuple[dict, dict[int, int]]:
    """
    Efficient crystal reconstruction using partition refinement.
    
    Returns:
        (crystal_data, quotient_map) where crystal_data contains
        states, weights, and transitions of the minimal crystal.
    """
    partition = partition_refinement(elements, colors, operators, obs)
    
    # Map each element to its partition index
    element_to_class = {}
    for idx, block in enumerate(partition):
        for m in block:
            element_to_class[m] = idx
    
    # Build crystal
    num_states = len(partition)
    representatives = [min(block) for block in partition]
    
    weights = {i: obs[representatives[i]] for i in range(num_states)}
    
    transitions = {}
    for c in colors:
        trans = {}
        for i, rep in enumerate(representatives):
            target = operators[c][rep]
            trans[i] = element_to_class[target]
        transitions[c] = trans
    
    crystal_data = {
        "num_states": num_states,
        "weights": weights,
        "transitions": transitions,
        "partition": [sorted(block) for block in partition]
    }
    
    return crystal_data, element_to_class


def hankel_tropical_rank(
    elements: list[int],
    colors: list[str],
    operators: dict[str, dict[int, int]],
    obs: dict[int, Any],
    max_depth: int = None
) -> int:
    """
    Compute the tropical rank of the Hankel–Hecke matrix.
    
    The tropical rank is the number of distinct rows, which equals
    the number of observational equivalence classes.
    
    Args:
        elements, colors, operators, obs: system specification
        max_depth: maximum word length (default: |elements|)
        
    Returns:
        The tropical rank (= minimal crystal state count)
    """
    if max_depth is None:
        max_depth = len(elements)
    
    def word_action(word, m):
        s = m
        for c in word:
            s = operators[c][s]
        return s
    
    profiles = set()
    for m in elements:
        profile = []
        for depth in range(max_depth + 1):
            for word in product(colors, repeat=depth):
                profile.append(obs[word_action(list(word), m)])
        profiles.add(tuple(profile))
    
    return len(profiles)


def check_crystal_isomorphism(
    crystal1: dict,
    crystal2: dict,
    colors: list[str]
) -> tuple[bool, dict[int, int] | None]:
    """
    Check if two crystal automata are isomorphic.
    
    Uses a brute-force approach for small crystals.
    
    Returns:
        (is_iso, bijection) where bijection maps states of crystal1
        to states of crystal2, or None if not isomorphic.
    """
    n1 = crystal1["num_states"]
    n2 = crystal2["num_states"]
    
    if n1 != n2:
        return False, None
    
    from itertools import permutations
    
    states1 = list(range(n1))
    states2 = list(range(n2))
    
    for perm in permutations(states2):
        bijection = dict(zip(states1, perm))
        
        # Check weight compatibility
        wt_ok = all(
            crystal2["weights"][bijection[q]] == crystal1["weights"][q]
            for q in states1
        )
        if not wt_ok:
            continue
        
        # Check transition compatibility
        trans_ok = all(
            bijection[crystal1["transitions"][c][q]] ==
            crystal2["transitions"][c][bijection[q]]
            for c in colors
            for q in states1
        )
        if trans_ok:
            return True, bijection
    
    return False, None


# ============================================================
# Demonstration
# ============================================================

if __name__ == "__main__":
    print("Efficient Crystal Reconstruction via Partition Refinement")
    print("=" * 60)
    
    # Example: 8-element system
    elements = list(range(8))
    colors = ["r", "b"]
    operators = {
        "r": {0: 1, 1: 0, 2: 3, 3: 2, 4: 5, 5: 4, 6: 7, 7: 6},
        "b": {0: 4, 1: 5, 2: 6, 3: 7, 4: 0, 5: 1, 6: 2, 7: 3}
    }
    obs = {0: "X", 1: "Y", 2: "X", 3: "Y", 4: "X", 5: "Y", 6: "X", 7: "Y"}
    
    # Partition refinement
    partition = partition_refinement(elements, colors, operators, obs)
    print(f"\nPartition refinement result:")
    for i, block in enumerate(partition):
        print(f"  Class {i}: {sorted(block)} → obs={obs[min(block)]}")
    
    # Efficient reconstruction
    crystal, qmap = reconstruct_crystal_efficient(elements, colors, operators, obs)
    print(f"\nMinimal crystal: {crystal['num_states']} states")
    print(f"Weights: {crystal['weights']}")
    print(f"Transitions: {crystal['transitions']}")
    
    # Tropical rank
    rank = hankel_tropical_rank(elements, colors, operators, obs, max_depth=4)
    print(f"\nTropical Hankel rank: {rank}")
    print(f"Minimal states: {crystal['num_states']}")
    print(f"Rank = States: {rank == crystal['num_states']}")
    
    # Isomorphism check (crystal with itself, reordered)
    crystal2 = {
        "num_states": crystal["num_states"],
        "weights": crystal["weights"],
        "transitions": crystal["transitions"]
    }
    is_iso, bij = check_crystal_isomorphism(crystal, crystal2, colors)
    print(f"\nSelf-isomorphism check: {is_iso}")
    if bij:
        print(f"Bijection: {bij}")
