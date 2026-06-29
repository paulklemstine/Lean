"""
Algorithms for Tropical Automata Minimization via Nerode Partition Refinement.

Implements the partition refinement algorithm for computing the Nerode quotient
of a deterministic tropical (min-plus) automaton, as formalized in Lean 4.
"""

from typing import Dict, List, Optional, Tuple, Set, FrozenSet
from dataclasses import dataclass
import math

INF = float('inf')


@dataclass
class DetTropicalAutomaton:
    """A deterministic tropical (min-plus) automaton.

    Attributes:
        states: Set of state labels.
        alphabet: Set of alphabet symbols.
        step: Transition function (state, symbol) -> state.
        out: Output/cost function state -> cost (float, with inf for ⊤).
        init: Optional initial state for language recognition.
    """
    states: List[str]
    alphabet: List[str]
    step: Dict[Tuple[str, str], str]
    out: Dict[str, float]
    init: Optional[str] = None

    def eval_from(self, q: str, word: List[str]) -> str:
        """Process a word from a given state, returning the final state."""
        current = q
        for a in word:
            current = self.step[(current, a)]
        return current

    def state_residual(self, q: str, word: List[str]) -> float:
        """Compute the residual cost of a word from state q."""
        return self.out[self.eval_from(q, word)]

    def language(self, word: List[str]) -> float:
        """Compute the cost assigned to a word by the automaton (requires init)."""
        if self.init is None:
            raise ValueError("No initial state defined")
        return self.state_residual(self.init, word)


def depth_eq(A: DetTropicalAutomaton, n: int, q: str, r: str) -> bool:
    """Check if states q and r are depth-n equivalent.

    Two states are depth-0 equivalent if they have the same output.
    They are depth-(n+1) equivalent if they have the same output and
    all their successors are depth-n equivalent.

    Args:
        A: The automaton.
        n: Depth level.
        q, r: States to compare.

    Returns:
        True if q and r are depth-n equivalent.
    """
    if n == 0:
        return A.out[q] == A.out[r]
    else:
        if A.out[q] != A.out[r]:
            return False
        return all(
            depth_eq(A, n - 1, A.step[(q, a)], A.step[(r, a)])
            for a in A.alphabet
        )


def compute_depth_partition(A: DetTropicalAutomaton, n: int) -> Dict[str, int]:
    """Compute the partition of states into depth-n equivalence classes.

    Args:
        A: The automaton.
        n: Depth level.

    Returns:
        Dictionary mapping each state to its class index.
    """
    classes: Dict[str, int] = {}
    class_reps: List[str] = []

    for q in A.states:
        found = False
        for idx, rep in enumerate(class_reps):
            if depth_eq(A, n, q, rep):
                classes[q] = idx
                found = True
                break
        if not found:
            classes[q] = len(class_reps)
            class_reps.append(q)

    return classes


def partition_refinement(A: DetTropicalAutomaton) -> Tuple[Dict[str, int], int, int]:
    """Compute the Nerode partition via iterative partition refinement.

    Starting from the depth-0 partition (by output values), iteratively refine
    until stabilization. Returns the final partition, the Nerode index, and
    the number of refinement steps.

    Args:
        A: The automaton.

    Returns:
        Tuple of (partition dict, nerode_index, num_steps).

    Complexity:
        At most |Q| refinement steps, each taking O(|Q|^2 * |Σ|) comparisons.
        Total: O(|Q|^3 * |Σ|).
    """
    n = len(A.states)

    # Compute initial partition (depth 0)
    prev_partition = compute_depth_partition(A, 0)
    prev_num_classes = len(set(prev_partition.values()))

    steps = 0
    for depth in range(1, n + 1):
        # Compute signature: (output, tuple of successor class indices)
        signatures: Dict[str, Tuple] = {}
        for q in A.states:
            sig = (A.out[q],) + tuple(
                prev_partition[A.step[(q, a)]] for a in A.alphabet
            )
            signatures[q] = sig

        # Build new partition from signatures
        sig_to_class: Dict[Tuple, int] = {}
        new_partition: Dict[str, int] = {}
        class_idx = 0
        for q in A.states:
            sig = signatures[q]
            if sig not in sig_to_class:
                sig_to_class[sig] = class_idx
                class_idx += 1
            new_partition[q] = sig_to_class[sig]

        new_num_classes = class_idx
        steps += 1

        if new_num_classes == prev_num_classes:
            # Stabilized
            break

        prev_partition = new_partition
        prev_num_classes = new_num_classes

    nerode_index = prev_num_classes
    return prev_partition, nerode_index, steps


def build_quotient_automaton(
    A: DetTropicalAutomaton,
    partition: Dict[str, int],
    nerode_index: int
) -> DetTropicalAutomaton:
    """Build the minimal quotient automaton from a Nerode partition.

    Args:
        A: The original automaton.
        partition: The Nerode partition (state -> class index).
        nerode_index: Number of equivalence classes.

    Returns:
        The minimal quotient automaton.
    """
    # Find representative for each class
    class_reps: Dict[int, str] = {}
    for q in A.states:
        c = partition[q]
        if c not in class_reps:
            class_reps[c] = q

    # Build quotient states
    q_states = [f"q{i}" for i in range(nerode_index)]

    # Build transition function
    q_step: Dict[Tuple[str, str], str] = {}
    for i in range(nerode_index):
        rep = class_reps[i]
        for a in A.alphabet:
            target = A.step[(rep, a)]
            q_step[(f"q{i}", a)] = f"q{partition[target]}"

    # Build output function
    q_out: Dict[str, float] = {}
    for i in range(nerode_index):
        q_out[f"q{i}"] = A.out[class_reps[i]]

    # Build initial state (if present)
    q_init = None
    if A.init is not None:
        q_init = f"q{partition[A.init]}"

    return DetTropicalAutomaton(
        states=q_states,
        alphabet=A.alphabet,
        step=q_step,
        out=q_out,
        init=q_init
    )


def verify_equivalence(
    A: DetTropicalAutomaton,
    B: DetTropicalAutomaton,
    max_word_length: int = 6
) -> bool:
    """Verify two automata with initial states recognize the same language.

    Tests all words up to a given length.

    Args:
        A, B: Automata to compare.
        max_word_length: Maximum word length to test.

    Returns:
        True if the automata agree on all tested words.
    """
    if A.init is None or B.init is None:
        raise ValueError("Both automata must have initial states")

    def all_words(alphabet, max_len):
        if max_len == 0:
            yield []
            return
        yield []
        for length in range(1, max_len + 1):
            def gen(prefix, remaining):
                if remaining == 0:
                    yield prefix[:]
                    return
                for a in alphabet:
                    prefix.append(a)
                    yield from gen(prefix, remaining - 1)
                    prefix.pop()
            yield from gen([], length)

    for word in all_words(A.alphabet, max_word_length):
        cost_a = A.language(word)
        cost_b = B.language(word)
        if cost_a != cost_b:
            return False
    return True


# --- Example Automata ---

def example_shortest_path_automaton() -> DetTropicalAutomaton:
    """A 4-state automaton modeling shortest path costs in a small network.

    States represent network nodes. Transitions encode edge costs.
    Output function gives the cost to reach the destination from each node.
    """
    states = ["A", "B", "C", "D"]
    alphabet = ["x", "y"]
    step = {
        ("A", "x"): "B", ("A", "y"): "C",
        ("B", "x"): "D", ("B", "y"): "A",
        ("C", "x"): "A", ("C", "y"): "D",
        ("D", "x"): "C", ("D", "y"): "B",
    }
    out = {"A": 0, "B": 3, "C": 3, "D": 5}
    return DetTropicalAutomaton(states, alphabet, step, out, init="A")


def example_redundant_automaton() -> DetTropicalAutomaton:
    """A 6-state automaton with redundant states that can be minimized.

    States q0, q1 are equivalent. States q2, q3 are equivalent.
    The minimal automaton should have 4 states.
    """
    states = ["q0", "q1", "q2", "q3", "q4", "q5"]
    alphabet = ["a", "b"]
    step = {
        ("q0", "a"): "q2", ("q0", "b"): "q4",
        ("q1", "a"): "q3", ("q1", "b"): "q4",
        ("q2", "a"): "q4", ("q2", "b"): "q5",
        ("q3", "a"): "q4", ("q3", "b"): "q5",
        ("q4", "a"): "q4", ("q4", "b"): "q4",
        ("q5", "a"): "q5", ("q5", "b"): "q5",
    }
    out = {"q0": 0, "q1": 0, "q2": 2, "q3": 2, "q4": 7, "q5": 1}
    return DetTropicalAutomaton(states, alphabet, step, out, init="q0")


def example_already_minimal() -> DetTropicalAutomaton:
    """A 3-state automaton that is already minimal."""
    states = ["s0", "s1", "s2"]
    alphabet = ["0", "1"]
    step = {
        ("s0", "0"): "s1", ("s0", "1"): "s2",
        ("s1", "0"): "s0", ("s1", "1"): "s2",
        ("s2", "0"): "s2", ("s2", "1"): "s0",
    }
    out = {"s0": 0, "s1": 1, "s2": INF}
    return DetTropicalAutomaton(states, alphabet, step, out, init="s0")


if __name__ == "__main__":
    print("=" * 60)
    print("TROPICAL AUTOMATA MINIMIZATION DEMO")
    print("=" * 60)

    # Example 1: Redundant automaton
    print("\n--- Example 1: Redundant Automaton ---")
    A = example_redundant_automaton()
    print(f"Original states: {A.states}")
    print(f"Alphabet: {A.alphabet}")
    print(f"Outputs: {A.out}")

    partition, index, steps = partition_refinement(A)
    print(f"\nNerode partition: {partition}")
    print(f"Nerode index: {index}")
    print(f"Refinement steps: {steps}")
    print(f"State count: {len(A.states)} → {index}")

    B = build_quotient_automaton(A, partition, index)
    print(f"\nMinimal automaton states: {B.states}")
    print(f"Minimal automaton outputs: {B.out}")

    equiv = verify_equivalence(A, B)
    print(f"Equivalence verified: {equiv}")

    # Example 2: Already minimal
    print("\n--- Example 2: Already Minimal Automaton ---")
    A2 = example_already_minimal()
    partition2, index2, steps2 = partition_refinement(A2)
    print(f"Original states: {len(A2.states)}")
    print(f"Nerode index: {index2}")
    print(f"Refinement steps: {steps2}")
    print(f"Already minimal: {index2 == len(A2.states)}")

    # Example 3: Shortest path
    print("\n--- Example 3: Shortest Path Automaton ---")
    A3 = example_shortest_path_automaton()
    partition3, index3, steps3 = partition_refinement(A3)
    print(f"Original states: {len(A3.states)}")
    print(f"Nerode index: {index3}")
    print(f"Refinement steps: {steps3}")

    # Show convergence of partition refinement
    print("\n--- Partition Refinement Convergence ---")
    A = example_redundant_automaton()
    for depth in range(len(A.states) + 1):
        p = compute_depth_partition(A, depth)
        num_classes = len(set(p.values()))
        classes = {}
        for q, c in p.items():
            classes.setdefault(c, []).append(q)
        print(f"  Depth {depth}: {num_classes} classes = {list(classes.values())}")
