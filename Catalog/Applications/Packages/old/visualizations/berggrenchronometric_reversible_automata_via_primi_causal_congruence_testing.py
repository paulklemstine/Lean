#!/usr/bin/env python3
"""
Berggren–Chronometric Reversible Automata: Core Algorithms

Implements the algorithms from the research paper with full docstrings,
type hints, and complexity analysis.
"""

from enum import Enum
from typing import List, Optional, Tuple, Dict, Set
from dataclasses import dataclass
import numpy as np


class BerggrenStep(Enum):
    """The three Berggren generators."""
    A = 0
    B = 1
    C = 2

BerggrenWord = List[BerggrenStep]


# ═══════════════════════════════════════════════════════════════
# Algorithm 1: Chronometric Length Computation
# ═══════════════════════════════════════════════════════════════

STEP_COSTS = {BerggrenStep.A: 1, BerggrenStep.B: 2, BerggrenStep.C: 2}

def chronometric_length(w: BerggrenWord) -> int:
    """
    Compute the chronometric length of a Berggren word.

    Time complexity: O(n) where n = len(w)
    Space complexity: O(1)

    >>> chronometric_length([])
    0
    >>> chronometric_length([BerggrenStep.A, BerggrenStep.B])
    3
    """
    return sum(STEP_COSTS[s] for s in w)


def reverse_inv(w: BerggrenWord) -> BerggrenWord:
    """
    Time reversal of a Berggren word. Since each step is self-inverse,
    this is just list reversal.

    Time complexity: O(n)
    Space complexity: O(n)

    Property: reverse_inv(reverse_inv(w)) == w (involutive)
    Property: chronometric_length(reverse_inv(w)) == chronometric_length(w)
    """
    return list(reversed(w))


# ═══════════════════════════════════════════════════════════════
# Algorithm 2: Berggren Matrix Evaluation
# ═══════════════════════════════════════════════════════════════

BERGGREN_MATRICES = {
    BerggrenStep.A: np.array([[1, -2, 2], [2, -1, 2], [2, -2, 3]]),
    BerggrenStep.B: np.array([[1, 2, 2], [2, 1, 2], [2, 2, 3]]),
    BerggrenStep.C: np.array([[-1, 2, 2], [-2, 1, 2], [-2, 2, 3]]),
}

ROOT = np.array([3, 4, 5])

def eval_berggren_word(w: BerggrenWord) -> np.ndarray:
    """
    Evaluate a Berggren word to produce a primitive Pythagorean triple.
    Steps are applied right-to-left (compositionally).

    Time complexity: O(n) matrix multiplications = O(n) since matrices are 3×3
    Space complexity: O(1)

    >>> eval_berggren_word([])
    array([3, 4, 5])
    >>> eval_berggren_word([BerggrenStep.A])
    array([ 5, 12, 13])
    """
    result = ROOT.copy()
    for s in reversed(w):
        result = BERGGREN_MATRICES[s] @ result
    return result


# ═══════════════════════════════════════════════════════════════
# Algorithm 3: Reversible Orbit Automaton
# ═══════════════════════════════════════════════════════════════

@dataclass
class ReversibleAutomaton:
    """
    A reversible automaton on a finite state space.

    Attributes:
        n_states: Number of states
        start: Initial state index
        transitions: Dict mapping (state, step) -> next_state
        back_transitions: Dict mapping (state, step) -> prev_state
    """
    n_states: int
    start: int
    transitions: Dict[Tuple[int, BerggrenStep], int]
    back_transitions: Dict[Tuple[int, BerggrenStep], int]

    def run(self, w: BerggrenWord) -> int:
        """
        Run the automaton on a word (right-to-left application).

        Time complexity: O(|w|)
        Space complexity: O(1)
        """
        state = self.start
        for s in reversed(w):
            state = self.transitions[(state, s)]
        return state

    def run_backward(self, w: BerggrenWord) -> int:
        """
        Run the automaton backward on a word.

        Time complexity: O(|w|)
        """
        state = self.start
        for s in w:
            state = self.back_transitions[(state, s)]
        return state


def make_cyclic_automaton(n: int = 3) -> ReversibleAutomaton:
    """
    Construct the cyclic orbit automaton on Z/nZ.
    A: +1 mod n, B: +2 mod n, C: identity.

    >>> auto = make_cyclic_automaton(3)
    >>> auto.run([BerggrenStep.A])
    1
    >>> auto.run([BerggrenStep.A, BerggrenStep.A, BerggrenStep.A])
    0
    """
    transitions = {}
    back_transitions = {}
    for q in range(n):
        transitions[(q, BerggrenStep.A)] = (q + 1) % n
        transitions[(q, BerggrenStep.B)] = (q + 2) % n
        transitions[(q, BerggrenStep.C)] = q
        back_transitions[(q, BerggrenStep.A)] = (q - 1) % n
        back_transitions[(q, BerggrenStep.B)] = (q - 2) % n
        back_transitions[(q, BerggrenStep.C)] = q
    return ReversibleAutomaton(n, 0, transitions, back_transitions)


# ═══════════════════════════════════════════════════════════════
# Algorithm 4: Causal Congruence Testing
# ═══════════════════════════════════════════════════════════════

def test_causal_congruence_finite(
    auto: ReversibleAutomaton,
    u: BerggrenWord,
    v: BerggrenWord,
    max_suffix_length: int = 5
) -> Tuple[bool, Optional[BerggrenWord]]:
    """
    Test causal congruence by checking all suffixes up to a given length.
    For finite automata, suffixes of length up to |states| suffice.

    Returns (is_congruent, separating_suffix_if_not).

    Time complexity: O(3^k · (|u| + |v|)) where k = max_suffix_length
    Space complexity: O(3^k)
    """
    steps = list(BerggrenStep)
    for length in range(max_suffix_length + 1):
        for suffix in _all_words(length):
            uw = u + suffix
            vw = v + suffix
            if auto.run(uw) != auto.run(vw):
                return False, suffix
    return True, None


def _all_words(length: int) -> List[BerggrenWord]:
    """Generate all BerggrenWords of a given length."""
    if length == 0:
        return [[]]
    steps = list(BerggrenStep)
    return [list(combo) for combo in __import__('itertools').product(steps, repeat=length)]


# ═══════════════════════════════════════════════════════════════
# Algorithm 5: Entropy and Extension Counting
# ═══════════════════════════════════════════════════════════════

def causal_entropy(n: int) -> int:
    """
    Compute the causal entropy proxy: 3^n.

    Time complexity: O(log n) via repeated squaring
    """
    return 3 ** n


def nb_extension_count(n: int) -> int:
    """
    Non-backtracking extension count: 1 if n=0, else 3·2^(n-1).

    Time complexity: O(log n)
    """
    if n == 0:
        return 1
    return 3 * (2 ** (n - 1))


def adjacent_repeat_count(w: BerggrenWord) -> int:
    """
    Count adjacent repeated steps in a word.

    Time complexity: O(n)
    Space complexity: O(1)

    >>> adjacent_repeat_count([BerggrenStep.A, BerggrenStep.B])
    0
    >>> adjacent_repeat_count([BerggrenStep.B, BerggrenStep.A, BerggrenStep.A])
    1
    """
    count = 0
    for i in range(len(w) - 1):
        if w[i] == w[i + 1]:
            count += 1
    return count


# ═══════════════════════════════════════════════════════════════
# Algorithm 6: Berggren Tree Enumeration
# ═══════════════════════════════════════════════════════════════

def enumerate_berggren_tree(max_depth: int) -> List[Tuple[BerggrenWord, np.ndarray]]:
    """
    Enumerate all primitive Pythagorean triples up to a given Berggren depth.

    Time complexity: O(3^d) where d = max_depth
    Space complexity: O(3^d)

    Returns list of (word, triple) pairs.
    """
    results = [([], ROOT.copy())]
    frontier = [([s], eval_berggren_word([s])) for s in BerggrenStep]

    for depth in range(1, max_depth + 1):
        next_frontier = []
        for w, t in frontier:
            results.append((w, t))
            if depth < max_depth:
                for s in BerggrenStep:
                    new_w = [s] + w
                    new_t = BERGGREN_MATRICES[s] @ t
                    next_frontier.append((new_w, new_t))
        frontier = next_frontier

    return results


# ═══════════════════════════════════════════════════════════════
# Security Proxy Computations
# ═══════════════════════════════════════════════════════════════

def post_quantum_security_level(w: BerggrenWord) -> int:
    """Post-quantum security parameter: 2 * chronometric_length."""
    return 2 * chronometric_length(w)

def lattice_trapdoor_cost(w: BerggrenWord) -> int:
    """Lattice trapdoor cost: chronometric_length + depth."""
    return chronometric_length(w) + len(w)

def quantum_certified_radius(w: BerggrenWord) -> int:
    """Quantum certified radius proxy."""
    return chronometric_length(w)


if __name__ == "__main__":
    # Quick verification
    auto = make_cyclic_automaton(3)
    assert auto.run([BerggrenStep.A]) == 1
    assert auto.run([BerggrenStep.A, BerggrenStep.A, BerggrenStep.A]) == 0

    # Verify reversibility
    for s in BerggrenStep:
        for q in range(3):
            assert auto.back_transitions[(auto.transitions[(q, s)], s)] == q
            assert auto.transitions[(auto.back_transitions[(q, s)], s)] == q
    print("✓ All reversibility axioms verified")

    # Verify Pythagorean property
    triples = enumerate_berggren_tree(3)
    for w, t in triples:
        assert t[0]**2 + t[1]**2 == t[2]**2, f"Failed for {w}: {t}"
    print(f"✓ Pythagorean property verified for {len(triples)} triples")

    # Verify strict separation
    u = [BerggrenStep.A, BerggrenStep.B]
    v = [BerggrenStep.B, BerggrenStep.A]
    assert adjacent_repeat_count(u) == adjacent_repeat_count(v)
    assert adjacent_repeat_count(u + [BerggrenStep.A]) != adjacent_repeat_count(v + [BerggrenStep.A])
    print("✓ Strict separation verified")

    print("All algorithm tests passed!")


#!/usr/bin/env python3
"""
Berggren–Chronometric Reversible Automata: Applications

Real-world applications of the formal theory to cryptography,
machine learning robustness, and thermodynamic computation analysis.
"""

import numpy as np