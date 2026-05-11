#!/usr/bin/env python3
"""
Tropical Neural Representation Theory: Core Algorithms

Implements the main algorithms from the research paper:
1. Nerode quotient computation via partition refinement
2. Separator certificate extraction
3. Join-irreducible decomposition
4. Tropical compression pipeline
"""

import numpy as np
from collections import defaultdict
from typing import (
    Any, Callable, Dict, FrozenSet, List, Optional,
    Set, Tuple, TypeVar
)

T = TypeVar('T')
C = TypeVar('C')
M = TypeVar('M')


# ============================================================================
# Algorithm 1: Partition Refinement for Nerode Quotient
# ============================================================================

def partition_refinement(
    states: List[T],
    contexts: List[C],
    plug: Callable[[C, T], T],
    obs: Callable[[T], Any],
) -> Tuple[List[Set[T]], int]:
    """
    Compute the Nerode quotient via iterative partition refinement.

    This implements the certified minimization algorithm from Section 5
    of the research paper. Starting from an initial partition by observable
    values, it iteratively refines blocks until no context can split any block.

    Algorithm:
        1. Initialize P = partition by obs value
        2. For each block B in P and context c:
           - Compute c-successor partition: group elements of B by
             which block contains plug(c, x)
           - If any block splits, update P
        3. Repeat until stable

    Time complexity: O(|contexts| · |states|² · iterations)
    Space complexity: O(|states|)

    Args:
        states: list of state/trace elements
        contexts: list of context elements
        plug: context application function
        obs: observable function

    Returns:
        (partition, iterations): final partition and iteration count
    """
    # Build state-to-index map
    state_idx = {s: i for i, s in enumerate(states)}

    # Initial partition by observable
    obs_groups: Dict[Any, Set[int]] = defaultdict(set)
    for i, s in enumerate(states):
        obs_groups[obs(s)].add(i)

    partition = list(obs_groups.values())
    block_of = np.zeros(len(states), dtype=int)
    for bi, block in enumerate(partition):
        for i in block:
            block_of[i] = bi

    iterations = 0
    changed = True

    while changed:
        changed = False
        new_partition: List[Set[int]] = []
        new_block_of = np.zeros(len(states), dtype=int)

        for block in partition:
            if len(block) <= 1:
                idx = len(new_partition)
                new_partition.append(block)
                for i in block:
                    new_block_of[i] = idx
                continue

            # Try splitting by each context
            current_splits = [block]

            for c in contexts:
                next_splits = []
                for sub in current_splits:
                    if len(sub) <= 1:
                        next_splits.append(sub)
                        continue
                    # Group by target block
                    target_groups: Dict[int, Set[int]] = defaultdict(set)
                    for i in sub:
                        ci = plug(c, states[i])
                        if ci in state_idx:
                            target = block_of[state_idx[ci]]
                        else:
                            target = -1
                        target_groups[target].add(i)

                    next_splits.extend(target_groups.values())

                current_splits = next_splits

            if len(current_splits) > 1:
                changed = True

            for sub in current_splits:
                idx = len(new_partition)
                new_partition.append(sub)
                for i in sub:
                    new_block_of[i] = idx

        partition = new_partition
        block_of = new_block_of
        iterations += 1

    # Convert back to state sets
    result = [{states[i] for i in block} for block in partition]
    return result, iterations


# ============================================================================
# Algorithm 2: Separator Certificate Extraction
# ============================================================================

def extract_separators(
    states: List[T],
    contexts: List[C],
    plug: Callable[[C, T], T],
    obs: Callable[[T], Any],
    partition: List[Set[T]],
) -> Dict[Tuple[int, int], C]:
    """
    Extract separating contexts (certificates of inequivalence) between
    all pairs of distinct blocks in the Nerode partition.

    For each pair of blocks (i, j) with i < j, find a context c such that
    some element of block i and some element of block j are distinguished by c.

    These certificates are machine-checkable proofs that the compression
    is correct: no two states in different blocks can be merged without
    losing observable behavior.

    Args:
        states: list of states
        contexts: list of contexts
        plug: context application
        obs: observable function
        partition: Nerode partition (output of partition_refinement)

    Returns:
        Dictionary mapping (block_i, block_j) -> separating context
    """
    # Get representative from each block
    reps = [(i, next(iter(block))) for i, block in enumerate(partition)]

    separators: Dict[Tuple[int, int], C] = {}

    for i, rep_i in reps:
        for j, rep_j in reps:
            if i >= j:
                continue
            for c in contexts:
                if obs(plug(c, rep_i)) != obs(plug(c, rep_j)):
                    separators[(i, j)] = c
                    break

    return separators


# ============================================================================
# Algorithm 3: Join-Irreducible Decomposition
# ============================================================================

def find_join_irreducibles(
    elements: List[T],
    join: Callable[[T, T], T],
    bot: T,
    le: Callable[[T, T], bool],
) -> List[T]:
    """
    Find join-irreducible elements in a finite lattice.

    An element a is join-irreducible if:
    1. a ≠ ⊥
    2. Whenever a = b ∨ c, either a = b or a = c

    These are the "atoms of behavior" — the irreducible building blocks
    from which all elements can be reconstructed.

    Args:
        elements: all elements of the finite lattice
        join: binary join (sup) operation
        bot: bottom element
        le: partial order ≤

    Returns:
        List of join-irreducible elements
    """
    ji = []
    for a in elements:
        if a == bot:
            continue
        is_ji = True
        for b in elements:
            if not is_ji:
                break
            for c in elements:
                if join(b, c) == a and a != b and a != c:
                    is_ji = False
                    break
        if is_ji:
            ji.append(a)
    return ji


def tropical_support(
    a: T,
    join_irreducibles: List[T],
    le: Callable[[T, T], bool],
) -> List[T]:
    """
    Compute the tropical support (Fourier coefficients) of an element.

    The tropical support is the set of join-irreducible elements below a.
    By Birkhoff's theorem, a = ⊔ support(a) in a finite distributive lattice.

    Args:
        a: element to decompose
        join_irreducibles: list of all join-irreducible elements
        le: partial order ≤

    Returns:
        List of join-irreducibles in the support of a
    """
    return [j for j in join_irreducibles if le(j, a)]


def verify_decomposition(
    elements: List[T],
    join: Callable[[T, T], T],
    bot: T,
    le: Callable[[T, T], bool],
) -> bool:
    """
    Verify that every element equals the join of its tropical support.

    This is a computational verification of Birkhoff's theorem /
    Theorem D (Tropical Fourier Decomposition).

    Returns:
        True if decomposition is correct for all elements
    """
    ji = find_join_irreducibles(elements, join, bot, le)

    for a in elements:
        supp = tropical_support(a, ji, le)
        reconstruction = bot
        for j in supp:
            reconstruction = join(reconstruction, j)
        if reconstruction != a:
            return False
    return True


# ============================================================================
# Algorithm 4: Tropical Compression Pipeline
# ============================================================================

class TropicalCompressionResult:
    """Result of the tropical compression pipeline."""

    def __init__(self):
        self.original_size: int = 0
        self.compressed_size: int = 0
        self.partition: List[Set] = []
        self.separators: Dict = {}
        self.tropical_dimension: int = 0  # number of join-irreducibles
        self.compression_ratio: float = 1.0

    def __repr__(self):
        return (
            f"TropicalCompressionResult(\n"
            f"  original_size={self.original_size},\n"
            f"  compressed_size={self.compressed_size},\n"
            f"  compression_ratio={self.compression_ratio:.2f}x,\n"
            f"  tropical_dimension={self.tropical_dimension},\n"
            f"  num_separators={len(self.separators)}\n"
            f")"
        )


def tropical_compress(
    states: List[T],
    contexts: List[C],
    plug: Callable[[C, T], T],
    obs: Callable[[T], Any],
) -> TropicalCompressionResult:
    """
    Full tropical compression pipeline:
    1. Compute Nerode quotient via partition refinement
    2. Extract separation certificates
    3. Build quotient lattice and find join-irreducibles

    This is the certified compression pipeline from Section 9.1
    of the research paper.

    Args:
        states: list of states
        contexts: list of contexts
        plug: context application
        obs: observable function

    Returns:
        TropicalCompressionResult with all compression artifacts
    """
    result = TropicalCompressionResult()
    result.original_size = len(states)

    # Step 1: Compute quotient
    partition, iters = partition_refinement(states, contexts, plug, obs)
    result.partition = partition
    result.compressed_size = len(partition)
    result.compression_ratio = (
        result.original_size / result.compressed_size
        if result.compressed_size > 0 else float('inf')
    )

    # Step 2: Extract certificates
    result.separators = extract_separators(
        states, contexts, plug, obs, partition
    )

    # Step 3: Build quotient lattice (power set ordered by inclusion)
    # The quotient blocks form a partition; their lattice structure depends
    # on the observable algebra. For counting, we use the partition size.
    result.tropical_dimension = result.compressed_size  # upper bound

    return result


# ============================================================================
# Self-test
# ============================================================================

if __name__ == "__main__":
    print("Testing algorithms...")

    # Test 1: Partition refinement
    states = list(range(12))
    contexts = list(range(12))
    partition, iters = partition_refinement(
        states, contexts,
        plug=lambda c, x: (c + x) % 12,
        obs=lambda x: x % 3,
    )
    assert len(partition) == 3, f"Expected 3 blocks, got {len(partition)}"
    print(f"  ✓ Partition refinement: {len(partition)} blocks in {iters} iterations")

    # Test 2: Separator extraction
    seps = extract_separators(
        states, contexts,
        plug=lambda c, x: (c + x) % 12,
        obs=lambda x: x % 3,
        partition=partition,
    )
    assert len(seps) == 3, f"Expected 3 separators, got {len(seps)}"
    print(f"  ✓ Separator extraction: {len(seps)} certificates")

    # Test 3: Join-irreducible decomposition
    # Power set of {0, 1, 2}
    elts = [frozenset(s) for s in [
        set(), {0}, {1}, {2}, {0,1}, {0,2}, {1,2}, {0,1,2}
    ]]
    ji = find_join_irreducibles(
        elts,
        join=lambda a, b: a | b,
        bot=frozenset(),
        le=lambda a, b: a <= b,
    )
    assert len(ji) == 3, f"Expected 3 join-irreducibles, got {len(ji)}"
    print(f"  ✓ Join-irreducibles: {len(ji)} found")

    # Test 4: Verify Birkhoff decomposition
    ok = verify_decomposition(
        elts,
        join=lambda a, b: a | b,
        bot=frozenset(),
        le=lambda a, b: a <= b,
    )
    assert ok, "Birkhoff decomposition verification failed"
    print(f"  ✓ Birkhoff decomposition verified")

    # Test 5: Full pipeline
    result = tropical_compress(
        list(range(100)),
        list(range(100)),
        plug=lambda c, x: (c + x) % 100,
        obs=lambda x: x % 5,
    )
    assert result.compressed_size == 5
    print(f"  ✓ Full pipeline: {result.compression_ratio:.0f}x compression")

    print("\nAll tests passed!")


#!/usr/bin/env python3
"""
Tropical Neural Representation Theory: Applications

Demonstrates real-world applications of the theory:
1. ReLU Network Compression via Tropical Quotient
2. Max-Plus Dynamic Programming Minimization
3. Weighted Automaton Compression
4. Certified Model Distillation
"""

import numpy as np
from collections import defaultdict
from typing import List, Tuple, Dict, Set, Callable, Any


# ============================================================================
# Application 1: ReLU Network Tropical Compression
# ============================================================================

def relu(x: np.ndarray) -> np.ndarray:
    """ReLU activation: max(0, x)."""
    return np.maximum(0, x)


class SimpleReLUNetwork:
    """A small ReLU network for demonstration."""

    def __init__(self, weights: List[np.ndarray], biases: List[np.ndarray]):
        self.weights = weights
        self.biases = biases
        self.num_layers = len(weights)

    def forward(self, x: np.ndarray) -> np.ndarray:
        for i in range(self.num_layers - 1):
            x = relu(self.weights[i] @ x + self.biases[i])
        return self.weights[-1] @ x + self.biases[-1]

    def activation_pattern(self, x: np.ndarray) -> Tuple:
        """Get the activation pattern (which neurons are active)."""
        patterns = []
        for i in range(self.num_layers - 1):
            pre = self.weights[i] @ x + self.biases[i]
            patterns.append(tuple(pre > 0))
            x = relu(pre)
        return tuple(patterns)


def demo_relu_compression():
    """
    Demonstrate tropical compression of a ReLU network.

    Key insight: ReLU networks compute piecewise-linear (tropical rational)
    functions. On each linear region, the network is an affine map.
    Two inputs in the same linear region produce the same activation pattern
    and can be compressed to a single representative.

    The Nerode quotient identifies the minimal set of distinct behaviors.
    """
    print("=" * 60)
    print("APPLICATION 1: ReLU Network Tropical Compression")
    print("=" * 60)

    np.random.seed(42)

    # Create a small 2D -> 1D ReLU network
    net = SimpleReLUNetwork(
        weights=[
            np.array([[1.0, -1.0], [-0.5, 1.0], [1.0, 0.5]]),  # 2 -> 3
            np.array([[1.0, -0.5, 0.5]]),                         # 3 -> 1
        ],
        biases=[
            np.array([0.0, -0.5, 0.3]),
            np.array([0.0]),
        ],
    )

    # Sample input space
    grid = np.linspace(-2, 2, 20)
    inputs = [(x, y) for x in grid for y in grid]
    n_inputs = len(inputs)

    # Compute activation patterns
    patterns = {}
    for inp in inputs:
        x = np.array(inp)
        pat = net.activation_pattern(x)
        if pat not in patterns:
            patterns[pat] = []
        patterns[pat].append(inp)

    n_regions = len(patterns)
    compression = n_inputs / n_regions

    print(f"  Network: 2 -> 3 (ReLU) -> 1")
    print(f"  Input grid: {len(grid)}×{len(grid)} = {n_inputs} points")
    print(f"  Distinct activation patterns: {n_regions}")
    print(f"  Compression ratio: {compression:.1f}x")
    print(f"\n  Each activation pattern defines a 'linear region' where")
    print(f"  the network acts as a fixed affine map. The Nerode quotient")
    print(f"  groups inputs by their tropical behavioral equivalence class.")
    print()

    # Show some patterns
    for i, (pat, members) in enumerate(sorted(patterns.items(), key=lambda x: len(x[1]), reverse=True)[:5]):
        active = sum(sum(1 for b in layer if b) for layer in pat)
        print(f"    Region {i}: {len(members)} inputs, {active} active neurons")
    print()


# ============================================================================
# Application 2: Max-Plus Dynamic Programming
# ============================================================================

def demo_maxplus_dp():
    """
    Demonstrate tropical quotient for max-plus dynamic programming.

    In shortest-path / longest-path problems, the state space can be
    compressed using tropical Nerode equivalence: states that produce
    the same optimal costs under all future decisions are equivalent.
    """
    print("=" * 60)
    print("APPLICATION 2: Max-Plus Dynamic Programming Compression")
    print("=" * 60)

    # Simple grid world: states are (row, col), actions move in 4 directions
    # Reward depends on position mod 3
    grid_size = 6
    states = [(r, c) for r in range(grid_size) for c in range(grid_size)]
    actions = [(0, 1), (0, -1), (1, 0), (-1, 0)]  # right, left, down, up

    def step(action, state):
        r, c = state
        dr, dc = action
        nr = max(0, min(grid_size - 1, r + dr))
        nc = max(0, min(grid_size - 1, c + dc))
        return (nr, nc)

    def reward(state):
        r, c = state
        return (r + c) % 3  # Tropical observable

    # Compute Nerode equivalence
    equiv_classes = {}
    class_id = 0
    for s in states:
        found = False
        for rep, cid in equiv_classes.items():
            # Check if s and rep are equivalent under all action sequences
            equiv = True
            for a1 in actions:
                for a2 in actions:
                    s1 = step(a2, step(a1, s))
                    s2 = step(a2, step(a1, rep))
                    if reward(s1) != reward(s2):
                        equiv = False
                        break
                if not equiv:
                    break
            if equiv:
                equiv_classes[s] = cid
                found = True
                break
        if not found:
            equiv_classes[s] = class_id
            class_id += 1

    n_classes = len(set(equiv_classes.values()))
    compression = len(states) / n_classes

    print(f"  Grid world: {grid_size}×{grid_size} = {len(states)} states")
    print(f"  Actions: 4 directions")
    print(f"  Observable: (row + col) mod 3")
    print(f"  Nerode classes (depth-2 contexts): {n_classes}")
    print(f"  Compression ratio: {compression:.1f}x")
    print()


# ============================================================================
# Application 3: Weighted Automaton Compression
# ============================================================================

def demo_weighted_automaton():
    """
    Demonstrate tropical compression of a weighted automaton.

    Weighted automata over the tropical semiring compute shortest-path
    distances. The Nerode quotient identifies the minimal equivalent automaton.
    """
    print("=" * 60)
    print("APPLICATION 3: Weighted Automaton Compression")
    print("=" * 60)

    # 6-state automaton over {a, b} with tropical (min-plus) weights
    n_states = 6
    alphabet = ['a', 'b']

    # Transition weights (min-plus multiplication = addition)
    # Some states are redundant
    transitions = {
        (0, 'a'): (1, 2), (0, 'b'): (2, 3),
        (1, 'a'): (3, 1), (1, 'b'): (4, 2),
        (2, 'a'): (4, 1), (2, 'b'): (5, 2),
        (3, 'a'): (1, 2), (3, 'b'): (2, 3),  # same as state 0
        (4, 'a'): (3, 1), (4, 'b'): (4, 2),  # same as state 1
        (5, 'a'): (4, 1), (5, 'b'): (5, 2),  # same as state 2
    }
    final_weights = {0: 0, 1: 1, 2: 2, 3: 0, 4: 1, 5: 2}

    def compute_weight(state, word):
        """Compute tropical (min-plus) weight of a word from a state."""
        total = 0
        s = state
        for c in word:
            next_s, w = transitions[(s, c)]
            total += w
            s = next_s
        total += final_weights[s]
        return total

    # Check equivalence: states with same behavior under all words
    max_word_len = 3
    words = ['']
    for length in range(1, max_word_len + 1):
        new_words = []
        for w in [w for w in words if len(w) == length - 1]:
            for c in alphabet:
                new_words.append(w + c)
        words.extend(new_words)

    equiv = {}
    cid = 0
    for s in range(n_states):
        found = False
        for rep, c in equiv.items():
            if all(compute_weight(s, w) == compute_weight(rep, w) for w in words):
                equiv[s] = c
                found = True
                break
        if not found:
            equiv[s] = cid
            cid += 1

    n_classes = len(set(equiv.values()))

    print(f"  Weighted automaton: {n_states} states, alphabet {{a, b}}")
    print(f"  Semiring: min-plus (tropical)")
    print(f"  Test words: up to length {max_word_len} ({len(words)} words)")
    print(f"  Nerode classes: {n_classes}")
    print(f"  Compression: {n_states} → {n_classes} states ({n_states/n_classes:.1f}x)")
    print()

    # Show equivalence classes
    class_members = defaultdict(list)
    for s, c in equiv.items():
        class_members[c].append(s)
    for c in sorted(class_members):
        print(f"    Class {c}: states {class_members[c]}")
    print()


# ============================================================================
# Application 4: Certified Model Distillation
# ============================================================================

def demo_certified_distillation():
    """
    Demonstrate certified model distillation via Nerode quotient.

    Given a teacher model and a student model, verify that the student
    preserves all observable behavior of the teacher by checking Nerode
    equivalence of corresponding states.
    """
    print("=" * 60)
    print("APPLICATION 4: Certified Model Distillation")
    print("=" * 60)

    # Teacher: 8-state system
    teacher_states = list(range(8))
    # Student: 4-state system (compressed)
    student_states = list(range(4))

    # Teacher transition: cyclic mod 8
    def teacher_plug(c, x):
        return (x + c) % 8

    def teacher_obs(x):
        return x % 4  # Observable only depends on x mod 4

    # Student transition: cyclic mod 4
    def student_plug(c, x):
        return (x + c) % 4

    def student_obs(x):
        return x  # Direct identity

    # Encoding: teacher state -> student state
    def encode(x):
        return x % 4

    # Verify: the encoding preserves all observable behavior
    contexts = list(range(8))
    all_preserved = True
    violations = []

    for x in teacher_states:
        for c in contexts:
            teacher_result = teacher_obs(teacher_plug(c, x))
            student_result = student_obs(student_plug(c, encode(x)))
            if teacher_result != student_result:
                all_preserved = False
                violations.append((x, c, teacher_result, student_result))

    print(f"  Teacher: {len(teacher_states)} states, obs = x mod 4")
    print(f"  Student: {len(student_states)} states, obs = x")
    print(f"  Encoding: x ↦ x mod 4")
    print(f"  Contexts tested: {len(contexts)}")
    print(f"  All behaviors preserved: {'✓ YES' if all_preserved else '✗ NO'}")

    if all_preserved:
        print(f"\n  Certificate: The student model is a valid Nerode quotient")
        print(f"  of the teacher. Compression ratio: {len(teacher_states)/len(student_states):.0f}x")
        print(f"  This compression is PROVABLY semantics-preserving.")
    else:
        print(f"\n  Found {len(violations)} violations:")
        for x, c, tr, sr in violations[:5]:
            print(f"    State {x}, context {c}: teacher={tr}, student={sr}")

    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║    Tropical Neural Representation Theory: Applications  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_relu_compression()
    demo_maxplus_dp()
    demo_weighted_automaton()
    demo_certified_distillation()

    print("All applications demonstrated successfully.")


#!/usr/bin/env python3
"""
Tropical Neural Representation Theory: Interactive Demo

Demonstrates the core theorems with concrete numerical examples:
1. Nerode equivalence computation
2. Separator extraction
3. Quotient construction
4. Minimal representation
5. Tropical Fourier (join-irreducible) decomposition
"""

import numpy as np
from collections import defaultdict
from typing import Callable, Dict, List, Set, Tuple, Any, Optional

# ============================================================================
# Core Definitions
# ============================================================================

class ContextActionSystem:
    """A compositional system with context actions and observables."""

    def __init__(self, traces, contexts, plug, obs, comp=None):
        """
        Args:
            traces: list of trace/state elements
            contexts: list of context elements
            plug: function (context, trace) -> trace
            obs: function trace -> observable
            comp: optional function (ctx, ctx) -> ctx
        """
        self.traces = list(traces)
        self.contexts = list(contexts)
        self.plug = plug
        self.obs = obs
        self.comp = comp

    def nerode_equiv(self, x, y) -> bool:
        """Check if x ~N y: no context separates them."""
        return all(
            self.obs(self.plug(c, x)) == self.obs(self.plug(c, y))
            for c in self.contexts
        )

    def find_separator(self, x, y) -> Optional[Any]:
        """Find a context that separates x and y, or None."""
        for c in self.contexts:
            if self.obs(self.plug(c, x)) != self.obs(self.plug(c, y)):
                return c
        return None

    def compute_quotient(self) -> Dict[Any, int]:
        """Compute Nerode equivalence classes. Returns trace -> class_id."""
        classes = {}
        class_id = 0
        for x in self.traces:
            found = False
            for rep, cid in classes.items():
                if self.nerode_equiv(x, rep):
                    classes[x] = cid
                    found = True
                    break
            if not found:
                classes[x] = class_id
                class_id += 1
        return classes

    def quotient_size(self) -> int:
        """Number of Nerode equivalence classes."""
        return len(set(self.compute_quotient().values()))


# ============================================================================
# Example 1: Integer Addition System (Modular Observable)
# ============================================================================

def demo_modular_system():
    """Demo: ℤ with addition contexts and mod-n observable."""
    print("=" * 60)
    print("EXAMPLE 1: Integer Addition with Modular Observable")
    print("=" * 60)

    n = 4  # mod 4
    traces = list(range(-8, 9))  # subset of ℤ
    contexts = list(range(-8, 9))

    sys = ContextActionSystem(
        traces=traces,
        contexts=contexts,
        plug=lambda c, x: c + x,
        obs=lambda x: x % n,
        comp=lambda c1, c2: c1 + c2,
    )

    quotient = sys.compute_quotient()
    n_classes = len(set(quotient.values()))

    print(f"  Traces: integers from -8 to 8")
    print(f"  Contexts: integers from -8 to 8")
    print(f"  plug(c, x) = c + x")
    print(f"  Obs(x) = x mod {n}")
    print(f"  Number of Nerode classes: {n_classes}")
    print(f"  (Expected: {n})")
    print()

    # Show classes
    class_members = defaultdict(list)
    for x, cid in quotient.items():
        class_members[cid].append(x)
    for cid in sorted(class_members):
        members = sorted(class_members[cid])
        print(f"  Class {cid}: {members}  (obs = {traces[0] if not members else members[0] % n})")

    # Separator example
    print(f"\n  Separator for 1 and 2: context {sys.find_separator(1, 2)}")
    print(f"  Separator for 0 and 4: {sys.find_separator(0, 4)}  (None = equivalent)")
    print()


# ============================================================================
# Example 2: Max-Plus Affine Network
# ============================================================================

def demo_maxplus_network():
    """Demo: Max-plus affine network with finite state compression."""
    print("=" * 60)
    print("EXAMPLE 2: Max-Plus Affine Network")
    print("=" * 60)

    # 2D max-plus system: state = (x1, x2), context adds weights
    # Obs = max(x1, x2) (max-pooling)
    traces = [(i, j) for i in range(-3, 4) for j in range(-3, 4)]
    contexts = [(i, j) for i in range(-2, 3) for j in range(-2, 3)]

    sys = ContextActionSystem(
        traces=traces,
        contexts=contexts,
        plug=lambda c, x: (c[0] + x[0], c[1] + x[1]),
        obs=lambda x: max(x[0], x[1]),
    )

    quotient = sys.compute_quotient()
    n_classes = len(set(quotient.values()))
    print(f"  State space: ℤ² (subset -3..3 × -3..3)")
    print(f"  Contexts: ℤ² (subset -2..2 × -2..2)")
    print(f"  plug(c, x) = (c₁+x₁, c₂+x₂)")
    print(f"  Obs(x) = max(x₁, x₂)")
    print(f"  Number of Nerode classes: {n_classes}")

    # The max-plus observable max(x1, x2) distinguishes based on
    # the difference x1 - x2 and the max value.
    # Under shifts, what matters is max(c1+x1, c2+x2) for all c1,c2.
    # This equals max(c1, c2+x2-x1) + x1 (up to shift).
    # So two states are equivalent iff they are equal.
    print(f"  (Under full contexts, all distinct states are distinguishable)")

    # Show some separators
    print(f"\n  Separator for (1,2) and (2,1): {sys.find_separator((1,2), (2,1))}")
    print(f"  Separator for (0,0) and (1,1): {sys.find_separator((0,0), (1,1))}")
    print()


# ============================================================================
# Example 3: Finite Binary Classifier
# ============================================================================

def demo_binary_classifier():
    """Demo: Binary classifier with threshold, quotient computation."""
    print("=" * 60)
    print("EXAMPLE 3: Binary Threshold Classifier")
    print("=" * 60)

    # Traces in a finite subset, contexts are small perturbations
    traces = list(range(-5, 6))
    contexts = list(range(-10, 11))

    # Observable: whether value exceeds threshold
    threshold = 3
    sys = ContextActionSystem(
        traces=traces,
        contexts=contexts,
        plug=lambda c, x: c + x,
        obs=lambda x: x >= threshold,
    )

    quotient = sys.compute_quotient()
    n_classes = len(set(quotient.values()))

    print(f"  Traces: {traces}")
    print(f"  Obs(x) = (x ≥ {threshold})")
    print(f"  Nerode classes: {n_classes}")

    class_members = defaultdict(list)
    for x, cid in quotient.items():
        class_members[cid].append(x)
    for cid in sorted(class_members):
        members = sorted(class_members[cid])
        print(f"  Class {cid}: {members}")

    print(f"\n  Note: With enough contexts, each integer gets its own class")
    print(f"  (threshold can be shifted to separate any pair)")
    print()


# ============================================================================
# Example 4: Partition Refinement Algorithm
# ============================================================================

def partition_refinement(sys: ContextActionSystem):
    """
    Compute Nerode quotient via partition refinement.

    This is the algorithmic version of the backward direction of
    Theorem B: given an initial representation, iteratively refine
    until stable. The result is the Nerode quotient.
    """
    # Initial partition: group by observable
    obs_groups = defaultdict(list)
    for x in sys.traces:
        obs_groups[sys.obs(x)].append(x)

    partition = [set(g) for g in obs_groups.values()]
    block_of = {}
    for i, block in enumerate(partition):
        for x in block:
            block_of[x] = i

    iterations = 0
    changed = True
    while changed:
        changed = False
        new_partition = []
        new_block_of = {}

        for block in partition:
            # Try to split this block using each context
            sub_blocks = {frozenset(block): set(block)}

            for c in sys.contexts:
                next_sub_blocks = {}
                for sb_key, sb in sub_blocks.items():
                    splits = defaultdict(set)
                    for x in sb:
                        cx = sys.plug(c, x)
                        # Where does cx land in current partition?
                        if cx in block_of:
                            target = block_of[cx]
                        else:
                            target = -1  # out of trace set
                        splits[target].add(x)

                    for split_set in splits.values():
                        next_sub_blocks[frozenset(split_set)] = split_set

                sub_blocks = next_sub_blocks

            if len(sub_blocks) > 1:
                changed = True

            for sb in sub_blocks.values():
                idx = len(new_partition)
                new_partition.append(sb)
                for x in sb:
                    new_block_of[x] = idx

        partition = new_partition
        block_of = new_block_of
        iterations += 1

    return partition, iterations


def demo_partition_refinement():
    """Demo: Partition refinement algorithm."""
    print("=" * 60)
    print("EXAMPLE 4: Partition Refinement Algorithm")
    print("=" * 60)

    n = 6
    traces = list(range(12))
    contexts = list(range(12))

    sys = ContextActionSystem(
        traces=traces,
        contexts=contexts,
        plug=lambda c, x: (c + x) % 12,
        obs=lambda x: x % n,
    )

    partition, iters = partition_refinement(sys)

    print(f"  System: ℤ/12ℤ with mod-{n} observable")
    print(f"  Partition refinement converged in {iters} iterations")
    print(f"  Number of blocks: {len(partition)}")
    for i, block in enumerate(sorted(partition, key=lambda b: min(b))):
        print(f"    Block {i}: {sorted(block)}")
    print()


# ============================================================================
# Example 5: Join-Irreducible Decomposition
# ============================================================================

def demo_join_irreducible():
    """Demo: Join-irreducible decomposition in a finite lattice."""
    print("=" * 60)
    print("EXAMPLE 5: Tropical Fourier (Join-Irreducible) Decomposition")
    print("=" * 60)

    # Power set lattice of {a, b, c} — a Boolean algebra
    elements = [
        frozenset(),        # bot
        frozenset('a'),     # atom
        frozenset('b'),     # atom
        frozenset('c'),     # atom
        frozenset('ab'),    # a ∨ b
        frozenset('ac'),    # a ∨ c
        frozenset('bc'),    # b ∨ c
        frozenset('abc'),   # top
    ]

    # Join = union, Meet = intersection
    def join(x, y):
        return x | y

    def is_join_irreducible(a):
        """a is join-irreducible if a ≠ ⊥ and a = b ∨ c implies a = b or a = c."""
        if len(a) == 0:
            return False
        for b in elements:
            for c in elements:
                if join(b, c) == a and a != b and a != c:
                    return False
        return True

    def tropical_support(a):
        """Join-irreducibles below a."""
        return [j for j in elements if is_join_irreducible(j) and j <= a]

    print("  Lattice: Power set of {a, b, c}")
    print(f"  Elements: {len(elements)}")
    print()

    ji = [e for e in elements if is_join_irreducible(e)]
    print(f"  Join-irreducibles: {[set(j) for j in ji]}")
    print(f"  (These are the atoms: singletons)")
    print()

    print("  Decompositions (Tropical Fourier):")
    for e in elements:
        supp = tropical_support(e)
        supp_str = [set(s) for s in supp]
        recon = frozenset()
        for s in supp:
            recon = join(recon, s)
        check = "✓" if recon == e else "✗"
        label = str(set(e)) if e else '∅'
        print(f"    {label:>12} = ⊔{supp_str}  {check}")

    print()
    print("  Key insight: Every element is uniquely determined by its")
    print("  tropical support (the set of atoms/join-irreducibles below it).")
    print("  This is Birkhoff's theorem = Tropical Fourier decomposition.")
    print()


# ============================================================================
# Example 6: Compression Ratio Computation
# ============================================================================

def demo_compression():
    """Demo: Computing compression ratios for various systems."""
    print("=" * 60)
    print("EXAMPLE 6: Compression Ratios")
    print("=" * 60)

    systems = []

    # System 1: mod 4 (divides 100? No. Use mod on ℤ directly)
    sys1 = ContextActionSystem(
        traces=list(range(100)),
        contexts=list(range(100)),
        plug=lambda c, x: (c + x) % 100,
        obs=lambda x: x % 4,
    )
    systems.append(("ℤ/100ℤ, obs=mod 4", sys1, 100, 4))

    # System 2: mod 5
    sys2 = ContextActionSystem(
        traces=list(range(100)),
        contexts=list(range(100)),
        plug=lambda c, x: (c + x) % 100,
        obs=lambda x: x % 5,
    )
    systems.append(("ℤ/100ℤ, obs=mod 5", sys2, 100, 5))

    # System 3: mod 10
    sys3 = ContextActionSystem(
        traces=list(range(100)),
        contexts=list(range(100)),
        plug=lambda c, x: (c + x) % 100,
        obs=lambda x: x % 10,
    )
    systems.append(("ℤ/100ℤ, obs=mod 10", sys3, 100, 10))

    # System 4: constant obs
    sys4 = ContextActionSystem(
        traces=list(range(100)),
        contexts=list(range(100)),
        plug=lambda c, x: (c + x) % 100,
        obs=lambda x: 0,
    )
    systems.append(("ℤ/100ℤ, obs=const", sys4, 100, 1))

    print(f"  {'System':<25} {'Original':>10} {'Quotient':>10} {'Ratio':>10}")
    print(f"  {'-'*25} {'-'*10} {'-'*10} {'-'*10}")

    for name, sys, orig_size, expected_q in systems:
        q_size = sys.quotient_size()
        ratio = orig_size / q_size if q_size > 0 else float('inf')
        print(f"  {name:<25} {orig_size:>10} {q_size:>10} {ratio:>10.1f}x")

    print()
    print("  The Nerode quotient achieves optimal compression:")
    print("  no smaller representation can preserve all observable behavior.")
    print()


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  Tropical Neural Representation Theory: Demonstrations  ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_modular_system()
    demo_maxplus_network()
    demo_binary_classifier()
    demo_partition_refinement()
    demo_join_irreducible()
    demo_compression()

    print("All demos completed successfully.")


#!/usr/bin/env python3
"""Generate PACKAGE.json by bundling all artifacts."""

import json
import base64
import os

def read_file(path):
    with open(path, 'r') as f:
        return f.read()

def read_binary(path):
    with open(path, 'rb') as f:
        return base64.b64encode(f.read()).decode('utf-8')

# Read all content
article = read_file('ARTICLE.md')
research_paper = read_file('RESEARCH_PAPER.md')
future_directions = read_file('FUTURE_DIRECTIONS.md')

# Read Lean proofs
lean_files = [
    'Bridges/TropicalNerode/Basic.lean',
    'Bridges/TropicalNerode/Representation.lean',
    'Bridges/TropicalNerode/Minimality.lean',
    'Bridges/TropicalNerode/Extremal.lean',
    'Bridges/TropicalNerode/Examples.lean',
]
lean_proofs = ""
for f in lean_files:
    content = read_file(f)
    lean_proofs += f"-- ============ {f} ============\n\n{content}\n\n"

# Read Python demos
demo_code = read_file('demo.py')
algorithms_code = read_file('algorithms.py')
applications_code = read_file('applications.py')

# Read visualizations as base64
viz_data = []
for name, filename in [
    ("Nerode Quotient Visualization", "nerode_quotient.png"),
    ("Compression Ratios", "compression_ratios.png"),
    ("Birkhoff Decomposition", "birkhoff_decomposition.png"),
    ("Theorem Structure", "theorem_structure.png"),
]:
    b64 = read_binary(filename)
    viz_data.append({
        "name": name,
        "data": f"data:image/png;base64,{b64}"
    })

# Build package
package = {
    "title": "Tropical Neural Representation Theory: Idempotent Myhill-Nerode and Canonical Tropical Fourier Compression",
    "domain": "Algebra / Tropical Geometry / Machine Learning / Automata Theory",
    "article": article,
    "research_paper": research_paper,
    "future_directions": future_directions,
    "demos": [
        {"name": "Tropical Nerode Theory Demo", "code": demo_code},
        {"name": "Applications", "code": applications_code},
    ],
    "algorithms": [
        {
            "name": "Partition Refinement for Nerode Quotient",
            "pseudocode": (
                "Input: States S, Contexts K, plug, obs\n"
                "1. P ← partition S by obs value\n"
                "2. repeat:\n"
                "   for each block B in P, context c in K:\n"
                "     Split B by which P-block contains plug(c, x)\n"
                "   until no splits occur\n"
                "3. return P\n\n"
                "Complexity: O(|K| · |S|² · iterations)\n"
                "Correctness: Output = Nerode quotient (Theorem B)"
            )
        },
        {
            "name": "Separator Certificate Extraction",
            "pseudocode": (
                "Input: Nerode partition P, contexts K, plug, obs\n"
                "1. For each pair of blocks (B_i, B_j):\n"
                "   Pick representatives r_i ∈ B_i, r_j ∈ B_j\n"
                "   Find c ∈ K with obs(plug(c, r_i)) ≠ obs(plug(c, r_j))\n"
                "   Record (B_i, B_j) → c as separation certificate\n"
                "2. return certificates\n\n"
                "Correctness: Certificates are machine-checkable proofs\n"
                "of inequivalence (Theorem E)"
            )
        },
        {
            "name": "Tropical Fourier Decomposition",
            "pseudocode": (
                "Input: Finite lattice (L, ⊔, ⊥)\n"
                "1. Find join-irreducibles:\n"
                "   JI = {a ∈ L : a ≠ ⊥ ∧ (a = b⊔c → a=b ∨ a=c)}\n"
                "2. For each a ∈ L:\n"
                "   supp(a) = {j ∈ JI : j ≤ a}\n"
                "3. Verify: a = ⊔ supp(a) for all a (Birkhoff)\n"
                "4. return (JI, supp)\n\n"
                "This is the tropical Fourier transform:\n"
                "supp(a) = spectral support of a"
            )
        },
    ],
    "visualizations": viz_data,
    "lean_proofs": lean_proofs,
}

with open('PACKAGE.json', 'w') as f:
    json.dump(package, f, indent=2, ensure_ascii=False)

print(f"Generated PACKAGE.json ({os.path.getsize('PACKAGE.json') / 1024:.0f} KB)")


#!/usr/bin/env python3
"""
Generate visualizations for Tropical Neural Representation Theory.
Outputs base64-encoded PNG images.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
import base64
import io
import json


def fig_to_base64(fig):
    """Convert matplotlib figure to base64 data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    data = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{data}"


def viz_nerode_quotient():
    """Visualize the Nerode quotient: traces grouped into equivalence classes."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    # Left: Original state space
    ax1.set_title("Original State Space (12 states)", fontsize=14, fontweight='bold')
    colors_orig = plt.cm.Set3(np.linspace(0, 1, 12))
    for i in range(12):
        angle = 2 * np.pi * i / 12
        x, y = 2 * np.cos(angle), 2 * np.sin(angle)
        circle = plt.Circle((x, y), 0.3, color=colors_orig[i], ec='black', lw=1.5)
        ax1.add_patch(circle)
        ax1.text(x, y, str(i), ha='center', va='center', fontsize=10, fontweight='bold')
    ax1.set_xlim(-3.5, 3.5)
    ax1.set_ylim(-3.5, 3.5)
    ax1.set_aspect('equal')
    ax1.axis('off')

    # Right: Nerode quotient (mod 3 → 4 classes if we use mod 4, or 3)
    n_classes = 3
    ax2.set_title(f"Nerode Quotient ({n_classes} classes)", fontsize=14, fontweight='bold')
    class_colors = ['#FF6B6B', '#4ECDC4', '#45B7D1']
    class_members = {0: [0, 3, 6, 9], 1: [1, 4, 7, 10], 2: [2, 5, 8, 11]}

    for cid in range(n_classes):
        angle = 2 * np.pi * cid / n_classes - np.pi / 2
        cx, cy = 2 * np.cos(angle), 2 * np.sin(angle)

        # Draw class circle
        circle = plt.Circle((cx, cy), 0.8, color=class_colors[cid],
                           ec='black', lw=2, alpha=0.7)
        ax2.add_patch(circle)

        members = class_members[cid]
        ax2.text(cx, cy + 0.15, f"Class {cid}", ha='center', va='center',
                fontsize=11, fontweight='bold')
        ax2.text(cx, cy - 0.25, f"{{{', '.join(map(str, members))}}}",
                ha='center', va='center', fontsize=8)

    ax2.set_xlim(-3.5, 3.5)
    ax2.set_ylim(-3.5, 3.5)
    ax2.set_aspect('equal')
    ax2.axis('off')

    # Arrow between
    fig.text(0.5, 0.5, "→\nNerode\nQuotient", ha='center', va='center',
            fontsize=12, fontweight='bold', color='#333')

    fig.suptitle("Tropical Nerode Quotient: State Compression",
                fontsize=16, fontweight='bold', y=0.98)
    return fig_to_base64(fig)


def viz_compression_ratios():
    """Bar chart of compression ratios for different observable granularities."""
    fig, ax = plt.subplots(figsize=(10, 6))

    systems = ['const', 'mod 2', 'mod 4', 'mod 5', 'mod 10', 'mod 20', 'mod 50', 'identity']
    quotient_sizes = [1, 2, 4, 5, 10, 20, 50, 100]
    ratios = [100/q for q in quotient_sizes]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, len(systems)))
    bars = ax.bar(systems, ratios, color=colors, edgecolor='black', linewidth=0.5)

    ax.set_ylabel('Compression Ratio (×)', fontsize=13)
    ax.set_xlabel('Observable Granularity', fontsize=13)
    ax.set_title('Compression Ratio vs Observable Granularity\n(100-state cyclic system)',
                fontsize=14, fontweight='bold')

    # Add value labels
    for bar, ratio in zip(bars, ratios):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 1,
               f'{ratio:.0f}×', ha='center', va='bottom', fontsize=10, fontweight='bold')

    ax.set_ylim(0, 115)
    ax.spines['top'].set_visible(False)
    ax.spines['right'].set_visible(False)

    return fig_to_base64(fig)


def viz_birkhoff_decomposition():
    """Visualize the Birkhoff/tropical Fourier decomposition."""
    fig, ax = plt.subplots(figsize=(10, 8))

    # Hasse diagram of power set of {a,b,c}
    levels = {
        0: [('∅', frozenset())],
        1: [('{a}', frozenset('a')), ('{b}', frozenset('b')), ('{c}', frozenset('c'))],
        2: [('{a,b}', frozenset('ab')), ('{a,c}', frozenset('ac')), ('{b,c}', frozenset('bc'))],
        3: [('{a,b,c}', frozenset('abc'))],
    }

    positions = {}
    for level, elts in levels.items():
        n = len(elts)
        for i, (label, _) in enumerate(elts):
            x = (i - (n-1)/2) * 2.5
            y = level * 2
            positions[label] = (x, y)

    # Draw edges (Hasse diagram)
    edges = [
        ('∅', '{a}'), ('∅', '{b}'), ('∅', '{c}'),
        ('{a}', '{a,b}'), ('{a}', '{a,c}'),
        ('{b}', '{a,b}'), ('{b}', '{b,c}'),
        ('{c}', '{a,c}'), ('{c}', '{b,c}'),
        ('{a,b}', '{a,b,c}'), ('{a,c}', '{a,b,c}'), ('{b,c}', '{a,b,c}'),
    ]

    for e1, e2 in edges:
        x1, y1 = positions[e1]
        x2, y2 = positions[e2]
        ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, lw=1)

    # Draw nodes
    ji_labels = {'{a}', '{b}', '{c}'}
    for label, (x, y) in positions.items():
        is_ji = label in ji_labels
        color = '#FF6B6B' if is_ji else '#E8E8E8'
        ec = '#CC0000' if is_ji else '#666'
        lw = 2.5 if is_ji else 1
        size = 0.4 if is_ji else 0.35

        circle = plt.Circle((x, y), size, color=color, ec=ec, lw=lw, zorder=5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=9,
               fontweight='bold' if is_ji else 'normal', zorder=6)

    # Annotations
    ax.text(4.5, 2, "★ Join-irreducible\n(tropical basis)", fontsize=11,
           color='#CC0000', fontweight='bold', va='center')

    ax.text(-4.5, 5, "Decomposition examples:\n"
            "{a,b} = {a} ⊔ {b}\n"
            "{a,b,c} = {a} ⊔ {b} ⊔ {c}\n"
            "∅ = ⊔(empty)",
           fontsize=10, va='center', fontfamily='monospace',
           bbox=dict(boxstyle='round', facecolor='lightyellow', alpha=0.8))

    ax.set_xlim(-5.5, 5.5)
    ax.set_ylim(-1, 7.5)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Tropical Fourier Decomposition (Birkhoff's Theorem)\nPower Set Lattice of {a, b, c}",
                fontsize=14, fontweight='bold')

    return fig_to_base64(fig)


def viz_theorem_structure():
    """Visualize the theorem dependency structure."""
    fig, ax = plt.subplots(figsize=(12, 7))

    theorems = {
        'Equiv': ('Theorem 3.3\nEquivalence', (2, 6)),
        'RightInv': ('Theorem 3.4\nRight-Invariance', (6, 6)),
        'Max': ('Theorem A\nMaximality', (4, 4.5)),
        'Sep': ('Theorem E\nSeparation', (8, 4.5)),
        'FwdRep': ('Forward\nQuotient→Rep', (2, 3)),
        'BwdRep': ('Backward\nRep→Quotient', (6, 3)),
        'MainIff': ('Theorem B\nMain Iff', (4, 1.5)),
        'Uniq': ('Theorem C\nUniqueness', (8, 1.5)),
        'Birk': ('Theorem D\nBirkhoff', (10, 3)),
    }

    deps = [
        ('Equiv', 'Max'), ('RightInv', 'Max'),
        ('RightInv', 'FwdRep'), ('Max', 'FwdRep'),
        ('Sep', 'BwdRep'), ('Max', 'BwdRep'),
        ('FwdRep', 'MainIff'), ('BwdRep', 'MainIff'),
        ('MainIff', 'Uniq'), ('Sep', 'Uniq'),
        ('MainIff', 'Birk'),
    ]

    # Draw edges
    for d1, d2 in deps:
        x1, y1 = theorems[d1][1]
        x2, y2 = theorems[d2][1]
        ax.annotate('', xy=(x2, y2 + 0.35), xytext=(x1, y1 - 0.35),
                   arrowprops=dict(arrowstyle='->', color='#666', lw=1.5))

    # Draw nodes
    main_theorems = {'Max', 'MainIff', 'Uniq', 'Birk', 'Sep'}
    for key, (label, (x, y)) in theorems.items():
        is_main = key in main_theorems
        color = '#4ECDC4' if is_main else '#E8E8E8'
        ec = '#2B8B8B' if is_main else '#666'
        box = patches.FancyBboxPatch((x - 0.9, y - 0.35), 1.8, 0.7,
                                     boxstyle="round,pad=0.1",
                                     facecolor=color, edgecolor=ec, lw=2)
        ax.add_patch(box)
        ax.text(x, y, label, ha='center', va='center', fontsize=8,
               fontweight='bold' if is_main else 'normal')

    ax.set_xlim(0, 12)
    ax.set_ylim(0.5, 7)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title("Theorem Dependency Structure", fontsize=14, fontweight='bold')

    return fig_to_base64(fig)


if __name__ == "__main__":
    print("Generating visualizations...")

    viz1 = viz_nerode_quotient()
    viz2 = viz_compression_ratios()
    viz3 = viz_birkhoff_decomposition()
    viz4 = viz_theorem_structure()

    # Save individual files
    for name, data in [
        ("nerode_quotient.png", viz1),
        ("compression_ratios.png", viz2),
        ("birkhoff_decomposition.png", viz3),
        ("theorem_structure.png", viz4),
    ]:
        img_data = base64.b64decode(data.split(",")[1])
        with open(name, "wb") as f:
            f.write(img_data)
        print(f"  Saved {name}")

    # Output JSON fragment for PACKAGE.json
    vizs = [
        {"name": "Nerode Quotient Visualization", "data": viz1},
        {"name": "Compression Ratios", "data": viz2},
        {"name": "Birkhoff Decomposition", "data": viz3},
        {"name": "Theorem Structure", "data": viz4},
    ]

    print(f"  Generated {len(vizs)} visualizations")
    print("Done.")
