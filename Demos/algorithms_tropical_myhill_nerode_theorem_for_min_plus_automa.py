#!/usr/bin/env python3
"""
Algorithms for Tropical Automata Theory

Implements the key algorithms from the Tropical Myhill-Nerode Theorem:
1. Tropical DFA evaluation
2. Residual computation and Nerode equivalence
3. Tropical DFA minimization (partition refinement)
4. Nerode automaton construction
5. Equivalence testing
6. Syntactic monoid computation
"""

from typing import Dict, List, Tuple, Set, Optional, FrozenSet
from dataclasses import dataclass, field
from collections import defaultdict
import itertools

INF = float('inf')


@dataclass
class TropicalDFA:
    """
    A deterministic tropical (min-plus) finite automaton.

    Attributes:
        states: Set of state identifiers
        alphabet: Set of input symbols
        transitions: Dict mapping (state, symbol) -> state
        initial: Initial state
        output: Dict mapping state -> tropical weight (float, inf = ⊤)
    """
    states: Set[str]
    alphabet: Set[str]
    transitions: Dict[Tuple[str, str], str]
    initial: str
    output: Dict[str, float]

    def eval_from(self, state: str, word: str) -> str:
        """Return the state reached from 'state' after reading 'word'."""
        for ch in word:
            state = self.transitions[(state, ch)]
        return state

    def eval_cost(self, word: str) -> float:
        """Compute the tropical cost of a word."""
        return self.output[self.eval_from(self.initial, word)]

    def reachable_states(self) -> Set[str]:
        """Compute the set of states reachable from the initial state."""
        visited: Set[str] = set()
        queue = [self.initial]
        while queue:
            state = queue.pop()
            if state in visited:
                continue
            visited.add(state)
            for a in self.alphabet:
                next_state = self.transitions[(state, a)]
                if next_state not in visited:
                    queue.append(next_state)
        return visited

    def residual_of_state(self, state: str, suffixes: List[str]) -> Tuple[float, ...]:
        """Compute the residual function at a state, evaluated on given suffixes."""
        return tuple(self.output[self.eval_from(state, w)] for w in suffixes)


def generate_words(alphabet: Set[str], max_length: int) -> List[str]:
    """Generate all words over the alphabet up to max_length."""
    words = [""]
    alpha_list = sorted(alphabet)
    for length in range(1, max_length + 1):
        for combo in itertools.product(alpha_list, repeat=length):
            words.append("".join(combo))
    return words


# =============================================================================
# Algorithm 1: Tropical DFA Minimization
# =============================================================================

def minimize_tropical_dfa(dfa: TropicalDFA, max_suffix_length: int = 10) -> TropicalDFA:
    """
    Minimize a tropical DFA using partition refinement.

    The algorithm identifies Nerode-equivalent states (states with identical
    residual functions) and merges them.

    Args:
        dfa: Input tropical DFA
        max_suffix_length: Maximum suffix length for equivalence testing

    Returns:
        Minimal equivalent tropical DFA

    Complexity: O(n² · |Σ| · L) where L = max_suffix_length
    """
    reachable = dfa.reachable_states()
    suffixes = generate_words(dfa.alphabet, max_suffix_length)

    # Compute residual for each reachable state
    state_residuals: Dict[str, Tuple[float, ...]] = {}
    for state in reachable:
        state_residuals[state] = dfa.residual_of_state(state, suffixes)

    # Group states by residual (= Nerode classes)
    classes: Dict[Tuple[float, ...], List[str]] = defaultdict(list)
    for state in reachable:
        classes[state_residuals[state]].append(state)

    # Build representative map
    representative: Dict[str, str] = {}
    for members in classes.values():
        rep = min(members)  # canonical representative
        for state in members:
            representative[state] = rep

    # Build minimal automaton
    min_states = set(representative.values())
    min_transitions: Dict[Tuple[str, str], str] = {}
    min_output: Dict[str, float] = {}

    for state in min_states:
        min_output[state] = dfa.output[state]
        for a in dfa.alphabet:
            next_state = dfa.transitions[(state, a)]
            min_transitions[(state, a)] = representative[next_state]

    return TropicalDFA(
        states=min_states,
        alphabet=dfa.alphabet,
        transitions=min_transitions,
        initial=representative[dfa.initial],
        output=min_output,
    )


# =============================================================================
# Algorithm 2: Nerode Automaton Construction
# =============================================================================

def build_nerode_automaton(
    language_func,
    alphabet: Set[str],
    max_prefix_length: int = 5,
    max_suffix_length: int = 8
) -> TropicalDFA:
    """
    Construct the canonical Nerode automaton from a language function.

    The Nerode automaton has states = distinct residual functions,
    transitions = appending a letter, output = residual at empty word.

    Args:
        language_func: Function mapping words to tropical costs
        alphabet: Input alphabet
        max_prefix_length: Maximum prefix length to explore
        max_suffix_length: Maximum suffix length for residual comparison

    Returns:
        The Nerode automaton (canonical minimal recognizer)
    """
    prefixes = generate_words(alphabet, max_prefix_length)
    suffixes = generate_words(alphabet, max_suffix_length)

    # Compute residuals for all prefixes
    residual_map: Dict[str, Tuple[float, ...]] = {}
    for u in prefixes:
        residual_map[u] = tuple(language_func(u + w) for w in suffixes)

    # Identify distinct residuals
    residual_to_state: Dict[Tuple[float, ...], str] = {}
    state_to_prefix: Dict[str, str] = {}

    for u in prefixes:
        res = residual_map[u]
        if res not in residual_to_state:
            state_name = f"[{u}]" if u else "[ε]"
            residual_to_state[res] = state_name
            state_to_prefix[state_name] = u

    states = set(residual_to_state.values())
    initial = residual_to_state[residual_map[""]]

    # Build transitions
    transitions: Dict[Tuple[str, str], str] = {}
    for state_name in states:
        prefix = state_to_prefix[state_name]
        for a in alphabet:
            extended = prefix + a
            if extended in residual_map:
                target_res = residual_map[extended]
                if target_res in residual_to_state:
                    transitions[(state_name, a)] = residual_to_state[target_res]
                else:
                    # Create new state for this residual
                    new_name = f"[{extended}]"
                    residual_to_state[target_res] = new_name
                    state_to_prefix[new_name] = extended
                    states.add(new_name)
                    transitions[(state_name, a)] = new_name

    # Build output
    output: Dict[str, float] = {}
    for state_name in states:
        prefix = state_to_prefix[state_name]
        output[state_name] = language_func(prefix)

    # Fill missing transitions with a sink state if needed
    for state in list(states):
        for a in alphabet:
            if (state, a) not in transitions:
                if "SINK" not in states:
                    states.add("SINK")
                    output["SINK"] = INF
                    for b in alphabet:
                        transitions[("SINK", b)] = "SINK"
                transitions[(state, a)] = "SINK"

    return TropicalDFA(
        states=states,
        alphabet=alphabet,
        transitions=transitions,
        initial=initial,
        output=output,
    )


# =============================================================================
# Algorithm 3: Equivalence Testing
# =============================================================================

def test_equivalence(
    dfa1: TropicalDFA,
    dfa2: TropicalDFA,
    max_word_length: int = 10
) -> Tuple[bool, Optional[str]]:
    """
    Test whether two tropical DFAs recognize the same weighted language.

    Args:
        dfa1, dfa2: Input DFAs (must have the same alphabet)
        max_word_length: Maximum word length to test

    Returns:
        (equivalent, counterexample) where counterexample is None if equivalent

    Complexity: O(n₁ · n₂ · |Σ|^L)
    """
    assert dfa1.alphabet == dfa2.alphabet, "Alphabets must match"

    words = generate_words(dfa1.alphabet, max_word_length)
    for w in words:
        c1 = dfa1.eval_cost(w)
        c2 = dfa2.eval_cost(w)
        if c1 != c2:
            return False, w

    return True, None


# =============================================================================
# Algorithm 4: Syntactic Monoid Computation
# =============================================================================

def compute_syntactic_monoid(
    dfa: TropicalDFA,
    max_word_length: int = 6
) -> Dict[Tuple[str, ...], str]:
    """
    Compute the syntactic monoid of the language recognized by a DFA.

    The syntactic monoid is the set of distinct transition functions
    induced by words, under composition.

    Args:
        dfa: Input tropical DFA
        max_word_length: Maximum word length to explore

    Returns:
        Dict mapping transition function (as tuple) -> representative word
    """
    reachable = sorted(dfa.reachable_states())
    words = generate_words(dfa.alphabet, max_word_length)

    monoid_elements: Dict[Tuple[str, ...], str] = {}

    for w in words:
        # Compute transition function for word w
        trans = tuple(dfa.eval_from(s, w) for s in reachable)
        if trans not in monoid_elements:
            monoid_elements[trans] = w

    return monoid_elements


# =============================================================================
# Algorithm 5: Nerode Index Computation
# =============================================================================

def compute_nerode_index(dfa: TropicalDFA, max_suffix_length: int = 8) -> int:
    """
    Compute the Nerode index of the language recognized by a DFA.

    This is the number of distinct residual functions, which equals
    the number of states in the minimal equivalent DFA.

    Args:
        dfa: Input tropical DFA
        max_suffix_length: Maximum suffix length for residual comparison

    Returns:
        The Nerode index
    """
    reachable = dfa.reachable_states()
    suffixes = generate_words(dfa.alphabet, max_suffix_length)

    residuals: Set[Tuple[float, ...]] = set()
    for state in reachable:
        res = dfa.residual_of_state(state, suffixes)
        residuals.add(res)

    return len(residuals)


# =============================================================================
# Main: Run all algorithms on example instances
# =============================================================================

if __name__ == "__main__":
    print("=" * 70)
    print("TROPICAL AUTOMATA ALGORITHMS — DEMONSTRATION")
    print("=" * 70)

    # Create a test automaton
    dfa = TropicalDFA(
        states={"q0", "q1", "q2", "q3", "q4", "q5"},
        alphabet={"a", "b"},
        transitions={
            ("q0", "a"): "q1", ("q0", "b"): "q2",
            ("q1", "a"): "q3", ("q1", "b"): "q4",
            ("q2", "a"): "q3", ("q2", "b"): "q5",
            ("q3", "a"): "q3", ("q3", "b"): "q3",
            ("q4", "a"): "q3", ("q4", "b"): "q3",
            ("q5", "a"): "q3", ("q5", "b"): "q3",
        },
        initial="q0",
        output={"q0": 0, "q1": 1, "q2": 2, "q3": 5, "q4": 3, "q5": 3},
    )

    print("\n1. NERODE INDEX COMPUTATION")
    print("-" * 40)
    index = compute_nerode_index(dfa)
    print(f"   Original states: {len(dfa.states)}")
    print(f"   Nerode index: {index}")

    print("\n2. MINIMIZATION")
    print("-" * 40)
    min_dfa = minimize_tropical_dfa(dfa)
    print(f"   Original states: {len(dfa.states)}")
    print(f"   Minimal states: {len(min_dfa.states)}")
    print(f"   Minimal states: {sorted(min_dfa.states)}")

    print("\n3. EQUIVALENCE TEST")
    print("-" * 40)
    equiv, counter = test_equivalence(dfa, min_dfa, max_word_length=6)
    print(f"   Original ≡ Minimal: {equiv}")
    if counter:
        print(f"   Counterexample: \"{counter}\"")

    print("\n4. SYNTACTIC MONOID")
    print("-" * 40)
    monoid = compute_syntactic_monoid(dfa, max_word_length=4)
    print(f"   Monoid size: {len(monoid)}")
    for trans, word in sorted(monoid.items(), key=lambda x: (len(x[1]), x[1])):
        word_str = f'"{word}"' if word else '"ε"'
        trans_str = " → ".join(f"{s}↦{t}" for s, t in
                               zip(sorted(dfa.reachable_states()), trans))
        print(f"   {word_str:8s}: {trans_str}")

    print("\n5. NERODE AUTOMATON CONSTRUCTION")
    print("-" * 40)
    nerode = build_nerode_automaton(dfa.eval_cost, dfa.alphabet,
                                     max_prefix_length=4, max_suffix_length=5)
    print(f"   Nerode automaton states: {len(nerode.states)}")
    print(f"   States: {sorted(nerode.states)}")

    # Verify correctness
    words = generate_words(dfa.alphabet, 5)
    mismatches = 0
    for w in words:
        c1 = dfa.eval_cost(w)
        c2 = nerode.eval_cost(w)
        if c1 != c2:
            mismatches += 1
            print(f"   MISMATCH on \"{w}\": DFA={c1}, Nerode={c2}")
    if mismatches == 0:
        print(f"   ✓ Verified on {len(words)} words: Nerode automaton is correct")

    print("\n" + "=" * 70)
    print("All algorithms completed successfully.")
    print("=" * 70)
