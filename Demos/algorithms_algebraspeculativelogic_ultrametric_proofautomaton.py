#!/usr/bin/env python3
"""
Ultrametric Proof Automaton Duality — Algorithms

Implements the key algorithms from the research:
1. Minimal proof automaton construction
2. Observer separation distance computation
3. Ultrametric verification
4. Trace profile computation and comparison

All algorithms include docstrings, type hints, and complexity analysis.
"""

from typing import Callable, TypeVar, Any, Optional
from collections import defaultdict
from itertools import product as cartprod
import numpy as np

S = TypeVar('S')  # State type
A = TypeVar('A')  # Alphabet type
O = TypeVar('O')  # Observer type
V = TypeVar('V')  # Value type


class ProofSystem:
    """A finite proof system with states, contraction symbols, and observers.

    Attributes:
        states: List of proof states.
        alphabet: List of contraction symbols.
        observers: List of observer indices.
        step: Transition function (symbol, state) -> state.
        obs: Observer function (observer, state) -> value.
    """

    def __init__(self, states: list, alphabet: list, observers: list,
                 step: Callable, obs: Callable):
        self.states = states
        self.alphabet = alphabet
        self.observers = observers
        self.step = step
        self.obs = obs

    def run_word(self, word: list, state) -> Any:
        """Apply a contraction word to a state.

        Time: O(|word|)
        """
        p = state
        for a in word:
            p = self.step(a, p)
        return p

    def build_trace(self, state, max_word_len: int) -> dict:
        """Compute the trace profile of a state.

        Returns a dictionary mapping (word, observer) -> value.

        Time: O(|A|^L * |O|) where L = max_word_len, A = alphabet, O = observers
        Space: O(|A|^L * |O|)
        """
        trace = {}
        for length in range(max_word_len + 1):
            for word in cartprod(self.alphabet, repeat=length):
                result = self.run_word(list(word), state)
                for o in self.observers:
                    trace[(tuple(word), o)] = self.obs(o, result)
        return trace


class MinimalAutomaton:
    """The minimal quotient automaton of a proof system.

    Constructed by partitioning states into observational equivalence classes.

    Attributes:
        classes: List of equivalence classes (each a list of original states).
        class_map: Dictionary mapping original state -> class index.
        transitions: Dictionary mapping (symbol, class_index) -> class_index.
        outputs: Dictionary mapping (observer, class_index) -> value.
    """

    def __init__(self, system: ProofSystem, max_word_len: Optional[int] = None):
        """Construct the minimal automaton.

        Args:
            system: The proof system to minimize.
            max_word_len: Maximum word length for trace computation.
                         Defaults to |states| - 1 (sufficient by pumping).

        Time: O(|P|^2 * |A|^L * |O|) where P = states, L = max_word_len
        Space: O(|P| * |A|^L * |O|)
        """
        if max_word_len is None:
            max_word_len = len(system.states) - 1

        self.system = system

        # Step 1: Compute trace profiles
        traces = {}
        for p in system.states:
            t = system.build_trace(p, max_word_len)
            traces[p] = tuple(sorted(t.items()))

        # Step 2: Partition by trace equality
        class_dict = defaultdict(list)
        for p, key in traces.items():
            class_dict[key].append(p)

        self.classes = list(class_dict.values())
        self.class_map = {}
        for i, cls in enumerate(self.classes):
            for p in cls:
                self.class_map[p] = i

        # Step 3: Compute quotient transitions
        self.transitions = {}
        for a in system.alphabet:
            for i, cls in enumerate(self.classes):
                rep = cls[0]
                target = system.step(a, rep)
                self.transitions[(a, i)] = self.class_map[target]

        # Step 4: Compute quotient observer outputs
        self.outputs = {}
        for o in system.observers:
            for i, cls in enumerate(self.classes):
                rep = cls[0]
                self.outputs[(o, i)] = system.obs(o, rep)

    @property
    def num_states(self) -> int:
        """Number of states in the minimal automaton."""
        return len(self.classes)

    def transition(self, symbol, class_idx: int) -> int:
        """Apply a transition in the quotient automaton."""
        return self.transitions[(symbol, class_idx)]

    def output(self, observer, class_idx: int):
        """Get observer output for a quotient state."""
        return self.outputs[(observer, class_idx)]

    def verify_well_defined(self) -> bool:
        """Verify that transitions are independent of class representative.

        Time: O(|classes| * max_class_size * |A|)
        """
        for a in self.system.alphabet:
            for i, cls in enumerate(self.classes):
                targets = set()
                for p in cls:
                    target = self.system.step(a, p)
                    targets.add(self.class_map[target])
                if len(targets) > 1:
                    return False
        return True


def observer_separation(system: ProofSystem, p, q) -> float:
    """Compute the observer separation distance between two states.

    obsSep(p, q) = max_o |obs(o, p) - obs(o, q)|

    Time: O(|O|)
    """
    return max(abs(system.obs(o, p) - system.obs(o, q))
               for o in system.observers)


def distance_matrix(system: ProofSystem) -> np.ndarray:
    """Compute the full observer separation distance matrix.

    Time: O(|P|^2 * |O|)
    """
    n = len(system.states)
    D = np.zeros((n, n))
    for i, p in enumerate(system.states):
        for j, q in enumerate(system.states):
            D[i, j] = observer_separation(system, p, q)
    return D


def verify_ultrametric(D: np.ndarray, tol: float = 1e-10) -> tuple[bool, list]:
    """Verify that a distance matrix satisfies the ultrametric inequality.

    Checks d(x,z) ≤ max(d(x,y), d(y,z)) for all triples.

    Time: O(n^3)

    Returns:
        (is_ultrametric, list_of_violations)
    """
    n = D.shape[0]
    violations = []
    for i in range(n):
        for j in range(n):
            for k in range(n):
                if D[i, k] > max(D[i, j], D[j, k]) + tol:
                    violations.append((i, j, k, D[i, k], max(D[i, j], D[j, k])))
    return len(violations) == 0, violations


def verify_isosceles(D: np.ndarray, tol: float = 1e-10) -> bool:
    """Verify the isosceles property: all non-equilateral triangles are isosceles.

    Time: O(n^3)
    """
    n = D.shape[0]
    for i in range(n):
        for j in range(n):
            for k in range(n):
                sides = sorted([D[i,j], D[j,k], D[i,k]])
                if sides[0] < sides[1] - tol:
                    # Non-equilateral: two largest must be equal
                    if abs(sides[1] - sides[2]) > tol:
                        return False
    return True


def trace_semimodule_generators(system: ProofSystem, max_word_len: int) -> list:
    """Compute the generators of the trace semimodule.

    Returns distinct trace profiles (one per equivalence class).

    Time: O(|P| * |A|^L * |O|)
    """
    seen = set()
    generators = []
    for p in system.states:
        t = system.build_trace(p, max_word_len)
        key = tuple(sorted(t.items()))
        if key not in seen:
            seen.add(key)
            generators.append((p, t))
    return generators


# ============================================================
# Example usage
# ============================================================

if __name__ == "__main__":
    # Example: 4-state system with swap and Boolean observer
    system = ProofSystem(
        states=[0, 1, 2, 3],
        alphabet=[0, 1],
        observers=[0],
        step=lambda a, p: {0: {0:1, 1:0, 2:3, 3:2}, 1: {0:0, 1:1, 2:2, 3:3}}[a][p],
        obs=lambda o, p: p % 2
    )

    print("Proof System: 4 states, swap/identity, parity observer")
    print()

    # Build minimal automaton
    aut = MinimalAutomaton(system)
    print(f"Original states: {len(system.states)}")
    print(f"Minimal automaton states: {aut.num_states}")
    print(f"Equivalence classes: {aut.classes}")
    print(f"Well-defined: {aut.verify_well_defined()}")
    print()

    # Distance matrix
    D = distance_matrix(system)
    print("Distance matrix:")
    print(D)
    print()

    is_ultra, violations = verify_ultrametric(D)
    print(f"Ultrametric: {is_ultra}")
    print(f"Isosceles: {verify_isosceles(D)}")
    print()

    # Trace generators
    gens = trace_semimodule_generators(system, 3)
    print(f"Trace semimodule generators: {len(gens)}")
    for p, t in gens:
        print(f"  State {p}: {dict(list(t.items())[:6])}...")
