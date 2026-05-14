#!/usr/bin/env python3
"""
Applications of the Tropical Myhill–Nerode Theorem

Demonstrates real-world applications of tropical automata theory:
1. Shortest-path optimization in networks
2. Dynamic programming state compression
3. Cost-aware protocol verification
4. Resource-bounded computation analysis
"""

from __future__ import annotations
from typing import Callable, Dict, List, Optional, Tuple, Set
from dataclasses import dataclass
from collections import defaultdict
import random

Cost = Optional[int]
Word = tuple


# ===========================================================================
# Application 1: Network Shortest Paths
# ===========================================================================

@dataclass
class WeightedGraph:
    """A directed weighted graph for shortest-path computation."""
    nodes: List[str]
    edges: Dict[Tuple[str, str], int]  # (from, to) -> weight

    def shortest_path_cost(self, source: str, target: str,
                            path: List[str] = None) -> Cost:
        """Compute shortest path cost via Bellman-Ford."""
        n = len(self.nodes)
        dist = {node: None for node in self.nodes}
        dist[source] = 0

        for _ in range(n - 1):
            for (u, v), w in self.edges.items():
                if dist[u] is not None:
                    new_dist = dist[u] + w
                    if dist[v] is None or new_dist < dist[v]:
                        dist[v] = new_dist

        return dist.get(target)


def network_routing_demo():
    """
    Application: Network routing as a tropical weighted language.

    A sequence of routing decisions (left/right/straight at intersections)
    defines a path through a network. The cost is the total travel time.
    The tropical Myhill–Nerode theorem tells us the minimum number of
    "routing states" needed to optimally route packets.
    """
    print("=" * 60)
    print("APPLICATION 1: Network Routing Optimization")
    print("=" * 60)

    # A simple network: 4 intersections with different travel times
    graph = WeightedGraph(
        nodes=['A', 'B', 'C', 'D'],
        edges={
            ('A', 'B'): 3, ('A', 'C'): 7,
            ('B', 'C'): 2, ('B', 'D'): 5,
            ('C', 'D'): 1,
            ('D', 'A'): 4,
        }
    )

    # Define a weighted language: L(route) = cost of the route from A
    # Route symbols: 'n' = next node in order, 's' = skip to further node
    route_map = {
        ('A', 'n'): ('B', 3), ('A', 's'): ('C', 7),
        ('B', 'n'): ('C', 2), ('B', 's'): ('D', 5),
        ('C', 'n'): ('D', 1), ('C', 's'): ('D', 1),
        ('D', 'n'): ('A', 4), ('D', 's'): ('A', 4),
    }

    def route_cost(word: Word) -> Cost:
        """Cost of a routing sequence starting from A."""
        state = 'A'
        total = 0
        for action in word:
            key = (state, action)
            if key not in route_map:
                return None  # invalid route
            state, cost = route_map[key]
            total += cost
        return total

    print("\nSample routing costs from node A:")
    for route in [(), ('n',), ('s',), ('n', 'n'), ('n', 's'),
                   ('s', 'n'), ('n', 'n', 'n')]:
        cost = route_cost(route)
        route_str = '→'.join(route) if route else 'ε (stay)'
        print(f"  Route [{route_str}]: cost = {cost if cost is not None else '∞'}")

    # Find Nerode classes
    from algorithms import discover_nerode_classes
    classes = discover_nerode_classes(route_cost, ['n', 's'],
                                      max_prefix_len=3, max_suffix_len=3)
    print(f"\nNerode equivalence classes: {len(classes)}")
    print("→ This is the minimum number of routing states needed!")
    print("  Any router tracking fewer states cannot compute optimal costs.")


# ===========================================================================
# Application 2: Dynamic Programming Compression
# ===========================================================================

def dp_compression_demo():
    """
    Application: State-space compression in dynamic programming.

    The tropical Myhill–Nerode theorem provides a rigorous lower bound
    on the number of states needed in any DP formulation. This is the
    "cost-to-go" compression theorem.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 2: Dynamic Programming State Compression")
    print("=" * 60)

    # Consider a manufacturing process with operations a, b
    # Cost depends on the sequence of operations performed
    operation_costs = {
        'a': 2,  # operation a costs 2
        'b': 3,  # operation b costs 3
    }

    # Setup cost depends on transition between operations
    setup_costs = {
        ('a', 'a'): 0,  # same operation, no setup
        ('a', 'b'): 5,  # switching from a to b
        ('b', 'a'): 4,  # switching from b to a
        ('b', 'b'): 0,  # same operation
    }

    def manufacturing_cost(word: Word) -> Cost:
        """Total manufacturing cost including setup transitions."""
        if not word:
            return 0
        total = operation_costs.get(word[0], 0)
        for i in range(1, len(word)):
            key = (word[i-1], word[i])
            total += setup_costs.get(key, 0) + operation_costs.get(word[i], 0)
        return total

    print("\nManufacturing cost analysis:")
    sequences = [
        (), ('a',), ('b',), ('a', 'a'), ('a', 'b'),
        ('b', 'a'), ('b', 'b'), ('a', 'b', 'a'), ('a', 'a', 'a'),
    ]
    for seq in sequences:
        cost = manufacturing_cost(seq)
        seq_str = '→'.join(seq) if seq else 'ε (idle)'
        print(f"  Sequence [{seq_str}]: cost = {cost}")

    from algorithms import discover_nerode_classes
    classes = discover_nerode_classes(manufacturing_cost, ['a', 'b'],
                                      max_prefix_len=3, max_suffix_len=3)
    print(f"\nNerode classes: {len(classes)}")
    print("→ Minimum DP state space size for this cost structure!")
    print("  No DP formulation can use fewer states and remain correct.")


# ===========================================================================
# Application 3: Cost-Aware Protocol Verification
# ===========================================================================

def protocol_verification_demo():
    """
    Application: Verifying cost bounds in communication protocols.

    Model a protocol as a tropical automaton where the cost represents
    resource consumption (time, bandwidth, energy). The Nerode automaton
    gives the minimal monitor needed to track costs.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 3: Protocol Cost Verification")
    print("=" * 60)

    # Protocol actions: s=send, r=receive
    # Each action has a cost; sending costs more bandwidth
    action_costs = {'s': 10, 'r': 2}

    # Protocol states: idle, active
    protocol_transitions = {
        ('idle', 's'): 'active',
        ('idle', 'r'): 'idle',
        ('active', 's'): 'active',
        ('active', 'r'): 'idle',
    }

    def protocol_cost(word: Word) -> Cost:
        """Total protocol execution cost."""
        state = 'idle'
        total = 0
        for action in word:
            key = (state, action)
            if key not in protocol_transitions:
                return None
            total += action_costs.get(action, 0)
            state = protocol_transitions[key]
        return total

    print("\nProtocol cost examples:")
    traces = [
        (), ('s',), ('r',),
        ('s', 'r'), ('s', 's'), ('r', 's'),
        ('s', 'r', 's', 'r'),
    ]
    for trace in traces:
        cost = protocol_cost(trace)
        trace_str = '→'.join(trace) if trace else 'ε (start)'
        print(f"  Trace [{trace_str}]: cost = {cost if cost is not None else '∞'}")

    from algorithms import (discover_nerode_classes,
                              build_nerode_automaton, enumerate_words)

    classes = discover_nerode_classes(protocol_cost, ['s', 'r'],
                                      max_prefix_len=3, max_suffix_len=3)
    print(f"\nNerode classes: {len(classes)}")
    print("→ Minimum monitor states for cost tracking!")

    # Build minimal monitor
    monitor = build_nerode_automaton(protocol_cost, ['s', 'r'],
                                      max_prefix_len=3, max_suffix_len=3)
    print(f"   Minimal monitor states: {len(monitor.states)}")

    # Verify
    test_words = enumerate_words(['s', 'r'], 3)
    correct = all(monitor.evaluate(w) == protocol_cost(w) for w in test_words)
    print(f"   Monitor correctness: {correct}")


# ===========================================================================
# Application 4: Resource-Bounded Computation
# ===========================================================================

def resource_bounded_demo():
    """
    Application: Analyzing resource consumption in computation.

    A program's resource usage (time, memory, energy) over a sequence
    of operations forms a tropical weighted language. The Nerode quotient
    identifies the minimum state needed to track resource consumption.
    """
    print("\n" + "=" * 60)
    print("APPLICATION 4: Resource-Bounded Computation")
    print("=" * 60)

    # Operations: 'c' = compute (uses CPU), 'm' = memory alloc
    # Resource = total resource units consumed
    def resource_cost(word: Word) -> Cost:
        """Total resource units consumed."""
        total = 0
        for op in word:
            if op == 'c':
                total += 3
            elif op == 'm':
                total += 5
        return total

    print("\nResource consumption analysis:")
    sequences = [
        (), ('c',), ('m',),
        ('c', 'c'), ('c', 'm'), ('m', 'c'),
        ('m', 'm'), ('c', 'c', 'c'),
    ]
    for seq in sequences:
        cost = resource_cost(seq)
        seq_str = '→'.join(seq) if seq else 'ε (idle)'
        print(f"  Ops [{seq_str}]: resource cost = {cost}")

    from algorithms import discover_nerode_classes
    classes = discover_nerode_classes(resource_cost, ['c', 'm'],
                                      max_prefix_len=3, max_suffix_len=3)
    print(f"\nNerode classes: {len(classes)}")
    print("→ Minimum tracking states for resource monitoring!")
    print("  This bounds the complexity of any correct resource monitor.")


# ===========================================================================
# Main
# ===========================================================================

if __name__ == '__main__':
    network_routing_demo()
    dp_compression_demo()
    protocol_verification_demo()
    resource_bounded_demo()

    print("\n" + "=" * 60)
    print("All applications demonstrated successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Tropical Myhill–Nerode Theorem: Concrete Demonstrations

This module demonstrates the core concepts of the tropical Myhill–Nerode
theorem with concrete examples of min-plus weighted languages, residuals,
Nerode equivalence classes, and canonical automaton construction.
"""

from __future__ import annotations
from typing import Callable, Dict, List, Optional, Set, Tuple
from dataclasses import dataclass, field
import math

# Type alias: a weighted language maps words to costs (None = infinity/⊤)
Cost = Optional[int]
Word = tuple  # tuple of symbols


def min_plus(a: Cost, b: Cost) -> Cost:
    """Tropical addition: min of two costs (None = ∞)."""
    if a is None:
        return b
    if b is None:
        return a
    return min(a, b)


def plus(a: Cost, b: Cost) -> Cost:
    """Tropical multiplication: sum of two costs (None = ∞)."""
    if a is None or b is None:
        return None
    return a + b


# ===========================================================================
# Example 1: Shortest-path language (number of 'a's in a word)
# ===========================================================================

def count_a_language(word: Word) -> Cost:
    """L(w) = number of 'a' symbols in w. Cost is always finite."""
    return sum(1 for c in word if c == 'a')


def residual(L: Callable[[Word], Cost], prefix: Word) -> Callable[[Word], Cost]:
    """Compute the right residual: (residual L u)(v) = L(u ++ v)."""
    return lambda v: L(prefix + v)


def words_up_to(alphabet: list, max_len: int) -> List[Word]:
    """Generate all words up to a given length."""
    result = [()]
    for length in range(1, max_len + 1):
        for w in list(result):
            if len(w) == length - 1:
                for a in alphabet:
                    result.append(w + (a,))
    return result


def residual_signature(L: Callable[[Word], Cost], prefix: Word,
                        test_words: List[Word]) -> Tuple[Cost, ...]:
    """Compute a finite signature of a residual for comparison."""
    r = residual(L, prefix)
    return tuple(r(w) for w in test_words)


def find_nerode_classes(L: Callable[[Word], Cost], alphabet: list,
                         max_prefix_len: int = 4,
                         max_test_len: int = 4) -> Dict[tuple, List[Word]]:
    """Find Nerode equivalence classes by computing residual signatures."""
    test_words = words_up_to(alphabet, max_test_len)
    prefixes = words_up_to(alphabet, max_prefix_len)

    classes: Dict[tuple, List[Word]] = {}
    for prefix in prefixes:
        sig = residual_signature(L, prefix, test_words)
        if sig not in classes:
            classes[sig] = []
        classes[sig].append(prefix)

    return classes


# ===========================================================================
# Example 2: Tropical DFA and evaluation
# ===========================================================================

@dataclass
class TropicalDFA:
    """A deterministic tropical (min-plus) finite automaton."""
    states: List[str]
    alphabet: list
    transitions: Dict[Tuple[str, any], str]  # (state, symbol) -> state
    initial: str
    output: Dict[str, Cost]  # state -> output cost

    def eval_state(self, state: str, word: Word) -> str:
        """Process a word from a given state."""
        for symbol in word:
            state = self.transitions[(state, symbol)]
        return state

    def eval_cost(self, word: Word) -> Cost:
        """Compute the cost of a word."""
        final_state = self.eval_state(self.initial, word)
        return self.output[final_state]

    def recognizes(self, L: Callable[[Word], Cost],
                    test_words: List[Word]) -> bool:
        """Check if the automaton recognizes L on given test words."""
        return all(self.eval_cost(w) == L(w) for w in test_words)


def build_nerode_automaton(L: Callable[[Word], Cost], alphabet: list,
                            max_prefix_len: int = 4,
                            max_test_len: int = 4) -> TropicalDFA:
    """Construct the canonical Nerode automaton for L.

    States are residual equivalence classes.
    Transitions append letters.
    Output is the residual evaluated at the empty word.
    """
    test_words = words_up_to(alphabet, max_test_len)
    prefixes = words_up_to(alphabet, max_prefix_len)

    # Map each prefix to its residual signature
    sig_map: Dict[Word, tuple] = {}
    for prefix in prefixes:
        sig_map[prefix] = residual_signature(L, prefix, test_words)

    # Collect unique signatures as states
    unique_sigs = list(set(sig_map.values()))
    state_names = {sig: f"q{i}" for i, sig in enumerate(unique_sigs)}

    # Build transitions
    transitions = {}
    for sig in unique_sigs:
        # Find a representative prefix for this signature
        rep = next(p for p in prefixes if sig_map[p] == sig)
        for a in alphabet:
            extended = rep + (a,)
            if extended in sig_map:
                next_sig = sig_map[extended]
                transitions[(state_names[sig], a)] = state_names[next_sig]

    # Initial state: residual at empty word
    initial_sig = sig_map[()]
    initial_state = state_names[initial_sig]

    # Output: residual evaluated at empty word = L(prefix) for any representative
    output = {}
    for sig in unique_sigs:
        rep = next(p for p in prefixes if sig_map[p] == sig)
        output[state_names[sig]] = L(rep)

    return TropicalDFA(
        states=list(state_names.values()),
        alphabet=alphabet,
        transitions=transitions,
        initial=initial_state,
        output=output
    )


# ===========================================================================
# Example 3: Mod-3 cost language (counterexample for idempotence)
# ===========================================================================

def mod3_language(word: Word) -> Cost:
    """L(w) = (number of 'a's) mod 3, or None if no 'a's."""
    count = sum(1 for c in word if c == 'a')
    if count == 0:
        return None  # ⊤
    return count % 3


# ===========================================================================
# Main demonstration
# ===========================================================================

def demonstrate_example_1():
    """Demonstrate the count-a language."""
    print("=" * 70)
    print("EXAMPLE 1: Count-a Language")
    print("L(w) = number of 'a' symbols in w")
    print("=" * 70)

    alphabet = ['a', 'b']
    L = count_a_language

    # Show some language values
    test_words = words_up_to(alphabet, 3)
    print("\nLanguage values:")
    for w in test_words[:15]:
        word_str = ''.join(w) if w else 'ε'
        print(f"  L({word_str}) = {L(w)}")

    # Find Nerode classes
    classes = find_nerode_classes(L, alphabet, max_prefix_len=3, max_test_len=3)
    print(f"\nNumber of Nerode equivalence classes: {len(classes)}")
    print("(This language has infinitely many classes in principle,")
    print(" but we see finitely many within our test horizon.)")

    for i, (sig, members) in enumerate(list(classes.items())[:5]):
        reps = [''.join(m) if m else 'ε' for m in members[:5]]
        print(f"  Class {i}: {reps}{'...' if len(members) > 5 else ''}")

    # Build Nerode automaton
    automaton = build_nerode_automaton(L, alphabet,
                                        max_prefix_len=3, max_test_len=3)
    print(f"\nNerode automaton has {len(automaton.states)} states")
    print(f"  States: {automaton.states}")
    print(f"  Initial: {automaton.initial}")

    # Verify correctness
    verify_words = words_up_to(alphabet, 3)
    correct = automaton.recognizes(L, verify_words)
    print(f"  Correctly recognizes L on words up to length 3: {correct}")


def demonstrate_example_2():
    """Demonstrate a finite-state tropical language."""
    print("\n" + "=" * 70)
    print("EXAMPLE 2: Shortest-Path Language")
    print("A 2-state min-plus automaton computing min edit distance")
    print("=" * 70)

    # Define a simple 2-state tropical DFA
    dfa = TropicalDFA(
        states=['s0', 's1'],
        alphabet=['a', 'b'],
        transitions={
            ('s0', 'a'): 's1', ('s0', 'b'): 's0',
            ('s1', 'a'): 's0', ('s1', 'b'): 's1',
        },
        initial='s0',
        output={'s0': 0, 's1': 1}
    )

    # The language this recognizes
    def dfa_language(w: Word) -> Cost:
        return dfa.eval_cost(w)

    print("\nDFA output on words:")
    test_words = words_up_to(['a', 'b'], 4)
    for w in test_words[:20]:
        word_str = ''.join(w) if w else 'ε'
        print(f"  L({word_str}) = {dfa_language(w)}")

    # Find Nerode classes
    classes = find_nerode_classes(dfa_language, ['a', 'b'],
                                  max_prefix_len=4, max_test_len=4)
    print(f"\nNumber of Nerode classes: {len(classes)}")
    print(f"Number of DFA states: {len(dfa.states)}")
    print("→ Nerode classes ≤ DFA states (minimality theorem!)")

    # Build canonical automaton
    nerode_dfa = build_nerode_automaton(dfa_language, ['a', 'b'],
                                         max_prefix_len=4, max_test_len=4)
    print(f"\nNerode automaton states: {len(nerode_dfa.states)}")

    # Verify
    correct = nerode_dfa.recognizes(dfa_language, test_words)
    print(f"Nerode automaton correct: {correct}")


def demonstrate_example_3():
    """Demonstrate the counterexample for idempotence."""
    print("\n" + "=" * 70)
    print("EXAMPLE 3: Non-Idempotent Syntactic Action")
    print("L(w) = (#a mod 3) if #a > 0, else ⊤")
    print("=" * 70)

    alphabet = ['a', 'b']
    L = mod3_language

    print("\nLanguage values:")
    test_words = words_up_to(alphabet, 4)
    for w in test_words[:20]:
        word_str = ''.join(w) if w else 'ε'
        val = L(w)
        print(f"  L({word_str}) = {val if val is not None else '⊤'}")

    # Find Nerode classes
    classes = find_nerode_classes(L, alphabet, max_prefix_len=4, max_test_len=4)
    print(f"\nNumber of Nerode classes: {len(classes)}")

    # Show that the 'a' action is not idempotent
    print("\nAction of letter 'a' on residual classes:")
    print("  The letter 'a' shifts #a count by 1 mod 3.")
    print("  This is a cyclic permutation, NOT idempotent:")
    print("  If f = action of 'a', then f(class_k) = class_{k+1 mod 3}")
    print("  But f∘f(class_k) = class_{k+2 mod 3} ≠ f(class_k)")
    print("  → f∘f ≠ f, so f is not idempotent!")
    print("\n  This refutes the claim that syntactic monoid elements")
    print("  are always idempotent in tropical automata theory.")


def demonstrate_minimality():
    """Demonstrate the minimality theorem with a concrete redundant automaton."""
    print("\n" + "=" * 70)
    print("EXAMPLE 4: Minimality Theorem in Action")
    print("A 4-state DFA with only 2 Nerode classes")
    print("=" * 70)

    # A redundant 4-state DFA (states s0,s2 equivalent, s1,s3 equivalent)
    dfa = TropicalDFA(
        states=['s0', 's1', 's2', 's3'],
        alphabet=['a', 'b'],
        transitions={
            ('s0', 'a'): 's1', ('s0', 'b'): 's2',
            ('s1', 'a'): 's0', ('s1', 'b'): 's3',
            ('s2', 'a'): 's3', ('s2', 'b'): 's0',
            ('s3', 'a'): 's2', ('s3', 'b'): 's1',
        },
        initial='s0',
        output={'s0': 0, 's1': 1, 's2': 0, 's3': 1}
    )

    def dfa_language(w: Word) -> Cost:
        return dfa.eval_cost(w)

    test_words = words_up_to(['a', 'b'], 5)
    classes = find_nerode_classes(dfa_language, ['a', 'b'],
                                  max_prefix_len=5, max_test_len=5)

    print(f"\n  Original DFA states: {len(dfa.states)}")
    print(f"  Nerode classes: {len(classes)}")
    print(f"  → {len(classes)} ≤ {len(dfa.states)} (minimality theorem)")

    nerode_dfa = build_nerode_automaton(dfa_language, ['a', 'b'],
                                         max_prefix_len=5, max_test_len=5)
    print(f"  Nerode automaton states: {len(nerode_dfa.states)}")
    print(f"  → Minimal automaton found!")

    correct = nerode_dfa.recognizes(dfa_language, test_words)
    print(f"  Correctness verified: {correct}")


if __name__ == '__main__':
    demonstrate_example_1()
    demonstrate_example_2()
    demonstrate_example_3()
    demonstrate_minimality()
    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("=" * 70)


#!/usr/bin/env python3
"""
Visualizations for the Tropical Myhill–Nerode Theorem.

Generates publication-quality figures illustrating:
1. Nerode equivalence classes as a partition of the word space
2. Residual function landscapes
3. Minimality comparison between automata
4. Syntactic monoid structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import defaultdict
import base64
import io

# Import our algorithms
from algorithms import (enumerate_words, discover_nerode_classes,
                          compute_residual, TropicalDFA,
                          compute_syntactic_monoid, minimize_automaton)


def fig_to_base64(fig) -> str:
    """Convert matplotlib figure to base64 PNG data URI."""
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight',
                facecolor='white', edgecolor='none')
    buf.seek(0)
    encoded = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return f"data:image/png;base64,{encoded}"


# ===========================================================================
# Figure 1: Nerode Equivalence Classes
# ===========================================================================

def visualize_nerode_classes():
    """Visualize Nerode equivalence classes as colored word partitions."""

    def parity_cost(w):
        return sum(1 for c in w if c == 'a') % 2

    classes = discover_nerode_classes(parity_cost, ['a', 'b'], 3, 3)

    fig, ax = plt.subplots(1, 1, figsize=(12, 6))

    # Sort classes by their representative's cost
    sorted_classes = sorted(classes.items(),
                             key=lambda x: parity_cost(x[1][0]))

    colors = plt.cm.Set2(np.linspace(0, 1, len(sorted_classes)))

    y_offset = 0
    legend_patches = []
    for i, (sig, members) in enumerate(sorted_classes):
        # Show first few members
        display_members = sorted(members, key=len)[:8]
        for j, word in enumerate(display_members):
            word_str = ''.join(word) if word else 'ε'
            ax.text(j * 1.5 + 0.5, -y_offset, word_str,
                    ha='center', va='center', fontsize=10,
                    bbox=dict(boxstyle='round,pad=0.3',
                             facecolor=colors[i], alpha=0.7))

        cost = parity_cost(members[0])
        label = f"Class {i}: L(rep) = {cost}"
        if len(members) > 8:
            label += f" ({len(members)} words)"
        legend_patches.append(mpatches.Patch(color=colors[i], label=label))
        y_offset += 1.2

    ax.set_xlim(-0.5, 12)
    ax.set_ylim(-y_offset, 1)
    ax.set_title('Nerode Equivalence Classes\n(Parity Cost Language)',
                 fontsize=14, fontweight='bold')
    ax.legend(handles=legend_patches, loc='upper right', fontsize=9)
    ax.axis('off')

    return fig


# ===========================================================================
# Figure 2: Residual Function Landscape
# ===========================================================================

def visualize_residual_landscape():
    """Visualize how residuals change as we extend prefixes."""

    def step_cost(w):
        """Cost = sum of position-weighted symbols."""
        return sum((i + 1) * (1 if c == 'a' else 2) for i, c in enumerate(w))

    alphabet = ['a', 'b']
    suffixes = enumerate_words(alphabet, 3)
    suffix_labels = [''.join(s) if s else 'ε' for s in suffixes[:16]]

    prefixes = [(), ('a',), ('b',), ('a', 'a'), ('a', 'b'),
                ('b', 'a'), ('b', 'b')]
    prefix_labels = [''.join(p) if p else 'ε' for p in prefixes]

    # Build residual matrix
    matrix = np.zeros((len(prefixes), len(suffixes[:16])))
    for i, p in enumerate(prefixes):
        for j, s in enumerate(suffixes[:16]):
            val = step_cost(p + s)
            matrix[i, j] = val if val is not None else -1

    fig, ax = plt.subplots(1, 1, figsize=(14, 6))
    im = ax.imshow(matrix, cmap='YlOrRd', aspect='auto')

    ax.set_xticks(range(len(suffix_labels)))
    ax.set_xticklabels(suffix_labels, rotation=45, ha='right', fontsize=8)
    ax.set_yticks(range(len(prefix_labels)))
    ax.set_yticklabels(prefix_labels, fontsize=10)

    ax.set_xlabel('Suffix v', fontsize=12)
    ax.set_ylabel('Prefix u', fontsize=12)
    ax.set_title('Residual Functions: L(u·v) for each prefix u\n'
                 'Each row is a residual; identical rows ↔ Nerode equivalence',
                 fontsize=13, fontweight='bold')

    cbar = plt.colorbar(im, ax=ax, shrink=0.8)
    cbar.set_label('Cost L(u·v)', fontsize=11)

    # Add cell values
    for i in range(len(prefixes)):
        for j in range(len(suffix_labels)):
            val = int(matrix[i, j])
            ax.text(j, i, str(val), ha='center', va='center',
                    fontsize=7, color='black' if val < matrix.max() * 0.7 else 'white')

    return fig


# ===========================================================================
# Figure 3: Minimality Theorem Visualization
# ===========================================================================

def visualize_minimality():
    """Visualize the minimality theorem: Nerode automaton ≤ any recognizer."""

    # Create several automata of different sizes for the same language
    # Language: parity of number of a's (0 or 1)

    # Minimal: 2 states
    minimal = TropicalDFA(
        states=['even', 'odd'],
        alphabet=['a', 'b'],
        delta={('even', 'a'): 'odd', ('even', 'b'): 'even',
               ('odd', 'a'): 'even', ('odd', 'b'): 'odd'},
        initial='even',
        output={'even': 0, 'odd': 1}
    )

    # Redundant: 4 states (2 copies)
    redundant4 = TropicalDFA(
        states=['e0', 'o0', 'e1', 'o1'],
        alphabet=['a', 'b'],
        delta={('e0', 'a'): 'o0', ('e0', 'b'): 'e1',
               ('o0', 'a'): 'e0', ('o0', 'b'): 'o1',
               ('e1', 'a'): 'o1', ('e1', 'b'): 'e0',
               ('o1', 'a'): 'e1', ('o1', 'b'): 'o0'},
        initial='e0',
        output={'e0': 0, 'o0': 1, 'e1': 0, 'o1': 1}
    )

    # Minimize the redundant one
    minimized = minimize_automaton(redundant4)

    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    automata = [
        (minimal, "Nerode Automaton\n(2 states — minimal)"),
        (redundant4, "Redundant Automaton\n(4 states)"),
        (minimized, "After Minimization\n(2 states)")
    ]

    for ax, (dfa, title) in zip(axes, automata):
        n = len(dfa.states)
        theta = np.linspace(0, 2 * np.pi, n, endpoint=False)
        x = np.cos(theta) * 0.6
        y = np.sin(theta) * 0.6

        for i, state in enumerate(dfa.states):
            color = '#4CAF50' if dfa.output.get(state, None) == 0 else '#FF5722'
            circle = plt.Circle((x[i], y[i]), 0.15, color=color,
                                alpha=0.7, ec='black', lw=2)
            ax.add_patch(circle)

            label = str(state)[:6]
            ax.text(x[i], y[i], label, ha='center', va='center',
                    fontsize=8, fontweight='bold')

            if state == dfa.initial:
                ax.annotate('', xy=(x[i] - 0.15, y[i]),
                           xytext=(x[i] - 0.35, y[i]),
                           arrowprops=dict(arrowstyle='->', lw=2))

        ax.set_xlim(-1, 1)
        ax.set_ylim(-1, 1)
        ax.set_aspect('equal')
        ax.set_title(title, fontsize=11, fontweight='bold')
        ax.axis('off')

        # Add state count
        ax.text(0, -0.9, f"|Q| = {n}", ha='center', fontsize=14,
                fontweight='bold',
                bbox=dict(boxstyle='round', facecolor='lightyellow'))

    fig.suptitle('Minimality Theorem: |Nerode classes| ≤ |states| for any recognizer',
                 fontsize=14, fontweight='bold', y=1.02)

    return fig


# ===========================================================================
# Figure 4: Syntactic Monoid Structure
# ===========================================================================

def visualize_syntactic_monoid():
    """Visualize the syntactic transformation monoid."""

    dfa = TropicalDFA(
        states=['q0', 'q1', 'q2'],
        alphabet=['a', 'b'],
        delta={
            ('q0', 'a'): 'q1', ('q0', 'b'): 'q0',
            ('q1', 'a'): 'q2', ('q1', 'b'): 'q1',
            ('q2', 'a'): 'q0', ('q2', 'b'): 'q2',
        },
        initial='q0',
        output={'q0': 0, 'q1': 1, 'q2': 2}
    )

    monoid = compute_syntactic_monoid(dfa, max_word_len=5)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Show transformations as permutation matrices
    ax1 = axes[0]
    transforms = list(monoid.keys())[:9]
    words = [monoid[t] for t in transforms]

    n_show = min(len(transforms), 9)
    cell_size = 1.0

    for idx in range(n_show):
        row, col = divmod(idx, 3)
        transform = transforms[idx]
        word = words[idx]
        word_str = ''.join(word) if word else 'ε'

        x_offset = col * 4
        y_offset = -row * 4

        ax1.text(x_offset + 1.5, y_offset + 1, word_str,
                ha='center', fontsize=9, fontweight='bold')

        for i, (src, dst) in enumerate(zip(dfa.states, transform)):
            color = '#2196F3' if src == dst else '#FF9800'
            ax1.add_patch(plt.Rectangle(
                (x_offset + i * cell_size, y_offset - 1),
                cell_size, cell_size, facecolor=color, alpha=0.5,
                edgecolor='black'))
            ax1.text(x_offset + i * cell_size + 0.5,
                    y_offset - 0.5, f"{src}→{dst}",
                    ha='center', va='center', fontsize=7)

    ax1.set_xlim(-0.5, 12.5)
    ax1.set_ylim(-12, 2)
    ax1.set_title(f'Syntactic Monoid Elements\n({len(monoid)} transformations)',
                  fontsize=12, fontweight='bold')
    ax1.axis('off')

    # Right: Idempotence check
    ax2 = axes[1]
    idempotent_count = 0
    non_idempotent_count = 0

    for transform, word in monoid.items():
        # Check f∘f = f
        composed = tuple(dfa.run(dfa.run(q, word), word) for q in dfa.states)
        is_idemp = (composed == transform)
        if is_idemp:
            idempotent_count += 1
        else:
            non_idempotent_count += 1

    labels = ['Idempotent\n(f∘f = f)', 'Non-idempotent\n(f∘f ≠ f)']
    sizes = [idempotent_count, non_idempotent_count]
    colors = ['#4CAF50', '#FF5722']
    explode = (0.05, 0.05)

    if all(s > 0 for s in sizes):
        ax2.pie(sizes, explode=explode, labels=labels, colors=colors,
                autopct='%1.0f%%', shadow=True, startangle=90,
                textprops={'fontsize': 11})
    else:
        ax2.bar(labels, sizes, color=colors)

    ax2.set_title('Idempotence in Syntactic Monoid\n'
                  '(Not all elements are idempotent!)',
                  fontsize=12, fontweight='bold')

    fig.suptitle('Tropical Syntactic Transformation Monoid',
                 fontsize=14, fontweight='bold')

    return fig


# ===========================================================================
# Generate all figures
# ===========================================================================

def generate_all_figures():
    """Generate all visualization figures and save them."""
    print("Generating visualizations...")

    fig1 = visualize_nerode_classes()
    fig1.savefig('nerode_classes.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ nerode_classes.png")

    fig2 = visualize_residual_landscape()
    fig2.savefig('residual_landscape.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ residual_landscape.png")

    fig3 = visualize_minimality()
    fig3.savefig('minimality_theorem.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ minimality_theorem.png")

    fig4 = visualize_syntactic_monoid()
    fig4.savefig('syntactic_monoid.png', dpi=150, bbox_inches='tight',
                 facecolor='white')
    print("  ✓ syntactic_monoid.png")

    # Return base64 versions for JSON package
    return {
        'nerode_classes': fig_to_base64(visualize_nerode_classes()),
        'residual_landscape': fig_to_base64(visualize_residual_landscape()),
        'minimality_theorem': fig_to_base64(visualize_minimality()),
        'syntactic_monoid': fig_to_base64(visualize_syntactic_monoid()),
    }


if __name__ == '__main__':
    generate_all_figures()
    print("\nAll visualizations generated successfully.")
