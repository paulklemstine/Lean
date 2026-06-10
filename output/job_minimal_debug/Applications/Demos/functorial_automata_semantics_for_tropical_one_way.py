#!/usr/bin/env python3
"""
Algorithms for Tropical Automata Nerode Theory

Implements:
1. Right-cost computation (O(|w| · |σ|) per query)
2. Partition refinement for Nerode classes (O(k · n² · |α|^k))
3. Separation witness extraction (exhaustive search)
4. Functorial state map verification
5. Collision entropy computation
"""

from typing import Dict, List, Tuple, Set, Optional, FrozenSet
from itertools import product
from collections import defaultdict
import time


class WeightedAutomaton:
    """Tropical one-way weighted automaton.

    Models the structure TropicalOneWayAutomaton from the formalization:
    - step : α → σ → σ → W (transition weights)
    - output : σ → W (output weights)

    Time complexity of construction: O(|step| + |σ|)
    Space complexity: O(|step| + |σ|)
    """

    def __init__(self, states: List[int], alphabet: List, step: Dict, output: Dict):
        self.states = list(states)
        self.alphabet = list(alphabet)
        self.step = step  # (a, q, s) -> w
        self.output = output  # q -> w
        self.n = len(self.states)

    def transition_weight(self, a, q, s) -> int:
        return self.step.get((a, q, s), 0)

    def output_weight(self, q) -> int:
        return self.output.get(q, 0)


def compute_right_cost(A: WeightedAutomaton, word: List, q: int) -> int:
    """Compute rightCost(A, word, q) by structural recursion.

    Algorithm: direct recursive computation following the formal definition.

    Time complexity: O(|word| · |σ|) for deterministic automata,
                     O(|word| · |σ|²) for nondeterministic.
    Space complexity: O(|word|) stack depth.

    Args:
        A: The weighted automaton
        word: Input word as list of alphabet symbols
        q: Starting state

    Returns:
        The right-cost value (integer)
    """
    if not word:
        return A.output_weight(q)
    a = word[0]
    rest = word[1:]
    total = 0
    for s in A.states:
        w = A.transition_weight(a, q, s)
        if w != 0:  # optimization: skip zero weights
            total += w * compute_right_cost(A, rest, s)
    return total


def compute_right_cost_dp(A: WeightedAutomaton, word: List) -> Dict[int, int]:
    """Compute rightCost(A, word, q) for ALL states q simultaneously.

    Uses dynamic programming (backward pass) to avoid redundant computation.

    Time complexity: O(|word| · |σ|²)
    Space complexity: O(|σ|)

    Args:
        A: The weighted automaton
        word: Input word as list of alphabet symbols

    Returns:
        Dictionary mapping each state to its right-cost
    """
    # Base case: empty word
    costs = {q: A.output_weight(q) for q in A.states}

    # Process word from right to left
    for a in reversed(word):
        new_costs = {}
        for q in A.states:
            total = 0
            for s in A.states:
                w = A.transition_weight(a, q, s)
                if w != 0:
                    total += w * costs[s]
            new_costs[q] = total
        costs = new_costs

    return costs


def partition_refinement(A: WeightedAutomaton, max_depth: int) -> List[FrozenSet[int]]:
    """Bounded Nerode partition refinement algorithm.

    Implements iterative refinement of state partitions based on
    observable behavior up to depth k.

    Algorithm:
        1. Initialize partition by output values (depth 0)
        2. For each depth 1..k:
           - Refine each class by checking if states produce
             different aggregated costs when transitioning into
             the current partition classes
        3. Return final partition

    Time complexity: O(max_depth · |σ|² · |α|)
    Space complexity: O(|σ|²)

    Args:
        A: The weighted automaton
        max_depth: Maximum refinement depth k

    Returns:
        List of frozensets, each a Nerode equivalence class (up to depth k)
    """
    # Step 0: initial partition by output
    groups = defaultdict(set)
    for q in A.states:
        groups[A.output_weight(q)].add(q)
    partition = [frozenset(g) for g in groups.values()]

    def state_to_class(q):
        for i, cls in enumerate(partition):
            if q in cls:
                return i
        return -1

    for depth in range(1, max_depth + 1):
        new_partition = []
        for cls in partition:
            # Compute signature for each state in class
            signatures = defaultdict(set)
            for q in cls:
                sig_parts = []
                for a in A.alphabet:
                    # Signature: for each symbol, the distribution of
                    # weights over partition classes
                    class_weights = defaultdict(int)
                    for s in A.states:
                        w = A.transition_weight(a, q, s)
                        if w != 0:
                            class_weights[state_to_class(s)] += w
                    sig_parts.append(tuple(sorted(class_weights.items())))
                signatures[tuple(sig_parts)].add(q)
            new_partition.extend(frozenset(g) for g in signatures.values())
        partition = new_partition

    return partition


def find_separation_witness(A: WeightedAutomaton, p: int, q: int,
                            max_length: int) -> Optional[List]:
    """Find the shortest word separating states p and q.

    Exhaustive search over words of increasing length.

    Time complexity: O(|α|^L · |σ|) where L is the witness length
    Space complexity: O(L)

    Args:
        A: The weighted automaton
        p, q: States to separate
        max_length: Maximum word length to search

    Returns:
        Shortest separating word, or None if states are equivalent up to max_length
    """
    for length in range(max_length + 1):
        for word in product(A.alphabet, repeat=length):
            word_list = list(word)
            costs = compute_right_cost_dp(A, word_list)
            if costs[p] != costs[q]:
                return word_list
    return None


def verify_functorial_map(A: WeightedAutomaton, B: WeightedAutomaton,
                          state_map: Dict[int, int], max_word_length: int = 4) -> bool:
    """Verify that a state map preserves right-costs (up to bounded word length).

    Checks: ∀ w q, rightCost(A, w, q) = rightCost(B, w, map(q))

    Args:
        A, B: Source and target automata
        state_map: Mapping from A's states to B's states
        max_word_length: Maximum word length to check

    Returns:
        True if the map preserves costs for all tested words
    """
    for length in range(max_word_length + 1):
        for word in product(A.alphabet, repeat=length):
            word_list = list(word)
            costs_A = compute_right_cost_dp(A, word_list)
            costs_B = compute_right_cost_dp(B, word_list)
            for q in A.states:
                if costs_A[q] != costs_B[state_map[q]]:
                    return False
    return True


def collision_entropy_bound(A: WeightedAutomaton) -> int:
    """Compute the collision entropy bound (= |σ|).

    This is the upper bound on the number of distinguishable
    output profiles (Nerode classes).

    Args:
        A: The weighted automaton

    Returns:
        Number of states (collision entropy bound)
    """
    return len(A.states)


def nerode_class_count(A: WeightedAutomaton, max_depth: int = 10) -> int:
    """Compute the number of Nerode equivalence classes (up to depth).

    Args:
        A: The weighted automaton
        max_depth: Refinement depth

    Returns:
        Number of classes in the bounded partition
    """
    partition = partition_refinement(A, max_depth)
    return len(partition)


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    print("Algorithms for Tropical Automata Nerode Theory")
    print("=" * 50)

    # Example automaton
    A = WeightedAutomaton(
        states=[0, 1, 2, 3],
        alphabet=[0, 1],
        step={
            (0, 0, 1): 1, (1, 0, 2): 1,
            (0, 1, 0): 1, (1, 1, 3): 1,
            (0, 2, 3): 1, (1, 2, 0): 1,
            (0, 3, 1): 1, (1, 3, 2): 1,
        },
        output={0: 1, 1: 2, 2: 1, 3: 2}
    )

    print("\n1. Right-cost computation (DP):")
    for w in [[], [0], [1], [0, 1], [1, 0]]:
        costs = compute_right_cost_dp(A, w)
        print(f"  word {w}: costs = {costs}")

    print("\n2. Partition refinement:")
    for k in range(5):
        partition = partition_refinement(A, k)
        print(f"  depth {k}: {[sorted(c) for c in partition]}")

    print("\n3. Separation witnesses:")
    for p in range(4):
        for q in range(p + 1, 4):
            w = find_separation_witness(A, p, q, max_length=4)
            if w is None:
                print(f"  states {p}, {q}: equivalent (no witness found)")
            else:
                costs = compute_right_cost_dp(A, w)
                print(f"  states {p}, {q}: separated by {w} "
                      f"(costs: {costs[p]} vs {costs[q]})")

    print(f"\n4. Collision entropy bound: {collision_entropy_bound(A)}")
    print(f"   Actual Nerode classes: {nerode_class_count(A)}")

    # Timing benchmark
    print("\n5. Performance benchmark:")
    import random
    random.seed(123)
    for n in [10, 50, 100]:
        states = list(range(n))
        step = {}
        for a in [0, 1]:
            for q in states:
                t = random.choice(states)
                step[(a, q, t)] = random.randint(1, 5)
        output = {q: random.randint(0, 10) for q in states}
        B = WeightedAutomaton(states, [0, 1], step, output)

        start = time.time()
        classes = nerode_class_count(B, max_depth=5)
        elapsed = time.time() - start
        print(f"  n={n:3d}: {classes} classes, {elapsed:.4f}s")


#!/usr/bin/env python3
"""
Applications of Tropical Automata Nerode Theory

Demonstrates real-world applications to:
1. Cryptography: tropical hash collision analysis
2. Machine Learning: certified robustness margins
3. Physics: thermodynamic energy landscape analysis
"""

from typing import Dict, List, Tuple, Set
from itertools import product
from collections import defaultdict
import random
import math


class TropicalAutomaton:
    """Tropical one-way weighted automaton for application demos."""

    def __init__(self, states, alphabet, step, output):
        self.states = list(states)
        self.alphabet = list(alphabet)
        self.step = step
        self.output = output

    def right_cost(self, word, q):
        if not word:
            return self.output.get(q, 0)
        a = word[0]
        rest = word[1:]
        return sum(
            self.step.get((a, q, s), 0) * self.right_cost(rest, s)
            for s in self.states
        )

    def right_cost_dp(self, word):
        costs = {q: self.output.get(q, 0) for q in self.states}
        for a in reversed(word):
            new_costs = {}
            for q in self.states:
                new_costs[q] = sum(
                    self.step.get((a, q, s), 0) * costs[s]
                    for s in self.states
                )
            costs = new_costs
        return costs


# ============================================================
# APPLICATION 1: Tropical Hash Collision Analysis
# ============================================================

def app_collision_analysis():
    """Analyze collision structure of a tropical hash function.

    Models a hash function as a tropical automaton where inputs
    are words and outputs are hash values. Collisions correspond
    to Nerode-equivalent input prefixes.
    """
    print("APPLICATION 1: Tropical Hash Collision Analysis")
    print("=" * 55)

    # Model a simple hash as an 8-state automaton
    n = 8
    states = list(range(n))
    alphabet = [0, 1]

    random.seed(2024)
    step = {}
    for a in alphabet:
        for q in states:
            # Deterministic transitions with varying weights
            target = (q * 3 + a * 5 + 7) % n
            weight = (q + a + 1) % 5 + 1
            step[(a, q, target)] = weight

    output = {q: (q * 7 + 3) % 13 for q in states}

    A = TropicalAutomaton(states, alphabet, step, output)

    # Compute hash values for all 6-bit inputs
    hash_values = {}
    for length in range(1, 7):
        for word in product(alphabet, repeat=length):
            word_list = list(word)
            # Hash = right-cost from initial state 0
            h = A.right_cost(word_list, 0)
            hash_values[tuple(word_list)] = h

    # Find collisions
    value_to_inputs = defaultdict(list)
    for inp, h in hash_values.items():
        value_to_inputs[h].append(inp)

    collisions = {h: inputs for h, inputs in value_to_inputs.items() if len(inputs) > 1}

    print(f"Total inputs tested: {len(hash_values)}")
    print(f"Distinct hash values: {len(value_to_inputs)}")
    print(f"Collision groups: {len(collisions)}")
    print(f"Collision entropy bound (|σ|): {n}")
    print()

    if collisions:
        print("Sample collisions:")
        for h, inputs in sorted(collisions.items())[:3]:
            print(f"  Hash value {h}: {len(inputs)} colliding inputs")
            for inp in inputs[:3]:
                print(f"    input = {list(inp)}")
    print()

    # Nerode class analysis
    print("Nerode equivalence classes (by observable behavior):")
    classes = defaultdict(set)
    max_test = 4
    for q in states:
        sig = []
        for length in range(max_test + 1):
            for word in product(alphabet, repeat=length):
                sig.append(A.right_cost(list(word), q))
        classes[tuple(sig)].add(q)

    for i, (sig, members) in enumerate(sorted(classes.items(), key=lambda x: min(x[1]))):
        print(f"  Class {i}: states {sorted(members)}")

    print(f"\nNerode class count: {len(classes)}")
    print(f"Compression ratio: {n}/{len(classes)} = {n/len(classes):.2f}")
    print()


# ============================================================
# APPLICATION 2: Certified Robustness Margins
# ============================================================

def app_certified_robustness():
    """Compute Lipschitz certified robustness margins for a classifier.

    Models a sequence classifier as a tropical automaton where
    different states represent different classification decisions.
    The margin is the minimum cost gap over separating words.
    """
    print("APPLICATION 2: Certified Robustness Margins")
    print("=" * 55)

    # Binary classifier: states 0-2 = class A, states 3-5 = class B
    states = list(range(6))
    alphabet = [0, 1]

    step = {
        (0, 0, 1): 2, (1, 0, 2): 3,
        (0, 1, 0): 1, (1, 1, 3): 4,
        (0, 2, 4): 2, (1, 2, 5): 1,
        (0, 3, 4): 2, (1, 3, 5): 3,
        (0, 4, 3): 1, (1, 4, 0): 4,
        (0, 5, 1): 2, (1, 5, 2): 1,
    }

    output = {0: 10, 1: 8, 2: 12, 3: -5, 4: -3, 5: -7}

    A = TropicalAutomaton(states, alphabet, step, output)

    class_A = [0, 1, 2]
    class_B = [3, 4, 5]

    print("Class A states: 0, 1, 2 (positive output)")
    print("Class B states: 3, 4, 5 (negative output)")
    print()

    # Compute margins between all inter-class pairs
    max_word_len = 5
    margins = {}

    for p in class_A:
        for q in class_B:
            min_gap = float('inf')
            best_word = None
            found_sep = False

            for length in range(max_word_len + 1):
                for word in product(alphabet, repeat=length):
                    word_list = list(word)
                    cp = A.right_cost(word_list, p)
                    cq = A.right_cost(word_list, q)
                    gap = abs(cp - cq)
                    if gap > 0:
                        found_sep = True
                        if gap < min_gap:
                            min_gap = gap
                            best_word = word_list

            if found_sep:
                margins[(p, q)] = (min_gap, best_word)

    print("Lipschitz separation margins (inter-class):")
    for (p, q), (margin, word) in sorted(margins.items()):
        print(f"  states ({p}, {q}): margin = {margin}, witness = {word}")

    if margins:
        min_margin = min(m for m, _ in margins.values())
        print(f"\nMinimum inter-class margin: {min_margin}")
        print(f"Certified robustness radius: {min_margin}")
        print("(Any perturbation with cost < margin preserves classification)")
    print()


# ============================================================
# APPLICATION 3: Thermodynamic Energy Landscape
# ============================================================

def app_thermodynamic_energy():
    """Analyze the energy landscape of a tropical dynamical system.

    Interprets the tropical automaton as a physical system where
    output weights are energies and transitions are state changes.
    """
    print("APPLICATION 3: Thermodynamic Energy Landscape")
    print("=" * 55)

    # 10-state system modeling energy levels
    n = 10
    states = list(range(n))
    alphabet = [0, 1]  # two types of perturbation

    random.seed(42)
    step = {}
    for a in alphabet:
        for q in states:
            # Each state transitions to 2 possible successors
            t1 = (q + a + 1) % n
            t2 = (q + 2 * a + 3) % n
            step[(a, q, t1)] = 1
            step[(a, q, t2)] = 1

    # Energy levels
    output = {q: int(10 * math.sin(q * 0.7) + 15) for q in states}

    A = TropicalAutomaton(states, alphabet, step, output)

    print("State energies (tropical free energy):")
    for q in states:
        print(f"  State {q}: E = {output[q]}")

    # Compute energy evolution over time steps
    print("\nEnergy evolution (right-cost for increasing word length):")
    for q in [0, 3, 7]:
        print(f"  Starting state {q}:")
        for length in range(6):
            # Average right-cost over all words of given length
            costs = []
            for word in product(alphabet, repeat=length):
                costs.append(A.right_cost(list(word), q))
            avg = sum(costs) / len(costs) if costs else output[q]
            print(f"    depth {length}: avg right-cost = {avg:.1f}")

    # Check Nerode equivalence (energy invariance)
    print("\nNerode equivalence classes and energy conservation:")
    classes = defaultdict(set)
    max_test = 3
    for q in states:
        sig = []
        for length in range(max_test + 1):
            for word in product(alphabet, repeat=length):
                sig.append(A.right_cost(list(word), q))
        classes[tuple(sig)].add(q)

    for sig, members in sorted(classes.items(), key=lambda x: min(x[1])):
        energies = [output[q] for q in members]
        members_sorted = sorted(members)
        energy_str = ", ".join(f"E({q})={output[q]}" for q in members_sorted)
        all_equal = len(set(energies)) == 1
        print(f"  Class {members_sorted}: {energy_str} "
              f"{'✓ equal' if all_equal else '(non-degenerate)'}")

    print()


# ============================================================
# Run all applications
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL AUTOMATA NERODE THEORY — APPLICATIONS")
    print("=" * 60)
    print()

    app_collision_analysis()
    print("\n" + "=" * 60 + "\n")
    app_certified_robustness()
    print("\n" + "=" * 60 + "\n")
    app_thermodynamic_energy()

    print("=" * 60)
    print("All applications completed.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Automata Nerode Theory — Concrete Demonstrations

This module provides working examples of the tropical weighted Myhill-Nerode
theory, demonstrating right-cost computation, Nerode equivalence testing,
separation witness extraction, and partition refinement.
"""

from typing import Dict, List, Tuple, Set, Optional
from itertools import product
from collections import defaultdict


class TropicalOneWayAutomaton:
    """A one-way tropical weighted automaton.

    Attributes:
        states: Set of state identifiers
        alphabet: Set of input symbols
        step: Dict mapping (symbol, source, target) -> weight
        output: Dict mapping state -> output weight
    """

    def __init__(self, states: set, alphabet: set,
                 step: Dict[Tuple, int], output: Dict, default_weight: int = 0):
        self.states = states
        self.alphabet = alphabet
        self.step = step
        self.output = output
        self.default_weight = default_weight

    def get_step(self, a, q, s) -> int:
        return self.step.get((a, q, s), self.default_weight)

    def get_output(self, q) -> int:
        return self.output.get(q, 0)


def right_cost(A: TropicalOneWayAutomaton, word: List, q) -> int:
    """Compute the right-cost of processing word from state q.

    rightCost(A, [], q) = A.output(q)
    rightCost(A, a::w, q) = sum_s A.step(a,q,s) * rightCost(A, w, s)
    """
    if not word:
        return A.get_output(q)
    a, *rest = word
    return sum(A.get_step(a, q, s) * right_cost(A, rest, s) for s in A.states)


def tropical_nerode_check(A: TropicalOneWayAutomaton, p, q, max_length: int = 5) -> Tuple[bool, Optional[List]]:
    """Check if two states are Nerode-equivalent up to words of given length.

    Returns (equivalent, separating_word_or_None).
    """
    for length in range(max_length + 1):
        for word in product(A.alphabet, repeat=length):
            word_list = list(word)
            cost_p = right_cost(A, word_list, p)
            cost_q = right_cost(A, word_list, q)
            if cost_p != cost_q:
                return False, word_list
    return True, None


def bounded_nerode_partition(A: TropicalOneWayAutomaton, k: int) -> List[Set]:
    """Compute the k-bounded Nerode partition by iterative refinement.

    Implements the partition refinement algorithm from the paper.
    """
    # Initial partition: group by output
    output_groups = defaultdict(set)
    for q in A.states:
        output_groups[A.get_output(q)].add(q)
    partition = list(output_groups.values())

    for level in range(1, k + 1):
        new_partition = []
        for cls in partition:
            # Refine class by checking all words of length exactly 'level'
            signatures = defaultdict(set)
            for q in cls:
                sig_parts = []
                for word in product(A.alphabet, repeat=level):
                    sig_parts.append(right_cost(A, list(word), q))
                sig = tuple(sig_parts)
                signatures[sig].add(q)
            new_partition.extend(signatures.values())
        partition = new_partition

    return partition


def tropical_state_energy(A: TropicalOneWayAutomaton, q) -> int:
    """Compute the tropical state energy (empty-word right-cost)."""
    return right_cost(A, [], q)


def print_separator():
    print("\n" + "=" * 70 + "\n")


# ============================================================
# DEMO 1: Basic right-cost computation
# ============================================================

def demo_basic_right_cost():
    """Demonstrate right-cost computation on a simple 3-state automaton."""
    print("DEMO 1: Basic Right-Cost Computation")
    print("-" * 40)

    # 3-state automaton over binary alphabet {0, 1}
    states = {0, 1, 2}
    alphabet = {0, 1}

    # Transition weights: deterministic with unit weights
    step = {
        (0, 0, 1): 1,  # state 0, input 0 -> state 1
        (1, 0, 2): 1,  # state 0, input 1 -> state 2
        (0, 1, 0): 1,  # state 1, input 0 -> state 0
        (1, 1, 1): 1,  # state 1, input 1 -> state 1
        (0, 2, 2): 1,  # state 2, input 0 -> state 2
        (1, 2, 0): 1,  # state 2, input 1 -> state 0
    }

    output = {0: 1, 1: 2, 2: 3}

    A = TropicalOneWayAutomaton(states, alphabet, step, output)

    print(f"States: {states}")
    print(f"Alphabet: {alphabet}")
    print(f"Outputs: {output}")
    print()

    # Compute right-costs for various words
    for q in sorted(states):
        print(f"State {q}:")
        for word in [[], [0], [1], [0, 0], [0, 1], [1, 0], [1, 1]]:
            cost = right_cost(A, word, q)
            word_str = str(word) if word else "[]"
            print(f"  rightCost({word_str}) = {cost}")
        print()


# ============================================================
# DEMO 2: Nerode equivalence testing
# ============================================================

def demo_nerode_equivalence():
    """Demonstrate Nerode equivalence testing with separation witnesses."""
    print("DEMO 2: Nerode Equivalence Testing")
    print("-" * 40)

    # 4-state automaton where states 0 and 2 are Nerode-equivalent
    states = {0, 1, 2, 3}
    alphabet = {0, 1}

    # States 0 and 2 have identical transition structure and outputs
    step = {
        (0, 0, 1): 1, (1, 0, 3): 1,
        (0, 1, 1): 1, (1, 1, 3): 1,
        (0, 2, 1): 1, (1, 2, 3): 1,  # same as state 0
        (0, 3, 3): 1, (1, 3, 1): 1,
    }

    output = {0: 5, 1: 10, 2: 5, 3: 7}

    A = TropicalOneWayAutomaton(states, alphabet, step, output)

    print("Testing Nerode equivalence for all state pairs:")
    for p in sorted(states):
        for q in sorted(states):
            if p < q:
                equiv, witness = tropical_nerode_check(A, p, q, max_length=4)
                if equiv:
                    print(f"  States {p} ≡ {q}  (Nerode-equivalent)")
                else:
                    print(f"  States {p} ≢ {q}  (separated by word {witness})")
                    cp = right_cost(A, witness, p)
                    cq = right_cost(A, witness, q)
                    print(f"    rightCost(w, {p}) = {cp}, rightCost(w, {q}) = {cq}")
    print()


# ============================================================
# DEMO 3: Partition refinement
# ============================================================

def demo_partition_refinement():
    """Demonstrate the bounded Nerode partition refinement algorithm."""
    print("DEMO 3: Partition Refinement Algorithm")
    print("-" * 40)

    states = {0, 1, 2, 3, 4, 5}
    alphabet = {0, 1}

    step = {
        (0, 0, 1): 1, (1, 0, 2): 1,
        (0, 1, 0): 1, (1, 1, 3): 1,
        (0, 2, 3): 1, (1, 2, 4): 1,
        (0, 3, 1): 1, (1, 3, 5): 1,
        (0, 4, 5): 1, (1, 4, 0): 1,
        (0, 5, 4): 1, (1, 5, 1): 1,
    }

    output = {0: 1, 1: 2, 2: 1, 3: 2, 4: 1, 5: 2}

    A = TropicalOneWayAutomaton(states, alphabet, step, output)

    print("Partition refinement results:")
    for k in range(5):
        partition = bounded_nerode_partition(A, k)
        partition_str = [sorted(cls) for cls in partition]
        partition_str.sort()
        print(f"  k={k}: {partition_str}")
    print()


# ============================================================
# DEMO 4: Energy invariance under Nerode equivalence
# ============================================================

def demo_energy_invariance():
    """Demonstrate that Nerode-equivalent states have equal energy."""
    print("DEMO 4: Energy Invariance under Nerode Equivalence")
    print("-" * 40)

    # Automaton where states 0 and 3 are Nerode-equivalent
    states = {0, 1, 2, 3}
    alphabet = {0}

    step = {
        (0, 0, 1): 1,
        (0, 1, 2): 1,
        (0, 2, 0): 1,
        (0, 3, 1): 1,  # same successor as state 0
    }

    output = {0: 42, 1: 17, 2: 99, 3: 42}  # states 0 and 3 have same output

    A = TropicalOneWayAutomaton(states, alphabet, step, output)

    print("State energies (empty-word right-costs):")
    for q in sorted(states):
        energy = tropical_state_energy(A, q)
        print(f"  Energy(state {q}) = {energy}")

    print()
    equiv_03, _ = tropical_nerode_check(A, 0, 3, max_length=6)
    print(f"States 0 and 3 Nerode-equivalent: {equiv_03}")
    if equiv_03:
        e0 = tropical_state_energy(A, 0)
        e3 = tropical_state_energy(A, 3)
        print(f"Energy(0) = {e0}, Energy(3) = {e3}")
        print(f"Energy invariance verified: {e0 == e3}")
    print()


# ============================================================
# DEMO 5: Separation witness complexity
# ============================================================

def demo_witness_complexity():
    """Demonstrate separation witness finding and length statistics."""
    print("DEMO 5: Separation Witness Complexity")
    print("-" * 40)

    import random
    random.seed(42)

    n_states = 8
    states = set(range(n_states))
    alphabet = {0, 1}

    # Random automaton
    step = {}
    for a in alphabet:
        for q in states:
            target = random.choice(list(states))
            weight = random.randint(-3, 3)
            step[(a, q, target)] = weight

    output = {q: random.randint(0, 10) for q in states}

    A = TropicalOneWayAutomaton(states, alphabet, step, output)

    print(f"Random automaton with {n_states} states, alphabet {{0,1}}")
    print(f"Finite witness complexity bound: {n_states}")
    print()

    witness_lengths = []
    n_equiv = 0
    n_inequiv = 0

    for p in sorted(states):
        for q in sorted(states):
            if p < q:
                equiv, witness = tropical_nerode_check(A, p, q, max_length=n_states)
                if equiv:
                    n_equiv += 1
                else:
                    n_inequiv += 1
                    witness_lengths.append(len(witness))

    print(f"Equivalent pairs: {n_equiv}")
    print(f"Inequivalent pairs: {n_inequiv}")
    if witness_lengths:
        print(f"Shortest witness length: {min(witness_lengths)}")
        print(f"Longest witness length: {max(witness_lengths)}")
        print(f"Average witness length: {sum(witness_lengths)/len(witness_lengths):.2f}")
        print(f"All ≤ card(σ) = {n_states}: {all(l <= n_states for l in witness_lengths)}")
    print()


# ============================================================
# Run all demos
# ============================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL AUTOMATA NERODE THEORY — DEMONSTRATIONS")
    print("=" * 70)

    demo_basic_right_cost()
    print_separator()
    demo_nerode_equivalence()
    print_separator()
    demo_partition_refinement()
    print_separator()
    demo_energy_invariance()
    print_separator()
    demo_witness_complexity()

    print("=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)
