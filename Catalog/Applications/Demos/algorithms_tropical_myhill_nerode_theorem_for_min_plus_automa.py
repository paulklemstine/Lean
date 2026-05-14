#!/usr/bin/env python3
"""
Tropical Myhill–Nerode: Algorithms

Implements the core algorithms from the tropical Myhill–Nerode theorem:
- Residual computation
- Nerode equivalence testing
- Canonical Nerode automaton construction
- Minimality verification
- Syntactic monoid computation
"""

import itertools
from collections import defaultdict
from typing import Dict, List, Tuple, Optional, Callable, Set, FrozenSet

INF = float('inf')


def residual(L: Callable, u: List[str]) -> Callable:
    """
    Compute the right residual of L at prefix u.

    residual(L, u)(v) = L(u ++ v)

    Args:
        L: Weighted language L : List[str] → float (or inf)
        u: Prefix word

    Returns:
        Function v ↦ L(u + v)
    """
    return lambda v: L(u + v)


def nerode_equivalent(L: Callable, u: List[str], v: List[str],
                       probe_words: List[List[str]]) -> bool:
    """
    Test whether u ~_L v (tropical Nerode equivalence).

    Two words are Nerode-equivalent iff their residuals agree on all suffixes.
    Since we can't test all suffixes, we probe a finite set.

    Args:
        L: Weighted language
        u, v: Words to compare
        probe_words: Finite set of suffixes to test

    Returns:
        True if residuals agree on all probe words (approximate equivalence)
    """
    for w in probe_words:
        if abs(L(u + w) - L(v + w)) > 1e-12:
            return False
    return True


def generate_words(alphabet: List[str], max_len: int) -> List[List[str]]:
    """Generate all words over alphabet up to given length."""
    words = [[]]
    for length in range(1, max_len + 1):
        for combo in itertools.product(alphabet, repeat=length):
            words.append(list(combo))
    return words


class TropicalDFA:
    """
    A deterministic tropical (min-plus) finite automaton.

    Attributes:
        states: Set of state identifiers
        alphabet: List of symbols
        transitions: Dict mapping (state, symbol) → state
        init_state: Initial state
        output: Dict mapping state → WithTop ℕ (cost)
    """

    def __init__(self, states, alphabet, transitions, init_state, output):
        self.states = states
        self.alphabet = alphabet
        self.transitions = transitions
        self.init_state = init_state
        self.output = output

    def run(self, state, word: List[str]):
        """Run the automaton from state on word, returning final state."""
        for symbol in word:
            state = self.transitions[(state, symbol)]
        return state

    def evaluate(self, word: List[str]) -> float:
        """Evaluate the automaton's cost on a word."""
        final_state = self.run(self.init_state, word)
        return self.output[final_state]

    def recognizes(self, L: Callable, test_words: List[List[str]]) -> bool:
        """Check if automaton recognizes L on a set of test words."""
        for w in test_words:
            if abs(self.evaluate(w) - L(w)) > 1e-12:
                return False
        return True

    def reachable_states(self, max_word_len: int = 10):
        """Compute reachable states by BFS."""
        reached = {self.init_state}
        frontier = [self.init_state]
        for _ in range(max_word_len):
            new_frontier = []
            for state in frontier:
                for symbol in self.alphabet:
                    next_state = self.transitions[(state, symbol)]
                    if next_state not in reached:
                        reached.add(next_state)
                        new_frontier.append(next_state)
            frontier = new_frontier
            if not frontier:
                break
        return reached

    def num_reachable(self, max_word_len: int = 10) -> int:
        return len(self.reachable_states(max_word_len))


class NerodeAutomaton:
    """
    The canonical Nerode automaton for a weighted language.

    Construction algorithm:
    1. Enumerate words up to max_word_len
    2. Compute residual fingerprints (evaluations on probe suffixes)
    3. Identify equivalence classes
    4. Build the canonical automaton with residual classes as states

    This implements the constructive content of the tropical Myhill–Nerode theorem.

    Complexity:
        Let n = |alphabet|, k = max_word_len, p = probe_len.
        - Word enumeration: O(n^k) words
        - Fingerprinting: O(n^k · n^p) evaluations of L
        - State identification: O(n^k) using hash maps
        - Total: O(n^(k+p)) evaluations of L

    Args:
        L: Weighted language L : List[str] → float
        alphabet: List of alphabet symbols
        max_word_len: Maximum prefix length to explore
        probe_len: Maximum suffix length for residual fingerprinting
    """

    def __init__(self, L: Callable, alphabet: List[str],
                 max_word_len: int = 6, probe_len: int = 4):
        self.L = L
        self.alphabet = alphabet
        self.max_word_len = max_word_len
        self.probe_len = probe_len

        # Generate probe words (suffixes for fingerprinting)
        self.probes = generate_words(alphabet, probe_len)

        # Build the automaton
        self._build()

    def _fingerprint(self, u: List[str]) -> Tuple:
        """Compute the residual fingerprint of prefix u."""
        return tuple(self.L(u + w) for w in self.probes)

    def _build(self):
        """Construct the Nerode automaton."""
        # Map fingerprints to state IDs
        self.fp_to_state = {}
        self.state_to_rep = {}  # state ID → representative word
        self.state_to_fp = {}   # state ID → fingerprint
        self.word_to_state = {} # word → state ID

        next_state_id = 0
        words = generate_words(self.alphabet, self.max_word_len)

        for w in words:
            fp = self._fingerprint(w)
            w_key = tuple(w)
            if fp not in self.fp_to_state:
                self.fp_to_state[fp] = next_state_id
                self.state_to_rep[next_state_id] = w
                self.state_to_fp[next_state_id] = fp
                next_state_id += 1
            self.word_to_state[w_key] = self.fp_to_state[fp]

        self.num_states_val = next_state_id

        # Build transitions
        self.transitions = {}
        for state_id in range(next_state_id):
            rep = self.state_to_rep[state_id]
            for a in self.alphabet:
                extended = rep + [a]
                ext_key = tuple(extended)
                if ext_key in self.word_to_state:
                    self.transitions[(state_id, a)] = self.word_to_state[ext_key]
                else:
                    # Word beyond max_word_len — fingerprint it
                    fp = self._fingerprint(extended)
                    if fp in self.fp_to_state:
                        self.transitions[(state_id, a)] = self.fp_to_state[fp]
                    else:
                        # New state discovered (shouldn't happen for finite-index languages
                        # with large enough max_word_len)
                        self.fp_to_state[fp] = next_state_id
                        self.state_to_rep[next_state_id] = extended
                        self.state_to_fp[next_state_id] = fp
                        self.transitions[(state_id, a)] = next_state_id
                        next_state_id += 1
                        self.num_states_val = next_state_id

        # Initial state
        self.init_state = self.word_to_state[()]

        # Output function
        self.output = {}
        for state_id, rep in self.state_to_rep.items():
            self.output[state_id] = self.L(rep)

    def num_states(self) -> int:
        """Number of states (= number of distinct residuals found)."""
        return self.num_states_val

    def evaluate(self, word: List[str]) -> float:
        """Evaluate the Nerode automaton on a word."""
        state = self.init_state
        for a in word:
            if (state, a) in self.transitions:
                state = self.transitions[(state, a)]
            else:
                raise ValueError(f"No transition for ({state}, {a})")
        return self.output[state]

    def get_classes(self) -> Dict[str, List[str]]:
        """Get the equivalence classes (representative → members)."""
        classes = defaultdict(list)
        for w_tuple, state_id in self.word_to_state.items():
            rep = self.state_to_rep[state_id]
            rep_str = ''.join(rep) if rep else 'ε'
            w_str = ''.join(w_tuple) if w_tuple else 'ε'
            classes[rep_str].append(w_str)
        return dict(classes)

    def print_transitions(self):
        """Print the transition table."""
        for state_id in sorted(self.state_to_rep.keys()):
            rep = ''.join(self.state_to_rep[state_id]) or 'ε'
            out = self.output[state_id]
            for a in self.alphabet:
                target = self.transitions.get((state_id, a), '?')
                target_rep = ''.join(self.state_to_rep.get(target, [])) or 'ε'
                print(f"  δ([{rep}], {a}) = [{target_rep}]  (output: {out})")

    def compute_syntactic_monoid(self, max_word_len: int = 4) -> Dict[str, Tuple]:
        """
        Compute the syntactic transformation monoid.

        Each word w induces a transformation τ_w on states.
        The monoid is the set of all such transformations.

        Returns:
            Dict mapping word string → transformation tuple
        """
        monoid = {}
        words = generate_words(self.alphabet, max_word_len)

        for w in words:
            # Compute the transformation induced by w
            transform = []
            for state_id in sorted(self.state_to_rep.keys()):
                rep = self.state_to_rep[state_id]
                extended = rep + w
                fp = self._fingerprint(extended)
                if fp in self.fp_to_state:
                    transform.append(self.fp_to_state[fp])
                else:
                    transform.append(-1)  # unknown

            transform_tuple = tuple(transform)
            w_str = ''.join(w)
            if transform_tuple not in set(monoid.values()):
                monoid[w_str] = transform_tuple

        return monoid

    def to_tdfa(self) -> TropicalDFA:
        """Convert to a TropicalDFA object."""
        states = set(range(self.num_states_val))
        return TropicalDFA(
            states=states,
            alphabet=self.alphabet,
            transitions=self.transitions,
            init_state=self.init_state,
            output=self.output
        )


def minimize_tdfa(dfa: TropicalDFA, L: Callable,
                  max_word_len: int = 6, probe_len: int = 4) -> NerodeAutomaton:
    """
    Minimize a tropical DFA using the Nerode construction.

    Algorithm:
    1. Extract the language recognized by the DFA
    2. Build the Nerode automaton for that language
    3. Return the minimal automaton

    Complexity: Same as NerodeAutomaton construction.

    Args:
        dfa: The automaton to minimize
        L: The language it recognizes (or compute from dfa)
        max_word_len: Maximum prefix length
        probe_len: Maximum probe suffix length

    Returns:
        The minimal Nerode automaton
    """
    return NerodeAutomaton(L, dfa.alphabet, max_word_len, probe_len)


def verify_minimality(dfa: TropicalDFA, nerode: NerodeAutomaton,
                       test_words: List[List[str]]) -> dict:
    """
    Verify the minimality theorem: |Nerode states| ≤ |reachable DFA states|.

    Also verifies the surjection from reachable states to Nerode classes.

    Returns:
        Dictionary with verification results
    """
    reachable = dfa.reachable_states()
    nerode_states = nerode.num_states()

    # Compute the surjection
    surjection = {}
    for state in reachable:
        # Find a word reaching this state
        word = None
        for w in test_words:
            if dfa.run(dfa.init_state, w) == state:
                word = w
                break
        if word is not None:
            fp = nerode._fingerprint(word)
            nerode_state = nerode.fp_to_state.get(fp, -1)
            surjection[state] = nerode_state

    # Check surjectivity
    image = set(surjection.values())
    all_nerode_states = set(range(nerode_states))
    is_surjective = image >= all_nerode_states

    return {
        'reachable_states': len(reachable),
        'nerode_states': nerode_states,
        'lower_bound_holds': nerode_states <= len(reachable),
        'surjection_computed': surjection,
        'is_surjective': is_surjective,
    }


if __name__ == '__main__':
    # Quick test
    alphabet = ['a', 'b']
    L = lambda w: min(len(w), 3)

    print("Building Nerode automaton for L(w) = min(|w|, 3)...")
    nerode = NerodeAutomaton(L, alphabet, max_word_len=6, probe_len=5)
    print(f"States: {nerode.num_states()}")
    print(f"Monoid size: {len(nerode.compute_syntactic_monoid())}")

    # Verify
    for k in range(7):
        w = ['a'] * k
        print(f"  L({'a'*k or 'ε'}) = {L(w)}, automaton = {nerode.evaluate(w)}")
