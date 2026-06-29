#!/usr/bin/env python3
"""
algorithms.py — Algorithms from the Berggren Automaton Realization Theory

Implements:
1. Residual discovery algorithm (finds all distinct residuals)
2. Canonical residual automaton construction
3. Minimality verification
4. Hankel matrix construction and rank computation
5. Berggren tree enumeration
"""

import numpy as np
from typing import Callable, Dict, List, Set, Tuple, Optional
from collections import defaultdict
from itertools import product

# ============================================================
# Berggren Infrastructure
# ============================================================

BERG_A = np.array([[ 1, -2,  2], [ 2, -1,  2], [ 2, -2,  3]])
BERG_B = np.array([[ 1,  2,  2], [ 2,  1,  2], [ 2,  2,  3]])
BERG_C = np.array([[-1,  2,  2], [-2,  1,  2], [-2,  2,  3]])
MATRICES = {'A': BERG_A, 'B': BERG_B, 'C': BERG_C}
LETTERS = ['A', 'B', 'C']


def apply_berggren_word(word: str, start: Tuple[int, int, int] = (3, 4, 5)) -> Tuple[int, int, int]:
    """Apply a Berggren word to a triple, producing a new Pythagorean triple.

    Args:
        word: String of letters from {A, B, C}
        start: Initial Pythagorean triple

    Returns:
        The resulting primitive Pythagorean triple

    Example:
        >>> apply_berggren_word('A')
        (5, 12, 13)
    """
    v = np.array(start)
    for ch in word:
        v = MATRICES[ch] @ v
    return tuple(int(x) for x in v)


def enumerate_berggren_tree(max_depth: int) -> Dict[str, Tuple[int, int, int]]:
    """Enumerate all Berggren tree nodes up to a given depth.

    Args:
        max_depth: Maximum word length

    Returns:
        Dictionary mapping words to Pythagorean triples

    Time complexity: O(3^max_depth)
    Space complexity: O(3^max_depth)
    """
    result = {'': (3, 4, 5)}
    frontier = ['']

    for _ in range(max_depth):
        new_frontier = []
        for word in frontier:
            for letter in LETTERS:
                new_word = word + letter
                result[new_word] = apply_berggren_word(new_word)
                new_frontier.append(new_word)
        frontier = new_frontier

    return result


# ============================================================
# Algorithm 1: Residual Discovery
# ============================================================

def generate_all_words(max_length: int) -> List[str]:
    """Generate all Berggren words up to max_length.

    Time: O(3^max_length), Space: O(3^max_length)
    """
    words = ['']
    for length in range(1, max_length + 1):
        for w in product(LETTERS, repeat=length):
            words.append(''.join(w))
    return words


class ResidualDiscovery:
    """Discovers distinct residuals of a Berggren stream.

    Algorithm:
        1. Fix a set of test words T for distinguishing residuals
        2. For each prefix u (in BFS order), compute signature
           sig(u) = (S(u+t) for t in T)
        3. Two prefixes u, v have the same residual iff sig(u) = sig(v)
        4. Track new signatures as new residual states

    Time: O(|words| * |test_words|) stream evaluations
    Space: O(|distinct_residuals| * |test_words|)
    """

    def __init__(self, stream: Callable[[str], any],
                 test_depth: int = 4, search_depth: int = 6):
        """
        Args:
            stream: The Berggren stream S: words → K
            test_depth: Depth of test words for distinguishing residuals
            search_depth: Maximum depth to search for new residuals
        """
        self.stream = stream
        self.test_words = generate_all_words(test_depth)
        self.search_depth = search_depth

    def compute_signature(self, prefix: str) -> Tuple:
        """Compute the residual signature of a prefix.

        The signature uniquely identifies the residual (up to test_depth).
        """
        return tuple(self.stream(prefix + tw) for tw in self.test_words)

    def discover(self) -> Dict[Tuple, str]:
        """Discover all distinct residuals.

        Returns:
            Dictionary mapping signatures to representative words
        """
        residuals: Dict[Tuple, str] = {}
        words = generate_all_words(self.search_depth)

        for w in words:
            sig = self.compute_signature(w)
            if sig not in residuals:
                residuals[sig] = w

        return residuals

    def is_finite_rank(self, growth_threshold: int = 3) -> Tuple[bool, int]:
        """Heuristically determine if the stream has finite residual rank.

        Checks if the number of distinct residuals stabilizes as depth increases.

        Returns:
            (is_finite, estimated_rank)
        """
        prev_count = 0
        stable_count = 0

        for depth in range(1, self.search_depth + 1):
            words = generate_all_words(depth)
            sigs = set()
            for w in words:
                sigs.add(self.compute_signature(w))

            if len(sigs) == prev_count:
                stable_count += 1
            else:
                stable_count = 0

            if stable_count >= growth_threshold:
                return True, len(sigs)

            prev_count = len(sigs)

        return False, prev_count


# ============================================================
# Algorithm 2: Canonical Residual Automaton
# ============================================================

class BerggrenAutomaton:
    """A finite-state weighted Berggren automaton.

    Attributes:
        n_states: Number of states
        transitions: Dict mapping (state, letter) → state
        initial_state: Index of start state
        outputs: Dict mapping state → output value
    """

    def __init__(self, n_states: int, transitions: Dict[Tuple[int, str], int],
                 initial_state: int, outputs: Dict[int, any]):
        self.n_states = n_states
        self.transitions = transitions
        self.initial_state = initial_state
        self.outputs = outputs

    def run(self, word: str) -> int:
        """Process a word and return the final state.

        Time: O(len(word))
        """
        state = self.initial_state
        for ch in word:
            state = self.transitions[(state, ch)]
        return state

    def evaluate(self, word: str) -> any:
        """Evaluate the automaton on a word: output(run(word)).

        Time: O(len(word))
        """
        return self.outputs[self.run(word)]

    def verify(self, stream: Callable[[str], any], max_depth: int = 5) -> bool:
        """Verify the automaton recognizes the stream up to max_depth.

        Time: O(3^max_depth * max_depth)
        """
        for w in generate_all_words(max_depth):
            if self.evaluate(w) != stream(w):
                return False
        return True

    def __repr__(self):
        lines = [f"BerggrenAutomaton(states={self.n_states}, initial={self.initial_state})"]
        lines.append("  Transitions:")
        for (s, a), t in sorted(self.transitions.items()):
            lines.append(f"    δ(q{s}, {a}) = q{t}")
        lines.append("  Outputs:")
        for s, o in sorted(self.outputs.items()):
            lines.append(f"    out(q{s}) = {o}")
        return '\n'.join(lines)


def build_residual_automaton(stream: Callable[[str], any],
                              test_depth: int = 4,
                              search_depth: int = 6) -> Optional[BerggrenAutomaton]:
    """Build the canonical residual automaton for a stream.

    Algorithm (Residual Automaton Construction):
        1. Discover all distinct residuals via ResidualDiscovery
        2. Assign state indices to each distinct residual
        3. Compute transitions: δ(state_u, a) = state of residual at u+a
        4. Compute outputs: out(state_u) = S(representative_u)
        5. Initial state = state of ε-residual (the stream itself)

    Time: O(3^search_depth * 3^test_depth) stream evaluations
    Space: O(n_states * 3^test_depth) for signatures

    Args:
        stream: The Berggren stream
        test_depth: Depth of test words
        search_depth: Search depth for residuals

    Returns:
        BerggrenAutomaton if finite rank detected, None otherwise
    """
    discovery = ResidualDiscovery(stream, test_depth, search_depth)
    is_finite, rank = discovery.is_finite_rank()

    if not is_finite:
        return None

    residuals = discovery.discover()

    # Assign indices
    sig_to_idx = {}
    idx_to_rep = {}
    for i, (sig, rep) in enumerate(residuals.items()):
        sig_to_idx[sig] = i
        idx_to_rep[i] = rep

    n_states = len(residuals)

    # Build transitions
    transitions = {}
    for sig, rep in residuals.items():
        state = sig_to_idx[sig]
        for letter in LETTERS:
            next_sig = discovery.compute_signature(rep + letter)
            if next_sig in sig_to_idx:
                transitions[(state, letter)] = sig_to_idx[next_sig]
            else:
                # Shouldn't happen if properly saturated
                transitions[(state, letter)] = state  # self-loop fallback

    # Build outputs
    outputs = {sig_to_idx[sig]: stream(rep) for sig, rep in residuals.items()}

    # Initial state
    init_sig = discovery.compute_signature('')
    initial_state = sig_to_idx[init_sig]

    return BerggrenAutomaton(n_states, transitions, initial_state, outputs)


# ============================================================
# Algorithm 3: Hankel Matrix Construction
# ============================================================

def build_hankel_matrix(stream: Callable[[str], float],
                         row_depth: int = 3,
                         col_depth: int = 3) -> np.ndarray:
    """Build the Hankel matrix H[u,v] = S(u ++ v).

    The (i,j) entry is S(row_words[i] + col_words[j]).

    Args:
        stream: The Berggren stream
        row_depth: Maximum length of row-indexing words
        col_depth: Maximum length of column-indexing words

    Returns:
        NumPy array representing the Hankel matrix

    Time: O(3^row_depth * 3^col_depth)
    """
    row_words = generate_all_words(row_depth)
    col_words = generate_all_words(col_depth)

    H = np.zeros((len(row_words), len(col_words)))
    for i, u in enumerate(row_words):
        for j, v in enumerate(col_words):
            H[i, j] = stream(u + v)

    return H


def hankel_rank(stream: Callable[[str], float],
                row_depth: int = 3, col_depth: int = 3,
                tol: float = 1e-10) -> int:
    """Compute the numerical rank of the Hankel matrix.

    This gives an upper bound on the minimal automaton size.

    Args:
        stream: The Berggren stream (must return numeric values)
        row_depth: Maximum row word length
        col_depth: Maximum column word length
        tol: Tolerance for rank determination

    Returns:
        Numerical rank of the Hankel matrix
    """
    H = build_hankel_matrix(stream, row_depth, col_depth)
    return int(np.linalg.matrix_rank(H, tol=tol))


# ============================================================
# Algorithm 4: Minimality Verification
# ============================================================

def verify_minimality(automaton: BerggrenAutomaton,
                       stream: Callable[[str], any],
                       test_depth: int = 4) -> Dict[str, any]:
    """Verify minimality of an automaton for a given stream.

    Checks:
    1. The automaton recognizes the stream (soundness)
    2. All states are reachable
    3. All states produce distinct residuals (no equivalent states)
    4. |states| = |distinct residuals| (minimality)

    Returns:
        Dictionary with verification results
    """
    results = {}

    # Check soundness
    results['sound'] = automaton.verify(stream, test_depth)

    # Check reachability
    reachable = set()
    frontier = [automaton.initial_state]
    while frontier:
        s = frontier.pop()
        if s in reachable:
            continue
        reachable.add(s)
        for letter in LETTERS:
            frontier.append(automaton.transitions[(s, letter)])
    results['all_reachable'] = len(reachable) == automaton.n_states
    results['reachable_states'] = len(reachable)

    # Count distinct residuals
    discovery = ResidualDiscovery(stream, test_depth, test_depth + 2)
    residuals = discovery.discover()
    results['distinct_residuals'] = len(residuals)

    # Minimality check
    results['is_minimal'] = results['reachable_states'] == results['distinct_residuals']

    return results


# ============================================================
# Main Demo
# ============================================================

if __name__ == '__main__':
    print("=" * 60)
    print("ALGORITHM DEMONSTRATIONS")
    print("=" * 60)

    # Example 1: Length parity stream
    print("\n--- Example 1: Length Parity Stream ---")
    parity_stream = lambda w: len(w) % 2

    auto = build_residual_automaton(parity_stream, test_depth=3, search_depth=4)
    if auto:
        print(auto)
        print(f"\nVerification: {auto.verify(parity_stream, 5)}")

        results = verify_minimality(auto, parity_stream, 3)
        print(f"Minimality check: {results}")

    # Example 2: Depth mod 3
    print("\n--- Example 2: Depth mod 3 Stream ---")
    mod3_stream = lambda w: len(w) % 3

    auto3 = build_residual_automaton(mod3_stream, test_depth=3, search_depth=5)
    if auto3:
        print(auto3)
        print(f"\nVerification: {auto3.verify(mod3_stream, 5)}")

    # Example 3: Hankel rank
    print("\n--- Example 3: Hankel Matrix Rank ---")
    for name, stream in [("length parity", parity_stream),
                          ("depth mod 3", mod3_stream),
                          ("constant 1", lambda w: 1.0)]:
        rank = hankel_rank(stream, 3, 3)
        print(f"  Hankel rank of '{name}': {rank}")

    # Example 4: Berggren tree enumeration
    print("\n--- Example 4: Berggren Tree (depth 3) ---")
    tree = enumerate_berggren_tree(3)
    print(f"  Total triples: {len(tree)}")
    print(f"  Sample: {list(tree.items())[:5]}")

    # Verify all are Pythagorean
    all_pyth = all(a**2 + b**2 == c**2 for a, b, c in tree.values())
    print(f"  All Pythagorean: {all_pyth}")
