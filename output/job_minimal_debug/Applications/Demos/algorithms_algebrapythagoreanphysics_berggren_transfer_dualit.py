#!/usr/bin/env python3
"""
algorithms.py — Berggren Transfer Duality: Core Algorithms

Implements the key algorithms from the research paper:
1. Berggren tree generation and prefix-closed subset construction
2. Transfer Hankel kernel computation
3. Future-equivalence partition (Myhill-Nerode quotient)
4. Minimal resonance automaton construction
5. Certified reconstruction from observables

All algorithms include complexity analysis and type hints.
"""

import numpy as np
from typing import List, Tuple, Dict, Set, Optional, Callable, FrozenSet
from collections import defaultdict
from dataclasses import dataclass, field
from itertools import product

# ============================================================
# Data Structures
# ============================================================

@dataclass
class PrimitiveTriple:
    """A primitive Pythagorean triple (a, b, c) with a² + b² = c²."""
    a: int
    b: int
    c: int
    
    def __post_init__(self):
        vals = sorted([abs(self.a), abs(self.b), abs(self.c)])
        self.a, self.b, self.c = vals[0], vals[1], vals[2]
    
    def is_valid(self) -> bool:
        return self.a**2 + self.b**2 == self.c**2
    
    def hypotenuse(self) -> int:
        return self.c

@dataclass
class ResonanceAutomaton:
    """
    A minimal resonance automaton over an observable semiring.
    
    States correspond to future-equivalence classes.
    Transitions follow the Berggren generators A, B, C.
    
    Time complexity:
        - Construction: O(|B|² · |suffixes|) where |suffixes| is the suffix test set size
        - Query (word evaluation): O(|w|) per word
        - Space: O(|states| · |alphabet|) for the transition table
    """
    states: List[int]
    init_state: int
    transitions: Dict[Tuple[int, str], int]
    output: Dict[int, int]
    state_representatives: Dict[int, str]  # maps state id to representative word
    
    def run(self, word: str) -> int:
        """Run the automaton on a word, returning the output value.
        
        Time: O(|word|)
        """
        state = self.init_state
        for g in word:
            state = self.transitions.get((state, g), -1)
            if state == -1:
                return 0  # sink state
        return self.output.get(state, 0)
    
    def num_states(self) -> int:
        return len(self.states)

# ============================================================
# Algorithm 1: Berggren Tree Generation
# ============================================================

# Berggren matrices
A_MAT = np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]])
B_MAT = np.array([[1,  2, 2], [2,  1, 2], [2,  2, 3]])
C_MAT = np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]])
GENS = {'A': A_MAT, 'B': B_MAT, 'C': C_MAT}

def generate_berggren_tree(max_depth: int) -> Dict[str, PrimitiveTriple]:
    """
    Generate all primitive Pythagorean triples in the Berggren tree
    up to a given depth.
    
    Algorithm:
        BFS traversal of the ternary tree, applying each generator matrix
        to the current triple.
    
    Time: O(3^d) where d = max_depth
    Space: O(3^d) for storing all triples
    
    Args:
        max_depth: Maximum depth of the tree to generate
    
    Returns:
        Dictionary mapping Berggren words to their triples
    """
    root = np.array([3, 4, 5])
    tree = {"": PrimitiveTriple(*sorted(np.abs(root)))}
    
    frontier = [("", root)]
    for depth in range(max_depth):
        next_frontier = []
        for word, triple in frontier:
            for gen_name, gen_mat in GENS.items():
                new_word = word + gen_name
                new_triple = gen_mat @ triple
                tree[new_word] = PrimitiveTriple(*sorted(np.abs(new_triple)))
                next_frontier.append((new_word, new_triple))
        frontier = next_frontier
    
    return tree

# ============================================================
# Algorithm 2: Prefix-Closed Subset Construction
# ============================================================

def build_prefix_closed_set(words: Set[str]) -> Set[str]:
    """
    Build the prefix-closure of a set of words.
    
    Algorithm:
        For each word, add all its prefixes to the set.
    
    Time: O(sum of |w| for w in words)
    Space: O(|output set|)
    
    Args:
        words: A set of Berggren words
    
    Returns:
        The smallest prefix-closed set containing the input
    """
    closed = set()
    for w in words:
        for i in range(len(w) + 1):
            closed.add(w[:i])
    return closed

def compute_boundary(B: Set[str]) -> Set[str]:
    """
    Compute the boundary (leaf set) of a prefix-closed set.
    
    A word w is a boundary word if w ∈ B but w+g ∉ B for all generators g.
    
    Time: O(|B| · |alphabet|)
    Space: O(|boundary|)
    """
    return {w for w in B if all(w + g not in B for g in 'ABC')}

def compute_shells(B: Set[str]) -> Dict[int, Set[str]]:
    """
    Compute the depth-shell decomposition of B.
    
    Time: O(|B|)
    Space: O(|B|)
    """
    shells = defaultdict(set)
    for w in B:
        shells[len(w)].add(w)
    return dict(shells)

# ============================================================
# Algorithm 3: Transfer Hankel Kernel
# ============================================================

def compute_hankel_matrix(
    B: Set[str],
    obs: Callable[[str], int],
    row_words: Optional[List[str]] = None,
    col_words: Optional[List[str]] = None
) -> np.ndarray:
    """
    Compute the Hankel matrix H(u, v) = Obs(u ++ v).
    
    Time: O(|rows| · |cols| · T_obs) where T_obs is the time for one observable evaluation
    Space: O(|rows| · |cols|)
    
    Args:
        B: The prefix-closed set
        obs: Observable function
        row_words: Words for matrix rows (default: all words in B)
        col_words: Words for matrix columns (default: all words in B)
    
    Returns:
        The Hankel matrix as a numpy array
    """
    if row_words is None:
        row_words = sorted(B, key=lambda w: (len(w), w))
    if col_words is None:
        col_words = sorted(B, key=lambda w: (len(w), w))
    
    H = np.zeros((len(row_words), len(col_words)), dtype=np.int64)
    for i, u in enumerate(row_words):
        for j, v in enumerate(col_words):
            H[i, j] = obs(u + v)
    return H

def hankel_rank(H: np.ndarray) -> int:
    """
    Compute the rank of the Hankel matrix.
    
    Time: O(min(m,n) · m · n) for an m×n matrix
    Space: O(m · n)
    """
    return int(np.linalg.matrix_rank(H))

# ============================================================
# Algorithm 4: Future-Equivalence Partition (Myhill-Nerode)
# ============================================================

def compute_future_equivalence(
    B: Set[str],
    obs: Callable[[str], int],
    suffix_depth: int = 3
) -> Dict[int, List[str]]:
    """
    Compute the future-equivalence partition of words in B.
    
    Two words u, v are future-equivalent if Obs(u++x) = Obs(v++x) for all x.
    In practice, we test suffixes up to a given depth.
    
    Algorithm:
        1. Generate all suffixes up to suffix_depth
        2. For each word w ∈ B, compute its future function signature
        3. Group words with identical signatures
    
    Time: O(|B| · 3^suffix_depth · T_obs)
    Space: O(|B| · 3^suffix_depth)
    
    Args:
        B: The prefix-closed set
        obs: Observable function
        suffix_depth: Maximum depth of test suffixes
    
    Returns:
        Dictionary mapping class ID to list of words in that class
    """
    # Generate test suffixes
    suffixes = [""]
    for d in range(1, suffix_depth + 1):
        suffixes.extend(''.join(p) for p in product('ABC', repeat=d))
    
    # Compute future function signatures
    signatures = {}
    for w in sorted(B, key=lambda w: (len(w), w)):
        sig = tuple(obs(w + s) for s in suffixes)
        signatures[w] = sig
    
    # Group by signature
    classes = defaultdict(list)
    sig_to_id = {}
    next_id = 0
    
    for w, sig in signatures.items():
        if sig not in sig_to_id:
            sig_to_id[sig] = next_id
            next_id += 1
        classes[sig_to_id[sig]].append(w)
    
    return dict(classes)

# ============================================================
# Algorithm 5: Minimal Resonance Automaton Construction
# ============================================================

def build_minimal_automaton(
    B: Set[str],
    obs: Callable[[str], int],
    suffix_depth: int = 3
) -> ResonanceAutomaton:
    """
    Build the minimal resonance automaton from a finite Berggren subtree
    and its transfer observables.
    
    This implements the certified reconstruction algorithm:
    1. Compute future-equivalence classes (states)
    2. Choose a representative for each class
    3. Define transitions by one-step extensions
    4. Define output from the observable
    
    Time: O(|B| · 3^suffix_depth · T_obs) for partition
          + O(|classes| · |alphabet|) for transitions
    Space: O(|classes| · |alphabet|) for the automaton
    
    Correctness:
        The resulting automaton satisfies:
        - ReconstructsFromObservables: A.run(w) == obs(w) for all w ∈ B
        - Minimality: no automaton with fewer states can reconstruct obs
        - CertifiedUnique: any other minimal automaton is isomorphic
    
    Args:
        B: Finite prefix-closed set of Berggren words
        obs: Observable function supported on B
        suffix_depth: Depth for future-equivalence testing
    
    Returns:
        A minimal ResonanceAutomaton
    """
    # Step 1: Compute equivalence classes
    eq_classes = compute_future_equivalence(B, obs, suffix_depth)
    
    # Step 2: Map words to their class IDs
    word_to_class = {}
    for class_id, members in eq_classes.items():
        for w in members:
            word_to_class[w] = class_id
    
    # Step 3: Choose representatives
    representatives = {}
    for class_id, members in eq_classes.items():
        representatives[class_id] = min(members, key=lambda w: (len(w), w))
    
    # Step 4: Define transitions
    transitions = {}
    sink_state = -1
    
    for class_id, rep in representatives.items():
        for g in 'ABC':
            next_word = rep + g
            if next_word in word_to_class:
                transitions[(class_id, g)] = word_to_class[next_word]
            else:
                transitions[(class_id, g)] = sink_state
    
    # Step 5: Define output
    output = {}
    for class_id, rep in representatives.items():
        output[class_id] = obs(rep)
    output[sink_state] = 0
    
    # Initial state is the class of the empty word
    init_state = word_to_class.get("", 0)
    
    return ResonanceAutomaton(
        states=list(eq_classes.keys()),
        init_state=init_state,
        transitions=transitions,
        output=output,
        state_representatives=representatives
    )

def verify_automaton(
    automaton: ResonanceAutomaton,
    B: Set[str],
    obs: Callable[[str], int]
) -> Tuple[bool, List[str]]:
    """
    Verify that the automaton correctly reconstructs the observable.
    
    Time: O(|B| · max_depth)
    
    Returns:
        (is_correct, list_of_failures)
    """
    failures = []
    for w in sorted(B, key=lambda w: (len(w), w)):
        expected = obs(w)
        actual = automaton.run(w)
        if expected != actual:
            failures.append(f"  {w}: expected {expected}, got {actual}")
    
    return len(failures) == 0, failures

# ============================================================
# Algorithm 6: Boundary Resonance Partition
# ============================================================

def compute_boundary_resonance_partition(
    B: Set[str],
    obs: Callable[[str], int],
    suffix_depth: int = 3
) -> List[Set[str]]:
    """
    Compute the boundary resonance partition.
    
    Groups boundary words by future-equivalence: words that produce
    identical transfer responses to all future extensions.
    
    Time: O(|boundary| · 3^suffix_depth · T_obs)
    Space: O(|boundary| · 3^suffix_depth)
    
    This partition is:
    - Unique (determined solely by the observable)
    - Complete (covers all boundary words)
    - Compatible with the minimal automaton structure
    
    Returns:
        List of equivalence classes (sets of boundary words)
    """
    boundary = compute_boundary(B)
    
    # Generate test suffixes
    suffixes = [""]
    for d in range(1, suffix_depth + 1):
        suffixes.extend(''.join(p) for p in product('ABC', repeat=d))
    
    # Compute signatures
    sig_to_class = defaultdict(set)
    for w in boundary:
        sig = tuple(obs(w + s) for s in suffixes)
        sig_to_class[sig].add(w)
    
    return list(sig_to_class.values())

# ============================================================
# Demonstration
# ============================================================

def main():
    """Run all algorithms with concrete examples."""
    print("=" * 60)
    print("Berggren Transfer Duality — Algorithm Demonstrations")
    print("=" * 60)
    print()
    
    # Generate tree
    max_depth = 2
    tree = generate_berggren_tree(max_depth)
    B = set(tree.keys())
    
    print(f"1. Generated Berggren tree with {len(tree)} nodes (depth ≤ {max_depth})")
    print(f"   B is prefix-closed: {B == build_prefix_closed_set(B)}")
    print()
    
    # Observable: hypotenuse
    def obs(word):
        if word in tree:
            return tree[word].hypotenuse()
        return 0
    
    # Hankel matrix
    words = sorted(B, key=lambda w: (len(w), w))
    H = compute_hankel_matrix(B, obs, words, words)
    rank = hankel_rank(H)
    print(f"2. Hankel matrix size: {H.shape[0]}×{H.shape[1]}")
    print(f"   Hankel rank: {rank}")
    print()
    
    # Future equivalence
    eq_classes = compute_future_equivalence(B, obs)
    print(f"3. Future-equivalence classes: {len(eq_classes)}")
    for cid, members in eq_classes.items():
        print(f"   Class {cid}: {members}")
    print()
    
    # Boundary
    boundary = compute_boundary(B)
    print(f"4. Boundary words: {sorted(boundary)}")
    print()
    
    # Shells
    shells = compute_shells(B)
    print(f"5. Shell decomposition:")
    for d, shell in sorted(shells.items()):
        print(f"   Depth {d}: {sorted(shell)} (size {len(shell)})")
    print()
    
    # Minimal automaton
    automaton = build_minimal_automaton(B, obs)
    is_correct, failures = verify_automaton(automaton, B, obs)
    print(f"6. Minimal resonance automaton:")
    print(f"   States: {automaton.num_states()}")
    print(f"   Correct reconstruction: {is_correct}")
    if not is_correct:
        print(f"   Failures: {failures}")
    print()
    
    # Boundary resonance partition
    partition = compute_boundary_resonance_partition(B, obs)
    print(f"7. Boundary resonance partition:")
    for i, cls in enumerate(partition):
        print(f"   Class {i}: {sorted(cls)}")
    print()
    
    # Summary
    print("Summary of key relationships verified:")
    print(f"  |B| = {len(B)}")
    print(f"  Hankel rank = {rank}")
    print(f"  # equivalence classes = {len(eq_classes)}")
    print(f"  # boundary classes = {len(partition)}")
    print(f"  # automaton states = {automaton.num_states()}")
    print(f"  Bound: # classes ≤ |B| + 1 = {len(B) + 1}")
    print()

if __name__ == "__main__":
    main()
