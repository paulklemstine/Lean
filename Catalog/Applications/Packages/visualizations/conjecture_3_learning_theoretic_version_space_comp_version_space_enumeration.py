#!/usr/bin/env python3
"""
Version Space Entropy — Algorithms

Implements the core computational methods from the version-space entropy theory:
  - Exact version-space enumeration for finite concept classes
  - Semantic entropy computation across sample streams
  - Fiber partition analysis
  - Pattern complexity computation
  - Optimal query selection (greedy entropy minimization)
"""

import math
import itertools
from typing import List, Tuple, Set, Dict, Optional, FrozenSet
from dataclasses import dataclass


# ───────────────────────────────────────────────────────────────────
# Core Data Structures
# ───────────────────────────────────────────────────────────────────

@dataclass
class LearningState:
    """Snapshot of the learning process at a given point."""
    version_space: FrozenSet[tuple]
    dataset: List[Tuple[int, int]]
    entropy: float
    step: int

    @property
    def card(self) -> int:
        return len(self.version_space)


# ───────────────────────────────────────────────────────────────────
# Algorithm 1: Version Space Enumeration
# ───────────────────────────────────────────────────────────────────

def enumerate_version_space(
    H: Set[tuple],
    D: List[Tuple[int, int]]
) -> Set[tuple]:
    """
    Exact enumeration of the version space.

    Computes versionSpace(H, D) = {h ∈ H | ∀ (x,y) ∈ D, h(x) = y}.

    Time complexity: O(|H| · |D|)
    Space complexity: O(|H|)

    Args:
        H: Hypothesis class as set of tuples (each tuple is a function X → Y)
        D: Dataset as list of (instance, label) pairs

    Returns:
        Set of hypotheses consistent with D
    """
    return {h for h in H if all(h[x] == y for x, y in D)}


def enumerate_version_space_incremental(
    V: Set[tuple],
    example: Tuple[int, int]
) -> Set[tuple]:
    """
    Incremental version space update: filter by one new example.

    Time complexity: O(|V|)

    Args:
        V: Current version space
        example: New labeled example (x, y)

    Returns:
        Updated version space
    """
    x, y = example
    return {h for h in V if h[x] == y}


# ───────────────────────────────────────────────────────────────────
# Algorithm 2: Semantic Entropy Computation
# ───────────────────────────────────────────────────────────────────

def compute_entropy(V: Set[tuple]) -> float:
    """
    Compute version-space entropy: log₂(|V|).

    This is the semantic entropy under the uniform posterior — the number
    of bits needed to specify the target hypothesis among survivors.

    Time complexity: O(1)
    """
    if len(V) == 0:
        return 0.0
    return math.log2(len(V))


def entropy_stream(
    H: Set[tuple],
    examples: List[Tuple[int, int]]
) -> List[LearningState]:
    """
    Compute the full entropy trajectory over a stream of examples.

    Returns a list of LearningState snapshots, one per step (including
    the initial state before any examples).

    Time complexity: O(|H| · |examples|)

    Args:
        H: Initial hypothesis class
        examples: Ordered stream of (instance, label) pairs

    Returns:
        List of LearningState snapshots
    """
    V = H.copy()
    states = [LearningState(
        version_space=frozenset(V),
        dataset=[],
        entropy=compute_entropy(V),
        step=0
    )]

    D = []
    for i, (x, y) in enumerate(examples):
        V = enumerate_version_space_incremental(V, (x, y))
        D = D + [(x, y)]
        states.append(LearningState(
            version_space=frozenset(V),
            dataset=D.copy(),
            entropy=compute_entropy(V),
            step=i + 1
        ))

    return states


# ───────────────────────────────────────────────────────────────────
# Algorithm 3: Fiber Partition Analysis
# ───────────────────────────────────────────────────────────────────

@dataclass
class FiberAnalysis:
    """Result of fiber partition analysis at an instance point."""
    instance: int
    fibers: Dict[int, Set[tuple]]
    fiber_sizes: Dict[int, int]
    entropy_drops: Dict[int, float]
    best_label: int
    best_drop: float
    worst_label: int
    worst_drop: float
    log2_Y: float


def analyze_fibers(
    V: Set[tuple],
    x: int,
    label_size: int
) -> FiberAnalysis:
    """
    Compute the fiber partition of V at instance x and analyze entropy drops.

    Partitions V into {h ∈ V | h(x) = y} for each y ∈ Y, computes entropy
    drops for each fiber, and identifies the best/worst labels.

    Time complexity: O(|V| · |Y|)

    Args:
        V: Version space
        x: Instance to query
        label_size: Number of possible labels |Y|

    Returns:
        FiberAnalysis with complete partition data
    """
    base_entropy = compute_entropy(V)
    fibers = {}
    fiber_sizes = {}
    entropy_drops = {}

    for y in range(label_size):
        fiber = {h for h in V if h[x] == y}
        fibers[y] = fiber
        fiber_sizes[y] = len(fiber)
        if len(fiber) > 0:
            entropy_drops[y] = base_entropy - compute_entropy(fiber)
        else:
            entropy_drops[y] = float('inf')

    nonempty_drops = {y: d for y, d in entropy_drops.items() if d < float('inf')}

    best_label = min(nonempty_drops, key=nonempty_drops.get) if nonempty_drops else 0
    worst_label = max(nonempty_drops, key=nonempty_drops.get) if nonempty_drops else 0

    return FiberAnalysis(
        instance=x,
        fibers=fibers,
        fiber_sizes=fiber_sizes,
        entropy_drops=entropy_drops,
        best_label=best_label,
        best_drop=nonempty_drops.get(best_label, 0),
        worst_label=worst_label,
        worst_drop=nonempty_drops.get(worst_label, 0),
        log2_Y=math.log2(label_size) if label_size > 1 else 0
    )


# ───────────────────────────────────────────────────────────────────
# Algorithm 4: Pattern Complexity Computation
# ───────────────────────────────────────────────────────────────────

def compute_pattern_complexity(
    H: Set[tuple],
    query_instances: List[int]
) -> Tuple[int, int, Set[tuple]]:
    """
    Compute the number of distinct label patterns on a query sequence.

    Each hypothesis h ∈ H produces a pattern (h(x₁), ..., h(xₖ)).
    The number of distinct patterns is the Natarajan dimension analog
    for the query sequence.

    Time complexity: O(|H| · k) where k = |query_instances|

    Args:
        H: Hypothesis class
        query_instances: Sequence of instances to query

    Returns:
        (num_patterns, bound, patterns) where bound = |Y|^k
    """
    patterns = set()
    for h in H:
        pattern = tuple(h[x] for x in query_instances)
        patterns.add(pattern)

    # Determine label size from hypothesis outputs
    if H:
        label_size = max(max(h) for h in H) + 1
    else:
        label_size = 2

    bound = label_size ** len(query_instances)
    return len(patterns), bound, patterns


# ───────────────────────────────────────────────────────────────────
# Algorithm 5: Greedy Optimal Query Selection
# ───────────────────────────────────────────────────────────────────

def greedy_query(
    V: Set[tuple],
    domain_size: int,
    label_size: int
) -> Tuple[int, FiberAnalysis]:
    """
    Select the query instance that minimizes worst-case entropy after observation.

    This is the greedy active learning strategy: choose x to maximize the
    minimum fiber size (equivalently, minimize worst-case entropy drop).

    Time complexity: O(|X| · |V| · |Y|)

    Args:
        V: Current version space
        domain_size: Size of instance space |X|
        label_size: Size of label space |Y|

    Returns:
        (best_instance, fiber_analysis)
    """
    best_x = 0
    best_min_drop = float('inf')
    best_analysis = None

    for x in range(domain_size):
        analysis = analyze_fibers(V, x, label_size)
        # The "best" query minimizes the maximum possible entropy drop
        # (equivalently, maximizes the minimum surviving fiber)
        if analysis.worst_drop < best_min_drop:
            best_min_drop = analysis.worst_drop
            best_x = x
            best_analysis = analysis

    return best_x, best_analysis


def semantic_compression_rate(
    H: Set[tuple],
    D: List[Tuple[int, int]],
    E: List[Tuple[int, int]]
) -> float:
    """
    Compute the semantic compression rate for dataset extension.

    rate = (H(V_D) - H(V_{D++E})) / |E|

    This measures how many bits of entropy each additional sample removes
    on average.

    Args:
        H: Hypothesis class
        D: Initial dataset
        E: Extension dataset

    Returns:
        Compression rate in bits per sample
    """
    V_D = enumerate_version_space(H, D)
    V_DE = enumerate_version_space(H, D + E)

    if len(E) == 0:
        return 0.0

    return (compute_entropy(V_D) - compute_entropy(V_DE)) / len(E)


# ───────────────────────────────────────────────────────────────────
# Concept Class Library
# ───────────────────────────────────────────────────────────────────

def all_functions(domain_size: int, label_size: int) -> Set[tuple]:
    """All functions {0,...,d-1} → {0,...,l-1}."""
    return set(itertools.product(range(label_size), repeat=domain_size))


def threshold_functions(n: int) -> Set[tuple]:
    """Threshold functions h_t(x) = 1[x ≥ t] for t ∈ {0,...,n}."""
    return {tuple(1 if x >= t else 0 for x in range(n)) for t in range(n + 1)}


def monotone_functions(n: int) -> Set[tuple]:
    """Monotone Boolean functions on {0,...,n-1}."""
    domain = 2 ** n
    funcs = set()
    for bits in itertools.product([0, 1], repeat=domain):
        h = bits
        is_monotone = True
        for x in range(domain):
            for y in range(domain):
                if (x & y) == x and h[x] > h[y]:
                    is_monotone = False
                    break
            if not is_monotone:
                break
        if is_monotone:
            funcs.add(h)
    return funcs


# ───────────────────────────────────────────────────────────────────
# Example Usage
# ───────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Algorithms — Example Usage")
    print("=" * 50)

    # Example: entropy stream for threshold functions
    n = 8
    H = threshold_functions(n)
    target = tuple(1 if x >= 4 else 0 for x in range(n))

    # Generate all examples from target
    examples = [(x, target[x]) for x in range(n)]

    print(f"\nThreshold functions on {{0,...,{n-1}}}")
    print(f"|H| = {len(H)}, target threshold = 4")
    print()

    states = entropy_stream(H, examples)
    for s in states:
        print(f"  Step {s.step}: |V| = {s.card:>4}, entropy = {s.entropy:.4f}")

    print()

    # Pattern complexity
    for k in range(1, 6):
        xs = list(range(k))
        num_patterns, bound, _ = compute_pattern_complexity(H, xs)
        print(f"  k={k}: patterns = {num_patterns}, bound = {bound}")

    print()

    # Fiber analysis
    V = H.copy()
    analysis = analyze_fibers(V, 4, 2)
    print(f"  Fiber analysis at x=4:")
    for y, size in analysis.fiber_sizes.items():
        print(f"    y={y}: |fiber| = {size}, drop = {analysis.entropy_drops[y]:.4f}")
    print(f"    Best: y={analysis.best_label} (drop {analysis.best_drop:.4f} ≤ log₂|Y| = {analysis.log2_Y:.4f})")
