#!/usr/bin/env python3
"""
Algorithms for Tropical Myhill–Nerode Theory

Implements the core algorithms arising from the tropical Myhill–Nerode theorem:
1. Residual computation and Nerode class discovery
2. Canonical Nerode automaton construction
3. Automaton minimization via residual quotient
4. Syntactic transformation monoid computation
5. Recognizability testing

All algorithms work over the min-plus semiring (WithTop ℕ):
  - addition = min
  - multiplication = +
  - zero = ∞ (None)
  - one = 0
"""

from __future__ import annotations
from typing import (Callable, Dict, FrozenSet, List, Optional,
                     Set, Tuple, Any)
from dataclasses import dataclass, field
from collections import defaultdict
import itertools

# ---------------------------------------------------------------------------
# Types
# ---------------------------------------------------------------------------

Cost = Optional[int]       # None represents ∞ (top)
Symbol = Any               # alphabet symbol
Word = Tuple[Symbol, ...]  # a word is a tuple of symbols


# ---------------------------------------------------------------------------
# Min-Plus Semiring Operations
# ---------------------------------------------------------------------------

def tropical_add(a: Cost, b: Cost) -> Cost:
    """Tropical addition: min(a, b), with None = ∞."""
    if a is None: return b
    if b is None: return a
    return min(a, b)


def tropical_mul(a: Cost, b: Cost) -> Cost:
    """Tropical multiplication: a + b, with None = ∞."""
    if a is None or b is None: return None
    return a + b


# ---------------------------------------------------------------------------
# Algorithm 1: Word Enumeration
# ---------------------------------------------------------------------------

def enumerate_words(alphabet: List[Symbol], max_length: int) -> List[Word]:
    """
    Enumerate all words over alphabet up to max_length.

    Time complexity: O(|Σ|^(max_length+1))
    Space complexity: O(|Σ|^(max_length+1))

    Args:
        alphabet: List of symbols
        max_length: Maximum word length

    Returns:
        List of all words (as tuples) of length 0..max_length
    """
    words: List[Word] = [()]
    frontier = [()]
    for _ in range(max_length):
        new_frontier = []
        for w in frontier:
            for a in alphabet:
                new_word = w + (a,)
                words.append(new_word)
                new_frontier.append(new_word)
        frontier = new_frontier
    return words


# ---------------------------------------------------------------------------
# Algorithm 2: Residual Computation
# ---------------------------------------------------------------------------

def compute_residual(
    L: Callable[[Word], Cost],
    prefix: Word,
    test_suffixes: List[Word]
) -> Tuple[Cost, ...]:
    """
    Compute a finite approximation of the residual function at prefix u.

    The residual is: (Res_L u)(v) = L(u ++ v)

    We approximate it by evaluating on a finite set of test suffixes.

    Time complexity: O(|test_suffixes| · T_L) where T_L is cost of evaluating L
    Space complexity: O(|test_suffixes|)

    Args:
        L: Weighted language function
        prefix: The prefix word u
        test_suffixes: Finite set of suffix words to test

    Returns:
        Tuple of costs, one per test suffix (the "residual signature")
    """
    return tuple(L(prefix + v) for v in test_suffixes)


# ---------------------------------------------------------------------------
# Algorithm 3: Nerode Equivalence Class Discovery
# ---------------------------------------------------------------------------

def discover_nerode_classes(
    L: Callable[[Word], Cost],
    alphabet: List[Symbol],
    max_prefix_len: int = 5,
    max_suffix_len: int = 5
) -> Dict[Tuple[Cost, ...], List[Word]]:
    """
    Discover Nerode equivalence classes by residual fingerprinting.

    Two prefixes u, v are Nerode-equivalent iff their residuals agree
    on all suffixes. We approximate this by testing suffixes up to
    max_suffix_len.

    Time complexity: O(|Σ|^max_prefix_len · |Σ|^max_suffix_len · T_L)
    Space complexity: O(|Σ|^max_prefix_len · |Σ|^max_suffix_len)

    Pseudocode:
        NERODE-CLASSES(L, Σ, k_pre, k_suf):
        1. suffixes ← ENUMERATE(Σ, k_suf)
        2. prefixes ← ENUMERATE(Σ, k_pre)
        3. classes ← empty map
        4. for each u in prefixes:
        5.     sig ← (L(u++v) : v ∈ suffixes)
        6.     classes[sig].append(u)
        7. return classes

    Args:
        L: Weighted language
        alphabet: Alphabet symbols
        max_prefix_len: Max length of prefixes to explore
        max_suffix_len: Max length of suffixes to test

    Returns:
        Dictionary mapping residual signatures to lists of equivalent prefixes
    """
    suffixes = enumerate_words(alphabet, max_suffix_len)
    prefixes = enumerate_words(alphabet, max_prefix_len)

    classes: Dict[Tuple[Cost, ...], List[Word]] = defaultdict(list)
    for u in prefixes:
        sig = compute_residual(L, u, suffixes)
        classes[sig].append(u)

    return dict(classes)


# ---------------------------------------------------------------------------
# Algorithm 4: Tropical DFA
# ---------------------------------------------------------------------------

@dataclass
class TropicalDFA:
    """
    A deterministic tropical (min-plus) finite automaton.

    Attributes:
        states: List of state identifiers
        alphabet: List of alphabet symbols
        delta: Transition function as dict (state, symbol) -> state
        initial: Initial state
        output: Output function as dict state -> Cost
    """
    states: List[Any]
    alphabet: List[Symbol]
    delta: Dict[Tuple[Any, Symbol], Any]
    initial: Any
    output: Dict[Any, Cost]

    def run(self, state: Any, word: Word) -> Any:
        """Process word from given state. O(|word|)."""
        for a in word:
            state = self.delta[(state, a)]
        return state

    def evaluate(self, word: Word) -> Cost:
        """Compute cost of word. O(|word|)."""
        return self.output[self.run(self.initial, word)]

    def reachable_states(self, max_len: int = 10) -> Set[Any]:
        """Find all reachable states via BFS."""
        visited = {self.initial}
        frontier = {self.initial}
        for _ in range(max_len):
            new_frontier = set()
            for q in frontier:
                for a in self.alphabet:
                    q2 = self.delta.get((q, a))
                    if q2 is not None and q2 not in visited:
                        visited.add(q2)
                        new_frontier.add(q2)
            frontier = new_frontier
            if not frontier:
                break
        return visited

    def transition_function(self, word: Word) -> Dict[Any, Any]:
        """Compute the transition function induced by word on all states."""
        return {q: self.run(q, word) for q in self.states}


# ---------------------------------------------------------------------------
# Algorithm 5: Nerode Automaton Construction
# ---------------------------------------------------------------------------

def build_nerode_automaton(
    L: Callable[[Word], Cost],
    alphabet: List[Symbol],
    max_prefix_len: int = 5,
    max_suffix_len: int = 5
) -> TropicalDFA:
    """
    Construct the canonical minimal Nerode automaton for L.

    This is the central construction from the tropical Myhill–Nerode theorem.
    States are Nerode equivalence classes (identified by residual signatures).
    The transition on symbol a sends [u] to [u·a].
    Output at [u] is L(u).

    Time complexity: O(|Σ|^max_prefix_len · |Σ|^max_suffix_len · T_L)
    Space complexity: O(|classes| · |Σ|)

    Pseudocode:
        NERODE-AUTOMATON(L, Σ, k_pre, k_suf):
        1. classes ← NERODE-CLASSES(L, Σ, k_pre, k_suf)
        2. states ← keys of classes
        3. for each state sig, symbol a:
        4.     rep ← shortest member of classes[sig]
        5.     sig' ← RESIDUAL(L, rep·a, suffixes)
        6.     delta[sig, a] ← sig'
        7. init ← RESIDUAL(L, ε, suffixes)
        8. output[sig] ← L(shortest rep of sig)
        9. return DFA(states, delta, init, output)

    Args:
        L: Weighted language
        alphabet: Alphabet
        max_prefix_len: Exploration depth for prefixes
        max_suffix_len: Test depth for suffixes

    Returns:
        A TropicalDFA that is the canonical Nerode automaton for L
    """
    suffixes = enumerate_words(alphabet, max_suffix_len)
    classes = discover_nerode_classes(L, alphabet, max_prefix_len, max_suffix_len)

    # Representative for each class: shortest word
    reps = {sig: min(members, key=len) for sig, members in classes.items()}

    # State identifiers are the signatures themselves
    states = list(classes.keys())

    # Build transitions using worklist (capped to avoid infinite loops)
    delta = {}
    worklist = list(states)
    visited = set(states)
    max_states = len(states) * len(alphabet) * 2 + 100  # safety cap
    while worklist and len(visited) < max_states:
        sig = worklist.pop(0)
        rep = reps[sig]
        for a in alphabet:
            extended = rep + (a,)
            ext_sig = compute_residual(L, extended, suffixes)
            if ext_sig not in visited:
                visited.add(ext_sig)
                states.append(ext_sig)
                reps[ext_sig] = extended
                classes[ext_sig] = [extended]
                worklist.append(ext_sig)
            delta[(sig, a)] = ext_sig

    # Initial state
    init_sig = compute_residual(L, (), suffixes)

    # Output
    output = {sig: L(reps[sig]) for sig in states}

    return TropicalDFA(
        states=states,
        alphabet=alphabet,
        delta=delta,
        initial=init_sig,
        output=output
    )


# ---------------------------------------------------------------------------
# Algorithm 6: Automaton Minimization via Nerode Quotient
# ---------------------------------------------------------------------------

def minimize_automaton(
    A: TropicalDFA,
    max_suffix_len: int = 6
) -> TropicalDFA:
    """
    Minimize a tropical DFA by quotienting by the Nerode equivalence.

    Two states q, q' are merged iff they have identical future behavior:
    ∀ w, output(run(q, w)) = output(run(q', w))

    This is guaranteed to produce the unique minimal automaton by the
    tropical Myhill–Nerode theorem (nerode_index_le_card).

    Time complexity: O(|Q|^2 · |Σ|^max_suffix_len)
    Space complexity: O(|Q| · |Σ|^max_suffix_len)

    Args:
        A: Input tropical DFA
        max_suffix_len: Depth for distinguishing states

    Returns:
        Minimized TropicalDFA
    """
    suffixes = enumerate_words(A.alphabet, max_suffix_len)

    # Compute state signatures (future behavior fingerprints)
    state_sigs = {}
    for q in A.states:
        sig = tuple(A.output.get(A.run(q, w)) for w in suffixes)
        state_sigs[q] = sig

    # Group states by signature
    sig_to_states: Dict[tuple, List] = defaultdict(list)
    for q, sig in state_sigs.items():
        sig_to_states[sig].append(q)

    # Build minimized automaton
    new_states = list(sig_to_states.keys())
    state_to_class = {q: sig for q, sig in state_sigs.items()}

    new_delta = {}
    for sig in new_states:
        rep = sig_to_states[sig][0]
        for a in A.alphabet:
            next_state = A.delta[(rep, a)]
            new_delta[(sig, a)] = state_to_class[next_state]

    new_output = {}
    for sig in new_states:
        rep = sig_to_states[sig][0]
        new_output[sig] = A.output[rep]

    new_initial = state_to_class[A.initial]

    return TropicalDFA(
        states=new_states,
        alphabet=A.alphabet,
        delta=new_delta,
        initial=new_initial,
        output=new_output
    )


# ---------------------------------------------------------------------------
# Algorithm 7: Syntactic Transformation Monoid Computation
# ---------------------------------------------------------------------------

def compute_syntactic_monoid(
    A: TropicalDFA,
    max_word_len: int = 5
) -> Dict[Tuple, Dict[Any, Any]]:
    """
    Compute the syntactic transformation monoid of a tropical DFA.

    Each word w induces a transformation τ_w : Q → Q on states.
    The syntactic monoid is the set of all such transformations
    (under composition).

    Time complexity: O(|Σ|^max_word_len · |Q|)
    Space complexity: O(min(|Q|^|Q|, |Σ|^max_word_len) · |Q|)

    Args:
        A: Tropical DFA
        max_word_len: Maximum word length to explore

    Returns:
        Dictionary mapping transformation tuples to a representative word
    """
    words = enumerate_words(A.alphabet, max_word_len)

    monoid: Dict[Tuple, Word] = {}
    for w in words:
        # Compute the transformation induced by w
        transform = tuple(A.run(q, w) for q in A.states)
        if transform not in monoid:
            monoid[transform] = w

    return monoid


def check_idempotent(transform: Tuple, states: List, A: TropicalDFA,
                      word: Word) -> bool:
    """Check if a transformation is idempotent: f∘f = f."""
    # Apply transform twice
    first_app = {q: A.run(q, word) for q in states}
    second_app = {q: A.run(first_app[q], word) for q in states}
    return all(first_app[q] == second_app[q] for q in states)


# ---------------------------------------------------------------------------
# Algorithm 8: Recognizability Test
# ---------------------------------------------------------------------------

def test_recognizability(
    L: Callable[[Word], Cost],
    alphabet: List[Symbol],
    max_depth: int = 6
) -> Tuple[bool, int, Optional[TropicalDFA]]:
    """
    Test whether a weighted language appears recognizable.

    Uses the tropical Myhill–Nerode theorem: L is recognizable iff
    the set of residuals is finite. We check whether the number of
    distinct residuals stabilizes as we increase the exploration depth.

    Time complexity: O(|Σ|^max_depth · |Σ|^max_depth · T_L)

    Args:
        L: Weighted language
        alphabet: Alphabet
        max_depth: Maximum exploration depth

    Returns:
        (appears_recognizable, num_classes, automaton_if_recognizable)
    """
    prev_count = 0
    stable_count = 0

    for depth in range(1, max_depth + 1):
        classes = discover_nerode_classes(L, alphabet, depth, depth)
        count = len(classes)

        if count == prev_count:
            stable_count += 1
        else:
            stable_count = 0

        prev_count = count

        # If class count stabilized for 2 consecutive depths,
        # likely recognizable
        if stable_count >= 2:
            automaton = build_nerode_automaton(L, alphabet, depth, depth)
            return (True, count, automaton)

    # Count still growing — likely not recognizable
    return (False, prev_count, None)


# ---------------------------------------------------------------------------
# Demonstration
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("Tropical Myhill–Nerode: Algorithm Demonstrations")
    print("=" * 60)

    # Example: parity language
    def parity_cost(w: Word) -> Cost:
        """Cost = 0 if even number of a's, 1 if odd."""
        return sum(1 for c in w if c == 'a') % 2

    alphabet = ['a', 'b']

    print("\n1. Nerode Class Discovery (parity language)")
    classes = discover_nerode_classes(parity_cost, alphabet, 3, 3)
    print(f"   Found {len(classes)} Nerode classes")

    print("\n2. Nerode Automaton Construction")
    nerode = build_nerode_automaton(parity_cost, alphabet, 4, 4)
    print(f"   States: {len(nerode.states)}")

    # Verify
    test_words = enumerate_words(alphabet, 4)
    all_correct = all(nerode.evaluate(w) == parity_cost(w) for w in test_words)
    print(f"   Correct on all words up to length 4: {all_correct}")

    print("\n3. Minimization")
    # Build a redundant 4-state automaton
    big_dfa = TropicalDFA(
        states=['q0', 'q1', 'q2', 'q3'],
        alphabet=['a', 'b'],
        delta={
            ('q0', 'a'): 'q1', ('q0', 'b'): 'q2',
            ('q1', 'a'): 'q0', ('q1', 'b'): 'q3',
            ('q2', 'a'): 'q3', ('q2', 'b'): 'q0',
            ('q3', 'a'): 'q2', ('q3', 'b'): 'q1',
        },
        initial='q0',
        output={'q0': 0, 'q1': 1, 'q2': 0, 'q3': 1}
    )
    minimized = minimize_automaton(big_dfa)
    print(f"   Original states: {len(big_dfa.states)}")
    print(f"   Minimized states: {len(minimized.states)}")

    print("\n4. Syntactic Monoid Computation")
    monoid = compute_syntactic_monoid(big_dfa, max_word_len=4)
    print(f"   Monoid size: {len(monoid)} transformations")

    # Check idempotence
    non_idempotent = 0
    for transform, word in monoid.items():
        if not check_idempotent(transform, big_dfa.states, big_dfa, word):
            non_idempotent += 1
    print(f"   Non-idempotent elements: {non_idempotent}")

    print("\n5. Recognizability Test")
    recognizable, n_classes, auto = test_recognizability(parity_cost, alphabet)
    print(f"   Parity language recognizable: {recognizable}")
    print(f"   Number of classes: {n_classes}")

    print("\nAll algorithms executed successfully.")
