#!/usr/bin/env python3
"""
Tropical Myhill–Nerode: Algorithms

Implements the core algorithms from the tropical Myhill–Nerode theory:
1. Nerode partition computation
2. Nerode automaton construction (minimal tropical DFA)
3. Minimality verification
4. Syntactic monoid computation
"""

from __future__ import annotations
from dataclasses import dataclass, field
from typing import Callable, Optional
import itertools
import time

INF = float('inf')


@dataclass
class TropicalDFA:
    """Deterministic tropical (min-plus) finite automaton."""
    n_states: int
    alphabet: list[str]
    step: list[dict[str, int]]
    init: int
    out: list[float]

    def eval_state(self, q: int, word: list[str]) -> int:
        for a in word:
            q = self.step[q][a]
        return q

    def eval_cost(self, word: list[str]) -> float:
        return self.out[self.eval_state(self.init, word)]

    def transition_function(self, word: list[str]) -> tuple[int, ...]:
        """The transition function of a word: a tuple mapping state → state."""
        return tuple(self.eval_state(q, word) for q in range(self.n_states))


# ---------------------------------------------------------------------------
# Algorithm 1: Nerode Partition via Refinement
# ---------------------------------------------------------------------------

def compute_nerode_partition(
    automaton: TropicalDFA,
    max_suffix_len: int = 10
) -> dict[int, int]:
    """Compute the Nerode partition of states.
    
    Two states q, q' are Nerode-equivalent if they have the same residual:
      ∀ w, out(eval(q, w)) = out(eval(q', w))
    
    Returns: mapping from state → equivalence class id.
    
    Time complexity: O(|σ|² · |Σ|^max_suffix_len)
    Space complexity: O(|σ| · |Σ|^max_suffix_len)
    """
    alphabet = automaton.alphabet
    n = automaton.n_states

    # Compute residual signatures for each state
    suffixes = []
    for k in range(max_suffix_len + 1):
        suffixes.extend(itertools.product(alphabet, repeat=k))

    signatures: dict[int, tuple[float, ...]] = {}
    for q in range(n):
        sig = tuple(automaton.out[automaton.eval_state(q, list(w))] for w in suffixes)
        signatures[q] = sig

    # Group states by signature
    sig_to_class: dict[tuple[float, ...], int] = {}
    state_to_class: dict[int, int] = {}
    
    for q in range(n):
        sig = signatures[q]
        if sig not in sig_to_class:
            sig_to_class[sig] = len(sig_to_class)
        state_to_class[q] = sig_to_class[sig]

    return state_to_class


# ---------------------------------------------------------------------------
# Algorithm 2: Nerode Automaton Construction
# ---------------------------------------------------------------------------

def build_nerode_automaton(
    automaton: TropicalDFA,
    max_suffix_len: int = 10
) -> TropicalDFA:
    """Construct the minimal Nerode automaton from a given DFA.
    
    Algorithm:
    1. Compute Nerode partition (merge equivalent states)
    2. Build quotient automaton with one state per equivalence class
    3. Inherit transitions and output from representatives
    
    Time complexity: O(|σ|² · |Σ|^max_suffix_len + |σ| · |Σ|)
    Space complexity: O(|σ| · |Σ|^max_suffix_len)
    
    Returns: minimal tropical DFA recognizing the same language.
    """
    partition = compute_nerode_partition(automaton, max_suffix_len)
    n_classes = len(set(partition.values()))
    
    # Find representative for each class
    class_rep: dict[int, int] = {}
    for q in range(automaton.n_states):
        c = partition[q]
        if c not in class_rep:
            class_rep[c] = q

    # Build quotient automaton
    step = [{} for _ in range(n_classes)]
    out = [0.0] * n_classes
    
    for c, rep in class_rep.items():
        out[c] = automaton.out[rep]
        for a in automaton.alphabet:
            next_state = automaton.step[rep][a]
            step[c][a] = partition[next_state]

    init = partition[automaton.init]
    
    return TropicalDFA(n_classes, automaton.alphabet, step, init, out)


# ---------------------------------------------------------------------------
# Algorithm 3: Nerode Automaton from Language Function
# ---------------------------------------------------------------------------

def build_nerode_from_language(
    L: Callable[[tuple[str, ...]], float],
    alphabet: list[str],
    max_word_len: int = 6
) -> Optional[TropicalDFA]:
    """Build the Nerode automaton directly from a language function.
    
    Algorithm:
    1. Enumerate all words up to max_word_len as potential prefixes
    2. Compute residual signature for each prefix
    3. If finitely many distinct residuals found, construct automaton
    
    Time complexity: O(|Σ|^(2·max_word_len))
    Space complexity: O(|Σ|^(2·max_word_len))
    
    Returns: TropicalDFA if finite Nerode index detected, None otherwise.
    """
    words = []
    for k in range(max_word_len + 1):
        words.extend(itertools.product(alphabet, repeat=k))
    
    # Compute residual signatures
    sig_to_class: dict[tuple[float, ...], int] = {}
    word_to_class: dict[tuple[str, ...], int] = {}
    class_rep: dict[int, tuple[str, ...]] = {}
    
    for u in words:
        sig = tuple(L(u + v) for v in words)
        if sig not in sig_to_class:
            sig_to_class[sig] = len(sig_to_class)
            class_rep[sig_to_class[sig]] = u
        word_to_class[u] = sig_to_class[sig]
    
    n_classes = len(sig_to_class)
    
    # Build automaton
    step = [{} for _ in range(n_classes)]
    out = [0.0] * n_classes
    
    for c, rep in class_rep.items():
        out[c] = L(rep)
        for a in alphabet:
            next_word = rep + (a,)
            if next_word in word_to_class:
                step[c][a] = word_to_class[next_word]
            else:
                # Word too long; try to find equivalent shorter word
                next_sig = tuple(L(next_word + v) for v in words)
                if next_sig in sig_to_class:
                    step[c][a] = sig_to_class[next_sig]
                else:
                    return None  # Can't determine; might be infinite index
    
    init = word_to_class[()]
    return TropicalDFA(n_classes, alphabet, step, init, out)


# ---------------------------------------------------------------------------
# Algorithm 4: Syntactic Monoid Computation
# ---------------------------------------------------------------------------

def compute_syntactic_monoid(
    automaton: TropicalDFA,
    max_word_len: int = 6
) -> dict[str, list]:
    """Compute the syntactic monoid of the language recognized by the automaton.
    
    The syntactic equivalence: u ≡ v iff ∀ x,y: L(xuy) = L(xvy).
    The syntactic monoid is List(Σ)/≡ with concatenation.
    
    Algorithm:
    1. For each word, compute its transition function (state → state map)
    2. Group words by transition function (which refines syntactic equivalence)
    3. Compute the monoid multiplication table
    
    Time complexity: O(|σ| · |Σ|^max_word_len)
    Space complexity: O(|σ|^|σ| · |Σ|^max_word_len)
    
    Returns: dict with 'elements', 'multiplication_table', 'word_classes'.
    """
    alphabet = automaton.alphabet
    n = automaton.n_states
    
    words = []
    for k in range(max_word_len + 1):
        words.extend(itertools.product(alphabet, repeat=k))
    
    # Compute transition functions
    tf_to_class: dict[tuple[int, ...], int] = {}
    class_rep: dict[int, tuple[str, ...]] = {}
    word_classes: dict[int, list[str]] = {}
    
    for w in words:
        tf = automaton.transition_function(list(w))
        if tf not in tf_to_class:
            tf_to_class[tf] = len(tf_to_class)
            class_rep[tf_to_class[tf]] = w
            word_classes[tf_to_class[tf]] = []
        word_classes[tf_to_class[tf]].append(''.join(w) if w else 'ε')
    
    n_elements = len(tf_to_class)
    elements = list(tf_to_class.keys())
    
    # Compute multiplication table
    mult_table = [[0] * n_elements for _ in range(n_elements)]
    for i, tf1 in enumerate(elements):
        for j, tf2 in enumerate(elements):
            # Compose: tf1 then tf2
            composed = tuple(tf2[tf1[q]] for q in range(n))
            if composed in tf_to_class:
                mult_table[i][j] = tf_to_class[composed]
            else:
                # This shouldn't happen for words up to max_word_len
                mult_table[i][j] = -1
    
    return {
        'n_elements': n_elements,
        'elements': elements,
        'multiplication_table': mult_table,
        'word_classes': word_classes,
        'class_reps': {c: ''.join(rep) if rep else 'ε' for c, rep in class_rep.items()}
    }


# ---------------------------------------------------------------------------
# Algorithm 5: Recognizability Test
# ---------------------------------------------------------------------------

def test_recognizability(
    L: Callable[[tuple[str, ...]], float],
    alphabet: list[str],
    max_len: int = 5
) -> dict[str, object]:
    """Test whether a language appears to have finite Nerode index.
    
    Heuristic: compute residual signatures for all prefixes up to max_len.
    If the number of distinct signatures stabilizes, declare finite index.
    
    Returns: dict with 'likely_finite', 'n_classes_by_depth', 'automaton'.
    """
    words_by_depth = []
    for k in range(max_len + 1):
        words_by_depth.append(list(itertools.product(alphabet, repeat=k)))
    
    all_suffixes = []
    for k in range(max_len + 1):
        all_suffixes.extend(itertools.product(alphabet, repeat=k))
    
    n_classes_by_depth = []
    all_sigs = set()
    
    for depth in range(max_len + 1):
        for u in words_by_depth[depth]:
            sig = tuple(L(u + v) for v in all_suffixes)
            all_sigs.add(sig)
        n_classes_by_depth.append(len(all_sigs))
    
    # Check if stabilized
    likely_finite = (len(n_classes_by_depth) >= 3 and 
                     n_classes_by_depth[-1] == n_classes_by_depth[-2] == n_classes_by_depth[-3])
    
    automaton = None
    if likely_finite:
        automaton = build_nerode_from_language(L, alphabet, max_len)
    
    return {
        'likely_finite': likely_finite,
        'n_classes_by_depth': n_classes_by_depth,
        'automaton': automaton
    }


# ---------------------------------------------------------------------------
# Demonstrations
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("=" * 70)
    print("ALGORITHMS: Tropical Myhill–Nerode Computations")
    print("=" * 70)

    alphabet = ['a', 'b']

    # Example 1: Minimize a redundant automaton
    print("\n--- Algorithm: Automaton Minimization ---\n")
    
    redundant = TropicalDFA(
        n_states=4,
        alphabet=alphabet,
        step=[
            {'a': 0, 'b': 1},  # q0: no b seen
            {'a': 2, 'b': 3},  # q1: first b seen
            {'a': 2, 'b': 3},  # q2: same as q1 after 'a'
            {'a': 2, 'b': 3},  # q3: same as q1 after 'b'
        ],
        init=0,
        out=[0, 1, 1, 1]
    )
    
    print(f"Original automaton: {redundant.n_states} states")
    minimal = build_nerode_automaton(redundant)
    print(f"Minimal automaton: {minimal.n_states} states")
    
    # Verify
    test_words = list(itertools.product(alphabet, repeat=0))
    for k in range(1, 8):
        test_words.extend(itertools.product(alphabet, repeat=k))
    
    all_match = all(redundant.eval_cost(list(w)) == minimal.eval_cost(list(w)) 
                    for w in test_words)
    print(f"Verification (all words ≤ 7): {'PASS' if all_match else 'FAIL'}")

    # Example 2: Build from language function
    print("\n--- Algorithm: Build from Language Function ---\n")
    
    def L_parity(w: tuple[str, ...]) -> float:
        """Cost = parity of number of a's (0 or 1)."""
        return sum(1 for c in w if c == 'a') % 2

    result = test_recognizability(L_parity, alphabet)
    print(f"L(w) = (#a's) mod 2")
    print(f"Classes by prefix depth: {result['n_classes_by_depth']}")
    print(f"Likely finite index: {result['likely_finite']}")
    if result['automaton']:
        print(f"Constructed automaton: {result['automaton'].n_states} states")

    # Example 3: Syntactic monoid
    print("\n--- Algorithm: Syntactic Monoid ---\n")
    
    small_dfa = TropicalDFA(
        n_states=3,
        alphabet=['a', 'b'],
        step=[
            {'a': 1, 'b': 0},
            {'a': 2, 'b': 0},
            {'a': 2, 'b': 0},
        ],
        init=0,
        out=[0, 1, 2]
    )
    
    monoid = compute_syntactic_monoid(small_dfa, max_word_len=5)
    print(f"Automaton: {small_dfa.n_states} states")
    print(f"Syntactic monoid: {monoid['n_elements']} elements")
    for c, words in sorted(monoid['word_classes'].items()):
        rep = monoid['class_reps'][c]
        print(f"  Element {c} (rep: {rep}): {', '.join(words[:5])}{'...' if len(words) > 5 else ''}")
    
    print(f"\nMultiplication table:")
    header = "  * |" + "".join(f" {i:2}" for i in range(monoid['n_elements']))
    print(header)
    print("  " + "-" * (len(header) - 2))
    for i in range(monoid['n_elements']):
        row = f"  {i} |"
        for j in range(monoid['n_elements']):
            row += f" {monoid['multiplication_table'][i][j]:2}"
        print(row)

    # Example 4: Non-recognizable language detection
    print("\n--- Algorithm: Non-recognizability Detection ---\n")
    
    def L_first_b(w: tuple[str, ...]) -> float:
        """Position of first 'b' (infinite if no b)."""
        for i, c in enumerate(w):
            if c == 'b':
                return float(i)
        return INF

    result = test_recognizability(L_first_b, alphabet)
    print(f"L(w) = position of first 'b'")
    print(f"Classes by prefix depth: {result['n_classes_by_depth']}")
    print(f"Likely finite index: {result['likely_finite']}")
    if not result['likely_finite']:
        print("→ Language is likely NOT recognizable (growing number of classes)")

    print("\n" + "=" * 70)
    print("All algorithm demonstrations completed!")
    print("=" * 70)
